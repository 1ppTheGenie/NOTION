-- ============================================================================
-- Versium Cache Analysis - Fallbrook Report (233048)
-- User: Michael Chiesl (04f46ae2-bff8-4d4f-adc8-a1492f1930d2)
-- Original Purchase: 10/24/2025
-- Attom Migration: 11/06/2025
-- ============================================================================
-- Run these queries BEFORE refresh to establish baseline
-- Then run again AFTER refresh (update @RefreshStartTime) to compare
-- ============================================================================

USE FarmGenie;
GO

-- ============================================================================
-- QUERY 1: Current State Analysis (Before Refresh)
-- ============================================================================
-- Baseline metrics before refresh operation
SELECT 
    COUNT(*) AS TotalDataAppends,
    SUM(CASE WHEN ResultFromCache = 1 THEN 1 ELSE 0 END) AS CacheHits,
    SUM(CASE WHEN ResultFromCache = 0 THEN 1 ELSE 0 END) AS CacheMisses,
    SUM(CreditsUsed) AS TotalCreditsUsed,
    SUM(CASE WHEN ResultFromCache = 1 THEN CreditsUsed ELSE 0 END) AS CreditsFromCache,
    SUM(CASE WHEN ResultFromCache = 0 THEN CreditsUsed ELSE 0 END) AS CreditsFromAPI,
    CAST(SUM(CASE WHEN ResultFromCache = 1 THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100 AS DECIMAL(5,2)) AS CacheHitRatePercent,
    MIN(CreateDate) AS FirstAppendDate,
    MAX(CreateDate) AS LastAppendDate
FROM [FarmGenie].[dbo].[DataAppendFileLog]
WHERE ReportId = 233048
    AND DataAppendProviderId = 3  -- Versium
    AND AspNetUserId = '04f46ae2-bff8-4d4f-adc8-a1492f1930d2';
GO

-- ============================================================================
-- QUERY 2: Response Code Breakdown (Before Refresh)
-- ============================================================================
SELECT 
    ResponseCode,
    ResponseDescription,
    COUNT(*) AS Count,
    SUM(CreditsUsed) AS CreditsUsed,
    SUM(CASE WHEN ResultFromCache = 1 THEN 1 ELSE 0 END) AS FromCache,
    SUM(CASE WHEN ResultFromCache = 0 THEN 1 ELSE 0 END) AS FromAPI
FROM [FarmGenie].[dbo].[DataAppendFileLog]
WHERE ReportId = 233048
    AND DataAppendProviderId = 3  -- Versium
    AND AspNetUserId = '04f46ae2-bff8-4d4f-adc8-a1492f1930d2'
GROUP BY ResponseCode, ResponseDescription
ORDER BY Count DESC;
GO

-- ============================================================================
-- QUERY 3: Property-Level Analysis (Before Refresh)
-- ============================================================================
SELECT 
    PropertyId,
    COUNT(*) AS TotalAppends,
    SUM(CASE WHEN ResultFromCache = 1 THEN 1 ELSE 0 END) AS CacheHits,
    SUM(CASE WHEN ResultFromCache = 0 THEN 1 ELSE 0 END) AS CacheMisses,
    SUM(CreditsUsed) AS TotalCredits,
    MAX(CreateDate) AS LastAppendDate,
    MAX(ResponseDescription) AS LastResponseDescription
FROM [FarmGenie].[dbo].[DataAppendFileLog]
WHERE ReportId = 233048
    AND DataAppendProviderId = 3  -- Versium
    AND AspNetUserId = '04f46ae2-bff8-4d4f-adc8-a1492f1930d2'
GROUP BY PropertyId
ORDER BY TotalCredits DESC;
GO

-- ============================================================================
-- QUERY 4: Cache Key Analysis (Ankit's Finding)
-- ============================================================================
SELECT 
    iul.DataAppendItemUserLogId,
    iul.PropertyId,
    iul.DataAppendTypeId,
    iul.DataAppendContactLookupKey,  -- Encrypted key (PropertyId + firstName + lastName)
    iul.CreateDate,
    cl.LookupKeyReadable,  -- Human-readable key format
    cl.CreateDate AS CacheCreateDate
FROM [FarmGenie].[dbo].[DataAppendItemUserLog] iul
INNER JOIN [FarmGenie].[dbo].[DataAppendContactLookup] cl 
    ON iul.DataAppendContactLookupId = cl.DataAppendContactLookupId
WHERE iul.AspNetUserId = '04f46ae2-bff8-4d4f-adc8-a1492f1930d2'
    AND iul.PropertyId IN (
        SELECT DISTINCT PropertyId 
        FROM [FarmGenie].[dbo].[DataAppendFileLog]
        WHERE ReportId = 233048
            AND PropertyId IS NOT NULL
    )
ORDER BY iul.CreateDate DESC;
GO

-- ============================================================================
-- QUERY 5: Properties with Owner Changes (Since 10/24/2025)
-- ============================================================================
USE TitleData;
GO

SELECT 
    adpm.AttomId AS CurrentPropertyId,
    adpm.DataTreePropertyId AS OldPropertyId,
    adpm.AttomFirstName AS CurrentOwnerFirstName,
    adpm.AttomLastName AS CurrentOwnerLastName,
    adpm.DataTreeFirstName AS OldOwnerFirstName,
    adpm.DataTreeLastName AS OldOwnerLastName,
    CASE 
        WHEN LOWER(LTRIM(RTRIM(adpm.AttomFirstName))) = LOWER(LTRIM(RTRIM(adpm.DataTreeFirstName)))
            AND LOWER(LTRIM(RTRIM(adpm.AttomLastName))) = LOWER(LTRIM(RTRIM(adpm.DataTreeLastName)))
        THEN 'Owner Match - Use Cache'
        ELSE 'Owner Changed - Fetch New'
    END AS OwnerStatus,
    adpm.LastUpdateDate AS AttomLastUpdateDate
FROM [TitleData].[dbo].[AssessorDataPropertyMap] adpm
WHERE adpm.AttomId IN (
    SELECT DISTINCT PropertyId 
    FROM [FarmGenie].[dbo].[DataAppendFileLog]
    WHERE ReportId = 233048
        AND PropertyId IS NOT NULL
)
    AND adpm.DataTreePropertyId IS NOT NULL
    AND adpm.AttomFirstName IS NOT NULL
    AND adpm.AttomLastName IS NOT NULL
ORDER BY OwnerStatus, adpm.AttomId;
GO

-- ============================================================================
-- QUERY 6: Post-Refresh Analysis (After Refresh)
-- ============================================================================
-- UPDATE @RefreshStartTime to the exact time refresh operation started
USE FarmGenie;
GO

DECLARE @RefreshStartTime DATETIME = '2025-12-17 00:00:00';  -- ⚠️ UPDATE THIS to refresh start time

SELECT 
    COUNT(*) AS TotalDataAppends,
    SUM(CASE WHEN ResultFromCache = 1 THEN 1 ELSE 0 END) AS CacheHits,
    SUM(CASE WHEN ResultFromCache = 0 THEN 1 ELSE 0 END) AS CacheMisses,
    SUM(CreditsUsed) AS TotalCreditsUsed,
    CAST(SUM(CASE WHEN ResultFromCache = 1 THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100 AS DECIMAL(5,2)) AS CacheHitRatePercent,
    MIN(CreateDate) AS FirstAppendDate,
    MAX(CreateDate) AS LastAppendDate
FROM [FarmGenie].[dbo].[DataAppendFileLog]
WHERE ReportId = 233048
    AND DataAppendProviderId = 3  -- Versium
    AND AspNetUserId = '04f46ae2-bff8-4d4f-adc8-a1492f1930d2'
    AND CreateDate >= @RefreshStartTime;
GO

-- ============================================================================
-- QUERY 7: New Versium API Calls (After Refresh)
-- ============================================================================
-- Shows properties that did NOT use cache (owner changed or no cache)
DECLARE @RefreshStartTime DATETIME = '2025-12-17 00:00:00';  -- ⚠️ UPDATE THIS to refresh start time

SELECT 
    dafl.PropertyId,
    dafl.DataAppendFileLogId,
    dafl.ResultFromCache,
    dafl.CreditsUsed,
    dafl.ResponseCode,
    dafl.ResponseDescription,
    dafl.CreateDate,
    adpm.DataTreePropertyId AS OldPropertyId,
    adpm.AttomFirstName AS CurrentOwnerFirstName,
    adpm.AttomLastName AS CurrentOwnerLastName,
    adpm.DataTreeFirstName AS OldOwnerFirstName,
    adpm.DataTreeLastName AS OldOwnerLastName,
    CASE 
        WHEN LOWER(LTRIM(RTRIM(adpm.AttomFirstName))) = LOWER(LTRIM(RTRIM(adpm.DataTreeFirstName)))
            AND LOWER(LTRIM(RTRIM(adpm.AttomLastName))) = LOWER(LTRIM(RTRIM(adpm.DataTreeLastName)))
        THEN 'Owner Match'
        ELSE 'Owner Changed'
    END AS OwnerStatus
FROM [FarmGenie].[dbo].[DataAppendFileLog] dafl
LEFT JOIN [TitleData].[dbo].[AssessorDataPropertyMap] adpm 
    ON dafl.PropertyId = adpm.AttomId
WHERE dafl.ReportId = 233048
    AND dafl.DataAppendProviderId = 3  -- Versium
    AND dafl.AspNetUserId = '04f46ae2-bff8-4d4f-adc8-a1492f1930d2'
    AND dafl.CreateDate >= @RefreshStartTime
    AND dafl.ResultFromCache = 0  -- Only new API calls
ORDER BY dafl.CreateDate DESC;
GO

-- ============================================================================
-- QUERY 8: Cache Hit Analysis (After Refresh)
-- ============================================================================
-- Shows properties that successfully used cache
DECLARE @RefreshStartTime DATETIME = '2025-12-17 00:00:00';  -- ⚠️ UPDATE THIS to refresh start time

SELECT 
    dafl.PropertyId,
    dafl.DataAppendFileLogId,
    dafl.ResultFromCache,
    dafl.CreditsUsed,
    dafl.ResponseDescription,
    dafl.CreateDate,
    adpm.DataTreePropertyId AS OldPropertyId,
    CASE 
        WHEN LOWER(LTRIM(RTRIM(adpm.AttomFirstName))) = LOWER(LTRIM(RTRIM(adpm.DataTreeFirstName)))
            AND LOWER(LTRIM(RTRIM(adpm.AttomLastName))) = LOWER(LTRIM(RTRIM(adpm.DataTreeLastName)))
        THEN 'Owner Match - Cache Valid'
        ELSE 'Owner Changed - Cache Should NOT Be Used'
    END AS OwnerStatus
FROM [FarmGenie].[dbo].[DataAppendFileLog] dafl
LEFT JOIN [TitleData].[dbo].[AssessorDataPropertyMap] adpm 
    ON dafl.PropertyId = adpm.AttomId
WHERE dafl.ReportId = 233048
    AND dafl.DataAppendProviderId = 3  -- Versium
    AND dafl.AspNetUserId = '04f46ae2-bff8-4d4f-adc8-a1492f1930d2'
    AND dafl.CreateDate >= @RefreshStartTime
    AND dafl.ResultFromCache = 1  -- Only cache hits
ORDER BY dafl.CreateDate DESC;
GO

