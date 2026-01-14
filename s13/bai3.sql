/* =========================================================
   FULL CODE — BÀI TẬP 3 (GIỎI)
   Quản lý lượt thích với 3 bảng: users, posts, likes
   - Chặn self-like (BEFORE INSERT / BEFORE UPDATE)
   - Cập nhật like_count khi INSERT / DELETE / UPDATE (đổi post_id)
   - View user_statistics (từ bài 2)
   - Script test đầy đủ
========================================================= */

-- 0) TẠO DB (nếu bạn muốn chạy độc lập). Nếu đã có DB thì có thể bỏ 2 dòng này.
DROP DATABASE IF EXISTS SocialTriggerDB;
CREATE DATABASE SocialTriggerDB;
USE SocialTriggerDB;

-- 1) SETUP LẠI BẢNG (để chạy độc lập từ đầu)
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATE,
    follower_count INT DEFAULT 0,
    post_count INT DEFAULT 0
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT,
    created_at DATETIME,
    like_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    UNIQUE (user_id, post_id) -- chống like trùng
);

-- 2) DỮ LIỆU MẪU (users, posts, likes)
INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');

INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

-- Đồng bộ post_count ban đầu (vì bài trước dùng trigger; ở đây chạy độc lập nên set bằng query)
UPDATE users u
SET u.post_count = (
    SELECT COUNT(*) FROM posts p WHERE p.user_id = u.user_id
);

-- Likes mẫu (không tự like)
INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

-- 3) DROP TRIGGER (để chạy lại không lỗi)
DROP TRIGGER IF EXISTS tg_likes_before_insert_no_self_like;
DROP TRIGGER IF EXISTS tg_likes_before_update_no_self_like;
DROP TRIGGER IF EXISTS tg_likes_after_insert;
DROP TRIGGER IF EXISTS tg_likes_after_delete;
DROP TRIGGER IF EXISTS tg_likes_after_update;

-- 4) TẠO TRIGGER CHO LIKES
DELIMITER //

-- (A) BEFORE INSERT: không cho phép user like bài của chính mình
CREATE TRIGGER tg_likes_before_insert_no_self_like
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE post_owner_id INT;

    SELECT user_id
    INTO post_owner_id
    FROM posts
    WHERE post_id = NEW.post_id;

    IF post_owner_id = NEW.user_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không thể like bài đăng của chính mình!';
    END IF;
END//

-- (B) BEFORE UPDATE: nếu đổi post_id hoặc user_id thì vẫn chặn self-like
CREATE TRIGGER tg_likes_before_update_no_self_like
BEFORE UPDATE ON likes
FOR EACH ROW
BEGIN
    DECLARE post_owner_id INT;

    IF (NEW.post_id <> OLD.post_id) OR (NEW.user_id <> OLD.user_id) THEN
        SELECT user_id
        INTO post_owner_id
        FROM posts
        WHERE post_id = NEW.post_id;

        IF post_owner_id = NEW.user_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Không thể like bài đăng của chính mình!';
        END IF;
    END IF;
END//

-- (C) AFTER INSERT: tăng like_count của post
CREATE TRIGGER tg_likes_after_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END//

-- (D) AFTER DELETE: giảm like_count của post (không cho âm)
CREATE TRIGGER tg_likes_after_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = CASE WHEN like_count > 0 THEN like_count - 1 ELSE 0 END
    WHERE post_id = OLD.post_id;
END//

-- (E) AFTER UPDATE: nếu đổi post_id -> trừ post cũ, cộng post mới
CREATE TRIGGER tg_likes_after_update
AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
    IF NEW.post_id <> OLD.post_id THEN
        UPDATE posts
        SET like_count = CASE WHEN like_count > 0 THEN like_count - 1 ELSE 0 END
        WHERE post_id = OLD.post_id;

        UPDATE posts
        SET like_count = like_count + 1
        WHERE post_id = NEW.post_id;
    END IF;
END//

DELIMITER ;

-- 5) ĐỒNG BỘ like_count BAN ĐẦU (vì likes đã insert trước trigger)
UPDATE posts p
SET p.like_count = (
    SELECT COUNT(*) FROM likes l WHERE l.post_id = p.post_id
);

-- 6) VIEW user_statistics (bài 2)
DROP VIEW IF EXISTS user_statistics;

CREATE VIEW user_statistics AS
SELECT
    u.user_id,
    u.username,
    u.post_count,
    COALESCE(SUM(p.like_count), 0) AS total_likes
FROM users u
LEFT JOIN posts p ON p.user_id = u.user_id
GROUP BY u.user_id, u.username, u.post_count;

-- =========================================================
-- 7) TEST THEO ĐỀ BÀI
-- =========================================================

-- 7.1) Thử like bài của chính mình (Alice user_id=1 đang là chủ post_id=1) => PHẢI BÁO LỖI
-- BỎ COMMENT để test lỗi:
-- INSERT INTO likes (user_id, post_id, liked_at) VALUES (1, 1, NOW());

-- 7.2) Thêm like hợp lệ (Bob like post 4 của Charlie) => like_count post 4 tăng
INSERT INTO likes (user_id, post_id, liked_at) VALUES (2, 4, NOW());
SELECT post_id, user_id, like_count FROM posts WHERE post_id = 4;

-- 7.3) UPDATE một like sang post khác (chuyển like vừa thêm từ post 4 sang post 2)
-- Lưu ý: post 2 là của Alice (user 1), Bob (2) like được => OK
UPDATE likes
SET post_id = 2
WHERE user_id = 2 AND post_id = 4
ORDER BY like_id DESC
LIMIT 1;

-- Kiểm tra like_count của cả hai post (4 và 2)
SELECT post_id, like_count FROM posts WHERE post_id IN (2, 4);

-- 7.4) Xóa like và kiểm tra lại
DELETE FROM likes
WHERE user_id = 2 AND post_id = 2
ORDER BY like_id DESC
LIMIT 1;

SELECT post_id, like_count FROM posts WHERE post_id = 2;

-- 7.5) Kiểm chứng tổng hợp qua posts và view
SELECT * FROM posts ORDER BY post_id;
SELECT * FROM user_statistics ORDER BY user_id;
