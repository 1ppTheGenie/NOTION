# PLS Detailed Workflow Steps
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** ✅ Complete Workflow Specification

## Overview

Complete detailed workflow steps for PLS listing creation, following patterns from Listing Command and Neighborhood Command services. PLS is a **NEW SERVICE** integrated into the permission system.

## Complete Workflow (Step-by-Step)

### Phase 1: Entry Point - Paisley Pre-Listing Focus

#### Step 1: User Navigation & Permission Check
**Action:** User navigates to "Pre-Listing" menu  
**UI:** Main navigation menu  
**Permission Check:** `[SmartAuthorize(PermissionType.MenuPLS)]` (Permission 211)  
**System:** Verifies user has Permission 211 (Menu PLS)  
**If No Permission:** User sees "Access Denied" or menu item hidden

**Database Query:**
```sql
SELECT COUNT(*)
FROM FarmGenie.dbo.Permission p
INNER JOIN dbo.PermissionType pt ON pt.PermissionTypeId = p.PermissionTypeId
WHERE p.UserId = @AspNetUserId
  AND pt.PermissionTypeId = 211  -- Menu PLS
```

#### Step 2: Address Autocomplete
**Action:** User types address (minimum 4 characters)  
**UI:** Address input field with autocomplete dropdown  
**API:** `POST /api/Data/AutoCompleteAddress`  
**Backend:** `AgentDashboardManager.AutocompleteAddress()` (existing Paisley service)  
**Debounce:** 600ms delay  
**Response:** List of address suggestions with PlaceKey

**Request:**
```json
{
  "AspNetUserId": "",
  "AddressKey": "10037 Rebecca Place",
  "BiasLatitude": null,
  "BiasLongitude": null,
  "SessionToken": null
}
```

**Response:**
```json
{
  "Success": true,
  "Addresses": [
    {
      "FullAddress": "10037 Rebecca Place, Boerne, TX 78006",
      "Address": "10037 Rebecca Place",
      "PlaceKey": "ChIJ...",
      "Key": "ChIJ..."
    }
  ]
}
```

#### Step 3: Address Selection
**Action:** User selects address from dropdown  
**UI:** Autocomplete dropdown closes, address populated  
**System:** Triggers property details lookup

#### Step 4: Property Details Retrieval
**Action:** System automatically calls property details API  
**API:** `POST /api/Data/GetPropertiesFromPlaceKey`  
**Backend Process:**
1. Google Places Details API → Get address components and coordinates
2. TitleData lookup → Query `TitleData.dbo.AttomDataAssessor` by address/coordinates
3. Historical MLS lookup → Query `MlsListing.dbo.Listing` for conflicts
4. Conflict detection → Compare TitleData vs Historical MLS values

**Request:**
```json
{
  "AspNetUserId": "",
  "PlaceKey": "ChIJ..."
}
```

**Response:**
```json
{
  "Success": true,
  "Properties": [{
    "StreetNumber": "10037",
    "StreetName": "Rebecca Place",
    "City": "Boerne",
    "State": "TX",
    "Zip": "78006",
    "Latitude": 29.72229,
    "Longitude": -98.68958,
    "Bedrooms": 4,
    "BathroomsFull": 3,
    "Sqft": 3018,
    "LotSqft": 9101,
    "YearBuilt": 2022,
    "HasSqftConflict": false,
    "HistoricalMlsSqft": null
  }]
}
```

#### Step 5: Area Auto-Fetch
**Action:** System automatically fetches areas based on selected city  
**API:** `POST /api/Data/GetAreaList`  
**Backend:** `DashboardAutoCompleteManager.GetAreas()` (existing Paisley service)  
**Trigger:** After property details retrieved (city available)

**Request:**
```json
{
  "AspNetUserId": "",
  "AreaTypes": [],
  "SearchKey": "Boerne"
}
```

**Response:**
```json
{
  "ResponseCode": 0,
  "ResponseDescription": "Success",
  "Areas": [
    {
      "AreaId": 407559,
      "AreaName": "Balcones Creek",
      "AreaType": "Neighborhood",
      "OriginalAreaName": "Balcones Creek",
      "AreaApnCount": 0
    }
  ]
}
```

#### Step 6: Area Selection
**Action:** User selects area/neighborhood  
**UI:** Area dropdown (desktop) or drawer (mobile)  
**System:** Stores AreaId for Listing Command integration  
**Critical:** Area selection is required for Listing Command circle prospecting

### Phase 2: Property Pre-Population & Review

#### Step 7: Form Pre-Population
**Action:** System pre-populates property form  
**Data Sources:**
- TitleData (AttomDataAssessor) - Primary source
- Historical MLS - Conflict detection
- Google Places - Address components

