# PLS Schema Extensions - README
**Version:** 1.1  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Documentation for PLS schema extension tables (pls_tracking, pls_status_log, pls_collaborators)

---

## 🎯 OVERVIEW

This document describes three new SQL tables that extend the existing RESO-based TheGenie.ai platform to support the PLS (Private Listing Service) feature lifecycle.

**Critical Design Decision:** These tables extend the existing `MlsListing.dbo.Listing` table - **NO new listing table was created**. All property listing details are stored in the existing RESO-compliant `Listing` table with `MlsID=777` for PLS listings.

---

## 📊 TABLE SUMMARY

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| **pls_tracking** | Tracks PLS-specific metadata for each listing | Links to `Listing` (listing_id) and `AspNetUsers` (agent_id) |
| **pls_status_log** | Audit trail of all status transitions | Links to `Listing` (listing_id) and `AspNetUsers` (changed_by) |
| **pls_collaborators** | Tracks co-agents and title reps | Links to `Listing` (listing_id) and `AspNetUsers` (user_id) |

---

## 📋 TABLE 1: pls_tracking

### Purpose
Tracks PLS-specific metadata for each listing, including creation source, lifecycle status, and business outcome flags.

### Key Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | INT (PK) | Primary key, auto-increment |
| `listing_id` | INT (FK) | References `MlsListing.dbo.Listing(ListingID)` |
| `agent_id` | NVARCHAR(450) (FK) | References `FarmGenie.dbo.AspNetUsers(Id)` - listing owner |
| `source` | NVARCHAR(50) | Creation source: 'paisley', 'manual', 'import', 'api' |
| `status` | NVARCHAR(50) | Lifecycle status: 'incomplete', 'draft', 'active', 'coming_soon', 'lost_opportunity', 'published_to_mls' |
| `was_listed` | BIT | Whether agent ultimately got the listing |
| `mls_published` | BIT | Whether listing was published to actual MLS |
| `created_at` | DATETIME2(7) | Creation timestamp (UTC) |
| `updated_at` | DATETIME2(7) | Last update timestamp (UTC) |

### Status Mapping

| pls_tracking.status | MlsListing.Listing.StatusTypeID | Description |
|---------------------|--------------------------------|-------------|
| `incomplete` | NULL | Not yet saved |
| `draft` | NULL | Saved but not published |
| `active` | 6 | Private Listing (published) |
| `coming_soon` | 14 | Coming Soon (published) |
| `lost_opportunity` | NULL | Listing opportunity lost |
| `published_to_mls` | 1, 2, etc. | Published to actual MLS |

### Constraints
- **PK:** `id` (clustered)
- **FK:** `agent_id` → `AspNetUsers(Id)` (CASCADE on delete)
- **Unique:** `listing_id` (one tracking record per listing)
- **Check:** `status` must be valid enum value
- **Check:** `source` must be valid enum value

### Indexes
- `IX_pls_tracking_listing_id` - Fast lookup by listing
- `IX_pls_tracking_agent_id` - Fast lookup by agent (filtered for active listings)
- `IX_pls_tracking_status` - Fast lookup by status (filtered for published listings)
- `UQ_pls_tracking_listing_id` - Unique constraint on listing_id

---

## 📋 TABLE 2: pls_status_log

### Purpose
Complete audit trail of every status transition for PLS listings. Never delete records - preserves complete history.

### Key Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | BIGINT (PK) | Primary key, auto-increment |
| `listing_id` | INT (FK) | References `MlsListing.dbo.Listing(ListingID)` |
| `changed_by` | NVARCHAR(450) (FK) | References `FarmGenie.dbo.AspNetUsers(Id)` - who made the change |
| `from_status` | NVARCHAR(50) | Previous status (NULL for initial creation) |
| `to_status` | NVARCHAR(50) | New status |
| `changed_at` | DATETIME2(7) | Timestamp of change (UTC) |

### Constraints
- **PK:** `id` (clustered)
- **FK:** `changed_by` → `AspNetUsers(Id)` (NO ACTION on delete - preserve audit trail)
- **Check:** `to_status` must be valid enum value
- **Check:** `from_status` must be NULL or valid enum value

### Indexes
- `IX_pls_status_log_listing_id` - Fast lookup by listing (ordered by date DESC)
- `IX_pls_status_log_changed_by` - Fast lookup by user (ordered by date DESC)
- `IX_pls_status_log_to_status` - Fast lookup by status (filtered for published/lost)

### Usage Pattern
Every time `pls_tracking.status` changes, insert a new record into `pls_status_log`:

```sql
-- When status changes from 'draft' to 'active'
INSERT INTO dbo.pls_status_log (listing_id, changed_by, from_status, to_status)
VALUES (12345, 'user-guid', 'draft', 'active');

-- Update pls_tracking
UPDATE dbo.pls_tracking 
SET status = 'active', updated_at = GETUTCDATE()
WHERE listing_id = 12345;
```

