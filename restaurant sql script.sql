CREATE DATABASE restaurant;
USE restaurant;

CREATE TABLE employees (
employee_id INT PRIMARY KEY NOT NULL,
firstname VARCHAR(50) NOT NULL,
lastname VARCHAR (50) NOT NULL,
hourly_pay DECIMAL(5,2) NOT NULL,
salary DECIMAL(10,2),
job VARCHAR(25) NOT NULL,
hire_date DATE NOT NULL,
supervisor_id INT
);

CREATE TABLE customers (
customer_id INT PRIMARY KEY AUTO_INCREMENT,
firstname VARCHAR(50),
lastname VARCHAR(50),
email VARCHAR(50),
referral_id INT
);

CREATE TABLE products (
product_id INT PRIMARY KEY,
product_name VARCHAR(25) UNIQUE,
price DECIMAL (4,2) NOT NULL DEFAULT '0.00',
supplied_by CHAR(2) 
);

CREATE TABLE transactions(
transaction_id INT PRIMARY KEY AUTO_INCREMENT,
product_id INT NOT NULL,
amount DECIMAL (5,2) NOT NULL,
customer_id INT,
order_date DATE NOT NULL,
served_by INT
);
ALTER TABLE transactions
AUTO_INCREMENT = 1000;

CREATE TABLE suppliers (
supplier_id CHAR(2) PRIMARY KEY,
supplier_name VARCHAR(20)
);

-- -------------------------------------------------------------------------------------

INSERT INTO employees
VALUES
(1, 'Eugene', 'Krabs', 25.50, 53040, 'manager', '2023-01-02', NULL),
(2, 'Squidward', 'Tentacles', 15.00, 31200, 'cashier', '2023-01-03', 5),
(3, 'Spongebob', 'Squarepants', 12.50, 26000, 'cook', '2023-01-04', 5),
(4, 'Patrick', 'Star', 12.50, 26000, 'cook', '2023-01-05', 5),
(5, 'Sandy', 'Cheeks', 17.25, 35880, 'asst. manager', '2023-01-06', 1),
(6, 'Sheldon', 'Plankton', 10, 20800, 'janitor', '2023-01-07', 5);

INSERT INTO customers (firstname, lastname, email)
VALUES
('Fred','Fish','FFtish@gmail.com '),
('Larry','Lobster', 'LLobster@gmail.com '),
('Bubble','Bass', 'BBass@gmail.com '),
('Poppy','Puff','PPuff@gmail.com'),
('Pearl', 'Krabs', 'PKrabs@gmail.com');
UPDATE customers set referral_id = 1 WHERE customer_id = 2;
UPDATE customers set referral_id = 2 WHERE customer_id = 3;
UPDATE customers set referral_id = 2 WHERE customer_id = 4;

INSERT INTO products
VALUES
(100, 'hamburger', 3.99, 'S3'),
(101, 'fries', 1.89, 'S3'),
(102, 'soda', 1.00, 'S4'),
(103, 'ice cream', 1.49, 'S1');
INSERT INTO products (product_id, product_name, supplied_by)
VALUES
(104, 'straw', 'S1'),
(105, 'napkin', 'S2'),
(106, 'fork', 'S2'),
(107, 'spoon', 'S2');

INSERT INTO transactions (product_id, amount, customer_id, order_date, served_by)
VALUES 
(100, 3.99, 3, '2023-01-01', 2),
(101, 1.89, 2, '2023-01-01', 3),
(102, 1, 2, '2023-01-01', 3),
(101, 1.89, 3, '2023-01-02', 2),
(103, 1.49, 3, '2023-01-02', 4),
(100, 3.99, 1, '2023-01-02', 1),
(102, 1, 1, '2023-01-02', 3),
(102, 1, 4, '2023-01-03', 3),
(103, 1.49, 5, '2023-01-04', 3),
(102, 1, 5, '2023-01-04', 3),
(101, 1.89, 1, '2023-01-05', 2),
(100, 3.99, 5, '2023-01-05', 2),
(100, 3.99, 4, '2023-01-05', 4);

INSERT INTO suppliers
VALUES
('S1', 'Pineapple Co'),
('S2', 'Rocky Goods'),
('S3', 'Chump Supply'),
('S4', 'Sea Store');