**Pre-Populated Fields:**
- Street Number, Street Name, City, State, Zip
- Bedrooms, Bathrooms Full, Bathrooms Half
- Square Feet, Lot Size
- Year Built, Property Type
- Garage Spaces, Parking Spaces
- Latitude, Longitude

#### Step 8: Conflict Detection & Resolution
**Action:** System flags conflicts, user reviews  
**Conflict Detection:**
- Compare TitleData sqft vs Historical MLS sqft
- Compare TitleData beds/baths vs Historical MLS
- Flag with asterisk (*) in UI
- Show recommended value (usually Historical MLS if different)

**UI Display:**
```
Sqft: 2500* (TitleData) vs 3018 (Historical MLS)
Reason: MLS value includes permitted expansion
Recommended: 3018 (use MLS value)
```

**User Action:** User selects preferred value or keeps pre-populated

### Phase 3: Auto-Generated Content (v1.12 Workflow)

#### Step 9: Mapbox Photo Auto-Generation
**Action:** System automatically generates satellite photo  
**Trigger:** After property pre-population (coordinates available)  
**API:** `POST /api/pls/generate-mapbox-photo`  
**Backend:** Mapbox Static Images API  
**Features:**
- Property boundary overlay
- Clearest closed view of best angle
- Zoom level 18-20 (close view)
- Calculated bearing and pitch for best angle

**Request:**
```json
{
  "Latitude": 29.72229,
  "Longitude": -98.68958,
  "Address": "10037 Rebecca Place, Boerne, TX 78006"
}
```

**Response:**
```json
{
  "Success": true,
  "PhotoUrl": "https://genie-cloud.s3.us-west-1.amazonaws.com/genie-pages/pls100001a/photos/mapbox-satellite.jpg"
}
```

**Database:** Photo stored as DisplayOrder=1, PhotoSource='Mapbox'

#### Step 10: Paisley Description Auto-Generation
**Action:** System automatically generates property description  
**Trigger:** After property pre-population (listing data + area data available)  
**API:** `POST /api/pls/generate-description`  
**Backend:** Paisley AI Chat Service  
**ChatStartTypeId:** 3 (Pre-Listing Focused)  
**Data Passed:**
- Listing Data (property details from TitleData/MLS)
- Area Data (selected area for market context)

**Request:**
```json
{
  "AspNetUserId": "",
  "PropertyAddress": "10037 Rebecca Place, Boerne, TX 78006",
  "ListingData": {
    "Bedrooms": 4,
    "BathroomsFull": 3,
    "Sqft": 3018,
    "YearBuilt": 2022,
    "PropertyType": "Single Family"
  },
  "AreaData": {
    "AreaId": 407559,
    "AreaName": "Balcones Creek"
  }
}
```

**Response:**
```json
{
  "Success": true,
  "Description": "Welcome to this stunning 2022-built home in the desirable Balcones Creek neighborhood..."
}
```

#### Step 11: Combined UI Display
**Action:** System displays auto-generated content on same page  
**UI Elements:**
- **Mapbox satellite photo** (displayed, with property boundary overlay)
- **Paisley-generated description** (displayed in textarea, with "Edit" button only)
- **"Load Photos" button** (optional - opens photo upload component)

**User Actions:**
- Can edit description (click "Edit Description" button)
- Can upload additional photos (click "Load Photos" button)
- Additional photos stored as DisplayOrder=2, 3, etc. (up to RESO DB limit)

### Phase 4: Listing Creation

#### Step 12: Form Completion
**Action:** User completes remaining form fields  
**Required Fields:**
- Original List Price
- Status Selection (Coming Soon=14 or Private=6)
- Optional: Additional photos

**Status Options:**
- **Coming Soon** (StatusTypeID=14) - Property will be listed soon
- **Private Listing** (StatusTypeID=6) - Active private listing

#### Step 13: Save & Generate Content Kit
**Action:** User clicks "Save & Generate Content Kit" button  
**Permission Check:** `[SmartAuthorize(PermissionType.ManagePLS)]` (Permission 210)  
**System:** Verifies user has Permission 210 (ManagePLS)

**If No Permission:**
- Return 403 Forbidden
- Show error: "You do not have permission to create PLS listings. Contact your administrator."

#### Step 14: Stored Procedure Call
**Action:** System calls `usp_CreatePlsListing` stored procedure  
**Pattern:** Following Listing Command stored procedure pattern

**Stored Procedure Steps:**
1. **Generate PLS Number:**
   ```sql
   EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNumber OUTPUT
   -- Returns: PLS100001A (format: PLS{6-digit}{letter})
   ```

