CREATE TABLE DEPARTMENTS (DEPARTMENT_ID INT PRIMARY KEY,
																											DEPARTMENT_NAME VARCHAR(50),
																											LOCATION_ID INT);


CREATE TABLE EMPLOYEES (EMPLOYEE_ID INT PRIMARY KEY,
																									FIRST_NAME VARCHAR(50),
																									LAST_NAME VARCHAR(50),
																									DEPARTMENT_ID INT, SALARY DECIMAL(10,

																																																				2),
																								FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID));


CREATE TABLE LOCATIONS (LOCATION_ID INT PRIMARY KEY,
																									CITY VARCHAR(50),
																									COUNTRY VARCHAR(50));


INSERT INTO DEPARTMENTS (DEPARTMENT_ID,

														DEPARTMENT_NAME,
														LOCATION_ID)
VALUES (1, 'HR', 100),
							(2, 'Finance', 200),
							(3, 'IT', 300),
							(4, 'Marketing', 400),
							(5, 'Sales', 500);


INSERT INTO EMPLOYEES (EMPLOYEE_ID,

														FIRST_NAME,
														LAST_NAME,
														DEPARTMENT_ID,
														SALARY)
VALUES (1, 'John', 'Doe', 1, 60000),
							(2, 'Jane', 'Smith', 2, 80000),
							(3, 'Jim', 'Brown', 3, 90000),
							(4, 'Jake', 'White', 4, 70000),
							(5, 'Jill', 'Green', 5, 75000),
							(6, 'Jack', 'Black', 3, 95000),
							(7, 'Jerry', 'Gray', 2, 82000);


INSERT INTO LOCATIONS (LOCATION_ID,

														CITY,
														COUNTRY)
VALUES (100, 'New York', 'USA'),
							(200, 'London', 'UK'),
							(300, 'San Francisco', 'USA'),
							(400, 'Berlin', 'Germany'),
							(500, 'Paris', 'France');

-- Task: Find the employee details who have the highest salary in each department.

SELECT D.DEPARTMENT_NAME,
	E.FIRST_NAME,
	E.LAST_NAME,
	E.SALARY
FROM
	(SELECT DEPARTMENT_ID,
			MAX(SALARY) AS MAX_SALARY
		FROM EMPLOYEES
		GROUP BY DEPARTMENT_ID) M
JOIN EMPLOYEES E ON E.DEPARTMENT_ID = M.DEPARTMENT_ID
AND E.SALARY = M.MAX_SALARY
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID;

-- Task: List the employees who work in departments located in either New York or London.

SELECT FIRST_NAME,
	LAST_NAME
FROM EMPLOYEES E
WHERE EXISTS
		(SELECT 1
			FROM DEPARTMENTS D
			JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
			WHERE E.DEPARTMENT_ID = D.DEPARTMENT_ID
				AND L.CITY IN ('London',
																				'New York') );

-- Task: Find employees whose salary is above the departmental average, but only for departments located in the USA.

SELECT E.FIRST_NAME,
	E.LAST_NAME,
	E.SALARY,
	D.DEPARTMENT_NAME,
	L.CITY,
	M.AVG_SALARY
FROM EMPLOYEES E
JOIN
	(SELECT DEPARTMENT_ID,
			AVG(SALARY) AS AVG_SALARY
		FROM EMPLOYEES
		GROUP BY DEPARTMENT_ID) M ON E.DEPARTMENT_ID = M.DEPARTMENT_ID
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
WHERE E.SALARY > M.AVG_SALARY
	AND L.COUNTRY = 'USA';

-- Affiche les employés dont le salaire est supérieur au salaire moyen de toute l’entreprise.

SELECT E.FIRST_NAME,
	E.LAST_NAME,
	E.SALARY
FROM EMPLOYEES E
WHERE salary > (SELECT AVG(salary) AS avg_salary FROM employees)


-- Affiche les employés dont le salaire est égal au salaire le plus bas de toute l’entreprise.

SELECT E.FIRST_NAME,
	E.LAST_NAME,
	E.SALARY
