# PLS Database Extensions - Visual Schema Diagram
**Version:** 1.2  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Visual representation of PLS control/tracking tables (separate from RESO listing data)

---

## 🎯 SCOPE

This diagram shows **only the PLS extension tables** that control, track, update, and manage PLS listings. These tables are **NOT part of the RESO listing package** sent to MLS.

**Excluded:** The actual `MlsListing.dbo.Listing` table structure (RESO data) - only shown as a reference point.

---

## 📋 TABLE CLASSIFICATION

### 🆕 NEW TABLES (Created by PLS Schema Extensions)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **pls_tracking** | FarmGenie | 🆕 NEW | Tracks PLS-specific metadata and lifecycle status |
| **pls_status_log** | FarmGenie | 🆕 NEW | Complete audit trail of status transitions |
| **pls_collaborators** | FarmGenie | 🆕 NEW | Tracks co-agents and title reps |

### ✅ EXISTING TABLES (Referenced, Not Modified)

| Table | Database | Status | Purpose |
|-------|----------|--------|---------|
| **AspNetUsers** | FarmGenie | ✅ EXISTING | User accounts (referenced via FK) |
| **MlsListing.dbo.Listing** | MlsListing | ✅ EXISTING | RESO listing data (referenced via listing_id) |
| **Permission** | FarmGenie | ✅ EXISTING | Permission definitions (application-level) |
| **RolePermission** | FarmGenie | ✅ EXISTING | Role-permission mapping (application-level) |

**Note:** Existing tables are **NOT modified** by PLS extensions. They are only referenced via foreign keys or application-level relationships.

---

## 🆕 NEW TABLES ONLY (Isolated View)

This section shows **ONLY the 3 new tables** that will be created by the PLS schema extensions. These tables do not currently exist in the system.

### Visual Schema - New Tables Only

```
┌─────────────────────────────────────────────────────────────────────────────┐
│         🆕 NEW TABLES TO BE CREATED                                          │
│         (FarmGenie Database - PLS Schema Extensions)                        │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  🆕 pls_tracking                                                      │  │
│  │     (Primary Control Table)                                          │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: id (INT IDENTITY)                                               │  │
│  │  FK: listing_id (INT) ────────────┐                                  │  │
│  │  FK: agent_id (NVARCHAR(450)) ────┼──┐                               │  │
│  │  source (NVARCHAR(50))             │  │                               │  │
│  │    DEFAULT 'paisley'               │  │                               │  │
│  │    CHECK: 'paisley', 'manual', 'import', 'api'                       │  │
│  │  status (NVARCHAR(50))              │  │                               │  │
│  │    DEFAULT 'incomplete'            │  │                               │  │
│  │    CHECK: 'incomplete', 'draft', 'active', 'coming_soon',            │  │
│  │          'lost_opportunity', 'published_to_mls'                      │  │
│  │  was_listed (BIT) DEFAULT 0         │  │                               │  │
│  │  mls_published (BIT) DEFAULT 0     │  │                               │  │
│  │  created_at (DATETIME2(7))         │  │                               │  │
│  │  updated_at (DATETIME2(7))         │  │                               │  │
│  │  UNIQUE: listing_id (one per listing)                               │  │
│  └────────────────────────────────────┼──┼───────────────────────────────┘  │
│                                        │  │                                   │
│                                        │  │                                   │
│  ┌────────────────────────────────────▼──▼───────────────────────────────┐  │
│  │  🆕 pls_status_log                                                     │  │
│  │     (Audit Trail Table)                                               │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: id (BIGINT IDENTITY)                                            │  │
│  │  FK: listing_id (INT) ────────────┐                                  │  │
│  │  FK: changed_by (NVARCHAR(450)) ───┼──┐                               │  │
│  │  from_status (NVARCHAR(50)) NULL   │  │                               │  │
│  │    CHECK: NULL or valid status enum                                  │  │
│  │  to_status (NVARCHAR(50))           │  │                               │  │
│  │    CHECK: valid status enum                                          │  │
│  │  changed_at (DATETIME2(7))          │  │                               │  │
│  │  (No unique constraints - multiple records per listing)              │  │
│  └────────────────────────────────────┼──┼───────────────────────────────┘  │
│                                        │  │                                   │
│                                        │  │                                   │
│  ┌────────────────────────────────────▼──▼───────────────────────────────┐  │
│  │  🆕 pls_collaborators                                                 │  │
│  │     (Collaboration Table)                                             │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: id (INT IDENTITY)                                               │  │
│  │  FK: listing_id (INT) ────────────┐                                  │  │
│  │  FK: user_id (NVARCHAR(450)) ─────┼──┐                               │  │
│  │  role (NVARCHAR(50))               │  │                               │  │
│  │    CHECK: 'title_rep', 'co_lister' │  │                               │  │
│  │  joined_at (DATETIME2(7))          │  │                               │  │
│  │  UNIQUE: (listing_id, user_id, role)                                │  │
│  └────────────────────────────────────┼──┼───────────────────────────────┘  │
│                                        │  │                                   │
│                                        │  │                                   │
│  ┌────────────────────────────────────┐  │                                   │
│  │  Foreign Key References:           │  │                                   │
│  │  • listing_id → MlsListing.dbo.Listing(ListingID)                    │  │
│  │    (Cross-database - validated in application layer)                 │  │
│  │  • agent_id → FarmGenie.dbo.AspNetUsers(Id)                          │  │
│  │  • changed_by → FarmGenie.dbo.AspNetUsers(Id)                        │  │
│  │  • user_id → FarmGenie.dbo.AspNetUsers(Id)                           │  │
│  └────────────────────────────────────┘  │                                   │
│                                           │                                   │
└───────────────────────────────────────────┘                                   │
```

