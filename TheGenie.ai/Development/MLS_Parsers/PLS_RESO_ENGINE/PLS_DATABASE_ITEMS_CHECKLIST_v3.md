# PLS Database Items - Complete Checklist
**Version:** 1.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Comprehensive checklist of all database items needed for PLS feature

---

## ✅ COMPLETED (v3.0 Schema)

### Core PLS Tracking Tables
- [x] `pls_tracking` - PLS metadata and lifecycle control
- [x] `pls_status_log` - Complete audit trail
- [x] `pls_status_type` - Status lookup table (normalized)
- [x] `pls_source_type` - Source lookup table (normalized)
- [x] `pls_status_mapping` - PLS status → MLS StatusTypeID mapping
- [x] `vw_pls_tracking_with_codes` - Backward-compatible view
- [x] `vw_pls_status_log_with_codes` - Backward-compatible view

### Removed (v3.0)
- [x] ~~`pls_collaborators`~~ - REMOVED (use RESO listing table for agents)
- [x] ~~`pls_collaborator_role`~~ - REMOVED (not needed)
- [x] ~~`vw_pls_collaborators_with_codes`~~ - REMOVED (not needed)

---

## ⏳ PENDING DATABASE ITEMS

### 1. PlsListingOwnership Table

**Status:** ✅ **APPROVED - NEEDS CREATE**

**Architecture Clarification:**
- **`pls_tracking`** = Lifecycle/metadata tracking (status, source, flags) - SEPARATE from ownership
- **`PlsListingOwnership`** = Ownership tracking (who owns/co-owns) - FLEXIBLE for multiple owners

**Purpose:** 
- Track ownership for authorization/permissions
- Support multiple owners (currently max 2: Creator + CoAgent)
- Architecture is flexible for future expansion (different property types, more owners)

**SQL Script:** `PLS_DATABASE_OWNERSHIP_TABLE_v3.sql`

**Key Features:**
- OwnershipTypeId: 1=Creator, 2=CoAgent (expandable for future)
- Supports multiple owners per listing
- PLS number storage per user
- Soft delete via IsActive flag
- Updated: MlsId=777 (not 999), AspNetUserId=NVARCHAR(450) to match AspNetUsers.Id

**Action Required:** Execute `PLS_DATABASE_OWNERSHIP_TABLE_v3.sql`

---

### 2. PlsNumberSequence Table

**Status:** ⏳ **NEEDS CREATE**

**Purpose:** Thread-safe PLS number generation (format: `PLS-YYYY-NNNNN`)

**SQL:**
```sql
CREATE TABLE FarmGenie.dbo.PlsNumberSequence (
    Year INT PRIMARY KEY,
    NextNumber INT NOT NULL DEFAULT 1,
    LastUpdate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE()
);
```

**Indexes:**
```sql
-- No additional indexes needed (Year is PK)
```

**Action Required:** Create table

---

### 3. usp_GetNextPlsNumber Stored Procedure

**Status:** ⏳ **NEEDS CREATE**

**Purpose:** Generate next PLS number in format `PLS-YYYY-NNNNN` (thread-safe)

**Logic:**
1. Get current year
2. Query `PlsNumberSequence` table
3. If year doesn't exist, INSERT with NextNumber=1
4. If year exists, increment NextNumber atomically
5. Format: `PLS-{YEAR}-{RIGHT('00000' + CAST(NextNumber AS VARCHAR), 5)}`

**SQL:**
```sql
CREATE PROCEDURE dbo.usp_GetNextPlsNumber
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentYear INT = YEAR(GETUTCDATE());
    DECLARE @NextNumber INT;
    DECLARE @PlsNumber VARCHAR(50);
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Try to get existing year record
        SELECT @NextNumber = NextNumber
        FROM dbo.PlsNumberSequence
        WHERE Year = @CurrentYear;
        
        IF @NextNumber IS NULL
        BEGIN
            -- Year doesn't exist, create it
            INSERT INTO dbo.PlsNumberSequence (Year, NextNumber)
            VALUES (@CurrentYear, 1);
            SET @NextNumber = 1;
        END
        ELSE
        BEGIN
            -- Year exists, increment atomically
            UPDATE dbo.PlsNumberSequence
            SET NextNumber = NextNumber + 1,
                LastUpdate = GETUTCDATE()
            WHERE Year = @CurrentYear;
            
            SET @NextNumber = @NextNumber + 1;
        END
        
        -- Format: PLS-YYYY-NNNNN
        SET @PlsNumber = 'PLS-' + CAST(@CurrentYear AS VARCHAR(4)) + '-' + 
                         RIGHT('00000' + CAST(@NextNumber AS VARCHAR), 5);
        
        COMMIT TRANSACTION;
        
        SELECT @PlsNumber AS PlsNumber;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
```

