USE social_network_pro;

-- (1) Xóa view nếu đã tồn tại
DROP VIEW IF EXISTS view_user_activity_status;

-- (2) Tạo view xác định trạng thái hoạt động
CREATE VIEW view_user_activity_status AS
SELECT
  u.user_id,
  u.username,
  u.gender,
  u.created_at,
  CASE
    WHEN COUNT(DISTINCT p.post_id) > 0 OR COUNT(DISTINCT c.comment_id) > 0
      THEN 'Active'
    ELSE 'Inactive'
  END AS status
FROM users u
LEFT JOIN posts p
  ON p.user_id = u.user_id
LEFT JOIN comments c
  ON c.user_id = u.user_id
GROUP BY
  u.user_id, u.username, u.gender, u.created_at;

-- (3) Truy vấn view để kiểm tra kết quả
SELECT
  user_id,
  username,
  gender,
  created_at,
  status
FROM view_user_activity_status
ORDER BY user_id;

-- (4) Thống kê số lượng người dùng theo từng trạng thái
SELECT
  status,
  COUNT(*) AS user_count
FROM view_user_activity_status
GROUP BY status
ORDER BY user_count DESC, status ASC;
