-- [Bài tập 3] INOUT: CalculateBonusPoints
USE social_network_pro;

-- 2) Tạo stored procedure
DELIMITER //

CREATE PROCEDURE CalculateBonusPoints(
    IN    p_user_id INT,
    INOUT p_bonus_points INT
)
BEGIN
    DECLARE v_post_count INT DEFAULT 0;

    -- Đếm số bài viết của user
    SELECT COUNT(*)
    INTO v_post_count
    FROM posts
    WHERE user_id = p_user_id;

    -- Cộng điểm theo điều kiện
    IF v_post_count >= 20 THEN
        SET p_bonus_points = p_bonus_points + 100;
    ELSEIF v_post_count >= 10 THEN
        SET p_bonus_points = p_bonus_points + 50;
    END IF;
END//

DELIMITER ;

-- 3) Gọi thủ tục (ví dụ user_id = 1, điểm ban đầu = 100)
SET @bonus = 100;
CALL CalculateBonusPoints(1, @bonus);

-- 4) Select ra p_bonus_points (giá trị mới)
SELECT @bonus AS p_bonus_points;

-- (Tuỳ chọn) xem số bài viết để đối chiếu
-- SELECT COUNT(*) AS post_count FROM posts WHERE user_id = 1;

-- 5) Xóa thủ tục
DROP PROCEDURE IF EXISTS CalculateBonusPoints;
