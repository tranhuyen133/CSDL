CREATE DATABASE session02_student;

-- chọn CSDL muốn tạo bảng
USE session02_student;
CREATE TABLE Student (
    -- mã sinh viên
    student_id CHAR(10) PRIMARY KEY,

    -- họ tên
    full_name VARCHAR(50) NOT NULL
);
CREATE TABLE Subject (
    -- mã môn học
    subject_id CHAR(10) PRIMARY KEY,

    -- tên môn học
    subject_name VARCHAR(50) NOT NULL,

    -- số tín chỉ
    credit INT NOT NULL CHECK (credit > 0)
);

CREATE TABLE Enrollment (
    -- mã sinh viên : char(10)
    student_id CHAR(10) NOT NULL,

    -- mã môn học : char(10)
    subject_id CHAR(10) NOT NULL,

    -- ngày đăng ký môn học
    enroll_date DATE NOT NULL,

    -- khóa chính ghép
    PRIMARY KEY (student_id, subject_id),

    -- khóa ngoại tới bảng Student
    FOREIGN KEY (student_id)
        REFERENCES Student(student_id),

    -- khóa ngoại tới bảng Subject
    FOREIGN KEY (subject_id)
        REFERENCES Subject(subject_id)
);
