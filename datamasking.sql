--Prepare database, table & roles--
Use role accountadmin;
Use database python_db;
use schema public;

CREATE OR REPLACE TABLE customers (
    id NUMBER,
    full_name VARCHAR,
    email VARCHAR,
    phone VARCHAR,
    spent NUMBER,
    create_date DATE DEFAULT CURRENT_DATE
);

. -- insert values in table --
insert into customers (id, full_name, email,phone,spent)
values
(1,'Lewiss MacDwyer','lmacdwyer0@un.org','262-665-9168',140),
(2,'Ty Pettingall','tpettingall1@mayoclinic.com','734-987-7120',254),
(3,'Marlee Spadazzi','mspadazzi2@txnews.com','867-946-3659',120),
(4,'Heywood Tearney','htearney3@patch.com','563-853-8192',1230),
(5,'Odilia Seti','oseti4@globo.com','730-451-8637',143),
(6,'Meggie Washtell','mwashtell5@rediff.com','568-896-6138',600);

select * from customers;

create or replace role analyst_masked;
create or replace role analyst_full;

grant usage on database python_db to role analyst_masked;
GRANT USAGE ON SCHEMA PYTHON_DB.PUBLIC TO ROLE ANALYST_MASKED;
GRANT SELECT ON TABLE PYTHON_DB.PUBLIC.customers TO ROLE ANALYST_MASKED;

GRANT USAGE ON DATABASE PYTHON_DB TO ROLE ANALYST_FULL;
GRANT USAGE ON SCHEMA PYTHON_DB.PUBLIC TO ROLE ANALYST_FULL;
GRANT SELECT ON TABLE PYTHON_DB.PUBLIC.CUSTOMERS TO ROLE ANALYST_FULL;

GRANT USAGE ON WAREHOUSE PYTHON_WH TO ROLE ANALYST_MASKED;
GRANT USAGE ON WAREHOUSE PYTHON_WH TO ROLE ANALYST_FULL;

GRANT ROLE ANALYST_MASKED TO USER SWATHIHA;
GRANT ROLE ANALYST_FULL TO USER SWATHIHA;

SHOW USERS;

--Create masking policy (show *** except ANALYST_FULL)--
CREATE OR REPLACE MASKING POLICY name_masking_policy
AS (val STRING)
RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() = 'ANALYST_FULL' THEN val
        ELSE '***'
    END;

--Apply masking policy on full_name--
--ALTER TABLE CUSTOMERS
--MODIFY COLUMN FULL_NAME
--SET MASKING POLICY NAME_MASKING_POLICY;

ALTER TABLE customers
MODIFY COLUMN full_name
SET MASKING POLICY name_masking_policy;

--Validate the result
🔹 As ANALYST_MASKED--
USE ROLE ANALYST_MASKED;
SELECT id, full_name FROM customers;

--Unset (remove) the masking policy--
ALTER TABLE CUSTOMERS
MODIFY COLUMN FULL_NAME
UNSET MASKING POLICY;

--Alter masking policy

Requirement: show only last 2 characters (example: ***er)--

CREATE OR REPLACE MASKING POLICY NAME_MASKING_POLICY
AS (VAL STRING)
RETURNS STRING ->
    CASE 
        WHEN CURRENT_ROLE() = 'ANALYST_FULL' THEN VAL
        ELSE '***' || RIGHT(VAL,2)
    END;    
--Apply the policy again & validate--
ALTER TABLE customers
MODIFY COLUMN full_name
SET MASKING POLICY name_masking_policy;

USE ROLE ANALYST_MASKED;
SELECT full_name FROM customers;

USE ROLE ANALYST_FULL;
SELECT full_name FROM customers;
