# /*

# Analysis: Database Exploration and Business Metrics

Purpose:
This script explores the structure and contents of the Gold layer and
calculates key business metrics, including:
- Available tables and columns.
- Product categories and subcategories.
- Sales date ranges.
- Customer age ranges.
- Overall sales, quantity, price, order, product, and customer metrics.
- A summary report containing the main business KPIs.

===============================================================================
*/

-- View all tables available in the database.
-- Helps understand the tables available for analysis.
SELECT
*
FROM INFORMATION_SCHEMA.TABLES

-- View the column information for the dim_products table.
-- Helps inspect the structure and available fields in the product dimension.
SELECT
*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products'

-- Explore the product hierarchy by viewing unique category,
-- subcategory, and product combinations.
SELECT DISTINCT
category,
subcategory,
product_name
FROM gold.dim_products
ORDER BY 1,2,3

-- Determine the first and last order dates in the sales data.
-- Calculates the total range of sales data in years.
SELECT
MIN(order_date) first_order_date,
MAX(order_date) last_order_date,
DATEDIFF(YEAR, MIN(order_date),MAX(order_date)) AS order_range_year
FROM gold.fact_sales

-- Determine the first and last order dates in the sales data.
-- Calculates the total range of sales data in months.
SELECT
MIN(order_date) first_order_date,
MAX(order_date) last_order_date,
DATEDIFF(MONTH, MIN(order_date),MAX(order_date)) AS order_range_month
FROM gold.fact_sales

-- Find the oldest and youngest customers based on their birthdates.
-- Calculates their approximate ages using the current date.
SELECT
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS oldest_age,
MAX(birthdate) AS young_birthdate,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers

-- EXPLORING MEASURES

-- Calculate the total sales revenue across all sales records.
SELECT
SUM(sales_amount) AS total_sales
FROM gold.fact_sales

-- Calculate the total quantity of items sold.
SELECT
SUM(quantity) AS total_quantity
FROM gold.fact_sales

-- Calculate the average selling price across all sales records.
SELECT
AVG(price) AS average_price
FROM gold.fact_sales

-- Count the total number of order records.
SELECT
COUNT(order_number) AS total_orders
FROM gold.fact_sales

-- Count the number of unique orders.
SELECT
COUNT(DISTINCT(order_number)) AS total_orders
FROM gold.fact_sales

-- Count the total number of product records.
SELECT
COUNT(product_key) AS total_products
FROM gold.dim_products

-- Count the number of unique products.
SELECT
COUNT(DISTINCT(product_key)) AS total_products
FROM gold.dim_products

-- Count the total number of customer records.
SELECT
COUNT(customer_id) AS total_customers
FROM gold.dim_customers

-- Count the number of unique customers.
SELECT
COUNT(DISTINCT(customer_key)) AS total_customers
FROM gold.dim_customers

-- Count the number of unique customers who have placed at least one order.
-- Uses the fact table to identify customers with sales activity.
SELECT
COUNT(DISTINCT(customer_key)) AS total_customers
FROM gold.fact_sales

-- Generate Report that shows all key metrics of the business

-- Combine the main business metrics into a single summary report.
-- Each UNION ALL adds another business measure to the final result.
SELECT
'Total Sales' AS measure_name,
SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
'Total Quantity',
SUM(quantity)
FROM gold.fact_sales

UNION ALL

SELECT
'Average Price',
AVG(price)
FROM gold.fact_sales

UNION ALL

SELECT
'Total # of Orders',
COUNT(DISTINCT(order_number)) AS total_orders
FROM gold.fact_sales

UNION ALL

SELECT
'Total # of Products',
COUNT(product_key) AS total_products
FROM gold.dim_products

UNION ALL

SELECT
'Total # of customers',
COUNT(customer_id) AS total_customers
FROM gold.dim_customers
