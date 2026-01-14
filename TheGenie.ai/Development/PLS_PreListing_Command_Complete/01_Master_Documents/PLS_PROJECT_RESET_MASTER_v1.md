# PLS Pre-Listing Command - Project Reset Master
**Version:** 1.0  
**Created:** 01/13/2026 9:15 PM  
**Last Updated:** 01/13/2026 9:15 PM  
**Author:** JR (Project Manager)  
**Status:** ✅ ACTIVE - Single Source of Truth for Project Reset

---

## 🎯 PURPOSE

This document consolidates all prior PLS documentation, organizes it by feature/priority, and creates an iterative sprint schedule. This is the **SINGLE SOURCE OF TRUTH** for the project reset and sprint planning.

**DRA-2026 Compliant:** ✅ Yes - Master document with cataloged exhibits  
**Master Rules Compliant:** ✅ Yes - Proper versioning, headers, change log  
**Master Index Compliant:** ✅ Yes - Will be indexed in GLOBAL_MASTER_INDEX.md

---

## 📋 MASTER RULES ENFORCEMENT

### Rule Compliance Checklist
- ✅ **File Versioning:** All documents properly versioned (v1, v2, v3...)
- ✅ **No Assumptions:** All facts verified from source documents
- ✅ **No Placeholders:** All data is real or confirmed
- ✅ **Document Headers:** All documents have proper headers with timestamps
- ✅ **Date/Time Format:** MM/DD/YYYY HH:MM AM/PM format used
- ✅ **D: Drive Location:** All files on D: drive (never C:)
- ✅ **DRA-2026:** Master document with cataloged exhibits

---

## 📚 COMPLETE DOCUMENT INDEX

### Master Documents (01_Master_Documents/)
| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **PLS_MASTER_SPECIFICATION_v3.md** | 3.0 | ✅ Canonical | Complete system specification |
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md** | 1.7 | ✅ Canonical | Complete project blueprint |
| **CONTRACT_PLS_to_GenieCloud_v6.1.md** | 6.1 | ✅ Canonical | PLS ↔ GenieCloud data contract |
| **PLS_DATABASE_SCHEMA_RELATIONAL_v1.md** | 1.0 | ✅ Active | Database schema design |
| **PLS_WIREFRAME_SPECIFICATIONS_v1.md** | 1.0 | ✅ Active | UI wireframes and design |
| **PLS_GENIECLOUD_XML_MAPPING_v1.md** | 1.0 | ✅ Active | XML mapping specification |
| **PLS_3_LAYER_GAP_ANALYSIS_v1.md** | 1.0 | ✅ Active | Architecture gap analysis |
| **TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md** | 1.0 | ✅ Active | Field mapping analysis |
| **PLS_DRA_2026_COMPLIANCE_v1.md** | 1.0 | ✅ Active | DRA-2026 compliance status |
| **DOCUMENTATION_INDEX_v1.md** | 1.0 | ⚠️ Needs Update | Legacy index (superseded by this document) |

### Scripts (02_Scripts/)
| Script | Version | Status | Purpose |
|--------|---------|--------|---------|
| **PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql** | 3.0 | ✅ Current | Database schema (USE THIS) |
| **PLS_STORED_PROCEDURES_COMPLETE_v1.sql** | 1.0 | ✅ Active | Stored procedures |
| **PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql** | 4.0 | ✅ Current | PLS number generation (USE THIS) |
| **PLS_DATABASE_MASTER_DATA_v3.sql** | 3.0 | ✅ Active | Master data inserts |
| **PLS_DATABASE_OWNERSHIP_TABLE_v3.sql** | 3.0 | ✅ Active | Ownership table |
| **PLS_COMPLETE_DATABASE_SETUP_v1.sql** | 1.0 | ✅ Active | Complete setup script |
| **PLS_SANDBOX_SETUP_COMPLETE_v1.sql** | 1.0 | ✅ Active | Sandbox setup |
| **PLS_SANDBOX_DATA_FETCH_v1.sql** | 1.0 | ✅ Active | Data fetch script |
| **PLS_SCHEMA_EXTENSIONS_NORMALIZED_v2.sql** | 2.0 | ⚠️ Deprecated | Use v3 |
| **PLS_SCHEMA_EXTENSIONS_v1.sql** | 1.0 | ⚠️ Deprecated | Use v3 |
| **PLS_DATABASE_PLSNUMBER_SEQUENCE_v3.sql** | 3.0 | ⚠️ Deprecated | Use v4 |
| **FIX_*.ps1** | Various | ✅ Active | Connection string fixes |
| **deploy_*.py** | Various | ✅ Active | Deployment scripts |

