--SQL JOIN QUESTIONS
/*
1. Product Catalog Details: 
Write a query to list all products along with their respective 
brand name and category name. Sort the output alphabetically by category, then brand.
*/

SELECT pp.product_name, pb.brand_name, pc.category_name
FROM production.products pp
LEFT JOIN production.brands pb
ON pp.brand_id = pb.brand_id
LEFT JOIN production.categories pc
ON pp.category_id = pc.category_id
ORDER BY pc.category_name, pb.brand_name

/*
2. Customer Order History: 
Retrieve a list of all orders showing the order_id, order_date, 
and the full name of the customer (first_name and last_name) who placed it.
*/

SELECT 
	so.order_id, so.order_date,
	CONCAT(sc.first_name, ' ' ,sc.last_name) as full_name
FROM sales.orders so
LEFT JOIN sales.customers sc
ON so.customer_id = sc.customer_id

/*
3. Store Staff Assignment: 
Display a list of all staff members (first_name, last_name) 
alongside the name of the store they are currently working at.*/

SELECT
	CONCAT(ss.first_name, ' ' ,ss.last_name) AS staff_member,
	sst.store_name
FROM sales.staffs ss
LEFT JOIN sales.stores sst
ON ss.store_id = sst.store_id

/*
4. Out-of-Stock Items: 
Find all products that currently have a quantity of 0 or are completely 
missing from the stock records for a specific store (e.g., 'Santa Cruz Bikes').
*/
SELECT 
	po.product_name, ps.quantity
FROM production.products po
LEFT JOIN production.stocks ps
ON po.product_id = ps.product_id
WHERE ps.quantity = 0 or ps.quantity IS NULL

/*
5. Revenue per Order Item: 
Write a query to calculate the net revenue for every item in 
sales.order_items. Formula: Quantity * List Price * (1 - Discount).
*/

SELECT 
	soi.item_id,
	SUM(soi.quantity * soi.list_price*(1-soi.discount)) AS net_revenue
FROM sales.order_items soi
LEFT JOIN sales.orders so
ON soi.order_id = so.order_id
GROUP BY soi.item_id 
ORDER BY soi.item_id

/*
6. Top Priced Products:
Identify all products that have a list_price greater than the overall 
average list price of all products in the database.
*/

SELECT 
	AVG(list_price) as average_price
FROM production.products

SELECT
	product_name, list_price
FROM production.products
WHERE list_price > (
	SELECT AVG(list_price)
	FROM production.products
	)

/*
 7. Active Customers:
Extract a list of unique customers who have placed at least one order 
where the order_status is completed (4).
*/

SELECT DISTINCT
	sc.customer_id,
	CONCAT(sc.first_name,' ',sc.last_name) as full_name
FROM sales.customers sc
JOIN sales.orders so
ON sc.customer_id = so.customer_id
WHERE order_status = 4

/*
8. Manager Identification: 
List the names of all staff members who are also managers (i.e., 
their staff_id appears in someone else's manager_id column).
*/

SELECT DISTINCT
	CONCAT(ss1.first_name,' ',ss1.last_name) AS manager_name
FROM sales.staffs ss1
JOIN sales.staffs ss2
ON ss1.staff_id = ss2.manager_id;

/*
9. State-wise Sales Hubs: 
Find all stores located in states where more than 50 customers 
reside.
*/

SELECT *
FROM sales.stores ss
WHERE ss.state in 
(
	SELECT state
	FROM sales.customers 
	GROUP BY state
	HAVING COUNT(customer_id) > 150
)

/*
10. Brand Variety: 
Identify which product categories contain products from more than 3 
different brands.
*/

SELECT pc.category_id, COUNT(DISTINCT pb.brand_id) AS total_brands FROM production.products pp
JOIN production.brands pb
ON pb.brand_id = pp.brand_id
JOIN production.categories pc
ON pp.category_id = pc.category_id
GROUP BY pc.category_id
HAVING COUNT(pb.brand_id) > 3


