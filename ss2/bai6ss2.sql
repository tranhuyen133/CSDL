
-- TẠO DATABASE

DROP DATABASE IF EXISTS training_management;
CREATE DATABASE training_management;
USE training_management;

-- TẠO BẢNG STUDENT

CREATE TABLE Student (
    student_id CHAR(10) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL
);

-- TẠO BẢNG SUBJECT

CREATE TABLE Subject (
    subject_id CHAR(10) PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    credit INT NOT NULL CHECK (credit > 0)
);

-- TẠO BẢNG ENROLLMENT (ĐĂNG KÝ MÔN)

CREATE TABLE Enrollment (
    student_id CHAR(10) NOT NULL,
    subject_id CHAR(10) NOT NULL,
    enroll_date DATE NOT NULL,

    -- khóa chính ghép: chống đăng ký trùng
    PRIMARY KEY (student_id, subject_id),

    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);

-- TẠO BẢNG SCORE (ĐIỂM)

CREATE TABLE Score (
    student_id CHAR(10) NOT NULL,
    subject_id CHAR(10) NOT NULL,
    mid_score DECIMAL(4,2) NOT NULL,
    final_score DECIMAL(4,2) NOT NULL,

    -- mỗi sinh viên có 1 bảng điểm / 1 môn
    PRIMARY KEY (student_id, subject_id),

    -- ràng buộc điểm hợp lệ
    CHECK (mid_score BETWEEN 0 AND 10),
    CHECK (final_score BETWEEN 0 AND 10),

    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);

-- DỮ LIỆU BAN ĐẦU

-- sinh viên cũ
INSERT INTO Student VALUES
('SV01', 'Nguyen Van A'),
('SV02', 'Tran Thi B');

-- môn học
INSERT INTO Subject VALUES
('MH01', 'Co so du lieu', 3),
('MH02', 'Lap trinh C', 4),
('MH03', 'He dieu hanh', 3);

-- 1. THÊM MỘT SINH VIÊN MỚI

INSERT INTO Student (student_id, full_name)
VALUES ('SV03', 'Le Van C');

-- 2. ĐĂNG KÝ ÍT NHẤT 2 MÔN CHO SINH VIÊN ĐÓ

INSERT INTO Enrollment (student_id, subject_id, enroll_date)
VALUES
('SV03', 'MH01', '2025-10-10'),
('SV03', 'MH02', '2025-10-10');

-- 3. THÊM & CẬP NHẬT ĐIỂM CHO SINH VIÊN VỪA THÊM

-- thêm điểm ban đầu
INSERT INTO Score (student_id, subject_id, mid_score, final_score)
VALUES
('SV03', 'MH01', 7.0, 0),
('SV03', 'MH02', 6.5, 0);

-- cập nhật điểm cuối kỳ
UPDATE Score
SET final_score = 8.0
WHERE student_id = 'SV03'
  AND subject_id = 'MH01';

UPDATE Score
SET final_score = 7.5
WHERE student_id = 'SV03'
  AND subject_id = 'MH02';

-- 4. XÓA MỘT LƯỢT ĐĂNG KÝ KHÔNG HỢP LỆ
-- (ví dụ: SV03 hủy đăng ký môn MH02)

DELETE FROM Enrollment
WHERE student_id = 'SV03'
  AND subject_id = 'MH02';

-- 5. LẤY RA DANH SÁCH SINH VIÊN & ĐIỂM SỐ

SELECT 
    s.student_id,
    s.full_name,
    sub.subject_name,
    sc.mid_score,
    sc.final_score
FROM Student s
JOIN Score sc ON s.student_id = sc.student_id
JOIN Subject sub ON sc.subject_id = sub.subject_id
ORDER BY s.student_id;