### Source Code (08_Source_Code/)
| File | Version | Status | Purpose |
|------|---------|--------|---------|
| **PlsController_Complete_v1.cs** | 1.0 | ✅ Active | Complete API controller |
| **DataController_PLS_Complete_v1.cs** | 1.0 | ✅ Active | Data controller |
| **DataController_PLS_Implementation_v1.cs** | 1.0 | ✅ Active | Implementation |
| **DataController_Endpoints_v1.cs** | 1.0 | ✅ Active | Endpoint definitions |
| **pls-create.component.ts** | 1.0 | ✅ Active | Angular create component |
| **pls-create.component.html** | 1.0 | ✅ Active | Component template |
| **pls-create.component.scss** | 1.0 | ✅ Active | Component styles |
| **PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html** | 4.0 | ✅ Current | Address lookup prototype (USE THIS) |

### Prototypes (09_Prototypes/)
| File | Version | Status | Purpose |
|------|---------|--------|---------|
| **PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html** | 4.0 | ✅ Current | Address lookup (USE THIS) |
| **PLS_PROTOTYPE_ADDRESS_LOOKUP_v3.html** | 3.0 | ⚠️ Deprecated | Use v4 |
| **PLS_PROTOTYPE_ADDRESS_LOOKUP_v2.html** | 2.0 | ⚠️ Deprecated | Use v4 |
| **PLS_PROTOTYPE_ADDRESS_LOOKUP_v1.html** | 1.0 | ⚠️ Deprecated | Use v4 |

