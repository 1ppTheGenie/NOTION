# PLS RESO Engine - Relational Database Schema
**Version:** 1.0  
**Created:** 01/02/2026  
**Last Updated:** 01/02/2026  
**Author:** Cursor AI Agent  
**Purpose:** Complete relational database schema showing all tables, joins, indexes, and relationships for PLS system

---

## 🎯 EXECUTIVE SUMMARY

This document provides a complete relational database schema for the PLS RESO Engine, showing:
- All tables (existing and new)
- Foreign key relationships
- Join paths
- Index tables
- Current database state

---

## 📊 COMPLETE RELATIONAL SCHEMA

### Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FARMGENIE DATABASE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────┐         ┌──────────────────────┐                 │
│  │   AspNetUsers        │         │  AspNetUserProfiles  │                 │
│  │   (PK) Id            │◄────────┤  (FK) AspNetUserId   │                 │
│  │   Email              │  1:1    │  FirstName           │                 │
│  │   UserName           │         │  LastName            │                 │
│  └──────────┬───────────┘         └──────────────────────┘                 │
│             │                                                               │
│             │ 1:N                                                           │
│             ▼                                                               │
│  ┌──────────────────────┐                                                 │
│  │  AspNetUserRoles      │                                                 │
│  │  (FK) UserId          │                                                 │
│  │  (FK) RoleId          │────────────────┐                               │
│  └──────────────────────┘                 │                               │
│                                            │                               │
│                                            ▼                               │
│                                  ┌──────────────────────┐                 │
│                                  │  AspNetRoles         │                 │
│                                  │  (PK) Id             │                 │
│                                  │  Name                │                 │
│                                  └──────────────────────┘                 │
│                                                                              │
│  ┌──────────────────────┐         ┌──────────────────────┐                 │
│  │  UserMarketingProfile│         │  MarketingImage      │                 │
│  │  (FK) AspNetUserId   │◄────────┤  (FK) AspNetUserId   │                 │
│  │  DisplayName         │  1:N    │  (FK) ImageTypeId    │                 │
│  │  MarketingTitle      │         │  ImageUrl            │                 │
│  │  Phone               │         │  DisplayOrder        │                 │
│  │  Website             │         └──────────────────────┘                 │
│  │  CompanyName         │                                                   │
│  │  StreetAddress       │                                                   │
│  │  City, State, Zip     │                                                   │
│  └──────────────────────┘                                                   │
│                                                                              │
│  ┌──────────────────────┐         ┌──────────────────────┐                 │
│  │  PlsListingOwnership │         │  PlsNumberSequence   │                 │
│  │  (PK) PlsListing     │         │  (PK) Year           │                 │
│  │       OwnershipId    │         │  NextNumber          │                 │
│  │  (FK) AspNetUserId   │         │  LastUpdate          │                 │
│  │  (FK) MlsId = 999    │         └──────────────────────┘                 │
│  │  (FK) MlsNumber      │                                                   │
│  │  (FK) ListingId      │────────────────┐                                 │
│  │  OwnershipTypeId    │                 │                                 │
│  │  IsActive            │                 │                                 │
│  └──────────────────────┘                 │                                 │
│                                            │                                 │
│                                            ▼                                 │
│                                  ┌──────────────────────┐                 │
│                                  │  ListingCommandQueue  │                 │
│                                  │  (PK) QueueId        │                 │
│                                  │  (FK) MlsID = 999    │                 │
│                                  │  (FK) MlsNumber      │                 │
│                                  │  (FK) PropertyCast   │                 │
│                                  │       TypeId = 4     │                 │
│                                  │  (FK) AspNetUserId   │                 │
│                                  │  (FK) AreaId         │                 │
│                                  │  ListingJson         │                 │
│                                  └──────────────────────┘                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          MLSLISTING DATABASE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────┐         ┌──────────────────────┐                 │
│  │  Listing             │         │  Photo               │                 │
│  │  (PK) ListingID      │◄────────┤  (FK) ListingID       │                 │
│  │  (FK) MlsID = 999    │  1:N    │  (FK) MlsID = 999    │                 │
│  │  (FK) MlsNumber      │         │  PhotoUrl             │                 │
│  │  (FK) StatusTypeID   │──┐      │  DisplayOrder         │                 │
│  │  (FK) PropertyTypeID │  │      └──────────────────────┘                 │
│  │  DisplayAddress      │  │                                                 │
│  │  StreetNumber        │  │                                                 │
│  │  StreetName          │  │                                                 │
│  │  City, State, Zip    │  │                                                 │
│  │  OriginalListPrice   │  │                                                 │
│  │  Bedrooms            │  │                                                 │
│  │  BathroomsTotal      │  │                                                 │
│  │  BathroomsFull       │  │                                                 │
│  │  BathroomsHalf       │  │                                                 │
│  │  Sqft                │  │                                                 │
│  │  LotSqft             │  │                                                 │
│  │  YearBuilt           │  │                                                 │
│  │  Latitude            │  │                                                 │
│  │  Longitude           │  │                                                 │
│  │  Remarks             │  │                                                 │
│  │  PhotoPrimaryUrl     │  │                                                 │
│  │  ListDate            │  │                                                 │
│  │  MlsCreateDate       │  │                                                 │
│  │  MlsUpdateDate       │  │                                                 │
│  └──────────────────────┘  │                                                 │
│                            │                                                 │
│                            │ N:1                                             │
│                            ▼                                                 │
│                  ┌──────────────────────┐                                   │
│                  │  StatusType           │                                   │
│                  │  (PK) StatusTypeID   │                                   │
│                  │  Name                │                                   │
│                  │  • 6 = Private Listing│                                   │
│                  │  • 14 = Coming Soon   │                                   │
│                  └──────────────────────┘                                   │
│                                                                              │
│  ┌──────────────────────┐                                                   │
│  │  Mls                 │                                                   │
│  │  (PK) MlsID          │                                                   │
│  │  Name                │                                                   │
│  │  DisplayName         │                                                   │
│  │  • 999 = PLS         │                                                   │
│  └──────────────────────┘                                                   │
│                                                                              │
│  ┌──────────────────────┐                                                   │
│  │  PropertyType        │                                                   │
│  │  (PK) PropertyTypeID │                                                   │
│  │  Name                │                                                   │
│  └──────────────────────┘                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           TITLEDATA DATABASE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────┐                                                   │
│  │  AttomDataAssessor   │                                                   │
│  │  (PK) PropertyId     │                                                   │
│  │  ParcelNumberFormatted (JOIN KEY)                                       │
│  │  PropertyAddressHouseNumber                                             │
│  │  PropertyAddressStreetName                                             │
│  │  PropertyAddressCity                                                   │
│  │  PropertyAddressState                                                  │
│  │  PropertyAddressZIP                                                    │
│  │  BedroomsCount                                                          │
│  │  BathCount                                                              │
│  │  AreaBuilding (sqft)                                                    │
│  │  AreaLotSF                                                              │
│  │  YearBuilt                                                              │
│  │  PropertyLatitude                                                       │
│  │  PropertyLongitude                                                      │
│  │  ... (318 total fields)                                                │
│  └──────────────────────┘                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           FARMGENIE DATABASE (CONTINUED)                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────┐         ┌──────────────────────┐                 │
│  │  Area                │         │  PropertyCastType     │                 │
│  │  (PK) AreaId         │         │  (PK) PropertyCast   │                 │
│  │  AreaName            │         │       TypeId          │                 │
│  │  CenterLatitude      │         │  Name                 │                 │
│  │  CenterLongitude     │         │  • 4 = PLS            │                 │
│  └──────────────────────┘         └──────────────────────┘                 │
│                                                                              │
│  ┌──────────────────────┐         ┌──────────────────────┐                 │
│  │  Permission          │         │  RolePermission      │                 │
│  │  (PK) PermissionID   │◄────────┤  (FK) RoleID          │                 │
│  │  Description         │         │  (FK) PermissionID   │                 │
│  │  Notes               │         └──────────────────────┘                 │
│  │  • 210 = ManagePLS   │                                                   │
│  │  • 211 = Menu PLS    │                                                   │
│  │  • 212 = View PLS History│                                              │
│  │  • 213 = PLS Radar   │                                                   │
│  │  • 214 = PLS Submit While Impersonating│                                │
│  └──────────────────────┘                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 JOIN PATHS & QUERIES

