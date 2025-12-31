-- 1) Lấy toàn bộ sản phẩm đang có trong hệ thống
SELECT *
FROM products;

-- 2) Lấy danh sách sản phẩm đang bán (status = 'active')
SELECT *
FROM products
WHERE status = 'active';

-- 3) Lấy các sản phẩm có giá lớn hơn 1.000.000
SELECT *
FROM products
WHERE price > 1000000;

-- 4) Hiển thị danh sách sản phẩm đang bán, sắp xếp theo giá tăng dần
SELECT *
FROM products
WHERE status = 'active'
ORDER BY price ASC;
