# PLS Project - Role Clarification & Revision
**Version:** 1.0  
**Created:** 01/13/2026 7:45 PM  
**Last Updated:** 01/13/2026 7:45 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ Discussion Document

---

## 🎯 YOUR QUESTIONS

1. **Database vs Backend API - What's the difference?**
2. **Should Frontend UI handle GenieCloud contract?**
3. **XML/Integration timing - Should be Phase 1.5, not Phase 4?**
4. **Are we creating too many roles?**

---

## 📊 CURRENT ROLE SEPARATION

### Database Specialist vs Backend API Specialist

**Database Specialist:**
- SQL Server schema design
- Stored procedures (`usp_GetNextPlsNumber`)
- Database tables, indexes, constraints
- Data migration scripts
- **Skillset:** SQL, T-SQL, Database Administration

**Backend API Specialist:**
- C# controllers (`PlsController.cs`)
- REST API endpoints (`POST /api/pls/create`)
- Business logic (validation, error handling)
- Integration with stored procedures
- **Skillset:** C#, .NET, REST APIs, Business Logic

**Your Point:** These could potentially be combined into one "Backend Specialist" role.

---

## 🔄 XML/INTEGRATION TIMING ISSUE

**You're RIGHT!** Looking at the blueprint:

The `/api/pls/{listingNumber}/render` endpoint (Section 5) needs to:
1. Load listing data
2. **Build XML (PlsService.BuildXml)** ← This is XML generation
3. Validate XML against contract
4. POST to GenieCloud

**Current Problem:** XML/Integration Specialist is Phase 4, but XML generation is needed in Phase 2 (Backend API).

**Your Solution:** XML should be Phase 1.5 or integrated into Phase 2.

---

## 🎨 FRONTEND UI AND GENIECLOUD

**Current Understanding:**
- Frontend UI: Angular components, user interface
- GenieCloud: Backend API calls GenieCloud (via `/render` endpoint)
- Frontend just calls `POST /api/pls/{listingNumber}/render` - doesn't directly handle GenieCloud

**Your Question:** Should Frontend handle the GenieCloud contract?

**Answer:** No - Frontend calls the API, Backend API handles GenieCloud integration.

---

## 💡 PROPOSED REVISIONS

### Option 1: Combine Database + Backend API
**New Role:** "Backend Specialist" (Database + API)
- Handles both SQL and C# work
- One person/agent for all backend work

### Option 2: Keep Separate, Better Explain
**Keep:** Database Specialist and Backend API Specialist separate
**Reason:** Different skillsets (SQL vs C#), can work in parallel

### Option 3: Revise Phases
**Phase 1:** Database (unchanged)
**Phase 1.5:** XML Generation (framework for API) ← Your suggestion
**Phase 2:** Backend API (uses XML framework)
**Phase 3:** Frontend UI (unchanged)

---

## 🤔 RECOMMENDATION

Based on your feedback, I recommend:

1. **Keep Database and Backend API separate** - Different skillsets, but clarify the distinction
2. **Move XML to Phase 1.5 or integrate into Phase 2** - You're right, it's needed earlier
3. **Clarify Frontend doesn't handle GenieCloud** - Backend API does via `/render` endpoint

**Revised Phase Structure:**
- **Phase 1:** Database Foundation
- **Phase 1.5:** XML Framework (GenieCloud contract implementation)
- **Phase 2:** Backend API (uses XML framework from 1.5)
- **Phase 3:** Frontend UI
- **Phase 4:** Testing & Deployment

---

## 📝 NEXT STEPS

1. **Read the master document:** `AgentCollaboration/PLS_AGENT_COORDINATION_MASTER_v1.md`
2. **Review the blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 5)
3. **Review the contract:** `11_Contracts/CONTRACT_PLS_to_GenieCloud_v6.1.md`
4. **Decide on role structure** - Should we combine Database + Backend API?
5. **Revise phases** - Move XML to Phase 1.5 or integrate into Phase 2?

---

**Status:** ✅ Awaiting Your Decision

**Master Document Location:** `AgentCollaboration/PLS_AGENT_COORDINATION_MASTER_v1.md`
