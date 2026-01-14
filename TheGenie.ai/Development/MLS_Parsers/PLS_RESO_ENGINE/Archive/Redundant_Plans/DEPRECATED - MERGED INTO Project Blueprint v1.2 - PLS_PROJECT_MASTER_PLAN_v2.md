# PLS (Paisley Listing Service) Project - Master Plan
**Version:** 2.0  
**Created:** 12/30/2025 4:00 PM  
**Last Updated:** 01/01/2026 6:15 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ ACTIVE - Consolidated Master Plan

---

## 🎯 PROJECT GOAL

**Build Paisley Listing Service (PLS)** - Our own MLS-like system for:
- **Pre-MLS listings** (Coming Soon / Private Listings)
- **Push to MLS** when listings go live (automated via Bridge Interactive API)
- **Modeled after MLS architecture** (using existing MLS schema/docs as blueprint)

---

## 📋 PRIMARY OBJECTIVES

1. ✅ **Study MLS Architecture** - All schema docs, parser docs, PDFs in MLS_Parsers folder
2. ✅ **Review PLS Project Docs** - Paisley and GenieCloud folders
3. ✅ **Review Master Index & Project Universe Dashboard** - Latest versions
4. ✅ **Study eRealtor Spec PDF** - Understand software design spec format
5. ✅ **Find Bridge eInteractive API spec** - For MLS push functionality
6. ✅ **Create PLS Database spec** - Based on MLS architecture
7. ✅ **Create UI Functionality spec** - For interface designers
8. ✅ **Research "Push to MLS" feature** - Bridge Interactive API integration
9. ✅ **Document everything** - For new project/chat context

---

## 📊 CURRENT STATUS

### ✅ COMPLETED:

1. **Key Documents Found:**
   - ✅ `eRealtorMSv1i1 Tech Design.pdf` - Software design spec format
   - ✅ `MlsListing Schema 1.pdf` - Core MLS database schema
   - ✅ `RTK_System Schema.pdf`, `RTK_Provider Schema.pdf`, `RTK_Listings_Uploads Schema 1.pdf`
   - ✅ `PLS_MASTER_SPECIFICATION_v3.md` - Main PLS spec
   - ✅ `CONTRACT_PLS_to_GenieCloud_v6.1.md` - GenieCloud contract
   - ✅ `GLOBAL_MASTER_INDEX.md` - Project organization
   - ✅ `PROJECT_UNIVERSE_DASHBOARD.html` - Latest dashboard

2. **Specifications Created:**
   - ✅ `PLS_UI_SPECIFICATION_v1.md` - eRealtor-style UI spec
   - ✅ `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md` - SQL scripts
   - ✅ `PLS_XML_GENERATION_SPEC_v1.md` - XML mapping

3. **Current PLS State:**
   - ✅ MVP exists: https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html
   - ✅ Database: MlsId=999, StatusTypeID=6 (Private) or 14 (Coming Soon)
   - ✅ PropertyCastTypeId=4 for PLS
   - ✅ Uses `MlsListing.dbo.Listing` table (not new tables)

### ⏳ IN PROGRESS:
- Database setup execution
- Backend API development
- Frontend UI development

### ❌ PENDING:
- Bridge eInteractive API Spec (need to contact Bridge)
- Full implementation
- Push to MLS feature

---

## 🔍 KEY FINDINGS

### MLS Architecture (From Schema PDFs):
- **Main Table:** `MlsListing.dbo.Listing` (94+ columns)
- **Key Columns:** MlsID, MlsNumber, DisplayAddress, Price, Bedrooms, Bathrooms, Sqft, StatusTypeID
- **Photos:** `MlsListing.dbo.Photo` (separate table)
- **Agents:** `MlsListingAgent`, `MasterMlsAgent` tables
- **Status Types:** 1=Active, 2=Sold, 4=Pending, 6=Private Listing, 14=Coming Soon

### PLS Current State (From PLS Master Spec v3):
- **Database Strategy:** Uses `MlsListing.dbo.Listing` with `MlsId=999`
- **Status Types:** StatusTypeID=6 (Private) or 14 (Coming Soon)
- **PropertyCastTypeId:** 4 (PLS)
- **PLS Number Format:** `PLS-YYYY-NNNNN` (e.g., PLS-2025-00001)
- **New Tables Needed:**
  - `FarmGenie.dbo.PlsListingOwnership` (user-listing link)
  - `FarmGenie.dbo.PlsNumberSequence` (auto-increment PLS numbers)

