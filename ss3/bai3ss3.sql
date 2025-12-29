-- 1. Cập nhật email cho sinh viên có student_id = 3
UPDATE students
SET email = 'sv3_new@gmail.com'
WHERE student_id = 3;

-- 2. Cập nhật ngày sinh cho sinh viên có student_id = 2
UPDATE students
SET date_of_birth = '2003-01-15'
WHERE student_id = 2;

-- 3. Xóa sinh viên nhập nhầm (student_id = 5)
DELETE FROM students
WHERE student_id = 5;

-- 4. Kiểm tra lại dữ liệu sau khi cập nhật và xóa
SELECT * FROM Student;
