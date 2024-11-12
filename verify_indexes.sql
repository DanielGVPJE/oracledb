-- Conectar como usuario HR
CONNECT hr/Oracle123#

-- Mostrar todos los índices y sus columnas
SELECT i.table_name, 
       i.index_name, 
       i.index_type, 
       i.uniqueness,
       LISTAGG(ic.column_name, ',') WITHIN GROUP (ORDER BY ic.column_position) as indexed_columns
FROM user_indexes i
JOIN user_ind_columns ic ON i.index_name = ic.index_name
WHERE i.table_name IN ('EMPLOYEES', 'DEPARTMENTS')
GROUP BY i.table_name, i.index_name, i.index_type, i.uniqueness
ORDER BY i.table_name, i.index_name;

EXIT;
