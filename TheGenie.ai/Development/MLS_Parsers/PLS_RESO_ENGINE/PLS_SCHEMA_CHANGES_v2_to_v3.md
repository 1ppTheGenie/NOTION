# PLS Schema Changes: v2.0 → v3.0
**Version:** 1.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Documents the removal of collaborator concept and clarification of agent/permission model

---

## 🎯 SUMMARY OF CHANGES

**Version 3.0** removes the `pls_collaborators` table and `pls_collaborator_role` lookup table, clarifying that:
- **Listing Agents** (including Co-Listing Agent) are stored in `MlsListing.dbo.Listing` using standard RESO fields
- **Title Reps** access listings via the `Permission` table (account-level permissions), not listing-specific tracking

---

## ❌ REMOVED TABLES

### 1. `pls_collaborators` Table
**Removed:** Entire table and all indexes  
**Reason:** Collaborator concept doesn't align with RESO architecture

**Previous Purpose (v2.0):**
- Tracked co-agents or title reps involved in a PLS listing
- Had foreign keys to `listing_id`, `user_id`, and `role_id`

**Replacement:**
- **Co-Listing Agent:** Stored in `MlsListing.dbo.Listing` fields:
  - `CoListingAgentName` (NVARCHAR)
  - `CoListingAgentID` (NVARCHAR)
  - Both must be verified MLS members (validated by RESO feed)
- **Title Reps:** Access controlled via `FarmGenie.dbo.Permission` table
  - Title Partner permissions grant account-level access
  - NOT listing-specific

### 2. `pls_collaborator_role` Lookup Table
**Removed:** Entire lookup table and all indexes  
**Reason:** No longer needed without `pls_collaborators` table

**Previous Values (v2.0):**
- `title_rep` - Title Representative
- `co_lister` - Co-Listing Agent

**Replacement:**
- Co-Listing Agent role = stored in RESO listing table (no lookup needed)
- Title Rep role = Permission table (no lookup needed)

### 3. `vw_pls_collaborators_with_codes` View
**Removed:** View that joined `pls_collaborators` with `pls_collaborator_role`  
**Reason:** No longer needed without base table

---

## ✅ CLARIFIED ARCHITECTURE

### Listing Agents (RESO-Compliant)

**Storage Location:** `MlsListing.dbo.Listing` (existing RESO table)

| Field | Type | Purpose |
|-------|------|---------|
| `ListingAgentName` | NVARCHAR | Primary listing agent name |
| `ListingAgentID` | NVARCHAR | Primary listing agent ID (MLS member) |
| `CoListingAgentName` | NVARCHAR | Co-listing agent name (optional) |
| `CoListingAgentID` | NVARCHAR | Co-listing agent ID (MLS member) |

**Validation Requirements:**
- Both agents must be verified MLS members
- RESO feed validates MLS membership before publishing
- Stored in standard RESO fields - no PLS-specific tracking needed

**Example Query:**
```sql
SELECT 
    l.ListingID,
    l.MlsNumber,
    l.ListingAgentName,
    l.ListingAgentID,
    l.CoListingAgentName,
    l.CoListingAgentID
FROM MlsListing.dbo.Listing l
WHERE l.MlsID = 777  -- PLS listings
    AND l.CoListingAgentID IS NOT NULL;  -- Has co-listing agent
```

### Title Reps (Permission-Based Access)

**Storage Location:** `FarmGenie.dbo.Permission` (existing table)

**Access Model:**
- Title reps have access to agent's **account**, not individual listings
- Permissions granted via `Permission` table with `PermissionTypeId` for "Title Partner"
- Account-level access allows title reps to perform certain tasks across all agent's listings
- NOT tracked as listing-specific collaborators

**Example Query:**
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

---

## 📊 REMAINING TABLES (Unchanged)

### Core PLS Tables
1. **`pls_tracking`** - Tracks PLS metadata (status, source, flags)
2. **`pls_status_log`** - Audit trail of status changes

