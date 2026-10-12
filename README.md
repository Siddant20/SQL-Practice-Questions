### SQL Practice & Solutions: BikeStores E-Commerce Database

Welcome to my SQL practice repository! This collection documents my progress, solution patterns, and query optimizations based on the BikeStores relational e-commerce database schema.

The goal of this repository is to demonstrate proficiency in writing clean, readable, and efficient standard SQL code to solve practical business analytics problems.

## Schemas & Tables:

# sales Schema:

-customers: Customer details and location information.

-orders: Order dates, status, fulfillment stores, and sales staff IDs.

-order_items: Order line items detailing product quantities, list prices, and discounts.

-stores: Physical store location data.

-staffs: Employee info, management relationships, and store assignments.

# production Schema:

-categories: Product category listings.

-brands: Brand names and identifier data.

-products: Master product table with pricing and relationships.

-stocks: Real-time product inventory levels per store location.

## 💡 Key SQL Concepts & Patterns Covered

This repository demonstrates mastery over several essential SQL querying techniques:

1. Multi-Table Relational Joins

Combining data across schema boundaries using inner joins across relational primary/foreign keys (brand_id, product_id, store_id, order_id).

2. Group Aggregation & Threshold Filtering

Grouping data across entities (GROUP BY) and applying criteria to aggregated totals using the HAVING clause (e.g., filtering categories with total stock exceeding 500 items, or brands selling over 100 total units).

3. Business Revenue & Financial Calculations

Potential vs. Actual Revenue: Calculating un-discounted potential sales versus discounted real sales.

Discount Impact Analysis: Quantifying revenue lost due to promotional discounts (quantity * list_price * discount).

4. Data Transformation & Formatting

String Manipulations: Standardizing full names using CONCAT(first_name, ' ', last_name).

Conditional Categorization: Multi-branch conditional logic using CASE WHEN constructs (e.g., segmenting products into 'Budget', 'Mid-Range', and 'Premium' pricing tiers).

📝