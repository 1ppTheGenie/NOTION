# PLS Database Extensions - Normalized Visual Schema Diagram
**Version:** 3.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Visual representation of normalized PLS control/tracking tables (collaborator concept removed)

---

## 🎯 SCOPE

This diagram shows the **normalized PLS extension tables** (v3.0) with proper lookup tables, foreign keys, and referential integrity. All string enums have been replaced with integer foreign keys to lookup tables.

**Key Changes from v2.0:**
- ❌ **Removed:** `pls_collaborators` table
- ❌ **Removed:** `pls_collaborator_role` lookup table
- ✅ **Clarified:** Listing Agents stored in `MlsListing.dbo.Listing` (RESO fields)
- ✅ **Clarified:** Title Reps access via `Permission` table (account-level)

---

## 📋 TABLE CLASSIFICATION

### 🆕 NEW LOOKUP TABLES (Normalized Reference Data)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **pls_status_type** | FarmGenie | 🆕 NEW | Lookup table for PLS lifecycle status values |
| **pls_source_type** | FarmGenie | 🆕 NEW | Lookup table for PLS creation source values |
| **pls_status_mapping** | FarmGenie | 🆕 NEW | Explicit mapping: PLS status → MLS StatusTypeID |

### 🆕 NEW MAIN TABLES (Normalized with Foreign Keys)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **pls_tracking** | FarmGenie | 🆕 NEW | Tracks PLS-specific metadata (uses FK to lookup tables) |
| **pls_status_log** | FarmGenie | 🆕 NEW | Complete audit trail (uses FK to lookup tables) |

### ✅ EXISTING TABLES (Referenced, Not Modified)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **AspNetUsers** | FarmGenie | ✅ EXISTING | User accounts (referenced via FK) |
| **Permission** | FarmGenie | ✅ EXISTING | Account-level permissions (for Title Reps) |
| **MlsListing.dbo.Listing** | MlsListing | ✅ EXISTING | RESO listing data (includes Listing Agent + Co-Listing Agent) |
| **MlsListing.dbo.StatusType** | MlsListing | ✅ EXISTING | MLS status definitions (referenced via mapping) |

---

## 📊 NORMALIZED VISUAL SCHEMA DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────────────┐
│         🆕 NEW: LOOKUP TABLES (Normalized Reference Data)                    │
│         (FarmGenie Database - Master Data)                                  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  🆕 pls_status_type                                                  │  │
│  │     (Status Lookup Table)                                           │  │
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
│  │  🆕 pls_status_mapping                                               │  │
│  │     (Status → MLS StatusTypeID Mapping)                              │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: mapping_id (INT)                                                │  │
│  │  FK: pls_status_type_id → pls_status_type(status_type_id)            │  │
│  │  mls_status_type_id (INT) NULL                                       │  │
│  │    → References: MlsListing.dbo.StatusType(StatusTypeID)            │  │
│  │    • NULL = no MLS status (incomplete, draft, lost_opportunity)     │  │
│  │    • 6 = Private Listing (for 'active')                              │  │
│  │    • 14 = Coming Soon (for 'coming_soon')                             │  │
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
│  │  FK: source_type_id (TINYINT) ─────┼──┼──┐                            │    │
│  │    → pls_source_type(source_type_id)│  │  │                            │    │
│  │  FK: status_type_id (TINYINT) ──────┼──┼──┼──┐                        │    │
│  │    → pls_status_type(status_type_id)│  │  │  │                        │    │
│  │  was_listed (BIT)                   │  │  │  │                        │    │
│  │  mls_published (BIT)                │  │  │  │                        │    │
│  │  created_at (DATETIME2)             │  │  │  │                        │    │
│  │  updated_at (DATETIME2)             │  │  │  │                        │    │
│  │  UNIQUE: listing_id                │  │  │  │                        │    │
│  │                                                                       │    │
│  │  NOTE: Co-Listing Agent stored in MlsListing.dbo.Listing             │    │
│  │        (NOT tracked here - use CoListingAgentName/ID)               │    │
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
│  │  FK: from_status_type_id (TINYINT) ─┼──┼──┐                            │    │
│  │    → pls_status_type(status_type_id)│  │  │                            │    │
│  │    • NULL = initial creation        │  │  │                            │    │
│  │  FK: to_status_type_id (TINYINT) ────┼──┼──┼──┐                        │    │
│  │    → pls_status_type(status_type_id)│  │  │  │                        │    │
│  │  changed_at (DATETIME2)             │  │  │  │                        │    │
│  │                                                                       │    │
│  │  NOTE: changed_by can be agent, title rep (with permissions),       │    │
│  │        or admin - all tracked via AspNetUsers(Id)                    │    │
│  └────────────────────────────────────┼──┼──┼──┼────────────────────────┘    │
│                                        │  │  │  │                              │
└────────────────────────────────────────┼──┼──┼──┼──────────────────────────────┘
                                         │  │  │  │
                                         │  │  │  │ (Logical FKs to existing tables)
                                         │  │  │  │
