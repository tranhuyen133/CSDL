-- [Bài tập 4] CreatePostWithValidation: IN + OUT + IF/ELSE + CHAR_LENGTH
USE social_network_pro;

-- 2) Tạo procedure
DELIMITER //

CREATE PROCEDURE CreatePostWithValidation(
    IN  p_user_id INT,
    IN  p_content TEXT,
    OUT result_message VARCHAR(255)
)
BEGIN
    IF CHAR_LENGTH(p_content) < 5 THEN
        SET result_message = 'Nội dung quá ngắn';
    ELSE
        INSERT INTO posts(user_id, content)
        VALUES (p_user_id, p_content);

        SET result_message = 'Thêm bài viết thành công';
    END IF;
END//

DELIMITER ;

-- 3) Gọi thủ tục và thử các trường hợp

-- Case 1: Nội dung quá ngắn (< 5 ký tự)
SET @msg = '';
CALL CreatePostWithValidation(1, 'hi', @msg);
SELECT @msg AS result_message;

-- Case 2: Hợp lệ (>= 5 ký tự)
SET @msg = '';
CALL CreatePostWithValidation(1, 'hello', @msg);
SELECT @msg AS result_message;

-- 4) Kiểm tra kết quả (xem các bài mới nhất của user_id = 1)
SELECT post_id, user_id, content, created_at
FROM posts
WHERE user_id = 1
ORDER BY post_id DESC
LIMIT 5;

-- 5) Xóa thủ tục
DROP PROCEDURE IF EXISTS CreatePostWithValidation;
