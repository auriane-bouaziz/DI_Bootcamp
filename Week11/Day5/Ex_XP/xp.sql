-- 🌟 Exercise 1: Building a Comprehensive Dataset for Employee Analysis
-- Create a temporary table that join all tables and create a new one using LEFT JOIN.
-- Create an unique identifier code between the columns ‘employee_id’ and ‘date’ and call it ‘id’.
-- Convert the column ‘date’ to DATE type because it was previously configured as TIMESTAMP.
-- Transform this new table into a dataset “df_employee” for analysis.


DROP TABLE IF EXISTS emp_dataset;

CREATE TEMP TABLE emp_dataset AS
SELECT
    s.employee_id,
    s.employee_name,
    s.date AS salary_date,
    s.salary AS salary_raw,
    e."GEN(M_F)" AS gender,
    e.age AS age_raw,
    f.function_group,
    c.company_name,
    c.company_city,
    c.company_state,
    c.company_type,
    c.const_site_category
FROM salaries s
LEFT JOIN companies c
    ON s.comp_name = c.company_name
LEFT JOIN functions f
    ON s.func_code = f.function_code
LEFT JOIN employees e
    ON s.employee_id = e.employee_code_emp;

SELECT *
FROM emp_dataset;


-- 1.2. Create df_employee with the required columns

DROP TABLE IF EXISTS df_employee;

CREATE TABLE df_employee AS
SELECT
    employee_id || '_' ||
        TO_CHAR(
            TO_TIMESTAMP(salary_date, 'DD/MM/YYYY HH24:MI'),
            'YYYY-MM-DD'
        ) AS id,

    TO_TIMESTAMP(
        salary_date, 'DD/MM/YYYY HH24:MI'
    )::DATE AS month_year,

    employee_id,
    employee_name,
    gender,
    NULLIF(TRIM(age_raw), '')::INTEGER AS age,

    REPLACE(
        NULLIF(TRIM(salary_raw), ''),
        ',', '.'
    )::NUMERIC(12,2) AS salary,

    function_group,
    company_name,
    company_city,
    company_state,
    company_type,
    const_site_category

FROM emp_dataset;

SELECT *
FROM df_employee;


-- Exercise 2 — Cleaning Data for Consistency and Quality
-- 2.1. Observe the new table



SELECT *
FROM df_employee;


-- 2.2. Remove unwanted spaces using TRIM


UPDATE df_employee
SET
    id = TRIM(id),
    employee_id = TRIM(employee_id),
    employee_name = TRIM(employee_name),
    gender = TRIM(gender),
    function_group = TRIM(function_group),
    company_name = TRIM(company_name),
    company_city = TRIM(company_city),
    company_state = TRIM(company_state),
    company_type = TRIM(company_type),
    const_site_category = TRIM(const_site_category);

-- 2.3. Check NULL and empty values


SELECT *
FROM df_employee
WHERE
    id IS NULL OR id = ''
    OR month_year IS NULL
    OR employee_id IS NULL OR employee_id = ''
    OR employee_name IS NULL OR employee_name = ''
    OR gender IS NULL OR gender = ''
    OR age IS NULL
    OR salary IS NULL
    OR function_group IS NULL OR function_group = ''
    OR company_name IS NULL OR company_name = ''
    OR company_city IS NULL OR company_city = ''
    OR company_state IS NULL OR company_state = ''
    OR company_type IS NULL OR company_type = ''
    OR const_site_category IS NULL
    OR const_site_category = '';





SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE salary IS NULL
    ) AS missing_salary,
    COUNT(*) FILTER (
        WHERE gender IS NULL OR gender = ''
    ) AS missing_gender,
    COUNT(*) FILTER (
        WHERE age IS NULL
    ) AS missing_age,
    COUNT(*) FILTER (
        WHERE const_site_category IS NULL
           OR const_site_category = ''
    ) AS missing_category
FROM df_employee;


-- 2.4. Delete rows with missing values



UPDATE df_employee
SET const_site_category = 'Not applicable'
WHERE const_site_category IS NULL
   OR const_site_category = '';

DELETE FROM df_employee
WHERE id IS NULL OR id = ''
   OR month_year IS NULL
   OR employee_id IS NULL OR employee_id = ''
   OR employee_name IS NULL OR employee_name = ''
   OR gender IS NULL OR gender = ''
   OR age IS NULL
   OR salary IS NULL
   OR function_group IS NULL OR function_group = ''
   OR company_name IS NULL OR company_name = ''
   OR company_city IS NULL OR company_city = ''
   OR company_state IS NULL OR company_state = ''
   OR company_type IS NULL OR company_type = '';


-- 2.5. Additional cleaning 

-- Standardize gender
UPDATE df_employee
SET gender = CASE
    WHEN gender = 'M' THEN 'Male'
    WHEN gender = 'F' THEN 'Female'
    ELSE gender
END;

-- Correct company cities
UPDATE df_employee
SET company_city = 'Goiania'
WHERE company_city = 'Goianiaa';

-- Standardize company states
UPDATE df_employee
SET company_state = 'Goias'
WHERE company_state = 'GOIAS';

-- Correct company types
UPDATE df_employee
SET company_type = 'Construction Site'
WHERE company_type IN (
    'Construction Sites',
    'Construction Site s'
);

-- Correct construction site categories
UPDATE df_employee
SET const_site_category = 'Commercial'
WHERE const_site_category = 'Commerciall';

-- Remove HR test salaries
DELETE FROM df_employee
WHERE salary = 1000000;


-- 2.6. Remove duplicates

