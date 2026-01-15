

DELIMITER //

DROP PROCEDURE IF EXISTS sp_pay_salary//
CREATE PROCEDURE sp_pay_salary(IN p_emp_id INT)
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_fund_balance DECIMAL(12,2);
    DECLARE v_bank_status VARCHAR(20);

    -- Validate input
    IF p_emp_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emp_id khong duoc NULL';
    END IF;

    START TRANSACTION;

        -- Lấy lương nhân viên (khoá dòng nhân viên nếu muốn ổn định)
        SELECT salary INTO v_salary
        FROM employees
        WHERE emp_id = p_emp_id
        FOR UPDATE;

        -- Nhân viên không tồn tại
        IF v_salary IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nhan vien khong ton tai';
        END IF;

        -- Lấy số dư quỹ + trạng thái ngân hàng (giả sử fund_id = 1)
        SELECT balance, bank_status INTO v_fund_balance, v_bank_status
        FROM company_funds
        WHERE fund_id = 1
        FOR UPDATE;

        -- Không có quỹ công ty
        IF v_fund_balance IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quy cong ty khong ton tai';
        END IF;

        -- Quỹ không đủ tiền
        IF v_fund_balance < v_salary THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quy cong ty khong du tien de tra luong';
        END IF;

        -- Trừ quỹ
        UPDATE company_funds
        SET balance = balance - v_salary
        WHERE fund_id = 1;

        -- Ghi nhận bảng lương
        INSERT INTO payroll(emp_id, amount, paid_at)
        VALUES (p_emp_id, v_salary, NOW());

        -- Kiểm tra trạng thái hệ thống ngân hàng
        -- Nếu ERROR -> rollback để hoàn tiền về quỹ
        IF v_bank_status <> 'OK' THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'He thong ngan hang dang loi. Giao dich bi huy (rollback).';
        END IF;

    COMMIT;

END//

DELIMITER ;

