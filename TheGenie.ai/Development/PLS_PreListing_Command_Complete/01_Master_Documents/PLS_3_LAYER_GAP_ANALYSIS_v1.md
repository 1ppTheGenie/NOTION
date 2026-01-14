# PLS RESO Engine - 3-Layer Gap Analysis
**Version:** 1.0  
**Created:** 01/02/2026  
**Last Updated:** 01/02/2026  
**Author:** Cursor AI Agent  
**Purpose:** Comprehensive gap analysis across Data Layer, Function Layer, and Interface Layer to identify what's complete, what's missing, and what connects them

---

## 🎯 EXECUTIVE SUMMARY

This document analyzes the **3-layer architecture** defined in `CONTRACT_PLS_to_GenieCloud_v6.1.md` Section 17 to identify:

1. **What's Complete** - Specifications, database scripts, contracts
2. **What's Missing** - Implementation gaps, missing connections
3. **What Connects Them** - API contracts, data flows, integration points

**Critical Finding:** All **specifications are complete**, but **implementation is pending** across all 3 layers. The gaps are primarily in **execution**, not design.

---

## 📋 REFERENCE DOCUMENTS

| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **CONTRACT_PLS_to_GenieCloud_v6.1.md** | 6.1 | ✅ Complete | Defines XML structure, API endpoints, 3-layer architecture |
| **PLS_MASTER_SPECIFICATION_v3.md** | 3.0 | ✅ Complete | Complete PLS system spec |
| **PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md** | 1.0 | ✅ Complete | SQL scripts ready to execute |
| **PLS_UI_SPECIFICATION_v1.md** | 1.0 | ✅ Complete | UI blueprint (eRealtor format) |
| **PLS_XML_GENERATION_SPEC_v1.md** | 1.0 | ✅ Complete | XML mapping & generation code |
| **TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md** | 1.0 | ✅ Complete | Field mapping deep dive |

---

## 🏗️ THE 3-LAYER ARCHITECTURE

From `CONTRACT_PLS_to_GenieCloud_v6.1.md` Section 17:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PAISLEY RESO LISTING ENGINE                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    DATA LAYER (Backend Infrastructure)              │  │
│  │  • Database structure (MlsListing.dbo.Listing, supporting tables)  │  │
│  │  • Stored procedures (usp_GetNextPlsNumber)                        │  │
│  │  • Data sources (TitleData, Historical MLS)                        │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                        │                                   │
│                                        ▼                                   │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    FUNCTION LAYER (API Endpoints)                   │  │
│  │  • POST /api/pls/create - Create new PLS listing                  │  │
│  │  • PUT /api/pls/{listingNumber} - Update existing listing         │  │
│  │  • GET /api/pls/{listingNumber} - Get listing details              │  │
│  │  • POST /api/pls/{listingNumber}/render - Generate XML            │  │
│  │  • Business logic (pre-population, validation, XML generation)    │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                        │                                   │
│                                        ▼                                   │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    INTERFACE LAYER (UI/XML Team)                      │  │
│  │  • Property Address Entry - System fetches TitleData                │  │
│  │  • Pre-populated Form - Shows TitleData + Historical MLS data       │  │
│  │  • Photo Upload Interface - S3 integration                         │  │
│  │  • Paisley AI Description - Pre-populated, user edits               │  │
│  │  • Status Selection - Coming Soon vs Private Listing                │  │
│  │  • XML Generation - Maps UI form data → XML structure               │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 LAYER-BY-LAYER GAP ANALYSIS

### LAYER 1: DATA LAYER (Backend Infrastructure)

#### ✅ WHAT'S COMPLETE

| Component | Status | Location | Notes |
|-----------|--------|---------|-------|
| **Database Schema Design** | ✅ Complete | `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md` | Zero schema changes approach documented |
| **PlsListingOwnership Table** | ✅ Spec Complete | SQL scripts ready | Table structure defined |
| **PlsNumberSequence Table** | ✅ Spec Complete | SQL scripts ready | Table structure defined |
| **usp_GetNextPlsNumber SP** | ✅ Spec Complete | SQL scripts ready | Stored procedure code ready |
| **Master Data Inserts** | ✅ Spec Complete | SQL scripts ready | StatusType 6, MlsId 999, PropertyCastTypeId 4 |
| **Permissions Setup** | ✅ Spec Complete | SQL scripts ready | Permissions 210-214, role grants |
| **Field Mapping Analysis** | ✅ Complete | `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md` | 318 TitleData fields → 93 MlsListing fields |

