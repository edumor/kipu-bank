// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KipuBank
 * @author Eduardo Moreno
 * @notice A simple bank contract that allows users to deposit and withdraw ETH
 * @dev Implements basic deposit and withdrawal functionalities with security limits
 */
contract KipuBank {
    // ============ IMMUTABLE AND CONSTANT VARIABLES ============
    
    /// @notice Maximum withdrawal limit per transaction (0.1 ETH)
    /// @dev Immutable variable set in constructor
    uint256 public immutable WITHDRAWAL_LIMIT;
    
    /// @notice Total deposit limit that the bank can handle
    /// @dev Immutable variable set in constructor
    uint256 public immutable BANK_CAP;

    // ============ STORAGE VARIABLES ============
    
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

    // ============ EVENTS ============
    
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

    // ============ CUSTOM ERRORS ============
    
    /// @notice Error when deposit exceeds bank limit
    error CapExceeded(uint256 attempted, uint256 available);
    
    /// @notice Error when withdrawal exceeds transaction limit
    error LimitExceeded(uint256 attempted, uint256 limit);
    
    /// @notice Error when withdrawal exceeds user balance
    error LowBalance(uint256 attempted, uint256 current);
    
    /// @notice Error when trying to deposit 0 ETH
    error ZeroDeposit();
    
    /// @notice Error when trying to withdraw 0 ETH
    error ZeroAmount();
    
    /// @notice Error when ETH transfer fails
    error TransferFail();

    // ============ MODIFIERS ============
    
    /// @notice Modifier to validate that amount is greater than zero
    modifier validAmount(uint256 amount) {
        if (amount == 0) {
            revert ZeroAmount();
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

    // ============ EXTERNAL FUNCTIONS ============
    
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
            revert CapExceeded(msg.value, BANK_CAP - currentTotalDeposited);
        }

        // Effects - Single access to state variables
        uint256 currentUserBalance = balances[msg.sender];
        uint256 currentTotalDeposits = totalDeposits;
        uint256 newUserBalance = currentUserBalance + msg.value;
        
        balances[msg.sender] = newUserBalance;
        totalDeposited = newTotalDeposited;
        totalDeposits = currentTotalDeposits + 1;

        // Interactions (event emission)
        emit Deposit(msg.sender, msg.value, newUserBalance);
    }

    /// @notice External function to withdraw ETH from the bank
    /// @param amount Amount to withdraw in wei
    /// @dev Verifies withdrawal limits and sufficient balance
    function withdraw(uint256 amount) external validAmount(amount) {
        // Checks
        
        if (amount > WITHDRAWAL_LIMIT) {
            revert LimitExceeded(amount, WITHDRAWAL_LIMIT);
        }
        
        uint256 currentBalance = balances[msg.sender];
        if (amount > currentBalance) {
            revert LowBalance(amount, currentBalance);
        }

        // Effects - Single access to state variables
        uint256 newBalance = currentBalance - amount;
        uint256 currentTotalDeposited = totalDeposited;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
        balances[msg.sender] = newBalance;
        totalDeposited = currentTotalDeposited - amount;
        totalWithdrawals = currentTotalWithdrawals + 1;

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
        // Single access to each state variable
        uint256 currentTotalDeposited = totalDeposited;
        uint256 currentTotalDeposits = totalDeposits;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
        return (
            currentTotalDeposited,
            currentTotalDeposits,
            currentTotalWithdrawals,
            BANK_CAP,
            WITHDRAWAL_LIMIT
        );
    }

    // ============ PRIVATE FUNCTIONS ============
    
    /// @notice Private function to perform safe ETH transfers
    /// @param to Destination address
    /// @param amount Amount to transfer in wei
    /// @dev Uses call for better security instead of transfer
    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFail();
        }
    }

}