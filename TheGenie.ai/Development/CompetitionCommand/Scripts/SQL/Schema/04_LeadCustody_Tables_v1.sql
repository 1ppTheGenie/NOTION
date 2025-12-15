/*
================================================================================
FR-001 & FR-006: Area Ownership & Lead Custody Schema
Script 04: Lead Custody Tables
================================================================================
Version: 1.0
Created: 12/15/2025
Author: Cursor AI
Database: FarmGenie (or FarmGenie_Dev for local testing)

PREREQUISITES:
- Run Script 01 (Lookup Tables) first
- Run Script 02 (Core Tables) first
- GenieLead table must exist (it does in production)

CHANGE LOG:
- v1.0 (12/15/2025): Initial creation
================================================================================
*/

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Script 04: Creating Lead Custody Tables';
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

-- ============================================================================
-- 1. LeadCustody - Primary custody tracking per lead
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LeadCustody]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LeadCustody] (
        -- Primary Key
        [LeadCustodyId] BIGINT IDENTITY(1,1) NOT NULL,
        
        -- Link to Lead
        [GenieLeadId] BIGINT NOT NULL,                             -- FK to GenieLead
        
        -- Custody Status
        [CustodyStatusTypeId] INT NOT NULL DEFAULT 2,              -- FK to CustodyStatusType (default: AgentLicensed)
        [CurrentLicenseeUserId] NVARCHAR(128) NULL,                -- FK to AspNetUsers (NULL = 1PP custody)
        
        -- Link to Area Ownership
        [SourceAreaOwnershipId] INT NULL,                          -- FK to AreaOwnership
        
        -- Split Configuration
        [SplitPercentage] DECIMAL(5,2) NOT NULL DEFAULT 25.00,     -- 1PP's cut if transaction happens
        
        -- Grace Period
        [GracePeriodEndDate] DATETIME NULL,                        -- When grace period expires after cancellation
        
        -- Audit
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [LastUpdateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Constraints
        CONSTRAINT [PK_LeadCustody] PRIMARY KEY CLUSTERED ([LeadCustodyId]),
        CONSTRAINT [FK_LeadCustody_CustodyStatusType] FOREIGN KEY ([CustodyStatusTypeId]) 
            REFERENCES [dbo].[CustodyStatusType]([CustodyStatusTypeId]),
        CONSTRAINT [FK_LeadCustody_AreaOwnership] FOREIGN KEY ([SourceAreaOwnershipId]) 
            REFERENCES [dbo].[AreaOwnership]([AreaOwnershipId])
    );
    PRINT 'Created table: LeadCustody';
    
    -- Create unique index (one custody record per lead)
    CREATE UNIQUE NONCLUSTERED INDEX [IX_LeadCustody_GenieLeadId] 
    ON [dbo].[LeadCustody] ([GenieLeadId]);
    PRINT 'Created unique index: IX_LeadCustody_GenieLeadId';
    
    -- Create index for licensee lookups
    CREATE NONCLUSTERED INDEX [IX_LeadCustody_Licensee] 
    ON [dbo].[LeadCustody] ([CurrentLicenseeUserId], [CustodyStatusTypeId])
    INCLUDE ([GenieLeadId], [SplitPercentage]);
    PRINT 'Created index: IX_LeadCustody_Licensee';
    
    -- Create index for 1PP custody (orphaned leads)
    CREATE NONCLUSTERED INDEX [IX_LeadCustody_1PPCustody] 
    ON [dbo].[LeadCustody] ([CustodyStatusTypeId])
    WHERE [CurrentLicenseeUserId] IS NULL;
    PRINT 'Created index: IX_LeadCustody_1PPCustody';
    
    -- Create index for grace period expiration checks
    CREATE NONCLUSTERED INDEX [IX_LeadCustody_GracePeriod] 
    ON [dbo].[LeadCustody] ([GracePeriodEndDate])
    WHERE [CustodyStatusTypeId] = 3;  -- AgentSuspended
    PRINT 'Created index: IX_LeadCustody_GracePeriod';
    
END
ELSE
    PRINT 'Table already exists: LeadCustody';
GO

-- ============================================================================
-- 2. LeadCustodyHistory - Audit trail for custody changes
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LeadCustodyHistory]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LeadCustodyHistory] (
        -- Primary Key
        [LeadCustodyHistoryId] BIGINT IDENTITY(1,1) NOT NULL,
        
        -- Link to Custody Record
        [LeadCustodyId] BIGINT NOT NULL,                           -- FK to LeadCustody
        
        -- Transfer Details
        [FromUserId] NVARCHAR(128) NULL,                           -- Previous licensee (NULL = was 1PP)
        [ToUserId] NVARCHAR(128) NULL,                             -- New licensee (NULL = now 1PP)
        [CustodyTransferReasonId] INT NOT NULL,                    -- FK to CustodyTransferReason
        
        -- Who/When
        [TransferredByUserId] NVARCHAR(128) NOT NULL,              -- Admin who initiated
        [TransferDate] DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Notes
        [Notes] NVARCHAR(500) NULL,
        
        -- Constraints
        CONSTRAINT [PK_LeadCustodyHistory] PRIMARY KEY CLUSTERED ([LeadCustodyHistoryId]),
        CONSTRAINT [FK_LeadCustodyHistory_LeadCustody] FOREIGN KEY ([LeadCustodyId]) 
            REFERENCES [dbo].[LeadCustody]([LeadCustodyId]),
        CONSTRAINT [FK_LeadCustodyHistory_TransferReason] FOREIGN KEY ([CustodyTransferReasonId]) 
            REFERENCES [dbo].[CustodyTransferReason]([CustodyTransferReasonId])
    );
    PRINT 'Created table: LeadCustodyHistory';
    
    -- Create index for custody record lookups
    CREATE NONCLUSTERED INDEX [IX_LeadCustodyHistory_LeadCustodyId] 
    ON [dbo].[LeadCustodyHistory] ([LeadCustodyId], [TransferDate] DESC);
    PRINT 'Created index: IX_LeadCustodyHistory_LeadCustodyId';
    
    -- Create index for date range queries
    CREATE NONCLUSTERED INDEX [IX_LeadCustodyHistory_TransferDate] 
    ON [dbo].[LeadCustodyHistory] ([TransferDate] DESC)
    INCLUDE ([LeadCustodyId], [CustodyTransferReasonId]);
    PRINT 'Created index: IX_LeadCustodyHistory_TransferDate';
    
