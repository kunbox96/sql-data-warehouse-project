/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script perform various quality checks for data uniqueness, data 
    connectivity between various dims and fact table

Usage Notes:
    - Run these checks after refresh views with v_load_gold procedure
	- Investigate and resolve any discrepancies found during the checks.

Usage Example:
    USE MyDataWarehouse; EXEC gold.v_load_gold;
===============================================================================
*/

-- Check for Uniqueness of Customer Key in gold.dim_product
-- Expectation: No Result
SELECT product_key, COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No Result
SELECT customer_key, COUNT(*)
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- Check for connectivity between fact_sales with 2 dim table

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON        f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON        f.product_key = p.product_key
