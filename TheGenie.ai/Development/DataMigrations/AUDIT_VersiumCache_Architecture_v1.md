# Versium Cache Architecture Audit
## Technical Analysis Report
### Version 1.0 | Date: 12/14/2025

---

## Document Purpose

This audit documents the reverse-engineering analysis of TheGenie's Versium data append caching system, performed to understand how cached lookups could be preserved during the property data provider migration from First American (DataTree) to Attom.

---

## Executive Summary

| Finding | Impact |
|---------|--------|
| Cache uses PropertyID in lookup key | PropertyID change = cache invalidation |
| 17.7M cached records at risk | ~15M Versium credits if lost |
| Mapping possible via FIPS + APN | 680K PropertyIDs successfully mapped |
| AttomId column was empty | Updated with 1.6M mappings |

---

## 1. Cache System Architecture

### 1.1 Cache Key Structure

The Versium cache stores lookup results using a composite key:

```
::PID-{PropertyId}::L-{LastName}::F-{FirstName}
```

**Example:**
```
::PID-18808742::L-RICHTER::F-KENNETH
```

**Source Code:** `Smart.DataAppend.Core/BLL/Utility.cs`

```csharp
public static string GetLookupCacheKeyReadable(string propertyId, string firstName, string lastName)
{
     return $"::PID-{propertyId}::L-{lastName}::F-{firstName}".ToUpper();
}
```

### 1.2 Cache Table

**Table:** `FarmGenie.dbo.DataAppendContactLookup`

| Column | Type | Purpose |
|--------|------|---------|
| DataAppendContactLookupId | INT | Primary key |
| LookupKeyReadable | NVARCHAR | The cache key (::PID-X::L-Y::F-Z) |
| DataAppendProviderId | INT | Provider (3 = Versium) |
| DataAppendActionTypeId | INT | Action type (Email, Phone, etc.) |
| ResponseJson | NVARCHAR(MAX) | Cached response data |
| CreateDate | DATETIME2 | When cached |

### 1.3 Cache Lookup Flow

```
1. Request comes in with PropertyId, FirstName, LastName
2. Generate lookup key: ::PID-{PropertyId}::L-{LastName}::F-{FirstName}
3. Check DataAppendContactLookup for matching key
4. If found → Return cached data (no Versium API call)
5. If not found → Call Versium API, cache result
```

**Source Code:** `Smart.DataAppend.Core/BLL/Actions/ActionCacheCheck.cs`

```csharp
private void LoadCacheProperty(DataAppendInput input)
{
    var lookupKey = Utility.GetLookupCacheKeyReadable(input.PropertyId, input.FirstName, input.LastName);
    LoadCache(lookupKey);
    
    // Also check legacy format
    lookupKey = Utility.GetLookupCacheKeyReadableLegacy(input.PropertyId, input.FirstName, input.LastName);
    AppendCache(lookupKey);
}
```

---

## 2. Current Cache Statistics

### 2.1 Overall Metrics

| Metric | Value |
|--------|-------|
| **Total Cache Records** | 17,753,324 |
| **Unique Cache Keys** | 4,806,863 |
| **Unique PropertyIDs** | 3,226,651 |
| **Oldest Record** | 07/26/2018 |
| **Newest Record** | 12/13/2025 |
| **Years of Data** | 7+ years |

### 2.2 Cache Records per PropertyID

| Metric | Value |
|--------|-------|
| Average | 5.5 records |
| Reason | Multiple API types (Email, Phone, Demographics, Financial) |

---

## 3. PropertyID Mapping Analysis

### 3.1 Data Sources

| Source | Records | ID Range |
|--------|---------|----------|
| ViewAssessor_v3 | 46,705,455 | 4,134,346 → 180,808,347 |
| AssessorDataPropertyMap | 11,538,115 | 4,136,285 → 175,299,629 |
| AttomDataAssessor | 3,837,449 | 88,530 → 1,003,268,533 |

### 3.2 AssessorDataPropertyMap Structure

| Column | Populated Before | Populated After |
|--------|------------------|-----------------|
| PropertyId | 11,538,115 | 11,538,115 |
| DataTreePropertyId | 11,538,115 | 11,538,115 |
| AttomId | **0** | **1,598,561** |

**Key Finding:** The AttomId column existed but was completely empty before this audit.

### 3.3 Mapping Key Discovery

After testing multiple approaches, the successful mapping key was:

```sql
-- Mapping Logic
JOIN AttomDataAssessor a 
ON v.FIPS = a.SitusStateCountyFIPS 
AND v.FormattedAPN = REPLACE(a.ParcelNumberRaw, '-', '')
```

**Example:**
| Old DataTree ID | FormattedAPN | Attom ParcelNumberRaw | New Attom ID |
|-----------------|--------------|----------------------|--------------|
| 18808742 | 2581010300 | 258-101-03-00 | 40628215 |

