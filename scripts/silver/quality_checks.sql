/*
===============================================================================
Data Quality Checks: Bronze and Silver Layers
===============================================================================
Purpose:
    This script performs data quality checks on the Bronze and Silver tables.

Checks include:
    - NULL values
    - Duplicate primary keys
    - Unwanted spaces
    - Negative or invalid values
    - Data standardization
    - Invalid dates
    - Invalid relationships between dates
===============================================================================
*/


-- =======================================================
-- CRM CUSTOMER INFO
-- =======================================================

-- =======================================
-- BRONZE: CRM CUSTOMER INFO
-- =======================================

-- Check for NULLs or duplicates in Primary Key
-- Expectation: No results

SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Checking for unwanted spaces
-- Expectation: No results

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- Data Standardization & Consistency
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;


-- =======================================
-- SILVER: CRM CUSTOMER INFO
-- =======================================

-- Check for NULLs or duplicates in Primary Key
-- Expectation: No results

SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Checking for unwanted spaces
-- Expectation: No results

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- Data Standardization & Consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


-- Check for future customer creation dates
SELECT *
FROM silver.crm_cust_info
WHERE cst_create_date > GETDATE();


-- =======================================================
-- CRM PRODUCT INFO
-- =======================================================

-- =======================================
-- BRONZE: CRM PRODUCT INFO
-- =======================================

-- Check for NULLs or duplicates in Primary Key
-- Expectation: No results

SELECT
    prd_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Checking for unwanted spaces
-- Expectation: No results

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Checking NULL or negative cost
-- Expectation: No results

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;


-- Checking different values in the column
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;


-- Check for invalid date ranges
-- Expectation: No results

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- =======================================
-- SILVER: CRM PRODUCT INFO
-- =======================================

-- Check for NULLs or duplicates in Primary Key
-- Expectation: No results

SELECT
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Checking for unwanted spaces
-- Expectation: No results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Checking NULL or negative cost
-- Expectation: No results

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;


-- Checking standardized product lines
-- Expected values:
-- Mountain, Road, Other Sales, Touring, n/a

SELECT DISTINCT prd_line
FROM silver.crm_prd_info;


-- Check for invalid date ranges
-- Expectation: No results

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- =======================================================
-- CRM SALES DETAILS
-- =======================================================

-- =======================================
-- BRONZE: CRM SALES DETAILS
-- =======================================

-- Check for NULL values in Order Number
-- Expectation: No results

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL;


-- Check for NULL values in Product Key
-- Expectation: No results

SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key IS NULL;


-- Check for NULL values in Customer ID
-- Expectation: No results

SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id IS NULL;


-- Check for invalid Order Dates
-- Expectation: No results

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt IS NOT NULL
  AND (
        sls_order_dt = 0
        OR LEN(sls_order_dt) != 8
      );


-- Check for invalid Ship Dates
-- Expectation: No results

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ship_dt IS NOT NULL
  AND (
        sls_ship_dt = 0
        OR LEN(sls_ship_dt) != 8
      );


-- Check for invalid Due Dates
-- Expectation: No results

SELECT *
FROM bronze.crm_sales_details
WHERE sls_due_dt IS NOT NULL
  AND (
        sls_due_dt = 0
        OR LEN(sls_due_dt) != 8
      );


-- Check for invalid sales values
-- Sales should not be negative

SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales < 0;


-- Check for invalid quantities
-- Quantity should normally be greater than 0

SELECT *
FROM bronze.crm_sales_details
WHERE sls_quantity <= 0;


-- Check for invalid prices

SELECT *
FROM bronze.crm_sales_details
WHERE sls_price <= 0;


-- Check whether Sales = Quantity * Price
-- This identifies inconsistent sales calculations

SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales IS NOT NULL
  AND sls_quantity IS NOT NULL
  AND sls_price IS NOT NULL
  AND sls_sales != sls_quantity * ABS(sls_price);


-- =======================================
-- SILVER: CRM SALES DETAILS
-- =======================================

-- Check for NULL values in Order Number
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL;


-- Check for NULL values in Product Key
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL;


-- Check for NULL values in Customer ID
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id IS NULL;


-- Check for invalid dates
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
   OR sls_ship_dt IS NULL
   OR sls_due_dt IS NULL;


-- Check date sequence
-- Order Date should be before Ship Date
-- Ship Date should be before Due Date

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_ship_dt > sls_due_dt;


-- Check for invalid sales values
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <= 0;


-- Check for invalid quantities
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity <= 0;


-- Check for invalid prices
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_price <= 0;


-- Check Sales = Quantity * Price
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * ABS(sls_price);


-- =======================================================
-- ERP CUSTOMER AZ12
-- =======================================================

