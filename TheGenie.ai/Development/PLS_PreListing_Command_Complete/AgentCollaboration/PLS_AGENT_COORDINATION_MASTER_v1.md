# PLS Pre-Listing Command - Agent Coordination Master Document
**Version:** 1.1  
**Created:** 01/13/2026 7:34 PM  
**Last Updated:** 01/13/2026 9:00 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ ACTIVE - DRA-2026 Compliant Master Document

---

## 🎯 PURPOSE

This is the **SINGLE SOURCE OF TRUTH** for all agent coordination, role definitions, status tracking, and collaboration protocols for the PLS Pre-Listing Command project. This master document consolidates all agent-related content per DRA-2026 requirements.

**DRA-2026 Compliance:** This master document consolidates all agent coordination content. Exhibits (separate files) are cataloged below but this document is the authoritative source.

---

## 📋 TABLE OF CONTENTS

1. [Executive Summary](#executive-summary)
2. [The 5 Agent Roles](#the-5-agent-roles)
   - [Role 1: Database Specialist](#role-1-database-specialist)
   - [Role 2: Backend API Specialist](#role-2-backend-api-specialist)
   - [Role 3: Frontend UI Specialist](#role-3-frontend-ui-specialist)
   - [Role 4: XML/Integration Specialist](#role-4-xmlintegration-specialist)
   - [Role 5: DevOps/Deployment Specialist](#role-5-devopsdeployment-specialist)
3. [Status Tracking](#status-tracking)
4. [Collaboration Protocols](#collaboration-protocols)
5. [Quick Start Guide](#quick-start-guide)
6. [Exhibits Catalog](#exhibits-catalog)

---

## 🎯 EXECUTIVE SUMMARY

This document defines **5 specialized agent roles** required to implement the PLS Pre-Listing Command project. Each agent is a specialist in their domain, working collaboratively using a **SCRUM/SPRINT model** (not linear phases).

**Project Status:** Specifications 100% complete, Implementation 0% (ready to begin)

**Current Sprint:** Sprint 1 - MVP Foundation

**Model:** SCRUM/SPRINT - Iterative development with 2-week sprints, not linear phases

---

## 👥 THE 5 AGENT ROLES

| Role | Primary Focus | Sprint Focus | Status |
|------|--------------|--------------|--------|
| **Database Specialist** | Database schema, stored procedures | Database foundation for MVP | ⏳ Ready |
| **Backend API Specialist** | REST API endpoints, controllers | API endpoints for MVP | ⏳ Waiting |
| **Frontend UI Specialist** | Angular components, UI/UX | MVP UI components | ⏳ Waiting |
| **XML/Integration Specialist** | GenieCloud XML, API integration | XML framework for MVP | ⏳ Ready |
| **DevOps/Deployment Specialist** | Deployment, configuration, testing | Deployment infrastructure | ✅ Active |

**Model:** SCRUM/SPRINT - Tasks assigned per sprint, not linear phases. See `SPRINT_MODEL_GUIDE_v1.md` for details.

---

## 🗄️ ROLE 1: DATABASE SPECIALIST

### Primary Responsibilities

1. **Database Schema Implementation**
   - Execute normalized schema v3.0 (`PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`)
   - Create PLS number sequence table and stored procedure
   - Create master data lookup tables
   - Verify all tables, indexes, and constraints

2. **Stored Procedures**
   - Implement `usp_GetNextPlsNumber` (PLS number generation)
   - Create any additional stored procedures as needed
   - Test all procedures in Sandbox environment

3. **Data Migration**
   - Migrate existing data if needed
   - Set up master data (status types, source types)
   - Initialize PLS number sequence

4. **Database Documentation**
   - Update schema diagrams
   - Document all tables and relationships
   - Create database setup checklist

### Key Documents to Reference
- `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
- `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
- `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
- `06_Infrastructure/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`

### Deliverables
- [ ] All database tables created in Sandbox
- [ ] All stored procedures tested and working
- [ ] Master data inserted
- [ ] PLS number generation verified
- [ ] Database setup checklist completed

### Success Criteria
- PLS number format: `PLS100000A` (6 digits + letter)
- All foreign keys and indexes created
- Stored procedures return expected results
- Database ready for API integration

### Collaboration Points
- **Task Dependencies:** None - Can start Sprint 1 tasks immediately
- **Handoffs TO:** Backend API Specialist, XML/Integration Specialist, DevOps Specialist
- **Communication:** Update status daily, document blockers immediately
- **Sprint Focus:** Database foundation for MVP

---

## 🔧 ROLE 2: BACKEND API SPECIALIST

### Primary Responsibilities

1. **API Controller Implementation**
   - Implement `PlsController.cs` with all endpoints
   - Implement `DataController.PLS.cs` partial class
   - Create business logic service layer (`PlsService`)
   - Handle authentication and authorization

2. **API Endpoints** (from Project Blueprint Section 5)
   - `POST /api/pls/create` - Create new PLS listing
   - `PUT /api/pls/{listingNumber}` - Update listing
   - `GET /api/pls/{listingNumber}` - Get listing details
   - `GET /api/pls/my-listings` - Get user's listings
   - `POST /api/pls/{listingNumber}/render` - Generate GenieCloud XML
   - `POST /api/pls/pre-populate` - Pre-populate from TitleData
   - `POST /api/pls/upload-photo` - Upload property photos
   - `POST /api/pls/generate-description` - Generate AI description
   - `PUT /api/pls/archive/{listingNumber}` - Archive listing

3. **Data Validation**
   - Validate all input data
   - Handle errors gracefully
   - Return proper HTTP status codes

4. **Integration Points**
   - TitleGenie data pre-population
   - Paisley AI description generation
   - GenieCloud XML generation (coordinate with XML Specialist)

### Key Documents to Reference
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 5)
- `08_Source_Code/PlsController_Complete_v1.cs`
- `08_Source_Code/DataController_PLS_Complete_v1.cs`
- `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_03_API_DEVELOPMENT_v1.md`

### Deliverables
- [ ] All API endpoints implemented
- [ ] Request/response validation
- [ ] Error handling
- [ ] API documentation
- [ ] Unit tests for critical endpoints

### Success Criteria
- All endpoints return correct HTTP status codes
- Data validation prevents invalid input
- Integration with Database Specialist's stored procedures
- Ready for Frontend UI integration

### Collaboration Points
- **Task Dependencies:** Database tasks, XML framework tasks (for Sprint 1)
- **Handoffs TO:** Frontend UI Specialist, XML/Integration Specialist
- **Communication:** Update status daily, coordinate with XML Specialist on `/render` endpoint
- **Sprint Focus:** API endpoints for MVP

---

## 🎨 ROLE 3: FRONTEND UI SPECIALIST

### Primary Responsibilities

1. **Angular Component Implementation**
   - `PlsMyListingsComponent` - List all user's PLS listings
   - `PlsCreateComponent` - Create new PLS listing form
   - `PlsEditComponent` - Edit existing listing
   - `PlsPhotoUploadComponent` - Photo upload interface
   - `PlsAreaSelectorComponent` - Area selection for Paisley
   - `PlsAIDescriptionComponent` - AI description generation UI

2. **User Experience Flow**
   - Address lookup (Mapbox integration)
   - Area selection (for Paisley context)
   - Property data pre-population display
   - Photo upload workflow
   - AI description generation workflow
   - Form validation and error display

3. **Mobile-First Design**
   - Responsive design (mobile, tablet, desktop)
   - Touch-friendly interface
   - Fast loading and optimization

4. **Integration**
   - API calls to Backend API endpoints
   - Mapbox address autocomplete
   - Photo upload to S3/GenieCloud

### Key Documents to Reference
- `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md`
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 10)
- `08_Source_Code/pls-create.component.*`
- `09_Prototypes/PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html`
- `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_04_UI_FRONTEND_v1.md`

### Deliverables
- [ ] All Angular components implemented
- [ ] Responsive design (mobile-first)
- [ ] Form validation
- [ ] Error handling and user feedback
- [ ] Integration with Backend API

### Success Criteria
- All components load and function correctly
- Forms validate input client-side and server-side
- Mobile-responsive design works on all screen sizes
- Integration with Backend API endpoints working

### Collaboration Points
- **Task Dependencies:** Backend API tasks (for Sprint 1)
- **Handoffs TO:** DevOps Specialist
- **Communication:** Update status daily, coordinate with Backend API Specialist
- **Sprint Focus:** MVP UI components

---

## 📄 ROLE 4: XML/INTEGRATION SPECIALIST

### Primary Responsibilities

1. **GenieCloud XML Generation**
   - Implement XML generation from PLS listing data
   - Follow `CONTRACT_PLS_to_GenieCloud_v6.1.md` exactly
   - Map PLS data to GenieCloud XML structure
   - Handle all required XML fields

2. **GenieCloud API Integration**
   - Implement `POST /api/pls/{listingNumber}/render` endpoint
   - Call GenieCloud API to create collection
   - Handle GenieCloud responses
   - Return marketing asset URLs

3. **Collection System**
   - Understand GenieCloud Collection Editor
   - Implement collection creation workflow
   - Handle collection updates

4. **CTA System Integration**
   - Implement call-to-action system
   - Handle CTA tracking and analytics

5. **Asset Selection System**
   - Implement HubAssetSetting integration
   - Handle asset order assignment

### Key Documents to Reference
- `11_Contracts/CONTRACT_PLS_to_GenieCloud_v6.1.md` - **CRITICAL - READ FIRST**
- `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 7)
- `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_06_INTEGRATION_POINTS_v1.md`

### Deliverables
- [ ] XML generation code implemented
- [ ] GenieCloud API integration working
- [ ] Collection creation workflow
- [ ] Marketing asset generation verified
- [ ] XML schema validation

### Success Criteria
- XML matches contract specification exactly
- GenieCloud accepts XML and creates collection
- Marketing assets (social ads, postcards, brochures) generated
- Landing pages created successfully

### Collaboration Points
- **Task Dependencies:** Database tasks (needs PLS data structure for Sprint 1)
- **Handoffs TO:** Backend API Specialist (for /render endpoint), DevOps Specialist
- **Communication:** Coordinate closely with Backend API Specialist on `/render` endpoint
- **Sprint Focus:** XML framework for MVP

---

## 🚀 ROLE 5: DEVOPS/DEPLOYMENT SPECIALIST

### Primary Responsibilities

1. **Deployment Automation**
   - Create deployment scripts (PowerShell/Python)
   - Automate database script execution
   - Automate code deployment
   - Handle configuration file management

2. **Configuration Management**
   - Manage Web.config and DLL.config files
   - Handle connection strings
   - Manage environment-specific settings
   - **CRITICAL:** Include DLL.config in all backups

3. **Testing Infrastructure**
   - Set up test environments (Sandbox, Stage)
   - Create automated test scripts
   - Implement integration testing
   - Performance testing

4. **Deployment Procedures**
   - Follow Fortune 500 enterprise procedures
   - Create timestamped backups before deployment
   - Verify rollback procedures
   - Pre/post-deployment checklists

5. **CI/CD Pipeline**
   - Set up Azure DevOps pipelines (if applicable)
   - Automate build and deployment
   - Handle deployment approvals

### Key Documents to Reference
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 14)
- `02_Scripts/*.ps1` (PowerShell deployment scripts)
- `05_Verification_Audits/PLS_TEST_READINESS_STATUS_v1.md`
- `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_05_DEPLOYMENT_DEVOPS_v1.md`

### Deliverables
- [ ] Deployment scripts for all environments
- [ ] Backup and rollback procedures
- [ ] Pre/post-deployment checklists
- [ ] Test environment setup
- [ ] Configuration management scripts

### Success Criteria
- All deployments follow enterprise procedures
- Backups created before every deployment
- Rollback procedures tested and verified
- Sandbox → Stage → Production deployment path working

### Collaboration Points
- **Task Dependencies:** None - Supports all sprints
- **Handoffs TO:** Provides deployment support to all roles
- **Communication:** Supports all sprints, coordinates deployments
- **Sprint Focus:** Deployment infrastructure for all sprints

---

## 📊 STATUS TRACKING

### Master Status Dashboard

**Current Sprint:** Sprint 1 - MVP Foundation  
**Sprint Goal:** Basic PLS listing creation and listing with GenieCloud integration  
**Sprint Duration:** 2 weeks  
**Overall Progress:** 0%  
**Blockers:** 0  
**Next Milestone:** Sprint 1 MVP complete

### Agent Status Summary

| Agent | Role | Status | Sprint Focus | Progress | Last Update |
|-------|------|--------|--------------|----------|-------------|
| **Agent 1** | Database Specialist | ⏳ Ready | Database foundation for MVP | 0% | 01/13/2026 |
| **Agent 2** | Backend API Specialist | ⏳ Waiting | API endpoints for MVP | 0% | 01/13/2026 |
| **Agent 3** | Frontend UI Specialist | ⏳ Waiting | MVP UI components | 0% | 01/13/2026 |
| **Agent 4** | XML/Integration Specialist | ⏳ Ready | XML framework for MVP | 0% | 01/13/2026 |
| **Agent 5** | DevOps/Deployment Specialist | ✅ Active | Deployment infrastructure | 0% | 01/13/2026 |

### Sprint 1 Tasks

**Sprint 1: MVP Foundation** - ⏳ In Progress  
- Database schema and PLS number generation (Database Specialist) - ⏳ Not Started
- XML generation framework (XML/Integration Specialist) - ⏳ Waiting for Database
- MVP API endpoints (Backend API Specialist) - ⏳ Waiting for Database + XML
- MVP UI components (Frontend UI Specialist) - ⏳ Waiting for Backend API
- Sandbox deployment infrastructure (DevOps Specialist) - ⏳ In Progress

**Sprint Model:** Tasks assigned per sprint, dependencies are task-based, not phase-based. See `SPRINT_MODEL_GUIDE_v1.md` for details.

---

## 🤝 COLLABORATION PROTOCOLS

### Daily Workflow

**Every Agent Should:**
1. **Morning:** Check master status dashboard for dependencies
2. **Morning:** Check blockers file for new blockers
3. **Morning:** Check handoffs file for new handoffs
4. **During Work:** Update status as you progress
5. **End of Day:** Update status and document blockers

### When Completing Work
1. Test your deliverable thoroughly
2. Create handoff entry in handoffs file
3. Update your status
4. Update master status dashboard

### When Blocked
1. Document blocker immediately
2. Tag affected agents
3. Update status with blocker details

### When Receiving Handoff
1. Read handoff entry
2. Review deliverables
3. Test integration
4. Confirm receipt
5. Update status

---

## 🚀 QUICK START GUIDE

### For New Agents

1. **Read:** This master document (you're reading it now)
2. **Read:** `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md` (original handoff)
3. **Read:** Your role section above
4. **Check:** Status tracking section for current project status
5. **Start:** Begin working on your deliverables

### For Project Managers

1. **Review:** This master document for overview
2. **Monitor:** Status tracking section daily
3. **Check:** Blockers file for issues
4. **Review:** Handoffs file for progress

---

## 📁 EXHIBITS CATALOG

**DRA-2026 Note:** The following files exist as separate "exhibits" for operational use, but this master document is the single source of truth. All content is consolidated above.

### Role Definition Exhibits (Reference Only)
- `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md` - Database Specialist role (content consolidated above)
- `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md` - Backend API Specialist role (content consolidated above)
- `AgentCollaboration/AGENT_ROLE_FRONTEND_UI_SPECIALIST_v1.md` - Frontend UI Specialist role (content consolidated above)
- `AgentCollaboration/AGENT_ROLE_XML_INTEGRATION_SPECIALIST_v1.md` - XML/Integration Specialist role (content consolidated above)
- `AgentCollaboration/AGENT_ROLE_DEVOPS_SPECIALIST_v1.md` - DevOps/Deployment Specialist role (content consolidated above)

### Status Tracking Exhibits (Operational - Updated Daily)
- `AgentStatus/AGENT_STATUS_ALL_v1.md` - Master status dashboard (operational file, updated daily)
- `AgentStatus/AGENT_STATUS_DATABASE_v1.md` - Database Specialist status (operational file)
- `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md` - Backend API Specialist status (operational file)
- `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md` - Frontend UI Specialist status (operational file)
- `AgentStatus/AGENT_STATUS_XML_INTEGRATION_v1.md` - XML/Integration Specialist status (operational file)
- `AgentStatus/AGENT_STATUS_DEVOPS_v1.md` - DevOps/Deployment Specialist status (operational file)

### Collaboration Exhibits (Operational - Updated as Needed)
- `AgentCollaboration/BLOCKERS_v1.md` - Active blockers tracking (operational file, updated when blockers occur)
- `AgentCollaboration/HANDOFFS_v1.md` - Agent handoff tracking (operational file, updated when handoffs occur)

### Reference Exhibits (Historical/Reference)
- `AgentCollaboration/AGENT_COORDINATION_MASTER_v1.md` - Previous coordination guide (superseded by this document)
- `AgentCollaboration/AGENT_SETUP_GUIDE_v1.md` - Setup guide (content consolidated above)
- `AgentCollaboration/AGENT_SYSTEM_SUMMARY_v1.md` - System summary (content consolidated above)
- `AgentCollaboration/README_AGENT_SYSTEM_v1.md` - System overview (content consolidated above)
- `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md` - Original project roles handoff (reference document)

**Note:** Exhibits are maintained for operational convenience and historical reference, but this master document contains all authoritative content.

---

## 🚨 CRITICAL RULES

1. **Never Overwrite Files** - Always version (v1 → v2 → v3)
2. **Update Status Daily** - Keep status files current
3. **Document Blockers Immediately** - Don't wait
4. **Test Before Handoff** - Verify your work
5. **Follow Role Definitions** - Stay within your scope
6. **Sandbox First** - All work in Sandbox before Stage/Production
7. **DLL.config Backup** - DevOps MUST include DLL.config in backups

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.1 | 01/13/2026 9:00 PM | **SPRINT MODEL UPDATE:** Replaced phase-based model with SCRUM/SPRINT model. Removed all phase references, replaced with sprint-based language. Updated status tracking to show current sprint instead of phases. Changed dependencies from phase-based to task-based. Added sprint model section. Agents now work on sprint tasks, not phases. See `SPRINT_MODEL_GUIDE_v1.md` for details. |
| 1.0 | 01/13/2026 7:34 PM | **INITIAL MASTER VERSION:** Created DRA-2026 compliant master document consolidating all agent coordination content. Consolidated 5 role definitions, status tracking, collaboration protocols, and quick start guide into single master document. Cataloged 18 existing files as exhibits. This document is now the single source of truth for agent coordination. All content from separate files is consolidated above. Exhibits remain for operational use but this master is authoritative. |

---

**Status:** ✅ ACTIVE - DRA-2026 Compliant Master Document

**Location:** `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete\AgentCollaboration\PLS_AGENT_COORDINATION_MASTER_v1.md`

**This is the SINGLE SOURCE OF TRUTH for agent coordination. All content is consolidated here. Exhibits are cataloged above for reference.**
