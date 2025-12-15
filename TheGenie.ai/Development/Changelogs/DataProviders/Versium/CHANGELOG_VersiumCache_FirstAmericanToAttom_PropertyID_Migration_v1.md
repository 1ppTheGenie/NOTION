# Standard Operating Procedure
## Versium Cache Migration: DataTree to Attom PropertyID
### Version 1.0 | Date: 12/14/2025

---

## Document Control

| Attribute | Value |
|-----------|-------|
| **SOP ID** | SOP-VERSIUM-001 |
| **Version** | 1.0 |
| **Created** | 12/14/2025 |
| **Author** | TheGenie AI |
| **Approved By** | Pending |
| **Effective Date** | TBD |

---

## 1. Purpose

This SOP provides step-by-step instructions for migrating Versium cache lookup keys from old DataTree PropertyIDs to new Attom PropertyIDs to preserve cached data and avoid re-paying for Versium API lookups.

---

## 2. Scope

**Applies to:** Database administrators, DevOps team, or developers responsible for the Attom property data migration.

**Systems affected:**
- FarmGenie database
- TitleData database
- Versium Data Append system

---

## 3. Background

### 3.1 Why This Migration is Needed

When TheGenie switched property data providers from First American (DataTree) to Attom, PropertyIDs changed. The Versium cache uses PropertyID in its lookup key:

```
::PID-{PropertyId}::L-{LastName}::F-{FirstName}
```

If PropertyIDs change without updating cache keys, all cached lookups become orphaned, resulting in:
- Loss of 7+ years of cached data
- ~15 million Versium credits wasted on re-lookups
- Increased API costs

### 3.2 Solution Overview

A stored procedure updates cache keys to use new Attom PropertyIDs based on a mapping table that links old DataTree IDs to new Attom IDs via FIPS + APN matching.

---

## 4. Prerequisites

### 4.1 Database Objects Required

| Object | Database | Status |
|--------|----------|--------|
| `CachePropertyIdMapping` | FarmGenie | ✅ Created |
| `usp_MigrateVersiumCache_DataTreeToAttom` | FarmGenie | ✅ Created |
| `AssessorDataPropertyMap.AttomId` | TitleData | ✅ Populated |

### 4.2 Permissions Required

- `db_datareader` and `db_datawriter` on FarmGenie
- Execute permission on `usp_MigrateVersiumCache_DataTreeToAttom`

### 4.3 Timing Requirements

- Schedule during **low-traffic window** (nights/weekends)
- Estimated duration: 30-60 minutes for full migration
- System can remain online (non-blocking updates)

---

## 5. Pre-Migration Checklist

| # | Task | Verified |
|---|------|----------|
| 1 | Verify database connectivity to 192.168.29.45 | ☐ |
| 2 | Confirm `CachePropertyIdMapping` table exists | ☐ |
| 3 | Confirm mapping table has `NewAttomId` populated | ☐ |
| 4 | Notify stakeholders of migration window | ☐ |
| 5 | Create database backup (recommended) | ☐ |
| 6 | Verify disk space for backup table | ☐ |

### 5.1 Verification Queries

```sql
-- Check mapping table exists and has data
SELECT COUNT(*) AS TotalRows,
       COUNT(NewAttomId) AS RowsWithAttomId
FROM FarmGenie.dbo.CachePropertyIdMapping;

-- Expected: ~3.2M total, ~680K with AttomId

-- Check stored procedure exists
SELECT OBJECT_ID('FarmGenie.dbo.usp_MigrateVersiumCache_DataTreeToAttom', 'P');
-- Expected: Non-NULL value
```

---

## 6. Migration Procedure

### Step 1: Run Preview Mode

**Purpose:** See what would be updated without making changes.

```sql
USE FarmGenie;
GO

EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 1;
```

**Expected Output:**
- Total cache records count
- Records that can be migrated count
- Sample of 10 before/after key changes

**Review:** Verify the output looks correct before proceeding.

---

### Step 2: Execute Migration

**Purpose:** Actually update the cache keys.

```sql
USE FarmGenie;
GO

EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom 
    @PreviewMode = 0,
    @BatchSize = 10000;
```

**Parameters:**
| Parameter | Value | Description |
|-----------|-------|-------------|
| @PreviewMode | 0 | Execute mode (make changes) |
| @BatchSize | 10000 | Records per batch (adjust for performance) |
| @MaxBatches | NULL | Process all (or set limit for testing) |

