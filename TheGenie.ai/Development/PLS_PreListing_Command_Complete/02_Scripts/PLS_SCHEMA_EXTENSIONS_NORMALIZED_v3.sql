-- ============================================================================
-- PLS RESO Engine - Schema Extensions (NORMALIZED)
-- Version: 3.0
-- Created: 01/05/2026
-- Last Updated: 01/05/2026
-- Author: Cursor AI Agent
-- Purpose: Fully normalized PLS schema with lookup tables and proper FKs
--          Removed collaborator concept - agents stored in RESO listing table
-- ============================================================================
--
-- NORMALIZATION IMPROVEMENTS:
-- 1. Status values → pls_status_type lookup table
-- 2. Source values → pls_source_type lookup table
-- 3. Status mapping → pls_status_mapping table (explicit mapping to StatusTypeID)
-- 4. All string enums replaced with INT foreign keys
-- 5. Proper referential integrity throughout
--
-- AGENT MODEL CLARIFICATION:
-- - Listing Agent + Co-Listing Agent = Stored in MlsListing.dbo.Listing (RESO fields)
--   * Both must be verified MLS members (validated by RESO feed)
--   * Stored in standard RESO fields: ListingAgentName, ListingAgentID, CoListingAgentName, CoListingAgentID
-- - Title Reps = Access via Permission table (Title Partner permissions)
--   * NOT tracked as listing-specific collaborators
--   * Access controlled via FarmGenie.dbo.Permission table
--   * Title reps have access to agent's account, not individual listings
--
-- Database: FarmGenie (for PLS tracking tables)
--           MlsListing (for listing data - existing table, no changes)
--
-- Dependencies:
--   - MlsListing.dbo.Listing (existing table)
--   - MlsListing.dbo.StatusType (existing table)
--   - FarmGenie.dbo.AspNetUsers (existing table)
--   - FarmGenie.dbo.Permission (existing table - for Title Partner access)
-- ============================================================================

USE FarmGenie;
GO

-- ============================================================================
-- LOOKUP TABLES (Normalized Reference Data)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TABLE: pls_status_type
-- Purpose: Lookup table for PLS lifecycle status values
-- Normalization: Replaces hardcoded NVARCHAR status strings
-- ----------------------------------------------------------------------------

IF OBJECT_ID('dbo.pls_status_type', 'U') IS NOT NULL
    DROP TABLE dbo.pls_status_type;
GO

CREATE TABLE dbo.pls_status_type (
    status_type_id TINYINT IDENTITY(1,1) NOT NULL,
    status_code NVARCHAR(50) NOT NULL,
        -- Unique code: 'incomplete', 'draft', 'active', etc.
    status_name NVARCHAR(100) NOT NULL,
        -- Display name: 'Incomplete', 'Draft', 'Active', etc.
    description NVARCHAR(500) NULL,
        -- Detailed description of status
    display_order TINYINT NOT NULL,
        -- Order for UI dropdowns
    is_active BIT NOT NULL DEFAULT 1,
        -- Can disable status without deleting
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_status_type PRIMARY KEY CLUSTERED (status_type_id),
    CONSTRAINT UQ_pls_status_type_code UNIQUE (status_code),
    CONSTRAINT CK_pls_status_type_display_order CHECK (display_order > 0)
);
GO

-- Insert master data for status types
INSERT INTO dbo.pls_status_type (status_code, status_name, description, display_order)
VALUES
    ('incomplete', 'Incomplete', 'Listing not yet saved', 1),
    ('draft', 'Draft', 'Saved but not published', 2),
    ('active', 'Active', 'Private Listing (published)', 3),
    ('coming_soon', 'Coming Soon', 'Coming Soon (published)', 4),
    ('lost_opportunity', 'Lost Opportunity', 'Listing opportunity was lost', 5),
    ('published_to_mls', 'Published to MLS', 'Successfully published to actual MLS', 6);
GO

-- Index for status code lookups
CREATE NONCLUSTERED INDEX IX_pls_status_type_code 
    ON dbo.pls_status_type (status_code)
    INCLUDE (status_name, display_order)
    WHERE is_active = 1;
GO

-- ----------------------------------------------------------------------------
-- TABLE: pls_source_type
-- Purpose: Lookup table for PLS creation source values
-- Normalization: Replaces hardcoded NVARCHAR source strings
-- ----------------------------------------------------------------------------

