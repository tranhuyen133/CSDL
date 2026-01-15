

-- 1) Stored Procedure xử lý đặt hàng
DELIMITER //

DROP PROCEDURE IF EXISTS sp_place_order//
CREATE PROCEDURE sp_place_order(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;

    -- Validate
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'So luong dat hang phai > 0';
    END IF;

    START TRANSACTION;

        -- Khoá dòng sản phẩm để đọc stock an toàn
        SELECT stock INTO v_stock
        FROM products
        WHERE product_id = p_product_id
        FOR UPDATE;

        -- Sản phẩm không tồn tại
        IF v_stock IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'San pham khong ton tai';
        END IF;

        -- Không đủ tồn kho
        IF v_stock < p_quantity THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong du hang trong kho';
        END IF;

        -- Tạo đơn hàng mới
        INSERT INTO orders(product_id, quantity, order_date)
        VALUES (p_product_id, p_quantity, NOW());

        -- Giảm tồn kho
        UPDATE products
        SET stock = stock - p_quantity
        WHERE product_id = p_product_id;

    COMMIT;
END//

DELIMITER ;