### Query 1: Get PLS Listing with Ownership

**Purpose:** Load listing for edit/view

```sql
SELECT 
    l.*,
    st.Name AS StatusName,
    plo.AspNetUserId,
    plo.OwnershipTypeId,
    plo.IsActive AS OwnershipIsActive,
    plo.CreateDate AS OwnershipCreateDate
FROM MlsListing.dbo.Listing l
INNER JOIN MlsListing.dbo.StatusType st 
    ON st.StatusTypeID = l.StatusTypeID
INNER JOIN FarmGenie.dbo.PlsListingOwnership plo
    ON plo.ListingId = l.ListingID
    AND plo.MlsID = l.MlsID
    AND plo.MlsNumber = l.MlsNumber
WHERE l.MlsID = 999
    AND l.MlsNumber = @plsNumber
    AND plo.IsActive = 1
```

**Join Path:**
```
Listing (MlsID=999, MlsNumber)
    ↓ INNER JOIN
StatusType (StatusTypeID)
    ↓ INNER JOIN
PlsListingOwnership (ListingId, MlsID, MlsNumber)
```

### Query 2: Get User's PLS Listings

**Purpose:** List view for "My PLS Listings"

```sql
SELECT 
    plo.MlsNumber AS PlsNumber,
    l.DisplayAddress,
    l.OriginalListPrice,
    st.Name AS StatusName,
    st.StatusTypeID,
    plo.CreateDate,
    l.ListingID
FROM FarmGenie.dbo.PlsListingOwnership plo
INNER JOIN MlsListing.dbo.Listing l 
    ON l.ListingID = plo.ListingId
    AND l.MlsID = plo.MlsId
    AND l.MlsNumber = plo.MlsNumber
INNER JOIN MlsListing.dbo.StatusType st 
    ON st.StatusTypeID = l.StatusTypeID
WHERE plo.AspNetUserId = @userId
    AND plo.IsActive = 1
    AND l.MlsID = 999
ORDER BY plo.CreateDate DESC
```

