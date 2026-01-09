USE social_network_pro;

-- (2) COMPOSITE INDEX
-- (2.1) EXPLAIN ANALYZE TRƯỚC KHI TẠO INDEX
EXPLAIN ANALYZE
SELECT
  post_id,
  content,
  created_at
FROM posts
WHERE user_id = 1
  AND created_at >= '2026-01-01 00:00:00'
  AND created_at <  '2027-01-01 00:00:00';

-- (2.2) Tạo composite index
-- Lưu ý: thứ tự (created_at, user_id) theo đề bài
CREATE INDEX idx_created_at_user_id
ON posts (created_at, user_id);

-- (2.3) EXPLAIN ANALYZE SAU KHI TẠO INDEX
EXPLAIN ANALYZE
SELECT
  post_id,
  content,
  created_at
FROM posts
WHERE user_id = 1
  AND created_at >= '2026-01-01 00:00:00'
  AND created_at <  '2027-01-01 00:00:00';

-- (3) UNIQUE INDEX
-- (3.1) EXPLAIN ANALYZE TRƯỚC KHI TẠO UNIQUE INDEX
EXPLAIN ANALYZE
SELECT
  user_id,
  username,
  email
FROM users
WHERE email = 'an@gmail.com';

-- (3.2) Tạo unique index trên email
CREATE UNIQUE INDEX idx_email
ON users (email);

-- (3.3) EXPLAIN ANALYZE SAU KHI TẠO UNIQUE INDEX
EXPLAIN ANALYZE
SELECT
  user_id,
  username,
  email
FROM users
WHERE email = 'an@gmail.com';

-- (4) XÓA CHỈ MỤC
DROP INDEX idx_created_at_user_id ON posts;
DROP INDEX idx_email ON users;


