# Agent Onboarding: Database Specialist - Complete Educational Content

**Version:** 2.0  
**Created:** 01/14/2026 3:00 AM  
**Last Updated:** 01/14/2026 3:00 AM  
**Author:** JR (Project Manager)  
**Status:** ✅ **COMPREHENSIVE ONBOARDING - READY FOR AGENT**

---

## 🎯 WELCOME TO THE PLS PROJECT

You've been assigned the **Database Specialist** role for the PLS (Paisley RESO Listing Engine) project. This is a comprehensive onboarding document with ALL context, prior discovery, ecosystem knowledge, and technical specifications you need to succeed.

**Your Mission:** Build the database foundation that enables agents to create pre-MLS listings with full marketing automation.

---

## 📚 SECTION 1: PROJECT CONTEXT & VISION

### What is PLS?

**PLS (Paisley RESO Listing Engine)** is a private listing service that enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate full marketing asset kits (landing pages, social ads, brochures) automatically
- Automate circle prospecting campaigns via Listing Command integration
- Future: One-button push to publish listings directly to Bridge/Trestle MLSs via RESO Insert

### Business Value

| Value Proposition | Impact |
|------------------|--------|
| **Early Mover Advantage** | Agents market properties BEFORE they hit MLS |
| **Zero Double Entry** | Future RESO Insert eliminates manual MLS entry |
| **Time Savings** | AI pre-population reduces data entry by 80% |
| **Marketing Assets** | Automatic generation of landing pages, social ads, brochures |

### Project Status

| Phase | Status | Your Role |
|-------|--------|-----------|
| **Specifications** | ✅ Complete | Reference only |
| **Database Design** | ✅ Complete | **YOU IMPLEMENT THIS** |
| **API Design** | ✅ Complete | You enable this |
| **UI Design** | ✅ Complete | You enable this |
| **Implementation** | ⏳ Starting | **YOU START PHASE 1** |

---

## 📚 SECTION 2: ECOSYSTEM INTEGRATION CONTEXT

### The Big Picture

PLS sits at the intersection of 4 major systems:

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ TITLE GENIE  │    │   PAISLEY    │    │  ENGAGEMENT  │
│              │    │              │    │    CENTER    │
│ • Attom Data │───▶│ • AI Content │    │              │
│ • MLS Data   │    │ • Templates  │    │ • Lead Capture│
│ • Property   │    │ • ChatStart3 │    │ • Notifications│
│   Research   │    │              │    │ • Workflows   │
└──────────────┘    └──────────────┘    └──────────────┘
       │                   │                    ▲
       ▼                   ▼                    │
┌───────────────────────────────────────────────┴───────────┐
│              PAISLEY RESO LISTING ENGINE (PLS)          │
│                                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ DATA LAYER   │  │ FUNCTION     │  │ INTERFACE    │  │
│  │              │  │ LAYER        │  │ LAYER        │  │
│  │ • Database   │─▶│ • API        │─▶│ • UI         │  │
│  │ • Stored     │  │ • Business   │  │ • Forms      │  │
│  │   Procedures │  │   Logic      │  │ • Uploads    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└───────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌───────────────────────────┐
              │      GENIE CLOUD           │
              │  • XSL Templates           │
              │  • Puppeteer Renderer      │
              │  • S3 Storage              │
              └───────────────────────────┘
