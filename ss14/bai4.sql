

DELIMITER //

DROP PROCEDURE IF EXISTS sp_enroll_course//
CREATE PROCEDURE sp_enroll_course(
    IN p_student_name VARCHAR(50),
    IN p_course_name  VARCHAR(100)
)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_course_id INT;
    DECLARE v_seats INT;

    -- Validate input
    IF p_student_name IS NULL OR CHAR_LENGTH(TRIM(p_student_name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ten sinh vien khong duoc de trong';
    END IF;

    IF p_course_name IS NULL OR CHAR_LENGTH(TRIM(p_course_name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ten mon hoc khong duoc de trong';
    END IF;

    START TRANSACTION;

        -- Tìm student_id theo tên
        SELECT student_id INTO v_student_id
        FROM students
        WHERE student_name = p_student_name
        LIMIT 1
        FOR UPDATE;

        IF v_student_id IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sinh vien khong ton tai';
        END IF;

        -- Tìm course_id và số chỗ trống theo tên môn học (khóa dòng course)
        SELECT course_id, available_seats INTO v_course_id, v_seats
        FROM courses
        WHERE course_name = p_course_name
        LIMIT 1
        FOR UPDATE;

        IF v_course_id IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mon hoc khong ton tai';
        END IF;

        -- Kiểm tra còn chỗ trống không
        IF v_seats <= 0 THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mon hoc da het cho (available_seats = 0)';
        END IF;

        -- (Tuỳ chọn nhưng nên có) không cho đăng ký trùng
        IF EXISTS (
            SELECT 1
            FROM enrollments
            WHERE student_id = v_student_id AND course_id = v_course_id
        ) THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sinh vien da dang ky mon hoc nay';
        END IF;

        -- Thêm bản ghi đăng ký
        INSERT INTO enrollments(student_id, course_id, enrolled_at)
        VALUES (v_student_id, v_course_id, NOW());

        -- Giảm chỗ trống
        UPDATE courses
        SET available_seats = available_seats - 1
        WHERE course_id = v_course_id;

    COMMIT;
END//

DELIMITER ;

