// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

error ERC20InvalidReceiver(address receiver);

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingTokenTest is Test {

    StakingToken stakingToken;
    string name_ = "StakingToken";
    string symbol_ = "STK";
    address randomUser = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name_, symbol_);
    }
    
    function testStakingTokenMintsCorrectly() public {
        vm.startPrank(randomUser);
        uint256 amount_ = 1 ether;

        uint256 balanceBefore_ = IERC20(address(stakingToken)).balanceOf(randomUser);

        stakingToken.mint(amount_);

        uint256 balanceAfter_ = IERC20(address(stakingToken)).balanceOf(randomUser);

        assert(balanceAfter_ == balanceBefore_ + amount_);
        vm.stopPrank();
    }

    function testTokenNameAndSymbol() public view {
        assertEq(stakingToken.name(), name_);
        assertEq(stakingToken.symbol(), symbol_);
    }

    function testMintingMultipleTimes() public {
        vm.startPrank(randomUser);
        
        uint256 amount1 = 1 ether;
        uint256 amount2 = 2 ether;
        
        stakingToken.mint(amount1);
        uint256 balanceAfterFirstMint = IERC20(address(stakingToken)).balanceOf(randomUser);
        assertEq(balanceAfterFirstMint, amount1);
        
        stakingToken.mint(amount2);
        uint256 balanceAfterSecondMint = IERC20(address(stakingToken)).balanceOf(randomUser);
        assertEq(balanceAfterSecondMint, amount1 + amount2);
        
        vm.stopPrank();
    }

    function testMintingToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ERC20InvalidReceiver.selector, address(0)));
        vm.prank(address(0));
        stakingToken.mint(1 ether);
    }

}