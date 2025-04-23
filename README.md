# 🔐 Staking Vault - ERC20 Token Vault with Receipt Tokens and Early Withdrawal Penalties

## 📝 Overview

**Staking Vault** is a smart contract based on ERC20 that allows users to deposit tokens for staking and receive receipt tokens (`StakingReceiptToken`) that represent their participation. The contract includes early withdrawal penalties and redistributes the penalties among active stakers.

> [!NOTE]
> This contract follows the OpenZeppelin ERC20 standard to ensure security and interoperability.

### 🔹 Main Features:
- ✅ **Receipt tokens (`StakingReceiptToken`)** issued when depositing tokens for staking.
- ✅ **Configurable early withdrawal penalty.**
- ✅ **Penalty redistribution** among active stakers.
- ✅ **Pause functionality** for emergencies.

---

## 🖉 Contract Flow Diagram

This diagram represents the flow of operations from the user's perspective:

![Staking Vault Flow Diagram](https://github.com/Sulvank/staking-vault/blob/main/diagrams/staking_vault_flow.png)

---

## ✨ Features

### 🏦 Receipt Tokens (`StakingReceiptToken`)
- When depositing tokens, the user receives `StakingReceiptToken`.
- `StakingReceiptToken` represent the user's staking position and are required to withdraw the original tokens.

### ⏳ Early Withdrawal Penalty
- If a user withdraws before the minimum staking period, a penalty is applied (e.g., 5%).
- The penalized amount is redistributed among the active stakers proportionally.

### 🔄 Penalty Redistribution
- Accumulated penalties are distributed among the active stakers.
- Distribution is based on the amount of `StakingReceiptToken` each staker holds.

### 🚫 Pause Functionality
- The contract owner can pause and resume staking and withdrawal operations in emergencies.

> [!IMPORTANT]
> The contract owner has admin privileges to manage penalties, pause operations, and distribute rewards.

---

## 📖 Contract Summary

### Main Functions

| 🔧 Function Name                    | 📋 Description                                                                |
|------------------------------------|--------------------------------------------------------------------------------|
| `depositTokens(uint256 amount)`    | Deposits a fixed amount of tokens and issues `StakingReceiptToken`.          |
| `withdrawTokens()`                 | Withdraws tokens; applies a penalty if done before the staking period ends.  |
| `distributeFees()`                 | Distributes accumulated penalties among active stakers.                       |
| `claimRewards()`                   | Allows claiming ETH rewards after the staking period has passed.             |
| `pause()`                          | Pauses all contract operations (owner only).                                  |
| `unpause()`                        | Resumes operations (owner only).                                              |
| `changeStakingPeriod(uint256)`     | Updates the staking duration (owner only).                                    |
| `updateEarlyWithdrawalPenalty(uint256)` | Updates early withdrawal penalty (owner only).                          |

---

## ⚙️ Prerequisites

### 🛠️ Required Tools:
- **Foundry**: To test contracts locally ([Installation Guide](https://book.getfoundry.sh/getting-started/installation)).
- **Node.js + npm** (if integrating with frontend).
- **MetaMask** (optional, for manual testing).

### 🌐 Environment:
- Solidity compiler version: `0.8.x`
- Recommended networks: local (Anvil), Goerli, Sepolia.

> [!TIP]
> Use `forge test` to run unit tests and validate the contract before deployment.

---

## 🚀 How to Use the Contract Locally

### 1️⃣ Clone and Set Up

```bash
git clone https://github.com/youruser/staking-vault.git
cd staking-vault
```

### 2️⃣ Install Foundry (if you haven’t)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 3️⃣ Run the Tests

```bash
forge test -vv
```

This will execute all tests for the `StakingApp` contract and display detailed output.

---

## 🛠️ Contract Extensions

### 🔍 Possible Enhancements
- 📈 **Oracle Integration**: Dynamically adjust penalties based on market conditions.
- ⛏️ **Reward Mechanism**: Add extra rewards for long-term stakers.
- 📊 **DAO Governance**: Enable community voting on contract parameters.
- 🔗 **Cross-Chain Bridge**: Allow token transfer between different blockchains.

> [!CAUTION]
> Ensure thorough testing and audits before adding new features to a production contract.

---

## 📜 License

This project is licensed under the MIT License. See the LICENSE file for details.

---

### 🚀 **Staking Vault: Optimize your investments with security and efficiency.**

