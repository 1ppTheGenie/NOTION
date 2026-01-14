# PLS Project - Agent Setup Guide
**Version:** 1.0  
**Created:** 01/13/2026  
**Last Updated:** 01/13/2026  
**Status:** ✅ Ready for Use

---

## 🎯 PURPOSE

This guide explains how to set up and use the agent collaboration system for the PLS Pre-Listing Command project. **Note:** Cursor does not have built-in agent configuration, so we use a file-based collaboration system.

---

## 🤖 HOW AGENTS WORK IN THIS WORKSPACE

### Understanding "Agents"

In this context, "agents" are **specialized AI assistant sessions** or **human developers** working on specific roles. Each agent:

1. **Has a specific role** (Database, Backend API, Frontend UI, XML/Integration, DevOps)
2. **Follows a role definition** in `AgentCollaboration/AGENT_ROLE_*.md`
3. **Tracks status** in `AgentStatus/AGENT_STATUS_*.md`
4. **Coordinates** through handoff documents and blockers

### Agent Assignment Options

#### Option 1: Manual Agent Assignment (Recommended)
**For Human Developers:**
- Assign each developer to a specific role
- Each developer reads their role definition file
- Developers update status files manually
- Use handoff documents for coordination

#### Option 2: AI Assistant Sessions
**For AI Assistants (Cursor):**
- Open separate Cursor sessions for each role
- In each session, load the workspace and read the role definition
- Use the role definition as context for that session
- Update status files after completing work

#### Option 3: Hybrid Approach
- Human developers for complex tasks
- AI assistants for documentation, testing, code review
- All use the same collaboration system

---

## 📋 SETUP STEPS

### Step 1: Choose Your Role

Review the 5 roles in `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md`:
1. Database Specialist
2. Backend API Specialist
3. Frontend UI Specialist
4. XML/Integration Specialist
5. DevOps/Deployment Specialist

### Step 2: Read Your Role Definition

Read your specific role file:
- `AgentCollaboration/AGENT_ROLE_DATABASE_SPECIALIST_v1.md`
- `AgentCollaboration/AGENT_ROLE_BACKEND_API_SPECIALIST_v1.md`
- `AgentCollaboration/AGENT_ROLE_FRONTEND_UI_SPECIALIST_v1.md`
- `AgentCollaboration/AGENT_ROLE_XML_INTEGRATION_SPECIALIST_v1.md`
- `AgentCollaboration/AGENT_ROLE_DEVOPS_SPECIALIST_v1.md`

### Step 3: Read Key Documents

Each role has a "Key Documents to Reference" section. Read those first.

### Step 4: Check Dependencies

Check `AgentStatus/AGENT_STATUS_ALL_v1.md` to see:
- What phase you're in
- If you're blocked by dependencies
- What other agents are working on

### Step 5: Start Working

Follow your role's daily workflow and update status files as you progress.

---

## 📁 COLLABORATION FILES STRUCTURE

```
AgentCollaboration/
├── AGENT_ROLE_*.md          # Role definitions (5 files)
├── AGENT_SETUP_GUIDE_v1.md  # This file
├── BLOCKERS_v1.md           # Active blockers
├── HANDOFFS_v1.md           # Agent handoffs
└── DEPLOYMENTS_v1.md        # Deployment tracking (future)

AgentStatus/
├── AGENT_STATUS_ALL_v1.md   # Master status dashboard
├── AGENT_STATUS_DATABASE_v1.md
├── AGENT_STATUS_BACKEND_API_v1.md
├── AGENT_STATUS_FRONTEND_UI_v1.md
├── AGENT_STATUS_XML_INTEGRATION_v1.md
└── AGENT_STATUS_DEVOPS_v1.md
```

---

## 🔄 DAILY WORKFLOW

### Morning Routine
1. Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for project status
2. Check `AgentCollaboration/BLOCKERS_v1.md` for new blockers
3. Check `AgentCollaboration/HANDOFFS_v1.md` for new handoffs
4. Review your role's status file

### During Work
1. Follow your role's responsibilities
2. Update your status file as you make progress
3. Document blockers immediately if you hit one
4. Create handoff entries when completing deliverables

### End of Day
1. Update your status file with progress
2. Update `AgentStatus/AGENT_STATUS_ALL_v1.md` if major milestones
3. Document any blockers or questions

---

## 📝 STATUS FILE TEMPLATE

Each agent should maintain their own status file. Here's the template:

```markdown
# Agent Status: [ROLE NAME]
**Last Updated:** MM/DD/YYYY  
**Current Phase:** [Phase Number]  
**Progress:** X%

## Current Tasks
- [ ] Task 1
- [ ] Task 2
- [x] Task 3 (completed)

## Blockers
- None / [List blockers]

## Next Steps
1. Next action item
2. Another action item

## Notes
[Any relevant notes]
```

---

## 🤝 COLLABORATION PROTOCOLS

### When You Complete Work
1. Test your deliverable
2. Create handoff entry in `AgentCollaboration/HANDOFFS_v1.md`
3. Update your status file
4. Update `AgentStatus/AGENT_STATUS_ALL_v1.md`

### When You're Blocked
1. Document blocker in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag affected agents
3. Update your status file
4. Update `AgentStatus/AGENT_STATUS_ALL_v1.md`

### When You Need Information
1. Check relevant role definition files
2. Check handoff documents
3. Check status files
4. If still unclear, document as blocker with question

---

## 🚨 CRITICAL RULES

1. **Never Overwrite Files** - Always version files (v1 → v2 → v3)
2. **Update Status Daily** - Keep status files current
3. **Document Blockers Immediately** - Don't wait
4. **Test Before Handoff** - Verify your work before handing off
5. **Follow Role Definitions** - Stay within your role's scope

---

## 📞 QUICK REFERENCE

- **Project Handoff:** `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md`
- **Quick Start:** `QUICK_START_GUIDE_v1.md`
- **Master Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md`
- **Status Dashboard:** `AgentStatus/AGENT_STATUS_ALL_v1.md`

---

## ✅ CHECKLIST FOR NEW AGENTS

- [ ] Read `Handoffs/PLS_PROJECT_ROLES_HANDOFF_v1.md`
- [ ] Read your role definition file
- [ ] Read key documents listed in your role definition
- [ ] Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for current status
- [ ] Create your status file (if it doesn't exist)
- [ ] Review collaboration protocols above
- [ ] Start working on your deliverables

---

**Status:** ✅ Ready for Agent Assignment

**Questions?** Review the role definitions or check the master blueprint.
