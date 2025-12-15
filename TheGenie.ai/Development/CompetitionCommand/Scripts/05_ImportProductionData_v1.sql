-- ============================================
-- Competition Command: Import Production Data
-- Version 1.0 | Created: 12/14/2025
-- Target: Local (localhost\SQLEXPRESS / FarmGenie_Dev)
-- ============================================

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE FarmGenie_Dev;
GO

PRINT '============================================';
PRINT 'IMPORTING PRODUCTION DATA TO LOCAL';
PRINT 'Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================';
PRINT '';

-- First, update table schemas to match import data
-- ============================================

-- Drop and recreate AspNetUsers with correct columns
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AspNetUsers')
    DROP TABLE dbo.AspNetUsers;
GO

CREATE TABLE dbo.AspNetUsers (
    Id                      NVARCHAR(128) PRIMARY KEY,
    UserName                NVARCHAR(256) NOT NULL,
    Email                   NVARCHAR(256) NULL,
    EmailConfirmed          BIT NOT NULL DEFAULT 0,
    PhoneNumber             NVARCHAR(50) NULL,
    PhoneNumberConfirmed    BIT NOT NULL DEFAULT 0,
    LockoutEnabled          BIT NOT NULL DEFAULT 0,
    AccessFailedCount       INT NOT NULL DEFAULT 0
);
PRINT '✓ Recreated AspNetUsers';
GO

-- Drop and recreate AspNetUserProfiles with correct columns
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AspNetUserProfiles')
    DROP TABLE dbo.AspNetUserProfiles;
GO

CREATE TABLE dbo.AspNetUserProfiles (
    AspNetUserId            NVARCHAR(128) PRIMARY KEY,
    FirstName               NVARCHAR(100) NULL,
    LastName                NVARCHAR(100) NULL,
    CreateDate              DATETIME2 NULL
);
PRINT '✓ Recreated AspNetUserProfiles';
GO

-- Drop and recreate ViewArea with correct columns  
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ViewArea')
    DROP TABLE dbo.ViewArea;
GO

CREATE TABLE dbo.ViewArea (
    AreaId                  INT PRIMARY KEY,
    Name                    NVARCHAR(200) NULL,
    AreaTypeId              INT NULL,
    StateFipsID             INT NULL,
    CenterLatitude          FLOAT NULL,
    CenterLongitude         FLOAT NULL
);
PRINT '✓ Recreated ViewArea';
GO

-- Drop and recreate PropertyCast with correct columns
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PropertyCast')
    DROP TABLE dbo.PropertyCast;
GO

CREATE TABLE dbo.PropertyCast (
    PropertyCastId          INT PRIMARY KEY,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    PropertyCastTypeId      INT NOT NULL,
    PropertyCastTriggerTypeId INT NULL,
    Enabled                 BIT NULL,
    CreateDate              DATETIME2 NULL,
    LastServiceRun          DATETIME2 NULL,
    AreaId                  INT NULL,
    PropertyTypeId          INT NULL
);
PRINT '✓ Recreated PropertyCast';
GO

-- Drop and recreate GenieLead with correct columns
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'GenieLead')
    DROP TABLE dbo.GenieLead;
GO

CREATE TABLE dbo.GenieLead (
    GenieLeadId             INT PRIMARY KEY,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    FirstName               NVARCHAR(100) NULL,
    LastName                NVARCHAR(100) NULL,
    Email                   NVARCHAR(200) NULL,
    Phone                   NVARCHAR(50) NULL,
    CreateDate              DATETIME2 NOT NULL
);
PRINT '✓ Recreated GenieLead';
GO

PRINT '';
PRINT 'Tables ready for BULK INSERT';
PRINT 'Run the BCP import commands next...';
GO

