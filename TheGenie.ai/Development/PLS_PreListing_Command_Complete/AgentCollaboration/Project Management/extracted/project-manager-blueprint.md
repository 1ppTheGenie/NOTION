# Simple Task Manager Blueprint
## For One Park Place Development Team

**Goal**: A lightweight, internal task/project manager that connects to your existing MSSQL infrastructure.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Frontend (React)                        │
│                    localhost:3000                            │
└─────────────────────┬───────────────────────────────────────┘
                      │ REST API
┌─────────────────────▼───────────────────────────────────────┐
│                   Backend (.NET 8 API)                       │
│                    localhost:5000                            │
└─────────────────────┬───────────────────────────────────────┘
                      │ Entity Framework Core
┌─────────────────────▼───────────────────────────────────────┐
│                   SQL Server Database                        │
│                  (Your existing MSSQL)                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Schema (MSSQL)

```sql
-- =====================================================
-- TASK MANAGER DATABASE SCHEMA
-- Run this against your MSSQL instance
-- =====================================================

CREATE DATABASE TaskManager;
GO

USE TaskManager;
GO

-- Users table
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    DisplayName NVARCHAR(100) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Projects table
CREATE TABLE Projects (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Status NVARCHAR(20) DEFAULT 'Active', -- Active, Archived, Completed
    OwnerId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Task statuses as a lookup table
CREATE TABLE TaskStatuses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    DisplayOrder INT NOT NULL,
    Color NVARCHAR(7) DEFAULT '#6B7280' -- Hex color for UI
);

-- Insert default statuses (Kanban columns)
INSERT INTO TaskStatuses (Name, DisplayOrder, Color) VALUES 
    ('Backlog', 1, '#6B7280'),
    ('To Do', 2, '#3B82F6'),
    ('In Progress', 3, '#F59E0B'),
    ('In Review', 4, '#8B5CF6'),
    ('Done', 5, '#10B981');

-- Tasks table
CREATE TABLE Tasks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX),
    ProjectId INT NOT NULL FOREIGN KEY REFERENCES Projects(Id),
    StatusId INT NOT NULL FOREIGN KEY REFERENCES TaskStatuses(Id) DEFAULT 1,
    AssigneeId INT NULL FOREIGN KEY REFERENCES Users(Id),
    Priority INT DEFAULT 2, -- 1=Low, 2=Medium, 3=High, 4=Urgent
    DueDate DATETIME2 NULL,
    DisplayOrder INT DEFAULT 0, -- For ordering within a status column
    CreatedById INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Task comments
CREATE TABLE TaskComments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TaskId INT NOT NULL FOREIGN KEY REFERENCES Tasks(Id) ON DELETE CASCADE,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Content NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Project members (who can access which projects)
CREATE TABLE ProjectMembers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId INT NOT NULL FOREIGN KEY REFERENCES Projects(Id) ON DELETE CASCADE,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Role NVARCHAR(20) DEFAULT 'Member', -- Owner, Admin, Member
    JoinedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_ProjectMember UNIQUE (ProjectId, UserId)
);

-- Indexes for performance
CREATE INDEX IX_Tasks_ProjectId ON Tasks(ProjectId);
CREATE INDEX IX_Tasks_StatusId ON Tasks(StatusId);
CREATE INDEX IX_Tasks_AssigneeId ON Tasks(AssigneeId);
CREATE INDEX IX_ProjectMembers_UserId ON ProjectMembers(UserId);

-- Trigger to update UpdatedAt timestamp
GO
CREATE TRIGGER TR_Tasks_UpdateTimestamp ON Tasks
AFTER UPDATE AS
BEGIN
    UPDATE Tasks SET UpdatedAt = GETUTCDATE()
    WHERE Id IN (SELECT Id FROM inserted);
END;
GO

CREATE TRIGGER TR_Projects_UpdateTimestamp ON Projects
AFTER UPDATE AS
BEGIN
    UPDATE Projects SET UpdatedAt = GETUTCDATE()
    WHERE Id IN (SELECT Id FROM inserted);
END;
GO
```

---

## Backend API (.NET 8)

### Project Structure

```
TaskManager.Api/
├── Controllers/
│   ├── AuthController.cs
│   ├── ProjectsController.cs
│   ├── TasksController.cs
│   └── UsersController.cs
├── Models/
│   ├── User.cs
│   ├── Project.cs
│   ├── TaskItem.cs
│   ├── TaskStatus.cs
│   └── DTOs/
│       ├── CreateTaskDto.cs
│       ├── UpdateTaskDto.cs
│       ├── MoveTaskDto.cs
│       └── ...
├── Data/
│   └── TaskManagerContext.cs
├── Services/
│   ├── IAuthService.cs
│   └── AuthService.cs
├── Program.cs
└── appsettings.json
```

