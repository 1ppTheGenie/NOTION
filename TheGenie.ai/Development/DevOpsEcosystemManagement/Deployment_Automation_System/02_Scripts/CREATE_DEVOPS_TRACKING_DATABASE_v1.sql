-- =============================================
-- DevOps Tracking Database - Local Standalone
-- Completely isolated from FarmGenie/Enterprise
-- =============================================
-- Version: 1.0
-- Created: 01/12/2026 10:45 AM
-- Author: Danny
-- Purpose: Create local check-in and deployment tracking database
-- Location: Local SQL Server (localhost) - COMPLETELY SEPARATE
-- =============================================

USE master;
GO

-- Create database (if it doesn't exist)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DevOpsTracking')
BEGIN
    CREATE DATABASE DevOpsTracking;
    PRINT '✅ Database DevOpsTracking created successfully';
END
ELSE
BEGIN
    PRINT '⚠️  Database DevOpsTracking already exists';
END
GO

-- Switch to DevOpsTracking database
USE DevOpsTracking;
GO

-- Grant permissions to current user (Windows Authentication)
-- This ensures the user who runs the script has full access
DECLARE @CurrentUser NVARCHAR(128) = SUSER_SNAME();
EXEC('CREATE USER [' + @CurrentUser + '] FOR LOGIN [' + @CurrentUser + ']');
EXEC('ALTER ROLE db_owner ADD MEMBER [' + @CurrentUser + ']');
PRINT '✅ Permissions granted to current user: ' + @CurrentUser;
GO

