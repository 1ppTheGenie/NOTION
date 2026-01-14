-- Create PLS Project and All Tasks in Task Manager
-- Version: 1.0
-- Created: 01/14/2026
-- Purpose: Populate Task Manager with PLS project and all 51 tasks

USE TaskManager;
GO

-- Get PM User ID (assuming pm@thegenie.ai exists)
DECLARE @UserId INT;
SELECT @UserId = Id FROM Users WHERE Email = 'pm@thegenie.ai';

IF @UserId IS NULL
BEGIN
    -- Create PM user if doesn't exist
    INSERT INTO Users (Email, DisplayName, PasswordHash, CreatedAt, UpdatedAt)
    VALUES ('pm@thegenie.ai', 'JR Project Manager', '$2a$11$DummyHashForTesting', GETUTCDATE(), GETUTCDATE());
    SET @UserId = SCOPE_IDENTITY();
END

-- Create PLS Project
DECLARE @ProjectId INT;
INSERT INTO Projects (Name, Description, Status, OwnerId, CreatedAt, UpdatedAt)
VALUES (
    'PLS Pre-Listing Command',
    'Paisley RESO Listing Engine - Private Listing Service for pre-MLS listings with full marketing asset generation',
    'Active',
    @UserId,
    GETUTCDATE(),
    GETUTCDATE()
);
SET @ProjectId = SCOPE_IDENTITY();

PRINT 'Project Created: PLS Pre-Listing Command (ID: ' + CAST(@ProjectId AS VARCHAR) + ')';

-- Get Status IDs (assuming standard statuses: 1=Backlog, 2=To Do, 3=In Progress, 4=In Review, 5=Done)
DECLARE @StatusBacklog INT = 1;
DECLARE @StatusToDo INT = 2;
DECLARE @StatusInProgress INT = 3;
DECLARE @StatusInReview INT = 4;
DECLARE @StatusDone INT = 5;

-- Phase 1: Database Foundation (8 tasks) - Status: Backlog (1)
INSERT INTO Tasks (Title, Description, ProjectId, StatusId, Priority, CreatedById, CreatedAt, UpdatedAt, DisplayOrder)
VALUES
    ('DB-001: Execute PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql', 'Create all PLS tables', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 1),
    ('DB-002: Execute PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql', 'PLS number generation', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 2),
    ('DB-003: Execute PLS_DATABASE_MASTER_DATA_v3.sql', 'Master data inserts', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 3),
    ('DB-004: Execute PLS_STORED_PROCEDURES_COMPLETE_v1.sql', 'All stored procedures', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 4),
    ('DB-005: Verify all tables, indexes, constraints created', 'Verification', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 5),
    ('DB-006: Test PLS number generation (usp_GetNextPlsNumber)', 'Test format: PLS100000A', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 6),
    ('DB-007: Verify master data inserted correctly', 'Data verification', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 7),
    ('DB-008: Update status file and announce Phase 1 complete', 'Handoff to Phase 2', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 8);

-- Phase 2: Backend API (16 tasks) - Status: Backlog (1)
INSERT INTO Tasks (Title, Description, ProjectId, StatusId, Priority, CreatedById, CreatedAt, UpdatedAt, DisplayOrder)
VALUES
    ('API-001: Implement PlsController.cs with all endpoints', 'Core CRUD endpoints', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 9),
    ('API-002: Implement DataController.PLS.cs partial class', 'Data controller', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 10),
    ('API-003: Create business logic service layer (PlsService)', 'Service layer', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 11),
    ('API-004: Implement POST /api/pls/create endpoint', 'Create listing', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 12),
    ('API-005: Implement PUT /api/pls/{listingNumber} endpoint', 'Update listing', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 13),
    ('API-006: Implement GET /api/pls/{listingNumber} endpoint', 'Get listing', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 14),
    ('API-007: Implement GET /api/pls/my-listings endpoint', 'List user''s listings', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 15),
    ('API-008: Implement POST /api/pls/pre-populate endpoint', 'Title Genie integration', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 16),
    ('API-009: Implement POST /api/pls/generate-description endpoint', 'Paisley integration (ChatStartTypeId=3)', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 17),
    ('API-010: Implement POST /api/pls/upload-photo endpoint', 'S3 photo upload', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 18),
    ('API-011: Implement POST /api/pls/{listingNumber}/render endpoint', 'Coordinate with XML Specialist', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 19),
    ('API-012: Implement PUT /api/pls/archive/{listingNumber} endpoint', 'Archive listing', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 20),
    ('API-013: Implement data validation and error handling', 'Validation layer', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 21),
    ('API-014: Create API documentation', 'For Frontend Specialist', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 22),
    ('API-015: Write unit tests for critical endpoints', 'Testing', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 23),
    ('API-016: Update status file and announce Phase 2 complete', 'Handoff to Phase 3', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 24);