2. **Get Agent Information:**
   ```sql
   SELECT u.Id, up.FirstName, up.LastName, ump.DisplayName
   FROM AspNetUsers u
   LEFT JOIN AspNetUserProfiles up ON up.AspNetUserId = u.Id
   LEFT JOIN UserMarketingProfile ump ON ump.AspNetUserId = u.Id
   WHERE u.Id = @AspNetUserId
   ```

3. **Get Lookup IDs:**
   ```sql
   SELECT source_type_id FROM pls_source_type WHERE source_code = 'paisley'
   SELECT status_type_id FROM pls_status_type WHERE status_code = 'draft' (or 'active'/'coming_soon')
   ```

4. **INSERT into MlsListing.dbo.Listing:**
   ```sql
   INSERT INTO MlsListing.dbo.Listing (
       MlsID,              -- 777
       MlsNumber,          -- PLS100001A
       StatusTypeID,       -- 6 or 14
       PropertyCastTypeId, -- 4 (PLS)
       DisplayAddress, StreetNumber, StreetName, City, State, Zip,
       OriginalListPrice, Bedrooms, BathroomsTotal, BathroomsFull, BathroomsHalf,
       Sqft, LotSqft, YearBuilt, Latitude, Longitude, Remarks,
       ListingAgentName, ListingAgentID,
       ListDate, MlsCreateDate
   )
   VALUES (...)
   ```

5. **INSERT Mapbox Photo:**
   ```sql
   INSERT INTO MlsListing.dbo.Photo (ListingID, MlsID, PhotoUrl, DisplayOrder)
   VALUES (@ListingID, 777, @MapboxPhotoUrl, 1)
   ```

6. **INSERT into pls_tracking:**
   ```sql
   INSERT INTO FarmGenie.dbo.pls_tracking (
       listing_id, agent_id, source_type_id, status_type_id
   )
   VALUES (@ListingID, @AspNetUserId, @SourceTypeID, @StatusTypeID)
   ```

7. **INSERT into pls_status_log:**
   ```sql
   INSERT INTO FarmGenie.dbo.pls_status_log (
       listing_id, changed_by, from_status_type_id, to_status_type_id
   )
   VALUES (@ListingID, @AspNetUserId, NULL, @StatusTypeID)
   ```

8. **INSERT into PlsListingOwnership:**
   ```sql
   INSERT INTO FarmGenie.dbo.PlsListingOwnership (
       AspNetUserId, ListingId, MlsId, MlsNumber, OwnershipTypeId
   )
   VALUES (@AspNetUserId, @ListingID, 777, @PlsNumber, 1)  -- 1 = Creator
   ```

9. **INSERT into ListingCommandQueue (if applicable):**
   ```sql
   -- Only if AreaId provided AND StatusTypeID is 6 (Private) or 14 (Coming Soon)
   IF @AreaId IS NOT NULL AND @StatusTypeID IN (6, 14)
   BEGIN
       INSERT INTO FarmGenie.dbo.ListingCommandQueue (
           MlsID,              -- 777
           MlsNumber,          -- PLS100001A
           PropertyCastTypeId, -- 4 (PLS)
           AspNetUserId,       -- Agent user ID
           AreaId,             -- Selected area
           CreateDate
       )
       VALUES (777, @PlsNumber, 4, @AspNetUserId, @AreaId, GETDATE())
   END
   ```

**Response:**
```json
{
  "Success": true,
  "PlsNumber": "PLS100001A",
  "ListingId": 12345,
  "Message": "PLS listing created successfully"
}
```

### Phase 5: XML Generation & GenieCloud Render

#### Step 15: XML Generation
**Action:** System generates XML per Contract v6.1  
**API:** `POST /api/pls/{plsNumber}/render`  
**Backend Process:**
1. Load listing data from `MlsListing.dbo.Listing`
2. Load agent data from `AspNetUsers` and related tables
3. Load area data from `FarmGenie.dbo.Area`
4. Load photos from `MlsListing.dbo.Photo`
5. Build XML structure (per Contract v6.1)
6. Validate XML

**XML Structure:**
```xml
<renderRoot>
  <agents>
    <agent>
      <name>{ListingAgentName}</name>
      <email>{Email}</email>
      <phone>{Phone}</phone>
      ...
    </agent>
  </agents>
  <areas>
    <area>
      <id>{AreaId}</id>
      <name>{AreaName}</name>
      ...
    </area>
  </areas>
  <single>
    <mlsNumber>{PlsNumber}</mlsNumber>
    <price>{OriginalListPrice}</price>
    <description><![CDATA[{Remarks}]]></description>
    <images>
      <image src="{PhotoUrl}"/>
      ...
    </images>
    ...
  </single>
</renderRoot>
```

