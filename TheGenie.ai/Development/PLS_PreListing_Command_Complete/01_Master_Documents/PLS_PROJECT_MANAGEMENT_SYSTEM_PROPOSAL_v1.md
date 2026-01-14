# PLS Project Management System - Proposal

**Version:** 1.0  
**Created:** 01/14/2026 12:05 AM  
**Last Updated:** 01/14/2026 12:05 AM  
**Author:** JR (Project Manager)  
**Status:** 📋 **PROPOSAL - PENDING APPROVAL**

---

## 🎯 EXECUTIVE SUMMARY

**Goal:** Web-based project management dashboard with Gantt charts, visual task completion, and real-time status visibility (Asana-style).

**Discovery:** ✅ **Asana API already integrated into TheGenie** (`Smart.Asana.dll`, `DashboardAsanaManager.cs`)

**Recommendation:** **Leverage existing Asana integration** - Build custom PM Dashboard UI that syncs with Asana for PLS project management.

---

## 🔍 WHAT WE FOUND

### Existing Asana Integration

**Location:** `Smart.Asana.dll`, `Smart.Dashboard.BLL.Asana.DashboardAsanaManager`

**Current Capabilities:**

- ✅ Create bugs in Asana (`CreateBug`)
- ✅ Create theme requests in Asana (`CreateThemeRequest`)
- ✅ Create team agent tasks (`CreateTeamAgentTask`)
- ✅ API endpoints: `POST /api/agentservice/createasanabug`, `POST /api/agentservice/createthemerequest`
- ✅ Activity tracking integration

**Infrastructure:**

- `AsanaTaskManager` - Core Asana API manager
- `DashboardAsanaManager` - Dashboard-specific Asana operations
- Authentication and authorization already configured

---

## 🎯 RECOMMENDED APPROACH: Asana-Powered PM Dashboard

### Option 1: Asana Integration (RECOMMENDED) ⭐

**Why This Works:**

- ✅ Asana API already built into Genie
- ✅ Asana has native Gantt charts (Timeline view)
- ✅ Real-time sync via Asana API
- ✅ Web UI already exists (Asana web app)
- ✅ Multi-project support (this is "one of many projects")
- ✅ Minimal development - extend existing integration

**What We Build:**

1. **PM Dashboard Controller** - New controller for project management
2. **Asana Project Manager** - Extend `AsanaTaskManager` to create projects, tasks, dependencies
3. **PM Dashboard UI** - Angular component showing:
   - Project overview (from Asana)
   - Task list with status (from Asana)
   - Embedded Asana Timeline (Gantt chart) - **Native Asana feature**
   - Progress metrics (calculated from Asana data)
   - Real-time sync via Asana API

**Implementation:**

- Extend `DashboardAsanaManager` with project management methods
- Create `ProjectManagementController.cs` with endpoints:
  - `POST /api/pm/create-project` - Create Asana project
  - `POST /api/pm/create-task` - Create task in Asana project
  - `GET /api/pm/project/{id}` - Get project with tasks
  - `GET /api/pm/tasks` - Get all tasks for project
  - `PUT /api/pm/task/{id}/status` - Update task status
- Build Angular PM Dashboard component
- Embed Asana Timeline view (iframe or API-driven Gantt)

**Timeline:** 1-2 weeks (leverages existing infrastructure)

---

### Option 2: Custom Database-Driven PM System

**What We Build:**

- New database tables in `FarmGenie`:
  - `ProjectManagement_Projects`
  - `ProjectManagement_Tasks`
  - `ProjectManagement_Phases`
  - `ProjectManagement_Dependencies`
  - `ProjectManagement_Blockers`
- API endpoints for CRUD operations
- Custom Gantt chart component (D3.js or similar)
- Full custom UI

**Pros:**

- Complete control
- No external dependencies
- Custom features

**Cons:**

- More development time (4-6 weeks)
- Need to build Gantt chart from scratch
- Need to build all PM features

**Timeline:** 4-6 weeks

---

### Option 3: Open-Source PM Tool (Self-Hosted)

**Options:**

- **OpenProject** - Full-featured, includes Gantt charts
- **Taskist** - SQL Server-based, Bootstrap 5 UI
- **Kanboard** - Simple Kanban, lightweight

**Pros:**

- Turn-key solution
- Gantt charts included
- Multi-project support

**Cons:**

- Separate system (not integrated with TheGenie)
- Need to host/maintain
- May need custom integration

**Timeline:** 1-2 weeks setup + integration time

---