-- Phase 3: Frontend UI (12 tasks) - Status: Backlog (1)
INSERT INTO Tasks (Title, Description, ProjectId, StatusId, Priority, CreatedById, CreatedAt, UpdatedAt, DisplayOrder)
VALUES
    ('UI-001: Implement PlsMyListingsComponent', 'List all user''s PLS listings', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 25),
    ('UI-002: Implement PlsCreateComponent', 'Create new PLS listing form', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 26),
    ('UI-003: Implement PlsEditComponent', 'Edit existing listing', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 27),
    ('UI-004: Implement PlsPhotoUploadComponent', 'Photo upload interface', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 28),
    ('UI-005: Implement PlsAreaSelectorComponent', 'Area selection for Paisley', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 29),
    ('UI-006: Implement PlsAIDescriptionComponent', 'AI description generation UI', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 30),
    ('UI-007: Implement Mapbox address autocomplete', 'Address lookup', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 31),
    ('UI-008: Implement mobile-first responsive design', 'Mobile optimization', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 32),
    ('UI-009: Implement form validation (client-side)', 'Validation', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 33),
    ('UI-010: Implement error handling and user feedback', 'Error handling', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 34),
    ('UI-011: Integrate with Backend API endpoints', 'API integration', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 35),
    ('UI-012: Update status file and announce Phase 3 complete', 'Handoff to Phase 5', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 36);

-- Phase 4: XML/Integration (8 tasks) - Status: Backlog (1)
INSERT INTO Tasks (Title, Description, ProjectId, StatusId, Priority, CreatedById, CreatedAt, UpdatedAt, DisplayOrder)
VALUES
    ('XML-001: Implement XML generation from PLS listing data', 'Follow contract v6.1 exactly', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 37),
    ('XML-002: Map PLS data to GenieCloud XML structure', 'Contract mapping', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 38),
    ('XML-003: Integrate with Backend API /render endpoint', 'Coordinate with Backend', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 39),
    ('XML-004: Implement GenieCloud API integration', 'Call GenieCloud API', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 40),
    ('XML-005: Handle GenieCloud responses and errors', 'Error handling', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 41),
    ('XML-006: Test XML schema validation', 'Validation', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 42),
    ('XML-007: Verify marketing assets generated correctly', 'Asset verification', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 43),
    ('XML-008: Update status file and announce Phase 4 complete', 'Handoff to Phase 5', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 44);

-- Phase 5: Testing & Deployment (7 tasks) - Status: In Progress (3) for first 2, Backlog (1) for rest
INSERT INTO Tasks (Title, Description, ProjectId, StatusId, Priority, CreatedById, CreatedAt, UpdatedAt, DisplayOrder)
VALUES
    ('DEPLOY-001: Create deployment scripts (PowerShell/Python)', 'Supporting all phases', @ProjectId, @StatusInProgress, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 45),
    ('DEPLOY-002: Set up Sandbox test environment', 'Test environment', @ProjectId, @StatusInProgress, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 46),
    ('DEPLOY-003: Create backup and rollback procedures', 'Include DLL.config', @ProjectId, @StatusBacklog, 2, @UserId, GETUTCDATE(), GETUTCDATE(), 47),
    ('DEPLOY-004: Integration testing (all phases)', 'End-to-end testing', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 48),
    ('DEPLOY-005: End-to-end testing', 'Full workflow test', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 49),
    ('DEPLOY-006: Production deployment', 'Final deployment', @ProjectId, @StatusBacklog, 4, @UserId, GETUTCDATE(), GETUTCDATE(), 50),
    ('DEPLOY-007: Post-deployment validation', 'Verify production', @ProjectId, @StatusBacklog, 3, @UserId, GETUTCDATE(), GETUTCDATE(), 51);

PRINT 'Tasks Created: 51 tasks';
PRINT 'Project ID: ' + CAST(@ProjectId AS VARCHAR);
PRINT '';
PRINT 'Access Task Manager: http://localhost:5173';
PRINT 'Login: pm@thegenie.ai';
GO