┌────────────────────────────────────────▼──▼──▼──▼──────────────────────────────┐
│                    EXTERNAL REFERENCES (Existing Tables)                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌──────────────────────────────┐      ┌──────────────────────────────┐     │
│  │     AspNetUsers              │      │     MlsListing.dbo.Listing   │     │
│  │     (FarmGenie)               │      │     (MlsListing)             │     │
│  ├──────────────────────────────┤      ├──────────────────────────────┤     │
│  │  PK: Id (NVARCHAR) ◄─────────┼──────┤  PK: ListingID (INT)         │     │
│  │  Email                        │      │  MlsID = 777 (PLS)          │     │
│  │  UserName                     │      │                              │     │
│  └──────────────────────────────┘      │  ListingAgentName (NVARCHAR) │     │
│                                        │  ListingAgentID (NVARCHAR)    │     │
│  ┌──────────────────────────────┐      │  CoListingAgentName (NVARCHAR)│    │
│  │     Permission                │      │  CoListingAgentID (NVARCHAR) │     │
│  │     (FarmGenie)               │      │                              │     │
│  ├──────────────────────────────┤      │  ... (all other RESO fields) │     │
│  │  PK: PermissionId (INT)       │      └──────────────────────────────┘     │
│  │  FK: UserId (NVARCHAR)        │                                             │
│  │    → AspNetUsers(Id)          │      ┌──────────────────────────────┐     │
│  │  FK: PermissionTypeId (INT)   │      │     MlsListing.dbo.StatusType│     │
│  │    → PermissionType           │      │     (MlsListing)              │     │
│  │                              │      ├──────────────────────────────┤     │
│  │  NOTE: Title Reps access      │      │  PK: StatusTypeID (INT)       │     │
│  │        via Permission table   │      │  Name (NVARCHAR)              │     │
│  │        (account-level, not   │      │    • 6 = Private Listing      │     │
│  │         listing-specific)    │      │    • 14 = Coming Soon         │     │
│  └──────────────────────────────┘      └──────────────────────────────┘     │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔑 KEY RELATIONSHIPS

### 1. Listing Agents (RESO-Compliant)

**Storage:** `MlsListing.dbo.Listing` table

```
MlsListing.dbo.Listing
├── ListingAgentName (NVARCHAR)      ← Primary listing agent
├── ListingAgentID (NVARCHAR)        ← Primary listing agent ID (MLS member)
├── CoListingAgentName (NVARCHAR)    ← Co-listing agent (optional)
└── CoListingAgentID (NVARCHAR)      ← Co-listing agent ID (MLS member)
```

**Validation:**
- Both agents must be verified MLS members
- RESO feed validates MLS membership before publishing
- Stored in standard RESO fields - no PLS-specific tracking needed

**Relationship to PLS Tables:**
- `pls_tracking.agent_id` → `AspNetUsers.Id` (primary listing agent/owner)
- Co-Listing Agent stored in RESO listing table, NOT in PLS tables

### 2. Title Reps (Permission-Based Access)

**Storage:** `FarmGenie.dbo.Permission` table

```
FarmGenie.dbo.Permission
├── UserId (NVARCHAR)                ← Title rep user ID
├── PermissionTypeId (INT)           ← "Title Partner" permission type
└── (Account-level access, not listing-specific)
```

**Access Model:**
- Title reps have access to agent's **account**, not individual listings
- Permissions granted via `Permission` table
- Account-level access allows title reps to perform certain tasks
- NOT tracked as listing-specific collaborators

**Relationship to PLS Tables:**
- Title reps can make changes (tracked in `pls_status_log.changed_by`)
- Access controlled via `Permission` table, NOT `pls_collaborators`

---

## 📊 HELPER VIEWS (Backward Compatibility)

### 1. `vw_pls_tracking_with_codes`
**Purpose:** Provides status_code and source_code for easier querying

**Columns:**
- All `pls_tracking` columns
- `source_code`, `source_display_name` (from `pls_source_type`)
- `status_code`, `status_display_name` (from `pls_status_type`)

### 2. `vw_pls_status_log_with_codes`
**Purpose:** Provides status codes for easier querying

