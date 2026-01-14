# PLS Database Extensions - Normalized Visual Schema Diagram
**Version:** 2.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Visual representation of normalized PLS control/tracking tables with lookup tables

---

## 🎯 SCOPE

This diagram shows the **normalized PLS extension tables** (v2.0) with proper lookup tables, foreign keys, and referential integrity. All string enums have been replaced with integer foreign keys to lookup tables.

**Key Improvement:** All hardcoded string enums (status, source, role) are now normalized into lookup tables with proper foreign key relationships.

---

## 📋 TABLE CLASSIFICATION

### 🆕 NEW LOOKUP TABLES (Normalized Reference Data)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **pls_status_type** | FarmGenie | 🆕 NEW | Lookup table for PLS lifecycle status values |
| **pls_source_type** | FarmGenie | 🆕 NEW | Lookup table for PLS creation source values |
| **pls_collaborator_role** | FarmGenie | 🆕 NEW | Lookup table for collaborator role values |
| **pls_status_mapping** | FarmGenie | 🆕 NEW | Explicit mapping: PLS status → MLS StatusTypeID |

### 🆕 NEW MAIN TABLES (Normalized with Foreign Keys)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **pls_tracking** | FarmGenie | 🆕 NEW | Tracks PLS-specific metadata (uses FK to lookup tables) |
| **pls_status_log** | FarmGenie | 🆕 NEW | Complete audit trail (uses FK to lookup tables) |
| **pls_collaborators** | FarmGenie | 🆕 NEW | Tracks co-agents and title reps (uses FK to lookup tables) |

### ✅ EXISTING TABLES (Referenced, Not Modified)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **AspNetUsers** | FarmGenie | ✅ EXISTING | User accounts (referenced via FK) |
| **MlsListing.dbo.Listing** | MlsListing | ✅ EXISTING | RESO listing data (referenced via listing_id) |
| **MlsListing.dbo.StatusType** | MlsListing | ✅ EXISTING | MLS status definitions (referenced via mapping) |

---

