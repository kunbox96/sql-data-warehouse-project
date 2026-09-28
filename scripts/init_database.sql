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

-- Create Schema for Medalion Architecture
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name IN('bronze', 'silver', 'gold'))
BEGIN
	EXEC('create schema bronze');
	EXEC('create schema silver');
	EXEC('create schema gold');
END
GO



