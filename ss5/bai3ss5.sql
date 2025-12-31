-- 1) Lấy danh sách đơn hàng đã hoàn thành
SELECT *
FROM orders
WHERE status = 'completed';

-- 2) Lấy các đơn hàng có tổng tiền > 5.000.000
SELECT *
FROM orders
WHERE total_amount > 5000000;

-- 3) Hiển thị 5 đơn hàng mới nhất
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 5;

-- 4) Hiển thị các đơn hàng đã hoàn thành, sắp xếp theo tổng tiền giảm dần
SELECT *
FROM orders
WHERE status = 'completed'
ORDER BY total_amount DESC;
