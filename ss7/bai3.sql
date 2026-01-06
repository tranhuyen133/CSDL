-- 1) Tạo database (nếu bạn đã có DB từ bài trước thì vẫn dùng được)
CREATE DATABASE IF NOT EXISTS ecommerce_basic;
USE ecommerce_basic;

-- 2) Nếu bài trước đã có bảng orders thì bỏ phần DROP/CREATE này
-- (Để chạy lại nhiều lần cho chắc)
DROP TABLE IF EXISTS orders;

-- 3) Tạo lại bảng orders
CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL
);

-- 4) Thêm dữ liệu mẫu (>= 5)
INSERT INTO orders (id, customer_id, order_date, total_amount) VALUES
(101, 1, '2024-01-10', 1200000.00),
(102, 1, '2024-01-15',  800000.00),
(103, 2, '2024-01-12', 2500000.00),
(104, 3, '2024-01-18',  450000.00),
(105, 3, '2024-01-20',  650000.00),
(106, 5, '2024-01-22',  990000.00);

-- =========================================================
-- 5) TRUY VẤN: Đơn hàng có giá trị > giá trị trung bình tất cả đơn
--    - Subquery dùng AVG
--    - KHÔNG dùng JOIN
-- =========================================================
SELECT id, customer_id, order_date, total_amount
FROM orders
WHERE total_amount > (
  SELECT AVG(total_amount)
  FROM orders
);