---

## 📋 TABLE 3: pls_collaborators

### Purpose
Tracks co-agents or title reps involved in a PLS listing. Supports collaboration workflows.

### Key Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | INT (PK) | Primary key, auto-increment |
| `listing_id` | INT (FK) | References `MlsListing.dbo.Listing(ListingID)` |
| `user_id` | NVARCHAR(450) (FK) | References `FarmGenie.dbo.AspNetUsers(Id)` - collaborator |
| `role` | NVARCHAR(50) | Role: 'title_rep' or 'co_lister' |
| `joined_at` | DATETIME2(7) | When collaborator was added (UTC) |

### Role Types

| Role | Description |
|------|-------------|
| `title_rep` | Title company representative |
| `co_lister` | Co-listing agent |

### Constraints
- **PK:** `id` (clustered)
- **FK:** `user_id` → `AspNetUsers(Id)` (CASCADE on delete)
- **Unique:** `(listing_id, user_id, role)` - One role per user per listing
- **Check:** `role` must be 'title_rep' or 'co_lister'

### Indexes
- `IX_pls_collaborators_listing_id` - Fast lookup by listing
- `IX_pls_collaborators_user_id` - Fast lookup by user
- `IX_pls_collaborators_role` - Fast lookup by role (filtered for title_rep)

### Usage Pattern
```sql
-- Add title rep
INSERT INTO dbo.pls_collaborators (listing_id, user_id, role)
VALUES (12345, 'title-rep-guid', 'title_rep');

-- Add co-lister
INSERT INTO dbo.pls_collaborators (listing_id, user_id, role)
VALUES (12345, 'co-agent-guid', 'co_lister');
```

---

## 🔗 RELATIONSHIPS TO EXISTING TABLES

### MlsListing.dbo.Listing
- **Relationship:** One-to-one with `pls_tracking` (via `listing_id`)
- **Usage:** All property listing details stored here
- **PLS Identifier:** `MlsID = 777`
- **Status Codes:** `StatusTypeID = 6` (Private) or `14` (Coming Soon)

### FarmGenie.dbo.AspNetUsers
- **Relationship:** One-to-many with all three PLS tables
- **Usage:** 
  - `pls_tracking.agent_id` = listing owner
  - `pls_status_log.changed_by` = who made status change
  - `pls_collaborators.user_id` = collaborator

### FarmGenie.dbo.Permission
- **Relationship:** Application-level permissions (not database FK)
- **Permissions:**
  - 210: ManagePLS - Create/edit/delete listings
  - 211: Menu PLS - Access PLS menu
  - 212: View PLS History - View status log
  - 213: PLS Radar - View all listings (admin)
  - 214: PLS Submit While Impersonating

---

## 🛡️ PERMISSIONS MODEL

### Role Requirements

| Role | Permissions | Can Create/Edit | Can Publish to MLS |
|------|-------------|-----------------|-------------------|
| **Elite Agent** | 210, 211 | ✅ Yes | ✅ Own listings only |
| **Ultimate Agent** | 210, 211 | ✅ Yes | ✅ Own listings only |
| **Super User** | 210, 211, 213 | ✅ Yes | ✅ All listings |
| **Admin** | 210, 211, 213, 214 | ✅ Yes | ✅ All listings (can impersonate) |
| **Title Rep** | 211 (view only) | ❌ No | ❌ No |

### Business Rules
1. **Only listing owners can publish to MLS** (validated in application layer)
2. **Admins can view all listings** (Permission 213)
3. **Elite Agent or higher required** to create/edit listings (Permission 210)
4. **Collaborators can view** but not edit (unless granted explicit permission)

---

## 📊 COMMON QUERIES

### Query 1: Get User's Active PLS Listings
```sql
SELECT 
    l.ListingID,
    l.MlsNumber,
    l.DisplayAddress,
    l.OriginalListPrice,
    pt.status,
    pt.was_listed,
    pt.mls_published,
    pt.created_at
FROM MlsListing.dbo.Listing l
INNER JOIN FarmGenie.dbo.pls_tracking pt ON pt.listing_id = l.ListingID
WHERE pt.agent_id = @userId
    AND l.MlsID = 777
    AND pt.status IN ('active', 'coming_soon')
ORDER BY pt.updated_at DESC;
```

### Query 2: Get Status History for Listing
```sql
SELECT 
    from_status,
    to_status,
    u.Email AS changed_by_email,
    changed_at
FROM FarmGenie.dbo.pls_status_log psl
INNER JOIN FarmGenie.dbo.AspNetUsers u ON u.Id = psl.changed_by
WHERE psl.listing_id = @listingId
ORDER BY psl.changed_at DESC;
```

