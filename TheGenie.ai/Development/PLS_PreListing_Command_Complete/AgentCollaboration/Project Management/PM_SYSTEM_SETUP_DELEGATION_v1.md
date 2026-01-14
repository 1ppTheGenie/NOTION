# Project Management System Setup - Team Delegation

**Version:** 1.0  
**Created:** 01/14/2026 2:45 PM  
**Last Updated:** 01/14/2026 2:45 PM  
**Author:** JR (Project Manager)  
**Status:** 🚀 **ASSIGNED - READY FOR IMPLEMENTATION**

---

## 🎯 EXECUTIVE SUMMARY

**Task:** Set up web-based project management dashboard for PLS project  
**Approach:** ✅ **Asana Integration** (recommended - leverages existing infrastructure)  
**Timeline:** Quick setup (1-2 days for basic functionality)  
**Assigned To:** Backend API Specialist + Frontend UI Specialist (collaborative)

---

## 📋 ASSIGNMENT BREAKDOWN

### Backend API Specialist
**Primary Tasks:**
1. Extend `DashboardAsanaManager` with project management methods
2. Create `ProjectManagementController.cs` with PM endpoints
3. Test Asana API integration for projects/tasks

### Frontend UI Specialist
**Primary Tasks:**
1. Create Angular PM Dashboard component
2. Build project overview UI
3. Integrate Asana Timeline (Gantt chart) view

---

## 🔍 BACKGROUND CONTEXT

### What We Discovered

1. **TaskManager Database Exists** - But it's a simple task list, not project-oriented
   - See: `01_Master_Documents/TASKMANAGER_DATABASE_AUDIT_v1.md`
   - Missing: Project grouping, phases, dependencies, Gantt data

2. **Asana API Already Integrated** - `Smart.Asana.dll` exists in Genie
   - Location: `Smart.Dashboard.BLL.Asana.DashboardAsanaManager`
   - Current methods: `CreateBug`, `CreateThemeRequest`, `CreateTeamAgentTask`
   - Endpoints: `/api/agentservice/createasanabug`, `/api/agentservice/createthemerequest`

3. **Recommendation:** Use Asana for project management (native Gantt charts, multi-project support)

### Full Proposal
See: `01_Master_Documents/PLS_PROJECT_MANAGEMENT_SYSTEM_PROPOSAL_v1.md`

---

## 🚀 IMPLEMENTATION STEPS

### PHASE 1: Backend API Extension (Backend API Specialist)

#### Step 1.1: Review Existing Asana Integration
**Location:** `Smart.Dashboard.BLL.Asana.DashboardAsanaManager.cs`

**What to Study:**
- How `CreateBug` method works
- How `AsanaTaskManager` is used
- Authentication/authorization pattern

**Action:** Read the code, understand the pattern

---

#### Step 1.2: Extend DashboardAsanaManager
**File:** `Smart.Dashboard.BLL.Asana.DashboardAsanaManager.cs`

**Add New Methods:**

```csharp
// Create Asana project for PLS
public static ResponseWithUrl CreateProject(string aspNetUserId, string projectName, string projectDescription)
{
    // Use AsanaTaskManager to create project
    // Return project URL
}

// Create task in Asana project
public static ResponseWithUrl CreateProjectTask(string aspNetUserId, string projectGid, string taskName, string taskNotes, DateTime? dueDate)
{
    // Create task in specific project
    // Link to project
    // Return task URL
}

// Get project tasks
public static ResponseGeneral GetProjectTasks(string projectGid)
{
    // Fetch all tasks for project
    // Return task list with status
}

// Update task status
public static ResponseGeneral UpdateTaskStatus(string taskGid, string status)
{
    // Update task completion status
    // Status: "completed", "incomplete"
}
```

**Reference:** Study `AsanaTaskManager` class to understand Asana API calls

---

#### Step 1.3: Create ProjectManagementController
**File:** `Smart.Dashboard/Controllers/ProjectManagementController.cs`

**Endpoints to Create:**

```csharp
[HttpPost]
public JsonResult CreateProject(AsanaProjectRequest request)
{
    // Call DashboardAsanaManager.CreateProject
    // Return project URL
}

[HttpPost]
public JsonResult CreateTask(AsanaTaskRequest request)
{
    // Call DashboardAsanaManager.CreateProjectTask
    // Return task URL
}

[HttpGet]
public JsonResult GetProjectTasks(string projectGid)
{
    // Call DashboardAsanaManager.GetProjectTasks
    // Return task list
}

[HttpPut]
public JsonResult UpdateTaskStatus(string taskGid, string status)
{
    // Call DashboardAsanaManager.UpdateTaskStatus
    // Return success
}
```

**Authorization:** Use `[ProductionAuthorize]` attribute (same as existing Asana endpoints)

---

#### Step 1.4: Test Asana API Connection
**Action:**
1. Verify Asana API credentials are configured
2. Test creating a project manually via Asana API
3. Test creating tasks in that project
4. Document any configuration needed

**Check:** Asana API token/credentials location (likely in Web.config or app settings)

---

### PHASE 2: Frontend UI Dashboard (Frontend UI Specialist)

#### Step 2.1: Create PM Dashboard Component
**Location:** `Smart.Dashboard/AngularApp/src/app/project-management/`

**Component:** `pm-dashboard.component.ts`, `pm-dashboard.component.html`, `pm-dashboard.component.css`

