-- ============================================
-- Competition Command: Clone Production Data to Local Dev
-- Version 1.0 | Created: 12/14/2025
-- Source: Production (192.168.29.45 / FarmGenie)
-- Target: Local (localhost\SQLEXPRESS / FarmGenie_Dev)
-- ============================================

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE FarmGenie_Dev;
GO

PRINT '============================================';
PRINT 'CLONING PRODUCTION DATA TO LOCAL DEV';
PRINT 'Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================';
PRINT '';

-- ============================================
-- STEP 1: Create schema tables (if missing)
-- ============================================

-- UserOwnedArea (Production table - copy structure)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserOwnedArea')
BEGIN
    CREATE TABLE dbo.UserOwnedArea (
        UserOwnedAreaId         INT IDENTITY(1,1) PRIMARY KEY,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        AreaId                  INT NOT NULL,
        PropertyTypeId          INT NOT NULL DEFAULT 0,
        AreaOwnershipTypeId     INT NOT NULL DEFAULT 1,
        CreateDate              DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT '✓ Created table: UserOwnedArea';
END
GO

-- AspNetUsers
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AspNetUsers')
BEGIN
    CREATE TABLE dbo.AspNetUsers (
        Id                      NVARCHAR(128) PRIMARY KEY,
        UserName                NVARCHAR(256) NOT NULL,
        Email                   NVARCHAR(256) NULL,
        EmailConfirmed          BIT NOT NULL DEFAULT 0,
        PhoneNumber             NVARCHAR(50) NULL,
        PhoneNumberConfirmed    BIT NOT NULL DEFAULT 0,
        LockoutEnabled          BIT NOT NULL DEFAULT 0,
        AccessFailedCount       INT NOT NULL DEFAULT 0,
        CreateDate              DATETIME2 NULL
    );
    PRINT '✓ Created table: AspNetUsers';
END
GO

-- AspNetUserProfiles
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AspNetUserProfiles')
BEGIN
    CREATE TABLE dbo.AspNetUserProfiles (
        AspNetUserProfileId     INT IDENTITY(1,1) PRIMARY KEY,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        FirstName               NVARCHAR(100) NULL,
        LastName                NVARCHAR(100) NULL,
        Company                 NVARCHAR(200) NULL,
        Address1                NVARCHAR(200) NULL,
        City                    NVARCHAR(100) NULL,
        State                   NVARCHAR(50) NULL,
        ZipCode                 NVARCHAR(20) NULL,
        Phone                   NVARCHAR(50) NULL,
        CreateDate              DATETIME2 NULL
    );
    PRINT '✓ Created table: AspNetUserProfiles';
END
GO

-- UserWhmcs
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserWhmcs')
BEGIN
    CREATE TABLE dbo.UserWhmcs (
        UserWhmcsId             INT IDENTITY(1,1) PRIMARY KEY,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        WhmcsClientId           INT NOT NULL,
        CreateDate              DATETIME2 NOT NULL,
        LastUpdate              DATETIME2 NOT NULL
    );
    PRINT '✓ Created table: UserWhmcs';
END
GO

-- ViewArea (simplified)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ViewArea')
BEGIN
    CREATE TABLE dbo.ViewArea (
        AreaId                  INT PRIMARY KEY,
        Name                    NVARCHAR(200) NULL,
        FriendlyName            NVARCHAR(200) NULL,
        State                   NVARCHAR(50) NULL,
        ZipCode                 NVARCHAR(20) NULL,
        County                  NVARCHAR(100) NULL,
        PropertyCount           INT NULL
    );
    PRINT '✓ Created table: ViewArea';
END
GO

-- PolygonNameOverride
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PolygonNameOverride')
BEGIN
    CREATE TABLE dbo.PolygonNameOverride (
        PolygonNameOverrideId   INT IDENTITY(1,1) PRIMARY KEY,
        PolygonId               INT NOT NULL,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        FriendlyName            NVARCHAR(200) NOT NULL,
        CreateDate              DATETIME2 NOT NULL
    );
    PRINT '✓ Created table: PolygonNameOverride';
END
GO

-- PropertyCast
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PropertyCast')
BEGIN
    CREATE TABLE dbo.PropertyCast (
        PropertyCastId          INT PRIMARY KEY,
        PropertyCastTypeId      INT NOT NULL,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        PropertyCastStatusId    INT NOT NULL,
        ScheduleDate            DATETIME2 NULL,
        CreateDate              DATETIME2 NOT NULL,
        SentDate                DATETIME2 NULL,
        RecipientCount          INT NULL,
        DeliveredCount          INT NULL,
        FailedCount             INT NULL
    );
    PRINT '✓ Created table: PropertyCast';
END
GO

-- PropertyCollectionDetail
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PropertyCollectionDetail')
BEGIN
    CREATE TABLE dbo.PropertyCollectionDetail (
        PropertyCollectionDetailId INT PRIMARY KEY,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        AreaId                  INT NULL,
        PropertyTypeId          INT NULL,
        Name                    NVARCHAR(200) NULL,
        CreateDate              DATETIME2 NOT NULL
    );
    PRINT '✓ Created table: PropertyCollectionDetail';
END
GO

-- PropertyCastWorkflowQueue
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PropertyCastWorkflowQueue')
BEGIN
    CREATE TABLE dbo.PropertyCastWorkflowQueue (
        PropertyCastWorkflowQueueId INT PRIMARY KEY,
        PropertyCastId          INT NOT NULL,
        CollectionId            INT NOT NULL,
        CreateDate              DATETIME2 NOT NULL
    );
    PRINT '✓ Created table: PropertyCastWorkflowQueue';
END
GO

-- GenieLead (simplified)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GenieLead')
BEGIN
    CREATE TABLE dbo.GenieLead (
        GenieLeadId             INT PRIMARY KEY,
        PropertyCastId          INT NULL,
        AspNetUserId            NVARCHAR(128) NOT NULL,
        FirstName               NVARCHAR(100) NULL,
        LastName                NVARCHAR(100) NULL,
        Email                   NVARCHAR(200) NULL,
        Phone                   NVARCHAR(50) NULL,
        ClickDate               DATETIME2 NULL,
        CTASubmitDate           DATETIME2 NULL,
        VerifiedDate            DATETIME2 NULL,
        CreateDate              DATETIME2 NOT NULL
    );
    PRINT '✓ Created table: GenieLead';
END
GO

PRINT '';
PRINT '============================================';
PRINT 'SCHEMA READY - Now run the data insert script';
PRINT '============================================';
GO

