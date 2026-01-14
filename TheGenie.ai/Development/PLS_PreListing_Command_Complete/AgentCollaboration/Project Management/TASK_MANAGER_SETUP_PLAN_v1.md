# Task Manager System - Quick Setup Plan

**Version:** 1.0  
**Created:** 01/14/2026 3:30 PM  
**Last Updated:** 01/14/2026 3:30 PM  
**Author:** JR (Project Manager)  
**Status:** 🚀 **READY TO EXECUTE**

---

## 🎯 OBJECTIVE

**Build custom task manager system from blueprint on localhost SQL**  
**Purpose:** PM tool for managing PLS and other projects  
**Timeline:** Quick setup (few minutes to hours)  
**Blueprint:** `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`

---

## 📋 ASSIGNMENT BREAKDOWN

### Database Specialist
**Task:** Create NEW database schema on LOCALHOST SQL Server

**Steps:**
1. Connect to LOCALHOST SQL Server (not production!)
2. Create NEW database: `TaskManager` (or `TaskManager_PM` to avoid conflicts)
3. Run schema creation script from blueprint (lines 31-139):
   - Create `Users` table
   - Create `Projects` table
   - Create `TaskStatuses` table (insert default statuses: Backlog, To Do, In Progress, In Review, Done)
   - Create `Tasks` table
   - Create `TaskComments` table
   - Create `ProjectMembers` table
   - Create indexes
   - Create triggers
4. Verify all tables created

**Time Estimate:** 3-5 minutes

**Deliverable:** New localhost database ready with all tables

**Connection:** Localhost SQL Server (local instance, not 192.168.29.45)

---

### Backend API Specialist
**Task:** Build .NET 8 API following blueprint structure

**Steps:**
1. Create new .NET 8 Web API project:
   ```bash
   dotnet new webapi -n TaskManager.Api
   cd TaskManager.Api
   ```
2. Add required packages:
   ```bash
   dotnet add package Microsoft.EntityFrameworkCore.SqlServer
   dotnet add package Microsoft.EntityFrameworkCore.Tools
   dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
   ```
3. Configure `appsettings.json`:
   - Connection string to LOCALHOST TaskManager database (not production!)
   - Example: `Server=localhost;Database=TaskManager;Trusted_Connection=True;TrustServerCertificate=True;`
   - JWT settings
4. Create Entity Framework models:
   - `Models/User.cs`
   - `Models/Project.cs`
   - `Models/TaskItem.cs`
   - `Models/TaskStatus.cs`
   - `Models/TaskComment.cs`
   - `Models/ProjectMember.cs`
5. Create `Data/TaskManagerContext.cs`
6. Create controllers:
   - `Controllers/AuthController.cs`
   - `Controllers/ProjectsController.cs`
   - `Controllers/TasksController.cs`
   - `Controllers/UsersController.cs`
7. Configure `Program.cs` (from blueprint lines 190-249)
8. Run Entity Framework migrations:
   ```bash
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```
9. Test API runs on `localhost:5000`
10. Verify Swagger UI accessible

**Time Estimate:** 2-3 minutes (quick setup, then test)

**Deliverable:** .NET 8 API running on localhost:5000 with all endpoints

---

### Frontend UI Specialist
**Task:** Build React Kanban board frontend

**Steps:**
1. Create React app:
   ```bash
   npm create vite@latest task-manager-ui -- --template react-ts
   cd task-manager-ui
   ```
2. Install dependencies:
   ```bash
   npm install @tanstack/react-query @dnd-kit/core @dnd-kit/sortable axios lucide-react
   npm install -D tailwindcss postcss autoprefixer
   npx tailwindcss init -p
   ```
3. Create API service (`src/services/api.ts`) - from blueprint lines 498-547
4. Create components:
   - `src/components/Board/KanbanBoard.tsx` - from blueprint lines 372-424
   - `src/components/Board/Column.tsx`
   - `src/components/Board/TaskCard.tsx` - from blueprint lines 427-495
   - `src/components/Modals/TaskModal.tsx`
   - `src/components/Modals/ProjectModal.tsx`
   - `src/components/Layout/Sidebar.tsx`
   - `src/components/Layout/Header.tsx`
5. Configure routing and authentication
6. Test runs on `localhost:3000`
7. Verify Kanban board displays and drag-and-drop works

**Time Estimate:** 2-3 minutes (quick setup, then test)

**Deliverable:** React app running on localhost:3000 with Kanban board

---

## 🔄 EXECUTION ORDER

1. **Database Specialist** (FIRST - blocks others)
   - Creates schema
   - Verifies tables exist
   - Signals "Database Ready"

2. **Backend API Specialist** (SECOND - after database)
   - Builds API
   - Connects to database
   - Tests endpoints
   - Signals "API Ready"

3. **Frontend UI Specialist** (THIRD - after API)
   - Builds React app
   - Connects to API
   - Tests full flow
   - Signals "UI Ready"

---

## ✅ SUCCESS CRITERIA

- [ ] Database: All tables created, indexes and triggers working
- [ ] Backend: API runs on localhost:5000, Swagger accessible, all endpoints work
- [ ] Frontend: React app runs on localhost:3000, Kanban board displays, drag-and-drop works
- [ ] Integration: Can create project → create tasks → move tasks between columns
- [ ] PM can access system and start managing PLS project tasks

---

## 🚨 CRITICAL NOTES

1. **Database Location:** LOCALHOST SQL Server ONLY (NOT production 192.168.29.45!)
   - Create NEW database on localhost
   - Keep it simple - fresh database
   - Name: `TaskManager` or `TaskManager_PM`

2. **Quick Setup Goal:** 7 minutes for initial setup
   - Get it running fast
   - Q/A and tweaking comes AFTER initial setup
   - Follow blueprint exactly for speed

3. **Localhost Only:** This is for PM use on localhost
   - Not production deployment
   - Just need it working locally for now

---

## 📚 REFERENCE

**Blueprint:** `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`

**Key Sections:**
- Database Schema: Lines 29-139
- Backend API: Lines 143-316
- Frontend: Lines 320-547
- Quick Start: Lines 551-587

---

## 📞 COORDINATION

**Database Specialist:**
- Update `AgentStatus/AGENT_STATUS_DATABASE_v1.md` when schema ready
- Signal in `AgentCollaboration/HANDOFFS_v1.md` when done

**Backend API Specialist:**
- Wait for Database Specialist "Database Ready" signal
- Update `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md` when API ready
- Signal in `AgentCollaboration/HANDOFFS_v1.md` when done

**Frontend UI Specialist:**
- Wait for Backend API Specialist "API Ready" signal
- Update `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md` when UI ready
- Signal in `AgentCollaboration/HANDOFFS_v1.md` when done

---

## 📊 CHANGE LOG

### Version 1.0 (01/14/2026 3:30 PM)
- Initial setup plan created
- Assigned tasks to Database, Backend API, and Frontend UI Specialists
- Defined execution order and success criteria
- Referenced blueprint document

---

**Status:** 🚀 **READY FOR TEAM TO START**  
**Priority:** High (PM needs this for project management)  
**Estimated Initial Setup Time:** 7 minutes (then Q/A and tweaking)
