
-------------------- QC for table crm_cust_info -----------------------

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

-- Duplicate values
WITH tmp AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
	FROM silver.crm_cust_info
)

SELECT *
FROM tmp
WHERE rn > 1 
  AND cst_id IS NOT NULL
ORDER BY cst_id;

-- Check for unwanted spaces
-- Expectations: No Result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Check inconsistency 
-- Expectations: No Result
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
GROUP BY cst_gndr


SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
GROUP BY cst_marital_status

-------------------- QC for table crm_prd_info -----------------------
SELECT * FROM bronze.crm_prd_info

-- Check for unwanted spaces
-- Expectations: No Result
SELECT 
	*
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check for logic problem
-- Expectations: No Result
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Check for Invalid Date Orders
-- Expectations: No Result
SELECT * 

SELECT * FROM bronze.crm_sales_details

SELECT * FROM bronze.erp_px_cat_g1v2

