-- ============================================================================
-- PLS RESO Engine - Master Data Inserts
-- Version: 3.0
-- Created: 01/05/2026
-- Last Updated: 01/05/2026
-- Author: Cursor AI Agent
-- Purpose: Master data inserts for PLS feature (StatusType, Mls, PropertyCastType, Permissions)
-- ============================================================================
--
-- IMPORTANT: Execute these inserts AFTER creating the PLS schema extensions
--            Some inserts are idempotent (check if exists first)
--            Others may need manual verification
--
-- ============================================================================

-- ============================================================================
-- 1. MLS LISTING DATABASE - StatusType Inserts
-- ============================================================================

USE MlsListing;
GO

-- StatusTypeID 6: Private Listing
IF NOT EXISTS (SELECT 1 FROM dbo.StatusType WHERE StatusTypeID = 6)
BEGIN
    INSERT INTO dbo.StatusType (StatusTypeID, Name, Description)
    VALUES (6, 'Private Listing', 'Private listing (pre-MLS)');
    PRINT 'StatusTypeID 6 (Private Listing) inserted successfully';
END
ELSE
BEGIN
    PRINT 'StatusTypeID 6 (Private Listing) already exists';
END
GO

-- StatusTypeID 14: Coming Soon (verify exists)
IF EXISTS (SELECT 1 FROM dbo.StatusType WHERE StatusTypeID = 14)
BEGIN
    PRINT 'StatusTypeID 14 (Coming Soon) exists - no action needed';
END
ELSE
BEGIN
    PRINT 'WARNING: StatusTypeID 14 (Coming Soon) does NOT exist - may need to insert';
END
GO

-- ============================================================================
-- 2. MLS LISTING DATABASE - Mls Insert (PLS Identifier)
-- ============================================================================

USE MlsListing;
GO

-- MlsID 777: PLS (Paisley Listing Service)
-- NOTE: Blueprint originally specified 999, but v3.0 schema uses 777
IF NOT EXISTS (SELECT 1 FROM dbo.Mls WHERE MlsID = 777)
BEGIN
    INSERT INTO dbo.Mls (MlsID, Name, Description)
    VALUES (777, 'PLS', 'Paisley Listing Service (Private Listing Service)');
    PRINT 'MlsID 777 (PLS) inserted successfully';
END
ELSE
BEGIN
    PRINT 'MlsID 777 (PLS) already exists';
END
GO

-- Check if MlsID 999 exists (old value from blueprint)
IF EXISTS (SELECT 1 FROM dbo.Mls WHERE MlsID = 999)
BEGIN
    PRINT 'WARNING: MlsID 999 exists - this was the old PLS identifier from blueprint';
    PRINT '         If you have existing PLS listings with MlsID=999, migrate them to 777';
    PRINT '         Otherwise, you can remove MlsID=999 if not used elsewhere';
END
GO

-- ============================================================================
-- 3. FARMGENIE DATABASE - PropertyCastType Insert
-- ============================================================================

USE FarmGenie;
GO

-- PropertyCastTypeId 4: PLS
IF NOT EXISTS (SELECT 1 FROM dbo.PropertyCastType WHERE PropertyCastTypeId = 4)
BEGIN
    INSERT INTO dbo.PropertyCastType (PropertyCastTypeId, Name, Description)
    VALUES (4, 'PLS', 'Private Listing Service');
    PRINT 'PropertyCastTypeId 4 (PLS) inserted successfully';
END
ELSE
BEGIN
    PRINT 'PropertyCastTypeId 4 (PLS) already exists';
END
GO

-- ============================================================================
-- 4. FARMGENIE DATABASE - Permission Inserts
-- ============================================================================
--
-- NOTE: Permission structure may vary. This assumes PermissionType table exists.
--       Adjust based on your actual schema (may be Permission table directly).
--       Verify table structure before executing.
--

USE FarmGenie;
GO

