# Agent Onboarding: Database Specialist

**Version:** 1.0  
**Created:** 01/13/2026 11:45 PM  
**Last Updated:** 01/13/2026 11:45 PM  
**Author:** JR (Project Manager)  
**Status:** ✅ Ready for Agent Onboarding

---

## 🎯 WELCOME TO THE PLS PROJECT

You've been assigned the **Database Specialist** role for the PLS (Pre-Listing Command) RESO Engine project. This onboarding guide will get you up to speed quickly with all the context, documents, and resources you need.

---

## 📋 YOUR ROLE AT A GLANCE

**Role:** Database Specialist  
**Phase:** Phase 1 (Foundation) - **YOU START FIRST**  
**Primary Focus:** Database schema, stored procedures, data migration  
**Workspace Folders:** `02_Scripts/`, `06_Infrastructure/`

**Key Responsibility:** Execute the normalized database schema v3.0 and create all supporting infrastructure so the Backend API Specialist can begin Phase 2.

---

## 🚀 QUICK START (30 Minutes)

### Step 1: Read Your Role Definition (5 min)
- **File:** `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md`
- **Purpose:** Understand your exact responsibilities and deliverables

### Step 2: Read Master Blueprint Section 8 (15 min)
- **File:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.1.md` - Section 8: Database Design
- **Purpose:** Understand the complete database architecture

### Step 3: Review Database Schema Document (10 min)
- **File:** `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
- **Purpose:** See the complete normalized schema design

---

## 📚 MUST-READ DOCUMENTS (In Order)

### Priority 1: Core Database Documents (Read First)

1. **Your Role Definition**
   - `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md`
   - **Why:** Your exact responsibilities and deliverables

2. **Project Blueprint - Database Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.1.md` - Section 8
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

### Priority 2: Supporting Documents (Read Before Starting Work)

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
    - `Paisley/PAISLEY_PRELISTING_DATA_CATALOG_v2.md`
    - **Why:** See what data is available for PLS (500+ fields)

---

## 🎯 YOUR DELIVERABLES

### Phase 1: Database Foundation (Your Phase)

**Must Complete:**
- [ ] Execute `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` on production SQL 2012
- [ ] Execute `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` on production SQL 2012
- [ ] Execute `PLS_DATABASE_MASTER_DATA_v3.sql` on MlsListing and FarmGenie databases
- [ ] Execute `PLS_STORED_PROCEDURES_COMPLETE_v1.sql` on FarmGenie database
- [ ] Verify all tables, indexes, and constraints created
- [ ] Test PLS number generation (`usp_GetNextPlsNumber`)
- [ ] Verify master data inserted correctly
- [ ] Update `AgentStatus/AGENT_STATUS_DATABASE_v1.md` with completion status
- [ ] Announce Phase 1 complete in `AgentCollaboration/HANDOFFS_v1.md`

**Success Criteria:**
- ✅ PLS number format: `PLS100000A` (6 digits + letter)
- ✅ All foreign keys and indexes created
- ✅ Stored procedures return expected results
- ✅ Database ready for API integration

---

## 🔑 CRITICAL INFORMATION

### Database Connection (CRITICAL - READ THIS)

**✅ CORRECT APPROACH:**
- **Server:** Production SQL 2012 (`192.168.29.45,1433`)
- **Databases:** `FarmGenie`, `MlsListing`, `TitleData` (production databases)
- **NOT:** Local SQL, NOT Sandbox databases

**Connection Strings:**
```xml
<connectionStrings>
  <add name="FarmGenieConnection" 
       connectionString="Server=192.168.29.45,1433;Database=FarmGenie;User Id=cursor;Password=1ppINSAyay$;..." />
  <add name="MlsListingConnection" 
       connectionString="Server=192.168.29.45,1433;Database=MlsListing;User Id=cursor;Password=1ppINSAyay$;..." />
  <add name="TitleDataConnection" 
       connectionString="Server=192.168.29.45,1433;Database=TitleData;User Id=cursor;Password=1ppINSAyay$;..." />
