-- Phải xóa profiles trước vì profiles phụ thuộc (FK) vào users
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS users;

-- TẠO BẢNG USERS: lưu thông tin tài khoản người dùng
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,          -- Khóa chính, tự tăng
    full_name VARCHAR(100) NOT NULL,            -- Họ tên (bắt buộc)
    username VARCHAR(100) NOT NULL UNIQUE,      -- Tên đăng nhập (không trùng)
    password VARCHAR(255) NOT NULL              -- Mật khẩu (bắt buộc)
);

-- TẠO BẢNG PROFILES: lưu thông tin hồ sơ chi tiết của user
CREATE TABLE profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,          -- Khóa chính, tự tăng
    user_id INT NOT NULL UNIQUE,                -- Mỗi user chỉ có 1 profile (UNIQUE)
    phone VARCHAR(10),                          -- SĐT (có thể null)
    email VARCHAR(100),                         -- Email (có thể null)
    address VARCHAR(255),                       -- Địa chỉ (có thể null)
    CONSTRAINT fk_profiles_users
        FOREIGN KEY (user_id) REFERENCES users(id)  -- Khóa ngoại: profiles.user_id -> users.id
);

DELIMITER //

/* TRIGGER 1: AFTER INSERT ON users
   Mục tiêu: Khi đăng ký (insert users) thành công -> tự tạo 1 profile rỗng tương ứng
   NEW.id là id vừa được tạo ở bảng users */
CREATE TRIGGER tg_create_profile_after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO profiles (user_id, phone, email, address)
    VALUES (NEW.id, NULL, NULL, NULL);          -- Tạo profile trống, chỉ gắn đúng user_id
END//

/* TRIGGER 2: AFTER DELETE ON users
   Mục tiêu: Khi xóa user -> xóa luôn profile của user đó để không còn dữ liệu mồ côi
   OLD.id là id của user trước khi bị xóa */
CREATE TRIGGER tg_delete_profile_after_user_delete
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    DELETE FROM profiles WHERE user_id = OLD.id; -- Xóa profile theo user_id
END//

-- Trả delimiter về mặc định
DELIMITER ;

-- =========================
-- TEST KIỂM TRA TRIGGER
-- =========================

-- 1) Thêm 1 user mới (giả lập đăng ký)
-- Sau lệnh này, trigger tg_create_profile_after_user_insert sẽ tự chạy và tạo profile
INSERT INTO users (full_name, username, password)
VALUES ('Hà Bích Ngọc', 'ngoc@vip.com', '123456');

-- 2) Kiểm tra bảng users và profiles
-- Kỳ vọng: users có 1 dòng, profiles cũng có 1 dòng với user_id đúng
SELECT * FROM users;
SELECT * FROM profiles;

-- 3) Xóa user vừa tạo
-- Sau lệnh này, trigger tg_delete_profile_after_user_delete sẽ tự chạy và xóa profile
DELETE FROM users WHERE id = 1;

-- 4) Kiểm tra lại
-- Kỳ vọng: users rỗng, profiles cũng rỗng
SELECT * FROM users;
SELECT * FROM profiles;