#### ❌ WHAT'S MISSING

| Gap | Impact | Priority | Owner |
|-----|--------|----------|-------|
| **Database Scripts NOT Executed** | Cannot create listings | 🔴 CRITICAL | DBA/Backend Team |
| **PlsListingOwnership Table** | No ownership tracking | 🔴 CRITICAL | DBA |
| **PlsNumberSequence Table** | Cannot generate PLS numbers | 🔴 CRITICAL | DBA |
| **usp_GetNextPlsNumber SP** | No number generation | 🔴 CRITICAL | DBA |
| **Master Data NOT Inserted** | StatusType 6, MlsId 999 missing | 🔴 CRITICAL | DBA |
| **Permissions NOT Granted** | Users can't access PLS | 🔴 CRITICAL | DBA/Admin |
| **TitleData Pre-Population Logic** | No automatic data fetch | 🟡 HIGH | Backend Team |
| **Historical MLS Conflict Resolution** | No sqft/beds/baths override | 🟡 HIGH | Backend Team |
| **Data Validation Rules** | No business logic enforcement | 🟡 HIGH | Backend Team |

#### 🔗 CONNECTION POINTS

| Connection | From | To | Status |
|------------|------|----|--------|
| **MlsListing.dbo.Listing** | Data Layer | Function Layer | ✅ Table exists, needs MlsId=999 data |
| **PlsListingOwnership** | Data Layer | Function Layer | ❌ Table not created |
| **TitleData.dbo.AttomDataAssessor** | Data Layer | Function Layer | ✅ Table exists, needs query logic |
| **Historical MLS Query** | Data Layer | Function Layer | ✅ Table exists, needs conflict resolution |

---

### LAYER 2: FUNCTION LAYER (API Endpoints)

#### ✅ WHAT'S COMPLETE

| Component | Status | Location | Notes |
|-----------|--------|---------|-------|
| **API Endpoint Specifications** | ✅ Complete | `CONTRACT_v6.1.md` Section 17 | All endpoints defined |
| **Business Logic Design** | ✅ Complete | `PLS_UI_SPECIFICATION_v1.md` Section 4.2 | Function definitions documented |
| **XML Generation Spec** | ✅ Complete | `PLS_XML_GENERATION_SPEC_v1.md` | Complete mapping & C# code |
| **Validation Rules** | ✅ Complete | `CONTRACT_v6.1.md` Section 7 | Required fields, format validation |
| **Error Handling Design** | ✅ Complete | `PLS_UI_SPECIFICATION_v1.md` Section 10 | Error codes, response formats |
| **GenieCloud Integration** | ✅ Contract Complete | `CONTRACT_v6.1.md` Section 4-6 | XML structure, API endpoints |

#### ❌ WHAT'S MISSING

| Gap | Impact | Priority | Owner |
|-----|--------|----------|-------|
| **PlsController NOT Created** | No API endpoints | 🔴 CRITICAL | Backend Team |
| **POST /api/pls/create** | Cannot create listings | 🔴 CRITICAL | Backend Team |
| **PUT /api/pls/{listingNumber}** | Cannot edit listings | 🔴 CRITICAL | Backend Team |
| **GET /api/pls/{listingNumber}** | Cannot retrieve listings | 🔴 CRITICAL | Backend Team |
| **GET /api/pls/my-listings** | Cannot list user's listings | 🔴 CRITICAL | Backend Team |
| **POST /api/pls/{listingNumber}/render** | Cannot generate XML | 🔴 CRITICAL | Backend Team |
| **PUT /api/pls/archive/{listingNumber}** | Cannot archive listings | 🟡 HIGH | Backend Team |
| **PlsService Business Logic** | No pre-population, validation | 🔴 CRITICAL | Backend Team |
| **TitleData Pre-Population** | No automatic data fetch | 🟡 HIGH | Backend Team |
| **Historical MLS Conflict Resolution** | No sqft override logic | 🟡 HIGH | Backend Team |
| **XML Generation Implementation** | No XML builder code | 🔴 CRITICAL | Backend Team |
| **GenieCloud API Integration** | Cannot trigger renders | 🔴 CRITICAL | Backend Team |
| **ListingCommandQueue Integration** | Cannot queue campaigns | 🟡 HIGH | Backend Team |
| **Paisley AI Integration** | Cannot generate descriptions | 🟡 HIGH | Backend Team |
| **S3 Photo Upload** | Cannot upload photos | 🟡 HIGH | Backend Team |
| **Geocoding Integration** | Cannot geocode addresses | 🟡 HIGH | Backend Team |
| **Ownership Validation** | No permission checks | 🔴 CRITICAL | Backend Team |

