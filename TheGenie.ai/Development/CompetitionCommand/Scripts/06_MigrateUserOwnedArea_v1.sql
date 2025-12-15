/*
================================================================================
SCRIPT: 06_MigrateUserOwnedArea_v1.sql
PURPOSE: Migrate data from UserOwnedArea to new AreaOwnership table with status
CREATED: 12/14/2025
AUTHOR: Competition Command Enhancement Project

LOGIC:
- ACTIVE: User has run a CC campaign since December 1, 2025
- INACTIVE: User has CC areas but no campaign since Dec 1 OR never ran campaign
- Uses campaign activity as proxy for billing status

NOTE: Run on PRODUCTION (192.168.29.45) FarmGenie database
================================================================================
*/

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- ============================================================================
-- STEP 1: ANALYSIS (Preview Mode - No Changes)
-- ============================================================================

PRINT '================================================================';
PRINT 'MIGRATION ANALYSIS: UserOwnedArea → AreaOwnership';
PRINT 'Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '================================================================';
PRINT '';

-- Summary by Status
PRINT 'STATUS DISTRIBUTION:';
PRINT '';

WITH UserActivity AS (
    SELECT 
        uoa.AspNetUserId,
        uoa.UserOwnedAreaId,
        uoa.AreaId,
        uoa.PropertyTypeId,
        uoa.AreaOwnershipTypeId,
        uoa.CreateDate,
        MAX(pc.CreateDate) AS LastCampaignDate,
        CASE 
            WHEN MAX(pc.CreateDate) >= '2025-12-01' THEN 'Active'
            WHEN MAX(pc.CreateDate) IS NOT NULL THEN 'Suspended'  -- Had campaigns but stopped
            ELSE 'Pending'  -- Never ran a campaign
        END AS ProposedStatus
    FROM dbo.UserOwnedArea uoa
    LEFT JOIN dbo.PropertyCast pc 
        ON pc.AspNetUserId = uoa.AspNetUserId 
        AND pc.PropertyCastTypeId = 1  -- CC only
    GROUP BY 
        uoa.AspNetUserId,
        uoa.UserOwnedAreaId,
        uoa.AreaId,
        uoa.PropertyTypeId,
        uoa.AreaOwnershipTypeId,
        uoa.CreateDate
)
SELECT 
    ProposedStatus AS [Status],
    COUNT(DISTINCT AspNetUserId) AS [Users],
    COUNT(*) AS [Areas],
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,1)) AS [Pct]
FROM UserActivity
GROUP BY ProposedStatus
ORDER BY 
    CASE ProposedStatus 
        WHEN 'Active' THEN 1 
        WHEN 'Suspended' THEN 2 
        WHEN 'Pending' THEN 3 
    END;

PRINT '';
PRINT 'DETAILED BREAKDOWN BY USER:';
PRINT '';

-- Detailed by user with WHMCS status
WITH UserActivity AS (
    SELECT 
        uoa.AspNetUserId,
        u.Email,
        uw.WhmcsClientId,
        COUNT(DISTINCT uoa.AreaId) AS OwnedAreas,
        MAX(pc.CreateDate) AS LastCampaign,
        DATEDIFF(DAY, ISNULL(MAX(pc.CreateDate), uoa.CreateDate), GETUTCDATE()) AS DaysSinceActivity,
        CASE 
            WHEN MAX(pc.CreateDate) >= '2025-12-01' THEN 'Active'
            WHEN MAX(pc.CreateDate) IS NOT NULL THEN 'Suspended'
            ELSE 'Pending'
        END AS ProposedStatus
    FROM dbo.UserOwnedArea uoa
    INNER JOIN dbo.AspNetUsers u ON u.Id = uoa.AspNetUserId
    LEFT JOIN dbo.UserWhmcs uw ON uw.AspNetUserId = u.Id
    LEFT JOIN dbo.PropertyCast pc 
        ON pc.AspNetUserId = uoa.AspNetUserId 
        AND pc.PropertyCastTypeId = 1
    GROUP BY uoa.AspNetUserId, u.Email, uw.WhmcsClientId, uoa.CreateDate
)
SELECT 
    Email,
    WhmcsClientId,
    OwnedAreas,
    ProposedStatus,
    LastCampaign,
    DaysSinceActivity
FROM UserActivity
ORDER BY 
    CASE ProposedStatus 
        WHEN 'Active' THEN 1 
        WHEN 'Suspended' THEN 2 
        WHEN 'Pending' THEN 3 
    END,
    OwnedAreas DESC;

-- ============================================================================
-- STEP 2: CREATE MIGRATION TABLE (if not exists)
-- ============================================================================

PRINT '';
PRINT '================================================================';
PRINT 'MIGRATION TABLE CREATION';
PRINT '================================================================';

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AreaOwnership')
BEGIN
    PRINT 'Creating AreaOwnership table...';
    
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

    -- Indexes
    CREATE INDEX IX_AreaOwnership_AspNetUserId ON dbo.AreaOwnership(AspNetUserId);
    CREATE INDEX IX_AreaOwnership_AreaId ON dbo.AreaOwnership(AreaId);
    CREATE INDEX IX_AreaOwnership_Status ON dbo.AreaOwnership(Status);
    CREATE UNIQUE INDEX IX_AreaOwnership_User_Area_PropType 
        ON dbo.AreaOwnership(AspNetUserId, AreaId, PropertyTypeId) 
        WHERE Status != 'Ended';

    PRINT 'AreaOwnership table created successfully.';
