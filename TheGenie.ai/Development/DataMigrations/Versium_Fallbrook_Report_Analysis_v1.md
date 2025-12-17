# Versium Cache Analysis - Fallbrook Report (233048)
**Date:** 12/17/2025  
**Report ID:** 233048  
**User:** Michael Chiesl  
**AspNetUserId:** `04f46ae2-bff8-4d4f-adc8-a1492f1930d2`  
**Location:** Fallbrook  
**Original Purchase Date:** 10/24/2025  
**Attom Migration Date:** 11/06/2025

---

## EXECUTIVE SUMMARY

### Purpose
Analyze Versium cache behavior for Fallbrook report (233048) before and after refresh to:
1. Track Versium credit usage
2. Verify cache hit rates
3. Identify properties with owner changes since 10/24/2025
4. Ensure only properties with changed owners trigger new Versium API calls

### Ankit's Findings (Key Context)
- **`DataAppendFileLog`** tracks data appends for each ReportId
- System creates encrypted key from **PropertyId, firstName, lastName**
- Key stored in **`DataAppendItemUserLog.DataAppendContactLookupKey`**
- System compares with assessor property data's firstName/lastName to decide cache vs. new request
- Response "Previously Purchased Append Data" indicates cache hit (no credit used)

---

## ANALYSIS QUERIES

### Query 1: Current State Analysis (Before Refresh)
**Purpose:** Baseline metrics before refresh operation

```sql
-- Current State: Fallbrook Report Data Append Activity
-- Report ID: 233048
-- User: Michael Chiesl (04f46ae2-bff8-4d4f-adc8-a1492f1930d2)

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
```

### Query 2: Response Code Breakdown (Before Refresh)
**Purpose:** Understand current response types

```sql
-- Response Code Analysis: Fallbrook Report
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
```

### Query 3: Property-Level Analysis (Before Refresh)
**Purpose:** See which properties have cache entries

```sql
-- Property-Level Cache Status: Fallbrook Report
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
```

### Query 4: Cache Key Analysis (Ankit's Finding)
**Purpose:** Examine the encrypted cache keys being used

```sql
-- Cache Key Analysis: DataAppendItemUserLog
-- Shows the encrypted keys (PropertyId + firstName + lastName)
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
    )
ORDER BY iul.CreateDate DESC;
```

### Query 5: Properties with Owner Changes (Since 10/24/2025)
**Purpose:** Identify properties that changed owners (should trigger new Versium calls)

```sql
-- Properties with Owner Changes Since Original Purchase (10/24/2025)
-- Compare Attom owner names with DataTree owner names from cache
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
```

### Query 6: Post-Refresh Analysis (After Refresh)
**Purpose:** Compare metrics after refresh operation

```sql
-- Post-Refresh Analysis: Fallbrook Report
-- Run this AFTER refresh operation completes
-- Compare with Query 1 results

DECLARE @RefreshStartTime DATETIME = '2025-12-17 00:00:00';  -- UPDATE THIS to refresh start time

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
```

### Query 7: New Versium API Calls (After Refresh)
**Purpose:** Identify which properties triggered new Versium API calls

```sql
-- New Versium API Calls After Refresh
-- Shows properties that did NOT use cache (owner changed or no cache)

DECLARE @RefreshStartTime DATETIME = '2025-12-17 00:00:00';  -- UPDATE THIS to refresh start time

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
```

### Query 8: Cache Hit Analysis (After Refresh)
**Purpose:** Verify cache is being used correctly

```sql
-- Cache Hit Analysis After Refresh
-- Shows properties that successfully used cache

DECLARE @RefreshStartTime DATETIME = '2025-12-17 00:00:00';  -- UPDATE THIS to refresh start time

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
```

---

## EXPECTED BEHAVIOR

### Before Refresh (Current State)
- **Cache Hit Rate:** Should be > 0% if smart cache lookup is working
- **Response Description:** Should see "Previously Purchased Append Data" for cache hits
- **Credits Used:** Should be 0 for cache hits, 1 for API calls

