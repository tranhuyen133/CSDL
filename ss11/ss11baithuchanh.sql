/* =========================
   1) CHUẨN BỊ DATABASE + TABLE
   ========================= */
DROP DATABASE IF EXISTS SocialLab;
CREATE DATABASE SocialLab;
USE SocialLab;

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    content TEXT NOT NULL,
    author  VARCHAR(100) NOT NULL,
    likes_count INT NOT NULL DEFAULT 0
);

/* =========================
   2) STORED PROCEDURES
   ========================= */

-- Task 1: CREATE post, IN(content, author), OUT(new_post_id)
DELIMITER //

CREATE PROCEDURE sp_CreatePost(
    IN  p_content TEXT,
    IN  p_author  VARCHAR(100),
    OUT p_new_post_id INT
)
BEGIN
    INSERT INTO posts(content, author)
    VALUES (p_content, p_author);

    SET p_new_post_id = LAST_INSERT_ID();
END//

-- Task 2: READ & SEARCH by keyword in content
CREATE PROCEDURE sp_SearchPost(
    IN p_keyword VARCHAR(255)
)
BEGIN
    SELECT post_id, content, author, likes_count
    FROM posts
    WHERE content LIKE CONCAT('%', p_keyword, '%')
    ORDER BY post_id DESC;
END//

-- Task 3: UPDATE likes
-- IN(post_id), INOUT(current_like) -> new_like after +1
CREATE PROCEDURE sp_IncreaseLike(
    IN    p_post_id INT,
    INOUT p_like_count INT
)
BEGIN
    -- tăng trong DB
    UPDATE posts
    SET likes_count = likes_count + 1
    WHERE post_id = p_post_id;

    -- lấy lại like mới để trả ra INOUT
    SELECT likes_count
    INTO p_like_count
    FROM posts
    WHERE post_id = p_post_id;
END//

-- Task 4: DELETE by post_id
CREATE PROCEDURE sp_DeletePost(
    IN p_post_id INT
)
BEGIN
    DELETE FROM posts
    WHERE post_id = p_post_id;
END//

DELIMITER ;

/* =========================
   3) KIỂM TRA LOGIC
   ========================= */

-- (1) Tạo 2 bài viết mới và xem ID trả về
SET @new_id_1 = 0;
CALL sp_CreatePost('hello everyone, this is my first post', 'Huyen', @new_id_1);
SELECT @new_id_1 AS created_post_id_1;

SET @new_id_2 = 0;
CALL sp_CreatePost('today I learned MySQL stored procedure', 'Dung', @new_id_2);
SELECT @new_id_2 AS created_post_id_2;

-- xem dữ liệu hiện có
SELECT * FROM posts ORDER BY post_id DESC;

-- (2) Tìm kiếm bài viết có chữ "hello"
CALL sp_SearchPost('hello');

-- (3) Tăng like cho bài viết vừa tạo (dùng biến @ cho INOUT)
-- Nếu bạn chưa biết like hiện tại, có thể lấy trước:
SELECT likes_count INTO @like_now
FROM posts
WHERE post_id = @new_id_1;

-- truyền vào @like_now, sau CALL thì @like_now trở thành like mới
CALL sp_IncreaseLike(@new_id_1, @like_now);
SELECT @new_id_1 AS post_id, @like_now AS like_after_increment;

-- kiểm tra lại DB
SELECT post_id, likes_count FROM posts WHERE post_id = @new_id_1;

-- (4) Xóa một bài viết bất kỳ (ví dụ xóa bài thứ 2)
CALL sp_DeletePost(@new_id_2);

-- kiểm tra sau khi xóa
SELECT * FROM posts ORDER BY post_id DESC;

/* =========================
   4) DỌN DẸP: DROP PROCEDURES
   ========================= */
DROP PROCEDURE IF EXISTS sp_CreatePost;
DROP PROCEDURE IF EXISTS sp_SearchPost;
DROP PROCEDURE IF EXISTS sp_IncreaseLike;
DROP PROCEDURE IF EXISTS sp_DeletePost;
