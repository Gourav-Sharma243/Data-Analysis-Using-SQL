-------------------------------------
-- Performace Analysis
-------------------------------------
/* Aanalyze the yearly performance of the products by comparing their sales 
   to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS(
SELECT	
 YEAR(f.order_date) AS order_year,
 p.product_name,
 SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY 
YEAR(f.order_date),
p.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE 
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
	ELSE 'Average'
END avg_change,
-- Year over year Analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) prev_year_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev_year_sales,
CASE 
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	ELSE 'No Change'
END prev_year_change
FROM yearly_product_sales
ORDER BY product_name, order_year