**Join Path:**
```
PlsListingOwnership (AspNetUserId, IsActive=1)
    ↓ INNER JOIN
Listing (ListingID, MlsID, MlsNumber)
    ↓ INNER JOIN
StatusType (StatusTypeID)
```

### Query 3: Get Listing with Photos for XML Generation

**Purpose:** Build XML for GenieCloud render

```sql
SELECT 
    l.*,
    st.Name AS StatusName,
    pt.Name AS PropertyTypeName,
    -- Photos subquery
    (
        SELECT 
            PhotoUrl,
            DisplayOrder
        FROM MlsListing.dbo.Photo p
        WHERE p.ListingID = l.ListingID
            AND p.MlsID = 999
        ORDER BY p.DisplayOrder ASC
        FOR XML PATH('image'), ROOT('images'), TYPE
    ) AS PhotosXml
FROM MlsListing.dbo.Listing l
INNER JOIN MlsListing.dbo.StatusType st 
    ON st.StatusTypeID = l.StatusTypeID
LEFT JOIN MlsListing.dbo.PropertyType pt 
    ON pt.PropertyTypeID = l.PropertyTypeID
WHERE l.MlsID = 999
    AND l.MlsNumber = @plsNumber
```

**Join Path:**
```
Listing (MlsID=999, MlsNumber)
    ↓ INNER JOIN
StatusType (StatusTypeID)
    ↓ LEFT JOIN
PropertyType (PropertyTypeID)
    ↓ Subquery
Photo (ListingID, MlsID=999)
```

### Query 4: Get Agent Data for XML

**Purpose:** Fetch agent marketing data for XML generation