### Query 3: Get All Collaborators for Listing
```sql
SELECT 
    u.Email,
    u.UserName,
    up.FirstName,
    up.LastName,
    pc.role,
    pc.joined_at
FROM FarmGenie.dbo.pls_collaborators pc
INNER JOIN FarmGenie.dbo.AspNetUsers u ON u.Id = pc.user_id
LEFT JOIN FarmGenie.dbo.AspNetUserProfiles up ON up.AspNetUserId = u.Id
WHERE pc.listing_id = @listingId
ORDER BY pc.joined_at ASC;
```

### Query 4: Get Listings Ready for MLS Publish
```sql
SELECT 
    l.ListingID,
    l.MlsNumber,
    l.DisplayAddress,
    pt.agent_id,
    pt.status,
    pt.created_at
FROM MlsListing.dbo.Listing l
INNER JOIN FarmGenie.dbo.pls_tracking pt ON pt.listing_id = l.ListingID
WHERE l.MlsID = 777
    AND pt.status IN ('active', 'coming_soon')
    AND pt.mls_published = 0
    AND pt.was_listed = 1
ORDER BY pt.updated_at DESC;
```

---

## ⚠️ IMPORTANT NOTES

### 0. MlsID Change Coordination
- **⚠️ CRITICAL:** This schema uses `MlsID = 777` for PLS listings
- **Previous Value:** `MlsID = 999` was used in earlier documentation
- **Action Required:** This change must be coordinated across the entire PLS system:
  - Update `MlsListing.dbo.Mls` table INSERT statement (use 777 instead of 999)
  - Update all application code that filters by `MlsID = 999`
  - Update all stored procedures that reference `MlsID = 999`
  - Update all documentation that references `MlsID = 999`
  - Verify no existing PLS listings use `MlsID = 999` before changing

### 1. Cross-Database Foreign Keys
- SQL Server does not support cross-database foreign keys
- `listing_id` references `MlsListing.dbo.Listing(ListingID)` but FK not enforced
- **Application layer must validate** listing_id exists before inserting

### 2. Status Synchronization
- `pls_tracking.status` must be kept in sync with `MlsListing.dbo.Listing.StatusTypeID`
- Application layer must maintain consistency:
  - When `status = 'active'` → `StatusTypeID = 6`
  - When `status = 'coming_soon'` → `StatusTypeID = 14`

### 3. Audit Trail Preservation
- **Never delete records from `pls_status_log`** - it's a complete audit trail
- Use `changed_by` to track who made each change
- Consider archiving old records if volume grows (partition by date)

### 4. Performance Considerations
- Indexes created for common query patterns
- Filtered indexes for active/published listings (reduces index size)
- Consider partitioning `pls_status_log` by date if volume exceeds 1M records

### 5. Future Enhancements
- Add `notes` column to `pls_status_log` for change reasons
- Add `notification_preferences` to `pls_collaborators`
- Add soft-delete support (`IsDeleted` flag) if needed
- Add `exported_to_mls_at` timestamp to `pls_tracking` for future RESO Insert feature

---

## 🚀 DEPLOYMENT

### Prerequisites
1. Database: `FarmGenie` (for PLS tables)
2. Database: `MlsListing` (existing, no changes)
3. User: `sa` or user with `db_owner` role
4. Existing tables: `AspNetUsers`, `Permission` (must exist)

### Execution Steps
1. **Backup Production** (per Fortune 500 deployment rules)
2. **Review SQL Script** (`PLS_SCHEMA_EXTENSIONS_v1.sql`)
3. **Execute in Test Environment First**
4. **Verify Tables Created:**
   ```sql
   SELECT * FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_NAME IN ('pls_tracking', 'pls_status_log', 'pls_collaborators');
   ```
5. **Verify Indexes Created:**
   ```sql
   SELECT * FROM sys.indexes 
   WHERE object_id IN (
       OBJECT_ID('dbo.pls_tracking'),
       OBJECT_ID('dbo.pls_status_log'),
       OBJECT_ID('dbo.pls_collaborators')
   );
   ```
6. **Deploy to Production** (after test validation)

---

## 📚 RELATED DOCUMENTS

- **SQL Script:** `PLS_SCHEMA_EXTENSIONS_v1.sql`
- **Relational Schema:** `PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
- **Database Implementation Spec:** `../PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`
- **3-Layer Gap Analysis:** `PLS_3_LAYER_GAP_ANALYSIS_v1.md`
- **Project Blueprint:** `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.2.md`

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.1 | 01/05/2026 | Updated MlsID from 999 to 777 for PLS listings |
| 1.0 | 01/05/2026 | Initial schema creation - three tables (pls_tracking, pls_status_log, pls_collaborators) with indexes, constraints, and documentation |

---

**Status:** ✅ Schema Complete - Ready for DBA Review and Deployment

**Next Action:** DBA reviews schema, executes script in test environment, validates indexes, then deploys to production.

