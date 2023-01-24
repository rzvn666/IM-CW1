#!/bin/bash

export PGHOST=localhost
export PGDATABASE=banking
export PGUSER=postgres
export PGPASSWORD=postgres


psql -c "INSERT INTO bank.bank (bank_id, bank_name, bank_bic, bank_address, bank_postcode, bank_country) VALUES
(nextval('bank.bank_bank_id_seq'),'LLOYDS PANK PLC','LOYDGB2LXXX','25 MONUMENT STREET','EC3R8BQ','United Kingdom');
"


psql -c "INSERT INTO bank.branch (branch_sortcode, branch_bankid, branch_name, branch_address, branch_postcode, branch_country) VALUES
('309921',1,'Lloyds Bank Watford','Po Box 1000','BX11LT','United Kingdom'),
('386650',1,'Lloyds Bank Warwick','Po Box WARWICK','CV354LT','United Kingdom');
"


psql -c "INSERT INTO bank.account_type (type_id, type_name) VALUES
(nextval('bank.account_type_type_id_seq'),'Current Account');
"


psql -c "INSERT INTO bank.loan_type (loantype_id, loantype_amount, loantype_interest, loantype_term) VALUES
(nextval('bank.loan_type_loantype_id_seq'),10000,0.054,60),
(nextval('bank.loan_type_loantype_id_seq'),25000,0.069,60);
"


psql -c "INSERT INTO bank.loan (loan_id, loan_type, loan_status, loan_date) VALUES
(nextval('bank.loan_loan_id_seq'),1,'PENDING', NOW());
"


psql -c "INSERT INTO customer.customer (customer_id, customer_username, customer_password, customer_fname, customer_lname, customer_mobile, customer_email, customer_address, customer_postcode) VALUES
(nextval('customer.customer_customer_id_seq'),'aferguson1','testpass','Andrew','Ferguson','07941083085','andrewferguson@gmail.com','10 Abbey Close, Coventry','CV56HN'),
(nextval('customer.customer_customer_id_seq'),'mpearlo1','passtest','Maria','Pearlo','07458634123','mariapearlo123@gmail.com','156 Lowley Road, Warwick','CV344XP');
"


psql -c "INSERT INTO customer.account (account_number, account_sortcode, account_customerid, account_type, account_balance, account_name, account_iban, account_opendate) VALUES
('68932868','309921',1,1,2000,'bank account 1 andrew','GB73LOYD30992168932868',NOW()),
('68932777','309921',1,1,500,'bank account 2 andrew','GB73LOYD30992168932777',NOW()),
('68156222','386650',2,1,10000,'bank account 1 maria','GB73LOYD38665068156222',NOW()),
('68156345','386650',2,1,65000,'bank account 2 maria','GB73LOYD38665068156345',NOW());
"

psql -c "INSERT INTO customer.payment (payment_id, payment_accountnum, payment_receiveraccnum, payment_receiversortcode, payment_receivername, payment_amount, payment_status, payment_date) VALUES
(nextval('customer.payment_payment_id_seq'),'68932777','12345678','112233','John Ferguson',500,'COMPLETE',NOW()),
(nextval('customer.payment_payment_id_seq'),'68156222','65423133','112233','Johnny Pearlo',500,'PENDING',NOW()),
(nextval('customer.payment_payment_id_seq'),'68156345','98732123','112233','Janay Pearlo',500,'COMPLETE',NOW()),
(nextval('customer.payment_payment_id_seq'),'68932868','87654321','332211','Jane Ferguson',220,'PENDING',NOW());
"

psql -c "INSERT INTO customer.transfer (transfer_id, transfer_senderaccnum, transfer_receiveraccnum, transfer_amount, transfer_status, transfer_date) VALUES
(nextval('customer.transfer_transfer_id_seq'),'68932868','68932777',300,'COMPLETE',NOW()),
(nextval('customer.transfer_transfer_id_seq'),'68156222','68156345',1200,'PENDING',NOW());
"

psql -c "INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_transferid, pending_paymentid, pending_loanid, pending_sensitiveflag, pending_approvalflag) VALUES
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,1,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,2,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,3,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,4,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'TRANSFER',1,NULL,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'TRANSFER',2,NULL,NULL,true,false),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'LOAN',NULL,NULL,1,true,false);
"

# psql -c "INSERT INTO customer.transaction (transaction_id, transaction_complete) VALUES
# ();
# "



# psql -c "INSERT INTO manager.approval (approval_id, approval_employee, approval_date, approval_flag) VALUES
# ();
# "

    
psql -c "INSERT INTO employee.employee (employee_id, employee_sortcode, employee_username, employee_password, employee_role, employee_fname, employee_lname, employee_mobile, employee_email, employee_address, employee_postcode) VALUES
(nextval('employee.employee_employee_id_seq'),'309921','employeeuser','employeepass','employee','John','Doe','07495381704','johndoe@gmail.com','321 Regent Street','N127JE'),
(nextval('employee.employee_employee_id_seq'),'309921','manageruser','managerpass','manager','Jane','Doe','07495385874','janedoe@gmail.com','1 Market Street','W36PE');
"
