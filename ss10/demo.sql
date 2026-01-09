
-- PHẦN 1: DATABASE SS10 (BÀI CƠ BẢN: TABLE + INDEX + VIEW)

DROP DATABASE IF EXISTS ss10;
CREATE DATABASE ss10;
USE ss10;

-- Tạo bảng users (ss10)
CREATE TABLE users(
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

-- Insert dữ liệu (KHÔNG nhét id để tránh trùng PK)
INSERT INTO users (name) VALUES
('Nguyen van A'),
('Nguyen Van B'),
('Nguyen Van C'),
('Nguyen Van D');

INSERT INTO users (name) VALUES
('Nguyen Van E');

-- Thêm cột email UNIQUE
ALTER TABLE users
ADD COLUMN email VARCHAR(50) UNIQUE;

-- (tuỳ chọn) cập nhật email để test index
UPDATE users SET email='a@gmail.com' WHERE id=1;
UPDATE users SET email='b@gmail.com' WHERE id=2;
UPDATE users SET email='c@gmail.com' WHERE id=3;
UPDATE users SET email='d@gmail.com' WHERE id=4;
UPDATE users SET email='e@gmail.com' WHERE id=5;

-- Tạo chỉ mục cho email và name (composite index)
CREATE INDEX idx_02 ON users(email, name);

-- EXPLAIN theo dõi truy vấn (đúng cột name/email)
EXPLAIN SELECT * FROM users WHERE name='abc';
EXPLAIN ANALYZE SELECT * FROM users WHERE name='Nguyen van A';
EXPLAIN SELECT * FROM users WHERE email='a@gmail.com';

-- Tạo view (đúng cột đang có)
DROP VIEW IF EXISTS view_user_info;

CREATE VIEW view_user_info AS
SELECT id, name, email
FROM users;

-- Kiểm tra view
SELECT * FROM view_user_info;

-- Xoá view (nếu cần)
-- DROP VIEW view_user_info;

-- Kiểm tra bảng users
SELECT * FROM ss10.users;

-- PHẦN 2: DATABASE SOCIAL_NETWORK (GỘP 2 VÍ DỤ VIEW NÂNG CAO)

DROP DATABASE IF EXISTS social_network;
CREATE DATABASE social_network;
USE social_network;

-- 1) users
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2) posts
CREATE TABLE posts (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content TEXT,
  privacy ENUM('PUBLIC', 'FRIEND', 'PRIVATE') DEFAULT 'PUBLIC',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 3) comments
CREATE TABLE comments (
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(post_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 4) likes
CREATE TABLE likes (
  like_id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(post_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Insert sample data
INSERT INTO users (username, email, phone) VALUES
('alice', 'alice@gmail.com', '0901111111'),
('bob', 'bob@gmail.com', '0902222222'),
('charlie', 'charlie@gmail.com', '0903333333'),
('david', 'david@gmail.com', '0904444444');

INSERT INTO posts (user_id, content, privacy, created_at) VALUES
(1, 'Hello world from Alice', 'PUBLIC', '2024-01-10'),
(2, 'Bob private post', 'PRIVATE', '2024-02-01'),
(3, 'Charlie public sharing', 'PUBLIC', '2024-03-05'),
(1, 'Alice friend-only post', 'FRIEND', '2024-03-20'),
(4, 'David public post', 'PUBLIC', '2024-04-01');

INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, 'Nice post!'),
(1, 3, 'Welcome Alice'),
(3, 1, 'Good content'),
(5, 2, 'Great post David');

INSERT INTO likes (post_id, user_id) VALUES
(1, 2),
(1, 3),
(3, 1),
(3, 2),
(5, 1),
(5, 3);

-- =========================================================
-- VÍ DỤ 1 (VIEW): Thông tin 1 bài viết + thống kê like/comment
-- Gồm: người tạo, thời gian tạo, nội dung, số lượt thích, số bình luận
-- GROUP BY + COUNT(DISTINCT...) để tránh nhân bản dòng
-- =========================================================

DROP VIEW IF EXISTS view_post_full_info;

CREATE VIEW view_post_full_info AS
SELECT
  p.post_id,
  u.user_id,
  u.username AS author_username,
  p.created_at AS post_created_at,
  p.content AS post_content,
  COUNT(DISTINCT l.like_id)    AS like_count,
  COUNT(DISTINCT c.comment_id) AS comment_count
FROM posts p
JOIN users u
  ON u.user_id = p.user_id
LEFT JOIN likes l
  ON l.post_id = p.post_id
LEFT JOIN comments c
  ON c.post_id = p.post_id
GROUP BY
  p.post_id, u.user_id, u.username, p.created_at, p.content;

-- Kiểm tra ví dụ 1
SELECT *
FROM view_post_full_info
ORDER BY post_created_at DESC;

-- Xem 1 bài cụ thể (ví dụ post_id = 1)
SELECT *
FROM view_post_full_info
WHERE post_id = 1;


-- =========================================================
-- VÍ DỤ 2 (VIEW): Danh sách "bạn bè" của user đầu tiên (user_id = 1)
-- Vì chưa có bảng friends nên mô phỏng bạn bè bằng tương tác:
--   - user đã LIKE bài của user 1 hoặc COMMENT bài của user 1
-- Trả về: tất cả thông tin người dùng (u.*)
-- =========================================================

DROP VIEW IF EXISTS view_friends_user1;

CREATE VIEW view_friends_user1 AS
SELECT DISTINCT
  u.*
FROM users u
JOIN (
  -- Người LIKE bài của user 1
  SELECT l.user_id
  FROM likes l
  JOIN posts p ON p.post_id = l.post_id
  WHERE p.user_id = 1

  UNION

  -- Người COMMENT bài của user 1
  SELECT c.user_id
  FROM comments c
  JOIN posts p ON p.post_id = c.post_id
  WHERE p.user_id = 1
) friend_ids
ON friend_ids.user_id = u.user_id
WHERE u.user_id <> 1;

-- Kiểm tra ví dụ 2
SELECT *
FROM view_friends_user1
ORDER BY user_id;
