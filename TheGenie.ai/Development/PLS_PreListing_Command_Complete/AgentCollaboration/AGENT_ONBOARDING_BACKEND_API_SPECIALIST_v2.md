# Agent Onboarding: Backend API Specialist - Complete Educational Content

**Version:** 2.0  
**Created:** 01/14/2026 3:15 AM  
**Last Updated:** 01/14/2026 3:15 AM  
**Author:** JR (Project Manager)  
**Status:** ✅ **COMPREHENSIVE ONBOARDING - READY FOR AGENT**

---

## 🎯 WELCOME TO THE PLS PROJECT

You've been assigned the **Backend API Specialist** role for the PLS (Paisley RESO Listing Engine) project. This is a comprehensive onboarding document with ALL context, prior discovery, ecosystem knowledge, integration points, and technical specifications you need to succeed.

**Your Mission:** Build the REST API layer that connects the database, frontend UI, and external services (Title Genie, Paisley AI, GenieCloud) into a cohesive system.

---

## 📚 SECTION 1: PROJECT CONTEXT & VISION

### What is PLS?

**PLS (Paisley RESO Listing Engine)** is a private listing service that enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate full marketing asset kits (landing pages, social ads, brochures) automatically
- Automate circle prospecting campaigns via Listing Command integration
- Future: One-button push to publish listings directly to Bridge/Trestle MLSs via RESO Insert

### Your Role in the System

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   FRONTEND   │────────▶│   BACKEND    │────────▶│   DATABASE   │
│      UI      │  HTTP   │     API      │   SQL   │   (YOU ENABLE)│
│              │         │   (YOU BUILD)│         │              │
└──────────────┘         └──────┬───────┘         └──────────────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
                    ▼           ▼           ▼
            ┌──────────┐  ┌──────────┐  ┌──────────┐
            │  TITLE   │  │  PAISLEY │  │  GENIE   │
            │  GENIE   │  │    AI    │  │  CLOUD   │
            └──────────┘  └──────────┘  └──────────┘
```

**You are the central hub** that:
- Receives requests from Frontend UI
- Queries Database (via Database Specialist's stored procedures)
- Calls external services (Title Genie, Paisley AI, GenieCloud)
- Returns formatted responses to Frontend

---

## 📚 SECTION 2: ECOSYSTEM INTEGRATION CONTEXT

### The Big Picture - 4 System Integration

PLS sits at the intersection of 4 major systems:

| System | Role | Your Integration Point | API Endpoint |
|--------|------|------------------------|--------------|
| **TitleGenie** | Property data source | Pre-populate form data | `POST /api/pls/pre-populate` |
| **Paisley AI** | Description generation | Generate AI descriptions | `POST /api/pls/generate-description` |
| **GenieCloud** | Asset rendering | Generate XML and trigger render | `POST /api/pls/{listingNumber}/render` |
| **Listing Command** | Circle prospecting | Queue PLS listings | `POST /api/pls/{listingNumber}/initiate-campaign` |

### Title Genie Integration

**Purpose:** Pre-populate PLS form with property data

**Data Sources:**
- `TitleData.dbo.AttomDataAssessor` (318 fields - 100% imported)
- `TitleData.dbo.ViewAssessor_v3` (315+ fields)
- `MlsListing.dbo.Listing` (Historical MLS data)

**Key Fields for Pre-Population:**
- `ParcelNumberFormatted` (APN)
- `StreetNumber`, `StreetName`, `City`, `State`, `Zip`
- `BedroomsTotal`, `BathroomsTotal`, `LivingArea`, `LotSizeSquareFeet`
- `YearBuilt`, `PropertyType`, `GarageSpaces`

**Field Mapping Document:**
- `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
- Maps 318 TitleData fields to 93 MlsListing fields

**Your Implementation:**
- `POST /api/pls/pre-populate` endpoint
- Query TitleData by PlaceKey or address
- Return pre-populated data + conflict flags
- Frontend displays data with asterisks for conflicts

### Paisley AI Integration

**Purpose:** Generate AI descriptions for PLS listings

**Paisley Chat Type:** `ChatStartTypeId=3` (Pre-Listing Focused)