### Lookup Tables
1. **`pls_status_type`** - PLS lifecycle status values
2. **`pls_source_type`** - PLS creation source values
3. **`pls_status_mapping`** - Maps PLS status to MLS StatusTypeID

### Views
1. **`vw_pls_tracking_with_codes`** - Backward-compatible view with status/source codes
2. **`vw_pls_status_log_with_codes`** - Backward-compatible view with status codes

---

## 🔄 MIGRATION NOTES

### If You Have Existing v2.0 Data

**Before Dropping Tables:**
1. Export any data from `pls_collaborators` table (if exists)
2. For Co-Listing Agents:
   - Migrate to `MlsListing.dbo.Listing.CoListingAgentName` and `CoListingAgentID`
   - Verify both agents are MLS members
3. For Title Reps:
   - Ensure permissions are set in `FarmGenie.dbo.Permission` table
   - Grant "Title Partner" permission type

**Migration Script (if needed):**
```sql
-- Example: Migrate co-listing agents from pls_collaborators to Listing table
-- (Only if you have existing data - adjust as needed)

UPDATE MlsListing.dbo.Listing l
SET 
    l.CoListingAgentName = u.UserName,  -- Adjust based on your user table structure
    l.CoListingAgentID = pc.user_id
FROM MlsListing.dbo.Listing l
INNER JOIN FarmGenie.dbo.pls_collaborators pc ON pc.listing_id = l.ListingID
INNER JOIN FarmGenie.dbo.pls_collaborator_role pcr ON pcr.role_id = pc.role_id
INNER JOIN FarmGenie.dbo.AspNetUsers u ON u.Id = pc.user_id
WHERE pcr.role_code = 'co_lister'
    AND l.MlsID = 777
    AND l.CoListingAgentID IS NULL;  -- Only update if not already set
```

---

## 📝 UPDATED COMMENTS IN v3.0

### `pls_tracking.agent_id` Field
**v2.0 Comment:**
```sql
agent_id NVARCHAR(450) NOT NULL,
    -- References: FarmGenie.dbo.AspNetUsers(Id)
```

**v3.0 Comment:**
```sql
agent_id NVARCHAR(450) NOT NULL,
    -- References: FarmGenie.dbo.AspNetUsers(Id)
    -- Primary listing agent (owner of PLS listing)
    -- NOTE: Co-Listing Agent stored in MlsListing.dbo.Listing (RESO fields)
    --       NOT tracked here - use CoListingAgentName/CoListingAgentID in Listing table
```

### `pls_status_log.changed_by` Field
**v2.0 Comment:**
```sql
changed_by NVARCHAR(450) NOT NULL,
    -- References: FarmGenie.dbo.AspNetUsers(Id)
```

**v3.0 Comment:**
```sql
changed_by NVARCHAR(450) NOT NULL,
    -- References: FarmGenie.dbo.AspNetUsers(Id)
    -- User who made the status change (agent, title rep with permissions, admin)
```

---

## ✅ BENEFITS OF v3.0 CHANGES

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

## 🎯 NEXT STEPS

1. **Review v3.0 Schema:**
   - `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`

2. **Update Application Code:**
   - Remove any references to `pls_collaborators` table
   - Update queries to use `MlsListing.dbo.Listing.CoListingAgentName/ID`
   - Update permission checks to use `Permission` table for title reps

3. **Update Documentation:**
   - Remove collaborator references from project blueprints
   - Update API documentation
   - Update UI mockups (if any)

4. **Test Migration (if needed):**
   - Run migration script if you have existing v2.0 data
   - Verify Co-Listing Agents appear in RESO listing table
   - Verify Title Rep permissions work correctly

---

## 📚 RELATED DOCUMENTS

- `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` - New schema (v3.0)
- `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v2.sql` - Previous schema (v2.0) - **DEPRECATED**
- `PLS_COLLABORATOR_ROLE_DESIGN_v2.md` - Analysis that led to this change
- `PLS_COLLABORATOR_ORIGIN_ANALYSIS_v2.md` - Origin of collaborator concept

---

**Change Log:**
- **v1.0 (01/05/2026):** Initial document created to explain v2.0 → v3.0 changes