#### Step 16: GenieCloud API Call
**Action:** System POSTs XML to GenieCloud API  
**API:** `POST https://cloud-api.thegenie.ai/api/render`  
**Request:**
```json
{
  "userId": "{asp-user-id}",
  "listingId": "pls-PLS100001A",
  "assets": [
    "landing-pages/pls-hollywood",
    "social-marketing-graphics/lc-prop-post-03"
  ],
  "theme": "compass",
  "themeHue": "dark",
  "xml": "<renderRoot>...</renderRoot>"
}
```

**Response:**
```json
{
  "renderId": "pls-PLS100001A",
  "status": "queued",
  "collectionUrl": "https://cloud.thegenie.ai/genie-collection/{id}"
}
```

#### Step 17: Status Update
**Action:** System updates PLS status to 'active' or 'coming_soon'  
**Stored Procedure:** `usp_UpdatePlsStatus`  
**Process:**
1. Update `pls_tracking.status_type_id`
2. Update `MlsListing.dbo.Listing.StatusTypeID` (if published)
3. Insert into `pls_status_log` (audit trail)

**SQL:**
```sql
EXEC dbo.usp_UpdatePlsStatus
    @ListingId = @ListingId,
    @AspNetUserId = @AspNetUserId,
    @NewStatusCode = 'active',  -- or 'coming_soon'
    @ErrorMessage = @ErrorMessage OUTPUT
```

### Phase 6: Listing Command Integration

#### Step 18: Listing Command Queue Processing
**Action:** Listing Command service processes queue  
**Trigger:** Automatic (Windows Service or scheduled job)  
**Queue Table:** `FarmGenie.dbo.ListingCommandQueue`  
**Filter:** `PropertyCastTypeId = 4` (PLS)

**Workflow (Reuses Existing Listing Command Service):**
1. Service picks up queue item (MlsID=777, PropertyCastTypeId=4)
2. Generates SMS messages to farm area (AreaId)
3. Creates landing page links with UTM tracking
4. Engagement Center captures leads
5. Versium data append (automatic)
6. Status remains 'active' or 'coming_soon'

**UI:** Reuse existing `ListingCommandInitiateComponent` with route parameter `{plsNumber}`

## Permission Checks at Each Step

### Step-by-Step Permission Verification

| Step | Action | Permission Required | Check Location |
|------|--------|-------------------|----------------|
| 1 | Navigate to menu | Permission 211 (Menu PLS) | Controller `[SmartAuthorize]` |
| 2-6 | Address/Area lookup | Permission 211 (Menu PLS) | Controller `[SmartAuthorize]` |
| 7-11 | Form pre-population | Permission 211 (Menu PLS) | Controller `[SmartAuthorize]` |
| 13 | Save listing | Permission 210 (ManagePLS) | Method `[SmartAuthorize]` |
| 14 | Stored procedure | Permission 210 (ManagePLS) | Verified in procedure |
| 15-17 | Generate content | Permission 210 (ManagePLS) | Method `[SmartAuthorize]` |
| 18 | Listing Command | Permission 210 (ManagePLS) | Verified in queue procedure |

## Error Handling

### Permission Denied
**Scenario:** User without Permission 210 tries to create listing  
**Response:** 403 Forbidden  
**Message:** "You do not have permission to create PLS listings. Contact your administrator."

### Ownership Verification Failed
**Scenario:** User tries to edit listing they don't own  
**Response:** 403 Forbidden  
**Message:** "You do not have permission to edit this listing."

### Database Errors
**Scenario:** Stored procedure fails  
**Response:** 500 Internal Server Error  
**Message:** Error message from stored procedure  
**Logging:** `DashboardManager.Log(ex)`

## Audit Trail

### Complete Status History
Every status change is logged in `pls_status_log`:
- Initial creation (from_status_type_id = NULL)
- Status transitions (draft → active, active → coming_soon, etc.)
- Changed by (AspNetUserId)
- Changed at (timestamp)

### Query Status History
```sql
SELECT 
    psl.changed_at,
    pst_from.status_name AS FromStatus,
    pst_to.status_name AS ToStatus,
    u.UserName AS ChangedBy
FROM dbo.pls_status_log psl
INNER JOIN dbo.pls_status_type pst_to ON pst_to.status_type_id = psl.to_status_type_id
LEFT JOIN dbo.pls_status_type pst_from ON pst_from.status_type_id = psl.from_status_type_id
LEFT JOIN dbo.AspNetUsers u ON u.Id = psl.changed_by
WHERE psl.listing_id = @ListingId
ORDER BY psl.changed_at DESC
```

---

**Key Points:**
- PLS is a NEW SERVICE integrated into the permission system
- Follows Listing Command and Neighborhood Command patterns
- All access controlled via Permission table
- Features accessible based on role permissions
- Complete stored procedures for all operations
- Detailed workflow steps documented
