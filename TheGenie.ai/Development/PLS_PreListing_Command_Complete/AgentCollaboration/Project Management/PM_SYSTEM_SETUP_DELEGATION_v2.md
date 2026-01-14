# Project Management System Setup - Team Delegation (CORRECTED)

**Version:** 2.0  
**Created:** 01/14/2026 3:00 PM  
**Last Updated:** 01/14/2026 3:00 PM  
**Author:** JR (Project Manager)  
**Status:** 🚀 **ASSIGNED - READY FOR IMPLEMENTATION**

---

## 🎯 EXECUTIVE SUMMARY

**Task:** Build custom task/project manager using provided blueprint  
**Approach:** ✅ **CUSTOM TASK MANAGER** (React + .NET 8 + SQL Server) - Blueprint provided  
**Timeline:** 3-5 days per blueprint estimate  
**Assigned To:** Database Specialist + Backend API Specialist + Frontend UI Specialist

**CRITICAL:** This is NOT Asana integration - this is a custom-built system using the existing TaskManager database (extended).

---

## 📋 ASSIGNMENT BREAKDOWN

### Database Specialist
**Primary Tasks:**
1. Extend existing `TaskManager` database with new schema from blueprint
2. Add `Projects`, `TaskStatuses`, `ProjectMembers`, `TaskComments` tables
3. Migrate existing `Task` table data if needed
4. Set up indexes and triggers

### Backend API Specialist
**Primary Tasks:**
1. Build .NET 8 API following blueprint structure
2. Implement `ProjectsController`, `TasksController`, `AuthController`
3. Set up Entity Framework Core with TaskManager database
4. Implement JWT authentication
5. Create drag-and-drop task movement endpoint

### Frontend UI Specialist
**Primary Tasks:**
1. Build React + TypeScript frontend
2. Implement Kanban board with drag-and-drop (@dnd-kit)
3. Create task cards, modals, project selector
4. Integrate with backend API

---

## 🔍 BACKGROUND CONTEXT

### What We Have

1. **Existing TaskManager Database** - Simple task list (4,369 tasks)
   - See: `01_Master_Documents/TASKMANAGER_DATABASE_AUDIT_v1.md`
   - Current: `Task`, `TaskHistory`, `Category` tables
   - Missing: Projects, proper status workflow, team collaboration

2. **Blueprint Provided** - Complete custom task manager solution
   - Location: `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`
   - Architecture: React frontend + .NET 8 API + SQL Server
   - Features: Kanban board, projects, team members, task statuses

3. **Decision:** Use the blueprint to extend TaskManager into full PM system

---

## 🚀 IMPLEMENTATION STEPS

### PHASE 1: Database Extension (Database Specialist)

#### Step 1.1: Review Existing TaskManager Schema
**Action:** Study current `TaskManager` database structure
- Current tables: `Task`, `TaskHistory`, `Category`
- Current Task table has: ID, UserID, ContactID, CategoryID, Completed, Priority, Subject, Notes, DueDate

**Decision Needed:** 
- Migrate existing Task data to new schema?
- Or keep old Task table and create new `Tasks` table?

---

#### Step 1.2: Create New Schema Tables
**File:** Create migration script based on blueprint

**Tables to Create:**
```sql
-- Projects table (NEW)
CREATE TABLE Projects (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Status NVARCHAR(20) DEFAULT 'Active',
    OwnerId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- TaskStatuses lookup table (NEW)
CREATE TABLE TaskStatuses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    DisplayOrder INT NOT NULL,
    Color NVARCHAR(7) DEFAULT '#6B7280'
);

-- Insert default statuses (Kanban columns)
INSERT INTO TaskStatuses (Name, DisplayOrder, Color) VALUES 
    ('Backlog', 1, '#6B7280'),
    ('To Do', 2, '#3B82F6'),
    ('In Progress', 3, '#F59E0B'),
    ('In Review', 4, '#8B5CF6'),
    ('Done', 5, '#10B981');

-- Tasks table (NEW - different from existing Task table)
CREATE TABLE Tasks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX),
    ProjectId INT NOT NULL FOREIGN KEY REFERENCES Projects(Id),
    StatusId INT NOT NULL FOREIGN KEY REFERENCES TaskStatuses(Id) DEFAULT 1,
    AssigneeId INT NULL FOREIGN KEY REFERENCES Users(Id),
    Priority INT DEFAULT 2,
    DueDate DATETIME2 NULL,
    DisplayOrder INT DEFAULT 0,
    CreatedById INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- TaskComments table (NEW)
CREATE TABLE TaskComments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TaskId INT NOT NULL FOREIGN KEY REFERENCES Tasks(Id) ON DELETE CASCADE,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Content NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- ProjectMembers table (NEW)
CREATE TABLE ProjectMembers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId INT NOT NULL FOREIGN KEY REFERENCES Projects(Id) ON DELETE CASCADE,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Role NVARCHAR(20) DEFAULT 'Member',
    JoinedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_ProjectMember UNIQUE (ProjectId, UserId)
);
```

