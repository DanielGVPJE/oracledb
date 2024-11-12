-- Ejercicio 2.7: Operaciones con departments2
-- Conectar como usuario HR
CONNECT hr/Oracle123#

PROMPT *** 2.7.1 Crear duplicado de departments ***
CREATE TABLE departments2 AS SELECT * FROM departments;

PROMPT *** 2.7.2 Insertar tres tuplas ***
INSERT INTO departments2 VALUES (280, 'Data Science', NULL, 1700);
INSERT INTO departments2 VALUES (290, 'AI Research', NULL, 1800);
INSERT INTO departments2 VALUES (300, 'Innovation Lab', NULL, 1900);

PROMPT *** 2.7.3 Cerrar y reconectar sesión ***
DISCONNECT
CONNECT hr/Oracle123#

PROMPT *** 2.7.4 Consultar departments2 ***
SELECT * FROM departments2 ORDER BY department_id;

PROMPT *** 2.7.5 Bloque anónimo con transacción ***
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando transacción...');
    
    -- Insertar nuevo departamento
    INSERT INTO departments2 VALUES (310, 'Digital Marketing', NULL, 1700);
    
    -- Actualizar departamento existente
    UPDATE departments2 SET location_id = 2000 
    WHERE department_id = 290;
    
    -- Confirmar transacción
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transacción completada exitosamente.');
EXCEPTION
    WHEN OTHERS THEN
        -- Deshacer en caso de error
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT *** 2.7.6 Ejemplo de deshacer transacción ***
-- Iniciar transacción
INSERT INTO departments2 VALUES (320, 'Test Department', NULL, 1700);

-- Verificar la inserción
SELECT department_id, department_name FROM departments2 WHERE department_id = 320;

-- Deshacer la transacción
ROLLBACK;

-- Verificar que se deshizo
SELECT department_id, department_name FROM departments2 WHERE department_id = 320;

EXIT;
