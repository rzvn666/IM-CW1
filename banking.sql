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

CREATE TABLE customer.customer (
    customer_id SERIAL PRIMARY KEY,
    customer_username character varying(30) NOT NULL UNIQUE,
    customer_password character varying(255) NOT NULL,
    customer_fname character varying(255) NOT NULL,
    customer_lname character varying(255) NOT NULL,
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


CREATE TABLE manager.approval (
    approval_id SERIAL PRIMARY KEY,
    approval_employee integer NOT NULL REFERENCES employee.employee(employee_id),
    approval_date date NOT NULL,
    approval_flag boolean NOT NULL
);


CREATE TABLE bank.loan (
    loan_id SERIAL PRIMARY KEY,
    loan_accountnum character(8) NOT NULL REFERENCES customer.account(account_number),
    loan_amount integer NOT NULL,
    loan_interest real NOT NULL,
    loan_apr real NOT NULL,
    loan_term integer NOT NULL
);


CREATE TABLE customer.payment (
    payment_id SERIAL PRIMARY KEY,
    payment_accountnum character(8) NOT NULL REFERENCES customer.account(account_number),
    payment_receiveraccnum character(8) NOT NULL,
    payment_receiversortcode character(6) NOT NULL,
    payment_receivername character varying(255) NOT NULL,
    payment_amount integer NOT NULL,
    payment_date date NOT NULL
);

CREATE TABLE customer.transfer (
    transfer_id SERIAL PRIMARY KEY,
    transfer_senderaccnum character(8) NOT NULL,
    transfer_receiveraccnum character(8) NOT NULL,
    transfer_amount integer NOT NULL,
    transfer_date date NOT NULL
);


CREATE TABLE customer.transaction_pending (
    pending_transactionid SERIAL PRIMARY KEY,
    pending_transactionref character varying(255) NOT NULL,
    pending_transferid INTEGER REFERENCES customer.transfer(transfer_id),
    pending_paymentid INTEGER REFERENCES customer.payment(payment_id),
    pending_loanid INTEGER REFERENCES bank.loan(loan_id),
    pending_sensitiveflag BOOLEAN NOT NULL,
    pending_approvalid INTEGER REFERENCES manager.approval(approval_id)
);


CREATE TABLE customer.transaction (
    transaction_id SERIAL PRIMARY KEY,
    transaction_complete integer NOT NULL REFERENCES customer.transaction_pending(pending_transactionid)
);


-- all functions and procedures

-- employee get balance function
CREATE OR REPLACE FUNCTION customer.check_all_account_balances(id INTEGER)
RETURNS TABLE (account_number character(8), account_name character varying(255), account_type varchar(100), account_balance INTEGER) AS $$
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


-- make a transfer
CREATE OR REPLACE FUNCTION bank.transfer_money(
    sender_accnum character(8),
    receiver_accnum character(8),
    amount integer
)
RETURNS void AS $$
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
    INSERT INTO customer.transfer (transfer_id, transfer_senderaccnum, transfer_receiveraccnum, transfer_amount, transfer_date)
    VALUES (nextval('customer.transfer_transfer_id_seq'), sender_accnum, receiver_accnum, amount, CURRENT_DATE);

    -- insert transfer into customer.transaction_pending table
    INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_sensitiveflag, pending_transferid)
    VALUES (nextval('customer.transaction_pending_pending_transactionid_seq'), 'transferring funds', false, currval('customer.transfer_transfer_id_seq'));

END;
$$ LANGUAGE plpgsql;


-- check a transfer
CREATE OR REPLACE FUNCTION customer.check_transfer_transactions(IN c_id INTEGER)
RETURNS TABLE(transaction_id INTEGER, transaction_ref character varying(255), transfer_id INTEGER, account_number CHARACTER(8), receiver_accnum CHARACTER(8), amount INTEGER, date DATE)
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY 
    SELECT t.pending_transactionid, t.pending_transactionref, t.pending_transferid, tr.transfer_senderaccnum, tr.transfer_receiveraccnum, tr.transfer_amount, tr.transfer_date
    FROM customer.transaction_pending t
    JOIN customer.transfer tr ON t.pending_transferid = tr.transfer_id
    WHERE tr.transfer_senderaccnum IN (SELECT account_number FROM customer.account WHERE account_customerid = c_id);
END;
$$ LANGUAGE plpgsql;


-- -- manager approval of transaction procedure





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
GRANT SELECT ON ALL TABLES IN SCHEMA customer TO role_customer;

GRANT USAGE ON SCHEMA bank TO role_customer;
GRANT SELECT ON TABLE bank.account_type TO role_customer;

GRANT role_customer TO user_customer1;