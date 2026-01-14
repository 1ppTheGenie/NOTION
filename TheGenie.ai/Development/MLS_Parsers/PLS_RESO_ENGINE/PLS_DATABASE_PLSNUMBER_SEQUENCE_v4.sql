-- ============================================================================
-- PLS RESO Engine - PLS Number Sequence Table and Stored Procedure
-- Version: 4.0
-- Created: 01/05/2026
-- Last Updated: 01/05/2026
-- Author: Cursor AI Agent
-- Purpose: Thread-safe PLS number generation (format: PLS100000A)
-- ============================================================================
--
-- PLS Number Format: PLS{6-digit-number}{single-letter}
--   Example: PLS100000A, PLS100001A, ..., PLS999999A, PLS100000B, PLS100001B, ...
--   Number Range: 100000-999999 (900,000 numbers per letter)
--   Letter Range: A-Z (26 letters = 23.4 million total listings capacity)
--   When number reaches 999999, increment letter and reset to 100000
--
-- Thread-Safe: Uses transaction with atomic increment to prevent race conditions
--
-- ============================================================================

USE FarmGenie;
GO

-- ============================================================================
-- TABLE: PlsNumberSequence
-- Purpose: Manage PLS number generation (thread-safe)
-- Updated: Now tracks both number (100000-999999) and letter suffix (A-Z)
-- ============================================================================

IF OBJECT_ID('dbo.PlsNumberSequence', 'U') IS NOT NULL
    DROP TABLE dbo.PlsNumberSequence;
GO

CREATE TABLE dbo.PlsNumberSequence (
    LetterSuffix CHAR(1) NOT NULL,
        -- Current letter suffix: A, B, C, ..., Z
        -- When number reaches 999999, increment letter and reset to 100000
    CurrentNumber INT NOT NULL DEFAULT 100000,
        -- Current number in sequence (100000-999999)
        -- Starts at 100000, increments by 1
        -- Resets to 100000 when letter increments
    LastUpdate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        -- Last time this letter's sequence was updated
    
    CONSTRAINT PK_PlsNumberSequence PRIMARY KEY CLUSTERED (LetterSuffix),
    CONSTRAINT CK_PlsNumberSequence_Number CHECK (CurrentNumber >= 100000 AND CurrentNumber <= 999999),
    CONSTRAINT CK_PlsNumberSequence_Letter CHECK (LetterSuffix >= 'A' AND LetterSuffix <= 'Z')
);
GO

-- Insert initial record for letter 'A'
INSERT INTO dbo.PlsNumberSequence (LetterSuffix, CurrentNumber, LastUpdate)
VALUES ('A', 100000, GETUTCDATE());
GO

PRINT 'PlsNumberSequence table created successfully with initial record (A, 100000)';
GO

-- ============================================================================
-- STORED PROCEDURE: usp_GetNextPlsNumber
-- Purpose: Generate next PLS number in format PLS{6-digit}{letter} (thread-safe)
-- Updated: New format PLS100000A, PLS100001A, ..., PLS999999A, PLS100000B, ...
-- ============================================================================

