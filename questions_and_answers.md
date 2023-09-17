# Restaurant Database

### by Tidi-Seira

[**Click here to review or load up my SQL script**](https://github.com/teeseira/sql-restaurant-project/blob/main/restaurant%20sql%20script.sql)

## Tasks
#### Joins
Show all employees and who they are supervised by:
````sql
SELECT a.firstname, a.lastname, CONCAT(b.firstname, " ", b.lastname) AS "reports to"
FROM employees AS a
INNER JOIN employees AS b
ON a.supervisor_id = b.employee_id;
````
firstname |lastname    |reports to
----------|------------|------------
Squidward | Tentacles  | Sandy Cheeks
Spongebob | Squarepants| Sandy Cheeks
Patrick   | Star       | Sandy Cheeks
Sandy     | Cheeks     | Eugene Krabs
Sheldon   | Plankton   | Sandy Cheeks

Include all employees, even if they don't report to anyone:
````sql
SELECT a.firstname, a.lastname, CONCAT(b.firstname, " ", b.lastname) AS "reports to"
FROM employees AS a
LEFT JOIN employees AS b
ON a.supervisor_id = b.employee_id;
````
firstname |lastname    |reports to
----------|------------|------------
Eugene    | Krabs      | 
Squidward | Tentacles  | Sandy Cheeks
Spongebob | Squarepants| Sandy Cheeks
Patrick   | Star       | Sandy Cheeks
Sandy     | Cheeks     | Eugene Krabs
Sheldon   | Plankton   | Sandy Cheeks

#### Stored Function
The following CREATE FUNCTION statement creates a function that returns the employee status level based on their hourly_pay:
````sql
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
````
firstname |lastname    |employeelevel(hourly_pay)
----------|------------|------------
Eugene    | Krabs      | GOLD
Squidward | Tentacles  | SILVER
Spongebob | Squarepants| BRONZE
Patrick   | Star       | BRONZE
Sandy     | Cheeks     | SILVER
Sheldon   | Plankton   | BRONZE

#### Stored Procedure
Invoke the stored procedure to get a customer’s information:
````sql
DELIMITER $$
CREATE PROCEDURE find_customer(IN id INT)
BEGIN  
	SELECT *
	FROM customers
	WHERE customer_id = id;
END $$

DELIMITER ; 

CALL find_customer(5); 
````
customer_id |firstname   | lastname  | email             | referral_id
------------|------------|-----------|------------------ |----------
1           | Fred       | Fish      | FFtish@gmail.com  | 


````sql
CALL find_customer(2); 
````
customer_id |firstname   | lastname  | email               | referral_id
------------|------------|-----------|-------------------- |----------
2           | Larry      | Lobster   | LLobster@gmail.com  | 1

````sql
CALL find_customer(3); 
````
customer_id |firstname   | lastname  | email               | referral_id
------------|------------|-----------|-------------------- |----------
3           | Bubble     | Bass      | BBass@gmail.com     | 2

````sql
CALL find_customer(4); 
````
customer_id |firstname   | lastname  | email               | referral_id
------------|------------|-----------|-------------------- |----------
4           | Poppy      | Puff      | PPuff@gmail.com     | 2

````sql
CALL find_customer(5); 
````
customer_id |firstname   | lastname  | email               | referral_id
------------|------------|-----------|-------------------- |----------
5           | Pearl      | Krabs     | PKrabs@gmail.com    | 

#### Nested Query (Subquery)
Find every employee that has an hourly pay greater than the average pay:
````sql
SELECT firstname, lastname, hourly_pay
FROM employees
WHERE hourly_pay > (SELECT AVG(hourly_pay) FROM employees);
````
firstname |lastname    |hourly_pay
----------|------------|------------
Eugene    | Krabs      | 50.00

#### Trigger
Whenever I update the employee’s hourly_pay, I would also like to update the salary automatically with a trigger. I don’t want to have to update each employee’s salary manually.

Before updating Mr Krab's hourly pay:
````sql
SELECT * FROM employees;
````
employee_id|firstname	|lastname    |hourly_pay |salary       |job	        |hire_date |supervisor_id
-----------|------------|------------|-----------|-------------|---------------|-----------|-------------
1	   |Eugene	|Krabs	     |**25.5**	 |**53040**    |manager        |02/01/2023 |NULL
2	   |Squidward	|Tentacles   |15	 |31200        |cashier        |03/01/2023 |5
3	   |Spongebob	|Squarepants |12.5	 |26000	       |cook	       |04/01/2023 |5
4	   |Patrick	|Star	     |12.5	 |26000	       |cook	       |05/01/2023 |5
5	   |Sandy	|Cheeks	     |17.25	 |35880	       |asst. manager  |06/01/2023 |1
6	   |Sheldon	|Plankton    |10	 |20800	       |janitor	       |07/01/2023 |5

Create Trigger:
````sql
CREATE TRIGGER before_hourly_pay_update 
BEFORE UPDATE ON employees 
FOR EACH ROW
SET NEW.salary = (NEW.hourly_pay * 2080);
````

After updating Mr Krab's hourly pay to £50:
````sql
UPDATE employees
SET hourly_pay = 50
WHERE employee_id = 1;
SELECT * FROM employees;
````
employee_id|firstname	|lastname    |hourly_pay |salary      |job	     |hire_date  |supervisor_id
-----------|------------|------------|-----------|------------|--------------|-----------|-------------
1	   |Eugene	|Krabs	     |**50.00**	 |**104,000** |manager       |02/01/2023 |NULL
2	   |Squidward	|Tentacles   |15	 |31200       |cashier       |03/01/2023 |5
3	   |Spongebob	|Squarepants |12.5	 |26000	      |cook	     |04/01/2023 |5
4	   |Patrick	|Star	     |12.5	 |26000	      |cook	     |05/01/2023 |5
5	   |Sandy	|Cheeks	     |17.25	 |35880	      |asst. manager |06/01/2023 |1
6	   |Sheldon	|Plankton    |10	 |20800	      |janitor	     |07/01/2023 |5

#### Group By
````sql
SELECT SUM(amount) AS "Total spent", customer_id
FROM transactions 
GROUP BY customer_id;
````

Total Spent|customer_id
-----------|-----------
2.89       |       2
7.37       |       3
4.99       |       4
6.48       |       5

#### Group By & Having
Where total spend by each customer is more than £5:
````sql
SELECT SUM(amount) AS "Total spent", customer_id
FROM transactions 
GROUP BY customer_id
HAVING SUM(amount) > 5;
````
Total Spent|customer_id
-----------|-----------
6.88       |       1
7.37       |       3
6.48       |       5

#### Views
Create a simple view for customer’s email. This is useful for me because I can use this information to spam customers with coupons, discounts, rewards etc.
````sql
CREATE VIEW customer_emails AS
SELECT email 
FROM customers;
SELECT * FROM customer_emails;
````

email               |
--------------------|
FFtish@gmail.com    |
LLobster@gmail.com  | 
BBass@gmail.com     |  
PPuff@gmail.com     |
PKrabs@gmail.com    |

### Bonus Questions and Answers
#### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT t.customer_id AS c_id,
	SUM(p.price) AS total_spent
FROM transactions AS t
	JOIN products AS p ON t.product_id = p.product_id
GROUP BY c_id
ORDER BY total_spent DESC;

````

c_id|total_spent|
----|-----------|
3   |       7.37|
1   |       6.88|
5   |       6.48|
4   |       4.99|
2   |       2.89|


#### 2. What is the most purchased item on the menu and how many times was it purchased by all customers?
````sql
SELECT p.product_name,
	COUNT(t.product_id) AS most_purchased
FROM products AS p
	JOIN transactions AS t ON p.product_id = t.product_id
GROUP BY p.product_name
ORDER BY most_purchased DESC
LIMIT 1;
````

product_name|most_puchased|
------------|-------------|
soda        |            4|