**Features:**
- Project overview card (showing PLS project)
- Task list with status indicators
- Progress metrics (completed vs total tasks)
- Link to Asana project (opens in new tab)

---

#### Step 2.2: Integrate Asana Timeline (Gantt Chart)
**Options:**

**Option A: Embed Asana Timeline (EASIEST)**
- Use Asana Timeline view URL in iframe
- Requires Asana project to be created first
- Native Asana Gantt chart functionality

**Option B: Build Custom Gantt (MORE WORK)**
- Use D3.js or similar library
- Fetch tasks from Asana API
- Render custom Gantt chart
- More control, but more development

**Recommendation:** Start with Option A (iframe), upgrade to Option B later if needed

---

#### Step 2.3: Add PM Dashboard Route
**File:** `Smart.Dashboard/AngularApp/src/app/app-routing.module.ts`

**Add Route:**
```typescript
{
  path: 'project-management',
  component: PmDashboardComponent,
  canActivate: [AuthGuard]
}
```

---

#### Step 2.4: Create Service for PM API Calls
**File:** `Smart.Dashboard/AngularApp/src/app/services/project-management.service.ts`

**Methods:**
```typescript
createProject(name: string, description: string): Observable<any>
createTask(projectGid: string, taskName: string, notes: string, dueDate?: Date): Observable<any>
getProjectTasks(projectGid: string): Observable<any>
updateTaskStatus(taskGid: string, status: string): Observable<any>
```

---

### PHASE 3: Initial PLS Project Setup (Both Specialists)

#### Step 3.1: Create PLS Project in Asana
**Action:** Use new API endpoint to create "PLS Pre-Listing Command" project in Asana

**Project Details:**
- Name: "PLS Pre-Listing Command"
- Description: "Paisley RESO Listing Engine - Private Listing Service"

---

#### Step 3.2: Create Initial Tasks
**Action:** Create tasks for each phase from Project Blueprint

**Reference:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` (Section 3: Project Phases)

**Tasks to Create:**
- Phase 1: Database Schema (Database Specialist)
- Phase 2: Backend API (Backend API Specialist)
- Phase 3: Frontend UI (Frontend UI Specialist)
- Phase 4: XML/Integration (XML/Integration Specialist)
- Phase 5: DevOps/Deployment (DevOps Specialist)

**Note:** Can create tasks manually in Asana first, then automate later

---

## 📚 REFERENCE DOCUMENTS

### Must Read
1. `01_Master_Documents/PLS_PROJECT_MANAGEMENT_SYSTEM_PROPOSAL_v1.md` - Full proposal with details
2. `01_Master_Documents/TASKMANAGER_DATABASE_AUDIT_v1.md` - Why we're using Asana instead
3. `Smart.Dashboard/Controllers/AgentServiceController.Asana.cs` - Existing Asana endpoint pattern
4. `Smart.Dashboard.BLL.Asana/DashboardAsanaManager.cs` - Existing Asana integration

### Supporting
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Project phases reference
- Asana API Documentation: https://developers.asana.com/reference

---

## ✅ DELIVERABLES CHECKLIST

### Backend API Specialist
- [ ] Extended `DashboardAsanaManager` with PM methods
- [ ] Created `ProjectManagementController.cs` with all endpoints
- [ ] Tested Asana API connection
- [ ] Documented any configuration needed
- [ ] Updated status in `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`

### Frontend UI Specialist
- [ ] Created `pm-dashboard.component.*` files
- [ ] Integrated Asana Timeline (iframe or custom)
- [ ] Added PM dashboard route
- [ ] Created `project-management.service.ts`
- [ ] Tested UI with backend API
- [ ] Updated status in `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md`

### Both (Collaborative)
- [ ] Created PLS project in Asana
- [ ] Created initial phase tasks
- [ ] Tested end-to-end flow
- [ ] Documented setup in handoff

---

## 🎯 SUCCESS CRITERIA

1. ✅ PM Dashboard accessible at `/project-management` route
2. ✅ Can create projects via API
3. ✅ Can create tasks in projects
4. ✅ Can view tasks with status
5. ✅ Gantt chart visible (Asana Timeline)
6. ✅ PLS project created with initial tasks

---

## 🚨 CRITICAL NOTES

1. **Asana API Credentials** - May need to configure API token (check Web.config or app settings)
2. **Asana Account** - Verify Asana account is set up and accessible
3. **Quick Win Approach** - Start with iframe embedding (fastest), upgrade later if needed
4. **Test in Sandbox** - All development in Sandbox environment first

---

## 📞 ESCALATION

**If Blocked:**
1. Document in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag Project Manager (JR) if Asana setup issues
3. Tag each other if API/UI integration issues

**Questions:**
- Asana API credentials location?
- Asana account setup needed?
- Custom Gantt vs iframe preference?

---

## 🔗 RELATED TASKS

- This enables project-wide task tracking
- All agents will update tasks in Asana
- PM Dashboard becomes central visibility tool

---

## 📊 CHANGE LOG

### Version 1.0 (01/14/2026 2:45 PM)
- Initial delegation document created
- Assigned to Backend API + Frontend UI Specialists
- Provided step-by-step implementation guide
- Referenced all relevant documents

---

**Status:** 🚀 **READY TO START**  
**Priority:** High (enables project-wide visibility)  
**Estimated Time:** 1-2 days for basic functionality