**Input Data:**
- Listing data (address, property details)
- Selected area data (for market context)
- Agent preferences (optional)

**Paisley API Endpoint:**
- `POST /api/paisley/chat`
- Request body includes `chatStartTypeId: 3`

**Your Implementation:**
- `POST /api/pls/generate-description` endpoint
- Collect listing data + area data
- Call Paisley API with ChatStartTypeId=3
- Return generated description
- Frontend displays with "Edit" button

**Reference Documents:**
- `Paisley/PRELISTING_API_SPECIFICATION_v1.md` - Paisley API spec
- `Paisley/PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md` - User flow

### GenieCloud Integration

**Purpose:** Generate marketing assets (landing pages, social ads, brochures)

**Contract:** `CONTRACT_PLS_to_GenieCloud_v6.1.md` - **MUST FOLLOW EXACTLY**

**XML Generation:**
- You generate XML per contract specification
- XML includes: listing data, agent data, area data, photos
- XML structure defined in contract Section 4

**GenieCloud API:**
- `POST https://cloud-api.thegenie.ai/api/render`
- Request includes: `userId`, `listingId`, `assets[]`, `theme`, `themeHue`, `xml`
- Response includes: `renderId`, `status`, `collectionUrl`

**Your Implementation:**
- `POST /api/pls/{listingNumber}/render` endpoint
- Load listing, agent, area data
- Build XML (coordinate with XML Specialist)
- Call GenieCloud API
- Return collection URL

**Coordination:** Work with XML/Integration Specialist on XML generation logic

### Listing Command Integration

**Purpose:** Automate circle prospecting for PLS listings

**PropertyCastTypeId:** `4` (for PLS listings)

**Queue Table:** `FarmGenie.dbo.ListingCommandQueue`

**Your Implementation:**
- When PLS listing created with `PropertyCastTypeId=4`
- Insert into `ListingCommandQueue`:
  ```sql
  INSERT INTO ListingCommandQueue (
      MlsID, MlsNumber, PropertyCastTypeId, AspNetUserId, AreaId, CreateDate
  )
  VALUES (777, 'PLS100000A', 4, @userId, @areaId, GETDATE())
  ```

**UI Integration:** Frontend reuses `ListingCommandInitiateComponent` with route parameter `{plsNumber}`

---

## 📚 SECTION 3: API ENDPOINTS - COMPLETE SPECIFICATIONS

### Core CRUD Endpoints

#### 1. POST /api/pls/create

**Purpose:** Create new PLS listing

**Request Body:**
```json
{
  "address": {
    "streetNumber": "10037",
    "streetName": "Rebecca Place",
    "city": "Boerne",
    "state": "TX",
    "zip": "78006"
  },
  "propertyDetails": {
    "price": 450000,
    "bedrooms": 3,
    "bathrooms": 3,
    "sqft": 2500,
    "lotSize": 0.5,
    "yearBuilt": 2020,
    "propertyType": "Single Family"
  },
  "statusTypeId": 14, // 6=Private, 14=Coming Soon
  "description": "Beautiful home...",
  "photos": ["https://s3.../photo1.jpg", ...],
  "areaId": 12345
}
```

**Your Implementation:**
1. Get current user from JWT token
2. Generate PLS number: `EXEC usp_GetNextPlsNumber`
3. INSERT into `MlsListing.dbo.Listing` (MlsId=777, PropertyCastTypeId=4)
4. INSERT into `MlsListing.dbo.Photo` (for each photo)
5. INSERT into `FarmGenie.dbo.PlsListingOwnership`
6. INSERT into `FarmGenie.dbo.ListingCommandQueue` (if PropertyCastTypeId=4)
7. Return created listing with PLS number

**Response:**
```json
{
  "plsNumber": "PLS100000A",
  "listingId": 12345,
  "status": "created",
  "collectionUrl": null
}
```

#### 2. PUT /api/pls/{listingNumber}

**Purpose:** Update existing PLS listing

**Request Body:** Same as create (all fields optional)