```

### Key Integration Points

| System | Role | Database Integration | Your Responsibility |
|--------|------|---------------------|---------------------|
| **TitleGenie** | Property data source | `TitleData.dbo.AttomDataAssessor` | Ensure data can be queried for pre-population |
| **Paisley AI** | Description generation | `ChatStartTypeId=3` (Pre-Listing Focused) | No DB changes needed |
| **GenieCloud** | Asset rendering | XML generation (API layer) | No DB changes needed |
| **Listing Command** | Circle prospecting | `PropertyCastTypeId=4` workflow | Ensure `ListingCommandQueue` can accept PLS listings |
| **MlsListing Database** | Listing storage | `MlsListing.dbo.Listing` (MlsId=777) | **CRITICAL: Use existing table, NO schema changes** |

---

## 📚 SECTION 3: DATABASE ARCHITECTURE - COMPLETE SPECIFICATIONS

### Core Design Principle: ZERO SCHEMA CHANGES

**CRITICAL RULE:** PLS listings are stored in the EXISTING `MlsListing.dbo.Listing` table. We do NOT add new columns. We use existing columns with new values.

### Database Strategy

#### 1. Main Listing Table (EXISTING - NO CHANGES)

**Table:** `MlsListing.dbo.Listing`

**Key Fields for PLS:**
- `MlsId = 777` (NOT 999 - that was old spec)
- `MlsNumber` = PLS number format: `PLS100000A`
- `StatusTypeID` = 6 (Private Listing) or 14 (Coming Soon)
- `PropertyCastTypeId = 4` (for Listing Command integration)
- All other fields use existing columns

**What You DON'T Do:**
- ❌ Add new columns
- ❌ Modify existing columns
- ❌ Change data types
- ❌ Add new indexes (unless performance requires)

**What You DO:**
- ✅ Insert PLS listings with MlsId=777
- ✅ Use StatusTypeID 6 or 14
- ✅ Ensure PropertyCastTypeId=4

#### 2. Supporting Tables (NEW - YOU CREATE THESE)

**Location:** `FarmGenie` database

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `PlsListingOwnership` | Track which user owns which PLS listing | `AspNetUserId`, `MlsNumber`, `ListingId` |
| `PlsNumberSequence` | Generate sequential PLS numbers | `Year`, `NextNumber` |
| `pls_tracking` | Lifecycle and metadata tracking | `listing_id`, `status_type_id`, `was_listed`, `mls_published` |
| `pls_status_log` | Audit trail of status changes | `listing_id`, `from_status_type_id`, `to_status_type_id`, `changed_at` |
| `pls_status_type` | Lookup table (normalized) | `id`, `name`, `display_order` |
| `pls_source_type` | Lookup table (normalized) | `id`, `name` |
| `pls_status_mapping` | Map PLS status to MLS status | `pls_status_type_id`, `mls_status_type_id` |

#### 3. Stored Procedures (NEW - YOU CREATE THESE)

| Procedure | Purpose | Returns |
|-----------|---------|---------|
| `usp_GetNextPlsNumber` | Generate next PLS number | `PLS{6-digit}{letter}` (e.g., `PLS100000A`) |
| `usp_GetPlsListingByNumber` | Get PLS listing by number | Full listing data with joins |
| `usp_GetPlsListingsByUser` | Get all PLS listings for a user | List of listings |

### PLS Number Format

**Format:** `PLS{6-digit}{letter}`

**Examples:**
- `PLS100000A` (first listing of year)
- `PLS100001B` (second listing)
- `PLS100002C` (third listing)
- After `PLS100000Z`, next is `PLS100001A` (increment number, reset letter)

**Implementation:**
- Table: `FarmGenie.dbo.PlsNumberSequence`
- Stored Procedure: `usp_GetNextPlsNumber`
- Script: `02_Scripts/PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`

---

## 📚 SECTION 4: PRIOR DISCOVERY FINDINGS

### What Was Discovered Before You

#### 1. Database Connection Discovery

**Finding:** Production SQL 2012 server at `192.168.29.45,1433`

**Credentials:**
- **READ-ONLY:** `cursor` / `1ppINSAyay$` (for queries)
- **WRITE ACCESS:** `sa` / `neo222` (for INSERT/UPDATE/DELETE)

**Databases:**
- `FarmGenie` (main app database)
- `MlsListing` (listings database)
- `TitleData` (Attom data database)

**CRITICAL:** Use production SQL 2012. Do NOT use local SQL or sandbox databases.

#### 2. Existing Table Discovery

**Finding:** `MlsListing.dbo.Listing` has 93 columns, all suitable for PLS

**Key Columns:**
- `ListingID` (PK)
- `MlsID` (FK to Mls table)
- `MlsNumber` (string)
- `StatusTypeID` (FK to StatusType table)
- `PropertyCastTypeId` (FK to PropertyCastType table)
- `ListingAgentName`, `ListingAgentID`
- `CoListingAgentName`, `CoListingAgentID`
- All property fields (Bedrooms, Bathrooms, Sqft, YearBuilt, etc.)

**StatusTypeID Values:**
- `6` = Private Listing (NEEDS INSERT - does NOT exist yet)
- `14` = Coming Soon (EXISTS in database)

**Action Required:** Insert StatusTypeID 6 if it doesn't exist.

#### 3. Listing Command Integration Discovery

**Finding:** Listing Command uses `PropertyCastTypeId=4` for PLS

**Table:** `FarmGenie.dbo.ListingCommandQueue`

**Fields:**
- `MlsID = 777`
- `MlsNumber` = PLS number
- `PropertyCastTypeId = 4`
- `AspNetUserId`
- `AreaId`

**Action Required:** Ensure PLS listings can be inserted into this queue.

#### 4. Title Genie Data Discovery

**Finding:** `TitleData.dbo.AttomDataAssessor` has 318 fields (100% imported)

**Key Fields for Pre-Population:**
- `ParcelNumberFormatted` (APN)
- `StreetNumber`, `StreetName`, `City`, `State`, `Zip`
- `BedroomsTotal`, `BathroomsTotal`, `LivingArea`, `LotSizeSquareFeet`
- `YearBuilt`, `PropertyType`, `GarageSpaces`

**Action Required:** Ensure these fields can be queried for pre-population.

---

## 📚 SECTION 5: YOUR DELIVERABLES - PHASE 1

### Must Complete (In Order)

1. **Execute Schema Extensions**
   - Script: `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
   - Creates all supporting tables in `FarmGenie` database
   - Creates indexes and foreign keys
   - **VERIFY:** All tables created, all indexes created

