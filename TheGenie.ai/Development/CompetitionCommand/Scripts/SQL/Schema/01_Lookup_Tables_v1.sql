/*
================================================================================
FR-001 & FR-006: Area Ownership & Lead Custody Schema
Script 01: Lookup Tables
================================================================================
Version: 1.0
Created: 12/15/2025
Author: Cursor AI
Database: FarmGenie (or FarmGenie_Dev for local testing)

INSTRUCTIONS:
1. Run this script FIRST before any other schema scripts
2. Execute on FarmGenie_Dev for local testing
3. All lookup tables are seeded with initial values

CHANGE LOG:
- v1.0 (12/15/2025): Initial creation
================================================================================
*/

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Script 01: Creating Lookup Tables';
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

-- ============================================================================
-- 1. PropertyType
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PropertyType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PropertyType] (
        [PropertyTypeId] INT NOT NULL PRIMARY KEY,
        [PropertyTypeName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: PropertyType';
END
ELSE
    PRINT 'Table already exists: PropertyType';
GO

-- Seed PropertyType
IF NOT EXISTS (SELECT 1 FROM [dbo].[PropertyType] WHERE PropertyTypeId = 0)
BEGIN
    INSERT INTO [dbo].[PropertyType] (PropertyTypeId, PropertyTypeName, Description)
    VALUES 
        (0, 'SFR', 'Single Family Residence'),
        (1, 'Condo', 'Condominium');
    PRINT 'Seeded PropertyType with 2 values';
END
GO

-- ============================================================================
-- 2. OwnershipType (How they got the area)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OwnershipType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[OwnershipType] (
        [OwnershipTypeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [OwnershipTypeName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: OwnershipType';
END
ELSE
    PRINT 'Table already exists: OwnershipType';
GO

-- Seed OwnershipType
IF NOT EXISTS (SELECT 1 FROM [dbo].[OwnershipType] WHERE OwnershipTypeName = 'Purchase')
BEGIN
    INSERT INTO [dbo].[OwnershipType] (OwnershipTypeName, Description)
    VALUES 
        ('Purchase', 'Customer purchased the area directly'),
        ('WaitlistConversion', 'Customer was on waitlist and accepted when available'),
        ('AdminAssignment', 'Admin assigned the area to customer'),
        ('Partnership', 'Special partnership or revenue share deal'),
        ('Promotion', 'Promotional or free trial'),
        ('Migration', 'Migrated from legacy UserOwnedArea table');
    PRINT 'Seeded OwnershipType with 6 values';
END
GO

-- ============================================================================
-- 3. OwnershipStatusType (Current status - unified for Waitlist & Ownership)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OwnershipStatusType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[OwnershipStatusType] (
        [OwnershipStatusTypeId] INT NOT NULL PRIMARY KEY,
        [StatusName] NVARCHAR(50) NOT NULL,
        [StatusCategory] NVARCHAR(20) NOT NULL, -- WAITLIST, OWNERSHIP, HISTORICAL
        [Description] NVARCHAR(200) NULL,
        [IsFinal] BIT NOT NULL DEFAULT 0,
        [AllowsCampaigns] BIT NOT NULL DEFAULT 0,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: OwnershipStatusType';
END
ELSE
    PRINT 'Table already exists: OwnershipStatusType';
GO

-- Seed OwnershipStatusType
IF NOT EXISTS (SELECT 1 FROM [dbo].[OwnershipStatusType] WHERE OwnershipStatusTypeId = 1)
BEGIN
    INSERT INTO [dbo].[OwnershipStatusType] (OwnershipStatusTypeId, StatusName, StatusCategory, Description, IsFinal, AllowsCampaigns, DisplayOrder)
    VALUES 
        -- Waitlist statuses (1-9)
        (1, 'Waiting', 'WAITLIST', 'In queue waiting for area to become available', 0, 0, 10),
        (2, 'Notified', 'WAITLIST', 'Area available, customer has been notified', 0, 0, 20),
        (3, 'Accepted', 'WAITLIST', 'Customer accepted, converting to ownership', 1, 0, 30),
        (4, 'Expired', 'WAITLIST', 'Customer did not respond in time', 1, 0, 40),
        (5, 'Declined', 'WAITLIST', 'Customer declined the offer', 1, 0, 50),
        (6, 'Canceled', 'WAITLIST', 'Customer removed themselves from waitlist', 1, 0, 60),
        
        -- Ownership statuses (10-19)
        (10, 'Pending', 'OWNERSHIP', 'Ownership requested, awaiting approval', 0, 0, 100),
        (11, 'Active', 'OWNERSHIP', 'Active ownership, campaigns running', 0, 1, 110),
        (12, 'Suspended', 'OWNERSHIP', 'Temporarily suspended (payment issue, etc.)', 0, 0, 120),
        
        -- Historical statuses (20+)
        (20, 'Ended', 'HISTORICAL', 'Ownership ended, see EndReasonTypeId', 1, 0, 200);
    PRINT 'Seeded OwnershipStatusType with 10 values';
END
GO

-- ============================================================================
-- 4. EndReasonType (Why ownership ended)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EndReasonType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[EndReasonType] (
        [EndReasonTypeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [EndReasonName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: EndReasonType';
END
ELSE
    PRINT 'Table already exists: EndReasonType';
GO

-- Seed EndReasonType
IF NOT EXISTS (SELECT 1 FROM [dbo].[EndReasonType] WHERE EndReasonName = 'Cancelled')
BEGIN
    INSERT INTO [dbo].[EndReasonType] (EndReasonName, Description)
    VALUES 
        ('Cancelled', 'Customer cancelled their subscription'),
        ('NonPayment', 'Ended due to non-payment'),
        ('Violation', 'Ended due to terms violation'),
        ('Upgraded', 'Upgraded to different area or plan'),
        ('Transferred', 'Transferred to another customer'),
        ('AdminAction', 'Ended by admin action'),
        ('Expired', 'Trial or promotional period expired');
    PRINT 'Seeded EndReasonType with 7 values';
END
GO

-- ============================================================================
-- 5. ActionType (For history tracking)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ActionType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ActionType] (
        [ActionTypeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ActionTypeName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: ActionType';
END
ELSE
    PRINT 'Table already exists: ActionType';
GO

-- Seed ActionType
IF NOT EXISTS (SELECT 1 FROM [dbo].[ActionType] WHERE ActionTypeName = 'Created')
BEGIN
    INSERT INTO [dbo].[ActionType] (ActionTypeName, Description)
    VALUES 
        ('Created', 'Record was created'),
        ('StatusChanged', 'Status was changed'),
        ('Transferred', 'Ownership was transferred to another user'),
        ('Suspended', 'Ownership was suspended'),
        ('Reactivated', 'Ownership was reactivated'),
        ('Ended', 'Ownership was ended'),
        ('Updated', 'Record was updated');
    PRINT 'Seeded ActionType with 7 values';
END
GO

-- ============================================================================
-- 6. ReferralSourceType
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReferralSourceType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ReferralSourceType] (
        [ReferralSourceTypeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [SourceTypeName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: ReferralSourceType';
END
ELSE
    PRINT 'Table already exists: ReferralSourceType';
GO

-- Seed ReferralSourceType
IF NOT EXISTS (SELECT 1 FROM [dbo].[ReferralSourceType] WHERE SourceTypeName = 'GenieUser')
BEGIN
    INSERT INTO [dbo].[ReferralSourceType] (SourceTypeName, Description)
    VALUES 
        ('GenieUser', 'Referred by another Genie customer'),
        ('TitleRep', 'Referred by a title company representative'),
        ('Affiliate', 'Referred through affiliate program'),
        ('Direct', 'No referral, came directly'),
        ('Marketing', 'Came from marketing campaign');
    PRINT 'Seeded ReferralSourceType with 5 values';
END
GO

-- ============================================================================
-- 7. CustodyStatusType (Lead Custody)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustodyStatusType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[CustodyStatusType] (
        [CustodyStatusTypeId] INT NOT NULL PRIMARY KEY,
        [StatusName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: CustodyStatusType';
END
ELSE
    PRINT 'Table already exists: CustodyStatusType';
GO

-- Seed CustodyStatusType
IF NOT EXISTS (SELECT 1 FROM [dbo].[CustodyStatusType] WHERE CustodyStatusTypeId = 1)
BEGIN
    INSERT INTO [dbo].[CustodyStatusType] (CustodyStatusTypeId, StatusName, Description)
    VALUES 
        (1, '1PPCustody', 'Lead is in 1PP custody, available for licensing'),
        (2, 'AgentLicensed', 'Lead is licensed to an active agent'),
        (3, 'AgentSuspended', 'Agent in grace period after cancellation'),
        (4, 'Reclaimed', 'Lead was reclaimed from non-performing agent'),
        (5, 'Converted', 'Lead converted to a transaction');
    PRINT 'Seeded CustodyStatusType with 5 values';
END
GO

-- ============================================================================
-- 8. CustodyTransferReason
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustodyTransferReason]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[CustodyTransferReason] (
        [CustodyTransferReasonId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ReasonName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreateDate] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table: CustodyTransferReason';
END
ELSE
    PRINT 'Table already exists: CustodyTransferReason';
GO

-- Seed CustodyTransferReason
IF NOT EXISTS (SELECT 1 FROM [dbo].[CustodyTransferReason] WHERE ReasonName = 'InitialAssignment')
BEGIN
    INSERT INTO [dbo].[CustodyTransferReason] (ReasonName, Description)
    VALUES 
        ('InitialAssignment', 'Lead initially assigned when created'),
        ('AgentCancelled', 'Agent cancelled their subscription'),
        ('NonPayment', 'Agent failed to pay'),
        ('Reclaimed', 'Lead reclaimed due to non-performance'),
        ('AreaTransfer', 'Area ownership transferred to new agent'),
        ('ManualAdmin', 'Manually transferred by admin');
    PRINT 'Seeded CustodyTransferReason with 6 values';
END
GO

PRINT '========================================';
PRINT 'Script 01: Lookup Tables COMPLETE';
PRINT 'Finished: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

