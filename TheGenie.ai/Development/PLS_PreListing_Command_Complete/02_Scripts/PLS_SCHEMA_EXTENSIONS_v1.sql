-- ============================================================================
-- PLS RESO Engine - Schema Extensions
-- Version: 1.1
-- Created: 01/05/2026
-- Last Updated: 01/05/2026
-- Change: Updated MlsID from 999 to 777 for PLS listings
-- Author: Cursor AI Agent
-- Purpose: SQL schema extensions for PLS (Private Listing Service) feature
--          Extends existing RESO-based architecture without duplicating listing schema
-- ============================================================================
--
-- CRITICAL: These tables extend the existing MlsListing.dbo.Listing table
--           DO NOT create a new listing table - use existing MlsListing.dbo.Listing
--           with MlsID=777 for PLS listings
--
-- Database: FarmGenie (for PLS tracking tables)
--           MlsListing (for listing data - existing table, no changes)
--
-- Dependencies:
--   - MlsListing.dbo.Listing (existing table)
--   - FarmGenie.dbo.AspNetUsers (existing table)
--   - FarmGenie.dbo.Permission (existing table)
-- ============================================================================

USE FarmGenie;
GO

-- ============================================================================
-- TABLE 1: pls_tracking
-- Purpose: Tracks PLS-specific metadata for each listing
-- Links to: MlsListing.dbo.Listing (via ListingID)
--          FarmGenie.dbo.AspNetUsers (via agent_id)
-- ============================================================================

IF OBJECT_ID('dbo.pls_tracking', 'U') IS NOT NULL
    DROP TABLE dbo.pls_tracking;
GO

CREATE TABLE dbo.pls_tracking (
    -- Primary Key
    id INT IDENTITY(1,1) NOT NULL,
    
    -- Foreign Keys
    listing_id INT NOT NULL,
        -- References: MlsListing.dbo.Listing(ListingID)
        -- Note: Cross-database FK not enforced, validated in application layer
    agent_id NVARCHAR(450) NOT NULL,
        -- References: FarmGenie.dbo.AspNetUsers(Id)
        -- Stores the ASP.NET User ID (GUID as string)
    
    -- PLS Metadata
    source NVARCHAR(50) NOT NULL DEFAULT 'paisley',
        -- Values: 'paisley', 'manual', 'import', etc.
        -- Tracks how the listing was created
    
    status NVARCHAR(50) NOT NULL DEFAULT 'incomplete',
        -- ENUM values: 'incomplete', 'draft', 'active', 'coming_soon', 
        --             'lost_opportunity', 'published_to_mls'
        -- Maps to StatusTypeID in MlsListing.dbo.Listing:
        --   'incomplete' = not yet saved
        --   'draft' = saved but not published
        --   'active' = StatusTypeID 6 (Private Listing)
        --   'coming_soon' = StatusTypeID 14 (Coming Soon)
        --   'lost_opportunity' = listing lost, not published
        --   'published_to_mls' = successfully published to actual MLS
    
    -- Business Logic Flags
    was_listed BIT NOT NULL DEFAULT 0,
        -- Whether the agent ultimately got the listing
        -- TRUE = agent secured the listing
        -- FALSE = listing opportunity was lost
    
    mls_published BIT NOT NULL DEFAULT 0,
        -- Whether this PLS listing was published to actual MLS
        -- TRUE = successfully pushed to MLS via RESO Insert (future feature)
        -- FALSE = still private/pre-MLS
    
    -- Audit Timestamps
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    -- Constraints
    CONSTRAINT PK_pls_tracking PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pls_tracking_agent FOREIGN KEY (agent_id) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE CASCADE,
    CONSTRAINT CK_pls_tracking_status CHECK (
        status IN ('incomplete', 'draft', 'active', 'coming_soon', 
                   'lost_opportunity', 'published_to_mls')
    ),
    CONSTRAINT CK_pls_tracking_source CHECK (
        source IN ('paisley', 'manual', 'import', 'api')
    )
);
GO

-- Indexes for pls_tracking
CREATE NONCLUSTERED INDEX IX_pls_tracking_listing_id 
    ON dbo.pls_tracking (listing_id)
    INCLUDE (agent_id, status, mls_published, updated_at);
GO

CREATE NONCLUSTERED INDEX IX_pls_tracking_agent_id 
    ON dbo.pls_tracking (agent_id, status)
    INCLUDE (listing_id, created_at, was_listed)
    WHERE status IN ('active', 'coming_soon', 'draft');
GO

CREATE NONCLUSTERED INDEX IX_pls_tracking_status 
    ON dbo.pls_tracking (status, updated_at)
    INCLUDE (listing_id, agent_id, mls_published)
    WHERE status IN ('active', 'coming_soon', 'published_to_mls');
