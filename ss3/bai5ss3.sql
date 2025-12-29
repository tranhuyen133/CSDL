-- 1. Tạo bảng Enrollment có khóa ngoại
CREATE TABLE Enrollment (
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    enroll_date DATE NOT NULL,

    -- Khóa chính kép: không cho phép 1 sinh viên đăng ký trùng 1 môn
    PRIMARY KEY (student_id, subject_id),

    -- Khóa ngoại
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);

-- 2. Thêm dữ liệu đăng ký môn học cho ít nhất 2 sinh viên
INSERT INTO Enrollment (student_id, subject_id, enroll_date)
VALUES
(1, 1, '2024-09-01'),
(1, 2, '2024-09-02'),
(2, 1, '2024-09-01'),
(2, 3, '2024-09-03');

-- 3. Lấy ra tất cả các lượt đăng ký
SELECT * FROM Enrollment;

-- 4. Lấy ra các lượt đăng ký của một sinh viên cụ thể
-- Ví dụ: sinh viên có student_id = 1
SELECT *
FROM Enrollment
WHERE student_id = 1;
