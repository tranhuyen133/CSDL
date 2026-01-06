-- 1) Dùng lại database (tạo nếu chưa có)
CREATE DATABASE IF NOT EXISTS ecommerce_basic;
USE ecommerce_basic;

-- 2) Tạo bảng (nếu bạn đã có từ bài trước thì có thể bỏ phần DROP/CREATE)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(120) UNIQUE
);

CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- 3) Dữ liệu mẫu customers (>= 5)
INSERT INTO customers (id, name, email) VALUES
(1, 'Nguyen Van A', 'a@gmail.com'),
(2, 'Tran Thi B',  'b@gmail.com'),
(3, 'Le Van C',    'c@gmail.com'),
(4, 'Pham Thi D',  'd@gmail.com'),
(5, 'Hoang Van E', 'e@gmail.com');

-- 4) Dữ liệu mẫu orders (>= 5)
INSERT INTO orders (id, customer_id, order_date, total_amount) VALUES
(101, 1, '2024-01-10', 1200000.00),
(102, 1, '2024-01-15',  800000.00),
(103, 2, '2024-01-12', 2500000.00),
(104, 3, '2024-01-18',  450000.00),
(105, 3, '2024-01-20',  650000.00),
(106, 5, '2024-01-22',  990000.00);

-- =========================================================
-- 5) TRUY VẤN: Tên khách hàng + số lượng đơn hàng của từng khách
--    - Subquery trong SELECT
--    - KHÔNG JOIN
--    - KHÔNG GROUP BY
-- =========================================================
SELECT
  c.name AS customer_name,
  (
    SELECT COUNT(*)
    FROM orders o
    WHERE o.customer_id = c.id
  ) AS order_count
FROM customers c;
