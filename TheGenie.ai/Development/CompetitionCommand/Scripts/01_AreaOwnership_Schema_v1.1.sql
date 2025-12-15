-- ============================================
-- Competition Command: Area Ownership Schema
-- Version 1.1 | Created: 12/14/2025
-- Database: FarmGenie_Dev
-- Fixed SET options for filtered indexes
-- ============================================

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE FarmGenie_Dev;
GO

PRINT 'Creating AreaOwnership Schema for FarmGenie_Dev...';
PRINT '----------------------------------------------------';

-- ============================================
-- TABLE: AreaCampaignHistory (Create first for dependencies)
-- Tracks all CC campaign activity per ownership
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AreaCampaignHistory')
BEGIN
    CREATE TABLE dbo.AreaCampaignHistory (
        AreaCampaignHistoryId   INT IDENTITY(1,1) PRIMARY KEY,
        AreaOwnershipId         INT NOT NULL,
        
        -- Campaign Reference
        PropertyCastId          INT NULL,
        PropertyCollectionDetailId INT NULL,
        
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
        
        -- Metadata
        CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );

    PRINT '✓ Created table: AreaCampaignHistory';
END
ELSE
BEGIN
    PRINT '• Table AreaCampaignHistory already exists - skipping';
END
GO

-- Add computed column separately
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AreaCampaignHistory') AND name = 'TotalCost')
BEGIN
    ALTER TABLE dbo.AreaCampaignHistory 
    ADD TotalCost AS (TwilioCost + AgentNotifyCost) PERSISTED;
    PRINT '✓ Added computed column TotalCost to AreaCampaignHistory';
END
GO

-- Add FK constraint if AreaOwnership exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AreaOwnership')
   AND NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_AreaCampaignHistory_AreaOwnership')
BEGIN
    ALTER TABLE dbo.AreaCampaignHistory 
    ADD CONSTRAINT FK_AreaCampaignHistory_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId);
    PRINT '✓ Added FK constraint to AreaCampaignHistory';
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
-- Fix filtered indexes that failed (need SET QUOTED_IDENTIFIER ON)
-- ============================================

-- Unique constraint: One active owner per Area + PropertyType + OwnershipType
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaOwnership_UniqueActive')
    CREATE UNIQUE INDEX IX_AreaOwnership_UniqueActive 
        ON dbo.AreaOwnership(AreaId, PropertyTypeId, AreaOwnershipTypeId) 
        WHERE Status = 'Active';

PRINT '✓ Created filtered index IX_AreaOwnership_UniqueActive';
GO

-- Unique constraint: One waitlist entry per user per area
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AreaWaitlist_UniqueWaiting')
    CREATE UNIQUE INDEX IX_AreaWaitlist_UniqueWaiting 
        ON dbo.AreaWaitlist(AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId) 
        WHERE Status IN ('Waiting', 'Notified');

PRINT '✓ Created filtered index IX_AreaWaitlist_UniqueWaiting';
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
    SUM(ISNULL(ach.MessagesSent, 0)) AS TotalMessagesSent,
    SUM(ISNULL(ach.MessagesDelivered, 0)) AS TotalDelivered,
    CASE WHEN SUM(ISNULL(ach.MessagesSent, 0)) > 0 
         THEN CAST(SUM(ISNULL(ach.MessagesDelivered, 0)) AS FLOAT) / SUM(ach.MessagesSent) * 100 
         ELSE 0 END AS DeliveryRate,
    
    -- Engagement Totals
    SUM(ISNULL(ach.Clicks, 0)) AS TotalClicks,
    CASE WHEN SUM(ISNULL(ach.MessagesDelivered, 0)) > 0 
         THEN CAST(SUM(ISNULL(ach.Clicks, 0)) AS FLOAT) / SUM(ach.MessagesDelivered) * 100 
         ELSE 0 END AS ClickRate,
    SUM(ISNULL(ach.CTASubmitted, 0)) AS TotalCTASubmitted,
    SUM(ISNULL(ach.CTAVerified, 0)) AS TotalCTAVerified,
    SUM(ISNULL(ach.AgentNotifications, 0)) AS TotalAgentNotifications,
    
    -- Opt-Out Totals
    SUM(ISNULL(ach.OptOuts, 0)) AS TotalOptOuts,
    CASE WHEN SUM(ISNULL(ach.MessagesDelivered, 0)) > 0 
         THEN CAST(SUM(ISNULL(ach.OptOuts, 0)) AS FLOAT) / SUM(ach.MessagesDelivered) * 100 
         ELSE 0 END AS OptOutRate,
    
    -- Cost Totals
    SUM(ISNULL(ach.TwilioCost, 0)) AS TotalTwilioCost,
    SUM(ISNULL(ach.AgentNotifyCost, 0)) AS TotalAgentNotifyCost,
    SUM(ISNULL(ach.TotalCost, 0)) AS GrandTotalCost,
    
    -- Averages
    AVG(ISNULL(ach.MessagesSent, 0)) AS AvgMessagesPerCampaign,
    AVG(ISNULL(ach.TotalCost, 0)) AS AvgCostPerCampaign

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
PRINT 'SCHEMA FIX COMPLETE';
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

-- Show all tables
SELECT 
    t.name AS TableName,
    SUM(p.rows) AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE t.name IN ('AreaOwnership', 'AreaOwnershipHistory', 'AreaCampaignHistory', 'AreaWaitlist')
  AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;

PRINT '';
PRINT 'Schema creation complete!';
GO

