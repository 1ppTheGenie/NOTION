# PLS UI Specification - Software Design Document

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Format:** eRealtor Tech Design Style  
**Target:** Friday Prototype (12/31/2025 or 01/03/2026)

---

## 🎯 EXECUTIVE SUMMARY

**Purpose:** Create a web-based UI for agents and title reps to create Pre-Listing Service (PLS) listings that generate marketing content kits BEFORE properties hit MLS.

**Two Use Cases:**
1. **Coming Soon/Private Listings** - Market property BEFORE MLS → Push to MLS when ready (one button)
2. **MLS-Ready Listings** - AI pre-populates listing data → Agent reviews/submits (saves manual entry time)

**Key Value:** Agents get Listing Command circle prospecting automation for pre-MLS listings, becoming "early movers" to sell properties before they go public.

---

## 📋 TABLE OF CONTENTS

1. [System Overview](#1-system-overview)
2. [User Flow Diagrams](#2-user-flow-diagrams)
3. [Screen Specifications](#3-screen-specifications)
4. [Function Definitions](#4-function-definitions)
5. [Data Flow](#5-data-flow)
6. [Business Logic](#6-business-logic)
7. [Integration Points](#7-integration-points)
8. [Database Operations](#8-database-operations)
9. [XML Generation Logic](#9-xml-generation-logic)
10. [Error Handling](#10-error-handling)

---

## 1. SYSTEM OVERVIEW

### 1.1 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    PLS UI SYSTEM ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐      ┌──────────────────┐                 │
│  │  Angular UI      │      │  .NET API        │                 │
│  │  (Frontend)      │◄────►│  (Backend)       │                 │
│  │                  │      │                  │                 │
│  │  • Create Form   │      │  • Validation    │                 │
│  │  • Edit Form     │      │  • Save Listing   │                 │
│  │  • List View     │      │  • Generate XML  │                 │
│  │  • Photo Upload  │      │  • Queue Render  │                 │
│  └──────────────────┘      └────────┬─────────┘                 │
│                                      │                            │
│                                      ▼                            │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │              DATABASE LAYER                               │    │
│  │  • MlsListing.dbo.Listing (MlsId=999)                    │    │
│  │  • MlsListing.dbo.Photo                                  │    │
│  │  • FarmGenie.dbo.PlsListingOwnership                     │    │
│  │  • FarmGenie.dbo.ListingCommandQueue                     │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                      │                            │
│                                      ▼                            │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │              GENIECLOUD RENDER                            │    │
│  │  • XML → HTML/SVG                                        │    │
│  │  • Landing Pages                                         │    │
│  │  • Social Graphics                                       │    │
│  │  • Collection Pages                                      │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Key Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Angular | UI forms, lists, photo upload |
| **Backend API** | .NET Core | Business logic, validation, database |
| **Database** | SQL Server | Listing storage (MlsId=999) |
| **Photo Storage** | S3 | Image hosting |
| **Render Engine** | GenieCloud | XML → Assets |
| **Workflow** | ListingCommand | Circle prospecting automation |

---

## 2. USER FLOW DIAGRAMS

### 2.1 Create New PLS Listing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│              CREATE NEW PLS LISTING - USER FLOW                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: NAVIGATE TO PLS                                        │
│  ════════════════════════════════                              │
│  User clicks "Private Listings" in left nav                    │
│  → Checks Permission: ManagePLS (210)                           │
│  → Shows "My PLS Listings" page                                │
│                                                                  │
│  STEP 2: CLICK "CREATE NEW"                                     │
│  ════════════════════════════════                              │
│  User clicks "Create New Listing" button                       │
│  → Navigates to /pls/create                                     │
│  → Loads empty form                                            │
│                                                                  │
│  STEP 3: FILL PROPERTY DATA                                     │
│  ════════════════════════════════                              │
│  Form Sections:                                                 │
│  ├── Property Address (required)                               │
│  │   • Street Number, Street Name, City, State, Zip            │
│  │   • Auto-geocode on blur                                    │
│  ├── Property Details (required)                               │
│  │   • List Price                                              │
│  │   • Bedrooms, Bathrooms (Full/Half)                         │
│  │   • Square Feet, Lot Size                                   │
│  │   • Year Built                                              │
│  │   • Property Type (dropdown)                               │
│  ├── Status Selection (required)                              │
│  │   • Coming Soon (StatusTypeID=14)                           │
│  │   • Private Listing (StatusTypeID=6)                       │
│  ├── Photos (required - at least 1)                            │
│  │   • Upload to S3                                            │
│  │   • Set primary photo                                       │
│  │   • Reorder photos                                          │
│  ├── Description (optional - AI can generate)                  │
│  │   • Manual entry OR                                         │
│  │   • "Generate with AI" button (Paisley ChatStartTypeId=3) │
│  ├── Area Selection (required for widgets)                     │
│  │   • Search/select area                                      │
│  │   • Used for market stats widgets                           │
│  └── Agent Selection (auto-filled from logged-in user)        │
│      • Can override if Title Rep creating for agent            │
│                                                                  │
│  STEP 4: VALIDATE & SAVE                                        │
│  ════════════════════════════════                              │
│  User clicks "Save Listing"                                     │
│  → Frontend validation (required fields)                       │
│  → POST /api/pls/create                                        │
│  → Backend validation                                          │
│  → Generate PLS Number (PLS-YYYY-NNNNN)                        │
│  → INSERT into MlsListing.dbo.Listing (MlsId=999)              │
│  → INSERT into MlsListing.dbo.Photo (1-N rows)                 │
│  → INSERT into FarmGenie.dbo.PlsListingOwnership               │
│  → Return success + PLS Number                                 │
│                                                                  │
│  STEP 5: GENERATE CONTENT KIT                                  │
│  ════════════════════════════════                              │
│  User clicks "Generate Content Kit"                            │
│  → POST /api/pls/render                                        │
│  → Build XML from listing data                                 │
│  → POST to GenieCloud /api/render                               │
│  → Queue ListingCommandQueue (PropertyCastTypeId=4)            │
│  → Show "Generating..." status                                  │
│  → Poll for completion                                         │
│  → Show collection URL when ready                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Edit Existing PLS Listing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│              EDIT PLS LISTING - USER FLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: VIEW MY LISTINGS                                       │
│  ════════════════════════════════                              │
│  User navigates to /pls/my-listings                            │
│  → Query: SELECT * FROM PlsListingOwnership                    │
│           WHERE AspNetUserId = @userId                          │
│  → JOIN MlsListing.dbo.Listing                                 │
│  → Display list with:                                          │
│     • PLS Number                                                │
│     • Address                                                   │
│     • Status (Coming Soon/Private)                             │
│     • Price                                                     │
│     • Created Date                                             │
│     • Content Kit Status                                       │
│                                                                  │
│  STEP 2: CLICK "EDIT"                                          │
│  ════════════════════════════════                              │
│  User clicks "Edit" on a listing                               │
│  → Navigate to /pls/edit/{plsNumber}                          │
│  → Load listing data from database                             │
│  → Populate form                                               │
│                                                                  │
│  STEP 3: MODIFY DATA                                           │
│  ════════════════════════════════                              │
│  User changes any fields                                       │
│  → Track "dirty" state                                         │
│  → Show "Save Changes" button                                  │
│                                                                  │
│  STEP 4: SAVE CHANGES                                          │
│  ════════════════════════════════                              │
│  User clicks "Save Changes"                                    │
│  → PUT /api/pls/edit/{plsNumber}                              │
│  → UPDATE MlsListing.dbo.Listing                               │
│  → UPDATE MlsListing.dbo.Photo (if changed)                     │
│  → Return success                                              │
│                                                                  │
│  STEP 5: RE-RENDER (if needed)                                 │
│  ════════════════════════════════                              │
│  If significant changes (price, photos, status):               │
│  → Show "Re-generate Content Kit" option                       │
│  → Re-trigger GenieCloud render                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 Start Campaign Flow (Listing Command Integration)

```
┌─────────────────────────────────────────────────────────────────┐
│              START CAMPAIGN - LISTING COMMAND FLOW              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: SELECT LISTING                                        │
│  ════════════════════════════════                              │
│  From "My PLS Listings" page                                   │
│  → User clicks "Start Campaign" button                         │
│  → Navigate to /pls/initiate/{plsNumber}                       │
│                                                                  │
│  STEP 2: REUSE LISTING COMMAND UI                              │
│  ════════════════════════════════                              │
│  Use existing ListingCommandInitiateComponent                  │
│  → Same UI as MLS Listing Command                              │
│  → User selects:                                               │
│     • Area (for circle prospecting)                            │
│     • Campaign options                                         │
│     • SMS/Facebook/Direct Mail                                 │
│                                                                  │
│  STEP 3: PROCESS PAYMENT                                       │
│  ════════════════════════════════                              │
│  Same billing flow as Listing Command                         │
│  → Check WHMCS credits                                         │
│  → Process payment                                             │
│  → Create ListingCommandBilling record                        │
│                                                                  │
│  STEP 4: QUEUE CAMPAIGN                                        │
│  ════════════════════════════════                              │
│  INSERT into ListingCommandQueue                               │
│  → MlsId = 999                                                 │
│  → MlsNumber = "PLS-2025-00001"                                │
│  → PropertyCastTypeId = 4                                      │
│  → ListingJson = {full listing data}                          │
│                                                                  │
│  STEP 5: WORKFLOW EXECUTES                                     │
│  ════════════════════════════════                              │
│  Windows Service picks up queue                               │
│  → Same workflow as MLS Listing Command                        │
│  → Generates assets via GenieCloud                             │
│  → Sends SMS to farm area                                      │
│  → Creates GenieLead records                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. SCREEN SPECIFICATIONS

### 3.1 Screen 1: My PLS Listings (List View)

**Route:** `/pls/my-listings`  
**Component:** `PlsMyListingsComponent`  
**Permission:** `ManagePLS` (210)

#### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  PRIVATE LISTINGS                    [Create New Listing] [+]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  PLS-2025-00001  │  10037 Rebecca Place  │  $749,000   │  │
│  │  Private Listing │  Boerne, TX 78006     │  Created:   │  │
│  │                  │                       │  12/30/2025 │  │
│  │  [Edit] [View] [Start Campaign] [Delete]                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  PLS-2025-00002  │  123 Main St        │  $450,000     │  │
│  │  Coming Soon     │  San Antonio, TX    │  Created:     │  │
│  │                  │                     │  12/29/2025   │  │
│  │  [Edit] [View] [Start Campaign] [Delete]                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  [No listings message if empty]                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Data Source

```sql
SELECT 
    plo.MlsNumber,
    l.DisplayAddress,
    l.OriginalListPrice,
    st.Name AS StatusName,
    plo.CreateDate,
    l.ListingId
FROM FarmGenie.dbo.PlsListingOwnership plo
INNER JOIN MlsListing.dbo.Listing l 
    ON l.MlsID = plo.MlsId 
    AND l.MlsNumber = plo.MlsNumber
INNER JOIN MlsListing.dbo.StatusType st 
    ON st.StatusTypeID = l.StatusTypeID
WHERE plo.AspNetUserId = @userId
    AND plo.IsActive = 1
ORDER BY plo.CreateDate DESC
```

#### Actions

| Button | Action | Route |
|--------|--------|-------|
| **Edit** | Navigate to edit form | `/pls/edit/{plsNumber}` |
| **View** | Open landing page (if rendered) | External link |
| **Start Campaign** | Navigate to campaign initiation | `/pls/initiate/{plsNumber}` |
| **Delete** | Confirm → Archive listing | `PUT /api/pls/archive/{plsNumber}` |

---

### 3.2 Screen 2: Create New Listing Form

**Route:** `/pls/create`  
**Component:** `PlsCreateComponent`  
**Permission:** `ManagePLS` (210)

#### Layout (Multi-Step Form)

```
┌─────────────────────────────────────────────────────────────────┐
│  CREATE NEW PRIVATE LISTING              [Cancel] [Save Draft]  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: PROPERTY ADDRESS                                       │
│  ════════════════════════════════                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Street Number:  [10037        ]  *Required              │  │
│  │  Street Name:    [Rebecca Place]  *Required              │  │
│  │  City:           [Boerne        ]  *Required              │  │
│  │  State:          [TX ▼]          *Required                │  │
│  │  Zip:            [78006         ]  *Required              │  │
│  │                                                           │  │
│  │  [Auto-geocode on blur]                                  │  │
│  │  Latitude: 29.72229  Longitude: -98.68958               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  STEP 2: PROPERTY DETAILS                                       │
│  ════════════════════════════════                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  List Price:        [$749,000    ]  *Required            │  │
│  │  Bedrooms:          [4 ▼]         *Required              │  │
│  │  Bathrooms Full:    [3 ▼]         *Required              │  │
│  │  Bathrooms Half:    [0 ▼]         *Required              │  │
│  │  Square Feet:       [3,018        ]  *Required            │  │
│  │  Lot Size (sq ft):  [9,101        ]  *Required            │  │
│  │  Year Built:        [2022         ]  *Required            │  │
│  │  Property Type:     [Single Family ▼]  *Required         │  │
│  │  Garage Spaces:     [3 ▼]         Optional               │  │
│  │  Parking Spaces:    [3 ▼]         Optional               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  STEP 3: LISTING STATUS                                         │
│  ════════════════════════════════                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ○ Coming Soon (StatusTypeID=14)                        │  │
│  │    Pre-market listing - will go to MLS soon             │  │
│  │                                                           │  │
│  │  ● Private Listing (StatusTypeID=6)                       │  │
│  │    Off-market/exclusive - not going to MLS              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  STEP 4: PHOTOS                                                 │
│  ════════════════════════════════                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [Drag & Drop Photos Here]                              │  │
│  │  or                                                       │  │
│  │  [Browse Files]                                          │  │
│  │                                                           │  │
│  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐                            │  │
│  │  │[1] │ │[2] │ │[3] │ │[4] │  [Set Primary]            │  │
│  │  └────┘ └────┘ └────┘ └────┘                            │  │
│  │                                                           │  │
│  │  *At least 1 photo required                              │  │
│  │  *Primary photo will be used for social graphics         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  STEP 5: DESCRIPTION                                             │
│  ════════════════════════════════                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [Generate with AI]  [Manual Entry]                       │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  [Text area for description]                       │  │  │
│  │  │                                                     │  │  │
│  │  │  Welcome to this stunning 2022-built home...       │  │  │
│  │  │                                                     │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  AI uses: Paisley ChatStartTypeId=3 (Pre-Listing)        │  │
│  │  Data source: TitleData.dbo.ViewAssessor_v3             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  STEP 6: AREA SELECTION                                         │
│  ════════════════════════════════                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Search Area: [Balcones Creek ▼]                         │  │
│  │                                                           │  │
│  │  Selected: Balcones Creek - All Neighborhoods            │  │
│  │  Area ID: 407559                                          │  │
│  │                                                           │  │
│  │  *Used for market stats widgets on landing page          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  STEP 7: AGENT SELECTION                                        │
│  ════════════════════════════════                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Listing Agent: [Steve Hundley ▼]  (Auto-filled)        │  │
│  │                                                           │  │
│  │  *If Title Rep: Can select from sponsored agents         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  [← Back]  [Save Listing]  [Save & Generate Content Kit] →      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Form Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| Street Number | Required, non-empty | "Street number is required" |
| Street Name | Required, non-empty | "Street name is required" |
| City | Required, non-empty | "City is required" |
| State | Required, 2 characters | "State is required" |
| Zip | Required, 5 digits | "Zip code is required" |
| List Price | Required, > 0, integer | "List price must be a positive number" |
| Bedrooms | Required, > 0 | "Bedrooms is required" |
| Bathrooms Full | Required, >= 0 | "Full bathrooms is required" |
| Square Feet | Required, > 0 | "Square feet is required" |
| Lot Size | Required, > 0 | "Lot size is required" |
| Year Built | Required, 1800-2100 | "Year built is required" |
| Status | Required, 6 or 14 | "Status is required" |
| Photos | At least 1 | "At least one photo is required" |
| Area | Required | "Area selection is required" |

#### Business Logic

1. **Auto-Geocode on Address Blur:**
   - When user leaves address field, call geocoding API
   - Populate Latitude/Longitude
   - Show map preview

2. **AI Description Generation:**
   - User clicks "Generate with AI"
   - Call Paisley API with ChatStartTypeId=3
   - Use property address to lookup Attom data
   - Generate description based on assessor data
   - Populate text area

3. **Photo Upload:**
   - Upload to S3 bucket: `genie-cloud-stage` (or `genie-cloud` for prod)
   - Path: `genie-pages/{pls-number}/photos/{filename}`
   - Return HTTPS URL
   - Store in `MlsListing.dbo.Photo` table

4. **Agent Selection:**
   - If logged-in user is Agent: Auto-fill self
   - If logged-in user is Title Rep: Show dropdown of sponsored agents
   - Query: `UserPartner` table WHERE `PartnerTypeId=2`

---

### 3.3 Screen 3: Edit Listing Form

**Route:** `/pls/edit/{plsNumber}`  
**Component:** `PlsEditComponent`  
**Permission:** `ManagePLS` (210)

#### Layout

Same as Create form, but:
- Pre-populated with existing data
- Shows PLS Number (read-only)
- Shows "Created Date" (read-only)
- "Save Changes" button instead of "Save Listing"
- "Re-generate Content Kit" button (if already rendered)

#### Data Loading

```sql
SELECT 
    l.*,
    plo.AspNetUserId,
    plo.CreateDate AS PlsCreateDate
FROM MlsListing.dbo.Listing l
INNER JOIN FarmGenie.dbo.PlsListingOwnership plo
    ON l.MlsID = plo.MlsId 
    AND l.MlsNumber = plo.MlsNumber
WHERE plo.MlsNumber = @plsNumber
    AND plo.AspNetUserId = @userId
    AND plo.IsActive = 1
```

---

### 3.4 Screen 4: Start Campaign (Reuse Listing Command)

**Route:** `/pls/initiate/{plsNumber}`  
**Component:** `ListingCommandInitiateComponent` (REUSE)  
**Permission:** `ManageListingCommand` (142) - Same as LC

#### Layout

**REUSE existing Listing Command initiation UI:**
- Same component as `/listing-command/initiate/{mlsId}/{mlsNumber}`
- Route parameter: `{plsNumber}` instead of `{mlsId}/{mlsNumber}`
- Backend handles MlsId=999 automatically

---

## 4. FUNCTION DEFINITIONS

### 4.1 Frontend Functions (Angular)

#### `PlsCreateComponent`

```typescript
class PlsCreateComponent {
  // Form Data
  formData: PlsListingForm;
  
  // Methods
  onAddressBlur(): void
    // Geocode address
    // Populate lat/lng
    // Show map preview
  
  onPhotoUpload(files: File[]): void
    // Upload to S3
    // Store URLs
    // Update photo list
  
  onGenerateAIDescription(): void
    // Call Paisley API (ChatStartTypeId=3)
    // Use property address
    // Populate description field
  
  onSaveListing(): void
    // Validate form
    // POST /api/pls/create
    // Show success/error
  
  onSaveAndGenerate(): void
    // Save listing first
    // Then trigger render
    // Show progress
}
```

#### `PlsMyListingsComponent`

```typescript
class PlsMyListingsComponent {
  listings: PlsListing[];
  
  loadListings(): void
    // GET /api/pls/my-listings
    // Populate list
  
  onEdit(plsNumber: string): void
    // Navigate to /pls/edit/{plsNumber}
  
  onStartCampaign(plsNumber: string): void
    // Navigate to /pls/initiate/{plsNumber}
  
  onDelete(plsNumber: string): void
    // Confirm dialog
    // PUT /api/pls/archive/{plsNumber}
    // Refresh list
}
```

---

### 4.2 Backend Functions (.NET Core)

#### `PlsController`

```csharp
[ApiController]
[Route("api/pls")]
public class PlsController : ControllerBase
{
    // POST /api/pls/create
    [HttpPost("create")]
    [SmartAuthorize(PermissionType.ManagePLS)]
    public async Task<IActionResult> CreateListing([FromBody] PlsListingDto dto)
    {
        // 1. Validate input
        // 2. Generate PLS Number (PLS-YYYY-NNNNN)
        // 3. Geocode address (if not provided)
        // 4. INSERT into MlsListing.dbo.Listing (MlsId=999)
        // 5. INSERT into MlsListing.dbo.Photo (1-N rows)
        // 6. INSERT into FarmGenie.dbo.PlsListingOwnership
        // 7. Return PLS Number
    }
    
    // PUT /api/pls/edit/{plsNumber}
    [HttpPut("edit/{plsNumber}")]
    [SmartAuthorize(PermissionType.ManagePLS)]
    public async Task<IActionResult> EditListing(string plsNumber, [FromBody] PlsListingDto dto)
    {
        // 1. Verify ownership
        // 2. Validate input
        // 3. UPDATE MlsListing.dbo.Listing
        // 4. UPDATE MlsListing.dbo.Photo (if changed)
        // 5. Return success
    }
    
    // GET /api/pls/my-listings
    [HttpGet("my-listings")]
    [SmartAuthorize(PermissionType.ManagePLS)]
    public async Task<IActionResult> GetMyListings()
    {
        // 1. Get AspNetUserId from token
        // 2. Query PlsListingOwnership
        // 3. JOIN MlsListing.dbo.Listing
        // 4. Return list
    }
    
    // POST /api/pls/render
    [HttpPost("render")]
    [SmartAuthorize(PermissionType.ManagePLS)]
    public async Task<IActionResult> RenderContentKit([FromBody] PlsRenderDto dto)
    {
        // 1. Load listing data
        // 2. Build XML structure
        // 3. POST to GenieCloud /api/render
        // 4. Queue ListingCommandQueue (PropertyCastTypeId=4)
        // 5. Return render ID
    }
    
    // PUT /api/pls/archive/{plsNumber}
    [HttpPut("archive/{plsNumber}")]
    [SmartAuthorize(PermissionType.ManagePLS)]
    public async Task<IActionResult> ArchiveListing(string plsNumber)
    {
        // 1. Verify ownership
        // 2. UPDATE PlsListingOwnership.IsActive = 0
        // 3. Return success
    }
}
```

#### `PlsService` (Business Logic)

```csharp
public class PlsService
{
    // Generate next PLS number
    public string GetNextPlsNumber()
    {
        // Call stored procedure: usp_GetNextPlsNumber
        // Returns: "PLS-2025-00001"
    }
    
    // Build XML from listing data
    public string BuildXml(PlsListing listing, UserMarketingProfile agent, Area area)
    {
        // Map listing → XML structure
        // Include agent data
        // Include area data
        // Return XML string
    }
    
    // Geocode address
    public async Task<GeoCoordinates> GeocodeAddress(string address)
    {
        // Call geocoding API
        // Return lat/lng
    }
    
    // Upload photo to S3
    public async Task<string> UploadPhoto(Stream photoStream, string plsNumber, string filename)
    {
        // Upload to S3
        // Return HTTPS URL
    }
}
```

---

## 5. DATA FLOW

### 5.1 Create Listing Data Flow

```
USER INPUT (Angular Form)
    ↓
FRONTEND VALIDATION
    ↓
POST /api/pls/create
    ↓
BACKEND VALIDATION
    ↓
GENERATE PLS NUMBER (usp_GetNextPlsNumber)
    ↓
GEOCODE ADDRESS (if needed)
    ↓
INSERT MlsListing.dbo.Listing (MlsId=999, StatusTypeID=6 or 14)
    ↓
INSERT MlsListing.dbo.Photo (1-N rows)
    ↓
INSERT FarmGenie.dbo.PlsListingOwnership
    ↓
RETURN SUCCESS + PLS NUMBER
    ↓
FRONTEND SHOWS SUCCESS
```

### 5.2 Generate Content Kit Data Flow

```
USER CLICKS "Generate Content Kit"
    ↓
POST /api/pls/render
    ↓
LOAD LISTING DATA (MlsListing.dbo.Listing)
    ↓
LOAD AGENT DATA (UserMarketingProfile)
    ↓
LOAD AREA DATA (Area table)
    ↓
BUILD XML (PlsService.BuildXml)
    ↓
POST TO GENIECLOUD /api/render
    ↓
INSERT ListingCommandQueue
    → MlsId = 999
    → MlsNumber = "PLS-2025-00001"
    → PropertyCastTypeId = 4
    → ListingJson = {full listing data}
    ↓
WINDOWS SERVICE PICKS UP
    ↓
WORKFLOW EXECUTES (same as Listing Command)
    ↓
GENIECLOUD RENDERS ASSETS
    ↓
SMS SENT TO FARM AREA
    ↓
LEADS CAPTURED
```

---

## 6. BUSINESS LOGIC

### 6.1 PLS Number Generation

**Format:** `PLS-{YEAR}-{SEQUENCE}`

**Example:** `PLS-2025-00001`

**Logic:**
1. Get current year
2. Query `PlsNumberSequence` table
3. If year doesn't exist, INSERT with NextNumber=1
4. If year exists, increment NextNumber
5. Format: `PLS-{YEAR}-{RIGHT('00000' + NextNumber, 5)}`

**Stored Procedure:**
```sql
EXEC dbo.usp_GetNextPlsNumber
-- Returns: "PLS-2025-00001"
```

### 6.2 Ownership Verification

**Rule:** Users can only edit/delete their own listings (unless admin)

**Logic:**
```sql
SELECT COUNT(*) 
FROM FarmGenie.dbo.PlsListingOwnership
WHERE MlsNumber = @plsNumber
    AND AspNetUserId = @userId
    AND IsActive = 1
```

If count = 0 → Return 403 Forbidden

### 6.3 Title Rep Agent Selection

**Rule:** Title Reps can create PLS for their sponsored agents

**Logic:**
```sql
SELECT u.*
FROM FarmGenie.dbo.AspNetUsers u
INNER JOIN FarmGenie.dbo.UserPartner up
    ON up.PartnerUserId = u.Id
WHERE up.PartnerTypeId = 2  -- Title Rep → Agent
    AND up.UserId = @titleRepUserId
    AND up.IsActive = 1
```

### 6.4 AI Description Generation

**Trigger:** User clicks "Generate with AI"

**Logic:**
1. Use property address to lookup Attom data
2. Call Paisley API with:
   - ChatStartTypeId = 3 (Pre-Listing Focused)
   - PropertyId from Attom
   - Request: "Generate a compelling property description for this pre-listing"
3. Return generated description
4. Populate form field

---

## 7. INTEGRATION POINTS

### 7.1 GenieCloud Render API

**Endpoint:** `POST https://cloud-api.thegenie.ai/api/render`

**Request:**
```json
{
    "userId": "9f750957-4d66-4151-bd37-9588d17d4fb8",
    "listingId": "pls-2025-00001",
    "assets": [
        "landing-pages/pls-hollywood",
        "social-marketing-graphics/lc-prop-post-03",
        "social-marketing-graphics/lc-prop-post-01-vip"
    ],
    "theme": "compass",
    "themeHue": "dark",
    "xml": "<renderRoot>...</renderRoot>"
}
```

**Response:**
```json
{
    "renderId": "pls-2025-00001",
    "status": "queued",
    "collectionUrl": "https://cloud.thegenie.ai/genie-collection/{id}"
}
```

### 7.2 Listing Command Queue

**Table:** `FarmGenie.dbo.ListingCommandQueue`

**Insert:**
```sql
INSERT INTO ListingCommandQueue (
    MlsID,
    MlsNumber,
    PropertyCastTypeId,
    AspNetUserId,
    AreaId,
    CreateDate
)
VALUES (
    999,  -- PLS MlsId
    'PLS-2025-00001',
    4,    -- PropertyCastTypeId for PLS
    @userId,
    @areaId,
    GETDATE()
)
```

### 7.3 Paisley AI API

**Endpoint:** `POST /api/paisley/chat`

**Request:**
```json
{
    "chatStartTypeId": 3,  // Pre-Listing Focused
    "propertyAddress": "10037 Rebecca Place, Boerne, TX 78006",
    "message": "Generate a compelling property description for this pre-listing"
}
```

---

## 8. DATABASE OPERATIONS

### 8.1 Create Listing

```sql
-- Step 1: Insert into MlsListing.dbo.Listing
INSERT INTO MlsListing.dbo.Listing (
    MlsID,
    MlsNumber,
    StatusTypeID,
    DisplayAddress,
    StreetNumber,
    StreetName,
    City,
    State,
    Zip,
    OriginalListPrice,
    Bedrooms,
    BathroomsTotal,
    BathroomsFull,
    BathroomsHalf,
    Sqft,
    LotSqft,
    YearBuilt,
    Latitude,
    Longitude,
    Remarks,  -- Description
    PhotoPrimaryUrl,
    PhotoCount,
    ListDate,
    MlsCreateDate,
    MlsUpdateDate
)
VALUES (
    999,  -- PLS MlsId
    'PLS-2025-00001',
    6,    -- Private Listing (or 14 for Coming Soon)
    '10037 Rebecca Place',
    '10037',
    'Rebecca Place',
    'Boerne',
    'TX',
    '78006',
    749000,
    4,
    3,
    3,
    0,
    3018,
    9101,
    2022,
    29.72229,
    -98.68958,
    'Property description...',
    'https://.../photo1.jpg',
    5,
    GETDATE(),
    GETDATE(),
    GETDATE()
);

-- Step 2: Insert photos
INSERT INTO MlsListing.dbo.Photo (ListingID, MlsID, PhotoUrl, DisplayOrder)
VALUES 
    (@ListingId, 999, 'https://.../photo1.jpg', 1),
    (@ListingId, 999, 'https://.../photo2.jpg', 2),
    (@ListingId, 999, 'https://.../photo3.jpg', 3);

-- Step 3: Insert ownership
INSERT INTO FarmGenie.dbo.PlsListingOwnership (
    AspNetUserId,
    MlsId,
    MlsNumber,
    ListingId,
    OwnershipTypeId,
    IsActive,
    CreateDate
)
VALUES (
    @userId,
    999,
    'PLS-2025-00001',
    @ListingId,
    1,  -- Creator
    1,
    GETDATE()
);
```

### 8.2 Update Listing

```sql
UPDATE MlsListing.dbo.Listing
SET 
    OriginalListPrice = @price,
    Bedrooms = @bedrooms,
    BathroomsTotal = @bathroomsTotal,
    Sqft = @sqft,
    Remarks = @description,
    MlsUpdateDate = GETDATE()
WHERE MlsID = 999
    AND MlsNumber = @plsNumber;
```

### 8.3 Archive Listing

```sql
UPDATE FarmGenie.dbo.PlsListingOwnership
SET IsActive = 0,
    LastUpdate = GETDATE()
WHERE MlsNumber = @plsNumber
    AND AspNetUserId = @userId;
```

---

## 9. XML GENERATION LOGIC

### 9.1 XML Structure Mapping

| Database Field | XML Element | Transformation |
|----------------|-------------|----------------|
| `MlsNumber` | `<mlsNumber>` | Direct |
| `MlsID` | `<mlsId>` | Always 999 for PLS |
| `StatusTypeID` | `<statusTypeID>` | Direct (6 or 14) |
| `OriginalListPrice` | `<price>` | Integer, no formatting |
| `Bedrooms` | `<bedrooms count="X"/>` | Attribute format |
| `BathroomsTotal` | `<bathrooms total="X" full="Y" half="Z"/>` | Split into attributes |
| `Sqft` | `<squareFeet>` | Direct |
| `LotSqft` | `<lotSize>` | Direct |
| `YearBuilt` | `<built>` | Direct |
| `Remarks` | `<description>` | CDATA wrapped |
| `PhotoPrimaryUrl` | `<photoPrimary>` | Direct |
| `Latitude` | `<latitude>` | Direct |
| `Longitude` | `<longitude>` | Direct |
| `DisplayAddress` | `<address>/*` | Split into components |

### 9.2 Agent Data Mapping

| Source | XML Element | Notes |
|--------|-------------|-------|
| `UserMarketingProfile.DisplayName` | `<marketingName>` | |
| `UserMarketingProfile.MarketingTitle` | `<marketingTitle>` | |
| `UserMarketingProfile.LicenseNumberDisplay` | `<marketingLicense>` | |
| `AspNetUsers.Email` | `<email>` | |
| `UserMarketingProfile.Phone` | `<mobile>` | |
| Marketing Image Type 1 | `<photo>` | Profile photo |
| Marketing Image Type 2 | `<personalLogoLight>` | Actually dark logo |
| Marketing Image Type 3 | `<personalLogoDark>` | Actually light logo |
| Marketing Image Type 4 | `<companyLogoLight>` | Actually dark logo |
| Marketing Image Type 6 | `<companyLogoDark>` | Actually light logo |

### 9.3 XML Generation Function

```csharp
public string BuildPlsXml(PlsListing listing, UserMarketingProfile agent, Area area)
{
    var xml = new XDocument(
        new XElement("renderRoot",
            new XElement("output",
                new XAttribute("apiUrl", "https://cloud-api.thegenie.ai/"),
                new XAttribute("siteUrl", "https://cloud.thegenie.ai/"),
                new XAttribute("userId", agent.AspNetUserId),
                new XAttribute("theme", agent.Theme ?? "compass"),
                new XAttribute("themeHue", "dark"),
                new XAttribute("size", "landing-page"),
                new XAttribute("renderId", $"pls-{listing.MlsNumber}"),
                new XAttribute("version", "3.0.0")
            ),
            new XElement("xslAsset", "landing-pages/pls-hollywood"),
            BuildAgentXml(agent),
            BuildAreaXml(area),
            BuildListingXml(listing)
        )
    );
    
    return xml.ToString();
}
```

---

## 10. ERROR HANDLING

### 10.1 Validation Errors

**Response Format:**
```json
{
    "error": true,
    "code": "VALIDATION_ERROR",
    "message": "Required fields missing",
    "details": {
        "missingFields": ["streetNumber", "listPrice"],
        "invalidFields": {
            "listPrice": "Must be a positive number"
        }
    }
}
```

### 10.2 Permission Errors

**Response:**
```json
{
    "error": true,
    "code": "PERMISSION_DENIED",
    "message": "User does not have ManagePLS permission"
}
```

### 10.3 Ownership Errors

**Response:**
```json
{
    "error": true,
    "code": "OWNERSHIP_DENIED",
    "message": "User does not own this listing"
}
```

### 10.4 Render Errors

**Response:**
```json
{
    "error": true,
    "code": "RENDER_FAILED",
    "message": "GenieCloud render failed",
    "details": {
        "genieCloudError": "..."
    }
}
```

---

## 📝 IMPLEMENTATION CHECKLIST

### Database Setup
- [ ] Create `PlsListingOwnership` table
- [ ] Create `PlsNumberSequence` table
- [ ] Create `usp_GetNextPlsNumber` stored procedure
- [ ] INSERT StatusType 6 (Private Listing)
- [ ] INSERT MlsId 999 (PLS)
- [ ] INSERT PropertyCastTypeId 4 (PLS)
- [ ] INSERT Permissions 210-214

### Backend API
- [ ] Create `PlsController`
- [ ] Create `PlsService`
- [ ] Implement `CreateListing` endpoint
- [ ] Implement `EditListing` endpoint
- [ ] Implement `GetMyListings` endpoint
- [ ] Implement `RenderContentKit` endpoint
- [ ] Implement `ArchiveListing` endpoint
- [ ] Add permission checks

### Frontend UI
- [ ] Create `PlsMyListingsComponent`
- [ ] Create `PlsCreateComponent`
- [ ] Create `PlsEditComponent`
- [ ] Add routing (`/pls/*`)
- [ ] Add menu item (requires Menu PLS permission)
- [ ] Integrate photo uploader
- [ ] Integrate area selector
- [ ] Integrate AI description generator

### Integration
- [ ] Connect to GenieCloud render API
- [ ] Connect to Listing Command queue
- [ ] Connect to Paisley AI API
- [ ] Test XML generation
- [ ] Test workflow execution

---

**Status:** ✅ Specification Complete - Ready for Implementation!



