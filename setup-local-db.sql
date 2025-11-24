-- Setup script for local database with tinyint field
-- This script creates a database and a sample table with tinyint data type

-- Create database (if it doesn't exist)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DABTestDB')
BEGIN
    CREATE DATABASE DABTestDB;
END
GO

USE DABTestDB;
GO

-- Drop table if it exists
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO

-- Create table with tinyint field
CREATE TABLE dbo.Products
(
    Id TINYINT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StockLevel TINYINT NOT NULL,  -- tinyint: 0 to 255
    IsActive TINYINT NOT NULL DEFAULT 1,  -- Using tinyint as boolean (0 or 1)
    CategoryId TINYINT NULL,  -- Category ID using tinyint
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- Insert sample data
INSERT INTO dbo.Products (Name, Price, StockLevel, IsActive, CategoryId)
VALUES
    ('Laptop', 999.99, 15, 1, 1),
    ('Mouse', 29.99, 100, 1, 1),
    ('Keyboard', 79.99, 50, 1, 1),
    ('Monitor', 299.99, 25, 1, 1),
    ('Webcam', 49.99, 0, 0, 1),
    ('Headphones', 89.99, 30, 1, 2),
    ('Speaker', 129.99, 20, 1, 2),
    ('Tablet', 399.99, 10, 1, 1);
GO

-- Verify the data
SELECT * FROM dbo.Products;
GO

-- Display information about tinyint usage
SELECT 
    'TINYINT Range: 0 to 255' AS Info,
    MIN(StockLevel) AS MinStockLevel,
    MAX(StockLevel) AS MaxStockLevel,
    AVG(StockLevel) AS AvgStockLevel
FROM dbo.Products;
GO

PRINT 'Database setup completed successfully!';
PRINT 'Database: DABTestDB';
PRINT 'Table: dbo.Products';
PRINT 'Tinyint fields: StockLevel, IsActive, CategoryId';
GO

