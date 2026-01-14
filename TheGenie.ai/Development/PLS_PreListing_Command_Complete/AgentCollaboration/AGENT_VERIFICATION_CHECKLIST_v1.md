# PLS Project - Agent Verification Checklist
**Version:** 1.0  
**Created:** 01/13/2026 8:50 PM  
**Last Updated:** 01/13/2026 8:50 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ Active

---

## 🎯 PURPOSE

Use this checklist to verify that all 5 PLS project agents are created correctly in Cursor.

---

## ✅ VERIFICATION CHECKLIST

### Agent 1: Database Specialist
- [ ] **Agent exists in Cursor sidebar** - Name: "Database Specialist" or "Database Specialist Agent"
- [ ] **Description matches** - Should mention "DATABASE SPECIALIST" and "SQL Server schema, stored procedures"
- [ ] **Workspace set correctly** - `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete`
- [ ] **Phase:** 1 (Foundation)
- [ ] **Dependencies:** None (should start immediately)
- [ ] **Reference:** `AgentInstructions/pls-database_SETUP_INSTRUCTIONS.md`

**Expected Key Tasks:**
- Execute PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql in Sandbox
- Create PLS number sequence table
- Implement usp_GetNextPlsNumber
- Test PLS number generation (format: PLS100000A)

---

### Agent 2: Backend API Specialist
- [ ] **Agent exists in Cursor sidebar** - Name: "Backend API Specialist" or "Backend API Specialist Agent"
- [ ] **Description matches** - Should mention "BACKEND API SPECIALIST" and "C# controllers, REST API endpoints"
- [ ] **Workspace set correctly** - `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete`
- [ ] **Phase:** 2 (Backend API)
- [ ] **Dependencies:** Database Specialist (should wait for Phase 1)
- [ ] **Reference:** `AgentInstructions/pls-backend-api_SETUP_INSTRUCTIONS.md`

**Expected Key Tasks:**
- Implement PlsController.cs with all 9 endpoints
- Implement DataController.PLS.cs partial class
- Create PlsService business logic layer
- Add data validation and error handling

---

### Agent 3: Frontend UI Specialist
- [ ] **Agent exists in Cursor sidebar** - Name: "Frontend UI Specialist" or "Frontend UI Specialist Agent"
- [ ] **Description matches** - Should mention "FRONTEND UI SPECIALIST" and "Angular components, user interface"
- [ ] **Workspace set correctly** - `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete`
- [ ] **Phase:** 3 (Frontend UI)
- [ ] **Dependencies:** Backend API Specialist (should wait for Phase 2)
- [ ] **Reference:** `AgentInstructions/pls-frontend-ui_SETUP_INSTRUCTIONS.md`

**Expected Key Tasks:**
- Implement PlsMyListingsComponent
- Implement PlsCreateComponent
- Integrate Mapbox address lookup
- Mobile-responsive design

---

### Agent 4: XML/Integration Specialist
- [ ] **Agent exists in Cursor sidebar** - Name: "XML/Integration Specialist" or "XML/Integration Specialist Agent"
- [ ] **Description matches** - Should mention "XML/INTEGRATION SPECIALIST" and "GenieCloud XML generation"
- [ ] **Workspace set correctly** - `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete`
- [ ] **Phase:** 1.5 (XML Framework - needed before Phase 2)
- [ ] **Dependencies:** Database Specialist (needs PLS data structure)
- [ ] **Reference:** `AgentInstructions/pls-xml-integration_SETUP_INSTRUCTIONS.md`

**Expected Key Tasks:**
- Implement XML generation from PLS listing data
- Follow CONTRACT_PLS_to_GenieCloud_v6.1.md exactly
- Implement GenieCloud API integration
- Test marketing asset generation

**CRITICAL:** This agent should coordinate with Backend API Specialist on `/render` endpoint.

---

### Agent 5: DevOps/Deployment Specialist
- [ ] **Agent exists in Cursor sidebar** - Name: "DevOps/Deployment Specialist" or "DevOps/Deployment Specialist Agent"
- [ ] **Description matches** - Should mention "DEVOPS/DEPLOYMENT SPECIALIST" and "deployment automation, configuration management"
- [ ] **Workspace set correctly** - `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete`
- [ ] **Phase:** All Phases (Supporting)
- [ ] **Dependencies:** None (supports all phases)
- [ ] **Reference:** `AgentInstructions/pls-devops_SETUP_INSTRUCTIONS.md`

**Expected Key Tasks:**
- Create deployment scripts (PowerShell/Python)
- Set up test environments (Sandbox, Stage)
- Create backup and rollback procedures
- **CRITICAL:** Include DLL.config in all backups

---

## 🔍 HOW TO VERIFY IN CURSOR

### Step 1: Check Agents Sidebar
1. Open Cursor
2. Look for "Agents" sidebar (usually on left side)
3. Verify all 5 agents are listed

### Step 2: Verify Each Agent
For each agent:
1. Click on the agent in sidebar
2. Check the description matches the instruction file
3. Verify workspace path is correct
4. Check that dependencies are understood

### Step 3: Test Agent Context
1. Select an agent
2. Ask: "What is your role and what phase are you in?"
3. Agent should respond with correct role and phase information

---

## 📋 COMMON ISSUES TO CHECK

### Issue 1: Missing Agents
**Symptom:** Less than 5 agents in sidebar  
**Solution:** Create missing agents using instruction files in `AgentInstructions/`

### Issue 2: Wrong Description
**Symptom:** Agent description doesn't match instruction file  
**Solution:** Update agent description by copying from `AgentInstructions/[agent-id]_SETUP_INSTRUCTIONS.md`

### Issue 3: Wrong Workspace
**Symptom:** Agent working in wrong directory  
**Solution:** Verify workspace path: `D:\Cursor\TheGenie.ai\Development\PLS_PreListing_Command_Complete`

### Issue 4: Missing Dependencies
**Symptom:** Agent starts work before dependencies are ready  
**Solution:** Verify agent understands dependencies from instruction file

---

## ✅ VERIFICATION RESULTS

**Date Verified:** _______________  
**Verified By:** _______________

| Agent | Exists | Description | Workspace | Dependencies | Status |
|-------|--------|-------------|-----------|--------------|--------|
| Database Specialist | [ ] | [ ] | [ ] | [ ] | ⏳ / ✅ |
| Backend API Specialist | [ ] | [ ] | [ ] | [ ] | ⏳ / ✅ |
| Frontend UI Specialist | [ ] | [ ] | [ ] | [ ] | ⏳ / ✅ |
| XML/Integration Specialist | [ ] | [ ] | [ ] | [ ] | ⏳ / ✅ |
| DevOps/Deployment Specialist | [ ] | [ ] | [ ] | [ ] | ⏳ / ✅ |

**Overall Status:** ⏳ Needs Verification / ✅ All Agents Verified

---

## 📝 NOTES

- Agents are stored in Cursor's internal system (not in workspace files)
- Each agent should have its own context space
- Agents communicate via JSON messages in `AgentCollaboration/Messages/`
- Status files are in `AgentStatus/` folder

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/13/2026 8:50 PM | Initial verification checklist created |

---

**Status:** ✅ Ready for Verification

**Location:** `AgentCollaboration/AGENT_VERIFICATION_CHECKLIST_v1.md`
