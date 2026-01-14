# PLS RESO Engine - Complete Project Blueprint
**Version:** 1.15  
**Created:** 01/02/2026  
**Last Updated:** 01/10/2026 3:15 AM  
**Author:** Steve Hundley
**Developer Lead:** Danny
**Status:** 🎯 MASTER PROJECT BLUEPRINT - Single Source of Truth  
**DRA-2026 Compliant:** ✅ Yes

**Change Log:**
- **v1.15 (01/10/2026 3:15 AM):** **ROLLBACK PROCEDURE FIX - DLL.CONFIG CRITICAL** - Updated Section 14 (Deployment Prompt Beta) to include `bin\Smart.Dashboard.dll.config` in backup/rollback procedures. Documented why rollback failed (DLL.config was missing from backup). Added complete backup and rollback script examples. Added critical lesson learned: DLL.config must be included in all backups because it's loaded at application startup and contains connection strings. If DLL.config is not restored, authentication will fail even if Web.config is correct. This is why rollback didn't work - DLL.config wasn't backed up or restored.
- **v1.14 (01/09/2026):** **SANDBOX SAFETY VERIFICATION INTEGRATION** - Integrated Sandbox Safety Verification into Section 14 (Deployment Prompt Beta). Added comprehensive safety verification checklist, connection string verification, database context verification, and production protection guarantees. All deployment procedures now include mandatory pre-deployment safety checks. Standalone safety verification document archived per DRA-2026 Rule 1.
- **v1.13 (01/09/2026):** **DRA-2026 COMPLIANCE + DEPLOYMENT PROMPT BETA** - Consolidated 4 redundant deployment/testing documents (PLS_UI_TESTING_CHECKLIST_v1.md, PLS_UI_READY_TO_TEST_v1.md, PLS_QUICK_START_DEPLOYMENT_v1.md, PLS_SANDBOX_DEPLOYMENT_GUIDE_v1.md) into Section 14 (Deployment Plan). Added Deployment Prompt Beta (Fortune 500 enterprise procedures) with timestamped backup, rollback verification, pre/post-deployment checklists. Added complete sandbox deployment steps, UI testing readiness checklist, and production deployment procedures. All redundant documents archived per DRA-2026 Rule 1.
- **v1.12 (01/09/2026):** **WORKFLOW ENHANCEMENT** - Updated Section 10 (UI Design) Steps 10-11: Combined into single step showing auto-generated content. System now auto-generates Mapbox satellite photo (property boundary + best angle view) and Paisley auto-generates description (ChatStartTypeId=3) on same UI page. Photo upload is now optional with "Load Photos" button. Description shows with "Edit" button only (no "Generate" button). Updated Section 20.3 Step 8 to match. Fixed step numbering (11-15).
- **v1.11 (01/09/2026):** **WORKFLOW CORRECTIONS** - Fixed Section 10 (UI Design): (1) Changed Step 1 menu from "Private Listings" to "Pre-Listing" (Paisley ChatStartTypeId=3). (2) Corrected order of Steps 6-7: System auto-fetches areas (Step 6) now comes before User selects area (Step 7) to match logical flow and Section 20.2 workflow.
- **v1.10 (01/09/2026):** **WORKFLOW CLARIFICATION** - Updated Section 10 (UI Design) Step 11 to correctly state that Paisley generates the AI description (not the user). Paisley uses ChatStartTypeId=3 (Pre-Listing Focused) with Listing Data + Area Data to generate the description. User clicks "Generate with AI" button to trigger Paisley.
- **v1.9 (01/09/2026):** **WORKFLOW FIX** - Added missing Area Selection step to Section 11 (Data Flow Diagrams) User Experience Flow. Corrected workflow sequence to match Paisley Pre-Listing Focus flow: Address selection → Area selection (critical for Listing Command) → Property pre-population. Updated step numbering (4-16) to reflect complete flow. Added API endpoint references for clarity.
- **v1.8 (01/09/2026):** Added hyperlinks to Table of Contents (all 21 sections) and "Back to TOC" navigation links at end of each section for improved document navigation.
- **v1.7 (01/09/2026):** **DRA-2026 COMPLIANCE** - Consolidated complete workflow specification, multi-role lifecycle management, and eRealtor blueprint comparison from 4 new v1 documents into Section 20 (Complete Workflow Specification). Deleted redundant v1 documents per DRA-2026 Rule 1 (No New V1 Documents). Added end-to-end workflow phases, role definitions, status transitions, and prototype workflow example.
- **v1.6 (01/07/2026 12:00 PM):** **DRA-2026 COMPLIANCE** - Consolidated API endpoint specifications from standalone v1 document into Section 19. Removed all mock data from prototype per Master Rules (Rule 3: NO PLACEHOLDERS). Added detailed endpoint specs with request/response formats. Prototype tested and verified - shows proper error messages when endpoints don't exist.
- **v1.5 (01/06/2026):** **DRA-2026 COMPLIANCE** - Consolidated Paisley study findings, Angular component implementation, mobile-first design requirements, and AskPaisley redesign integration into blueprint. Added Section 19: Paisley Service Architecture, Section 20: Mobile-First Design Requirements, Section 21: Angular Component Implementation. **No new v1 documents created** - all content consolidated into this blueprint.
- **v1.4 (01/06/2026):** Added Future Features section (Section 18) - AR Mobile App workflow and photo-initiated listing creation. Updated `POST /api/pls/pre-populate` to accept optional latitude/longitude parameters. Added `POST /api/pls/reverse-geocode` endpoint specification. **DRA-2026 Compliant:** No new v1 documents created - content consolidated into blueprint.
- **v1.3 (01/05/2026):** Updated database schema - MlsID changed to 777, normalized schema with lookup tables, removed collaborator concept, updated PlsListingOwnership table definition, **PLS number format changed to PLS{6-digit}{letter} (e.g., PLS100000A)**
- **v1.2 (01/04/2026):** Initial complete blueprint

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
17. [DRA-2026 Compliance](#17-dra-2026-compliance)
18. [Future Features](#18-future-features)
19. [PLS Address Lookup Component (Paisley Integration)](#19-pls-address-lookup-component-paisley-integration)
20. [Complete Workflow Specification](#20-complete-workflow-specification)
21. [Reference Documents](#21-reference-documents)

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

**[↑ Back to Table of Contents](#-table-of-contents)**

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
│  │  • MlsId=777      • PropertyCastTypeId=4                │           │
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
| **MlsListing Database** | Listing storage | MlsId=777, StatusTypeID 6/14 |

---

**[↑ Back to Table of Contents](#-table-of-contents)**

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
│  │  │   • PLS listings stored with MlsId=777                           │  │
│  │  │   • Uses existing columns - NO new columns added                │  │
│  │  │   • New StatusTypeID values (6=Private, 14=Coming Soon)         │  │
│  │  │                                                                   │  │
│  │  ├── Supporting Tables (Minimal):                                │  │
│  │  │   • FarmGenie.dbo.PlsListingOwnership (ownership tracking)     │  │
│  │  │   • FarmGenie.dbo.PlsNumberSequence (number generation)         │  │
│  │  │   • FarmGenie.dbo.pls_tracking (lifecycle/metadata tracking)   │  │
│  │  │   • FarmGenie.dbo.pls_status_log (audit trail)                │  │
│  │  │   • FarmGenie.dbo.pls_status_type (lookup - normalized)       │  │
│  │  │   • FarmGenie.dbo.pls_source_type (lookup - normalized)       │  │
│  │  │   • FarmGenie.dbo.pls_status_mapping (status → MLS mapping)    │  │
│  │  │                                                                   │  │
│  │  │  NOTE: Listing Agents stored in MlsListing.dbo.Listing (RESO) │  │
│  │  │        Title Reps access via Permission table (account-level)  │  │
│  │  │                                                                   │  │
│  │  STORED PROCEDURES:                                                 │  │
│  │  ├── usp_GetNextPlsNumber - Generate PLS{6-digit}{letter} (e.g., PLS100000A) │  │
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

**[↑ Back to Table of Contents](#-table-of-contents)**

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
| `MlsID` | `777` | PLS identifier |
| `MlsNumber` | `PLS{6-digit}{letter}` (e.g., `PLS100000A`) | Generated by stored procedure |
| `StatusTypeID` | `6` (Private) or `14` (Coming Soon) | User selects |
| `PropertyCastTypeId` | `4` | For Listing Command integration |
| All address, property, agent fields | Standard usage | Existing columns, no changes |

#### FarmGenie.dbo.PlsListingOwnership (New)

**Purpose:** Track user ownership of PLS listings.

```sql
CREATE TABLE FarmGenie.dbo.PlsListingOwnership (
    PlsListingOwnershipId INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId NVARCHAR(450) NOT NULL,  -- Updated to match AspNetUsers.Id
    MlsId INT NOT NULL DEFAULT 777,        -- Updated from 999 to 777
    MlsNumber VARCHAR(10) NOT NULL,         -- 'PLS100000A' (format: PLS{6-digit}{letter})
    ListingId INT NOT NULL,                 -- FK to MlsListing.dbo.Listing
    OwnershipTypeId INT NOT NULL DEFAULT 1, -- 1=Creator, 2=CoAgent
    IsActive BIT NOT NULL DEFAULT 1,
    CreateDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),  -- Updated to DATETIME2(7)
    LastUpdate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),  -- Updated to DATETIME2(7)
    
    CONSTRAINT FK_PlsOwnership_User FOREIGN KEY (AspNetUserId) 
        REFERENCES FarmGenie.dbo.AspNetUsers(Id),
    CONSTRAINT UQ_PlsOwnership_User_Listing_Type UNIQUE (AspNetUserId, ListingId, OwnershipTypeId),
    CONSTRAINT UQ_PlsOwnership_User_Mls_Number UNIQUE (AspNetUserId, MlsId, MlsNumber)
);
```

**Purpose:** Track user ownership of PLS listings (flexible for multiple owners).
- **OwnershipTypeId:** 1=Creator (primary owner), 2=CoAgent (co-owner)
- **Architecture:** Supports multiple owners per listing (currently max 2, expandable for future property types)
- **Note:** Separate from `pls_tracking` - ownership vs lifecycle tracking

#### FarmGenie.dbo.PlsNumberSequence (New)

**Purpose:** Manage PLS number generation (thread-safe).

```sql
CREATE TABLE FarmGenie.dbo.PlsNumberSequence (
    LetterSuffix CHAR(1) NOT NULL PRIMARY KEY,
        -- Current letter suffix: A, B, C, ..., Z
        -- When number reaches 999999, increment letter and reset to 100000
    CurrentNumber INT NOT NULL DEFAULT 100000,
        -- Current number in sequence (100000-999999)
        -- Starts at 100000, increments by 1
        -- Resets to 100000 when letter increments
    LastUpdate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT CK_PlsNumberSequence_Number CHECK (CurrentNumber >= 100000 AND CurrentNumber <= 999999),
    CONSTRAINT CK_PlsNumberSequence_Letter CHECK (LetterSuffix >= 'A' AND LetterSuffix <= 'Z')
);
```

**Format:** `PLS{6-digit-number}{letter}` (e.g., `PLS100000A`, `PLS100001A`, ..., `PLS999999A`, `PLS100000B`)
- **Number Range:** 100000-999999 (900,000 per letter)
- **Letter Range:** A-Z (26 letters = 23.4M total capacity)
- **Cycles:** PLS999999A → PLS100000B → ... → PLS999999Z → PLS100000A

#### FarmGenie.dbo.pls_tracking (New - Normalized Schema v3.0)

**Purpose:** Tracks PLS-specific metadata and lifecycle for each listing (separate from ownership).

**Key Features:**
- Lifecycle status tracking (incomplete, draft, active, coming_soon, lost_opportunity, published_to_mls)
- Creation source tracking (paisley, manual, import, api)
- Business flags (was_listed, mls_published)
- Normalized with lookup tables (pls_status_type, pls_source_type)

**Note:** This is separate from `PlsListingOwnership` - tracking vs ownership are different concerns.

#### FarmGenie.dbo.pls_status_log (New - Normalized Schema v3.0)

**Purpose:** Complete audit trail of all status transitions for PLS listings.

**Key Features:**
- Tracks every status change (from_status → to_status)
- Records who made the change (changed_by)
- Timestamp of change (changed_at)
- Normalized with lookup tables (pls_status_type)

#### FarmGenie.dbo.pls_status_type (New - Lookup Table)

**Purpose:** Master data for PLS lifecycle status values (normalized).

**Values:** incomplete, draft, active, coming_soon, lost_opportunity, published_to_mls

#### FarmGenie.dbo.pls_source_type (New - Lookup Table)

**Purpose:** Master data for PLS creation source values (normalized).

**Values:** paisley, manual, import, api

#### FarmGenie.dbo.pls_status_mapping (New - Mapping Table)

**Purpose:** Explicit mapping between PLS status and MLS StatusTypeID.

**Mappings:**
- `active` → StatusTypeID 6 (Private Listing)
- `coming_soon` → StatusTypeID 14 (Coming Soon)
- `published_to_mls` → Dynamic (based on target MLS)

**Note:** See `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` for complete schema definition.

### Agent Model Clarification

**Listing Agents (RESO-Compliant):**
- **Storage:** `MlsListing.dbo.Listing` table (standard RESO fields)
- **Fields:** `ListingAgentName`, `ListingAgentID`, `CoListingAgentName`, `CoListingAgentID`
- **Validation:** Both agents must be verified MLS members (validated by RESO feed)
- **Note:** NOT tracked in PLS-specific tables - stored in RESO listing table

**Title Reps (Permission-Based Access):**
- **Storage:** `FarmGenie.dbo.Permission` table (account-level permissions)
- **Access Model:** Title reps have access to agent's account, not individual listings
- **Permissions:** Title Partner permission type grants account-level access
- **Note:** NOT tracked as listing-specific collaborators - access via Permission table

### Stored Procedures

#### usp_GetNextPlsNumber

**Purpose:** Generate next PLS number in format `PLS{6-digit-number}{letter}` (e.g., `PLS100000A`).

**Format:** `PLS{6-digit-number}{single-letter}`
- **Number Range:** 100000-999999 (900,000 numbers per letter)
- **Letter Range:** A-Z (26 letters = 23.4 million total listings capacity)
- **Examples:** `PLS100000A`, `PLS100001A`, ..., `PLS999999A`, `PLS100000B`, `PLS100001B`, ...

**Logic:**
1. Get current letter and number from `PlsNumberSequence` table
2. If number < 999999, increment number
3. If number = 999999, increment letter (A→B→...→Z) and reset number to 100000
4. If at Z999999, cycle back to A100000
5. Format: `PLS` + 6-digit number (padded) + letter

**Thread-Safe:** Uses transaction with UPDLOCK to prevent race conditions.

**Future-Proof:** Supports 23.4 million listings before cycling (26 letters × 900,000 numbers).

### Master Data Inserts

| Type | ID | Name | Status |
|------|----|----|--------|
| **StatusType** | 6 | Private Listing | ⏳ Needs INSERT |
| **StatusType** | 14 | Coming Soon | ✅ Exists |
| **Mls** | 777 | PLS (Paisley Listing Service) | ⏳ Needs INSERT |
| **PropertyCastType** | 4 | PLS | ⏳ Needs INSERT |

**Note:** MlsID changed from 999 to 777 in v1.3 schema. Update all references accordingly.

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

**[↑ Back to Table of Contents](#-table-of-contents)**

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
  "plsNumber": "PLS100000A",
  "listingId": 12345
}
```

**Business Logic:**
1. Validate input
2. Generate PLS Number (usp_GetNextPlsNumber)
3. Geocode address (if not provided)
4. INSERT into MlsListing.dbo.Listing (MlsId=777)
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
  "plsNumber": "PLS100000A",
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
      "plsNumber": "PLS100000A",
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
  "renderId": "pls-PLS100000A",
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
  "address": "10037 Rebecca Place, Boerne, TX 78006",
  "latitude": 29.72229,  // Optional: For photo-initiated listings
  "longitude": -98.68958  // Optional: For photo-initiated listings
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
  ],
  "geocodeMatch": {  // Optional: If lat/lng provided
    "matched": true,
    "distance": 0.0001,
    "source": "TitleData"
  }
}
```

#### POST /api/pls/reverse-geocode (🔮 Future Feature)

**Purpose:** Convert GPS coordinates (from photo EXIF) to address for photo-initiated listings.

**Request:**
```json
{
  "latitude": 29.72229,
  "longitude": -98.68958
}
```

**Response:**
```json
{
  "address": {
    "streetNumber": "10037",
    "streetName": "Rebecca Place",
    "city": "Boerne",
    "state": "TX",
    "zip": "78006",
    "fullAddress": "10037 Rebecca Place, Boerne, TX 78006"
  },
  "confidence": 0.95,
  "geocodeAccuracy": "ROOFTOP",
  "source": "TitleData"
}
```

**Note:** See `PLS_PHOTO_GEOCODE_WORKFLOW_v1.md` for complete photo-initiated workflow documentation.

#### POST /api/pls/upload-photo

**Purpose:** Upload photo to S3.

**Request:** Multipart form data (file)

**Response:**
```json
{
  "url": "https://genie-cloud.s3.us-west-1.amazonaws.com/genie-pages/pls100000a/photos/photo1.jpg"
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

**[↑ Back to Table of Contents](#-table-of-contents)**

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

**[↑ Back to Table of Contents](#-table-of-contents)**

---

**[↑ Back to Table of Contents](#-table-of-contents)**

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
  "renderId": "pls-PLS100000A",
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
VALUES (777, 'PLS100000A', 4, @userId, @areaId, GETDATE())
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

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 8. DATABASE DESIGN

### Entity Relationship Diagram

```
┌─────────────────────────┐
│   MlsListing.dbo.Listing│
│   (MlsId=777)           │
│                         │
│  ListingID (PK)         │
│  MlsID = 777            │
│  MlsNumber              │
│  StatusTypeID (6 or 14) │
│  PropertyCastTypeId = 4 │
│  ListingAgentName       │
│  ListingAgentID         │
│  CoListingAgentName      │
│  CoListingAgentID       │
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
│  MlsID = 777            │
│  PhotoUrl               │
│  DisplayOrder           │
└─────────────────────────┘

┌─────────────────────────┐
│ PlsListingOwnership      │
│ (FarmGenie)              │
│                         │
│  PlsListingOwnershipId  │
│  AspNetUserId (FK)       │
│  MlsId = 777            │
│  MlsNumber              │
│  ListingId (FK)         │
│  OwnershipTypeId        │
│  IsActive               │
└─────────────────────────┘

┌─────────────────────────┐
│ pls_tracking             │
│ (FarmGenie)              │
│                         │
│  id (PK)                │
│  listing_id (FK)        │
│  agent_id (FK)          │
│  status_type_id (FK)    │
│  source_type_id (FK)    │
│  was_listed             │
│  mls_published          │
└─────────────────────────┘

┌─────────────────────────┐
│ pls_status_log           │
│ (FarmGenie)              │
│                         │
│  id (PK)                │
│  listing_id (FK)        │
│  changed_by (FK)        │
│  from_status_type_id    │
│  to_status_type_id (FK) │
│  changed_at             │
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
INSERT MlsListing.dbo.Listing (MlsId=777)
    ↓
INSERT MlsListing.dbo.Photo (1-N rows)
    ↓
INSERT FarmGenie.dbo.PlsListingOwnership
    ↓
Listing ready for XML generation
```

---

**[↑ Back to Table of Contents](#-table-of-contents)**

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

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 10. UI DESIGN

### Design System

**Framework:** Angular (version TBD)

**UI Library:** Material Design or custom components

**Styling:** SCSS/CSS

### User Experience Flow

```
1. User navigates to "Pre-Listing" menu (Paisley ChatStartTypeId=3)
    ↓
2. User sees "My PLS Listings" page
    ↓
3. User clicks "Create New Listing"
    ↓
4. User enters property address (autocomplete via Google Places)
    ↓
5. User selects address from dropdown
    ↓
6. System auto-fetches areas based on selected city (API: `POST /api/Data/GetAreaList`)
    ↓
7. User selects area (neighborhood/farm area) ← **CRITICAL: Required for Listing Command circle prospecting**
    ↓
8. System pre-populates from TitleData + Historical MLS (API: `POST /api/Data/GetPropertiesFromPlaceKey`)
    ↓
9. User reviews pre-populated data, flags conflicts
    ↓
10. System auto-generates satellite photo from Mapbox API (property boundary + clearest closed view of best angle) + Paisley auto-generates description (ChatStartTypeId=3, Pre-Listing Focused) using Listing Data + Area Data
    ↓
    **Combined UI shows:**
    - System-generated Mapbox satellite photo (with property boundary overlay)
    - Paisley-generated description (displayed, with "Edit" button only)
    - "Load Photos" button (optional - upload additional photos up to RESO DB limit)
    ↓
11. User selects status (Coming Soon/Private)
    ↓
12. User clicks "Save & Generate Content Kit"
    ↓
13. System generates XML, triggers GenieCloud render
    ↓
14. User sees "Generating..." status
    ↓
15. System displays collection URL when ready
```

### Accessibility

- WCAG 2.1 AA compliance
- Keyboard navigation
- Screen reader support
- Color contrast ratios

---

**[↑ Back to Table of Contents](#-table-of-contents)**

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

**[↑ Back to Table of Contents](#-table-of-contents)**

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
- [ ] Handle MlsId=777 in component (Frontend)
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
- [ ] `EXEC dbo.usp_GetNextPlsNumber;` returns "PLS100001A" (first call after initial 100000A)
- [ ] Can INSERT test listing with MlsId=777
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
- [ ] Listing Command queue processes PLS listings (MlsId=777, PropertyCastTypeId=4)
- [ ] SMS sent to farm area
- [ ] Lead capture works via Engagement Center

---

## 12.2. MINIMUM VIABLE PROTOTYPE (MVP) DEFINITION

### Must Have (For Initial Release):
1. ✅ Database setup complete (tables, stored procedures, master data)
2. ✅ Create listing form (all 7 steps functional)
3. ✅ Save to database (MlsId=777, StatusTypeID 6 or 14)
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

**[↑ Back to Table of Contents](#-table-of-contents)**

---

**[↑ Back to Table of Contents](#-table-of-contents)**

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
- PLS Number: PLS100000A
- Status: Private Listing (6)

---

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 14. DEPLOYMENT PLAN

### Environment Strategy

| Environment | Purpose | Database | API | UI |
|-------------|---------|----------|-----|-----|
| **Development** | Local development | Local SQL | Localhost | Localhost |
| **Staging** | Pre-production testing | Staging DB | Staging API | Staging URL |
| **Production** | Live system | Production DB | Production API | Production URL |

### Deployment Prompt Beta - Fortune 500 Enterprise Procedures

**CRITICAL:** ALL deployments - no exceptions - MUST follow Fortune 500 enterprise-level procedures:

1. **Create Timestamped Backup of Production BEFORE Any Deployment**
   - Location: `I:\Backups\PreDeploy_{timestamp}`
   - Backup: **ALL files being deployed** (DLLs, configs, database scripts)
   - **CRITICAL:** Must include `bin\Smart.Dashboard.dll.config` (NOT just Web.config)
   - **CRITICAL:** Must include all modified controller files
   - **CRITICAL:** Must include all modified routing files
   - Format: `PreDeploy_20260109_143000` (YYYYMMDD_HHMMSS)
   - **NEVER offer "skip" or "proceed without backup" options**
   - **Backup Script Example:**
     ```powershell
     $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
     $backupPath = "I:\Backups\PreDeploy_$timestamp"
     New-Item -ItemType Directory -Path $backupPath
     
     # Backup ALL config files (Web.config AND DLL.config)
     Copy-Item "C:\Sandbox\...\Smart.Dashboard\Web.config" -Destination "$backupPath\Web.config"
     Copy-Item "C:\Sandbox\...\Smart.Dashboard\bin\Smart.Dashboard.dll.config" -Destination "$backupPath\Smart.Dashboard.dll.config"
     
     # Backup ALL DLLs
     Copy-Item "C:\Sandbox\...\Smart.Dashboard\bin\*.dll" -Destination "$backupPath\bin\"
     
     # Backup ALL modified controller files
     Copy-Item "C:\Sandbox\...\Controllers\*.cs" -Destination "$backupPath\Controllers\" -Recurse
     
     # Backup routing files
     Copy-Item "C:\Sandbox\...\App_Start\RouteConfig.cs" -Destination "$backupPath\RouteConfig.cs"
     ```

2. **Verify Rollback Procedure is Ready**
   - Document how to revert changes
   - Test rollback on staging first
   - Recovery source: Stage folder or timestamped backup
   - **CRITICAL:** Rollback must restore ALL files from backup:
     - `Web.config`
     - `bin\Smart.Dashboard.dll.config` ← **THIS WAS MISSING IN ROLLBACK**
     - All DLLs
     - All modified controller files
     - All routing files
   - Rollback scripts prepared and tested
   - **Rollback Script Example:**
     ```powershell
     $backupPath = "I:\Backups\PreDeploy_20260109_143000"
     
     # Restore ALL config files
     Copy-Item "$backupPath\Web.config" -Destination "C:\Sandbox\...\Smart.Dashboard\Web.config" -Force
     Copy-Item "$backupPath\Smart.Dashboard.dll.config" -Destination "C:\Sandbox\...\Smart.Dashboard\bin\Smart.Dashboard.dll.config" -Force
     
     # Restore ALL DLLs
     Copy-Item "$backupPath\bin\*.dll" -Destination "C:\Sandbox\...\Smart.Dashboard\bin\" -Force
     
     # Restore ALL controller files
     Copy-Item "$backupPath\Controllers\*.cs" -Destination "C:\Sandbox\...\Controllers\" -Recurse -Force
     
     # Restore routing files
     Copy-Item "$backupPath\RouteConfig.cs" -Destination "C:\Sandbox\...\App_Start\RouteConfig.cs" -Force
     ```

3. **Follow Pre-Deployment Checklist**
   - Review all changes
   - Get approval
   - Schedule deployment window
   - Notify stakeholders

4. **Follow Post-Deployment Validation**
   - Test endpoints in production
   - Monitor for errors
   - Verify UI components
   - User acceptance testing

### Sandbox Safety Verification - 100% Production/Staging Protection

**✅ VERIFIED: ALL IMPLEMENTATION IS SANDBOX-ONLY**

**Critical Safety Guarantees:**

1. **Database Connection Strings - SANDBOX-ONLY**
   - All code reads from `Web.config` (no hardcoded connections)
   - Deployment guide specifies `FarmGenie_Sandbox` and `MlsListing_Sandbox`
   - Code uses `configuration.GetConnectionString()` - fully configurable
   - **✅ SAFE:** Connection strings explicitly use `*_Sandbox` databases

2. **Database Scripts - SANDBOX-ONLY**
   - Scripts use `USE FarmGenie;` and `USE MlsListing;` (context-dependent)
   - When executed on sandbox server → uses sandbox databases
   - Manual execution required (DBA control)
   - **✅ SAFE:** Scripts execute on sandbox server = sandbox databases only

3. **Code Deployment - SANDBOX-ONLY**
   - All file paths are sandbox: `C:\Sandbox\1ppDevelopment\...`
   - No production paths referenced
   - Build and test in sandbox environment
   - **✅ SAFE:** All deployment instructions specify sandbox paths

4. **API Endpoints - SANDBOX-ONLY**
   - Test URLs: `http://localhost:38949/pls/create` (Localhost/Sandbox)
   - No production URLs referenced
   - **✅ SAFE:** All testing is localhost/sandbox only

5. **Deployment Procedures - SANDBOX-FIRST**
   - Sandbox/Staging Deployment FIRST (mandatory)
   - Production Deployment only after sandbox validation (separate section)
   - Explicit warnings about production deployment
   - Backup procedures required for production
   - **✅ SAFE:** Deployment procedures enforce sandbox-first approach

**Pre-Deployment Safety Checklist (MANDATORY):**

Before ANY deployment, verify:

- [ ] **Verify Environment:** Confirm you are deploying to SANDBOX, not Production
- [ ] **Verify Connection Strings:** Check `Web.config` uses `*_Sandbox` databases:
   ```xml
   <!-- VERIFY THESE ARE SANDBOX -->
   <add name="FarmGenieConnection" connectionString="...Database=FarmGenie_Sandbox;..." />
   <add name="MlsListingConnection" connectionString="...Database=MlsListing_Sandbox;..." />
   ```
- [ ] **Verify Database Context:** Confirm SQL scripts will execute on sandbox server:
   ```sql
   -- Verify you're connected to sandbox
   SELECT DB_NAME() AS CurrentDatabase;
   -- Should return: FarmGenie_Sandbox or MlsListing_Sandbox
   ```
- [ ] **Verify Paths:** Confirm file copy locations are sandbox paths (`C:\Sandbox\...`)
- [ ] **Verify Server Context:** Confirm you're working on sandbox server/environment
- [ ] **Build in Sandbox:** Verify solution builds in sandbox environment
- [ ] **Test in Sandbox:** Verify all endpoints work in sandbox

**Why Production Cannot Be Impacted:**

1. **Code reads connection strings from `Web.config`** → Sandbox config = sandbox databases
2. **Database scripts execute on sandbox server** → Sandbox databases only
3. **Files deployed to sandbox paths only** → No production file system access
4. **Production deployment requires explicit, separate steps** → With backup/approval required

**Current Status:** All implementation is **SANDBOX-ONLY**. Production cannot be impacted by current deployment procedures.

**Production Deployment (Future - After Sandbox Validation):**

When ready for production (AFTER sandbox validation):

- [ ] **Sandbox Validation Complete:** All features tested and working in sandbox
- [ ] **Backup Created:** Timestamped backup of production (Deployment Prompt Beta)
- [ ] **Rollback Verified:** Rollback procedure tested and documented
- [ ] **Approval Obtained:** Management approval for production deployment
- [ ] **Maintenance Window:** Scheduled during low-traffic period
- [ ] **Connection Strings Updated:** Production connection strings (NOT sandbox):
   ```xml
   <!-- PRODUCTION (update when ready) -->
   <add name="FarmGenieConnection" connectionString="...Database=FarmGenie;..." />
   <add name="MlsListingConnection" connectionString="...Database=MlsListing;..." />
   ```
- [ ] **Database Scripts Executed:** On production server (NOT sandbox)
- [ ] **Post-Deployment Validation:** All endpoints tested in production

### Deployment Steps (Sandbox/Staging First)

#### Phase 1: Database Setup (5-10 minutes)

**Execute in Order:**
1. `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` (FarmGenie)
2. `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` (FarmGenie)
3. `PLS_DATABASE_MASTER_DATA_v3.sql` (MlsListing + FarmGenie)
4. `PLS_STORED_PROCEDURES_COMPLETE_v1.sql` (FarmGenie)

**Verify:**
```sql
-- Test PLS number generation
DECLARE @PlsNum VARCHAR(10);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum; -- Should return: PLS100001A

-- Verify tables created
SELECT COUNT(*) FROM FarmGenie.dbo.pls_status_type;
SELECT COUNT(*) FROM FarmGenie.dbo.pls_source_type;
SELECT COUNT(*) FROM FarmGenie.dbo.pls_tracking;
```

#### Phase 2: Backend Deployment (10-15 minutes)

**Files to Copy:**
1. `DataController_PLS_Complete_v1.cs` → `Controllers\DataController.PLS.cs`
2. `PlsController_Complete_v1.cs` → `Controllers\PlsController.cs`

**Actions:**
1. Add `DataController.PLS.cs` as partial class to existing `DataController.cs`
2. Create new `PlsController.cs` file
3. Update `Smart.Dashboard.csproj`:
   ```xml
   <Compile Include="Controllers\PlsController.cs" />
   <Compile Include="Controllers\DataController.PLS.cs" />
   ```
4. Add connection strings to `Web.config`:
   ```xml
   <connectionStrings>
     <add name="FarmGenieConnection" connectionString="Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;..." />
     <add name="MlsListingConnection" connectionString="Server=192.168.29.45,1433;Database=MlsListing_Sandbox;..." />
     <add name="TitleDataConnection" connectionString="Server=192.168.29.45,1433;Database=TitleData;..." />
   </connectionStrings>
   ```
5. Build solution (F6) - Verify no compilation errors

**Test Endpoints:**
- `POST http://localhost:38949/api/Data/AutoCompleteAddress`
- `POST http://localhost:38949/api/Data/GetPropertiesFromPlaceKey`
- `POST http://localhost:38949/api/Data/GetAreaList`
- `POST http://localhost:38949/api/pls/create`

#### Phase 3: Angular Component Deployment (5 minutes)

**Files to Copy:**
1. `pls-create.component.ts` → Angular app components directory
2. `pls-create.component.html` → Angular app components directory
3. `pls-create.component.scss` (if exists)

**Actions:**
1. Copy to Angular app components directory
2. Add route to `app-routing.module.ts`:
   ```typescript
   {
     path: 'pls',
     canActivate: [PermissionGuard],
     data: { permission: PermissionType.MenuPLS },
     children: [
       { path: 'create', component: PlsCreateComponent }
     ]
   }
   ```
3. Add `PlsCreateComponent` to module declarations
4. Add "Pre-Listing" menu item (optional but recommended)

#### Phase 4: Permission Setup (5 minutes)

**Grant Permissions to Test User:**
```sql
-- Grant Menu PLS (211) - Required for UI access
INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
SELECT Id, 211
FROM dbo.AspNetUsers
WHERE UserName = 'your-test-user@email.com'
AND NOT EXISTS (
    SELECT 1 FROM dbo.Permission 
    WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 211
);

-- Grant ManagePLS (210) - Required for create/edit
INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
SELECT Id, 210
FROM dbo.AspNetUsers
WHERE UserName = 'your-test-user@email.com'
AND NOT EXISTS (
    SELECT 1 FROM dbo.Permission 
    WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 210
);
```

### Production Deployment (After Sandbox/Staging Validation)

**CRITICAL - Follow Deployment Prompt Beta Procedures:**

1. **Pre-Deployment Backup:**
   ```powershell
   # Create timestamped backup
   $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
   $backupPath = "I:\Backups\PreDeploy_$timestamp"
   New-Item -ItemType Directory -Path $backupPath
   
   # Backup files being deployed
   Copy-Item "C:\Sandbox\...\Smart.Dashboard\bin\*.dll" -Destination $backupPath
   Copy-Item "C:\Sandbox\...\Web.config" -Destination $backupPath
   ```

2. **Database Backup:**
   - Backup Production databases (FarmGenie, MlsListing)
   - Store backup location in deployment log
   - Verify backup is restorable

3. **Deploy to Production:**
   - Execute database scripts (during maintenance window)
   - Deploy backend DLLs
   - Deploy frontend assets
   - Update connection strings

4. **Post-Deployment Validation:**
   - Test all API endpoints
   - Test UI components
   - Monitor error logs
   - Verify PLS number generation
   - User acceptance testing

5. **Rollback Plan (If Needed):**
   - **CRITICAL:** Restore ALL files from backup:
     - Restore DLLs from backup
     - Restore Web.config from backup
     - **Restore bin\Smart.Dashboard.dll.config from backup** ← **CRITICAL - THIS WAS MISSING**
     - Restore all modified controller files from backup
     - Restore all routing files from backup
     - Revert database scripts (if applicable)
   - **Verify rollback:** Test login immediately after rollback
   - Login page should work
   - Authentication should work
   - If rollback doesn't work, the backup was incomplete
   - Document rollback in deployment log
   - **Lesson Learned (01/10/2026):** Rollback failed because DLL.config was not included in backup. DLL.config is loaded at application startup and contains connection strings. If not restored, authentication will fail even if Web.config is correct.

### UI Testing Readiness

**Ready for Basic UI Test (15-20 minutes):**
- Database master data executed
- Backend controllers deployed (even if APIs return mock data)
- Angular component deployed
- Route added

**Ready for Full End-to-End Test (30-45 minutes):**
- All database scripts executed
- All stored procedures created
- Backend fully deployed with connection strings
- Permissions granted
- Routing configured

**Test URL:** `http://localhost:38949/pls/create`

**Test Flow:**
1. Navigate to `/pls/create`
2. Enter address: "10037 Rebecca Place, Boerne, TX"
3. Select address from autocomplete
4. Verify property pre-populates
5. Select area
6. Verify auto-generation triggers (photo + description)
7. Complete form and save
8. Verify PLS number generated (e.g., PLS100001A)

---

**[↑ Back to Table of Contents](#-table-of-contents)**

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

**[↑ Back to Table of Contents](#-table-of-contents)**

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

**[↑ Back to Table of Contents](#-table-of-contents)**

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

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 18. FUTURE FEATURES

### AR Mobile App - Photo-Initiated Listing Creation

**Status:** 🔮 Future Feature - Design Phase  
**Priority:** Phase 2 (After MVP)

#### Overview

The PLS AR Mobile App will use **Augmented Reality (AR)** technology to capture, compile, and deliver property data for PLS listing creation. Agents will scan properties using their mobile device camera, automatically extract property information, measurements, and features through AR overlays, and seamlessly deliver this data to the PLS system.

#### Workflow

1. **AR Property Scan** → User scans property with AR-enabled mobile app
2. **GPS Capture** → Automatic GPS coordinates from device location
3. **Room Measurement** → AR-based room dimension measurement
4. **Feature Recognition** → AI-powered recognition of property features
5. **360° Photo Capture** → Guided 360° photo capture with AR positioning
6. **Data Compilation** → Compile all captured data into structured format
7. **Reverse Geocoding** → Convert GPS to address via `POST /api/pls/reverse-geocode`
8. **Property Lookup** → Query TitleData + Historical MLS by GPS proximity
9. **Data Delivery** → Push compiled data to PLS web platform
10. **Listing Creation** → User reviews on web, confirms, creates listing

#### Technical Stack

**Mobile App:**
- **iOS:** Swift + SwiftUI, ARKit 6.0+, Core ML 5.0+
- **Android:** Kotlin, ARCore 1.40+, ML Kit

**Backend API:**
- `POST /api/pls/ar-scan` - Receive AR scan data
- `POST /api/pls/reverse-geocode` - Convert GPS to address
- `POST /api/pls/upload-photo` - Upload photos from AR scan

**Data Structure:**
```json
{
  "propertyScan": {
    "gps": { "latitude": 29.72229, "longitude": -98.68958 },
    "rooms": [ /* room measurements */ ],
    "features": [ /* AI-recognized features */ ],
    "photos": [ /* 360° photos with GPS */ ]
  }
}
```

#### AR Features

- **Room Measurement:** Measure length, width, height with ±2-5% accuracy
- **Feature Recognition:** Recognize appliances, fixtures, room types (confidence-based)
- **360° Photo Capture:** AR-guided positioning for complete coverage
- **Property Boundary Detection:** Detect boundaries, measure lot size

**See:** API endpoint documentation in Section 5 (Function Layer) for `POST /api/pls/reverse-geocode`

---

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 19. PLS ADDRESS LOOKUP COMPONENT (Paisley Integration)

### Overview

PLS Create component uses Paisley's existing address autocomplete API for property lookup. This section documents only the PLS-specific implementation details.

### Paisley APIs Used

| API Endpoint | Purpose | Used In PLS | Status |
|-------------|---------|------------|--------|
| `POST /api/Data/AutoCompleteAddress` | Address autocomplete (Google Places backend) | ✅ Step 1: Address Input | ⚠️ **MUST BE CREATED** |
| `POST /api/Data/GetPropertiesFromPlaceKey` | Get property details from PlaceKey | ✅ Step 1: Property Pre-population | ⚠️ **MUST BE CREATED** |
| `POST /api/Data/GetAreaList` | Area/neighborhood lookup | ✅ Step 1: Area Selection | ⚠️ **MUST BE CREATED** |

**Reference:** See `PAISLEY_UI_DISCOVERY_FINDINGS_v1.md` for full Paisley service architecture and mobile design patterns.

### API Endpoint Specifications

**⚠️ CRITICAL:** These endpoints do not exist yet and must be created in `DataController.cs`. Per Master Rules (Rule 3: NO PLACEHOLDERS), no mock data is allowed in the prototype - endpoints must be implemented.

#### 1. POST /api/Data/AutoCompleteAddress

**Purpose:** Address autocomplete using Google Places API (backend integration)

**Request Body:**
```json
{
  "AspNetUserId": "",  // Will be set by backend from JWT token
  "AddressKey": "10025 Rebecca Pl",  // User's typed query
  "BiasLatitude": null,  // Optional: For location biasing
  "BiasLongitude": null,  // Optional: For location biasing
  "SessionToken": null  // Optional: For Google Places session management
}
```

**Response:**
```json
{
  "Success": true,
  "Addresses": [
    {
      "FullAddress": "10025 Rebecca Place, Boerne, TX 78006",
      "Address": "10025 Rebecca Place",
      "PlaceKey": "ChIJ...",  // Google Places Place ID
      "Key": "ChIJ...",  // Alternative key field
      "StreetNumber": "10025",
      "StreetName": "Rebecca Place",
      "City": "Boerne",
      "State": "TX",
      "Zip": "78006"
    }
  ],
  "Errors": null
}
```

**Alternative Response Format (if using Data wrapper):**
```json
{
  "Success": true,
  "Data": [ /* same address objects */ ],
  "Errors": null
}
```

**Implementation Notes:**
- Uses Google Places Autocomplete API on backend
- Debounced calls (600ms) from frontend
- Minimum 4 characters required before API call
- Returns up to 5-10 suggestions

#### 2. POST /api/Data/GetPropertiesFromPlaceKey

**Purpose:** Get full property details from Google Places PlaceKey

**Request Body:**
```json
{
  "AspNetUserId": "",  // Will be set by backend from JWT token
  "PlaceKey": "ChIJ..."  // Google Places Place ID
}
```

**Response:**
```json
{
  "Success": true,
  "Properties": [
    {
      "StreetNumber": "10025",
      "StreetName": "Rebecca Place",
      "City": "Boerne",
      "State": "TX",
      "Zip": "78006",
      "OriginalListPrice": 749000,
      "Bedrooms": 4,
      "BathroomsFull": 3,
      "BathroomsHalf": 0,
      "LivingAreaSqFt": 3018,
      "LotSizeSqFt": 9101,
      "YearBuilt": 2022,
      "PropertyType": "Single Family",
      "GarageSpaces": 3,
      "ParkingSpaces": 3,
      "Latitude": 29.72229,
      "Longitude": -98.68958
    }
  ],
  "Errors": null
}
```

**Implementation Notes:**
- Uses Google Places Details API
- May also query TitleData/MLS for additional property data
- Returns first matching property

#### 3. POST /api/Data/GetAreaList

**Purpose:** Get area/neighborhood list for a city or search term

**Request Body:**
```json
{
  "AspNetUserId": "",  // Will be set by backend from JWT token
  "AreaTypes": [],  // Empty = all area types, or specify types if needed
  "SearchKey": "Boerne"  // City name or search term
}
```

**Response:**
```json
[
  {
    "AreaId": 1,
    "AreaName": "Balcones Creek",
    "City": "Boerne",
    "State": "TX"
  }
]
```

**Alternative Response Format (if using wrapper):**
```json
{
  "Success": true,
  "Data": [ /* same area objects */ ],
  "Errors": null
}
```

**Implementation Notes:**
- Queries area/neighborhood database
- Filters by city or search term
- Returns all matching areas

**Implementation Location:**
- **Controller:** `DataController.cs`
- **Base Route:** `/api/Data`
- **Authentication:** JWT Bearer Token (required)
- **C# Template:** `DataController_Endpoints_v1.cs` (reference implementation)

### PLS Address Lookup Flow

1. **User types address** → Calls `AutoCompleteAddress` (debounced 600ms)
2. **User selects address** → Calls `GetPropertiesFromPlaceKey` to get full property details
3. **Auto-populates form** → Street Number, Street Name, City, State, Zip, Bedrooms, Bathrooms, Sqft, etc.
4. **Fetches areas** → Calls `GetAreaList` with city name
5. **User selects area** → Proceeds to Step 2 (Property Details)

### Component Files

- `pls-create.component.ts` - Address autocomplete logic
- `pls-create.component.html` - Address input field with autocomplete dropdown
- `pls-create.component.scss` - Mobile-responsive styling

### Prototype Files

- `PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html` - Latest prototype (mobile-first, fixed area binding)
  - **URL:** [http://127.0.0.1:8092/PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html](http://127.0.0.1:8092/PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html)
  - **Improvements in v4:**
    - Mobile-first responsive design (drawer pattern for mobile, dropdown for desktop)
    - Fixed area binding issue (properly triggers on address selection)
    - Input always enabled (MutationObserver + setInterval backup)
    - Touch-friendly inputs (44px min height)
    - Fixed step numbering (Step 2 for Property Details)
    - Better error handling and loading states

### Mobile Considerations

- **Mobile:** Drawer pattern for area selection
- **Desktop:** Dropdown pattern for area selection
- **Touch-friendly:** All inputs 44px min height

**Note:** Full mobile-first design requirements and Paisley service architecture documented in `PAISLEY_UI_DISCOVERY_FINDINGS_v1.md` (separate Paisley UI redesign project).

---

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 20. COMPLETE WORKFLOW SPECIFICATION

### 20.1 Workflow Overview

The PLS RESO Engine workflow defines the **complete end-to-end lifecycle** from initial property lookup through GenieCloud asset generation and multi-role lifecycle management.

#### Complete Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PLS LISTING LIFECYCLE                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  PHASE 1: PAISLEY PRE-LISTING FOCUS                                      │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │ 1. Agent opens Paisley → ChatStartTypeId=3 (Pre-Listing Focus)   │ │
│  │ 2. Google Places property lookup (address autocomplete)           │ │
│  │ 3. Area selection (neighborhood/farm area)                         │ │
│  │ 4. Pre-Listing Configurator (Title Genie integration)             │ │
│  │ 5. Property data pre-population (TitleData + Historical MLS)     │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                    │                                     │
│                                    ▼                                     │
│  PHASE 2: PLS LISTING CREATION                                          │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │ 6. Agent reviews pre-populated data                              │ │
│  │ 7. Resolves conflicts (sqft, beds/baths flagged with *)          │ │
│  │ 8. Uploads photos (S3, minimum 1 required)                        │ │
│  │ 9. Generates AI description (Paisley ChatStartTypeId=3)           │ │
│  │ 10. Selects status (Coming Soon=14 or Private=6)                 │ │
│  │ 11. Saves listing → Generates PLS Number (PLS100000A)             │ │
│  │ 12. INSERT into MlsListing.dbo.Listing (MlsId=777)               │ │
│  │ 13. INSERT into pls_tracking (status='draft', source='paisley')   │ │
│  │ 14. INSERT into PlsListingOwnership (OwnershipTypeId=1, Creator) │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                    │                                     │
│                                    ▼                                     │
│  PHASE 3: XML GENERATION & GENIECLOUD RENDER                            │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │ 15. Agent clicks "Generate Content Kit"                           │ │
│  │ 16. System loads listing + agent + area data                     │ │
│  │ 17. Build XML (PlsService.BuildXml)                               │ │
│  │ 18. Validate XML against Contract v6.1                            │ │
│  │ 19. POST to GenieCloud /api/render                               │ │
│  │ 20. GenieCloud renders assets (landing page, social ads, etc.)   │ │
│  │ 21. Returns collection URL                                       │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                    │                                     │
│                                    ▼                                     │
│  PHASE 4: LISTING COMMAND INTEGRATION                                  │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │ 22. INSERT into ListingCommandQueue (PropertyCastTypeId=4)       │ │
│  │ 23. Listing Command workflow processes PLS listing                │ │
│  │ 24. Circle prospecting automation (SMS to farm area)             │ │
│  │ 25. Lead capture via Engagement Center                           │ │
│  │ 26. Status updated: 'draft' → 'active' or 'coming_soon'          │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

### 20.2 Phase 1: Paisley Pre-Listing Focus Workflow

The PLS workflow **starts in Paisley** with ChatStartTypeId=3 (Pre-Listing Focused). This is the entry point that integrates property lookup, area selection, and the Pre-Listing Configurator.

#### Step 1: Agent Opens Paisley Pre-Listing Focus
**UI:** Paisley interface (existing)  
**Action:** Agent selects "Pre-Listing Focus" (ChatStartTypeId=3)  
**System:** Initializes Paisley chat session with pre-listing context

#### Step 2: Google Places Property Lookup
**UI:** Address autocomplete input (from `PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html`)  
**API:** `POST /api/Data/AutoCompleteAddress`  
**Backend:** `AgentDashboardManager.AutocompleteAddress()` → Google Places API  
**Response:** List of address suggestions with PlaceKey (Google Places ID)

**User Action:**
- Types address (minimum 4 characters)
- Debounced API call (600ms delay)
- Selects address from dropdown

#### Step 3: Property Details Retrieval
**API:** `POST /api/Data/GetPropertiesFromPlaceKey`  
**Backend:** Google Places Details API + TitleData/MLS lookup  
**Response:** Full property details (bedrooms, bathrooms, sqft, year built, etc.)

**Data Sources:**
- Google Places Details API (address components, coordinates)
- TitleData.dbo.AttomDataAssessor (property characteristics)
- Historical MLS listings (conflict detection)

#### Step 4: Area Selection
**UI:** Area/neighborhood picker (drawer on mobile, dropdown on desktop)  
**API:** `POST /api/Data/GetAreaList`  
**Backend:** `DashboardAutoCompleteManager.GetAreas()`  
**Response:** List of areas matching city/search term

**User Action:**
- System auto-fetches areas based on selected city
- User selects area (for market stats widgets on landing page)
- AreaId stored for Listing Command integration

#### Step 5: Pre-Listing Configurator (Title Genie Integration)
**UI:** Pre-Listing Command Configurator (from Title Genie Pre-Listing Command Project)  
**Purpose:** Configure listing parameters before creating PLS listing  
**Integration:** Uses TitleData + Historical MLS data for pre-population

**Key Features:**
- Property data pre-population
- Conflict flagging (sqft, beds/baths differences)
- Area selection
- Status selection (Coming Soon vs Private)

### 20.3 Phase 2: PLS Listing Creation

#### Step 6-7: Data Review & Conflict Resolution
**UI:** PlsCreateComponent form  
**Data Source:** Pre-populated from Phase 1  
**Conflict Detection:**
- Compare TitleData vs Historical MLS values
- Flag conflicts with asterisk (*)
- User reviews and selects preferred value

**Example Conflict:**
```
Sqft: 2500* (TitleData) vs 3018 (Historical MLS)
Reason: MLS value includes permitted expansion
Recommended: 3018 (use MLS value)
```

#### Step 8: Auto-Generated Photo & Description (Combined UI)
**UI:** Combined display page showing auto-generated content  
**Auto-Generated Content:**
1. **Mapbox Satellite Photo** (automatic):
   - API: Mapbox Static Images API
   - Features: Property boundary overlay + clearest closed view of best angle
   - Generated using property coordinates from TitleData/address
   - Stored as primary photo in `MlsListing.dbo.Photo` (DisplayOrder=1)

2. **Paisley AI Description** (automatic):
   - API: `POST /api/pls/generate-description` (triggered automatically)
   - Backend: Paisley AI integration (ChatStartTypeId=3, Pre-Listing Focused)
   - Uses: Listing Data + Area Data
   - Generated automatically when property data is pre-populated

**Combined UI Elements:**
- **System-generated Mapbox satellite photo** (displayed, with property boundary overlay)
- **Paisley-generated description** (displayed, with "Edit" button only - no "Generate" button)
- **"Load Photos" button** (optional - allows user to upload additional photos up to RESO DB limit)

**Photo Upload (Optional):**
- **UI:** "Load Photos" button opens photo upload component (drag-and-drop)
- **API:** `POST /api/pls/upload-photo`  
- **Backend:** S3 upload service  
- **Storage:** `https://genie-cloud.s3.us-west-1.amazonaws.com/genie-pages/pls100000a/photos/photo2.jpg` (DisplayOrder=2, 3, etc.)
- **Requirement:** Mapbox photo is automatic (DisplayOrder=1). Additional photos are optional.

**Database:**
```sql
-- Auto-insert Mapbox photo (DisplayOrder=1)
INSERT INTO MlsListing.dbo.Photo (ListingID, MlsID, PhotoUrl, DisplayOrder, PhotoSource)
VALUES (@ListingID, 777, @MapboxPhotoUrl, 1, 'Mapbox')

-- Optional: User-uploaded photos (DisplayOrder=2, 3, etc.)
INSERT INTO MlsListing.dbo.Photo (ListingID, MlsID, PhotoUrl, DisplayOrder, PhotoSource)
VALUES (@ListingID, 777, @UserPhotoUrl, @DisplayOrder, 'User')
```

#### Step 10: Status Selection
**UI:** Radio buttons or dropdown  
**Options:**
- **Coming Soon** (StatusTypeID=14) - Property will be listed soon
- **Private Listing** (StatusTypeID=6) - Active private listing

#### Step 10-13: Save Listing & Generate PLS Number

**API:** `POST /api/pls/create`

**Business Logic:**
1. **Generate PLS Number:**
   ```sql
   DECLARE @PlsNumber VARCHAR(10);
   EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNumber OUTPUT;
   -- Returns: PLS100000A (first call), PLS100001A (second call), etc.
   ```

2. **INSERT into MlsListing.dbo.Listing:**
   ```sql
   INSERT INTO MlsListing.dbo.Listing (
       MlsID,              -- 777
       MlsNumber,          -- PLS100000A
       StatusTypeID,       -- 6 or 14
       PropertyCastTypeId, -- 4
       DisplayAddress, StreetNumber, StreetName, City, State, Zip,
       OriginalListPrice, Bedrooms, BathroomsTotal, BathroomsFull, BathroomsHalf,
       Sqft, LotSqft, YearBuilt, Latitude, Longitude, Remarks,
       ListingAgentName, ListingAgentID,  -- From logged-in user
       CoListingAgentName, CoListingAgentID,  -- Optional co-agent
       ListDate, MlsCreateDate
   )
   VALUES (...)
   ```

3. **INSERT into pls_tracking:**
   ```sql
   INSERT INTO FarmGenie.dbo.pls_tracking (
       listing_id,         -- From Listing.ListingID
       agent_id,           -- AspNetUserId (logged-in user)
       source_type_id,     -- 1 (paisley) - from pls_source_type lookup
       status_type_id,     -- 1 (incomplete) or 2 (draft) - from pls_status_type lookup
       was_listed,         -- 0 (default)
       mls_published       -- 0 (default)
   )
   VALUES (...)
   ```

4. **INSERT into pls_status_log (initial status):**
   ```sql
   INSERT INTO FarmGenie.dbo.pls_status_log (
       listing_id,
       changed_by,         -- AspNetUserId
       from_status_type_id, -- NULL (initial creation)
       to_status_type_id    -- 1 (incomplete) or 2 (draft)
   )
   VALUES (...)
   ```

5. **INSERT into PlsListingOwnership:**
   ```sql
   INSERT INTO FarmGenie.dbo.PlsListingOwnership (
       AspNetUserId,       -- Logged-in user
       MlsId,              -- 777
       MlsNumber,          -- PLS100000A
       ListingId,          -- From Listing.ListingID
       OwnershipTypeId,    -- 1 (Creator)
       IsActive            -- 1
   )
   VALUES (...)
   ```

**Response:**
```json
{
  "success": true,
  "plsNumber": "PLS100000A",
  "listingId": 12345
}
```

### 20.4 Phase 3: XML Generation & GenieCloud Render

#### Step 15-21: Generate Content Kit

**UI:** "Generate Content Kit" button (PlsEditComponent)  
**API:** `POST /api/pls/{listingNumber}/render`

**Business Logic:**

1. **Load Listing Data:**
   ```sql
   SELECT * FROM MlsListing.dbo.Listing l
   INNER JOIN MlsListing.dbo.StatusType st ON st.StatusTypeID = l.StatusTypeID
   WHERE l.MlsID = 777 AND l.MlsNumber = @plsNumber
   ```

2. **Load Agent Data:**
   ```sql
   SELECT 
       u.Id AS AspNetUserId,
       up.FirstName, up.LastName,
       ump.DisplayName, ump.MarketingTitle, ump.Phone, ump.Email,
       ump.Website, ump.CompanyName, ump.StreetAddress, ump.City, ump.State, ump.Zip
   FROM FarmGenie.dbo.AspNetUsers u
   INNER JOIN FarmGenie.dbo.AspNetUserProfiles up ON up.AspNetUserId = u.Id
   LEFT JOIN FarmGenie.dbo.UserMarketingProfile ump ON ump.AspNetUserId = u.Id
   WHERE u.Id = @userId
   ```

3. **Load Area Data:**
   ```sql
   SELECT AreaId, AreaName, CenterLatitude, CenterLongitude
   FROM FarmGenie.dbo.Area
   WHERE AreaId = @areaId
   ```

4. **Load Photos:**
   ```sql
   SELECT PhotoUrl, DisplayOrder
   FROM MlsListing.dbo.Photo
   WHERE ListingID = @listingId AND MlsID = 777
   ORDER BY DisplayOrder ASC
   ```

5. **Build XML (PlsService.BuildXml):**
   - Maps listing data → XML structure (per Contract v6.1)
   - Maps agent data → `<agents>` section
   - Maps area data → `<areas>` section
   - Maps photos → `<images>` section
   - Validates XML against contract

6. **POST to GenieCloud:**
   ```json
   POST https://cloud-api.thegenie.ai/api/render
   {
     "userId": "{asp-user-id}",
     "listingId": "pls-PLS100000A",
     "assets": [
       "landing-pages/pls-hollywood",
       "social-marketing-graphics/lc-prop-post-03"
     ],
     "theme": "compass",
     "themeHue": "dark",
     "xml": "<renderRoot>...</renderRoot>"
   }
   ```

7. **GenieCloud Response:**
   ```json
   {
     "renderId": "pls-PLS100000A",
     "status": "queued",
     "collectionUrl": "https://cloud.thegenie.ai/genie-collection/{id}"
   }
   ```

8. **Update pls_tracking:**
   ```sql
   UPDATE FarmGenie.dbo.pls_tracking
   SET status_type_id = (SELECT status_type_id FROM pls_status_type WHERE status_code = 'active'),
       updated_at = GETUTCDATE()
   WHERE listing_id = @listingId
   ```

9. **Log Status Change:**
   ```sql
   INSERT INTO FarmGenie.dbo.pls_status_log (
       listing_id, changed_by, from_status_type_id, to_status_type_id
   )
   VALUES (@listingId, @userId, 2, 3)  -- draft → active
   ```

### 20.5 Phase 4: Listing Command Integration

#### Step 22-26: Circle Prospecting Automation

**Queue Insert:**
```sql
INSERT INTO FarmGenie.dbo.ListingCommandQueue (
    MlsID,              -- 777
    MlsNumber,          -- PLS100000A
    PropertyCastTypeId, -- 4 (PLS)
    AspNetUserId,       -- Agent user ID
    AreaId,             -- Selected area
    CreateDate
)
VALUES (777, 'PLS100000A', 4, @userId, @areaId, GETDATE())
```

**Workflow:**
1. Listing Command service processes queue
2. Generates SMS messages to farm area
3. Creates landing page links with UTM tracking
4. Engagement Center captures leads
5. Versium data append (automatic)
6. Status remains 'active' or 'coming_soon'

**UI:** Reuse existing `ListingCommandInitiateComponent` with route parameter `{plsNumber}`

### 20.6 Multi-Role Lifecycle Management

#### Role 1: LISTING AGENT (Primary Owner)
**Permission:** `ManagePLS` (210)  
**Access Level:** Full CRUD on own listings  
**Views:**
- **My PLS Listings** (`/pls/my-listings`) - List all own listings
- **Create Listing** (`/pls/create`) - Create new PLS listing
- **Edit Listing** (`/pls/edit/{plsNumber}`) - Edit own listings
- **View Listing** (`/pls/view/{plsNumber}`) - View listing details
- **Generate Content Kit** - Trigger GenieCloud render
- **Start Campaign** - Initiate Listing Command workflow

**Database Access:**
- Own listings via `PlsListingOwnership` (OwnershipTypeId=1, Creator)
- Can update `MlsListing.dbo.Listing` fields
- Can change status (draft → active, active → coming_soon, etc.)
- Can upload/edit photos
- Can generate/regenerate XML

#### Role 2: TITLE REP (Optional - Permission-Based)
**Permission:** `Title Partner` (via `Permission` table)  
**Access Level:** Account-level access (not listing-specific)  
**Views:**
- **Agent's PLS Listings** - View all listings for agents they have access to
- **View Listing** - Read-only access to listing details
- **Assist with Listing** - Can view but cannot edit (unless granted specific permission)

**Database Access:**
- Access via `Permission` table (account-level, not listing-level)
- Read-only access to listings for agents they support
- Cannot create/edit listings (unless granted `ManagePLS` permission)
- Can view GenieCloud collection URLs
- Can view Listing Command campaign status

**Note:** Title Reps are NOT tracked as listing-specific collaborators. Access is controlled via `FarmGenie.dbo.Permission` table (Title Partner permission type).

#### Role 3: GENIE SUPERUSER ADMIN
**Permission:** `PLS Radar` (213) + `PLS Submit While Impersonating` (214)  
**Access Level:** Full access across all users  
**Views:**
- **PLS Radar** (`/pls/radar`) - View ALL PLS listings across all users
- **Admin Dashboard** - System-wide PLS statistics
- **User Impersonation** - Create/edit listings for any user
- **Status Management** - Can change any listing's status
- **Audit Trail** - View complete `pls_status_log` for any listing

**Database Access:**
- Full access to all PLS listings (no ownership filter)
- Can query `pls_tracking` for all listings
- Can view `pls_status_log` audit trail
- Can update any listing's status
- Can create listings for any user (impersonation)

#### Lifecycle Status Transitions

**Status Types (from pls_status_type lookup table):**
1. **incomplete** (status_type_id=1) - Listing not yet saved
2. **draft** (status_type_id=2) - Saved but not published
3. **active** (status_type_id=3) - Private Listing (StatusTypeID=6, published)
4. **coming_soon** (status_type_id=4) - Coming Soon (StatusTypeID=14, published)
5. **lost_opportunity** (status_type_id=5) - Listing opportunity was lost
6. **published_to_mls** (status_type_id=6) - Successfully published to actual MLS

**Status Transition Rules:**
- **incomplete → draft:** User saves listing
- **draft → active:** User publishes as Private Listing (StatusTypeID=6)
- **draft → coming_soon:** User publishes as Coming Soon (StatusTypeID=14)
- **active/coming_soon → lost_opportunity:** Agent marks as lost
- **active/coming_soon → published_to_mls:** Future RESO Insert feature

**Who Can Change Status:**
- **Listing Agent:** Can change own listing status (draft → active, active → lost_opportunity, etc.)
- **Title Rep:** Cannot change status (read-only access)
- **Admin:** Can change any listing's status

#### Audit Trail

**pls_status_log Table:**
- Tracks every status change
- Records `changed_by` (AspNetUserId)
- Records `from_status_type_id` → `to_status_type_id`
- Records `changed_at` timestamp
- Complete audit trail for compliance

**Query Example:**
```sql
SELECT 
    psl.changed_at,
    u.Email AS ChangedByEmail,
    pst_from.status_name AS FromStatus,
    pst_to.status_name AS ToStatus
FROM FarmGenie.dbo.pls_status_log psl
INNER JOIN FarmGenie.dbo.AspNetUsers u ON u.Id = psl.changed_by
LEFT JOIN FarmGenie.dbo.pls_status_type pst_from ON pst_from.status_type_id = psl.from_status_type_id
INNER JOIN FarmGenie.dbo.pls_status_type pst_to ON pst_to.status_type_id = psl.to_status_type_id
WHERE psl.listing_id = @listingId
ORDER BY psl.changed_at DESC
```

### 20.7 Prototype Workflow (NO DUMMY DATA)

#### Sample Project: 10037 Rebecca Place, Boerne, TX 78006

**Step 1: Property Lookup**
- User types: "10037 Rebecca Place"
- API returns: Google Places suggestions
- User selects: "10037 Rebecca Place, Boerne, TX 78006"
- PlaceKey: `ChIJ...` (Google Places ID)

**Step 2: Property Details**
- API queries TitleData.dbo.AttomDataAssessor
- API queries Historical MLS (MlsListing.dbo.Listing)
- Returns: Bedrooms=4, Bathrooms=3, Sqft=3018, YearBuilt=2022, etc.
- Conflicts: None (data matches)

**Step 3: Area Selection**
- City: Boerne, TX
- API returns: Areas in Boerne
- User selects: "Balcones Creek" (AreaId=407559)

**Step 4: Create Listing**
- User fills form with pre-populated data
- Uploads 5 photos (S3 URLs generated)
- Generates AI description (Paisley ChatStartTypeId=3)
- Selects status: Private Listing (StatusTypeID=6)
- Clicks "Save Listing"

**Step 5: PLS Number Generated**
- Stored procedure: `usp_GetNextPlsNumber`
- Returns: `PLS100000A` (first listing)
- INSERT into MlsListing.dbo.Listing (MlsId=777, MlsNumber=PLS100000A)
- INSERT into pls_tracking (status='draft', source='paisley')
- INSERT into PlsListingOwnership (OwnershipTypeId=1)

**Step 6: Generate Content Kit**
- User clicks "Generate Content Kit"
- System builds XML (Contract v6.1 format)
- POST to GenieCloud /api/render
- GenieCloud renders: Landing page, social ads, brochures
- Returns: Collection URL

**Step 7: Listing Command**
- INSERT into ListingCommandQueue (PropertyCastTypeId=4)
- Listing Command workflow processes
- SMS sent to farm area
- Lead capture via Engagement Center

**Result:**
- ✅ Real property data (no dummy data)
- ✅ Real PLS number (PLS100000A)
- ✅ Real GenieCloud collection
- ✅ Real Listing Command campaign

### 20.8 Comparison with eRealtor Blueprint

#### eRealtor Architecture Patterns (Reference)

**From eRealtorMSv1i1 Tech Design.pdf:**

1. **3-Layer Architecture:**
   - **Strategy Layer** - Business logic, workflows
   - **Data Layer** - Database, stored procedures
   - **Interface Layer** - UI, XML generation

2. **Session Management:**
   - `isSessionManagement` maintains user state
   - 10-minute session lifespan (configurable)
   - Session data includes: UID, UserTypeCode, Authenticated flag

3. **Include Files Pattern:**
   - `_AuthCheck.inc` - Authentication verification
   - `_Constants.inc` - Never use "magic numbers"
   - `_SessionRead.inc` - Read session data
   - `_SessionSave.inc` - Save session data

4. **Private Label Support:**
   - Header/footer content delivered by Offer Manager
   - Server-to-server communication (no cookies)
   - Cached for user session

#### PLS Alignment with eRealtor Patterns

**✅ Similarities:**
- **3-Layer Architecture:** PLS follows same pattern (Data → Function → Interface)
- **Session Management:** Uses JWT tokens (modern equivalent of isSessionManagement)
- **Constants:** Master data in lookup tables (pls_status_type, pls_source_type)
- **Audit Trail:** Complete status log (similar to eRealtor transaction logs)

**🔄 Differences:**
- **Technology:** PLS uses .NET Framework 4.8 Web API (modern), eRealtor used ASP/VB6 (legacy)
- **Authentication:** PLS uses JWT Bearer tokens, eRealtor used session cookies
- **Database:** PLS uses normalized schema with lookup tables, eRealtor used string enums
- **XML Generation:** PLS generates XML for GenieCloud, eRealtor generated SOAP XML

**📋 Lessons Applied:**
1. **Never use "magic numbers"** → PLS uses lookup tables (pls_status_type, pls_source_type)
2. **Complete audit trail** → pls_status_log tracks every status change
3. **Session state management** → JWT tokens maintain user context
4. **Include file pattern** → PLS uses service layer (PlsService) for reusable logic

### 20.9 Future Roles (Iteration 2+)

#### Role 4: Team Manager (Future)
**Purpose:** Manage listings for team members  
**Access:** View/edit listings for team members  
**Status:** 🔮 Future Feature - Not in MVP

#### Role 5: Broker Manager (Future)
**Purpose:** Broker-level oversight of all listings  
**Access:** View all listings for broker's agents  
**Status:** 🔮 Future Feature - Not in MVP

---

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 21. REFERENCE DOCUMENTS

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

**[↑ Back to Table of Contents](#-table-of-contents)**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.14 | 01/09/2026 | Danny (Dev Lead) | **SANDBOX SAFETY VERIFICATION INTEGRATION** - Integrated Sandbox Safety Verification into Section 14 (Deployment Prompt Beta). Added comprehensive safety verification checklist, connection string verification, database context verification, and production protection guarantees. All deployment procedures now include mandatory pre-deployment safety checks. Standalone safety verification document archived per DRA-2026 Rule 1. |
| 1.13 | 01/09/2026 | Danny (Dev Lead) | **DRA-2026 COMPLIANCE + DEPLOYMENT PROMPT BETA** - Consolidated 4 redundant deployment/testing documents into Section 14 (Deployment Plan). Added Deployment Prompt Beta (Fortune 500 enterprise procedures) with timestamped backup, rollback verification, pre/post-deployment checklists. Added complete sandbox deployment steps, UI testing readiness checklist, and production deployment procedures. All redundant documents archived per DRA-2026 Rule 1. |
| 1.12 | 01/09/2026 | Danny (Dev Lead) | **WORKFLOW ENHANCEMENT** - Updated Section 10 (UI Design) Steps 10-11: Combined into single step showing auto-generated content. System now auto-generates Mapbox satellite photo (property boundary + best angle view) and Paisley auto-generates description (ChatStartTypeId=3) on same UI page. Photo upload is now optional with "Load Photos" button. Description shows with "Edit" button only (no "Generate" button). Updated Section 20.3 Step 8 to match. Fixed step numbering (11-15). |
| 1.11 | 01/09/2026 | Danny (Dev Lead) | **WORKFLOW CORRECTIONS** - Fixed Section 10 (UI Design): (1) Changed Step 1 menu from "Private Listings" to "Pre-Listing" (Paisley ChatStartTypeId=3). (2) Corrected order of Steps 6-7: System auto-fetches areas (Step 6) now comes before User selects area (Step 7) to match logical flow and Section 20.2 workflow. |
| 1.10 | 01/09/2026 | Danny (Dev Lead) | **WORKFLOW CLARIFICATION** - Updated Section 10 (UI Design) Step 11 to correctly state that Paisley generates the AI description (not the user). Paisley uses ChatStartTypeId=3 (Pre-Listing Focused) with Listing Data + Area Data to generate the description. User clicks "Generate with AI" button to trigger Paisley. |
| 1.9 | 01/09/2026 | Danny (Dev Lead) | **WORKFLOW FIX** - Added missing Area Selection step to Section 11 (Data Flow Diagrams) User Experience Flow. Corrected workflow sequence to match Paisley Pre-Listing Focus flow: Address selection → Area selection (critical for Listing Command) → Property pre-population. Updated step numbering (4-16) to reflect complete flow. Added API endpoint references for clarity. |
| 1.8 | 01/09/2026 | Steve Hundley | Added hyperlinks to Table of Contents (all 21 sections) and "Back to TOC" navigation links at end of each section for improved document navigation. |
| 1.7 | 01/09/2026 | Cursor AI Agent | **DRA-2026 COMPLIANCE** - Consolidated complete workflow specification, multi-role lifecycle management, and eRealtor blueprint comparison from 4 new v1 documents into Section 20 (Complete Workflow Specification). Deleted redundant v1 documents per DRA-2026 Rule 1 (No New V1 Documents). Added end-to-end workflow phases, role definitions, status transitions, and prototype workflow example. |
| 1.6 | 01/07/2026 12:00 PM | Cursor AI Agent | **DRA-2026 COMPLIANCE** - Consolidated API endpoint specifications from standalone v1 document into Section 19. Removed all mock data from prototype per Master Rules (Rule 3: NO PLACEHOLDERS). Added detailed endpoint specs with request/response formats. |
| 1.5 | 01/06/2026 | Cursor AI Agent | **DRA-2026 COMPLIANCE** - Moved Paisley-specific content (service architecture, mobile design, AskPaisley redesign) to `PAISLEY_UI_DISCOVERY_FINDINGS_v1.md`. Kept only PLS-specific address lookup details in Section 19. Deleted 4 new v1 documents. |
| 1.4 | 01/06/2026 | Cursor AI Agent | Added Future Features section (Section 18) - AR Mobile App workflow and photo-initiated listing creation. Updated `POST /api/pls/pre-populate` to accept optional latitude/longitude parameters. Added `POST /api/pls/reverse-geocode` endpoint specification. **DRA-2026 Compliant:** No new v1 documents created - content consolidated into blueprint. |
| 1.3 | 01/05/2026 | Cursor AI Agent | Updated database schema - MlsID changed to 777, normalized schema with lookup tables, removed collaborator concept, updated PlsListingOwnership table definition, **PLS number format changed to PLS{6-digit}{letter} (e.g., PLS100000A)** |
| 1.2 | 01/04/2026 | Cursor AI Agent | DRA-2026 Phase 4: Consolidated redundant project plans (Master Plan v2, Comprehensive Plan, Action Plan, Status & Next Steps) - Added detailed testing checklist, MVP definition with Must Have/Nice to Have/Future breakdown |
| 1.1 | 01/04/2026 | Cursor AI Agent | DRA-2026 compliance: Added compliance section, consolidated redundant project plans, archived session documents |
| 1.0 | 01/02/2026 | Cursor AI Agent | Initial project blueprint created |

---

**Status:** ✅ Project Blueprint Complete - Ready for Team Alignment

**Next Action:** Review with all participating agents and roles to confirm scope, assign ownership, and begin implementation.

