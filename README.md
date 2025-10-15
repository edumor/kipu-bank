# KipuBank Smart Contract

[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Verified](https://img.shields.io/badge/Etherscan-Verified-green.svg)](https://sepolia.etherscan.io/address/0xEA522ec9237Cb4FCe33c2E417a97a704a7924F91)

## Overview

KipuBank is a secure smart contract that implements a decentralized banking system on the Ethereum blockchain. Users can deposit ETH into personal vaults and withdraw funds with built-in security measures and transaction limits.

## Contract Information

**Network**: Sepolia Testnet  
**Contract Address**: `0xEA522ec9237Cb4FCe33c2E417a97a704a7924F91`  
**Block Explorer**: [View on Etherscan](https://sepolia.etherscan.io/address/0xEA522ec9237Cb4FCe33c2E417a97a704a7924F91)  
**Deployment Date**: October 14, 2025  
**Status**: ✅ Verified and Published

## Features

- **Personal ETH Vaults**: Users can deposit native ETH into individual accounts
- **Withdrawal Limits**: Maximum 0.1 ETH per transaction withdrawal limit
- **Global Deposit Cap**: Total bank capacity of 10 ETH
- **Transaction Tracking**: Monitors total deposits and withdrawals
- **Security First**: Implements checks-effects-interactions pattern
- **Gas Optimized**: Uses custom errors and single storage access patterns
- **Safe Transfers**: Low-level call implementation for secure ETH transfers

## Technical Implementation

### Contract Architecture

#### Immutable Variables
- `WITHDRAWAL_LIMIT`: 100000000000000000 wei (0.1 ETH)
- `BANK_CAP`: 10000000000000000000 wei (10 ETH)

#### State Variables
- `owner`: Contract deployer address
- `totalDeposited`: Total ETH currently in the bank
- `totalDeposits`: Counter of successful deposits
- `totalWithdrawals`: Counter of successful withdrawals
- `balances`: Mapping of user addresses to their balances

#### Events
- `Deposit(address indexed user, uint256 amount, uint256 newBalance)`
- `Withdrawal(address indexed user, uint256 amount, uint256 newBalance)`

#### Custom Errors (Gas Optimized)
- `CapExceeded(uint256 attempted, uint256 available)`
- `LimitExceeded(uint256 attempted, uint256 limit)`
- `LowBalance(uint256 attempted, uint256 current)`
- `ZeroDeposit()`
- `ZeroAmount()`
- `TransferFail()`

#### Security Features
- Single storage variable access per function
- Checks-effects-interactions pattern
- Custom errors for gas efficiency
- Safe ETH transfers using low-level call
- Input validation with modifiers

## How to Test the Contract (For Instructors)

The KipuBank contract is deployed and verified on Sepolia Testnet. You can interact with it directly through Etherscan without needing to deploy your own instance.

### Prerequisites for Testing

1. **MetaMask Wallet** with Sepolia Testnet configured
2. **Sepolia ETH** for transaction fees (get from [Sepolia Faucet](https://sepoliafaucet.com/))
3. **Web browser** with MetaMask extension installed

### Testing via Etherscan (Recommended)

#### Step 1: Access the Verified Contract
1. Go to [sepolia.etherscan.io/address/0xEA522ec9237Cb4FCe33c2E417a97a704a7924F91](https://sepolia.etherscan.io/address/0xEA522ec9237Cb4FCe33c2E417a97a704a7924F91)
2. Click on the **"Contract"** tab
3. You'll see the verified source code and contract functions

#### Step 2: Read Contract Functions (No Gas Required)
Click on **"Read Contract"** to view current state:

**Available Read Functions:**
- `WITHDRAWAL_LIMIT` → Returns: 100000000000000000 (0.1 ETH)
- `BANK_CAP` → Returns: 10000000000000000000 (10 ETH)
- `owner` → Returns: Contract deployer address
- `totalDeposited` → Returns: Current total ETH in bank
- `totalDeposits` → Returns: Number of deposits made
- `totalWithdrawals` → Returns: Number of withdrawals made
- `getBalance` → Input: user address → Returns: user's balance
- `getBankInfo` → Returns: All bank statistics at once

#### Step 3: Write Contract Functions (Requires Gas)
Click on **"Write Contract"** and connect your MetaMask:

1. **Connect Wallet**
   - Click "Connect to Web3"
   - Select MetaMask and approve connection
   - Ensure you're on Sepolia Testnet

2. **Test Deposit Function**
   - Find the `deposit` function
   - Enter amount in ETH (e.g., 0.01) in "payableAmount (ether)" field
   - Click "Write" and confirm transaction in MetaMask
   - Wait for confirmation

3. **Verify Deposit**
   - Go back to "Read Contract"
   - Use `getBalance` with your wallet address
   - Check `totalDeposited` and `totalDeposits` counters

4. **Test Withdrawal Function**
   - In "Write Contract", find `withdraw` function
   - Enter amount in wei (e.g., 10000000000000000 for 0.01 ETH)
   - Click "Write" and confirm transaction
   - Verify transaction in your MetaMask activity

### Test Scenarios

#### Scenario 1: Normal Deposit
```
Action: Deposit 0.01 ETH
Expected: Success, balance increases, event emitted
```

#### Scenario 2: Zero Deposit (Should Fail)
```
Action: Deposit 0 ETH
Expected: Transaction fails with "ZeroDeposit" error
```

#### Scenario 3: Exceed Bank Cap (Should Fail)
```
Action: Deposit more than remaining capacity
Expected: Transaction fails with "CapExceeded" error
```

#### Scenario 4: Normal Withdrawal
```
Action: Withdraw 0.01 ETH (after depositing)
Expected: Success, balance decreases, ETH received
```

#### Scenario 5: Exceed Withdrawal Limit (Should Fail)
```
Action: Withdraw more than 0.1 ETH
Expected: Transaction fails with "LimitExceeded" error
```

#### Scenario 6: Insufficient Balance (Should Fail)
```
Action: Withdraw more than your balance
Expected: Transaction fails with "LowBalance" error
```

### Contract Parameters

- **Withdrawal Limit**: 0.1 ETH per transaction
- **Bank Capacity**: 10 ETH total
- **Owner**: Contract deployer (can be checked in Read Contract)

### Expected Gas Costs (Approximate)

- **Deposit**: ~45,000 gas
- **Withdrawal**: ~55,000 gas
- **Read functions**: Free (no gas required)

## How to Interact with the Contract

Once deployed, you can interact with the KipuBank contract through various methods. The contract provides both read (view) and write (state-changing) functions.

### Contract Functions

#### Write Functions (State-Changing)

**1. deposit() - Payable Function**
- **Purpose**: Deposit ETH into your personal vault
- **How to use**: Send ETH along with the function call
- **Restrictions**: 
  - Amount must be greater than 0
  - Total deposits cannot exceed the bank cap
- **Example**: Send 0.5 ETH to deposit into your vault

**2. withdraw(uint256 amount)**
- **Purpose**: Withdraw ETH from your vault
- **Parameters**: 
  - `amount`: Amount to withdraw in wei
- **Restrictions**:
  - Amount must be greater than 0
  - Cannot exceed withdrawal limit (0.1 ETH per transaction)
  - Cannot exceed your current balance
- **Example**: `withdraw(50000000000000000)` to withdraw 0.05 ETH



#### Read Functions (View Functions)

**1. getBalance(address user)**
- **Purpose**: Check the balance of any user
- **Parameters**: 
  - `user`: Address of the user to check
- **Returns**: User's balance in wei
- **Example**: `getBalance(0x742d35Cc6644C068532A63C9cF3b6D6B5c5c7B7a)`

**2. getBankInfo()**
- **Purpose**: Get comprehensive bank statistics
- **Returns**: 
  - `totalDep`: Total ETH deposited in the bank
  - `totalDeps`: Total number of deposits made
  - `totalWith`: Total number of withdrawals made
  - `bankCap`: Maximum bank capacity
  - `withdrawLimit`: Maximum withdrawal per transaction

#### Public Variables (Automatically Generated View Functions)

- `WITHDRAWAL_LIMIT`: Maximum withdrawal per transaction (immutable)
- `BANK_CAP`: Maximum total deposits allowed (immutable)
- `owner`: Contract owner address
- `totalDeposited`: Current total ETH in the bank
- `totalDeposits`: Counter of all deposits
- `totalWithdrawals`: Counter of all withdrawals
- `balances(address)`: Individual user balances

### Interaction Methods

#### Method 1: Using Remix IDE

1. After deployment, scroll down to see "Deployed Contracts"
2. Expand your KipuBank contract
3. **For Write Functions**: 
   - Enter parameters if required
   - For `deposit()`: Enter ETH amount in "Value" field
   - Click the red button (state-changing function)
   - Confirm transaction in MetaMask
4. **For Read Functions**:
   - Click the blue button (view function)
   - Results display immediately (no transaction needed)

#### Method 2: Using Etherscan Block Explorer (Recommended for Testing)

Once your contract is deployed and verified on Etherscan, you can test it directly through the web interface:

1. **Access Your Contract on Etherscan**:
   - Go to [Sepolia Etherscan](https://sepolia.etherscan.io/) (or your chosen testnet)
   - Navigate to your contract address
   - Click on the "Contract" tab

2. **Testing Write Functions**:
   - Click on "Write Contract" tab
   - Connect your MetaMask wallet by clicking "Connect to Web3"
   - **Test deposit()**: 
     - Scroll to "deposit" function
     - Enter amount in ETH (e.g., 0.1) in the "payableAmount" field
     - Click "Write" and confirm in MetaMask
   - **Test withdraw()**:
     - Scroll to "withdraw" function  
     - Enter amount in wei (e.g., 50000000000000000 for 0.05 ETH)
     - Click "Write" and confirm in MetaMask

3. **Testing Read Functions**:
   - Click on "Read Contract" tab (no wallet connection needed)
   - **Test getBalance()**:
     - Enter your wallet address
     - Click "Query" to see your balance
   - **Test getBankInfo()**:
     - Click "Query" to see bank statistics
   - **View public variables**:
     - Check WITHDRAWAL_LIMIT, BANK_CAP, totalDeposited, etc.

4. **Verify Transactions**:
   - After each write operation, check the transaction hash
   - View transaction details to see events emitted
   - Verify gas usage and transaction status

#### Method 3: Direct MetaMask Interaction

1. Add contract address to MetaMask
2. Use MetaMask's contract interaction features

### Important Notes

- **Gas Fees**: All write functions require gas fees
- **Wei Conversion**: 1 ETH = 1,000,000,000,000,000,000 wei
- **Transaction Confirmation**: Wait for transaction confirmation before proceeding
- **Event Logs**: Check transaction logs for emitted events (`Deposit`, `Withdrawal`)

### Example Interactions

**Depositing 0.1 ETH:**
1. Call `deposit()` function
2. Set value to `100000000000000000` wei (0.1 ETH)
3. Confirm transaction

**Withdrawing 0.05 ETH:**
1. Call `withdraw(50000000000000000)`
2. Confirm transaction

**Checking Your Balance:**
1. Call `getBalance(YOUR_ADDRESS)`
2. View result instantly

## Testing Your Deployed Contract

After deploying your contract, you can test all functionality through Etherscan:

### Step-by-Step Testing Guide

1. **Initial Setup**:
   - Ensure your contract is deployed and verified on Etherscan
   - Have some testnet ETH in your MetaMask wallet
   - Navigate to your contract's Etherscan page

2. **Test Deposit Functionality**:
   - Go to "Write Contract" tab on Etherscan
   - Connect your MetaMask wallet
   - Find the `deposit` function
   - Enter a small amount (e.g., 0.01 ETH) in the payable amount field
   - Click "Write" and confirm the transaction
   - Check the transaction hash for the `Deposit` event

3. **Verify Your Balance**:
   - Go to "Read Contract" tab
   - Use `getBalance` function with your wallet address
   - Confirm your balance shows the deposited amount

4. **Test Withdrawal Functionality**:
   - Return to "Write Contract" tab
   - Use `withdraw` function with an amount in wei (e.g., 10000000000000000 for 0.01 ETH)
   - Confirm transaction and check for `Withdrawal` event

5. **Test Bank Information**:
   - Use `getBankInfo` function to see overall statistics
   - Verify the counters increased after your transactions

6. **Test Edge Cases**:
   - Try depositing 0 ETH (should fail with ZeroDeposit error)
   - Try withdrawing more than your balance (should fail)
   - Try withdrawing more than the limit (should fail)

### Security Features

The KipuBank contract implements several security best practices:

- **Checks-Effects-Interactions Pattern**: All validations performed before state changes
- **Custom Errors**: Gas-efficient error handling instead of require strings
- **Access Control Modifiers**: Reusable permission validation
- **Safe ETH Transfers**: Uses low-level `call` instead of deprecated `transfer`
- **Immutable Variables**: Gas optimization and enhanced security

### Validation Features

- ✅ Sufficient balance verification
- ✅ Per-transaction withdrawal limits
- ✅ Global bank deposit limits
- ✅ Protection against zero deposits/withdrawals

## Contract Data Structure

```
KipuBank Contract
├── Immutable Variables
│   ├── WITHDRAWAL_LIMIT (default: 0.1 ETH)
│   └── BANK_CAP (default: 10 ETH)
├── State Variables
│   ├── owner
│   ├── totalDeposited
│   ├── totalDeposits
│   ├── totalWithdrawals
│   └── balances (mapping)
└── Functions
    ├── deposit() - External Payable
    ├── withdraw() - External
    ├── getBalance() - View
    ├── getBankInfo() - View
    └── _safeTransfer() - Private
```

## Deployed Contract Information

**Network**: Sepolia Testnet  
**Contract Address**: `0xEA522ec9237Cb4FCe33c2E417a97a704a7924F91`  
**Block Explorer**: [View on Etherscan](https://sepolia.etherscan.io/address/0xEA522ec9237Cb4FCe33c2E417a97a704a7924F91)  
**Deployment Date**: October 14, 2025  
**Status**: ✅ Verified and Published

### Contract Parameters
- **Withdrawal Limit**: 0.1 ETH per transaction
- **Bank Cap**: 10 ETH total deposits

## Technical Specifications

```
KipuBank Contract
├── Immutable Variables
│   ├── WITHDRAWAL_LIMIT (default: 0.1 ETH)
│   └── BANK_CAP (default: 10 ETH)
├── State Variables
│   ├── owner (address)
│   ├── totalDeposited (uint256)
│   ├── totalDeposits (uint256)
│   ├── totalWithdrawals (uint256)
│   └── balances (mapping: address => uint256)
├── Events
│   ├── Deposit(user, amount, newBalance)
│   └── Withdrawal(user, amount, newBalance)
├── Custom Errors
│   ├── CapExceeded(attempted, available)
│   ├── LimitExceeded(attempted, limit)
│   ├── LowBalance(attempted, current)
│   ├── ZeroDeposit() / ZeroAmount()
│   └── TransferFail()
└── Functions
    ├── deposit() - External Payable
    ├── withdraw(uint256) - External
    ├── getBalance(address) - External View
    ├── getBankInfo() - External View
    └── _safeTransfer(address, uint256) - Private
```

### Gas Optimizations

- Custom errors instead of require strings (~50-100 gas saved per error)
- Single storage variable access per function (~200 gas saved per avoided SLOAD)
- Optimized event emission using calculated values

## Function Reference

### Write Functions (State-Changing)

#### `deposit()` - Payable
- **Purpose**: Deposit ETH into your personal vault
- **Parameters**: None (ETH amount sent with transaction)
- **Restrictions**: 
  - Amount must be greater than 0
  - Total bank deposits cannot exceed 10 ETH cap
- **Gas Cost**: ~45,000 gas
- **Events**: Emits `Deposit(user, amount, newBalance)`

#### `withdraw(uint256 amount)` 
- **Purpose**: Withdraw ETH from your vault
- **Parameters**: `amount` (amount in wei to withdraw)
- **Restrictions**:
  - Amount must be greater than 0
  - Cannot exceed 0.1 ETH per transaction
  - Cannot exceed your current balance
- **Gas Cost**: ~55,000 gas
- **Events**: Emits `Withdrawal(user, amount, newBalance)`

### Read Functions (View Functions - No Gas Required)

#### `getBalance(address user)`
- **Purpose**: Check balance of any user
- **Parameters**: `user` (address to check)
- **Returns**: User's balance in wei

#### `getBankInfo()`
- **Purpose**: Get comprehensive bank statistics
- **Returns**: 
  - `totalDep`: Total ETH in bank
  - `totalDeps`: Number of deposits
  - `totalWith`: Number of withdrawals  
  - `bankCap`: Bank capacity (10 ETH)
  - `withdrawLimit`: Withdrawal limit (0.1 ETH)

#### Public Variables
- `WITHDRAWAL_LIMIT`: 100000000000000000 (0.1 ETH)
- `BANK_CAP`: 10000000000000000000 (10 ETH)  
- `owner`: Contract deployer address
- `totalDeposited`: Current ETH in bank
- `totalDeposits`: Deposit counter
- `totalWithdrawals`: Withdrawal counter
- `balances(address)`: Individual user balances

## Troubleshooting

### Common Issues

**Transaction Fails with "CapExceeded"**
- The bank has reached its 10 ETH capacity limit
- Try depositing a smaller amount

**Transaction Fails with "LimitExceeded"**  
- You're trying to withdraw more than 0.1 ETH in one transaction
- Split your withdrawal into multiple smaller transactions

**Transaction Fails with "LowBalance"**
- You don't have enough balance to withdraw the requested amount
- Check your balance using `getBalance()` function

**Transaction Fails with "ZeroDeposit" or "ZeroAmount"**
- You're trying to deposit or withdraw 0 ETH
- Enter a valid amount greater than 0

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Developer

**Eduardo Moreno**  
Henry Web3 Bootcamp - Module 2 Final Project  
2025

---

## Disclaimer

This smart contract is developed for educational purposes as part of a Web3 development bootcamp. While it implements security best practices, it has not undergone professional security audits. Use in production environments is not recommended without additional security reviews and testing.

## Additional Resources

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Ethereum Smart Contract Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)
- [Remix IDE](https://remix.ethereum.org/)
- [MetaMask](https://metamask.io/)
- [Sepolia Testnet Faucet](https://sepoliafaucet.com/)