SELECT
    id,
    COUNT(*) AS duplicate_count
FROM df_employee
GROUP BY id
HAVING COUNT(*) > 1;




WITH duplicates AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY ctid
        ) AS row_num
    FROM df_employee
)
DELETE FROM df_employee d
USING duplicates x
WHERE d.ctid = x.ctid
  AND x.row_num > 1;

-- 2.7. Create the pay_month column


ALTER TABLE df_employee
ADD COLUMN pay_month DATE;

UPDATE df_employee
SET pay_month = DATE_TRUNC(
    'month', month_year
)::DATE;

-- Final check
SELECT *
FROM df_employee
ORDER BY pay_month, employee_id;


-- Exercise 3 — Calculating Current Employee Counts by Company
-- 3.1. How many employees do the companies have today?


SELECT
    COUNT(DISTINCT employee_id) AS total_employees
FROM df_employee
WHERE pay_month = (
    SELECT MAX(pay_month)
    FROM df_employee
);

-- 3.2. Group employees by company


SELECT
    company_name,
    COUNT(DISTINCT employee_id) AS employee_count
FROM df_employee
WHERE pay_month = (
    SELECT MAX(pay_month)
    FROM df_employee
)
GROUP BY company_name
ORDER BY employee_count DESC;

-- Exercise 4 — Analyzing Employee Distribution by City and Over Time
-- 4.1. Total employees by city with percentage


WITH city_counts AS (
    SELECT
        company_city,
        COUNT(DISTINCT employee_id) AS employee_count
    FROM df_employee
    WHERE pay_month = (
        SELECT MAX(pay_month)
        FROM df_employee
    )
    GROUP BY company_city
)

SELECT
    company_city,
    employee_count,
    ROUND(
        employee_count * 100.0 /
        SUM(employee_count) OVER (),
        2
    ) AS percentage
FROM city_counts
ORDER BY employee_count DESC;



-- 4.2. Total employees each month


SELECT
    TO_CHAR(pay_month, 'YYYY-MM') AS month,
    COUNT(DISTINCT employee_id) AS employee_count
FROM df_employee
GROUP BY pay_month
ORDER BY pay_month;


-- 4.3. Average number of employees per month


WITH monthly_employees AS (
    SELECT
        pay_month,
        COUNT(DISTINCT employee_id) AS employee_count
    FROM df_employee
    GROUP BY pay_month
)

SELECT
    ROUND(
        AVG(employee_count),
        2
    ) AS avg_employees_per_month
FROM monthly_employees;

-- Exercise 5 — Analyzing Employment Trends and Salary Metrics
-- 5.1. Minimum number of employees and corresponding month


WITH monthly_employees AS (
    SELECT
        pay_month,
        COUNT(DISTINCT employee_id) AS employee_count
    FROM df_employee
    GROUP BY pay_month
)

SELECT
    TO_CHAR(pay_month, 'YYYY-MM') AS month,
    employee_count
FROM monthly_employees
WHERE employee_count = (
    SELECT MIN(employee_count)
    FROM monthly_employees
)
ORDER BY pay_month;


-- 5.2. Maximum number of employees and corresponding month


WITH monthly_employees AS (
    SELECT
        pay_month,
        COUNT(DISTINCT employee_id) AS employee_count
    FROM df_employee
    GROUP BY pay_month
)

SELECT
    TO_CHAR(pay_month, 'YYYY-MM') AS month,
    employee_count
FROM monthly_employees
WHERE employee_count = (
    SELECT MAX(employee_count)
    FROM monthly_employees
)
ORDER BY pay_month;


-- 5.3. Monthly average number of employees by function group


WITH monthly_function AS (
    SELECT
        function_group,
        pay_month,
        COUNT(DISTINCT employee_id) AS employee_count
    FROM df_employee
    GROUP BY function_group, pay_month
)

SELECT
    function_group,
    ROUND(
        AVG(employee_count),
        2
    ) AS avg_employees_per_month
FROM monthly_function
GROUP BY function_group
ORDER BY avg_employees_per_month DESC;


-- 5.4. Annual average salary


SELECT
    EXTRACT(YEAR FROM month_year)::INT AS year,
    ROUND(
        AVG(salary),
        2
    ) AS average_salary
FROM df_employee
GROUP BY EXTRACT(YEAR FROM month_year)
ORDER BY year;


-- Bonus — Additional salary analyses from original script


-- Average monthly salary
SELECT
    TO_CHAR(pay_month, 'YYYY-MM') AS month,
    ROUND(AVG(salary), 2) AS average_salary
FROM df_employee
GROUP BY pay_month
ORDER BY pay_month;


-- Average salary by city
SELECT
    company_city,
    ROUND(AVG(salary), 2) AS average_salary
FROM df_employee
GROUP BY company_city
ORDER BY average_salary DESC;


-- Average salary by state
SELECT
    company_state,
    ROUND(AVG(salary), 2) AS average_salary
FROM df_employee
GROUP BY company_state
ORDER BY average_salary DESC;


-- Average salary by function group
SELECT
    function_group,
    ROUND(AVG(salary), 2) AS average_salary
FROM df_employee
GROUP BY function_group
ORDER BY average_salary DESC;


-- Top 10 employees with highest current salaries
SELECT
    employee_id,
    employee_name,
    ROUND(AVG(salary), 2) AS average_salary
FROM df_employee
WHERE pay_month = (
    SELECT MAX(pay_month)
    FROM df_employee
)
GROUP BY employee_id, employee_name
ORDER BY average_salary DESC
LIMIT 10;
