## 📊 NORMALIZED VISUAL SCHEMA DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────────────┐
│         🆕 NEW: LOOKUP TABLES (Normalized Reference Data)                    │
│         (FarmGenie Database - Master Data)                                    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  🆕 pls_status_type                                                  │  │
│  │     (Status Lookup Table)                                            │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: status_type_id (TINYINT)                                        │  │
│  │  status_code (NVARCHAR) UNIQUE                                      │  │
│  │    • 'incomplete'                                                    │  │
│  │    • 'draft'                                                         │  │
│  │    • 'active'                                                        │  │
│  │    • 'coming_soon'                                                   │  │
│  │    • 'lost_opportunity'                                              │  │
│  │    • 'published_to_mls'                                              │  │
│  │  status_name (NVARCHAR) - Display name                              │  │
│  │  description (NVARCHAR)                                              │  │
│  │  display_order (TINYINT)                                             │  │
│  │  is_active (BIT)                                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                        │                                     │
│                                        │ FK                                   │
│  ┌────────────────────────────────────▼──────────────────────────────────┐  │
│  │  🆕 pls_source_type                                                  │  │
│  │     (Source Lookup Table)                                            │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: source_type_id (TINYINT)                                        │  │
│  │  source_code (NVARCHAR) UNIQUE                                      │  │
│  │    • 'paisley'                                                       │  │
│  │    • 'manual'                                                        │  │
│  │    • 'import'                                                        │  │
│  │    • 'api'                                                           │  │
│  │  source_name (NVARCHAR) - Display name                              │  │
│  │  description (NVARCHAR)                                              │  │
│  │  display_order (TINYINT)                                             │  │
│  │  is_active (BIT)                                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                        │                                     │
│                                        │ FK                                   │
│  ┌────────────────────────────────────▼──────────────────────────────────┐  │
│  │  🆕 pls_collaborator_role                                            │  │
│  │     (Role Lookup Table)                                              │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: role_id (TINYINT)                                               │  │
│  │  role_code (NVARCHAR) UNIQUE                                        │  │
│  │    • 'title_rep'                                                     │  │
│  │    • 'co_lister'                                                     │  │
│  │  role_name (NVARCHAR) - Display name                                │  │
│  │  description (NVARCHAR)                                             │  │
│  │  display_order (TINYINT)                                             │  │
│  │  is_active (BIT)                                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                        │                                     │
│                                        │ FK                                   │
│  ┌────────────────────────────────────▼──────────────────────────────────┐  │
│  │  🆕 pls_status_mapping                                               │  │
│  │     (Status → MLS StatusTypeID Mapping)                              │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: mapping_id (INT)                                                │  │
│  │  FK: pls_status_type_id → pls_status_type(status_type_id)            │  │
│  │  mls_status_type_id (INT) NULL                                       │  │
│  │    → References: MlsListing.dbo.StatusType(StatusTypeID)            │  │
│  │    • NULL = no MLS status (incomplete, draft, lost_opportunity)     │  │
│  │    • 6 = Private Listing (for 'active')                            │  │
│  │    • 14 = Coming Soon (for 'coming_soon')                           │  │
│  │  is_published (BIT)                                                  │  │
│  │  is_active (BIT)                                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │
┌───────────────────────────────────────▼───────────────────────────────────────┐
│         🆕 NEW: MAIN TABLES (Normalized with Foreign Keys)                     │
│         (FarmGenie Database - Transactional Data)                              │
│                                                                                │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  🆕 pls_tracking                                                      │    │
│  │     (Primary Control Table - Normalized)                              │    │
│  ├──────────────────────────────────────────────────────────────────────┤    │
│  │  PK: id (INT)                                                         │    │
│  │  FK: listing_id (INT) ────────────┐                                  │    │
│  │  FK: agent_id (NVARCHAR) ─────────┼──┐                               │    │
│  │  FK: source_type_id (TINYINT) ────┼──┼──┐                            │    │
│  │    → pls_source_type(source_type_id)│  │  │                            │    │
│  │  FK: status_type_id (TINYINT) ─────┼──┼──┼──┐                        │    │
│  │    → pls_status_type(status_type_id)│  │  │  │                        │    │
│  │  was_listed (BIT)                   │  │  │  │                        │    │
│  │  mls_published (BIT)                │  │  │  │                        │    │
│  │  created_at (DATETIME2)             │  │  │  │                        │    │
│  │  updated_at (DATETIME2)             │  │  │  │                        │    │
│  │  UNIQUE: listing_id                │  │  │  │                        │    │
│  └────────────────────────────────────┼──┼──┼──┼────────────────────────┘    │
│                                        │  │  │  │                              │
│                                        │  │  │  │                              │
│  ┌────────────────────────────────────▼──▼──▼──▼────────────────────────┐    │
│  │  🆕 pls_status_log                                                     │    │
│  │     (Audit Trail Table - Normalized)                                  │    │
│  ├──────────────────────────────────────────────────────────────────────┤    │
│  │  PK: id (BIGINT)                                                      │    │
│  │  FK: listing_id (INT) ────────────┐                                  │    │
│  │  FK: changed_by (NVARCHAR) ────────┼──┐                               │    │
│  │  FK: from_status_type_id (TINYINT) ──┼──┼──┐                        │    │
│  │    → pls_status_type(status_type_id)│  │  │                          │    │
│  │    NULL = initial creation          │  │  │                          │    │
│  │  FK: to_status_type_id (TINYINT) ────┼──┼──┼──┐                      │    │
│  │    → pls_status_type(status_type_id)│  │  │  │                      │    │
│  │  changed_at (DATETIME2)             │  │  │  │                      │    │
│  └────────────────────────────────────┼──┼──┼──┼────────────────────────┘    │
│                                        │  │  │  │                              │
│                                        │  │  │  │                              │
│  ┌────────────────────────────────────▼──▼──▼──▼────────────────────────┐    │
│  │  🆕 pls_collaborators                                                 │    │
│  │     (Collaboration Table - Normalized)                                │    │
│  ├──────────────────────────────────────────────────────────────────────┤    │
│  │  PK: id (INT)                                                         │    │
│  │  FK: listing_id (INT) ────────────┐                                  │    │
│  │  FK: user_id (NVARCHAR) ───────────┼──┐                               │    │
│  │  FK: role_id (TINYINT) ─────────────┼──┼──┐                           │    │
│  │    → pls_collaborator_role(role_id)│  │  │                            │    │
│  │  joined_at (DATETIME2)             │  │  │                            │    │
│  │  UNIQUE: (listing_id, user_id, role_id)                              │    │
│  └────────────────────────────────────┼──┼──┼────────────────────────────┘    │
│                                        │  │  │                                  │
└────────────────────────────────────────┼──┼──┼──────────────────────────────────┘
                                          │  │  │
                                          │  │  │
