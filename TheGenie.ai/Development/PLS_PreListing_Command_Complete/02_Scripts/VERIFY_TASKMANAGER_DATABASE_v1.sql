-- =====================================================
-- VERIFY TASKMANAGER DATABASE
-- Purpose: Verify all tables, indexes, and data created successfully
-- =====================================================

USE TaskManager;
GO

PRINT '========================================';
PRINT 'TaskManager Database Verification';
PRINT '========================================';
PRINT '';

-- Verify Tables
PRINT '1. TABLES:';
SELECT 
    TABLE_NAME AS TableName,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

PRINT '';
PRINT 'Expected Tables: Users, Projects, TaskStatuses, Tasks, TaskComments, ProjectMembers';
PRINT '';

-- Verify TaskStatuses Data
PRINT '2. TASK STATUSES (should have 5 rows):';
SELECT Id, Name, DisplayOrder, Color
FROM TaskStatuses
ORDER BY DisplayOrder;

PRINT '';
PRINT 'Expected: Backlog, To Do, In Progress, In Review, Done';
PRINT '';

-- Verify Indexes
PRINT '3. INDEXES:';
SELECT 
    i.name AS IndexName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.type_desc AS IndexType
FROM sys.indexes i
WHERE i.object_id IN (
    OBJECT_ID('Users'),
    OBJECT_ID('Projects'),
    OBJECT_ID('TaskStatuses'),
    OBJECT_ID('Tasks'),
    OBJECT_ID('TaskComments'),
    OBJECT_ID('ProjectMembers')
)
AND i.name IS NOT NULL
AND i.is_primary_key = 0
ORDER BY OBJECT_NAME(i.object_id), i.name;

PRINT '';
PRINT 'Expected Indexes:';
PRINT '  - IX_Tasks_ProjectId';
PRINT '  - IX_Tasks_StatusId';
PRINT '  - IX_Tasks_AssigneeId';
PRINT '  - IX_ProjectMembers_UserId';
PRINT '';

-- Verify Triggers
PRINT '4. TRIGGERS:';
SELECT 
    t.name AS TriggerName,
    OBJECT_NAME(t.parent_id) AS TableName
FROM sys.triggers t
WHERE t.parent_id IN (
    OBJECT_ID('Tasks'),
    OBJECT_ID('Projects')
)
ORDER BY OBJECT_NAME(t.parent_id), t.name;

PRINT '';
PRINT 'Expected Triggers:';
PRINT '  - TR_Tasks_UpdateTimestamp';
PRINT '  - TR_Projects_UpdateTimestamp';
PRINT '';

-- Verify Foreign Keys
PRINT '5. FOREIGN KEY RELATIONSHIPS:';
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS FromTable,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS FromColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ToTable,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ToColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fc ON fk.object_id = fc.constraint_object_id
WHERE fk.parent_object_id IN (
    OBJECT_ID('Projects'),
    OBJECT_ID('Tasks'),
    OBJECT_ID('TaskComments'),
    OBJECT_ID('ProjectMembers')
)
ORDER BY OBJECT_NAME(fk.parent_object_id), fk.name;

PRINT '';
PRINT '========================================';
PRINT 'Verification Complete!';
PRINT '========================================';
GO
