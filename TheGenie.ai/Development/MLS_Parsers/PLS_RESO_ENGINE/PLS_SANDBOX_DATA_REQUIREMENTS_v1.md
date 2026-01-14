# PLS Sandbox Data Requirements
**Version:** 1.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Identify data needed to populate sandbox databases for PLS development

---

## ✅ SANDBOX STATUS

**Schema Structure:** ✅ Complete
- FarmGenie_Sandbox: 359 tables (empty)
- MlsListing_Sandbox: 118 tables (empty)
- TitleData_Sandbox: 148 tables (empty)

**Next Step:** Fetch reference data needed for PLS development

---

## 📋 DATA REQUIRED FOR PLS DEVELOPMENT

### 1. Master Data (Lookup Tables) - CRITICAL

#### FarmGenie_Sandbox

**A. PropertyCastType**
- **Need:** PropertyCastTypeId = 4 (PLS)
- **Source:** Production `FarmGenie.dbo.PropertyCastType`
- **Query:**
```sql
SELECT PropertyCastTypeId, Name, Description
FROM FarmGenie.dbo.PropertyCastType
WHERE PropertyCastTypeId = 4;
```
- **Action:** INSERT into FarmGenie_Sandbox if exists in production, otherwise create via master data script

**B. PermissionType**
- **Need:** PermissionTypeIDs 210-214 (PLS permissions)
- **Source:** Production `FarmGenie.dbo.PermissionType`
- **Query:**
```sql
SELECT PermissionTypeId, Name, Description
FROM FarmGenie.dbo.PermissionType
WHERE PermissionTypeId BETWEEN 210 AND 214;
```
- **Action:** INSERT into FarmGenie_Sandbox if exists in production, otherwise create via master data script

**C. AspNetUsers (Sample Users)**
- **Need:** 5-10 sample users for testing
- **Source:** Production `FarmGenie.dbo.AspNetUsers`
- **Query:**
```sql
SELECT TOP 10 Id, Email, UserName, EmailConfirmed
FROM FarmGenie.dbo.AspNetUsers
WHERE EmailConfirmed = 1
ORDER BY Id;
```
- **Action:** Copy sample users for testing PLS ownership and permissions

**D. Permission (Sample Permissions)**
- **Need:** Sample permission records for test users
- **Source:** Production `FarmGenie.dbo.Permission`
- **Query:**
```sql
SELECT TOP 20 PermissionId, UserId, PermissionTypeId
FROM FarmGenie.dbo.Permission
WHERE PermissionTypeId BETWEEN 210 AND 214;
```
- **Action:** Copy permissions for test users (adjust UserId to match sandbox users)

---

#### MlsListing_Sandbox

**A. StatusType**
- **Need:** StatusTypeID 6 (Private Listing) and 14 (Coming Soon)
- **Source:** Production `MlsListing.dbo.StatusType`
- **Query:**
```sql
SELECT StatusTypeID, Name, Description
FROM MlsListing.dbo.StatusType
WHERE StatusTypeID IN (6, 14);
```
- **Action:** INSERT into MlsListing_Sandbox (StatusTypeID 6 may not exist, needs INSERT)

**B. Mls**
- **Need:** MlsID 777 (PLS identifier)
- **Source:** Production `MlsListing.dbo.Mls`
- **Query:**
```sql
SELECT MlsID, Name, Description
FROM MlsListing.dbo.Mls
WHERE MlsID = 777;
```
- **Action:** INSERT into MlsListing_Sandbox (MlsID 777 may not exist, needs INSERT)

**C. Listing (Historical MLS Data - Sample)**
- **Need:** 50-100 sample historical listings for pre-population testing
- **Source:** Production `MlsListing.dbo.Listing`
- **Query:**
```sql
SELECT TOP 100 
    ListingID, MlsNumber, DisplayAddress, StreetNumber, StreetName, 
    City, State, Zip, APN, OriginalListPrice, SalePrice,
    Bedrooms, BathroomsTotal, Sqft, YearBuilt, LotSqft,
    ListDate, SoldDate, StatusTypeID, MlsID
FROM MlsListing.dbo.Listing
WHERE StatusTypeID IN (1, 2, 4)  -- Active, Sold, Pending
    AND MlsID != 777  -- Exclude any existing PLS listings
    AND APN IS NOT NULL  -- Need APN for TitleData join
ORDER BY ListDate DESC;
```
- **Action:** Copy sample listings for testing pre-population logic