-- Check if PermissionType table exists
IF OBJECT_ID('dbo.PermissionType', 'U') IS NOT NULL
BEGIN
    -- PermissionTypeID 210: ManagePLS
    IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE PermissionTypeId = 210)
    BEGIN
        INSERT INTO dbo.PermissionType (PermissionTypeId, Name, Description)
        VALUES (210, 'ManagePLS', 'Allow user to create and edit PLS listings');
        PRINT 'PermissionTypeID 210 (ManagePLS) inserted successfully';
    END
    ELSE
    BEGIN
        PRINT 'PermissionTypeID 210 (ManagePLS) already exists';
    END
    
    -- PermissionTypeID 211: Menu PLS
    IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE PermissionTypeId = 211)
    BEGIN
        INSERT INTO dbo.PermissionType (PermissionTypeId, Name, Description)
        VALUES (211, 'Menu PLS', 'Allows user to view PLS menu');
        PRINT 'PermissionTypeID 211 (Menu PLS) inserted successfully';
    END
    ELSE
    BEGIN
        PRINT 'PermissionTypeID 211 (Menu PLS) already exists';
    END
    
    -- PermissionTypeID 212: View PLS History
    IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE PermissionTypeId = 212)
    BEGIN
        INSERT INTO dbo.PermissionType (PermissionTypeId, Name, Description)
        VALUES (212, 'View PLS History', 'View past PLS listings');
        PRINT 'PermissionTypeID 212 (View PLS History) inserted successfully';
    END
    ELSE
    BEGIN
        PRINT 'PermissionTypeID 212 (View PLS History) already exists';
    END
    
    -- PermissionTypeID 213: PLS Radar
    IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE PermissionTypeId = 213)
    BEGIN
        INSERT INTO dbo.PermissionType (PermissionTypeId, Name, Description)
        VALUES (213, 'PLS Radar', 'ADMIN - View PLS across all users');
        PRINT 'PermissionTypeID 213 (PLS Radar) inserted successfully';
    END
    ELSE
    BEGIN
        PRINT 'PermissionTypeID 213 (PLS Radar) already exists';
    END
    
    -- PermissionTypeID 214: PLS Submit While Impersonating
    IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE PermissionTypeId = 214)
    BEGIN
        INSERT INTO dbo.PermissionType (PermissionTypeId, Name, Description)
        VALUES (214, 'PLS Submit While Impersonating', 'ADMIN - Create PLS for other users');
        PRINT 'PermissionTypeID 214 (PLS Submit While Impersonating) inserted successfully';
    END
    ELSE
    BEGIN
        PRINT 'PermissionTypeID 214 (PLS Submit While Impersonating) already exists';
    END
END
ELSE
BEGIN
    PRINT 'WARNING: PermissionType table does not exist';
    PRINT '         Verify your permission table structure and adjust inserts accordingly';
    PRINT '         Permissions may be in a different table (e.g., Permission, RolePermission)';
END
GO

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION - Check inserted data';
PRINT '========================================';
GO

-- Verify StatusType inserts
USE MlsListing;
GO
SELECT 'StatusType' AS TableName, StatusTypeID, Name, Description
FROM dbo.StatusType
WHERE StatusTypeID IN (6, 14)
ORDER BY StatusTypeID;
GO

-- Verify Mls insert
SELECT 'Mls' AS TableName, MlsID, Name, Description
FROM dbo.Mls
WHERE MlsID = 777;
GO

-- Verify PropertyCastType insert
USE FarmGenie;
GO
SELECT 'PropertyCastType' AS TableName, PropertyCastTypeId, Name, Description
FROM dbo.PropertyCastType
WHERE PropertyCastTypeId = 4;
GO

-- Verify PermissionType inserts
IF OBJECT_ID('dbo.PermissionType', 'U') IS NOT NULL
BEGIN
    SELECT 'PermissionType' AS TableName, PermissionTypeId, Name, Description
    FROM dbo.PermissionType
    WHERE PermissionTypeId BETWEEN 210 AND 214
    ORDER BY PermissionTypeId;
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Master Data Inserts Complete';
PRINT '========================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Verify all inserts were successful (check output above)';
PRINT '2. If PermissionType table structure differs, adjust inserts';
PRINT '3. Grant permissions to appropriate users/roles';
PRINT '4. Update blueprint to reflect MlsID = 777 (not 999)';
GO

