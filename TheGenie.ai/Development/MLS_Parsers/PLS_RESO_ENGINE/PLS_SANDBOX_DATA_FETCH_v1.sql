-- ============================================================================
-- PLS Sandbox Data Fetch Script
-- Version: 1.0
-- Created: 01/05/2026
-- Last Updated: 01/05/2026
-- Author: Cursor AI Agent
-- Purpose: Fetch reference data from production to sandbox for PLS development
-- ============================================================================
--
-- PREREQUISITES:
-- 1. Master data inserts executed first (PLS_DATABASE_MASTER_DATA_v3.sql)
-- 2. Sandbox databases exist with schema structure
-- 3. Production databases accessible
--
-- EXECUTION ORDER:
-- 1. Execute master data inserts (StatusType, Mls, PropertyCastType, PermissionType)
-- 2. Execute this script to fetch reference data
-- 3. Verify data counts
-- 4. Execute PLS schema scripts
--
-- ============================================================================

PRINT '========================================';
PRINT 'PLS Sandbox Data Fetch Script';
PRINT '========================================';
PRINT '';
GO

-- ============================================================================
-- 1. FARMGENIE_SANDBOX - Master Data & Users
-- ============================================================================

USE FarmGenie_Sandbox;
GO

PRINT '1. Fetching PropertyCastType (PropertyCastTypeId = 4)...';
-- Check if exists in production, if so copy it
IF EXISTS (SELECT 1 FROM FarmGenie.dbo.PropertyCastType WHERE PropertyCastTypeId = 4)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM FarmGenie_Sandbox.dbo.PropertyCastType WHERE PropertyCastTypeId = 4)
    BEGIN
        INSERT INTO FarmGenie_Sandbox.dbo.PropertyCastType (PropertyCastTypeId, Name, Description)
        SELECT PropertyCastTypeId, Name, Description
        FROM FarmGenie.dbo.PropertyCastType
        WHERE PropertyCastTypeId = 4;
        PRINT '  ✓ PropertyCastTypeId 4 copied';
    END
    ELSE
    BEGIN
        PRINT '  ✓ PropertyCastTypeId 4 already exists';
    END
END
ELSE
BEGIN
    PRINT '  ⚠ PropertyCastTypeId 4 does not exist in production - will be created by master data script';
END
GO

PRINT '';
PRINT '2. Fetching PermissionType (PermissionTypeIDs 210-214)...';
-- Copy PermissionType records if they exist
INSERT INTO FarmGenie_Sandbox.dbo.PermissionType (PermissionTypeId, Name, Description)
SELECT PermissionTypeId, Name, Description
FROM FarmGenie.dbo.PermissionType
WHERE PermissionTypeId BETWEEN 210 AND 214
    AND NOT EXISTS (
        SELECT 1 FROM FarmGenie_Sandbox.dbo.PermissionType pt2 
        WHERE pt2.PermissionTypeId = FarmGenie.dbo.PermissionType.PermissionTypeId
    );
PRINT '  ✓ PermissionType records copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

PRINT '';
PRINT '3. Fetching sample AspNetUsers (10 users)...';
-- Copy sample users for testing
INSERT INTO FarmGenie_Sandbox.dbo.AspNetUsers (
    Id, Email, EmailConfirmed, PasswordHash, SecurityStamp, PhoneNumber, 
    PhoneNumberConfirmed, TwoFactorEnabled, LockoutEndDateUtc, LockoutEnabled, 
    AccessFailedCount, UserName
)
SELECT TOP 10 
    Id, Email, EmailConfirmed, PasswordHash, SecurityStamp, PhoneNumber,
    PhoneNumberConfirmed, TwoFactorEnabled, LockoutEndDateUtc, LockoutEnabled,
    AccessFailedCount, UserName
FROM FarmGenie.dbo.AspNetUsers
WHERE EmailConfirmed = 1
    AND NOT EXISTS (
        SELECT 1 FROM FarmGenie_Sandbox.dbo.AspNetUsers u2 
        WHERE u2.Id = FarmGenie.dbo.AspNetUsers.Id
    )
ORDER BY Id;
PRINT '  ✓ AspNetUsers copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

