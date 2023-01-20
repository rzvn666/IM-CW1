#!/bin/bash

export PGHOST=localhost
export PGDATABASE=banking
export PGUSER=postgres
export PGPASSWORD=postgres


psql -c "INSERT INTO bank.bank (bank_id, bank_name, bank_bic, bank_address, bank_postcode, bank_country) VALUES
(nextval('bank.bank_bank_id_seq'),'LLOYDS PANK PLC','LOYDGB2LXXX','25 MONUMENT STREET','EC3R8BQ','United Kingdom');
"


psql -c "INSERT INTO bank.branch (branch_sortcode, branch_bankid, branch_name, branch_address, branch_postcode, branch_country) VALUES
('309921',1,'Lloyds Bank Watford','Po Box 1000','BX11LT','United Kingdom');
"


psql -c "INSERT INTO bank.account_type (type_id, type_name) VALUES
(nextval('bank.account_type_type_id_seq'),'Current Account');
"


# psql -c "INSERT INTO bank.loan (loan_id, loan_accountnum, loan_amount, loan_interest, loan_apr, loan_term) VALUES
# ();
# "


psql -c "INSERT INTO customer.customer (customer_id, customer_username, customer_password, customer_fname, customer_lname, customer_mobile, customer_email, customer_address, customer_postcode) VALUES
(nextval('customer.customer_customer_id_seq'),'testuser','testuser','Andrew','Ferguson','07941083085','andrewferguson@gmail.com','10 Abbey Close, Coventry','CV56HN');
"


psql -c "INSERT INTO customer.account (account_number, account_sortcode, account_customerid, account_type, account_balance, account_name, account_iban, account_opendate) VALUES
('68932868','309921',1,1,2000,'bank account 1','GB73LOYD30992168932868','2023-01-16');
"

psql -c "INSERT INTO customer.account (account_number, account_sortcode, account_customerid, account_type, account_balance, account_name, account_iban, account_opendate) VALUES
('68932777','309921',1,1,500,'bank account 2','GB73LOYD30992168932777','2023-01-19');
"

# psql -c "INSERT INTO customer.payment (payment_id, payment_accountnum, payment_receiveraccnum, payment_receiversortcode, payment_receivername, payment_amount, payment_date) VALUES
# ();
# "


# psql -c "INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_transferid, pending_paymentid, pending_loanid, pending_sensitiveflag, pending_approvalid) VALUES
# ();
# "

# psql -c "INSERT INTO customer.transaction (transaction_id, transaction_complete) VALUES
# ();
# "


# psql -c "INSERT INTO customer.transfer (transfer_id, transfer_senderaccnum, transfer_receiveraccnum, transfer_amount, transfer_date) VALUES
# ();
# "


# psql -c "INSERT INTO manager.approval (approval_id, approval_employee, approval_date, approval_flag) VALUES
# ();
# "

    
psql -c "INSERT INTO employee.employee (employee_id, employee_sortcode, employee_username, employee_password, employee_role, employee_fname, employee_lname, employee_mobile, employee_email, employee_address, employee_postcode) VALUES
(nextval('employee.employee_employee_id_seq'),'309921','employeeuser','employeepass','employee','John','Doe','07495381704','johndoe@gmail.com','321 Regent Street','N127JE'),
(nextval('employee.employee_employee_id_seq'),'309921','manageruser','managerpass','manager','Jane','Doe','07495385874','janedoe@gmail.com','1 Market Street','W36PE');
"
