-- [Bài tập 2] IN + OUT: Tính tổng like của 1 bài viết
USE social_network_pro;

-- 2) Tạo stored procedure: truyền vào post_id, trả ra tổng likes của post đó
DELIMITER //

CREATE PROCEDURE CalculatePostLikes(
    IN  p_post_id INT,
    OUT total_likes INT
)
BEGIN
    SELECT COUNT(*) 
    INTO total_likes
    FROM likes
    WHERE post_id = p_post_id;
END//

DELIMITER ;

-- 3) Gọi thủ tục với 1 post cụ thể và lấy giá trị OUT
SET @total_likes = 0;
CALL CalculatePostLikes(101, @total_likes);   -- đổi 101 thành post_id bạn muốn
SELECT @total_likes AS total_likes;

-- (Tuỳ chọn) kiểm tra nhanh post có tồn tại không
-- SELECT post_id, user_id, content FROM posts WHERE post_id = 101;

-- 4) Xóa thủ tục
DROP PROCEDURE IF EXISTS CalculatePostLikes;
