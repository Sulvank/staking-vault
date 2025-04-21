// StakingAppTest.t.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {
    StakingToken stakingToken;
    StakingApp stakingApp;
    StakingReceiptToken receiptToken;

    string name_ = "StakingToken";
    string symbol_ = "STK";

    address owner_ = vm.addr(1);
    uint256 stakingPeriod_ = 100000000000000;
    uint256 fixedStackingAmount_ = 10;
    uint256 rewardPerPeriod_ = 1 ether;
    uint256 earlyWithdrawalPenalty_ = 500; // 5%

    address randomUser = vm.addr(2);
    address randomUser2 = vm.addr(3);

    event PenaltyApplied(address user, uint256 penaltyAmount);


    function setUp() public {
        vm.startPrank(owner_);
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(
            address(stakingToken), 
            owner_, 
            stakingPeriod_, 
            fixedStackingAmount_, 
            rewardPerPeriod_,
            earlyWithdrawalPenalty_
        );
        receiptToken = stakingApp.receiptToken();
        vm.stopPrank();
    }
    
    function testStakingTokenCorrectlyDeploy() external view {
        assert(address(stakingToken) != address(0));
    }

    function testStakingAppCorrectlyDeploy() external view{
        assert(address(stakingToken) != address(0));
        assert(address(receiptToken) != address(0));
    }

    function testShouldRevertIfNotOwner() external {
        uint256 newStakingPeriod_ = 1;
        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod_);
    }

    function testShouldChangeStakingPeriod() external {
        vm.startPrank(owner_);

        uint256 newStakingPeriod_ = 1;
        uint256 stakingPeriodBefore = stakingApp.stakingPeriod();
        stakingApp.changeStakingPeriod(newStakingPeriod_);
        uint256 stakingPeriodAfter = stakingApp.stakingPeriod();

        assert(stakingPeriodBefore != newStakingPeriod_);
        assert(stakingPeriodAfter == newStakingPeriod_);
        vm.stopPrank();
    }

    function testContractReveivesEtherCorrectly() external {
        vm.startPrank(owner_);
        vm.deal(owner_, 1 ether);

        uint256 etherValue = 1 ether;
        uint256 balanceBefore = address(stakingApp).balance;

        (bool success, ) = address(stakingApp).call{value: etherValue}("");

        uint256 balanceAfter = address(stakingApp).balance;

        require(success, "Transfer failed.");

        assert(balanceAfter - balanceBefore == etherValue);

        vm.stopPrank();
    }

    function testIncorrectAmountShouldRevert() external {
        vm.startPrank(randomUser);

        uint256 depositAmount = 1;
        vm.expectRevert("Deposit amount must be 10 tokens");
        stakingApp.depositTokens(depositAmount);

        vm.stopPrank();
    }

    function testDepositTokensCorrectly() external {
        vm.startPrank(randomUser);
        
        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        uint256 balanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 balanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(balanceAfter - balanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);
        vm.stopPrank();
    }

    function testUserCanNotDepositMoreThanOnce() external {
        vm.startPrank(randomUser);
        
        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        uint256 balanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 balanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(balanceAfter - balanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        stakingToken.mint(tokenAmount);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        vm.expectRevert("You already have a deposit");
        stakingApp.depositTokens(tokenAmount);

        vm.stopPrank();
    }

    function testWithdrawShouldRevertWithoutDeposit() external {
        vm.startPrank(randomUser);
        vm.expectRevert("You have no deposit to withdraw");
        stakingApp.withdrawTokens();
        vm.stopPrank();
    }

    function testWithdrawTokensCorrectly() external {
        vm.startPrank(randomUser);
        
        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);

        // Esperar que pase el periodo de staking
        vm.warp(block.timestamp + stakingPeriod_ + 1);

        uint256 userBalanceBefore = IERC20(stakingToken).balanceOf(randomUser);
        uint256 userBalanceInMapping = stakingApp.userBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 userBalanceAfter = IERC20(stakingToken).balanceOf(randomUser);

        assert(userBalanceAfter == userBalanceBefore + userBalanceInMapping);

        vm.stopPrank();
    }

    function testCanNotClaimIfNotStaking() external {
        vm.startPrank(randomUser);
        vm.expectRevert("You have no deposit to claim rewards for");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testCanNotClaimIfNotElapsedTime() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);

        vm.expectRevert("Staking period not yet completed");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testShouldRevertIfNoEther() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);

        vm.warp(block.timestamp +  stakingPeriod_);
        vm.expectRevert("Transfer failed.");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testCanClaimRewardsCorrectly() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);

        vm.stopPrank();

        vm.startPrank(owner_);
        uint256 etherAmount = 100000 ether;
        vm.deal(owner_, etherAmount);
        (bool success, ) = address(stakingApp).call{value: etherAmount}("");
        require(success, "Test Transfer failed.");
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.warp(block.timestamp + stakingPeriod_);
        uint256 etherAmountBefore = address(randomUser).balance;
        stakingApp.claimRewards();
        uint256 etherAmountAfter = address(randomUser).balance;
        uint256 elapsedPeriod = stakingApp.elapsePeriod(randomUser);
        assert(etherAmountAfter - etherAmountBefore == rewardPerPeriod_);
        assert(elapsedPeriod == block.timestamp);

        vm.stopPrank();
    }

    // Nuevos tests para las funcionalidades añadidas

    function testDepositTokensMintsReceiptToken() external {
        vm.startPrank(randomUser);
        
        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        uint256 receiptBalanceBefore = receiptToken.balanceOf(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 receiptBalanceAfter = receiptToken.balanceOf(randomUser);

        assertEq(receiptBalanceAfter - receiptBalanceBefore, tokenAmount);
        vm.stopPrank();
    }

    function testWithdrawEarlyAppliesPenalty() external {
        vm.startPrank(randomUser);
        
        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);

        uint256 userTokenBalanceBefore = IERC20(stakingToken).balanceOf(randomUser);
        stakingApp.withdrawTokens();
        uint256 userTokenBalanceAfter = IERC20(stakingToken).balanceOf(randomUser);

        uint256 expectedPenalty = (tokenAmount * earlyWithdrawalPenalty_) / 10000;
        uint256 expectedWithdrawAmount = tokenAmount - expectedPenalty;

        assertEq(userTokenBalanceAfter - userTokenBalanceBefore, expectedWithdrawAmount);
        assertEq(stakingApp.accumulatedFees(), expectedPenalty);
        vm.stopPrank();
    }

    function testFeeDistribution() external {
        // User 1 deposits
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp.fixedStackingAmount();
        stakingToken.mint(tokenAmount);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        vm.stopPrank();

        // User 2 deposits
        vm.startPrank(randomUser2);
        stakingToken.mint(tokenAmount);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        vm.stopPrank();

        // User 1 withdraws early
        vm.startPrank(randomUser);
        uint256 user2BalanceBefore = stakingApp.userBalance(randomUser2);
        stakingApp.withdrawTokens();
        uint256 user2BalanceAfter = stakingApp.userBalance(randomUser2);
        vm.stopPrank();

        // Verify fee was distributed to user 2
        uint256 expectedPenalty = (tokenAmount * earlyWithdrawalPenalty_) / 10000;
        assertEq(user2BalanceAfter - user2BalanceBefore, expectedPenalty);
    }

    function testCannotSetPenaltyOver100Percent() external {
        vm.startPrank(owner_);
        uint256 invalidPenalty = 10001; // 100.01%
        vm.expectRevert("Penalty cannot exceed 100%");
        stakingApp.updateEarlyWithdrawalPenalty(invalidPenalty);
        vm.stopPrank();
    }

    function testUpdateEarlyWithdrawalPenalty() external {
        vm.startPrank(owner_);
        uint256 newPenalty = 1000; // 10%
        stakingApp.updateEarlyWithdrawalPenalty(newPenalty);
        assertEq(stakingApp.earlyWithdrawalPenalty(), newPenalty);
        vm.stopPrank();
    }

    function testGetActiveStakerCount() external {
        // Initial count should be 0
        assertEq(stakingApp.getActiveStakerCount(), 0);

        // After deposit, count should be 1
        vm.startPrank(randomUser);
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        vm.stopPrank();
        
        assertEq(stakingApp.getActiveStakerCount(), 1);

        // After second user deposits, count should be 2
        vm.startPrank(randomUser2);
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        vm.stopPrank();
        
        assertEq(stakingApp.getActiveStakerCount(), 2);

        // After first user withdraws, count should be 1
        vm.startPrank(randomUser);
        stakingApp.withdrawTokens();
        vm.stopPrank();
        
        assertEq(stakingApp.getActiveStakerCount(), 1);
    }

    function testIsActiveStaker() external {
        // Initially, user should not be active staker
        assertFalse(stakingApp.isActiveStaker(randomUser));

        // After deposit, user should be active staker
        vm.startPrank(randomUser);
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        vm.stopPrank();
        
        assertTrue(stakingApp.isActiveStaker(randomUser));

        // After withdrawal, user should not be active staker
        vm.startPrank(randomUser);
        stakingApp.withdrawTokens();
        vm.stopPrank();
        
        assertFalse(stakingApp.isActiveStaker(randomUser));
    }

    function testWithdrawTokensRequiresSufficientReceiptTokens() external {
        vm.startPrank(randomUser);
        
        // Deposit tokens
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        
        // Transfer receipt tokens to another address
        receiptToken.transfer(randomUser2, fixedStackingAmount_);
        
        // Try to withdraw without receipt tokens
        vm.expectRevert("Insufficient receipt tokens");
        stakingApp.withdrawTokens();
        
        vm.stopPrank();
    }

    function testCompleteScenarioWithMultipleUsers() external {
        address[] memory users = new address[](3);
        users[0] = vm.addr(10);
        users[1] = vm.addr(11);
        users[2] = vm.addr(12);

        // All users deposit
        for (uint i = 0; i < users.length; i++) {
            vm.startPrank(users[i]);
            stakingToken.mint(fixedStackingAmount_);
            IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
            stakingApp.depositTokens(fixedStackingAmount_);
            vm.stopPrank();
        }

        // Verify active staker count
        assertEq(stakingApp.getActiveStakerCount(), 3);

        // First user withdraws early
        vm.startPrank(users[0]);
        uint256[] memory balancesBefore = new uint256[](2);
        balancesBefore[0] = stakingApp.userBalance(users[1]);
        balancesBefore[1] = stakingApp.userBalance(users[2]);
        
        stakingApp.withdrawTokens();
        
        uint256[] memory balancesAfter = new uint256[](2);
        balancesAfter[0] = stakingApp.userBalance(users[1]);
        balancesAfter[1] = stakingApp.userBalance(users[2]);
        vm.stopPrank();

        // Verify fees were distributed equally
        uint256 penalty = (fixedStackingAmount_ * earlyWithdrawalPenalty_) / 10000;
        uint256 feePerStaker = penalty / 2;

        assertEq(balancesAfter[0] - balancesBefore[0], feePerStaker);
        assertEq(balancesAfter[1] - balancesBefore[1], feePerStaker);
        assertEq(stakingApp.accumulatedFees(), 0);
        assertEq(stakingApp.getActiveStakerCount(), 2);
    }

    function testReceiveEtherDirectly() external {
        vm.startPrank(owner_);
        vm.deal(owner_, 1 ether);
        (bool success, ) = payable(address(stakingApp)).call{value: 1 ether}("");
        assertTrue(success);
        vm.stopPrank();
    }

    function testReceiveEtherShouldFailIfNotOwner() external {
        vm.deal(randomUser, 1 ether);
        vm.startPrank(randomUser);
        vm.expectRevert("Ownable: caller is not the owner");
        (bool success, ) = payable(address(stakingApp)).call{value: 1 ether}("");
        assertTrue(!success);
        vm.stopPrank();
    }

    function testPenaltyAndFeeEvents() external {
        fixedStackingAmount_ = 10000;
        earlyWithdrawalPenalty_ = 500;

        vm.startPrank(owner_);
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(
            address(stakingToken),
            owner_,
            stakingPeriod_,
            fixedStackingAmount_,
            rewardPerPeriod_,
            earlyWithdrawalPenalty_
        );
        receiptToken = stakingApp.receiptToken();
        vm.stopPrank();

        vm.startPrank(randomUser);
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        vm.stopPrank();

        vm.warp(block.timestamp + 1); // Forzar penalización

        vm.startPrank(randomUser);
        uint256 expectedPenalty = (fixedStackingAmount_ * earlyWithdrawalPenalty_) / 10000;

        vm.expectEmit(true, false, false, true);
        emit PenaltyApplied(randomUser, expectedPenalty);


        stakingApp.withdrawTokens();
        vm.stopPrank();
    }

    function testReceiptTokenBurnsOnWithdraw() external {
        vm.startPrank(randomUser);
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        stakingApp.withdrawTokens();
        assertEq(receiptToken.balanceOf(randomUser), 0);
        vm.stopPrank();
    }

    function testReceiptTokenMintedOnDeposit() external {
        vm.startPrank(randomUser);
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        assertEq(receiptToken.balanceOf(randomUser), fixedStackingAmount_);
        vm.stopPrank();
    }
    function testReceiptTokenBurnedOnWithdraw() external {
        vm.startPrank(randomUser);
        stakingToken.mint(fixedStackingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStackingAmount_);
        stakingApp.depositTokens(fixedStackingAmount_);
        stakingApp.withdrawTokens();
        assertEq(receiptToken.balanceOf(randomUser), 0);
        vm.stopPrank();
    }    
}