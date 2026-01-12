-- [Bài tập 5] CalculateUserActivityScore: IN + OUT + COUNT + JOIN + CASE
USE social_network_pro;

-- 2) Tạo procedure
DELIMITER //

CREATE PROCEDURE CalculateUserActivityScore(
    IN  p_user_id INT,
    OUT activity_score INT,
    OUT activity_level VARCHAR(50)
)
BEGIN
    DECLARE v_post_count INT DEFAULT 0;
    DECLARE v_comment_count INT DEFAULT 0;
    DECLARE v_like_received_count INT DEFAULT 0;

    -- Đếm số bài viết của user
    SELECT COUNT(*)
    INTO v_post_count
    FROM posts
    WHERE user_id = p_user_id;

    -- Đếm số comment mà user đã viết
    SELECT COUNT(*)
    INTO v_comment_count
    FROM comments
    WHERE user_id = p_user_id;

    -- Đếm số like nhận được trên các bài viết của user
    SELECT COUNT(*)
    INTO v_like_received_count
    FROM likes l
    JOIN posts p ON p.post_id = l.post_id
    WHERE p.user_id = p_user_id;

    -- Tính điểm: post*10 + comment*5 + like_received*3
    SET activity_score = (v_post_count * 10)
                       + (v_comment_count * 5)
                       + (v_like_received_count * 3);

    -- Phân loại mức hoạt động
    SET activity_level =
        CASE
            WHEN activity_score > 500 THEN 'Rất tích cực'
            WHEN activity_score BETWEEN 200 AND 500 THEN 'Tích cực'
            ELSE 'Bình thường'
        END;
END//

DELIMITER ;

-- 3) Gọi thủ tục và select ra activity_score + activity_level
SET @score = 0;
SET @level = '';
CALL CalculateUserActivityScore(1, @score, @level);   -- đổi 1 thành user_id bạn muốn
SELECT @score AS activity_score, @level AS activity_level;

-- (Tuỳ chọn) kiểm tra chi tiết thành phần điểm
-- SELECT
--   (SELECT COUNT(*) FROM posts WHERE user_id = 1) AS post_count,
--   (SELECT COUNT(*) FROM comments WHERE user_id = 1) AS comment_count,
--   (SELECT COUNT(*) FROM likes l JOIN posts p ON p.post_id=l.post_id WHERE p.user_id = 1) AS like_received_count;

-- 4) Xóa thủ tục
DROP PROCEDURE IF EXISTS CalculateUserActivityScore;
