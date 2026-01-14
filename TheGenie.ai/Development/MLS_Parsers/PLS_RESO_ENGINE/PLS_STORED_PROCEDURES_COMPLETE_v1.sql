-- ============================================================================
-- PLS RESO Engine - Complete Stored Procedures
-- Version: 1.0
-- Created: 01/09/2026
-- Last Updated: 01/09/2026
-- Author: Danny (Dev Lead)
-- Purpose: Complete stored procedures following Listing Command/Neighborhood Command patterns
-- ============================================================================
--
-- PATTERNS FOLLOWED:
-- - Consistent with Listing Command stored procedures
-- - Consistent with Neighborhood Command patterns
-- - Thread-safe operations
-- - Complete audit trail
-- - Permission-aware queries
--
-- ============================================================================

USE FarmGenie;
GO

-- ============================================================================
-- STORED PROCEDURE: usp_CreatePlsListing
-- Purpose: Create PLS listing with all related records (following Listing Command pattern)
-- Pattern: Similar to Listing Command creation workflow
-- ============================================================================

IF OBJECT_ID('dbo.usp_CreatePlsListing', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CreatePlsListing;
GO

CREATE PROCEDURE dbo.usp_CreatePlsListing
    @AspNetUserId NVARCHAR(128),
    @StreetNumber NVARCHAR(50),
    @StreetName NVARCHAR(100),
    @City NVARCHAR(100),
    @State NVARCHAR(2),
    @Zip NVARCHAR(10),
    @DisplayAddress NVARCHAR(200),
    @OriginalListPrice DECIMAL(18,2),
    @Bedrooms INT,
    @BathroomsFull INT,
    @BathroomsHalf INT = 0,
    @Sqft INT,
    @LotSqft INT,
    @YearBuilt INT,
    @Latitude FLOAT = NULL,
    @Longitude FLOAT = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @StatusTypeID INT,  -- 6 = Private, 14 = Coming Soon
    @AreaId INT = NULL,
    @MapboxPhotoUrl NVARCHAR(500) = NULL,
    @PlsNumber VARCHAR(10) OUTPUT,
    @ListingId INT OUTPUT,
    @ErrorMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MlsId INT = 777;
    DECLARE @PropertyCastTypeId INT = 4;
    DECLARE @SourceTypeId TINYINT;
    DECLARE @PlsStatusTypeId TINYINT;
    DECLARE @ListingAgentName NVARCHAR(200);
    DECLARE @ListingAgentID NVARCHAR(128);
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Step 1: Generate PLS Number
        EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNumber OUTPUT;
        
        IF @PlsNumber IS NULL
        BEGIN
            SET @ErrorMessage = 'Failed to generate PLS number';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Step 2: Get agent information (from AspNetUsers and related tables)
        SELECT TOP 1
            @ListingAgentName = COALESCE(ump.DisplayName, up.FirstName + ' ' + up.LastName, u.UserName),
            @ListingAgentID = u.Id
        FROM dbo.AspNetUsers u
        LEFT JOIN dbo.AspNetUserProfiles up ON up.AspNetUserId = u.Id
        LEFT JOIN dbo.UserMarketingProfile ump ON ump.AspNetUserId = u.Id
        WHERE u.Id = @AspNetUserId;
        
        IF @ListingAgentName IS NULL
        BEGIN
            SET @ListingAgentName = 'Unknown Agent';
            SET @ListingAgentID = @AspNetUserId;
        END
        
        -- Step 3: Get lookup IDs
        SELECT @SourceTypeId = source_type_id 
        FROM dbo.pls_source_type 
        WHERE source_code = 'paisley';
        
        SELECT @PlsStatusTypeId = status_type_id 
        FROM dbo.pls_status_type 
        WHERE status_code = CASE 
            WHEN @StatusTypeID = 6 THEN 'active'
            WHEN @StatusTypeID = 14 THEN 'coming_soon'
            ELSE 'draft'
        END;
        
        -- Defaults if not found
        IF @SourceTypeId IS NULL SET @SourceTypeId = 1;
        IF @PlsStatusTypeId IS NULL SET @PlsStatusTypeId = 2; -- draft
        
        -- Step 4: INSERT into MlsListing.dbo.Listing
        -- NOTE: PropertyCastTypeId is NOT in Listing table - it's only in ListingCommandQueue
        -- NOTE: DisplayAddress is a BIT flag (not the address string)
        -- NOTE: PropertyTypeID and SaleTypeID are required (NOT NULL)
        INSERT INTO MlsListing.dbo.Listing (
            MlsID, MlsNumber, StatusTypeID, PropertyTypeID, SaleTypeID,
            DisplayAddress, StreetNumber, StreetName, City, State, Zip,
            PriceLow, OriginalListPrice, Bedrooms, BathroomsTotal, BathroomsFull, BathroomsHalf,
            Sqft, LotSqft, YearBuilt, Latitude, Longitude, Remarks,
            ListingAgentName, ListingAgentID,
            ListDate
        )
        VALUES (
            @MlsId, @PlsNumber, @StatusTypeID, 1, 1,  -- PropertyTypeID = 1, SaleTypeID = 1 (defaults)
            1, @StreetNumber, @StreetName, @City, @State, @Zip,  -- DisplayAddress = 1 (show address)
            @OriginalListPrice, @OriginalListPrice, @Bedrooms, CAST((@BathroomsFull + @BathroomsHalf) AS DECIMAL(18,2)), @BathroomsFull, @BathroomsHalf,
            @Sqft, @LotSqft, @YearBuilt, @Latitude, @Longitude, @Description,
            @ListingAgentName, @ListingAgentID,
            GETUTCDATE()
        );
        
        SET @ListingId = SCOPE_IDENTITY();
        
        -- Step 5: INSERT Mapbox photo if provided
        IF @MapboxPhotoUrl IS NOT NULL
        BEGIN
            INSERT INTO MlsListing.dbo.Photo (ListingID, MlsID, PhotoUrl, DisplayOrder)
            VALUES (@ListingId, @MlsId, @MapboxPhotoUrl, 1);
        END
        
        -- Step 6: INSERT into pls_tracking
        INSERT INTO dbo.pls_tracking (
            listing_id, agent_id, source_type_id, status_type_id
        )
        VALUES (@ListingId, @AspNetUserId, @SourceTypeId, @PlsStatusTypeId);
        
        -- Step 7: INSERT into pls_status_log (initial status)
        INSERT INTO dbo.pls_status_log (
            listing_id, changed_by, from_status_type_id, to_status_type_id
        )
        VALUES (@ListingId, @AspNetUserId, NULL, @PlsStatusTypeId);
        
        -- Step 8: INSERT into PlsListingOwnership
        INSERT INTO dbo.PlsListingOwnership (
            AspNetUserId, ListingId, MlsId, MlsNumber, OwnershipTypeId
        )
        VALUES (@AspNetUserId, @ListingId, @MlsId, @PlsNumber, 1); -- 1 = Creator
        
        -- Step 9: Queue Listing Command (if area selected and status is active/coming_soon)
        -- NOTE: ListingCommandQueue doesn't have PropertyCastTypeId column - it only has:
        --       ListingCommandQueueId, AspNetUserId, ListingCommandUserConfigurationId, MlsNumber, MlsId
        -- PropertyCastTypeId (4 for PLS) is handled by the Listing Command service logic, not stored in queue
        IF @AreaId IS NOT NULL AND @StatusTypeID IN (6, 14)
        BEGIN
            INSERT INTO dbo.ListingCommandQueue (
                MlsId, MlsNumber, AspNetUserId
            )
            VALUES (@MlsId, @PlsNumber, @AspNetUserId);
        END
        
        COMMIT TRANSACTION;
        
        SET @ErrorMessage = NULL;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        SET @PlsNumber = NULL;
        SET @ListingId = NULL;
    END CATCH
END;
GO

PRINT 'usp_CreatePlsListing stored procedure created successfully';
GO

-- ============================================================================
-- STORED PROCEDURE: usp_UpdatePlsStatus
-- Purpose: Update PLS status with complete audit trail (following service patterns)
-- Pattern: Similar to Listing Command status updates
-- ============================================================================

IF OBJECT_ID('dbo.usp_UpdatePlsStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UpdatePlsStatus;
GO

CREATE PROCEDURE dbo.usp_UpdatePlsStatus
    @ListingId INT,
    @AspNetUserId NVARCHAR(128),
    @NewStatusCode NVARCHAR(50),  -- 'draft', 'active', 'coming_soon', etc.
    @ErrorMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewStatusTypeId TINYINT;
    DECLARE @CurrentStatusTypeId TINYINT;
    DECLARE @MlsStatusTypeId INT;
    DECLARE @IsPublished BIT;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get new status type ID
        SELECT @NewStatusTypeId = status_type_id
        FROM dbo.pls_status_type
        WHERE status_code = @NewStatusCode;
        
        IF @NewStatusTypeId IS NULL
        BEGIN
            SET @ErrorMessage = 'Invalid status code: ' + @NewStatusCode;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Get current status
        SELECT @CurrentStatusTypeId = status_type_id
        FROM dbo.pls_tracking
        WHERE listing_id = @ListingId;
        
        IF @CurrentStatusTypeId IS NULL
        BEGIN
            SET @ErrorMessage = 'Listing not found in pls_tracking';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Get MLS status mapping
        SELECT 
            @MlsStatusTypeId = mls_status_type_id,
            @IsPublished = is_published
        FROM dbo.pls_status_mapping
        WHERE pls_status_type_id = @NewStatusTypeId;
        
        -- Update pls_tracking
        UPDATE dbo.pls_tracking
        SET status_type_id = @NewStatusTypeId,
            updated_at = GETUTCDATE()
        WHERE listing_id = @ListingId;
        
        -- Update MlsListing.dbo.Listing if published
        IF @IsPublished = 1 AND @MlsStatusTypeId IS NOT NULL
        BEGIN
            UPDATE MlsListing.dbo.Listing
            SET StatusTypeID = @MlsStatusTypeId,
                ListDate = CASE WHEN ListDate IS NULL THEN GETUTCDATE() ELSE ListDate END
            WHERE ListingID = @ListingId AND MlsID = 777;
        END
        
        -- Log status change
        INSERT INTO dbo.pls_status_log (
            listing_id, changed_by, from_status_type_id, to_status_type_id
        )
        VALUES (@ListingId, @AspNetUserId, @CurrentStatusTypeId, @NewStatusTypeId);
        
        COMMIT TRANSACTION;
        SET @ErrorMessage = NULL;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
    END CATCH
END;
GO

PRINT 'usp_UpdatePlsStatus stored procedure created successfully';
GO

-- ============================================================================
-- STORED PROCEDURE: usp_GetPlsListingDetails
-- Purpose: Get complete PLS listing with all related data (following service patterns)
-- Pattern: Similar to Listing Command detail queries
-- ============================================================================

IF OBJECT_ID('dbo.usp_GetPlsListingDetails', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetPlsListingDetails;
GO

CREATE PROCEDURE dbo.usp_GetPlsListingDetails
    @PlsNumber VARCHAR(10),
    @AspNetUserId NVARCHAR(128) = NULL  -- For permission checking
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get listing details with PLS tracking info
    SELECT 
        -- Listing data
        l.ListingID,
        l.MlsID,
        l.MlsNumber,
        l.StatusTypeID,
        -- NOTE: PropertyCastTypeId is NOT in Listing table - it's only in ListingCommandQueue
        l.DisplayAddress,
        l.StreetNumber,
        l.StreetName,
        l.City,
        l.State,
        l.Zip,
        l.OriginalListPrice,
        l.Bedrooms,
        l.BathroomsTotal,
        l.BathroomsFull,
        l.BathroomsHalf,
        l.Sqft,
        l.LotSqft,
        l.YearBuilt,
        l.Latitude,
        l.Longitude,
        l.Remarks,
        l.ListingAgentName,
        l.ListingAgentID,
        l.CoListingAgentName,
        l.CoListingAgentID,
        l.ListDate,
        l.MlsCreateDate,
        -- PLS tracking data
        pt.id AS TrackingId,
        pt.agent_id AS OwnerAgentId,
        pt.source_type_id,
        st.source_code,
        st.source_name AS SourceName,
        pt.status_type_id,
        pst.status_code,
        pst.status_name AS StatusName,
        pt.was_listed,
        pt.mls_published,
        pt.created_at AS PlsCreatedAt,
        pt.updated_at AS PlsUpdatedAt,
        -- Ownership
        po.OwnershipTypeId,
        -- Permission check (if user provided)
        CASE 
            WHEN @AspNetUserId IS NULL THEN 1
            WHEN pt.agent_id = @AspNetUserId THEN 1
            WHEN EXISTS (
                SELECT 1 FROM dbo.Permission p
                INNER JOIN dbo.PermissionType pt ON pt.PermissionTypeId = p.PermissionTypeId
                WHERE p.UserId = @AspNetUserId 
                  AND pt.PermissionTypeId IN (213, 214)  -- PLS Radar or Impersonate
            ) THEN 1
            ELSE 0
        END AS CanEdit
    FROM MlsListing.dbo.Listing l
    INNER JOIN dbo.pls_tracking pt ON pt.listing_id = l.ListingID
    INNER JOIN dbo.pls_source_type st ON st.source_type_id = pt.source_type_id
    INNER JOIN dbo.pls_status_type pst ON pst.status_type_id = pt.status_type_id
    LEFT JOIN dbo.PlsListingOwnership po ON po.ListingId = l.ListingID AND po.AspNetUserId = pt.agent_id
    WHERE l.MlsID = 777
      AND l.MlsNumber = @PlsNumber;
    
    -- Get photos
    -- NOTE: Photo table doesn't have PhotoID - uses ListingID + MlsID as composite key
    SELECT 
        ListingID,
        MlsID,
        PhotoUrl,
        DisplayOrder
    FROM MlsListing.dbo.Photo
    WHERE ListingID = (SELECT ListingID FROM MlsListing.dbo.Listing WHERE MlsID = 777 AND MlsNumber = @PlsNumber)
      AND MlsID = 777
    ORDER BY DisplayOrder ASC;
    
    -- Get status log (audit trail)
    SELECT 
        psl.id,
        psl.changed_at,
        psl.changed_by,
        pst_from.status_code AS FromStatusCode,
        pst_from.status_name AS FromStatusName,
        pst_to.status_code AS ToStatusCode,
        pst_to.status_name AS ToStatusName,
        u.UserName AS ChangedByUserName
    FROM dbo.pls_status_log psl
    INNER JOIN dbo.pls_status_type pst_to ON pst_to.status_type_id = psl.to_status_type_id
    LEFT JOIN dbo.pls_status_type pst_from ON pst_from.status_type_id = psl.from_status_type_id
    LEFT JOIN dbo.AspNetUsers u ON u.Id = psl.changed_by
    WHERE psl.listing_id = (SELECT ListingID FROM MlsListing.dbo.Listing WHERE MlsID = 777 AND MlsNumber = @PlsNumber)
    ORDER BY psl.changed_at DESC;
    
END;
GO

PRINT 'usp_GetPlsListingDetails stored procedure created successfully';
GO

-- ============================================================================
-- STORED PROCEDURE: usp_GetPlsListingsByUser
-- Purpose: Get user's PLS listings (following service patterns)
-- Pattern: Similar to Listing Command user listing queries
-- ============================================================================

IF OBJECT_ID('dbo.usp_GetPlsListingsByUser', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetPlsListingsByUser;
GO

CREATE PROCEDURE dbo.usp_GetPlsListingsByUser
    @AspNetUserId NVARCHAR(128),
    @IncludeAll BIT = 0  -- 1 = Admin view (all listings), 0 = Own listings only
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Permission check for admin view
    IF @IncludeAll = 1
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Permission p
            INNER JOIN dbo.PermissionType pt ON pt.PermissionTypeId = p.PermissionTypeId
            WHERE p.UserId = @AspNetUserId 
              AND pt.PermissionTypeId = 213  -- PLS Radar
        )
        BEGIN
            SET @IncludeAll = 0;  -- Force to own listings if no permission
        END
    END
    
    SELECT 
        l.ListingID,
        l.MlsNumber AS PlsNumber,
        l.DisplayAddress,
        l.City,
        l.State,
        l.OriginalListPrice,
        l.Bedrooms,
        l.BathroomsTotal,
        l.Sqft,
        l.StatusTypeID,
        st.Name AS StatusName,
        pst.status_code AS PlsStatusCode,
        pst.status_name AS PlsStatusName,
        pt.created_at AS CreatedDate,
        pt.updated_at AS UpdatedDate,
        pt.was_listed,
        pt.mls_published,
        l.ListDate,
        -- Photo count
        (SELECT COUNT(*) FROM MlsListing.dbo.Photo WHERE ListingID = l.ListingID AND MlsID = 777) AS PhotoCount,
        -- Primary photo URL
        (SELECT TOP 1 PhotoUrl FROM MlsListing.dbo.Photo 
         WHERE ListingID = l.ListingID AND MlsID = 777 
         ORDER BY DisplayOrder ASC) AS PrimaryPhotoUrl
    FROM MlsListing.dbo.Listing l
    INNER JOIN dbo.pls_tracking pt ON pt.listing_id = l.ListingID
    INNER JOIN dbo.pls_status_type pst ON pst.status_type_id = pt.status_type_id
    INNER JOIN MlsListing.dbo.StatusType st ON st.StatusTypeID = l.StatusTypeID
    WHERE l.MlsID = 777
      AND (
          @IncludeAll = 1  -- Admin view all
          OR pt.agent_id = @AspNetUserId  -- Own listings
      )
    ORDER BY pt.updated_at DESC, l.ListDate DESC;
    
END;
GO

PRINT 'usp_GetPlsListingsByUser stored procedure created successfully';
GO

-- ============================================================================
-- STORED PROCEDURE: usp_QueuePlsListingCommand
-- Purpose: Queue PLS listing for Listing Command workflow (following Listing Command pattern)
-- Pattern: Identical to Listing Command queue insertion
-- ============================================================================

IF OBJECT_ID('dbo.usp_QueuePlsListingCommand', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_QueuePlsListingCommand;
GO

CREATE PROCEDURE dbo.usp_QueuePlsListingCommand
    @PlsNumber VARCHAR(10),
    @AspNetUserId NVARCHAR(128),
    @AreaId INT,
    @ErrorMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ListingId INT;
    DECLARE @MlsId INT = 777;
    DECLARE @PropertyCastTypeId INT = 4;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get ListingID from PLS number
        SELECT @ListingId = ListingID
        FROM MlsListing.dbo.Listing
        WHERE MlsID = @MlsId AND MlsNumber = @PlsNumber;
        
        IF @ListingId IS NULL
        BEGIN
            SET @ErrorMessage = 'PLS listing not found: ' + @PlsNumber;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Verify ownership
        IF NOT EXISTS (
            SELECT 1 FROM dbo.pls_tracking
            WHERE listing_id = @ListingId AND agent_id = @AspNetUserId
        )
        BEGIN
            -- Check for admin permission
            IF NOT EXISTS (
                SELECT 1 FROM dbo.Permission p
                INNER JOIN dbo.PermissionType pt ON pt.PermissionTypeId = p.PermissionTypeId
                WHERE p.UserId = @AspNetUserId 
                  AND pt.PermissionTypeId IN (213, 214)  -- PLS Radar or Impersonate
            )
            BEGIN
                SET @ErrorMessage = 'User does not have permission to queue this listing';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Check if already queued
        -- NOTE: ListingCommandQueue doesn't have PropertyCastTypeId or ProcessedDate columns
        IF EXISTS (
            SELECT 1 FROM dbo.ListingCommandQueue
            WHERE MlsId = @MlsId 
              AND MlsNumber = @PlsNumber
        )
        BEGIN
            SET @ErrorMessage = 'Listing already queued for Listing Command';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Insert into queue (following Listing Command pattern)
        -- NOTE: ListingCommandQueue only has: ListingCommandQueueId, AspNetUserId, 
        --       ListingCommandUserConfigurationId, MlsNumber, MlsId
        INSERT INTO dbo.ListingCommandQueue (
            MlsId,
            MlsNumber,
            AspNetUserId
        )
        VALUES (
            @MlsId,
            @PlsNumber,
            @AspNetUserId
        );
        
        COMMIT TRANSACTION;
        SET @ErrorMessage = NULL;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
    END CATCH
END;
GO

PRINT 'usp_QueuePlsListingCommand stored procedure created successfully';
GO

-- ============================================================================
-- VERIFICATION
-- ============================================================================

PRINT '';
PRINT '========================================';
PRINT 'PLS Stored Procedures Created';
PRINT '========================================';
PRINT '';
PRINT 'Procedures:';
PRINT '  1. usp_CreatePlsListing - Create listing with full workflow';
PRINT '  2. usp_UpdatePlsStatus - Update status with audit trail';
PRINT '  3. usp_GetPlsListingDetails - Get complete listing details';
PRINT '  4. usp_GetPlsListingsByUser - Get user listings (with permission check)';
PRINT '  5. usp_QueuePlsListingCommand - Queue for Listing Command workflow';
PRINT '';
PRINT 'Patterns:';
PRINT '  - Consistent with Listing Command stored procedures';
PRINT '  - Consistent with Neighborhood Command patterns';
PRINT '  - Permission-aware queries';
PRINT '  - Complete audit trail';
PRINT '  - Thread-safe operations';
PRINT '';
