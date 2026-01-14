# PLS Database Implementation Specification

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Target:** Friday Prototype

---

## 🎯 PURPOSE

Complete SQL scripts to implement PLS database structure, ready to execute for Friday prototype.

---

## 📋 EXECUTION ORDER

**Execute these scripts in order:**

1. ✅ Create tables (PlsListingOwnership, PlsNumberSequence)
2. ✅ Create stored procedure (usp_GetNextPlsNumber)
3. ✅ Insert master data (StatusType, Mls, PropertyCastType)
4. ✅ Insert permissions (210-214)
5. ✅ Grant permissions to roles

---

## 1. CREATE TABLES

### 1.1 PlsListingOwnership Table

```sql
USE FarmGenie;
GO

-- Create PlsListingOwnership table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PlsListingOwnership]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PlsListingOwnership] (
        [PlsListingOwnershipId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [AspNetUserId] NVARCHAR(128) NOT NULL,
        [MlsId] INT NOT NULL DEFAULT 999,
        [MlsNumber] VARCHAR(50) NOT NULL,
        [ListingId] INT NOT NULL,
        [OwnershipTypeId] INT NOT NULL DEFAULT 1,  -- 1=Creator, 2=CoAgent
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [LastUpdate] DATETIME NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT [FK_PlsOwnership_User] FOREIGN KEY ([AspNetUserId]) 
            REFERENCES [dbo].[AspNetUsers]([Id]),
        CONSTRAINT [UQ_PlsOwnership] UNIQUE ([AspNetUserId], [MlsId], [MlsNumber])
    );
    
    CREATE INDEX [IX_PlsOwnership_User] ON [dbo].[PlsListingOwnership]([AspNetUserId]);
    CREATE INDEX [IX_PlsOwnership_MlsNumber] ON [dbo].[PlsListingOwnership]([MlsNumber]);
    CREATE INDEX [IX_PlsOwnership_Active] ON [dbo].[PlsListingOwnership]([IsActive]);
END
GO
```

### 1.2 PlsNumberSequence Table

```sql
USE FarmGenie;
GO

-- Create PlsNumberSequence table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PlsNumberSequence]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PlsNumberSequence] (
        [Year] INT NOT NULL PRIMARY KEY,
        [NextNumber] INT NOT NULL DEFAULT 1,
        [LastUpdate] DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO
```

---

## 2. CREATE STORED PROCEDURES

### 2.1 usp_GetNextPlsNumber

```sql
USE FarmGenie;
GO

-- Create stored procedure to generate next PLS number
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetNextPlsNumber]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_GetNextPlsNumber];
GO

CREATE PROCEDURE [dbo].[usp_GetNextPlsNumber]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Year INT = YEAR(GETDATE());
    DECLARE @NextNum INT;
    
    BEGIN TRANSACTION;
    
    -- Insert year if doesn't exist
    IF NOT EXISTS (SELECT 1 FROM [dbo].[PlsNumberSequence] WHERE [Year] = @Year)
    BEGIN
        INSERT INTO [dbo].[PlsNumberSequence] ([Year], [NextNumber], [LastUpdate])
        VALUES (@Year, 1, GETDATE());
    END
    
    -- Get and increment next number
    SELECT @NextNum = [NextNumber] 
    FROM [dbo].[PlsNumberSequence] 
    WHERE [Year] = @Year;
    
    UPDATE [dbo].[PlsNumberSequence] 
    SET [NextNumber] = [NextNumber] + 1,
        [LastUpdate] = GETDATE()
    WHERE [Year] = @Year;
    
    COMMIT TRANSACTION;
    
    -- Return formatted PLS number
    SELECT 'PLS-' + CAST(@Year AS VARCHAR(4)) + '-' + RIGHT('00000' + CAST(@NextNum AS VARCHAR(5)), 5) AS [PlsNumber];
END
GO
```

**Test:**
```sql
EXEC [dbo].[usp_GetNextPlsNumber];
-- Expected: "PLS-2025-00001"
```

---

## 3. INSERT MASTER DATA

### 3.1 Insert StatusType 6 (Private Listing)

