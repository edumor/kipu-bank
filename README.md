# KipuBank Smart Contract

[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Description

KipuBank is a secure smart contract that implements a simple banking system on the Ethereum blockchain. The contract allows users to deposit and withdraw ETH with built-in security measures and transaction limits.

### What the Contract Does

The KipuBank smart contract provides the following functionality:

- **Personal ETH Vaults**: Users can deposit native ETH tokens into their individual vaults
- **Withdrawal Limits**: Users can withdraw funds with a maximum limit per transaction (set as immutable variable)
- **Global Deposit Cap**: The contract enforces a total deposit limit for the entire bank (set during deployment)
- **Transaction Tracking**: The system keeps track of the total number of deposits and withdrawals
- **Balance Management**: Users can check their individual balances and overall bank statistics

### Key Features

- **Security First**: Implements checks-effects-interactions pattern and custom errors
- **Gas Optimized**: Uses custom errors instead of require strings and optimized storage access
- **Event Logging**: Emits events for all deposits and successful withdrawals
- **Access Control**: Owner-only emergency functions with proper modifiers
- **Safe Transfers**: Uses low-level call for secure ETH transfers

## Contract Architecture

### Main Components

#### Immutable Variables
- `WITHDRAWAL_LIMIT`: Maximum withdrawal limit per transaction
- `BANK_CAP`: Total deposit limit that the bank can handle

#### State Variables
- `owner`: Contract owner address
- `totalDeposited`: Total ETH deposited in the bank
- `totalDeposits`: Counter of deposits made
- `totalWithdrawals`: Counter of withdrawals made
- `balances`: Mapping of addresses to their balances

#### Events
- `Deposit`: Emitted when a deposit is made
- `Withdrawal`: Emitted when a successful withdrawal is made

#### Custom Errors
- `BankCapExceeded`: When the bank limit is exceeded
- `WithdrawalLimitExceeded`: When the withdrawal limit is exceeded
- `InsufficientBalance`: When there is insufficient balance
- `ZeroDeposit/ZeroWithdrawal`: For zero-value transactions
- `OnlyOwner`: For owner-restricted functions

## Deployment Instructions

### Prerequisites

Before deploying the KipuBank contract, ensure you have:

1. **MetaMask Wallet** installed and configured
2. **Testnet ETH** for gas fees and testing
3. Access to **Remix IDE** or another Solidity development environment

### Recommended Testnets

Choose one of these testnets for deployment:

- **Sepolia Testnet**: [Get Sepolia ETH](https://sepoliafaucet.com/)
- **Goerli Testnet**: [Get Goerli ETH](https://goerlifaucet.com/)
- **Mumbai Testnet (Polygon)**: [Get Mumbai MATIC](https://faucet.polygon.technology/)

### Step-by-Step Deployment

#### Method 1: Using Remix IDE (Recommended)

1. **Access Remix IDE**
   - Navigate to [remix.ethereum.org](https://remix.ethereum.org/)
   - Create a new workspace or use the default workspace

2. **Upload Contract Code**
   - Create a new file named `KipuBank.sol` in the `contracts` folder
   - Copy the complete contract code from `contracts/KipuBank.sol`
   - Paste it into the new file

3. **Compile the Contract**
   - Navigate to the "Solidity Compiler" tab (Ctrl+Shift+S)
   - Select Solidity version `0.8.20` or `^0.8.20`
   - Enable optimization (recommended): 200 runs
   - Click "Compile KipuBank.sol"
   - Verify there are no compilation errors

4. **Configure Deployment Environment**
   - Go to "Deploy & Run Transactions" tab (Ctrl+Shift+D)
   - Select "Injected Provider - MetaMask" as environment
   - Ensure MetaMask is connected to your chosen testnet
   - Select your account address

5. **Set Constructor Parameters**
   
   Before deployment, set these constructor parameters:
   
   - **_withdrawalLimit**: `100000000000000000` (0.1 ETH in wei)
   - **_bankCap**: `10000000000000000000` (10 ETH in wei)
   
   *Note: You can modify these values based on your requirements*

6. **Deploy Contract**
   - Select "KipuBank" from the contract dropdown
   - Enter the constructor parameters
   - Click "Deploy" button
   - Confirm the transaction in MetaMask

7. **Verify Deployment**
   - Copy the deployed contract address
   - Visit your testnet's block explorer (e.g., Sepolia Etherscan)
   - Search for your contract address
   - Verify the contract source code on the explorer

### Contract Verification

After deployment, verify your contract on the block explorer:

1. Go to your testnet's Etherscan (e.g., sepolia.etherscan.io)
2. Navigate to your contract address
3. Click "Verify and Publish" 
4. Select "Solidity (Single file)"
5. Choose compiler version `0.8.20`
6. Enable optimization: Yes, 200 runs
7. Paste your contract source code
8. Enter constructor parameters used during deployment
9. Complete verification

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

**3. emergencyWithdraw() - Owner Only**
- **Purpose**: Emergency function for contract owner to withdraw all funds
- **Access**: Only contract owner can call this function

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
2. Send ETH directly to contract address (triggers `receive()` function)
3. Use MetaMask's contract interaction features

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
- ✅ Owner-only emergency functions

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

**Network**: [Update after deployment]  
**Contract Address**: `[Update with your deployed contract address]`  
**Block Explorer**: [Update with link to verified contract]  
**Deployment Date**: [Update after deployment]

*Note: Please update this section after successful deployment and verification*

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
│   ├── BankCapExceeded(attemptedAmount, availableSpace)
│   ├── WithdrawalLimitExceeded(attemptedAmount, limit)
│   ├── InsufficientBalance(attemptedAmount, currentBalance)
│   ├── ZeroDeposit() / ZeroWithdrawal()
│   ├── OnlyOwner()
│   └── TransferFailed()
└── Functions
    ├── deposit() - External Payable
    ├── withdraw(uint256) - External
    ├── getBalance(address) - External View
    ├── getBankInfo() - External View
    ├── emergencyWithdraw() - External OnlyOwner
    ├── _safeTransfer(address, uint256) - Private
    └── receive() - External Payable
```

### Gas Optimizations

- Custom errors instead of require strings (~50-100 gas saved per error)
- Single storage variable access per function (~200 gas saved per avoided SLOAD)
- Optimized event emission using calculated values
- Efficient fallback function implementation

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