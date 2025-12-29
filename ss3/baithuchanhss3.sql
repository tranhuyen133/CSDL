-- : TẠO DATABASE
CREATE DATABASE QuanLyDaoTao;
USE QuanLyDaoTao;
--  TẠO BẢNG SINHVIEN
CREATE TABLE SinhVien (
    maSV CHAR(10) PRIMARY KEY,
    hoTen VARCHAR(50) NOT NULL,
    ngaySinh DATE NOT NULL,
    email VARCHAR(50)
);

-- TẠO BẢNG MONHOC
CREATE TABLE MonHoc (
    maMH CHAR(10) PRIMARY KEY,
    tenMH VARCHAR(100) NOT NULL,
    credits INT DEFAULT 3
);

-- TẠO BẢNG DANGKY
CREATE TABLE DangKy (
    maSV CHAR(10),
    maMH CHAR(10),
    semester VARCHAR(10),
    PRIMARY KEY (maSV, maMH),
    FOREIGN KEY (maSV) REFERENCES SinhVien(maSV),
    FOREIGN KEY (maMH) REFERENCES MonHoc(maMH)
);

-- PHẦN 5: ALTER TABLE – CHỈNH SỬA BẢNG

-- 1. Thêm cột số điện thoại cho SinhVien
ALTER TABLE SinhVien
ADD phone CHAR(10);

-- 2. Thêm ràng buộc UNIQUE cho email
ALTER TABLE SinhVien
ADD CONSTRAINT uq_email UNIQUE (email);

-- 3. Thay đổi kiểu dữ liệu cột semester
ALTER TABLE DangKy
MODIFY semester VARCHAR(20);

-- 4. Thêm ràng buộc CHECK cho credits
ALTER TABLE MonHoc
ADD CONSTRAINT chk_credits CHECK (credits > 0);

-- 5. Xóa cột không cần thiết (ví dụ: ngaySinh)
ALTER TABLE SinhVien
DROP COLUMN ngaySinh;

-- PHẦN 6: KIỂM TRA CẤU TRÚC BẢNG
DESCRIBE SinhVien;
DESCRIBE MonHoc;
DESCRIBE DangKy;
