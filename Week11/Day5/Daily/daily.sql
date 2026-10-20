-- Your Task
-- For this tutorial, let’s create an employees table like so:



-- -- Create the employees table
-- CREATE TABLE employees (
--     employee_id INT PRIMARY KEY,
--     employee_name VARCHAR(50),
--     salary DECIMAL(10, 2),
--     hire_date VARCHAR(20),
--     department VARCHAR(50)
-- );


-- Next, let’s insert some fictional sample records into the table:



-- -- Insert 20 sample records 
-- INSERT INTO employees (employee_id, employee_name, salary, hire_date, department) VALUES
-- (1, 'Amy West', 60000.00, '2021-01-15', 'HR'),
-- (2, 'Ivy Lee', 75000.50, '2020-05-22', 'Sales'),
-- (3, 'joe smith', 80000.75, '2019-08-10', 'Marketing'), 
-- (4, 'John White', 90000.00, '2020-11-05', 'Finance'),
-- (5, 'Jane Hill', 55000.25, '2022-02-28', 'IT'),
-- (6, 'Dave West', 72000.00, '2020-03-12', 'Marketing'),
-- (7, 'Fanny Lee', 85000.50, '2018-06-25', 'Sales'),
-- (8, 'Amy Smith', 95000.25, '2019-11-30', 'Finance'),
-- (9, 'Ivy Hill', 62000.75, '2021-07-18', 'IT'),
-- (10, 'Joe White', 78000.00, '2022-04-05', 'Marketing'),
-- (11, 'John Lee', 68000.50, '2018-12-10', 'HR'),
-- (12, 'Jane West', 89000.25, '2017-09-15', 'Sales'),
-- (13, 'Dave Smith', 60000.75, '2022-01-08', NULL),
-- (14, 'Fanny White', 72000.00, '2019-04-22', 'IT'),
-- (15, 'Amy Hill', 84000.50, '2020-08-17', 'Marketing'),
-- (16, 'Ivy West', 92000.25, '2021-02-03', 'Finance'),
-- (17, 'Joe Lee', 58000.75, '2018-05-28', 'IT'),
-- (18, 'John Smith', 77000.00, '2019-10-10', 'HR'),
-- (19, 'Jane Hill', 81000.50, '2022-03-15', 'Sales'),
-- (20, 'Dave White', 70000.25, '2017-12-20', 'Marketing');


-- Identify and handle any missing value.
-- Check for and eliminate any duplicate rows in the dataset.
-- Correct any structural issues, such as inconsistent naming conventions or formatting errors.
-- Ensure all columns have appropriate data types (e.g. the hire_date column).
-- Detect and address any outliers that may skew the analysis.
-- Standardize and normalize data where applicable to ensure consistency.



CREATE SCHEMA IF NOT EXISTS cleaning_practice;


CREATE TABLE cleaning_practice.employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date VARCHAR(20),
    department VARCHAR(50)
);

INSERT INTO cleaning_practice.employees
(employee_id, employee_name, salary, hire_date, department)
VALUES
(1, 'Amy West', 60000.00, '2021-01-15', 'HR'),
(2, 'Ivy Lee', 75000.50, '2020-05-22', 'Sales'),
(3, 'joe smith', 80000.75, '2019-08-10', 'Marketing'),
(4, 'John White', 90000.00, '2020-11-05', 'Finance'),
(5, 'Jane Hill', 55000.25, '2022-02-28', 'IT'),
(6, 'Dave West', 72000.00, '2020-03-12', 'Marketing'),
(7, 'Fanny Lee', 85000.50, '2018-06-25', 'Sales'),
(8, 'Amy Smith', 95000.25, '2019-11-30', 'Finance'),
(9, 'Ivy Hill', 62000.75, '2021-07-18', 'IT'),
(10, 'Joe White', 78000.00, '2022-04-05', 'Marketing'),
(11, 'John Lee', 68000.50, '2018-12-10', 'HR'),
(12, 'Jane West', 89000.25, '2017-09-15', 'Sales'),
(13, 'Dave Smith', 60000.75, '2022-01-08', NULL),
(14, 'Fanny White', 72000.00, '2019-04-22', 'IT'),
(15, 'Amy Hill', 84000.50, '2020-08-17', 'Marketing'),
(16, 'Ivy West', 92000.25, '2021-02-03', 'Finance'),
(17, 'Joe Lee', 58000.75, '2018-05-28', 'IT'),
(18, 'John Smith', 77000.00, '2019-10-10', 'HR'),
(19, 'Jane Hill', 81000.50, '2022-03-15', 'Sales'),
(20, 'Dave White', 70000.25, '2017-12-20', 'Marketing');


