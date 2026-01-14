-- =====================================================
-- TASK MANAGER DATABASE SCHEMA
-- Created: 01/14/2026
-- Purpose: Create TaskManager database on LOCALHOST for PM system
-- =====================================================

-- Create NEW database on LOCALHOST
IF DB_ID('TaskManager') IS NOT NULL
BEGIN
    PRINT 'TaskManager database already exists. Dropping and recreating...';
    ALTER DATABASE TaskManager SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TaskManager;
END
GO

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

PRINT '';
PRINT '========================================';
PRINT 'TaskManager Database Created Successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Tables Created:';
PRINT '  - Users';
PRINT '  - Projects';
PRINT '  - TaskStatuses (5 default statuses inserted)';
PRINT '  - Tasks';
PRINT '  - TaskComments';
PRINT '  - ProjectMembers';
PRINT '';
PRINT 'Indexes Created: 4';
PRINT 'Triggers Created: 2';
PRINT '';
PRINT 'Database is ready for .NET 8 API connection!';
PRINT 'Connection String: Server=localhost;Database=TaskManager;Trusted_Connection=True;TrustServerCertificate=True;';
GO
