-- tạo Database
CREATE DATABASE session02_student;

-- chọn CSDL muốn tạo bảng
USE session02_student;
CREATE TABLE Student (
-- mã sinh viên : char(10) → khóa chính (duy nhất)
    student_id CHAR(10) PRIMARY KEY,
-- họ tên sinh viênstudentssys_config
    full_name VARCHAR(50) NOT NULL
);

CREATE TABLE Subject (
-- mã môn học : char(10) → khóa chính (duy nhất)
    subject_id CHAR(10) PRIMARY KEY,
-- tên môn học
    subject_name VARCHAR(50) NOT NULL,
-- số tín chỉ
    credit INT NOT NULL,
-- ràng buộc: số tín chỉ phải lớn hơn 0
    CONSTRAINT chk_credit CHECK (credit > 0)
);