**What Happens:**
1. Creates backup table: `DataAppendContactLookup_Backup_PreAttomMigration`
2. Updates cache keys in batches
3. Reports progress every 10 batches
4. Returns summary statistics

---

### Step 3: Verify Migration

```sql
-- Check sample of migrated records
SELECT TOP 10 
    LookupKeyReadable,
    CreateDate
FROM FarmGenie.dbo.DataAppendContactLookup
WHERE LookupKeyReadable LIKE '%::PID-4%'  -- Attom IDs are typically higher
  AND LEN(LookupKeyReadable) > 30
ORDER BY CreateDate DESC;

-- Count records with new vs old format
SELECT 
    CASE 
        WHEN CAST(SUBSTRING(LookupKeyReadable, 7, 
            CHARINDEX('::', LookupKeyReadable, 7) - 7) AS BIGINT) > 100000000 
        THEN 'Attom ID (migrated)'
        ELSE 'DataTree ID (original)'
    END AS IDType,
    COUNT(*) AS RecordCount
FROM FarmGenie.dbo.DataAppendContactLookup
WHERE LookupKeyReadable LIKE '%::PID-%'
GROUP BY CASE 
    WHEN CAST(SUBSTRING(LookupKeyReadable, 7, 
        CHARINDEX('::', LookupKeyReadable, 7) - 7) AS BIGINT) > 100000000 
    THEN 'Attom ID (migrated)'
    ELSE 'DataTree ID (original)'
END;
```

---

### Step 4: Post-Migration Validation

| Validation | Query | Expected |
|------------|-------|----------|
| Backup table exists | `SELECT COUNT(*) FROM DataAppendContactLookup_Backup_PreAttomMigration` | > 0 |
| No duplicate keys | `SELECT LookupKeyReadable, COUNT(*) FROM DataAppendContactLookup GROUP BY LookupKeyReadable HAVING COUNT(*) > 1` | 0 rows |
| Cache still works | Monitor Versium API calls for next 24 hours | Reduced calls |

---

## 7. Rollback Procedure

If issues are discovered, rollback using the backup table:

```sql
-- Step 1: Identify records to rollback
SELECT COUNT(*) FROM DataAppendContactLookup_Backup_PreAttomMigration;

-- Step 2: Restore original cache keys
UPDATE l
SET l.LookupKeyReadable = b.LookupKeyReadable
FROM FarmGenie.dbo.DataAppendContactLookup l
JOIN FarmGenie.dbo.DataAppendContactLookup_Backup_PreAttomMigration b
ON l.DataAppendContactLookupId = b.DataAppendContactLookupId;

-- Step 3: Verify rollback
SELECT TOP 10 LookupKeyReadable FROM DataAppendContactLookup ORDER BY 1;
```

---

## 8. Cleanup (After 30 Days)

Once confident the migration is successful:

```sql
-- Remove backup table to free space
DROP TABLE FarmGenie.dbo.DataAppendContactLookup_Backup_PreAttomMigration;

-- Optional: Remove mapping table if no longer needed
-- DROP TABLE FarmGenie.dbo.CachePropertyIdMapping;
```

---

## 9. Troubleshooting

### Issue: Procedure runs slowly

**Solution:** Reduce batch size

```sql
EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom 
    @PreviewMode = 0,
    @BatchSize = 5000;  -- Smaller batches
```

### Issue: Disk space error

**Solution:** Backup table growing too large
- Clear backup table between runs
- Or skip backup (not recommended for production)

### Issue: Timeout errors

**Solution:** Run in smaller batches with MaxBatches limit

```sql
-- Run 100 batches at a time
EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom 
    @PreviewMode = 0,
    @BatchSize = 10000,
    @MaxBatches = 100;
-- Then run again to continue
```

---

## 10. Success Metrics

| Metric | Before | After |
|--------|--------|-------|
| Cache hit rate | Baseline | Should maintain or improve |
| Versium API calls | Baseline | Should not spike |
| Records with Attom IDs | 0 | ~680,000+ |

---

## 11. Related Documents

| Document | Location |
|----------|----------|
| Architecture Audit | `docs/AUDIT_VersiumCache_Architecture_v1.md` |
| SQL Script | `SQL/usp_MigrateVersiumCache_DataTreeToAttom_v1.sql` |
| Credits Specification | `docs/SPEC_Versium_Credits_DataAppend_v1.md` |

---

## 12. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/14/2025 | TheGenie AI | Initial creation |

---

*SOP-VERSIUM-001 | Version 1.0 | Effective: TBD*

