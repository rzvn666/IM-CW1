--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.account (
    account_number character(8) NOT NULL,
    sort_code character(6) NOT NULL,
    customer_id integer NOT NULL,
    type_id integer NOT NULL,
    balance integer NOT NULL,
    name character varying(255) NOT NULL,
    iban character varying(34) NOT NULL,
    open_date date NOT NULL
);


ALTER TABLE public.account OWNER TO bank;

--
-- Name: account_types; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.account_types (
    type_id integer NOT NULL,
    type_name character varying(100) NOT NULL
);


ALTER TABLE public.account_types OWNER TO bank;

--
-- Name: account_types_type_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.account_types_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_types_type_id_seq OWNER TO bank;

--
-- Name: account_types_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.account_types_type_id_seq OWNED BY public.account_types.type_id;


--
-- Name: approval; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.approval (
    approval_id integer NOT NULL,
    employee_id integer NOT NULL,
    date date NOT NULL,
    approval_flag character(1) NOT NULL
);


ALTER TABLE public.approval OWNER TO bank;

--
-- Name: approval_approval_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.approval_approval_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.approval_approval_id_seq OWNER TO bank;

--
-- Name: approval_approval_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.approval_approval_id_seq OWNED BY public.approval.approval_id;


--
-- Name: bank; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.bank (
    bank_id integer NOT NULL,
    name character varying(50) NOT NULL,
    bic character(11) NOT NULL,
    address character varying(255) NOT NULL,
    postcode character varying(10) NOT NULL,
    country character varying(60) NOT NULL
);


ALTER TABLE public.bank OWNER TO bank;

--
-- Name: bank_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.bank_bank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bank_bank_id_seq OWNER TO bank;

--
-- Name: bank_bank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.bank_bank_id_seq OWNED BY public.bank.bank_id;


--
-- Name: branch; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.branch (
    sort_code character(6) NOT NULL,
    bank_id integer NOT NULL,
    name character varying(50) NOT NULL,
    address character varying(255) NOT NULL,
    postcode character varying(10) NOT NULL,
    country character varying(60) NOT NULL
);


ALTER TABLE public.branch OWNER TO bank;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.customer (
    customer_id integer NOT NULL,
    username character varying(30) NOT NULL,
    password character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    mobile_number character(11) NOT NULL,
    email character varying(50) NOT NULL,
    address character varying(255) NOT NULL,
    postcode character varying(10) NOT NULL
);


ALTER TABLE public.customer OWNER TO bank;

--
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.customer_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customer_customer_id_seq OWNER TO bank;

--
-- Name: customer_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.customer_customer_id_seq OWNED BY public.customer.customer_id;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    sort_code character(6) NOT NULL,
    role character varying(50) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    mobile_number character(11) NOT NULL,
    email character varying(50) NOT NULL,
    address character varying(255) NOT NULL,
    postcode character varying(10) NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL
);


ALTER TABLE public.employee OWNER TO bank;

--
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_employee_id_seq OWNER TO bank;

--
-- Name: employee_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.employee_employee_id_seq OWNED BY public.employee.employee_id;


--
-- Name: loan; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.loan (
    loan_id integer NOT NULL,
    account_number character(8) NOT NULL,
    amount integer NOT NULL,
    interest_rate real NOT NULL,
    apr real NOT NULL,
    term integer NOT NULL,
    transaction_id integer NOT NULL
);


ALTER TABLE public.loan OWNER TO bank;

--
-- Name: loan_loan_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.loan_loan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.loan_loan_id_seq OWNER TO bank;

--
-- Name: loan_loan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.loan_loan_id_seq OWNED BY public.loan.loan_id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.payment (
    payment_id integer NOT NULL,
    transaction_id integer NOT NULL,
    account_number character(8) NOT NULL,
    receiver_accnum character(8) NOT NULL,
    receiver_sortcode character(6) NOT NULL,
    receiver_name character varying(255) NOT NULL,
    amount integer NOT NULL,
    date date NOT NULL
);


ALTER TABLE public.payment OWNER TO bank;

--
-- Name: payment_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.payment_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_payment_id_seq OWNER TO bank;

--
-- Name: payment_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.payment_payment_id_seq OWNED BY public.payment.payment_id;


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.transaction (
    transaction_id integer NOT NULL,
    sensitive_flag character(1) NOT NULL,
    approval_id integer NOT NULL,
    transfer_id integer,
    payment_id integer,
    loan_id integer
);


ALTER TABLE public.transaction OWNER TO bank;