**Your Implementation:**
1. Validate user owns listing (check `PlsListingOwnership`)
2. UPDATE `MlsListing.dbo.Listing`
3. Handle photo updates (add/remove/reorder)
4. Return updated listing

#### 3. GET /api/pls/{listingNumber}

**Purpose:** Get PLS listing details

**Your Implementation:**
1. Validate user owns listing
2. Query `MlsListing.dbo.Listing` with MlsId=777
3. JOIN with photos, agent data, area data
4. Return complete listing object

**Response:**
```json
{
  "plsNumber": "PLS100000A",
  "listing": { /* full listing data */ },
  "photos": [ /* photo array */ ],
  "agent": { /* agent data */ },
  "area": { /* area data */ }
}
```

#### 4. GET /api/pls/my-listings

**Purpose:** Get all PLS listings for current user

**Your Implementation:**
1. Get current user from JWT token
2. Query `PlsListingOwnership` for user's listings
3. JOIN with `MlsListing.dbo.Listing`
4. Return list of listings

**Response:**
```json
[
  {
    "plsNumber": "PLS100000A",
    "address": "10037 Rebecca Place, Boerne, TX 78006",
    "statusTypeId": 14,
    "createdAt": "2026-01-14T10:00:00Z",
    "collectionUrl": "https://cloud.thegenie.ai/genie-collection/..."
  },
  ...
]
```

#### 5. PUT /api/pls/archive/{listingNumber}

**Purpose:** Archive PLS listing

**Your Implementation:**
1. Validate user owns listing
2. UPDATE `MlsListing.dbo.Listing` StatusTypeID to archived status
3. UPDATE `PlsListingOwnership` IsActive = false
4. Return success

### Integration Endpoints

#### 6. POST /api/pls/pre-populate

**Purpose:** Pre-populate form with Title Genie data

**Request Body:**
```json
{
  "placeKey": "ChIJ...", // Google Places Place ID
  "address": "10037 Rebecca Place, Boerne, TX 78006"
}
```

**Your Implementation:**
1. Query `TitleData.dbo.AttomDataAssessor` by PlaceKey or address
2. Query `MlsListing.dbo.Listing` for historical MLS data
3. Map fields using `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
4. Return pre-populated data + conflict flags

**Response:**
```json
{
  "propertyData": {
    "bedrooms": 3,
    "bathrooms": 3,
    "sqft": 2500,
    ...
  },
  "conflicts": {
    "price": true, // User should verify
    "yearBuilt": false
  }
}
```

#### 7. POST /api/pls/generate-description

**Purpose:** Generate AI description using Paisley

**Request Body:**
```json
{
  "listingData": { /* property details */ },
  "areaId": 12345
}
```

**Your Implementation:**
1. Collect listing data + area data
2. Call Paisley API: `POST /api/paisley/chat` with `chatStartTypeId: 3`
3. Return generated description

**Response:**
```json
{
  "description": "Nestled in the heart of Boerne...",
  "generatedAt": "2026-01-14T10:00:00Z"
}
```

#### 8. POST /api/pls/upload-photo

**Purpose:** Upload property photos to S3

**Request:** Multipart form data with photo files

**Your Implementation:**
1. Validate file types (jpg, png)
2. Upload to S3 bucket (genie-cloud, us-west-1)
3. Return photo URLs

**Response:**
```json
{
  "photos": [
    {
      "url": "https://genie-cloud.s3.us-west-1.amazonaws.com/...",
      "displayOrder": 1
    },
    ...
  ]
}
```

#### 9. POST /api/pls/{listingNumber}/render

**Purpose:** Generate XML and trigger GenieCloud render

**Your Implementation:**
1. Load listing, agent, area data
2. Build XML (coordinate with XML Specialist - follow contract v6.1)
3. Call GenieCloud API: `POST https://cloud-api.thegenie.ai/api/render`
4. Insert into `ListingCommandQueue` (if PropertyCastTypeId=4)
5. Return collection URL

**Response:**
```json
{
  "renderId": "pls-PLS100000A",
  "status": "queued",
  "collectionUrl": "https://cloud.thegenie.ai/genie-collection/..."
}
```

**Coordination:** Work with XML/Integration Specialist on XML generation

---

