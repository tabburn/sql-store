-- Return all the products including the name of the product, the unit price, and the new price (unit price * 1.1).
SELECT
	name,
    unit_price,
    unit_price * 1.1 AS new_price
FROM products;

-- Retrieve all the orders placed in 2019.
SELECT *
FROM orders
WHERE order_date >= '2019-01-01';

-- From the order_items table, get the items from order #6 where the total price is greater than 30.
SELECT *
FROM order_items
WHERE order_id = 6 AND (unit_price * quantity) > 30;

-- Return products where the quantity in stock is equal to 49, 38, or 72.
SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72);

-- Return customers born between 1/1/1990 and 1/1/2000.
SELECT *
FROM customers
WHERE birth_date BETWEEN '1990-01-01' AND '2000-01-01';

-- Return the customers whose address contain TRAIL or AVENUE.
SELECT *
FROM customers
WHERE address LIKE '%TRAIL%' OR 
	  address LIKE '%AVENUE%';

-- Return the customers whose phone number ends with 9.
SELECT *
FROM customers
WHERE phone LIKE '%9';

-- Return the customers whose first names are ELKA or AMBUR.
SELECT *
FROM customers
WHERE first_name REGEXP 'elka|ambur';

-- Return the customers whose last names end with EY or ON.
SELECT *
FROM customers
WHERE last_name REGEXP 'ey$|on$';

-- Return the customers whose last names start with MY or contains SE.
SELECT *
FROM customers
WHERE last_name REGEXP '^my|se';

-- Return the customer whose last names contain B followed by R or U.
SELECT *
FROM customers
WHERE last_name REGEXP 'b[ru]';

-- Get the orders that are not yet shipped.
SELECT *
FROM orders
WHERE shipped_date IS NULL;

-- Write a query to return order #2 sorted by total price.
SELECT *, quantity * unit_price AS total_price
FROM order_items
WHERE order_id = 2
ORDER BY total_price DESC;

-- Get the top three loyal customers.
SELECT *
FROM customers
ORDER BY points DESC
LIMIT 3;

-- Write a query that joins the order_items table with the products table such that each order displays the product_id, the name of the product, quantity, and unit price.
SELECT order_id, oi.product_id, name, quantity, oi.unit_price -- unit price taken from order_items table because it was the price taken at the time of the order
FROM order_items oi
JOIN products p
	ON p.product_id = oi.product_id;
    
-- Write a query that joins the payments table with the payment_methods table and includes the client's id and name. The report should produce client name, id, and payment method.
USE sql_invoicing;

SELECT
	p.date,
    p.invoice_id,
    p.amount,
    c.name,
    pm.name AS payment_method
FROM payments p
JOIN clients c
	ON p.client_id = c.client_id
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id;
    
-- Write a query that produces product_id, name, and quantity.
USE sql_store;

SELECT
	p.product_id,
    p.name,
    oi.quantity
FROM products p
LEFT JOIN order_items oi
	ON oi.product_id = p.product_id;
    
-- Write a query that returns the order_date, order_id, first_name, shipper (even if none exists), and status.
SELECT
	o.order_date,
    o.order_id,
    c.first_name,
    sh.name AS shipper,
    os.name AS status
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
LEFT JOIN shippers sh
	ON o.shipper_id = sh.shipper_id
LEFT JOIN order_statuses os
	ON o.status = os.order_status_id
ORDER BY status;

-- Write a query to select the payments from the payments table and include the date, client, amount, and payment method.
USE sql_invoicing;

SELECT
	p.date,
    c.name AS client,
    p.amount,
    pm.name AS payment_method
FROM clients c
JOIN payments p
	USING (client_id)
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id;
    
-- Do a cross join between shippers and products. Write a query using implicit syntax and the using explicit syntax.
SELECT *
FROM shippers sh, products p; -- implicit

SELECT *
FROM shippers sh
CROSS JOIN products p; -- explicit

-- Write a query to produce a report of four columns: customer_id, first_name, points, and type.
SELECT
	customer_id,
    first_name,
    points,
    'Bronze' AS type
FROM customers
WHERE points < 2000
UNION
SELECT
	customer_id,
    first_name,
    points,
    'Silver' AS type
FROM customers
WHERE points BETWEEN 2000 AND 3000
UNION
SELECT
	customer_id,
    first_name,
    points,
    'Gold' AS type
FROM customers
WHERE points >= 3000
ORDER BY first_name;

-- Write a statement to insert three rows in the products table.
INSERT INTO products (name, quantity_in_stock, unit_price)
VALUES ('Product1', 10, 1.95),
	   ('Product2', 10, 1.95),
       ('Product3', 10, 1.95);

SELECT *
FROM products;

-- Write a query and subquery that creates a new table 'invoices_archived' which joins the invoices table and the client table
-- to create an additional name column using only records that have a payment.
USE sql_invoicing;

CREATE TABLE invoices_archived AS
SELECT
	i.invoice_id,
    i.number,
    c.name AS client,
    i.invoice_total,
    i.payment_total,
    i.invoice_date,
    i.payment_date,
    i.due_date
FROM invoices i
JOIN clients c
	USING (client_id)
WHERE payment_date IS NOT NULL;

-- Write a SQL statement to give any customers born before 1990 50 extra points.
USE sql_store;

UPDATE customers
SET points = points + 50
WHERE birth_date < '1990-01-01';

-- Write a SQL statement to update the comments column in the orders table for the customers that have more than 3000 points, noting that they are a gold customer.
USE sql_store;

UPDATE orders
SET comments = 'Gold Customer'
WHERE customer_id IN
		(SELECT customer_id
		FROM customers
		WHERE points > 3000);
        