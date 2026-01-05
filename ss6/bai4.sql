/* 1) Tính tổng doanh thu theo từng ngày (chỉ đơn completed) */
SELECT
    order_date,
    SUM(total_amount) AS daily_revenue
FROM orders
WHERE status = 'completed'
GROUP BY order_date
ORDER BY order_date;

/* 2) Tính số lượng đơn hàng theo từng ngày (chỉ đơn completed) */
SELECT
    order_date,
    COUNT(order_id) AS total_orders
FROM orders
WHERE status = 'completed'
GROUP BY order_date
ORDER BY order_date;

/* 3) Chỉ hiển thị các ngày có doanh thu > 10.000.000 (chỉ đơn completed) */
SELECT
    order_date,
    SUM(total_amount)  AS daily_revenue,
    COUNT(order_id)    AS total_orders
FROM orders
WHERE status = 'completed'
GROUP BY order_date
HAVING SUM(total_amount) > 10000000
ORDER BY daily_revenue DESC, order_date;
