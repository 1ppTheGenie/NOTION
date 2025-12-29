-- ============================================================
-- INSERT INITIAL DISPUTE CASES
-- ============================================================
-- Version: 1.0
-- Created: 12/29/2025
-- Author: Cursor Opus Agent
-- 
-- PURPOSE:
-- Inserts the 2 chargebacks disputed on 12/28/2025:
-- 1. Chris Plank - Listing Command ($67.50)
-- 2. Susan Featherly - Competition Command ($500.00)
--
-- PREREQUISITE:
-- Run DISPUTE_ADMIN_SCHEMA_v1.sql first to create tables
-- ============================================================

USE FarmGenie;
GO

PRINT '============================================================';
PRINT 'Inserting Initial Dispute Cases';
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================';

-- ============================================================
-- CASE 1: Chris Plank - Listing Command
-- ============================================================
DECLARE @ChrisPlankUserId UNIQUEIDENTIFIER = NULL; -- Look up if exists
DECLARE @CreatedByUserId UNIQUEIDENTIFIER = 'E48D2A8E-C991-44F4-B751-E170FC8DF131'; -- Steve's ID (update as needed)

-- Try to find Chris Plank's AspNetUserId
SELECT TOP 1 @ChrisPlankUserId = Id 
FROM dbo.AspNetUsers 
WHERE Email LIKE '%cp@pacificapg.com%' OR Email LIKE '%chris%plank%';

IF NOT EXISTS (SELECT 1 FROM dbo.DisputeCase WHERE CustomerEmail = 'cp@pacificapg.com')
BEGIN
    INSERT INTO dbo.DisputeCase (
        CaseNumber,
        PaymentProviderCaseId,
        PaymentProviderTransactionId,
        WhmcsClientId,
        AspNetUserId,
        CustomerName,
        CustomerEmail,
        WhmcsInvoiceId,
        WhmcsOrderId,
        TransactionDate,
        TransactionAmount,
        ProductType,
        ProductName,
        ProductDetails,
        DisputeReason,
        DisputeFiledDate,
        DisputeAmount,
        ResponseDeadline,
        DisputeStatus,
        DisputeOutcome,
        OutcomeDate,
        OutcomeNotes,
        EvidenceCollectionStarted,
        EvidenceCollectionCompleted,
        EvidenceScore,
        CurrentDocumentVersion,
        LastDocumentGeneratedDate,
        LastDocumentPath,
        CreatedBy,
        CreatedDate
    )
    VALUES (
        'DC-2025-00001',                                    -- CaseNumber
        NULL,                                                -- PaymentProviderCaseId (update with actual)
        NULL,                                                -- PaymentProviderTransactionId (update with actual)
        0,                                                   -- WhmcsClientId (update with actual)
        @ChrisPlankUserId,                                   -- AspNetUserId
        'Chris Plank',                                       -- CustomerName
        'cp@pacificapg.com',                                 -- CustomerEmail
        0,                                                   -- WhmcsInvoiceId (update with actual)
        0,                                                   -- WhmcsOrderId (update with actual)
        '2025-12-01',                                        -- TransactionDate (approximate)
        67.50,                                               -- TransactionAmount
        'OneOff',                                            -- ProductType
        'Listing Command Pro',                               -- ProductName
        NULL,                                                -- ProductDetails
        'Unauthorized transaction',                          -- DisputeReason
        '2025-12-19',                                        -- DisputeFiledDate
        67.50,                                               -- DisputeAmount
        '2026-01-03',                                        -- ResponseDeadline
        'Won',                                               -- DisputeStatus
        'Won',                                               -- DisputeOutcome
        '2025-12-28',                                        -- OutcomeDate
        'Successfully defended. Evidence package submitted showing service delivery and customer engagement.',
        '2025-12-28',                                        -- EvidenceCollectionStarted
        '2025-12-28',                                        -- EvidenceCollectionCompleted
        95,                                                  -- EvidenceScore
        12,                                                  -- CurrentDocumentVersion (v12 template)
        '2025-12-28',                                        -- LastDocumentGeneratedDate
        'D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Output\ChrisPlank_ListingCommand_Dispute_Response_v12.pdf',
        @CreatedByUserId,                                    -- CreatedBy
        '2025-12-28'                                         -- CreatedDate
    );
    
    PRINT '✅ Inserted Case: DC-2025-00001 - Chris Plank (Listing Command) - WON';
    
    -- Add activity log entry
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'Created', 'Case created', 'Dispute case created from PayPal notification', 'Steve Hundley', 0, '2025-12-28 10:00:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00001';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'EvidenceCompleted', 'Evidence collection completed', 'Score: 95/100 - All evidence sources collected successfully', 'System', 1, '2025-12-28 10:30:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00001';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'DocumentGenerated', 'Defense document v12 generated', 'ChrisPlank_ListingCommand_Dispute_Response_v12.pdf', 'Cursor Agent', 0, '2025-12-28 11:00:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00001';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'OutcomeLogged', 'Dispute WON', 'PayPal ruled in favor of merchant. Full amount retained.', 'Steve Hundley', 0, '2025-12-28 14:00:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00001';
    
