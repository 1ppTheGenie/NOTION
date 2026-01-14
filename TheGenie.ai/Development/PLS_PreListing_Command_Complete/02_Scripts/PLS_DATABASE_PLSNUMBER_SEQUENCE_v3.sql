-- ============================================================================
-- PLS RESO Engine - PLS Number Sequence Table and Stored Procedure
-- Version: 3.0
-- Created: 01/05/2026
-- Last Updated: 01/05/2026
-- Author: Cursor AI Agent
-- Purpose: Thread-safe PLS number generation (format: PLS-YYYY-NNNNN)
-- ============================================================================
--
-- PLS Number Format: PLS-YYYY-NNNNN
--   Example: PLS-2026-00001, PLS-2026-00002, etc.
--   Resets each year (2026 starts at 00001, 2027 starts at 00001)
--
-- Thread-Safe: Uses transaction with atomic increment to prevent race conditions
--
-- ============================================================================

USE FarmGenie;
GO

-- ============================================================================
-- TABLE: PlsNumberSequence
-- Purpose: Manage PLS number generation (thread-safe)
-- ============================================================================

IF OBJECT_ID('dbo.PlsNumberSequence', 'U') IS NOT NULL
    DROP TABLE dbo.PlsNumberSequence;
GO

CREATE TABLE dbo.PlsNumberSequence (
    Year INT NOT NULL,
        -- Year for sequence (e.g., 2026, 2027)
    NextNumber INT NOT NULL DEFAULT 1,
        -- Next number to use for this year
    LastUpdate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        -- Last time this year's sequence was updated
    
    CONSTRAINT PK_PlsNumberSequence PRIMARY KEY CLUSTERED (Year)
);
GO

-- Index for year lookups (Year is already PK, but adding for clarity)
-- Note: Year is the PK, so no additional index needed

PRINT 'PlsNumberSequence table created successfully';
GO

-- ============================================================================
-- STORED PROCEDURE: usp_GetNextPlsNumber
-- Purpose: Generate next PLS number in format PLS-YYYY-NNNNN (thread-safe)
-- ============================================================================

IF OBJECT_ID('dbo.usp_GetNextPlsNumber', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetNextPlsNumber;
GO

CREATE PROCEDURE dbo.usp_GetNextPlsNumber
    @PlsNumber VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentYear INT = YEAR(GETUTCDATE());
    DECLARE @NextNumber INT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Try to get existing year record
        SELECT @NextNumber = NextNumber
        FROM dbo.PlsNumberSequence WITH (UPDLOCK, ROWLOCK)
        WHERE Year = @CurrentYear;
        
        IF @NextNumber IS NULL
        BEGIN
            -- Year doesn't exist, create it with NextNumber = 1
            INSERT INTO dbo.PlsNumberSequence (Year, NextNumber, LastUpdate)
            VALUES (@CurrentYear, 1, GETUTCDATE());
            
            SET @NextNumber = 1;
        END
        ELSE
        BEGIN
            -- Year exists, increment atomically
            UPDATE dbo.PlsNumberSequence
            SET NextNumber = NextNumber + 1,
                LastUpdate = GETUTCDATE()
            WHERE Year = @CurrentYear;
            
            SET @NextNumber = @NextNumber + 1;
        END
        
        -- Format: PLS-YYYY-NNNNN
        -- Example: PLS-2026-00001, PLS-2026-00002
        SET @PlsNumber = 'PLS-' + 
                         CAST(@CurrentYear AS VARCHAR(4)) + '-' + 
                         RIGHT('00000' + CAST(@NextNumber AS VARCHAR), 5);
        
        COMMIT TRANSACTION;
        
        -- Return the PLS number
        SELECT @PlsNumber AS PlsNumber;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        SET @ErrorMessage = ERROR_MESSAGE();
        SET @PlsNumber = NULL;
        
        -- Re-throw the error
        THROW;
    END CATCH
END;
GO

PRINT 'usp_GetNextPlsNumber stored procedure created successfully';
GO

-- ============================================================================
-- TEST / EXAMPLE USAGE
-- ============================================================================

/*
-- Example 1: Get next PLS number
DECLARE @PlsNum VARCHAR(50);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum AS GeneratedPlsNumber;
GO

-- Example 2: Get multiple PLS numbers (for testing)
DECLARE @PlsNum1 VARCHAR(50), @PlsNum2 VARCHAR(50), @PlsNum3 VARCHAR(50);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum1 OUTPUT;
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum2 OUTPUT;
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum3 OUTPUT;
SELECT 
    @PlsNum1 AS PlsNumber1,
    @PlsNum2 AS PlsNumber2,
    @PlsNum3 AS PlsNumber3;
GO

-- Example 3: View current sequence state
SELECT Year, NextNumber, LastUpdate
FROM dbo.PlsNumberSequence
ORDER BY Year DESC;
GO
*/

-- ============================================================================
-- VERIFICATION
-- ============================================================================

PRINT '';
PRINT '========================================';
PRINT 'Verification';
PRINT '========================================';
PRINT 'PlsNumberSequence table and usp_GetNextPlsNumber procedure created';
PRINT '';
PRINT 'To test, run:';
PRINT '  DECLARE @PlsNum VARCHAR(50);';
PRINT '  EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;';
PRINT '  SELECT @PlsNum AS GeneratedPlsNumber;';
GO

