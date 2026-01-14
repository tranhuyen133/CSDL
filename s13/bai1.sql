-- 0) Tạo database (tuỳ chọn, nếu bạn muốn tách riêng)
DROP DATABASE IF EXISTS SocialTriggerDB;
CREATE DATABASE SocialTriggerDB;
USE SocialTriggerDB;

-- 1) Xóa bảng nếu tồn tại (xóa posts trước vì có FK)
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

-- 1) Tạo bảng users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATE,
    follower_count INT DEFAULT 0,
    post_count INT DEFAULT 0
);

-- 1) Tạo bảng posts (FK + ON DELETE CASCADE)
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content TEXT,
    created_at DATETIME,
    like_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- 2) Thêm dữ liệu mẫu users
INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');

-- 3) Tạo 2 trigger: AFTER INSERT và AFTER DELETE trên posts
DELIMITER //

-- Trigger: thêm bài mới -> tăng post_count
CREATE TRIGGER tg_posts_after_insert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET post_count = post_count + 1
    WHERE user_id = NEW.user_id;
END//

-- Trigger: xóa bài -> giảm post_count
CREATE TRIGGER tg_posts_after_delete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET post_count = post_count - 1
    WHERE user_id = OLD.user_id;
END//

DELIMITER ;

-- 4) Insert các bài đăng và kiểm chứng post_count
INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

SELECT * FROM users;

-- 5) Xóa 1 bài đăng (ví dụ post_id = 2) và kiểm chứng lại
DELETE FROM posts WHERE post_id = 2;

SELECT * FROM users;

-- (Tuỳ chọn) Xem bảng posts sau khi xóa
SELECT * FROM posts;