2. **Execute PLS Number Sequence**
   - Script: `02_Scripts/PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`
   - Creates `PlsNumberSequence` table
   - Creates `usp_GetNextPlsNumber` stored procedure
   - **VERIFY:** Procedure returns format `PLS100000A`

3. **Execute Master Data**
   - Script: `02_Scripts/PLS_DATABASE_MASTER_DATA_v3.sql`
   - Inserts lookup data into `pls_status_type`, `pls_source_type`, `pls_status_mapping`
   - Inserts StatusTypeID 6 (Private Listing) if missing
   - **VERIFY:** All lookup data inserted correctly

4. **Execute Stored Procedures**
   - Script: `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
   - Creates all stored procedures
   - **VERIFY:** All procedures created, no errors

5. **Verification Tests**
   - Test `usp_GetNextPlsNumber` returns correct format
   - Verify all foreign keys work
   - Verify all indexes created
   - Verify master data inserted

6. **Documentation**
   - Update `AgentStatus/AGENT_STATUS_DATABASE_v1.md` with completion status
   - Announce Phase 1 complete in `AgentCollaboration/HANDOFFS_v1.md`

### Success Criteria

- ✅ PLS number format: `PLS100000A` (6 digits + letter)
- ✅ All foreign keys and indexes created
- ✅ Stored procedures return expected results
- ✅ Master data inserted correctly
- ✅ Database ready for API integration
- ✅ No errors in SQL execution logs

---

## 📚 SECTION 6: CRITICAL TECHNICAL SPECIFICATIONS

### Database Connection Strings

**Production SQL 2012:**
```
Server=192.168.29.45,1433
Database=FarmGenie (or MlsListing or TitleData)
User Id=cursor (read-only) or sa (write)
Password=1ppINSAyay$ (read-only) or neo222 (write)
```

### Table Relationships

```
MlsListing.dbo.Listing (MlsId=777)
    │
    ├──► MlsListing.dbo.Photo (MlsId=777, ListingID FK)
    │
    └──► FarmGenie.dbo.PlsListingOwnership (MlsNumber FK)
            │
            ├──► FarmGenie.dbo.AspNetUsers (AspNetUserId FK)
            │
            └──► FarmGenie.dbo.pls_tracking (listing_id FK)
                    │
                    ├──► FarmGenie.dbo.pls_status_type (status_type_id FK)
                    │
                    └──► FarmGenie.dbo.pls_source_type (source_type_id FK)
