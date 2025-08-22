# SQL Employees Database

This project contains a sample Employees Database used to practice SQL exercises. The database schema includes 6 tables:

- Employees: Stores information about all employees.

- Dept_emp: Stores details about employees and the departments they have worked in.

- Departments: Stores details about company departments.

- Dept_manager: Stores information about managers and the departments they managed.

- Salaries: Stores all employee salary contracts.

- Titles: Stores employee titles.

## Database Schema
<img width="1774" height="769" alt="Screenshot 2025-08-22 002005" src="https://github.com/user-attachments/assets/7f49e404-7e4f-4680-912e-285ab14feb6c" />

## SQL Exercises

Below are some SQL exercises solved using the Employees Database.

1. Average Salary of Male and Female Employees in Each Department
USE employees;
```sql
SELECT 
    d.dept_name, 
    e.gender, 
    ROUND(AVG(s.salary), 2) AS avg_salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON de.emp_no = s.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_name, e.gender;
```

2. Find the Lowest and Highest Department Numbers
```sql
-- Lowest department number
SELECT MIN(dept_no) FROM dept_emp;

-- Highest department number
SELECT MAX(dept_no) FROM dept_emp;
```

3. Employee Department and Manager Assignment
```sql
SELECT 
    emp_no,
    MIN(dept_no) AS dept_no,
    CASE
        WHEN emp_no < 10021 THEN 110022
        ELSE 110039
    END AS manager
FROM dept_emp
WHERE emp_no <= 10040
GROUP BY emp_no;
```
4. Employees Hired in the Year 2000
```sql
SELECT emp_no, hire_date
FROM employees
WHERE YEAR(hire_date) = 2000;
```

5. Retrieve Employees by Title
```sql
-- Engineers
SELECT emp_no, title
FROM titles
WHERE title = 'Engineer';

-- Senior Engineers
SELECT emp_no, title
FROM titles
WHERE title = 'Senior Engineer';

-- All Engineers using LIKE
SELECT emp_no, title
FROM titles
WHERE title LIKE '%Engineer%';
```

6. Procedure: Get Last Department an Employee Worked In
```sql
DELIMITER $$
CREATE PROCEDURE emp_latest_department(IN p_emp_no INT)
BEGIN
    SELECT d1.emp_no, d1.dept_no, d1.from_date
    FROM dept_emp d1
    JOIN (
        SELECT emp_no, MAX(from_date) AS from_date
        FROM dept_emp
        WHERE emp_no = p_emp_no
        GROUP BY emp_no
    ) d2 
    ON d1.emp_no = d2.emp_no
    AND d1.from_date = d2.from_date;
END $$
DELIMITER ;

CALL employees.emp_latest_department(10010);
```
7. Count Salary Contracts
```sql
-- Contracts longer than 1 year with salary >= 100,000
SELECT COUNT(*)
FROM salaries
WHERE salary >= 100000
  AND DATEDIFF(to_date, from_date) > 365;

```

8. Trigger: Ensure hire_date ≤ Current Date
```sql

DELIMITER $$
CREATE TRIGGER hire_date_check
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.hire_date > SYSDATE() THEN
        SET NEW.hire_date = SYSDATE();
    END IF;
END $$
DELIMITER ;
```
9. Functions for Employee Salaries
```sql
# Maximum Salary

DELIMITER $$
CREATE FUNCTION max_salary(p_emp_no INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_max_salary DECIMAL(10,2);
    SELECT MAX(salary) INTO v_max_salary
    FROM salaries
    WHERE emp_no = p_emp_no;
    RETURN v_max_salary;
END$$
DELIMITER ;

SELECT employees.max_salary(11356);


# Minimum Salary

DELIMITER $$
CREATE FUNCTION min_salary(p_emp_no INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_min_salary DECIMAL(10,2);
    SELECT MIN(salary) INTO v_min_salary
    FROM salaries
    WHERE emp_no = p_emp_no;
    RETURN v_min_salary;
END$$
DELIMITER ;

SELECT employees.min_salary(11356);


# Min, Max, or Difference

DELIMITER $$
CREATE FUNCTION employee_salary(p_emp_no INT, p_salary VARCHAR(255)) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    SELECT 
        CASE
            WHEN p_salary = 'min' THEN MIN(salary)
            WHEN p_salary = 'max' THEN MAX(salary)
            ELSE MAX(salary) - MIN(salary)
        END AS employee_salary
    INTO v_salary
    FROM salaries
    WHERE emp_no = p_emp_no;
    RETURN v_salary;
END$$
DELIMITER ;

SELECT employees.employee_salary(11356, 'max');
SELECT employees.employee_salary(11356, 'min');
SELECT employees.employee_salary(11356, 'diff');

```