**Note:** Blueprint assumes `Users` table exists. May need to create or map to existing user system.

---

#### Step 1.3: Create Indexes and Triggers
**From Blueprint:**
```sql
CREATE INDEX IX_Tasks_ProjectId ON Tasks(ProjectId);
CREATE INDEX IX_Tasks_StatusId ON Tasks(StatusId);
CREATE INDEX IX_Tasks_AssigneeId ON Tasks(AssigneeId);
CREATE INDEX IX_ProjectMembers_UserId ON ProjectMembers(UserId);

-- Update timestamp triggers
CREATE TRIGGER TR_Tasks_UpdateTimestamp ON Tasks
AFTER UPDATE AS
BEGIN
    UPDATE Tasks SET UpdatedAt = GETUTCDATE()
    WHERE Id IN (SELECT Id FROM inserted);
END;

CREATE TRIGGER TR_Projects_UpdateTimestamp ON Projects
AFTER UPDATE AS
BEGIN
    UPDATE Projects SET UpdatedAt = GETUTCDATE()
    WHERE Id IN (SELECT Id FROM inserted);
END;
```

---

### PHASE 2: Backend API (.NET 8) (Backend API Specialist)

#### Step 2.1: Create .NET 8 API Project
**Commands:**
```bash
dotnet new webapi -n TaskManager.Api
cd TaskManager.Api
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
```

---

