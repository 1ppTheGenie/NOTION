# Database Specialist - Action Plan (URGENT)

**From:** JR (Project Manager)  
**To:** Database Specialist  
**Date:** 01/14/2026 3:55 PM  
**Status:** 🚨 **START NOW**

---

## 🎯 YOUR TASK

**Create NEW TaskManager database on LOCALHOST SQL Server**  
**Time:** 3-5 minutes  
**Blocks:** Backend API and Frontend UI (they're waiting on you)

---

## 📋 STEP-BY-STEP INSTRUCTIONS

### Step 1: Open the Blueprint

**File:** `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`  
**Lines to use:** 31-139 (the SQL schema script)

### Step 2: Connect to LOCALHOST SQL Server

- **NOT production** (192.168.29.45)
- **LOCALHOST only** - your local SQL Server instance
- Use SQL Server Management Studio or Azure Data Studio
- Connect to: `localhost` or `(local)` or `.`

### Step 3: Create the Database

Run this SQL script (from blueprint lines 31-139):

```sql
-- Create NEW database on LOCALHOST
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
    Status NVARCHAR(20) DEFAULT 'Active',
    OwnerId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Task statuses as a lookup table
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

-- Tasks table
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

-- Task comments
CREATE TABLE TaskComments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TaskId INT NOT NULL FOREIGN KEY REFERENCES Tasks(Id) ON DELETE CASCADE,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Content NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Project members
CREATE TABLE ProjectMembers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId INT NOT NULL FOREIGN KEY REFERENCES Projects(Id) ON DELETE CASCADE,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Role NVARCHAR(20) DEFAULT 'Member',
    JoinedAt DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_ProjectMember UNIQUE (ProjectId, UserId)
);

-- Indexes
CREATE INDEX IX_Tasks_ProjectId ON Tasks(ProjectId);
CREATE INDEX IX_Tasks_StatusId ON Tasks(StatusId);
CREATE INDEX IX_Tasks_AssigneeId ON Tasks(AssigneeId);
CREATE INDEX IX_ProjectMembers_UserId ON ProjectMembers(UserId);

-- Triggers
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

### Step 4: Verify Tables Created

Run this to verify:

```sql
USE TaskManager;
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
```

**Expected tables:**

- Users
- Projects
- TaskStatuses
- Tasks
- TaskComments
- ProjectMembers

### Step 5: Signal Completion

**Update:** `AgentCollaboration/HANDOFFS_v1.md`

Add this entry:

```markdown
### Handoff #1 - Database Specialist → Backend API Specialist

**Date:** 01/14/2026 [TIME]
**From:** Database Specialist
**To:** Backend API Specialist
**Status:** ✅ Complete

**Deliverable:** TaskManager database created on LOCALHOST SQL Server

**Location:**

- Database: TaskManager (on localhost)
- Connection: localhost (or (local) or .)
- All tables created: Users, Projects, TaskStatuses, Tasks, TaskComments, ProjectMembers

**Key Information:**

- Database is ready for .NET 8 API connection
- Use connection string: Server=localhost;Database=TaskManager;Trusted_Connection=True;TrustServerCertificate=True;
- All indexes and triggers created

**Next Steps:**

- Backend API Specialist can now build .NET 8 API and connect to this database
```

**Also update:** `AgentStatus/AGENT_STATUS_DATABASE_v1.md`

- Mark task as complete
- Update status to "✅ Database Ready"

---

## ✅ SUCCESS CRITERIA

- [ ] TaskManager database created on LOCALHOST
- [ ] All 6 tables created (Users, Projects, TaskStatuses, Tasks, TaskComments, ProjectMembers)
- [ ] TaskStatuses has 5 rows (Backlog, To Do, In Progress, In Review, Done)
- [ ] Indexes created
- [ ] Triggers created
- [ ] Handoff signal sent to Backend API Specialist

---

## 🚨 IMPORTANT NOTES

1. **LOCALHOST ONLY** - Do NOT use production SQL (192.168.29.45)
2. **NEW Database** - Create fresh, don't modify existing TaskManager if it exists
3. **Quick Task** - This should take 3-5 minutes
4. **Blocks Others** - Backend API and Frontend UI are waiting on you

---

## 📞 IF YOU GET STUCK

1. Check blueprint: `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md` (lines 31-139)
2. Document blocker in: `AgentCollaboration/BLOCKERS_v1.md`
3. Tag JR (Project Manager) for help

---

**Status:** 🚀 **START NOW - 3-5 MINUTE TASK**
