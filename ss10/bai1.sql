USE social_network_mini;

-- (0) Dọn dữ liệu test cũ (nếu bạn đã chạy trước đó mà bị sót)
DELETE FROM users
WHERE username = 'nguyen_view_test';

-- (1) Xóa view nếu đã tồn tại
DROP VIEW IF EXISTS view_users_firstname;

-- (2) Tạo view: danh sách người dùng có họ "Nguyễn"
CREATE VIEW view_users_firstname AS
SELECT
  user_id,
  username,
  full_name,
  email,
  created_at
FROM users
WHERE full_name LIKE 'Nguyễn%';

-- (3) Hiển thị lại view vừa tạo
SELECT * FROM view_users_firstname;

-- (4) Thêm 1 nhân viên mới vào bảng users có họ "Nguyễn"
INSERT INTO users (username, full_name, gender, email, password, birthdate, hometown)
VALUES ('nguyen_view_test', 'Nguyễn Văn View', 'Nam', 'nguyen_view_test@gmail.com', '123', '1999-01-01', 'Hà Nội');

-- (4.1) Truy vấn lại view để kiểm tra user vừa thêm có xuất hiện không
SELECT *
FROM view_users_firstname
WHERE username = 'nguyen_view_test';

-- (5) Xóa nhân viên vừa thêm khỏi bảng users
DELETE FROM users
WHERE username = 'nguyen_view_test';

-- (5.1) Truy vấn lại view để kiểm tra user vừa xóa còn xuất hiện không
SELECT *
FROM view_users_firstname
WHERE username = 'nguyen_view_test';
