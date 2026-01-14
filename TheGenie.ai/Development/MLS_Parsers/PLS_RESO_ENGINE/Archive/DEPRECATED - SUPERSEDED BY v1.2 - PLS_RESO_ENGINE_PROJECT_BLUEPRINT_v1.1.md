# PLS RESO Engine - Complete Project Blueprint
**Version:** 1.2  
**Created:** 01/02/2026  
**Last Updated:** 01/04/2026  
**Author:** Cursor AI Agent  
**Status:** 🎯 MASTER PROJECT BLUEPRINT - Single Source of Truth  
**DRA-2026 Compliant:** ✅ Yes

---

## 🎯 EXECUTIVE SUMMARY

### Project Overview

The **Paisley RESO Listing Engine (PLS)** is a private listing service that enables agents to create and market pre-MLS listings (Coming Soon/Private) with full marketing asset generation, circle prospecting automation, and future "one-button push" to publish listings directly to Bridge and Trestle MLSs via RESO Insert.

### Business Value

| Value Proposition | Impact |
|-------------------|--------|
| **Early Mover Advantage** | Agents market properties BEFORE they hit MLS |
| **Listing Command Integration** | Full circle prospecting automation for pre-MLS listings |
| **Zero Double Entry** | Future RESO Insert eliminates manual MLS entry |
| **Time Savings** | AI pre-population reduces data entry by 80% |
| **Marketing Assets** | Automatic generation of landing pages, social ads, brochures |

### Project Status

| Phase | Status | Completion |
|-------|--------|------------|
| **Specifications** | ✅ Complete | 100% |
| **Database Design** | ✅ Complete | 100% |
| **API Design** | ✅ Complete | 100% |
| **UI Design** | ✅ Complete | 100% |
| **Implementation** | ⏳ Pending | 0% |
| **Testing** | ⏳ Pending | 0% |
| **Deployment** | ⏳ Pending | 0% |

---

## 📋 TABLE OF CONTENTS