#### Step 2.2: Configure Database Connection
**File:** `appsettings.json`
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=192.168.29.45,1433;Database=TaskManager;User Id=sa;Password=neo222;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "YOUR-SECRET-KEY-MIN-32-CHARS-LONG",
    "Issuer": "TaskManager",
    "Audience": "TaskManagerUsers",
    "ExpiryMinutes": 1440
  }
}
```

**Note:** Use SA credentials for now, or create dedicated TaskManager user.

---

#### Step 2.3: Create Entity Models
**Files to Create:**
- `Models/User.cs`
- `Models/Project.cs`
- `Models/TaskItem.cs`
- `Models/TaskStatus.cs`
- `Models/TaskComment.cs`
- `Models/ProjectMember.cs`
- `DTOs/CreateTaskDto.cs`
- `DTOs/UpdateTaskDto.cs`
- `DTOs/MoveTaskDto.cs`

**Reference:** Blueprint shows structure - map to SQL schema.

---

#### Step 2.4: Create DbContext
**File:** `Data/TaskManagerContext.cs`
```csharp
public class TaskManagerContext : DbContext
{
    public TaskManagerContext(DbContextOptions<TaskManagerContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Project> Projects { get; set; }
    public DbSet<TaskItem> Tasks { get; set; }
    public DbSet<TaskStatus> TaskStatuses { get; set; }
    public DbSet<TaskComment> TaskComments { get; set; }
    public DbSet<ProjectMember> ProjectMembers { get; set; }
}
```

---

#### Step 2.5: Implement Controllers
**Files to Create:**
- `Controllers/AuthController.cs` - Login, register, JWT tokens
- `Controllers/ProjectsController.cs` - CRUD for projects
- `Controllers/TasksController.cs` - CRUD for tasks, drag-and-drop move
- `Controllers/UsersController.cs` - User management

**Key Endpoint (from blueprint):**
```csharp
// PUT: api/tasks/{id}/move (for drag-and-drop)
[HttpPut("{id}/move")]
public async Task<IActionResult> MoveTask(int id, MoveTaskDto dto)
{
    var task = await _context.Tasks.FindAsync(id);
    if (task == null) return NotFound();

    task.StatusId = dto.NewStatusId;
    task.DisplayOrder = dto.NewOrder;

    await _context.SaveChangesAsync();
    return NoContent();
}
```

---

#### Step 2.6: Configure Program.cs
**File:** `Program.cs`
- Add DbContext
- Add JWT Authentication
- Add CORS for React frontend (localhost:3000)
- Add Swagger for development

**Reference:** Blueprint has full Program.cs example.

---

### PHASE 3: Frontend (React + TypeScript) (Frontend UI Specialist)

#### Step 3.1: Create React App
**Commands:**
```bash
npm create vite@latest task-manager-ui -- --template react-ts
cd task-manager-ui
npm install @tanstack/react-query @dnd-kit/core @dnd-kit/sortable axios lucide-react
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

---

#### Step 3.2: Create API Service
**File:** `src/services/api.ts`
- Axios instance with base URL
- JWT token interceptor
- `taskApi`, `projectApi`, `authApi` exports

**Reference:** Blueprint has full api.ts example.

---

#### Step 3.3: Build Kanban Board
**Files to Create:**
- `src/components/Board/KanbanBoard.tsx` - Main board with drag-and-drop
- `src/components/Board/Column.tsx` - Status column
- `src/components/Board/TaskCard.tsx` - Individual task card

**Key Library:** `@dnd-kit/core` and `@dnd-kit/sortable` for drag-and-drop

**Reference:** Blueprint has full KanbanBoard.tsx and TaskCard.tsx examples.

---

#### Step 3.4: Create Modals and Layout
**Files to Create:**
- `src/components/Modals/TaskModal.tsx` - Create/edit task
- `src/components/Modals/ProjectModal.tsx` - Create/edit project
- `src/components/Layout/Sidebar.tsx` - Project selector
- `src/components/Layout/Header.tsx` - User menu, logout

---

#### Step 3.5: Add Routing
**File:** `src/App.tsx`
- Login page
- Dashboard (Kanban board)
- Project selector

---

## 📚 REFERENCE DOCUMENTS

### Must Read
1. `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md` - **COMPLETE BLUEPRINT**
2. `01_Master_Documents/TASKMANAGER_DATABASE_AUDIT_v1.md` - Existing database structure

### Supporting
- `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - PLS project phases (for initial tasks)

---

## ✅ DELIVERABLES CHECKLIST

### Database Specialist
- [ ] Extended TaskManager database with new schema
- [ ] Created Projects, TaskStatuses, Tasks, TaskComments, ProjectMembers tables
- [ ] Added indexes and triggers
- [ ] Tested schema with sample data
- [ ] Updated status in `AgentStatus/AGENT_STATUS_DATABASE_v1.md`

### Backend API Specialist
- [ ] Created .NET 8 API project
- [ ] Configured Entity Framework Core
- [ ] Implemented all controllers (Auth, Projects, Tasks, Users)
- [ ] JWT authentication working
- [ ] Drag-and-drop endpoint working
- [ ] Swagger documentation available
- [ ] Updated status in `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`

### Frontend UI Specialist
- [ ] Created React app with TypeScript
- [ ] Built Kanban board with drag-and-drop
- [ ] Created task and project modals
- [ ] Integrated with backend API
- [ ] Responsive design (mobile-friendly)
- [ ] Updated status in `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md`

### All (Collaborative)
- [ ] End-to-end testing (create project → create tasks → move tasks)
- [ ] Created initial PLS project in new system
- [ ] Created initial phase tasks from PLS blueprint
- [ ] Documented setup in handoff

---

## 🎯 SUCCESS CRITERIA

1. ✅ TaskManager database extended with new schema
2. ✅ .NET 8 API running on localhost:5000
3. ✅ React app running on localhost:3000
4. ✅ Kanban board displays tasks by status
5. ✅ Drag-and-drop moves tasks between columns
6. ✅ Can create projects and tasks
7. ✅ JWT authentication working
8. ✅ PLS project created with initial tasks

---

## 🚨 CRITICAL NOTES

1. **Users Table** - Blueprint assumes Users table exists. May need to:
   - Create new Users table, OR
   - Map to existing FarmGenie user system, OR
   - Use ASP.NET Identity if already in Genie

2. **Existing Task Data** - Decide whether to:
   - Migrate old Task table data to new Tasks table, OR
   - Keep both tables separate (old for legacy, new for PM)

3. **Authentication** - Blueprint uses JWT. May need to integrate with existing Genie auth system.

4. **Deployment** - Blueprint suggests Azure App Service for API, Azure Static Web App for frontend. Can also deploy alongside existing Genie app.

---

## 📞 ESCALATION

**If Blocked:**
1. Document in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag Project Manager (JR) for decisions (Users table, auth integration, etc.)
3. Tag each other for integration issues

**Key Decisions Needed:**
- Users table approach (new vs existing)
- Authentication integration (JWT vs existing Genie auth)
- Deployment location (separate vs integrated with Genie)

---

## 🔗 RELATED TASKS

- This enables project-wide task tracking for PLS and future projects
- All agents will use this system for task updates
- Replaces manual status files with real-time Kanban board

---

## 📊 CHANGE LOG

### Version 2.0 (01/14/2026 3:00 PM)
- **CORRECTED:** Changed from Asana integration to custom Task Manager from blueprint
- Updated all implementation steps to match blueprint
- Added database extension steps
- Added .NET 8 API and React frontend steps
- Referenced provided blueprint document

### Version 1.0 (01/14/2026 2:45 PM)
- Initial delegation (incorrectly assumed Asana integration)

---

**Status:** 🚀 **READY TO START**  
**Priority:** High (enables project-wide visibility)  
**Estimated Time:** 3-5 days per blueprint estimate
