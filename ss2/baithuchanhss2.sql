/* =========================================================
   BÀI THỰC HÀNH TỔNG HỢP SQL
   Chủ đề: Kiểu dữ liệu – Ràng buộc – Thao tác với bảng
   ========================================================= */

------------------------------------------------------------
-- PHẦN 0: TẠO DATABASE
------------------------------------------------------------

DROP DATABASE IF EXISTS training_sql_practice;
CREATE DATABASE training_sql_practice;

-- chọn CSDL để làm việc
USE training_sql_practice;


------------------------------------------------------------
-- PHẦN 1 & 2: TẠO BẢNG + KIỂU DỮ LIỆU + RÀNG BUỘC
------------------------------------------------------------

-- ========================
-- BẢNG SINHVIEN
-- ========================

CREATE TABLE SinhVien (
    student_id CHAR(10) PRIMARY KEY,        -- mã sinh viên (PK)
    full_name VARCHAR(50) NOT NULL,          -- họ tên sinh viên
    email VARCHAR(50),                       -- email
    birth_date DATE NOT NULL                 -- ngày sinh
);

-- ========================
-- BẢNG MONHOC
-- ========================

CREATE TABLE MonHoc (
    subject_id CHAR(10) PRIMARY KEY,         -- mã môn học (PK)
    subject_name VARCHAR(50) NOT NULL,       -- tên môn học
    credits INT NOT NULL                     -- số tín chỉ
);

-- ========================
-- BẢNG DANGKY (QUAN HỆ N–N)
-- ========================

CREATE TABLE DangKy (
    student_id CHAR(10) NOT NULL,            -- FK -> SinhVien
    subject_id CHAR(10) NOT NULL,            -- FK -> MonHoc
    semester VARCHAR(10) DEFAULT 'HK1',      -- học kỳ
    enroll_date DATE NOT NULL,               -- ngày đăng ký

    -- khóa chính ghép: không đăng ký trùng
    PRIMARY KEY (student_id, subject_id),

    FOREIGN KEY (student_id) REFERENCES SinhVien(student_id),
    FOREIGN KEY (subject_id) REFERENCES MonHoc(subject_id)
);


------------------------------------------------------------
-- PHẦN 3: ALTER TABLE (CHỈNH SỬA BẢNG)
------------------------------------------------------------

-- 1. Thêm cột số điện thoại cho bảng SinhVien
ALTER TABLE SinhVien
ADD COLUMN phone CHAR(10);
-- Lý do: bổ sung thông tin liên hệ sinh viên

-- 2. Thêm ràng buộc UNIQUE cho email
ALTER TABLE SinhVien
ADD CONSTRAINT uq_email UNIQUE (email);
-- Lý do: email không được trùng

-- 3. Thay đổi kiểu dữ liệu cột semester trong DangKy
ALTER TABLE DangKy
MODIFY COLUMN semester VARCHAR(20);
-- Lý do: lưu học kỳ linh hoạt (HK1-2025, HK2-2025)

-- 4. Bổ sung CHECK cho cột credits
ALTER TABLE MonHoc
ADD CONSTRAINT chk_credits CHECK (credits > 0);
-- Lý do: số tín chỉ phải lớn hơn 0

-- 5. Xóa cột không cần thiết (birth_date)
ALTER TABLE SinhVien
DROP COLUMN birth_date;
-- Lý do: không còn sử dụng trong nghiệp vụ hiện tại


------------------------------------------------------------
-- PHẦN 4: INSERT DỮ LIỆU MẪU
------------------------------------------------------------

-- thêm sinh viên
INSERT INTO SinhVien (student_id, full_name, email, phone)
VALUES
('SV01', 'Nguyen Van A', 'a@gmail.com', '0912345678'),
('SV02', 'Tran Thi B', 'b@gmail.com', '0987654321');

-- thêm môn học
INSERT INTO MonHoc (subject_id, subject_name, credits)
VALUES
('MH01', 'Co so du lieu', 3),
('MH02', 'Lap trinh C', 4),
('MH03', 'He dieu hanh', 3);

-- đăng ký môn học
INSERT INTO DangKy (student_id, subject_id, semester, enroll_date)
VALUES
('SV01', 'MH01', 'HK1-2025', '2025-10-01'),
('SV01', 'MH02', 'HK1-2025', '2025-10-01'),
('SV02', 'MH01', 'HK1-2025', '2025-10-02');


------------------------------------------------------------
-- PHẦN 5: TRUY VẤN KIỂM TRA DỮ LIỆU
------------------------------------------------------------

-- lấy danh sách sinh viên và môn học đã đăng ký
SELECT
    sv.student_id,
    sv.full_name,
    mh.subject_name,
    dk.semester,
    dk.enroll_date
FROM SinhVien sv
JOIN DangKy dk ON sv.student_id = dk.student_id
JOIN MonHoc mh ON dk.subject_id = mh.subject_id
ORDER BY sv.student_id;
