-- Find the average salary of the male and female employees in each department
USE employees;

SELECT 
    d.dept_name, 
    e.gender, 
    ROUND(AVG(s.salary), 2) AS avg_salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON de.emp_no = s.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_name, e.gender;


-- Find the lowest department number encountered in the 'dept_emp' table
SELECT MIN(dept_no) 
FROM dept_emp;

-- Find the highest department number
SELECT MAX(dept_no) 
FROM dept_emp;


-- Exercise 3
-- Obtain a table containing:
-- 1. employee number
-- 2. the lowest department number among the departments where the employee has worked
-- 3. assign '110022' as 'manager' if emp_no <= 10020, otherwise '110039'
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


-- Retrieve a list of all employees that have been hired in 2000
SELECT 
    emp_no, 
    hire_date
FROM employees
WHERE YEAR(hire_date) = 2000;


-- Retrieve employees from the ‘titles’ table who are engineers
SELECT emp_no, title
FROM titles
WHERE title = 'Engineer';

-- Retrieve employees who are senior engineers
SELECT emp_no, title
FROM titles
WHERE title = 'Senior Engineer';

-- Retrieve employees using LIKE
SELECT emp_no, title
FROM titles
WHERE title LIKE '%Engineer%';


-- Create a procedure to get the last department an employee has worked in
DELIMITER $$
CREATE PROCEDURE emp_latest_department(IN p_emp_no INT)
BEGIN
    SELECT 
        d1.emp_no, d1.dept_no, d1.from_date
    FROM dept_emp d1
    JOIN (
        SELECT 
            emp_no, MAX(from_date) AS from_date
        FROM dept_emp
        WHERE emp_no = p_emp_no
        GROUP BY emp_no
    ) d2 
    ON d1.emp_no = d2.emp_no
    AND d1.from_date = d2.from_date;
END $$
DELIMITER ;

CALL employees.emp_latest_department(10010);


-- Count contracts with duration > 1 year and salary >= 100,000
SELECT COUNT(*)
FROM salaries
WHERE salary >= 100000
  AND DATEDIFF(to_date, from_date) > 365;

SELECT COUNT(*)
FROM salaries
WHERE salary >= 100000
  AND TIMESTAMPDIFF(YEAR, from_date, to_date) > 1;

-- Create a trigger to ensure hire_date <= current date
COMMIT;

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


-- Function: get max salary of an employee
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


-- Function: get min salary of an employee
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


-- Function: get min, max, or difference depending on parameter
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
