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


-- ======= Check for tables silver.crm_sales_details
-- Check for Invalid Date Orders
-- Expectations: No Result
SELECT * 
FROM silver.crm_sales_details;

-- Check for NULL in key columns
-- Expectation: No Result
SELECT
	sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL

SELECT
	sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL

SELECT
	sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id IS NULL

-- Check for invalid date 
-- Expectation: No Results

SELECT
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt 


-- Check valid price, quantity, and sales
-- Expectation: No Results

select 
	*
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
   or sls_sales is null or sls_quantity is null or sls_price is null
   or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0


-- =========================================
-- Check for tables silver.erp_cust_az12

-- bdate invalid values
select
	*
from silver.erp_cust_az12
where DATEDIFF(year,GETDATE(),bdate) > 100
   OR DATEDIFF(year,bdate,GETDATE()) > 100

-- check for invalid cid
select *
from silver.erp_cust_az12
where cid like 'NA%'

-- Check for inconsistency and invalid gen
select distinct gen 
from silver.erp_cust_az12


-- =========================================
-- Check for tables silver.erp_loc_a101

-- Check duplicate values
-- Expectation: No Results
SELECT 
	cid,
	COUNT(cid)
FROM silver.erp_loc_a101
group by cid
having COUNT(cid) > 1


-- Check invalid cid
-- Expectation: No Results
SELECT 
	cid
FROM silver.erp_loc_a101
WHERE LEN(cid) != 10

-- Check invalid cntry 
-- Expectation: No duplicates and consistence

select 
	DISTINCT cntry
from silver.erp_loc_a101 


select cid 
from silver.erp_loc_a101 s
where not exists(
	select 1
	from silver.crm_cust_info s1
	where s.cid = s1.cst_key
)

-- =========================================
-- Check for tables silver.erp_px_cat_g1v2

-- Check for unwanted space in category, sub-category columns
-- Expected: No Result

select * 
from bronze.erp_px_cat_g1v2
where cat != TRIM(cat)
   or subcat != TRIM(subcat)
   or maintenance != TRIM(maintenance)

-- Check for inconsitence 
-- Expected: No Result

select 
	DISTINCT cat
from bronze.erp_px_cat_g1v2

select 
	DISTINCT subcat
from bronze.erp_px_cat_g1v2

select distinct maintenance
from bronze.erp_px_cat_g1v2


select id 
from bronze.erp_px_cat_g1v2 e
where not exists (
	select 1 
	from silver.crm_prd_info c
	where trim(e.id) = c.category_id
)

