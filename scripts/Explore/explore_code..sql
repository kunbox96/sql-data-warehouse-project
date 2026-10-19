SELECT TOP 1000 * FROM bronze.crm_sales_details;
SELECT TOP 1000 * FROM bronze.crm_cust_info;
SELECT TOP 1000 * FROM bronze.erp_cust_az12;

SELECT TOP 1000 * FROM bronze.erp_loc_a101
SELECT TOP 1000 * FROM bronze.crm_cust_info;

SELECT TOP 1000 *,'crm_prd_info' as derived_table FROM bronze.crm_prd_info;
SELECT TOP 1000 *, 'erp_px_cat_g1v2' as derived_table FROM bronze.erp_px_cat_g1v2;

SELECT RIGHT(cid, 5) FROM bronze.erp_cust_az12
SELECT * 
FROM bronze.crm_prd_info crm_p
JOIN bronze.erp_px_cat_g1v2 erp_p
  ON REPLACE(LEFT(crm_p.prd_key, 5),'-','_') = erp_p.id;



SELECT COUNT(DISTINCT prd_key) FROM bronze.crm_prd_info
SELECT COUNT(DISTINCT sls_prd_key) FROM bronze.crm_sales_details
SELECT COUNT(*) FROM bronze.crm_sales_details
--BK-R93R-62
SELECT 
	--p.*,
	--s.sls_quantity
	COUNT(*)
FROM bronze.crm_prd_info p
LEFT JOIN bronze.crm_sales_details s
	ON p.prd_key = s.sls_prd_key



