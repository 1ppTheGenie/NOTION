# Task Manager Setup - Team Assignment

**Version:** 1.0  
**Created:** 01/14/2026 3:45 PM  
**Author:** JR (Project Manager)  
**Priority:** 🚨 **URGENT - 7 MINUTE SETUP**

---

## 🎯 MISSION

**Build custom task manager system from blueprint on LOCALHOST SQL**  
**Timeline:** 7 minutes for initial setup, then Q/A and tweaking  
**Blueprint:** `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`

---

## 👥 ASSIGNMENTS

### Database Specialist - ASSIGNED ✅

**Your Task:** Create NEW database on LOCALHOST SQL Server

**Steps:**
1. Connect to LOCALHOST SQL Server (NOT production!)
2. Create NEW database: `TaskManager` (or `TaskManager_PM`)
3. Run SQL script from blueprint lines 31-139
4. Verify tables created: Users, Projects, TaskStatuses, Tasks, TaskComments, ProjectMembers

**Time:** 3-5 minutes  
**Deliverable:** Database ready, signal "Database Ready" in HANDOFFS_v1.md

**Start Now:** Read blueprint lines 31-139, execute SQL script

---

### Backend API Specialist - ASSIGNED ✅

**Your Task:** Build .NET 8 API (wait for Database Specialist)

**Steps:**
1. Wait for "Database Ready" signal
2. Create .NET 8 Web API: `dotnet new webapi -n TaskManager.Api`
3. Add packages: EF Core, JWT
4. Configure connection to LOCALHOST TaskManager database
5. Create models, DbContext, controllers from blueprint
6. Run migrations, start API on localhost:5000

**Time:** 2-3 minutes (after database ready)  
**Deliverable:** API running, signal "API Ready" in HANDOFFS_v1.md

**Start:** After Database Specialist signals ready

---

### Frontend UI Specialist - ASSIGNED ✅

**Your Task:** Build React Kanban board (wait for Backend API Specialist)

**Steps:**
1. Wait for "API Ready" signal
2. Create React app: `npm create vite@latest task-manager-ui -- --template react-ts`
3. Install dependencies: @dnd-kit, axios, tailwindcss
4. Build KanbanBoard, TaskCard, Column components from blueprint
5. Connect to API, test drag-and-drop

**Time:** 2-3 minutes (after API ready)  
**Deliverable:** React app running on localhost:3000, signal "UI Ready" in HANDOFFS_v1.md

**Start:** After Backend API Specialist signals ready

---

## ⚡ EXECUTION ORDER

1. **Database Specialist** → Creates database → Signals "Database Ready"
2. **Backend API Specialist** → Builds API → Signals "API Ready"  
3. **Frontend UI Specialist** → Builds UI → Signals "UI Ready"

**Total Time:** ~7 minutes (sequential)

---

## ✅ SUCCESS CRITERIA

- [ ] Database: All tables created on localhost
- [ ] API: Running on localhost:5000, Swagger accessible
- [ ] UI: Running on localhost:3000, Kanban board displays
- [ ] Integration: Can create project → create tasks → move tasks

---

## 📚 REFERENCE

**Full Plan:** `AgentCollaboration/Project Management/TASK_MANAGER_SETUP_PLAN_v1.md`  
**Blueprint:** `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`

---

**Status:** 🚀 **TEAM ASSIGNED - START NOW**