--
-- Name: transaction_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.transaction_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transaction_transaction_id_seq OWNER TO bank;

--
-- Name: transaction_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.transaction_transaction_id_seq OWNED BY public.transaction.transaction_id;


--
-- Name: transfer; Type: TABLE; Schema: public; Owner: bank
--

CREATE TABLE public.transfer (
    transfer_id integer NOT NULL,
    transaction_id integer NOT NULL,
    account_number character(8) NOT NULL,
    receiver_accnum character(8) NOT NULL,
    amount integer NOT NULL,
    date date NOT NULL
);


ALTER TABLE public.transfer OWNER TO bank;

--
-- Name: transfer_transfer_id_seq; Type: SEQUENCE; Schema: public; Owner: bank
--

CREATE SEQUENCE public.transfer_transfer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfer_transfer_id_seq OWNER TO bank;

--
-- Name: transfer_transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank
--

ALTER SEQUENCE public.transfer_transfer_id_seq OWNED BY public.transfer.transfer_id;


--
-- Name: account_types type_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account_types ALTER COLUMN type_id SET DEFAULT nextval('public.account_types_type_id_seq'::regclass);


--
-- Name: approval approval_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.approval ALTER COLUMN approval_id SET DEFAULT nextval('public.approval_approval_id_seq'::regclass);


--
-- Name: bank bank_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.bank ALTER COLUMN bank_id SET DEFAULT nextval('public.bank_bank_id_seq'::regclass);


--
-- Name: customer customer_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.customer ALTER COLUMN customer_id SET DEFAULT nextval('public.customer_customer_id_seq'::regclass);


--
-- Name: employee employee_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.employee ALTER COLUMN employee_id SET DEFAULT nextval('public.employee_employee_id_seq'::regclass);


--
-- Name: loan loan_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.loan ALTER COLUMN loan_id SET DEFAULT nextval('public.loan_loan_id_seq'::regclass);


--
-- Name: payment payment_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.payment ALTER COLUMN payment_id SET DEFAULT nextval('public.payment_payment_id_seq'::regclass);


--
-- Name: transaction transaction_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction ALTER COLUMN transaction_id SET DEFAULT nextval('public.transaction_transaction_id_seq'::regclass);


--
-- Name: transfer transfer_id; Type: DEFAULT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transfer ALTER COLUMN transfer_id SET DEFAULT nextval('public.transfer_transfer_id_seq'::regclass);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.account (account_number, sort_code, customer_id, type_id, balance, name, iban, open_date) FROM stdin;
68932868	309921	1	1	0	bank account	GB73LOYD30992168932868	2023-01-16
\.


--
-- Data for Name: account_types; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.account_types (type_id, type_name) FROM stdin;
1	Current Account
\.


--
-- Data for Name: approval; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.approval (approval_id, employee_id, date, approval_flag) FROM stdin;
\.


--
-- Data for Name: bank; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.bank (bank_id, name, bic, address, postcode, country) FROM stdin;
1	LLOYDS PANK PLC	LOYDGB2LXXX	25 MONUMENT STREET	EC3R8BQ	United Kingdom
\.


--
-- Data for Name: branch; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.branch (sort_code, bank_id, name, address, postcode, country) FROM stdin;
309921	1	Lloyds Bank Watford	Po Box 1000	BX11LT	United Kingdom
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.customer (customer_id, username, password, first_name, last_name, mobile_number, email, address, postcode) FROM stdin;
1	testuser	testuser	Andrew	Ferguson	7941083085 	andrewferguson@gmail.com	10 Abbey Close, Coventry	CV56HN
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.employee (employee_id, sort_code, role, first_name, last_name, mobile_number, email, address, postcode, username, password) FROM stdin;
1	309921	employee	John	Doe	07495381704	johndoe@gmail.com	321 Regent Street	N127JE	employeeuser	employeepass
2	309921	manager	Jane	Doe	07495385874	janedoe@gmail.com	1 Market Street	W36PE	manageruser	managerpass
\.


--
-- Data for Name: loan; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.loan (loan_id, account_number, amount, interest_rate, apr, term, transaction_id) FROM stdin;
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.payment (payment_id, transaction_id, account_number, receiver_accnum, receiver_sortcode, receiver_name, amount, date) FROM stdin;
\.


--
-- Data for Name: transaction; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.transaction (transaction_id, sensitive_flag, approval_id, transfer_id, payment_id, loan_id) FROM stdin;
\.


--
-- Data for Name: transfer; Type: TABLE DATA; Schema: public; Owner: bank
--

