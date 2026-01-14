-- ============================================================================
-- PLS Sandbox Complete Setup Script
-- Version: 1.0
-- Created: 01/05/2026
-- Last Updated: 01/05/2026
-- Author: Cursor AI Agent
-- Purpose: Complete PLS setup for sandbox - tables, master data, first listing
-- ============================================================================
--
-- EXECUTION ORDER:
-- 1. This script creates all PLS tables
-- 2. Inserts master data
-- 3. Fetches minimal reference data
-- 4. Imports 10037 Rebecca Place as first PLS listing (PLS100000A)
--
-- NOTE: AspNetUsers.Id is NVARCHAR(128) in sandbox (not 450)
--
-- ============================================================================

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================================
-- STEP 1: CREATE PLS TABLES (FarmGenie_Sandbox)
-- ============================================================================

USE FarmGenie_Sandbox;
GO

PRINT '========================================';
PRINT 'STEP 1: Creating PLS Tables';
PRINT '========================================';
GO

-- ----------------------------------------------------------------------------
-- LOOKUP TABLES
-- ----------------------------------------------------------------------------

-- pls_status_type
IF OBJECT_ID('dbo.pls_status_type', 'U') IS NOT NULL
    DROP TABLE dbo.pls_status_type;
GO

CREATE TABLE dbo.pls_status_type (
    status_type_id TINYINT IDENTITY(1,1) NOT NULL,
    status_code NVARCHAR(50) NOT NULL,
    status_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,
    display_order TINYINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_status_type PRIMARY KEY CLUSTERED (status_type_id),
    CONSTRAINT UQ_pls_status_type_code UNIQUE (status_code),
    CONSTRAINT CK_pls_status_type_display_order CHECK (display_order > 0)
);
GO

INSERT INTO dbo.pls_status_type (status_code, status_name, description, display_order)
VALUES
    ('incomplete', 'Incomplete', 'Listing not yet saved', 1),
    ('draft', 'Draft', 'Saved but not published', 2),
    ('active', 'Active', 'Private Listing (published)', 3),
    ('coming_soon', 'Coming Soon', 'Coming Soon (published)', 4),
    ('lost_opportunity', 'Lost Opportunity', 'Listing opportunity was lost', 5),
    ('published_to_mls', 'Published to MLS', 'Successfully published to actual MLS', 6);
GO

CREATE NONCLUSTERED INDEX IX_pls_status_type_code 
    ON dbo.pls_status_type (status_code)
    INCLUDE (status_name, display_order)
    WHERE is_active = 1;
GO

-- pls_source_type
IF OBJECT_ID('dbo.pls_source_type', 'U') IS NOT NULL
    DROP TABLE dbo.pls_source_type;
GO

CREATE TABLE dbo.pls_source_type (
    source_type_id TINYINT IDENTITY(1,1) NOT NULL,
    source_code NVARCHAR(50) NOT NULL,
    source_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,
    display_order TINYINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_source_type PRIMARY KEY CLUSTERED (source_type_id),
    CONSTRAINT UQ_pls_source_type_code UNIQUE (source_code),
    CONSTRAINT CK_pls_source_type_display_order CHECK (display_order > 0)
);
GO

INSERT INTO dbo.pls_source_type (source_code, source_name, description, display_order)
VALUES
    ('paisley', 'Paisley', 'Created via Paisley AI interface', 1),
    ('manual', 'Manual Entry', 'Manually created by agent', 2),
    ('import', 'Import', 'Imported from external source', 3),
    ('api', 'API', 'Created via API integration', 4);
GO

CREATE NONCLUSTERED INDEX IX_pls_source_type_code 
    ON dbo.pls_source_type (source_code)
    INCLUDE (source_name, display_order)
    WHERE is_active = 1;
GO

-- pls_status_mapping
IF OBJECT_ID('dbo.pls_status_mapping', 'U') IS NOT NULL
    DROP TABLE dbo.pls_status_mapping;
GO