PRINT '';
PRINT '4. Fetching sample Permissions for test users...';
-- Copy permissions for the users we just copied
-- Note: Only copy permissions where UserId exists in sandbox
INSERT INTO FarmGenie_Sandbox.dbo.Permission (PermissionId, UserId, PermissionTypeId)
SELECT p.PermissionId, p.UserId, p.PermissionTypeId
FROM FarmGenie.dbo.Permission p
INNER JOIN FarmGenie_Sandbox.dbo.AspNetUsers u ON u.Id = p.UserId
WHERE p.PermissionTypeId BETWEEN 210 AND 214
    AND NOT EXISTS (
        SELECT 1 FROM FarmGenie_Sandbox.dbo.Permission p2 
        WHERE p2.PermissionId = p.PermissionId
    );
PRINT '  ✓ Permissions copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================================
-- 2. MLSLISTING_SANDBOX - Master Data & Historical Listings
-- ============================================================================

USE MlsListing_Sandbox;
GO

PRINT '';
PRINT '5. Fetching StatusType (StatusTypeID 6 and 14)...';
-- Copy StatusType records
INSERT INTO MlsListing_Sandbox.dbo.StatusType (StatusTypeID, Name, Description)
SELECT StatusTypeID, Name, Description
FROM MlsListing.dbo.StatusType
WHERE StatusTypeID IN (6, 14)
    AND NOT EXISTS (
        SELECT 1 FROM MlsListing_Sandbox.dbo.StatusType st2 
        WHERE st2.StatusTypeID = MlsListing.dbo.StatusType.StatusTypeID
    );
PRINT '  ✓ StatusType records copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

PRINT '';
PRINT '6. Fetching Mls (MlsID 777)...';
-- Copy Mls record if exists
IF EXISTS (SELECT 1 FROM MlsListing.dbo.Mls WHERE MlsID = 777)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM MlsListing_Sandbox.dbo.Mls WHERE MlsID = 777)
    BEGIN
        INSERT INTO MlsListing_Sandbox.dbo.Mls (MlsID, Name, Description, [Other fields...])
        SELECT MlsID, Name, Description, [Other fields...]
        FROM MlsListing.dbo.Mls
        WHERE MlsID = 777;
        PRINT '  ✓ MlsID 777 copied';
    END
    ELSE
    BEGIN
        PRINT '  ✓ MlsID 777 already exists';
    END
END
ELSE
BEGIN
    PRINT '  ⚠ MlsID 777 does not exist in production - will be created by master data script';
END
GO

PRINT '';
PRINT '7. Fetching sample historical Listings (100 listings with APN)...';
-- Copy sample listings for pre-population testing
-- Select listings that have APN (needed for TitleData join)
INSERT INTO MlsListing_Sandbox.dbo.Listing (
    ListingID, MlsNumber, DisplayAddress, StreetNumber, StreetName, City, State, Zip,
    APN, OriginalListPrice, SalePrice, Bedrooms, BathroomsTotal, Sqft, YearBuilt,
    LotSqft, ListDate, SoldDate, StatusTypeID, MlsID, [Other fields...]
)
SELECT TOP 100
    ListingID, MlsNumber, DisplayAddress, StreetNumber, StreetName, City, State, Zip,
    APN, OriginalListPrice, SalePrice, Bedrooms, BathroomsTotal, Sqft, YearBuilt,
    LotSqft, ListDate, SoldDate, StatusTypeID, MlsID, [Other fields...]
FROM MlsListing.dbo.Listing
WHERE StatusTypeID IN (1, 2, 4)  -- Active, Sold, Pending
    AND MlsID != 777  -- Exclude any existing PLS listings
    AND APN IS NOT NULL  -- Need APN for TitleData join
    AND NOT EXISTS (
        SELECT 1 FROM MlsListing_Sandbox.dbo.Listing l2 
        WHERE l2.ListingID = MlsListing.dbo.Listing.ListingID
    )
ORDER BY ListDate DESC;
PRINT '  ✓ Listings copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

