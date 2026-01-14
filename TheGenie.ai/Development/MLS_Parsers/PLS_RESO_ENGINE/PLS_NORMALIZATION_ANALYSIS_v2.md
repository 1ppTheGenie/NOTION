# PLS Schema Normalization Analysis
**Version:** 2.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Analysis of normalization improvements for PLS extension tables

---

## 🎯 EXECUTIVE SUMMARY

The original PLS schema (v1.1) had **significant normalization issues** with hardcoded string enums. The normalized version (v2.0) implements proper database design with lookup tables, foreign keys, and referential integrity.

---

## ❌ NORMALIZATION ISSUES IN v1.1

### Issue 1: Hardcoded Status Strings
**Problem:**
```sql
status NVARCHAR(50) NOT NULL DEFAULT 'incomplete',
    CHECK (status IN ('incomplete', 'draft', 'active', ...))
```

**Issues:**
- String values stored directly in main table
- No referential integrity
- Cannot add new status without schema change
- Display names not stored
- No way to disable status without deleting data
- Status mapping to MLS StatusTypeID is implicit (in comments only)

### Issue 2: Hardcoded Source Strings
**Problem:**
```sql
source NVARCHAR(50) NOT NULL DEFAULT 'paisley',
    CHECK (source IN ('paisley', 'manual', 'import', 'api'))
```

**Issues:**
- Same problems as status strings
- No metadata about sources
- Cannot track source descriptions

### Issue 3: Hardcoded Role Strings
**Problem:**
```sql
role NVARCHAR(50) NOT NULL,
    CHECK (role IN ('title_rep', 'co_lister'))
```

**Issues:**
- Same problems as status/source
- Limited extensibility

### Issue 4: Implicit Status Mapping
**Problem:**
- Status mapping to `MlsListing.dbo.StatusType(StatusTypeID)` only documented in comments
- No database-level enforcement
- Application must maintain mapping logic

### Issue 5: Index Performance
**Problem:**
- Indexes on NVARCHAR(50) strings
- Larger index size
- Slower comparisons
- Filtered indexes use string literals

---

## ✅ NORMALIZATION SOLUTIONS IN v2.0

### Solution 1: pls_status_type Lookup Table

**New Table:**
```sql
CREATE TABLE dbo.pls_status_type (
    status_type_id TINYINT IDENTITY(1,1) NOT NULL,
    status_code NVARCHAR(50) NOT NULL,      -- 'incomplete', 'draft', etc.
    status_name NVARCHAR(100) NOT NULL,     -- 'Incomplete', 'Draft', etc.
    description NVARCHAR(500) NULL,
    display_order TINYINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    ...
);
```

**Benefits:**
- ✅ Foreign key integrity
- ✅ Add new status without schema change
- ✅ Display names stored in database
- ✅ Can disable status without deleting
- ✅ Display order for UI dropdowns
- ✅ Descriptions for documentation

**Main Table Change:**
```sql
-- OLD (v1.1):
status NVARCHAR(50) NOT NULL DEFAULT 'incomplete'

-- NEW (v2.0):
status_type_id TINYINT NOT NULL,
    FOREIGN KEY (status_type_id) REFERENCES pls_status_type(status_type_id)
```

### Solution 2: pls_source_type Lookup Table

**New Table:**
```sql
CREATE TABLE dbo.pls_source_type (
    source_type_id TINYINT IDENTITY(1,1) NOT NULL,
    source_code NVARCHAR(50) NOT NULL,
    source_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,
    display_order TINYINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    ...
);
```

**Benefits:**
- ✅ Same benefits as status_type
- ✅ Centralized source definitions
- ✅ Easy to add new sources

### Solution 3: pls_collaborator_role Lookup Table

**New Table:**
```sql
CREATE TABLE dbo.pls_collaborator_role (
    role_id TINYINT IDENTITY(1,1) NOT NULL,
    role_code NVARCHAR(50) NOT NULL,
    role_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,
    display_order TINYINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    ...
);
```

**Benefits:**
- ✅ Same benefits as other lookup tables
- ✅ Extensible role system

