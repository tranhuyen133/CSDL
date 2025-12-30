CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- câu 1: DDL

CREATE TABLE Reader (
	reader_id INT AUTO_INCREMENT PRIMARY KEY,
    reader_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    register_date DATE DEFAULT(CURRENT_DATE)
);

CREATE TABLE Book (
	book_id INT PRIMARY KEY,
    book_title VARCHAR(150) NOT NULL,
    author VARCHAR(100),
    publish_year INT CHECK (publish_year >= 1900)
);

CREATE TABLE Borrow (
    reader_id INT,
    book_id INT,
    borrow_date DATE DEFAULT (CURRENT_DATE),
    return_date DATE,
    PRIMARY KEY (reader_id, book_id, borrow_date),
    FOREIGN KEY (reader_id) REFERENCES Reader(reader_id),
    FOREIGN KEY (book_id) REFERENCES Book(book_id)
);

-- câu2 : DDL
-- them email vao reader
ALTER TABLE Reader
ADD email VARCHAR(100) UNIQUE;

-- sua kieu du lieu author thanh varchar(150)
ALTER TABLE Book
MODIFY author VARCHAR(150);

-- rang buoc de return_date >= borrow_date
ALTER TABLE Borrow
ADD CONSTRAINT chk_return_date
CHECK (return_date IS NULL OR return_date >= borrow_date);

-- câu 3 :DML
-- them du lieu 

INSERT INTO Reader(reader_id, reader_name, phone, email, register_date) VALUES
(1, 'Nguyễn Văn An', '0901234567', 'an.nguyen@gmail.com', '2024-09-01'),
(2, 'Trần Thị Bình', '0912345678', 'binh.tran@gmail.com', '2024-09-05'),
(3, 'Lê Minh Châu', '0923456789', 'chau.le@gmail.com', '2024-09-10');

INSERT INTO Book (book_id, book_title, author, publish_year) VALUES
(101, 'Lập trình C căn bản', 'Nguyễn Văn A', 2018),
(102, 'Cơ sở dữ liệu', 'Trần Thị B', 2020),
(103, 'Lập trình Java', 'Lê Minh C', 2019),
(104, 'Hệ quản trị MySQL', 'Phạm Văn D', 2021);

INSERT INTO Borrow (reader_id, book_id, borrow_date, return_date) VALUES
(1, 101, '2024-09-15', NULL),
(1, 102, '2024-09-15', '2024-09-25'),
(2, 103, '2024-09-18', NULL);

-- cap nhat return_date cho reader id =1
UPDATE Borrow 
SET return_date = '2024-10-01'
WHERE reader_id = 1;

-- cap nhat nam xuat ban thanh 2023 cho cac sach có public_year >=2021
UPDATE Book
SET publish_year = 2023
WHERE publish_year >= 2021;

-- xoa cac luot muon sach co borrow_date < '2024-09-18'
DELETE FROM Borrow
WHERE borrow_date < '2024-09-18';

-- truy van
-- xem toan bo doc gia
SELECT * FROM Reader;

-- xem toan bo sach
SELECT * FROM Book;

-- xem toan bo luot muon 
SELECT * FROM Borrow;