IF OBJECT_ID('dbo.pls_source_type', 'U') IS NOT NULL
    DROP TABLE dbo.pls_source_type;
GO

CREATE TABLE dbo.pls_source_type (
    source_type_id TINYINT IDENTITY(1,1) NOT NULL,
    source_code NVARCHAR(50) NOT NULL,
        -- Unique code: 'paisley', 'manual', 'import', etc.
    source_name NVARCHAR(100) NOT NULL,
        -- Display name: 'Paisley', 'Manual Entry', 'Import', etc.
    description NVARCHAR(500) NULL,
    display_order TINYINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_source_type PRIMARY KEY CLUSTERED (source_type_id),
    CONSTRAINT UQ_pls_source_type_code UNIQUE (source_code),
    CONSTRAINT CK_pls_source_type_display_order CHECK (display_order > 0)
);
GO

-- Insert master data for source types
INSERT INTO dbo.pls_source_type (source_code, source_name, description, display_order)
VALUES
    ('paisley', 'Paisley', 'Created via Paisley AI interface', 1),
    ('manual', 'Manual Entry', 'Manually created by agent', 2),
    ('import', 'Import', 'Imported from external source', 3),
    ('api', 'API', 'Created via API integration', 4);
GO

-- Index for source code lookups
CREATE NONCLUSTERED INDEX IX_pls_source_type_code 
    ON dbo.pls_source_type (source_code)
    INCLUDE (source_name, display_order)
    WHERE is_active = 1;
GO

-- ----------------------------------------------------------------------------
-- TABLE: pls_status_mapping
-- Purpose: Explicit mapping between PLS status and MlsListing StatusTypeID
-- Normalization: Makes implicit mapping explicit and queryable
-- ----------------------------------------------------------------------------

IF OBJECT_ID('dbo.pls_status_mapping', 'U') IS NOT NULL
    DROP TABLE dbo.pls_status_mapping;
GO

CREATE TABLE dbo.pls_status_mapping (
    mapping_id INT IDENTITY(1,1) NOT NULL,
    pls_status_type_id TINYINT NOT NULL,
        -- References: pls_status_type(status_type_id)
    mls_status_type_id INT NULL,
        -- References: MlsListing.dbo.StatusType(StatusTypeID)
        -- NULL = no corresponding MLS status (e.g., 'incomplete', 'draft')
    is_published BIT NOT NULL DEFAULT 0,
        -- TRUE = status represents a published listing
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_status_mapping PRIMARY KEY CLUSTERED (mapping_id),
    CONSTRAINT FK_pls_status_mapping_status FOREIGN KEY (pls_status_type_id)
        REFERENCES dbo.pls_status_type(status_type_id) ON DELETE CASCADE,
    CONSTRAINT UQ_pls_status_mapping_status UNIQUE (pls_status_type_id),
        -- One mapping per PLS status
    CONSTRAINT CK_pls_status_mapping_mls_status CHECK (
        (mls_status_type_id IS NULL AND is_published = 0) OR
        (mls_status_type_id IS NOT NULL)
    )
);
GO

-- Insert status mappings
-- Note: mls_status_type_id validated in application layer (cross-database)
INSERT INTO dbo.pls_status_mapping (pls_status_type_id, mls_status_type_id, is_published)
SELECT 
    st.status_type_id,
    CASE st.status_code
        WHEN 'active' THEN 6      -- Private Listing
        WHEN 'coming_soon' THEN 14 -- Coming Soon
        WHEN 'published_to_mls' THEN NULL -- Dynamic based on target MLS
        ELSE NULL                 -- incomplete, draft, lost_opportunity
    END AS mls_status_type_id,
    CASE st.status_code
        WHEN 'active' THEN 1
        WHEN 'coming_soon' THEN 1
        WHEN 'published_to_mls' THEN 1
        ELSE 0
    END AS is_published
FROM dbo.pls_status_type st;
GO

-- Index for status mapping lookups
CREATE NONCLUSTERED INDEX IX_pls_status_mapping_status 
    ON dbo.pls_status_mapping (pls_status_type_id)
    INCLUDE (mls_status_type_id, is_published)
    WHERE is_active = 1;
GO