1. [Project Vision & Goals](#1-project-vision--goals)
2. [System Architecture](#2-system-architecture)
3. [3-Layer Architecture](#3-3-layer-architecture)
4. [Data Layer (Backend Infrastructure)](#4-data-layer-backend-infrastructure)
5. [Function Layer (API Endpoints)](#5-function-layer-api-endpoints)
6. [Interface Layer (UI Components)](#6-interface-layer-ui-components)
7. [Integration Points](#7-integration-points)
8. [Database Design](#8-database-design)
9. [API Design](#9-api-design)
10. [UI Design](#10-ui-design)
11. [Data Flow Diagrams](#11-data-flow-diagrams)
12. [Implementation Phases](#12-implementation-phases)
13. [Testing Strategy](#13-testing-strategy)
14. [Deployment Plan](#14-deployment-plan)
15. [Risk Assessment](#15-risk-assessment)
16. [Success Metrics](#16-success-metrics)
17. [Reference Documents](#17-reference-documents)

---

## 1. PROJECT VISION & GOALS

### Vision Statement

> Enable agents to become "early movers" by marketing properties BEFORE they hit MLS, with full marketing automation and seamless transition to MLS when ready.

### Primary Goals

1. **Create Pre-MLS Listings** - Agents can create Coming Soon/Private listings in TheGenie system
2. **Generate Marketing Assets** - Automatic creation of landing pages, social ads, brochures via GenieCloud
3. **Circle Prospecting Automation** - Full Listing Command integration for pre-MLS listings
4. **Zero Schema Changes** - Leverage existing `MlsListing.dbo.Listing` structure
5. **Future RESO Insert** - One-button push to Bridge/Trestle MLSs (strategic opportunity)

### Success Criteria

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Time to Create Listing** | < 5 minutes | User testing |
| **Data Pre-Population Accuracy** | > 90% | Field comparison |
| **XML Generation Success Rate** | > 99% | API monitoring |
| **GenieCloud Render Success** | > 95% | Render logs |
| **User Adoption** | 50+ listings/month | Usage analytics |

---

## 2. SYSTEM ARCHITECTURE

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        THEGENIE.AI ECOSYSTEM                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐               │
│  │ TITLE GENIE  │    │   PAISLEY    │    │  ENGAGEMENT  │               │
│  │              │    │              │    │    CENTER    │               │
│  │ • Attom Data │───▶│ • AI Content │    │              │               │
│  │ • MLS Data   │    │ • Templates  │    │ • Lead Capture│              │
│  │ • Property   │    │ • ChatStart3 │    │ • Notifications│             │
│  │   Research   │    │              │    │ • Workflows   │               │
│  └──────────────┘    └──────────────┘    └──────────────┘               │
│         │                   │                    ▲                       │
│         ▼                   ▼                    │                       │
│  ┌──────────────────────────────────────────────┴───────────┐           │
│  │              PAISLEY RESO LISTING ENGINE (PLS)          │           │
│  │                                                           │           │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │           │
│  │  │ DATA LAYER   │  │ FUNCTION     │  │ INTERFACE    │  │           │
│  │  │              │  │ LAYER        │  │ LAYER        │  │           │
│  │  │ • Database   │─▶│ • API        │─▶│ • UI         │  │           │
│  │  │ • Stored     │  │ • Business   │  │ • Forms      │  │           │
│  │  │   Procedures │  │   Logic      │  │ • Uploads    │  │           │
│  │  │ • Data       │  │ • Validation │  │ • Navigation │  │           │
│  │  │   Sources    │  │ • XML Gen    │  │              │  │           │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │           │
│  │                                                           │           │
│  │  • MlsId=999      • PropertyCastTypeId=4                │           │
│  │  • StatusTypeID 6/14  • Listing Command Integration      │           │
│  └───────────────────────────────────────────────────────────┘           │
│                                    │                                     │
│                                    ▼                                     │
│  ┌───────────────────────────────────────────────────────────┐           │
│  │                     GENIE CLOUD                            │           │
│  │  • XSL Templates  • Puppeteer Renderer  • S3 Storage      │           │
│  │  • PDF/PNG Gen    • Landing Pages       • Collections     │           │
│  └───────────────────────────────────────────────────────────┘           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Systems Integration

| System | Role | Integration Point |
|--------|------|-------------------|
| **TitleGenie** | Property data source | TitleData.dbo.AttomDataAssessor (pre-population) |
| **Paisley AI** | Description generation | ChatStartTypeId=3 (Pre-Listing Focused) |
| **GenieCloud** | Asset rendering | XML → HTML/SVG/PNG/PDF |
| **Listing Command** | Circle prospecting | PropertyCastTypeId=4 workflow |
| **Engagement Center** | Lead capture | UTM tracking, Versium append |
| **MlsListing Database** | Listing storage | MlsId=999, StatusTypeID 6/14 |

---

## 3. 3-LAYER ARCHITECTURE

### Architecture Overview

The PLS RESO Engine follows a **3-layer architecture** as defined in `CONTRACT_PLS_to_GenieCloud_v6.1.md` Section 17:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PAISLEY RESO LISTING ENGINE                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    DATA LAYER (Backend Infrastructure)              │  │
│  ├────────────────────────────────────────────────────────────────────┤  │
│  │                                                                      │  │
│  │  DATABASE STRUCTURE (ZERO SCHEMA CHANGES):                          │  │
│  │  ├── MlsListing.dbo.Listing - EXISTING TABLE (PLS uses same)       │  │
│  │  │   • PLS listings stored with MlsId=999                           │  │
│  │  │   • Uses existing columns - NO new columns added                │  │
│  │  │   • New StatusTypeID values (6=Private, 14=Coming Soon)         │  │
│  │  │                                                                   │  │
│  │  ├── Supporting Tables (Minimal):                                │  │
│  │  │   • FarmGenie.dbo.PlsListingOwnership (ownership tracking)     │  │
│  │  │   • FarmGenie.dbo.PlsNumberSequence (number generation)         │  │
│  │  │                                                                   │  │
│  │  STORED PROCEDURES:                                                 │  │
│  │  ├── usp_GetNextPlsNumber - Generate PLS-YYYY-NNNNN               │  │
│  │  │                                                                   │  │
│  │  DATA SOURCES:                                                      │  │
│  │  ├── TitleData.dbo.AttomDataAssessor - Property data (318 fields) │  │
│  │  ├── Historical MLS Data - For conflict resolution                │  │
│  │  └── Paisley AI - Pre-populate listing description                 │  │
│  │                                                                      │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                        │                                   │
│                                        ▼                                   │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    FUNCTION LAYER (API Endpoints)                   │  │
│  ├────────────────────────────────────────────────────────────────────┤  │
│  │                                                                      │  │
│  │  API ENDPOINTS:                                                     │  │
│  │  ├── POST /api/pls/create - Create new PLS listing                 │  │
│  │  ├── PUT /api/pls/{listingNumber} - Update existing listing        │  │
│  │  ├── GET /api/pls/{listingNumber} - Get listing details            │  │
│  │  ├── GET /api/pls/my-listings - List user's listings               │  │
│  │  ├── POST /api/pls/{listingNumber}/render - Generate XML           │  │
│  │  ├── POST /api/pls/pre-populate - Fetch TitleData + Historical MLS │  │
│  │  ├── POST /api/pls/upload-photo - Upload photo to S3                │  │
│  │  ├── POST /api/pls/generate-description - Paisley AI call           │  │
│  │  └── PUT /api/pls/archive/{listingNumber} - Archive listing       │  │
│  │                                                                      │  │
│  │  BUSINESS LOGIC:                                                     │  │
│  │  ├── Data pre-population (TitleData + Historical MLS)              │  │
│  │  ├── Conflict resolution (sqft, beds/baths)                        │  │
│  │  ├── Ownership validation                                             │  │
│  │  ├── Status validation (Coming Soon vs Private Listing)             │  │
│  │  └── XML generation (maps existing MLS columns → GenieCloud XML)  │  │
│  │                                                                      │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                        │                                   │
│                                        ▼                                   │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    INTERFACE LAYER (UI/XML Team)                      │  │
│  ├────────────────────────────────────────────────────────────────────┤  │
│  │                                                                      │  │
│  │  UI COMPONENTS:                                                      │  │
│  │  ├── PlsMyListingsComponent - List view of user's listings          │  │
│  │  ├── PlsCreateComponent - Create new listing form                   │  │
│  │  ├── PlsEditComponent - Edit existing listing form                 │  │
│  │  ├── PlsPhotoUploadComponent - Drag-and-drop photo uploader         │  │
│  │  ├── PlsAreaSelectorComponent - Area/neighborhood picker            │  │
│  │  └── PlsAIDescriptionComponent - AI description generator           │  │
│  │                                                                      │  │
│  │  FEATURES:                                                           │  │
│  │  ├── Property Address Entry - Auto-geocode on blur                  │  │
│  │  ├── Pre-populated Form - Shows TitleData + Historical MLS data     │  │
│  │  ├── Conflict Flagging - Asterisk (*) for sqft/beds/baths conflicts│  │
│  │  ├── Photo Upload - S3 integration, reordering, primary selection   │  │
│  │  ├── Paisley AI Description - Pre-populated, user edits             │  │
│  │  ├── Status Selection - Coming Soon vs Private Listing              │  │
│  │  └── Preview/Review Screen - Before submission                      │  │
│  │                                                                      │  │
│  │  XML GENERATION:                                                     │  │
│  │  ├── Maps UI form data → MlsListing.dbo.Listing (existing table)  │  │
│  │  ├── Maps MlsListing.dbo.Listing → XML structure (per contract)   │  │
│  │  ├── Uses existing Listing Command XML generation logic             │  │
│  │  └── Validates XML against contract before sending to GenieCloud  │  │
│  │                                                                      │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. DATA LAYER (Backend Infrastructure)

### Database Strategy

**Core Principle:** Zero schema changes to existing MLS architecture. PLS leverages existing `MlsListing.dbo.Listing` table structure with new IDs/types only.

### Core Tables

#### MlsListing.dbo.Listing (Existing - No Changes)

**All PLS listings stored here - NO new table needed.**

| Column | PLS Usage | Notes |
|--------|-----------|-------|
| `ListingID` | Primary key | Auto-generated |
| `MlsID` | `999` | PLS identifier |
| `MlsNumber` | `PLS-YYYY-NNNNN` | Generated by stored procedure |
| `StatusTypeID` | `6` (Private) or `14` (Coming Soon) | User selects |
| `PropertyCastTypeId` | `4` | For Listing Command integration |
| All address, property, agent fields | Standard usage | Existing columns, no changes |

#### FarmGenie.dbo.PlsListingOwnership (New)

**Purpose:** Track user ownership of PLS listings.

```sql
CREATE TABLE FarmGenie.dbo.PlsListingOwnership (
    PlsListingOwnershipId INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId NVARCHAR(128) NOT NULL,
    MlsId INT NOT NULL DEFAULT 999,
    MlsNumber VARCHAR(50) NOT NULL,  -- 'PLS-2025-00001'
    ListingId INT NOT NULL,           -- FK to MlsListing.dbo.Listing
    OwnershipTypeId INT NOT NULL DEFAULT 1,  -- 1=Creator, 2=CoAgent
    IsActive BIT NOT NULL DEFAULT 1,
    CreateDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastUpdate DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_PlsOwnership_User FOREIGN KEY (AspNetUserId) 
        REFERENCES FarmGenie.dbo.AspNetUsers(Id),
    CONSTRAINT UQ_PlsOwnership UNIQUE (AspNetUserId, MlsId, MlsNumber)
);
```

#### FarmGenie.dbo.PlsNumberSequence (New)

**Purpose:** Manage PLS number generation (thread-safe).

```sql
CREATE TABLE FarmGenie.dbo.PlsNumberSequence (
    Year INT PRIMARY KEY,
    NextNumber INT NOT NULL DEFAULT 1,
    LastUpdate DATETIME NOT NULL DEFAULT GETDATE()
);
```

### Stored Procedures

#### usp_GetNextPlsNumber

**Purpose:** Generate next PLS number in format `PLS-YYYY-NNNNN`.

**Logic:**
1. Get current year
2. Query `PlsNumberSequence` table
3. If year doesn't exist, INSERT with NextNumber=1
4. If year exists, increment NextNumber
5. Format: `PLS-{YEAR}-{RIGHT('00000' + NextNumber, 5)}`

**Thread-Safe:** Uses transaction to prevent race conditions.

### Master Data Inserts

| Type | ID | Name | Status |
|------|----|----|--------|
| **StatusType** | 6 | Private Listing | ⏳ Needs INSERT |
| **StatusType** | 14 | Coming Soon | ✅ Exists |
| **Mls** | 999 | PLS (Paisley Listing Service) | ⏳ Needs INSERT |
| **PropertyCastType** | 4 | PLS | ⏳ Needs INSERT |

### Permissions

| PermissionID | Name | Description |
|--------------|------|-------------|
| 210 | ManagePLS | Allow user to create and edit PLS listings |
| 211 | Menu PLS | Allows user to view PLS menu |
| 212 | View PLS History | View past PLS listings |
| 213 | PLS Radar | ADMIN - View PLS across all users |
| 214 | PLS Submit While Impersonating | ADMIN - Create PLS for other users |

### Data Sources

#### TitleData.dbo.AttomDataAssessor

**Purpose:** Property data for pre-population (318 fields).

**Key Fields:**
- Address (StreetNumber, StreetName, City, State, Zip)
- Property characteristics (YearBuilt, Bedrooms, Bathrooms, LotSqft)
- Location (Latitude, Longitude, APN)
- Building details (AreaBuilding, YearBuiltEffective)

**Join Key:** `APN` (MlsListing) = `ParcelNumberFormatted` (TitleData) OR address match

#### Historical MLS Data

**Purpose:** Pre-populate fields that may have been updated (e.g., sqft after expansion).

**Source:** `MlsListing.dbo.Listing` (historical listings by APN or address)

**Conflict Resolution:** Use Historical MLS value if different from TitleData, flag with asterisk (*)

#### Paisley AI

**Purpose:** Pre-populate listing description.

**ChatStartTypeId:** `3` (Pre-Listing Focused)

**Data Sources:** TitleData + Historical MLS data

---

## 5. FUNCTION LAYER (API Endpoints)

### API Controller: PlsController

**Base Route:** `/api/pls`

**Authentication:** Required (JWT token)

**Authorization:** Permission checks via `[SmartAuthorize(PermissionType.ManagePLS)]`

### Endpoints

#### POST /api/pls/create

**Purpose:** Create new PLS listing.

**Request Body:**
```json
{
  "streetNumber": "10037",
  "streetName": "Rebecca Place",
  "city": "Boerne",
  "state": "TX",
  "zip": "78006",
  "originalListPrice": 749000,
  "bedrooms": 4,
  "bathroomsFull": 3,
  "bathroomsHalf": 0,
  "sqft": 3018,
  "lotSqft": 9101,
  "yearBuilt": 2022,
  "statusTypeID": 6,
  "description": "Property description...",
  "photos": [
    {"url": "https://...", "displayOrder": 1, "isPrimary": true}
  ],
  "areaId": 407559
}
```

**Response:**
```json
{
  "success": true,
  "plsNumber": "PLS-2025-00001",
  "listingId": 12345
}
```

**Business Logic:**
1. Validate input
2. Generate PLS Number (usp_GetNextPlsNumber)
3. Geocode address (if not provided)
4. INSERT into MlsListing.dbo.Listing (MlsId=999)
5. INSERT into MlsListing.dbo.Photo (1-N rows)
6. INSERT into FarmGenie.dbo.PlsListingOwnership
7. Return PLS Number

#### PUT /api/pls/{listingNumber}

**Purpose:** Update existing PLS listing.

**Authorization:** Verify ownership (PlsListingOwnership check)

**Business Logic:**
1. Verify ownership
2. Validate input
3. UPDATE MlsListing.dbo.Listing
4. UPDATE MlsListing.dbo.Photo (if changed)
5. Return success

#### GET /api/pls/{listingNumber}

**Purpose:** Get listing details.

**Response:**
```json
{
  "plsNumber": "PLS-2025-00001",
  "listing": { /* full listing object */ },
  "photos": [ /* photo array */ ],
  "ownership": { /* ownership info */ }
}
```

#### GET /api/pls/my-listings

**Purpose:** List user's PLS listings.

**Response:**
```json
{
  "listings": [
    {
      "plsNumber": "PLS-2025-00001",
      "displayAddress": "10037 Rebecca Place",
      "originalListPrice": 749000,
      "statusTypeID": 6,
      "statusName": "Private Listing",
      "createDate": "2025-01-02T10:00:00Z"
    }
  ]
}
```

#### POST /api/pls/{listingNumber}/render

**Purpose:** Generate XML and trigger GenieCloud render.

**Response:**
```json
{
  "renderId": "pls-PLS-2025-00001",
  "status": "queued",
  "collectionUrl": "https://cloud.thegenie.ai/genie-collection/{id}"
}
```

**Business Logic:**
1. Load listing data
2. Load agent data (UserMarketingProfile)
3. Load area data
4. Build XML (PlsService.BuildXml)
5. Validate XML against contract
6. POST to GenieCloud /api/render
7. Queue ListingCommandQueue (PropertyCastTypeId=4)
8. Return render ID

#### POST /api/pls/pre-populate

**Purpose:** Fetch TitleData + Historical MLS for pre-population.

**Request:**
```json
{
  "address": "10037 Rebecca Place, Boerne, TX 78006"
}
```

**Response:**
```json
{
  "titleData": { /* TitleData fields */ },
  "historicalMls": { /* Historical MLS fields */ },
  "conflicts": [
    {
      "field": "sqft",
      "titleDataValue": 2500,
      "mlsValue": 3018,
      "recommended": 3018,
      "reason": "MLS value includes permitted expansion"
    }
  ]
}
```

#### POST /api/pls/upload-photo

**Purpose:** Upload photo to S3.

**Request:** Multipart form data (file)

**Response:**
```json
{
  "url": "https://genie-cloud.s3.us-west-1.amazonaws.com/genie-pages/pls-2025-00001/photos/photo1.jpg"
}
```

#### POST /api/pls/generate-description

**Purpose:** Generate listing description via Paisley AI.

**Request:**
```json
{
  "address": "10037 Rebecca Place, Boerne, TX 78006"
}
```

**Response:**
```json
{
  "description": "Welcome to this stunning 2022-built home..."
}
```

#### PUT /api/pls/archive/{listingNumber}

**Purpose:** Archive (soft delete) PLS listing.

**Business Logic:**
1. Verify ownership
2. UPDATE PlsListingOwnership.IsActive = 0
3. Return success

### Business Logic Service: PlsService

**Purpose:** Encapsulate business logic separate from controller.

**Key Methods:**
- `GetNextPlsNumber()` - Call stored procedure
- `PrePopulateFromTitleData(address)` - Query TitleData
- `PrePopulateFromHistoricalMLS(address)` - Query historical listings
- `ResolveConflicts(titleData, historicalMls)` - Sqft, beds/baths override
- `BuildXml(listing, agent, area)` - Generate XML
- `ValidateXml(xml)` - Check against contract
- `UploadPhotoToS3(stream, plsNumber, filename)` - S3 integration
- `GeocodeAddress(address)` - Geocoding API
- `GenerateAIDescription(address)` - Paisley AI call
- `QueueListingCommand(plsNumber, areaId)` - Insert into queue

---

## 6. INTERFACE LAYER (UI Components)

### Angular Components

#### PlsMyListingsComponent

**Route:** `/pls/my-listings`

**Purpose:** List view of user's PLS listings.

**Features:**
- Display list with PLS Number, Address, Price, Status, Created Date
- Actions: Edit, View, Start Campaign, Delete
- Empty state message
- Permission check: `ManagePLS` (210)

**Data Source:** `GET /api/pls/my-listings`

#### PlsCreateComponent

**Route:** `/pls/create`

**Purpose:** Create new PLS listing form.

**Form Sections:**
1. **Property Address** - Street Number, Street Name, City, State, Zip (auto-geocode)
2. **Property Details** - Price, Beds, Baths, Sqft, Lot Size, Year Built, Property Type
3. **Status Selection** - Coming Soon (14) vs Private Listing (6)
4. **Photos** - Drag-and-drop uploader (at least 1 required)
5. **Description** - Manual entry OR "Generate with AI" button
6. **Area Selection** - Search/select area (for market stats widgets)
7. **Agent Selection** - Auto-filled from logged-in user

**Actions:**
- Cancel
- Save Draft (future)
- Save Listing
- Save & Generate Content Kit

**Data Source:** `POST /api/pls/create`

#### PlsEditComponent

**Route:** `/pls/edit/{plsNumber}`

**Purpose:** Edit existing PLS listing.

**Same as Create form, but:**
- Pre-populated with existing data
- Shows PLS Number (read-only)
- Shows Created Date (read-only)
- "Save Changes" button
- "Re-generate Content Kit" button (if already rendered)

**Data Source:** `GET /api/pls/{listingNumber}`, `PUT /api/pls/{listingNumber}`

#### PlsPhotoUploadComponent

**Purpose:** Reusable photo upload component.

**Features:**
- Drag-and-drop uploader
- File browser fallback
- Photo thumbnails with reordering
- Primary photo selection
- Delete photo
- Upload progress indicator

**Data Source:** `POST /api/pls/upload-photo`

#### PlsAreaSelectorComponent

**Purpose:** Area/neighborhood picker.

**Features:**
- Search/filter areas
- Display area name, ID
- Used for market stats widgets on landing page

#### PlsAIDescriptionComponent

**Purpose:** AI description generator.

**Features:**
- "Generate with AI" button
- Loading state during generation
- Populate text area with generated description
- User can edit after generation

**Data Source:** `POST /api/pls/generate-description`

### Routing

```typescript
const routes: Routes = [
  {
    path: 'pls',
    canActivate: [PermissionGuard],
    data: { permission: PermissionType.MenuPLS },
    children: [
      { path: 'my-listings', component: PlsMyListingsComponent },
      { path: 'create', component: PlsCreateComponent },
      { path: 'edit/:plsNumber', component: PlsEditComponent },
      { path: 'initiate/:plsNumber', component: ListingCommandInitiateComponent }
    ]
  }
];
```

### Navigation

**Menu Item:** "Private Listings" (left nav)

**Permission Check:** `Menu PLS` (211)

**Breadcrumbs:**
- Home > Private Listings > My Listings
- Home > Private Listings > Create New
- Home > Private Listings > Edit {PLS Number}

---

## 7. INTEGRATION POINTS

### GenieCloud Integration

**Contract:** `CONTRACT_PLS_to_GenieCloud_v6.1.md`

**API Endpoint:** `POST https://cloud-api.thegenie.ai/api/render`

**Request:**
```json
{
  "userId": "{asp-user-id}",
  "listingId": "pls-PLS-2025-00001",
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
  "renderId": "pls-PLS-2025-00001",
  "status": "queued",
  "collectionUrl": "https://cloud.thegenie.ai/genie-collection/{id}"
}
```

### Listing Command Integration

**PropertyCastTypeId:** `4` (PLS)

**Workflow:** Reuse existing Listing Command workflow

**Queue Table:** `FarmGenie.dbo.ListingCommandQueue`

**Insert:**
```sql
INSERT INTO ListingCommandQueue (
    MlsID, MlsNumber, PropertyCastTypeId, AspNetUserId, AreaId, CreateDate
)
VALUES (999, 'PLS-2025-00001', 4, @userId, @areaId, GETDATE())
```

**UI:** Reuse `ListingCommandInitiateComponent` with route parameter `{plsNumber}`

### Paisley AI Integration

**ChatStartTypeId:** `3` (Pre-Listing Focused)

**Endpoint:** `POST /api/paisley/chat`

**Request:**
```json
{
  "chatStartTypeId": 3,
  "propertyAddress": "10037 Rebecca Place, Boerne, TX 78006",
  "message": "Generate a compelling property description for this pre-listing"
}
```

### TitleGenie Integration

**Data Source:** `TitleData.dbo.AttomDataAssessor`

**Query:** By APN (`ParcelNumberFormatted`) or address match

**Purpose:** Pre-populate property data

### Engagement Center Integration

**Lead Capture:** Automatic via Listing Command workflow

**UTM Tracking:** Standard UTM parameters

**Versium Append:** Automatic via Engagement Center

---

## 8. DATABASE DESIGN

### Entity Relationship Diagram

```
┌─────────────────────────┐
│   MlsListing.dbo.Listing│
│   (MlsId=999)           │
│                         │
│  ListingID (PK)         │
│  MlsID = 999            │
│  MlsNumber              │
│  StatusTypeID (6 or 14) │
│  PropertyCastTypeId = 4 │
│  ... (93 columns)       │
└───────────┬─────────────┘
            │
            │ 1:N
            ▼
┌─────────────────────────┐
│   MlsListing.dbo.Photo   │
│                         │
│  PhotoID (PK)           │
│  ListingID (FK)         │
│  MlsID = 999            │
│  PhotoUrl               │
│  DisplayOrder           │
└─────────────────────────┘

┌─────────────────────────┐
│ PlsListingOwnership      │
│ (FarmGenie)              │
│                         │
│  PlsListingOwnershipId  │
│  AspNetUserId (FK)       │
│  MlsId = 999            │
│  MlsNumber              │
│  ListingId (FK)         │
│  OwnershipTypeId        │
│  IsActive               │
└─────────────────────────┘

┌─────────────────────────┐
│ PlsNumberSequence        │
│ (FarmGenie)              │
│                         │
│  Year (PK)              │
│  NextNumber             │
│  LastUpdate             │
└─────────────────────────┘
```

### Data Flow

```
User creates PLS listing
    ↓
Generate PLS Number (usp_GetNextPlsNumber)
    ↓
INSERT MlsListing.dbo.Listing (MlsId=999)
    ↓
INSERT MlsListing.dbo.Photo (1-N rows)
    ↓
INSERT FarmGenie.dbo.PlsListingOwnership
    ↓
Listing ready for XML generation
```

---

## 9. API DESIGN

### API Architecture

**Framework:** .NET Core Web API

**Authentication:** JWT Bearer Token

**Authorization:** Permission-based (`[SmartAuthorize]`)

**Error Handling:** Standardized error response format

**Validation:** FluentValidation or Data Annotations

### Request/Response Patterns

**Standard Response:**
```json
{
  "success": true,
  "data": { /* response data */ },
  "errors": null
}
```

**Error Response:**
```json
{
  "success": false,
  "data": null,
  "errors": [
    {
      "code": "VALIDATION_ERROR",
      "message": "Required field missing",
      "field": "streetNumber"
    }
  ]
}
```

### API Documentation

**Tool:** Swagger/OpenAPI

**Location:** `/swagger` endpoint

---

## 10. UI DESIGN

### Design System

**Framework:** Angular (version TBD)

**UI Library:** Material Design or custom components

**Styling:** SCSS/CSS

### User Experience Flow

```
1. User navigates to "Private Listings" menu
    ↓
2. User sees "My PLS Listings" page
    ↓
3. User clicks "Create New Listing"
    ↓
4. User enters property address
    ↓
5. System pre-populates from TitleData + Historical MLS
    ↓
6. User reviews pre-populated data, flags conflicts
    ↓
7. User uploads photos
    ↓
8. User generates AI description (optional)
    ↓
9. User selects status (Coming Soon/Private)
    ↓
10. User clicks "Save & Generate Content Kit"
    ↓
11. System generates XML, triggers GenieCloud render
    ↓
12. User sees "Generating..." status
    ↓
13. System displays collection URL when ready
```

### Accessibility

- WCAG 2.1 AA compliance
- Keyboard navigation
- Screen reader support
- Color contrast ratios

---

## 11. DATA FLOW DIAGRAMS

### Create Listing Flow

```
┌─────────────┐
│   User      │
│   (UI)      │
└──────┬──────┘
       │
       │ 1. Enter address
       ▼
┌─────────────────────┐
│  PlsCreateComponent │
└──────┬──────────────┘
       │
       │ 2. POST /api/pls/pre-populate
       ▼
┌─────────────────────┐
│  PlsController      │
│  PrePopulate()      │
└──────┬──────────────┘
       │
       │ 3. Query TitleData + Historical MLS
       ▼
┌─────────────────────┐
│  TitleData DB       │
│  Historical MLS    │
└──────┬──────────────┘
       │
       │ 4. Return pre-populated data + conflicts
       ▼
┌─────────────────────┐
│  PlsCreateComponent │
│  (Display form)     │
└──────┬──────────────┘
       │
       │ 5. User fills form, uploads photos
       │ 6. POST /api/pls/create
       ▼
┌─────────────────────┐
│  PlsController      │
│  CreateListing()    │
└──────┬──────────────┘
       │
       │ 7. Generate PLS Number
       │ 8. INSERT MlsListing.dbo.Listing
       │ 9. INSERT MlsListing.dbo.Photo
       │ 10. INSERT PlsListingOwnership
       ▼
┌─────────────────────┐
│  Database           │
└─────────────────────┘
```

### Generate Content Kit Flow

```
┌─────────────┐
│   User      │
│   (UI)      │
└──────┬──────┘
       │
       │ 1. Click "Generate Content Kit"
       ▼
┌─────────────────────┐
│  PlsEditComponent   │
└──────┬──────────────┘
       │
       │ 2. POST /api/pls/{listingNumber}/render
       ▼
┌─────────────────────┐
│  PlsController      │
│  RenderContentKit() │
└──────┬──────────────┘
       │
       │ 3. Load listing, agent, area data
       │ 4. Build XML (PlsService.BuildXml)
       │ 5. Validate XML
       ▼
┌─────────────────────┐
│  PlsService         │
│  BuildXml()         │
└──────┬──────────────┘
       │
       │ 6. POST to GenieCloud /api/render
       ▼
┌─────────────────────┐
│  GenieCloud API     │
└──────┬──────────────┘
       │
       │ 7. Queue ListingCommandQueue
       ▼
┌─────────────────────┐
│  ListingCommandQueue│
└─────────────────────┘
```

---

## 12. IMPLEMENTATION PHASES

### Phase 1: Foundation (Week 1-2)

**Goal:** Database infrastructure and basic API endpoints

**Tasks:**
- [ ] Execute database scripts (DBA)
- [ ] Create PlsController skeleton (Backend)
- [ ] Create PlsService skeleton (Backend)
- [ ] Implement POST /api/pls/create (Backend)
- [ ] Implement GET /api/pls/my-listings (Backend)
- [ ] Implement GET /api/pls/{listingNumber} (Backend)
- [ ] Basic error handling (Backend)

**Deliverables:**
- Database tables created
- Basic CRUD operations working
- API endpoints tested via Postman

### Phase 2: Data Pre-Population (Week 3-4)

**Goal:** TitleData + Historical MLS pre-population

**Tasks:**
- [ ] Implement POST /api/pls/pre-populate (Backend)
- [ ] TitleData query service (Backend)
- [ ] Historical MLS query service (Backend)
- [ ] Conflict resolution logic (Backend)
- [ ] Create PlsCreateComponent (Frontend)
- [ ] Pre-population UI display (Frontend)
- [ ] Conflict flagging UI (Frontend)

**Deliverables:**
- Pre-population API working
- UI displays pre-populated data
- Conflicts flagged with asterisk

### Phase 3: Photo Upload (Week 5)

**Goal:** S3 photo upload integration

**Tasks:**
- [ ] Implement POST /api/pls/upload-photo (Backend)
- [ ] S3 upload service (Backend)
- [ ] Create PlsPhotoUploadComponent (Frontend)
- [ ] Drag-and-drop uploader (Frontend)
- [ ] Photo reordering UI (Frontend)
- [ ] Primary photo selection (Frontend)

**Deliverables:**
- Photo upload working
- Photos stored in S3
- Photo URLs in database

### Phase 4: XML Generation (Week 6-7)

**Goal:** XML generation and GenieCloud integration

**Tasks:**
- [ ] Implement PlsService.BuildXml() (Backend)
- [ ] Agent data fetching (Backend)
- [ ] Area data fetching (Backend)
- [ ] XML validation (Backend)
- [ ] Implement POST /api/pls/{listingNumber}/render (Backend)
- [ ] GenieCloud API integration (Backend)
- [ ] Render status polling (Backend)

**Deliverables:**
- XML generation working
- GenieCloud renders assets
- Collection URLs returned

### Phase 5: UI Completion (Week 8-9)

**Goal:** Complete UI components and navigation

**Tasks:**
- [ ] Create PlsMyListingsComponent (Frontend)
- [ ] Create PlsEditComponent (Frontend)
- [ ] Add routing (/pls/*) (Frontend)
- [ ] Add menu item (Frontend)
- [ ] Form validation (Frontend)
- [ ] Error display (Frontend)
- [ ] Loading states (Frontend)
- [ ] Permission checks (Frontend)

**Deliverables:**
- All UI components complete
- Navigation working
- Forms validated

### Phase 6: AI Integration (Week 10)

**Goal:** Paisley AI description generation

**Tasks:**
- [ ] Implement POST /api/pls/generate-description (Backend)
- [ ] Paisley AI API integration (Backend)
- [ ] Create PlsAIDescriptionComponent (Frontend)
- [ ] "Generate with AI" button (Frontend)
- [ ] Loading state during generation (Frontend)

**Deliverables:**
- AI description generation working
- UI integrated

### Phase 7: Listing Command Integration (Week 11)

**Goal:** Full Listing Command workflow integration

**Tasks:**
- [ ] Implement POST /api/pls/{listingNumber}/initiate-campaign (Backend)
- [ ] ListingCommandQueue integration (Backend)
- [ ] Reuse ListingCommandInitiateComponent (Frontend)
- [ ] Handle MlsId=999 in component (Frontend)
- [ ] Handle PropertyCastTypeId=4 (Frontend)

**Deliverables:**
- Campaign initiation working
- Workflow executes for PLS listings

### Phase 8: Testing & Polish (Week 12)

**Goal:** End-to-end testing and bug fixes

**Tasks:**
- [ ] Unit tests (Backend)
- [ ] Integration tests (Backend)
- [ ] E2E tests (Frontend)
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] Documentation

**Deliverables:**
- All tests passing
- Production-ready code

---

## 12.1. DETAILED TESTING CHECKLIST

### Database Tests
- [ ] `EXEC dbo.usp_GetNextPlsNumber;` returns "PLS-2025-00001"
- [ ] Can INSERT test listing with MlsId=999
- [ ] Can query PlsListingOwnership table
- [ ] Permissions work (user can see menu with Permission 211)
- [ ] StatusTypeID 6 (Private) and 14 (Coming Soon) exist
- [ ] PropertyCastTypeId 4 (PLS) exists

### API Tests
- [ ] `POST /api/pls/create` creates listing
- [ ] `GET /api/pls/my-listings` returns user's listings
- [ ] `PUT /api/pls/edit/{plsNumber}` updates listing
- [ ] `POST /api/pls/render` triggers GenieCloud
- [ ] `POST /api/pls/pre-populate` returns TitleData + MLS data
- [ ] `POST /api/pls/upload-photo` uploads to S3
- [ ] `POST /api/pls/generate-description` calls Paisley AI

### UI Tests
- [ ] Can navigate to "Private Listings" menu (requires Permission 211)
- [ ] Can create new listing (all 7 steps)
- [ ] Can upload photos (drag-and-drop)
- [ ] Can generate AI description
- [ ] Can save listing
- [ ] Can view "My Listings" page
- [ ] Can edit existing listing
- [ ] Can start campaign (reuses Listing Command UI)
- [ ] Form validation works
- [ ] Error messages display correctly

### Integration Tests
- [ ] XML generates correctly (validates against Contract v6.1)
- [ ] GenieCloud receives XML and renders assets
- [ ] Landing page renders correctly
- [ ] Social graphics render correctly
- [ ] Collection page created
- [ ] Listing Command queue processes PLS listings (MlsId=999, PropertyCastTypeId=4)
- [ ] SMS sent to farm area
- [ ] Lead capture works via Engagement Center

---

## 12.2. MINIMUM VIABLE PROTOTYPE (MVP) DEFINITION

### Must Have (For Initial Release):
1. ✅ Database setup complete (tables, stored procedures, master data)
2. ✅ Create listing form (all 7 steps functional)
3. ✅ Save to database (MlsId=999, StatusTypeID 6 or 14)
4. ✅ Generate XML (validates against Contract v6.1)
5. ✅ Trigger GenieCloud render (POST to render API)
6. ✅ View "My Listings" page (list user's PLS listings)
7. ✅ Basic photo upload (at least 1 photo required)

### Nice to Have (Post-MVP):
- Edit listing functionality
- Start campaign (reuse Listing Command UI)
- AI description generation (Paisley AI integration)
- Photo reordering and primary photo selection
- Pre-population from TitleData (can be manual entry for MVP)
- Conflict resolution UI (can be manual for MVP)

### Future (Not for MVP):
- Push to MLS (RESO Insert) - Strategic opportunity
- Advanced analytics
- Bulk operations
- Export functionality

**MVP Timeline:** 4-6 weeks (Phases 1-5)

---

## 13. TESTING STRATEGY

### Unit Tests

**Backend:**
- PlsService methods
- Validation logic
- XML generation
- Conflict resolution

**Frontend:**
- Component logic
- Form validation
- Permission checks

### Integration Tests

**Backend:**
- API endpoints
- Database operations
- External API calls (GenieCloud, Paisley AI, S3)

**Frontend:**
- API integration
- Component interactions

### End-to-End Tests

**Scenarios:**
1. Create new PLS listing
2. Edit existing listing
3. Generate content kit
4. Upload photos
5. Generate AI description
6. Start campaign

### Test Data

**Test Property:**
- Address: 10037 Rebecca Place, Boerne, TX 78006
- PLS Number: PLS-2025-00001
- Status: Private Listing (6)

---

## 14. DEPLOYMENT PLAN

### Environment Strategy

| Environment | Purpose | Database | API | UI |
|-------------|---------|----------|-----|-----|
| **Development** | Local development | Local SQL | Localhost | Localhost |
| **Staging** | Pre-production testing | Staging DB | Staging API | Staging URL |
| **Production** | Live system | Production DB | Production API | Production URL |

### Deployment Steps

1. **Database Migration**
   - Execute database scripts on staging
   - Verify all objects created
   - Test stored procedures
   - Execute on production (during maintenance window)

2. **Backend Deployment**
   - Deploy API to staging
   - Run integration tests
   - Deploy to production
   - Monitor error logs

3. **Frontend Deployment**
   - Build Angular app
   - Deploy to staging
   - Test all routes
   - Deploy to production
   - Clear CDN cache

4. **Post-Deployment**
   - Verify database objects
   - Test API endpoints
   - Test UI components
   - Monitor error logs
   - User acceptance testing

---

## 15. RISK ASSESSMENT

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Database scripts fail** | High | Low | Test on staging first, have rollback scripts |
| **GenieCloud API changes** | High | Medium | Contract versioning, monitor API changes |
| **TitleData unavailable** | Medium | Low | Fallback to manual entry, cache data |
| **S3 upload failures** | Medium | Low | Retry logic, error handling |
| **Performance issues** | Medium | Medium | Database indexing, query optimization |
| **Permission system issues** | High | Low | Thorough testing, admin override |

---

## 16. SUCCESS METRICS

### Technical Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **API Response Time** | < 500ms | API monitoring |
| **XML Generation Time** | < 2s | Performance logs |
| **Photo Upload Success Rate** | > 99% | S3 upload logs |
| **GenieCloud Render Success** | > 95% | Render logs |
| **Database Query Performance** | < 100ms | SQL Profiler |

### Business Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Listings Created/Month** | 50+ | Usage analytics |
| **Time to Create Listing** | < 5 minutes | User testing |
| **User Adoption Rate** | 30% of eligible users | Usage analytics |
| **Content Kit Generation Rate** | 80% of listings | Usage analytics |

---

## 17. DRA-2026 COMPLIANCE

### Document Structure

This document is the **canonical single source of truth** for the PLS RESO Engine project. All redundant project plans have been consolidated into this blueprint per the Document Reduction Act of 2026 (DRA-2026).

**Compliance Status:** ✅ Active  
**Compliance Document:** `PLS_DRA_2026_COMPLIANCE_v1.md`

### Archived Documents

The following documents have been archived per DRA-2026:
- **Session Logs** → `Archive/Session_Logs/` (historical context merged into this blueprint)
- **One-time SOPs** → `Archive/SOPs/` (completed procedures)
- **Redundant Project Plans** → `Archive/Redundant_Plans/` (consolidated into this blueprint)

See `PLS_DRA_2026_COMPLIANCE_v1.md` for complete archive listing and compliance details.

---

## 18. REFERENCE DOCUMENTS

### Master Documents

| Document | Version | Location |
|----------|---------|----------|
| **CONTRACT_PLS_to_GenieCloud** | 6.1 | `Paisley/Pre.Listing.Command/Docs/` |
| **PLS_MASTER_SPECIFICATION** | 3.0 | `Paisley/Pre.Listing.Command/Docs/` |
| **PLS_3_LAYER_GAP_ANALYSIS** | 1.0 | `MLS_Parsers/PLS_RESO_ENGINE/` |
| **PLS_DRA_2026_COMPLIANCE** | 1.0 | `MLS_Parsers/PLS_RESO_ENGINE/` |

### Implementation Specs

| Document | Version | Location |
|----------|---------|----------|
| **PLS_DATABASE_IMPLEMENTATION_SPEC** | 1.0 | `MLS_Parsers/PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md` |
| **PLS_UI_SPECIFICATION** | 1.0 | `MLS_Parsers/PLS_UI_SPECIFICATION_v1.md` |
| **PLS_XML_GENERATION_SPEC** | 1.0 | `MLS_Parsers/PLS_XML_GENERATION_SPEC_v1.md` |

### Analysis Documents

| Document | Version | Location |
|----------|---------|----------|
| **TITLEDATA_TO_MLSLISTING_FIELD_MAPPING** | 1.0 | `MLS_Parsers/PLS_RESO_ENGINE/` |
| **RESO_INSERT_OPPORTUNITY_ANALYSIS** | 1.0 | `MLS_Parsers/RESO_INSERT_OPPORTUNITY_ANALYSIS_v1.md` |

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.2 | 01/04/2026 | Cursor AI Agent | DRA-2026 Phase 4: Consolidated redundant project plans (Master Plan v2, Comprehensive Plan, Action Plan, Status & Next Steps) - Added detailed testing checklist, MVP definition with Must Have/Nice to Have/Future breakdown |
| 1.1 | 01/04/2026 | Cursor AI Agent | DRA-2026 compliance: Added compliance section, consolidated redundant project plans, archived session documents |
| 1.0 | 01/02/2026 | Cursor AI Agent | Initial project blueprint created |

---

**Status:** ✅ Project Blueprint Complete - Ready for Team Alignment

**Next Action:** Review with all participating agents and roles to confirm scope, assign ownership, and begin implementation.

