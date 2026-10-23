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

/*
13. Staff vs. Manager Hierarchy: 
Write a query using a self-join to display every staff 
member's name along with their direct manager's name. Include staff who do not have a 
manager.
*/

--join
SELECT CONCAT(ss1.first_name, ' ', ss1.last_name) AS staff_name, CONCAT(ss2.first_name, ' ',ss2.last_name) AS manager_name
FROM sales.staffs ss1
LEFT JOIN sales.staffs ss2
ON ss1.manager_id = ss2.staff_id;

--subquery
SELECT CONCAT(ss1.first_name, ' ', ss1.last_name) AS staff_name,
(
	SELECT	CONCAT(ss2.first_name, ' ', ss2.last_name) AS manager_name
	FROM sales.staffs ss2
	WHERE ss1.manager_id = ss2.staff_id
) AS manager_name
FROM sales.staffs ss1

/*
14. Dead Inventory Detection: 
Identify brands that have products in the production.products 
table but have never been sold in any order.
*/

SELECT pb.brand_name, COUNT(soi.order_id) AS total_orders FROM production.brands pb
LEFT JOIN production.products pp
ON pp.brand_id = pb.brand_id
LEFT JOIN sales.order_items soi
ON soi.product_id = pp.product_id
GROUP BY pb.brand_name
HAVING  COUNT(soi.order_id) = 0
AND COUNT (pp.product_id) > 0 

SELECT pb.brand_name
FROM production.brands pb
WHERE EXISTS
(
	SELECT 1 FROM production.products pp
	WHERE pp.brand_id = pb.brand_id
)
AND NOT EXISTS
(
	SELECT 1 FROM production.products pp
	JOIN sales.order_items soi
	ON pp.product_id = soi.product_id
)


/*
15. Store Performance Summary: 
For each store, calculate the total number of orders 
handled, total items sold, and total revenue generated.
*/

SELECT ss.store_name, 
COUNT(distinct so.order_id) as total_orders,
SUM(soi.quantity) as total_items,
SUM(soi.list_price * soi.quantity* (1-soi.discount)) AS total_revenue
FROM sales.stores ss
JOIN sales.orders so
ON so.store_id = ss.store_id
JOIN sales.order_items soi
ON so.order_id = soi.order_id
GROUP BY ss.store_name

/*
16. Delayed Shipments Analysis: 
Find orders that took longer to ship than expected 
(shipped_date > required_date). Show the order details, the customer's email, and how 
many days it was delayed.
*/

SELECT 
so.order_id, 
so.order_date,
so.order_status,
so.required_date,
so.shipped_date,
sc.email,
DATEDIFF(DAY, required_date, shipped_date) AS delayed_days
FROM sales.orders so
JOIN sales.customers sc
ON sc.customer_id = so.customer_id
WHERE DATEDIFF(DAY, required_date, shipped_date) > 0
ORDER BY delayed_days DESC;


/*
17. Most Popular Category per Store: 
Write a query to find which product category has the 
highest number of units sold for each individual store
*/

WITH store_category_sales AS (
	SELECT 
	ss.store_id,
	ss.store_name,
	pc.category_name,
	SUM(soi.quantity) AS total_units
	FROM production.categories pc
	JOIN production.products pp
	ON pc.category_id = pp.category_id
	JOIN sales.order_items soi
	ON soi.product_id= pp.product_id
	JOIN sales.orders so
	ON soi.order_id = so.order_id
	JOIN sales.stores ss
	ON ss.store_id = so.store_id
	GROUP BY ss.store_id, ss.store_name, pc.category_name
)
SELECT * FROM
	(SELECT store_id, store_name,category_name, total_units,
	ROW_NUMBER() OVER(Partition BY store_id ORDER BY total_units DESC) AS rank_num
	FROM store_category_sales) AS ranked_categories
	WHERE rank_num = 1

/*
18. Stock Shortage Warning:
Find products where the total stock across all stores is less than 
the total quantity of that product ordered in the last 30 days of the data history.
*/

WITH 
	total_stock AS (
		SELECT ps.product_id, pp.product_name, SUM(quantity) AS total_stock
		FROM production.stocks ps
		JOIN production.products pp
		ON ps.product_id = pp.product_id
		GROUP BY ps.product_id, pp.product_name
	),
	recent_sales AS (
		SELECT pp.product_id, pp.product_name, SUM(soi.quantity) As total_orders 
		FROM sales.orders so
		JOIN sales.order_items soi
		ON soi.order_id = so.order_id
		JOIN production.products pp
		ON pp.product_id = soi.product_id
		WHERE order_date >= DATEADD( DAY, -30, (SELECT MAX(order_date) FROM sales.orders))
		GROUP BY pp.product_id, pp.product_name
	)
SELECT ts.product_id, ts.product_name, ts.total_stock, rs.total_orders
FROM total_stock ts
JOIN recent_sales rs
ON ts.product_id = rs.product_id
WHERE rs.total_orders > ts.total_stock


