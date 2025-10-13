// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KipuBank
 * @author Henry Web3 Module 2 Final Project
 * @notice A secure ETH deposit and withdrawal system with gas-optimized code and withdrawal limits
 * @dev This contract implements a simple banking system with the following features:
 * - ETH deposits with event logging
 * - ETH withdrawals with configurable limits
 * - Balance tracking per user
 * - Gas-optimized storage patterns
 * - Custom errors for better UX and gas efficiency
 */
contract KipuBank {
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Thrown when attempting to deposit 0 ETH
    error ZeroDeposit();
    
    /// @dev Thrown when attempting to withdraw 0 ETH
    error ZeroWithdrawal();
    
    /// @dev Thrown when withdrawal amount exceeds balance
    error InsufficientBalance();
    
    /// @dev Thrown when withdrawal amount exceeds the allowed limit
    error WithdrawalLimitExceeded();
    
    /// @dev Thrown when ETH transfer fails
    error TransferFailed();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Maximum withdrawal amount per transaction (in wei)
    /// @dev Using uint256 for consistency with ETH values
    uint256 public constant WITHDRAWAL_LIMIT = 1 ether;

    /// @notice Mapping of user addresses to their balance
    /// @dev Using mapping for O(1) lookups, gas-optimized storage
    mapping(address => uint256) private balances;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when a user deposits ETH
     * @param user Address of the user depositing
     * @param amount Amount of ETH deposited in wei
     * @param newBalance User's new total balance after deposit
     */
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);

    /**
     * @notice Emitted when a user withdraws ETH
     * @param user Address of the user withdrawing
     * @param amount Amount of ETH withdrawn in wei
     * @param newBalance User's new total balance after withdrawal
     */
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deposit ETH into the bank
     * @dev Increases the sender's balance and emits a Deposit event
     * @custom:gas-optimization Uses unchecked math where overflow is impossible
     */
    function deposit() external payable {
        if (msg.value == 0) revert ZeroDeposit();
        
        // Gas optimization: unchecked is safe here as balance + msg.value won't overflow
        unchecked {
            balances[msg.sender] += msg.value;
        }
        
        emit Deposit(msg.sender, msg.value, balances[msg.sender]);
    }

    /**
     * @notice Withdraw ETH from the bank
     * @dev Withdraws the specified amount if conditions are met:
     * - Amount must be greater than 0
     * - Amount must not exceed user's balance
     * - Amount must not exceed the withdrawal limit
     * @param amount Amount of ETH to withdraw in wei
     * @custom:security Uses checks-effects-interactions pattern to prevent reentrancy
     * @custom:gas-optimization Uses unchecked math where underflow is impossible
     */
    function withdraw(uint256 amount) external {
        if (amount == 0) revert ZeroWithdrawal();
        if (amount > balances[msg.sender]) revert InsufficientBalance();
        if (amount > WITHDRAWAL_LIMIT) revert WithdrawalLimitExceeded();

        // Effects: Update state before external call (checks-effects-interactions pattern)
        // Gas optimization: unchecked is safe here as we already verified amount <= balance
        unchecked {
            balances[msg.sender] -= amount;
        }

        // Interactions: External call comes last to prevent reentrancy
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit Withdrawal(msg.sender, amount, balances[msg.sender]);
    }

    /**
     * @notice Get the balance of a specific user
     * @param user Address of the user to query
     * @return The balance of the specified user in wei
     * @custom:gas-optimization View function, no state changes
     */
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    /**
     * @notice Get the balance of the caller
     * @return The balance of msg.sender in wei
     * @dev Convenience function for users to check their own balance
     * @custom:gas-optimization View function, no state changes
     */
    function getMyBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    /**
     * @notice Get the withdrawal limit
     * @return The maximum amount that can be withdrawn in a single transaction (in wei)
     * @dev Returns the WITHDRAWAL_LIMIT constant
     */
    function getWithdrawalLimit() external pure returns (uint256) {
        return WITHDRAWAL_LIMIT;
    }
}