```sql
SELECT 
    u.Id AS AspNetUserId,
    up.FirstName,
    up.LastName,
    ump.DisplayName AS MarketingName,
    ump.MarketingTitle,
    ump.LicenseNumberDisplay AS MarketingLicense,
    u.Email,
    ump.Phone,
    ump.Website,
    ump.CompanyName,
    ump.StreetAddress,
    ump.City,
    ump.State,
    ump.Zip,
    -- Marketing Images subquery
    (
        SELECT 
            ImageTypeId,
            ImageUrl
        FROM FarmGenie.dbo.MarketingImage mi
        WHERE mi.AspNetUserId = u.Id
            AND mi.IsActive = 1
        FOR XML PATH('image'), ROOT('marketingImages'), TYPE
    ) AS MarketingImagesXml
FROM FarmGenie.dbo.AspNetUsers u
INNER JOIN FarmGenie.dbo.AspNetUserProfiles up 
    ON up.AspNetUserId = u.Id
LEFT JOIN FarmGenie.dbo.UserMarketingProfile ump 
    ON ump.AspNetUserId = u.Id
WHERE u.Id = @userId
```

**Join Path:**
```
AspNetUsers (Id)
    ↓ INNER JOIN
AspNetUserProfiles (AspNetUserId)
    ↓ LEFT JOIN
UserMarketingProfile (AspNetUserId)
    ↓ Subquery
MarketingImage (AspNetUserId, IsActive=1)
```

### Query 5: Pre-Populate from TitleData + Historical MLS

**Purpose:** Fetch property data for pre-population

```sql
-- Step 1: Find TitleData by address or APN
SELECT TOP 1
    a.*
FROM TitleData.dbo.AttomDataAssessor a
WHERE (
    -- Address match
    (a.PropertyAddressHouseNumber = @streetNumber
     AND a.PropertyAddressStreetName LIKE @streetName + '%'
     AND a.PropertyAddressCity = @city
     AND a.PropertyAddressState = @state
     AND a.PropertyAddressZIP = @zip)
    OR
    -- APN match (if provided)
    (a.ParcelNumberFormatted = @apn)
)
ORDER BY a.LastUpdateDate DESC

-- Step 2: Find Historical MLS by address or APN
SELECT TOP 1
    l.*
FROM MlsListing.dbo.Listing l
WHERE l.MlsID != 999  -- Exclude PLS listings
    AND (
        -- Address match
        (l.StreetNumber = @streetNumber
         AND l.StreetName LIKE @streetName + '%'
         AND l.City = @city
         AND l.State = @state
         AND l.Zip = @zip)
        OR
        -- APN match (if available in ExtendedData)
        (l.APN = @apn)
    )
    AND l.StatusTypeID IN (1, 2)  -- Active or Sold
ORDER BY l.MlsUpdateDate DESC
```

**Join Strategy:**
- **Primary:** Address match (StreetNumber + StreetName + City + State + Zip)
- **Fallback:** APN match (ParcelNumberFormatted in TitleData, APN in Listing)

---

## 📋 INDEX TABLES & PERFORMANCE

### Recommended Indexes

#### MlsListing.dbo.Listing

```sql
-- Index for PLS listings lookup
CREATE NONCLUSTERED INDEX IX_Listing_MlsID_MlsNumber 
ON MlsListing.dbo.Listing (MlsID, MlsNumber)
INCLUDE (StatusTypeID, DisplayAddress, OriginalListPrice, ListDate);

-- Index for address lookup (pre-population)
CREATE NONCLUSTERED INDEX IX_Listing_Address 
ON MlsListing.dbo.Listing (StreetNumber, StreetName, City, State, Zip)
INCLUDE (MlsID, StatusTypeID, Sqft, Bedrooms, BathroomsTotal)
WHERE MlsID != 999;  -- Filtered index for historical MLS only

-- Index for StatusTypeID lookup
CREATE NONCLUSTERED INDEX IX_Listing_StatusTypeID 
ON MlsListing.dbo.Listing (StatusTypeID)
INCLUDE (MlsID, MlsNumber, DisplayAddress)
WHERE MlsID = 999;  -- Filtered index for PLS only
```

#### FarmGenie.dbo.PlsListingOwnership