PRINT '';
PRINT '8. Fetching Photos for sample listings...';
-- Copy photos for the listings we just copied
INSERT INTO MlsListing_Sandbox.dbo.Photo (PhotoID, ListingID, PhotoUrl, DisplayOrder, IsPrimary)
SELECT p.PhotoID, p.ListingID, p.PhotoUrl, p.DisplayOrder, p.IsPrimary
FROM MlsListing.dbo.Photo p
INNER JOIN MlsListing_Sandbox.dbo.Listing l ON l.ListingID = p.ListingID
WHERE NOT EXISTS (
    SELECT 1 FROM MlsListing_Sandbox.dbo.Photo p2 
    WHERE p2.PhotoID = p.PhotoID
);
PRINT '  ✓ Photos copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================================
-- 3. TITLEDATA_SANDBOX - Property Data
-- ============================================================================

USE TitleData_Sandbox;
GO

PRINT '';
PRINT '9. Fetching AttomDataAssessor (matching property data for test listings)...';
-- Copy property data that matches the listings we copied
-- Match on APN (ParcelNumberFormatted)
INSERT INTO TitleData_Sandbox.dbo.AttomDataAssessor (
    AttomId, ParcelNumberFormatted, PropertyAddressHouseNumber,
    PropertyAddressStreetName, PropertyAddressCity, PropertyAddressState,
    PropertyAddressZIP, YearBuilt, Bedrooms, BathCount, AreaBuilding,
    LotSizeSquareFeet, Latitude, Longitude, [Other fields...]
)
SELECT TOP 100
    a.AttomId, a.ParcelNumberFormatted, a.PropertyAddressHouseNumber,
    a.PropertyAddressStreetName, a.PropertyAddressCity, a.PropertyAddressState,
    a.PropertyAddressZIP, a.YearBuilt, a.Bedrooms, a.BathCount, a.AreaBuilding,
    a.LotSizeSquareFeet, a.Latitude, a.Longitude, [Other fields...]
FROM TitleData.dbo.AttomDataAssessor a
INNER JOIN MlsListing_Sandbox.dbo.Listing l ON l.APN = a.ParcelNumberFormatted
WHERE NOT EXISTS (
    SELECT 1 FROM TitleData_Sandbox.dbo.AttomDataAssessor a2 
    WHERE a2.AttomId = a.AttomId
);
PRINT '  ✓ AttomDataAssessor records copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================================
-- VERIFICATION
-- ============================================================================

PRINT '';
PRINT '========================================';
PRINT 'Verification - Row Counts';
PRINT '========================================';
GO

USE FarmGenie_Sandbox;
GO
SELECT 'FarmGenie_Sandbox' AS DatabaseName, 'AspNetUsers' AS TableName, COUNT(*) AS RowCount FROM dbo.AspNetUsers
UNION ALL
SELECT 'FarmGenie_Sandbox', 'Permission', COUNT(*) FROM dbo.Permission
UNION ALL
SELECT 'FarmGenie_Sandbox', 'PermissionType', COUNT(*) FROM dbo.PermissionType WHERE PermissionTypeId BETWEEN 210 AND 214
UNION ALL
SELECT 'FarmGenie_Sandbox', 'PropertyCastType', COUNT(*) FROM dbo.PropertyCastType WHERE PropertyCastTypeId = 4;
GO

USE MlsListing_Sandbox;
GO
SELECT 'MlsListing_Sandbox' AS DatabaseName, 'Listing' AS TableName, COUNT(*) AS RowCount FROM dbo.Listing
UNION ALL
SELECT 'MlsListing_Sandbox', 'Photo', COUNT(*) FROM dbo.Photo
UNION ALL
SELECT 'MlsListing_Sandbox', 'StatusType', COUNT(*) FROM dbo.StatusType WHERE StatusTypeID IN (6, 14)
UNION ALL
SELECT 'MlsListing_Sandbox', 'Mls', COUNT(*) FROM dbo.Mls WHERE MlsID = 777;
GO

USE TitleData_Sandbox;
GO
SELECT 'TitleData_Sandbox' AS DatabaseName, 'AttomDataAssessor' AS TableName, COUNT(*) AS RowCount FROM dbo.AttomDataAssessor;
GO

PRINT '';
PRINT '========================================';
PRINT 'Data Fetch Complete';
PRINT '========================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Verify row counts above';
PRINT '2. Execute PLS schema scripts to create new tables';
PRINT '3. Test PLS number generation';
PRINT '4. Begin PLS development';
GO

