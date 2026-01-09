USE social_network_pro;

-- (1) Xóa view nếu đã tồn tại
DROP VIEW IF EXISTS view_users_summary;

-- (2) Tạo view thống kê tổng số bài viết theo từng user
CREATE VIEW view_users_summary AS
SELECT
  u.user_id AS user_id,
  u.username AS username,
  COUNT(p.post_id) AS total_posts
FROM users u
LEFT JOIN posts p
  ON p.user_id = u.user_id
GROUP BY u.user_id, u.username;

--  kiểm tra nhanh toàn bộ view
SELECT * FROM view_users_summary
ORDER BY total_posts DESC, username ASC;

-- (3) Truy vấn từ view: chỉ lấy user có total_posts > 5
SELECT
  user_id,
  username,
  total_posts
FROM view_users_summary
WHERE total_posts > 5
ORDER BY total_posts DESC, username ASC;
