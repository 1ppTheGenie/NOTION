# PLS Project - SCRUM/SPRINT Model Guide
**Version:** 1.0  
**Created:** 01/13/2026 9:00 PM  
**Last Updated:** 01/13/2026 9:00 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ Active

---

## 🎯 PURPOSE

This document explains the SCRUM/SPRINT model for the PLS Pre-Listing Command project. We use iterative sprints, not linear phases.

---

## 🔄 SPRINT MODEL OVERVIEW

### Key Principles
- **Iterative Development** - Each sprint delivers working functionality
- **MVP First** - Start with minimum viable product, iterate
- **Task-Based Dependencies** - Dependencies are on specific tasks, not phases
- **Sprint Goals** - Each sprint has a clear goal and deliverable
- **Continuous Integration** - Deploy and test after each sprint

### Sprint Structure
- **Duration:** 2 weeks (typical)
- **Sprint Goal:** Clear, measurable outcome
- **Sprint Tasks:** Assigned to agents based on skills
- **Sprint Review:** Demo working functionality
- **Sprint Retrospective:** Learn and improve

---

## 📋 CURRENT SPRINT

### Sprint 1: MVP Foundation
**Goal:** Basic PLS listing creation and listing with GenieCloud integration

**Sprint Tasks:**
1. **Database Specialist:** Database schema and PLS number generation (5 points)
2. **XML/Integration Specialist:** XML generation framework (8 points) - depends on Database
3. **Backend API Specialist:** MVP API endpoints (8 points) - depends on Database + XML
4. **Frontend UI Specialist:** MVP UI components (8 points) - depends on Backend API
5. **DevOps Specialist:** Sandbox deployment infrastructure (3 points) - parallel

**Total Story Points:** 32

---

## 🔄 SPRINT WORKFLOW

### Sprint Planning
1. **Define Sprint Goal** - What will we deliver?
2. **Break Down Tasks** - What tasks are needed?
3. **Assign to Agents** - Who does what?
4. **Identify Dependencies** - What blocks what?
5. **Estimate Story Points** - How big is each task?

### During Sprint
1. **Daily Standups** - What did you do? What will you do? Any blockers?
2. **Task Execution** - Agents work on assigned tasks
3. **Continuous Integration** - Deploy to Sandbox as tasks complete
4. **Communication** - Use JSON messages for coordination

### Sprint Review
1. **Demo Working Functionality** - Show what was built
2. **Verify Sprint Goal** - Did we achieve the goal?
3. **Document Learnings** - What worked? What didn't?

### Sprint Retrospective
1. **What Went Well?** - Celebrate successes
2. **What Could Improve?** - Identify improvements
3. **Action Items** - What will we change next sprint?

---

## 👥 AGENT ROLES IN SPRINTS

### Database Specialist
- **Sprint Focus:** Database tasks for current sprint
- **Dependencies:** Usually none (starts sprints)
- **Handoffs:** Backend API, XML/Integration, DevOps

### Backend API Specialist
- **Sprint Focus:** API endpoints for current sprint
- **Dependencies:** Database tasks, XML framework (if needed)
- **Handoffs:** Frontend UI, XML/Integration

### Frontend UI Specialist
- **Sprint Focus:** UI components for current sprint
- **Dependencies:** Backend API tasks
- **Handoffs:** DevOps

### XML/Integration Specialist
- **Sprint Focus:** XML/GenieCloud integration for current sprint
- **Dependencies:** Database tasks (for data structure)
- **Handoffs:** Backend API (for /render endpoint), DevOps

### DevOps/Deployment Specialist
- **Sprint Focus:** Deployment infrastructure for all sprints
- **Dependencies:** None (supports all agents)
- **Handoffs:** None (deploys for all)

---

## 📊 TASK DEPENDENCIES (Not Phase Dependencies)

### Example: Sprint 1 Tasks
```
Database Schema (pls-database)
    ↓
XML Framework (pls-xml-integration) ──┐
    ↓                                   │
Backend API (pls-backend-api) ←────────┘
    ↓
Frontend UI (pls-frontend-ui)
    ↓
Deployment (pls-devops)

DevOps Infrastructure (pls-devops) - Parallel (no dependencies)
```

**Key Point:** Dependencies are on **specific tasks**, not phases. In Sprint 2, tasks might be different.

---

## 🔄 SPRINT ITERATION MODEL

### Sprint 1: MVP Foundation
- Database schema
- Basic API (create, get, list)
- Basic UI (list, create)
- XML generation
- GenieCloud integration

### Sprint 2: Enhanced Features
- Edit functionality
- Photo upload
- AI description generation
- Enhanced UI

### Sprint 3: Advanced Features
- Area selection
- Paisley integration
- Advanced filtering
- Performance optimization

**Each Sprint:** Builds on previous, adds new functionality

---

## 📝 SPRINT-BASED STATUS TRACKING

### Status File Format
```markdown
# Agent Status: [ROLE NAME]
**Current Sprint:** Sprint 1 - MVP Foundation
**Sprint Goal:** [Goal]
**My Sprint Tasks:**
- [ ] Task 1 (5 points)
- [ ] Task 2 (3 points)
- [x] Task 3 (8 points) - Complete

**Blockers:** None
**Next Sprint:** Sprint 2 planning
```

---

## 🚨 KEY DIFFERENCES FROM PHASE MODEL

| Phase Model | Sprint Model |
|-------------|--------------|
| Linear phases (1→2→3→4) | Iterative sprints (Sprint 1, Sprint 2, etc.) |
| Phase dependencies | Task dependencies |
| Complete phase before next | Deliver working functionality each sprint |
| Long-term planning | Short-term (2-week) cycles |
| Phase gates | Sprint reviews |

---

## ✅ BENEFITS OF SPRINT MODEL

1. **Faster Feedback** - Working functionality every 2 weeks
2. **Flexibility** - Adjust priorities between sprints
3. **Risk Reduction** - Identify issues early
4. **Continuous Delivery** - Deploy incrementally
5. **Team Alignment** - Clear sprint goals

---

## 📋 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/13/2026 9:00 PM | Initial sprint model guide created - replaced phase-based model with SCRUM/SPRINT model |

---

**Status:** ✅ Active

**Location:** `AgentCollaboration/SPRINT_MODEL_GUIDE_v1.md`