## 📚 SECTION 4: PRIOR DISCOVERY FINDINGS

### What Was Discovered Before You

#### 1. Database Connection Discovery

**Finding:** Production SQL 2012 server at `192.168.29.45,1433`

**Credentials:**
- **READ-ONLY:** `cursor` / `1ppINSAyay$` (for queries)
- **WRITE ACCESS:** `sa` / `neo222` (for INSERT/UPDATE/DELETE)

**Databases:**
- `FarmGenie` (main app database)
- `MlsListing` (listings database)
- `TitleData` (Attom data database)

**Connection Strings:** Read from `Web.config` in your project

#### 2. Stored Procedures Discovery

**Finding:** Database Specialist creates these stored procedures:

- `usp_GetNextPlsNumber` - Generate PLS number (format: `PLS100000A`)
- `usp_GetPlsListingByNumber` - Get PLS listing by number
- `usp_GetPlsListingsByUser` - Get all PLS listings for a user

**Your Usage:** Call these from your API controllers

#### 3. Paisley API Discovery

**Finding:** Paisley has existing API for AI content generation

**Endpoint:** `POST /api/paisley/chat`

**ChatStartTypeId=3:** Pre-Listing Focused (exactly what PLS needs)

**Reference:** `Paisley/PRELISTING_API_SPECIFICATION_v1.md`

#### 4. GenieCloud Contract Discovery

**Finding:** GenieCloud has strict XML contract

**Contract:** `CONTRACT_PLS_to_GenieCloud_v6.1.md`

**CRITICAL:** Must follow contract exactly - no deviations

**XML Structure:** Defined in contract Section 4

**Coordination:** XML/Integration Specialist handles XML generation, but you coordinate on `/render` endpoint

#### 5. Title Genie Data Discovery

**Finding:** TitleData has 318 fields (100% imported)

**Key Tables:**
- `TitleData.dbo.AttomDataAssessor` (318 fields)
- `TitleData.dbo.ViewAssessor_v3` (315+ fields)

**Field Mapping:** `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`

---

## 📚 SECTION 5: YOUR DELIVERABLES - PHASE 2

### Must Complete (In Order)

1. **Wait for Phase 1 Completion**
   - Monitor Database Specialist status
   - Verify all stored procedures exist
   - Verify database schema is ready

2. **Create Controller Structure**
   - `PlsController.cs` - Main PLS controller
   - `DataController.PLS.cs` - Partial class for data endpoints
   - Reference: `08_Source_Code/PlsController_Complete_v1.cs`

3. **Create Service Layer**
   - `PlsService.cs` - Business logic
   - `TitleGenieService.cs` - Title Genie integration
   - `PaisleyService.cs` - Paisley AI integration
   - `GenieCloudService.cs` - GenieCloud integration (coordinate with XML Specialist)

4. **Implement Core CRUD Endpoints**
   - `POST /api/pls/create`
   - `PUT /api/pls/{listingNumber}`
   - `GET /api/pls/{listingNumber}`
   - `GET /api/pls/my-listings`
   - `PUT /api/pls/archive/{listingNumber}`

5. **Implement Integration Endpoints**
   - `POST /api/pls/pre-populate` (Title Genie)
   - `POST /api/pls/generate-description` (Paisley AI)
   - `POST /api/pls/upload-photo` (S3)
   - `POST /api/pls/{listingNumber}/render` (GenieCloud - coordinate with XML Specialist)

6. **Authentication & Authorization**
   - JWT token validation
   - User ownership verification
   - Permission checks (Permission 211: Menu PLS)

7. **Data Validation & Error Handling**
   - Input validation
   - Business rule validation
   - Error responses (proper HTTP status codes)

8. **Testing**
   - Unit tests for service layer
   - Integration tests for endpoints
   - Test with Postman/Swagger

9. **Documentation**
   - API documentation for Frontend Specialist
   - Update status file
   - Announce Phase 2 complete

### Success Criteria

- ✅ All endpoints return correct HTTP status codes
- ✅ Data validation prevents invalid input
- ✅ Integration with Database Specialist's stored procedures working
- ✅ Title Genie pre-population working
- ✅ Paisley AI description generation working
- ✅ GenieCloud render endpoint working (with XML Specialist)
- ✅ Ready for Frontend UI integration

