# Versium Cache Fix - Deployment Specification
**For: Ankit & Development Team**  
**Date:** 12/16/2025  
**Version:** 1.0  
**Status:** Ready for Implementation

---

## EXECUTIVE SUMMARY

### The Problem
We have **17.7 million Versium cache entries** representing **~15 million Versium credits** worth of data. This cache is currently **not being used** - every data append request is fetching new Versium data instead of using the existing cache, wasting credits we've already paid for.

**Root Cause:** On November 6, 2025, we migrated property data providers from First American (DataTree) to Attom Data Solutions. Our Versium cache uses PropertyIDs in the cache lookup key. All 17.7M cache entries use **DataTree PropertyIDs**, but the system now uses **Attom PropertyIDs** for all new requests. Result: Cache keys don't match → Cache lookups fail → Zero cache hits.

**Business Impact:**
- **Credits at Risk:** ~15 million Versium credits
- **Cache Hit Rate Since Migration:** 0% (was working before)
- **Cost:** Every data append is wasting credits we've already paid for

### The Solution
**Smart cache lookup with owner validation** that preserves and utilizes existing 17.7M cache entries:

1. Check Attom cache first (for new cache entries going forward)
2. If not found, get DataTree PropertyID from `AssessorDataPropertyMap`
3. Compare owner names (Attom vs DataTree):
   - **If owners match:** Property hasn't transferred → Use existing DataTree cache ✅
   - **If owners differ:** Property transferred → Fetch new Versium data for new owner ✅
4. New Versium data gets cached with Attom PropertyID (future-proof)

**Why Owner Validation is Critical:**
- If property transferred to new owner, old cache is for wrong person
- Owner name comparison ensures cache is still valid
- Prevents data quality issues from stale cache

**Business Benefits:**
- **Saves ~15M Versium credits** (immediate savings)
- **Preserves all 17.7M existing cache entries** (no data loss)
- **Future-proof** (new cache uses Attom IDs automatically)
- **Zero downtime** (backward compatible, no data changes)

---

## CODE CHANGES REQUIRED

### File: `Smart.DataAppend.Core/BLL/Actions/ActionCacheCheck.cs`

### Method: `LoadCacheProperty()`

**Current Implementation:**
```csharp
private void LoadCacheProperty(DataAppendInput input)
{
    var lookupKey = Utility.GetLookupCacheKeyReadable(input.PropertyId, input.FirstName, input.LastName);
    LoadCache(lookupKey);
}
```

**New Implementation:**
```csharp
private void LoadCacheProperty(DataAppendInput input)
{
    // Step 1: Try Attom cache first (for new cache entries with Attom IDs)
    var attomKey = Utility.GetLookupCacheKeyReadable(input.PropertyId, input.FirstName, input.LastName);
    if (LoadCache(attomKey)) 
    {
        return; // Found in Attom cache - use it
    }

    // Step 2: Get DataTree PropertyID and owner from AssessorDataPropertyMap
    var propertyMap = GetPropertyMap(input.PropertyId);
    if (propertyMap?.DataTreePropertyId == null) 
    {
        return; // No mapping found, proceed to fetch new
    }

    // Step 3: Validate owner names match
    if (OwnerNamesMatch(input.FirstName, input.LastName, propertyMap))
    {
        // Owners match - property hasn't transferred, safe to use DataTree cache
        var dataTreeKey = Utility.GetLookupCacheKeyReadable(
            propertyMap.DataTreePropertyId.Value, 
            input.FirstName, 
            input.LastName
        );
        if (LoadCache(dataTreeKey)) 
        {
            return; // Found in DataTree cache - use it!
        }
    }
    // If owners differ OR no cache found, proceed to fetch new Versium data
    // (New data will be cached with Attom PropertyID)
}

private bool OwnerNamesMatch(string attomFirst, string attomLast, PropertyMap map)
{
    return string.Equals(attomFirst, map.DataTreeFirstName, StringComparison.OrdinalIgnoreCase) &&
           string.Equals(attomLast, map.DataTreeLastName, StringComparison.OrdinalIgnoreCase);
}

private PropertyMap GetPropertyMap(int attomPropertyId)
{
    // Query TitleData.dbo.AssessorDataPropertyMap
    // WHERE AttomId = attomPropertyId
    // Return: DataTreePropertyId, DataTreeFirstName, DataTreeLastName
    // Implementation depends on existing data access layer
}
```

### Helper Method Required

**`GetPropertyMap(int attomPropertyId)`** - Queries `AssessorDataPropertyMap` to get DataTree PropertyID and owner names

**SQL Query:**
```sql
SELECT 
    DataTreePropertyId,
    DataTreeFirstName,
    DataTreeLastName
FROM TitleData.dbo.AssessorDataPropertyMap
WHERE AttomId = @attomPropertyId
```

**Note:** Implementation depends on existing data access layer. Use the same pattern as other TitleData queries in the codebase.

---

## DATABASE SCHEMA

### Key Tables

