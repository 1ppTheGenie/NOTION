/*
================================================================================
FR-001 & FR-006: Area Ownership & Lead Custody Schema
Script 02: Core Tables (AreaOwnership, AreaWaitlist)
================================================================================
Version: 1.0
Created: 12/15/2025
Author: Cursor AI
Database: FarmGenie (or FarmGenie_Dev for local testing)

PREREQUISITES:
- Run Script 01 (Lookup Tables) first

CHANGE LOG:
- v1.0 (12/15/2025): Initial creation
================================================================================
*/

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Script 02: Creating Core Tables';
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

-- ============================================================================
-- 1. AreaOwnership - Main ownership table
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AreaOwnership]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AreaOwnership] (
        -- Primary Key
        [AreaOwnershipId] INT IDENTITY(1,1) NOT NULL,
        
        -- Core Identifiers
        [AreaId] INT NOT NULL,                                      -- FK to ViewArea
        [PropertyTypeId] INT NOT NULL,                              -- FK to PropertyType (0=SFR, 1=Condo)
        [UserId] NVARCHAR(128) NOT NULL,                           -- FK to AspNetUsers
        
        -- Ownership Details
        [OwnershipTypeId] INT NOT NULL,                            -- FK to OwnershipType (Purchase, WaitlistConversion, etc.)
        [OwnershipStatusTypeId] INT NOT NULL DEFAULT 10,           -- FK to OwnershipStatusType (default: Pending)
        
        -- Dates
        [StartDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [EndDate] DATETIME NULL,
        [EndReasonTypeId] INT NULL,                                -- FK to EndReasonType (only when ended)
        
        -- Approval
        [ApprovedByUserId] NVARCHAR(128) NULL,                     -- FK to AspNetUsers (admin who approved)
        [ApprovedDate] DATETIME NULL,
        
        -- Referral Tracking
        [ReferredByUserId] NVARCHAR(128) NULL,                     -- FK to AspNetUsers (who referred)
        [ReferralSourceTypeId] INT NULL,                           -- FK to ReferralSourceType
        
        -- Waitlist Link
        [SourceWaitlistId] INT NULL,                               -- FK to AreaWaitlist (if came from waitlist)
        
        -- Lead Custody Settings
        [LeadCustodyEnabled] BIT NOT NULL DEFAULT 1,
        [DefaultSplitPercentage] DECIMAL(5,2) NOT NULL DEFAULT 25.00,  -- 1PP's default cut
        
        -- Legacy Migration
        [LegacyUserOwnedAreaId] INT NULL,                          -- Original UserOwnedArea.UserOwnedAreaId
        
        -- Audit Fields
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [LastUpdateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedByUserId] NVARCHAR(128) NULL,
        [LastUpdatedByUserId] NVARCHAR(128) NULL,
        [IsDeleted] BIT NOT NULL DEFAULT 0,
        
        -- Constraints
        CONSTRAINT [PK_AreaOwnership] PRIMARY KEY CLUSTERED ([AreaOwnershipId]),
        CONSTRAINT [FK_AreaOwnership_PropertyType] FOREIGN KEY ([PropertyTypeId]) 
            REFERENCES [dbo].[PropertyType]([PropertyTypeId]),
        CONSTRAINT [FK_AreaOwnership_OwnershipType] FOREIGN KEY ([OwnershipTypeId]) 
            REFERENCES [dbo].[OwnershipType]([OwnershipTypeId]),
        CONSTRAINT [FK_AreaOwnership_OwnershipStatusType] FOREIGN KEY ([OwnershipStatusTypeId]) 
            REFERENCES [dbo].[OwnershipStatusType]([OwnershipStatusTypeId]),
        CONSTRAINT [FK_AreaOwnership_EndReasonType] FOREIGN KEY ([EndReasonTypeId]) 
            REFERENCES [dbo].[EndReasonType]([EndReasonTypeId]),
        CONSTRAINT [FK_AreaOwnership_ReferralSourceType] FOREIGN KEY ([ReferralSourceTypeId]) 
            REFERENCES [dbo].[ReferralSourceType]([ReferralSourceTypeId])
    );
    PRINT 'Created table: AreaOwnership';
    
    -- Create unique index for active ownership (only one active owner per area+propertytype)
    CREATE UNIQUE NONCLUSTERED INDEX [IX_AreaOwnership_ActiveOwner] 
    ON [dbo].[AreaOwnership] ([AreaId], [PropertyTypeId])
    WHERE [OwnershipStatusTypeId] = 11 AND [IsDeleted] = 0;
    PRINT 'Created unique index: IX_AreaOwnership_ActiveOwner';
    
    -- Create index for user lookups
    CREATE NONCLUSTERED INDEX [IX_AreaOwnership_UserId] 
    ON [dbo].[AreaOwnership] ([UserId], [IsDeleted])
    INCLUDE ([AreaId], [PropertyTypeId], [OwnershipStatusTypeId]);
    PRINT 'Created index: IX_AreaOwnership_UserId';
    
    -- Create index for area lookups
    CREATE NONCLUSTERED INDEX [IX_AreaOwnership_AreaId] 
    ON [dbo].[AreaOwnership] ([AreaId], [PropertyTypeId], [IsDeleted])
    INCLUDE ([UserId], [OwnershipStatusTypeId]);
    PRINT 'Created index: IX_AreaOwnership_AreaId';
    
END
ELSE
    PRINT 'Table already exists: AreaOwnership';
GO

-- ============================================================================
-- 2. AreaWaitlist - Queue for interested parties
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AreaWaitlist]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AreaWaitlist] (
        -- Primary Key
        [AreaWaitlistId] INT IDENTITY(1,1) NOT NULL,
        
        -- Core Identifiers
        [AreaId] INT NOT NULL,                                      -- FK to ViewArea
        [PropertyTypeId] INT NOT NULL,                              -- FK to PropertyType
        [UserId] NVARCHAR(128) NOT NULL,                           -- FK to AspNetUsers
        
        -- Queue Position
        [QueuePosition] INT NOT NULL,                               -- 1 = first in line
        
        -- Status
        [WaitlistStatusTypeId] INT NOT NULL DEFAULT 1,             -- Uses OwnershipStatusType (WAITLIST category)
        
        -- Dates
        [RequestDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [NotifiedDate] DATETIME NULL,                              -- When notified of availability
        [ResponseDate] DATETIME NULL,                              -- When they responded
        [ExpirationDate] DATETIME NULL,                            -- When offer expires
        
        -- Notes
        [Notes] NVARCHAR(500) NULL,
        
        -- Audit
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [LastUpdateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Constraints
        CONSTRAINT [PK_AreaWaitlist] PRIMARY KEY CLUSTERED ([AreaWaitlistId]),
        CONSTRAINT [FK_AreaWaitlist_PropertyType] FOREIGN KEY ([PropertyTypeId]) 
            REFERENCES [dbo].[PropertyType]([PropertyTypeId]),
        CONSTRAINT [FK_AreaWaitlist_WaitlistStatusType] FOREIGN KEY ([WaitlistStatusTypeId]) 
            REFERENCES [dbo].[OwnershipStatusType]([OwnershipStatusTypeId])
    );
    PRINT 'Created table: AreaWaitlist';
    
    -- Create index for queue position lookups
    CREATE NONCLUSTERED INDEX [IX_AreaWaitlist_Queue] 
    ON [dbo].[AreaWaitlist] ([AreaId], [PropertyTypeId], [QueuePosition])
    WHERE [WaitlistStatusTypeId] = 1;  -- Only waiting status
    PRINT 'Created index: IX_AreaWaitlist_Queue';
    
    -- Create index for user waitlist lookups
    CREATE NONCLUSTERED INDEX [IX_AreaWaitlist_UserId] 
    ON [dbo].[AreaWaitlist] ([UserId])
    INCLUDE ([AreaId], [PropertyTypeId], [WaitlistStatusTypeId], [QueuePosition]);
    PRINT 'Created index: IX_AreaWaitlist_UserId';
    
END
ELSE
    PRINT 'Table already exists: AreaWaitlist';
GO

-- ============================================================================
-- Add FK from AreaOwnership to AreaWaitlist (SourceWaitlistId)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_AreaOwnership_SourceWaitlist')
BEGIN
    ALTER TABLE [dbo].[AreaOwnership]
    ADD CONSTRAINT [FK_AreaOwnership_SourceWaitlist] 
    FOREIGN KEY ([SourceWaitlistId]) REFERENCES [dbo].[AreaWaitlist]([AreaWaitlistId]);
    PRINT 'Added FK: FK_AreaOwnership_SourceWaitlist';
END
GO

PRINT '========================================';
PRINT 'Script 02: Core Tables COMPLETE';
PRINT 'Finished: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