┌─────────────────────────────────────────▼──▼──▼──────────────────────────────────┐
│         ✅ EXISTING: REFERENCE TABLES                                             │
│         (Not Created by PLS - Only Referenced)                                    │
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                   │
│  ┌──────────────────────────────┐      ┌──────────────────────────────┐         │
│  │  ✅ EXISTING: AspNetUsers    │      │  ✅ EXISTING: Listing         │         │
│  │     (FarmGenie)               │      │     (MlsListing)             │         │
│  ├──────────────────────────────┤      ├──────────────────────────────┤         │
│  │  PK: Id (NVARCHAR) ◄─────────┼──────┤  PK: ListingID (INT) ◄───────┼─────────┤
│  │  Email                        │      │  MlsID = 777 (PLS)          │         │
│  │  UserName                     │      │  MlsNumber                  │         │
│  │  ...                          │      │  DisplayAddress             │         │
│  └──────────────────────────────┘      │  StatusTypeID                │         │
│                                        │  ... (93 RESO fields)        │         │
│                                        │  [NOT SHOWN - RESO Data]     │         │
│                                        └──────────────────────────────┘         │
│                                                                                   │
│  ┌──────────────────────────────┐                                                │
│  │  ✅ EXISTING: StatusType      │                                                │
│  │     (MlsListing)              │                                                │
│  ├──────────────────────────────┤                                                │
│  │  PK: StatusTypeID (INT)       │                                                │
│  │  Name                         │                                                │
│  │  • 6 = Private Listing        │                                                │
│  │  • 14 = Coming Soon           │                                                │
│  └──────────────────────────────┘                                                │
│                                                                                   │
└───────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 RELATIONSHIP SUMMARY (Normalized)

### Lookup Tables → Main Tables

```
pls_status_type (1:N)
    ├── Referenced by: pls_tracking.status_type_id
    ├── Referenced by: pls_status_log.from_status_type_id
    ├── Referenced by: pls_status_log.to_status_type_id
    └── Referenced by: pls_status_mapping.pls_status_type_id

pls_source_type (1:N)
    └── Referenced by: pls_tracking.source_type_id

pls_collaborator_role (1:N)
    └── Referenced by: pls_collaborators.role_id

pls_status_mapping (1:1 with pls_status_type)
    ├── References: pls_status_type(status_type_id)
    └── References: MlsListing.dbo.StatusType(StatusTypeID) [logical FK]
```

### Main Tables → Existing Tables

```
pls_tracking
    ├── listing_id → MlsListing.dbo.Listing(ListingID) [logical FK]
    └── agent_id → FarmGenie.dbo.AspNetUsers(Id) [FK]

pls_status_log
    ├── listing_id → MlsListing.dbo.Listing(ListingID) [logical FK]
    └── changed_by → FarmGenie.dbo.AspNetUsers(Id) [FK]

pls_collaborators
    ├── listing_id → MlsListing.dbo.Listing(ListingID) [logical FK]
    └── user_id → FarmGenie.dbo.AspNetUsers(Id) [FK]
```

---

## 📊 NORMALIZED TABLE DETAILS

### Lookup Tables

#### 1. 🆕 pls_status_type
**Purpose:** Master data for PLS lifecycle status values

| Field | Type | Description |
|-------|------|-------------|
| `status_type_id` | TINYINT (PK) | Primary key, auto-increment |
| `status_code` | NVARCHAR(50) | Unique code: 'incomplete', 'draft', etc. |
| `status_name` | NVARCHAR(100) | Display name: 'Incomplete', 'Draft', etc. |
| `description` | NVARCHAR(500) | Detailed description |
| `display_order` | TINYINT | Order for UI dropdowns |
| `is_active` | BIT | Can disable without deleting |

**Master Data:**
- 1: incomplete
- 2: draft
- 3: active
- 4: coming_soon
- 5: lost_opportunity
- 6: published_to_mls

#### 2. 🆕 pls_source_type
**Purpose:** Master data for PLS creation source values

| Field | Type | Description |
|-------|------|-------------|
| `source_type_id` | TINYINT (PK) | Primary key, auto-increment |
| `source_code` | NVARCHAR(50) | Unique code: 'paisley', 'manual', etc. |
| `source_name` | NVARCHAR(100) | Display name |
| `description` | NVARCHAR(500) | Detailed description |
| `display_order` | TINYINT | Order for UI dropdowns |
| `is_active` | BIT | Can disable without deleting |

