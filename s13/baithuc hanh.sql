/* =========================================================
   1) SETUP: DB + TABLES
========================================================= */
DROP DATABASE IF EXISTS SocialNetworkDB;
CREATE DATABASE SocialNetworkDB;
USE SocialNetworkDB;

-- users: quản lý người dùng
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    total_posts INT NOT NULL DEFAULT 0
);

-- posts: quản lý bài viết
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- post_audits: nhật ký chỉnh sửa bài viết
CREATE TABLE post_audits (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

/* =========================================================
   2) TRIGGERS (4 TASKS)
========================================================= */
DELIMITER //

-- Task 1: BEFORE INSERT - chặn content trống / toàn khoảng trắng
CREATE TRIGGER tg_CheckPostContent
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    IF NEW.content IS NULL OR TRIM(NEW.content) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nội dung bài viết không được để trống!';
    END IF;
END//

-- Task 2: AFTER INSERT - tăng total_posts của user lên 1
CREATE TRIGGER tg_UpdatePostCountAfterInsert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts + 1
    WHERE user_id = NEW.user_id;
END//

-- Task 3: AFTER UPDATE - nếu content thay đổi thì ghi log vào post_audits
CREATE TRIGGER tg_LogPostChanges
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    -- xử lý cả trường hợp NULL để so sánh chính xác
    IF (OLD.content <> NEW.content)
       OR (OLD.content IS NULL AND NEW.content IS NOT NULL)
       OR (OLD.content IS NOT NULL AND NEW.content IS NULL) THEN

        INSERT INTO post_audits (post_id, old_content, new_content, changed_at)
        VALUES (OLD.post_id, OLD.content, NEW.content, NOW());
    END IF;
END//

-- Task 4: AFTER DELETE - giảm total_posts của user xuống 1
CREATE TRIGGER tg_UpdatePostCountAfterDelete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = CASE
                        WHEN total_posts > 0 THEN total_posts - 1
                        ELSE 0
                      END
    WHERE user_id = OLD.user_id;
END//

DELIMITER ;

/* =========================================================
   3) TEST & CHECK
========================================================= */

-- 3.1 Tạo 1 người dùng mới
INSERT INTO users (username) VALUES ('huyen');

-- Kiểm tra user
SELECT * FROM users;

-- 3.2 Chèn 1 bài viết hợp lệ (total_posts phải tăng lên 1)
INSERT INTO posts (user_id, content) VALUES (1, 'Bài viết đầu tiên');

SELECT * FROM posts;
SELECT * FROM users;  -- total_posts = 1

-- 3.3 Chèn 1 bài viết trống (phải bị chặn)
-- BỎ comment để test lỗi:
-- INSERT INTO posts (user_id, content) VALUES (1, '');
-- INSERT INTO posts (user_id, content) VALUES (1, '      ');

-- 3.4 Update nội dung bài viết (phải log vào post_audits)
UPDATE posts
SET content = 'Nội dung đã chỉnh sửa'
WHERE post_id = 1;

SELECT * FROM post_audits; -- phải có 1 dòng log

-- 3.5 Delete bài viết (total_posts phải giảm về 0)
DELETE FROM posts WHERE post_id = 1;

SELECT * FROM users; -- total_posts = 0

/* =========================================================
   4) CLEANUP: DROP TRIGGERS
========================================================= */
DROP TRIGGER IF EXISTS tg_CheckPostContent;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterInsert;
DROP TRIGGER IF EXISTS tg_LogPostChanges;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterDelete;
