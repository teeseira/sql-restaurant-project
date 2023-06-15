# Restaurant Database

### by Tidi Matthias

#### 1. What is the total amount each customer spent at the restaurant?




## Questions and Answers
#### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT s.customer_id AS c_id,
	SUM(m.price) AS total_spent
FROM sales AS s
	JOIN menu AS m ON s.product_id = m.product_id
GROUP BY c_id
ORDER BY total_spent DESC;
````

**Results:**

c_id|total_spent|
----|-----------|
A   |         76|
B   |         74|
C   |         36|

