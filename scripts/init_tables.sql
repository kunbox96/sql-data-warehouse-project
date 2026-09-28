/*
- Scripts này được sử dụng để tạo bảng mới cho Bronze, Silver Layers của database 'MyDataWarehouse'
- Cách thức tạo:
  - Kiểm tra table đã exists hay chưa?
  - Nếu có rồi thì truncate data và insert
  - Nếu chưa thì tạo rồi insert
*/
USE MyDataWarehouse;
GO

IF NOT EXISTS(
SELECT 1 FROM sys.tables 
WHERE name IN ('bronze.crm_cust_info', 'bronze.crm_prd_info', 'bronze.crm_sales_details', 
			   'bronze.erp_cust_az12', 'bronze.erp_loc_a101', 'bronze.erp_px_cat_g1v2',
			   'silver.crm_cust_info', 'silver.crm_prd_info', 'silver.crm_sales_details', 
			   'silver.erp_cust_az12', 'silver.erp_loc_a101', 'silver.erp_px_cat_g1v2')
)

BEGIN
	CREATE TABLE bronze.crm_cust_info(
		cst_id INT,
		cst_key NVARCHAR(50),
		cst_firstname NVARCHAR(50),
		cst_lastname NVARCHAR(50),
		cst_marital_status NVARCHAR(50),
		cst_gndr NVARCHAR(50),
		cst_create_date DATE
	);

	CREATE TABLE bronze.crm_prd_info(
		prd_id INT,
		prd_key NVARCHAR(50),
		prd_nm NVARCHAR(50),
		prd_cost INT NULL,
		prd_line NVARCHAR(50),
		prd_start_dt DATE,
		prd_end_dt DATE NULL
	);

	CREATE TABLE bronze.crm_sales_details(
		sls_ord_num NVARCHAR(50),
		sls_prd_key NVARCHAR(50),
		sls_cust_id INT,
		sls_order_dt NVARCHAR(50),
		sls_ship_dt NVARCHAR(50),
		sls_due_dt NVARCHAR(50),
		sls_sales INT,
		sls_quantity INT,
		sls_price INT
	);

	CREATE TABLE bronze.erp_cust_az12(
		cid NVARCHAR(50),
		bdate DATE,
		gen NVARCHAR(50)
	);

	CREATE TABLE bronze.erp_loc_a101(
		cid NVARCHAR(50),
		cntry NVARCHAR(50)
	);
	
	CREATE TABLE bronze.erp_px_cat_g1v2(
		id NVARCHAR(50),
		cat NVARCHAR(50),
		subcat NVARCHAR(50),
		mantenance BIT
	)
END