CREATE NONCLUSTERED INDEX IX_pls_status_mapping_mls_status 
    ON dbo.pls_status_mapping (mls_status_type_id)
    INCLUDE (pls_status_type_id, is_published)
    WHERE mls_status_type_id IS NOT NULL AND is_active = 1;
GO

-- ============================================================================
-- MAIN TABLES (Normalized with Foreign Keys)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TABLE: pls_tracking (NORMALIZED)
-- Purpose: Tracks PLS-specific metadata for each listing
-- Changes: status and source now use FK to lookup tables
-- ----------------------------------------------------------------------------

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
    agent_id NVARCHAR(128) NOT NULL,
        -- References: FarmGenie.dbo.AspNetUsers(Id)
        -- NOTE: Matches actual database structure (NVARCHAR(128), not 450)
        -- Primary listing agent (owner of PLS listing)
        -- NOTE: Co-Listing Agent stored in MlsListing.dbo.Listing (RESO fields)
        --       NOT tracked here - use CoListingAgentName/CoListingAgentID in Listing table
    
    -- Normalized Foreign Keys (replaces NVARCHAR strings)
    source_type_id TINYINT NOT NULL,
        -- References: pls_source_type(source_type_id)
        -- DEFAULT: 1 (paisley)
    status_type_id TINYINT NOT NULL,
        -- References: pls_status_type(status_type_id)
        -- DEFAULT: 1 (incomplete)
    
    -- Business Logic Flags
    was_listed BIT NOT NULL DEFAULT 0,
        -- Whether the agent ultimately got the listing
    mls_published BIT NOT NULL DEFAULT 0,
        -- Whether this PLS listing was published to actual MLS
    
    -- Audit Timestamps
    created_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    -- Constraints
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

-- Set default values using lookup table IDs
-- Note: Using ID 1 for 'paisley' and 'incomplete' (first inserts)
ALTER TABLE dbo.pls_tracking
ADD CONSTRAINT DF_pls_tracking_source_type DEFAULT 1 FOR source_type_id;
GO

ALTER TABLE dbo.pls_tracking
ADD CONSTRAINT DF_pls_tracking_status_type DEFAULT 1 FOR status_type_id;
GO

-- Indexes for pls_tracking (updated to use status_type_id)
CREATE NONCLUSTERED INDEX IX_pls_tracking_listing_id 
    ON dbo.pls_tracking (listing_id)
    INCLUDE (agent_id, status_type_id, mls_published, updated_at);
GO

CREATE NONCLUSTERED INDEX IX_pls_tracking_agent_id 
    ON dbo.pls_tracking (agent_id, status_type_id)
    INCLUDE (listing_id, created_at, was_listed);
GO

-- Filtered index using status_type_id (requires JOIN to get status_code)
CREATE NONCLUSTERED INDEX IX_pls_tracking_status_type 
    ON dbo.pls_tracking (status_type_id, updated_at)
    INCLUDE (listing_id, agent_id, mls_published);
GO

-- ============================================================================
-- TABLE: pls_status_log (NORMALIZED)
-- Purpose: Tracks every status transition for a PLS listing (audit trail)
-- Changes: from_status and to_status now use FK to lookup table
-- ----------------------------------------------------------------------------

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
    changed_by NVARCHAR(128) NOT NULL,
        -- References: FarmGenie.dbo.AspNetUsers(Id)
        -- NOTE: Matches actual database structure (NVARCHAR(128), not 450)
        -- User who made the status change (agent, title rep with permissions, admin)
    
    -- Normalized Foreign Keys (replaces NVARCHAR strings)
    from_status_type_id TINYINT NULL,
        -- References: pls_status_type(status_type_id)
        -- NULL = initial creation (no previous status)
    to_status_type_id TINYINT NOT NULL,
        -- References: pls_status_type(status_type_id)
    
    -- Audit Timestamp
    changed_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    -- Constraints
    CONSTRAINT PK_pls_status_log PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pls_status_log_user FOREIGN KEY (changed_by) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE NO ACTION,
        -- NO ACTION: Preserve audit trail even if user is deleted
    CONSTRAINT FK_pls_status_log_from_status FOREIGN KEY (from_status_type_id)
        REFERENCES dbo.pls_status_type(status_type_id) ON DELETE NO ACTION,
    CONSTRAINT FK_pls_status_log_to_status FOREIGN KEY (to_status_type_id)
        REFERENCES dbo.pls_status_type(status_type_id) ON DELETE NO ACTION
);
GO