GO

-- Unique constraint: One tracking record per listing
CREATE UNIQUE NONCLUSTERED INDEX UQ_pls_tracking_listing_id 
    ON dbo.pls_tracking (listing_id);
GO

-- ============================================================================
-- TABLE 2: pls_status_log
-- Purpose: Tracks every status transition for a PLS listing (audit trail)
-- Links to: MlsListing.dbo.Listing (via listing_id)
--          FarmGenie.dbo.AspNetUsers (via changed_by)
-- ============================================================================

IF OBJECT_ID('dbo.pls_status_log', 'U') IS NOT NULL
    DROP TABLE dbo.pls_status_log;
GO

CREATE TABLE dbo.pls_status_log (
    -- Primary Key
    id BIGINT IDENTITY(1,1) NOT NULL,
    
    -- Foreign Keys
    listing_id INT NOT NULL,
        -- References: MlsListing.dbo.Listing(ListingID)
        -- Note: Cross-database FK not enforced, validated in application layer
    changed_by NVARCHAR(450) NOT NULL,
        -- References: FarmGenie.dbo.AspNetUsers(Id)
        -- Stores the ASP.NET User ID who made the change
    
    -- Status Transition Data
    from_status NVARCHAR(50) NULL,
        -- Previous status value
        -- NULL = initial creation (no previous status)
    to_status NVARCHAR(50) NOT NULL,
        -- New status value
        -- Must match pls_tracking.status enum values
    
    -- Audit Timestamp
    changed_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    -- Constraints
    CONSTRAINT PK_pls_status_log PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pls_status_log_user FOREIGN KEY (changed_by) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE NO ACTION,
        -- NO ACTION: Preserve audit trail even if user is deleted
    CONSTRAINT CK_pls_status_log_to_status CHECK (
        to_status IN ('incomplete', 'draft', 'active', 'coming_soon', 
                      'lost_opportunity', 'published_to_mls')
    ),
    CONSTRAINT CK_pls_status_log_from_status CHECK (
        from_status IS NULL OR 
        from_status IN ('incomplete', 'draft', 'active', 'coming_soon', 
                        'lost_opportunity', 'published_to_mls')
    )
);
GO

-- Indexes for pls_status_log
CREATE NONCLUSTERED INDEX IX_pls_status_log_listing_id 
    ON dbo.pls_status_log (listing_id, changed_at DESC)
    INCLUDE (from_status, to_status, changed_by);
GO

CREATE NONCLUSTERED INDEX IX_pls_status_log_changed_by 
    ON dbo.pls_status_log (changed_by, changed_at DESC)
    INCLUDE (listing_id, to_status);
GO

CREATE NONCLUSTERED INDEX IX_pls_status_log_to_status 
    ON dbo.pls_status_log (to_status, changed_at DESC)
    INCLUDE (listing_id, changed_by)
    WHERE to_status IN ('published_to_mls', 'lost_opportunity');
GO

-- ============================================================================
-- TABLE 3: pls_collaborators
-- Purpose: Tracks co-agents or title reps involved in a PLS listing
-- Links to: MlsListing.dbo.Listing (via listing_id)
--          FarmGenie.dbo.AspNetUsers (via user_id)
-- ============================================================================

IF OBJECT_ID('dbo.pls_collaborators', 'U') IS NOT NULL
    DROP TABLE dbo.pls_collaborators;
GO

CREATE TABLE dbo.pls_collaborators (
    -- Primary Key
    id INT IDENTITY(1,1) NOT NULL,
    
    -- Foreign Keys
    listing_id INT NOT NULL,
        -- References: MlsListing.dbo.Listing(ListingID)
        -- Note: Cross-database FK not enforced, validated in application layer
    user_id NVARCHAR(450) NOT NULL,
        -- References: FarmGenie.dbo.AspNetUsers(Id)
        -- Stores the ASP.NET User ID of the collaborator
    
    -- Collaboration Metadata
    role NVARCHAR(50) NOT NULL,
        -- ENUM values: 'title_rep', 'co_lister'
        -- 'title_rep' = Title company representative
        -- 'co_lister' = Co-listing agent
    
    -- Audit Timestamp
    joined_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    -- Constraints
    CONSTRAINT PK_pls_collaborators PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pls_collaborators_user FOREIGN KEY (user_id) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE CASCADE,
    CONSTRAINT CK_pls_collaborators_role CHECK (
        role IN ('title_rep', 'co_lister')
    ),
    -- Unique constraint: One role per user per listing
    CONSTRAINT UQ_pls_collaborators_listing_user_role UNIQUE (listing_id, user_id, role)
);
GO

