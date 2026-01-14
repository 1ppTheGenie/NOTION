# TitleData to MlsListing Field Mapping Analysis
**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Purpose:** Deep dive into TitleData (Attom) schema to verify what fields map to MlsListing and determine data population strategy for PLS

---

## 🎯 PURPOSE

This document provides a comprehensive field-by-field mapping analysis between:
- **TitleData.dbo.AttomDataAssessor** (318 fields) - Property data from Attom
- **MlsListing.dbo.Listing** (93 fields) - MLS listing structure

**Goal:** Determine which fields can be pre-populated from TitleData vs historical MLS data, identify data quality issues (e.g., square footage mismatches), and establish the data population strategy for PLS.

---

## 📊 FIELD MAPPING TABLE

### Address Fields

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| `StreetNumber` | `PropertyAddressHouseNumber` | ✅ Direct | May need formatting |
| `StreetName` | `PropertyAddressStreetName` | ✅ Direct | Includes direction/suffix in TitleData |
| `UnitNumber` | `PropertyAddressUnitValue` | ✅ Direct | May need prefix concatenation |
| `City` | `PropertyAddressCity` | ✅ Direct | |
| `State` | `PropertyAddressState` | ✅ Direct | 2-char code |
| `Zip` | `PropertyAddressZIP` | ✅ Direct | 5-char code |
| `County` | `SitusCounty` | ✅ Direct | |
| `DisplayAddress` | `PropertyAddressFull` | ⚠️ Derived | Need to construct from components |

**Join Key:** `APN` (MlsListing) = `ParcelNumberFormatted` (TitleData) OR address match

---

### Property Characteristics

| MlsListing Field | TitleData Field | Match Type | Data Quality Notes |
|------------------|-----------------|------------|----------------|
| `YearBuilt` | `YearBuilt` | ✅ Direct | May differ from `YearBuiltEffective` |
| `Sqft` | `AreaBuilding` | ⚠️ **CONFLICT RISK** | **CRITICAL:** MLS may have updated sqft (expansions), TitleData has original builder sqft |
| `LotSqft` | `AreaLotSF` | ✅ Direct | Decimal in TitleData, int in MLS |
| `Acres` | `AreaLotAcres` | ✅ Direct | |
| `Bedrooms` | `BedroomsCount` | ✅ Direct | |
| `BathroomsFull` | `BathCount` | ⚠️ Partial | TitleData has `BathCount` (decimal), may need to split full/half |
| `BathroomsHalf` | `BathPartialCount` | ✅ Direct | |
| `BathroomsTotal` | `BathCount` | ✅ Direct | Decimal calculation |
| `ParkingSpaces` | `ParkingSpaceCount` | ✅ Direct | |
| `GarageSpaces` | `ParkingGarage` | ⚠️ Parse | TitleData is varchar(3), may need parsing |
| `StoriesCount` | `StoriesCount` | ✅ Direct | smallint in TitleData |

**⚠️ CRITICAL DATA QUALITY ISSUE - Square Footage:**
- **TitleData:** `AreaBuilding` = Original builder sqft (may be outdated)
- **MLS Historical:** `Sqft` = Current sqft (includes permitted expansions)
- **Resolution Strategy:** 
  - Compare TitleData vs Historical MLS
  - If mismatch detected: Use MLS value (more current)
  - Flag with asterisk (*) in UI for agent review
  - Add to listing change log: "Sqft updated from TitleData (X) to MLS historical (Y) - expansion detected"

---

### Location & Geography

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| `Latitude` | `PropertyLatitude` | ✅ Direct | float in TitleData, decimal in MLS |
| `Longitude` | `PropertyLongitude` | ✅ Direct | float in TitleData, decimal in MLS |
| `Geocode` | `PropertyLatitude` + `PropertyLongitude` | ⚠️ Derived | Need to construct geography type |
| `GeocodeAccuracyID` | `GeoQuality` | ⚠️ Map | TitleData has varchar(20), need lookup table |
| `Subdivision` | `LegalSubdivision` | ⚠️ Partial | May need additional sources |
| `APN` | `ParcelNumberFormatted` | ✅ **PRIMARY JOIN KEY** | |
| `TractCode` | `CensusTract` | ✅ Direct | int in TitleData |

---