#### 🔗 CONNECTION POINTS

| Connection | From | To | Status |
|------------|------|----|--------|
| **API → Database** | Function Layer | Data Layer | ❌ Controllers not created |
| **API → GenieCloud** | Function Layer | GenieCloud | ✅ Contract exists, needs implementation |
| **API → Paisley AI** | Function Layer | Paisley | ❌ Integration not built |
| **API → S3** | Function Layer | AWS S3 | ❌ Upload logic not built |
| **API → ListingCommandQueue** | Function Layer | Listing Command | ❌ Queue logic not built |

---

### LAYER 3: INTERFACE LAYER (UI/XML Team)

#### ✅ WHAT'S COMPLETE

| Component | Status | Location | Notes |
|-----------|--------|---------|-------|
| **UI Specification** | ✅ Complete | `PLS_UI_SPECIFICATION_v1.md` | Complete eRealtor-style spec |
| **Screen Designs** | ✅ Complete | `PLS_UI_SPECIFICATION_v1.md` Section 3 | 4 screens with layouts |
| **User Flow Diagrams** | ✅ Complete | `PLS_UI_SPECIFICATION_v1.md` Section 2 | Create, Edit, Campaign flows |
| **Form Validation Rules** | ✅ Complete | `PLS_UI_SPECIFICATION_v1.md` Section 3.2 | Frontend validation documented |
| **Component Definitions** | ✅ Complete | `PLS_UI_SPECIFICATION_v1.md` Section 4.1 | TypeScript class definitions |
| **XML Generation Mapping** | ✅ Complete | `PLS_XML_GENERATION_SPEC_v1.md` | Complete field mapping |

#### ❌ WHAT'S MISSING

