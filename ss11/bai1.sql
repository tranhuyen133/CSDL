-- 2) Tạo Stored Procedure (IN p_user_id) trả về danh sách bài viết của user đó
USE social_network_pro;

DELIMITER //

CREATE PROCEDURE sp_GetPostsByUser(IN p_user_id INT)
BEGIN
    SELECT
        post_id    AS PostID,
        content    AS `Nội dung`,
        created_at AS `Thời gian tạo`
    FROM posts
    WHERE user_id = p_user_id
    ORDER BY created_at DESC, post_id DESC;
END//

DELIMITER ;

-- 3) Gọi thủ tục với user cụ thể (ví dụ user_id = 1)
CALL sp_GetPostsByUser(1);

-- 4) Xóa thủ tục vừa tạo
DROP PROCEDURE IF EXISTS sp_GetPostsByUser;
