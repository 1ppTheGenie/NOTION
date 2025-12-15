# Versium Cache Migration SOP
## DataTree PropertyID → Attom PropertyID Preservation

| Document | Version | Date Created | Author |
|----------|---------|--------------|--------|
| SOP_VersiumCache_DataTreeToAttom_Migration | v1 | 12/14/2025 | TheGenie AI |

---

## 📋 Executive Summary

When TheGenie platform migrated from **First American (DataTree)** property data to **Attom** property data, the PropertyIDs changed. This created a risk of losing **17.7 million cached Versium lookup records** worth approximately **$15 million in credits**.

This SOP documents the reverse-engineering analysis and migration solution to **preserve the Versium cache** and avoid re-paying for data append lookups.

---

## 📊 Current State Analysis

### Versium Cache Statistics

| Metric | Value |
|--------|-------|
| **Total Cache Records** | 17,753,324 |
| **Unique PropertyIDs** | 3,226,651 |
| **Cache Date Range** | 07/26/2018 → 12/13/2025 |
| **Years of Data** | 7+ years |

### PropertyID Mapping Coverage

| Metric | Value |
|--------|-------|
| **PropertyIDs in ViewAssessor** | 3,221,370 (99.8%) |
| **PropertyIDs with FIPS+APN** | 3,221,370 |
| **PropertyIDs Mapped to Attom** | 680,182 (21.1%) |
| **PropertyIDs Not in Attom** | 2,546,469 |

### Why Only 21% Mapped?

Attom data currently only covers **6 states**:

| State | Attom Records |
|-------|---------------|
| California | 1,217,012 |
| Florida | 1,001,555 |
| Texas | 997,322 |
| North Carolina | 344,409 |
| Minnesota | 149,457 |
| Colorado | 127,694 |
| **TOTAL** | 3,837,449 |

---

## 🔧 Technical Architecture

### Cache Key Structure

The Versium cache uses lookup keys in this format:

```
::PID-{PropertyId}::L-{LastName}::F-{FirstName}
```

**Example:**
```
::PID-18808742::L-RICHTER::F-KENNETH
```

### The Problem

When PropertyIDs change:
- Old: `::PID-18808742::L-RICHTER::F-KENNETH` (DataTree ID)
- New: `::PID-40628215::L-RICHTER::F-KENNETH` (Attom ID)

The cache lookup **MISSES** because the key is different, causing:
1. A new Versium API call
2. Additional credit charges
3. Lost cached data

### The Solution

**Map old DataTree PropertyIDs to new Attom PropertyIDs using:**
- **FIPS Code** (County identifier)
- **APN (Assessor Parcel Number)** with dash normalization

```sql
-- Mapping Logic
JOIN AttomDataAssessor a 
ON v.FIPS = a.SitusStateCountyFIPS 
AND v.FormattedAPN = REPLACE(a.ParcelNumberRaw, '-', '')
```

---

## 📁 Database Objects Created

### 1. Mapping Table: `FarmGenie.dbo.CachePropertyIdMapping`

Stores the mapping between old and new PropertyIDs for cached records.

| Column | Type | Description |
|--------|------|-------------|
| OldPropertyId | BIGINT | Original DataTree PropertyID |
| NewAttomId | BIGINT | Mapped Attom PropertyID |
| FIPS | CHAR(5) | County FIPS code |
| FormattedAPN | VARCHAR(50) | Formatted APN |
| MappingMethod | VARCHAR(20) | How the mapping was found |
| MappedDate | DATETIME2 | When mapping was created |

### 2. Updated Table: `TitleData.dbo.AssessorDataPropertyMap`

The production property mapping table now includes Attom IDs:

| Column | Records Populated |
|--------|-------------------|
| DataTreePropertyId | 11,538,115 ✅ |
| AttomId | 1,598,561 ✅ (Updated 12/14/2025) |

### 3. Stored Procedure: `dbo.usp_MigrateVersiumCache_DataTreeToAttom`

Migrates cache lookup keys from old to new PropertyIDs.

**Usage:**

```sql
-- Preview mode (see what would be updated)
EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 1;

-- Execute mode (actually update the cache)
EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 0;
```

---

## 💰 Cost Savings Analysis

### Credits Saved