---

## 📚 SECTION 6: CRITICAL TECHNICAL SPECIFICATIONS

### Database Connection

**Production SQL 2012:**
```
Server=192.168.29.45,1433
Database=FarmGenie (or MlsListing or TitleData)
User Id=cursor (read-only) or sa (write)
Password=1ppINSAyay$ (read-only) or neo222 (write)
```

**Connection Strings:** Read from `Web.config` in your project

### PLS Number Format

**Format:** `PLS{6-digit}{letter}` (e.g., `PLS100000A`)

**Generation:** Call `EXEC usp_GetNextPlsNumber`

### MlsId and StatusTypeID

**MlsId:** `777` (NOT 999 - that was old spec)

**StatusTypeID:**
- `6` = Private Listing (may need INSERT if doesn't exist)
- `14` = Coming Soon (exists in database)

**PropertyCastTypeId:** `4` (for Listing Command integration)

### Authentication

**JWT Token:** Extract user ID from token claims

**User Ownership:** Verify via `PlsListingOwnership` table

**Permissions:** Check `Permission 211` (Menu PLS) for menu access

---

## 📚 SECTION 7: MUST-READ DOCUMENTS (In Priority Order)

### Priority 1: Core API Documents (READ FIRST)

1. **Your Role Definition**
   - `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`
   - **Why:** Your exact responsibilities and deliverables

2. **Project Blueprint - API Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 5
   - **Why:** Complete API endpoint specifications

3. **Reference Implementations**
   - `08_Source_Code/PlsController_Complete_v1.cs`
   - `08_Source_Code/DataController_PLS_Complete_v1.cs`
   - **Why:** Starting point for your implementation

4. **Workspace Memory Log - API Development**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_03_API_DEVELOPMENT_v1.md`
   - **Why:** Historical context and API design decisions

### Priority 2: Integration Documents (CRITICAL)

5. **Title Genie Integration - Field Mapping**
   - `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
   - **Why:** Maps 318 TitleData fields to 93 MlsListing fields for pre-population

6. **Title Genie Master Compilation**
   - `D:\Cursor\TheGenie.ai\Development\TitleGenie\TITLEGENIE_MASTER_COMPILATION_v1.md`
   - **Why:** Complete Title Genie context and data sources

7. **Paisley Integration - API Specification**
   - `D:\Cursor\TheGenie.ai\Development\Paisley\PRELISTING_API_SPECIFICATION_v1.md`
   - **Why:** Paisley API integration points (ChatStartTypeId=3)

8. **Paisley Complete Walkthrough**
   - `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md`
   - **Why:** User flow and integration context

9. **GenieCloud Contract**
   - `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md`
   - **Why:** XML generation contract (coordinate with XML Specialist)

### Priority 3: Database Context (Reference)

10. **Database Schema**
    - `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
    - **Why:** Understand database structure you'll be working with

11. **Stored Procedures**
    - `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
    - **Why:** Stored procedures you'll call from API

### Priority 4: Ecosystem Context (Reference)

12. **Ecosystem Document Catalog**
    - `01_Master_Documents/PLS_ECOSYSTEM_DOCUMENT_CATALOG_v1.md`
    - **Why:** Understand how PLS fits with Paisley, Title Genie, GenieCloud

---

## 📚 SECTION 8: COMMON PITFALLS & SOLUTIONS

### Pitfall 1: Using Wrong MlsId

**❌ WRONG:** `MlsId = 999` (old spec)  
**✅ CORRECT:** `MlsId = 777` (current spec)

### Pitfall 2: Not Validating User Ownership

**❌ WRONG:** Allowing any user to access any listing  
**✅ CORRECT:** Always verify user owns listing via `PlsListingOwnership` table

### Pitfall 3: Not Following GenieCloud Contract

**❌ WRONG:** Deviating from contract v6.1  
**✅ CORRECT:** Follow contract exactly - coordinate with XML Specialist

### Pitfall 4: Not Handling Errors Properly

**❌ WRONG:** Returning 500 for all errors  
**✅ CORRECT:** Return appropriate HTTP status codes (400, 401, 403, 404, 500)

### Pitfall 5: Not Testing Integration Points

**❌ WRONG:** Assuming external APIs work without testing  
**✅ CORRECT:** Test Title Genie, Paisley, GenieCloud integrations independently

---

## 📚 SECTION 9: DAILY WORKFLOW

### Morning (5 minutes)
1. Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for project status
2. Check Database Specialist status for Phase 1 completion
3. Check `AgentCollaboration/BLOCKERS_v1.md` for blockers
4. Review your status file: `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`

### During Work
1. Implement endpoints using reference implementations
2. Test each endpoint independently
3. Integrate with Title Genie and Paisley
4. Coordinate with XML Specialist on `/render` endpoint
5. Update progress in status file

### End of Day (5 minutes)
1. Update `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md` with progress
2. Document any blockers in `AgentCollaboration/BLOCKERS_v1.md`
3. Update deliverables checklist

---

## 📚 SECTION 10: COLLABORATION & HANDOFFS

### Dependencies
- **Database Specialist** - Must wait for Phase 1 completion (schema and stored procedures)

### Handoffs TO
- **Frontend UI Specialist** - Provides API documentation and endpoint specs
- **XML/Integration Specialist** - Coordinates on `/render` endpoint implementation

### Communication
- **Daily:** Update `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`
- **Blockers:** Document in `AgentCollaboration/BLOCKERS_v1.md`
- **Completions:** Announce in `AgentCollaboration/HANDOFFS_v1.md`

---

## ✅ ONBOARDING CHECKLIST

Before you start work, verify you've completed:

- [ ] Read this entire onboarding document
- [ ] Read your role definition (`AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`)
- [ ] Read Project Blueprint Section 5 (API Endpoints)
- [ ] Reviewed reference implementations
- [ ] Read Title Genie field mapping document
- [ ] Read Paisley API specification
- [ ] Read GenieCloud contract (for `/render` endpoint)
- [ ] Understood database connection requirements
- [ ] Understood all integration points
- [ ] Set up status tracking file
- [ ] Waiting for Phase 1 completion (Database Specialist)

---

## 🎯 NEXT STEPS

1. **Complete onboarding checklist above**
2. **Wait for Phase 1 completion** - Monitor Database Specialist status
3. **Review reference implementations** - Understand code structure
4. **Plan integration points** - Title Genie, Paisley, GenieCloud
5. **Begin implementation** - Start with core CRUD endpoints
6. **Test each endpoint** - Verify independently
7. **Integrate external services** - Title Genie, Paisley
8. **Coordinate with XML Specialist** - `/render` endpoint
9. **Update status and announce Phase 2 complete**

---

## 📞 ESCALATION

**If Blocked:**
1. Document in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag Database Specialist if schema issues
3. Tag XML Specialist if render endpoint coordination needed
4. Tag Project Manager (JR) if needed
5. Update status file with blocker details

**Questions?**
- Review your role definition first
- Check workspace memory logs for historical context
- Review integration documents (Title Genie, Paisley, GenieCloud)
- Document questions in blockers file if needed

---

## 📚 REFERENCE QUICK LINKS

- **Your Role:** `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`
- **Project Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md`
- **Reference Code:** `08_Source_Code/`
- **Title Genie Mapping:** `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
- **Paisley API Spec:** `D:\Cursor\TheGenie.ai\Development\Paisley\PRELISTING_API_SPECIFICATION_v1.md`
- **GenieCloud Contract:** `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **COMPREHENSIVE ONBOARDING COMPLETE**

**Welcome to the team! You're building the core API layer that connects everything together. You have all the context and knowledge you need. Let's build this right!**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | 01/14/2026 3:15 AM | JR (Project Manager) | Comprehensive rewrite with full ecosystem context, prior discovery findings, complete API specifications, integration points, common pitfalls, and educational content. This is the complete educational package for Backend API Specialist onboarding. |
| 1.0 | 01/13/2026 11:50 PM | JR (Project Manager) | Initial Backend API Specialist onboarding document. |
