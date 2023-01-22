DROP ROLE role_bank;
DROP ROLE role_employee;
DROP ROLE role_manager;
DROP ROLE role_customer;

DROP ROLE user_bank1;
DROP ROLE user_employee1;
DROP ROLE user_manager1;
DROP ROLE user_customer1;

CREATE SCHEMA bank;
CREATE SCHEMA employee;
CREATE SCHEMA manager;
CREATE SCHEMA customer;


CREATE TABLE bank.bank (
    bank_id SERIAL PRIMARY KEY,
    bank_name character varying(50) NOT NULL,
    bank_bic character(11) NOT NULL UNIQUE,
    bank_address character varying(255) NOT NULL,
    bank_postcode character varying(10) NOT NULL,
    bank_country character varying(60) NOT NULL
);

CREATE TABLE bank.branch (
    branch_sortcode character(6) PRIMARY KEY,
    branch_bankid integer NOT NULL REFERENCES bank.bank(bank_id),
    branch_name character varying(50) NOT NULL,
    branch_address character varying(255) NOT NULL,
    branch_postcode character varying(10) NOT NULL,
    branch_country character varying(60) NOT NULL
);

CREATE TABLE bank.account_type (
    type_id SERIAL PRIMARY KEY,
    type_name character varying(100) NOT NULL
);

CREATE TABLE bank.loan_type (
    loantype_id SERIAL PRIMARY KEY,
    loantype_amount integer NOT NULL,
    loantype_interest real NOT NULL,
    loantype_term integer NOT NULL
);

CREATE TABLE bank.loan(
    loan_id SERIAL PRIMARY KEY,
    loan_type INT NOT NULL REFERENCES bank.loan_type(loantype_id),
    loan_status varchar(50) NOT NULL
);

CREATE TABLE customer.customer (
    customer_id SERIAL PRIMARY KEY,
    customer_username character varying(30) NOT NULL UNIQUE,
    customer_password character varying(30) NOT NULL,
    customer_fname character varying(50) NOT NULL,
    customer_lname character varying(50) NOT NULL,
    customer_mobile character(11) NOT NULL UNIQUE,
    customer_email character varying(50) NOT NULL UNIQUE,
    customer_address character varying(255) NOT NULL,
    customer_postcode character varying(10) NOT NULL
);


CREATE TABLE customer.account (
    account_number character(8) PRIMARY KEY,
    account_sortcode character(6) NOT NULL REFERENCES bank.branch(branch_sortcode),
    account_customerid integer NOT NULL REFERENCES customer.customer(customer_id),
    account_type integer NOT NULL REFERENCES bank.account_type(type_id),
    account_loan integer REFERENCES bank.loan(loan_id),
    account_balance integer NOT NULL,
    account_name character varying(255) NOT NULL,
    account_iban character varying(34) NOT NULL,
    account_opendate date NOT NULL
);


CREATE TABLE employee.employee (
    employee_id SERIAL PRIMARY KEY,
    employee_sortcode character(6) NOT NULL REFERENCES bank.branch(branch_sortcode),
    employee_username character varying(255) NOT NULL,
    employee_password character varying(255) NOT NULL,
    employee_role character varying(50) NOT NULL,
    employee_fname character varying(50) NOT NULL,
    employee_lname character varying(50) NOT NULL,
    employee_mobile character(11) NOT NULL,
    employee_email character varying(50) NOT NULL,
    employee_address character varying(255) NOT NULL,
    employee_postcode character varying(10) NOT NULL
);



CREATE TABLE customer.payment (
    payment_id SERIAL PRIMARY KEY,
    payment_accountnum character(8) NOT NULL REFERENCES customer.account(account_number),
    payment_receiveraccnum character(8) NOT NULL,
    payment_receiversortcode character(6) NOT NULL,
    payment_receivername character varying(255) NOT NULL,
    payment_amount integer NOT NULL,
    payment_status varchar(50) NOT NULL,
    payment_date date NOT NULL
);