### After Refresh (Expected)
- **Properties with Owner Match:** Should use cache (0 credits, ResultFromCache = 1)
- **Properties with Owner Change:** Should fetch new Versium data (1 credit, ResultFromCache = 0)
- **Properties with No Cache:** Should fetch new Versium data (1 credit, ResultFromCache = 0)

### Success Criteria
1. ✅ Cache hits for properties where owner hasn't changed
2. ✅ New API calls only for properties with owner changes or no cache
3. ✅ Credits used = 0 for cache hits
4. ✅ Credits used = 1 for new API calls
5. ✅ Response description shows "Previously Purchased Append Data" for cache hits

---

## ANKIT'S FINDINGS - TECHNICAL CONTEXT

### Cache Key Generation
- **Format:** Encrypted MD5 hash of `PropertyId + firstName + lastName`
- **Storage:** `DataAppendItemUserLog.DataAppendContactLookupKey`
- **Lookup:** System compares encrypted key with assessor property firstName/lastName

### Cache Decision Logic
1. Generate key from current PropertyId (Attom), firstName, lastName
2. Look up in `DataAppendItemUserLog` by PropertyId and DataAppendTypeId
3. Compare encrypted key with stored keys
4. If match found → Use cache (0 credits)
5. If no match → Fetch new Versium data (1 credit)

### Current Issue
- Old cache entries use **DataTree PropertyIDs**
- New requests use **Attom PropertyIDs**
- Cache lookup fails because PropertyIDs don't match
- **Solution:** Smart cache lookup checks DataTree PropertyID if Attom lookup fails

---

## TESTING INSTRUCTIONS

### Step 1: Run Baseline Queries (Before Refresh)
1. Execute Query 1 (Current State Analysis)
2. Execute Query 2 (Response Code Breakdown)
3. Execute Query 3 (Property-Level Analysis)
4. Execute Query 5 (Properties with Owner Changes)
5. **Save results** for comparison

### Step 2: Perform Refresh Operation
1. User initiates refresh/optimize for Report ID 233048
2. **Note the exact start time** (needed for post-refresh queries)

### Step 3: Run Post-Refresh Queries
1. Update `@RefreshStartTime` in Queries 6, 7, 8
2. Execute Query 6 (Post-Refresh Analysis)
3. Execute Query 7 (New Versium API Calls)
4. Execute Query 8 (Cache Hit Analysis)
5. **Compare with baseline** results

### Step 4: Analysis
1. Calculate cache hit rate improvement
2. Count properties with owner changes
3. Verify credits saved (cache hits = 0 credits)
4. Verify new API calls only for owner changes or no cache

---

## METRICS TO TRACK

### Before Refresh
- Total data appends
- Cache hits
- Cache misses
- Total credits used
- Cache hit rate %

### After Refresh
- New data appends (since refresh start)
- New cache hits
- New cache misses
- New credits used
- New cache hit rate %
- Properties with owner changes
- Properties with owner matches

### Comparison
- Cache hit rate improvement
- Credits saved (cache hits = 0 credits)
- Properties correctly using cache
- Properties correctly fetching new data

---

## DISCOVERY QUESTIONS

1. **What is the current cache hit rate for Report 233048?**
   - Run Query 1 to find out

2. **How many properties have owner changes since 10/24/2025?**
   - Run Query 5 to identify

3. **Are we using cache correctly (owner match = cache, owner change = new)?**
   - Run Queries 7 and 8 after refresh to verify

4. **How many Versium credits will be used for the refresh?**
   - Run Query 6 after refresh to calculate

5. **Is the smart cache lookup working (checking DataTree cache when Attom cache fails)?**
   - Compare cache hit rates before/after implementation

---

## NOTES

- **Report ID:** 233048
- **User:** Michael Chiesl
- **AspNetUserId:** `04f46ae2-bff8-4d4f-adc8-a1492f1930d2`
- **Original Purchase:** 10/24/2025
- **Attom Migration:** 11/06/2025
- **Current Data:** Last sold date = 2023
- **Expected After Refresh:** Last sold date = 2025

---

**This analysis will verify that the Versium cache system is working correctly and only fetching new data when properties have changed owners.**

*Created: 12/17/2025*