## 💡 RECOMMENDED SOLUTION: Asana Integration

### Why Asana Integration is Best

1. **Already Built** - API integration exists, just needs extension
2. **Native Gantt Charts** - Asana Timeline view is excellent
3. **Multi-Project** - Perfect for "one of many projects"
4. **Real-Time** - Asana webhooks for live updates
5. **Web UI** - Asana web app is the UI (or embed in Genie)
6. **Minimal Development** - Extend existing code

### Implementation Plan

#### Phase 1: Extend Asana Integration (Week 1)

**Backend:**

1. Extend `AsanaTaskManager` with project management methods:

   - `CreateProject(projectName, workspaceId)`
   - `CreateTask(projectId, taskName, assignee, dueDate, dependencies)`
   - `UpdateTaskStatus(taskId, status)`
   - `GetProjectTasks(projectId)`
   - `GetProjectTimeline(projectId)` - For Gantt data

2. Create `ProjectManagementController.cs`:

   ```csharp
   [HttpPost]
   public JsonResult CreateProject(AsanaProjectRequest request)

   [HttpPost]
   public JsonResult CreateTask(AsanaTaskRequest request)

   [HttpGet]
   public JsonResult GetProject(string projectId)

   [HttpGet]
   public JsonResult GetProjectTimeline(string projectId) // Gantt data

   [HttpPut]
   public JsonResult UpdateTaskStatus(string taskId, string status)
   ```

3. Create PLS project in Asana:
   - Project: "PLS RESO Engine"
   - Sections: Phase 1, Phase 2, Phase 3, Phase 4, Phase 5
   - Tasks: All 51 tasks from dashboard

#### Phase 2: Build PM Dashboard UI (Week 1-2)

**Frontend:**

1. Create Angular component: `ProjectManagementDashboardComponent`
2. Features:

   - Project overview card (progress, tasks, timeline)
   - Task list with status indicators
   - Embedded Asana Timeline (iframe) OR custom Gantt from API data
   - Progress metrics (calculated from Asana)
   - Real-time updates (polling or webhooks)

3. Gantt Chart Options:
   - **Option A:** Embed Asana Timeline view (iframe) - Easiest
   - **Option B:** Use Asana API to get timeline data, render with D3.js/Gantt library
   - **Option C:** Use existing Gantt library (e.g., Frappe Gantt, DHTMLX Gantt)

#### Phase 3: Sync Existing Tasks (Week 2)

1. Create Asana project for PLS
2. Create all 51 tasks in Asana (from `PROJECT_DASHBOARD_v1.md`)
3. Set up dependencies between tasks
4. Assign tasks to agents
5. Set up webhooks for real-time updates

---

## 📊 ASANA API CAPABILITIES

### What Asana API Provides

**Projects:**

- Create/update projects
- Get project details
- List projects in workspace

**Tasks:**

- Create/update tasks
- Assign tasks to users
- Set due dates
- Add dependencies
- Update task status (complete/incomplete)
- Add custom fields

**Timeline (Gantt):**

- Get timeline data for project
- Task dependencies
- Start/end dates
- Resource allocation

**Webhooks:**

- Real-time updates when tasks change
- Project updates
- Task completion notifications

---

## 🎨 DASHBOARD UI MOCKUP

### PM Dashboard Layout