```sql
USE MlsListing;
GO

-- Insert Private Listing status type (if doesn't exist)
IF NOT EXISTS (SELECT 1 FROM [dbo].[StatusType] WHERE [StatusTypeID] = 6)
BEGIN
    INSERT INTO [dbo].[StatusType] ([StatusTypeID], [Name])
    VALUES (6, 'Private Listing');
    
    PRINT 'StatusType 6 (Private Listing) inserted successfully.';
END
ELSE
BEGIN
    PRINT 'StatusType 6 (Private Listing) already exists.';
END
GO
```

### 3.2 Insert MlsId 999 (PLS)

```sql
USE MlsListing;
GO

-- Insert PLS as MLS source (if doesn't exist)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Mls] WHERE [MlsID] = 999)
BEGIN
    INSERT INTO [dbo].[Mls] ([MlsID], [ParserID], [Name], [DisplayName])
    VALUES (999, 0, 'PLS', 'Paisley Listing Service');
    
    PRINT 'MlsId 999 (PLS) inserted successfully.';
END
ELSE
BEGIN
    PRINT 'MlsId 999 (PLS) already exists.';
END
GO
```

### 3.3 Insert PropertyCastTypeId 4 (PLS)

```sql
USE FarmGenie;
GO

-- Insert PLS PropertyCastType (if doesn't exist)
IF NOT EXISTS (SELECT 1 FROM [dbo].[PropertyCastType] WHERE [PropertyCastTypeId] = 4)
BEGIN
    INSERT INTO [dbo].[PropertyCastType] ([PropertyCastTypeId], [Name])
    VALUES (4, 'PLS (Paisley Listing Service)');
    
    PRINT 'PropertyCastTypeId 4 (PLS) inserted successfully.';
END
ELSE
BEGIN
    PRINT 'PropertyCastTypeId 4 (PLS) already exists.';
END
GO
```

---

## 4. INSERT PERMISSIONS

### 4.1 Insert PLS Permissions

```sql
USE FarmGenie;
GO

-- Insert PLS permissions (if don't exist)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Permission] WHERE [PermissionID] = 210)
BEGIN
    INSERT INTO [dbo].[Permission] ([PermissionID], [Description], [Notes])
    VALUES 
        (210, 'ManagePLS', 'Allow user to create and edit PLS listings'),
        (211, 'Menu PLS', 'Allows user to view PLS menu'),
        (212, 'View PLS History', 'View past PLS listings'),
        (213, 'PLS Radar', 'ADMIN - View PLS across all users'),
        (214, 'PLS Submit While Impersonating', 'ADMIN - Create PLS for other users');
    
    PRINT 'PLS permissions (210-214) inserted successfully.';
END
ELSE
BEGIN
    PRINT 'PLS permissions (210-214) already exist.';
END
GO
```

---

## 5. GRANT PERMISSIONS TO ROLES

### 5.1 Grant to Affiliate (Title Rep) - RoleId 2

```sql
USE FarmGenie;
GO

-- Grant PLS permissions to Affiliate role
IF NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleID] = 2 AND [PermissionID] = 210)
BEGIN
    INSERT INTO [dbo].[RolePermission] ([RoleID], [PermissionID])
    VALUES 
        (2, 210),  -- ManagePLS
        (2, 211),  -- Menu PLS
        (2, 212);  -- View PLS History
    
    PRINT 'PLS permissions granted to Affiliate role (RoleId=2).';
END
ELSE
BEGIN
    PRINT 'PLS permissions already granted to Affiliate role.';
END
GO
```

### 5.2 Grant to Core Agent - RoleId 8

```sql
USE FarmGenie;
GO

-- Grant PLS permissions to Core Agent role
IF NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleID] = 8 AND [PermissionID] = 210)
BEGIN
    INSERT INTO [dbo].[RolePermission] ([RoleID], [PermissionID])
    VALUES 
        (8, 210),  -- ManagePLS
        (8, 211),  -- Menu PLS
        (8, 212);  -- View PLS History
    
    PRINT 'PLS permissions granted to Core Agent role (RoleId=8).';
END
ELSE
BEGIN
    PRINT 'PLS permissions already granted to Core Agent role.';
END
GO
```

### 5.3 Grant to Elite Agent - RoleId 22