</connectionStrings>
```

**⚠️ IMPORTANT:**
- Use **READ-ONLY credentials** (`cursor` / `1ppINSAyay$`) for queries
- Use **SA credentials** (`sa` / `neo222`) only when INSERT/UPDATE/DELETE needed
- All database scripts execute on **production SQL 2012 server**

**❌ DO NOT USE:**
- `Database=FarmGenie_Sandbox` - Sandbox database doesn't exist
- `Database=MlsListing_Sandbox` - Sandbox database doesn't exist
- Local SQL Server - Not configured or doesn't exist

### PLS Number Format

**Format:** `PLS{6-digit}{letter}` (e.g., `PLS100000A`)

**Implementation:**
- Table: `FarmGenie.dbo.PlsNumberSequence`
- Stored Procedure: `usp_GetNextPlsNumber`
- Script: `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`

### Database Strategy

**Zero Schema Changes to MlsListing:**
- PLS listings stored in existing `MlsListing.dbo.Listing` table
- Uses `MlsId=777` (NOT 999 - that was old)
- Uses existing columns - NO new columns added
- New StatusTypeID values: 6=Private, 14=Coming Soon

**Supporting Tables (Minimal):**
- `FarmGenie.dbo.PlsListingOwnership` - Ownership tracking
- `FarmGenie.dbo.PlsNumberSequence` - Number generation
- `FarmGenie.dbo.pls_tracking` - Lifecycle/metadata tracking
- `FarmGenie.dbo.pls_status_log` - Audit trail
- `FarmGenie.dbo.pls_status_type` - Lookup (normalized)
- `FarmGenie.dbo.pls_source_type` - Lookup (normalized)
- `FarmGenie.dbo.pls_status_mapping` - Status → MLS mapping

---

## 🤝 COLLABORATION

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

## 📝 DAILY WORKFLOW

### Morning (5 minutes)
1. Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for project status
2. Check `AgentCollaboration/BLOCKERS_v1.md` for blockers
3. Review your status file

### During Work
1. Execute tasks from deliverables checklist
2. Test each stored procedure independently
3. Document any issues or questions

### End of Day (5 minutes)
1. Update `AgentStatus/AGENT_STATUS_DATABASE_v1.md` with progress
2. Document any blockers in `AgentCollaboration/BLOCKERS_v1.md`
3. Update deliverables checklist

---

## 🚨 CRITICAL RULES

1. **Sandbox First** - All work in Sandbox before Stage/Production
2. **Test Everything** - Verify each stored procedure independently
3. **Document Changes** - Update schema docs with any modifications
4. **Version Control** - All SQL scripts must be versioned
5. **Use Production SQL 2012** - Never use local SQL or sandbox databases
6. **Verify Before Handoff** - Test everything before announcing Phase 1 complete

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

## ✅ ONBOARDING CHECKLIST

Before you start work, verify you've completed:

- [ ] Read your role definition (`AGENT_ROLE_DATABASE_SPECIALIST_v1.md`)
- [ ] Read Project Blueprint Section 8 (Database Design)
- [ ] Read Database Schema Relational document
- [ ] Reviewed all SQL scripts you'll execute
- [ ] Understood database connection requirements (production SQL 2012)
- [ ] Understood PLS number format (`PLS100000A`)
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

## 📚 REFERENCE QUICK LINKS

- **Your Role:** `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md`
- **Project Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.1.md`
- **Database Schema:** `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
- **SQL Scripts:** `02_Scripts/`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_DATABASE_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **READY FOR ONBOARDING**

**Welcome to the team! You're starting Phase 1 - the foundation of the entire project. Let's build this right!**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/13/2026 11:45 PM | JR (Project Manager) | Initial Database Specialist onboarding document. Comprehensive guide with must-read documents, deliverables, critical information, collaboration points, and daily workflow. |
