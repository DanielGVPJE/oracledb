-- Conectar como usuario HR
CONNECT hr/Oracle123#

-- Crear índice para búsquedas por apellido
CREATE INDEX emp_last_name_idx ON employees(last_name);

-- Crear índice compuesto para búsquedas por departamento y cargo
CREATE INDEX emp_dept_job_idx ON employees(department_id, job_id);

-- Mostrar todos los índices después de la creación
SELECT table_name, index_name, index_type, uniqueness,
       LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_position) as indexed_columns
FROM user_indexes i
JOIN user_ind_columns ic ON i.index_name = ic.index_name
WHERE i.table_name IN ('EMPLOYEES', 'DEPARTMENTS')
GROUP BY table_name, index_name, index_type, uniqueness
ORDER BY table_name, index_name;

EXIT;
