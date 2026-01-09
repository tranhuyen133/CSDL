USE social_network_pro;
-- (1) EXPLAIN ANALYZE TRƯỚC KHI TẠO INDEX idx_hometown
EXPLAIN ANALYZE
SELECT
  u_top.user_id,
  u_top.username,
  u_top.hometown,
  f.friend_id,
  uf.username AS friend_username,
  uf.full_name AS friend_full_name
FROM
(
  SELECT user_id, username, hometown
  FROM users
  WHERE hometown = 'Hà Nội'
  ORDER BY username DESC
  LIMIT 3
) AS u_top
LEFT JOIN friends f
  ON f.user_id = u_top.user_id
LEFT JOIN users uf
  ON uf.user_id = f.friend_id
ORDER BY u_top.username DESC, uf.username ASC;

-- (2) TẠO INDEX idx_hometown
CREATE INDEX idx_hometown ON users (hometown);

-- (3) EXPLAIN ANALYZE SAU KHI TẠO INDEX idx_hometown
EXPLAIN ANALYZE
SELECT
  u_top.user_id,
  u_top.username,
  u_top.hometown,
  f.friend_id,
  uf.username AS friend_username,
  uf.full_name AS friend_full_name
FROM
(
  SELECT user_id, username, hometown
  FROM users
  WHERE hometown = 'Hà Nội'
  ORDER BY username DESC
  LIMIT 3
) AS u_top
LEFT JOIN friends f
  ON f.user_id = u_top.user_id
LEFT JOIN users uf
  ON uf.user_id = f.friend_id
ORDER BY u_top.username DESC, uf.username ASC;

