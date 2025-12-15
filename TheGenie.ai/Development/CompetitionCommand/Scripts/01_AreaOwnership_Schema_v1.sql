-- ============================================
-- Competition Command: Area Ownership Schema
-- Version 1.0 | Created: 12/14/2025
-- Database: FarmGenie_Dev
-- ============================================

USE FarmGenie_Dev;
GO

PRINT 'Creating AreaOwnership Schema for FarmGenie_Dev...';
PRINT '----------------------------------------------------';

-- ============================================
-- TABLE: AreaOwnership
-- Replaces UserOwnedArea with soft deletes
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AreaOwnership')
BEGIN
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
        
        -- Constraints (FK removed for dev - no AspNetUsers table yet)
        CONSTRAINT CK_AreaOwnership_Status 
            CHECK (Status IN ('Pending', 'Active', 'Suspended', 'Ended'))
    );

    PRINT '✓ Created table: AreaOwnership';
END
ELSE
BEGIN
    PRINT '• Table AreaOwnership already exists - skipping';
END
GO

-- Indexes for AreaOwnership
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnership_AspNetUserId')
    CREATE INDEX IX_AreaOwnership_AspNetUserId ON dbo.AreaOwnership(AspNetUserId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnership_AreaId')
    CREATE INDEX IX_AreaOwnership_AreaId ON dbo.AreaOwnership(AreaId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnership_Status')
    CREATE INDEX IX_AreaOwnership_Status ON dbo.AreaOwnership(Status);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnership_AreaId_Status')
    CREATE INDEX IX_AreaOwnership_AreaId_Status ON dbo.AreaOwnership(AreaId, Status);

-- Unique constraint: One active owner per Area + PropertyType + OwnershipType
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnership_UniqueActive')
    CREATE UNIQUE INDEX IX_AreaOwnership_UniqueActive 
        ON dbo.AreaOwnership(AreaId, PropertyTypeId, AreaOwnershipTypeId) 
        WHERE Status = 'Active';

PRINT '✓ Created indexes for AreaOwnership';
GO

-- ============================================
-- TABLE: AreaOwnershipHistory
-- Audit trail for all ownership changes
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AreaOwnershipHistory')
BEGIN
    CREATE TABLE dbo.AreaOwnershipHistory (
        AreaOwnershipHistoryId  INT IDENTITY(1,1) PRIMARY KEY,
        AreaOwnershipId         INT NOT NULL,
        
        -- Action Details
        Action                  NVARCHAR(30) NOT NULL,
            -- Values: 'Created', 'Approved', 'Activated', 'Suspended', 
            --         'Resumed', 'Ended', 'Modified', 'Transferred'
        PreviousStatus          NVARCHAR(20) NULL,
        NewStatus               NVARCHAR(20) NULL,
        
        -- Who & When
        ActionByUserId          NVARCHAR(128) NULL,
        ActionDate              DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        -- Context
        Notes                   NVARCHAR(500) NULL,
        AdditionalData          NVARCHAR(MAX) NULL, -- JSON for extra context
        
        CONSTRAINT FK_AreaOwnershipHistory_AreaOwnership 
            FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId)
    );

    PRINT '✓ Created table: AreaOwnershipHistory';
END
ELSE
BEGIN
    PRINT '• Table AreaOwnershipHistory already exists - skipping';
END
GO

-- Indexes for AreaOwnershipHistory
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnershipHistory_AreaOwnershipId')
    CREATE INDEX IX_AreaOwnershipHistory_AreaOwnershipId 
        ON dbo.AreaOwnershipHistory(AreaOwnershipId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnershipHistory_ActionDate')
    CREATE INDEX IX_AreaOwnershipHistory_ActionDate 
        ON dbo.AreaOwnershipHistory(ActionDate);

PRINT '✓ Created indexes for AreaOwnershipHistory';
GO

-- ============================================
-- TABLE: AreaCampaignHistory
-- Tracks all CC campaign activity per ownership
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AreaCampaignHistory')
BEGIN
    CREATE TABLE dbo.AreaCampaignHistory (
        AreaCampaignHistoryId   INT IDENTITY(1,1) PRIMARY KEY,
        AreaOwnershipId         INT NOT NULL,
        
        -- Campaign Reference
        PropertyCastId          INT NULL,           -- Link to PropertyCast execution
        PropertyCollectionDetailId INT NULL,        -- Link to campaign definition
        
        -- Campaign Details
        CampaignDate            DATETIME2 NOT NULL,
        PropertyTypeId          INT NOT NULL DEFAULT 0,
        
        -- Message Metrics
        MessagesSent            INT NOT NULL DEFAULT 0,
        MessagesDelivered       INT NOT NULL DEFAULT 0,
        MessagesFailed          INT NOT NULL DEFAULT 0,
        
        -- Engagement Metrics
        Clicks                  INT NOT NULL DEFAULT 0,
        CTASubmitted            INT NOT NULL DEFAULT 0,
        CTAVerified             INT NOT NULL DEFAULT 0,
        AgentNotifications      INT NOT NULL DEFAULT 0,
        
        -- Opt-Out Tracking
        OptOuts                 INT NOT NULL DEFAULT 0,
        
        -- Cost Tracking
        TwilioCost              DECIMAL(10,4) NOT NULL DEFAULT 0,
        AgentNotifyCost         DECIMAL(10,4) NOT NULL DEFAULT 0,
        TotalCost               AS (TwilioCost + AgentNotifyCost) PERSISTED,
        
        -- Metadata
        CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_AreaCampaignHistory_AreaOwnership 
            FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId)
    );

    PRINT '✓ Created table: AreaCampaignHistory';
END
ELSE
BEGIN
    PRINT '• Table AreaCampaignHistory already exists - skipping';
END
GO

-- Indexes for AreaCampaignHistory
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaCampaignHistory_AreaOwnershipId')
    CREATE INDEX IX_AreaCampaignHistory_AreaOwnershipId 
        ON dbo.AreaCampaignHistory(AreaOwnershipId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaCampaignHistory_CampaignDate')
    CREATE INDEX IX_AreaCampaignHistory_CampaignDate 
        ON dbo.AreaCampaignHistory(CampaignDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaCampaignHistory_PropertyCastId')
    CREATE INDEX IX_AreaCampaignHistory_PropertyCastId 
        ON dbo.AreaCampaignHistory(PropertyCastId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaCampaignHistory_Ownership_Date')
    CREATE INDEX IX_AreaCampaignHistory_Ownership_Date 
        ON dbo.AreaCampaignHistory(AreaOwnershipId, CampaignDate);

PRINT '✓ Created indexes for AreaCampaignHistory';
GO

-- ============================================
-- TABLE: AreaWaitlist
-- Queue for users waiting for areas
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AreaWaitlist')
BEGIN
    CREATE TABLE dbo.AreaWaitlist (
        AreaWaitlistId          INT IDENTITY(1,1) PRIMARY KEY,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        AreaId                  INT NOT NULL,
        PropertyTypeId          INT NOT NULL DEFAULT 0,
        AreaOwnershipTypeId     INT NOT NULL DEFAULT 1,
        
        -- Queue Position
        QueuePosition           INT NOT NULL,
        
        -- Status & Lifecycle
        Status                  NVARCHAR(20) NOT NULL DEFAULT 'Waiting',
            -- Values: 'Waiting', 'Notified', 'Accepted', 'Expired', 'Canceled'
        
        -- Dates
        RequestDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        NotifiedDate            DATETIME2 NULL,
        ExpirationDate          DATETIME2 NULL,
        ResolvedDate            DATETIME2 NULL,
        
        -- Metadata
        Notes                   NVARCHAR(500) NULL,
        CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT CK_AreaWaitlist_Status 
            CHECK (Status IN ('Waiting', 'Notified', 'Accepted', 'Expired', 'Canceled'))
    );

    PRINT '✓ Created table: AreaWaitlist';
END
ELSE
BEGIN
    PRINT '• Table AreaWaitlist already exists - skipping';
END
GO

-- Indexes for AreaWaitlist
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaWaitlist_AspNetUserId')
    CREATE INDEX IX_AreaWaitlist_AspNetUserId ON dbo.AreaWaitlist(AspNetUserId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaWaitlist_AreaId')
    CREATE INDEX IX_AreaWaitlist_AreaId ON dbo.AreaWaitlist(AreaId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaWaitlist_Status')
    CREATE INDEX IX_AreaWaitlist_Status ON dbo.AreaWaitlist(Status);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaWaitlist_AreaId_Status_Position')
    CREATE INDEX IX_AreaWaitlist_AreaId_Status_Position 
        ON dbo.AreaWaitlist(AreaId, Status, QueuePosition);

-- Unique constraint: One waitlist entry per user per area
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaWaitlist_UniqueWaiting')
    CREATE UNIQUE INDEX IX_AreaWaitlist_UniqueWaiting 
        ON dbo.AreaWaitlist(AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId) 
        WHERE Status IN ('Waiting', 'Notified');

PRINT '✓ Created indexes for AreaWaitlist';
GO

-- ============================================
-- VIEW: vw_AreaCampaignSummary
-- Aggregated campaign metrics per ownership
-- ============================================

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_AreaCampaignSummary')
    DROP VIEW dbo.vw_AreaCampaignSummary;
GO

CREATE VIEW dbo.vw_AreaCampaignSummary AS
SELECT 
    ao.AreaOwnershipId,
    ao.AspNetUserId,
    ao.AreaId,
    ao.PropertyTypeId,
    ao.Status AS OwnershipStatus,
    ao.StartDate AS OwnershipStartDate,
    ao.EndDate AS OwnershipEndDate,
    
    -- Campaign Totals
    COUNT(ach.AreaCampaignHistoryId) AS TotalCampaigns,
    MAX(ach.CampaignDate) AS LastCampaignDate,
    DATEDIFF(DAY, MAX(ach.CampaignDate), GETUTCDATE()) AS DaysSinceLastCampaign,
    
    -- Message Totals
    SUM(ach.MessagesSent) AS TotalMessagesSent,
    SUM(ach.MessagesDelivered) AS TotalDelivered,
    CASE WHEN SUM(ach.MessagesSent) > 0 
         THEN CAST(SUM(ach.MessagesDelivered) AS FLOAT) / SUM(ach.MessagesSent) * 100 
         ELSE 0 END AS DeliveryRate,
    
    -- Engagement Totals
    SUM(ach.Clicks) AS TotalClicks,
    CASE WHEN SUM(ach.MessagesDelivered) > 0 
         THEN CAST(SUM(ach.Clicks) AS FLOAT) / SUM(ach.MessagesDelivered) * 100 
         ELSE 0 END AS ClickRate,
    SUM(ach.CTASubmitted) AS TotalCTASubmitted,
    SUM(ach.CTAVerified) AS TotalCTAVerified,
    SUM(ach.AgentNotifications) AS TotalAgentNotifications,
    
    -- Opt-Out Totals
    SUM(ach.OptOuts) AS TotalOptOuts,
    CASE WHEN SUM(ach.MessagesDelivered) > 0 
         THEN CAST(SUM(ach.OptOuts) AS FLOAT) / SUM(ach.MessagesDelivered) * 100 
         ELSE 0 END AS OptOutRate,
    
    -- Cost Totals
    SUM(ach.TwilioCost) AS TotalTwilioCost,
    SUM(ach.AgentNotifyCost) AS TotalAgentNotifyCost,
    SUM(ach.TotalCost) AS GrandTotalCost,
    
    -- Averages
    AVG(ach.MessagesSent) AS AvgMessagesPerCampaign,
    AVG(ach.TotalCost) AS AvgCostPerCampaign

FROM dbo.AreaOwnership ao
LEFT JOIN dbo.AreaCampaignHistory ach 
    ON ach.AreaOwnershipId = ao.AreaOwnershipId
GROUP BY 
    ao.AreaOwnershipId,
    ao.AspNetUserId,
    ao.AreaId,
    ao.PropertyTypeId,
    ao.Status,
    ao.StartDate,
    ao.EndDate;
GO

PRINT '✓ Created view: vw_AreaCampaignSummary';
GO

-- ============================================
-- Final Summary
-- ============================================

PRINT '';
PRINT '============================================';
PRINT 'SCHEMA CREATION COMPLETE';
PRINT '============================================';
PRINT '';

SELECT 
    'Tables' AS ObjectType,
    COUNT(*) AS Count
FROM sys.tables 
WHERE name IN ('AreaOwnership', 'AreaOwnershipHistory', 'AreaCampaignHistory', 'AreaWaitlist')
UNION ALL
SELECT 
    'Views' AS ObjectType,
    COUNT(*) AS Count
FROM sys.views 
WHERE name = 'vw_AreaCampaignSummary';

PRINT '';
PRINT 'Next Steps:';
PRINT '  1. Add stored procedures (02_AreaOwnership_StoredProcs_v1.sql)';
PRINT '  2. Insert test data';
PRINT '  3. Validate schema with production schema';
GO

