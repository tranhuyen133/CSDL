/* 1) Tổng doanh thu theo từng ngày (chỉ đơn completed) */
SELECT
    o.order_date,
    SUM(o.total_amount) AS daily_revenue
FROM orders o
WHERE o.status = 'completed'
GROUP BY o.order_date
ORDER BY o.order_date;

/* 2) Số lượng đơn hàng theo từng ngày (chỉ đơn completed) */
SELECT
    o.order_date,
    COUNT(o.order_id) AS total_orders
FROM orders o
WHERE o.status = 'completed'
GROUP BY o.order_date
ORDER BY o.order_date;

/* 3) Chỉ hiển thị các ngày có doanh thu > 10.000.000 (chỉ đơn completed) */
SELECT
    o.order_date,
    SUM(o.total_amount) AS daily_revenue,
    COUNT(o.order_id) AS total_orders
FROM orders o
WHERE o.status = 'completed'
GROUP BY o.order_date
HAVING SUM(o.total_amount) > 10000000
ORDER BY daily_revenue DESC, o.order_date;