CREATE TABLE dbo.pls_status_mapping (
    mapping_id INT IDENTITY(1,1) NOT NULL,
    pls_status_type_id TINYINT NOT NULL,
    mls_status_type_id INT NULL,
    is_published BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_status_mapping PRIMARY KEY CLUSTERED (mapping_id),
    CONSTRAINT FK_pls_status_mapping_status FOREIGN KEY (pls_status_type_id)
        REFERENCES dbo.pls_status_type(status_type_id) ON DELETE CASCADE,
    CONSTRAINT UQ_pls_status_mapping_status UNIQUE (pls_status_type_id)
);
GO

-- Insert status mappings (fix CHECK constraint - allow NULL mls_status_type_id)
INSERT INTO dbo.pls_status_mapping (pls_status_type_id, mls_status_type_id, is_published)
SELECT 
    st.status_type_id,
    CASE st.status_code
        WHEN 'active' THEN 6      -- Private Listing
        WHEN 'coming_soon' THEN 14 -- Coming Soon
        ELSE NULL                 -- incomplete, draft, lost_opportunity, published_to_mls
    END AS mls_status_type_id,
    CASE st.status_code
        WHEN 'active' THEN 1
        WHEN 'coming_soon' THEN 1
        WHEN 'published_to_mls' THEN 1
        ELSE 0
    END AS is_published
FROM dbo.pls_status_type st;
GO

-- pls_tracking (FIXED: agent_id = NVARCHAR(128) to match sandbox)
IF OBJECT_ID('dbo.pls_tracking', 'U') IS NOT NULL
    DROP TABLE dbo.pls_tracking;
GO

CREATE TABLE dbo.pls_tracking (
    id INT IDENTITY(1,1) NOT NULL,
    listing_id INT NOT NULL,
    agent_id NVARCHAR(128) NOT NULL,  -- FIXED: 128 to match sandbox AspNetUsers.Id
    source_type_id TINYINT NOT NULL DEFAULT 1,
    status_type_id TINYINT NOT NULL DEFAULT 1,
    was_listed BIT NOT NULL DEFAULT 0,
    mls_published BIT NOT NULL DEFAULT 0,
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_tracking PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pls_tracking_agent FOREIGN KEY (agent_id) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE CASCADE,
    CONSTRAINT FK_pls_tracking_source FOREIGN KEY (source_type_id)
        REFERENCES dbo.pls_source_type(source_type_id) ON DELETE NO ACTION,
    CONSTRAINT FK_pls_tracking_status FOREIGN KEY (status_type_id)
        REFERENCES dbo.pls_status_type(status_type_id) ON DELETE NO ACTION,
    CONSTRAINT UQ_pls_tracking_listing_id UNIQUE (listing_id)
);
GO

CREATE NONCLUSTERED INDEX IX_pls_tracking_listing_id 
    ON dbo.pls_tracking (listing_id)
    INCLUDE (agent_id, status_type_id, mls_published, updated_at);
GO

CREATE NONCLUSTERED INDEX IX_pls_tracking_agent_id 
    ON dbo.pls_tracking (agent_id, status_type_id)
    INCLUDE (listing_id, created_at, was_listed);
GO

CREATE NONCLUSTERED INDEX IX_pls_tracking_status_type 
    ON dbo.pls_tracking (status_type_id, updated_at)
    INCLUDE (listing_id, agent_id, mls_published);
GO

-- pls_status_log (FIXED: changed_by = NVARCHAR(128) to match sandbox)
IF OBJECT_ID('dbo.pls_status_log', 'U') IS NOT NULL
    DROP TABLE dbo.pls_status_log;
GO

