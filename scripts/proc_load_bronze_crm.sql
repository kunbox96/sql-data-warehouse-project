CREATE OR ALTER PROCEDURE [bronze].[load_bronze_layer] AS

	BEGIN TRY
		BEGIN TRANSACTION

		PRINT N'Insert data bảng crm_cust_info';

		TRUNCATE TABLE bronze.crm_cust_info;
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Alvin Nguyen\Desktop\babara_SQL_ultimate_course\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2, 
			TABLOCK
		);

		PRINT N'Insert data bảng crm_prd_info';

		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Alvin Nguyen\Desktop\babara_SQL_ultimate_course\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);

		PRINT N'Insert data bảng crm_sales_details';

		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Alvin Nguyen\Desktop\babara_SQL_ultimate_course\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);

		PRINT N'Insert data cho 3 bảng crm thành công' 

		PRINT N'Insert data bảng erp_cust_az12';

		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Alvin Nguyen\Desktop\babara_SQL_ultimate_course\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);

		PRINT N'Insert data bảng erp_loc_a101';

		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Alvin Nguyen\Desktop\babara_SQL_ultimate_course\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);

		PRINT N'Insert data bảng erp_px_cat_g1v2';

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Alvin Nguyen\Desktop\babara_SQL_ultimate_course\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);

		PRINT N'Insert data cho 3 bảng erp thành công' 

		COMMIT TRANSACTION;
	
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
GO
