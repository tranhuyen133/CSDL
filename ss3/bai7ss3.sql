-- =====================================================
-- 1. Thêm một sinh viên mới
-- =====================================================
INSERT INTO Student (student_id, full_name, date_of_birth, email)
VALUES (10, 'Nguyen Van Tong', '2003-04-10', 'tong@gmail.com');

-- =====================================================
-- 2. Đăng ký ít nhất 2 môn học cho sinh viên đó
-- =====================================================
INSERT INTO Enrollment (student_id, subject_id, enroll_date)
VALUES
(10, 1, '2024-09-01'),
(10, 2, '2024-09-01');

-- =====================================================
-- 3. Thêm điểm cho sinh viên vừa thêm
-- =====================================================
INSERT INTO Score (student_id, subject_id, mid_score, final_score)
VALUES
(10, 1, 7.5, 8.0),
(10, 2, 6.5, 7.0);

-- =====================================================
-- 4. Cập nhật điểm cho sinh viên vừa thêm
-- Ví dụ: cập nhật điểm cuối kỳ môn subject_id = 2
-- =====================================================
UPDATE Score
SET final_score = 8.5
WHERE student_id = 10 AND subject_id = 2;

-- =====================================================
-- 5. Xóa một lượt đăng ký không hợp lệ
-- Ví dụ: xóa đăng ký môn subject_id = 1 của sinh viên 10
-- =====================================================
DELETE FROM Enrollment
WHERE student_id = 10 AND subject_id = 1;

-- =====================================================
-- 6. Lấy ra danh sách sinh viên và điểm số tương ứng
-- =====================================================
SELECT 
    s.student_id,
    s.full_name,
    sub.subject_name,
    sc.mid_score,
    sc.final_score
FROM Student s
JOIN Score sc ON s.student_id = sc.student_id
JOIN Subject sub ON sc.subject_id = sub.subject_id;