CREATE TABLE dbo.pls_status_log (
    id BIGINT IDENTITY(1,1) NOT NULL,
    listing_id INT NOT NULL,
    changed_by NVARCHAR(128) NOT NULL,  -- FIXED: 128 to match sandbox AspNetUsers.Id
    from_status_type_id TINYINT NULL,
    to_status_type_id TINYINT NOT NULL,
    changed_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_status_log PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pls_status_log_user FOREIGN KEY (changed_by) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE NO ACTION,
    CONSTRAINT FK_pls_status_log_from_status FOREIGN KEY (from_status_type_id)
        REFERENCES dbo.pls_status_type(status_type_id) ON DELETE NO ACTION,
    CONSTRAINT FK_pls_status_log_to_status FOREIGN KEY (to_status_type_id)
        REFERENCES dbo.pls_status_type(status_type_id) ON DELETE NO ACTION
);
GO

CREATE NONCLUSTERED INDEX IX_pls_status_log_listing_id 
    ON dbo.pls_status_log (listing_id, changed_at DESC)
    INCLUDE (from_status_type_id, to_status_type_id, changed_by);
GO

CREATE NONCLUSTERED INDEX IX_pls_status_log_changed_by 
    ON dbo.pls_status_log (changed_by, changed_at DESC)
    INCLUDE (listing_id, to_status_type_id);
GO

-- PlsListingOwnership (FIXED: AspNetUserId = NVARCHAR(128) to match sandbox)
IF OBJECT_ID('dbo.PlsListingOwnership', 'U') IS NOT NULL
    DROP TABLE dbo.PlsListingOwnership;
GO

CREATE TABLE dbo.PlsListingOwnership (
    PlsListingOwnershipId INT IDENTITY(1,1) NOT NULL,
    AspNetUserId NVARCHAR(128) NOT NULL,  -- FIXED: 128 to match sandbox
    MlsId INT NOT NULL DEFAULT 777,
    MlsNumber VARCHAR(10) NOT NULL,  -- PLS100000A format
    ListingId INT NOT NULL,
    OwnershipTypeId INT NOT NULL DEFAULT 1,
    IsActive BIT NOT NULL DEFAULT 1,
    CreateDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    LastUpdate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_PlsListingOwnership PRIMARY KEY CLUSTERED (PlsListingOwnershipId),
    CONSTRAINT FK_PlsListingOwnership_User FOREIGN KEY (AspNetUserId) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE CASCADE,
    CONSTRAINT UQ_PlsListingOwnership_User_Listing_Type UNIQUE (AspNetUserId, ListingId, OwnershipTypeId),
    CONSTRAINT UQ_PlsListingOwnership_User_Mls_Number UNIQUE (AspNetUserId, MlsId, MlsNumber)
);
GO

CREATE NONCLUSTERED INDEX IX_PlsListingOwnership_ListingId 
    ON dbo.PlsListingOwnership (ListingId, IsActive)
    INCLUDE (AspNetUserId, OwnershipTypeId, MlsNumber);
GO

-- PlsNumberSequence
IF OBJECT_ID('dbo.PlsNumberSequence', 'U') IS NOT NULL
    DROP TABLE dbo.PlsNumberSequence;
GO

CREATE TABLE dbo.PlsNumberSequence (
    LetterSuffix CHAR(1) NOT NULL,
    CurrentNumber INT NOT NULL DEFAULT 100000,
    LastUpdate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_PlsNumberSequence PRIMARY KEY CLUSTERED (LetterSuffix),
    CONSTRAINT CK_PlsNumberSequence_Number CHECK (CurrentNumber >= 100000 AND CurrentNumber <= 999999),
    CONSTRAINT CK_PlsNumberSequence_Letter CHECK (LetterSuffix >= 'A' AND LetterSuffix <= 'Z')
);
GO

INSERT INTO dbo.PlsNumberSequence (LetterSuffix, CurrentNumber, LastUpdate)
VALUES ('A', 100000, GETUTCDATE());
GO