CREATE TABLE customer.transfer (
    transfer_id SERIAL PRIMARY KEY,
    transfer_senderaccnum character(8) NOT NULL REFERENCES customer.account(account_number),
    transfer_receiveraccnum character(8) NOT NULL REFERENCES customer.account(account_number),
    transfer_amount integer NOT NULL,
    transfer_status varchar(50) NOT NULL,
    transfer_date date NOT NULL
);


CREATE TABLE customer.transaction_pending (
    pending_transactionid SERIAL PRIMARY KEY,
    pending_transactionref character varying(255) NOT NULL,
    pending_transferid INTEGER REFERENCES customer.transfer(transfer_id),
    pending_paymentid INTEGER REFERENCES customer.payment(payment_id),
    pending_loanid INTEGER REFERENCES bank.loan(loan_id),
    pending_sensitiveflag BOOLEAN NOT NULL,
    pending_approvalflag BOOLEAN NOT NULL
);

CREATE TABLE manager.approval (
    approval_id SERIAL PRIMARY KEY,
    approval_date date NOT NULL,
    approval_transaction integer NOT NULL REFERENCES customer.transaction_pending(pending_transactionid)
);

CREATE TABLE customer.transaction (
    transaction_id SERIAL PRIMARY KEY,
    transaction_complete integer NOT NULL REFERENCES customer.transaction_pending(pending_transactionid)
);


-- all functions and procedures

-- customer can enter their details into customer table 
-- and an account is created for them 

-- testing making customer entry 
-- psql -U user_customer1 -h localhost -d banking -c "select * from customer.create_entry('jmika','pass123','John','Mikaelis','07495083045','jonhhny@gmail.com','18 Abbey Close, Coventry','CV56HN')"


CREATE OR REPLACE FUNCTION customer.create_customer(param_uname varchar(30), param_pass varchar(30), param_fname varchar(50), param_lname varchar(50), param_mobile char(11), param_email varchar(50), param_address varchar(255), param_postcode varchar(10))
RETURNS void AS $$
BEGIN
    INSERT INTO customer.customer
    VALUES(nextval('customer.customer_customer_id_seq'),param_uname, param_pass, param_fname, param_lname, param_mobile, param_email, param_address, param_postcode);
END;
$$ LANGUAGE plpgsql;


-- existing customer can open another account


-- customer can see their balance function
CREATE OR REPLACE FUNCTION customer.check_all_account_balances(id INTEGER)
RETURNS TABLE (account_number character(8), account_name varchar(255), account_type varchar(100), account_balance INTEGER) AS $$
BEGIN
  -- check if the customer exists
  RETURN QUERY 
  SELECT a.account_number, a.account_name, at.type_name, a.account_balance 
  FROM customer.account a 
  JOIN bank.account_type at ON a.account_type = at.type_id
  WHERE a.account_customerid = id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE EXCEPTION 'Customer % not found', id;
END;
$$ LANGUAGE plpgsql;


-- apply for a loan, wait for approval and then loan gets assigned to account


-- MAKE SURE THAT THE PAYMENTS OR TRANSFERS PENDING ARE COMPLETED AND THE MONEY IS SENT ONLY
-- AFTER THEY HAVE BEEN COMPLETED
-- MAKE A PROCEDURE CALLED transfer_complete
-- IF TRANSFER IS COMPLETE, MINUS MONEY FROM HERE AND ADD HERE
-- IF PAYMENT IS COMPLETE, MINUS MONEY AND SEND DETAILS
-- IF LOAN IS COMPLETE, ADD MONEY TO BANK ACCOUNT WITH ACCOUNT NUMBER
-- MAYBE FIGURE OUT HOW TO PAY BACK MONTHLY AUTOMATICALLY


