# PLS Implementation Guide
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** 🚧 Implementation In Progress

## Overview

This guide provides step-by-step instructions for implementing the PLS RESO Engine UI on localhost, following the v1.12 workflow specification with Mapbox auto-photo and Paisley auto-description generation.

## Prerequisites

1. **Localhost Setup:**
   - Smart.Dashboard app running on `http://localhost:38949`
   - Authentication working (JWT token)
   - Database access (FarmGenie, MlsListing, TitleData)

2. **Codebase Locations:**
   - Controllers: `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\`
   - Angular Components: `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.NG.Agent\`
   - Models: `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Models\`

3. **API Keys Required:**
   - Google Places API key (for address autocomplete)
   - Mapbox API key (for satellite photo generation)
   - Paisley AI access (ChatStartTypeId=3)

## Implementation Steps

### Step 1: Backend API Endpoints (DataController)

**File:** `DataController.PLS.cs` (add as partial class)

**Location:** `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\DataController.PLS.cs`

**Reference:** See `DataController_PLS_Implementation_v1.cs` in this workspace

**Endpoints to Implement:**
1. `POST /api/Data/AutoCompleteAddress` - Uses `AgentDashboardManager.AutocompleteAddress()`
2. `POST /api/Data/GetPropertiesFromPlaceKey` - Google Places Details + TitleData lookup
3. `POST /api/Data/GetAreaList` - Uses `DashboardAutoCompleteManager.GetAreas()`

**Critical Notes:**
- Use existing `Models.External.Response.ApiAreaListResponse` and `Models.External.ApiArea` classes
- `AreaType` is a STRING property, NOT `AreaTypeId` (int)
- Follow existing error response patterns
- No mock data - real API calls only

### Step 2: Mapbox Satellite Photo Integration

**Purpose:** Auto-generate satellite photo with property boundary overlay

**Implementation:**
1. Create `MapboxService.cs` in BLL layer
2. Use Mapbox Static Images API
3. Generate photo when property coordinates are available
4. Store as `DisplayOrder=1` in `MlsListing.dbo.Photo`

**Mapbox API Endpoint:**
```
https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/{overlay}/{lon},{lat},{zoom},{bearing},{pitch}/{width}x{height}@2x?access_token={token}
```

**Parameters:**
- `overlay`: Property boundary polygon (GeoJSON)
- `lon`, `lat`: Property coordinates from TitleData/Google Places
- `zoom`: 18-20 (close view)
- `bearing`, `pitch`: Calculate best angle for property view
- `width`, `height`: 1200x800 (recommended)

**Storage:**
- Upload to S3: `https://genie-cloud.s3.us-west-1.amazonaws.com/genie-pages/pls{number}/photos/mapbox-satellite.jpg`
- Insert into `MlsListing.dbo.Photo` with `PhotoSource='Mapbox'`

### Step 3: Paisley Auto-Description Generation

**Purpose:** Auto-generate property description using Paisley AI (ChatStartTypeId=3)

**Implementation:**
1. Trigger automatically when property data is pre-populated
2. Use existing Paisley chat service with `ChatStartTypeId=3`
3. Pass Listing Data + Area Data to Paisley
4. Display generated description with "Edit" button only (no "Generate" button)

**API Call:**
```csharp
// POST /api/Paisley/Chat or existing Paisley service
var chatRequest = new ChatRequest
{
    ChatStartTypeId = 3,  // Pre-Listing Focused
    PropertyAddress = propertyAddress,
    ListingData = listingData,  // From TitleData + MLS
    AreaData = areaData,  // Selected area
    Message = "Generate a compelling property description for this pre-listing"
};
```

**Response:**
- Generated description text
- Display in UI textarea
- Show "Edit" button (description already generated)

### Step 4: Angular Component Update

**File:** `pls-create.component.ts` and `pls-create.component.html`

**Location:** Angular app components directory

**Updates Required:**
1. **Step 10 (Combined UI):**
   - Display Mapbox satellite photo (auto-generated)
   - Display Paisley-generated description (with "Edit" button)
   - Show "Load Photos" button (optional upload)

2. **Auto-Generation Flow:**
   - After property pre-population (Step 8), automatically:
     - Call Mapbox API to generate photo
     - Call Paisley API to generate description
   - Display both on same UI page

3. **Photo Upload:**
   - Make photo upload optional (Mapbox photo is automatic)
   - "Load Photos" button opens upload component
   - Additional photos stored as DisplayOrder=2, 3, etc.

### Step 5: Testing Workflow

**Test Flow:**
1. Navigate to `/pls/create` (or Pre-Listing menu)
2. Enter address → AutoCompleteAddress endpoint
3. Select address → GetPropertiesFromPlaceKey endpoint
4. System auto-fetches areas → GetAreaList endpoint
5. User selects area
6. System pre-populates property data
7. **System auto-generates:**
   - Mapbox satellite photo (DisplayOrder=1)
   - Paisley description (ChatStartTypeId=3)
8. Combined UI displays both (with "Edit" button for description, "Load Photos" button)
9. User reviews, optionally uploads more photos
10. User selects status (Coming Soon/Private)
11. User clicks "Save & Generate Content Kit"
12. System generates PLS number, saves listing, generates XML, triggers GenieCloud

## File Structure

```
C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\
├── Controllers\
│   ├── DataController.cs (existing)
│   └── DataController.PLS.cs (NEW - partial class)
├── BLL\
│   └── MapboxService.cs (NEW - Mapbox API integration)
└── Models\
    └── (use existing Models.External namespace)

Smart.NG.Agent\ (Angular app)
├── components\
│   └── pls\
│       ├── pls-create.component.ts (UPDATE)
│       ├── pls-create.component.html (UPDATE)
│       └── pls-create.component.scss (UPDATE)
```

## API Endpoint Specifications

### POST /api/Data/AutoCompleteAddress
- **Uses:** `AgentDashboardManager.AutocompleteAddress()`
- **Response:** `{ Success, Addresses[] }`

### POST /api/Data/GetPropertiesFromPlaceKey
- **Uses:** Google Places Details API + TitleData lookup
- **Response:** `{ Success, Properties[] }`
- **TODO:** Implement TitleData/MLS query for property characteristics

### POST /api/Data/GetAreaList
- **Uses:** `DashboardAutoCompleteManager.GetAreas()`
- **Response:** `ApiAreaListResponse` (existing Models.External namespace)

## Next Steps

1. ✅ Review `DataController_PLS_Implementation_v1.cs`
2. ⏳ Verify existing Paisley service method signatures
3. ⏳ Implement MapboxService for satellite photo generation
4. ⏳ Update Angular component for v1.12 workflow
5. ⏳ Test complete flow on localhost
6. ⏳ Deploy to sandbox for testing

---

**[↑ Back to Project Blueprint](../PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md)**
