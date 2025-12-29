
-- TẠO DATABASE

CREATE DATABASE session02_score_management;
USE session02_score_management;

-- TẠO BẢNG STUDENT (SINH VIÊN)

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
    subject_name VARCHAR(50) NOT NULL
);

-- TẠO BẢNG SCORE (BẢNG ĐIỂM)

CREATE TABLE Score (
    -- mã sinh viên
    student_id CHAR(10) NOT NULL,
    
    -- mã môn học
    subject_id CHAR(10) NOT NULL,
    
    -- điểm giữa kỳ
    mid_score DECIMAL(4,2) NOT NULL,
    
    -- điểm cuối kỳ
    final_score DECIMAL(4,2) NOT NULL,
    
    -- mỗi sinh viên chỉ có 1 bảng điểm / 1 môn
    PRIMARY KEY (student_id, subject_id),
    
    -- ràng buộc điểm từ 0 đến 10
    CONSTRAINT chk_mid_score CHECK (mid_score BETWEEN 0 AND 10),
    CONSTRAINT chk_final_score CHECK (final_score BETWEEN 0 AND 10),
    
    -- khóa ngoại tới Student
    FOREIGN KEY (student_id)
        REFERENCES Student(student_id),
        
    -- khóa ngoại tới Subject
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
INSERT INTO Subject (subject_id, subject_name)
VALUES
('MH01', 'Co so du lieu'),
('MH02', 'Lap trinh C');

-- thêm điểm cho sinh viên
INSERT INTO Score (student_id, subject_id, mid_score, final_score)
VALUES
('SV01', 'MH01', 7.5, 8.0),
('SV01', 'MH02', 6.0, 7.0),
('SV02', 'MH01', 8.0, 8.5);

-- CẬP NHẬT ĐIỂM CUỐI KỲ

-- cập nhật điểm cuối kỳ cho sinh viên SV01 môn MH02
UPDATE Score
SET final_score = 8.5
WHERE student_id = 'SV01'
  AND subject_id = 'MH02';

-- TRUY VẤN DỮ LIỆU

-- 1. Lấy ra toàn bộ bảng điểm
SELECT *
FROM Score;

-- 2. Lấy ra sinh viên có điểm cuối kỳ từ 8 trở lên
SELECT *
FROM Score
WHERE final_score >= 8;