END
ELSE
BEGIN
    PRINT '⏭️ Case already exists: Chris Plank';
END
GO

-- ============================================================
-- CASE 2: Susan Featherly - Competition Command
-- ============================================================
DECLARE @SusanUserId UNIQUEIDENTIFIER = NULL;
DECLARE @CreatedByUserId2 UNIQUEIDENTIFIER = 'E48D2A8E-C991-44F4-B751-E170FC8DF131';

-- Try to find Susan's AspNetUserId
SELECT TOP 1 @SusanUserId = Id 
FROM dbo.AspNetUsers 
WHERE Email LIKE '%homesbypeter%' OR Email LIKE '%susan%featherly%';

IF NOT EXISTS (SELECT 1 FROM dbo.DisputeCase WHERE CustomerEmail = 'homesbypeter.susan@gmail.com')
BEGIN
    INSERT INTO dbo.DisputeCase (
        CaseNumber,
        PaymentProviderCaseId,
        PaymentProviderTransactionId,
        WhmcsClientId,
        AspNetUserId,
        CustomerName,
        CustomerEmail,
        WhmcsInvoiceId,
        WhmcsOrderId,
        WhmcsProductId,
        TransactionDate,
        TransactionAmount,
        ProductType,
        ProductName,
        ProductDetails,
        DisputeReason,
        DisputeFiledDate,
        DisputeAmount,
        ResponseDeadline,
        DisputeStatus,
        EvidenceCollectionStarted,
        EvidenceCollectionCompleted,
        EvidenceScore,
        EvidenceNotes,
        CurrentDocumentVersion,
        LastDocumentGeneratedDate,
        LastDocumentPath,
        CreatedBy,
        CreatedDate
    )
    VALUES (
        'DC-2025-00002',                                    -- CaseNumber
        'PP-R-NVE-599340890',                               -- PaymentProviderCaseId
        '0XN48732G1786400J',                                -- PaymentProviderTransactionId
        3158,                                               -- WhmcsClientId
        @SusanUserId,                                       -- AspNetUserId
        'Susan Featherly',                                  -- CustomerName
        'homesbypeter.susan@gmail.com',                     -- CustomerEmail
        62279,                                              -- WhmcsInvoiceId
        8923,                                               -- WhmcsOrderId
        83,                                                 -- WhmcsProductId (Competition Command)
        '2025-10-14',                                       -- TransactionDate
        500.00,                                             -- TransactionAmount
        'Subscription',                                     -- ProductType
        'Competition Command',                              -- ProductName
        'ZIP 91325 - Monthly Subscription',                 -- ProductDetails
        'Cancelled before being billed',                    -- DisputeReason
        '2025-10-24',                                       -- DisputeFiledDate
        500.00,                                             -- DisputeAmount
        '2025-11-08',                                       -- ResponseDeadline
        'Submitted',                                        -- DisputeStatus (Evidence submitted, waiting)
        '2025-12-28 10:20:00',                              -- EvidenceCollectionStarted
        '2025-12-28 10:30:00',                              -- EvidenceCollectionCompleted
        95,                                                 -- EvidenceScore
        'KEY FINDING: Customer cancellation request dated Oct 23, 2025 - 9 DAYS AFTER the disputed billing date (Oct 14). This contradicts claim of "cancelled before being billed."',
        5,                                                  -- CurrentDocumentVersion
        '2025-12-28 11:45:00',                              -- LastDocumentGeneratedDate
        'D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Output\SusanFeatherly_CompetitionCommand_Dispute_Response_v5.pdf',
        @CreatedByUserId2,                                  -- CreatedBy
        '2025-12-28 10:20:00'                               -- CreatedDate
    );
    
    PRINT '✅ Inserted Case: DC-2025-00002 - Susan Featherly (Competition Command) - SUBMITTED';
    
    -- Add activity log entries
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'Created', 'Case created', 'Dispute imported from PayPal notification - PP-R-NVE-599340890', 'Steve Hundley', 0, '2025-12-28 10:20:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'EvidenceStarted', 'Evidence collection started', 'Querying WHMCS, FarmGenie, Intercom, Zoom...', 'System', 1, '2025-12-28 10:23:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'NoteAdded', 'Key finding noted', 'Customer cancellation request found dated Oct 23, 2025 - 9 days AFTER the disputed billing. This contradicts their claim.', 'Steve Hundley', 0, '2025-12-28 10:25:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'EvidenceCompleted', 'Evidence collection completed', 'Score: 95/100 - WHMCS ✅ FarmGenie ✅ Intercom ✅ Zoom ✅ SendGrid ⚠️ (not configured)', 'System', 1, '2025-12-28 10:30:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'DocumentGenerated', 'Defense document v5 generated', 'SusanFeatherly_CompetitionCommand_Dispute_Response_v5.pdf - Subscription Gold Class template with GPT Advisor polish', 'Cursor Agent', 0, '2025-12-28 11:45:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeActivityLog (DisputeCaseId, ActivityType, ActivityTitle, ActivityDescription, PerformedByName, IsSystemAction, PerformedDate)
    SELECT DisputeCaseId, 'StatusChanged', 'Status changed to Submitted', 'Defense package submitted to PayPal via Resolution Center', 'Steve Hundley', 0, '2025-12-28 12:00:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    -- Add the key evidence items
    INSERT INTO dbo.DisputeEvidence (DisputeCaseId, EvidenceSource, EvidenceType, EvidenceTitle, EvidenceDescription, EvidenceStrength, IsKeyFinding, KeyFindingNote, CollectedDate)
    SELECT DisputeCaseId, 'WHMCS', 'PaymentHistory', '9 Successful Payments', 'Customer made 9 consecutive payments from Feb-Oct 2025 totaling $4,000 without dispute', 5, 1, 'Establishes pattern of authorized recurring payments', '2025-12-28 10:25:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeEvidence (DisputeCaseId, EvidenceSource, EvidenceType, EvidenceTitle, EvidenceDescription, EvidenceStrength, IsKeyFinding, KeyFindingNote, CollectedDate)
    SELECT DisputeCaseId, 'Intercom', 'Conversation', 'Cancellation Request - Oct 23, 2025', 'Customer submitted cancellation request 9 DAYS AFTER disputed billing date', 5, 1, 'CRITICAL: Contradicts claim of "cancelled before being billed"', '2025-12-28 10:26:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeEvidence (DisputeCaseId, EvidenceSource, EvidenceType, EvidenceTitle, EvidenceDescription, EvidenceStrength, IsKeyFinding, CollectedDate)
    SELECT DisputeCaseId, 'FarmGenie', 'ServiceUsage', '15,750+ Events Logged', 'Extensive platform usage during subscription period including login sessions and feature access', 4, 0, '2025-12-28 10:27:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeEvidence (DisputeCaseId, EvidenceSource, EvidenceType, EvidenceTitle, EvidenceDescription, EvidenceStrength, IsKeyFinding, CollectedDate)
    SELECT DisputeCaseId, 'FarmGenie', 'LoginActivity', '6 Login Sessions', 'Customer actively logged in and used service during billing period', 4, 0, '2025-12-28 10:28:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
    INSERT INTO dbo.DisputeEvidence (DisputeCaseId, EvidenceSource, EvidenceType, EvidenceTitle, EvidenceDescription, CollectionStatus, CollectionError, CollectedDate)
    SELECT DisputeCaseId, 'SendGrid', 'EmailEvent', 'Email Delivery Events', 'Email tracking data not available - SendGrid webhooks not configured', 'Failed', 'INTEGRATION GAP: SendGrid webhooks need configuration', '2025-12-28 10:29:00'
    FROM dbo.DisputeCase WHERE CaseNumber = 'DC-2025-00002';
    