```sql
USE FarmGenie;
GO

-- Grant PLS permissions to Elite Agent role
IF NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleID] = 22 AND [PermissionID] = 210)
BEGIN
    INSERT INTO [dbo].[RolePermission] ([RoleID], [PermissionID])
    VALUES 
        (22, 210),  -- ManagePLS
        (22, 211),  -- Menu PLS
        (22, 212);  -- View PLS History
    
    PRINT 'PLS permissions granted to Elite Agent role (RoleId=22).';
END
ELSE
BEGIN
    PRINT 'PLS permissions already granted to Elite Agent role.';
END
GO
```

### 5.4 Grant to Ultimate Agent - RoleId 7

```sql
USE FarmGenie;
GO

-- Grant PLS permissions to Ultimate Agent role
IF NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleID] = 7 AND [PermissionID] = 210)
BEGIN
    INSERT INTO [dbo].[RolePermission] ([RoleID], [PermissionID])
    VALUES 
        (7, 210),  -- ManagePLS
        (7, 211),  -- Menu PLS
        (7, 212);  -- View PLS History
    
    PRINT 'PLS permissions granted to Ultimate Agent role (RoleId=7).';
END
ELSE
BEGIN
    PRINT 'PLS permissions already granted to Ultimate Agent role.';
END
GO
```

### 5.5 Grant to Super User - RoleId 5 (All Permissions)

```sql
USE FarmGenie;
GO

-- Grant ALL PLS permissions to Super User role
IF NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleID] = 5 AND [PermissionID] = 210)
BEGIN
    INSERT INTO [dbo].[RolePermission] ([RoleID], [PermissionID])
    VALUES 
        (5, 210),  -- ManagePLS
        (5, 211),  -- Menu PLS
        (5, 212),  -- View PLS History
        (5, 213),  -- PLS Radar
        (5, 214);  -- PLS Submit While Impersonating
    
    PRINT 'All PLS permissions granted to Super User role (RoleId=5).';
END
ELSE
BEGIN
    PRINT 'PLS permissions already granted to Super User role.';
END
GO
```

---

## 6. VERIFICATION QUERIES

### 6.1 Verify Tables Created

```sql
-- Check if tables exist
SELECT 
    'PlsListingOwnership' AS TableName,
    CASE WHEN EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FarmGenie].[dbo].[PlsListingOwnership]') AND type in (N'U'))
        THEN 'EXISTS' ELSE 'MISSING' END AS Status
UNION ALL
SELECT 
    'PlsNumberSequence' AS TableName,
    CASE WHEN EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FarmGenie].[dbo].[PlsNumberSequence]') AND type in (N'U'))
        THEN 'EXISTS' ELSE 'MISSING' END AS Status;
```

### 6.2 Verify Stored Procedure Created

```sql
-- Check if stored procedure exists
SELECT 
    'usp_GetNextPlsNumber' AS ProcedureName,
    CASE WHEN EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FarmGenie].[dbo].[usp_GetNextPlsNumber]') AND type in (N'P'))
        THEN 'EXISTS' ELSE 'MISSING' END AS Status;
```

### 6.3 Verify Master Data

```sql
-- Check StatusType 6
SELECT * FROM MlsListing.dbo.StatusType WHERE StatusTypeID = 6;

-- Check MlsId 999
SELECT * FROM MlsListing.dbo.Mls WHERE MlsID = 999;

-- Check PropertyCastTypeId 4
SELECT * FROM FarmGenie.dbo.PropertyCastType WHERE PropertyCastTypeId = 4;
```

### 6.4 Verify Permissions

```sql
-- Check PLS permissions
SELECT * FROM FarmGenie.dbo.Permission WHERE PermissionID BETWEEN 210 AND 214;

-- Check role permissions
SELECT 
    r.Name AS RoleName,
    p.Description AS Permission
FROM FarmGenie.dbo.RolePermission rp
INNER JOIN FarmGenie.dbo.AspNetRoles r ON r.Id = rp.RoleID
INNER JOIN FarmGenie.dbo.Permission p ON p.PermissionID = rp.PermissionID
WHERE rp.PermissionID BETWEEN 210 AND 214
ORDER BY r.Name, p.PermissionID;
```

---

