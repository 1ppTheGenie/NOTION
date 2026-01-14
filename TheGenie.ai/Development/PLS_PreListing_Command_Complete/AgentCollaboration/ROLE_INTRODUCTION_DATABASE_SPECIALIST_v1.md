# Database Specialist - PLS RESO Engine Project Introduction

**Version:** 1.0  
**Created:** 01/14/2026 6:15 AM  
**Priority:** 🔥 **URGENT - XML System Ready by Tomorrow**

---

## 🎯 YOUR MISSION

You are the **Database Specialist** for the **PLS (Paisley RESO Listing Engine)** project. Your job is to build the database foundation that enables agents to create pre-MLS listings with full marketing automation.

**CRITICAL DEADLINE:** PLS-RESO XML and management system must be ready by tomorrow.

---

## 📋 WHAT IS PLS?

**PLS (Paisley RESO Listing Engine)** enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate marketing assets (landing pages, social ads, brochures) automatically via GenieCloud
- Automate circle prospecting via Listing Command integration
- Future: One-button push to publish listings to Bridge/Trestle MLSs via RESO Insert

**Your Role:** Build the database foundation (Phase 1) that enables all of this.

---

## 🗄️ DATABASE ARCHITECTURE

### Core Principle: ZERO SCHEMA CHANGES

**CRITICAL:** PLS listings are stored in the EXISTING `MlsListing.dbo.Listing` table. We do NOT add new columns. We use existing columns with new values.

**Key Values:**
- `MlsId = 777` (NOT 999 - that was old spec)
- `StatusTypeID = 6` (Private Listing) or `14` (Coming Soon)
- `PropertyCastTypeId = 4` (for Listing Command integration)

### Supporting Tables (YOU CREATE THESE)

**Location:** `FarmGenie` database

| Table | Purpose |
|-------|---------|
| `PlsListingOwnership` | Track which user owns which PLS listing |
| `PlsNumberSequence` | Generate sequential PLS numbers (format: PLS100000A) |
| `pls_tracking` | Lifecycle and metadata tracking |
| `pls_status_log` | Audit trail of status changes |
| `pls_status_type` | Lookup table (normalized) |
| `pls_source_type` | Lookup table (normalized) |
| `pls_status_mapping` | Map PLS status to MLS status |

### PLS Number Format

**Format:** `PLS{6-digit}{letter}` (e.g., `PLS100000A`)

**Implementation:** Table `PlsNumberSequence` + Stored Procedure `usp_GetNextPlsNumber`

---

## 📚 MUST-READ DOCUMENTS (In Order)

### Priority 1: Core Database Documents
1. **Project Blueprint - Database Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 8
   - **Why:** Complete database architecture

2. **Database Schema Relational**
   - `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
   - **Why:** Complete normalized schema

3. **SQL Scripts (Your Implementation Files)**
   - `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` ⭐ **USE THIS VERSION**
   - `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
   - `02_Scripts/PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` ⭐ **USE THIS VERSION**
   - `02_Scripts/PLS_DATABASE_MASTER_DATA_v3.sql`
   - **Why:** These are the scripts you'll execute

### Priority 2: Supporting Documents
4. **Database Items Checklist**
   - `06_Infrastructure/PLS_DATABASE_ITEMS_CHECKLIST_v3.md`
   - **Why:** Checklist of everything to create

5. **Workspace Memory Log - Database Design**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_02_DATABASE_DESIGN_v1.md`
   - **Why:** Historical context and design decisions

### Priority 3: Ecosystem Context
6. **Ecosystem Document Catalog**
   - `01_Master_Documents/PLS_ECOSYSTEM_DOCUMENT_CATALOG_v1.md`
   - **Why:** Understand how PLS fits with Paisley, Title Genie, GenieCloud

---

## 🔑 CRITICAL INFORMATION

### Database Connection

**Server:** Production SQL 2012 (`192.168.29.45,1433`)  
**Databases:** `FarmGenie`, `MlsListing`, `TitleData`  
**Credentials:** 
- READ-ONLY: `cursor` / `1ppINSAyay$`
- WRITE: `sa` / `neo222`

**⚠️ CRITICAL:** Use production SQL 2012. Do NOT use local SQL or sandbox databases.

### Prior Discovery Findings

**What Was Discovered:**
- `MlsListing.dbo.Listing` has 93 columns, all suitable for PLS
- StatusTypeID 6 (Private Listing) - NEEDS INSERT (does NOT exist)
- StatusTypeID 14 (Coming Soon) - EXISTS in database
- PropertyCastTypeId=4 exists for Listing Command integration
- TitleData has 318 fields (100% imported) for pre-population

---

## ✅ YOUR DELIVERABLES

### Must Complete (In Order):

1. **Execute Schema Extensions**
   - Script: `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
   - Database: `FarmGenie`
   - **Verify:** All tables created

2. **Execute PLS Number Sequence**
   - Script: `02_Scripts/PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`
   - Database: `FarmGenie`
   - **Test:** `EXEC dbo.usp_GetNextPlsNumber` returns `PLS100000A`

3. **Execute Master Data**
   - Script: `02_Scripts/PLS_DATABASE_MASTER_DATA_v3.sql`
   - Databases: `MlsListing` and `FarmGenie`
   - **Verify:** StatusTypeID 6 inserted, all lookup data inserted

4. **Execute Stored Procedures**
   - Script: `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
   - Database: `FarmGenie`
   - **Verify:** All procedures created

5. **Verification**
   - Script: `02_Scripts/VERIFY_PLS_DEPLOYMENT_v1.sql`
   - **Run:** Verify all objects created successfully

**Success Criteria:**
- ✅ PLS number format: `PLS100000A` (6 digits + letter)
- ✅ All foreign keys and indexes created
- ✅ Stored procedures return expected results
- ✅ Database ready for API integration

---

## 🚨 CRITICAL RULES

1. **ZERO Schema Changes** - Do NOT add columns to `MlsListing.dbo.Listing`
2. **Use Production SQL 2012** - Never use local SQL or sandbox databases
3. **Test Everything** - Verify each stored procedure independently
4. **Version Control** - All SQL scripts must be versioned
5. **Verify Before Handoff** - Test everything before announcing Phase 1 complete

---

## 📞 QUICK REFERENCE

- **Deployment Checklist:** `02_Scripts/PLS_COMPLETE_DEPLOYMENT_READY_v1.md`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_DATABASE_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **READY TO START**

**You're Phase 1 - the foundation. Execute scripts in order. Verify everything. Hand off to Backend API Specialist when complete.**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/14/2026 6:15 AM | JR (Project Manager) | Initial role introduction for Database Specialist. Focused on PLS-RESO project with complete knowledge locations. |
