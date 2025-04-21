// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "./StakingReceiptToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract StakingApp is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public stakingToken;
    StakingReceiptToken public receiptToken;
    uint256 public stakingPeriod;
    uint256 public fixedStackingAmount;
    uint256 public rewardPerPeriod;
    uint256 public earlyWithdrawalPenalty; // In basis points (e.g., 500 = 5%)
    
    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public elapsePeriod;
    
    uint256 public accumulatedFees;
    EnumerableSet.AddressSet private activeStakers;

    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    event WithdrawTokens(address userAddress_, uint256 withdrawAmount_);
    event EtherSent(uint256 amount_);
    event PenaltyApplied(address userAddress_, uint256 penaltyAmount_);
    event FeesDistributed(uint256 totalFees_, uint256 activeStakers_);
    event PenaltyUpdated(uint256 newPenalty_);

    constructor(
        address stakingToken_, 
        address owner_, 
        uint256 stakingPeriod_, 
        uint256 fixedStakingAmount_, 
        uint256 rewardPerPeriod_,
        uint256 earlyWithdrawalPenalty_
    ) Ownable(owner_) {
        require(earlyWithdrawalPenalty_ <= 10000, "Penalty cannot exceed 100%");
        
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStackingAmount = fixedStakingAmount_;
        rewardPerPeriod = rewardPerPeriod_;
        earlyWithdrawalPenalty = earlyWithdrawalPenalty_;
        
        receiptToken = new StakingReceiptToken();
    }

    function depositTokens(uint256 tokenAmountToDeposit_) external {
        require(tokenAmountToDeposit_ == fixedStackingAmount, "Deposit amount must be 10 tokens");
        require(userBalance[msg.sender] == 0, "You already have a deposit");

        IERC20(stakingToken).transferFrom(msg.sender, address(this), tokenAmountToDeposit_);
        userBalance[msg.sender] += tokenAmountToDeposit_;
        elapsePeriod[msg.sender] = block.timestamp;
        activeStakers.add(msg.sender);

        receiptToken.mint(msg.sender, tokenAmountToDeposit_);

        emit DepositTokens(msg.sender, tokenAmountToDeposit_);
    }

    function withdrawTokens() external {
        require(userBalance[msg.sender] > 0, "You have no deposit to withdraw");
        require(receiptToken.balanceOf(msg.sender) >= userBalance[msg.sender], "Insufficient receipt tokens");

        uint256 userBalance_ = userBalance[msg.sender];
        uint256 withdrawAmount = userBalance_;
        
        if (block.timestamp < elapsePeriod[msg.sender] + stakingPeriod) {
            uint256 penalty = (userBalance_ * earlyWithdrawalPenalty) / 10000;
            withdrawAmount = userBalance_ - penalty;
            accumulatedFees += penalty;
            emit PenaltyApplied(msg.sender, penalty);
        }
        
        userBalance[msg.sender] = 0;
        activeStakers.remove(msg.sender);
        
        receiptToken.burn(msg.sender, userBalance_);
        IERC20(stakingToken).transfer(msg.sender, withdrawAmount);
        
        emit WithdrawTokens(msg.sender, withdrawAmount);
        
        if (accumulatedFees > 0 && activeStakers.length() > 0) {
            _distributeFees();
        }
    }

    function _distributeFees() internal {
        uint256 totalFees = accumulatedFees;
        uint256 feePerStaker = totalFees / activeStakers.length();
        uint256 remainingFees = totalFees;
        
        for (uint256 i = 0; i < activeStakers.length(); i++) {
            address staker = activeStakers.at(i);
            uint256 feeShare = (i == activeStakers.length() - 1) ? remainingFees : feePerStaker;
            
            userBalance[staker] += feeShare;
            receiptToken.mint(staker, feeShare);
            
            remainingFees -= feeShare;
        }
        
        accumulatedFees = 0;
        emit FeesDistributed(totalFees, activeStakers.length());
    }

    function claimRewards() external {
        require(userBalance[msg.sender] == fixedStackingAmount, "You have no deposit to claim rewards for");

        uint256 elapsePeriod_ = block.timestamp - elapsePeriod[msg.sender];
        require(elapsePeriod_ >= stakingPeriod, "Staking period not yet completed");

        elapsePeriod[msg.sender] = block.timestamp;

        (bool success,) = msg.sender.call{value: rewardPerPeriod}("");
        require(success, "Transfer failed.");
    }

    receive() external payable onlyOwner {
        emit EtherSent(msg.value);
    }

    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }
    
    function updateEarlyWithdrawalPenalty(uint256 newPenalty_) external onlyOwner {
        require(newPenalty_ <= 10000, "Penalty cannot exceed 100%");
        earlyWithdrawalPenalty = newPenalty_;
        emit PenaltyUpdated(newPenalty_);
    }

    function getActiveStakerCount() external view returns (uint256) {
        return activeStakers.length();
    }

    function isActiveStaker(address user) external view returns (bool) {
        return activeStakers.contains(user);
    }
}