### Solution 4: pls_status_mapping Table

**New Table:**
```sql
CREATE TABLE dbo.pls_status_mapping (
    mapping_id INT IDENTITY(1,1) NOT NULL,
    pls_status_type_id TINYINT NOT NULL,
    mls_status_type_id INT NULL,  -- References MlsListing.dbo.StatusType
    is_published BIT NOT NULL DEFAULT 0,
    ...
);
```

**Benefits:**
- ✅ Explicit mapping (not implicit in comments)
- ✅ Queryable mapping table
- ✅ Can handle NULL mappings (incomplete, draft)
- ✅ Tracks published status
- ✅ Single source of truth for status mapping

---

## 📊 COMPARISON TABLE

| Aspect | v1.1 (Denormalized) | v2.0 (Normalized) |
|--------|---------------------|-------------------|
| **Status Storage** | NVARCHAR(50) string | TINYINT FK to lookup |
| **Source Storage** | NVARCHAR(50) string | TINYINT FK to lookup |
| **Role Storage** | NVARCHAR(50) string | TINYINT FK to lookup |
| **Status Mapping** | Implicit (comments) | Explicit (mapping table) |
| **Referential Integrity** | CHECK constraints only | Foreign keys enforced |
| **Add New Values** | Schema change required | INSERT into lookup table |
| **Display Names** | Not stored | Stored in lookup table |
| **Disable Values** | Cannot (must delete) | Set is_active = 0 |
| **Index Size** | Larger (NVARCHAR) | Smaller (TINYINT) |
| **Query Performance** | String comparisons | Integer comparisons |
| **Storage per Row** | ~100 bytes (strings) | ~8 bytes (integers) |

---

## 🔄 MIGRATION PATH

### Step 1: Create Lookup Tables
```sql
-- Execute lookup table creation and master data inserts
-- This creates: pls_status_type, pls_source_type, pls_collaborator_role, pls_status_mapping
```

### Step 2: Migrate Existing Data (if any)
```sql
-- If v1.1 tables exist with data:
-- 1. Map string values to lookup table IDs
-- 2. Update main tables to use integer FKs
-- 3. Drop old string columns
```

### Step 3: Create New Normalized Tables
```sql
-- Execute main table creation (pls_tracking, pls_status_log, pls_collaborators)
-- These use integer FKs instead of strings
```

### Step 4: Update Application Code
```sql
-- Change queries from:
WHERE status = 'active'

-- To:
WHERE status_type_id = (SELECT status_type_id FROM pls_status_type WHERE status_code = 'active')

-- Or use views:
WHERE status_code = 'active'  -- via vw_pls_tracking_with_codes
```

---

## 📈 PERFORMANCE IMPROVEMENTS

### Storage Savings
- **Status field:** NVARCHAR(50) = ~50 bytes → TINYINT = 1 byte (**98% reduction**)
- **Source field:** NVARCHAR(50) = ~50 bytes → TINYINT = 1 byte (**98% reduction**)
- **Role field:** NVARCHAR(50) = ~50 bytes → TINYINT = 1 byte (**98% reduction**)
- **Total per row:** ~150 bytes → ~3 bytes (**98% reduction**)

### Index Performance
- **Integer indexes:** Faster comparisons, smaller size
- **Filtered indexes:** Can use integer ranges instead of string lists
- **JOIN performance:** Integer joins are faster than string joins

### Query Performance
```sql
-- OLD (v1.1) - String comparison:
WHERE status = 'active'  -- Slower, case-sensitive

-- NEW (v2.0) - Integer comparison:
WHERE status_type_id = 3  -- Faster, no case issues
```

---

## 🛡️ DATA INTEGRITY IMPROVEMENTS

### Before (v1.1)
- ❌ CHECK constraints can be bypassed
- ❌ No referential integrity
- ❌ Typos possible ('Active' vs 'active')
- ❌ Cannot prevent deletion of referenced values

### After (v2.0)
- ✅ Foreign keys enforce referential integrity
- ✅ Cannot insert invalid values
- ✅ ON DELETE CASCADE/NO ACTION controls behavior
- ✅ Lookup tables protect against accidental deletion