-- usp_GetNextPlsNumber
IF OBJECT_ID('dbo.usp_GetNextPlsNumber', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetNextPlsNumber;
GO

CREATE PROCEDURE dbo.usp_GetNextPlsNumber
    @PlsNumber VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER ON;
    
    DECLARE @CurrentLetter CHAR(1) = 'A';
    DECLARE @NextNumber INT;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        SELECT TOP 1 
            @CurrentLetter = LetterSuffix,
            @NextNumber = CurrentNumber
        FROM dbo.PlsNumberSequence WITH (UPDLOCK, ROWLOCK)
        WHERE CurrentNumber < 999999
        ORDER BY LetterSuffix ASC, CurrentNumber ASC;
        
        IF @NextNumber IS NULL
        BEGIN
            SELECT TOP 1 
                @CurrentLetter = LetterSuffix,
                @NextNumber = CurrentNumber
            FROM dbo.PlsNumberSequence WITH (UPDLOCK, ROWLOCK)
            ORDER BY LetterSuffix DESC;
            
            IF @NextNumber IS NULL
            BEGIN
                SET @CurrentLetter = 'A';
                SET @NextNumber = 100000;
            END
            ELSE IF @NextNumber = 999999
            BEGIN
                IF @CurrentLetter < 'Z'
                BEGIN
                    SET @CurrentLetter = CHAR(ASCII(@CurrentLetter) + 1);
                    SET @NextNumber = 100000;
                END
                ELSE
                BEGIN
                    SET @CurrentLetter = 'A';
                    SET @NextNumber = 100000;
                END
            END
        END
        
        SET @NextNumber = @NextNumber + 1;
        
        IF EXISTS (SELECT 1 FROM dbo.PlsNumberSequence WHERE LetterSuffix = @CurrentLetter)
        BEGIN
            UPDATE dbo.PlsNumberSequence
            SET CurrentNumber = @NextNumber,
                LastUpdate = GETUTCDATE()
            WHERE LetterSuffix = @CurrentLetter;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.PlsNumberSequence (LetterSuffix, CurrentNumber, LastUpdate)
            VALUES (@CurrentLetter, @NextNumber, GETUTCDATE());
        END
        
        SET @PlsNumber = 'PLS' + RIGHT('000000' + CAST(@NextNumber AS VARCHAR), 6) + @CurrentLetter;
        
        COMMIT TRANSACTION;
        
        SELECT @PlsNumber AS PlsNumber;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @PlsNumber = NULL;
        THROW;
    END CATCH
END;
GO

PRINT '✓ PLS tables created in FarmGenie_Sandbox';
GO

-- ============================================================================
-- STEP 2: MASTER DATA INSERTS (MlsListing_Sandbox)
-- ============================================================================

USE MlsListing_Sandbox;
GO

PRINT '';
PRINT '========================================';
PRINT 'STEP 2: Inserting Master Data';
PRINT '========================================';
GO

-- StatusType 6 (Private Listing)
IF NOT EXISTS (SELECT 1 FROM dbo.StatusType WHERE StatusTypeID = 6)
BEGIN
    INSERT INTO dbo.StatusType (StatusTypeID, Name, Description)
    VALUES (6, 'Private Listing', 'Private listing (pre-MLS)');
    PRINT '✓ StatusTypeID 6 (Private Listing) inserted';
END
ELSE
BEGIN
    PRINT '✓ StatusTypeID 6 (Private Listing) already exists';
END
GO

-- StatusType 14 (Coming Soon) - verify exists
IF EXISTS (SELECT 1 FROM dbo.StatusType WHERE StatusTypeID = 14)
BEGIN
    PRINT '✓ StatusTypeID 14 (Coming Soon) exists';
END
ELSE
BEGIN
    PRINT '⚠ StatusTypeID 14 (Coming Soon) does NOT exist - may need to insert';
END
GO

-- MlsID 777
IF NOT EXISTS (SELECT 1 FROM dbo.Mls WHERE MlsID = 777)
BEGIN
    -- Get column list for Mls table
    INSERT INTO dbo.Mls (MlsID, Name, Description)
    VALUES (777, 'PLS', 'Paisley Listing Service (Private Listing Service)');
    PRINT '✓ MlsID 777 (PLS) inserted';
END
ELSE
BEGIN
    PRINT '✓ MlsID 777 (PLS) already exists';
END
GO

-- ============================================================================
-- STEP 3: FETCH MINIMAL REFERENCE DATA
-- ============================================================================

USE FarmGenie_Sandbox;
GO

PRINT '';
PRINT '========================================';
PRINT 'STEP 3: Fetching Reference Data';
PRINT '========================================';
GO

-- PropertyCastType 4
IF NOT EXISTS (SELECT 1 FROM dbo.PropertyCastType WHERE PropertyCastTypeId = 4)
BEGIN
    IF EXISTS (SELECT 1 FROM FarmGenie.dbo.PropertyCastType WHERE PropertyCastTypeId = 4)
    BEGIN
        INSERT INTO FarmGenie_Sandbox.dbo.PropertyCastType (PropertyCastTypeId, Name, Description)
        SELECT PropertyCastTypeId, Name, Description
        FROM FarmGenie.dbo.PropertyCastType
        WHERE PropertyCastTypeId = 4;
        PRINT '✓ PropertyCastTypeId 4 copied from production';
    END
    ELSE
    BEGIN
        INSERT INTO dbo.PropertyCastType (PropertyCastTypeId, Name, Description)
        VALUES (4, 'PLS', 'Private Listing Service');
        PRINT '✓ PropertyCastTypeId 4 created';
    END
END
ELSE
BEGIN
    PRINT '✓ PropertyCastTypeId 4 already exists';
END
GO

-- PermissionType 210-214
INSERT INTO FarmGenie_Sandbox.dbo.PermissionType (PermissionTypeId, Name, Description)
SELECT PermissionTypeId, Name, Description
FROM FarmGenie.dbo.PermissionType
WHERE PermissionTypeId BETWEEN 210 AND 214
    AND NOT EXISTS (
        SELECT 1 FROM FarmGenie_Sandbox.dbo.PermissionType pt2 
        WHERE pt2.PermissionTypeId = FarmGenie.dbo.PermissionType.PermissionTypeId
    );
PRINT '✓ PermissionType records: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- Sample AspNetUser (get one from production)
IF NOT EXISTS (SELECT 1 FROM dbo.AspNetUsers)
BEGIN
    INSERT INTO dbo.AspNetUsers (
        Id, Email, EmailConfirmed, PasswordHash, SecurityStamp, PhoneNumber, 
        PhoneNumberConfirmed, TwoFactorEnabled, LockoutEndDateUtc, LockoutEnabled, 
        AccessFailedCount, UserName
    )
    SELECT TOP 1
        Id, Email, EmailConfirmed, PasswordHash, SecurityStamp, PhoneNumber,
        PhoneNumberConfirmed, TwoFactorEnabled, LockoutEndDateUtc, LockoutEnabled,
        AccessFailedCount, UserName
    FROM FarmGenie.dbo.AspNetUsers
    WHERE EmailConfirmed = 1
    ORDER BY Id;
    PRINT '✓ AspNetUser copied: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' row';
END
ELSE
BEGIN
    PRINT '✓ AspNetUsers already has data';
END
GO

-- ============================================================================
-- STEP 4: IMPORT 10037 REBECCA PLACE AS FIRST PLS LISTING
-- ============================================================================

USE MlsListing_Sandbox;
GO

PRINT '';
PRINT '========================================';
PRINT 'STEP 4: Importing 10037 Rebecca Place';
PRINT '========================================';
GO

-- Get the listing from production
DECLARE @SourceListingID INT;
DECLARE @NewListingID INT;
DECLARE @PlsNumber VARCHAR(10);
DECLARE @AgentId NVARCHAR(128);
DECLARE @StatusTypeId TINYINT;

-- Get source listing
SELECT TOP 1 @SourceListingID = ListingID
FROM MlsListing.dbo.Listing
WHERE StreetNumber = '10037' 
    AND StreetName LIKE '%Rebecca%'
    AND City = 'Boerne'
ORDER BY ListDate DESC;

IF @SourceListingID IS NULL
BEGIN
    PRINT 'ERROR: Could not find 10037 Rebecca Place in production';
    RETURN;
END

PRINT 'Found source listing: ListingID ' + CAST(@SourceListingID AS VARCHAR);

-- Get next PLS number
EXEC FarmGenie_Sandbox.dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNumber OUTPUT;
PRINT 'Generated PLS Number: ' + @PlsNumber;

-- Get a test user
SELECT TOP 1 @AgentId = Id
FROM FarmGenie_Sandbox.dbo.AspNetUsers;

-- Get status type ID for 'draft'
SELECT @StatusTypeId = status_type_id
FROM FarmGenie_Sandbox.dbo.pls_status_type
WHERE status_code = 'draft';

-- Insert into Listing (copy from production, modify for PLS)
INSERT INTO MlsListing_Sandbox.dbo.Listing (
    MlsID, MlsNumber, DisplayAddress, StreetNumber, StreetName, City, State, Zip, County,
    OriginalListPrice, Bedrooms, BathroomsFull, BathroomsTotal, Sqft, YearBuilt, LotSqft,
    StatusTypeID, PropertyTypeID, ListDate, MlsCreateDate, MlsUpdateDate,
    Latitude, Longitude, APN, Remarks
)
SELECT 
    777 AS MlsID,  -- PLS identifier
    @PlsNumber AS MlsNumber,  -- PLS100000A
    DisplayAddress, StreetNumber, StreetName, City, State, Zip, County,
    OriginalListPrice, Bedrooms, BathroomsFull, BathroomsTotal, Sqft, YearBuilt, LotSqft,
    6 AS StatusTypeID,  -- Private Listing
    PropertyTypeID,
    GETUTCDATE() AS ListDate,
    GETUTCDATE() AS MlsCreateDate,
    GETUTCDATE() AS MlsUpdateDate,
    Latitude, Longitude, APN,
    ISNULL(Remarks, '') AS Remarks
FROM MlsListing.dbo.Listing
WHERE ListingID = @SourceListingID;

SET @NewListingID = SCOPE_IDENTITY();
PRINT 'Created new listing: ListingID ' + CAST(@NewListingID AS VARCHAR);

-- Insert into pls_tracking
INSERT INTO FarmGenie_Sandbox.dbo.pls_tracking (
    listing_id, agent_id, source_type_id, status_type_id, was_listed, mls_published
)
VALUES (
    @NewListingID, 
    @AgentId, 
    2,  -- manual
    @StatusTypeId,  -- draft
    1,  -- was_listed
    0   -- mls_published
);
PRINT '✓ pls_tracking record created';

-- Insert into PlsListingOwnership
INSERT INTO FarmGenie_Sandbox.dbo.PlsListingOwnership (
    AspNetUserId, MlsId, MlsNumber, ListingId, OwnershipTypeId
)
VALUES (
    @AgentId, 777, @PlsNumber, @NewListingID, 1  -- Creator
);
PRINT '✓ PlsListingOwnership record created';

-- Insert initial status log
INSERT INTO FarmGenie_Sandbox.dbo.pls_status_log (
    listing_id, changed_by, from_status_type_id, to_status_type_id
)
VALUES (
    @NewListingID, 
    @AgentId, 
    NULL,  -- initial creation
    @StatusTypeId  -- draft
);
PRINT '✓ pls_status_log record created';

PRINT '';
PRINT '========================================';
PRINT 'Setup Complete!';
PRINT '========================================';
PRINT 'First PLS Listing:';
PRINT '  PLS Number: ' + @PlsNumber;
PRINT '  ListingID: ' + CAST(@NewListingID AS VARCHAR);
PRINT '  Address: 10037 Rebecca Place, Boerne, TX 78006';
PRINT '';
PRINT 'Next: Build UI to modify, save, and publish this listing';
GO