-- make a payment
CREATE OR REPLACE FUNCTION bank.make_payment(
    sender_accnum character(8),
    receiver_accnum character(8),
    receiver_sortcode character(6),
    receiver_name varchar(255),
    amount integer
)
RETURNS TABLE (pay_id INTEGER, pay_account char(8), pay_receiveracc char(8), pay_receiversort char(6), pay_receivername varchar(255), pay_amount INTEGER, pay_status varchar(50), pay_date DATE) AS $$
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
    VALUES (nextval('customer.payment_payment_id_seq'), sender_accnum, receiver_accnum, receiver_sortcode, receiver_name, amount, 'PENDING', NOW());

    -- insert payment into customer.transaction_pending table
    INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_sensitiveflag, pending_paymentid)
    VALUES (nextval('customer.transaction_pending_pending_transactionid_seq'), 'PAYMENT', false, currval('customer.payment_payment_id_seq'));

    RETURN QUERY
    SELECT *
    FROM customer.payment p
    WHERE p.payment_id = currval('customer.payment_payment_id_seq');

END;
$$ LANGUAGE plpgsql;

-- make a transfer
CREATE OR REPLACE FUNCTION bank.make_transfer(
    sender_accnum character(8),
    receiver_accnum character(8),
    amount integer
)
RETURNS TABLE (tran_id int, tran_senderacc char(8), tran_receiveracc char(8), tran_amount int, tran_status varchar(50), tran_date date) AS $$
BEGIN
    IF amount <= 0 THEN
        RAISE EXCEPTION 'Cannot transfer negative amount of money';
    END IF;

    -- check if sender account exists
    IF NOT EXISTS (SELECT 1 FROM customer.account WHERE account_number = sender_accnum) THEN
        RAISE EXCEPTION 'Sender account does not exist';
    END IF;

    -- check if receiver account exists
    IF NOT EXISTS (SELECT 1 FROM customer.account WHERE account_number = receiver_accnum) THEN
        RAISE EXCEPTION 'Receiver account does not exist';
    END IF;

    -- check if sender has sufficient funds
    IF (SELECT account_balance FROM customer.account WHERE account_number = sender_accnum) < amount THEN
        RAISE EXCEPTION 'Insufficient funds in sender account';
    END IF;

    -- update sender account balance
    UPDATE customer.account SET account_balance = account_balance - amount WHERE account_number = sender_accnum;

    -- update receiver account balance
    UPDATE customer.account SET account_balance = account_balance + amount WHERE account_number = receiver_accnum;

    -- insert transfer into customer.transfer table
    INSERT INTO customer.transfer (transfer_id, transfer_senderaccnum, transfer_receiveraccnum, transfer_amount, transfer_status, transfer_date)
    VALUES (nextval('customer.transfer_transfer_id_seq'), sender_accnum, receiver_accnum, amount, 'PENDING', NOW());

    -- insert transfer into customer.transaction_pending table
    INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_sensitiveflag, pending_transferid)
    VALUES (nextval('customer.transaction_pending_pending_transactionid_seq'), 'TRANSFER', false, currval('customer.transfer_transfer_id_seq'));

    RETURN QUERY
    SELECT *
    FROM customer.transfer t
    WHERE t.transfer_id = currval('customer.transfer_transfer_id_seq');
END;
$$ LANGUAGE plpgsql;


-- check a transfer
CREATE OR REPLACE FUNCTION customer.check_transfer_transactions(IN c_id INTEGER)
RETURNS TABLE(transaction_id INTEGER, transaction_ref character varying(255), transfer_id INTEGER, account_number CHARACTER(8), receiver_accnum CHARACTER(8), amount INTEGER, status varchar(50), date DATE)
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

