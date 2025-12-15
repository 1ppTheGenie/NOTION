/*
================================================================================
FR-001 & FR-006: Area Ownership & Lead Custody Schema
Script 03: History Tables
================================================================================
Version: 1.0
Created: 12/15/2025
Author: Cursor AI
Database: FarmGenie (or FarmGenie_Dev for local testing)

PREREQUISITES:
- Run Script 01 (Lookup Tables) first
- Run Script 02 (Core Tables) first

CHANGE LOG:
- v1.0 (12/15/2025): Initial creation
================================================================================
*/

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Script 03: Creating History Tables';
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

-- ============================================================================
-- 1. AreaOwnershipHistory - Audit trail for ownership changes
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AreaOwnershipHistory]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AreaOwnershipHistory] (
        -- Primary Key
        [AreaOwnershipHistoryId] BIGINT IDENTITY(1,1) NOT NULL,
        
        -- Link to Ownership
        [AreaOwnershipId] INT NOT NULL,                            -- FK to AreaOwnership
        
        -- Action Details
        [ActionTypeId] INT NOT NULL,                               -- FK to ActionType
        [OldValue] NVARCHAR(MAX) NULL,                             -- JSON of old values
        [NewValue] NVARCHAR(MAX) NULL,                             -- JSON of new values
        
        -- Who/When
        [ChangedByUserId] NVARCHAR(128) NOT NULL,                  -- FK to AspNetUsers
        [ChangeDate] DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Reason
        [Reason] NVARCHAR(500) NULL,
        
        -- Constraints
        CONSTRAINT [PK_AreaOwnershipHistory] PRIMARY KEY CLUSTERED ([AreaOwnershipHistoryId]),
        CONSTRAINT [FK_AreaOwnershipHistory_AreaOwnership] FOREIGN KEY ([AreaOwnershipId]) 
            REFERENCES [dbo].[AreaOwnership]([AreaOwnershipId]),
        CONSTRAINT [FK_AreaOwnershipHistory_ActionType] FOREIGN KEY ([ActionTypeId]) 
            REFERENCES [dbo].[ActionType]([ActionTypeId])
    );
    PRINT 'Created table: AreaOwnershipHistory';
    
    -- Create index for ownership lookups
    CREATE NONCLUSTERED INDEX [IX_AreaOwnershipHistory_AreaOwnershipId] 
    ON [dbo].[AreaOwnershipHistory] ([AreaOwnershipId], [ChangeDate] DESC);
    PRINT 'Created index: IX_AreaOwnershipHistory_AreaOwnershipId';
    
    -- Create index for date range queries
    CREATE NONCLUSTERED INDEX [IX_AreaOwnershipHistory_ChangeDate] 
    ON [dbo].[AreaOwnershipHistory] ([ChangeDate] DESC)
    INCLUDE ([AreaOwnershipId], [ActionTypeId]);
    PRINT 'Created index: IX_AreaOwnershipHistory_ChangeDate';
    
END
ELSE
    PRINT 'Table already exists: AreaOwnershipHistory';
GO

-- ============================================================================
-- 2. AreaCampaignHistory - Monthly campaign metrics per ownership
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AreaCampaignHistory]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AreaCampaignHistory] (
        -- Primary Key
        [AreaCampaignHistoryId] BIGINT IDENTITY(1,1) NOT NULL,
        
        -- Links
        [AreaOwnershipId] INT NOT NULL,                            -- FK to AreaOwnership
        [PropertyCastId] INT NULL,                                 -- FK to PropertyCast (if specific campaign)
        
        -- Period
        [CampaignMonth] DATE NOT NULL,                             -- First day of month (2025-12-01)
        
        -- Metrics
        [TextsSent] INT NOT NULL DEFAULT 0,
        [TextsDelivered] INT NOT NULL DEFAULT 0,
        [Clicks] INT NOT NULL DEFAULT 0,
        [LeadsGenerated] INT NOT NULL DEFAULT 0,
        [CTADisplayed] INT NOT NULL DEFAULT 0,
        [CTASubmitted] INT NOT NULL DEFAULT 0,
        [CTAVerified] INT NOT NULL DEFAULT 0,
        [AgentNotifications] INT NOT NULL DEFAULT 0,
        
        -- Costs
        [TwilioCost] DECIMAL(10,4) NOT NULL DEFAULT 0,
        [VersiumCost] DECIMAL(10,4) NOT NULL DEFAULT 0,
        [TotalCost] AS ([TwilioCost] + [VersiumCost]) PERSISTED,
        
        -- Audit
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [LastUpdateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Constraints
        CONSTRAINT [PK_AreaCampaignHistory] PRIMARY KEY CLUSTERED ([AreaCampaignHistoryId]),
        CONSTRAINT [FK_AreaCampaignHistory_AreaOwnership] FOREIGN KEY ([AreaOwnershipId]) 
            REFERENCES [dbo].[AreaOwnership]([AreaOwnershipId])
    );
    PRINT 'Created table: AreaCampaignHistory';
    
    -- Create unique index for one record per ownership per month
    CREATE UNIQUE NONCLUSTERED INDEX [IX_AreaCampaignHistory_Unique] 
    ON [dbo].[AreaCampaignHistory] ([AreaOwnershipId], [CampaignMonth]);
    PRINT 'Created unique index: IX_AreaCampaignHistory_Unique';
    
    -- Create index for monthly reporting
    CREATE NONCLUSTERED INDEX [IX_AreaCampaignHistory_Month] 
    ON [dbo].[AreaCampaignHistory] ([CampaignMonth])
    INCLUDE ([AreaOwnershipId], [TwilioCost], [VersiumCost], [LeadsGenerated]);
    PRINT 'Created index: IX_AreaCampaignHistory_Month';
    
END
ELSE
    PRINT 'Table already exists: AreaCampaignHistory';
GO

PRINT '========================================';
PRINT 'Script 03: History Tables COMPLETE';
PRINT 'Finished: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