-- Indexes for pls_status_log (updated to use status_type_id)
CREATE NONCLUSTERED INDEX IX_pls_status_log_listing_id 
    ON dbo.pls_status_log (listing_id, changed_at DESC)
    INCLUDE (from_status_type_id, to_status_type_id, changed_by);
GO

CREATE NONCLUSTERED INDEX IX_pls_status_log_changed_by 
    ON dbo.pls_status_log (changed_by, changed_at DESC)
    INCLUDE (listing_id, to_status_type_id);
GO

CREATE NONCLUSTERED INDEX IX_pls_status_log_to_status 
    ON dbo.pls_status_log (to_status_type_id, changed_at DESC)
    INCLUDE (listing_id, changed_by);
GO

-- ============================================================================
-- HELPER VIEWS (For Backward Compatibility and Ease of Use)
-- ============================================================================

-- View: pls_tracking_with_codes
-- Purpose: Provides status_code and source_code for easier querying
IF OBJECT_ID('dbo.vw_pls_tracking_with_codes', 'V') IS NOT NULL
    DROP VIEW dbo.vw_pls_tracking_with_codes;
GO

CREATE VIEW dbo.vw_pls_tracking_with_codes
AS
SELECT 
    pt.id,
    pt.listing_id,
    pt.agent_id,
    pt.source_type_id,
    st.source_code,
    st.source_name AS source_display_name,
    pt.status_type_id,
    pst.status_code,
    pst.status_name AS status_display_name,
    pt.was_listed,
    pt.mls_published,
    pt.created_at,
    pt.updated_at
FROM dbo.pls_tracking pt
INNER JOIN dbo.pls_source_type st ON st.source_type_id = pt.source_type_id
INNER JOIN dbo.pls_status_type pst ON pst.status_type_id = pt.status_type_id;
GO

-- View: pls_status_log_with_codes
-- Purpose: Provides status codes for easier querying
IF OBJECT_ID('dbo.vw_pls_status_log_with_codes', 'V') IS NOT NULL
    DROP VIEW dbo.vw_pls_status_log_with_codes;
GO

CREATE VIEW dbo.vw_pls_status_log_with_codes
AS
SELECT 
    psl.id,
    psl.listing_id,
    psl.changed_by,
    psl.from_status_type_id,
    pst_from.status_code AS from_status_code,
    pst_from.status_name AS from_status_display_name,
    psl.to_status_type_id,
    pst_to.status_code AS to_status_code,
    pst_to.status_name AS to_status_display_name,
    psl.changed_at
FROM dbo.pls_status_log psl
LEFT JOIN dbo.pls_status_type pst_from ON pst_from.status_type_id = psl.from_status_type_id
INNER JOIN dbo.pls_status_type pst_to ON pst_to.status_type_id = psl.to_status_type_id;
GO

-- ============================================================================
-- USAGE EXAMPLES (Normalized Schema)
-- ============================================================================

/*
-- Example 1: Create PLS tracking record (using lookup IDs)
DECLARE @source_type_id TINYINT = (SELECT source_type_id FROM pls_source_type WHERE source_code = 'paisley');
DECLARE @status_type_id TINYINT = (SELECT status_type_id FROM pls_status_type WHERE status_code = 'draft');

INSERT INTO dbo.pls_tracking (listing_id, agent_id, source_type_id, status_type_id)
VALUES (12345, 'user-guid-here', @source_type_id, @status_type_id);
*/

/*
-- Example 2: Log status change (using lookup IDs)
DECLARE @from_status_id TINYINT = (SELECT status_type_id FROM pls_status_type WHERE status_code = 'draft');
DECLARE @to_status_id TINYINT = (SELECT status_type_id FROM pls_status_type WHERE status_code = 'active');

INSERT INTO dbo.pls_status_log (listing_id, changed_by, from_status_type_id, to_status_type_id)
VALUES (12345, 'user-guid-here', @from_status_id, @to_status_id);
*/