-- -------------------------------------------------------------------------------------

ALTER TABLE transactions
ADD CONSTRAINT fk_customer_id
FOREIGN KEY (customer_id) 
REFERENCES customers(customer_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_employees_id
FOREIGN KEY (served_by) 
REFERENCES employees(employee_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_products_id
FOREIGN KEY (product_id) 
REFERENCES products(product_id);

ALTER TABLE products
ADD CONSTRAINT fk_suppliers_id
FOREIGN KEY (supplied_by) 
REFERENCES suppliers(supplier_id);

-- -------------------------------------------------------------------------------------

-- Create Joins:
-- Show all employees and who they are supervised by:
SELECT a.firstname, a.lastname, CONCAT(b.firstname, " ", b.lastname) AS "reports to"
FROM employees AS a
INNER JOIN employees AS b
ON a.supervisor_id = b.employee_id;

-- Include all employees, even if they don't report to anyone:
SELECT a.firstname, a.lastname, CONCAT(b.firstname, " ", b.lastname) AS "reports to"
FROM employees AS a
LEFT JOIN employees AS b
ON a.supervisor_id = b.employee_id;

-- -------------------------------------------------------------------------------------

-- Stored Function:
-- The following CREATE FUNCTION statement creates a function that returns the employee status level based on their hourly_pay:

DELIMITER $$
CREATE FUNCTION employeelevel(hourly_pay DECIMAL(5,2)) 
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
    DECLARE employeelevel VARCHAR(20);

    IF hourly_pay > 20 THEN
		SET employeelevel = 'GOLD';
    ELSEIF (hourly_pay >= 15 AND 
			hourly_pay <= 20) THEN
        SET employeelevel = 'SILVER';
    ELSEIF hourly_pay < 15 THEN
        SET employeelevel = 'BRONZE';
    END IF;
	-- return the Employee Level
	RETURN (employeelevel);
END$$

DELIMITER ;

SELECT firstname, lastname, employeelevel(hourly_pay) FROM employees; 

-- -------------------------------------------------------------------------------------

-- Stored Procedure:
-- Invoke the stored procedure to get a customer’s information:

DELIMITER $$
CREATE PROCEDURE find_customer(IN id INT)
BEGIN  
	SELECT *
	FROM customers
	WHERE customer_id = id;
END $$

DELIMITER ; 

CALL find_customer(1); 
CALL find_customer(2); 
CALL find_customer(3); 
CALL find_customer(4); 
CALL find_customer(5); 

-- -------------------------------------------------------------------------------------

-- Nested query (subquery):
-- Find every employee that has an hourly pay greater than the average pay:
SELECT firstname, lastname, hourly_pay
FROM employees
WHERE hourly_pay > (SELECT AVG(hourly_pay) FROM employees);

-- -------------------------------------------------------------------------------------

-- Trigger
-- Whenever we update an employee’s hourly_pay, I would also like to update the salary automatically with a trigger. I don’t want to have to update each employee’s salary manually.

-- Before update:
SELECT * FROM employees;

-- Create Trigger:
CREATE TRIGGER before_hourly_pay_update 
BEFORE UPDATE ON employees 
FOR EACH ROW
SET NEW.salary = (NEW.hourly_pay * 2080);

-- After update:
UPDATE employees
SET hourly_pay = 50
WHERE employee_id = 1;
SELECT * FROM employees;

-- -------------------------------------------------------------------------------------

-- Group By:
SELECT SUM(amount) AS "Total spent", customer_id
FROM transactions 
GROUP BY customer_id;

-- Group By & Having:
-- Where total spend by each customer is more than £5:
SELECT SUM(amount) AS "Total spent", customer_id
FROM transactions 
GROUP BY customer_id
HAVING SUM(amount) > 5;

-- -------------------------------------------------------------------------------------

-- A view:
-- We're going to spam these people with coupons maybe:
CREATE VIEW customer_emails AS
SELECT email 
FROM customers;
SELECT * FROM customer_emails;

-- -------------------------------------------------------------------------------------

SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM transactions;
SELECT * FROM suppliers;

SELECT * FROM customer_emails;
