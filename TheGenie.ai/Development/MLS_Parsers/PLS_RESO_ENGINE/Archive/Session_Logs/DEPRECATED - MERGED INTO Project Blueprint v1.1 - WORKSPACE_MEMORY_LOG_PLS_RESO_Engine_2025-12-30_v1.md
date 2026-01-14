# Workspace Memory Log: PLS RESO Engine Discovery & Development
**Date:** December 30, 2025  
**Version:** 1.0  
**Session Focus:** PLS RESO Engine Prototype Development & Strategic Vision

---

## 🎯 SESSION OBJECTIVE

Build the "Paisley RESO Listing Engine" (PLS) - a private listing service for pre-MLS listings (Coming Soon/Private) that enables agents to market properties BEFORE they hit MLS, with a future "one-button push" to automatically publish listings to actual MLSs (Bridge and Trestle) without double entry.

---

## 💡 VISION ALIGNMENT

### The Complete System
1. **PLS (Pre-MLS)** = Create Coming Soon/Private listings in our system
2. **RESO Insert** = Push those listings INTO Bridge and Trestle when ready (strategic opportunity)

### The Flow
```
Agent creates PLS listing (Coming Soon/Private)
    ↓
Market it via Listing Command (circle prospecting)
    ↓
When ready to go public → Push button
    ↓
RESO Insert → Bridge/Trestle → Listing goes live in MLS
```

### Two Use Cases
1. **Coming Soon/Private → Market BEFORE MLS → Push to MLS when ready (one button)**
   - Agents become "early movers" to sell properties before they go public
   - Use Listing Command circle prospecting automation
   - When ready, push to MLS without double entry

2. **MLS-Ready → AI pre-populates → Agent reviews/submits (saves time)**
   - Paisley AI pre-populates listing data from existing system data
   - Agent reviews and submits (saves manual entry time)
   - Reduces button-clicking and data loading time

---

## 🏗️ ARCHITECTURE & DESIGN

### Database Strategy
- **PLS Listings:** Stored in `MlsListing.dbo.Listing` with `MlsId=999` (NOT new tables)
- **Status Codes:**
  - `StatusTypeID 6` = Private Listing (NEEDS INSERT - does NOT exist)
  - `StatusTypeID 14` = Coming Soon (EXISTS in database)
- **PropertyCastTypeId:** `4` for PLS (leverages existing Listing Command workflows)
- **PLS Number Format:** `PLS-YYYY-NNNNN` (e.g., `PLS-2025-00001`)

### New Database Objects
1. **PlsListingOwnership Table (FarmGenie)**
   - Links users to PLS listings
   - Tracks ownership (Creator, CoAgent)
   - Prevents duplicate PLS numbers per user

2. **PlsNumberSequence Table (FarmGenie)**
   - Manages PLS number generation
   - Year-based sequence
   - Thread-safe via stored procedure

3. **usp_GetNextPlsNumber Stored Procedure**
   - Generates next PLS number
   - Format: `PLS-YYYY-NNNNN`
   - Thread-safe with transaction

### Integration Points
- **GenieCloud:** XML generation for asset rendering
- **Listing Command:** PropertyCastTypeId=4 workflow integration
- **Paisley AI:** ChatStartTypeId=3 for pre-listing descriptions
- **TitleGenie:** Property research, Attom/MLS data
- **Engagement Center:** Lead capture, UTM tracking, data append

---

## 📋 SPECIFICATIONS CREATED

### 1. PLS UI Specification (`PLS_UI_SPECIFICATION_v1.md`)
- **Format:** eRealtor Tech Design Style
- **Content:**
  - User flow diagrams (Create, Edit, Start Campaign)
  - Screen specifications (4 screens with layouts)
  - Function definitions (Frontend Angular + Backend .NET)
  - Data flow diagrams
  - Business logic (PLS number generation, ownership, AI description)
  - Integration points (GenieCloud, Listing Command, Paisley)

### 2. Database Implementation Spec (`PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`)
- **Content:**
  - SQL scripts ready to execute
  - Table creation (PlsListingOwnership, PlsNumberSequence)
  - Stored procedure (usp_GetNextPlsNumber)
  - Master data inserts (StatusType 6, MlsId 999, PropertyCastTypeId 4)
  - Permissions setup
  - Role grants (Affiliate, Core Agent, Elite, Ultimate, Super User)
  - Verification queries
  - Rollback scripts

### 3. XML Generation Spec (`PLS_XML_GENERATION_SPEC_v1.md`)
- **Content:**
  - Complete XML template
  - Data mapping tables (Listing → XML, Agent → XML, Area → XML)
  - C# implementation code
  - Validation rules
  - Test XML example

### 4. Friday Prototype Roadmap (`PLS_FRIDAY_PROTOTYPE_ROADMAP_v1.md`)
- **Content:**
  - Implementation phases (Database → API → UI → Integration)
  - Testing checklist
  - MVP requirements
  - Next steps

---

## 🔗 STRATEGIC OPPORTUNITY: RESO INSERT

### The Opportunity
- **Market Gap:** No standardized RESO Insert exists
- **Technical Foundation:** RESO Web API is built on OData (supports CRUD)
- **First-Mover Advantage:** Opportunity to set the industry standard
- **Vendor Landscape:**
  - Bridge Interactive: Standard API read-only; Bridge Listing Input (enterprise) supports writes
  - Trestle (CoreLogic): Standard API read-only; Trestle Direct™ (enterprise) capabilities unknown

