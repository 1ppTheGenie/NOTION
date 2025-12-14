/*
================================================================================
STORED PROCEDURE: usp_MigrateVersiumCache_DataTreeToAttom
PURPOSE: Migrate Versium cache lookup keys from DataTree PropertyIDs to Attom IDs
VERSION: 1.0
DATE: 12/14/2025
AUTHOR: TheGenie AI
================================================================================

DESCRIPTION:
    This procedure updates the LookupKeyReadable column in DataAppendContactLookup
    to replace old DataTree PropertyIDs with new Attom PropertyIDs, preserving
    the cache to avoid re-paying for Versium lookups.

DEPENDENCIES:
    - FarmGenie.dbo.CachePropertyIdMapping (must exist with NewAttomId populated)
    - FarmGenie.dbo.DataAppendContactLookup

PARAMETERS:
    @PreviewMode BIT = 1       -- 1 = Show what would change (default), 0 = Execute
    @BatchSize INT = 10000     -- Records per batch (for performance)
    @MaxBatches INT = NULL     -- Limit batches (NULL = process all)

USAGE:
    -- Preview mode (see what would change)
    EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 1;
    
    -- Execute mode (make changes)
    EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 0;
    
    -- Execute with smaller batches
    EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 0, @BatchSize = 5000;

ROLLBACK:
    If backup exists, restore with:
    UPDATE l SET l.LookupKeyReadable = b.LookupKeyReadable
    FROM DataAppendContactLookup l
    JOIN DataAppendContactLookup_Backup_PreAttomMigration b
    ON l.DataAppendContactLookupId = b.DataAppendContactLookupId;

================================================================================
*/

USE FarmGenie;
GO

