// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable {

    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStackingAmount;
    uint256 public rewardPerPeriod; 
    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public elapsePeriod;

    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    event WithdrawTokens(address userAddress_, uint256 withdrawAmount_);
    event EtherSent(uint256 amount_);

    constructor(address stakingToken_, address owner_, uint256 stakingPeriod_, uint256 fixedStakingAmount_, uint256 rewardPerPeriod_) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStackingAmount = fixedStakingAmount_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    function depositTokens(uint256 tokenAmountToDeposit_) external {
        require(tokenAmountToDeposit_ == fixedStackingAmount, "Deposit amount must be 10 tokens");
        require(userBalance[msg.sender] == 0, "You already have a deposit");

        IERC20(stakingToken).transferFrom(msg.sender, address(this), tokenAmountToDeposit_);
        userBalance[msg.sender] += tokenAmountToDeposit_;
        elapsePeriod[msg.sender] = block.timestamp;

        emit DepositTokens(msg.sender, tokenAmountToDeposit_);
    }

    function withdrawTokens() external { // CEI PATTERN
        require(userBalance[msg.sender] > 0, "You have no deposit to withdraw");

        uint256 userBalance_ = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, userBalance_);
        emit WithdrawTokens(msg.sender, userBalance_);
    }


    function claimRewards() external {
        require(userBalance[msg.sender] == fixedStackingAmount, "You have no deposit to claim rewards for");

        uint256 elapsePeriod_ = block.timestamp - elapsePeriod[msg.sender];
        require(elapsePeriod_ >= stakingPeriod, "Staking period not yet completed");

        elapsePeriod[msg.sender] = block.timestamp;

        (bool success,) = msg.sender.call{value: rewardPerPeriod}("");
        require(success, "Transfer failed.");
    }

    receive() external payable onlyOwner{
        emit EtherSent(msg.value);
    }

    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }
}