**D. Photo (Sample Photos)**
- **Need:** Sample photos for test listings
- **Source:** Production `MlsListing.dbo.Photo`
- **Query:**
```sql
SELECT TOP 200 
    PhotoID, ListingID, PhotoUrl, DisplayOrder, IsPrimary
FROM MlsListing.dbo.Photo
WHERE ListingID IN (
    -- Use ListingIDs from sample listings above
    SELECT TOP 100 ListingID FROM MlsListing.dbo.Listing 
    WHERE StatusTypeID IN (1, 2, 4) AND APN IS NOT NULL
    ORDER BY ListDate DESC
);
```
- **Action:** Copy photos for test listings

---

#### TitleData_Sandbox

**A. AttomDataAssessor (Property Data - Sample)**
- **Need:** 50-100 sample property records matching test listings
- **Source:** Production `TitleData.dbo.AttomDataAssessor`
- **Query:**
```sql
SELECT TOP 100 
    AttomId, ParcelNumberFormatted, PropertyAddressHouseNumber,
    PropertyAddressStreetName, PropertyAddressCity, PropertyAddressState,
    PropertyAddressZIP, YearBuilt, Bedrooms, BathCount, AreaBuilding,
    LotSizeSquareFeet, Latitude, Longitude
FROM TitleData.dbo.AttomDataAssessor
WHERE ParcelNumberFormatted IN (
    -- Match APNs from sample listings
    SELECT DISTINCT APN FROM MlsListing.dbo.Listing
    WHERE APN IS NOT NULL
    ORDER BY ListDate DESC
    OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY
);
```
- **Action:** Copy property data for pre-population testing

**B. AttomDataAssessor (Full Field Set - Optional)**
- **Need:** Full 318 fields for a few test properties (if needed for complete testing)
- **Source:** Production `TitleData.dbo.AttomDataAssessor`
- **Action:** Copy full records for 5-10 test properties

---

## 📊 DATA FETCH PRIORITY

### Priority 1: Master Data (Required for Schema)
1. ✅ **StatusType** (StatusTypeID 6, 14) - MlsListing_Sandbox
2. ✅ **Mls** (MlsID 777) - MlsListing_Sandbox
3. ✅ **PropertyCastType** (PropertyCastTypeId 4) - FarmGenie_Sandbox
4. ✅ **PermissionType** (PermissionTypeIDs 210-214) - FarmGenie_Sandbox

### Priority 2: Test Users & Permissions
5. ✅ **AspNetUsers** (5-10 sample users) - FarmGenie_Sandbox
6. ✅ **Permission** (sample permissions for test users) - FarmGenie_Sandbox

### Priority 3: Reference Data for Pre-Population Testing
7. ✅ **Listing** (50-100 historical listings) - MlsListing_Sandbox
8. ✅ **Photo** (photos for test listings) - MlsListing_Sandbox
9. ✅ **AttomDataAssessor** (matching property data) - TitleData_Sandbox

---

## 🔧 DATA FETCH QUERIES

### Complete Fetch Script

**File:** `PLS_SANDBOX_DATA_FETCH_v1.sql`

**Contents:**
- All queries above combined
- INSERT statements for sandbox databases
- Foreign key handling (ensure referential integrity)
- Data validation

---

## 📝 NOTES

1. **APN Matching:** Ensure AttomDataAssessor records match Listing APNs for pre-population testing
2. **User IDs:** When copying AspNetUsers, may need to update Permission.UserId to match new sandbox user IDs
3. **Photo URLs:** Photo URLs may point to production S3 - may need to update or use test URLs
4. **Data Volume:** Start with 50-100 listings, can expand later if needed
5. **Master Data:** Some master data may not exist in production (StatusTypeID 6, MlsID 777) - use master data script instead

---

## 🎯 NEXT STEPS

1. **Create Fetch Script:** `PLS_SANDBOX_DATA_FETCH_v1.sql`
2. **Execute Master Data Inserts:** Run `PLS_DATABASE_MASTER_DATA_v3.sql` first
3. **Execute Data Fetch:** Run fetch script to populate reference data
4. **Verify Data:** Check row counts and relationships
5. **Create PLS Tables:** Execute PLS schema scripts
6. **Test PLS Number Generation:** Verify `usp_GetNextPlsNumber` works

---

**Change Log:**
- **v1.0 (01/05/2026):** Initial data requirements document created