IF OBJECT_ID('dbo.usp_GetNextPlsNumber', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetNextPlsNumber;
GO

CREATE PROCEDURE dbo.usp_GetNextPlsNumber
    @PlsNumber VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentLetter CHAR(1) = 'A';
    DECLARE @NextNumber INT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get the current letter with highest number (or lowest letter if all at 999999)
        -- Priority: Find letter with number < 999999, otherwise get highest letter
        SELECT TOP 1 
            @CurrentLetter = LetterSuffix,
            @NextNumber = CurrentNumber
        FROM dbo.PlsNumberSequence WITH (UPDLOCK, ROWLOCK)
        WHERE CurrentNumber < 999999
        ORDER BY LetterSuffix ASC, CurrentNumber ASC;
        
        -- If no record found with number < 999999, get the highest letter
        IF @NextNumber IS NULL
        BEGIN
            SELECT TOP 1 
                @CurrentLetter = LetterSuffix,
                @NextNumber = CurrentNumber
            FROM dbo.PlsNumberSequence WITH (UPDLOCK, ROWLOCK)
            ORDER BY LetterSuffix DESC;
            
            -- If still NULL, start with 'A' and 100000
            IF @NextNumber IS NULL
            BEGIN
                SET @CurrentLetter = 'A';
                SET @NextNumber = 100000;
            END
            -- If current number is 999999, increment letter
            ELSE IF @NextNumber = 999999
            BEGIN
                -- Check if we can increment letter (not at 'Z')
                IF @CurrentLetter < 'Z'
                BEGIN
                    SET @CurrentLetter = CHAR(ASCII(@CurrentLetter) + 1);
                    SET @NextNumber = 100000;
                END
                ELSE
                BEGIN
                    -- At 'Z' and 999999 - cycle back to 'A' (or throw error - depends on business rule)
                    -- For now, cycle back to 'A' as user requested
                    SET @CurrentLetter = 'A';
                    SET @NextNumber = 100000;
                    PRINT 'WARNING: PLS number sequence cycled from Z999999 back to A100000';
                END
            END
        END
        
        -- Increment the number
        SET @NextNumber = @NextNumber + 1;
        
        -- Update or insert the record
        IF EXISTS (SELECT 1 FROM dbo.PlsNumberSequence WHERE LetterSuffix = @CurrentLetter)
        BEGIN
            -- Update existing letter record
            UPDATE dbo.PlsNumberSequence
            SET CurrentNumber = @NextNumber,
                LastUpdate = GETUTCDATE()
            WHERE LetterSuffix = @CurrentLetter;
        END
        ELSE
        BEGIN
            -- Insert new letter record (shouldn't happen often, but handles edge cases)
            INSERT INTO dbo.PlsNumberSequence (LetterSuffix, CurrentNumber, LastUpdate)
            VALUES (@CurrentLetter, @NextNumber, GETUTCDATE());
        END
        
        -- Format: PLS{6-digit-number}{letter}
        -- Example: PLS100000A, PLS100001A, PLS999999A, PLS100000B
        SET @PlsNumber = 'PLS' + 
                         RIGHT('000000' + CAST(@NextNumber AS VARCHAR), 6) + 
                         @CurrentLetter;
        
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
PRINT 'Format: PLS{6-digit-number}{letter} (e.g., PLS100000A, PLS100001A, ..., PLS999999A, PLS100000B)';
GO

-- ============================================================================
-- TEST / EXAMPLE USAGE
-- ============================================================================

/*
-- Example 1: Get next PLS number
DECLARE @PlsNum VARCHAR(10);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum AS GeneratedPlsNumber;
-- Expected: PLS100001A (first call after initial 100000A)
GO

-- Example 2: Get multiple PLS numbers (for testing)
DECLARE @PlsNum1 VARCHAR(10), @PlsNum2 VARCHAR(10), @PlsNum3 VARCHAR(10);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum1 OUTPUT;
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum2 OUTPUT;
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum3 OUTPUT;
SELECT 
    @PlsNum1 AS PlsNumber1,
    @PlsNum2 AS PlsNumber2,
    @PlsNum3 AS PlsNumber3;
-- Expected: PLS100001A, PLS100002A, PLS100003A
GO

-- Example 3: View current sequence state
SELECT LetterSuffix, CurrentNumber, LastUpdate
FROM dbo.PlsNumberSequence
ORDER BY LetterSuffix ASC, CurrentNumber ASC;
GO

-- Example 4: Test letter cycling (simulate reaching 999999)
-- Manually set to test:
UPDATE dbo.PlsNumberSequence SET CurrentNumber = 999999 WHERE LetterSuffix = 'A';
DECLARE @PlsNum VARCHAR(10);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum AS NextNumberAfter999999;
-- Expected: PLS100000B
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
PRINT 'Format: PLS{6-digit-number}{letter}';
PRINT '  - Number range: 100000-999999 (900,000 per letter)';
PRINT '  - Letter range: A-Z (26 letters = 23.4M total capacity)';
PRINT '  - Cycles: PLS999999A → PLS100000B → ... → PLS999999Z → PLS100000A';
PRINT '';
PRINT 'To test, run:';
PRINT '  DECLARE @PlsNum VARCHAR(10);';
PRINT '  EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;';
PRINT '  SELECT @PlsNum AS GeneratedPlsNumber;';
PRINT '  -- Expected: PLS100001A';
GO

