-- PLS Deployment Verification Script
-- Version: 1.0
-- Created: 01/14/2026 4:55 AM
-- Purpose: Verify all PLS database objects are created correctly

USE FarmGenie;
GO

PRINT '========================================';
PRINT 'PLS DEPLOYMENT VERIFICATION';
PRINT '========================================';
PRINT '';

-- Verify Tables
PRINT '1. VERIFYING TABLES...';
PRINT '';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PlsListingOwnership')
    PRINT '  ✓ PlsListingOwnership table exists';
ELSE
    PRINT '  ✗ PlsListingOwnership table MISSING';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PlsNumberSequence')
    PRINT '  ✓ PlsNumberSequence table exists';
ELSE
    PRINT '  ✗ PlsNumberSequence table MISSING';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'pls_tracking')
    PRINT '  ✓ pls_tracking table exists';
ELSE
    PRINT '  ✗ pls_tracking table MISSING';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'pls_status_log')
    PRINT '  ✓ pls_status_log table exists';
ELSE
    PRINT '  ✗ pls_status_log table MISSING';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'pls_status_type')
    PRINT '  ✓ pls_status_type table exists';
ELSE
    PRINT '  ✗ pls_status_type table MISSING';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'pls_source_type')
    PRINT '  ✓ pls_source_type table exists';
ELSE
    PRINT '  ✗ pls_source_type table MISSING';

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'pls_status_mapping')
    PRINT '  ✓ pls_status_mapping table exists';
ELSE
    PRINT '  ✗ pls_status_mapping table MISSING';

PRINT '';

-- Verify Stored Procedures
PRINT '2. VERIFYING STORED PROCEDURES...';
PRINT '';

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GetNextPlsNumber')
    PRINT '  ✓ usp_GetNextPlsNumber procedure exists';
ELSE
    PRINT '  ✗ usp_GetNextPlsNumber procedure MISSING';

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GetPlsListingByNumber')
    PRINT '  ✓ usp_GetPlsListingByNumber procedure exists';
ELSE
    PRINT '  ✗ usp_GetPlsListingByNumber procedure MISSING';

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GetPlsListingsByUser')
    PRINT '  ✓ usp_GetPlsListingsByUser procedure exists';
ELSE
    PRINT '  ✗ usp_GetPlsListingsByUser procedure MISSING';

PRINT '';

-- Test PLS Number Generation
PRINT '3. TESTING PLS NUMBER GENERATION...';
PRINT '';

BEGIN TRY
    DECLARE @PlsNumber VARCHAR(20);
    EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNumber OUTPUT;
    PRINT '  ✓ PLS Number Generated: ' + @PlsNumber;
    
    -- Verify format: PLS{6-digit}{letter}
    IF @PlsNumber LIKE 'PLS[0-9][0-9][0-9][0-9][0-9][0-9][A-Z]'
        PRINT '  ✓ PLS Number format is correct';
    ELSE
        PRINT '  ✗ PLS Number format is INCORRECT: ' + @PlsNumber;
END TRY
BEGIN CATCH
    PRINT '  ✗ PLS Number generation FAILED: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- Verify Master Data
PRINT '4. VERIFYING MASTER DATA...';
PRINT '';

DECLARE @StatusTypeCount INT;
SELECT @StatusTypeCount = COUNT(*) FROM pls_status_type;
IF @StatusTypeCount > 0
    PRINT '  ✓ pls_status_type has ' + CAST(@StatusTypeCount AS VARCHAR) + ' records';
ELSE
    PRINT '  ✗ pls_status_type is EMPTY';

DECLARE @SourceTypeCount INT;
SELECT @SourceTypeCount = COUNT(*) FROM pls_source_type;
IF @SourceTypeCount > 0
    PRINT '  ✓ pls_source_type has ' + CAST(@SourceTypeCount AS VARCHAR) + ' records';
ELSE
    PRINT '  ✗ pls_source_type is EMPTY';

DECLARE @StatusMappingCount INT;
SELECT @StatusMappingCount = COUNT(*) FROM pls_status_mapping;
IF @StatusMappingCount > 0
    PRINT '  ✓ pls_status_mapping has ' + CAST(@StatusMappingCount AS VARCHAR) + ' records';
ELSE
    PRINT '  ✗ pls_status_mapping is EMPTY';

PRINT '';

-- Verify MlsListing StatusTypeID
USE MlsListing;
GO

PRINT '5. VERIFYING MLS LISTING STATUS TYPES...';
PRINT '';

IF EXISTS (SELECT 1 FROM StatusType WHERE StatusTypeID = 6)
    PRINT '  ✓ StatusTypeID 6 (Private Listing) exists';
ELSE
    PRINT '  ✗ StatusTypeID 6 (Private Listing) MISSING - NEEDS INSERT';

IF EXISTS (SELECT 1 FROM StatusType WHERE StatusTypeID = 14)
    PRINT '  ✓ StatusTypeID 14 (Coming Soon) exists';
ELSE
    PRINT '  ✗ StatusTypeID 14 (Coming Soon) MISSING';

PRINT '';

-- Summary
PRINT '========================================';
PRINT 'VERIFICATION COMPLETE';
PRINT '========================================';
PRINT '';
PRINT 'If all checks passed (✓), database is ready.';
PRINT 'If any checks failed (✗), review deployment scripts.';
PRINT '';
