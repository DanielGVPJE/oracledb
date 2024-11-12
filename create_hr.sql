-- Allow local users
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

-- Create HR user
CREATE USER hr IDENTIFIED BY Oracle123#
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- Grant necessary privileges
GRANT CREATE SESSION TO hr;
GRANT CREATE TABLE TO hr;
GRANT CREATE VIEW TO hr;
GRANT CREATE SEQUENCE TO hr;
GRANT CREATE PROCEDURE TO hr;
GRANT CREATE TRIGGER TO hr;

-- Create basic HR schema tables
CREATE TABLE hr.departments (
    department_id    NUMBER(4) PRIMARY KEY,
    department_name  VARCHAR2(30) NOT NULL,
    manager_id       NUMBER(6),
    location_id      NUMBER(4)
);

CREATE TABLE hr.jobs (
    job_id         VARCHAR2(10) PRIMARY KEY,
    job_title      VARCHAR2(35) NOT NULL,
    min_salary     NUMBER(6),
    max_salary     NUMBER(6)
);

CREATE TABLE hr.employees (
    employee_id    NUMBER(6) PRIMARY KEY,
    first_name     VARCHAR2(20),
    last_name      VARCHAR2(25) NOT NULL,
    email          VARCHAR2(25) NOT NULL,
    phone_number   VARCHAR2(20),
    hire_date      DATE NOT NULL,
    job_id         VARCHAR2(10) NOT NULL,
    salary         NUMBER(8,2),
    commission_pct NUMBER(2,2),
    manager_id     NUMBER(6),
    department_id  NUMBER(4),
    CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES hr.departments(department_id),
    CONSTRAINT emp_job_fk FOREIGN KEY (job_id) REFERENCES hr.jobs(job_id),
    CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES hr.employees(employee_id)
);

ALTER TABLE hr.departments ADD CONSTRAINT dept_mgr_fk 
    FOREIGN KEY (manager_id) REFERENCES hr.employees (employee_id);

-- Insert sample data
INSERT INTO hr.departments VALUES (10, 'Administration', NULL, 1700);
INSERT INTO hr.departments VALUES (20, 'Marketing', NULL, 1800);
INSERT INTO hr.departments VALUES (30, 'Purchasing', NULL, 1700);

INSERT INTO hr.jobs VALUES ('AD_PRES', 'President', 20080, 40000);
INSERT INTO hr.jobs VALUES ('AD_VP', 'Vice President', 15000, 30000);
INSERT INTO hr.jobs VALUES ('AD_ASST', 'Administration Assistant', 3000, 6000);

INSERT INTO hr.employees VALUES (100, 'Steven', 'King', 'SKING', '515.123.4567', TO_DATE('17-JUN-2003', 'dd-MON-yyyy'), 'AD_PRES', 24000, NULL, NULL, 10);
INSERT INTO hr.employees VALUES (101, 'Neena', 'Kochhar', 'NKOCHHAR', '515.123.4568', TO_DATE('21-SEP-2005', 'dd-MON-yyyy'), 'AD_VP', 17000, NULL, 100, 20);
INSERT INTO hr.employees VALUES (102, 'Lex', 'De Haan', 'LDEHAAN', '515.123.4569', TO_DATE('13-JAN-2001', 'dd-MON-yyyy'), 'AD_VP', 17000, NULL, 100, 30);

-- Update department managers
UPDATE hr.departments SET manager_id = 100 WHERE department_id = 10;
UPDATE hr.departments SET manager_id = 101 WHERE department_id = 20;
UPDATE hr.departments SET manager_id = 102 WHERE department_id = 30;

COMMIT;

SELECT 'HR schema created successfully' AS status FROM dual;
EXIT;