| Table | Database | Purpose |
|-------|----------|---------|
| `DataAppendContactLookup` | FarmGenie | Versium cache entries (17.7M records) |
| `CachePropertyIdMapping` | FarmGenie | DataTree → Attom PropertyID mapping (680K mappings) |
| `AssessorDataPropertyMap` | TitleData | Property data with both Attom and DataTree IDs, owner names |

### Cache Key Format

```
::PID-{PropertyId}::L-{LastName}::F-{FirstName}
```

**Example:**
- **Before:** `::PID-15237408::L-THOMAS::F-F` (DataTree ID) → ✅ Found
- **After:** `::PID-155176603::L-THOMAS::F-F` (Attom ID) → ❌ Not found (until we check DataTree cache)

---

## TESTING PLAN

### Test Strategy

1. **Sandbox/Production Testing** (recommended - more reliable than local)
2. **Test Accounts Identified:**
   - Mike Campbell: AspNetUserId `893ffd3f-1bb7-441f-ae58-0fecb1e680df`
   - Higgins: AspNetUserId `23d254fe-792f-44b2-b40f-9b1d7a12189d`
   - Test Report: 190860 (Lido Park)

### Verification Query

```sql
SELECT 
    COUNT(*) AS TotalProperties,
    SUM(CASE WHEN ResultFromCache = 1 THEN 1 ELSE 0 END) AS CacheHits,
    SUM(CASE WHEN ResultFromCache = 0 THEN 1 ELSE 0 END) AS CacheMisses,
    SUM(CreditsUsed) AS CreditsUsed
FROM FarmGenie.dbo.DataAppendFileLog
WHERE CreateDate >= [DEPLOYMENT_TIME]
    AND DataAppendProviderId = 3;  -- Versium
```

**Expected Results:**
- **Before:** Cache Hits = 0, Cache Misses = 100%
- **After:** Cache Hits > 0 (should see significant improvement)

---

## DEPLOYMENT PLAN

### Status
- **Type:** Emergency Add
- **Sprint:** Next deployment
- **Priority:** High (wasting ~15M credits)
- **Risk:** Low (backward compatible, no data changes)
- **Rollback:** Simple code revert if needed

### Services Involved
- **SMART.DataAppendData** - Data append service (must be running)
- **SMART.CreditService** - Credit processing service
- **SMART.HubMarketingService** - Marketing service

**Note:** Services were found stopped during testing, restarted by user. Ensure services are running before deployment.

---

## SUCCESS CRITERIA

### Deployment Success
- ✅ Cache hits > 0 (was 0 before)
- ✅ Credits saved (cache hits use 0 credits)
- ✅ No data quality issues (owner validation working)
- ✅ New cache uses Attom IDs (future-proof)

### Metrics to Monitor
- Cache hit rate percentage
- Credits used per data append
- Cache hit vs. miss ratio
- Properties with owner matches vs. mismatches

---

## TECHNICAL NOTES

### Cache Key Generation
- **Format:** `::PID-{PropertyId}::L-{LastName}::F-{FirstName}`
- **Case:** Uppercase for new keys, title case for legacy
- **Location:** `Smart.Core.BLL.DataAppend/DataAppendCacheKey.cs`

### Cache Lookup Logic
- **Location:** `Smart.DataAppend.Core/BLL/Actions/ActionCacheCheck.cs`
- **Method:** `LoadCacheProperty()`
- **Repository:** `Smart.DataAppend.Data/Repository/DataAppendRepository.cs`
- **Method:** `GetDataAppendCacheItems()`

### Result Flag
- **Table:** `FarmGenie.dbo.DataAppendFileLog`
- **Column:** `ResultFromCache` (bit)
- **Meaning:** 1 = from cache, 0 = from API

---

## KEY DECISIONS

### Decision 1: Smart Cache Lookup vs. Simple Migration
**Chosen:** Smart cache lookup with owner validation  
**Why:** User's insight - "If owner names match, use cache. If different, property transferred, fetch new data."  
**Benefit:** Preserves all 17.7M cache entries, prevents stale data issues

### Decision 2: Code Change vs. Database Migration
**Chosen:** Code change (smart lookup)  
**Why:** Works for all properties (not just 21% with Attom mappings), future-proof, no data migration needed  
**Benefit:** Immediate fix, works going forward

---

## DATA CONTEXT

### Cache Statistics
- **Total Cached Records:** 17,753,324
- **Unique Properties:** 3,226,651
- **Date Range:** July 2018 → December 2025 (7+ years of data)
- **Properties with Attom mappings:** 680,182 (21.1%)
- **Properties without Attom mappings:** 2,546,469 (78.9%)

**Why only 21%:** Attom data currently covers only 6 states (CA, FL, TX, NC, MN, CO)

---

## NEXT STEPS

### Immediate (Dev Team)
1. Review this specification
2. Implement code changes in `ActionCacheCheck.cs`
3. Implement `GetPropertyMap()` helper method
4. Test in sandbox/stage environment
5. Deploy to production

### Post-Deployment
1. Monitor cache hit rates
2. Verify credit savings
3. Document results

---

## CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/16/2025 | Initial deployment specification created |

---

**This document contains everything needed for implementation. All code changes, database schema, and testing plans are included.**

*Ready for development team handoff - 12/16/2025*

