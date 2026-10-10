---------------------------------------------
-- Cumulative Analysis
---------------------------------------------
-- Calculate the total sales per month 
-- and the running total of sales over time

SELECT 
order_date,
total_sales,
--window func
SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM(
	SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	-- ORDER BY DATETRUNC(MONTH, order_date) gives issue with the window function
) value_returned

-- Calculate yearly sales and the running total of sales over time

SELECT 
order_date,
total_sales,
--window func
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales
FROM(
	SELECT
	DATETRUNC(YEAR, order_date) AS order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date)
	-- ORDER BY DATETRUNC(MONTH, order_date) gives issue with the window function
) value_returned

-- Calculate yearly sales, running total sales, and moving average price

SELECT 
order_date,
total_sales,
--window func
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
FROM(
	SELECT
	DATETRUNC(YEAR, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date)
	-- ORDER BY DATETRUNC(MONTH, order_date) gives issue with the window function
) value_returned