**Master Data:**
- 1: paisley
- 2: manual
- 3: import
- 4: api

#### 3. 🆕 pls_collaborator_role
**Purpose:** Master data for collaborator role values

| Field | Type | Description |
|-------|------|-------------|
| `role_id` | TINYINT (PK) | Primary key, auto-increment |
| `role_code` | NVARCHAR(50) | Unique code: 'title_rep', 'co_lister' |
| `role_name` | NVARCHAR(100) | Display name |
| `description` | NVARCHAR(500) | Detailed description |
| `display_order` | TINYINT | Order for UI dropdowns |
| `is_active` | BIT | Can disable without deleting |

**Master Data:**
- 1: title_rep
- 2: co_lister

#### 4. 🆕 pls_status_mapping
**Purpose:** Explicit mapping between PLS status and MLS StatusTypeID

| Field | Type | Description |
|-------|------|-------------|
| `mapping_id` | INT (PK) | Primary key, auto-increment |
| `pls_status_type_id` | TINYINT (FK) | References pls_status_type |
| `mls_status_type_id` | INT NULL | References MlsListing.dbo.StatusType |
| `is_published` | BIT | TRUE = published listing |
| `is_active` | BIT | Can disable mapping |

**Mappings:**
- incomplete → NULL (not published)
- draft → NULL (not published)
- active → 6 (Private Listing, published)
- coming_soon → 14 (Coming Soon, published)
- lost_opportunity → NULL (not published)
- published_to_mls → NULL (dynamic, published)

### Main Tables (Normalized)

#### 1. 🆕 pls_tracking (Normalized)
**Changes from v1.1:**
- `status NVARCHAR(50)` → `status_type_id TINYINT FK`
- `source NVARCHAR(50)` → `source_type_id TINYINT FK`

| Field | Type | Description |
|-------|------|-------------|
| `id` | INT (PK) | Primary key |
| `listing_id` | INT | References MlsListing.dbo.Listing |
| `agent_id` | NVARCHAR(450) (FK) | References AspNetUsers |
| `source_type_id` | TINYINT (FK) | References pls_source_type |
| `status_type_id` | TINYINT (FK) | References pls_status_type |
| `was_listed` | BIT | Business outcome flag |
| `mls_published` | BIT | MLS export flag |
| `created_at` | DATETIME2(7) | Creation timestamp |
| `updated_at` | DATETIME2(7) | Update timestamp |

#### 2. 🆕 pls_status_log (Normalized)
**Changes from v1.1:**
- `from_status NVARCHAR(50)` → `from_status_type_id TINYINT FK`
- `to_status NVARCHAR(50)` → `to_status_type_id TINYINT FK`

| Field | Type | Description |
|-------|------|-------------|
| `id` | BIGINT (PK) | Primary key |
| `listing_id` | INT | References MlsListing.dbo.Listing |
| `changed_by` | NVARCHAR(450) (FK) | References AspNetUsers |
| `from_status_type_id` | TINYINT (FK) NULL | References pls_status_type |
| `to_status_type_id` | TINYINT (FK) | References pls_status_type |
| `changed_at` | DATETIME2(7) | Change timestamp |

#### 3. 🆕 pls_collaborators (Normalized)
**Changes from v1.1:**
- `role NVARCHAR(50)` → `role_id TINYINT FK`

| Field | Type | Description |
|-------|------|-------------|
| `id` | INT (PK) | Primary key |
| `listing_id` | INT | References MlsListing.dbo.Listing |
| `user_id` | NVARCHAR(450) (FK) | References AspNetUsers |
| `role_id` | TINYINT (FK) | References pls_collaborator_role |
| `joined_at` | DATETIME2(7) | Join timestamp |

---

## 🔍 HELPER VIEWS (Backward Compatibility)

### View: vw_pls_tracking_with_codes
**Purpose:** Provides status_code and source_code for easy querying

```sql
SELECT 
    id,
    listing_id,
    agent_id,
    source_type_id,
    source_code,              -- From lookup table
    source_display_name,       -- From lookup table
    status_type_id,
    status_code,              -- From lookup table
    status_display_name,      -- From lookup table
    was_listed,
    mls_published,
    created_at,
    updated_at
FROM vw_pls_tracking_with_codes;
```

### View: vw_pls_status_log_with_codes
**Purpose:** Provides status codes in audit log

