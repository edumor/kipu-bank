// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KipuBank
 * @author Eduardo Moreno
 * @notice A simple bank contract that allows users to deposit and withdraw ETH
 * @dev Implements basic deposit and withdrawal functionalities with security limits
 */
contract KipuBank {
    // ============ VARIABLES INMUTABLES Y CONSTANTES ============
    
    /// @notice Maximum withdrawal limit per transaction (0.1 ETH)
    /// @dev Immutable variable set in constructor
    uint256 public immutable WITHDRAWAL_LIMIT;
    
    /// @notice Total deposit limit that the bank can handle
    /// @dev Immutable variable set in constructor
    uint256 public immutable BANK_CAP;

    // ============ VARIABLES DE ALMACENAMIENTO ============
    
    /// @notice Address of the contract owner
    address public owner;
    
    /// @notice Total ETH deposited in the bank
    uint256 public totalDeposited;
    
    /// @notice Total counter of deposits made
    uint256 public totalDeposits;
    
    /// @notice Total counter of withdrawals made  
    uint256 public totalWithdrawals;

    // ============ MAPPING ============
    
    /// @notice Mapping of addresses to their balances in the bank
    /// @dev address => balance in wei
    mapping(address => uint256) public balances;

    // ============ EVENTOS ============
    
    /// @notice Emitted when a user makes a deposit
    /// @param user Address of the user making the deposit
    /// @param amount Amount deposited in wei
    /// @param newBalance New balance of the user
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    
    /// @notice Emitted when a user makes a successful withdrawal
    /// @param user Address of the user making the withdrawal
    /// @param amount Amount withdrawn in wei
    /// @param newBalance New balance of the user
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    // ============ ERRORES PERSONALIZADOS ============
    
    /// @notice Error when trying to deposit more than the bank limit
    error BankCapExceeded(uint256 attemptedAmount, uint256 availableSpace);
    
    /// @notice Error when trying to withdraw more than the transaction limit
    error WithdrawalLimitExceeded(uint256 attemptedAmount, uint256 limit);
    
    /// @notice Error when trying to withdraw more than available balance
    error InsufficientBalance(uint256 attemptedAmount, uint256 currentBalance);
    
    /// @notice Error when trying to deposit 0 ETH
    error ZeroDeposit();
    
    /// @notice Error when trying to withdraw 0 ETH
    error ZeroWithdrawal();
    
    /// @notice Error when only the owner can execute the function
    error OnlyOwner();
    
    /// @notice Error when ETH transfer fails
    error TransferFailed();

    // ============ MODIFICADORES ============
    
    /// @notice Modifier that verifies only the owner can execute the function
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    // ============ CONSTRUCTOR ============
    
    /// @notice Constructor that initializes the contract with specified limits
    /// @param _withdrawalLimit Maximum withdrawal limit per transaction in wei
    /// @param _bankCap Total deposit limit that the bank can handle in wei
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        WITHDRAWAL_LIMIT = _withdrawalLimit;
        BANK_CAP = _bankCap;
        owner = msg.sender;
    }

    // ============ FUNCIONES EXTERNAS ============
    
    /// @notice External payable function to deposit ETH into the bank
    /// @dev Verifies that the deposit does not exceed the bank limit
    function deposit() external payable {
        // Checks
        if (msg.value == 0) {
            revert ZeroDeposit();
        }
        
        uint256 currentTotalDeposited = totalDeposited;
        uint256 newTotalDeposited = currentTotalDeposited + msg.value;
        if (newTotalDeposited > BANK_CAP) {
            revert BankCapExceeded(msg.value, BANK_CAP - currentTotalDeposited);
        }

        // Effects
        uint256 newUserBalance = balances[msg.sender] + msg.value;
        balances[msg.sender] = newUserBalance;
        totalDeposited = newTotalDeposited;
        totalDeposits++;

        // Interactions (event emission)
        emit Deposit(msg.sender, msg.value, newUserBalance);
    }

    /// @notice External function to withdraw ETH from the bank
    /// @param amount Amount to withdraw in wei
    /// @dev Verifies withdrawal limits and sufficient balance
    function withdraw(uint256 amount) external {
        // Checks
        if (amount == 0) {
            revert ZeroWithdrawal();
        }
        
        if (amount > WITHDRAWAL_LIMIT) {
            revert WithdrawalLimitExceeded(amount, WITHDRAWAL_LIMIT);
        }
        
        uint256 currentBalance = balances[msg.sender];
        if (amount > currentBalance) {
            revert InsufficientBalance(amount, currentBalance);
        }

        // Effects
        uint256 newBalance = currentBalance - amount;
        balances[msg.sender] = newBalance;
        totalDeposited -= amount;
        totalWithdrawals++;

        // Interactions
        _safeTransfer(msg.sender, amount);
        
        emit Withdrawal(msg.sender, amount, newBalance);
    }

    /// @notice External view function to get a user's balance
    /// @param user User's address
    /// @return User's balance in wei
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    /// @notice External view function to get general bank information
    /// @return totalDep Total deposited in the bank
    /// @return totalDeps Total number of deposits
    /// @return totalWith Total number of withdrawals
    /// @return bankCap Maximum bank limit
    /// @return withdrawLimit Withdrawal limit per transaction
    function getBankInfo() external view returns (
        uint256 totalDep,
        uint256 totalDeps,
        uint256 totalWith,
        uint256 bankCap,
        uint256 withdrawLimit
    ) {
        return (
            totalDeposited,
            totalDeposits,
            totalWithdrawals,
            BANK_CAP,
            WITHDRAWAL_LIMIT
        );
    }

    // ============ FUNCIONES PRIVADAS ============
    
    /// @notice Private function to perform safe ETH transfers
    /// @param to Destination address
    /// @param amount Amount to transfer in wei
    /// @dev Uses call for better security instead of transfer
    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    // ============ FUNCIONES DE EMERGENCIA (SOLO OWNER) ============
    
    /// @notice Emergency function for the owner to withdraw funds if necessary
    /// @dev Can only be called by the contract owner
    function emergencyWithdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        _safeTransfer(owner, contractBalance);
    }

    /// @notice Function to receive ETH directly (fallback)
    /// @dev Implements deposit logic directly to save gas
    receive() external payable {
        if (msg.value == 0) {
            revert ZeroDeposit();
        }
        
        uint256 currentTotalDeposited = totalDeposited;
        uint256 newTotalDeposited = currentTotalDeposited + msg.value;
        if (newTotalDeposited > BANK_CAP) {
            revert BankCapExceeded(msg.value, BANK_CAP - currentTotalDeposited);
        }

        uint256 newUserBalance = balances[msg.sender] + msg.value;
        balances[msg.sender] = newUserBalance;
        totalDeposited = newTotalDeposited;
        totalDeposits++;
        
        emit Deposit(msg.sender, msg.value, newUserBalance);
    }
}