-- Conectar como usuario HR
CONNECT hr/Oracle123#

-- Consulta SQL combinada
PROMPT *** Consulta SQL Combinada ***
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

-- Consulta SQL/XML
PROMPT *** Consulta SQL/XML ***
SELECT XMLELEMENT("employees",
    XMLAGG(
        XMLELEMENT("employee",
            XMLELEMENT("employee_id", e.employee_id),
            XMLELEMENT("first_name", e.first_name),
            XMLELEMENT("last_name", e.last_name),
            XMLELEMENT("department_name", d.department_name),
            XMLELEMENT("job_title", j.job_title)
        )
    )
) as xml_output
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id;

-- Crear esquema XML en la base de datos
PROMPT *** Creando esquema XML ***
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
SELECT schema_id, XMLSERIALIZE(DOCUMENT schema_doc AS CLOB INDENT SIZE = 2) as schema_content
FROM xml_schema_table;

EXIT;