**Action Required:** Create stored procedure

---

### 4. Master Data Inserts

#### 4.1. StatusTypeID 6 (Private Listing)

**Status:** ⏳ **NEEDS INSERT**

**Table:** `MlsListing.dbo.StatusType`

**SQL:**
```sql
-- Check if exists first
IF NOT EXISTS (SELECT 1 FROM MlsListing.dbo.StatusType WHERE StatusTypeID = 6)
BEGIN
    INSERT INTO MlsListing.dbo.StatusType (StatusTypeID, Name, Description)
    VALUES (6, 'Private Listing', 'Private listing (pre-MLS)');
END
GO
```

**Action Required:** Execute INSERT (if not exists)

---

#### 4.2. StatusTypeID 14 (Coming Soon)

**Status:** ✅ **EXISTS** (per blueprint)

**Table:** `MlsListing.dbo.StatusType`

**Action Required:** Verify exists, no action if already present

---

#### 4.3. MlsID 777 (PLS Identifier)

**Status:** ⏳ **NEEDS INSERT** (⚠️ Blueprint says 999, but we changed to 777)

**Table:** `MlsListing.dbo.Mls`

**SQL:**
```sql
-- Check if exists first
IF NOT EXISTS (SELECT 1 FROM MlsListing.dbo.Mls WHERE MlsID = 777)
BEGIN
    INSERT INTO MlsListing.dbo.Mls (MlsID, Name, Description)
    VALUES (777, 'PLS', 'Paisley Listing Service (Private Listing Service)');
END
GO
```

**⚠️ IMPORTANT:** Blueprint references `MlsID = 999`, but v3.0 schema uses `MlsID = 777`. Need to:
1. Update blueprint to reflect 777
2. Verify no existing PLS listings use 999 before changing
3. Execute INSERT for 777

**Action Required:** 
- [ ] Update blueprint references from 999 to 777
- [ ] Execute INSERT for MlsID = 777
- [ ] Verify no existing data uses 999

---

#### 4.4. PropertyCastTypeId 4 (PLS)

**Status:** ⏳ **NEEDS INSERT**

**Table:** `FarmGenie.dbo.PropertyCastType`

**SQL:**
```sql
-- Check if exists first
IF NOT EXISTS (SELECT 1 FROM FarmGenie.dbo.PropertyCastType WHERE PropertyCastTypeId = 4)
BEGIN
    INSERT INTO FarmGenie.dbo.PropertyCastType (PropertyCastTypeId, Name, Description)
    VALUES (4, 'PLS', 'Private Listing Service');
END
GO
```

**Purpose:** Used for Listing Command integration (PropertyCastTypeId=4 workflow)

**Action Required:** Execute INSERT (if not exists)

---

#### 4.5. Permissions (210-214)

**Status:** ⏳ **NEEDS INSERT**

**Table:** `FarmGenie.dbo.Permission` (or `PermissionType` - need to verify table structure)

**Permissions:**

| PermissionID | Name | Description |
|--------------|------|-------------|
| 210 | ManagePLS | Allow user to create and edit PLS listings |
| 211 | Menu PLS | Allows user to view PLS menu |
| 212 | View PLS History | View past PLS listings |
| 213 | PLS Radar | ADMIN - View PLS across all users |
| 214 | PLS Submit While Impersonating | ADMIN - Create PLS for other users |

**SQL (Example - adjust based on actual table structure):**
```sql
-- Check table structure first
-- May need to insert into PermissionType table, then map to users via Permission table

-- Example (adjust based on actual schema):
IF NOT EXISTS (SELECT 1 FROM FarmGenie.dbo.PermissionType WHERE PermissionTypeId = 210)
BEGIN
    INSERT INTO FarmGenie.dbo.PermissionType (PermissionTypeId, Name, Description)
    VALUES 
        (210, 'ManagePLS', 'Allow user to create and edit PLS listings'),
        (211, 'Menu PLS', 'Allows user to view PLS menu'),
        (212, 'View PLS History', 'View past PLS listings'),
        (213, 'PLS Radar', 'ADMIN - View PLS across all users'),
        (214, 'PLS Submit While Impersonating', 'ADMIN - Create PLS for other users');
END
GO
```

**Action Required:** 
- [ ] Verify table structure (Permission vs PermissionType)
- [ ] Execute INSERTs for permissions 210-214

---

### 5. Cross-Database Foreign Key Validation

**Status:** ⚠️ **NEEDS APPLICATION LAYER VALIDATION**

**Issue:** SQL Server doesn't support cross-database foreign keys

