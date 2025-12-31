-- Trang 1: 5 đơn hàng mới nhất (chưa bị hủy)
SELECT *
FROM orders
WHERE status <> 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 0;

-- Trang 2: 5 đơn hàng tiếp theo (bỏ qua 5 đơn đầu)
SELECT *
FROM orders
WHERE status <> 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 5;

-- Trang 3: 5 đơn hàng tiếp theo (bỏ qua 10 đơn đầu)
SELECT *
FROM orders
WHERE status <> 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 10;
