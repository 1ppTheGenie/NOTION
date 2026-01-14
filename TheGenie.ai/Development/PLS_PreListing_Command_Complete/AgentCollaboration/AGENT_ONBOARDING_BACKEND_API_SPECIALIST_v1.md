# Agent Onboarding: Backend API Specialist

**Version:** 1.0  
**Created:** 01/13/2026 11:50 PM  
**Last Updated:** 01/13/2026 11:50 PM  
**Author:** JR (Project Manager)  
**Status:** ✅ Ready for Agent Onboarding

---

## 🎯 WELCOME TO THE PLS PROJECT

You've been assigned the **Backend API Specialist** role for the PLS (Pre-Listing Command) RESO Engine project. This onboarding guide will get you up to speed quickly with all the context, documents, and resources you need.

---

## 📋 YOUR ROLE AT A GLANCE

**Role:** Backend API Specialist  
**Phase:** Phase 2 (Backend API) - **WAIT FOR PHASE 1 COMPLETE**  
**Primary Focus:** REST API endpoints, business logic, controllers  
**Workspace Folders:** `08_Source_Code/`

**Key Responsibility:** Implement all API endpoints, integrate Title Genie pre-population, integrate Paisley AI description generation, and coordinate with XML Specialist on `/render` endpoint.

---

## 🚀 QUICK START (30 Minutes)

### Step 1: Read Your Role Definition (5 min)
- **File:** `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`
- **Purpose:** Understand your exact responsibilities and deliverables

### Step 2: Read Master Blueprint Section 5 (15 min)
- **File:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.1.md` - Section 5: Function Layer (API Endpoints)
- **Purpose:** Understand all API endpoints you need to implement

### Step 3: Review Reference Implementation (10 min)
- **File:** `08_Source_Code/PlsController_Complete_v1.cs`
- **File:** `08_Source_Code/DataController_PLS_Complete_v1.cs`
- **Purpose:** See reference implementations (starting points)

---

## 📚 MUST-READ DOCUMENTS (In Order)

### Priority 1: Core API Documents (Read First)

1. **Your Role Definition**
   - `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`
   - **Why:** Your exact responsibilities and deliverables

2. **Project Blueprint - API Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.1.md` - Section 5
   - **Why:** Complete API endpoint specifications

3. **Reference Implementations**
   - `08_Source_Code/PlsController_Complete_v1.cs`
   - `08_Source_Code/DataController_PLS_Complete_v1.cs`
   - **Why:** Starting point for your implementation

4. **Workspace Memory Log - API Development**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_03_API_DEVELOPMENT_v1.md`
   - **Why:** Historical context and API design decisions

### Priority 2: Integration Documents (Critical)

5. **Title Genie Integration - Field Mapping**
   - `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
   - **Why:** Maps 318 TitleData fields to 93 MlsListing fields for pre-population

6. **Title Genie Master Compilation**
   - `TitleGenie/TITLEGENIE_MASTER_COMPILATION_v1.md`
   - **Why:** Complete Title Genie context and data sources

7. **Paisley Integration - API Specification**
   - `Paisley/PRELISTING_API_SPECIFICATION_v1.md`
   - **Why:** Paisley API integration points (ChatStartTypeId=3)

8. **Paisley Complete Walkthrough**
   - `Paisley/PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md`
   - **Why:** User flow and integration context

9. **GenieCloud Contract**
   - `11_Contracts/CONTRACT_PLS_to_GenieCloud_v6.1.md`
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

## 🎯 YOUR DELIVERABLES

### Phase 2: Backend API (Your Phase)

**Must Complete:**
- [ ] Implement `PlsController.cs` with all endpoints
- [ ] Implement `DataController.PLS.cs` partial class
- [ ] Create business logic service layer (`PlsService`)
- [ ] Handle authentication and authorization
- [ ] Implement all API endpoints (Section 5 of Blueprint):
  - `POST /api/pls/create` - Create new PLS listing
  - `PUT /api/pls/{listingNumber}` - Update listing
  - `GET /api/pls/{listingNumber}` - Get listing details
  - `GET /api/pls/my-listings` - Get user's listings
  - `POST /api/pls/{listingNumber}/render` - Generate GenieCloud XML (coordinate with XML Specialist)
  - `POST /api/pls/pre-populate` - Pre-populate from TitleData
  - `POST /api/pls/upload-photo` - Upload property photos
  - `POST /api/pls/generate-description` - Generate AI description (Paisley ChatStartTypeId=3)
  - `PUT /api/pls/archive/{listingNumber}` - Archive listing
- [ ] Integrate Title Genie pre-population (`GetPropertiesFromPlaceKey`)
- [ ] Integrate Paisley AI description generation (ChatStartTypeId=3)
- [ ] Data validation and error handling
- [ ] API documentation
- [ ] Unit tests for critical endpoints
- [ ] Update `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md` with completion status
- [ ] Announce Phase 2 complete in `AgentCollaboration/HANDOFFS_v1.md`

