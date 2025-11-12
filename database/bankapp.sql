-- Create database with UTF8 charset and collation for broad compatibility
CREATE DATABASE IF NOT EXISTS bankappdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bankappdb;

-- Users table to securely store customer details
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Store salted-hashed passwords only
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_username CHECK (char_length(username) >= 3),
    CONSTRAINT chk_email CHECK (email LIKE '%_@__%.__%')
);

-- Accounts table to store bank accounts linked to users
CREATE TABLE IF NOT EXISTS accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type ENUM('Savings', 'Checking') NOT NULL,
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Transactions table to store debit and credit records
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    related_account VARCHAR(20) NULL, -- For transfers, linked account number
    CONSTRAINT fk_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Ensure balance updates and transaction inserts happen atomically (application level)
-- Implement transaction logic in stored procedures or through application code with triggers/locking

-- Indexes for performance optimization
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_account_user ON accounts(user_id);
CREATE INDEX idx_transaction_account ON transactions(account_id);

-- Security notes:
-- 1. Passwords must be salted and hashed externally before storing in password_hash.
-- 2. Use parameterized queries/prepared statements in application to prevent SQL injection.
-- 3. Regular backups and encrypted connections (TLS) to database server are recommended.