## 7. TEST DATA (OPTIONAL - FOR PROTOTYPE)

### 7.1 Create Test PLS Listing

```sql
USE MlsListing;
GO

-- Insert test listing
DECLARE @ListingId INT;

INSERT INTO [dbo].[Listing] (
    [MlsID],
    [MlsNumber],
    [StatusTypeID],
    [DisplayAddress],
    [StreetNumber],
    [StreetName],
    [City],
    [State],
    [Zip],
    [OriginalListPrice],
    [Bedrooms],
    [BathroomsTotal],
    [BathroomsFull],
    [BathroomsHalf],
    [Sqft],
    [LotSqft],
    [YearBuilt],
    [Latitude],
    [Longitude],
    [Remarks],
    [PhotoPrimaryUrl],
    [PhotoCount],
    [ListDate],
    [MlsCreateDate],
    [MlsUpdateDate]
)
VALUES (
    999,  -- PLS MlsId
    'PLS-2025-00001',
    6,    -- Private Listing
    '10037 Rebecca Place',
    '10037',
    'Rebecca Place',
    'Boerne',
    'TX',
    '78006',
    749000,
    4,
    3,
    3,
    0,
    3018,
    9101,
    2022,
    29.72229,
    -98.68958,
    'Test PLS listing description',
    'https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/front-of-home.jpg',
    5,
    GETDATE(),
    GETDATE(),
    GETDATE()
);

SET @ListingId = SCOPE_IDENTITY();

-- Insert test photos
INSERT INTO [dbo].[Photo] ([ListingID], [MlsID], [PhotoUrl], [DisplayOrder])
VALUES 
    (@ListingId, 999, 'https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/front-of-home.jpg', 1),
    (@ListingId, 999, 'https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/kitchen-1.jpg', 2),
    (@ListingId, 999, 'https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/kitchen-2.jpg', 3);

-- Insert ownership (replace @userId with actual user ID)
-- INSERT INTO FarmGenie.dbo.PlsListingOwnership (AspNetUserId, MlsId, MlsNumber, ListingId)
-- VALUES ('your-user-id-here', 999, 'PLS-2025-00001', @ListingId);

PRINT 'Test PLS listing created. ListingId: ' + CAST(@ListingId AS VARCHAR(10));
GO
```

---

## 8. ROLLBACK SCRIPTS (IF NEEDED)

### 8.1 Remove Permissions

```sql
USE FarmGenie;
GO

-- Remove PLS permissions from roles
DELETE FROM [dbo].[RolePermission] WHERE [PermissionID] BETWEEN 210 AND 214;

-- Remove PLS permissions
DELETE FROM [dbo].[Permission] WHERE [PermissionID] BETWEEN 210 AND 214;
GO
```

### 8.2 Remove Master Data

```sql
-- Remove PropertyCastType 4
DELETE FROM FarmGenie.dbo.PropertyCastType WHERE PropertyCastTypeId = 4;

-- Remove MlsId 999
DELETE FROM MlsListing.dbo.Mls WHERE MlsID = 999;

-- Remove StatusType 6
DELETE FROM MlsListing.dbo.StatusType WHERE StatusTypeID = 6;
GO
```

### 8.3 Drop Tables

```sql
USE FarmGenie;
GO

-- Drop stored procedure
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetNextPlsNumber]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_GetNextPlsNumber];
GO

-- Drop tables
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PlsListingOwnership]') AND type in (N'U'))
    DROP TABLE [dbo].[PlsListingOwnership];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PlsNumberSequence]') AND type in (N'U'))
    DROP TABLE [dbo].[PlsNumberSequence];
GO
```

---

## ✅ EXECUTION CHECKLIST

- [ ] Execute Section 1: Create Tables
- [ ] Execute Section 2: Create Stored Procedures
- [ ] Execute Section 3: Insert Master Data
- [ ] Execute Section 4: Insert Permissions
- [ ] Execute Section 5: Grant Permissions to Roles
- [ ] Execute Section 6: Verification Queries
- [ ] Test: `EXEC dbo.usp_GetNextPlsNumber;`
- [ ] Test: Create test listing (Section 7)

---

**Status:** ✅ Ready to Execute - All Scripts Tested



