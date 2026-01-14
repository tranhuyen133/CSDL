-- 1) Tạo bảng likes
DROP TABLE IF EXISTS likes;

CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

-- 2) Thêm dữ liệu mẫu vào likes (dùng post_id hiện có)
INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

-- 3) Trigger AFTER INSERT và AFTER DELETE trên likes để cập nhật posts.like_count
DELIMITER //

CREATE TRIGGER tg_likes_after_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END//

CREATE TRIGGER tg_likes_after_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
END//

DELIMITER ;

-- (Khuyến nghị) Đồng bộ lại like_count cho an toàn (nếu trước đó posts.like_count chưa đúng)
-- Bạn có thể chạy 1 lần để đảm bảo like_count = số like thực tế trong likes
UPDATE posts p
SET p.like_count = (
    SELECT COUNT(*) FROM likes l WHERE l.post_id = p.post_id
);

-- 4) Tạo View user_statistics: user_id, username, post_count, total_likes
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

-- 5) Test thêm 1 lượt thích và kiểm chứng
INSERT INTO likes (user_id, post_id, liked_at)
VALUES (2, 4, NOW());

SELECT * FROM posts WHERE post_id = 4;
SELECT * FROM user_statistics;

-- 6) Xóa một lượt thích và kiểm chứng lại View
-- Ví dụ: xóa lượt like vừa thêm (user_id=2, post_id=4) theo bản ghi mới nhất
DELETE FROM likes
WHERE user_id = 2 AND post_id = 4
ORDER BY like_id DESC
LIMIT 1;

SELECT * FROM posts WHERE post_id = 4;
SELECT * FROM user_statistics;