### Property Type & Status

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| `PropertyTypeID` | `PropertyUseStandardized` | ⚠️ Map | TitleData has varchar(4), need lookup to PropertyType table |
| `PropertyUseMuni` | ⚠️ Additional | Municipal use code (varchar(10)) |
| `PropertyUseGroup` | ⚠️ Additional | Property use group (varchar(50)) |

**Mapping Required:**
- TitleData `PropertyUseStandardized` → MlsListing `PropertyTypeID`
- Need to create/verify lookup table

---

### Tax & Assessment Data

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| N/A | `TaxAssessedValueTotal` | ℹ️ Reference | Not in MLS, but useful for AVM |
| N/A | `TaxMarketValueTotal` | ℹ️ Reference | Not in MLS, but useful for AVM |
| N/A | `TaxYearAssessed` | ℹ️ Reference | Assessment year |
| N/A | `TaxBilledAmount` | ℹ️ Reference | Annual tax amount |

**Note:** Tax data not in MLS structure, but valuable for property research and AVM calculations.

---

### Sale History

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| N/A | `AssessorLastSaleDate` | ℹ️ Reference | Last sale per assessor |
| N/A | `AssessorLastSaleAmount` | ℹ️ Reference | Last sale price per assessor |
| N/A | `DeedLastSaleDate` | ℹ️ Reference | Last sale per deed records |
| N/A | `DeedLastSalePrice` | ℹ️ Reference | Last sale price per deed |
| `SoldDate` | Historical MLS only | ❌ Not in TitleData | Must come from historical MLS data |

**Note:** Sale history in TitleData is from assessor/deed records, not MLS. Historical MLS data provides actual MLS sale dates and prices.

---

### Building Details

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| N/A | `RoomsCount` | ℹ️ Reference | Total room count |
| N/A | `UnitsCount` | ℹ️ Reference | Multi-unit count |
| N/A | `Foundation` | ℹ️ Reference | Foundation type (varchar(3)) |
| N/A | `Construction` | ℹ️ Reference | Construction type (varchar(3)) |
| N/A | `RoofMaterial` | ℹ️ Reference | Roof material (varchar(3)) |
| N/A | `HVACHeatingDetail` | ℹ️ Reference | Heating system |
| N/A | `HVACCoolingDetail` | ℹ️ Reference | Cooling system |
| N/A | `FireplaceCount` | ℹ️ Reference | Number of fireplaces |

**Note:** Many building details in TitleData not in MLS structure. These are valuable for property research but not required for MLS listing.

---

### School Data

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| `SchoolDistrict` | N/A | ❌ Not in TitleData | Must come from other source |
| `SchoolElementary` | N/A | ❌ Not in TitleData | Must come from other source |
| `SchoolMiddle` | N/A | ❌ Not in TitleData | Must come from other source |
| `SchoolHigh` | N/A | ❌ Not in TitleData | Must come from other source |

**Note:** School data not in TitleData. Must come from:
- Historical MLS data (if property was listed before)
- External API (if available)
- Manual entry

---

### Agent & Broker Data

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| `ListingAgentName` | N/A | ❌ Not in TitleData | PLS: Current user |
| `ListingAgentID` | N/A | ❌ Not in TitleData | PLS: Current user ID |
| `ListingBrokerName` | N/A | ❌ Not in TitleData | PLS: User's broker |
| `ListingBrokerID` | N/A | ❌ Not in TitleData | PLS: User's broker ID |

**Note:** Agent/broker data comes from current PLS user context, not TitleData or historical MLS.

---

### Photos & Media

| MlsListing Field | TitleData Field | Match Type | Notes |
|------------------|-----------------|------------|-------|
| `PhotoPrimaryUrl` | N/A | ❌ Not in TitleData | **CRITICAL:** Photos cannot be fetched (violation) |
| `PhotoCount` | N/A | ❌ Not in TitleData | User must upload |
| `VirtualTourUrl` | N/A | ❌ Not in TitleData | User must provide |

**⚠️ CRITICAL RESTRICTION:** Photos cannot be fetched from TitleData or historical MLS (copyright violation). User must upload photos.

---

## 🔗 JOIN STRATEGY

### Primary Join: APN (Parcel Number)

**Best Match:**
- `MlsListing.dbo.Listing.APN` = `TitleData.dbo.AttomDataAssessor.ParcelNumberFormatted`

**Fallback Join: Address Match**
- If APN not available, match on:
  - `StreetNumber` + `StreetName` + `City` + `State` + `Zip`