-- =============================================
-- Table 1: CheckInForms
-- Main check-in records
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CheckInForms')
BEGIN
    CREATE TABLE CheckInForms (
        CheckInId INT PRIMARY KEY IDENTITY(1,1),
        FixName NVARCHAR(255) NOT NULL,
        AgentName NVARCHAR(100) NOT NULL,
        CheckInDate DATETIME NOT NULL,
        ChangesetNumber INT NULL,
        Priority NVARCHAR(20) NOT NULL, -- Emergency, Sprint, Hotfix
        DeploymentTarget NVARCHAR(100) NOT NULL, -- Staging, Production
        Status NVARCHAR(20) NOT NULL, -- Pending, Approved, Rejected, Deployed, RolledBack
        FormPath NVARCHAR(500) NOT NULL, -- Link to original markdown file
        BackupLocation NVARCHAR(500) NULL, -- Pre-commit backup location
        BuildId NVARCHAR(100) NULL, -- Build ID from pre-check-in QC
        BuildStatus NVARCHAR(20) NULL, -- SUCCESS, FAILED
        CheckInComment NVARCHAR(MAX) NULL, -- Full check-in comment
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    -- Create index on FixName for quick lookups
    CREATE INDEX IX_CheckInForms_FixName ON CheckInForms(FixName);
    
    -- Create index on AgentName
    CREATE INDEX IX_CheckInForms_AgentName ON CheckInForms(AgentName);
    
    -- Create index on CheckInDate
    CREATE INDEX IX_CheckInForms_CheckInDate ON CheckInForms(CheckInDate);
    
    -- Create index on Status
    CREATE INDEX IX_CheckInForms_Status ON CheckInForms(Status);
    
    PRINT '✅ Table CheckInForms created successfully';
END
ELSE
BEGIN
    PRINT '⚠️  Table CheckInForms already exists';
END
GO

-- =============================================
-- Table 2: CheckInFiles
-- File-by-file detail (one-to-many with CheckInForms)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CheckInFiles')
BEGIN
    CREATE TABLE CheckInFiles (
        FileId INT PRIMARY KEY IDENTITY(1,1),
        CheckInId INT NOT NULL FOREIGN KEY REFERENCES CheckInForms(CheckInId) ON DELETE CASCADE,
        FilePath NVARCHAR(500) NOT NULL,
        LinesModified NVARCHAR(100) NULL, -- e.g., "12-45", "100-120, 200-205"
        ChangeType NVARCHAR(50) NOT NULL, -- Modified, Added, Deleted
        WhatChanged NVARCHAR(MAX) NULL, -- Description of what changed
        WhyChanged NVARCHAR(MAX) NULL, -- Reason for change
        CodeChangesOld NVARCHAR(MAX) NULL, -- Old code (if applicable)
        CodeChangesNew NVARCHAR(MAX) NULL, -- New code (if applicable)
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    -- Create index on CheckInId for joins
    CREATE INDEX IX_CheckInFiles_CheckInId ON CheckInFiles(CheckInId);
    
    -- Create index on FilePath for "find all fixes to a file" queries
    CREATE INDEX IX_CheckInFiles_FilePath ON CheckInFiles(FilePath);
    
    PRINT '✅ Table CheckInFiles created successfully';
END
ELSE
BEGIN
    PRINT '⚠️  Table CheckInFiles already exists';
END
GO

-- =============================================
-- Table 3: CheckInDeployments
-- Deployment-level records (groups multiple check-ins)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CheckInDeployments')
BEGIN
    CREATE TABLE CheckInDeployments (
        DeploymentId INT PRIMARY KEY IDENTITY(1,1),
        DeploymentName NVARCHAR(255) NOT NULL, -- e.g., "Sprint_20260112", "Emergency_20260112"
        DeploymentType NVARCHAR(50) NOT NULL, -- Emergency, Sprint, Hotfix
        DeploymentDate DATETIME NOT NULL,
        BuildNumber NVARCHAR(100) NULL, -- Azure DevOps build number
        ReleaseNumber NVARCHAR(100) NULL, -- Azure DevOps release number
        Status NVARCHAR(20) NOT NULL, -- Pending, Deployed, Failed, RolledBack
        ChangelogPublic NVARCHAR(MAX) NULL, -- Generated public changelog
        ChangelogInternal NVARCHAR(MAX) NULL, -- Internal changelog (detailed)
        DeploymentNotes NVARCHAR(MAX) NULL, -- Additional notes
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    -- Create index on DeploymentName
    CREATE INDEX IX_CheckInDeployments_DeploymentName ON CheckInDeployments(DeploymentName);
    
    -- Create index on DeploymentDate
    CREATE INDEX IX_CheckInDeployments_DeploymentDate ON CheckInDeployments(DeploymentDate);
    
    -- Create index on Status
    CREATE INDEX IX_CheckInDeployments_Status ON CheckInDeployments(Status);
    
    PRINT '✅ Table CheckInDeployments created successfully';
END
ELSE
BEGIN
    PRINT '⚠️  Table CheckInDeployments already exists';
END
GO

-- =============================================
-- Table 4: CheckInDeploymentLinks
-- Links check-ins to deployments (many-to-many)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CheckInDeploymentLinks')
BEGIN
    CREATE TABLE CheckInDeploymentLinks (
        LinkId INT PRIMARY KEY IDENTITY(1,1),
        CheckInId INT NOT NULL FOREIGN KEY REFERENCES CheckInForms(CheckInId) ON DELETE CASCADE,
        DeploymentId INT NOT NULL FOREIGN KEY REFERENCES CheckInDeployments(DeploymentId) ON DELETE CASCADE,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Prevent duplicate links
        CONSTRAINT UQ_CheckInDeploymentLinks_CheckIn_Deployment UNIQUE (CheckInId, DeploymentId)
    );
    
    -- Create index on CheckInId
    CREATE INDEX IX_CheckInDeploymentLinks_CheckInId ON CheckInDeploymentLinks(CheckInId);
    
    -- Create index on DeploymentId
    CREATE INDEX IX_CheckInDeploymentLinks_DeploymentId ON CheckInDeploymentLinks(DeploymentId);
    
    PRINT '✅ Table CheckInDeploymentLinks created successfully';
END
ELSE
BEGIN
    PRINT '⚠️  Table CheckInDeploymentLinks already exists';
END
GO

-- =============================================
-- Verification: Show all tables created
-- =============================================
PRINT '';
PRINT '========================================';
PRINT '✅ DATABASE CREATION COMPLETE';
PRINT '========================================';
PRINT 'Database: DevOpsTracking';
PRINT 'Location: Local SQL Server (localhost)';
PRINT 'Status: COMPLETELY ISOLATED from FarmGenie';
PRINT '';
PRINT 'Tables Created:';
SELECT 
    TABLE_NAME AS TableName,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
PRINT '';
PRINT '✅ Ready for use!';
GO
