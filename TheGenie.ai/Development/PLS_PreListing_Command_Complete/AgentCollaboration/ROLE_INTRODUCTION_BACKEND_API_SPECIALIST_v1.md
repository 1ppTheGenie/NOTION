# Backend API Specialist - PLS RESO Engine Project Introduction

**Version:** 1.0  
**Created:** 01/14/2026 6:20 AM  
**Priority:** 🔥 **URGENT - XML System Ready by Tomorrow**

---

## 🎯 YOUR MISSION

You are the **Backend API Specialist** for the **PLS (Paisley RESO Listing Engine)** project. Your job is to build the REST API layer that connects the database, frontend UI, and external services (Title Genie, Paisley AI, GenieCloud) into a cohesive system.

**CRITICAL DEADLINE:** PLS-RESO XML and management system must be ready by tomorrow.

---

## 📋 WHAT IS PLS?

**PLS (Paisley RESO Listing Engine)** enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate marketing assets (landing pages, social ads, brochures) automatically via GenieCloud
- Automate circle prospecting via Listing Command integration
- Future: One-button push to publish listings to Bridge/Trestle MLSs via RESO Insert

**Your Role:** Build the API layer (Phase 2) that connects everything together.

---

## 🔌 YOUR INTEGRATION POINTS

### 1. Title Genie Integration
**Purpose:** Pre-populate PLS form with property data  
**Data Source:** `TitleData.dbo.AttomDataAssessor` (318 fields)  
**Endpoint:** `POST /api/pls/pre-populate`  
**Field Mapping:** `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`

### 2. Paisley AI Integration
**Purpose:** Generate AI descriptions for PLS listings  
**Paisley Chat Type:** `ChatStartTypeId=3` (Pre-Listing Focused)  
**Endpoint:** `POST /api/pls/generate-description`  
**Implementation:** Call existing `POST /api/paisley/chat` with ChatStartTypeId=3

### 3. GenieCloud Integration
**Purpose:** Generate marketing assets (landing pages, social ads, brochures)  
**Contract:** `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md` ⭐ **MUST FOLLOW EXACTLY**  
**Endpoint:** `POST /api/pls/{listingNumber}/render`  
**Coordination:** Work with XML/Integration Specialist on XML generation

### 4. Listing Command Integration
**Purpose:** Automate circle prospecting for PLS listings  
**PropertyCastTypeId:** `4` (for PLS listings)  
**Queue Table:** `FarmGenie.dbo.ListingCommandQueue`  
**Implementation:** Insert into queue when PLS listing created

---

## 📚 MUST-READ DOCUMENTS (In Order)

### Priority 1: Core API Documents
1. **Project Blueprint - API Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 5
   - **Why:** Complete API endpoint specifications

2. **Reference Implementations**
   - `08_Source_Code/PlsController_Complete_v1.cs` ⭐ **USE THIS**
   - `08_Source_Code/DataController_PLS_Complete_v1.cs` ⭐ **USE THIS**
   - **Why:** Starting point for your implementation

3. **Workspace Memory Log - API Development**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_03_API_DEVELOPMENT_v1.md`
   - **Why:** Historical context and API design decisions

### Priority 2: Integration Documents (CRITICAL)
4. **Title Genie Integration - Field Mapping**
   - `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
   - **Why:** Maps 318 TitleData fields to 93 MlsListing fields

5. **Paisley Integration - API Specification**
   - `D:\Cursor\TheGenie.ai\Development\Paisley\PRELISTING_API_SPECIFICATION_v1.md`
   - **Why:** Paisley API integration points (ChatStartTypeId=3)

6. **GenieCloud Contract** ⭐⭐⭐ **CRITICAL**
   - `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md`
   - **Why:** XML generation contract (coordinate with XML Specialist)

### Priority 3: Database Context
7. **Database Schema**
   - `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
   - **Why:** Understand database structure

8. **Stored Procedures**
   - `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
   - **Why:** Stored procedures you'll call from API

---

## 🔑 CRITICAL INFORMATION

### Database Connection

**Server:** Production SQL 2012 (`192.168.29.45,1433`)  
**Databases:** `FarmGenie`, `MlsListing`, `TitleData`  
**Connection Strings:** Read from `Web.config` in your project

### PLS Number Format

**Format:** `PLS{6-digit}{letter}` (e.g., `PLS100000A`)  
**Generation:** Call `EXEC usp_GetNextPlsNumber` (from Database Specialist)

### MlsId and StatusTypeID

**MlsId:** `777` (NOT 999 - that was old spec)  
**StatusTypeID:** `6` (Private Listing) or `14` (Coming Soon)  
**PropertyCastTypeId:** `4` (for Listing Command integration)

---

## ✅ YOUR DELIVERABLES

### Must Complete (In Order):

1. **Wait for Phase 1 Completion**
   - Monitor Database Specialist status
   - Verify all stored procedures exist

2. **Deploy Controllers**
   - Copy `08_Source_Code/PlsController_Complete_v1.cs` → `Controllers/PlsController.cs`
   - Copy `08_Source_Code/DataController_PLS_Complete_v1.cs` → `Controllers/DataController.PLS.cs`
   - Update `Smart.Dashboard.csproj`

3. **Implement All API Endpoints:**
   - `POST /api/pls/create` - Create new PLS listing
   - `PUT /api/pls/{listingNumber}` - Update listing
   - `GET /api/pls/{listingNumber}` - Get listing details
   - `GET /api/pls/my-listings` - Get user's listings
   - `POST /api/pls/pre-populate` - Pre-populate from Title Genie
   - `POST /api/pls/generate-description` - Generate AI description (Paisley)
   - `POST /api/pls/upload-photo` - Upload property photos
   - `POST /api/pls/{listingNumber}/render` - Generate GenieCloud XML (coordinate with XML Specialist)
   - `PUT /api/pls/archive/{listingNumber}` - Archive listing

4. **Integration Implementation:**
   - Title Genie pre-population (`GetPropertiesFromPlaceKey`)
   - Paisley AI description generation (ChatStartTypeId=3)
   - GenieCloud render endpoint (coordinate with XML Specialist)
   - Listing Command queue integration (PropertyCastTypeId=4)

5. **Build and Test**
   - Build solution (must have ZERO errors)
   - Test all endpoints with Postman
   - Verify integration points work

**Success Criteria:**
- ✅ All endpoints return correct HTTP status codes
- ✅ Data validation prevents invalid input
- ✅ Integration with Database Specialist's stored procedures working
- ✅ Title Genie pre-population working
- ✅ Paisley AI description generation working
- ✅ Ready for Frontend UI integration

---

## 🚨 CRITICAL RULES

1. **Wait for Database** - Do not start until Database Specialist completes Phase 1
2. **Use Reference Code** - Reference implementations in `08_Source_Code/` are starting points
3. **Follow Contract** - GenieCloud contract must be followed exactly (coordinate with XML Specialist)
4. **Test Integration Points** - Test Title Genie, Paisley, GenieCloud independently
5. **Use Production SQL 2012** - Never use local SQL or sandbox databases

---

## 📞 QUICK REFERENCE

- **Deployment Checklist:** `02_Scripts/PLS_COMPLETE_DEPLOYMENT_READY_v1.md`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **READY TO START (After Phase 1)**

**You're Phase 2 - the API layer. Wait for Database Specialist, then deploy controllers and implement endpoints. Coordinate with XML Specialist on `/render` endpoint.**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/14/2026 6:20 AM | JR (Project Manager) | Initial role introduction for Backend API Specialist. Focused on PLS-RESO project with complete knowledge locations. |