```
┌─────────────────────────────────────────────────────────┐
│  PLS RESO Engine - Project Management Dashboard          │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Progress: 0% │  │ Tasks: 0/51  │  │ Blockers: 0  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  GANTT CHART (Asana Timeline or Custom)             │ │
│  │  [Visual timeline showing all phases and tasks]     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌──────────────────┐  ┌─────────────────────────────┐ │
│  │  Task List        │  │  Agent Status               │ │
│  │  - DB-001 ⏳      │  │  Database: 0%               │ │
│  │  - DB-002 ⏳      │  │  Backend: Blocked           │ │
│  │  - API-001 🚨     │  │  Frontend: Blocked          │ │
│  └──────────────────┘  └─────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Recent Activity / Blockers / Handoffs              │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 SYNC WORKFLOW

### How It Works

1. **Initial Setup:**

   - Create PLS project in Asana
   - Create all 51 tasks in Asana
   - Set dependencies
   - Assign to agents

2. **Daily Updates:**

   - Agents update tasks in Asana (or via Genie UI)
   - Genie PM Dashboard syncs from Asana API
   - Real-time updates via webhooks

3. **Gantt Chart:**
   - Asana Timeline view (native) OR
   - Custom Gantt from Asana API data

---

## 📋 IMPLEMENTATION CHECKLIST

### Backend (Asana Integration Extension)

- [ ] Extend `AsanaTaskManager` with project methods
- [ ] Create `ProjectManagementController.cs`
- [ ] Add endpoints for project/task CRUD
- [ ] Add endpoint for Gantt/timeline data
- [ ] Set up Asana webhooks for real-time updates
- [ ] Test Asana API integration

### Frontend (PM Dashboard UI)

- [ ] Create `ProjectManagementDashboardComponent`
- [ ] Build project overview cards
- [ ] Build task list with status
- [ ] Integrate Gantt chart (Asana Timeline or custom)
- [ ] Add real-time sync (polling or webhooks)
- [ ] Add progress metrics
- [ ] Add agent status view

### Setup (Asana Project)

- [ ] Create PLS project in Asana workspace
- [ ] Create all 51 tasks from dashboard
- [ ] Set up task dependencies
- [ ] Assign tasks to agents
- [ ] Configure Asana webhooks
- [ ] Test end-to-end sync

---

## 🚀 QUICK START OPTION

**Fastest Path (1-2 days):**

1. **Create Asana Project Manually:**

   - Go to Asana
   - Create project "PLS RESO Engine"
   - Create sections: Phase 1, Phase 2, Phase 3, Phase 4, Phase 5
   - Create all 51 tasks
   - Set dependencies
   - Assign to team members

2. **Use Asana Web UI:**

   - Use Asana Timeline view for Gantt chart
   - Use Asana for all task management
   - Share Asana project link with team

3. **Build Simple Dashboard (Later):**
   - Create simple Angular component
   - Embed Asana Timeline (iframe)
   - Show progress metrics from Asana API

**This gets you Gantt charts and visual task completion TODAY.**

---

## 💰 COST/BENEFIT ANALYSIS

| Option                | Development Time | Cost                  | Features                                 | Maintenance               |
| --------------------- | ---------------- | --------------------- | ---------------------------------------- | ------------------------- |
| **Asana Integration** | 1-2 weeks        | Low (Asana free tier) | ✅ Gantt, ✅ Multi-project, ✅ Real-time | Low (Asana maintained)    |
| **Custom Database**   | 4-6 weeks        | Medium                | ✅ Full control                          | Medium (we maintain)      |
| **Open-Source Tool**  | 1-2 weeks setup  | Low                   | ✅ Gantt, ✅ Multi-project               | Medium (we host/maintain) |
| **Asana Manual**      | 1-2 days         | Free                  | ✅ Gantt, ✅ Multi-project               | None (use Asana web)      |

---

## 🎯 RECOMMENDATION

**Start with Asana Manual (1-2 days):**

- Create project in Asana
- Use Asana Timeline for Gantt
- Use Asana for task management
- **Get visibility TODAY**

**Then Build Integration (1-2 weeks):**

- Extend existing Asana API
- Build PM Dashboard in Genie
- Sync with Asana for real-time updates
- **Best of both worlds**

---

## 📝 NEXT STEPS

1. **Decision:** Approve Asana integration approach?
2. **Asana Setup:** Create PLS project in Asana (manual or API)
3. **Development:** Extend Asana integration + build dashboard
4. **Deployment:** Deploy PM Dashboard to Genie

---

## 📚 REFERENCE

**Existing Asana Integration:**

- `Smart.Asana.dll` - Asana API library
- `DashboardAsanaManager.cs` - Dashboard Asana operations
- `AsanaTaskManager` - Core Asana API manager
- Endpoints: `/api/agentservice/createasanabug`, `/api/agentservice/createthemerequest`

**Asana API Documentation:**

- https://developers.asana.com/
- Timeline API: https://developers.asana.com/reference/timeline
- Projects API: https://developers.asana.com/reference/projects
- Tasks API: https://developers.asana.com/reference/tasks

---

**Status:** 📋 **PROPOSAL READY** - Awaiting approval to proceed

**Recommendation:** Start with Asana manual setup (1-2 days) for immediate visibility, then build integration (1-2 weeks) for Genie dashboard.

---

## 📝 CHANGE LOG

| Version | Date                | Author               | Changes                                                                                                                                                                                 |
| ------- | ------------------- | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.0     | 01/14/2026 12:05 AM | JR (Project Manager) | Initial proposal. Discovered existing Asana integration. Recommended leveraging Asana for PM dashboard with Gantt charts. Provided 4 options with recommendation for Asana integration. |