### Agent Collaboration (AgentCollaboration/)
| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **PLS_AGENT_COORDINATION_MASTER_v1.md** | 1.1 | ✅ Active | Agent coordination master |
| **AGENT_DEFINITIONS_SPRINT_v1.json** | 1.0 | ✅ Active | Sprint-based agent definitions |
| **SPRINT_MODEL_GUIDE_v1.md** | 1.0 | ✅ Active | Sprint model guide |
| **AGENT_MESSAGE_PROTOCOL_v1.md** | 1.0 | ✅ Active | JSON message protocol |
| **AgentInstructions/*_SETUP_INSTRUCTIONS.md** | 1.0 | ✅ Active | Agent setup instructions (5 files) |

### Process Documentation (04_Process_Documentation/)
| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **SOP_PRELISTING_COMMAND_MASTER_v2.md** | 2.0 | ✅ Current | Master SOP (USE THIS) |
| **SOP_PRELISTING_COMMAND_MASTER_v1.md** | 1.0 | ⚠️ Deprecated | Use v2 |
| **SOP_PRELISTING_COMMAND_EXECUTION_v1.md** | 1.0 | ✅ Active | Execution SOP |
| **SOP_PRELISTING_COMMAND_PROTOTYPE_v2.md** | 2.0 | ✅ Current | Prototype SOP (USE THIS) |
| **SOP_PRELISTING_COMMAND_PROTOTYPE_v1.md** | 1.0 | ⚠️ Deprecated | Use v2 |
| **PLS_IMPLEMENTATION_GUIDE_v1.md** | 1.0 | ✅ Active | Implementation guide |
| **PLS_IMPLEMENTATION_STATUS_v1.md** | 1.0 | ✅ Active | Status tracking |
| **PLS_COMPLETE_IMPLEMENTATION_SUMMARY_v1.md** | 1.0 | ✅ Active | Summary |
| **PLS_DETAILED_WORKFLOW_STEPS_v1.md** | 1.0 | ✅ Active | Workflow steps |

### Iteration Plans (07_Iteration_Plans/)
| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.9.md** | 1.9 | ⚠️ Superseded | Use v1.7 (consolidated) |
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md** | 1.7 | ✅ Current | Project blueprint (USE THIS) |
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.2.md** | 1.2 | ⚠️ Deprecated | Use v1.7 |
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.1.md** | 1.1 | ⚠️ Deprecated | Use v1.7 |
| **PLS_PROJECT_NEXT_STEPS_v3.md** | 3.0 | ✅ Active | Next steps |
| **PLS_TEST_READINESS_STATUS_v1.md** | 1.0 | ✅ Active | Test readiness |
| **PLS_NEXT_TESTING_STEPS_v1.md** | 1.0 | ✅ Active | Testing steps |
| **PLS_PRE_TEST_DISCOVERY_ACTION_PLAN_v1.md** | 1.0 | ✅ Active | Discovery plan |
| **DANNY_ITERATIVE_TEST_PLAN_v1.md** | 1.0 | ✅ Active | Test plan |
| **DANNY-PLS-RESO-Prototype_INDEX_v1.md** | 1.0 | ✅ Active | Prototype index |
| **WORKSPACE_MEMORY_LOG_*.md** | Various | ✅ Active | Memory logs |

### Verification Audits (05_Verification_Audits/)
| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **PLS_TEST_READINESS_STATUS_v1.md** | 1.0 | ✅ Active | Test readiness |
| **PLS_IMPLEMENTATION_STATUS_v1.md** | 1.0 | ✅ Active | Implementation status |
| **PLS_DATABASE_ITEMS_CHECKLIST_v3.md** | 3.0 | ✅ Active | Database checklist |
| **PLS_VISUAL_STUDIO_CHECKIN_CHECKLIST_v1.md** | 1.0 | ✅ Active | Check-in checklist |

### Infrastructure (06_Infrastructure/)
| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **PLS_INTEGRATION_DISCOVERY_v1.md** | 1.0 | ✅ Active | Integration discovery |
| **PLS_PERMISSION_ROLE_INTEGRATION_v1.md** | 1.0 | ✅ Active | Permission integration |
| **PLS_SCHEMA_VISUAL_DIAGRAM_NORMALIZED_v2.md** | 2.0 | ✅ Active | Schema diagram |
| **PLS_DATABASE_ITEMS_CHECKLIST_v3.md** | 3.0 | ✅ Active | Database checklist |
| **PLS_SCHEMA_CHANGES_v2_to_v3.md** | 1.0 | ✅ Active | Schema changes |
| **WORKSPACE_MEMORY_LOG_*.md** | Various | ✅ Active | Memory logs |

### Workspace Memory Logs (12_Workspace_Memory_Logs/)
| Document | Version | Status | Purpose |
|----------|---------|--------|---------|
| **WORKSPACE_MEMORY_LOG_INDEX_v1.md** | 1.0 | ✅ Active | Memory log index |
| **WORKSPACE_MEMORY_LOG_01_PROJECT_VISION_ARCHITECTURE_v1.md** | 1.0 | ✅ Active | Vision/architecture |
| **WORKSPACE_MEMORY_LOG_02_DATABASE_DESIGN_v1.md** | 1.0 | ✅ Active | Database design |
| **WORKSPACE_MEMORY_LOG_03_API_DEVELOPMENT_v1.md** | 1.0 | ✅ Active | API development |
| **WORKSPACE_MEMORY_LOG_04_UI_FRONTEND_v1.md** | 1.0 | ✅ Active | UI/frontend |
| **WORKSPACE_MEMORY_LOG_05_DEPLOYMENT_DEVOPS_v1.md** | 1.0 | ✅ Active | Deployment/DevOps |
| **WORKSPACE_MEMORY_LOG_06_INTEGRATION_POINTS_v1.md** | 1.0 | ✅ Active | Integration points |
| **WORKSPACE_MEMORY_LOG_07_TESTING_QA_v1.md** | 1.0 | ✅ Active | Testing/QA |
| **WORKSPACE_MEMORY_LOG_08_DRA_COMPLIANCE_v1.md** | 1.0 | ✅ Active | DRA compliance |

---

## 🎯 FEATURE ORGANIZATION BY PRIORITY

### Priority 1: Foundation (MVP Core)
**Goal:** Basic PLS listing creation and listing with GenieCloud integration

#### Feature 1.1: Database Foundation
- **Documents:**
  - `PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
  - `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
  - `PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
  - `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`
  - `PLS_DATABASE_MASTER_DATA_v3.sql`
- **Deliverables:**
  - Database schema in Sandbox
  - PLS number generation (format: PLS100000A)
  - Master data (status types, source types)
  - Stored procedures tested

#### Feature 1.2: XML Framework
- **Documents:**
  - `CONTRACT_PLS_to_GenieCloud_v6.1.md`
  - `PLS_GENIECLOUD_XML_MAPPING_v1.md`
- **Deliverables:**
  - XML generation from PLS listing data
  - GenieCloud API integration
  - Marketing asset generation

#### Feature 1.3: Backend API (MVP)
- **Documents:**
  - `PlsController_Complete_v1.cs`
  - `DataController_PLS_Complete_v1.cs`
  - `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 5)
- **Deliverables:**
  - MVP API endpoints (create, get, list, render)
  - Data validation
  - Error handling

#### Feature 1.4: Frontend UI (MVP)
- **Documents:**
  - `PLS_WIREFRAME_SPECIFICATIONS_v1.md`
  - `pls-create.component.*`
  - `PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html`
- **Deliverables:**
  - MVP components (list, create)
  - Mapbox address lookup
  - Basic form validation
  - Mobile-responsive design

### Priority 2: Enhanced Features
**Goal:** Edit functionality, photo upload, enhanced UI

#### Feature 2.1: Edit Functionality
- **Documents:**
  - `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 10)
- **Deliverables:**
  - Edit component
  - Update API endpoints
  - Status transitions

#### Feature 2.2: Photo Upload
- **Documents:**
  - `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 10)
- **Deliverables:**
  - Photo upload component
  - S3 integration
  - Photo management

#### Feature 2.3: AI Description Generation
- **Documents:**
  - `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 19)
- **Deliverables:**
  - Paisley integration (ChatStartTypeId=3)
  - Auto-generated descriptions
  - Edit capability

### Priority 3: Advanced Features
**Goal:** Area selection, Paisley integration, advanced filtering

#### Feature 3.1: Area Selection
- **Documents:**
  - `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 10, 20)
- **Deliverables:**
  - Area selection component
  - Area data integration
  - Listing Command integration

#### Feature 3.2: Advanced Filtering
- **Documents:**
  - `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 10)
- **Deliverables:**
  - Filter component
  - Search functionality
  - Status filtering

#### Feature 3.3: Performance Optimization
- **Documents:**
  - `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 13)
- **Deliverables:**
  - Query optimization
  - Caching strategy
  - Performance monitoring

---

## 🔄 ITERATIVE SPRINT SCHEDULE

### Sprint 1: MVP Foundation (2 weeks)
**Goal:** Basic PLS listing creation and listing with GenieCloud integration

**Sprint Tasks:**
1. **Database Specialist:** Database schema and PLS number generation (5 points)
   - Execute `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` in Sandbox
   - Create PLS number sequence table
   - Implement `usp_GetNextPlsNumber`
   - Insert master data
   - Test PLS number generation

2. **XML/Integration Specialist:** XML generation framework (8 points)
   - Implement XML generation from PLS listing data
   - Follow `CONTRACT_PLS_to_GenieCloud_v6.1.md` exactly
   - Map PLS data to GenieCloud XML structure
   - Test GenieCloud API integration

3. **Backend API Specialist:** MVP API endpoints (8 points)
   - Implement `PlsController.cs` with MVP endpoints (create, get, list, render)
   - Implement `DataController.PLS.cs` partial class
   - Create `PlsService` business logic layer
   - Add data validation and error handling

4. **Frontend UI Specialist:** MVP UI components (8 points)
   - Implement `PlsMyListingsComponent` (list view)
   - Implement `PlsCreateComponent` (create form)
   - Integrate Mapbox address lookup
   - Basic form validation
   - Mobile-responsive design

5. **DevOps Specialist:** Sandbox deployment infrastructure (3 points)
   - Create deployment scripts
   - Set up Sandbox test environment
   - Create backup and rollback procedures

**Total Story Points:** 32  
**Dependencies:** Database → XML → Backend API → Frontend UI  
**Parallel:** DevOps (no dependencies)

---

### Sprint 2: Enhanced Features (2 weeks)
**Goal:** Edit functionality, photo upload, AI description generation

**Sprint Tasks:**
1. **Backend API Specialist:** Edit endpoints (5 points)
   - Implement update endpoint
   - Status transition logic
   - Validation updates

2. **Frontend UI Specialist:** Edit component (5 points)
   - Implement `PlsEditComponent`
   - Form pre-population
   - Update API integration

3. **Frontend UI Specialist:** Photo upload (8 points)
   - Implement `PlsPhotoUploadComponent`
   - S3 integration
   - Photo management UI

4. **XML/Integration Specialist:** AI description integration (5 points)
   - Paisley integration (ChatStartTypeId=3)
   - Auto-generated descriptions
   - Edit capability

5. **DevOps Specialist:** Enhanced deployment (3 points)
   - Stage environment setup
   - Enhanced backup procedures

**Total Story Points:** 26  
**Dependencies:** Sprint 1 complete

---

### Sprint 3: Advanced Features (2 weeks)
**Goal:** Area selection, advanced filtering, performance optimization

**Sprint Tasks:**
1. **Backend API Specialist:** Area selection API (5 points)
   - Area data endpoints
   - Listing Command integration

2. **Frontend UI Specialist:** Area selection component (5 points)
   - Area selection UI
   - Area data integration

3. **Frontend UI Specialist:** Advanced filtering (5 points)
   - Filter component
   - Search functionality
   - Status filtering

4. **Backend API Specialist:** Performance optimization (8 points)
   - Query optimization
   - Caching strategy
   - Performance monitoring

5. **DevOps Specialist:** Production deployment (5 points)
   - Production deployment scripts
   - Monitoring setup

**Total Story Points:** 28  
**Dependencies:** Sprint 2 complete

---

## 📊 SPRINT PROGRESS TRACKING

### Current Status
- **Current Sprint:** Sprint 1 - MVP Foundation
- **Sprint Start Date:** TBD
- **Sprint End Date:** TBD
- **Overall Progress:** 0%

### Sprint 1 Status
| Task | Agent | Status | Progress | Blockers |
|------|-------|--------|----------|----------|
| Database schema | Database Specialist | ⏳ Not Started | 0% | None |
| XML framework | XML/Integration Specialist | ⏳ Waiting | 0% | Database |
| MVP API endpoints | Backend API Specialist | ⏳ Waiting | 0% | Database + XML |
| MVP UI components | Frontend UI Specialist | ⏳ Waiting | 0% | Backend API |
| Deployment infrastructure | DevOps Specialist | ⏳ Not Started | 0% | None |

---

## 🚨 BLOCKERS & DEPENDENCIES

### Current Blockers
- None identified

### Dependencies
- **XML Framework** depends on **Database** (needs PLS data structure)
- **Backend API** depends on **Database + XML** (needs data structure + XML generation)
- **Frontend UI** depends on **Backend API** (needs API endpoints)

---

## 📋 NEXT ACTIONS

### Immediate Actions (This Week)
1. ✅ **Project Reset Complete** - This document created
2. ⏳ **Sprint 1 Planning** - Assign tasks to agents
3. ⏳ **Database Setup** - Execute schema in Sandbox
4. ⏳ **Agent Verification** - Verify all 5 agents are created

### Sprint 1 Actions
1. Database Specialist: Execute database setup
2. XML/Integration Specialist: Begin XML framework (after database)
3. Backend API Specialist: Begin API endpoints (after database + XML)
4. Frontend UI Specialist: Begin UI components (after backend API)
5. DevOps Specialist: Set up deployment infrastructure (parallel)

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/13/2026 9:15 PM | **INITIAL VERSION:** Created project reset master document. Indexed all prior documentation (122+ files). Organized by feature/priority. Created iterative sprint schedule (3 sprints). Enforced Master Rules, Master Index, and DRA-2026 compliance. This is the single source of truth for project reset and sprint planning. |

---

**Status:** ✅ ACTIVE - Single Source of Truth

**Location:** `01_Master_Documents/PLS_PROJECT_RESET_MASTER_v1.md`

**DRA-2026 Compliant:** ✅ Yes - Master document with cataloged exhibits