### Key Files

**appsettings.json**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=TaskManager;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "YOUR-SECRET-KEY-MIN-32-CHARS-LONG",
    "Issuer": "TaskManager",
    "Audience": "TaskManagerUsers",
    "ExpiryMinutes": 1440
  }
}
```

**Program.cs**
```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add DbContext with SQL Server
builder.Services.AddDbContext<TaskManagerContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add JWT Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// CORS for React frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReact", policy =>
    {
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowReact");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

**TasksController.cs (Key Endpoints)**
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TasksController : ControllerBase
{
    private readonly TaskManagerContext _context;

    public TasksController(TaskManagerContext context)
    {
        _context = context;
    }

    // GET: api/tasks/project/{projectId}
    [HttpGet("project/{projectId}")]
    public async Task<ActionResult<IEnumerable<TaskItem>>> GetTasksByProject(int projectId)
    {
        return await _context.Tasks
            .Where(t => t.ProjectId == projectId)
            .Include(t => t.Assignee)
            .Include(t => t.Status)
            .OrderBy(t => t.StatusId)
            .ThenBy(t => t.DisplayOrder)
            .ToListAsync();
    }

    // POST: api/tasks
    [HttpPost]
    public async Task<ActionResult<TaskItem>> CreateTask(CreateTaskDto dto)
    {
        var task = new TaskItem
        {
            Title = dto.Title,
            Description = dto.Description,
            ProjectId = dto.ProjectId,
            StatusId = dto.StatusId ?? 1,
            AssigneeId = dto.AssigneeId,
            Priority = dto.Priority ?? 2,
            DueDate = dto.DueDate,
            CreatedById = GetCurrentUserId()
        };

        _context.Tasks.Add(task);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetTask), new { id = task.Id }, task);
    }

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

    // GET, PUT, DELETE endpoints...
}
```

---

## Frontend (React + TypeScript)

### Project Structure

```
task-manager-ui/
├── src/
│   ├── components/
│   │   ├── Board/
│   │   │   ├── KanbanBoard.tsx
│   │   │   ├── Column.tsx
│   │   │   └── TaskCard.tsx
│   │   ├── Layout/
│   │   │   ├── Sidebar.tsx
│   │   │   └── Header.tsx
│   │   ├── Modals/
│   │   │   ├── TaskModal.tsx
│   │   │   └── ProjectModal.tsx
│   │   └── common/
│   │       ├── Button.tsx
│   │       └── Input.tsx
│   ├── hooks/
│   │   ├── useTasks.ts
│   │   └── useProjects.ts
│   ├── services/
│   │   └── api.ts
│   ├── types/
│   │   └── index.ts
│   ├── App.tsx
│   └── main.tsx
├── package.json
└── tailwind.config.js
```

### Key Dependencies

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "@tanstack/react-query": "^5.0.0",
    "@dnd-kit/core": "^6.1.0",
    "@dnd-kit/sortable": "^8.0.0",
    "axios": "^1.6.0",
    "tailwindcss": "^3.3.0",
    "lucide-react": "^0.290.0"
  }
}
```

### KanbanBoard.tsx (Core Component)

```tsx
import { DndContext, closestCorners, DragEndEvent } from '@dnd-kit/core';
import { useTasks, useMoveTask } from '../hooks/useTasks';
import Column from './Column';

interface KanbanBoardProps {
  projectId: number;
}

const COLUMNS = [
  { id: 1, name: 'Backlog', color: '#6B7280' },
  { id: 2, name: 'To Do', color: '#3B82F6' },
  { id: 3, name: 'In Progress', color: '#F59E0B' },
  { id: 4, name: 'In Review', color: '#8B5CF6' },
  { id: 5, name: 'Done', color: '#10B981' },
];

export default function KanbanBoard({ projectId }: KanbanBoardProps) {
  const { data: tasks, isLoading } = useTasks(projectId);
  const moveTask = useMoveTask();

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over) return;

    const taskId = active.id as number;
    const newStatusId = over.id as number;

    moveTask.mutate({
      taskId,
      newStatusId,
      newOrder: 0
    });
  };

  if (isLoading) return <div>Loading...</div>;

  return (
    <DndContext collisionDetection={closestCorners} onDragEnd={handleDragEnd}>
      <div className="flex gap-4 p-6 h-full overflow-x-auto">
        {COLUMNS.map(column => (
          <Column
            key={column.id}
            column={column}
            tasks={tasks?.filter(t => t.statusId === column.id) || []}
          />
        ))}
      </div>
    </DndContext>
  );
}
```

### TaskCard.tsx

