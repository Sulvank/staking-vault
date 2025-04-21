// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Receipt token that users receive when they stake
contract StakingReceiptToken is ERC20 {
    address public stakingApp;

    constructor() ERC20("Staking Receipt Token", "stkRCPT") {
        stakingApp = msg.sender;
    }

    modifier onlyStakingApp() {
        require(msg.sender == stakingApp, "Only staking app can call this function");
        _;
    }

    function mint(address to, uint256 amount) external onlyStakingApp {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyStakingApp {
        _burn(from, amount);
    }
}