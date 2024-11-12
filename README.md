# Índices y Restricciones en Bases de Datos Oracle

## Configuración del Entorno

### Requisitos Previos
- Docker
- Docker Compose

### Instrucciones de Instalación y Ejecución

1. Asegúrese de estar en el directorio del proyecto:
```bash
cd /app/oracledb
```

2. Inicie el contenedor de Oracle:
```bash
docker-compose up -d
```

3. El contenedor tardará aproximadamente 5-10 minutos en inicializarse completamente. Puede verificar el estado con:
```bash
docker-compose logs -f
```

4. Detalles de conexión:
- Hostname: localhost
- Puerto: 1521
- SID: XE
- PDB: XEPDB1
- Usuario Sistema: sys as sysdba
- Contraseña Sistema: Oracle123#
- Usuario HR: hr
- Contraseña HR: Oracle123#

## Ejercicio 1: Preguntas Teóricas

### 1.1 ¿Cuándo es preferible utilizar un índice denso en vez de uno disperso?

Un índice denso es preferible en las siguientes situaciones:

- Cuando se requiere acceso directo y rápido a cada registro individual
- En casos donde las búsquedas frecuentes necesitan alta precisión
- Cuando los datos tienen una distribución no uniforme o alta variabilidad
- Cuando el espacio de almacenamiento no es una limitación crítica
- Para tablas con actualizaciones frecuentes donde la precisión en la localización es crucial

Los índices densos son más eficientes para búsquedas precisas ya que mantienen una entrada por cada valor de la clave en el archivo de datos, permitiendo acceso directo sin necesidad de búsqueda secuencial adicional.

### 1.2 ¿Por qué no deberían mantenerse índices en varias claves de búsqueda?

Razones principales:

1. Overhead de almacenamiento:
   - Cada índice consume espacio adicional en disco
   - El espacio requerido puede ser significativo en tablas grandes

2. Impacto en el rendimiento de escritura:
   - Cada operación INSERT, UPDATE o DELETE debe actualizar todos los índices
   - Mayor tiempo de procesamiento por operación
   - Incremento en la carga del sistema

3. Mantenimiento y complejidad:
   - Mayor complejidad en la administración de la base de datos
   - Necesidad de monitoreo y optimización de múltiples estructuras
   - Incremento en el tiempo de mantenimiento

4. Recursos del sistema:
   - Mayor uso de memoria RAM
   - Incremento en la utilización de CPU
   - Posible degradación del rendimiento general

5. Optimización de consultas:
   - El optimizador debe evaluar más opciones de acceso
   - Puede llevar a planes de ejecución subóptimos

6. Fragmentación:
   - Mayor probabilidad de fragmentación de índices
   - Necesidad más frecuente de reconstrucción de índices

### 1.3 ¿Es posible tener dos índices primarios en la misma relación para dos claves de búsqueda diferentes?

No, no es posible tener dos índices primarios en la misma relación por las siguientes razones:

1. Definición conceptual:
   - Un índice primario está basado en la clave primaria de la tabla
   - La clave primaria es única por definición en el modelo relacional
   - Solo puede existir una clave primaria por tabla

2. Restricciones de integridad:
   - La clave primaria garantiza la unicidad de los registros
   - Tener dos claves primarias violaría los principios de normalización
   - Podría crear ambigüedad en la identificación única de registros

3. Implementación física:
   - La base de datos organiza físicamente los datos basándose en la clave primaria
   - No es posible organizar físicamente los datos de dos formas diferentes simultáneamente

## Ejercicio 2: Práctica con Oracle HR

### 2.1 Iniciar sesión con el usuario hr

**Archivo**: create_hr.sql

```sql
-- Permitir la creación de usuarios locales en Oracle 21c
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

-- Crear y configurar usuario HR
CREATE USER hr IDENTIFIED BY Oracle123#
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- Otorgar privilegios necesarios
GRANT CREATE SESSION TO hr;
GRANT CREATE TABLE TO hr;
GRANT CREATE VIEW TO hr;
GRANT CREATE SEQUENCE TO hr;
GRANT CREATE PROCEDURE TO hr;
GRANT CREATE TRIGGER TO hr;
```

**Error encontrado**: ORA-65096: invalid common user or role name
**Solución**: Se agregó `ALTER SESSION SET "_ORACLE_SCRIPT"=true;` para permitir la creación de usuarios locales en Oracle 21c.