-- check a payment
CREATE OR REPLACE FUNCTION customer.check_payment_transactions(IN c_id INTEGER)
RETURNS TABLE(transaction_id INTEGER, transaction_ref character varying(255), payment_id INTEGER, account_number CHARACTER(8), receiver_accnum CHARACTER(8), receiver_sortcode CHARACTER(6), payment_receivername character varying(255), amount INTEGER, status varchar(50), date DATE)
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY 
    SELECT t.pending_transactionid, t.pending_transactionref, t.pending_paymentid, p.payment_accountnum, p.payment_receiveraccnum, p.payment_receiversortcode, p.payment_receivername, p.payment_amount, p.payment_status, p.payment_date
    FROM customer.transaction_pending t
    JOIN customer.payment p ON t.pending_paymentid = p.payment_id
    WHERE p.payment_accountnum IN (SELECT account_number FROM customer.account WHERE account_customerid = c_id);
END;
$$ LANGUAGE plpgsql;


-- manager approval of transaction procedure (loans, credit limits)
CREATE OR REPLACE FUNCTION manager.approve_pending_transactions(tran_id int)
RETURNS TABLE(appr_id int, appr_date date, appr_tran int) AS $$
BEGIN
    -- Update pending transactions with sensitive flag set to true if sensitive flag is set to true
    IF EXISTS (SELECT * FROM customer.transaction_pending WHERE pending_sensitiveflag = true AND pending_approvalflag = false AND pending_transactionid = tran_id) THEN
        UPDATE customer.transaction_pending
        SET pending_approvalflag = true
        WHERE pending_sensitiveflag = true AND pending_transactionid = tran_id;
        
        
        -- Update approvals record
        INSERT INTO manager.approval(approval_id,approval_date,approval_transaction)
        VALUES (nextval('manager.approval_approval_id_seq'),NOW(),tran_id);

    ELSIF EXISTS (SELECT * FROM customer.transaction_pending WHERE pending_sensitiveflag = false OR pending_approvalflag = true AND pending_transactionid = tran_id) THEN
        RAISE EXCEPTION 'Transaction is not sensitive or does not need approval.';

    ELSE
        RAISE EXCEPTION 'No transaction found';

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

GRANT USAGE, SELECT ON SEQUENCE customer.transfer_transfer_id_seq TO role_bank;
GRANT USAGE, SELECT ON SEQUENCE customer.transaction_pending_pending_transactionid_seq TO role_bank;


GRANT USAGE ON SCHEMA bank TO role_bank;
GRANT USAGE ON SCHEMA manager TO role_bank;
GRANT USAGE ON SCHEMA employee TO role_bank;
GRANT USAGE ON SCHEMA customer TO role_bank;


GRANT role_bank TO user_bank1;


-- employee role and users, permission and privileges
CREATE ROLE role_employee;
CREATE ROLE user_employee1 WITH LOGIN PASSWORD 'test';

GRANT USAGE ON SCHEMA employee TO role_employee;
GRANT SELECT ON ALL TABLES IN SCHEMA employee TO role_employee;

GRANT USAGE ON SCHEMA customer TO role_employee;
GRANT SELECT ON TABLE customer.account TO role_employee;

GRANT USAGE ON SCHEMA bank TO role_employee;
GRANT SELECT ON TABLE bank.account_type TO role_employee;

GRANT role_employee TO user_employee1;


-- manager role and users, permission and privileges
CREATE ROLE role_manager;
CREATE ROLE user_manager1 WITH LOGIN PASSWORD 'test';
GRANT USAGE ON SCHEMA manager TO role_manager;
GRANT SELECT ON ALL TABLES IN SCHEMA manager TO role_manager;

GRANT SELECT, UPDATE ON TABLE customer.transaction_pending TO role_manager;

GRANT role_manager TO user_manager1;
GRANT role_employee TO user_manager1;

-- customer role and users, permission and privileges
CREATE ROLE role_customer;
CREATE ROLE user_customer1 WITH LOGIN PASSWORD 'test';

GRANT USAGE ON SCHEMA customer TO role_customer;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA customer TO role_customer;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA customer TO role_customer;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA customer TO role_customer;

GRANT USAGE ON SCHEMA bank TO role_customer;
GRANT SELECT ON TABLE bank.account_type TO role_customer;

GRANT role_customer TO user_customer1;