-- ============================================
-- Competition Command: Extract Production Data
-- Version 1.0 | Created: 12/14/2025
-- Source: Production (192.168.29.45 / FarmGenie)
-- Target: Local FarmGenie_Dev
-- ============================================

-- RUN THIS ON PRODUCTION to extract data
-- Then import to local FarmGenie_Dev

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE FarmGenie;
GO

PRINT '============================================';
PRINT 'EXTRACTING PRODUCTION DATA FOR LOCAL DEV';
PRINT 'Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================';
PRINT '';

-- ============================================
-- STEP 1: Get counts first
-- ============================================

PRINT '--- RECORD COUNTS ---';

SELECT 'UserOwnedArea (Active Ownership)' AS TableName, COUNT(*) AS Records FROM dbo.UserOwnedArea;
-- SELECT 'PropertyCollectionDetail (Campaigns)' AS TableName, COUNT(*) AS Records FROM dbo.PropertyCollectionDetail WHERE AreaId IS NOT NULL;
-- SELECT 'PropertyCast (CC Only)' AS TableName, COUNT(*) AS Records FROM dbo.PropertyCast WHERE PropertyCastTypeId = 1;

-- ============================================
-- STEP 2: Extract UserOwnedArea (current ownership)
-- ============================================

PRINT '';
PRINT '--- CURRENT OWNERSHIP (UserOwnedArea) ---';

SELECT 
    uoa.UserOwnedAreaId,
    uoa.AspNetUserId,
    u.UserName AS Email,
    up.FirstName,
    up.LastName,
    uoa.AreaId,
    COALESCE(pno.FriendlyName, va.Name) AS AreaName,
    va.State,
    va.ZipCode,
    uoa.PropertyTypeId,
    CASE uoa.PropertyTypeId 
        WHEN 0 THEN 'SFR'
        WHEN 1 THEN 'Condo'
        WHEN 2 THEN 'Townhouse'
        WHEN 3 THEN 'Multi-Family'
        ELSE 'Unknown'
    END AS PropertyTypeName,
    uoa.AreaOwnershipTypeId,
    uoa.CreateDate,
    
    -- Customer Status
    CASE WHEN cust.CustomerId IS NOT NULL AND cust.Status = 'Active' THEN 'Active' ELSE 'Inactive' END AS CustomerStatus,
    cust.Status AS WHMCSStatus,
    cust.DateJoined,
    cust.LastPaymentDate
    
FROM dbo.UserOwnedArea uoa
INNER JOIN dbo.AspNetUsers u ON u.Id = uoa.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up ON up.AspNetUserId = uoa.AspNetUserId
LEFT JOIN dbo.ViewArea va ON va.AreaId = uoa.AreaId
LEFT JOIN dbo.PolygonNameOverride pno ON pno.PolygonId = uoa.AreaId AND pno.AspNetUserId = uoa.AspNetUserId
LEFT JOIN dbo.Customer cust ON cust.AspNetUserId = uoa.AspNetUserId
ORDER BY uoa.CreateDate DESC;

-- ============================================
-- STEP 3: Identify INACTIVE customers with ACTIVE areas
-- (The 80% we need to test)
-- ============================================

PRINT '';
PRINT '--- INACTIVE CUSTOMERS WITH ACTIVE AREAS ---';
PRINT '(These are the ~80% that need to be cleaned up)';

SELECT 
    uoa.UserOwnedAreaId,
    uoa.AspNetUserId,
    u.UserName AS Email,
    COALESCE(up.FirstName + ' ' + up.LastName, u.UserName) AS CustomerName,
    uoa.AreaId,
    COALESCE(pno.FriendlyName, va.Name) AS AreaName,
    va.ZipCode,
    uoa.CreateDate AS OwnershipStartDate,
    DATEDIFF(DAY, uoa.CreateDate, GETDATE()) AS DaysOwned,
    cust.Status AS WHMCSStatus,
    cust.LastPaymentDate,
    DATEDIFF(DAY, cust.LastPaymentDate, GETDATE()) AS DaysSinceLastPayment
    
FROM dbo.UserOwnedArea uoa
INNER JOIN dbo.AspNetUsers u ON u.Id = uoa.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up ON up.AspNetUserId = uoa.AspNetUserId
LEFT JOIN dbo.ViewArea va ON va.AreaId = uoa.AreaId
LEFT JOIN dbo.PolygonNameOverride pno ON pno.PolygonId = uoa.AreaId AND pno.AspNetUserId = uoa.AspNetUserId
LEFT JOIN dbo.Customer cust ON cust.AspNetUserId = uoa.AspNetUserId
WHERE 
    cust.Status IS NULL                    -- No WHMCS record at all
    OR cust.Status != 'Active'             -- WHMCS status not Active
    OR cust.LastPaymentDate < DATEADD(MONTH, -3, GETDATE())  -- No payment in 3+ months
ORDER BY DATEDIFF(DAY, cust.LastPaymentDate, GETDATE()) DESC;

-- ============================================
-- STEP 4: Summary stats
-- ============================================

PRINT '';
PRINT '--- SUMMARY STATISTICS ---';

SELECT 
    COUNT(*) AS TotalActiveAreas,
    SUM(CASE WHEN cust.Status = 'Active' THEN 1 ELSE 0 END) AS ActiveCustomers,
    SUM(CASE WHEN cust.Status IS NULL OR cust.Status != 'Active' THEN 1 ELSE 0 END) AS InactiveCustomers,
    CAST(SUM(CASE WHEN cust.Status IS NULL OR cust.Status != 'Active' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100 AS DECIMAL(5,2)) AS InactivePercent
FROM dbo.UserOwnedArea uoa
LEFT JOIN dbo.Customer cust ON cust.AspNetUserId = uoa.AspNetUserId;

PRINT '';
PRINT 'Extraction complete.';
GO

