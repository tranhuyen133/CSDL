DROP DATABASE IF EXISTS transaction_ss14_cntt5;
CREATE DATABASE transaction_ss14_cntt5;
USE transaction_ss14_cntt5;

CREATE TABLE accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    balance DECIMAL(15,2),
    CHECK (balance >= 0)
);

CREATE TABLE transfers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    amount DECIMAL(15,2),
    sender_id INT,
    receiver_id INT,
    created_at DATETIME,
    FOREIGN KEY (sender_id) REFERENCES accounts(id),
    FOREIGN KEY (receiver_id) REFERENCES accounts(id)
);

-- 3) Thêm 2 tài khoản 
INSERT INTO accounts (full_name, balance) VALUES
('nguyen thanh tùng', 10000000),
('ho khanh linh', 99999999);

-- 4) Procedure chuyển tiền 
DELIMITER //

DROP PROCEDURE IF EXISTS transfer_money//
CREATE PROCEDURE transfer_money ( sender_id INT , receive_id INT, transfer_money DECIMAL(10,2) )
BEGIN
    DECLARE my_balance DECIMAL(15,2);

    -- validate số tiền
    IF (transfer_money IS NULL OR transfer_money <= 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'so tien chuyen phai > 0';
    END IF;

    START TRANSACTION;

    -- lấy số dư theo sender_id (không hard-code id = 2)
    SELECT balance INTO my_balance
    FROM accounts
    WHERE id = sender_id
    FOR UPDATE;

    -- sender không tồn tại
    IF (my_balance IS NULL) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tai khoan gui khong ton tai';
    END IF;

    -- receiver không tồn tại
    IF ((SELECT COUNT(*) FROM accounts WHERE id = receive_id) = 0) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tai khoan nhan khong ton tai';
    END IF;

    -- đủ số dư thì chuyển
    IF (my_balance >= transfer_money) THEN
        UPDATE accounts SET balance = balance + transfer_money WHERE id = receive_id;
        UPDATE accounts SET balance = balance - transfer_money WHERE id = sender_id;

        -- ghi lịch sử chuyển tiền
        INSERT INTO transfers(amount, sender_id, receiver_id, created_at)
        VALUES (transfer_money, sender_id, receive_id, NOW());

        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'khong du so du';
    END IF;

END//

DELIMITER ;

-- 5) TEST
-- Linh (id=2) chuyển cho Tùng (id=1)
CALL transfer_money(2, 1, 20000000);

-- Kiểm tra số dư + lịch sử
SELECT * FROM accounts;
SELECT * FROM transfers ORDER BY id DESC;