---

## 4. Mapping Results

### 4.1 Cache PropertyID Mapping

| Metric | Value |
|--------|-------|
| Total Cached PropertyIDs | 3,226,651 |
| Found in ViewAssessor | 3,221,370 (99.8%) |
| Mapped to Attom ID | 680,182 (21.1%) |
| No Attom Match | 2,546,469 |

### 4.2 Why Only 21% Mapped?

Attom data currently covers only **6 states**:

| State | FIPS Prefix | Attom Records |
|-------|-------------|---------------|
| California | 06 | 1,217,012 |
| Florida | 12 | 1,001,555 |
| Texas | 48 | 997,322 |
| North Carolina | 37 | 344,409 |
| Minnesota | 27 | 149,457 |
| Colorado | 08 | 127,694 |

### 4.3 Mapping by State

| State FIPS | Cached Records | Mapped | Rate |
|------------|----------------|--------|------|
| 06 (CA) | 2,185,701 | 440,486 | 20.15% |
| 48 (TX) | 802,302 | 178,086 | 22.20% |
| 12 (FL) | 203,096 | 61,610 | 30.34% |
| 32 (NV) | 20,901 | 0 | 0% |
| 08 (CO) | 9,361 | 0 | 0% |

---

## 5. Risk Assessment

### 5.1 If Cache Not Migrated

| Scenario | Impact |
|----------|--------|
| All cache keys orphaned | 17.7M records useless |
| All lookups re-charged | ~15M credits |
| Years of data lost | 7+ years |

### 5.2 ID Collision Risk

There are **1,023,655 overlapping IDs** where an AttomId happens to equal an existing ViewAssessor PropertyId. This could cause **false cache hits** if not handled properly.

---

## 6. Database Objects Created

### 6.1 Mapping Table

```sql
-- FarmGenie.dbo.CachePropertyIdMapping
CREATE TABLE dbo.CachePropertyIdMapping (
    OldPropertyId BIGINT,
    NewAttomId BIGINT NULL,
    FIPS CHAR(5) NULL,
    FormattedAPN VARCHAR(50) NULL,
    MappingMethod VARCHAR(20) NULL,
    MappedDate DATETIME2 NULL
);
-- 3,226,651 rows
```

### 6.2 Updated Production Table

```sql
-- TitleData.dbo.AssessorDataPropertyMap
-- AttomId column updated from 0 to 1,598,561 rows
UPDATE m SET m.AttomId = a.AttomId, m.LastUpdate = GETUTCDATE()
FROM dbo.AssessorDataPropertyMap m
JOIN ViewAssessor_v3 v ON m.PropertyId = v.PropertyId
JOIN AttomDataAssessor a ON v.FIPS = a.SitusStateCountyFIPS 
  AND v.FormattedAPN = REPLACE(a.ParcelNumberRaw, '-', '');
```

### 6.3 Migration Stored Procedure

```sql
-- FarmGenie.dbo.usp_MigrateVersiumCache_DataTreeToAttom
-- See SOP_VersiumCache_Migration_v1.md for details
```

---

## 7. Recommendations

### 7.1 Immediate

1. **Do NOT switch to Attom IDs** until cache is migrated
2. **Run migration procedure** before PropertyID changeover
3. **Monitor Versium API calls** after migration to verify cache hits

### 7.2 Future

1. **Re-run mapping** as Attom expands state coverage
2. **Consider dual-key lookup** in application code
3. **Create cache refresh job** for properties with ownership changes

---

## 8. Source Code References

| File | Purpose |
|------|---------|
| `Smart.DataAppend.Core/BLL/Utility.cs` | Cache key generation |
| `Smart.DataAppend.Core/BLL/Actions/ActionCacheCheck.cs` | Cache lookup logic |
| `Smart.DataAppend.Core/BLL/Actions/Versium/ActionContactBase.cs` | Versium API calls |
| `Smart.DataAppend.Data/Repository/DataAppendRepository.cs` | Data access |

---

## Appendix A: Sample Cache Keys

| CreateDate | LookupKeyReadable |
|------------|-------------------|
| 2018-07-26 | ::PID-18808742::L-RICHTER::F-KENNETH |
| 2018-07-26 | ::PID-18808744::L-PATTEN::F- |
| 2018-07-26 | ::PID-18808763::L-SHELLEY::F-SHANE & CATHERINE |
| 2025-12-13 | ::PID-33423780::L-THOMPSON::F-MICHAEL |
| 2025-12-13 | ::PID-33381033::L-SHUMAN::F-ELIZABETH |

---

*Document Version: 1.0 | Created: 12/14/2025 | Author: TheGenie AI*