| Metric | Value |
|--------|-------|
| PropertyIDs with Attom Mapping | 680,182 |
| Average Cache Records per Property | 5.5 |
| Estimated Cache Records Preserved | 3,741,001 |
| Credits per Re-lookup (Booster) | 22 |
| **Total Credits Saved** | **14,964,004** |

### If Not Migrated

Without this migration, when the system switches to Attom IDs:
- ❌ All 17.7M cache records become orphaned
- ❌ All properties re-charged by Versium
- ❌ ~15M credits wasted

---

## 📋 Migration Procedure

### Pre-Migration Checklist

- [ ] Verify database connectivity
- [ ] Confirm `CachePropertyIdMapping` table exists with data
- [ ] Confirm `AssessorDataPropertyMap.AttomId` is populated
- [ ] Schedule during low-traffic window
- [ ] Notify stakeholders

### Step 1: Preview Migration

```sql
EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 1;
```

Review the output:
- Total records that will be updated
- Sample of before/after key changes

### Step 2: Execute Migration

```sql
EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 0, @BatchSize = 10000;
```

The procedure:
1. Creates backup table: `DataAppendContactLookup_Backup_PreAttomMigration`
2. Updates cache keys in batches
3. Reports progress every 10 batches

### Step 3: Verify Migration

```sql
-- Check sample of migrated records
SELECT TOP 10 
    LookupKeyReadable,
    CreateDate
FROM DataAppendContactLookup
WHERE LookupKeyReadable LIKE '%::PID-40%'  -- Attom IDs are higher
ORDER BY CreateDate DESC;

-- Count migrated records
SELECT COUNT(*) AS MigratedRecords
FROM DataAppendContactLookup
WHERE LookupKeyReadable LIKE '%::PID-4%'
  AND LEN(SUBSTRING(LookupKeyReadable, 7, 
      CHARINDEX('::', LookupKeyReadable, 7) - 7)) > 7;
```

### Post-Migration Tasks

- [ ] Verify cache lookups work with new PropertyIDs
- [ ] Monitor Versium API call volume (should decrease)
- [ ] Remove backup table after 30 days if no issues

---

## ⚠️ Known Limitations

### Coverage Gaps

1. **Attom Data Limited to 6 States** - Properties in other states cannot be migrated until Attom expands coverage

2. **~2.5M Properties Without Attom Match** - These will require new Versium lookups when accessed

### Future Improvements

1. **Expand Attom Mapping** - As Attom adds more states, run mapping refresh
2. **Dual-Key Lookup** - Modify `ActionCacheCheck.cs` to check both old and new keys

---

## 📞 Support

**Questions?** Contact TheGenie development team.

**Files Created:**
- `SQL/usp_MigrateVersiumCache_DataTreeToAttom_v2.sql` - Migration stored procedure
- `FarmGenie.dbo.CachePropertyIdMapping` - Mapping table
- `TitleData.dbo.AssessorDataPropertyMap` - Updated with AttomId column

---

## 📚 Appendix: Key Findings

### Cache Key Generation Code

**File:** `Smart.DataAppend.Core/BLL/Utility.cs`

```csharp
public static string GetLookupCacheKeyReadable(string propertyId, string firstName, string lastName)
{
     return $"::PID-{propertyId}::L-{lastName}::F-{firstName}".ToUpper();
}
```

### Cache Check Flow

**File:** `Smart.DataAppend.Core/BLL/Actions/ActionCacheCheck.cs`

```csharp
private void LoadCacheProperty(DataAppendInput input)
{
    var lookupKey = Utility.GetLookupCacheKeyReadable(input.PropertyId, input.FirstName, input.LastName);
    LoadCache(lookupKey);
    
    // Also check legacy format (TitleCase vs UPPERCASE)
    lookupKey = Utility.GetLookupCacheKeyReadableLegacy(input.PropertyId, input.FirstName, input.LastName);
    AppendCache(lookupKey);
}
```

### PropertyID Source

**File:** `Smart.Core/BLL/Listing/Handler/GetPropertyIdFromListingHandler.cs`

```csharp
public static ResponseWithKey Get(int mlsId, string mlsNumber)
{
    using (var proxy = new ListingProxy())
    {
        var assessor = proxy.GetAssessorByListing(mlsId, mlsNumber);
        response.Key = assessor.PropertyID.GetValueOrDefault();  // This is the PropertyId used in cache
        return response;
    }
}
```

---

*Document Version: 1.0 | Created: 12/14/2025*

