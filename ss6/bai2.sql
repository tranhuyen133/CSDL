/* 1) Bổ sung cột total_amount vào bảng orders */
ALTER TABLE orders
ADD COLUMN total_amount DECIMAL(10,2) DEFAULT 0;

/* 2) Cập nhật total_amount cho toàn bộ đơn hàng (tính từ order_items) */
UPDATE orders o
JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS total_amount
    FROM order_items
    GROUP BY order_id
) t
    ON o.order_id = t.order_id
SET o.total_amount = t.total_amount;

/* (Tuỳ chọn) Nếu có đơn hàng không có order_items thì set 0 cho chắc */
UPDATE orders
SET total_amount = 0
WHERE total_amount IS NULL;

/* 3.1 Hiển thị tổng tiền mỗi khách hàng đã chi tiêu */
SELECT
    c.customer_id,
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name;

/* 3.2 Hiển thị giá trị đơn hàng cao nhất của từng khách */
SELECT
    c.customer_id,
    c.full_name,
    MAX(o.total_amount) AS max_order_value
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name;

/* 3.3 Sắp xếp danh sách khách hàng theo tổng tiền giảm dần */
SELECT
    c.customer_id,
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC;