```tsx
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Calendar, User } from 'lucide-react';
import { Task } from '../types';

interface TaskCardProps {
  task: Task;
  onClick: () => void;
}

const priorityColors = {
  1: 'border-l-gray-400',
  2: 'border-l-blue-400',
  3: 'border-l-orange-400',
  4: 'border-l-red-500',
};

export default function TaskCard({ task, onClick }: TaskCardProps) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({
    id: task.id,
  });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      onClick={onClick}
      className={`
        bg-white rounded-lg shadow-sm p-3 cursor-pointer
        border-l-4 ${priorityColors[task.priority]}
        hover:shadow-md transition-shadow
      `}
    >
      <h4 className="font-medium text-gray-900 mb-2">{task.title}</h4>
      
      {task.description && (
        <p className="text-sm text-gray-500 mb-3 line-clamp-2">
          {task.description}
        </p>
      )}

      <div className="flex items-center justify-between text-xs text-gray-400">
        {task.dueDate && (
          <span className="flex items-center gap-1">
            <Calendar size={12} />
            {new Date(task.dueDate).toLocaleDateString()}
          </span>
        )}
        
        {task.assignee && (
          <span className="flex items-center gap-1">
            <User size={12} />
            {task.assignee.displayName}
          </span>
        )}
      </div>
    </div>
  );
}
```

### api.ts (API Service)

```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:5000/api',
});

// Add JWT token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const taskApi = {
  getByProject: (projectId: number) => 
    api.get(`/tasks/project/${projectId}`).then(r => r.data),
  
  create: (task: CreateTaskDto) => 
    api.post('/tasks', task).then(r => r.data),
  
  update: (id: number, task: UpdateTaskDto) => 
    api.put(`/tasks/${id}`, task).then(r => r.data),
  
  move: (id: number, move: MoveTaskDto) => 
    api.put(`/tasks/${id}/move`, move).then(r => r.data),
  
  delete: (id: number) => 
    api.delete(`/tasks/${id}`),
};

export const projectApi = {
  getAll: () => api.get('/projects').then(r => r.data),
  create: (project: CreateProjectDto) => api.post('/projects', project).then(r => r.data),
  // ...
};

export const authApi = {
  login: (email: string, password: string) => 
    api.post('/auth/login', { email, password }).then(r => r.data),
  register: (data: RegisterDto) => 
    api.post('/auth/register', data).then(r => r.data),
};

export default api;
```

---

## Quick Start Commands

### Backend (.NET)

```bash
# Create new project
dotnet new webapi -n TaskManager.Api
cd TaskManager.Api

# Add packages
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer

# Run migrations (after creating models)
dotnet ef migrations add InitialCreate
dotnet ef database update

# Run the API
dotnet run
```

### Frontend (React)

```bash
# Create React app with Vite
npm create vite@latest task-manager-ui -- --template react-ts
cd task-manager-ui

# Install dependencies
npm install @tanstack/react-query @dnd-kit/core @dnd-kit/sortable axios lucide-react
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Run dev server
npm run dev
```

---

## MVP Feature Checklist

### Phase 1 (Day 1-2) - Core
- [ ] Database schema created
- [ ] .NET API with basic CRUD for Tasks
- [ ] JWT authentication working
- [ ] React app scaffolded with routing

### Phase 2 (Day 3-4) - Kanban
- [ ] Kanban board displaying tasks by status
- [ ] Drag-and-drop between columns
- [ ] Create/edit task modal
- [ ] Task priority indicators

### Phase 3 (Day 5) - Polish
- [ ] Project selector/switcher
- [ ] User assignment dropdown
- [ ] Due date picker
- [ ] Basic filtering (my tasks, all tasks)

### Phase 4 (Optional)
- [ ] Task comments
- [ ] Activity log
- [ ] Email notifications
- [ ] File attachments

---

## Deployment Notes

For Azure deployment (since you're already using Azure DevOps):

1. **API**: Deploy as Azure App Service
2. **Database**: Use your existing Azure SQL or on-prem MSSQL
3. **Frontend**: Deploy as Azure Static Web App or alongside the API

```yaml
# azure-pipelines.yml (simplified)
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

stages:
  - stage: Build
    jobs:
      - job: BuildApi
        steps:
          - task: DotNetCoreCLI@2
            inputs:
              command: 'publish'
              projects: '**/*.csproj'
              arguments: '-c Release -o $(Build.ArtifactStagingDirectory)'

      - job: BuildUI
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: '18.x'
          - script: |
              cd task-manager-ui
              npm ci
              npm run build
```

---

## Questions for Your Team

Before building, decide:

1. **Auth**: Use existing Azure AD? Or simple email/password?
2. **Hosting**: Same server as FarmGenie or separate?
3. **Users**: Just your team, or clients too?
4. **Integrations**: Connect to Azure DevOps work items?

---

*This blueprint prioritizes speed-to-deploy with your existing MSSQL infrastructure. Estimated build time: 3-5 days for a competent .NET/React developer.*
