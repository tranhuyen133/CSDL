
-- 1. Tạo bảng Subject với các ràng buộc
CREATE TABLE Subject (
    subject_id INT PRIMARY KEY,        -- mã môn học (khóa chính)
    subject_name VARCHAR(100) NOT NULL,-- tên môn học
    credit INT CHECK (credit > 0)       -- số tín chỉ phải lớn hơn 0
);

-- 2. Thêm dữ liệu cho một số môn học
INSERT INTO Subject (subject_id, subject_name, credit)
VALUES
(1, 'Co so du lieu', 3),
(2, 'Lap trinh Java', 4),
(3, 'Mang may tinh', 3);

-- 3. Cập nhật số tín chỉ cho một môn học
-- Ví dụ: cập nhật số tín chỉ môn có subject_id = 2
UPDATE Subject
SET credit = 5
WHERE subject_id = 2;

-- 4. Đổi tên một môn học
-- Ví dụ: đổi tên môn có subject_id = 1
UPDATE Subject
SET subject_name = 'Co so du lieu nang cao'
WHERE subject_id = 1;

-- 5. Hiển thị lại danh sách môn học sau khi cập nhật
SELECT * FROM Subject;
