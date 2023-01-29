DROP ROLE IF EXISTS role_bank;
DROP ROLE IF EXISTS role_employee;
DROP ROLE IF EXISTS role_manager;
DROP ROLE IF EXISTS role_customer;

DROP ROLE IF EXISTS user_bank1;
DROP ROLE IF EXISTS user_employee1;
DROP ROLE IF EXISTS user_manager1;
DROP ROLE IF EXISTS user_customer1;

CREATE SCHEMA bank;
CREATE SCHEMA employee;
CREATE SCHEMA manager;
CREATE SCHEMA customer;


CREATE TABLE bank.bank (
    bank_id SERIAL PRIMARY KEY,
    bank_name varchar(50) NOT NULL,
    bank_bic char(11) NOT NULL UNIQUE,
    bank_address varchar(255) NOT NULL,
    bank_postcode varchar(10) NOT NULL,
    bank_country varchar(60) NOT NULL
);

CREATE TABLE bank.branch (
    branch_sortcode char(6) PRIMARY KEY,
    branch_bankid int NOT NULL REFERENCES bank.bank(bank_id),
    branch_name varchar(50) NOT NULL,
    branch_address varchar(255) NOT NULL,
    branch_postcode varchar(10) NOT NULL,
    branch_country varchar(60) NOT NULL
);

CREATE TABLE customer.account_type (
    type_id SERIAL PRIMARY KEY,
    type_name varchar(100) NOT NULL
);

CREATE TABLE customer.loan_type (
    loantype_id SERIAL PRIMARY KEY,
    loantype_amount int NOT NULL,
    loantype_interest real NOT NULL,
    loantype_term int NOT NULL
);

CREATE TABLE customer.loan(
    loan_id SERIAL PRIMARY KEY,
    loan_type INT NOT NULL REFERENCES customer.loan_type(loantype_id),
    loan_outstanding INT,
    loan_status varchar(50) NOT NULL,
    loan_date DATE NOT NULL
);

CREATE TABLE customer.customer (
    customer_id SERIAL PRIMARY KEY,
    customer_username varchar(30) NOT NULL UNIQUE,
    customer_password varchar(30) NOT NULL,
    customer_fname varchar(50) NOT NULL,
    customer_lname varchar(50) NOT NULL,
    customer_mobile char(11) NOT NULL UNIQUE,
    customer_email varchar(50) NOT NULL UNIQUE,
    customer_address varchar(255) NOT NULL,
    customer_postcode varchar(10) NOT NULL
);

CREATE TABLE customer.account (
    account_number char(8) PRIMARY KEY,
    account_sortcode char(6) NOT NULL REFERENCES bank.branch(branch_sortcode),
    account_customerid int NOT NULL REFERENCES customer.customer(customer_id),
    account_type int NOT NULL REFERENCES customer.account_type(type_id),
    account_loan int REFERENCES customer.loan(loan_id),
    account_balance int NOT NULL,
    account_name varchar(255) NOT NULL,
    account_iban varchar(34) NOT NULL,
    account_opendate date NOT NULL
);

CREATE TABLE employee.employee_roles(
    employeerole_id SERIAL PRIMARY KEY,
    employeerole_name varchar(255) NOT NULL
);

CREATE TABLE employee.employee (
    employee_id SERIAL PRIMARY KEY,
    employee_sortcode char(6) NOT NULL REFERENCES bank.branch(branch_sortcode),
    employee_username varchar(255) NOT NULL UNIQUE,
    employee_password varchar(255) NOT NULL,
    employee_role int NOT NULL REFERENCES employee.employee_roles(employeerole_id),
    employee_fname varchar(50) NOT NULL,
    employee_lname varchar(50) NOT NULL,
    employee_mobile char(11) NOT NULL UNIQUE,
    employee_email varchar(50) NOT NULL UNIQUE,
    employee_address varchar(255) NOT NULL,
    employee_postcode varchar(10) NOT NULL
);