END
ELSE
BEGIN
    PRINT 'AreaOwnership table already exists. Checking for LegacyUserOwnedAreaId column...';
    
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AreaOwnership') AND name = 'LegacyUserOwnedAreaId')
    BEGIN
        ALTER TABLE dbo.AreaOwnership ADD LegacyUserOwnedAreaId INT NULL;
        PRINT 'Added LegacyUserOwnedAreaId column.';
    END
END;

-- ============================================================================
-- STEP 3: EXECUTE MIGRATION (Uncomment to run)
-- ============================================================================

/*
PRINT '';
PRINT '================================================================';
PRINT 'EXECUTING MIGRATION';
PRINT '================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    -- Insert migrated records
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
        -- Status Logic
        CASE 
            WHEN activity.LastCampaignDate >= '2025-12-01' THEN 'Active'
            WHEN activity.LastCampaignDate IS NOT NULL THEN 'Suspended'
            ELSE 'Pending'
        END AS Status,
        -- Request/Approval dates from original create
        uoa.CreateDate AS RequestDate,
        uoa.CreateDate AS ApprovalDate,  -- Assumed approved when created
        uoa.CreateDate AS StartDate,
        -- Notes
        CASE 
            WHEN activity.LastCampaignDate IS NULL THEN 'Migrated: Never ran campaign'
            WHEN activity.LastCampaignDate < '2025-12-01' THEN 
                'Migrated: Last campaign ' + CONVERT(VARCHAR, activity.LastCampaignDate, 120)
            ELSE 'Migrated: Active as of ' + CONVERT(VARCHAR, GETDATE(), 120)
        END AS Notes,
        -- Metadata
        GETUTCDATE() AS CreatedDate,
        GETUTCDATE() AS ModifiedDate,
        uoa.UserOwnedAreaId AS LegacyUserOwnedAreaId
    FROM dbo.UserOwnedArea uoa
    CROSS APPLY (
        SELECT MAX(pc.CreateDate) AS LastCampaignDate
        FROM dbo.PropertyCast pc 
        WHERE pc.AspNetUserId = uoa.AspNetUserId 
          AND pc.PropertyCastTypeId = 1
    ) activity
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.AreaOwnership ao 
        WHERE ao.LegacyUserOwnedAreaId = uoa.UserOwnedAreaId
    );

    DECLARE @rowsMigrated INT = @@ROWCOUNT;

    PRINT 'Migrated ' + CAST(@rowsMigrated AS VARCHAR) + ' records.';

    -- Verify counts match
    DECLARE @sourceCount INT, @targetCount INT;
    SELECT @sourceCount = COUNT(*) FROM dbo.UserOwnedArea;
    SELECT @targetCount = COUNT(*) FROM dbo.AreaOwnership;

    IF @sourceCount = @targetCount
    BEGIN
        PRINT 'Verification PASSED: Source (' + CAST(@sourceCount AS VARCHAR) + ') = Target (' + CAST(@targetCount AS VARCHAR) + ')';
        COMMIT TRANSACTION;
        PRINT 'Migration committed successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Verification FAILED: Source (' + CAST(@sourceCount AS VARCHAR) + ') != Target (' + CAST(@targetCount AS VARCHAR) + ')';
        ROLLBACK TRANSACTION;
        PRINT 'Migration rolled back.';
    END;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    PRINT 'Migration rolled back.';
END CATCH;
*/

-- ============================================================================
-- STEP 4: POST-MIGRATION VALIDATION
-- ============================================================================

PRINT '';
PRINT '================================================================';
PRINT 'POST-MIGRATION VALIDATION QUERIES';
PRINT '================================================================';
PRINT '';
PRINT 'After migration, run these queries to verify:';
PRINT '';
PRINT '-- Status summary:';
PRINT 'SELECT Status, COUNT(*) AS Areas FROM dbo.AreaOwnership GROUP BY Status;';
PRINT '';
PRINT '-- Compare with source:';
PRINT 'SELECT ';
PRINT '    (SELECT COUNT(*) FROM dbo.UserOwnedArea) AS SourceCount,';
PRINT '    (SELECT COUNT(*) FROM dbo.AreaOwnership) AS TargetCount;';
PRINT '';
PRINT '-- View migrated data:';
PRINT 'SELECT ao.*, u.Email FROM dbo.AreaOwnership ao';
PRINT 'INNER JOIN dbo.AspNetUsers u ON u.Id = ao.AspNetUserId';
PRINT 'ORDER BY ao.Status, ao.CreatedDate DESC;';

PRINT '';
PRINT '================================================================';
PRINT 'MIGRATION SCRIPT COMPLETE (Preview Mode)';
PRINT 'To execute: Uncomment STEP 3 and run again';
PRINT '================================================================';
GO

