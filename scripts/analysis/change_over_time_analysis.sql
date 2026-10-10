-------------------------------------
-- Change Over Time Analysis
-------------------------------------

-- Comment: Calculate total sales, unique customers, and quantity for each year and month
SELECT 
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customer,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)


-- Comment: Calculate total sales, unique customers, and quantity for each month using DATETRUNC
SELECT 
DATETRUNC(MONTH, order_date),
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customer,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date)


-- Comment: Calculate total sales, unique customers, and quantity for each year using DATETRUNC
SELECT 
DATETRUNC(YEAR, order_date),
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customer,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
ORDER BY DATETRUNC(YEAR, order_date)


-- Comment: Calculate monthly sales, unique customers, and quantity using a formatted year-month label (e.g., 2025-Jan)
SELECT 
FORMAT(order_date,'yyyy-MMM'),
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customer,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date,'yyyy-MMM')
