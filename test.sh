#!/bin/bash
version='psql --version | cut -c 19-20'
if $version; then
    go=$(eval "$version")
    foo='/etc/postgresql-'$go/
    sudo cp config/* ${foo}

    echo "
    ##################################
    CONFIG FILES MOVED SUCCESSFULLY
    ##################################
    "
else
    echo "
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    NO POSTGRESQL INSTALLED
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    "
fi

if sudo chown postgres:postgres ${foo}/pg_hba.conf && sudo chown postgres:postgres ${foo}/postgresql.conf; then
    echo "
    ##################################
    CONFIG FILES CHOWN SUCCESSFUL
    ##################################
    "
else
    echo "
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    CONFIG FILES FAILED TO CHOWN
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    "
fi

if sudo systemctl restart postgresql; then
    echo "
    ##################################
    SYSTEMCTL SUCCESSFUL RESTART
    ##################################    
    "
else 
    echo "
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    NO SYSTEMCTL FOUND
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    "
fi

if sudo rc-service postgresql-$go restart; then
    echo "
    ##################################
    RC-SERVICE SUCCESSFUL RESTART
    ##################################    
    "
else 
    echo "
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    NO RC-SERVICE FOUND
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    "
fi

export PGHOST=localhost
export PGPORT=5433
export PGUSER=postgres
export PGPASSWORD=postgres

psql -c "DROP DATABASE banking";
psql -c "CREATE DATABASE banking";
psql -U postgres -d banking < banking.sql;

export PGDATABASE=banking


psql -c "INSERT INTO bank.bank (bank_id, bank_name, bank_bic, bank_address, bank_postcode, bank_country) VALUES
(nextval('bank.bank_bank_id_seq'),'LLOYDS PANK PLC','LOYDGB2LXXX','25 MONUMENT STREET','EC3R8BQ','United Kingdom');
"


psql -c "INSERT INTO bank.branch (branch_sortcode, branch_bankid, branch_name, branch_address, branch_postcode, branch_country) VALUES
('309921',1,'Lloyds Bank Watford','Po Box 1000','BX11LT','United Kingdom'),
('386650',1,'Lloyds Bank Warwick','Po Box WARWICK','CV354LT','United Kingdom');
"


psql -c "INSERT INTO customer.account_type (type_id, type_name) VALUES
(nextval('customer.account_type_type_id_seq'),'Current Account');
"


psql -c "INSERT INTO customer.loan_type (loantype_id, loantype_amount, loantype_interest, loantype_term) VALUES
(nextval('customer.loan_type_loantype_id_seq'),10000,0.054,60),
(nextval('customer.loan_type_loantype_id_seq'),25000,0.069,60);
"


psql -c "INSERT INTO customer.loan (loan_id, loan_type, loan_status, loan_date) VALUES
(nextval('customer.loan_loan_id_seq'),1,'PENDING', NOW());
"


psql -c "INSERT INTO customer.customer (customer_id, customer_username, customer_password, customer_fname, customer_lname, customer_mobile, customer_email, customer_address, customer_postcode) VALUES
(nextval('customer.customer_customer_id_seq'),'aferguson1','testpass','Andrew','Ferguson','07941083085','andrewferguson@gmail.com','10 Abbey Close, Coventry','CV56HN'),
(nextval('customer.customer_customer_id_seq'),'mpearlo1','passtest','Maria','Pearlo','07458634123','mariapearlo123@gmail.com','156 Lowley Road, Warwick','CV344XP');
"


psql -c "INSERT INTO customer.account (account_number, account_sortcode, account_customerid, account_type, account_loan, account_balance, account_name, account_iban, account_opendate) VALUES
('68932868','309921',1,1,NULL,2000,'bank account 1 andrew','GB73LOYD30992168932868',NOW()),
('68932777','309921',1,1,NULL,500,'bank account 2 andrew','GB73LOYD30992168932777',NOW()),
('68156222','386650',2,1,NULL,10000,'bank account 1 maria','GB73LOYD38665068156222',NOW()),
('68156345','386650',2,1,1,65000,'bank account 2 maria','GB73LOYD38665068156345',NOW());
"

psql -c "INSERT INTO customer.payment (payment_id, payment_accountnum, payment_receiveraccnum, payment_receiversortcode, payment_receivername, payment_amount, payment_status, payment_date) VALUES
(nextval('customer.payment_payment_id_seq'),'68932777','12345678','112233','John Ferguson',500,'COMPLETE',NOW()),
(nextval('customer.payment_payment_id_seq'),'68156222','65423133','112233','Johnny Pearlo',500,'PENDING',NOW()),
(nextval('customer.payment_payment_id_seq'),'68156345','98732123','112233','Janay Pearlo',500,'COMPLETE',NOW()),
(nextval('customer.payment_payment_id_seq'),'68932868','87654321','332211','Jane Ferguson',220,'PENDING',NOW());
"

psql -c "INSERT INTO customer.transfer (transfer_id, transfer_senderaccnum, transfer_receiveraccnum, transfer_amount, transfer_status, transfer_date) VALUES
(nextval('customer.transfer_transfer_id_seq'),'68932868','68932777',300,'COMPLETE',NOW()),
(nextval('customer.transfer_transfer_id_seq'),'68932777','68932868',300,'PENDING',NOW()),
(nextval('customer.transfer_transfer_id_seq'),'68156222','68156345',1200,'PENDING',NOW());
"

psql -c "INSERT INTO customer.transaction_pending (pending_transactionid, pending_transactionref, pending_transferid, pending_paymentid, pending_loanid, pending_sensitiveflag, pending_approvalflag) VALUES
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,1,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,2,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,3,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'PAYMENT',NULL,4,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'TRANSFER',1,NULL,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'TRANSFER',2,NULL,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'TRANSFER',3,NULL,NULL,false,true),
(nextval('customer.transaction_pending_pending_transactionid_seq'),'LOAN',NULL,NULL,1,true,false);
"

psql -c "INSERT INTO customer.transaction (transaction_id, transaction_complete) VALUES
(nextval('customer.transaction_transaction_id_seq'),1),
(nextval('customer.transaction_transaction_id_seq'),2),
(nextval('customer.transaction_transaction_id_seq'),3),
(nextval('customer.transaction_transaction_id_seq'),4),
(nextval('customer.transaction_transaction_id_seq'),5),
(nextval('customer.transaction_transaction_id_seq'),6),
(nextval('customer.transaction_transaction_id_seq'),7);
"



# psql -c "INSERT INTO manager.approval (approval_id, approval_employee, approval_date, approval_flag) VALUES
# ();
# "

psql -c "INSERT INTO employee.employee_roles (employeerole_id, employeerole_name) VALUES
(nextval('employee.employee_roles_employeerole_id_seq'),'Teller'),
(nextval('employee.employee_roles_employeerole_id_seq'),'Manager');
"
   
psql -c "INSERT INTO employee.employee (employee_id, employee_sortcode, employee_username, employee_password, employee_role, employee_fname, employee_lname, employee_mobile, employee_email, employee_address, employee_postcode) VALUES
(nextval('employee.employee_employee_id_seq'),'309921','employeeuser','employeepass',1,'John','Doe','07495381704','johndoe@gmail.com','321 Regent Street','N127JE'),
(nextval('employee.employee_employee_id_seq'),'309921','manageruser','managerpass',2,'Jane','Doe','07495385874','janedoe@gmail.com','1 Market Street','W36PE');
"



# @@@@@@@@@@@@@@@@@@@@@@@@@ starting to test all procedures @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_bank1
export PGPASSWORD=test

# @@@@@@@@@@@@@@@@@@@@@@@@@ customer creation journey and applying for a loan @@@@@@@@@@@@@@@@@@@@@@@@@

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system user journey for back end 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system creating a customer 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo 

psql -c "select * from bank.create_customer
('mwarren','password123','Michael','Warren','07942173055',
'mwarren@gmail.com','109 Durban Rd W, Watford', 'WD187DT');"


echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system creating an account 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo 

psql -c "select * from bank.create_account
('mwarren', '68324767','309921',1,'my first personal bank account');"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system creating another account 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo 

psql -c "select * from bank.create_account
('mwarren', '68324676','309921',1,'my second personal bank account');"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system applying for a loan with customer account number 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.apply_loan('68324767',1)"


# @@@@@@@@@@@@@@@@@@@@@@@@@ employee and manager creation journey @@@@@@@@@@@@@@@@@@@@@@@@@

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
creating employees with the back end 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system creating an employee 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.create_employee('309921','abancu','password123',1,
'Andreea','Bancu','07495172653','abancu@gmail.com','14 Granville Rd, Watford',' WD180AH')"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system creating a manager 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.create_employee('309921','msmith','password123',2,
'Maria','Smith','07435225881','msmith@gmail.com','122 Anderson Rd, Watford',' WD225AD')"


# @@@@@@@@@@@@@@@@@@@@@@@@@ employee checking a customer's balances @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_employee1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
employee checking a customer's balances 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer 1 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_balances(1)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer 2 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_balances(2)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer 3 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_balances(3)"


# @@@@@@@@@@@@@@@@@@@@@@@@@ manager approving pending transactions @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_manager1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
manager checking loans 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_loans(3)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
manager approving loan 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from manager.approve_pending(2,9)"


# @@@@@@@@@@@@@@@@@@@@@@@@@ customer checking their accounts @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_customer1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer checking if their loan was approved 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer checking account balances 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_balances(3)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer checking loans 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_loans(3)"


# @@@@@@@@@@@@@@@@@@@@@@@@@ customer paying their loan back @@@@@@@@@@@@@@@@@@@@@@@@@


export PGUSER=user_bank1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer loan payments, payments and transfers 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer paying their loan back 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.pay_loan('68324767',500)"

# @@@@@@@@@@@@@@@@@@@@@@@@@ customer making a payment to an external bank then checking payments @@@@@@@@@@@@@@@@@@@@@@@@@


echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer making a payment to an external bank 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.make_payment('68324767','88316234','093165','Jane Anderson', 200)"


export PGUSER=user_customer1
export PGPASSWORD=test


echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer checking payments 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_payments(3)"



# @@@@@@@@@@@@@@@@@@@@@@@@@ customer making a transfer between their own accounts then checking transfers and balances @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_bank1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer making a transfer between their own accounts 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.make_transfer('68324767','68324676', 1000)"
psql -c "select * from bank.make_transfer('68324676','68324767', 200)"

export PGUSER=user_customer1
export PGPASSWORD=test


echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
customer checking transfers 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_transfers(3)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
customer checking balances 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_balances(3)"


# @@@@@@@@@@@@@@@@@@@@@@@@@ testing erroneous data and unwanted schema access @@@@@@@@@@@@@@@@@@@@@@@@@




# @@@@@@@@@@@@@@@@@@@@@@@@@ customer testing @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_customer1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
testing customer role
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
customer accessing functions in bank schema
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.make_transfer('68324767','68324676', 1000)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
customer accessing functions in employee schema
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from employee.check_employee(2)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
customer accessing functions in manager schema
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from manager.approve_pending(2,9)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
customer checking wrong customer details
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_customer(7)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
customer checking wrong account details
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_accounts(7)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
customer checking wrong balance details
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_balances(7)"


# @@@@@@@@@@@@@@@@@@@@@@@@@ employee testing @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_employee1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
testing employee role
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
employee accessing functions in bank schema
(has access to bank schema as bank.branch_sortcode attribute is needed;
but does not have access to updating any tables)
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.make_transfer('68324767','68324676', 1000)"


echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
employee accessing functions in manager schema
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from manager.approve_pending(2,9)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
employee checking wrong employee details
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from employee.check_employee(7)"

# @@@@@@@@@@@@@@@@@@@@@@@@@ manager testing @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_manager1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
testing manager role
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
manager accessing functions in bank schema 
(has access to bank schema as bank.branch_sortcode attribute is needed;
but does not have access to updating any tables)
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.make_transfer('68324767','68324676', 1000)"


echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
manager uses wrong employee details to approve transaction
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from manager.approve_pending(1,8)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
manager uses non-existent transaction details to approve transaction
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from manager.approve_pending(2,21)"

# @@@@@@@@@@@@@@@@@@@@@@@@@ bank testing @@@@@@@@@@@@@@@@@@@@@@@@@

export PGUSER=user_bank1
export PGPASSWORD=test

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
testing bank 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
bank system pays loan with negative money
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.pay_loan('68324767',-100000)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
bank system pays loan with more money than available
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.pay_loan('68324767',100000)"

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
bank system pays to the wrong account
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.pay_loan('12345678',11000)"

echo
echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
testing paying to a pending loan
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank system applying for a loan with customer account number 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.apply_loan('68932777',2)"



echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@ 
bank checking loans 
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from customer.check_loans(1)"


echo && echo "
@@@@@@@@@@@@@@@@@@@@@@@@@
bank system tries to pay to a pending loan
@@@@@@@@@@@@@@@@@@@@@@@@@"
echo

psql -c "select * from bank.pay_loan('68932777',50)"