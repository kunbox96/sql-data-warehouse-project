/* 
===============================================================================
THIS PROCEDURE CREATED WITH PURPOSE TO TRANSFORM AND LOAD DATA FROM BRONZE LAYER
INTO SILVER LAYER

- Method used is truncate data from silver -> transform -> load data

===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.tl_silver_layer AS
BEGIN
	BEGIN TRY
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME

	SET @batch_start_time = GETDATE();

	-- ======================== TRANSFORM FOR SILVER LAYER ========================
	-- TRANSFORM AND LOAD: crm_cust_info

		BEGIN TRANSACTION
		PRINT 'Start truncate, transfrom and load table silver.crm_cust_info'
		PRINT ''

		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_cust_info;

		WITH tmp AS(
			SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
			FROM bronze.crm_cust_info
		)

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
		  AND cst_id IS NOT NULL;

		SET @end_time = GETDATE();

		PRINT N'> Finished transform & Load data cho bảng silver.crm_cust_info';
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds' ;
		PRINT '        ----        '

		-- =================================================================
		-- TRANSFORM AND LOAD: crm_prd_info

		PRINT 'Start truncate, transfrom and load table silver.crm_prd_info'
		PRINT '' 

		SET @start_time = GETDATE();

		TRUNCATE TABLE silver.crm_prd_info;

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
		WHERE ISNULL(prd_cost, 0) >= 0;

		SET @end_time = GETDATE();

		PRINT N'> Finished transform & Load data cho bảng silver.crm_prd_info';
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds' ;
		PRINT '        ----        '

		-- =================================================================
		-- TRANSFORM AND LOAD: crm_sales_details

		PRINT 'Start truncate, transfrom and load table silver.crm_sales_details'
		PRINT ''

		SET @start_time = GETDATE();

		TRUNCATE TABLE silver.crm_sales_details;

		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)

		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS nvarchar) AS date)
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS nvarchar) AS date)
			END AS sls_ship_dt,
			CASE
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS nvarchar) AS date)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
				THEN ABS(sls_sales) / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;

		SET @end_time = GETDATE();

		PRINT N'> Finished transform & Load data cho bảng silver.crm_sales_details';
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds' ;
		PRINT '        ----        '

		-- =================================================================
		-- TRANSFORM AND LOAD: erp_cust_az12

		PRINT 'Start truncate, transfrom and load table silver.erp_cust_az12'
		PRINT '' 

		SET @start_time = GETDATE();

		TRUNCATE TABLE silver.erp_cust_az12;

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)

		select
			CASE
				WHEN cid LIKE 'NAS%' THEN TRIM(SUBSTRING(cid,4, LEN(cid)))
				ELSE cid
			END AS cid,
			CASE 
				WHEN DATEDIFF(YEAR,bdate, GETDATE()) > 100 OR DATEDIFF(YEAR,GETDATE(), bdate) > 100
				THEN NULL
				ELSE bdate
			END AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
				ELSE 'Unknown'
			END AS gen
		from bronze.erp_cust_az12;

		SET @end_time = GETDATE();

		PRINT N'> Finished transform & Load data cho bảng silver.erp_cust_az12';
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds' ;
		PRINT '        ----        '

		-- =================================================================
		-- TRANSFORM AND LOAD: erp_loc_a101

		PRINT 'Start truncate, transfrom and load table silver.erp_loc_a101'
		PRINT ''

		SET @start_time = GETDATE();

		TRUNCATE TABLE silver.erp_loc_a101

		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)

		SELECT 
			REPLACE(cid, '-', '') AS cid,
			CASE
				WHEN UPPER(TRIM(cntry)) IN ('Germany', 'DE') THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('United States', 'US', 'USA') THEN 'United States'
				WHEN UPPER(TRIM(cntry)) IN ('Australia') THEN 'Australia'
				WHEN UPPER(TRIM(cntry)) IN ('United Kingdom') THEN 'United Kingdom'
				WHEN UPPER(TRIM(cntry)) IN ('Canada') THEN 'Canada'
				WHEN UPPER(TRIM(cntry)) IN ('France') THEN 'France'
				ELSE NULL
			END AS cntry
		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();

		PRINT N'> Finished transform & Load data cho bảng silver.erp_loc_a101';
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds' ;
		PRINT '        ----        '

		-- =================================================================
		-- TRANSFORM AND LOAD: erp_px_cat_g1v2 <---

		PRINT 'Start truncate, transfrom and load table silver.erp_px_cat_g1v2';

		PRINT '';

		SET @start_time = GETDATE();

		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT id,
			   TRIM(cat),
			   TRIM(subcat),
			   TRIM(maintenance)
		FROM   bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();

		PRINT N'> Finished transform & Load data cho bảng silver.erp_px_cat_g1v2';
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds' ;
		PRINT '        ----        '

		---------------------------------------------------------------------

		PRINT '------------------ DONE LOAD ------------------'
		PRINT ''
		COMMIT TRANSACTION;

		SET @batch_end_time = GETDATE();
		PRINT'===============================================';
		PRINT' LOAD BRONZE LAYER COMPLETED';
		PRINT' >> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT'===============================================';
	END TRY

	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
			PRINT N'Đã xảy ra lỗi đã ROLLBACK toàn bộ dữ liệu'
		END

		-- Ghi log lỗi chi tiết vào bảng etl_error_logs
		DECLARE @ProcName NVARCHAR(100) = OBJECT_NAME(@@PROCID);
        INSERT INTO dbo.etl_error_logs (
            procedure_name, 
            error_number, 
            error_severity, 
            error_state, 
            error_line, 
            error_message,
			error_time
        )
        VALUES (
            @ProcName,
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_LINE(),
            ERROR_MESSAGE(),
			GETDATE()
        );

		-- Lấy và hiển thị thông tin chi tiết lỗi để dễ debug
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		DECLARE @ErrorLine INT = ERROR_LINE();

		RAISERROR (N'Lỗi tại dòng %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);
	END CATCH
END