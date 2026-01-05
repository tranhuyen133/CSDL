/* 1) Tạo CSDL + chọn CSDL */
CREATE DATABASE IF NOT EXISTS ecommerce_join_practice;
USE ecommerce_join_practice;

/* 2) Xóa bảng cũ (nếu có) để chạy lại nhiều lần không lỗi */
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

/* 3) Tạo bảng customers */
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name   VARCHAR(255) NOT NULL,
    city        VARCHAR(255)
);

/* 4) Tạo bảng orders */
CREATE TABLE orders (
    order_id    INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date  DATE NOT NULL,
    status      ENUM('pending', 'completed', 'cancelled') NOT NULL,
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

/* =========================================================
   5) DML: Thêm dữ liệu (tối thiểu 5 customers, 5 orders)
   ========================================================= */

/* Thêm customers */
INSERT INTO customers (customer_id, full_name, city) VALUES
(1, 'Nguyen Van An',   'Ha Noi'),
(2, 'Tran Thi Binh',   'Da Nang'),
(3, 'Le Van Cuong',    'Ho Chi Minh'),
(4, 'Pham Thi Dao',    'Ha Noi'),
(5, 'Hoang Van Em',    'Can Tho');

/* Thêm orders */
INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(101, 1, '2025-01-05', 'completed'),
(102, 2, '2025-01-06', 'pending'),
(103, 1, '2025-01-07', 'completed'),
(104, 4, '2025-01-08', 'cancelled'),
(105, 5, '2025-01-09', 'completed');

/* =========================================================
   6) TRUY VẤN THEO YÊU CẦU
   ========================================================= */

/* 6.1 Hiển thị danh sách đơn hàng kèm tên khách hàng */
SELECT
    o.order_id,
    c.full_name,
    o.order_date,
    o.status
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;

/* 6.2 Hiển thị mỗi khách hàng đã đặt bao nhiêu đơn hàng
      (kể cả khách chưa có đơn -> dùng LEFT JOIN) */
SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_orders DESC, c.customer_id;

/* 6.3 Chỉ hiển thị các khách hàng có ít nhất 1 đơn hàng */
SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) >= 1
ORDER BY total_orders DESC, c.customer_id;