**Property ID Mapping:**
- TitleData: `AttomId` (int) - Unique Attom property ID
- MLS: No direct property ID (uses MlsID + MlsNumber composite key)
- **Note:** Property IDs come from TitleData, not MLS. MLS numbers are unique per MLS, not per property.

---

## 📈 DATA POPULATION STRATEGY

### Step 1: User Enters Property Address
- System searches TitleData by address
- If found: Pre-populate from TitleData
- If not found: User enters manually

### Step 2: Fetch TitleData
- Join on APN or address
- Pre-populate all matching fields
- Flag fields that may conflict with historical MLS

### Step 3: Fetch Historical MLS Data
- Search historical MLS listings by APN or address
- Compare TitleData vs Historical MLS values
- **Square Footage Conflict Resolution:**
  - If TitleData sqft ≠ Historical MLS sqft:
    - Use Historical MLS sqft (more current)
    - Flag with asterisk (*) in UI
    - Add note: "Sqft updated from TitleData (X) to MLS historical (Y) - expansion detected"

### Step 4: Paisley AI Pre-population
- Use TitleData + Historical MLS data
- Generate listing description (ChatStartTypeId=3)
- Agent can edit description

### Step 5: User Review & Edit
- User reviews pre-populated data
- Edits any fields (especially flagged conflicts)
- Uploads photos (cannot be fetched)
- Selects status (Coming Soon vs Private Listing)

---

## ⚠️ DATA QUALITY FLAGS

### Fields That May Conflict

| Field | Conflict Type | Resolution |
|-------|---------------|------------|
| `Sqft` | TitleData = original, MLS = updated | Use MLS, flag with asterisk |
| `YearBuilt` | TitleData vs `YearBuiltEffective` | Use `YearBuiltEffective` if available |
| `BathroomsFull` | TitleData `BathCount` may include partial | Parse carefully, verify with historical MLS |

### Fields Requiring Manual Entry

| Field | Reason |
|-------|--------|
| `PhotoPrimaryUrl` | Copyright violation to fetch |
| `PhotoCount` | User must upload |
| `Remarks` | Paisley AI generates, but user edits |
| `ListingAgentName` | Current PLS user |
| `SchoolDistrict` | Not in TitleData |
| `SchoolElementary` | Not in TitleData |
| `SchoolMiddle` | Not in TitleData |
| `SchoolHigh` | Not in TitleData |

---

## 📋 GAP ANALYSIS

### Fields in MlsListing NOT in TitleData

1. **Agent/Broker Fields** - Not applicable (PLS user context)
2. **School Fields** - Need external source or historical MLS
3. **Photo Fields** - User upload required
4. **MLS-Specific Fields:**
   - `MlsNumber` - PLS generates
   - `MlsID` - PLS identifier (TBD)
   - `StatusTypeID` - User selects
   - `ListDate` - Current date
   - `MlsUpdateDate` - Current date
   - `MlsCreateDate` - Current date

### Fields in TitleData NOT in MlsListing

Many detailed property characteristics (318 fields in TitleData vs 93 in MLS):
- Tax assessment data
- Detailed room counts
- Building materials
- HVAC details
- Owner information
- Deed information

**Note:** These are valuable for property research but not required for MLS listing structure.

---

## 🎯 RECOMMENDATIONS

### 1. Pre-population Priority

**High Priority (Always Pre-populate):**
- Address fields (StreetNumber, StreetName, City, State, Zip, County)
- Property characteristics (YearBuilt, Bedrooms, Bathrooms, LotSqft, Acres)
- Location (Latitude, Longitude, APN)
- Property type (with mapping)

**Medium Priority (Pre-populate with Verification):**
- Square footage (compare TitleData vs Historical MLS, flag conflicts)
- Garage spaces (parse from TitleData)
- Stories count

**Low Priority (Optional Pre-population):**
- Tax data (reference only, not in MLS)
- Building details (reference only, not in MLS)

### 2. Data Quality Handling

- **Square Footage Conflicts:** Always use Historical MLS if available, flag with asterisk
- **Missing Data:** Leave blank, allow user to enter
- **Invalid Data:** Validate and prompt user for correction

### 3. Historical MLS Integration

- Search by APN first (most reliable)
- Fallback to address match
- Compare all overlapping fields
- Use most current data (MLS > TitleData for sqft)

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/30/2025 | Initial field mapping analysis created |

---

**Location:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\PLS_RESO_ENGINE\`

