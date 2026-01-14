/* =========================================================
   BÀI TẬP 3 (GIỎI) — TRIGGER LIKES (users/posts/likes đã có sẵn)
========================================================= */

-- 0) Đảm bảo posts có like_count (nếu bài trước đã có thì lệnh này sẽ lỗi, bạn có thể bỏ qua)
-- Nếu chắc chắn đã có like_count thì comment dòng này.
-- ALTER TABLE posts ADD COLUMN like_count INT DEFAULT 0;

-- 1) (Khuyến nghị) Chống like trùng: 1 user chỉ like 1 lần trên 1 post
-- Nếu đã tạo rồi mà chạy lại sẽ lỗi -> bạn có thể bỏ qua
-- ALTER TABLE likes ADD CONSTRAINT uq_like UNIQUE (user_id, post_id);

-- 2) XÓA TRIGGER CŨ (để tạo lại không bị lỗi)
DROP TRIGGER IF EXISTS tg_likes_before_insert_no_self_like;
DROP TRIGGER IF EXISTS tg_likes_before_update_no_self_like;
DROP TRIGGER IF EXISTS tg_likes_after_insert;
DROP TRIGGER IF EXISTS tg_likes_after_delete;
DROP TRIGGER IF EXISTS tg_likes_after_update;

DELIMITER //

/* =========================================================
   3) TRIGGER: BEFORE INSERT — CHẶN SELF-LIKE
========================================================= */
CREATE TRIGGER tg_likes_before_insert_no_self_like
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE post_owner_id INT;

    SELECT user_id
      INTO post_owner_id
      FROM posts
     WHERE post_id = NEW.post_id;

    IF post_owner_id = NEW.user_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không thể like bài đăng của chính mình!';
    END IF;
END//

/* =========================================================
   4) TRIGGER: BEFORE UPDATE — nếu đổi post_id/user_id vẫn chặn self-like
========================================================= */
CREATE TRIGGER tg_likes_before_update_no_self_like
BEFORE UPDATE ON likes
FOR EACH ROW
BEGIN
    DECLARE post_owner_id INT;

    IF (NEW.post_id <> OLD.post_id) OR (NEW.user_id <> OLD.user_id) THEN
        SELECT user_id
          INTO post_owner_id
          FROM posts
         WHERE post_id = NEW.post_id;

        IF post_owner_id = NEW.user_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Không thể like bài đăng của chính mình!';
        END IF;
    END IF;
END//

/* =========================================================
   5) TRIGGER: AFTER INSERT — TĂNG like_count
========================================================= */
CREATE TRIGGER tg_likes_after_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
       SET like_count = like_count + 1
     WHERE post_id = NEW.post_id;
END//

/* =========================================================
   6) TRIGGER: AFTER DELETE — GIẢM like_count (không cho âm)
========================================================= */
CREATE TRIGGER tg_likes_after_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
       SET like_count = CASE WHEN like_count > 0 THEN like_count - 1 ELSE 0 END
     WHERE post_id = OLD.post_id;
END//

/* =========================================================
   7) TRIGGER: AFTER UPDATE — nếu đổi post_id thì trừ post cũ, cộng post mới
========================================================= */
CREATE TRIGGER tg_likes_after_update
AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
    IF NEW.post_id <> OLD.post_id THEN
        UPDATE posts
           SET like_count = CASE WHEN like_count > 0 THEN like_count - 1 ELSE 0 END
         WHERE post_id = OLD.post_id;

        UPDATE posts
           SET like_count = like_count + 1
         WHERE post_id = NEW.post_id;
    END IF;
END//

DELIMITER ;



/* =========================================================
   8) (Khuyến nghị) Đồng bộ like_count theo dữ liệu likes hiện có (chạy 1 lần)
   Nếu trước đó like_count chưa đúng thì chạy để chuẩn hóa.
========================================================= */
UPDATE posts p
SET p.like_count = (
    SELECT COUNT(*) FROM likes l WHERE l.post_id = p.post_id
);



/* =========================================================
   9) VIEW user_statistics (nếu đã có từ Bài 2 thì có thể bỏ qua phần CREATE VIEW)
========================================================= */
DROP VIEW IF EXISTS user_statistics;

CREATE VIEW user_statistics AS
SELECT
    u.user_id,
    u.username,
    u.post_count,
    COALESCE(SUM(p.like_count), 0) AS total_likes
FROM users u
LEFT JOIN posts p ON p.user_id = u.user_id
GROUP BY u.user_id, u.username, u.post_count;



/* =========================================================
   10) TEST THEO ĐỀ BÀI
========================================================= */

-- 10.1 Thử like bài của chính mình (PHẢI BÁO LỖI)
-- Bạn thay (user_id, post_id) cho đúng trường hợp "chủ bài viết"
-- Ví dụ: nếu post_id=1 thuộc user_id=1 thì lệnh dưới sẽ lỗi:
-- INSERT INTO likes (user_id, post_id, liked_at) VALUES (1, 1, NOW());

-- 10.2 Thêm like hợp lệ -> kiểm tra like_count
-- Ví dụ: user 2 like post 1 (giả sử post 1 không thuộc user 2)
INSERT INTO likes (user_id, post_id, liked_at)
VALUES (2, 1, NOW());

SELECT post_id, user_id, like_count
FROM posts
WHERE post_id = 1;

-- 10.3 UPDATE một like sang post khác -> kiểm tra like_count của cả hai post
-- Chuyển like của user 2 từ post 1 sang post 4 (bạn đổi post_id cho phù hợp dữ liệu của bạn)
UPDATE likes
SET post_id = 4
WHERE user_id = 2 AND post_id = 1
ORDER BY like_id DESC
LIMIT 1;

SELECT post_id, like_count
FROM posts
WHERE post_id IN (1, 4);

-- 10.4 Xóa like -> kiểm tra lại
DELETE FROM likes
WHERE user_id = 2 AND post_id = 4
ORDER BY like_id DESC
LIMIT 1;

SELECT post_id, like_count
FROM posts
WHERE post_id = 4;

-- 10.5 Kiểm chứng tổng hợp: posts và view user_statistics
SELECT * FROM posts ORDER BY post_id;
SELECT * FROM user_statistics ORDER BY user_id;