### Table Relationships (New Tables Only)

```
pls_tracking (1:1 with Listing)
    │
    ├── listing_id → References MlsListing.dbo.Listing(ListingID)
    │
    └── agent_id → References FarmGenie.dbo.AspNetUsers(Id)

pls_status_log (1:N with Listing)
    │
    ├── listing_id → References MlsListing.dbo.Listing(ListingID)
    │
    └── changed_by → References FarmGenie.dbo.AspNetUsers(Id)

pls_collaborators (M:N with Listing and Users)
    │
    ├── listing_id → References MlsListing.dbo.Listing(ListingID)
    │
    └── user_id → References FarmGenie.dbo.AspNetUsers(Id)
```

### Indexes (New Tables Only)

**pls_tracking:**
- `IX_pls_tracking_listing_id` - Fast lookup by listing
- `IX_pls_tracking_agent_id` - Fast lookup by agent (filtered for active)
- `IX_pls_tracking_status` - Fast lookup by status (filtered for published)
- `UQ_pls_tracking_listing_id` - Unique constraint

**pls_status_log:**
- `IX_pls_status_log_listing_id` - Chronological history
- `IX_pls_status_log_changed_by` - User activity tracking
- `IX_pls_status_log_to_status` - Status transitions (filtered)

**pls_collaborators:**
- `IX_pls_collaborators_listing_id` - Listing collaborators
- `IX_pls_collaborators_user_id` - User collaborations
- `IX_pls_collaborators_role` - Role-based lookup (filtered)

### Summary

| Table | Records | Purpose | Key Constraint |
|-------|---------|---------|----------------|
| **pls_tracking** | 1 per listing | Lifecycle control | UNIQUE listing_id |
| **pls_status_log** | N per listing | Audit trail | None (preserve all history) |
| **pls_collaborators** | N per listing | Collaboration | UNIQUE (listing_id, user_id, role) |

**Total New Tables:** 3  
**Total New Indexes:** 9 (3 per table)  
**Database:** FarmGenie  
**Schema:** dbo

---