| Gap | Impact | Priority | Owner |
|-----|--------|----------|-------|
| **PlsMyListingsComponent** | No list view | 🔴 CRITICAL | Frontend Team |
| **PlsCreateComponent** | Cannot create listings | 🔴 CRITICAL | Frontend Team |
| **PlsEditComponent** | Cannot edit listings | 🔴 CRITICAL | Frontend Team |
| **Routing (/pls/*)** | No navigation | 🔴 CRITICAL | Frontend Team |
| **Menu Item** | No access point | 🔴 CRITICAL | Frontend Team |
| **Photo Upload UI** | Cannot upload photos | 🔴 CRITICAL | Frontend Team |
| **Area Selector** | Cannot select area | 🟡 HIGH | Frontend Team |
| **AI Description Generator UI** | Cannot generate descriptions | 🟡 HIGH | Frontend Team |
| **TitleData Pre-Population UI** | No auto-fill | 🟡 HIGH | Frontend Team |
| **Historical MLS Conflict Display** | No conflict flagging | 🟡 HIGH | Frontend Team |
| **Status Selection UI** | Cannot select Coming Soon/Private | 🔴 CRITICAL | Frontend Team |
| **Form Validation** | No client-side checks | 🟡 HIGH | Frontend Team |
| **Error Display** | No error messages | 🟡 HIGH | Frontend Team |
| **Loading States** | No progress indicators | 🟢 MEDIUM | Frontend Team |
| **Permission Checks** | No access control | 🔴 CRITICAL | Frontend Team |

#### 🔗 CONNECTION POINTS

| Connection | From | To | Status |
|------------|------|----|--------|
| **UI → API** | Interface Layer | Function Layer | ❌ Components not created |
| **UI → GenieCloud** | Interface Layer | GenieCloud | ❌ Render trigger not built |
| **UI → S3** | Interface Layer | AWS S3 | ❌ Photo upload not built |
| **UI → Paisley AI** | Interface Layer | Paisley | ❌ Description generator not built |

---

## 🔄 CROSS-LAYER GAPS

### Gap 1: Data Pre-Population Flow

**Current State:**
- ✅ Field mapping analysis complete
- ✅ TitleData schema documented
- ✅ Historical MLS conflict strategy defined

**Missing:**
- ❌ Backend API to fetch TitleData by address/APN
- ❌ Backend API to query historical MLS by address/APN
- ❌ Conflict resolution logic (sqft, beds/baths)
- ❌ UI component to display pre-populated data
- ❌ UI component to flag conflicts (asterisk for sqft)

**Connection Needed:**
```
User enters address
    ↓
UI calls API: GET /api/pls/pre-populate?address={address}
    ↓
Backend queries TitleData + Historical MLS
    ↓
Backend resolves conflicts (sqft, etc.)
    ↓
Backend returns pre-populated data + conflict flags
    ↓
UI displays form with pre-filled data + conflict indicators
```

**Priority:** 🔴 CRITICAL

---

### Gap 2: XML Generation Flow

**Current State:**
- ✅ XML structure defined in Contract v6.1
- ✅ Field mapping complete
- ✅ C# code example provided

**Missing:**
- ❌ Backend service to build XML from listing data
- ❌ Agent data fetching (UserMarketingProfile, logos)
- ❌ Area data fetching
- ❌ Photo URL collection
- ❌ XML validation before sending to GenieCloud

**Connection Needed:**
```
User clicks "Generate Content Kit"
    ↓
UI calls API: POST /api/pls/{listingNumber}/render
    ↓
Backend loads listing from MlsListing.dbo.Listing
    ↓
Backend loads agent data from UserMarketingProfile
    ↓
Backend loads area data
    ↓
Backend loads photos from MlsListing.dbo.Photo
    ↓
Backend builds XML (PlsService.BuildXml)
    ↓
Backend validates XML against contract
    ↓
Backend POSTs to GenieCloud /api/render
    ↓
Backend queues ListingCommandQueue
    ↓
Backend returns render ID + collection URL
    ↓
UI displays "Generating..." status
```

**Priority:** 🔴 CRITICAL

---

### Gap 3: Photo Upload Flow

**Current State:**
- ✅ S3 bucket identified (genie-cloud or genie-cloud-stage)
- ✅ Path structure defined: `genie-pages/{pls-number}/photos/{filename}`

**Missing:**
- ❌ Backend API endpoint for photo upload
- ❌ S3 upload service integration
- ❌ Photo URL generation
- ❌ MlsListing.dbo.Photo INSERT logic
- ❌ UI drag-and-drop uploader
- ❌ Photo reordering UI
- ❌ Primary photo selection UI

**Connection Needed:**
```
User drags photos to uploader
    ↓
UI uploads to: POST /api/pls/upload-photo
    ↓
Backend uploads to S3
    ↓
Backend returns HTTPS URL
    ↓
UI displays photo thumbnails
    ↓
User sets primary photo, reorders
    ↓
UI saves: PUT /api/pls/{listingNumber}/photos
    ↓
Backend updates MlsListing.dbo.Photo
```

**Priority:** 🔴 CRITICAL

---

### Gap 4: Listing Command Integration

**Current State:**
- ✅ PropertyCastTypeId=4 defined for PLS
- ✅ ListingCommandQueue table structure known
- ✅ Workflow execution pattern documented

**Missing:**
- ❌ Backend logic to queue PLS listings
- ❌ PropertyCastTypeId=4 validation
- ❌ MlsId=999 handling in workflow
- ❌ UI "Start Campaign" button integration
- ❌ Reuse of existing ListingCommandInitiateComponent

**Connection Needed:**
```
User clicks "Start Campaign"
    ↓
UI navigates to /pls/initiate/{plsNumber}
    ↓
UI reuses ListingCommandInitiateComponent
    ↓
User selects area, campaign options
    ↓
UI processes payment (same as LC)
    ↓
UI calls API: POST /api/pls/{plsNumber}/initiate-campaign
    ↓
Backend validates PropertyCastTypeId=4
    ↓
Backend INSERTs into ListingCommandQueue
    → MlsId = 999
    → MlsNumber = "PLS-2025-00001"
    → PropertyCastTypeId = 4
    → ListingJson = {full listing data}
    ↓
Windows Service picks up queue
    ↓
Workflow executes (same as LC)
```

**Priority:** 🟡 HIGH

---

### Gap 5: Paisley AI Description Generation

**Current State:**
- ✅ ChatStartTypeId=3 (Pre-Listing Focused) identified
- ✅ Uses Assessor data (TitleData)
- ✅ Integration point documented

**Missing:**
- ❌ Backend API call to Paisley AI
- ❌ Property address → PropertyId lookup
- ❌ ChatStartTypeId=3 request formatting
- ❌ UI "Generate with AI" button
- ❌ UI loading state during generation
- ❌ UI text area population

**Connection Needed:**
```
User clicks "Generate with AI"
    ↓
UI calls API: POST /api/pls/generate-description
    → address: "10037 Rebecca Place, Boerne, TX 78006"
    ↓
Backend looks up PropertyId from TitleData
    ↓
Backend calls Paisley API:
    → ChatStartTypeId = 3
    → PropertyId = {from TitleData}
    → message: "Generate compelling property description"
    ↓
Paisley returns generated description
    ↓
Backend returns description text
    ↓
UI populates description text area
```

**Priority:** 🟡 HIGH

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 1: Data Layer (Foundation)

- [ ] **Execute Database Scripts**
  - [ ] Create PlsListingOwnership table
  - [ ] Create PlsNumberSequence table
  - [ ] Create usp_GetNextPlsNumber stored procedure
  - [ ] Insert StatusType 6 (Private Listing)
  - [ ] Insert MlsId 999 (PLS)
  - [ ] Insert PropertyCastTypeId 4 (PLS)
  - [ ] Insert Permissions 210-214
  - [ ] Grant permissions to roles (Affiliate, Core Agent, Elite, Ultimate, Super User)
  - [ ] Verify all objects created

- [ ] **Build Data Pre-Population Services**
  - [ ] Create TitleData query service (by address/APN)
  - [ ] Create Historical MLS query service (by address/APN)
  - [ ] Create conflict resolution service (sqft, beds/baths)
  - [ ] Create data mash service (TitleData + Historical MLS)

### Phase 2: Function Layer (API)

- [ ] **Create PlsController**
  - [ ] POST /api/pls/create
  - [ ] PUT /api/pls/{listingNumber}
  - [ ] GET /api/pls/{listingNumber}
  - [ ] GET /api/pls/my-listings
  - [ ] POST /api/pls/{listingNumber}/render
  - [ ] PUT /api/pls/archive/{listingNumber}
  - [ ] POST /api/pls/pre-populate
  - [ ] POST /api/pls/upload-photo
  - [ ] PUT /api/pls/{listingNumber}/photos
  - [ ] POST /api/pls/generate-description
  - [ ] POST /api/pls/{listingNumber}/initiate-campaign

- [ ] **Create PlsService**
  - [ ] GetNextPlsNumber() - Call stored procedure
  - [ ] PrePopulateFromTitleData() - Query TitleData
  - [ ] PrePopulateFromHistoricalMLS() - Query historical listings
  - [ ] ResolveConflicts() - Sqft, beds/baths override
  - [ ] BuildXml() - Generate XML from listing
  - [ ] ValidateXml() - Check against contract
  - [ ] UploadPhotoToS3() - S3 integration
  - [ ] GeocodeAddress() - Geocoding API
  - [ ] GenerateAIDescription() - Paisley AI call
  - [ ] QueueListingCommand() - Insert into queue

- [ ] **Integrate External Services**
  - [ ] GenieCloud API client
  - [ ] Paisley AI API client
  - [ ] S3 upload service
  - [ ] Geocoding API client

### Phase 3: Interface Layer (UI)

- [ ] **Create Angular Components**
  - [ ] PlsMyListingsComponent (list view)
  - [ ] PlsCreateComponent (create form)
  - [ ] PlsEditComponent (edit form)
  - [ ] PlsPhotoUploadComponent (photo uploader)
  - [ ] PlsAreaSelectorComponent (area picker)
  - [ ] PlsAIDescriptionComponent (AI generator)

- [ ] **Add Routing**
  - [ ] /pls/my-listings
  - [ ] /pls/create
  - [ ] /pls/edit/{plsNumber}
  - [ ] /pls/initiate/{plsNumber}

- [ ] **Add Navigation**
  - [ ] Menu item (requires Menu PLS permission)
  - [ ] Left nav link
  - [ ] Breadcrumbs

- [ ] **Implement Features**
  - [ ] Address entry with auto-geocode
  - [ ] TitleData pre-population display
  - [ ] Historical MLS conflict flagging (asterisk)
  - [ ] Photo drag-and-drop upload
  - [ ] Photo reordering
  - [ ] Primary photo selection
  - [ ] AI description generation
  - [ ] Status selection (Coming Soon/Private)
  - [ ] Form validation
  - [ ] Error display
  - [ ] Loading states
  - [ ] Permission checks

- [ ] **Integrate Listing Command**
  - [ ] Reuse ListingCommandInitiateComponent
  - [ ] Handle MlsId=999 in component
  - [ ] Handle PropertyCastTypeId=4

---

## 🎯 PRIORITY MATRIX

| Gap | Layer | Priority | Effort | Dependencies |
|-----|-------|----------|--------|--------------|
| Execute Database Scripts | Data | 🔴 CRITICAL | Low | DBA access |
| Create PlsController | Function | 🔴 CRITICAL | Medium | Database scripts |
| Create PlsService | Function | 🔴 CRITICAL | High | Database scripts |
| Create PlsMyListingsComponent | Interface | 🔴 CRITICAL | Medium | API endpoints |
| Create PlsCreateComponent | Interface | 🔴 CRITICAL | High | API endpoints |
| XML Generation | Function | 🔴 CRITICAL | Medium | Listing data |
| GenieCloud Integration | Function | 🔴 CRITICAL | Low | XML generation |
| Photo Upload | Function + Interface | 🔴 CRITICAL | Medium | S3 access |
| TitleData Pre-Population | Function + Interface | 🟡 HIGH | High | TitleData access |
| Historical MLS Conflict | Function + Interface | 🟡 HIGH | Medium | Historical data |
| Paisley AI Integration | Function + Interface | 🟡 HIGH | Low | Paisley API |
| Listing Command Integration | Function + Interface | 🟡 HIGH | Low | Existing LC code |

---

## 🔗 CONTRACT ALIGNMENT

### Contract v6.1 Requirements

| Requirement | Status | Gap |
|-------------|--------|-----|
| **XML Structure** | ✅ Defined | None - contract complete |
| **API Endpoints** | ✅ Defined | ❌ Not implemented |
| **Validation Rules** | ✅ Defined | ❌ Not enforced |
| **Error Handling** | ✅ Defined | ❌ Not implemented |
| **Status Codes** | ✅ Defined | ❌ StatusType 6 not inserted |
| **Theme Guidance** | ✅ Defined | None - contract complete |
| **User Role Requirements** | ✅ Defined | ❌ Permissions not granted |
| **Collection System** | ✅ Defined | None - GenieCloud owns |
| **CTA System** | ✅ Defined | None - GenieCloud owns |
| **Asset Selection** | ✅ Defined | None - GenieCloud owns |

---

## 📝 DISCOVERY QUESTIONS

### For Backend Team

1. **Database Access:** Do we have write access to execute scripts? (sa/neo222)
2. **S3 Access:** Do we have AWS credentials for photo uploads?
3. **Paisley API:** What's the endpoint and authentication for ChatStartTypeId=3?
4. **Geocoding:** What service do we use? (Google Maps, Mapbox, etc.)
5. **GenieCloud API:** What's the exact endpoint URL and authentication?

### For Frontend Team

1. **Component Library:** What Angular components exist for forms, uploads, selectors?
2. **Permission System:** How do we check permissions in Angular? (hasPermission service?)
3. **Routing:** Where should PLS routes live? (new module or existing?)
4. **Menu System:** How do we add menu items dynamically based on permissions?

### For Integration

1. **Listing Command:** Can we reuse ListingCommandInitiateComponent as-is, or need modifications?
2. **GenieCloud:** What's the render status polling mechanism?
3. **Workflow:** Does PropertyCastTypeId=4 workflow exist, or need creation?

---

## ✅ NEXT STEPS

### Immediate (This Week)

1. **Execute Database Scripts** - DBA/Backend Team
2. **Create PlsController Skeleton** - Backend Team
3. **Create PlsService Skeleton** - Backend Team
4. **Create PlsMyListingsComponent** - Frontend Team
5. **Create PlsCreateComponent** - Frontend Team

### Short-Term (Next 2 Weeks)

1. **Implement Data Pre-Population** - Backend Team
2. **Implement XML Generation** - Backend Team
3. **Implement Photo Upload** - Backend + Frontend Teams
4. **Implement GenieCloud Integration** - Backend Team
5. **Complete UI Forms** - Frontend Team

### Medium-Term (Next Month)

1. **Paisley AI Integration** - Backend + Frontend Teams
2. **Listing Command Integration** - Backend + Frontend Teams
3. **Historical MLS Conflict Resolution** - Backend Team
4. **End-to-End Testing** - All Teams

---

## 📚 DOCUMENT LOCATIONS

- **This Document:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\PLS_RESO_ENGINE\PLS_3_LAYER_GAP_ANALYSIS_v1.md`
- **Contract:** `D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\Docs\CONTRACT_PLS_to_GenieCloud_v6.1.md`
- **Database Spec:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`
- **UI Spec:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\PLS_UI_SPECIFICATION_v1.md`
- **XML Spec:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\PLS_XML_GENERATION_SPEC_v1.md`

---

**Status:** ✅ Gap Analysis Complete - Ready for Team Alignment

**Next Action:** Review with all participating agents and roles to confirm gaps and assign ownership.