/*
-- Example 3: Query using view (backward compatible with code-based queries)
SELECT 
    l.ListingID,
    l.MlsNumber,
    l.DisplayAddress,
    l.ListingAgentName,
    l.ListingAgentID,
    l.CoListingAgentName,  -- Co-Listing Agent stored in RESO listing table
    l.CoListingAgentID,    -- Co-Listing Agent ID stored in RESO listing table
    vpt.status_code,
    vpt.status_display_name,
    vpt.was_listed,
    vpt.mls_published
FROM MlsListing.dbo.Listing l
INNER JOIN dbo.vw_pls_tracking_with_codes vpt ON vpt.listing_id = l.ListingID
WHERE vpt.agent_id = 'user-guid-here'
    AND l.MlsID = 777
    AND vpt.status_code IN ('active', 'coming_soon')
ORDER BY vpt.updated_at DESC;
*/

/*
-- Example 4: Get status mapping to MLS StatusTypeID
SELECT 
    pst.status_code,
    pst.status_name,
    psm.mls_status_type_id,
    st.Name AS mls_status_name
FROM dbo.pls_status_type pst
LEFT JOIN dbo.pls_status_mapping psm ON psm.pls_status_type_id = pst.status_type_id
LEFT JOIN MlsListing.dbo.StatusType st ON st.StatusTypeID = psm.mls_status_type_id
WHERE pst.is_active = 1
ORDER BY pst.display_order;
*/

/*
-- Example 5: Check Title Rep permissions (NOT listing-specific)
-- Title reps access via Permission table, not pls_collaborators
SELECT 
    p.UserId,
    p.PermissionTypeId,
    pt.Name AS PermissionTypeName
FROM FarmGenie.dbo.Permission p
INNER JOIN FarmGenie.dbo.PermissionType pt ON pt.PermissionTypeId = p.PermissionTypeId
WHERE p.UserId = 'title-rep-guid-here'
    AND pt.Name LIKE '%Title Partner%';
*/

-- ============================================================================
-- AGENT MODEL DOCUMENTATION
-- ============================================================================
--
-- LISTING AGENTS (Stored in MlsListing.dbo.Listing):
--   - ListingAgentName / ListingAgentID = Primary listing agent (owner)
--   - CoListingAgentName / CoListingAgentID = Co-listing agent (optional)
--   - Both must be verified MLS members (validated by RESO feed)
--   - Stored in standard RESO fields - no PLS-specific tracking needed
--
-- TITLE REPS (Access via Permission table):
--   - NOT tracked as listing-specific collaborators
--   - Access controlled via FarmGenie.dbo.Permission table
--   - Title Partner permissions grant access to agent's account
--   - Can perform certain tasks based on PermissionTypeId
--   - Access is account-level, not listing-level
--
-- ============================================================================
-- NORMALIZATION BENEFITS
-- ============================================================================
--
-- 1. Data Integrity:
--    - Foreign keys enforce referential integrity
--    - Cannot insert invalid status/source values
--    - Lookup tables can be updated without changing main tables
--
-- 2. Maintainability:
--    - Add new status/source values by inserting into lookup tables
--    - No schema changes needed for new enum values
--    - Centralized display names and descriptions
--
-- 3. Performance:
--    - INT foreign keys are smaller and faster than NVARCHAR(50)
--    - Better index performance with integer keys
--    - Reduced storage space
--
-- 4. Query Flexibility:
--    - JOIN to lookup tables for display names
--    - Views provide backward-compatible code-based queries
--    - Explicit status mapping table for MLS integration
--
-- 5. Audit Trail:
--    - Status changes reference lookup table (preserves history even if status renamed)
--    - Can track status type changes over time
--
-- ============================================================================

PRINT 'PLS Normalized Schema Extensions Created Successfully (v3.0)';
PRINT 'Lookup Tables: pls_status_type, pls_source_type, pls_status_mapping';
PRINT 'Main Tables: pls_tracking, pls_status_log';
PRINT 'Views: vw_pls_tracking_with_codes, vw_pls_status_log_with_codes';
PRINT '';
PRINT 'AGENT MODEL:';
PRINT '  - Listing Agents stored in MlsListing.dbo.Listing (RESO fields)';
PRINT '  - Title Reps access via Permission table (account-level, not listing-specific)';
PRINT '';
PRINT 'All indexes, constraints, and foreign keys applied';
GO

