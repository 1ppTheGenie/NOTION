# 🚨 Backend API Specialist - START NOW

**From:** JR (Project Manager)  
**To:** Backend API Specialist  
**Date:** 01/14/2026 1:30 AM  
**Status:** ✅ **DATABASE READY - YOU CAN START**

---

## ✅ DATABASE IS COMPLETE

**Database Specialist has finished!**  
**Handoff #1:** `AgentCollaboration/HANDOFFS_v1.md`

---

## 🎯 YOUR TASK

**Build .NET 8 API for Task Manager**  
**Time:** 2-3 minutes  
**Status:** ✅ **NO WAITING - START NOW**

---

## 📋 STEP-BY-STEP INSTRUCTIONS

### Step 1: Create .NET 8 Web API Project
```bash
dotnet new webapi -n TaskManager.Api
cd TaskManager.Api
```

### Step 2: Add Required Packages
```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
```

### Step 3: Configure Connection String
**File:** `appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=TaskManager;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "YOUR-SECRET-KEY-MIN-32-CHARS-LONG-FOR-TASK-MANAGER-API",
    "Issuer": "TaskManager",
    "Audience": "TaskManagerUsers",
    "ExpiryMinutes": 1440
  }
}
```

### Step 4: Create Entity Models
**Reference:** Blueprint lines 154-170

Create models in `Models/` folder:
- `User.cs`
- `Project.cs`
- `TaskItem.cs`
- `TaskStatus.cs`
- `TaskComment.cs`
- `ProjectMember.cs`

### Step 5: Create DbContext
**File:** `Data/TaskManagerContext.cs`

```csharp
using Microsoft.EntityFrameworkCore;

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

### Step 6: Configure Program.cs
**Reference:** Blueprint lines 190-249

Add DbContext, JWT auth, CORS for React frontend.

### Step 7: Create Controllers
**Reference:** Blueprint lines 251-316

Create:
- `Controllers/AuthController.cs`
- `Controllers/ProjectsController.cs`
- `Controllers/TasksController.cs` (with drag-and-drop move endpoint)
- `Controllers/UsersController.cs`

### Step 8: Run Migrations
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### Step 9: Test API
```bash
dotnet run
```

**Verify:**
- API runs on `localhost:5000`
- Swagger UI accessible at `https://localhost:5000/swagger`
- Can connect to TaskManager database

### Step 10: Signal Completion
**Update:** `AgentCollaboration/HANDOFFS_v1.md`

Add Handoff #2:
```markdown
### Handoff #2 - Backend API Specialist → Frontend UI Specialist
**Date:** 01/14/2026 [TIME]
**From:** Backend API Specialist
**To:** Frontend UI Specialist
**Status:** ✅ Complete

**Deliverable:** .NET 8 API running on localhost:5000

**Location:**
- API URL: http://localhost:5000
- Swagger: https://localhost:5000/swagger
- Connection: Connected to TaskManager database

**Key Information:**
- All controllers implemented
- JWT authentication configured
- CORS enabled for React frontend (localhost:3000)
- Drag-and-drop endpoint working: PUT /api/tasks/{id}/move

**Next Steps:**
- Frontend UI Specialist can now build React app and connect to this API
```

**Also update:** `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md`
- Mark task as complete
- Update status to "✅ API Ready"

---

## 📚 REFERENCE FILES

- **Blueprint:** `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`
  - Lines 143-316: Backend API structure
  - Lines 190-249: Program.cs configuration
  - Lines 251-316: Controllers example
- **Setup Plan:** `AgentCollaboration/Project Management/TASK_MANAGER_SETUP_PLAN_v1.md`
- **Handoff #1:** `AgentCollaboration/HANDOFFS_v1.md`

---

## ✅ SUCCESS CRITERIA

- [ ] .NET 8 API project created
- [ ] All packages installed
- [ ] Connection to TaskManager database working
- [ ] All controllers implemented
- [ ] API runs on localhost:5000
- [ ] Swagger UI accessible
- [ ] Handoff #2 sent to Frontend UI Specialist

---

**Status:** 🚀 **START NOW - DATABASE IS READY**
