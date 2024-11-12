-- Conectar como usuario HR
CONNECT hr/Oracle123#

PROMPT *** Estado inicial de las restricciones ***
SELECT constraint_name, constraint_type, status 
FROM user_constraints 
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS');

PROMPT *** Desactivando restricciones ***
ALTER TABLE employees DISABLE CONSTRAINT emp_dept_fk;
ALTER TABLE departments DISABLE CONSTRAINT dept_mgr_fk;

PROMPT *** Estado después de desactivar ***
SELECT constraint_name, constraint_type, status 
FROM user_constraints 
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS');

PROMPT *** Intentando insertar datos que violan las restricciones ***
INSERT INTO employees (employee_id, first_name, last_name, email, 
                      hire_date, job_id, department_id)
VALUES (999, 'Test', 'User', 'TUSER', 
        SYSDATE, 'AD_VP', 999);

INSERT INTO departments (department_id, department_name, manager_id)
VALUES (999, 'Test Department', 999);

PROMPT *** Verificando las inserciones ***
SELECT employee_id, first_name, last_name, department_id 
FROM employees WHERE employee_id = 999;

SELECT department_id, department_name, manager_id 
FROM departments WHERE department_id = 999;

PROMPT *** Reactivando restricciones ***
ALTER TABLE employees ENABLE CONSTRAINT emp_dept_fk;
ALTER TABLE departments ENABLE CONSTRAINT dept_mgr_fk;

PROMPT *** Estado final de las restricciones ***
SELECT constraint_name, constraint_type, status 
FROM user_constraints 
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS');

EXIT;
