
USE social_network;

-- 1) Thêm cột likes_count vào posts nếu chưa có
-- (Nếu đã có rồi thì câu này sẽ báo lỗi; khi đó bạn bỏ qua)
ALTER TABLE posts
ADD COLUMN likes_count INT DEFAULT 0;

-- 2) Tạo bảng likes
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY unique_like (post_id, user_id)
) ENGINE=InnoDB;

-- 3) Chuẩn bị dữ liệu test (nếu bạn đã có sẵn users/posts thì bỏ qua phần này)
-- Đảm bảo có user_id = 1 và post_id = 1 để test
INSERT INTO users(username, posts_count)
SELECT 'test_user', 0
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 1);

INSERT INTO posts(user_id, content)
SELECT 1, 'Post de test Like'
WHERE NOT EXISTS (SELECT 1 FROM posts WHERE post_id = 1);

-- ======================================================
-- CASE 1: LIKE LẦN ĐẦU -> COMMIT
-- post_id = 1, user_id = 1
-- ======================================================
START TRANSACTION;

    INSERT INTO likes(post_id, user_id)
    VALUES (1, 1);

    UPDATE posts
    SET likes_count = likes_count + 1
    WHERE post_id = 1;

COMMIT;

-- Kiểm tra sau Case 1
SELECT * FROM likes WHERE post_id = 1 AND user_id = 1;
SELECT post_id, likes_count FROM posts WHERE post_id = 1;

-- ======================================================
-- CASE 2: LIKE LẦN THỨ HAI CÙNG post_id & user_id
-- -> Vi phạm UNIQUE unique_like -> phải ROLLBACK
-- ======================================================
START TRANSACTION;

    -- Dòng này sẽ lỗi do đã tồn tại (1,1)
    INSERT INTO likes(post_id, user_id)
    VALUES (1, 1);

    -- Nếu insert fail, update không nên được áp dụng
    UPDATE posts
    SET likes_count = likes_count + 1
    WHERE post_id = 1;

-- Trong nhiều môi trường, khi câu lệnh INSERT lỗi thì transaction sẽ bị đánh dấu lỗi,
-- bạn chủ động rollback để đảm bảo không có thay đổi nào.
ROLLBACK;

-- Kiểm tra sau Case 2 (likes_count không tăng thêm)
SELECT COUNT(*) AS total_like_rows
FROM likes
WHERE post_id = 1 AND user_id = 1;

SELECT post_id, likes_count
FROM posts
WHERE post_id = 1;