### Strategic Approach
1. **Extend RESO Standard** - Propose RESO Insert spec to RESO.org
2. **Build Vendor-Agnostic Solution** - Work with Bridge and Trestle
3. **Partner with Vendors** - Collaborate on implementation

### Research Documents
- `BRIDGE_API_WRITE_CAPABILITY_ANALYSIS_v1.md` - Bridge API analysis
- `BRIDGE_ENTERPRISE_SOLUTIONS_RESEARCH_v1.md` - Enterprise solutions
- `TRESTLE_AND_RESO_WRITE_CAPABILITIES_RESEARCH_v1.md` - Trestle research
- `RESO_INSERT_OPPORTUNITY_ANALYSIS_v1.md` - Strategic opportunity

---

## 🎯 FRIDAY PROTOTYPE GOAL

**Target Date:** Friday, December 31, 2025 (or Monday, January 3, 2026)

**MVP Requirements:**
1. ✅ Database structure (specs complete)
2. ⏳ API endpoints (specs complete, implementation pending)
3. ⏳ UI interface (specs complete, implementation pending)
4. ⏳ XML generation (specs complete, implementation pending)
5. ⏳ GenieCloud integration (contract exists)

**Status:** All specifications complete. Ready for implementation.

---

## 📁 FILES CREATED

### Specifications
- `PLS_UI_SPECIFICATION_v1.md` - Complete UI blueprint (eRealtor format)
- `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md` - Ready-to-execute SQL scripts
- `PLS_XML_GENERATION_SPEC_v1.md` - XML mapping & code
- `PLS_FRIDAY_PROTOTYPE_ROADMAP_v1.md` - Implementation plan

### Project Planning
- `PLS_PROJECT_STATUS_AND_NEXT_STEPS_v1.md` - Status update
- `PLS_PROJECT_ACTION_PLAN_v1.md` - Action plan
- `PLS_PROJECT_COMPREHENSIVE_PLAN_v1.md` - Comprehensive plan

### Sandbox Setup
- `SANDBOX_TOPOLOGY_ANALYSIS_v1.md` - Sandbox topology analysis
- `SANDBOX_DATABASE_SETUP_v1.md` - Local SQL sandbox setup guide

---

## 🔧 TECHNICAL DECISIONS

### Database Design
- **Decision:** Use existing `MlsListing.dbo.Listing` table with `MlsId=999`
- **Rationale:** Leverages existing infrastructure, no new tables needed
- **Trade-off:** PLS listings mixed with MLS listings (distinguished by MlsId)

### PLS Number Generation
- **Format:** `PLS-YYYY-NNNNN`
- **Implementation:** Stored procedure with transaction safety
- **Storage:** `PlsNumberSequence` table tracks year-based sequences

### Status Codes
- **StatusTypeID 6:** Private Listing (needs INSERT)
- **StatusTypeID 14:** Coming Soon (exists)
- **Decision:** Use existing status codes where possible

### PropertyCastTypeId
- **Value:** `4` for PLS
- **Rationale:** Integrates with existing Listing Command workflows
- **Benefit:** Reuses existing automation infrastructure

---

## 🚧 CURRENT BLOCKERS

### Sandbox Setup
- **Status:** SQL Server Express installed locally
- **Next Step:** Clone production databases to local sandbox
- **Challenge:** FarmGenie is 365 GB (needs hybrid clone strategy)

### Azure Database Access
- **Blocker:** Cannot access Azure SQL for RESO credentials
- **Impact:** Cannot test RESO API connectivity
- **Workaround:** Use Bridge API credentials (if valid) or contact Bridge MLS

---

## 📊 INTEGRATION ARCHITECTURE

### Data Flow
```
TitleGenie (Property Data)
    ↓
Paisley AI (Pre-populate Listing)
    ↓
PLS UI (Agent Review/Edit)
    ↓
Database (MlsListing.dbo.Listing, MlsId=999)
    ↓
XML Generator
    ↓
GenieCloud (Asset Rendering)
    ↓
Listing Command (Circle Prospecting)
    ↓
[Future] RESO Insert → Bridge/Trestle
```

### Key Systems
1. **TitleGenie** - Provides property research, Attom/MLS data
2. **Paisley** - AI content generation (ChatStartTypeId=3 for pre-listing)
3. **PLS** - Pre-Listing Service (Coming Soon/Private listing creation)
4. **GenieCloud** - Asset rendering engine (landing pages, social ads, brochures)
5. **Listing Command** - Circle prospecting automation
6. **Engagement Center** - Lead capture, UTM tracking, data append

---

## 🎯 NEXT STEPS

### Immediate (Friday Prototype)
1. Set up local SQL sandbox
2. Execute database scripts (tables, stored procedures, master data)
3. Build API endpoints (create, save, render)
4. Build UI interface (web forms)
5. Test XML generation
6. Test GenieCloud integration

### Short-Term (Post-Prototype)
1. Complete UI/XML team collaboration
2. Integrate with Listing Command workflow
3. Test end-to-end flow
4. Deploy to staging environment

### Long-Term (Strategic)
1. Research RESO Insert standardization
2. Contact Bridge Interactive and Trestle for write API access
3. Build RESO Insert prototype
4. Propose RESO Insert spec to RESO.org

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/30/2025 | Initial memory log created |

---

**Location:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\PLS_RESO_ENGINE\`