### 2.2 Consultar los índices disponibles

**Archivo**: check_indexes.sql

```sql
SELECT table_name, index_name, index_type, uniqueness
FROM user_indexes
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS')
ORDER BY table_name, index_name;
```

Resultados:
1. Tabla DEPARTMENTS:
   - SYS_C008315: Índice único (PRIMARY KEY) sobre DEPARTMENT_ID

2. Tabla EMPLOYEES:
   - SYS_C008322: Índice único (PRIMARY KEY) sobre EMPLOYEE_ID

### 2.3 Justificación de nuevos índices

**Archivo**: create_indexes.sql

Se crearon dos nuevos índices:

1. EMP_LAST_NAME_IDX:
```sql
CREATE INDEX emp_last_name_idx ON employees(last_name);
```
Justificación: Optimiza búsquedas por apellido, muy comunes en sistemas de RRHH para búsqueda de empleados.

2. EMP_DEPT_JOB_IDX:
```sql
CREATE INDEX emp_dept_job_idx ON employees(department_id, job_id);
```
Justificación: Mejora el rendimiento de consultas que filtran por departamento y cargo, común en reportes organizacionales.

### 2.4 Desactivar restricciones

**Archivo**: test_constraints.sql

```sql
ALTER TABLE employees DISABLE CONSTRAINT emp_dept_fk;
ALTER TABLE departments DISABLE CONSTRAINT dept_mgr_fk;
```

Resultado: Las restricciones se desactivaron exitosamente, permitiendo operaciones que normalmente violarían la integridad referencial.

### 2.5 Insertar tuplas que no cumplan las restricciones

**Archivo**: test_constraints.sql

```sql
-- Insertar empleado con departamento inexistente
INSERT INTO employees (employee_id, first_name, last_name, email, 
                      hire_date, job_id, department_id)
VALUES (999, 'Test', 'User', 'TUSER', 
        SYSDATE, 'AD_VP', 999);

-- Insertar departamento con manager_id inválido
INSERT INTO departments (department_id, department_name, manager_id)
VALUES (999, 'Test Department', 999);
```

Resultado: Las inserciones fueron exitosas a pesar de violar las restricciones de integridad referencial.

### 2.6 Reactivar restricciones

**Archivo**: test_constraints.sql

```sql
ALTER TABLE employees ENABLE CONSTRAINT emp_dept_fk;
ALTER TABLE departments ENABLE CONSTRAINT dept_mgr_fk;
```

Resultado: Las restricciones se reactivaron exitosamente, manteniendo los datos que violan la integridad referencial.

### 2.7 Operaciones con departments2

**Archivo**: test_departments2.sql

#### 2.7.1 Crear duplicado de departments
```sql
CREATE TABLE departments2 AS SELECT * FROM departments;
```
Resultado: Tabla creada exitosamente con todos los datos de departments.

#### 2.7.2 Insertar tres tuplas
```sql
INSERT INTO departments2 VALUES (280, 'Data Science', NULL, 1700);
INSERT INTO departments2 VALUES (290, 'AI Research', NULL, 1800);
INSERT INTO departments2 VALUES (300, 'Innovation Lab', NULL, 1900);
```
Resultado: Tres departamentos nuevos insertados correctamente.

#### 2.7.3 Cerrar sesión y 2.7.4 Consultar departments2
```sql
DISCONNECT
CONNECT hr/Oracle123#
SELECT * FROM departments2 ORDER BY department_id;
```
Resultado: La tabla permanece accesible después de reconectar, mostrando todos los departamentos.

#### 2.7.5 Bloque anónimo con transacción
```sql
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando transacción...');
    INSERT INTO departments2 VALUES (310, 'Digital Marketing', NULL, 1700);
    UPDATE departments2 SET location_id = 2000 WHERE department_id = 290;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transacción completada exitosamente.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
```
Resultado: Transacción ejecutada exitosamente, realizando inserción y actualización.

#### 2.7.6 Deshacer una transacción
```sql
-- Iniciar transacción
INSERT INTO departments2 VALUES (320, 'Test Department', NULL, 1700);

-- Verificar la inserción
SELECT department_id, department_name FROM departments2 WHERE department_id = 320;

-- Deshacer la transacción
ROLLBACK;

-- Verificar que se deshizo
SELECT department_id, department_name FROM departments2 WHERE department_id = 320;
```
Resultado: La inserción se deshizo correctamente con ROLLBACK, demostrando que no quedó rastro de la transacción.