## 📊 FULL VISUAL SCHEMA DIAGRAM (With Existing Tables)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│         🆕 NEW: PLS CONTROL & TRACKING LAYER                                  │
│         (FarmGenie Database - Created by PLS Schema Extensions)              │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  🆕 NEW: pls_tracking                                                │  │
│  │         (PLS Metadata & Lifecycle)                                  │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: id (INT)                                                         │  │
│  │  FK: listing_id (INT) ──────┐                                        │  │
│  │  FK: agent_id (NVARCHAR) ───┼──┐                                     │  │
│  │  source (NVARCHAR)           │  │                                     │  │
│  │    • 'paisley'               │  │                                     │  │
│  │    • 'manual'                │  │                                     │  │
│  │    • 'import'                │  │                                     │  │
│  │    • 'api'                   │  │                                     │  │
│  │  status (NVARCHAR)            │  │                                     │  │
│  │    • 'incomplete'            │  │                                     │  │
│  │    • 'draft'                 │  │                                     │  │
│  │    • 'active'                │  │                                     │  │
│  │    • 'coming_soon'           │  │                                     │  │
│  │    • 'lost_opportunity'      │  │                                     │  │
│  │    • 'published_to_mls'      │  │                                     │  │
│  │  was_listed (BIT)            │  │                                     │  │
│  │  mls_published (BIT)          │  │                                     │  │
│  │  created_at (DATETIME2)       │  │                                     │  │
│  │  updated_at (DATETIME2)       │  │                                     │  │
│  └──────────────────────────────┼──┼──────────────────────────────────────┘  │
│                                  │  │                                        │
│                                  │  │                                        │
│  ┌──────────────────────────────▼──▼──────────────────────────────────────┐  │
│  │  🆕 NEW: pls_status_log                                                 │  │
│  │         (Complete Audit Trail)                                         │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: id (BIGINT)                                                      │  │
│  │  FK: listing_id (INT) ──────┐                                        │  │
│  │  FK: changed_by (NVARCHAR) ───┼──┐                                     │  │
│  │  from_status (NVARCHAR)       │  │                                     │  │
│  │    • NULL (initial)           │  │                                     │  │
│  │    • 'incomplete'             │  │                                     │  │
│  │    • 'draft'                  │  │                                     │  │
│  │    • 'active'                 │  │                                     │  │
│  │    • 'coming_soon'            │  │                                     │  │
│  │    • 'lost_opportunity'       │  │                                     │  │
│  │    • 'published_to_mls'      │  │                                     │  │
│  │  to_status (NVARCHAR)         │  │                                     │  │
│  │    • 'incomplete'             │  │                                     │  │
│  │    • 'draft'                  │  │                                     │  │
│  │    • 'active'                 │  │                                     │  │
│  │    • 'coming_soon'            │  │                                     │  │
│  │    • 'lost_opportunity'       │  │                                     │  │
│  │    • 'published_to_mls'       │  │                                     │  │
│  │  changed_at (DATETIME2)         │  │                                     │  │
│  └──────────────────────────────┼──┼──────────────────────────────────────┘  │
│                                  │  │                                        │
│                                  │  │                                        │
│  ┌──────────────────────────────▼──▼──────────────────────────────────────┐  │
│  │  🆕 NEW: pls_collaborators                                             │  │
│  │         (Co-Agents & Title Reps)                                      │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │  PK: id (INT)                                                         │  │
│  │  FK: listing_id (INT) ──────┐                                        │  │
│  │  FK: user_id (NVARCHAR) ─────┼──┐                                     │  │
│  │  role (NVARCHAR)              │  │                                     │  │
│  │    • 'title_rep'              │  │                                     │  │
│  │    • 'co_lister'              │  │                                     │  │
│  │  joined_at (DATETIME2)        │  │                                     │  │
│  │  UNIQUE: (listing_id, user_id, role)                                 │  │
│  └──────────────────────────────┼──┼──────────────────────────────────────┘  │
│                                  │  │                                        │
└──────────────────────────────────┼──┼────────────────────────────────────────┘
                                     │  │
                                     │  │
┌────────────────────────────────────▼──▼────────────────────────────────────────┐
│         ✅ EXISTING: REFERENCE TABLES                                         │
│         (Not Created by PLS - Only Referenced)                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌──────────────────────────────┐      ┌──────────────────────────────┐     │
│  │  ✅ EXISTING: AspNetUsers    │      │  ✅ EXISTING: Listing         │     │
│  │     (FarmGenie)               │      │     (MlsListing)             │     │
│  ├──────────────────────────────┤      ├──────────────────────────────┤     │
│  │  PK: Id (NVARCHAR) ◄─────────┼──────┤  PK: ListingID (INT) ◄───────┼─────┤
│  │  Email                        │      │  MlsID = 777 (PLS)          │     │
│  │  UserName                     │      │  MlsNumber                  │     │
│  │  ...                          │      │  DisplayAddress             │     │
│  └──────────────────────────────┘      │  StatusTypeID                 │     │
│                                        │  ... (93 RESO fields)        │     │
│                                        │  [NOT SHOWN - RESO Data]     │     │
│                                        └──────────────────────────────┘     │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 RELATIONSHIP SUMMARY