```sql
-- Index for user's listings lookup
CREATE NONCLUSTERED INDEX IX_PlsOwnership_User_Active 
ON FarmGenie.dbo.PlsListingOwnership (AspNetUserId, IsActive)
INCLUDE (MlsNumber, ListingId, CreateDate)
WHERE IsActive = 1;

-- Index for listing lookup
CREATE NONCLUSTERED INDEX IX_PlsOwnership_Listing 
ON FarmGenie.dbo.PlsListingOwnership (ListingId, MlsID, MlsNumber)
INCLUDE (AspNetUserId, IsActive);

-- Unique constraint (already in table definition)
-- CONSTRAINT UQ_PlsOwnership UNIQUE (AspNetUserId, MlsId, MlsNumber)
```

#### MlsListing.dbo.Photo

```sql
-- Index for photos by listing
CREATE NONCLUSTERED INDEX IX_Photo_Listing_Order 
ON MlsListing.dbo.Photo (ListingID, MlsID, DisplayOrder)
INCLUDE (PhotoUrl)
WHERE MlsID = 999;  -- Filtered index for PLS only
```

#### TitleData.dbo.AttomDataAssessor

```sql
-- Index for address lookup
CREATE NONCLUSTERED INDEX IX_Attom_Address 
ON TitleData.dbo.AttomDataAssessor 
(PropertyAddressHouseNumber, PropertyAddressStreetName, PropertyAddressCity, PropertyAddressState, PropertyAddressZIP)
INCLUDE (ParcelNumberFormatted, BedroomsCount, AreaBuilding, YearBuilt);

-- Index for APN lookup
CREATE NONCLUSTERED INDEX IX_Attom_APN 
ON TitleData.dbo.AttomDataAssessor (ParcelNumberFormatted)
INCLUDE (PropertyAddressHouseNumber, PropertyAddressStreetName, PropertyAddressCity);
```

---

## 🔑 FOREIGN KEY RELATIONSHIPS

### PlsListingOwnership Foreign Keys

```sql
-- To AspNetUsers
ALTER TABLE FarmGenie.dbo.PlsListingOwnership
ADD CONSTRAINT FK_PlsOwnership_User 
FOREIGN KEY (AspNetUserId) 
REFERENCES FarmGenie.dbo.AspNetUsers(Id);

-- To Listing (logical FK - no physical constraint due to cross-database)
-- ListingID references MlsListing.dbo.Listing(ListingID)
-- MlsID references MlsListing.dbo.Mls(MlsID)
-- MlsNumber references MlsListing.dbo.Listing(MlsNumber)
```

### Listing Foreign Keys (Existing)

```sql
-- To StatusType
ALTER TABLE MlsListing.dbo.Listing
ADD CONSTRAINT FK_Listing_StatusType 
FOREIGN KEY (StatusTypeID) 
REFERENCES MlsListing.dbo.StatusType(StatusTypeID);

-- To Mls
ALTER TABLE MlsListing.dbo.Listing
ADD CONSTRAINT FK_Listing_Mls 
FOREIGN KEY (MlsID) 
REFERENCES MlsListing.dbo.Mls(MlsID);

-- To PropertyType
ALTER TABLE MlsListing.dbo.Listing
ADD CONSTRAINT FK_Listing_PropertyType 
FOREIGN KEY (PropertyTypeID) 
REFERENCES MlsListing.dbo.PropertyType(PropertyTypeID);
```

### Photo Foreign Keys (Existing)

```sql
-- To Listing
ALTER TABLE MlsListing.dbo.Photo
ADD CONSTRAINT FK_Photo_Listing 
FOREIGN KEY (ListingID) 
REFERENCES MlsListing.dbo.Listing(ListingID);
```

---

## 📊 CURRENT DATABASE STATE

### Existing Tables (No Changes Needed)

