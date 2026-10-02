/*
Analysis: Top and Bottom Performing Products and Customers

Purpose:
This script analyzes sales performance in the Gold layer to identify:
- Products generating the highest total revenue.
- Products generating the lowest total revenue.
- Customers generating the highest total revenue.
- Customers with the lowest number of orders.
- Product and customer rankings using SQL window functions.

*/

-- Uses ROW_NUMBER() to rank products based on total revenue.
-- Returns the top 5 products with the highest revenue.
SELECT TOP 5
pro.product_name,
SUM(fact.sales_amount) AS total_revenue
FROM gold.fact_sales fact
LEFT JOIN gold.dim_products pro
ON pro.product_key = fact.product_key
GROUP BY pro.product_name
ORDER BY total_revenue DESC

-- Window function for the same:
-- Uses ROW_NUMBER() to rank products based on total revenue.
-- Returns the top 5 products with the highest revenue.
SELECT *
FROM (
SELECT
pro.product_name,
SUM(fact.sales_amount) AS total_revenue,
ROW_NUMBER() OVER(ORDER BY SUM(fact.sales_amount) DESC) AS rank_products
FROM gold.fact_sales fact
LEFT JOIN gold.dim_products pro
ON pro.product_key = fact.product_key
GROUP BY pro.product_name
) val
WHERE rank_products <= 5

-- LAST 5
-- Finds the 5 products with the lowest total revenue.
-- Sorts products from lowest to highest revenue.
SELECT TOP 5
pro.product_name,
SUM(fact.sales_amount) AS total_revenue
FROM gold.fact_sales fact
LEFT JOIN gold.dim_products pro
ON pro.product_key = fact.product_key
GROUP BY pro.product_name
ORDER BY total_revenue

-- Finds the top 10 customers based on total revenue.
-- Sorts customers from highest to lowest revenue.
SELECT TOP 10
cus.customer_key,
cus.first_name,
cus.last_name,
SUM(fact.sales_amount) AS total_revenue
FROM gold.fact_sales fact
LEFT JOIN gold.dim_customers cus
ON cus.customer_key = fact.customer_key
GROUP BY cus.customer_key,cus.first_name, cus.last_name
ORDER BY total_revenue DESC

-- Uses ROW_NUMBER() to rank customers based on total revenue.
-- Returns the top 10 customers with the highest revenue.
SELECT *
FROM (
SELECT
cus.customer_key,
cus.first_name,
cus.last_name,
SUM(fact.sales_amount) AS total_revenue,
ROW_NUMBER() OVER(ORDER BY SUM(fact.sales_amount) DESC) AS rank_customers
FROM gold.fact_sales fact
LEFT JOIN gold.dim_customers cus
ON cus.customer_key = fact.customer_key
GROUP BY cus.customer_key,cus.first_name, cus.last_name
) val
WHERE rank_customers <= 10

-- Finds the 3 customers with the fewest unique orders.
-- Counts distinct orders for each customer and sorts from lowest to highest.
SELECT TOP 3
cus.customer_key,
cus.first_name,
cus.last_name,
COUNT(DISTINCT (fact.order_number)) AS total_orders
FROM gold.fact_sales fact
LEFT JOIN gold.dim_customers cus
ON cus.customer_key = fact.customer_key
GROUP BY cus.customer_key,cus.first_name, cus.last_name
ORDER BY total_orders