### Core Relationships

```
pls_tracking
    ├── listing_id → MlsListing.dbo.Listing(ListingID)
    │   └── One-to-one: Each listing has one tracking record
    │
    └── agent_id → AspNetUsers(Id)
        └── Many-to-one: Many listings per agent

pls_status_log
    ├── listing_id → MlsListing.dbo.Listing(ListingID)
    │   └── One-to-many: Each listing has many status changes
    │
    └── changed_by → AspNetUsers(Id)
        └── Many-to-one: Many changes per user

pls_collaborators
    ├── listing_id → MlsListing.dbo.Listing(ListingID)
    │   └── One-to-many: Each listing can have many collaborators
    │
    └── user_id → AspNetUsers(Id)
        └── Many-to-many: Users can collaborate on many listings
```

---

## 📋 TABLE DETAILS

### 1. 🆕 pls_tracking (NEW - Control Table)

**Purpose:** Central control table for PLS listing lifecycle

**Key Relationships:**
- **One-to-One** with `Listing` (via `listing_id`)
- **Many-to-One** with `AspNetUsers` (via `agent_id` - listing owner)

**Critical Fields:**
- `status` - Current lifecycle state (NOT RESO status)
- `was_listed` - Business outcome flag
- `mls_published` - MLS export flag
- `source` - Creation origin

**Unique Constraint:** `listing_id` (one tracking record per listing)

---

### 2. 🆕 pls_status_log (NEW - Audit Table)

**Purpose:** Complete audit trail of status transitions

**Key Relationships:**
- **One-to-Many** with `Listing` (via `listing_id`)
- **Many-to-One** with `AspNetUsers` (via `changed_by`)

**Critical Fields:**
- `from_status` - Previous state
- `to_status` - New state
- `changed_by` - Who made the change
- `changed_at` - When it changed

**No Unique Constraints:** Multiple records per listing (audit trail)

---

### 3. 🆕 pls_collaborators (NEW - Collaboration Table)

**Purpose:** Track co-agents and title reps

**Key Relationships:**
- **One-to-Many** with `Listing` (via `listing_id`)
- **Many-to-Many** with `AspNetUsers` (via `user_id`)

**Critical Fields:**
- `role` - 'title_rep' or 'co_lister'
- `joined_at` - When collaborator was added

**Unique Constraint:** `(listing_id, user_id, role)` - One role per user per listing

---

## 🔄 DATA FLOW

### Status Change Flow

```
User changes listing status
    ↓
1. INSERT INTO pls_status_log
   (listing_id, changed_by, from_status, to_status)
    ↓
2. UPDATE pls_tracking
   SET status = new_status, updated_at = NOW
   WHERE listing_id = X
    ↓
3. UPDATE MlsListing.dbo.Listing
   SET StatusTypeID = mapped_status
   WHERE ListingID = X AND MlsID = 777
```

### Collaboration Flow

```
User adds collaborator
    ↓
INSERT INTO pls_collaborators
(listing_id, user_id, role)
    ↓
Collaborator can now view listing
(permissions enforced in application layer)
```

---

## 🎯 WHAT'S NOT INCLUDED

**These are NOT part of PLS extensions (RESO data layer):**

- `MlsListing.dbo.Listing` - Full RESO listing structure (93 fields)
- `MlsListing.dbo.Photo` - Listing photos
- `MlsListing.dbo.StatusType` - Status definitions
- `MlsListing.dbo.PropertyType` - Property type definitions
- `MlsListing.dbo.Mls` - MLS source definitions

**Why:** These tables contain the actual RESO-compliant listing data that gets sent to MLS. The PLS extension tables only **control and track** this data, they don't duplicate it.

---

## 📊 INDEX STRATEGY

### pls_tracking Indexes
- `IX_pls_tracking_listing_id` - Fast lookup by listing
- `IX_pls_tracking_agent_id` - Fast lookup by agent (filtered)
- `IX_pls_tracking_status` - Fast lookup by status (filtered)
- `UQ_pls_tracking_listing_id` - Unique constraint