**Tables Affected:**
- `pls_tracking.listing_id` → `MlsListing.dbo.Listing(ListingID)`
- `pls_status_log.listing_id` → `MlsListing.dbo.Listing(ListingID)`
- `pls_status_mapping.mls_status_type_id` → `MlsListing.dbo.StatusType(StatusTypeID)`

**Action Required:**
- [ ] Application layer must validate `listing_id` exists before INSERT
- [ ] Consider creating stored procedures that validate cross-database FKs
- [ ] Document validation requirements in application code

---

### 6. Data Type Consistency

**Status:** ⚠️ **NEEDS VERIFICATION**

**Potential Issues:**
- `PlsListingOwnership.AspNetUserId` is `NVARCHAR(128)` but `AspNetUsers.Id` is `NVARCHAR(450)`
- `PlsListingOwnership.MlsId` defaults to `999` but should be `777`
- Date fields: Some use `DATETIME`, some use `DATETIME2(7)` - should standardize

**Action Required:**
- [ ] Verify `AspNetUsers.Id` data type (likely `NVARCHAR(450)` based on ASP.NET Core)
- [ ] Update `PlsListingOwnership.AspNetUserId` to match if needed
- [ ] Standardize date fields to `DATETIME2(7)` for consistency
- [ ] Update `PlsListingOwnership.MlsId` default from 999 to 777

---

### 7. Indexes and Performance

**Status:** ✅ **COMPLETE** (for v3.0 schema)

**Created Indexes:**
- `pls_tracking`: 3 indexes (listing_id, agent_id, status_type)
- `pls_status_log`: 3 indexes (listing_id, changed_by, to_status)
- `pls_status_type`: 1 filtered index (status_code)
- `pls_source_type`: 1 filtered index (source_code)
- `pls_status_mapping`: 2 indexes (status, mls_status)

**Additional Indexes Needed (if PlsListingOwnership created):**
- [ ] `IX_PlsListingOwnership_ListingId` on `ListingId`
- [ ] `IX_PlsListingOwnership_AspNetUserId` on `AspNetUserId`
- [ ] `IX_PlsListingOwnership_MlsNumber` on `MlsNumber` (if queried frequently)

---

### 8. Stored Procedures for Common Operations

**Status:** ⏳ **RECOMMENDED** (not required)

**Suggested Procedures:**

#### 8.1. usp_CreatePlsListing
**Purpose:** Create PLS listing with all related records
- Generate PLS number
- Insert into `MlsListing.dbo.Listing`
- Insert into `pls_tracking`
- Insert into `PlsListingOwnership` (if kept)
- Log initial status

#### 8.2. usp_UpdatePlsStatus
**Purpose:** Update PLS status with audit trail
- Update `pls_tracking.status_type_id`
- Update `MlsListing.dbo.Listing.StatusTypeID` (if published)
- Insert into `pls_status_log`
- Return success/failure

#### 8.3. usp_GetPlsListingDetails
**Purpose:** Get complete PLS listing with all related data
- JOIN `MlsListing.dbo.Listing` with `pls_tracking`
- Include status codes from views
- Include ownership info (if PlsListingOwnership exists)

**Action Required:** Create stored procedures as needed (optional but recommended)

---

## 📋 SUMMARY CHECKLIST

### Critical (Must Have)
- [ ] **PlsListingOwnership** table - CREATE (ownership tracking, separate from pls_tracking)
- [ ] **PlsNumberSequence** table - CREATE
- [ ] **usp_GetNextPlsNumber** stored procedure - CREATE
- [ ] **StatusTypeID 6** (Private Listing) - INSERT
- [ ] **MlsID 777** - INSERT (update blueprint from 999)
- [ ] **PropertyCastTypeId 4** (PLS) - INSERT
- [ ] **Permissions 210-214** - INSERT

### Recommended
- [ ] **Stored procedures** for common operations (optional)
- [ ] **Additional indexes** on PlsListingOwnership (if created)
- [ ] **Data type consistency** check across all tables

### Documentation
- [ ] Update blueprint to reflect MlsID = 777 (not 999)
- [ ] Document cross-database FK validation requirements
- [ ] Document permission model (account-level vs listing-level)

---

## 🎯 NEXT STEPS

1. **Create Missing Objects:**
   - PlsNumberSequence table
   - usp_GetNextPlsNumber stored procedure
   - Master data inserts (StatusType, Mls, PropertyCastType, Permissions)

3. **Update Blueprint:**
   - Change all references from MlsID 999 to 777
   - Update PlsListingOwnership.MlsId default to 777
   - Fix data type inconsistencies

4. **Application Layer:**
   - Document cross-database FK validation requirements
   - Create validation functions/stored procedures

---

**Change Log:**
- **v1.0 (01/05/2026):** Initial checklist created after v3.0 schema completion