### eRealtor Spec Format (From PDF):
- **Structure:** Flow diagrams, function definitions, screen mockups with logic
- **Sections:** Overview, User Login, Transaction Detail, Forms Engine, etc.
- **Format:** Technical design document with logical components, deployment diagrams
- **Use Case:** Template for PLS UI/UX specification

### RESO API Vendors (Bridge & Trestle):
- **Standard APIs:** ✅ **READ-ONLY** - Both Bridge and Trestle standard APIs are read-only
- **Enterprise Solutions:**
  - ⭐ **Bridge Listing Input** - Separate product that DOES support write operations
  - ⭐ **Trestle Direct™** - Enterprise product (write capabilities unknown - needs inquiry)
- **RESO Web API Foundation:** Built on **OData** (which inherently supports CRUD operations)
- **Critical Opportunity:** ⭐ **RESO hasn't standardized write operations** - Opportunity to build RESO Insert!
- **Vision:** Be the company that builds the RESO Insert standard for pushing listings to MLS
- **Research Status:** ✅ Complete - Both vendors researched, opportunity identified

---

## 🚀 IMPLEMENTATION ROADMAP

### Phase 1: Database Setup (Day 1 - 2 hours)

**Execute SQL Scripts:**
1. ✅ Create `PlsListingOwnership` table
2. ✅ Create `PlsNumberSequence` table
3. ✅ Create `usp_GetNextPlsNumber` stored procedure
4. ✅ INSERT StatusType 6 (Private Listing)
5. ✅ INSERT MlsId 999 (PLS)
6. ✅ INSERT PropertyCastTypeId 4 (PLS)
7. ✅ INSERT Permissions 210-214
8. ✅ Grant permissions to roles

**Files:** `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`

---

### Phase 2: Backend API (Day 1-2 - 4 hours)

**Create .NET Core API Endpoints:**

1. **`PlsController.cs`**
   - `POST /api/pls/create` - Create listing
   - `PUT /api/pls/edit/{plsNumber}` - Edit listing
   - `GET /api/pls/my-listings` - List user's listings
   - `POST /api/pls/render` - Trigger GenieCloud render
   - `PUT /api/pls/archive/{plsNumber}` - Archive listing

2. **`PlsService.cs`** (Business Logic)
   - `GetNextPlsNumber()` - Call stored procedure
   - `BuildXml()` - Generate XML from listing data
   - `GeocodeAddress()` - Geocode property address
   - `UploadPhoto()` - Upload to S3

3. **`PlsDto.cs`** (Data Transfer Objects)
   - `PlsListingDto` - Form data
   - `PlsListingResponseDto` - API response
   - `PlsRenderDto` - Render request

**Files:** `PLS_UI_SPECIFICATION_v1.md` (Section 4.2)

---

### Phase 3: Frontend UI (Day 2-3 - 6 hours)

**Create Angular Components:**

1. **`PlsMyListingsComponent`**
   - List view of user's PLS listings
   - Edit, View, Start Campaign, Delete buttons
   - Route: `/pls/my-listings`

2. **`PlsCreateComponent`**
   - Multi-step form (7 steps)
   - Property address, details, status, photos, description, area, agent
   - Photo uploader (S3)
   - AI description generator (Paisley)
   - Area selector
   - Route: `/pls/create`

3. **`PlsEditComponent`**
   - Same form as Create, pre-populated
   - Route: `/pls/edit/{plsNumber}`

4. **Routing & Menu**
   - Add `/pls/*` routes
   - Add "Private Listings" menu item (requires Menu PLS permission)

**Files:** `PLS_UI_SPECIFICATION_v1.md` (Section 3)

---

### Phase 4: Integration (Day 3-4 - 4 hours)

**Connect to Existing Systems:**

1. **GenieCloud Render API**
   - POST XML to `https://cloud-api.thegenie.ai/api/render`
   - Handle response (render ID, collection URL)

