

-- 0) Tạo DB + bảng (nếu đã có social_network thì bỏ phần CREATE DATABASE)
DROP DATABASE IF EXISTS social_network;
CREATE DATABASE social_network;
USE social_network;

DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    posts_count INT DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

-- dữ liệu mẫu
INSERT INTO users(username, posts_count) VALUES
('nguyen_van_a', 0),
('le_thi_b', 0);

-- ======================================================
-- CASE 1: THÀNH CÔNG (COMMIT)
-- ======================================================
START TRANSACTION;

    -- 1) Insert bài viết mới (user_id tồn tại)
    INSERT INTO posts(user_id, content)
    VALUES (1, 'Bai viet thanh cong - case COMMIT');

    -- 2) Update tăng posts_count của user tương ứng
    UPDATE users
    SET posts_count = posts_count + 1
    WHERE user_id = 1;

COMMIT;

-- Kiểm tra kết quả Case 1
SELECT * FROM posts ORDER BY post_id DESC;
SELECT * FROM users ORDER BY user_id;

-- ======================================================
-- CASE 2: CỐ Ý GÂY LỖI (ROLLBACK)
-- Ví dụ: user_id không tồn tại => vi phạm FK
-- ======================================================
START TRANSACTION;

    -- Insert sẽ lỗi do user_id = 9999 không tồn tại
    INSERT INTO posts(user_id, content)
    VALUES (9999, 'Bai viet se bi rollback do loi FK');

    -- Dòng này sẽ không chạy nếu insert lỗi,
    -- nhưng vẫn để minh hoạ "nếu 1 bước fail thì cả transaction fail"
    UPDATE users
    SET posts_count = posts_count + 1
    WHERE user_id = 9999;

-- Nếu bạn chạy trong môi trường không tự rollback khi lỗi,
-- bạn có thể chủ động rollback thủ công:
ROLLBACK;

-- Kiểm tra sau Case 2 (không có "dữ liệu nửa vời")
SELECT * FROM posts WHERE user_id = 9999;
SELECT * FROM users ORDER BY user_id;
