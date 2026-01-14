# PLS Project - Agent Coordination Master Guide
**Version:** 1.0  
**Created:** 01/13/2026  
**Last Updated:** 01/13/2026  
**Status:** ✅ Active

---

## 🎯 PURPOSE

This is the **master coordination document** for all agents working on the PLS Pre-Listing Command project. Use this as your central reference for agent collaboration.

---

## 👥 THE 5 AGENT ROLES

| Role | Primary Focus | Phase | Status |
|------|--------------|-------|--------|
| **Database Specialist** | Database schema, stored procedures | Phase 1 | ⏳ Ready |
| **Backend API Specialist** | REST API endpoints, controllers | Phase 2 | ⏳ Waiting |
| **Frontend UI Specialist** | Angular components, UI/UX | Phase 3 | ⏳ Waiting |
| **XML/Integration Specialist** | GenieCloud XML, API integration | Phase 4 | ⏳ Waiting |
| **DevOps/Deployment Specialist** | Deployment, configuration, testing | All Phases | ✅ Active |

---

## 📁 FILE STRUCTURE

### AgentCollaboration/
- `AGENT_COORDINATION_MASTER_v1.md` - **This file** - Master coordination guide
- `AGENT_SETUP_GUIDE_v1.md` - How to set up and use agents
- `AGENT_ROLE_*.md` - Individual role definitions (5 files)
- `BLOCKERS_v1.md` - Active blockers tracking
- `HANDOFFS_v1.md` - Agent handoff tracking

### AgentStatus/
- `AGENT_STATUS_ALL_v1.md` - **Master status dashboard** - Check this daily
- `AGENT_STATUS_*.md` - Individual agent status files (5 files)

### Handoffs/
- `PLS_PROJECT_ROLES_HANDOFF_v1.md` - Original project roles handoff document

---

## 🚀 QUICK START FOR NEW AGENTS

1. **Read:** `AgentCollaboration/AGENT_SETUP_GUIDE_v1.md`
2. **Read:** `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md`
3. **Read:** Your role definition in `AgentCollaboration/AGENT_ROLE_*.md`
4. **Check:** `AgentStatus/AGENT_STATUS_ALL_v1.md` for current project status
5. **Start:** Begin working on your deliverables

---

## 📊 DAILY WORKFLOW

### Every Agent Should:
1. **Morning:** Check `AgentStatus/AGENT_STATUS_ALL_v1.md`
2. **Morning:** Check `AgentCollaboration/BLOCKERS_v1.md`
3. **Morning:** Check `AgentCollaboration/HANDOFFS_v1.md`
4. **During Work:** Update your status file as you progress
5. **End of Day:** Update status and document blockers

---

## 🔄 PHASE DEPENDENCIES

```
Phase 1: Database Foundation
  └─> Database Specialist (starts here)
  └─> DevOps Specialist (supports)

Phase 2: Backend API
  └─> Backend API Specialist (depends on Phase 1)
  └─> Database Specialist (supports)
  └─> DevOps Specialist (supports)

Phase 3: Frontend UI
  └─> Frontend UI Specialist (depends on Phase 2)
  └─> Backend API Specialist (supports)
  └─> DevOps Specialist (supports)

Phase 4: XML/Integration
  └─> XML/Integration Specialist (depends on Phase 2)
  └─> Backend API Specialist (coordinates)
  └─> DevOps Specialist (supports)

Phase 5: Testing & Deployment
  └─> All Specialists (depends on Phases 1-4)
  └─> DevOps Specialist (leads)
```

---

## 🤝 COLLABORATION PROTOCOLS

### When Completing Work
1. Test your deliverable thoroughly
2. Create handoff entry in `AgentCollaboration/HANDOFFS_v1.md`
3. Update your status file
4. Update `AgentStatus/AGENT_STATUS_ALL_v1.md`

### When Blocked
1. Document blocker in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag affected agents
3. Update your status file
4. Update `AgentStatus/AGENT_STATUS_ALL_v1.md`

### When Receiving Handoff
1. Read handoff entry in `AgentCollaboration/HANDOFFS_v1.md`
2. Review deliverables
3. Test integration
4. Confirm receipt in handoff document
5. Update your status file

---

## 📋 KEY DOCUMENTS BY ROLE

### All Agents Must Read
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md`
- `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md`
- `AgentCollaboration/AGENT_SETUP_GUIDE_v1.md`

### Database Specialist
- `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
- `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
- `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`

### Backend API Specialist
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 5)
- `08_Source_Code/PlsController_Complete_v1.cs`
- `08_Source_Code/DataController_PLS_Complete_v1.cs`

### Frontend UI Specialist
- `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md`
- `09_Prototypes/PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html`
- `08_Source_Code/pls-create.component.*`

### XML/Integration Specialist
- `11_Contracts/CONTRACT_PLS_to_GenieCloud_v6.1.md` - **CRITICAL**
- `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`

### DevOps/Deployment Specialist
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 14)
- `02_Scripts/*.ps1`
- `05_Verification_Audits/PLS_TEST_READINESS_STATUS_v1.md`

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

## 📞 ESCALATION PATH

1. **Document** - Create blocker or question in appropriate file
2. **Tag** - Tag relevant agents in the document
3. **Update Status** - Update status dashboard
4. **Wait** - Allow 24 hours for response
5. **Escalate** - If critical and no response, escalate to project lead

---

## 📊 SUCCESS METRICS

### Phase 1 Success
- ✅ All database tables created
- ✅ PLS number generation working
- ✅ Stored procedures tested
- ✅ Database ready for API

### Phase 2 Success
- ✅ All API endpoints implemented
- ✅ Data validation working
- ✅ API documentation complete
- ✅ Ready for Frontend integration

### Phase 3 Success
- ✅ All components implemented
- ✅ Mobile-responsive design
- ✅ API integration working
- ✅ User experience smooth

### Phase 4 Success
- ✅ XML generation matches contract
- ✅ GenieCloud integration working
- ✅ Marketing assets generated
- ✅ Collection system functional

### Phase 5 Success
- ✅ All testing complete
- ✅ Production deployment successful
- ✅ System operational

---

## 🔗 QUICK LINKS

- **Status Dashboard:** `AgentStatus/AGENT_STATUS_ALL_v1.md`
- **Setup Guide:** `AgentCollaboration/AGENT_SETUP_GUIDE_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`
- **Project Handoff:** `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md`
- **Master Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md`

---

## ✅ CHECKLIST FOR PROJECT START

- [ ] All 5 agents assigned to roles
- [ ] All agents have read their role definitions
- [ ] All agents have read key documents
- [ ] Status files created for all agents
- [ ] Database Specialist ready to begin Phase 1
- [ ] DevOps Specialist setting up infrastructure
- [ ] Communication protocols understood
- [ ] Daily standup schedule established

---

**Status:** ✅ Ready for Agent Assignment

**Last Updated:** 01/13/2026

**Questions?** Review `AgentCollaboration/AGENT_SETUP_GUIDE_v1.md` or check role definitions.
