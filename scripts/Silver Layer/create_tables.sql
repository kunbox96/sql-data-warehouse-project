/*
======================================================================
 DDL Script: Create Silver Tables
=======================================================================
 Script Purpose: 
  - This script create tables in the 'silver' schema, dropping 
    existing tables if they already exists
  
  - Run this script to re-define the DDL structure of 'silver' tables
*/

USE MyDataWarehouse;
GO

-- ===================================================================
-- 1. Đảm bảo Schema đã tồn tại
-- ===================================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver;');
GO

-- ============================================================================
-- 2. Khởi tạo các bảng tầng Silver (Sử dụng Pattern: Drop & Re-create an toàn)
-- ============================================================================

-- -------------------------------------------------------------------
-- Bảng: silver.crm_cust_info
-- -------------------------------------------------------------------
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_cust_info;
    PRINT N'Bảng silver.crm_cust_info cũ đã bị xóa để khởi tạo lại.';
END
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date    DATETIME2 DEFAULT GETDATE(),
    dwh_update_date    DATETIME2 DEFAULT GETDATE()
);
PRINT N'Đã tạo bảng silver.crm_cust_info thành công.' + CHAR(13);
GO

-- -------------------------------------------------------------------
-- Bảng: silver.crm_prd_info
-- -------------------------------------------------------------------
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_prd_info;
    PRINT N'Bảng silver.crm_prd_info cũ đã bị xóa để khởi tạo lại.';
END
GO

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    category_id  NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT NULL,
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE NULL,
    dwh_create_date    DATETIME2 DEFAULT GETDATE(),
    dwh_update_date    DATETIME2 DEFAULT GETDATE()
);
PRINT N'Đã tạo bảng silver.crm_prd_info thành công.' + CHAR(13);
GO

-- -------------------------------------------------------------------
-- Bảng: silver.crm_sales_details
-- -------------------------------------------------------------------
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_sales_details;
    PRINT N'Bảng silver.crm_sales_details cũ đã bị xóa để khởi tạo lại.';
END
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date    DATETIME2 DEFAULT GETDATE(),
    dwh_update_date    DATETIME2 DEFAULT GETDATE()
);
PRINT N'Đã tạo bảng silver.crm_sales_details thành công.' + CHAR(13);
GO

-- -------------------------------------------------------------------
-- Bảng: silver.erp_cust_az12
-- -------------------------------------------------------------------
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_cust_az12;
    PRINT N'Bảng silver.erp_cust_az12 cũ đã bị xóa để khởi tạo lại.';
END
GO

CREATE TABLE silver.erp_cust_az12 (
    cid   NVARCHAR(50),
    bdate DATE,
    gen   NVARCHAR(50),
    dwh_create_date    DATETIME2 DEFAULT GETDATE(),
    dwh_update_date    DATETIME2 DEFAULT GETDATE()
);
PRINT N'Đã tạo bảng silver.erp_cust_az12 thành công.' + CHAR(13);
GO

-- -------------------------------------------------------------------
-- Bảng: silver.erp_loc_a101
-- -------------------------------------------------------------------
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_loc_a101;
    PRINT N'Bảng silver.erp_loc_a101 cũ đã bị xóa để khởi tạo lại.';
END
GO

CREATE TABLE silver.erp_loc_a101 (
    cid   NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date    DATETIME2 DEFAULT GETDATE(),
    dwh_update_date    DATETIME2 DEFAULT GETDATE()
);
PRINT N'Đã tạo bảng silver.erp_loc_a101 thành công.' + CHAR(13);
GO

-- -------------------------------------------------------------------
-- Bảng: silver.erp_px_cat_g1v2
-- -------------------------------------------------------------------
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_px_cat_g1v2;
    PRINT N'Bảng silver.erp_px_cat_g1v2 cũ đã bị xóa để khởi tạo lại.';
END
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwh_create_date    DATETIME2 DEFAULT GETDATE(),
    dwh_update_date    DATETIME2 DEFAULT GETDATE()
);
PRINT N'Đã tạo bảng silver.erp_px_cat_g1v2 thành công.' + CHAR(13);
GO