---

## 🔍 EXAMPLE QUERIES

### Query 1: Get Active Listings (Normalized)
```sql
-- Using lookup table JOIN
SELECT 
    pt.listing_id,
    pst.status_code,
    pst.status_name,
    pt.was_listed
FROM dbo.pls_tracking pt
INNER JOIN dbo.pls_status_type pst ON pst.status_type_id = pt.status_type_id
WHERE pst.status_code = 'active'
    AND pst.is_active = 1;
```

### Query 2: Get Status Mapping to MLS
```sql
-- Explicit mapping query
SELECT 
    pst.status_code AS pls_status,
    pst.status_name AS pls_display_name,
    psm.mls_status_type_id,
    st.Name AS mls_status_name,
    psm.is_published
FROM dbo.pls_status_type pst
LEFT JOIN dbo.pls_status_mapping psm ON psm.pls_status_type_id = pst.status_type_id
LEFT JOIN MlsListing.dbo.StatusType st ON st.StatusTypeID = psm.mls_status_type_id
WHERE pst.is_active = 1
ORDER BY pst.display_order;
```

### Query 3: Using Helper Views (Backward Compatible)
```sql
-- View provides status_code for easy querying
SELECT 
    listing_id,
    status_code,  -- From view, not main table
    status_display_name,
    was_listed
FROM dbo.vw_pls_tracking_with_codes
WHERE status_code IN ('active', 'coming_soon');
```

---

## 📋 LOOKUP TABLE MASTER DATA

### pls_status_type
| status_type_id | status_code | status_name | display_order |
|----------------|-------------|-------------|---------------|
| 1 | incomplete | Incomplete | 1 |
| 2 | draft | Draft | 2 |
| 3 | active | Active | 3 |
| 4 | coming_soon | Coming Soon | 4 |
| 5 | lost_opportunity | Lost Opportunity | 5 |
| 6 | published_to_mls | Published to MLS | 6 |

### pls_source_type
| source_type_id | source_code | source_name | display_order |
|----------------|-------------|-------------|---------------|
| 1 | paisley | Paisley | 1 |
| 2 | manual | Manual Entry | 2 |
| 3 | import | Import | 3 |
| 4 | api | API | 4 |

### pls_collaborator_role
| role_id | role_code | role_name | display_order |
|---------|-----------|-----------|---------------|
| 1 | title_rep | Title Representative | 1 |
| 2 | co_lister | Co-Listing Agent | 2 |

### pls_status_mapping
| pls_status_type_id | mls_status_type_id | is_published |
|-------------------|---------------------|--------------|
| 1 (incomplete) | NULL | 0 |
| 2 (draft) | NULL | 0 |
| 3 (active) | 6 | 1 |
| 4 (coming_soon) | 14 | 1 |
| 5 (lost_opportunity) | NULL | 0 |
| 6 (published_to_mls) | NULL | 1 |

---

## 🎯 BEST PRACTICES IMPLEMENTED

1. ✅ **Third Normal Form (3NF)** - No transitive dependencies
2. ✅ **Lookup Tables** - All enums normalized
3. ✅ **Foreign Keys** - Referential integrity enforced
4. ✅ **Explicit Mappings** - No implicit relationships
5. ✅ **Audit Trail** - Status changes reference lookup (preserves history)
6. ✅ **Extensibility** - Add values without schema changes
7. ✅ **Performance** - Integer keys for faster queries
8. ✅ **Maintainability** - Centralized definitions

---

## 📚 RELATED DOCUMENTS

- **Normalized SQL Script:** `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v2.sql`
- **Original SQL Script:** `PLS_SCHEMA_EXTENSIONS_v1.sql` (for comparison)
- **Schema README:** `PLS_SCHEMA_EXTENSIONS_README_v1.md`

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 2.0 | 01/05/2026 | Complete normalization analysis - lookup tables, foreign keys, explicit mappings |

---

**Status:** ✅ Normalization Complete - Enterprise-Grade Database Design

**Recommendation:** Use v2.0 (normalized) for production deployment. Provides better data integrity, performance, and maintainability.