FROM EMPLOYEES E
WHERE salary = (SELECT MIN(salary) FROM employees)

-- Affiche les employés qui travaillent dans le même département que Jack Black.
-- N’affiche pas Jack Black lui-même.

SELECT
    e.first_name,
    e.last_name,
    e.department_id
FROM employees e
WHERE e.department_id = (
    SELECT department_id
    FROM employees
    WHERE first_name = 'Jack'
      AND last_name = 'Black'
)
AND NOT (
    e.first_name = 'Jack'
    AND e.last_name = 'Black'
);


-- Affiche les employés dont le salaire est supérieur à la moyenne de leur propre département.
SELECT E.FIRST_NAME,
	E.LAST_NAME,
	E.SALARY
FROM EMPLOYEES E
JOIN (SELECT department_id, AVG(salary) AS avg_salary
	  FROM employees 
	  GROUP BY department_id) 
	  AS avg_dpt
ON E.DEPARTMENT_ID = avg_dpt.department_id 
WHERE salary > avg_dpt.avg_salary 


-- Affiche les employés dont le salaire est inférieur au salaire maximum de leur propre département.
SELECT E.FIRST_NAME,
	E.LAST_NAME,
	E.SALARY
FROM EMPLOYEES E
JOIN (SELECT department_id, MAX(salary) AS max_salary
	  FROM employees 
	  GROUP BY department_id) 
	  AS max_dpt
ON E.DEPARTMENT_ID = max_dpt.department_id 
WHERE salary < max_dpt.max_salary 


-- Affiche les départements dont le salaire moyen est supérieur au salaire moyen de toute l’entreprise.

SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, ROUND(avg_dpt.avg_salary,2)
FROM DEPARTMENTS D
JOIN (SELECT department_id, AVG(salary) AS avg_salary
	  FROM employees 
	  GROUP BY department_id) 
	  AS avg_dpt
ON D.DEPARTMENT_ID = avg_dpt.DEPARTMENT_ID
WHERE avg_dpt.avg_salary > (SELECT AVG(SALARY) FROM EMPLOYEES)

-- Affiche le ou les départements ayant le salaire moyen le plus élevé.

SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, avg_dpt.avg_salary
FROM DEPARTMENTS D
JOIN (SELECT department_id, AVG(salary) AS avg_salary
	  FROM employees 
	  GROUP BY department_id) 
	  AS avg_dpt
ON D.DEPARTMENT_ID = avg_dpt.DEPARTMENT_ID
WHERE avg_dpt.avg_salary = (
    SELECT MAX(dept_averages.avg_salary)
    FROM (
        SELECT
            AVG(salary) AS avg_salary
        FROM employees
        GROUP BY department_id
    ) AS dept_averages
);

-- Affiche les employés qui travaillent dans un département où il y a au moins un employé payé plus de 90000.

SELECT
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM employees e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > 90000
);


SELECT
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.department_id IN (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    HAVING MAX(salary) > 90000
);

-- Pour cet énoncé, je choisirais EXISTS, parce que les mots “il y a au moins un employé” correspondent exactement à : “does there exist an employee…?”

-- Affiche les départements qui ont au moins deux employés.

SELECT
    d.department_id,
    d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
    GROUP BY e.department_id
    HAVING COUNT(e.employee_id) >= 2
);

SELECT
    d.department_id,
    d.department_name,
    count_dep.employee_count
FROM departments d
JOIN (
    SELECT
        department_id,
        COUNT(employee_id) AS employee_count
    FROM employees
    GROUP BY department_id
) AS count_dep
    ON d.department_id = count_dep.department_id
WHERE count_dep.employee_count >= 2;


-- Affiche les employés qui travaillent dans un département situé dans le même pays que le département Finance.	

SELECT
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN locations l
    ON d.location_id = l.location_id
WHERE l.country = (
    SELECT lf.country
    FROM departments df
    JOIN locations lf
        ON df.location_id = lf.location_id
    WHERE df.department_name = 'Finance'
);



