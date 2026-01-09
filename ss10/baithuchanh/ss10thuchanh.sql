USE social_network_pro;

-- =========================================================
-- PHẦN A – VIEW (Khung nhìn)
-- =========================================================
/* ---------------------------------------------------------
   CÂU 1. View hồ sơ người dùng công khai
   --------------------------------------------------------- */
DROP VIEW IF EXISTS view_public_user_profile;

CREATE VIEW view_public_user_profile AS
SELECT
  u.username,
  u.email,
  u.created_at
FROM users u;

-- Kiểm tra Câu 1
SELECT * FROM view_public_user_profile LIMIT 10;

/* ---------------------------------------------------------
   CÂU 2. View News Feed bài viết công khai (privacy='PUBLIC')
   --------------------------------------------------------- */
DROP VIEW IF EXISTS view_public_news_feed;

CREATE VIEW view_public_news_feed AS
SELECT
  u.username                  AS author_username,
  p.content                   AS post_content,
  p.created_at                AS post_created_at,
  COALESCE(lk.like_count, 0)  AS like_count
FROM posts p
JOIN users u
  ON u.user_id = p.user_id
LEFT JOIN (
  SELECT post_id, COUNT(*) AS like_count
  FROM likes
  GROUP BY post_id
) lk
  ON lk.post_id = p.post_id
WHERE p.privacy = 'PUBLIC';

-- Kiểm tra Câu 2
SELECT *
FROM view_public_news_feed
ORDER BY post_created_at DESC
LIMIT 10;

/* ---------------------------------------------------------
   CÂU 3. View có WITH CHECK OPTION (updatable)
   --------------------------------------------------------- */
DROP VIEW IF EXISTS view_public_posts_updatable;

CREATE VIEW view_public_posts_updatable AS
SELECT
  p.post_id,
  p.user_id,
  p.content,
  p.privacy,
  p.created_at
FROM posts p
WHERE p.privacy = 'PUBLIC'
WITH CHECK OPTION;

-- Kiểm tra dữ liệu public
SELECT *
FROM view_public_posts_updatable
ORDER BY created_at DESC
LIMIT 10;

-- Test CHECK OPTION (khuyến nghị chạy từng phần để quan sát rõ)
-- Không làm bẩn dữ liệu: dùng TRANSACTION + ROLLBACK
START TRANSACTION;

-- (A) INSERT hợp lệ -> ĐƯỢC PHÉP
INSERT INTO view_public_posts_updatable(user_id, content, privacy)
VALUES (1, 'TEST PUBLIC (insert qua view)', 'PUBLIC');

SELECT *
FROM view_public_posts_updatable
WHERE content = 'TEST PUBLIC (insert qua view)';

-- (B) INSERT không hợp lệ -> PHẢI BỊ CHẶN (mở comment để test)
ROLLBACK;

-- Sau rollback: không còn bản ghi test
SELECT *
FROM view_public_posts_updatable
WHERE content LIKE 'TEST %';

-- =========================================================
-- PHẦN B – INDEX (Chỉ mục)
-- =========================================================

/* ---------------------------------------------------------
   CÂU 4. Phân tích truy vấn News Feed bằng EXPLAIN
   --------------------------------------------------------- */
EXPLAIN
SELECT *
FROM posts
WHERE privacy = 'PUBLIC'
ORDER BY created_at DESC;


/* ---------------------------------------------------------
   CÂU 5. Tạo INDEX tối ưu + so sánh EXPLAIN
   --------------------------------------------------------- */

-- 5A) Tạo index cho news feed: idx_posts_privacy_created_at
SET @exists_idx1 := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'posts'
    AND index_name = 'idx_posts_privacy_created_at'
);

SET @sql1 := IF(
  @exists_idx1 = 0,
  'CREATE INDEX idx_posts_privacy_created_at ON posts (privacy, created_at)',
  'SELECT ''idx_posts_privacy_created_at already exists'' AS info'
);

PREPARE stmt1 FROM @sql1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- 5B) Tạo index cho truy vấn theo user: idx_posts_user_created_at
SET @exists_idx2 := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'posts'
    AND index_name = 'idx_posts_user_created_at'
);

SET @sql2 := IF(
  @exists_idx2 = 0,
  'CREATE INDEX idx_posts_user_created_at ON posts (user_id, created_at)',
  'SELECT ''idx_posts_user_created_at already exists'' AS info'
);

PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- EXPLAIN lại truy vấn news feed sau khi tạo index
EXPLAIN
SELECT *
FROM posts
WHERE privacy = 'PUBLIC'
ORDER BY created_at DESC;

-- EXPLAIN truy vấn lấy bài viết theo người dùng (ví dụ user_id = 1)
EXPLAIN
SELECT post_id, user_id, content, created_at
FROM posts
WHERE user_id = 1
ORDER BY created_at DESC
LIMIT 20;

/* ---------------------------------------------------------
   CÂU 6. Hạn chế của INDEX (trả lời ngắn gọn bằng comment)
   --------------------------------------------------------- */

-- (1) Khi nào KHÔNG nên tạo index?
-- - Bảng rất nhỏ: full scan nhanh hơn, index không đáng.
-- - Cột có độ phân tán thấp (ít giá trị khác nhau: giới tính/boolean): index ít hiệu quả.
-- - Hệ thống ghi nhiều (INSERT/UPDATE/DELETE liên tục): nhiều index làm chậm ghi.

-- (2) Vì sao không nên index cột nội dung bài viết (content)?
-- - content thường là TEXT dài: index B-Tree tốn dung lượng, ít hiệu quả cho LIKE '%keyword%'.
-- - Nếu cần tìm kiếm văn bản, dùng FULLTEXT INDEX (MATCH...AGAINST) thay vì index thường.

-- (3) Index ảnh hưởng thế nào đến INSERT/UPDATE?
-- - Mỗi lần INSERT/UPDATE/DELETE phải cập nhật cả dữ liệu + các cấu trúc index => tốn CPU/IO hơn.
-- - Càng nhiều index => ghi càng chậm; bù lại SELECT thường nhanh hơn.

-- (Tuỳ chọn) Xem danh sách index hiện có
-- SHOW INDEX FROM posts;
-- SHOW INDEX FROM users;
