-- hàm tổng hợp
select count(product_id), max(price), min(price), avg(price) from products;
 -- hầm làm việc với chuỗi
 -- hàm làm việc vs thời gian
 -- hàm làm việc với số
  -- ground by : gom , nhóm dữ liệu 
  select cattegory, count(product_id),max(price) from products
  group by category;
  -- ví dụ áp dụng 
  #1.1 tính tổng tiền của mỗi đơn hang : thông tin gồm :mã đơn hàng,trạng thái , tổng tiền
  SELECT o.order_id, o.status, sum(oi.quantity * oi.unit_price) 
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.status;

  #1.2 tính tổng doanh thu theo từng sản phẩm: lấy tên sản phẩm và tổng doanh 
select p.product_name, sum(oi.quantity * oi.unit_price) 
from order_items oi
join products p on p.product_id = oi.product_id
join orders o on o.order_id = oi.order_id
group by p.product_id
having sum(oi.quantity * oi.unit_price)  > 10000000
;
  #1.3 tính tổng số tiền đã chi của 1 khách hàng, sắp xếp theo tổng tiền giảm dần
select c.customer_id, c.customer_name,sum(oi.quantity * oi.unit_price) `total_amount`
from customers c
join orders o on o.customer_id = c.customer_id
join order_items oi on oi.order_id = o.order_id

group by c.customer_id
order by `total_amount` desc;

-- áp dụng :
-- lấy tất car sản phẩm có tổng số lượng bán ra > 10 cái
select p.product_id, p.product_name,sum(oi.quantity)
from order_items oi
join products p on p.product_id = oi.product_id
group by p.product_id, p.product_name
having SUM(oi.quantity) > 10;

-- lấy tất cả đơn hàng mua từ 2 đơn hàng trở lên
select o.customer_id, count(o.order_id) 
from orders o
group by o.customer_id
having count(o.order_id) >= 2;

-- lấy tất cả đơn hàng có sô loại SP mua tù 2 laoij sản phẩm
SELECT
  o.order_id,
  COUNT(DISTINCT oi.product_id) 
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id
HAVING count(DISTINCT oi.product_id) >= 2;

  
