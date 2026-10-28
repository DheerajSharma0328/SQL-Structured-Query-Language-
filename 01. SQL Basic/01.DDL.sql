-- DATA DEFINAION LANGUAGE
CREATE ROLE dheeraj_admin
WITH LOGIN
PASSWORD 'Dheeraj@9317';

CREATE DATABASE sql_sandbox OWNER dheeraj_admin;
-- To Create Database
CREATE DATABASE sql_sandbox

CREATE TABLE departments(
    department_id SERIAL PRIMARY KEY,
    departments_name VARCHAR(50) NOT NULL
);

INSERT INTO departments (departments_name) 
VALUES
('Sales'),
('Suppot'),
('Warehouse');


INSERT INTO departments 
(department_id,departments_name)
VALUES
(4,'Tech');


CREATE TABLE employees(
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    bio TEXT,
    job_title VARCHAR(50) NOT NULL,
    salary INT NOT NULL CHECK(salary>0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    hire_date DATE NOT NULL,
    last_login TIMESTAMP,
    employee_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                    CHECK(
                        employee_status IN ('ACTIVE','ON_LEAVE','TERMINATED')
                    ),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    department_id INT REFERENCES departments(department_id),
    manager_id INT REFERENCES employees(employee_id)
);


INSERT INTO employees(first_name, last_name, email, department_id, job_title, salary, manager_id, hire_date) VALUES
('Dheeraj', 'Sharma', 'Dheeraj@gmail.com', 4, 'Software Engineer', 100000, NULL, '2025-11-18'),
('Ankit', 'Sharestha', 'Ankit@gmail.com', 4, 'Software Engineer', 90000, NULL, '2025-11-18'),
('Ishaan', 'Bharadwaj', 'Ishaan@gmail.com', 1, 'Data Analytics', 88000, NULL, '2025-11-18'),
('Prachi', 'Rana', 'Prachi@gmail.com', 2, 'Bussiness Manager', 99000, NULL, '2025-11-18'),
('Deepanshi', 'Sharma', 'Deepanshi@gmail.com', 3, 'Execution Manager', 70000, NULL, '2025-11-18');

SELECT department_id, departments_name
FROM departments
ORDER BY department_id;


ALTER TABLE employees
ADD COLUMN interal_note VARCHAR(100) NOT NULL DEFAULT 'N/A';

ALTER TABLE employees
RENAME COLUMN interal_note to hr_note

ALTER TABLE employees 
DROP COLUMN hr_note;



SELECT * FROM employees