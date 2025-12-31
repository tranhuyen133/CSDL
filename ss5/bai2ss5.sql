-- 1) Lấy danh sách tất cả khách hàng
SELECT *
FROM customers;

-- 2) Lấy khách hàng ở TP.HCM
SELECT *
FROM customers
WHERE city = 'TP.HCM';

-- 3) Lấy khách hàng đang hoạt động và ở Hà Nội
SELECT *
FROM customers
WHERE status = 'active'
  AND city = 'Hà Nội';

-- 4) Sắp xếp danh sách khách hàng theo tên (A → Z)
SELECT *
FROM customers
ORDER BY full_name ASC;
