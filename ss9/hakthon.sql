-- 1. tạo DATABASE 
CREATE DATABASE IF NOT EXISTS hakathon;
USE hakathon;

DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    dept_id varchar(5) primary key,
    dept_name varchar(100) not null unique,
    location varchar(100) not null,
    manager_name varchar(50) not null
) ;

CREATE TABLE Employee (
    emp_id varchar(5) primary key,
    emp_name varchar(50) not null,
    dob date not null,
    email varchar(100) not null unique,
    phone varchar(15) not null unique,
    dept_id varchar(5) not null,
    foreign key (dept_id) references Department(dept_id)
);

CREATE TABLE Project (
    project_id varchar(5) primary key,
    project_name varchar(20) not null unique,
    start_date date not null,
    end_date date not null,
    budget decimal(10,2) not null
) ;

CREATE TABLE Assignment (
    assignment_id int primary key auto_increment,
    emp_id varchar(5) not null,
    project_id varchar(5) not null,
    role varchar(20) not null,
    hours_worked int not null,
    foreign key (emp_id) references Employee(emp_id),
    foreign key (project_id) references Project(project_id)
) ;

-- 2 chèn dữ liệu 
INSERT INTO Department (dept_id, dept_name, location, manager_name) VALUES
('D01', 'IT', 'Floor 5', 'Nguyen Van An'),
('D02', 'HR', 'Floor 2', 'Tran Thi Binh'),
('D03', 'Sales', 'Floor 1', 'Le Van Cuong'),
('D04', 'Marketing', 'Floor 3', 'Pham Thi Duong'),
('D05', 'Finance', 'Floor 4', 'Hoang Van Tu');

INSERT INTO Employee (emp_id, emp_name, dob, email, phone, dept_id) VALUES
('E001', 'Nguyen Van Tuan', '1990-01-01', 'tuan@mail.com', '0901234567', 'D01'),
('E002', 'Tran Thi Lan', '1995-05-05', 'lan@mail.com', '0902345678', 'D02'),
('E003', 'Le Minh Khoi', '1992-10-10', 'khoi@mail.com', '0903456789', 'D01'),
('E004', 'Pham Hoang Nam', '1998-12-12', 'nam@mail.com', '0904567890', 'D03'),
('E005', 'Vu Minh Ha', '1996-07-07', 'ha@mail.com', '0905678901', 'D01');

INSERT INTO Project (project_id, project_name, start_date, end_date, budget) VALUES
('P001', 'Website Redesign', '2025-01-01', '2025-06-01', 50000.00),
('P002', 'Mobile App Dev', '2025-02-01', '2025-08-01', 80000.00),
('P003', 'HR System', '2025-03-01', '2025-09-01', 30000.00),
('P004', 'Marketing Campaign', '2025-04-01', '2025-05-01', 10000.00),
('P005', 'AI Research', '2025-05-01', '2025-12-31', 100000.00);

INSERT INTO Assignment (assignment_id, emp_id, project_id, role, hours_worked) VALUES
(1, 'E001', 'P001', 'Developer', 150),
(2, 'E003', 'P001', 'Tester', 100),
(3, 'E001', 'P002', 'Tech Lead', 200),
(4, 'E005', 'P005', 'Data Scientist', 180),
(5, 'E004', 'P004', 'Content Creator', 50);

-- PHẦN 2 – TRUY VẤN DỮ LIỆU CƠ BẢN
-- 3 .cập nhật location của phòng ban có dept_id = 'C001' thành 'Floor 10'
update Department
set location = 'Floor 10'
where dept_id = 'C001';

-- 4. tăng budget dự án P005 thêm 10% và lùi end_date thêm 1 tháng
update Project
set budget = budget * 1.10,
    end_date = date_add(end_date, interval 1 month)
where project_id = 'P005';

-- 5. xóa các Assignment có hours_worked = 0 hoặc role = 'Intern'
delete from Assignment
where hours_worked = 0 or role = 'Intern';

-- 6. liệt kê emp_id, emp_name, email của nhân viên thuộc phòng ban D01
select emp_id, emp_name, email
from Employee
where dept_id = 'D01';

-- 7 .lấy project_name, start_date, budget của dự án có tên chứa 'System'
select project_name, start_date, budget
from Project
where project_name like '%System%';

-- 8 .hiển thị project_id, project_name, budget, sắp xếp budget giảm dần
select project_id, project_name, budget
from Project
order by budget desc;

-- 9. lấy 3 nhân viên lớn tuổi nhất 
select emp_id, emp_name, dob
from Employee
order by dob asc
limit 3;

-- 10. bỏ qua 1 bản ghi đầu, lấy 3 bản ghi tiếp theo 
select project_id, project_name
from Project
limit 3 offset 1;

-- PHẦN 3 TRUY VẤN DỮ LIỆU NÂNG CAO-
-- 11.  hien thi danh sách assignment_id, emp_name , project_name  và role.  lấy những đơn hàng có hours_worked l> 100.
select a.assignment_id, e.emp_name, p.project_name, a.role
from Assignment a
join Employee e on e.emp_id = a.emp_id
join Project p on p.project_id = a.project_id
where a.hours_worked > 100;

-- 12 Liệt kê tất cả phòng ban + emp_name 
select d.dept_id, d.dept_name, e.emp_name
from Department d
left join Employee e on e.dept_id = d.dept_id;

-- 13 Tổng số giờ làm việc cho từng dự án (project_name, Total_Hours)

-- 14 Đếm số nhân viên mỗi phòng ban>= 2 nhân viên
select d.dept_name, count(e.emp_id) Employee_Count
from Department d
join Employee e on e.dept_id = d.dept_id
group by d.dept_id, d.dept_name
having count(e.emp_id) >= 2;

-- 15 Nhân viên (emp_name, email) tham gia dự án có budget > 50000
select distinct e.emp_name, e.email
from Employee e
join Assignment a on a.emp_id = e.emp_id
join Project p on p.project_id = a.project_id
where p.budget > 50000;

-- 16 Emp thuộc phòng ban IT và đang tham gia dự án Website Redesign

-- 17 Thông tin tổng hợp: emp_id, emp_name, dept_name, project_name, hours_worked
select e.emp_id, e.emp_name, d.dept_name, p.project_name, a.hours_worked
from Assignment a
join Employee e on e.emp_id = a.emp_id
join Department d on d.dept_id = e.dept_id
join Project p on p.project_id = a.project_id;