SELECT *
FROM cleaning_practice.employees;

-- Exercise 1 — Identify and handle missing values

-- 1. Check for missing values


SELECT *
FROM cleaning_practice.employees
WHERE employee_id IS NULL
   OR employee_name IS NULL
   OR salary IS NULL
   OR hire_date IS NULL
   OR department IS NULL;
   
   
-- 2. Handle missing values


UPDATE cleaning_practice.employees
SET department = 'Unassigned'
WHERE department IS NULL
   OR TRIM(department) = '';
   
   
-- Exercise 2 — Check for and eliminate duplicate rows
-- 1. Check for duplicates


SELECT
    employee_name,
    salary,
    hire_date,
    department,
    COUNT(*) AS duplicate_count
FROM cleaning_practice.employees
GROUP BY
    employee_name,
    salary,
    hire_date,
    department
HAVING COUNT(*) > 1;


-- Exercise 3 — Correct structural and formatting issues
-- 1. Standardize employee names

UPDATE cleaning_practice.employees
SET employee_name = INITCAP(
    TRIM(employee_name)
);


-- 2. Standardize department names

UPDATE cleaning_practice.employees
SET department = CASE
    WHEN UPPER(TRIM(department)) = 'HR' THEN 'HR'
    WHEN UPPER(TRIM(department)) = 'IT' THEN 'IT'
    ELSE INITCAP(TRIM(department))
END;


-- Exercise 4 — Ensure appropriate data types


SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'cleaning_practice'
  AND table_name = 'employees';



-- 2. Convert hire_date to DATE


ALTER TABLE cleaning_practice.employees
ALTER COLUMN hire_date TYPE DATE
USING hire_date::DATE;



-- Exercise 5 — Detect and address outliers

-- 1. Check minimum, maximum and average salary



SELECT
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    ROUND(AVG(salary), 2) AS avg_salary
FROM cleaning_practice.employees;


-- 2. Detect outliers using IQR


WITH quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY salary) AS q1,
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY salary) AS q3
    FROM cleaning_practice.employees
)

SELECT
    e.employee_id,
    e.employee_name,
    e.salary
FROM cleaning_practice.employees e
CROSS JOIN quartiles q
WHERE e.salary < q.q1 - 1.5 * (q.q3 - q.q1)
   OR e.salary > q.q3 + 1.5 * (q.q3 - q.q1);

-- Exercise 6 — Standardize and normalize data

SELECT
    employee_id,
    employee_name,
    salary,
    ROUND(
        (salary - MIN(salary) OVER ()) /
        NULLIF(
            MAX(salary) OVER () - MIN(salary) OVER (),
            0
        ),
        3
    ) AS normalized_salary
FROM cleaning_practice.employees
ORDER BY salary DESC;

-- Final step — Validate the cleaned dataset



SELECT
    COUNT(*) AS total_employees,
    COUNT(DISTINCT employee_id) AS unique_employees,
    COUNT(*) FILTER (
        WHERE department IS NULL
    ) AS missing_departments,
    MIN(hire_date) AS earliest_hire,
    MAX(hire_date) AS latest_hire,
    ROUND(AVG(salary), 2) AS avg_salary
FROM cleaning_practice.employees;




SELECT *
FROM cleaning_practice.employees
ORDER BY employee_id;