| Table | Database | Purpose | PLS Usage |
|-------|----------|---------|-----------|
| `Listing` | MlsListing | Core listing data | ✅ Use with MlsID=999 |
| `Photo` | MlsListing | Listing photos | ✅ Use with MlsID=999 |
| `StatusType` | MlsListing | Status definitions | ✅ Use StatusTypeID 6, 14 |
| `Mls` | MlsListing | MLS source definitions | ⏳ Need INSERT for MlsID=999 |
| `PropertyType` | MlsListing | Property type definitions | ✅ Use existing |
| `AspNetUsers` | FarmGenie | User accounts | ✅ Use existing |
| `AspNetUserProfiles` | FarmGenie | User profile data | ✅ Use existing |
| `UserMarketingProfile` | FarmGenie | Agent marketing data | ✅ Use existing |
| `MarketingImage` | FarmGenie | Agent logos/photos | ✅ Use existing |
| `Area` | FarmGenie | Area/neighborhood data | ✅ Use existing |
| `PropertyCastType` | FarmGenie | Property cast types | ⏳ Need INSERT for ID=4 |
| `ListingCommandQueue` | FarmGenie | Campaign queue | ✅ Use with PropertyCastTypeId=4 |
| `Permission` | FarmGenie | Permission definitions | ⏳ Need INSERT for 210-214 |
| `RolePermission` | FarmGenie | Role-permission mapping | ⏳ Need INSERT for PLS permissions |

### New Tables (Need Creation)

| Table | Database | Purpose | Status |
|-------|----------|---------|--------|
| `PlsListingOwnership` | FarmGenie | User-listing ownership | ⏳ Needs CREATE |
| `PlsNumberSequence` | FarmGenie | PLS number generation | ⏳ Needs CREATE |

### New Stored Procedures (Need Creation)

| Procedure | Database | Purpose | Status |
|-----------|----------|---------|--------|
| `usp_GetNextPlsNumber` | FarmGenie | Generate PLS-YYYY-NNNNN | ⏳ Needs CREATE |

### Master Data Inserts (Need Execution)

| Type | ID | Name | Table | Status |
|------|----|----|-------|--------|
| StatusType | 6 | Private Listing | MlsListing.dbo.StatusType | ⏳ Needs INSERT |
| StatusType | 14 | Coming Soon | MlsListing.dbo.StatusType | ✅ Exists |
| Mls | 999 | PLS | MlsListing.dbo.Mls | ⏳ Needs INSERT |
| PropertyCastType | 4 | PLS | FarmGenie.dbo.PropertyCastType | ⏳ Needs INSERT |
| Permission | 210 | ManagePLS | FarmGenie.dbo.Permission | ⏳ Needs INSERT |
| Permission | 211 | Menu PLS | FarmGenie.dbo.Permission | ⏳ Needs INSERT |
| Permission | 212 | View PLS History | FarmGenie.dbo.Permission | ⏳ Needs INSERT |
| Permission | 213 | PLS Radar | FarmGenie.dbo.Permission | ⏳ Needs INSERT |
| Permission | 214 | PLS Submit While Impersonating | FarmGenie.dbo.Permission | ⏳ Needs INSERT |

---

## 🔍 DATA INTEGRITY RULES

### Business Rules

1. **PLS Number Uniqueness:** `(AspNetUserId, MlsId, MlsNumber)` must be unique in `PlsListingOwnership`
2. **Ownership Validation:** Users can only edit/delete their own listings (unless admin)
3. **Status Validation:** PLS listings must use StatusTypeID 6 or 14
4. **MlsID Validation:** PLS listings must use MlsID 999
5. **Photo Ordering:** Photos must have unique DisplayOrder per listing

### Constraints

```sql
-- PlsListingOwnership unique constraint
CONSTRAINT UQ_PlsOwnership UNIQUE (AspNetUserId, MlsId, MlsNumber)

-- PlsNumberSequence primary key
PRIMARY KEY (Year)

-- Listing check constraint (if needed)
ALTER TABLE MlsListing.dbo.Listing
ADD CONSTRAINT CK_Listing_PLS_Status 
CHECK (
    (MlsID != 999) OR 
    (MlsID = 999 AND StatusTypeID IN (6, 14))
);
```

---

## 📝 REFERENCE DOCUMENTS

- **Database Implementation Spec:** `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`
- **Field Mapping:** `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`

---

**Status:** ✅ Schema Complete - Ready for DBA Review

**Next Action:** DBA reviews schema, creates indexes, executes scripts.

