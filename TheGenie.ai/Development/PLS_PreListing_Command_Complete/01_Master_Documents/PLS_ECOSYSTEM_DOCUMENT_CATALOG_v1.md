# PLS Ecosystem Document Catalog & Team Agent Assignments

**Version:** 1.0  
**Created:** 01/13/2026 11:00 PM  
**Last Updated:** 01/13/2026 11:00 PM  
**Author:** JR (Project Manager)  
**Status:** 📋 **DOCUMENT CATALOG COMPLETE - READY FOR AGENT ASSIGNMENTS**

---

## 🎯 EXECUTIVE SUMMARY

This document catalogs **ALL** relevant documentation from three interconnected projects:
1. **Paisley** - AI content generation system (Pre-Listing Focused integration)
2. **Title Genie** - Property research and data source
3. **PLS (Pre-Listing Command)** - Current project (RESO Listing Engine)

**Purpose:** Provide complete document library for Team Agents to understand ecosystem context, dependencies, and integration points before beginning implementation.

**Critical Connection:** PLS replaces/enhances Paisley's "Pre-Listing Focused" prompt (ChatStartTypeId=3) and leverages Title Genie data for property pre-population.

---

## 📚 TABLE OF CONTENTS

1. [Paisley Project Document Catalog](#1-paisley-project-document-catalog)
2. [Title Genie Project Document Catalog](#2-title-genie-project-document-catalog)
3. [PLS Project Document Catalog](#3-pls-project-document-catalog)
4. [Ecosystem Integration Points](#4-ecosystem-integration-points)
5. [Team Agent Assignments](#5-team-agent-assignments)
6. [Agent Role Responsibilities Matrix](#6-agent-role-responsibilities-matrix)

---

## 1. PAISLEY PROJECT DOCUMENT CATALOG

**Location:** `D:\Cursor\TheGenie.ai\Development\Paisley\`  
**Purpose:** AI content generation system with 7 chat types, including ChatStartTypeId=3 (Pre-Listing Focused) which PLS will replace/enhance

### 1.1 Master Documents

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **MASTER_INDEX** | 3.0 | `Paisley/MASTER_INDEX_v3.md` | Central index of all Paisley documents | ⭐ Reference for ecosystem context |
| **MASTER_RULES** | 1.1 | `Paisley/MASTER_RULES_v1.md` | File versioning, data quality rules | ⭐ Follow same versioning rules |
| **Project Scope Blueprint** | 1.2 | `Paisley/PAISLEY_PROJECT_SCOPE_BLUEPRINT_v1.md` | Intent-focused project agreement | ⭐ Understand Pre-Listing Suite context |
| **Project README** | 1.0 | `Paisley/PAISLEY_PROJECT_README_v1.md` | Project overview and status | ⭐ General context |

### 1.2 Data & Specifications

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Pre-Listing Data Catalog v2** | 2.0 | `Paisley/PAISLEY_PRELISTING_DATA_CATALOG_v2.md` | Complete data field catalog (500+ fields) | ⭐⭐⭐ **CRITICAL** - Data available for PLS |
| **Pre-Listing Data Catalog v1** | 1.0 | `Paisley/PAISLEY_PRELISTING_DATA_CATALOG_v1.md` | Original data catalog | ⭐ Reference |
| **Complete Reverse Engineering** | 1.0 | `Paisley/PAISLEY_COMPLETE_REVERSE_ENGINEERING_v1.md` | System architecture analysis | ⭐ Technical context |
| **Pre-Listing API Specification** | 1.0 | `Paisley/PRELISTING_API_SPECIFICATION_v1.md` | API endpoints and integration | ⭐⭐⭐ **CRITICAL** - Integration points |

### 1.3 Discovery & Analysis

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Complete Walkthrough** | 1.0 | `Paisley/PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md` | Complete pre-listing workflow | ⭐⭐⭐ **CRITICAL** - User flow reference |
| **UI Discovery Findings** | 1.1 | `Paisley/PAISLEY_UI_DISCOVERY_FINDINGS_v1.1.md` | UI/UX discovery results | ⭐ UI patterns |
| **Pain Points Priority** | 1.0 | `Paisley/PAISLEY_PAIN_POINTS_PRIORITY_v1.md` | Prioritized pain points | ⭐ Problem context |
| **Discovery Questions** | 1.0 | `Paisley/PAISLEY_DISCOVERY_QUESTIONS_v1.md` | Discovery questions document | ⭐ Reference |
| **My Answers to Discovery** | 1.0 | `Paisley/PAISLEY_MY_ANSWERS_TO_DISCOVERY_QUESTIONS_v1.md` | Answers to discovery questions | ⭐ Reference |
| **Discovery Communication Gap** | 1.0 | `Paisley/PAISLEY_DISCOVERY_COMMUNICATION_GAP_ANALYSIS_v1.md` | Communication gap analysis | ⭐ Reference |
| **Deep Discovery Permissions** | 1.0 | `Paisley/PAISLEY_DEEP_DISCOVERY_PERMISSIONS_CLOUD_GPT_v1.md` | Permissions and cloud analysis | ⭐ Security context |

### 1.4 Design & Redesign

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Revolutionary Redesign** | 1.0 | `Paisley/PAISLEY_PRELISTING_REVOLUTIONARY_REDESIGN_v1.md` | Redesign vision document | ⭐ Design inspiration |
| **CSS Improvements Spec** | 1.0 | `Paisley/PAISLEY_CSS_IMPROVEMENTS_SPEC_v1.md` | CSS improvement specifications | ⭐ UI styling |
| **Property Profile Gap Analysis** | 1.0 | `Paisley/PROPERTY_PROFILE_GAP_ANALYSIS_v1.md` | Field-by-field comparison | ⭐ Data requirements |

### 1.5 Workspace Memory Logs ⭐⭐⭐ **CRITICAL - READ THESE**

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Pre-Listing Command Handoff** | 1.0 | `Paisley/WORKSPACE_MEMORY_LOG_PreListing_Command_Handoff_v1.md` | Handoff to PLS project | ⭐⭐⭐ **CRITICAL** - Direct PLS handoff |
| **Pre-Listing Command v3** | 3.0 | `Paisley/WORKSPACE_MEMORY_LOG_PreListing_Command_v3_2025-12-25.md` | Latest PLS integration work | ⭐⭐⭐ **CRITICAL** - Recent PLS work |
| **TitleGenie Paisley Discovery Session** | 2.0 | `Paisley/WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Discovery_Session_2025-12-19_v2.md` | Joint discovery session | ⭐⭐⭐ **CRITICAL** - Integration context |
| **TitleGenie Paisley Discovery** | 1.0 | `Paisley/WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Discovery_2025-12-18_v1.md` | Discovery session | ⭐ Integration context |
| **TitleGenie Paisley Study Session** | 1.0 | `Paisley/WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Study_Session_2025-12-17.md` | Study session | ⭐ Integration context |
| **Workspace Memory Log** | 1.0 | `Paisley/PAISLEY_WORKSPACE_MEMORY_LOG_v1.md` | General workspace memory | ⭐ Context |

### 1.6 Pre-Listing Command Sub-Project ⭐⭐⭐ **CRITICAL - PLS CONNECTION**

**Location:** `D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\`

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Contract PLS to GenieCloud** | 6.1 | `Paisley/Pre.Listing.Command/Docs/CONTRACT_PLS_to_GenieCloud_v6.1.md` | PLS ↔ GenieCloud contract | ⭐⭐⭐ **CRITICAL** - XML generation contract |
| **Project Status v4** | 4.0 | `Paisley/PRELISTING_COMMAND_PROJECT_STATUS_v4.md` | Latest project status | ⭐⭐⭐ **CRITICAL** - PLS status |
| **Project Status v3** | 3.0 | `Paisley/PRELISTING_COMMAND_PROJECT_STATUS_v3.md` | Previous status | ⭐ Reference |
| **Project Status v2** | 2.0 | `Paisley/PRELISTING_COMMAND_PROJECT_STATUS_v2.md` | Previous status | ⭐ Reference |
| **Project Status v1** | 1.0 | `Paisley/PRELISTING_COMMAND_PROJECT_STATUS_v1.md` | Initial status | ⭐ Reference |
| **SOP Pre-Listing Command Master v2** | 2.0 | `Paisley/SOP_PRELISTING_COMMAND_MASTER_v2.md` | Master SOP | ⭐ Process reference |
| **SOP Pre-Listing Command Master v1** | 1.0 | `Paisley/SOP_PRELISTING_COMMAND_MASTER_v1.md` | Original SOP | ⭐ Reference |
| **SOP Pre-Listing Command Execution** | 1.0 | `Paisley/SOP_PRELISTING_COMMAND_EXECUTION_v1.md` | Execution procedures | ⭐ Process reference |
| **SOP Pre-Listing Command Prototype v2** | 2.0 | `Paisley/SOP_PRELISTING_COMMAND_PROTOTYPE_v2.md` | Prototype procedures | ⭐ Reference |
| **SOP Pre-Listing Command Prototype v1** | 1.0 | `Paisley/SOP_PRELISTING_COMMAND_PROTOTYPE_v1.md` | Original prototype | ⭐ Reference |

### 1.7 Paisley 2.0 Sub-Project

**Location:** `D:\Cursor\TheGenie.ai\Development\Paisley\Paisley2.0\`

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Project Handoff** | 1.0 | `Paisley/Paisley2.0/PAISLEY_PROJECT_HANDOFF_v1.md` | Complete handoff documentation | ⭐ Context |
| **Project Inventory** | 1.0 | `Paisley/Paisley2.0/PAISLEY_PROJECT_INVENTORY_v1.md` | Project inventory | ⭐ Reference |
| **Consolidation Plan** | 1.0 | `Paisley/Paisley2.0/PAISLEY_CONSOLIDATION_PLAN_v1.md` | Consolidation plan | ⭐ Reference |
| **TitleRep TitleGenie Workflow** | 1.0 | `Paisley/Paisley2.0/WORKFLOW_TITLEREP_TITLEGENIE_v1.md` | Title rep workflow | ⭐ Context |

### 1.8 Key Paisley Integration Points for PLS

**ChatStartTypeId=3 (Pre-Listing Focused):**
- **Current:** Paisley generates AI descriptions for pre-listing presentations
- **PLS Enhancement:** PLS will replace/enhance this with structured listing data + area data
- **Integration:** PLS calls Paisley API with ChatStartTypeId=3 to generate descriptions
- **Data Flow:** PLS listing data → Paisley API → AI-generated description → PLS UI

**Area Selection:**
- **Critical:** PLS requires area selection for Listing Command integration
- **Paisley Context:** Paisley uses area data for market context in descriptions
- **Integration:** PLS passes selected area to Paisley for enhanced descriptions

---

## 2. TITLE GENIE PROJECT DOCUMENT CATALOG

**Location:** `D:\Cursor\TheGenie.ai\Development\TitleGenie\`  
**Purpose:** Property research system providing Attom data, MLS data, and property intelligence for PLS pre-population

### 2.1 Master Documents

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Master Compilation** | 1.0 | `TitleGenie/TITLEGENIE_MASTER_COMPILATION_v1.md` | Complete findings compilation | ⭐⭐⭐ **CRITICAL** - Complete Title Genie context |
| **Complete Strategy Compilation** | 1.0 | `TitleGenie/TITLEGENIE_COMPLETE_STRATEGY_COMPILATION_v1.md` | Strategy compilation | ⭐ Strategy context |
| **MVP Roadmap GTM Plan** | 2.0 | `TitleGenie/TITLEGENIE_MVP_ROADMAP_GTM_PLAN_v2.md` | Roadmap and GTM plan | ⭐ Business context |
| **Paisley Dashboard Design** | 1.0 | `TitleGenie/TITLEGENIE_PAISLEY_DASHBOARD_DESIGN_v1.md` | Dashboard design | ⭐ UI reference |

### 2.2 Discovery Documents

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Discovery Compilation** | 1.2 | `TitleGenie/Discovery/TITLEGENIE_DISCOVERY_COMPILATION_v1.2.md` | Complete discovery findings | ⭐⭐⭐ **CRITICAL** - Complete discovery |
| **Discovery Compilation v1.1** | 1.1 | `TitleGenie/Archive/Deprecated_Versions/DEPRECATED - SUPERSEDED BY v1.2 - TITLEGENIE_DISCOVERY_COMPILATION_v1.1.md` | Previous version | ⭐ Reference |
| **Discovery Compilation v1** | 1.0 | `TitleGenie/Archive/Deprecated_Versions/DEPRECATED - SUPERSEDED BY v1.2 - TITLEGENIE_DISCOVERY_COMPILATION_v1.md` | Original version | ⭐ Reference |

### 2.3 GTM & Strategy

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Outreach Email Sequence** | 1.0 | `TitleGenie/GTM/TITLEGENIE_OUTREACH_EMAIL_SEQUENCE_v1.md` | Email outreach sequence | ⭐ Marketing context |
| **Trial Experience** | 1.0 | `TitleGenie/GTM/TITLEGENIE_TRIAL_EXPERIENCE_v1.md` | Trial experience design | ⭐ User experience |

### 2.4 SOPs

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Onboarding SOP** | 1.0 | `TitleGenie/SOPs/TITLEGENIE_ONBOARDING_SOP_v1.md` | Onboarding procedures | ⭐ Process reference |

### 2.5 Workspace Memory Logs ⭐⭐⭐ **CRITICAL - READ THESE**

| Document | Version | Location | Purpose | PLS Relevance |
|----------|---------|----------|---------|---------------|
| **Drive Migration** | 1.0 | `TitleGenie/MemoryLogs/WORKSPACE_MEMORY_LOG_Drive_Migration_2025-01-15.md` | Drive migration log | ⭐ Context |
| **TitleGenie Discovery (Archived)** | 1.0 | `TitleGenie/Archive/Session_Logs/DEPRECATED - HISTORICAL - WORKSPACE_MEMORY_LOG_TitleGenie_Discovery_2025-01-15.md` | Historical discovery | ⭐ Reference |
| **TitleGenie Paisley Discovery Session (Archived)** | 2.0 | `TitleGenie/Archive/Session_Logs/DEPRECATED - HISTORICAL - WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Discovery_Session_2025-12-19_v2.md` | Historical session | ⭐ Reference |
| **TitleGenie Paisley Discovery (Archived)** | 1.0 | `TitleGenie/Archive/Session_Logs/DEPRECATED - HISTORICAL - WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Discovery_2025-12-18_v1.md` | Historical discovery | ⭐ Reference |
| **TitleGenie Paisley Study Session (Archived)** | 1.0 | `TitleGenie/Archive/Session_Logs/DEPRECATED - HISTORICAL - WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Study_Session_2025-12-17.md` | Historical study | ⭐ Reference |

### 2.6 Key Title Genie Integration Points for PLS

**Property Pre-Population:**
- **Data Source:** `TitleData.dbo.AttomDataAssessor` (318 fields)
- **Data Source:** `TitleData.dbo.ViewAssessor_v3` (315+ fields including mortgages, liens, HOA, AVM, flood zone)
- **Data Source:** `MlsListing.dbo.Listing` (Historical MLS data)
- **Integration:** PLS calls Title Genie data via `POST /api/pls/pre-populate` endpoint
- **Data Flow:** Address → PlaceKey → TitleData lookup → Pre-populate PLS form

**Field Mapping:**
- **Critical Document:** `PLS_PreListing_Command_Complete/01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
- **Purpose:** Maps 318 TitleData fields to 93 MlsListing fields
- **Usage:** Backend API Specialist uses this for pre-population logic

---

## 3. PLS PROJECT DOCUMENT CATALOG

**Location:** `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete\`  
**Purpose:** Current project - RESO Listing Engine for pre-MLS listings

### 3.1 Master Documents (Current Project)

| Document | Version | Location | Purpose | Status |
|----------|---------|----------|---------|--------|
| **Project Blueprint** | 2.0 | `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` | ⭐⭐⭐ **MASTER BLUEPRINT** - Single source of truth | ✅ Active |
| **Project Blueprint** | 1.7 | `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` | Previous version | ⚠️ Superseded |
| **Master Specification** | 3.0 | `01_Master_Documents/PLS_MASTER_SPECIFICATION_v3.md` | Complete specification | ✅ Active |
| **Database Schema Relational** | 1.0 | `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md` | Database schema | ✅ Active |
| **Wireframe Specifications** | 1.0 | `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md` | UI wireframes | ✅ Active |
| **GenieCloud XML Mapping** | 1.0 | `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md` | XML mapping | ✅ Active |
| **TitleData to MlsListing Mapping** | 1.0 | `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md` | Field mapping | ✅ Active |
| **Contract PLS to GenieCloud** | 6.1 | `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md` | GenieCloud contract | ✅ Active |
| **Dev Team Onboarding Package** | 1.0 | `01_Master_Documents/PLS_DEV_TEAM_ONBOARDING_PACKAGE_v1.md` | Onboarding guide | ✅ Active |
| **Dev Team Preparation Checklist** | 1.0 | `01_Master_Documents/PLS_DEV_TEAM_PREPARATION_CHECKLIST_v1.md` | Preparation checklist | ✅ Active |
| **Platform Documentation Master** | 1.0 | `01_Master_Documents/PLS_PLATFORM_DOCUMENTATION_MASTER_v1.md` | Platform documentation | ✅ Active |
| **Project Reset Master** | 1.0 | `01_Master_Documents/PLS_PROJECT_RESET_MASTER_v1.md` | Project reset | ✅ Active |
| **Blueprint Gap Analysis** | 1.0 | `01_Master_Documents/PLS_BLUEPRINT_GAP_ANALYSIS_v1.md` | Gap analysis | ✅ Active |
| **3-Layer Gap Analysis** | 1.0 | `01_Master_Documents/PLS_3_LAYER_GAP_ANALYSIS_v1.md` | Architecture gap analysis | ✅ Active |
| **DRA-2026 Compliance** | 1.0 | `01_Master_Documents/PLS_DRA_2026_COMPLIANCE_v1.md` | Compliance documentation | ✅ Active |
| **Documentation Index** | 1.0 | `01_Master_Documents/DOCUMENTATION_INDEX_v1.md` | Documentation index | ✅ Active |

### 3.2 Agent Collaboration Documents

| Document | Version | Location | Purpose | Status |
|----------|---------|----------|---------|--------|
| **Agent Setup Guide** | 1.0 | `AgentCollaboration/AGENT_SETUP_GUIDE_v1.md` | Agent setup instructions | ✅ Active |
| **Agent Role: Database Specialist** | 1.0 | `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md` | Database role definition | ✅ Active |
| **Agent Role: Backend API Specialist** | 1.0 | `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md` | Backend API role definition | ✅ Active |
| **Agent Role: Frontend UI Specialist** | 1.0 | `AgentCollaboration/AGENT_ROLE_FRONTEND_UI_SPECIALIST_v1.md` | Frontend UI role definition | ✅ Active |
| **Agent Role: XML Integration Specialist** | 1.0 | `AgentCollaboration/AGENT_ROLE_XML_INTEGRATION_SPECIALIST_v1.md` | XML integration role definition | ✅ Active |
| **Agent Role: DevOps Specialist** | 1.0 | `AgentCollaboration/AGENT_ROLE_DEVOPS_SPECIALIST_v1.md` | DevOps role definition | ✅ Active |

### 3.3 Agent Status Documents

| Document | Version | Location | Purpose | Status |
|----------|---------|----------|---------|--------|
| **Agent Status: All** | 1.0 | `AgentStatus/AGENT_STATUS_ALL_v1.md` | Combined status view | ✅ Active |
| **Agent Status: Database** | 1.0 | `AgentStatus/AGENT_STATUS_DATABASE_v1.md` | Database status | ✅ Active |
| **Agent Status: Backend API** | 1.0 | `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md` | Backend API status | ✅ Active |
| **Agent Status: Frontend UI** | 1.0 | `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md` | Frontend UI status | ✅ Active |
| **Agent Status: XML Integration** | 1.0 | `AgentStatus/AGENT_STATUS_XML_INTEGRATION_v1.md` | XML integration status | ✅ Active |
| **Agent Status: DevOps** | 1.0 | `AgentStatus/AGENT_STATUS_DEVOPS_v1.md` | DevOps status | ✅ Active |

---

## 4. ECOSYSTEM INTEGRATION POINTS

### 4.1 Paisley → PLS Integration

**ChatStartTypeId=3 (Pre-Listing Focused):**
- **Current State:** Paisley generates AI descriptions for pre-listing presentations
- **PLS Enhancement:** PLS replaces/enhances this with structured listing data + area data
- **Integration Point:** `POST /api/pls/generate-description` endpoint
- **Data Flow:**
  1. PLS user creates listing
  2. PLS system collects listing data + selected area data
  3. PLS calls Paisley API with ChatStartTypeId=3
  4. Paisley generates AI description
  5. PLS displays description in UI with "Edit" button

**Area Selection:**
- **Critical:** PLS requires area selection for Listing Command integration
- **Paisley Context:** Paisley uses area data for market context in descriptions
- **Integration:** PLS passes selected area to Paisley for enhanced descriptions

### 4.2 Title Genie → PLS Integration

**Property Pre-Population:**
- **Data Source:** `TitleData.dbo.AttomDataAssessor` (318 fields)
- **Data Source:** `TitleData.dbo.ViewAssessor_v3` (315+ fields)
- **Data Source:** `MlsListing.dbo.Listing` (Historical MLS data)
- **Integration Point:** `POST /api/pls/pre-populate` endpoint
- **Data Flow:**
  1. PLS user enters address
  2. PLS system looks up PlaceKey
  3. PLS calls Title Genie data via `GetPropertiesFromPlaceKey`
  4. Title Genie returns property data from TitleData + MlsListing
  5. PLS pre-populates form with property data

**Field Mapping:**
- **Critical Document:** `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
- **Purpose:** Maps 318 TitleData fields to 93 MlsListing fields
- **Usage:** Backend API Specialist uses this for pre-population logic

### 4.3 GenieCloud → PLS Integration

**XML Generation & Rendering:**
- **Contract:** `CONTRACT_PLS_to_GenieCloud_v6.1.md` (CRITICAL - must follow exactly)
- **Integration Point:** `POST /api/pls/{listingNumber}/render` endpoint
- **Data Flow:**
  1. PLS user saves listing
  2. PLS system generates XML per contract
  3. PLS calls GenieCloud API to create collection
  4. GenieCloud renders marketing assets (social ads, postcards, brochures, landing pages)
  5. PLS returns collection URL to user

**Marketing Assets:**
- Social ads (Facebook, Instagram)
- Postcards
- Brochures
- Landing pages
- Market reports

### 4.4 Listing Command → PLS Integration

**Circle Prospecting Automation:**
- **PropertyCastTypeId:** 4 (for PLS listings)
- **Integration:** PLS listings automatically trigger Listing Command workflows
- **Data Flow:**
  1. PLS listing created with PropertyCastTypeId=4
  2. Listing Command detects new PLS listing
  3. Listing Command creates circle prospecting campaign
  4. Listing Command sends marketing materials to neighbors

---

## 5. TEAM AGENT ASSIGNMENTS

### 5.1 Agent Role Overview

**5 Specialized Roles Defined:**
1. **Database Specialist** - Schema, stored procedures, data migration
2. **Backend API Specialist** - REST API endpoints, business logic, controllers
3. **Frontend UI Specialist** - Angular components, user interface, UX
4. **XML/Integration Specialist** - GenieCloud XML generation, API integration
5. **DevOps/Deployment Specialist** - Deployment automation, configuration, testing

### 5.2 Phase-Based Implementation Order

**Phase 1: Database Foundation** (Database Specialist)
- Execute normalized schema v3.0
- Create PLS number sequence table and stored procedure
- Create master data lookup tables
- Verify all tables, indexes, and constraints
- **Status:** ⏳ Ready to start

**Phase 2: Backend API** (Backend API Specialist)
- Implement all API endpoints
- Integrate Title Genie pre-population
- Integrate Paisley AI description generation
- Coordinate with XML Specialist on `/render` endpoint
- **Status:** ⏳ Waiting for Phase 1

**Phase 3: Frontend UI** (Frontend UI Specialist)
- Implement Angular components
- Mobile-first responsive design
- Form validation and error handling
- Integration with Backend API
- **Status:** ⏳ Waiting for Phase 2

**Phase 4: XML/Integration** (XML/Integration Specialist)
- Implement GenieCloud XML generation
- Follow `CONTRACT_PLS_to_GenieCloud_v6.1.md` exactly
- Integrate with Backend API `/render` endpoint
- Test marketing asset generation
- **Status:** ⏳ Waiting for Phase 2 (coordinates with Backend)

**Phase 5: DevOps/Deployment** (DevOps/Deployment Specialist)
- Create deployment scripts
- Set up test environments
- Implement Fortune 500 enterprise procedures
- Create backup and rollback procedures
- **Status:** ✅ Active - Supporting all phases

### 5.3 Agent Assignment Matrix

| Agent Role | Primary Documents | Paisley Documents | Title Genie Documents | PLS Documents |
|------------|-------------------|-------------------|----------------------|---------------|
| **Database Specialist** | PLS Database Schema, SQL Scripts | Data Catalog v2 (field reference) | Master Compilation (data context) | All database docs |
| **Backend API Specialist** | PLS Project Blueprint Section 5, API specs | Pre-Listing API Spec, Complete Walkthrough | Master Compilation, Discovery Compilation | All API docs |
| **Frontend UI Specialist** | PLS Wireframe Specs, UI Design | UI Discovery Findings, CSS Improvements | Paisley Dashboard Design | All UI docs |
| **XML/Integration Specialist** | Contract PLS to GenieCloud v6.1, XML Mapping | Pre-Listing Command Status | N/A | Contract, XML mapping |
| **DevOps Specialist** | Deployment Plan, Scripts | N/A | N/A | All deployment docs |

---

## 6. AGENT ROLE RESPONSIBILITIES MATRIX

### 6.1 Database Specialist

**Must Read First:**
1. `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
2. `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
3. `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
4. `Paisley/PAISLEY_PRELISTING_DATA_CATALOG_v2.md` (for field reference)

**Key Responsibilities:**
- Execute normalized schema v3.0
- Create PLS number sequence (format: PLS{6-digit}{letter})
- Create master data lookup tables
- Implement stored procedures
- **Integration Points:** None (starts Phase 1)

### 6.2 Backend API Specialist

**Must Read First:**
1. `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 5)
2. `Paisley/PRELISTING_API_SPECIFICATION_v1.md` (Paisley integration)
3. `Paisley/PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md` (user flow)
4. `TitleGenie/TITLEGENIE_MASTER_COMPILATION_v1.md` (Title Genie context)
5. `01_Master_Documents/TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md` (field mapping)

**Key Responsibilities:**
- Implement all API endpoints (Section 5 of Blueprint)
- Integrate Title Genie pre-population (`POST /api/pls/pre-populate`)
- Integrate Paisley AI description generation (`POST /api/pls/generate-description`)
- Coordinate with XML Specialist on `/render` endpoint
- **Integration Points:** Title Genie (pre-population), Paisley (AI descriptions), XML Specialist (render endpoint)

### 6.3 Frontend UI Specialist

**Must Read First:**
1. `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md`
2. `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 10)
3. `Paisley/PAISLEY_UI_DISCOVERY_FINDINGS_v1.1.md` (UI patterns)
4. `Paisley/PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md` (user flow)

**Key Responsibilities:**
- Implement Angular components (PlsMyListingsComponent, PlsCreateComponent, etc.)
- Mobile-first responsive design
- Form validation and error handling
- Integration with Backend API endpoints
- **Integration Points:** Backend API (all endpoints), Mapbox (address lookup)

### 6.4 XML/Integration Specialist

**Must Read First:**
1. `11_Contracts/CONTRACT_PLS_to_GenieCloud_v6.1.md` ⭐⭐⭐ **CRITICAL - READ THIS FIRST**
2. `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`
3. `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 7)
4. `Paisley/Pre.Listing.Command/Docs/CONTRACT_PLS_to_GenieCloud_v6.1.md` (same contract)

**Key Responsibilities:**
- Implement GenieCloud XML generation (follow contract exactly)
- Integrate with Backend API `/render` endpoint
- Test marketing asset generation
- Handle GenieCloud API responses
- **Integration Points:** Backend API (render endpoint), GenieCloud API

### 6.5 DevOps/Deployment Specialist

**Must Read First:**
1. `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 14)
2. `02_Scripts/*.ps1` (PowerShell deployment scripts)
3. `05_Verification_Audits/PLS_TEST_READINESS_STATUS_v1.md`

**Key Responsibilities:**
- Create deployment scripts (PowerShell/Python)
- Set up test environments (Sandbox, Stage)
- Implement Fortune 500 enterprise procedures
- Create backup and rollback procedures (CRITICAL: Include DLL.config)
- **Integration Points:** All specialists (receives deployment requirements from all)

---

## 7. CRITICAL DOCUMENTS BY PRIORITY

### 7.1 Must Read Before Starting (All Agents)

1. ⭐⭐⭐ **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md** - Master blueprint
2. ⭐⭐⭐ **CONTRACT_PLS_to_GenieCloud_v6.1.md** - XML generation contract
3. ⭐⭐ **PAISLEY_PRELISTING_DATA_CATALOG_v2.md** - Available data fields
4. ⭐⭐ **TITLEGENIE_MASTER_COMPILATION_v1.md** - Title Genie context
5. ⭐⭐ **TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md** - Field mapping

### 7.2 Role-Specific Critical Documents

**Database Specialist:**
- `PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
- `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
- `PLS_STORED_PROCEDURES_COMPLETE_v1.sql`

**Backend API Specialist:**
- `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 5)
- `PRELISTING_API_SPECIFICATION_v1.md`
- `PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md`
- `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`

**Frontend UI Specialist:**
- `PLS_WIREFRAME_SPECIFICATIONS_v1.md`
- `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 10)
- `PAISLEY_UI_DISCOVERY_FINDINGS_v1.1.md`

**XML/Integration Specialist:**
- `CONTRACT_PLS_to_GenieCloud_v6.1.md` ⭐⭐⭐ **CRITICAL**
- `PLS_GENIECLOUD_XML_MAPPING_v1.md`
- `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 7)

**DevOps Specialist:**
- `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 14)
- All PowerShell/Python scripts in `02_Scripts/`

---

## 8. NEXT STEPS

### 8.1 Immediate Actions

1. ✅ **Document Catalog Complete** - This document
2. ⏳ **Agent Assignment** - Assign agents to 5 specialized roles
3. ⏳ **Agent Onboarding** - Each agent reads role-specific critical documents
4. ⏳ **Phase 1 Start** - Database Specialist begins Phase 1

### 8.2 Agent Onboarding Checklist

**For Each Agent:**
- [ ] Read role-specific document (`AgentCollaboration/AGENT_ROLE_*.md`)
- [ ] Read critical documents listed in Section 7.2
- [ ] Review ecosystem integration points (Section 4)
- [ ] Understand dependencies and handoffs
- [ ] Set up status tracking (`AgentStatus/AGENT_STATUS_*.md`)

### 8.3 Project Kickoff

**Phase 1 Kickoff (Database Specialist):**
- [ ] Review database schema documentation
- [ ] Execute SQL scripts on production SQL 2012
- [ ] Verify all objects created
- [ ] Test PLS number generation
- [ ] Update status file
- [ ] Announce Phase 1 completion

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/13/2026 11:00 PM | JR (Project Manager) | Initial document catalog creation. Cataloged all Paisley documents (including workspace memory logs), all Title Genie documents, and all PLS documents. Documented ecosystem integration points. Created team agent assignment matrix and responsibilities matrix. Identified critical documents by priority. |

---

**Status:** ✅ **DOCUMENT CATALOG COMPLETE** - Ready for agent assignments and project kickoff

**Next Action:** Assign agents to 5 specialized roles and begin Phase 1 (Database Foundation)
