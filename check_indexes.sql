-- Conectar como usuario HR
CONNECT hr/Oracle123#

-- Mostrar índices de EMPLOYEES y DEPARTMENTS
SELECT table_name, index_name, index_type, uniqueness
FROM user_indexes
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS')
ORDER BY table_name, index_name;

-- Mostrar detalles de las columnas indexadas
SELECT i.table_name, i.index_name, i.index_type, i.uniqueness,
       ic.column_name, ic.column_position
FROM user_indexes i
JOIN user_ind_columns ic ON i.index_name = ic.index_name
WHERE i.table_name IN ('EMPLOYEES', 'DEPARTMENTS')
ORDER BY i.table_name, i.index_name, ic.column_position;

EXIT;