CREATE OR ALTER PROCEDURE dbo.usp_MigrateVersiumCache_DataTreeToAttom
    @PreviewMode BIT = 1,
    @BatchSize INT = 10000,
    @MaxBatches INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalCacheRecords INT;
    DECLARE @RecordsMappable INT;
    DECLARE @RecordsUpdated INT = 0;
    DECLARE @BatchCount INT = 0;
    DECLARE @StartTime DATETIME2 = GETUTCDATE();

    -- ==========================================================================
    -- STEP 1: Gather statistics
    -- ==========================================================================
    
    SELECT @TotalCacheRecords = COUNT(*) 
    FROM dbo.DataAppendContactLookup 
    WHERE LookupKeyReadable LIKE '::PID-%';

    -- Count how many can be mapped
    SELECT @RecordsMappable = COUNT(DISTINCT dacl.DataAppendContactLookupId)
    FROM dbo.DataAppendContactLookup dacl
    CROSS APPLY (
        SELECT 
            CAST(SUBSTRING(dacl.LookupKeyReadable, 7, 
                CHARINDEX('::', dacl.LookupKeyReadable, 7) - 7) AS BIGINT) AS PropertyId
    ) parsed
    JOIN dbo.CachePropertyIdMapping cpm ON parsed.PropertyId = cpm.OldPropertyId
    WHERE cpm.NewAttomId IS NOT NULL
      AND dacl.LookupKeyReadable LIKE '::PID-%';

    PRINT '================================================================================';
    PRINT 'VERSIUM CACHE MIGRATION: DataTree → Attom PropertyID';
    PRINT '================================================================================';
    PRINT '';
    PRINT 'Statistics:';
    PRINT '  Total cache records:       ' + FORMAT(@TotalCacheRecords, 'N0');
    PRINT '  Records that can be mapped: ' + FORMAT(@RecordsMappable, 'N0');
    PRINT '  Migration rate:            ' + CAST(CAST(@RecordsMappable AS FLOAT) / NULLIF(@TotalCacheRecords, 0) * 100 AS VARCHAR(10)) + '%';
    PRINT '';

    -- ==========================================================================
    -- STEP 2: Preview or Execute
    -- ==========================================================================

    IF @PreviewMode = 1
    BEGIN
        PRINT '>>> PREVIEW MODE <<<';
        PRINT 'No changes will be made.';
        PRINT '';
        PRINT 'Sample of 10 records that would be updated:';
        PRINT '';

        SELECT TOP 10
            dacl.DataAppendContactLookupId,
            dacl.LookupKeyReadable AS OldKey,
            REPLACE(dacl.LookupKeyReadable, 
                '::PID-' + CAST(parsed.PropertyId AS VARCHAR(20)) + '::',
                '::PID-' + CAST(cpm.NewAttomId AS VARCHAR(20)) + '::') AS NewKey,
            parsed.PropertyId AS OldPropertyId,
            cpm.NewAttomId AS NewAttomId,
            dacl.CreateDate
        FROM dbo.DataAppendContactLookup dacl
        CROSS APPLY (
            SELECT 
                CAST(SUBSTRING(dacl.LookupKeyReadable, 7, 
                    CHARINDEX('::', dacl.LookupKeyReadable, 7) - 7) AS BIGINT) AS PropertyId
        ) parsed
        JOIN dbo.CachePropertyIdMapping cpm ON parsed.PropertyId = cpm.OldPropertyId
        WHERE cpm.NewAttomId IS NOT NULL
          AND dacl.LookupKeyReadable LIKE '::PID-%'
        ORDER BY dacl.CreateDate DESC;

        PRINT '';
        PRINT 'To execute migration, run:';
        PRINT 'EXEC dbo.usp_MigrateVersiumCache_DataTreeToAttom @PreviewMode = 0;';
        PRINT '';
        PRINT '================================================================================';
        
        RETURN;
    END

    -- ==========================================================================
    -- STEP 3: Execute Migration
    -- ==========================================================================

    PRINT '>>> EXECUTE MODE <<<';
    PRINT 'Creating backup table...';

    -- Create backup table
    IF OBJECT_ID('dbo.DataAppendContactLookup_Backup_PreAttomMigration', 'U') IS NULL
    BEGIN
        SELECT DataAppendContactLookupId, LookupKeyReadable, CreateDate
        INTO dbo.DataAppendContactLookup_Backup_PreAttomMigration
        FROM dbo.DataAppendContactLookup
        WHERE LookupKeyReadable LIKE '::PID-%';

        PRINT 'Backup created: DataAppendContactLookup_Backup_PreAttomMigration';
        PRINT 'Backup records: ' + FORMAT(@@ROWCOUNT, 'N0');
    END
    ELSE
    BEGIN
        PRINT 'Backup table already exists. Skipping backup creation.';
    END

    PRINT '';
    PRINT 'Starting migration in batches of ' + CAST(@BatchSize AS VARCHAR(10)) + '...';
    PRINT '';

    -- Create temp table to track IDs to update
    IF OBJECT_ID('tempdb..#RecordsToUpdate', 'U') IS NOT NULL DROP TABLE #RecordsToUpdate;
    
    SELECT 
        dacl.DataAppendContactLookupId,
        dacl.LookupKeyReadable AS OldKey,
        REPLACE(dacl.LookupKeyReadable, 
            '::PID-' + CAST(parsed.PropertyId AS VARCHAR(20)) + '::',
            '::PID-' + CAST(cpm.NewAttomId AS VARCHAR(20)) + '::') AS NewKey
    INTO #RecordsToUpdate
    FROM dbo.DataAppendContactLookup dacl
    CROSS APPLY (
        SELECT 
            CAST(SUBSTRING(dacl.LookupKeyReadable, 7, 
                CHARINDEX('::', dacl.LookupKeyReadable, 7) - 7) AS BIGINT) AS PropertyId
    ) parsed
    JOIN dbo.CachePropertyIdMapping cpm ON parsed.PropertyId = cpm.OldPropertyId
    WHERE cpm.NewAttomId IS NOT NULL
      AND dacl.LookupKeyReadable LIKE '::PID-%';

    CREATE CLUSTERED INDEX IX_RecordsToUpdate ON #RecordsToUpdate(DataAppendContactLookupId);

    DECLARE @TotalToUpdate INT = (SELECT COUNT(*) FROM #RecordsToUpdate);
    PRINT 'Total records to update: ' + FORMAT(@TotalToUpdate, 'N0');

    -- Process in batches
    WHILE EXISTS (SELECT 1 FROM #RecordsToUpdate)
    BEGIN
        SET @BatchCount = @BatchCount + 1;

        -- Check max batches limit
        IF @MaxBatches IS NOT NULL AND @BatchCount > @MaxBatches
        BEGIN
            PRINT '';
            PRINT 'Reached max batches limit (' + CAST(@MaxBatches AS VARCHAR(10)) + '). Stopping.';
            BREAK;
        END

        -- Update a batch
        ;WITH BatchCTE AS (
            SELECT TOP (@BatchSize) 
                DataAppendContactLookupId, 
                NewKey
            FROM #RecordsToUpdate
        )
        UPDATE dacl
        SET dacl.LookupKeyReadable = b.NewKey
        FROM dbo.DataAppendContactLookup dacl
        JOIN BatchCTE b ON dacl.DataAppendContactLookupId = b.DataAppendContactLookupId;

        SET @RecordsUpdated = @RecordsUpdated + @@ROWCOUNT;

        -- Remove processed records from temp table
        ;WITH BatchCTE AS (
            SELECT TOP (@BatchSize) DataAppendContactLookupId FROM #RecordsToUpdate
        )
        DELETE FROM BatchCTE;

        -- Progress update every 10 batches
        IF @BatchCount % 10 = 0
        BEGIN
            PRINT 'Batch ' + CAST(@BatchCount AS VARCHAR(10)) + 
                  ' | Updated: ' + FORMAT(@RecordsUpdated, 'N0') + 
                  ' | Remaining: ' + FORMAT((SELECT COUNT(*) FROM #RecordsToUpdate), 'N0');
        END
    END

    -- ==========================================================================
    -- STEP 4: Summary
    -- ==========================================================================

    DECLARE @EndTime DATETIME2 = GETUTCDATE();
    DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);

    PRINT '';
    PRINT '================================================================================';
    PRINT 'MIGRATION COMPLETE';
    PRINT '================================================================================';
    PRINT '';
    PRINT 'Summary:';
    PRINT '  Total records updated:  ' + FORMAT(@RecordsUpdated, 'N0');
    PRINT '  Batches processed:      ' + CAST(@BatchCount AS VARCHAR(10));
    PRINT '  Duration:               ' + CAST(@Duration AS VARCHAR(10)) + ' seconds';
    PRINT '  Backup table:           DataAppendContactLookup_Backup_PreAttomMigration';
    PRINT '';
    PRINT 'To verify, run:';
    PRINT 'SELECT TOP 10 LookupKeyReadable FROM DataAppendContactLookup ORDER BY CreateDate DESC;';
    PRINT '';
    PRINT 'To rollback, run:';
    PRINT 'UPDATE l SET l.LookupKeyReadable = b.LookupKeyReadable';
    PRINT 'FROM DataAppendContactLookup l';
    PRINT 'JOIN DataAppendContactLookup_Backup_PreAttomMigration b';
    PRINT 'ON l.DataAppendContactLookupId = b.DataAppendContactLookupId;';
    PRINT '';
    PRINT '================================================================================';

    -- Cleanup
    DROP TABLE #RecordsToUpdate;

END;
GO

-- Grant execute permission
-- GRANT EXECUTE ON dbo.usp_MigrateVersiumCache_DataTreeToAttom TO [YourRole];
