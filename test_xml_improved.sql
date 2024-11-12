-- Conectar como usuario HR
CONNECT hr/Oracle123#

-- Configurar el formato de salida para XML
SET LINESIZE 1000
SET LONG 1000000
SET PAGESIZE 0
SET TRIM ON
SET WRAP ON
SET LONGCHUNKSIZE 1000000
SET HEADING OFF
SET FEEDBACK OFF

-- Consulta SQL combinada
PROMPT *** Consulta SQL Combinada ***
SET HEADING ON
SET FEEDBACK ON
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

-- Consulta SQL/XML con mejor formato
PROMPT *** Consulta SQL/XML ***
SET HEADING OFF
SET FEEDBACK OFF
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

-- Crear esquema XML en la base de datos
PROMPT *** Creando esquema XML ***
SET FEEDBACK ON
DROP TABLE xml_schema_table PURGE;

CREATE TABLE xml_schema_table (
    schema_id NUMBER PRIMARY KEY,
    schema_doc XMLTYPE
);

INSERT INTO xml_schema_table VALUES (
1,
XMLTYPE('<?xml version="1.0" encoding="UTF-8"?>
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
</xs:schema>'));

-- Verificar el esquema XML almacenado
PROMPT *** Verificando esquema XML almacenado ***
SET HEADING OFF
SET FEEDBACK OFF
SELECT XMLSERIALIZE(DOCUMENT schema_doc AS CLOB INDENT SIZE = 2) as schema_content
FROM xml_schema_table;

-- Insertar datos XML válidos
PROMPT *** Insertando datos XML válidos ***
SET FEEDBACK ON
CREATE TABLE employee_xml_data (
    doc_id NUMBER PRIMARY KEY,
    xml_data XMLTYPE
);

INSERT INTO employee_xml_data VALUES (
1,
XMLTYPE('<?xml version="1.0" encoding="UTF-8"?>
<employees>
    <employee>
        <employee_id>999</employee_id>
        <first_name>John</first_name>
        <last_name>Doe</last_name>
        <department_name>IT</department_name>
        <job_title>Developer</job_title>
    </employee>
</employees>'));

-- Intentar insertar datos XML inválidos
PROMPT *** Intentando insertar datos XML inválidos ***
INSERT INTO employee_xml_data VALUES (
2,
XMLTYPE('<?xml version="1.0" encoding="UTF-8"?>
<employees>
    <employee>
        <employee_id>ABC</employee_id>
        <first_name>Invalid</first_name>
        <last_name>Data</last_name>
        <department_name>Test</department_name>
    </employee>
</employees>'));

-- Mostrar datos XML almacenados
PROMPT *** Mostrando datos XML almacenados ***
SET HEADING OFF
SET FEEDBACK OFF
SELECT XMLSERIALIZE(DOCUMENT xml_data AS CLOB INDENT SIZE = 2) as xml_content
FROM employee_xml_data;

EXIT;