CREATE TABLE customer.payment (
    payment_id SERIAL PRIMARY KEY,
    payment_accountnum char(8) NOT NULL REFERENCES customer.account(account_number),
    payment_receiveraccnum char(8) NOT NULL,
    payment_receiversortcode char(6) NOT NULL,
    payment_receivername varchar(255) NOT NULL,
    payment_amount int NOT NULL,
    payment_status varchar(50) NOT NULL,
    payment_date date NOT NULL
);

CREATE TABLE customer.transfer (
    transfer_id SERIAL PRIMARY KEY,
    transfer_senderaccnum char(8) NOT NULL REFERENCES customer.account(account_number),
    transfer_receiveraccnum char(8) NOT NULL REFERENCES customer.account(account_number),
    transfer_amount int NOT NULL,
    transfer_status varchar(50) NOT NULL,
    transfer_date date NOT NULL
);


CREATE TABLE customer.transaction_pending (
    pending_transactionid SERIAL PRIMARY KEY,
    pending_transactionref varchar(255) NOT NULL,
    pending_transferid int REFERENCES customer.transfer(transfer_id),
    pending_paymentid int REFERENCES customer.payment(payment_id),
    pending_loanid int REFERENCES customer.loan(loan_id),
    pending_sensitiveflag BOOLEAN NOT NULL,
    pending_approvalflag BOOLEAN NOT NULL
);

CREATE TABLE manager.approval (
    approval_id SERIAL PRIMARY KEY,
    approval_employee INT NOT NULL REFERENCES employee.employee(employee_id),
    approval_date date NOT NULL,
    approval_transaction int NOT NULL REFERENCES customer.transaction_pending(pending_transactionid)
);

CREATE TABLE customer.transaction (
    transaction_id SERIAL PRIMARY KEY,
    transaction_complete int NOT NULL REFERENCES customer.transaction_pending(pending_transactionid) UNIQUE
);


-- #################################### all functions and procedures ####################################

-- customer can open an account
CREATE OR REPLACE FUNCTION bank.create_customer(param_uname varchar(30), param_pass varchar(30), param_fname varchar(50), param_lname varchar(50), param_mobile char(11), param_email varchar(50), param_address varchar(255), param_postcode varchar(10))
RETURNS TABLE (username varchar(30), first_name varchar(50), last_name varchar(50), mobile char(11), email varchar(50), address varchar(255), postcode varchar(10)) AS $$
BEGIN
    INSERT INTO customer.customer (customer_id, customer_username, customer_password, customer_fname, customer_lname, customer_mobile, customer_email, customer_address, customer_postcode)
    VALUES(nextval('customer.customer_customer_id_seq'),param_uname, param_pass, param_fname, param_lname, param_mobile, param_email, param_address, param_postcode);

  RETURN QUERY 
  SELECT customer_username, customer_fname, customer_lname, customer_mobile, customer_email, customer_address, customer_postcode
  FROM customer.customer 
  WHERE customer_id = currval('customer.customer_customer_id_seq');

END;
$$ LANGUAGE plpgsql;