**Columns:**
- All `pls_status_log` columns
- `from_status_code`, `from_status_display_name` (from `pls_status_type`)
- `to_status_code`, `to_status_display_name` (from `pls_status_type`)

---

## 🔄 REMOVED FROM v2.0

### ❌ `pls_collaborators` Table
- **Removed:** Entire table and all indexes
- **Reason:** Collaborator concept doesn't align with RESO architecture
- **Replacement:** 
  - Co-Listing Agent → `MlsListing.dbo.Listing` (RESO fields)
  - Title Reps → `Permission` table (account-level)

### ❌ `pls_collaborator_role` Lookup Table
- **Removed:** Entire lookup table
- **Reason:** No longer needed without `pls_collaborators` table
- **Previous Values:**
  - `title_rep` - Title Representative
  - `co_lister` - Co-Listing Agent

### ❌ `vw_pls_collaborators_with_codes` View
- **Removed:** View that joined `pls_collaborators` with `pls_collaborator_role`
- **Reason:** No longer needed without base table

---

## 📝 EXAMPLE QUERIES

### Query 1: Get PLS listing with agents (from RESO table)
```sql
SELECT 
    l.ListingID,
    l.MlsNumber,
    l.DisplayAddress,
    l.ListingAgentName,
    l.ListingAgentID,
    l.CoListingAgentName,  -- Co-Listing Agent from RESO table
    l.CoListingAgentID,    -- Co-Listing Agent ID from RESO table
    vpt.status_code,
    vpt.status_display_name,
    vpt.was_listed,
    vpt.mls_published
FROM MlsListing.dbo.Listing l
INNER JOIN dbo.vw_pls_tracking_with_codes vpt ON vpt.listing_id = l.ListingID
WHERE vpt.agent_id = 'user-guid-here'
    AND l.MlsID = 777
    AND vpt.status_code IN ('active', 'coming_soon')
ORDER BY vpt.updated_at DESC;
```

### Query 2: Check Title Rep permissions (account-level)
```sql
-- Check if user has Title Partner permissions
SELECT 
    p.UserId,
    p.PermissionTypeId,
    pt.Name AS PermissionTypeName
FROM FarmGenie.dbo.Permission p
INNER JOIN FarmGenie.dbo.PermissionType pt ON pt.PermissionTypeId = p.PermissionTypeId
WHERE p.UserId = 'title-rep-guid-here'
    AND pt.Name LIKE '%Title Partner%';
```

### Query 3: Get status mapping to MLS StatusTypeID
```sql
SELECT 
    pst.status_code,
    pst.status_name,
    psm.mls_status_type_id,
    st.Name AS mls_status_name
FROM dbo.pls_status_type pst
LEFT JOIN dbo.pls_status_mapping psm ON psm.pls_status_type_id = pst.status_type_id
LEFT JOIN MlsListing.dbo.StatusType st ON st.StatusTypeID = psm.mls_status_type_id
WHERE pst.is_active = 1
ORDER BY pst.display_order;
```

---

## ✅ BENEFITS OF v3.0 ARCHITECTURE

1. **RESO Compliance:**
   - Co-Listing Agents stored in standard RESO fields
   - RESO feed can validate MLS membership
   - No custom PLS-specific agent tracking

2. **Simplified Architecture:**
   - Fewer tables to maintain
   - Clear separation: agents in RESO table, permissions in Permission table
   - No confusion between "collaborators" and "agents"

3. **Permission Model Alignment:**
   - Title reps use existing Permission table
   - Account-level access (not listing-specific)
   - Consistent with rest of TheGenie.ai platform

4. **Future RESO Feed Integration:**
   - Co-Listing Agent already in RESO format
   - No transformation needed when publishing to MLS
   - RESO feed validates both agents are MLS members

---

## 📚 RELATED DOCUMENTS

- `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` - SQL schema (v3.0)
- `PLS_SCHEMA_CHANGES_v2_to_v3.md` - Detailed change log
- `PLS_COLLABORATOR_ROLE_DESIGN_v2.md` - Analysis that led to this change
- `PLS_COLLABORATOR_ORIGIN_ANALYSIS_v2.md` - Origin of collaborator concept

---

**Change Log:**
- **v3.0 (01/05/2026):** Removed collaborator concept, clarified agent/permission model
- **v2.0 (01/05/2026):** Initial normalized schema with lookup tables
- **v1.1 (01/05/2026):** Changed MlsID from 999 to 777
- **v1.0 (01/05/2026):** Initial schema with string-based enums