-- =======================================
-- BRONZE: ERP CUSTOMER AZ12
-- =======================================

-- Check for NULLs or duplicates in Customer ID
-- Expectation: No results

SELECT
    cid,
    COUNT(*) AS duplicate_count
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;


-- Check different values for Gender
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


-- Check for future birth dates
-- Expectation: No results

SELECT *
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();


-- Check for NULL birth dates

SELECT *
FROM bronze.erp_cust_az12
WHERE bdate IS NULL;


-- =======================================
-- SILVER: ERP CUSTOMER AZ12
-- =======================================

-- Check for NULLs or duplicates in Customer ID
-- Expectation: No results

SELECT
    cid,
    COUNT(*) AS duplicate_count
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;


-- Check Gender standardization
-- Expected:
-- Male, Female, n/a

SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- Check for unexpected gender values
-- Expectation: No results

SELECT *
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male', 'Female', 'n/a');


-- Check for future birth dates
-- Expectation: No results

SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


-- Check for unwanted spaces in Customer ID
-- Expectation: No results

SELECT cid
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid);


-- =======================================================
-- ERP LOCATION A101
-- =======================================================

-- =======================================
-- BRONZE: ERP LOCATION A101
-- =======================================

-- Check for NULLs or duplicates in Customer ID
-- Expectation: No results

SELECT
    cid,
    COUNT(*) AS duplicate_count
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;


-- Check for unwanted '-' characters in Customer ID

SELECT cid
FROM bronze.erp_loc_a101
WHERE cid LIKE '%-%';


-- Check different country values

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;


-- Check for NULL or blank countries

SELECT *
FROM bronze.erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';


-- =======================================
-- SILVER: ERP LOCATION A101
-- =======================================

-- Check for NULLs or duplicates in Customer ID
-- Expectation: No results

SELECT
    cid,
    COUNT(*) AS duplicate_count
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;


-- Check for unwanted '-' characters
-- Expectation: No results

SELECT cid
FROM silver.erp_loc_a101
WHERE cid LIKE '%-%';


-- Check country standardization

SELECT DISTINCT cntry
FROM silver.erp_loc_a101;


-- Expected values:
-- Germany
-- United States
-- n/a
-- Other country names

SELECT *
FROM silver.erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';


-- Check for unwanted spaces
-- Expectation: No results

SELECT cntry
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry);


-- =======================================================
-- ERP PRODUCT CATEGORY
-- =======================================================

-- =======================================
-- BRONZE: ERP PX CAT G1V2
-- =======================================

-- Check for NULLs or duplicates in ID
-- Expectation: No results

SELECT
    id,
    COUNT(*) AS duplicate_count
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;


-- Check for unwanted spaces

SELECT cat
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat);


SELECT subcat
FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat);


SELECT maintenance
FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance);


-- Check distinct category values

SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;


-- Check distinct subcategory values

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;


-- Check distinct maintenance values

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;


-- =======================================
-- SILVER: ERP PX CAT G1V2
-- =======================================

-- Check for NULLs or duplicates in ID
-- Expectation: No results

SELECT
    id,
    COUNT(*) AS duplicate_count
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;


-- Check for unwanted spaces

SELECT cat
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat);


SELECT subcat
FROM silver.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat);


SELECT maintenance
FROM silver.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance);


-- Check distinct category values

SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2;


-- Check distinct subcategory values

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;


-- Check distinct maintenance values

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;


-- =======================================================
-- FINAL DATA CHECK
-- =======================================================

-- Check row counts between Bronze and Silver

SELECT 
    'crm_cust_info' AS table_name,
    (SELECT COUNT(*) FROM bronze.crm_cust_info) AS bronze_count,
    (SELECT COUNT(*) FROM silver.crm_cust_info) AS silver_count

UNION ALL

SELECT 
    'crm_prd_info',
    (SELECT COUNT(*) FROM bronze.crm_prd_info),
    (SELECT COUNT(*) FROM silver.crm_prd_info)

UNION ALL

SELECT 
    'crm_sales_details',
    (SELECT COUNT(*) FROM bronze.crm_sales_details),
    (SELECT COUNT(*) FROM silver.crm_sales_details)

UNION ALL

SELECT 
    'erp_cust_az12',
    (SELECT COUNT(*) FROM bronze.erp_cust_az12),
    (SELECT COUNT(*) FROM silver.erp_cust_az12)

UNION ALL

SELECT 
    'erp_loc_a101',
    (SELECT COUNT(*) FROM bronze.erp_loc_a101),
    (SELECT COUNT(*) FROM silver.erp_loc_a101)

UNION ALL

SELECT 
    'erp_px_cat_g1v2',
    (SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2),
    (SELECT COUNT(*) FROM silver.erp_px_cat_g1v2);