2. **Listing Command Queue**
   - INSERT into `ListingCommandQueue` (MlsId=999, PropertyCastTypeId=4)
   - Reuse existing workflow

3. **Paisley AI API**
   - Call with ChatStartTypeId=3 (Pre-Listing Focused)
   - Use property address for Attom lookup

4. **Photo Upload**
   - Upload to S3: `genie-cloud-stage` (or `genie-cloud` for prod)
   - Path: `genie-pages/{pls-number}/photos/{filename}`

**Files:** `PLS_UI_SPECIFICATION_v1.md` (Section 7)

---

## ✅ TESTING CHECKLIST

### Database Tests
- [ ] `EXEC dbo.usp_GetNextPlsNumber;` returns "PLS-2025-00001"
- [ ] Can INSERT test listing
- [ ] Can query PlsListingOwnership
- [ ] Permissions work (user can see menu)

### API Tests
- [ ] `POST /api/pls/create` creates listing
- [ ] `GET /api/pls/my-listings` returns user's listings
- [ ] `PUT /api/pls/edit/{plsNumber}` updates listing
- [ ] `POST /api/pls/render` triggers GenieCloud

### UI Tests
- [ ] Can navigate to "Private Listings" menu
- [ ] Can create new listing (all 7 steps)
- [ ] Can upload photos
- [ ] Can generate AI description
- [ ] Can save listing
- [ ] Can view "My Listings"
- [ ] Can edit existing listing
- [ ] Can start campaign (reuses Listing Command UI)

### Integration Tests
- [ ] XML generates correctly
- [ ] GenieCloud receives XML
- [ ] Assets render (landing page, social graphics)
- [ ] Collection page created
- [ ] Listing Command queue processes
- [ ] SMS sent to farm area

---

## 🎯 MINIMUM VIABLE PROTOTYPE (MVP)

**For Friday Prototype:**

### Must Have:
1. ✅ Database setup complete
2. ✅ Create listing form (all 7 steps)
3. ✅ Save to database (MlsId=999)
4. ✅ Generate XML
5. ✅ Trigger GenieCloud render
6. ✅ View "My Listings" page

### Nice to Have:
- Edit listing
- Start campaign (reuse LC UI)
- AI description generation
- Photo upload (can use existing URLs for prototype)

### Future (Not for Friday):
- Push to MLS (RESO Insert)
- Advanced features

---

## 📝 NEXT STEPS

### Immediate:
1. Execute database scripts
2. Start backend API development
3. Start frontend UI development
4. Test end-to-end flow

### Short Term:
1. Complete MVP implementation
2. Test all integrations
3. Deploy to staging

### Long Term:
1. Contact Bridge Interactive for API documentation
2. Implement "Push to MLS" feature
3. Build RESO Insert standard

---

## 🔗 REFERENCE DOCUMENTS

- **UI Spec:** `PLS_UI_SPECIFICATION_v1.md`
- **Database Spec:** `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`
- **XML Spec:** `PLS_XML_GENERATION_SPEC_v1.md`
- **Master PLS Spec:** `Paisley/Pre.Listing.Command/Docs/PLS_MASTER_SPECIFICATION_v3.md`
- **GenieCloud Contract:** `Paisley/Pre.Listing.Command/Docs/CONTRACT_PLS_to_GenieCloud_v6.1.md`
- **RESO Research:** `RESO_INSERT_OPPORTUNITY_ANALYSIS_v1.md`

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 2.0 | 01/01/2026 6:15 PM | **CONSOLIDATED** - Merged PLS_PROJECT_ACTION_PLAN_v1.md, PLS_PROJECT_COMPREHENSIVE_PLAN_v1.md, PLS_PROJECT_STATUS_AND_NEXT_STEPS_v1.md, and PLS_FRIDAY_PROTOTYPE_ROADMAP_v1.md into single master plan. Includes project goal, status, findings, implementation roadmap, and testing checklist. |
| 1.0 | 12/30/2025 4:00 PM | Initial planning documents (now consolidated) |

---

*File: PLS_PROJECT_MASTER_PLAN_v2.md*  
*Location: D:\Cursor\TheGenie.ai\Development\MLS_Parsers\*