END
ELSE
    PRINT 'Table already exists: LeadCustodyHistory';
GO

-- ============================================================================
-- 3. LeadTransaction - Track when leads convert to deals
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LeadTransaction]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LeadTransaction] (
        -- Primary Key
        [LeadTransactionId] BIGINT IDENTITY(1,1) NOT NULL,
        
        -- Links
        [LeadCustodyId] BIGINT NOT NULL,                           -- FK to LeadCustody
        [GenieLeadId] BIGINT NOT NULL,                             -- FK to GenieLead (denormalized for performance)
        
        -- Transaction Details
        [TransactionDate] DATE NOT NULL,
        [TransactionType] NVARCHAR(50) NOT NULL DEFAULT 'Sale',    -- Sale, Listing, Rental
        [PropertyAddress] NVARCHAR(500) NULL,
        
        -- Financials
        [TransactionAmount] MONEY NOT NULL,                        -- Sale price
        [CommissionTotal] MONEY NOT NULL,                          -- Total commission earned
        [CommissionPercentage] DECIMAL(5,2) NULL,                  -- Commission rate
        
        -- Splits
        [SplitPercentageTo1PP] DECIMAL(5,2) NOT NULL,              -- 1PP's cut percentage
        [SplitTo1PP] MONEY NOT NULL,                               -- 1PP's portion in dollars
        [SplitToAgent] MONEY NOT NULL,                             -- Agent's portion in dollars
        
        -- Agent at Close
        [AgentUserIdAtClose] NVARCHAR(128) NOT NULL,               -- Who had license when closed
        
        -- Verification
        [VerifiedDate] DATETIME NULL,
        [VerifiedByUserId] NVARCHAR(128) NULL,
        [VerificationMethod] NVARCHAR(100) NULL,                   -- MLS, Manual, API, etc.
        [VerificationNotes] NVARCHAR(500) NULL,
        
        -- Audit
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [LastUpdateDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedByUserId] NVARCHAR(128) NULL,
        
        -- Constraints
        CONSTRAINT [PK_LeadTransaction] PRIMARY KEY CLUSTERED ([LeadTransactionId]),
        CONSTRAINT [FK_LeadTransaction_LeadCustody] FOREIGN KEY ([LeadCustodyId]) 
            REFERENCES [dbo].[LeadCustody]([LeadCustodyId])
    );
    PRINT 'Created table: LeadTransaction';
    
    -- Create index for custody lookups
    CREATE NONCLUSTERED INDEX [IX_LeadTransaction_LeadCustodyId] 
    ON [dbo].[LeadTransaction] ([LeadCustodyId]);
    PRINT 'Created index: IX_LeadTransaction_LeadCustodyId';
    
    -- Create index for lead lookups
    CREATE NONCLUSTERED INDEX [IX_LeadTransaction_GenieLeadId] 
    ON [dbo].[LeadTransaction] ([GenieLeadId]);
    PRINT 'Created index: IX_LeadTransaction_GenieLeadId';
    
    -- Create index for agent lookups
    CREATE NONCLUSTERED INDEX [IX_LeadTransaction_Agent] 
    ON [dbo].[LeadTransaction] ([AgentUserIdAtClose], [TransactionDate]);
    PRINT 'Created index: IX_LeadTransaction_Agent';
    
    -- Create index for date range reporting
    CREATE NONCLUSTERED INDEX [IX_LeadTransaction_Date] 
    ON [dbo].[LeadTransaction] ([TransactionDate])
    INCLUDE ([SplitTo1PP], [SplitToAgent], [TransactionAmount]);
    PRINT 'Created index: IX_LeadTransaction_Date';
    
END
ELSE
    PRINT 'Table already exists: LeadTransaction';
GO

PRINT '========================================';
PRINT 'Script 04: Lead Custody Tables COMPLETE';
PRINT 'Finished: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