### pls_status_log Indexes
- `IX_pls_status_log_listing_id` - Chronological history
- `IX_pls_status_log_changed_by` - User activity
- `IX_pls_status_log_to_status` - Status transitions (filtered)

### pls_collaborators Indexes
- `IX_pls_collaborators_listing_id` - Listing collaborators
- `IX_pls_collaborators_user_id` - User collaborations
- `IX_pls_collaborators_role` - Role-based lookup (filtered)

---

## 🔍 QUERY PATTERNS

### Pattern 1: Get Listing Control Data
```sql
SELECT 
    pt.*,  -- All tracking metadata
    (SELECT COUNT(*) FROM pls_status_log WHERE listing_id = pt.listing_id) AS change_count,
    (SELECT COUNT(*) FROM pls_collaborators WHERE listing_id = pt.listing_id) AS collaborator_count
FROM pls_tracking pt
WHERE pt.listing_id = @listingId;
```

### Pattern 2: Get Complete Audit Trail
```sql
SELECT 
    psl.*,
    u.Email AS changed_by_email
FROM pls_status_log psl
INNER JOIN AspNetUsers u ON u.Id = psl.changed_by
WHERE psl.listing_id = @listingId
ORDER BY psl.changed_at DESC;
```

### Pattern 3: Get All Collaborators
```sql
SELECT 
    pc.*,
    u.Email,
    u.UserName
FROM pls_collaborators pc
INNER JOIN AspNetUsers u ON u.Id = pc.user_id
WHERE pc.listing_id = @listingId;
```

---

## 🛡️ SEPARATION OF CONCERNS

### 🆕 Control Layer (NEW - PLS Extensions)
- **🆕 pls_tracking** - Lifecycle control (NEW TABLE)
- **🆕 pls_status_log** - Audit trail (NEW TABLE)
- **🆕 pls_collaborators** - Access control (NEW TABLE)

### ✅ Data Layer (EXISTING - RESO Listing)
- **✅ MlsListing.dbo.Listing** - RESO-compliant property data (EXISTING TABLE)
- **✅ MlsListing.dbo.Photo** - Property images (EXISTING TABLE)
- **✅ MlsListing.dbo.StatusType** - Status definitions (EXISTING TABLE)

**Key Principle:** PLS extensions **control** the listing, but don't **duplicate** the listing data.

---

## 🎯 DEPLOYMENT CHECKLIST

### New Tables to Create
- [ ] **pls_tracking** - Execute CREATE TABLE statement
- [ ] **pls_status_log** - Execute CREATE TABLE statement
- [ ] **pls_collaborators** - Execute CREATE TABLE statement

### Existing Tables (No Changes Required)
- [x] **AspNetUsers** - Already exists, no modifications needed
- [x] **MlsListing.dbo.Listing** - Already exists, no modifications needed
- [x] **Permission** - Already exists, no modifications needed
- [x] **RolePermission** - Already exists, no modifications needed

### Master Data Inserts (Existing Tables)
- [ ] Insert `MlsID = 777` into `MlsListing.dbo.Mls` (if not exists)
- [ ] Insert `StatusTypeID = 6` (Private Listing) into `MlsListing.dbo.StatusType` (if not exists)
- [ ] Insert `StatusTypeID = 14` (Coming Soon) into `MlsListing.dbo.StatusType` (if not exists)
- [ ] Insert `PropertyCastTypeId = 4` (PLS) into `FarmGenie.dbo.PropertyCastType` (if not exists)
- [ ] Insert Permissions 210-214 into `FarmGenie.dbo.Permission` (if not exists)

---

## 📚 RELATED DOCUMENTS

- **SQL Script:** `PLS_SCHEMA_EXTENSIONS_v1.sql`
- **README:** `PLS_SCHEMA_EXTENSIONS_README_v1.md`
- **Relational Schema:** `PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.2 | 01/05/2026 | Added isolated subsection showing ONLY the 3 new tables (without existing reference tables) |
| 1.1 | 01/05/2026 | Added clear NEW vs EXISTING table classification with visual indicators |
| 1.0 | 01/05/2026 | Initial visual schema diagram - PLS control/tracking layer only |

---

**Status:** ✅ Visual Schema Complete

**Purpose:** Shows PLS extension tables (control plane) separate from RESO listing data (data plane)