**Success Criteria:**
- ✅ All endpoints return correct HTTP status codes
- ✅ Data validation prevents invalid input
- ✅ Integration with Database Specialist's stored procedures working
- ✅ Title Genie pre-population working
- ✅ Paisley AI description generation working
- ✅ Ready for Frontend UI integration

---

## 🔑 CRITICAL INFORMATION

### API Endpoints (From Project Blueprint Section 5)

**Core CRUD Endpoints:**
- `POST /api/pls/create` - Create new PLS listing
- `PUT /api/pls/{listingNumber}` - Update listing
- `GET /api/pls/{listingNumber}` - Get listing details
- `GET /api/pls/my-listings` - Get user's listings
- `PUT /api/pls/archive/{listingNumber}` - Archive listing

**Integration Endpoints:**
- `POST /api/pls/pre-populate` - Pre-populate from TitleData (Title Genie integration)
- `POST /api/pls/generate-description` - Generate AI description (Paisley ChatStartTypeId=3)
- `POST /api/pls/upload-photo` - Upload property photos to S3
- `POST /api/pls/{listingNumber}/render` - Generate GenieCloud XML (coordinate with XML Specialist)

### Title Genie Integration

**Pre-Population Endpoint:**
- **Purpose:** Pre-populate PLS form with property data from TitleData
- **Data Source:** `TitleData.dbo.AttomDataAssessor` (318 fields)
- **Data Source:** `TitleData.dbo.ViewAssessor_v3` (315+ fields)
- **Data Source:** `MlsListing.dbo.Listing` (Historical MLS data)
- **Field Mapping:** Use `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
- **Implementation:** `GetPropertiesFromPlaceKey` method

### Paisley Integration

**AI Description Generation:**
- **Purpose:** Generate AI description for PLS listing
- **Paisley Chat Type:** ChatStartTypeId=3 (Pre-Listing Focused)
- **Input Data:** Listing data + selected area data
- **API Endpoint:** Paisley API (see `PRELISTING_API_SPECIFICATION_v1.md`)
- **Implementation:** `POST /api/pls/generate-description` endpoint

### GenieCloud XML Generation (Coordinate with XML Specialist)

**Render Endpoint:**
- **Purpose:** Generate XML and trigger GenieCloud render
- **Contract:** Follow `CONTRACT_PLS_to_GenieCloud_v6.1.md` exactly
- **Coordination:** Work with XML/Integration Specialist
- **Implementation:** `POST /api/pls/{listingNumber}/render` endpoint

### Database Connection

**Use Production SQL 2012:**
- **Server:** `192.168.29.45,1433`
- **Databases:** `FarmGenie`, `MlsListing`, `TitleData`
- **Connection Strings:** Read from `Web.config`
- **Credentials:** Use READ-ONLY for queries, SA for writes

---

## 🤝 COLLABORATION

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

## 📝 DAILY WORKFLOW

### Morning (5 minutes)
1. Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for project status
2. Check Database Specialist status for Phase 1 completion
3. Check `AgentCollaboration/BLOCKERS_v1.md` for blockers
4. Review your status file

### During Work
1. Implement endpoints using reference implementations
2. Test each endpoint independently
3. Integrate with Title Genie and Paisley
4. Coordinate with XML Specialist on `/render` endpoint

### End of Day (5 minutes)
1. Update `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md` with progress
2. Document any blockers in `AgentCollaboration/BLOCKERS_v1.md`
3. Update deliverables checklist

---

## 🚨 CRITICAL RULES

1. **Wait for Database** - Do not start until Database Specialist completes Phase 1
2. **Use Reference Code** - Reference implementations in `08_Source_Code/` are starting points
3. **Test in Sandbox** - All API testing in Sandbox environment
4. **Document APIs** - Create API documentation for Frontend Specialist
5. **Follow Contract** - GenieCloud contract must be followed exactly (coordinate with XML Specialist)
6. **Use Production SQL 2012** - Never use local SQL or sandbox databases

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

## ✅ ONBOARDING CHECKLIST

Before you start work, verify you've completed:

- [ ] Read your role definition (`AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`)
- [ ] Read Project Blueprint Section 5 (API Endpoints)
- [ ] Reviewed reference implementations (`PlsController_Complete_v1.cs`, `DataController_PLS_Complete_v1.cs`)
- [ ] Read Title Genie field mapping document
- [ ] Read Paisley API specification
- [ ] Read GenieCloud contract (for `/render` endpoint)
- [ ] Understood database connection requirements
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

## 📚 REFERENCE QUICK LINKS

- **Your Role:** `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`
- **Project Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.1.md`
- **Reference Code:** `08_Source_Code/`
- **Title Genie Mapping:** `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
- **Paisley API Spec:** `Paisley/PRELISTING_API_SPECIFICATION_v1.md`
- **GenieCloud Contract:** `11_Contracts/CONTRACT_PLS_to_GenieCloud_v6.1.md`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **READY FOR ONBOARDING**

**Welcome to the team! You're implementing the core API layer that connects everything together. Let's build this right!**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/13/2026 11:50 PM | JR (Project Manager) | Initial Backend API Specialist onboarding document. Comprehensive guide with must-read documents, deliverables, integration points, and daily workflow. |
