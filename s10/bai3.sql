USE social_network_pro;

-- (2) Truy vấn tìm tất cả user ở Hà Nội + EXPLAIN ANALYZE (TRƯỚC INDEX)
EXPLAIN ANALYZE
SELECT *
FROM users
WHERE hometown = 'Hà Nội';

-- (3) Tạo chỉ mục idx_hometown cho cột hometown
CREATE INDEX idx_hometown ON users (hometown);

-- (4) Chạy lại truy vấn + EXPLAIN ANALYZE (SAU INDEX)
EXPLAIN ANALYZE
SELECT *
FROM users
WHERE hometown = 'Hà Nội';

-- (6) Xóa chỉ mục idx_hometown
DROP INDEX idx_hometown ON users;


