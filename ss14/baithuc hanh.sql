DROP DATABASE IF EXISTS SocialNetworkTxDB;
CREATE DATABASE SocialNetworkTxDB;
USE SocialNetworkTxDB;

-- 1) Tạo bảng Users
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    total_posts INT DEFAULT 0
);

-- 2) Tạo bảng Posts
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 3) Dữ liệu mẫu
INSERT INTO users (username, total_posts) VALUES ('nguyen_van_a', 0);
INSERT INTO users (username, total_posts) VALUES ('le_thi_b', 0);

-- ======================================================
-- Task 1 + 2: Stored Procedure sp_create_post
-- ======================================================

DELIMITER //

DROP PROCEDURE IF EXISTS sp_create_post//
CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    DECLARE v_sqlstate CHAR(5) DEFAULT '00000';
    DECLARE v_errno INT DEFAULT 0;
    DECLARE v_msg TEXT DEFAULT '';
    DECLARE v_error TEXT;

    -- Bắt mọi lỗi SQL (FK, dữ liệu, ...)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_errno    = MYSQL_ERRNO,
            v_msg      = MESSAGE_TEXT;

        ROLLBACK;

        SET v_error = CONCAT('Tao bai viet that bai. (', v_errno, ' - ', v_sqlstate, '): ', v_msg);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error;
    END;

    -- Validation: content NULL/rỗng => báo lỗi và dừng (KHÔNG mở transaction)
    IF p_content IS NULL OR CHAR_LENGTH(TRIM(p_content)) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Noi dung bai viet khong duoc de trong.';
    END IF;

    -- Transaction: 2 thao tác cùng thành công hoặc cùng thất bại
    START TRANSACTION;

        -- insert trước để nếu user_id không tồn tại -> lỗi FK -> handler rollback
        INSERT INTO posts(user_id, content)
        VALUES (p_user_id, p_content);

        UPDATE users
        SET total_posts = total_posts + 1
        WHERE user_id = p_user_id;

    COMMIT;
END//

DELIMITER ;

-- Task 3: TESTING

-- Xem trạng thái ban đầu
SELECT * FROM users;
SELECT * FROM posts;

-- Case 1 (Happy Case): đăng bài cho nguyen_van_a (thường user_id = 1)
CALL sp_create_post(1, 'Bai viet hop le - hello world');

-- Kiểm tra Case 1:
-- posts có thêm dòng? total_posts của user 1 tăng?
SELECT * FROM posts WHERE user_id = 1 ORDER BY post_id DESC;
SELECT user_id, username, total_posts FROM users WHERE user_id = 1;

-- Case 2 (Error Case): user_id không tồn tại (9999)
CALL sp_create_post(9999, 'Test user khong ton tai');

-- Kiểm tra Case 2:
-- không có dòng rác trong posts, total_posts không tăng nhầm
SELECT * FROM posts WHERE user_id = 9999;
SELECT * FROM users ORDER BY user_id;
