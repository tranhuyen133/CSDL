-- tạo Database
CREATE DATABASE session02_DDL_table;
-- chọn CSDL muốn tạo bảng
USE session02_DDL_table;
CREATE TABLE Class (
-- mã lớp : char(10)  khóa chính
    class_id CHAR(10) PRIMARY KEY,
-- tên lớp : varchar(50)
    class_name VARCHAR(50) NOT NULL,
-- năm học : int
    school_year INT NOT NULL
);
CREATE TABLE Student (
-- mã sinh viên : char(10) - khóa chính
    student_id CHAR(10) PRIMARY KEY,
-- họ và tên : varchar(50)
    full_name VARCHAR(50) NOT NULL,
-- ngày sinh : datestudents
    date_of_birth DATE NOT NULL,
-- mã lớp học : char(10) → khóa ngoại
    class_id CHAR(10) NOT NULL,
-- thiết lập khóa ngoại
-- mỗi sinh viên thuộc về một lớp
    CONSTRAINT fk_student_class
        FOREIGN KEY (class_id)
        REFERENCES Class(class_id)
);
