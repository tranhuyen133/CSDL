

CREATE DATABASE session02_student;
USE session02_student;

CREATE TABLE Student (
    -- mã sinh viên
    student_id CHAR(10) PRIMARY KEY,
    
    -- họ tên sinh viên
    full_name VARCHAR(50) NOT NULL
);

-- TẠO BẢNG SUBJECT (MÔN HỌC)
CREATE TABLE Subject (
    -- mã môn học
    subject_id CHAR(10) PRIMARY KEY,
    
    -- tên môn học
    subject_name VARCHAR(50) NOT NULL,
    
    -- số tín chỉ (phải > 0)
    credit INT NOT NULL CHECK (credit > 0)
);

-- TẠO BẢNG ENROLLMENT (ĐĂNG KÝ MÔN HỌC)

CREATE TABLE Enrollment (
    -- mã sinh viên
    student_id CHAR(10) NOT NULL,
    
    -- mã môn học
    subject_id CHAR(10) NOT NULL,
    
    -- ngày đăng ký
    enroll_date DATE NOT NULL,
    
    -- khóa chính ghép
    -- đảm bảo 1 sinh viên không đăng ký trùng 1 môn
    PRIMARY KEY (student_id, subject_id),
    
    -- khóa ngoại tới bảng Student
    FOREIGN KEY (student_id)
        REFERENCES Student(student_id),
    
    -- khóa ngoại tới bảng Subject
    FOREIGN KEY (subject_id)
        REFERENCES Subject(subject_id)
);

-- THÊM DỮ LIỆU MẪU


-- thêm sinh viên
INSERT INTO Student (student_id, full_name)
VALUES
('SV01', 'Nguyen Van A'),
('SV02', 'Tran Thi B');

-- thêm môn học
INSERT INTO Subject (subject_id, subject_name, credit)
VALUES
('MH01', 'Co so du lieu', 3),
('MH02', 'Lap trinh C', 4);

-- thêm đăng ký môn học
INSERT INTO Enrollment (student_id, subject_id, enroll_date)
VALUES
('SV01', 'MH01', '2025-10-01'),
('SV01', 'MH02', '2025-10-02'),
('SV02', 'MH01', '2025-10-03');

-- TRUY VẤN DỮ LIỆU

-- 1. Lấy ra tất cả các lượt đăng ký
SELECT *
FROM Enrollment;

-- 2. Lấy ra các lượt đăng ký của sinh viên SV01
SELECT *
FROM Enrollment
WHERE student_id = 'SV01';