```

### PLS Number Generation Logic

```sql
-- Pseudo-code for usp_GetNextPlsNumber
1. Get current year
2. SELECT NextNumber, LastUpdate FROM PlsNumberSequence WHERE Year = @Year
3. IF NOT EXISTS, INSERT new row with NextNumber=100000, LastUpdate=GETDATE()
4. Increment NextNumber
5. Calculate letter suffix: ('A' + (NextNumber % 26))
6. UPDATE PlsNumberSequence SET NextNumber=NextNumber+1
7. RETURN 'PLS' + CAST(NextNumber AS VARCHAR) + Letter
```

---

## 📚 SECTION 7: MUST-READ DOCUMENTS (In Priority Order)

### Priority 1: Core Database Documents (READ FIRST)

1. **Your Role Definition**
   - `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md`
   - **Why:** Your exact responsibilities and deliverables

2. **Project Blueprint - Database Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 8
   - **Why:** Complete database architecture and design decisions

3. **Database Schema Relational**
   - `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
   - **Why:** Complete normalized schema with all tables and relationships

4. **SQL Scripts (Your Implementation Files)**
   - `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` - **USE THIS VERSION**
   - `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
   - `02_Scripts/PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` - **USE THIS VERSION**
   - `02_Scripts/PLS_DATABASE_MASTER_DATA_v3.sql`
   - **Why:** These are the scripts you'll execute

### Priority 2: Supporting Documents (READ BEFORE STARTING WORK)

5. **Database Items Checklist**
   - `06_Infrastructure/PLS_DATABASE_ITEMS_CHECKLIST_v3.md`
   - **Why:** Checklist of everything you need to create

6. **Schema Visual Diagram**
   - `06_Infrastructure/PLS_SCHEMA_VISUAL_DIAGRAM_NORMALIZED_v3.md`
   - **Why:** Visual representation of table relationships

7. **Permissions & Roles Integration**
   - `06_Infrastructure/PLS_PERMISSION_ROLE_INTEGRATION_v1.md`
   - **Why:** Understand how permissions work with PLS

8. **Workspace Memory Log - Database Design**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_02_DATABASE_DESIGN_v1.md`
   - **Why:** Historical context and design decisions

### Priority 3: Ecosystem Context (Reference)

9. **Ecosystem Document Catalog**
   - `01_Master_Documents/PLS_ECOSYSTEM_DOCUMENT_CATALOG_v1.md`
   - **Why:** Understand how PLS fits with Paisley, Title Genie, GenieCloud

10. **Paisley Data Catalog v2** (Reference)
    - `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_PRELISTING_DATA_CATALOG_v2.md`
    - **Why:** See what data is available for PLS (500+ fields)

---

## 📚 SECTION 8: COMMON PITFALLS & SOLUTIONS

### Pitfall 1: Using Wrong MlsId

**❌ WRONG:** `MlsId = 999` (old spec)  
**✅ CORRECT:** `MlsId = 777` (current spec)

### Pitfall 2: Adding Columns to MlsListing.dbo.Listing

**❌ WRONG:** Adding new columns for PLS-specific data  
**✅ CORRECT:** Use existing columns, store PLS-specific data in supporting tables

### Pitfall 3: Using Sandbox Databases

