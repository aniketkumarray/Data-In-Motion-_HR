-- Create 'departments' table
CREATE TABLE departments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    manager_id INT
);

-- Create 'employees' table
CREATE TABLE employees (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

-- Create 'projects' table
CREATE TABLE projects (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);

-- Insert data into 'departments'
INSERT INTO departments (name, manager_id)
VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- Insert data into 'employees'
INSERT INTO employees (name, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- Insert data into 'projects'
INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
  INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 2', '2023-01-01', '2023-08-30', 1)    
       UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
WHERE name = 'HR';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
WHERE name = 'IT';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson')
WHERE name = 'Sales';

Drop table departments;
Drop table employees;
Drop table projects;

-- SQL Challenge Questions

--1. Find the longest ongoing project for each department.

WITH CTE1 AS
(
SELECT d.id, d.name,p.name AS projname,p.department_id, DATEDIFF(day,p.start_date,p.end_date) as Duration from departments d 
JOIN projects p 
ON d.id = p.department_id
),
CTE2 AS
(
SELECT id, name,projname,Duration, 
row_number() 
Over ( partition by name Order by Duration DESC) rn 
FROM CTE1 ) 
Select id, name,projname,Duration FROM CTE2 Where rn = 1;



--2. Find all employees who are not managers.
with cte1 AS 
(
Select e.id,e.name,e.department_id, d.manager_id from employees e left join departments d 
ON e.id = d.manager_id 
)
Select id,name from cte1 where manager_id is null 


--3. Find all employees who have been hired after the start of a project in their department.
SELECT e.name, e.hire_date, p.start_date
FROM employees e
JOIN projects p ON e.department_id = p.department_id
WHERE e.hire_date > p.start_date;

--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).

SELECT e.id, e.name, e.hire_date, d.name AS department_name,
       RANK() OVER (PARTITION BY e.department_id ORDER BY e.hire_date ASC) AS rnk
FROM employees e
JOIN departments d ON e.department_id = d.id;

--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.

 WITH CTE1 AS
(
    SELECT id, name, hire_date, department_id,
           LEAD(hire_date) OVER (PARTITION BY department_id ORDER BY hire_date) AS next_hire_date
    FROM employees
)
SELECT id, name, hire_date, department_id,
       DATEDIFF(day, hire_date, next_hire_date) AS duration_to_next_hire
FROM CTE1;