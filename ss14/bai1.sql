-- 1) Tạo DB + dùng DB (tuỳ chọn)
DROP DATABASE IF EXISTS bank_tx_basic;
CREATE DATABASE bank_tx_basic;
USE bank_tx_basic;

-- 2) Tạo bảng accounts đúng mô tả
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CHECK (balance >= 0)
) ENGINE=InnoDB;

-- 3) Thêm dữ liệu mẫu (đúng yêu cầu)
INSERT INTO accounts (account_name, balance) VALUES 
('Nguyễn Văn An', 1000.00),
('Trần Thị Bảy', 500.00);

-- 4) Stored Procedure chuyển tiền (Transaction)
DELIMITER //

DROP PROCEDURE IF EXISTS sp_transfer_money//
CREATE PROCEDURE sp_transfer_money(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);

    -- Validate cơ bản
    IF amount IS NULL OR amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'So tien chuyen phai > 0';
    END IF;

    IF from_account = to_account THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong the chuyen tien cho chinh minh';
    END IF;

    START TRANSACTION;

        -- Khoá dòng tài khoản gửi để lấy số dư an toàn
        SELECT balance INTO from_balance
        FROM accounts
        WHERE account_id = from_account
        FOR UPDATE;

        -- Tài khoản gửi không tồn tại
        IF from_balance IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tai khoan gui khong ton tai';
        END IF;

        -- Tài khoản nhận không tồn tại
        IF (SELECT COUNT(*) FROM accounts WHERE account_id = to_account) = 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tai khoan nhan khong ton tai';
        END IF;

        -- Không đủ số dư
        IF from_balance < amount THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'So du khong du';
        END IF;

        -- Trừ tiền người gửi
        UPDATE accounts
        SET balance = balance - amount
        WHERE account_id = from_account;

        -- Cộng tiền người nhận
        UPDATE accounts
        SET balance = balance + amount
        WHERE account_id = to_account;

    COMMIT;
END//

DELIMITER ;

-- 5) Gọi procedure để kiểm thử
-- Chuyển 200 từ Nguyễn Văn An (id=1) sang Trần Thị Bảy (id=2)
CALL sp_transfer_money(1, 2, 200.00);

-- Kiểm tra kết quả
SELECT * FROM accounts;
