/*
================================
This is template for DDL process
================================

Usage: Create Database and Schemas for DataWarehouse with Medalion Architecture
-------------------------------------------------------------------------------
*/

USE master;
GO

/*
-- Không sử dụng câu lệnh này để tránh việc xoá toàn bộ database (bad practice)

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'MyDataWarehouse')
BEGIN
    ALTER DATABASE MyDataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE MyDataWarehouse
END
GO
*/

-- Create Database 'DataWarehouse'
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MyDataWarehouse')
BEGIN
	CREATE DATABASE MyDataWarehouse
END
GO

USE MyDataWarehouse;
GO

-- Create Schema for Medallion Architecture
-- 1. Khởi tạo Schema Bronze
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze;');
END;
GO

-- 2. Khởi tạo Schema Silver
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver;');
END;
GO

-- 3. Khởi tạo Schema Gold
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold;');
END;
GO