**❌ WRONG:** Creating tables in `FarmGenie_Sandbox` or `MlsListing_Sandbox`  
**✅ CORRECT:** Use production databases: `FarmGenie`, `MlsListing`, `TitleData`

### Pitfall 4: Not Testing PLS Number Generation

**❌ WRONG:** Assuming stored procedure works without testing  
**✅ CORRECT:** Test `usp_GetNextPlsNumber` and verify format `PLS100000A`

### Pitfall 5: Missing Foreign Keys

**❌ WRONG:** Creating tables without foreign key constraints  
**✅ CORRECT:** All foreign keys must be created for data integrity

---

## 📚 SECTION 9: DAILY WORKFLOW

### Morning (5 minutes)
1. Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for project status
2. Check `AgentCollaboration/BLOCKERS_v1.md` for blockers
3. Review your status file: `AgentStatus/AGENT_STATUS_DATABASE_v1.md`

### During Work
1. Execute tasks from deliverables checklist
2. Test each stored procedure independently
3. Document any issues or questions
4. Update progress in status file

### End of Day (5 minutes)
1. Update `AgentStatus/AGENT_STATUS_DATABASE_v1.md` with progress
2. Document any blockers in `AgentCollaboration/BLOCKERS_v1.md`
3. Update deliverables checklist

---

## 📚 SECTION 10: COLLABORATION & HANDOFFS

### Dependencies
- **None** - You start Phase 1 (no dependencies)

### Handoffs TO
- **Backend API Specialist** - Provides schema documentation and stored procedure specs
- **DevOps Specialist** - Provides deployment scripts and migration procedures

### Communication
- **Daily:** Update `AgentStatus/AGENT_STATUS_DATABASE_v1.md`
- **Blockers:** Document in `AgentCollaboration/BLOCKERS_v1.md`
- **Completions:** Announce in `AgentCollaboration/HANDOFFS_v1.md`

---

## ✅ ONBOARDING CHECKLIST

Before you start work, verify you've completed:

- [ ] Read this entire onboarding document
- [ ] Read your role definition (`AGENT_ROLE_DATABASE_SPECIALIST_v1.md`)
- [ ] Read Project Blueprint Section 8 (Database Design)
- [ ] Read Database Schema Relational document
- [ ] Reviewed all SQL scripts you'll execute
- [ ] Understood database connection requirements (production SQL 2012)
- [ ] Understood PLS number format (`PLS100000A`)
- [ ] Understood ZERO schema changes principle
- [ ] Set up status tracking file
- [ ] Ready to begin Phase 1 implementation

---

## 🎯 NEXT STEPS

1. **Complete onboarding checklist above**
2. **Review SQL scripts** - Understand what each script does
3. **Connect to production SQL 2012** - Verify connection
4. **Execute scripts in order:**
   - Schema extensions
   - PLS number sequence
   - Master data
   - Stored procedures
5. **Test PLS number generation**
6. **Update status and announce Phase 1 complete**

---

## 📞 ESCALATION

**If Blocked:**
1. Document in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag Project Manager (JR) if needed
3. Update status file with blocker details

**Questions?**
- Review your role definition first
- Check workspace memory logs for historical context
- Document questions in blockers file if needed

---

## 📚 REFERENCE QUICK LINKS

- **Your Role:** `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md`
- **Project Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md`
- **Database Schema:** `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
- **SQL Scripts:** `02_Scripts/`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_DATABASE_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **COMPREHENSIVE ONBOARDING COMPLETE**

**Welcome to the team! You're starting Phase 1 - the foundation of the entire project. You have all the context and knowledge you need. Let's build this right!**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | 01/14/2026 3:00 AM | JR (Project Manager) | Comprehensive rewrite with full ecosystem context, prior discovery findings, complete technical specifications, common pitfalls, and educational content. This is the complete educational package for Database Specialist onboarding. |
| 1.0 | 01/13/2026 11:45 PM | JR (Project Manager) | Initial Database Specialist onboarding document. |
