# PLS Friday Prototype Roadmap

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Target:** Friday Prototype (12/31/2025 or 01/03/2026)

---

## 🎯 PROTOTYPE GOAL

**Build a working PLS UI that:**
1. ✅ Creates listings (saves to database)
2. ✅ Generates XML
3. ✅ Triggers GenieCloud render
4. ✅ Produces content kits (landing pages, social graphics)

**Two Use Cases:**
1. **Coming Soon/Private** → Market BEFORE MLS → Push to MLS when ready (future)
2. **MLS-Ready** → AI pre-populates → Agent reviews/submits (saves time)

---

## 📋 DELIVERABLES CREATED

### ✅ Complete Specifications:

1. **`PLS_UI_SPECIFICATION_v1.md`** - eRealtor-style UI spec
   - Flow diagrams
   - Screen specifications
   - Function definitions
   - Business logic
   - Integration points

2. **`PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`** - SQL scripts
   - Table creation
   - Stored procedures
   - Master data inserts
   - Permissions setup
   - Verification queries

3. **`PLS_XML_GENERATION_SPEC_v1.md`** - XML mapping
   - Complete XML template
   - Data mapping tables
   - C# code implementation
   - Validation rules

---

## 🚀 IMPLEMENTATION PHASES

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

**For Friday, we need:**

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

## 📝 NEXT STEPS (IMMEDIATE)

1. **Review specs** - Confirm approach
2. **Execute database scripts** - Set up tables/permissions
3. **Start backend API** - Create controller/service
4. **Start frontend UI** - Create components
5. **Test end-to-end** - Create listing → Generate kit

---

## 🔗 REFERENCE DOCUMENTS

- **UI Spec:** `PLS_UI_SPECIFICATION_v1.md`
- **Database Spec:** `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`
- **XML Spec:** `PLS_XML_GENERATION_SPEC_v1.md`
- **Master PLS Spec:** `Paisley/Pre.Listing.Command/Docs/PLS_MASTER_SPECIFICATION_v3.md`
- **GenieCloud Contract:** `Paisley/Pre.Listing.Command/Docs/CONTRACT_PLS_to_GenieCloud_v5.md`

---

**Status:** ✅ Ready to Build - All Specs Complete!



