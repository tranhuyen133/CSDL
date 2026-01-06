
-- 1) Tạo database
CREATE DATABASE IF NOT EXISTS ecommerce_in_subquery;
USE ecommerce_in_subquery;

-- 2) Xóa bảng để chạy lại
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS products;

-- 3) Tạo bảng products
CREATE TABLE products (
  id INT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  price DECIMAL(12,2) NOT NULL
);

-- 4) Tạo bảng order_items
CREATE TABLE order_items (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 5) Dữ liệu mẫu products (>= 7)
INSERT INTO products (id, name, price) VALUES
(1, 'Laptop Dell',        20000000.00),
(2, 'iPhone 14',          25000000.00),
(3, 'Tai nghe Bluetooth',  1500000.00),
(4, 'Ban phim co',         2000000.00),
(5, 'Man hinh 27 inch',    7000000.00),
(6, 'Chuot khong day',      800000.00),
(7, 'USB 64GB',             300000.00);

-- 6) Dữ liệu mẫu order_items (một số sản phẩm được bán, một số chưa)
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1001, 1, 1),
(1001, 3, 2),
(1002, 2, 1),
(1003, 4, 1),
(1003, 3, 1),
(1004, 6, 2),
(1005, 5, 1);

-- =========================================================
-- 7) TRUY VẤN: Danh sách sản phẩm đã từng được bán
--    - Subquery lấy product_id từ order_items
--    - Dùng IN
--    - KHÔNG dùng JOIN
-- =========================================================
SELECT id, name, price
FROM products
WHERE id IN (
  SELECT product_id
  FROM order_items
);

-- (Tuỳ chọn) Nếu muốn chắc chắn không trùng product_id trong subquery:
-- SELECT id, name, price
-- FROM products
-- WHERE id IN (SELECT DISTINCT product_id FROM order_items);
