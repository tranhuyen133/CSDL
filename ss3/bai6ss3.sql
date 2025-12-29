-- 1. Tạo bảng Score với các ràng buộc phù hợp
CREATE TABLE Score (
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    mid_score DECIMAL(4,2) CHECK (mid_score BETWEEN 0 AND 10),
    final_score DECIMAL(4,2) CHECK (final_score BETWEEN 0 AND 10),

    -- Mỗi sinh viên chỉ có 1 bảng điểm cho mỗi môn
    PRIMARY KEY (student_id, subject_id),

    -- Khóa ngoại
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);

-- 2. Thêm điểm cho ít nhất 2 sinh viên
INSERT INTO Score (student_id, subject_id, mid_score, final_score)
VALUES
(1, 1, 7.5, 8.0),
(1, 2, 6.5, 7.0),
(2, 1, 8.0, 8.5),
(2, 3, 7.0, 9.0);

-- 3. Cập nhật điểm cuối kỳ cho một sinh viên
-- Ví dụ: cập nhật điểm cuối kỳ môn 1 của sinh viên có student_id = 1
UPDATE Score
SET final_score = 9.0
WHERE student_id = 1 AND subject_id = 1;

-- 4. Lấy ra toàn bộ bảng điểm
SELECT * FROM Score;

-- 5. Lấy ra các sinh viên có điểm cuối kỳ từ 8 trở lên
SELECT *
FROM Score
WHERE final_score >= 8;