### 2.8 Consulta SQL combinada

**Archivo**: test_xml_improved.sql

```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    j.job_title
FROM 
    employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN jobs j ON e.job_id = j.job_id
WHERE 
    d.location_id = 1700
ORDER BY 
    e.last_name;
```

### 2.9 Esquema XML y Validación

**Archivo**: test_xml_improved.sql

1. Esquema XML:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="employees">
        <xs:complexType>
            <xs:sequence>
                <xs:element name="employee" maxOccurs="unbounded">
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element name="employee_id" type="xs:integer"/>
                            <xs:element name="first_name" type="xs:string"/>
                            <xs:element name="last_name" type="xs:string"/>
                            <xs:element name="department_name" type="xs:string"/>
                            <xs:element name="job_title" type="xs:string"/>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
</xs:schema>
```

2. Consulta SQL/XML:
```sql
SELECT XMLSERIALIZE(
    DOCUMENT
    XMLELEMENT("employees",
        XMLAGG(
            XMLELEMENT("employee",
                XMLELEMENT("employee_id", e.employee_id),
                XMLELEMENT("first_name", e.first_name),
                XMLELEMENT("last_name", e.last_name),
                XMLELEMENT("department_name", d.department_name),
                XMLELEMENT("job_title", j.job_title)
            )
        )
    )
    AS CLOB INDENT SIZE = 2) as xml_output
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id;
```

3. Registro del esquema e inserción de datos:
```sql
-- Crear tabla para el esquema XML
CREATE TABLE xml_schema_table (
    schema_id NUMBER PRIMARY KEY,
    schema_doc XMLTYPE
);

-- Registrar el esquema
INSERT INTO xml_schema_table VALUES (1, XMLTYPE('... esquema XML ...'));

-- Insertar datos válidos
INSERT INTO employee_xml_data VALUES (
1,
XMLTYPE('
<employees>
    <employee>
        <employee_id>999</employee_id>
        <first_name>John</first_name>
        <last_name>Doe</last_name>
        <department_name>IT</department_name>
        <job_title>Developer</job_title>
    </employee>
</employees>'));

-- Insertar datos inválidos
INSERT INTO employee_xml_data VALUES (
2,
XMLTYPE('
<employees>
    <employee>
        <employee_id>ABC</employee_id>
        <first_name>Invalid</first_name>
        <last_name>Data</last_name>
        <department_name>Test</department_name>
    </employee>
</employees>'));
```

**Error encontrado**: La inserción de datos XML inválidos fue permitida
**Solución propuesta**: Implementar validación XML a nivel de base de datos usando XMLSchema para garantizar la integridad de los datos.

## Scripts Disponibles

1. create_hr.sql: Crea y configura el esquema HR
2. check_indexes.sql: Verifica índices existentes
3. create_indexes.sql: Crea nuevos índices
4. test_constraints.sql: Prueba restricciones
5. test_departments2.sql: Operaciones con departments2
6. test_xml_improved.sql: Consultas SQL/XML y validación

## Errores Encontrados y Soluciones

1. Error: ORA-65096: invalid common user or role name
   - Causa: Restricción de Oracle 21c para usuarios locales
   - Solución: Agregar ALTER SESSION SET "_ORACLE_SCRIPT"=true;

2. Error: No se podía acceder a HR inicialmente
   - Causa: Esquema HR no viene preinstalado en Oracle 21c XE
   - Solución: Script create_hr.sql para crear y configurar el esquema

3. Error: Inserción de XML inválido permitida
   - Causa: Falta de validación estricta XML
   - Solución propuesta: Implementar XMLSchema validation

## Notas Importantes

1. En un entorno de producción:
   - Usar contraseñas más seguras
   - Implementar políticas de respaldo
   - Monitorear el rendimiento de los índices
   - Mantener las restricciones activas
   - Validar estrictamente los documentos XML

2. Para pruebas y desarrollo:
   - Documentar desactivación de restricciones
   - Restaurar restricciones después de pruebas
   - Mantener registro de modificaciones
   - Usar herramientas de validación XML externas
