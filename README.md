# 🏦 KipuBank Smart Contract

A secure ETH deposit and withdrawal system built with Solidity. Features gas-optimized code, custom errors, withdrawal limits, and comprehensive NatSpec documentation. Built for Henry Web3 Module 2 Final Project.

## ✨ Features

- **Secure ETH Deposits**: Users can safely deposit ETH into their account
- **Withdrawal Limits**: Maximum withdrawal of 1 ETH per transaction for security
- **Gas-Optimized Code**: Uses unchecked math where safe, optimized storage patterns
- **Custom Errors**: Improved UX and gas efficiency with descriptive custom errors
- **Balance Tracking**: Individual balance tracking for each user
- **Comprehensive NatSpec**: Full documentation following best practices
- **Reentrancy Protection**: Follows checks-effects-interactions pattern

## 🔒 Security Features

- **Custom Error Handling**: Gas-efficient error messages
- **Withdrawal Limits**: Prevents large unauthorized withdrawals
- **Checks-Effects-Interactions Pattern**: Prevents reentrancy attacks
- **Zero Value Protection**: Prevents wasteful zero-value transactions

## 🚀 Getting Started

### Prerequisites

- Node.js (v20 or later)
- npm or yarn

### Installation

```bash
# Clone the repository
git clone https://github.com/edumor/kipu-bank.git
cd kipu-bank

# Install dependencies
npm install
```

### Compile the Contract

```bash
npm run compile
```

### Run Tests

```bash
npm test
```

### Deploy

```bash
# Deploy to local Hardhat network
npm run deploy

# Or use Hardhat Ignition
npx hardhat ignition deploy ignition/modules/KipuBank.js
```

## 📝 Contract Interface

### Core Functions

#### `deposit()` payable
Deposit ETH into your account.

```solidity
function deposit() external payable
```

**Requirements:**
- `msg.value` must be greater than 0

**Emits:** `Deposit(user, amount, newBalance)`

#### `withdraw(uint256 amount)` 
Withdraw ETH from your account.

```solidity
function withdraw(uint256 amount) external
```

**Parameters:**
- `amount`: Amount of ETH to withdraw (in wei)

**Requirements:**
- Amount must be greater than 0
- Amount must not exceed your balance
- Amount must not exceed withdrawal limit (1 ETH)

**Emits:** `Withdrawal(user, amount, newBalance)`

#### `getBalance(address user)` view
Get the balance of any user.

```solidity
function getBalance(address user) external view returns (uint256)
```

#### `getMyBalance()` view
Get your own balance.

```solidity
function getMyBalance() external view returns (uint256)
```

#### `getWithdrawalLimit()` pure
Get the maximum withdrawal amount per transaction.

```solidity
function getWithdrawalLimit() external pure returns (uint256)
```

### Events

```solidity
event Deposit(address indexed user, uint256 amount, uint256 newBalance);
event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);
```

### Custom Errors

```solidity
error ZeroDeposit();
error ZeroWithdrawal();
error InsufficientBalance();
error WithdrawalLimitExceeded();
error TransferFailed();
```

## 🧪 Testing

The contract includes comprehensive tests covering:

- ✅ Deployment and initialization
- ✅ Deposit functionality
- ✅ Withdrawal functionality with limits
- ✅ Balance queries
- ✅ Multiple user scenarios
- ✅ Error conditions
- ✅ Event emissions

Run the test suite:

```bash
npm test
```

## 📊 Gas Optimization

The contract implements several gas optimization techniques:

1. **Unchecked Math**: Uses unchecked blocks where overflow/underflow is impossible
2. **Custom Errors**: More gas-efficient than require strings
3. **Efficient Storage**: Uses mappings for O(1) lookups
4. **Constant for Limit**: Withdrawal limit stored as constant
5. **View Functions**: Balance queries don't modify state

## 🛠 Tech Stack

- **Solidity**: ^0.8.20
- **Hardhat**: Development environment
- **Ethers.js**: Ethereum library
- **Chai**: Testing framework
- **Hardhat Toolbox**: Comprehensive plugin bundle

## 📄 License

MIT

## 👨‍💻 Author

Built for Henry Web3 Module 2 Final Project

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## ⭐ Show your support

Give a ⭐️ if this project helped you!
