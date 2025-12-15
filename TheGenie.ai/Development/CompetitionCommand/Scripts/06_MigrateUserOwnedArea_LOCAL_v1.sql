/*
================================================================================
SCRIPT: 06_MigrateUserOwnedArea_LOCAL_v1.sql
PURPOSE: Create AreaOwnership table and migrate data in LOCAL dev environment
CREATED: 12/14/2025
AUTHOR: Competition Command Enhancement Project

TARGET: localhost\SQLEXPRESS - FarmGenie_Dev database
================================================================================
*/

USE FarmGenie_Dev;
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- ============================================================================
-- STEP 1: DROP AND CREATE AreaOwnership TABLE
-- ============================================================================

PRINT '================================================================';
PRINT 'CREATING AreaOwnership TABLE (LOCAL)';
PRINT 'Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '================================================================';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AreaOwnership')
BEGIN
    DROP TABLE dbo.AreaOwnership;
    PRINT 'Dropped existing AreaOwnership table.';
END;

CREATE TABLE dbo.AreaOwnership (
    AreaOwnershipId         INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    AreaId                  INT NOT NULL,
    PropertyTypeId          INT NOT NULL DEFAULT 0,
    AreaOwnershipTypeId     INT NOT NULL DEFAULT 1,

    -- Status & Lifecycle
    Status                  NVARCHAR(20) NOT NULL DEFAULT 'Active',
        -- Values: 'Pending', 'Active', 'Suspended', 'Ended'

    -- Request/Approval
    RequestDate             DATETIME2 NULL,
    ApprovalDate            DATETIME2 NULL,
    ApprovedByUserId        NVARCHAR(128) NULL,

    -- Ownership Period
    StartDate               DATETIME2 NULL,
    EndDate                 DATETIME2 NULL,
    EndReason               NVARCHAR(50) NULL,
        -- Values: 'Canceled', 'Expired', 'Transferred', 'AdminRemoved', 'NonPayment'

    -- Metadata
    Notes                   NVARCHAR(500) NULL,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedByUserId        NVARCHAR(128) NULL,

    -- Legacy Reference
    LegacyUserOwnedAreaId   INT NULL,

    -- Constraints
    CONSTRAINT CK_AreaOwnership_Status
        CHECK (Status IN ('Pending', 'Active', 'Suspended', 'Ended'))
);

PRINT 'Created AreaOwnership table.';

-- Indexes
CREATE INDEX IX_AreaOwnership_AspNetUserId ON dbo.AreaOwnership(AspNetUserId);
CREATE INDEX IX_AreaOwnership_AreaId ON dbo.AreaOwnership(AreaId);
CREATE INDEX IX_AreaOwnership_Status ON dbo.AreaOwnership(Status);
CREATE UNIQUE INDEX IX_AreaOwnership_User_Area_PropType 
    ON dbo.AreaOwnership(AspNetUserId, AreaId, PropertyTypeId) 
    WHERE Status != 'Ended';

PRINT 'Created indexes.';

-- ============================================================================
-- STEP 2: MIGRATE DATA FROM UserOwnedArea
-- ============================================================================

PRINT '';
PRINT '================================================================';
PRINT 'MIGRATING DATA FROM UserOwnedArea';
PRINT '================================================================';

-- Get last campaign date for each user
;WITH UserCampaignActivity AS (
    SELECT 
        AspNetUserId,
        MAX(CreateDate) AS LastCampaignDate
    FROM dbo.PropertyCast
    WHERE PropertyCastTypeId = 1  -- CC only
    GROUP BY AspNetUserId
)
INSERT INTO dbo.AreaOwnership (
    AspNetUserId,
    AreaId,
    PropertyTypeId,
    AreaOwnershipTypeId,
    Status,
    RequestDate,
    ApprovalDate,
    StartDate,
    Notes,
    CreatedDate,
    ModifiedDate,
    LegacyUserOwnedAreaId
)
SELECT 
    uoa.AspNetUserId,
    uoa.AreaId,
    uoa.PropertyTypeId,
    uoa.AreaOwnershipTypeId,
    -- Status Logic based on campaign activity
    CASE 
        WHEN uca.LastCampaignDate >= '2025-12-01' THEN 'Active'
        WHEN uca.LastCampaignDate IS NOT NULL THEN 'Suspended'
        ELSE 'Pending'
    END AS Status,
    -- Request/Approval dates from original create
    uoa.CreateDate AS RequestDate,
    uoa.CreateDate AS ApprovalDate,
    uoa.CreateDate AS StartDate,
    -- Notes
    CASE 
        WHEN uca.LastCampaignDate IS NULL THEN 'Migrated: Never ran campaign'
        WHEN uca.LastCampaignDate < '2025-12-01' THEN 
            'Migrated: Last campaign ' + CONVERT(VARCHAR, uca.LastCampaignDate, 120)
        ELSE 'Migrated: Active as of ' + CONVERT(VARCHAR, GETDATE(), 120)
    END AS Notes,
    -- Metadata
    GETUTCDATE() AS CreatedDate,
    GETUTCDATE() AS ModifiedDate,
    uoa.UserOwnedAreaId AS LegacyUserOwnedAreaId
FROM dbo.UserOwnedArea uoa
LEFT JOIN UserCampaignActivity uca ON uca.AspNetUserId = uoa.AspNetUserId;

DECLARE @rowsMigrated INT = @@ROWCOUNT;
PRINT 'Migrated ' + CAST(@rowsMigrated AS VARCHAR) + ' records from UserOwnedArea.';

-- ============================================================================
-- STEP 3: VALIDATION
-- ============================================================================

PRINT '';
PRINT '================================================================';
PRINT 'VALIDATION';
PRINT '================================================================';

-- Counts
DECLARE @sourceCount INT, @targetCount INT;
SELECT @sourceCount = COUNT(*) FROM dbo.UserOwnedArea;
SELECT @targetCount = COUNT(*) FROM dbo.AreaOwnership;

PRINT 'Source (UserOwnedArea): ' + CAST(@sourceCount AS VARCHAR);
PRINT 'Target (AreaOwnership): ' + CAST(@targetCount AS VARCHAR);

IF @sourceCount = @targetCount
    PRINT 'VALIDATION PASSED: Counts match!';
ELSE
    PRINT 'VALIDATION FAILED: Counts do not match!';

-- Status breakdown
PRINT '';
PRINT 'STATUS BREAKDOWN:';

SELECT 
    Status,
    COUNT(DISTINCT AspNetUserId) AS Users,
    COUNT(*) AS Areas
FROM dbo.AreaOwnership
GROUP BY Status
ORDER BY 
    CASE Status 
        WHEN 'Active' THEN 1 
        WHEN 'Suspended' THEN 2 
        WHEN 'Pending' THEN 3 
        WHEN 'Ended' THEN 4
    END;

-- Sample data
PRINT '';
PRINT 'SAMPLE MIGRATED DATA:';

SELECT TOP 10
    ao.AreaOwnershipId,
    ao.AspNetUserId,
    ao.AreaId,
    ao.Status,
    ao.StartDate,
    ao.Notes,
    ao.LegacyUserOwnedAreaId
FROM dbo.AreaOwnership ao
ORDER BY ao.Status, ao.AreaOwnershipId;

PRINT '';
PRINT '================================================================';
PRINT 'MIGRATION COMPLETE';
PRINT '================================================================';
GO