-- existing customer can open another account and new customers can open account first account
CREATE OR REPLACE FUNCTION bank.create_account(param_username varchar(30), param_accountnum char(8), param_sortcode char(6), param_accountype int, param_accountname varchar(255))
RETURNS TABLE(first_name varchar(50), last_name varchar(50), acc_number char(8), sort_code char(6), type int, balance int, name varchar(255), iban varchar(34), date date) AS $$
BEGIN
    
    DECLARE 
        param_iban VARCHAR(50);
    BEGIN 
        param_iban := 'GB73LOYD' || param_sortcode || param_accountnum;
    EXECUTE 'INSERT INTO customer.account(account_number, account_sortcode, account_customerid, account_type, account_balance, account_name, account_iban, account_opendate) VALUES ($1, $2, $3, $4, 3000, $5, '''|| format(param_iban) ||''', NOW())'
    USING param_accountnum, param_sortcode, (select customer_id from customer.customer where customer_username = param_username), param_accountype, param_accountname, param_iban;
    END;

    RETURN QUERY
    SELECT c.customer_fname, c.customer_lname, a.account_number, a.account_sortcode, a.account_type, a.account_balance, a.account_name, a.account_iban,a. account_opendate
    FROM customer.account a
    JOIN customer.customer c ON a.account_customerid = c.customer_id
    WHERE account_number = param_accountnum;

END;
$$ LANGUAGE plpgsql;

-- customer can check their details
CREATE OR REPLACE FUNCTION customer.check_customer(id int)
RETURNS TABLE (first_name varchar(50), last_name varchar(50), mobile char(11), email varchar(50), address varchar(255), postcode varchar(10)) AS $$
BEGIN
  -- return customer details for the table
  RETURN QUERY 
  SELECT customer_fname, customer_lname, customer_mobile, customer_email, customer_address, customer_postcode
  FROM customer.customer 
  WHERE customer_id = id;

-- if the customer does not exist
    IF NOT EXISTS (SELECT 1 FROM customer.customer WHERE customer_id=id) THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- customer can see their bank account details
CREATE OR REPLACE FUNCTION customer.check_accounts(id int)
RETURNS TABLE (account_number char(8), sort_code char(6), type varchar(100), loan int, 
balance int, name varchar(255), iban varchar(34), open_date date) AS $$
BEGIN
  -- returns bank account details
  RETURN QUERY 
  SELECT a.account_number, a.account_sortcode, at.type_name, a.account_loan, 
  a.account_balance, a.account_name, a.account_iban, a.account_opendate
  
  FROM customer.account a
  JOIN customer.account_type at ON a.account_type = at.type_id
  WHERE a.account_customerid = id;

-- if the customer does not exist
    IF NOT EXISTS (SELECT 1 FROM customer.customer WHERE customer_id=id) THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

END;
$$ LANGUAGE plpgsql;


-- customer can see their balance function
CREATE OR REPLACE FUNCTION customer.check_balances(id int)
RETURNS TABLE (account_number char(8), account_name varchar(255), account_type varchar(100), account_balance int) AS $$
BEGIN
  -- check if the customer exists
  RETURN QUERY 
  SELECT a.account_number, a.account_name, at.type_name, a.account_balance 
  FROM customer.account a 
  JOIN customer.account_type at ON a.account_type = at.type_id
  WHERE a.account_customerid = id;

-- if the customer does not exist
    IF NOT EXISTS (SELECT 1 FROM customer.customer WHERE customer_id=id) THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- check transfers
CREATE OR REPLACE FUNCTION customer.check_transfers(IN c_id int)
RETURNS TABLE(transaction_id int, transaction_ref varchar(255), transfer_id int, account_number char(8), receiver_accnum char(8), amount int, status varchar(50), date DATE)
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY 
    SELECT t.pending_transactionid, t.pending_transactionref, t.pending_transferid, tr.transfer_senderaccnum, tr.transfer_receiveraccnum, tr.transfer_amount, tr.transfer_status, tr.transfer_date
    FROM customer.transaction_pending t
    JOIN customer.transfer tr ON t.pending_transferid = tr.transfer_id
    WHERE tr.transfer_senderaccnum IN (SELECT account_number FROM customer.account WHERE account_customerid = c_id);
END;
$$ LANGUAGE plpgsql;

-- check payments
CREATE OR REPLACE FUNCTION customer.check_payments(IN c_id int)
RETURNS TABLE(transaction_id int, transaction_ref varchar(255), payment_id int, account_number char(8), receiver_accnum char(8), receiver_sortcode char(6), payment_receivername varchar(255), amount int, status varchar(50), date DATE) AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY 
    SELECT t.pending_transactionid, t.pending_transactionref, t.pending_paymentid, p.payment_accountnum, p.payment_receiveraccnum, p.payment_receiversortcode, p.payment_receivername, p.payment_amount, p.payment_status, p.payment_date
    FROM customer.transaction_pending t
    JOIN customer.payment p ON t.pending_paymentid = p.payment_id
    WHERE p.payment_accountnum IN (SELECT account_number FROM customer.account WHERE account_customerid = c_id);
END;
$$ LANGUAGE plpgsql;


-- check loan
CREATE OR REPLACE FUNCTION customer.check_loans(IN c_id int)
RETURNS TABLE(transaction int, loan_id int, account_number char(8), amount int, outstanding_balance int, interest real, term int, status varchar(50) ,date date) AS $$
BEGIN
    RETURN QUERY 
    SELECT tp.pending_transactionid, l.loan_id, a.account_number, lt.loantype_amount, l.loan_outstanding, lt.loantype_interest, lt.loantype_term, l.loan_status ,l.loan_date
    FROM customer.account a
    JOIN customer.loan l ON a.account_loan = l.loan_id
    JOIN customer.loan_type lt ON l.loan_type = lt.loantype_id
    JOIN customer.transaction_pending tp ON l.loan_id = tp.pending_loanid
    WHERE a.account_customerid = c_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE EXCEPTION 'No loans found';
END;
$$ LANGUAGE plpgsql;


-- create a new employee
CREATE OR REPLACE FUNCTION bank.create_employee(param_sortcode char(6), param_uname varchar(255), param_pass varchar(255), param_role int, param_fname varchar(50), param_lname varchar(50), param_mobile char(11), param_email varchar(50), param_address varchar(255), param_postcode varchar(10))
RETURNS TABLE(branch varchar(50), role varchar(255), first_name varchar(50), last_name varchar(50), mobile char(11), email varchar(50), address varchar(255), postcode varchar(10)) AS $$
BEGIN
    INSERT INTO employee.employee (employee_id, employee_sortcode, employee_username, employee_password, employee_role, employee_fname, employee_lname, employee_mobile, employee_email, employee_address, employee_postcode)
    VALUES(nextval('employee.employee_employee_id_seq'), param_sortcode, param_uname, param_pass, param_role, param_fname, param_lname, param_mobile, param_email, param_address, param_postcode);
    
    RETURN QUERY 
    SELECT br.branch_name, er.employeerole_name, e.employee_fname, e.employee_lname, e.employee_mobile, e.employee_email, e.employee_address, e.employee_postcode
    FROM employee.employee e
    JOIN employee.employee_roles er ON e.employee_role = er.employeerole_id
    JOIN bank.branch br ON e.employee_sortcode = br.branch_sortcode
    WHERE e.employee_id = currval('employee.employee_employee_id_seq');

END;
$$ LANGUAGE plpgsql;

-- checking an employee details
CREATE OR REPLACE FUNCTION employee.check_employee(id int)
RETURNS TABLE (branch varchar(50), role varchar(255), first_name varchar(50), last_name varchar(50), 
mobile char(11), email varchar(50), address varchar(255), postcode varchar(10)) AS $$
BEGIN
  -- returns employee details
  RETURN QUERY 
  SELECT br.branch_name, er.employeerole_name, e.employee_fname, e.employee_lname, e.employee_mobile, 
  e.employee_email, e.employee_address, e.employee_postcode

  FROM employee.employee e
  JOIN employee.employee_roles er ON e.employee_role = er.employeerole_id
  JOIN bank.branch br ON e.employee_sortcode = br.branch_sortcode
  WHERE e.employee_id = id;

-- if the employee does not exist
    IF NOT EXISTS (SELECT 1 FROM employee.employee WHERE employee_id=id) THEN
        RAISE EXCEPTION 'Employee does not exist';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- apply for loan
CREATE OR REPLACE FUNCTION bank.apply_loan(
    param_accountnum char(8),
    param_loantype int
)
RETURNS TABLE (id_loan int, type_loan int, status_loan varchar(50), date_loan date, id_loantype int, amount_loantype int, interest_loantype real, term_loantype int ) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM customer.account WHERE account_number = param_accountnum) THEN
        -- insert transfer into customer.loan table
        INSERT INTO customer.loan (loan_id, loan_type, loan_status, loan_date)
        VALUES (nextval('customer.loan_loan_id_seq'), param_loantype, 'PENDING', NOW());

        -- update customer.account table with loan
        UPDATE customer.account
        SET account_loan = currval('customer.loan_loan_id_seq')
        WHERE account_number = param_accountnum;

        -- insert transfer into customer.transaction_pending table
        INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_sensitiveflag, pending_approvalflag, pending_loanid)
        VALUES (nextval('customer.transaction_pending_pending_transactionid_seq'), 'LOAN', true, false, currval('customer.loan_loan_id_seq'));

    ELSE
        RAISE EXCEPTION 'Account does not exist';        
    END IF;
    
    RETURN QUERY
    SELECT l.loan_id, l.loan_type, l.loan_status, l.loan_date, lt.loantype_id, lt.loantype_amount, lt.loantype_interest, lt.loantype_term
    FROM customer.loan l
    JOIN customer.loan_type lt ON l.loan_type = lt.loantype_id
    WHERE loan_id = currval('customer.loan_loan_id_seq');
END;
$$ LANGUAGE plpgsql;


-- make a payment
CREATE OR REPLACE FUNCTION bank.make_payment(
    sender_accnum char(8),
    receiver_accnum char(8),
    receiver_sortcode char(6),
    receiver_name varchar(255),
    amount int
)
RETURNS TABLE (pay_id int, pay_account char(8), pay_receiveracc char(8), pay_receiversort char(6), pay_receivername varchar(255), pay_amount int, pay_status varchar(50), pay_date DATE) AS $$
BEGIN
    IF amount <= 0 THEN
        RAISE EXCEPTION 'Cannot pay negative amount of money';
    END IF;

    -- check if sender account exists
    IF NOT EXISTS (SELECT 1 FROM customer.account WHERE account_number = sender_accnum) THEN
        RAISE EXCEPTION 'Sender account does not exist';
    END IF;

    -- check if sender has sufficient funds
    IF (SELECT account_balance FROM customer.account WHERE account_number = sender_accnum) < amount THEN
        RAISE EXCEPTION 'Insufficient funds in sender account';
    END IF;

    -- update sender account balance
    UPDATE customer.account SET account_balance = account_balance - amount WHERE account_number = sender_accnum;

    -- insert payment into customer.payment table
    INSERT INTO customer.payment (payment_id, payment_accountnum, payment_receiveraccnum, payment_receiversortcode, payment_receivername, payment_amount, payment_status, payment_date)
    VALUES (nextval('customer.payment_payment_id_seq'), sender_accnum, receiver_accnum, receiver_sortcode, receiver_name, amount, 'COMPLETE', NOW());

    -- insert payment into customer.transaction_pending table
    INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_sensitiveflag, pending_approvalflag, pending_paymentid)
    VALUES (nextval('customer.transaction_pending_pending_transactionid_seq'), 'PAYMENT', false, true, currval('customer.payment_payment_id_seq'));

    INSERT INTO customer.transaction(transaction_id, transaction_complete)
    VALUES(nextval('customer.transaction_transaction_id_seq'), currval('customer.transaction_pending_pending_transactionid_seq'));

    RETURN QUERY
    SELECT *
    FROM customer.payment p
    WHERE p.payment_id = currval('customer.payment_payment_id_seq');

END;
$$ LANGUAGE plpgsql;

-- make a loan payment
CREATE OR REPLACE FUNCTION bank.pay_loan(param_accnum char(8), param_amount int)
RETURNS TABLE (pay_id int, pay_account char(8), pay_receiveracc char(8), pay_receiversort char(6), pay_receivername varchar(255), pay_amount int, pay_status varchar(50), pay_date DATE) AS $$
BEGIN
    IF param_amount <= 0 THEN
        RAISE EXCEPTION 'Cannot pay negative amount of money.';
    END IF;

    -- check if sender account exists
    IF NOT EXISTS (SELECT 1 FROM customer.account WHERE account_number = param_accnum) THEN
        RAISE EXCEPTION 'Account does not exist.';
    END IF;

    -- check if sender has sufficient funds
    IF (SELECT account_balance FROM customer.account WHERE account_number = param_accnum) < param_amount THEN
        RAISE EXCEPTION 'Insufficient funds in account.';
    END IF;

    -- check if sender has sufficient funds
    IF (SELECT loan_outstanding FROM customer.loan l JOIN customer.account a ON l.loan_id = a.account_loan WHERE account_number = param_accnum) < param_amount THEN
        RAISE EXCEPTION 'You cannot pay more than the outstanding balance.';
    END IF;

    -- check if sender has a loan to pay back
    IF EXISTS (SELECT 1 FROM customer.account WHERE account_number = param_accnum AND account_loan IS NULL) THEN
        RAISE EXCEPTION 'No loan to pay back.';
    END IF;

    -- check if the loan is pending
    IF (SELECT loan_status FROM customer.loan l JOIN customer.account a ON l.loan_id = a.account_loan WHERE account_number = param_accnum) = 'PENDING' THEN
        RAISE EXCEPTION 'Loan is pending. You cannot pay back now.';
    END IF;

    -- update account balance
    UPDATE customer.account SET account_balance = account_balance - param_amount WHERE account_number = param_accnum;
    
    -- update loan outstanding balance
    UPDATE customer.loan l SET loan_outstanding = loan_outstanding - param_amount FROM customer.account a WHERE l.loan_id = a.account_loan AND a.account_number = param_accnum;

    -- insert payment into customer.payment table
    INSERT INTO customer.payment (payment_id, payment_accountnum, payment_receiveraccnum, payment_receiversortcode, payment_receivername, payment_amount, payment_status, payment_date)
    VALUES (nextval('customer.payment_payment_id_seq'), param_accnum, '00000000', '000000', 'LOAN PAYMENT', param_amount, 'COMPLETE', NOW());

    -- insert payment into customer.transaction_pending table
    INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_sensitiveflag, pending_approvalflag, pending_paymentid)
    VALUES (nextval('customer.transaction_pending_pending_transactionid_seq'), 'LOAN PAYMENT', false, true, currval('customer.payment_payment_id_seq'));

    INSERT INTO customer.transaction(transaction_id, transaction_complete)
    VALUES(nextval('customer.transaction_transaction_id_seq'), currval('customer.transaction_pending_pending_transactionid_seq'));

    RETURN QUERY
    SELECT *
    FROM customer.payment p
    WHERE p.payment_id = currval('customer.payment_payment_id_seq');

END;
$$ LANGUAGE plpgsql;


-- make a transfer
CREATE OR REPLACE FUNCTION bank.make_transfer(
    sender_accnum char(8),
    receiver_accnum char(8),
    amount int
)
RETURNS TABLE (tran_id int, tran_senderacc char(8), tran_receiveracc char(8), tran_amount int, tran_status varchar(50), tran_date date) AS $$
BEGIN
    IF ((SELECT account_customerid FROM customer.account WHERE account_number = sender_accnum) = (SELECT account_customerid FROM customer.account WHERE account_number = receiver_accnum)) THEN
        IF amount <= 0 THEN
            RAISE EXCEPTION 'Cannot transfer negative amount of money.';
        END IF;

        -- check if sender account exists
        IF NOT EXISTS (SELECT 1 FROM customer.account WHERE account_number = sender_accnum) THEN
            RAISE EXCEPTION 'Sender account does not exist.';
        END IF;

        -- check if receiver account exists
        IF NOT EXISTS (SELECT 1 FROM customer.account WHERE account_number = receiver_accnum) THEN
            RAISE EXCEPTION 'Receiver account does not exist.';
        END IF;

        -- check if sender has sufficient funds
        IF (SELECT account_balance FROM customer.account WHERE account_number = sender_accnum) < amount THEN
            RAISE EXCEPTION 'Insufficient funds in sender account.';
        END IF;

        -- update sender account balance
        UPDATE customer.account SET account_balance = account_balance - amount WHERE account_number = sender_accnum;

        -- update receiver account balance
        UPDATE customer.account SET account_balance = account_balance + amount WHERE account_number = receiver_accnum;

        -- insert transfer into customer.transfer table
        INSERT INTO customer.transfer (transfer_id, transfer_senderaccnum, transfer_receiveraccnum, transfer_amount, transfer_status, transfer_date)
        VALUES (nextval('customer.transfer_transfer_id_seq'), sender_accnum, receiver_accnum, amount, 'COMPLETE', NOW());

        -- insert transfer into customer.transaction_pending table
        INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_sensitiveflag, pending_approvalflag, pending_transferid)
        VALUES (nextval('customer.transaction_pending_pending_transactionid_seq'), 'TRANSFER', false, true, currval('customer.transfer_transfer_id_seq'));

        INSERT INTO customer.transaction(transaction_id, transaction_complete)
        VALUES(nextval('customer.transaction_transaction_id_seq'), currval('customer.transaction_pending_pending_transactionid_seq'));

    ELSE
        RAISE EXCEPTION 'The receiving account does not exist or is not yours. You can only transfer money between your own accounts.';
    END IF;
    
    RETURN QUERY
    SELECT *
    FROM customer.transfer t
    WHERE t.transfer_id = currval('customer.transfer_transfer_id_seq');
END;
$$ LANGUAGE plpgsql;


-- manager approval of transaction procedure (loans, credit limits)
CREATE OR REPLACE FUNCTION manager.approve_pending(param_employee int, tran_id int)
RETURNS TABLE(appr_id int, appr_employee int, appr_date date, appr_tran int) AS $$
BEGIN
    IF (SELECT er.employeerole_name FROM employee.employee e JOIN employee.employee_roles er ON e.employee_role = er.employeerole_id WHERE e.employee_id = param_employee) = 'Manager' THEN
        -- Update pending transactions with sensitive flag set to true if sensitive flag is set to true
        IF EXISTS (SELECT * FROM customer.transaction_pending WHERE pending_sensitiveflag = true AND pending_approvalflag = false AND pending_transactionid = tran_id) THEN
            UPDATE customer.transaction_pending
            SET pending_approvalflag = true
            WHERE pending_sensitiveflag = true AND pending_transactionid = tran_id;

            IF EXISTS (SELECT pending_transferid FROM customer.transaction_pending WHERE pending_approvalflag = true AND pending_transactionid = tran_id) THEN
                UPDATE customer.transfer t
                SET transfer_status = 'COMPLETE'
                FROM customer.transaction_pending tr
                WHERE t.transfer_id = tr.pending_transferid;
            END IF;

            IF EXISTS (SELECT pending_paymentid FROM customer.transaction_pending WHERE pending_approvalflag = true AND pending_transactionid = tran_id) THEN
                UPDATE customer.payment p
                SET payment_status = 'COMPLETE'
                FROM customer.transaction_pending tr
                WHERE p.payment_id = tr.pending_paymentid;
            END IF;

            IF EXISTS (SELECT pending_loanid FROM customer.transaction_pending WHERE pending_approvalflag = true AND pending_transactionid = tran_id) THEN
                UPDATE customer.loan l
                SET loan_status = 'ACTIVE'
                FROM customer.transaction_pending tr
                WHERE l.loan_id = tr.pending_loanid;

                UPDATE customer.loan
                SET loan_outstanding = 
                (
                    SELECT lt.loantype_amount 
                    FROM customer.transaction_pending tp 
                    JOIN customer.loan l ON l.loan_id = tp.pending_loanid 
                    JOIN customer.loan_type lt ON l.loan_type = lt.loantype_id 
                    WHERE tp.pending_transactionid = tran_id
                )
                * (( SELECT lt.loantype_interest
                    FROM customer.transaction_pending tp 
                    JOIN customer.loan l ON l.loan_id = tp.pending_loanid 
                    JOIN customer.loan_type lt ON l.loan_type = lt.loantype_id 
                    WHERE tp.pending_transactionid = tran_id 
                )+1)
                
                FROM customer.transaction_pending tr
                WHERE loan_id = tr.pending_loanid; 

                UPDATE customer.account
                SET account_balance = account_balance + (SELECT loantype_amount FROM customer.loan_type lt JOIN customer.loan l ON l.loan_type = lt.loantype_id WHERE l.loan_id = (SELECT pending_loanid FROM customer.transaction_pending WHERE pending_approvalflag = true AND pending_transactionid = tran_id))
                WHERE account_loan = (SELECT pending_loanid FROM customer.transaction_pending WHERE pending_approvalflag = true AND pending_transactionid = tran_id);

            END IF;
            
            -- Update approvals record
            INSERT INTO manager.approval(approval_id, approval_employee, approval_date,approval_transaction)
            VALUES (nextval('manager.approval_approval_id_seq'), param_employee, NOW(), tran_id);

            -- Update transaction record
            INSERT INTO customer.transaction(transaction_id, transaction_complete)
            VALUES(nextval('customer.transaction_transaction_id_seq'), tran_id);

        ELSIF EXISTS (SELECT * FROM customer.transaction_pending WHERE (pending_sensitiveflag = false OR pending_approvalflag = true) AND pending_transactionid = tran_id) THEN
            RAISE EXCEPTION 'Transaction is not sensitive or does not need approval.';

        ELSE
            RAISE EXCEPTION 'No transaction found';

        END IF;

    ELSE
        RAISE EXCEPTION 'Employee is not a manager';
    END IF;

    RETURN QUERY
    SELECT *
    FROM manager.approval a
    WHERE a.approval_id = currval('manager.approval_approval_id_seq');
END;
$$ LANGUAGE plpgsql;




--creation of roles and users

-- bank role and users, permission and privileges
CREATE ROLE role_bank;
CREATE ROLE user_bank1 WITH LOGIN PASSWORD 'test';

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA bank TO role_bank;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA manager TO role_bank;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA employee TO role_bank;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA customer TO role_bank;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA customer TO role_bank;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA employee TO role_bank;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA manager TO role_bank;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bank TO role_bank;

GRANT USAGE ON SCHEMA bank TO role_bank;
GRANT USAGE ON SCHEMA manager TO role_bank;
GRANT USAGE ON SCHEMA employee TO role_bank;
GRANT USAGE ON SCHEMA customer TO role_bank;

GRANT role_bank TO user_bank1;


-- customer role and users, permission and privileges
CREATE ROLE role_customer;
CREATE ROLE user_customer1 WITH LOGIN PASSWORD 'test';

GRANT USAGE ON SCHEMA customer TO role_customer;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA customer TO role_customer;
GRANT SELECT ON ALL TABLES IN SCHEMA customer TO role_customer;

GRANT role_customer TO user_customer1;


-- employee role and users, permission and privileges
CREATE ROLE role_employee;
CREATE ROLE user_employee1 WITH LOGIN PASSWORD 'test';

GRANT USAGE ON SCHEMA employee TO role_employee;
GRANT SELECT ON ALL TABLES IN SCHEMA employee TO role_employee;

GRANT USAGE ON SCHEMA bank TO role_employee;
GRANT SELECT ON TABLE bank.branch TO role_employee;

GRANT role_employee TO user_employee1;
GRANT role_customer TO user_employee1;


-- manager role and users, permission and privileges
CREATE ROLE role_manager;
CREATE ROLE user_manager1 WITH LOGIN PASSWORD 'test';

GRANT USAGE ON SCHEMA manager TO role_manager;
GRANT SELECT, UPDATE, INSERT ON ALL TABLES IN SCHEMA manager TO role_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA manager TO role_manager; 

GRANT UPDATE ON TABLE customer.transaction_pending TO role_manager;
GRANT INSERT ON TABLE customer.transaction TO role_manager;
GRANT UPDATE ON TABLE customer.transfer TO role_manager;
GRANT UPDATE ON TABLE customer.payment TO role_manager;
GRANT UPDATE ON TABLE customer.account TO role_manager;
GRANT SELECT ON TABLE customer.loan_type TO role_manager;
GRANT SELECT, UPDATE ON TABLE customer.loan TO role_manager;

GRANT USAGE, SELECT ON SEQUENCE customer.transaction_transaction_id_seq TO role_manager;

GRANT role_manager TO user_manager1;
GRANT role_employee TO user_manager1;
GRANT role_customer TO user_manager1;   