COPY public.transfer (transfer_id, transaction_id, account_number, receiver_accnum, amount, date) FROM stdin;
\.


--
-- Name: account_types_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.account_types_type_id_seq', 1, true);


--
-- Name: approval_approval_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.approval_approval_id_seq', 1, false);


--
-- Name: bank_bank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.bank_bank_id_seq', 1, true);


--
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.customer_customer_id_seq', 4, true);


--
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.employee_employee_id_seq', 1, false);


--
-- Name: loan_loan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.loan_loan_id_seq', 1, false);


--
-- Name: payment_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.payment_payment_id_seq', 1, false);


--
-- Name: transaction_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.transaction_transaction_id_seq', 1, false);


--
-- Name: transfer_transfer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bank
--

SELECT pg_catalog.setval('public.transfer_transfer_id_seq', 1, false);


--
-- Name: account account_account_number_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_account_number_key UNIQUE (account_number);


--
-- Name: account account_iban_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_iban_key UNIQUE (iban);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_number);


--
-- Name: account_types account_types_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account_types
    ADD CONSTRAINT account_types_pkey PRIMARY KEY (type_id);


--
-- Name: approval approval_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.approval
    ADD CONSTRAINT approval_pkey PRIMARY KEY (approval_id);


--
-- Name: bank bank_bic_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.bank
    ADD CONSTRAINT bank_bic_key UNIQUE (bic);


--
-- Name: bank bank_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.bank
    ADD CONSTRAINT bank_pkey PRIMARY KEY (bank_id);


--
-- Name: branch branch_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (sort_code);


--
-- Name: customer customer_email_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_email_key UNIQUE (email);


--
-- Name: customer customer_mobile_number_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_mobile_number_key UNIQUE (mobile_number);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: customer customer_username_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_username_key UNIQUE (username);


--
-- Name: employee employee_email_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_email_key UNIQUE (email);


--
-- Name: employee employee_mobile_number_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_mobile_number_key UNIQUE (mobile_number);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- Name: employee employee_username_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_username_key UNIQUE (username);


--
-- Name: loan loan_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.loan
    ADD CONSTRAINT loan_pkey PRIMARY KEY (loan_id);


--
-- Name: loan loan_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.loan
    ADD CONSTRAINT loan_transaction_id_key UNIQUE (transaction_id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (payment_id);


--
-- Name: payment payment_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_transaction_id_key UNIQUE (transaction_id);


--
-- Name: transaction transaction_loan_id_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_loan_id_key UNIQUE (loan_id);


--
-- Name: transaction transaction_payment_id_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_payment_id_key UNIQUE (payment_id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (transaction_id);


--
-- Name: transaction transaction_transfer_id_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_transfer_id_key UNIQUE (transfer_id);


--
-- Name: transfer transfer_pkey; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_pkey PRIMARY KEY (transfer_id);


--
-- Name: transfer transfer_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_transaction_id_key UNIQUE (transaction_id);


--
-- Name: account account_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);


--
-- Name: account account_sort_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_sort_code_fkey FOREIGN KEY (sort_code) REFERENCES public.branch(sort_code);


--
-- Name: account account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.account_types(type_id);


--
-- Name: approval approval_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.approval
    ADD CONSTRAINT approval_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: branch branch_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.bank(bank_id);


--
-- Name: employee employee_sort_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_sort_code_fkey FOREIGN KEY (sort_code) REFERENCES public.branch(sort_code);


--
-- Name: loan loan_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.loan
    ADD CONSTRAINT loan_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account(account_number);


--
-- Name: loan loan_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.loan
    ADD CONSTRAINT loan_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transaction(transaction_id);


--
-- Name: payment payment_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account(account_number);


--
-- Name: payment payment_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transaction(transaction_id);


--
-- Name: transaction transaction_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_approval_id_fkey FOREIGN KEY (approval_id) REFERENCES public.approval(approval_id);


--
-- Name: transaction transaction_loan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_loan_id_fkey FOREIGN KEY (loan_id) REFERENCES public.loan(loan_id);


--
-- Name: transaction transaction_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payment(payment_id);


--
-- Name: transaction transaction_transfer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_transfer_id_fkey FOREIGN KEY (transfer_id) REFERENCES public.transfer(transfer_id);


--
-- Name: transfer transfer_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.account(account_number);


--
-- Name: transfer transfer_receiver_accnum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_receiver_accnum_fkey FOREIGN KEY (receiver_accnum) REFERENCES public.account(account_number);


--
-- Name: transfer transfer_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bank
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transaction(transaction_id);


--
-- PostgreSQL database dump complete
--