END
ELSE
BEGIN
    PRINT '⏭️ Case already exists: Susan Featherly';
END
GO

-- ============================================================
-- ADD SUPER USER PERMISSION
-- ============================================================
DECLARE @SteveUserId UNIQUEIDENTIFIER = 'E48D2A8E-C991-44F4-B751-E170FC8DF131'; -- Update with actual

IF NOT EXISTS (SELECT 1 FROM dbo.DisputePermission WHERE AspNetUserId = @SteveUserId)
BEGIN
    INSERT INTO dbo.DisputePermission (AspNetUserId, UserEmail, UserName, PermissionLevel, GrantedBy, GrantedDate)
    VALUES (@SteveUserId, 'steve@thegenie.ai', 'Steve Hundley', 'SuperUser', @SteveUserId, GETDATE());
    
    PRINT '✅ Added Super User permission: Steve Hundley';
END
GO

-- ============================================================
-- VERIFICATION
-- ============================================================
PRINT '';
PRINT '============================================================';
PRINT 'VERIFICATION - Current Dispute Cases:';
PRINT '============================================================';

SELECT 
    CaseNumber,
    CustomerName,
    ProductName,
    ProductType,
    FORMAT(DisputeAmount, 'C') AS Amount,
    DisputeStatus,
    DisputeOutcome,
    EvidenceScore
FROM dbo.DisputeCase
ORDER BY CaseNumber;

PRINT '';
PRINT 'Dashboard Statistics:';
SELECT * FROM dbo.vw_DisputeDashboardStats;

PRINT '';
PRINT '============================================================';
PRINT 'Initial Data Insert Complete!';
PRINT '============================================================';
GO

