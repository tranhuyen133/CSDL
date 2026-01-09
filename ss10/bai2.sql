USE social_network_mini;

-- (1) Xóa view nếu đã tồn tại để tránh lỗi
DROP VIEW IF EXISTS view_user_post;

-- (2) Tạo view: tổng số bài viết theo từng user
CREATE VIEW view_user_post AS
SELECT
  u.user_id AS user_id,
  COUNT(p.post_id) AS total_user_post
FROM users u
LEFT JOIN posts p
  ON p.user_id = u.user_id
GROUP BY u.user_id;

-- (3) Hiển thị lại view_user_post để kiểm chứng
SELECT * FROM view_user_post
ORDER BY user_id;

-- (4) JOIN view_user_post với bảng users để hiển thị full_name và total_user_post
SELECT
  u.full_name,
  v.total_user_post
FROM users u
JOIN view_user_post v
  ON v.user_id = u.user_id
ORDER BY v.total_user_post DESC, u.full_name ASC;
