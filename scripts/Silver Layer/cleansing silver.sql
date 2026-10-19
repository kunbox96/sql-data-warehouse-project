WITH tmp AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
	FROM bronze.crm_cust_info
)

-- Cleansing for crm_cust_info
INSERT INTO silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname, 
	cst_marital_status,
	cst_gndr,
	cst_create_date
)

SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname, --
	CASE 
		WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Married'
		WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Single'
		ELSE 'Unknown'
	END AS cst_marital_status, -- 
	CASE 
		WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
		WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'Unknomn'
	END AS cst_gndr, -- 
	cst_create_date
FROM tmp
WHERE rn = 1 
  AND cst_id IS NOT NULL



------------ Cleansing and Insert data for table silver.crm_prd_info --------------

INSERT INTO silver.crm_prd_info (
    prd_id       ,
    prd_key      ,
	category_id  ,
    prd_nm       ,
    prd_cost     ,
    prd_line     ,
    prd_start_dt ,
    prd_end_dt   
)

SELECT 
	prd_id, 
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS category_id,
	TRIM(prd_nm) prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'Unknown'
	END AS prd_line,
	CAST(prd_start_dt AS date) AS prd_start_dt,
	CAST(DATEADD(day, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS date) AS prd_end_dt
FROM bronze.crm_prd_info
WHERE ISNULL(prd_cost, 0) >= 0


  