```sql
SELECT 
    id,
    listing_id,
    changed_by,
    from_status_type_id,
    from_status_code,         -- From lookup table
    from_status_display_name, -- From lookup table
    to_status_type_id,
    to_status_code,          -- From lookup table
    to_status_display_name,  -- From lookup table
    changed_at
FROM vw_pls_status_log_with_codes;
```

### View: vw_pls_collaborators_with_codes
**Purpose:** Provides role codes

```sql
SELECT 
    id,
    listing_id,
    user_id,
    role_id,
    role_code,              -- From lookup table
    role_display_name,      -- From lookup table
    joined_at
FROM vw_pls_collaborators_with_codes;
```

---

## 📈 NORMALIZATION BENEFITS

### Storage Efficiency
- **Before:** NVARCHAR(50) = ~50 bytes per enum field
- **After:** TINYINT = 1 byte per enum field
- **Savings:** 98% reduction in storage per enum field

### Performance
- **Integer comparisons:** Faster than string comparisons
- **Index size:** Smaller indexes with integer keys
- **JOIN performance:** Integer joins are faster

### Data Integrity
- **Foreign keys:** Enforce referential integrity
- **Cannot insert invalid values:** Database prevents it
- **Lookup protection:** Cannot delete referenced values

### Maintainability
- **Add new values:** INSERT into lookup table (no schema change)
- **Disable values:** Set is_active = 0 (no data deletion)
- **Display names:** Stored in database, not application code
- **Centralized definitions:** Single source of truth

---

## 🔄 EXAMPLE QUERIES (Normalized)

### Query 1: Get Active Listings with Status Names
```sql
SELECT 
    pt.listing_id,
    pst.status_code,
    pst.status_name AS status_display_name,
    pst.description AS status_description,
    pt.was_listed,
    pt.mls_published
FROM dbo.pls_tracking pt
INNER JOIN dbo.pls_status_type pst ON pst.status_type_id = pt.status_type_id
WHERE pst.status_code = 'active'
    AND pst.is_active = 1;
```

### Query 2: Get Status Mapping to MLS
```sql
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

### Query 3: Using Helper View (Backward Compatible)
```sql
-- Query using status_code (like v1.1, but via view)
SELECT 
    listing_id,
    status_code,           -- From view
    status_display_name,    -- From view
    source_code,           -- From view
    was_listed
FROM dbo.vw_pls_tracking_with_codes
WHERE status_code IN ('active', 'coming_soon');
```

---

## 📋 DEPLOYMENT CHECKLIST

### New Lookup Tables to Create
- [ ] **pls_status_type** - Execute CREATE TABLE + INSERT master data
- [ ] **pls_source_type** - Execute CREATE TABLE + INSERT master data
- [ ] **pls_collaborator_role** - Execute CREATE TABLE + INSERT master data
- [ ] **pls_status_mapping** - Execute CREATE TABLE + INSERT mappings

### New Main Tables to Create
- [ ] **pls_tracking** - Execute CREATE TABLE (uses FK to lookup tables)
- [ ] **pls_status_log** - Execute CREATE TABLE (uses FK to lookup tables)
- [ ] **pls_collaborators** - Execute CREATE TABLE (uses FK to lookup tables)

### Helper Views to Create
- [ ] **vw_pls_tracking_with_codes** - For backward-compatible queries
- [ ] **vw_pls_status_log_with_codes** - For backward-compatible queries
- [ ] **vw_pls_collaborators_with_codes** - For backward-compatible queries

### Existing Tables (No Changes Required)
- [x] **AspNetUsers** - Already exists, no modifications needed
- [x] **MlsListing.dbo.Listing** - Already exists, no modifications needed
- [x] **MlsListing.dbo.StatusType** - Already exists, no modifications needed

---

## 📚 RELATED DOCUMENTS

- **Normalized SQL Script:** `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v2.sql`
- **Normalization Analysis:** `PLS_NORMALIZATION_ANALYSIS_v2.md`
- **Original Schema (v1.1):** `PLS_SCHEMA_EXTENSIONS_v1.sql` (for comparison)

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 2.0 | 01/05/2026 | Complete normalized schema diagram with lookup tables, foreign keys, and helper views |

---

**Status:** ✅ Normalized Schema Complete - Enterprise-Grade Database Design

**Key Improvement:** All string enums replaced with integer foreign keys to lookup tables, providing better data integrity, performance, and maintainability.