-- Indexes for pls_collaborators
CREATE NONCLUSTERED INDEX IX_pls_collaborators_listing_id 
    ON dbo.pls_collaborators (listing_id)
    INCLUDE (user_id, role, joined_at);
GO

CREATE NONCLUSTERED INDEX IX_pls_collaborators_user_id 
    ON dbo.pls_collaborators (user_id, role)
    INCLUDE (listing_id, joined_at);
GO

CREATE NONCLUSTERED INDEX IX_pls_collaborators_role 
    ON dbo.pls_collaborators (role, listing_id)
    INCLUDE (user_id, joined_at)
    WHERE role = 'title_rep';
GO

-- ============================================================================
-- PERMISSIONS & SECURITY
-- ============================================================================
--
-- Permissions Model (from existing Permission table):
--   - Permission 210: ManagePLS - Create/edit/delete PLS listings
--   - Permission 211: Menu PLS - Access PLS menu item
--   - Permission 212: View PLS History - View status log
--   - Permission 213: PLS Radar - View all PLS listings (admin)
--   - Permission 214: PLS Submit While Impersonating - Submit as another user
--
-- Role Requirements:
--   - Elite Agent or higher: Can create/edit listings (Permission 210)
--   - Listing owners: Can publish to MLS (validated in application layer)
--   - Admins: Can view all (Permission 213)
--
-- Note: Permissions are enforced in application layer, not database level
-- ============================================================================

-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================
--
-- Example 1: Create PLS tracking record
-- INSERT INTO dbo.pls_tracking (listing_id, agent_id, source, status)
-- VALUES (12345, 'user-guid-here', 'paisley', 'draft');
--
-- Example 2: Log status change
-- INSERT INTO dbo.pls_status_log (listing_id, changed_by, from_status, to_status)
-- VALUES (12345, 'user-guid-here', 'draft', 'active');
--
-- Example 3: Add collaborator
-- INSERT INTO dbo.pls_collaborators (listing_id, user_id, role)
-- VALUES (12345, 'title-rep-guid-here', 'title_rep');
--
-- Example 4: Query user's active PLS listings with tracking
-- SELECT 
--     l.ListingID,
--     l.MlsNumber,
--     l.DisplayAddress,
--     pt.status,
--     pt.was_listed,
--     pt.mls_published
-- FROM MlsListing.dbo.Listing l
-- INNER JOIN dbo.pls_tracking pt ON pt.listing_id = l.ListingID
-- WHERE pt.agent_id = 'user-guid-here'
--     AND l.MlsID = 777
--     AND pt.status IN ('active', 'coming_soon')
-- ORDER BY pt.updated_at DESC;
--
-- Example 5: Get status history for a listing
-- SELECT 
--     from_status,
--     to_status,
--     changed_by,
--     changed_at
-- FROM dbo.pls_status_log
-- WHERE listing_id = 12345
-- ORDER BY changed_at DESC;
--
-- Example 6: Get all collaborators for a listing
-- SELECT 
--     u.Email,
--     u.UserName,
--     pc.role,
--     pc.joined_at
-- FROM dbo.pls_collaborators pc
-- INNER JOIN dbo.AspNetUsers u ON u.Id = pc.user_id
-- WHERE pc.listing_id = 12345
-- ORDER BY pc.joined_at ASC;
--
-- ============================================================================

-- ============================================================================
-- NOTES & CONSIDERATIONS
-- ============================================================================
--
-- 1. Cross-Database Foreign Keys:
--    - listing_id references MlsListing.dbo.Listing(ListingID)
--    - SQL Server does not support cross-database foreign keys
--    - Validation must be enforced in application layer
--
-- 2. Status Synchronization:
--    - pls_tracking.status should be kept in sync with MlsListing.dbo.Listing.StatusTypeID
--    - Application layer must maintain consistency:
--      * 'active' = StatusTypeID 6 (Private Listing)
--      * 'coming_soon' = StatusTypeID 14 (Coming Soon)
--
-- 3. Audit Trail:
--    - pls_status_log provides complete audit trail
--    - Never delete records from pls_status_log (preserve history)
--    - Use changed_by to track who made each change
--
-- 4. Performance:
--    - Indexes created for common query patterns
--    - Filtered indexes for active/published listings
--    - Consider partitioning pls_status_log by date if volume grows
--
-- 5. Future Enhancements:
--    - Add notes/comments column to pls_status_log for change reasons
--    - Add notification preferences to pls_collaborators
--    - Add soft-delete support (IsDeleted flag) if needed
--
-- ============================================================================

PRINT 'PLS Schema Extensions Created Successfully';
PRINT 'Tables: pls_tracking, pls_status_log, pls_collaborators';
PRINT 'All indexes and constraints applied';
GO

