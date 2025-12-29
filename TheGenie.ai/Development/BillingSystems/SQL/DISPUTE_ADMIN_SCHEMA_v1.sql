-- ============================================================
-- DISPUTE ADMIN SYSTEM - DATABASE SCHEMA
-- ============================================================
-- Version: 1.0
-- Created: 12/29/2025
-- Author: Cursor Opus Agent
-- Database: FarmGenie
-- 
-- PURPOSE:
-- Creates all tables needed to power the Dispute Admin UI
-- for tracking chargebacks, evidence, documents, and outcomes.
--
-- EXECUTION:
-- Run this script on FarmGenie database (192.168.29.45)
-- Use SA credentials for table creation
-- ============================================================

USE FarmGenie;
GO

PRINT '============================================================';
PRINT 'DISPUTE ADMIN SYSTEM - Creating Tables';
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================';

-- ============================================================
-- TABLE 1: DisputeCase (Main Dispute Tracking)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputeCase]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputeCase (
        -- Primary Key
        DisputeCaseId INT IDENTITY(1,1) PRIMARY KEY,
        CaseNumber VARCHAR(50) NOT NULL, -- e.g., 'DC-2025-00001'
        
        -- Payment Provider Info
        PaymentProviderCaseId VARCHAR(100) NULL, -- PayPal case ID: PP-R-NVE-599340890
        PaymentProviderTransactionId VARCHAR(100) NULL, -- Gateway txn ID: 0XN48732G1786400J
        
        -- Customer Information (from WHMCS)
        WhmcsClientId INT NOT NULL,
        AspNetUserId UNIQUEIDENTIFIER NULL, -- Links to FarmGenie user if exists
        CustomerName NVARCHAR(200) NOT NULL,
        CustomerEmail NVARCHAR(200) NOT NULL,
        CustomerPhone NVARCHAR(50) NULL,
        
        -- WHMCS Transaction Details
        WhmcsTransactionId INT NULL,
        WhmcsInvoiceId INT NOT NULL,
        WhmcsOrderId INT NULL,
        WhmcsProductId INT NULL,
        
        -- Transaction Details
        TransactionDate DATETIME NOT NULL,
        TransactionAmount DECIMAL(10,2) NOT NULL,
        
        -- Product Information
        ProductType VARCHAR(20) NOT NULL, -- 'OneOff' or 'Subscription'
        ProductName NVARCHAR(200) NOT NULL,
        ProductDetails NVARCHAR(500) NULL, -- e.g., "ZIP 91325" or extra info
        
        -- Dispute Information
        DisputeReason NVARCHAR(500) NOT NULL,
        DisputeReasonCode VARCHAR(50) NULL, -- Visa/MC reason code if available
        DisputeFiledDate DATETIME NOT NULL,
        DisputeAmount DECIMAL(10,2) NOT NULL,
        ResponseDeadline DATETIME NULL,
        
        -- Status & Outcome
        DisputeStatus VARCHAR(30) NOT NULL DEFAULT 'Open', 
            -- Values: Open, EvidenceCollecting, EvidenceComplete, DocumentGenerated, 
            --         Submitted, UnderReview, Won, Lost, Withdrawn
        DisputeOutcome VARCHAR(20) NULL, -- Won, Lost, Partial, Withdrawn
        OutcomeDate DATETIME NULL,
        OutcomeAmount DECIMAL(10,2) NULL, -- Amount recovered (if partial or won)
        OutcomeNotes NVARCHAR(MAX) NULL,
        
        -- Evidence Collection Status
        EvidenceCollectionStarted DATETIME NULL,
        EvidenceCollectionCompleted DATETIME NULL,
        EvidenceScore INT NULL, -- 0-100 strength score
        EvidenceNotes NVARCHAR(MAX) NULL,
        
        -- Document Generation
        CurrentDocumentVersion INT NULL DEFAULT 0,
        LastDocumentGeneratedDate DATETIME NULL,
        LastDocumentPath NVARCHAR(500) NULL,
        
        -- Audit Fields
        CreatedBy UNIQUEIDENTIFIER NOT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        ModifiedBy UNIQUEIDENTIFIER NULL,
        ModifiedDate DATETIME NULL,
        IsDeleted BIT DEFAULT 0,
        
        -- Constraints
        CONSTRAINT UQ_DisputeCase_CaseNumber UNIQUE (CaseNumber)
    );

    -- Indexes for common queries
    CREATE INDEX IX_DisputeCase_Status ON dbo.DisputeCase(DisputeStatus);
    CREATE INDEX IX_DisputeCase_CustomerEmail ON dbo.DisputeCase(CustomerEmail);
    CREATE INDEX IX_DisputeCase_WhmcsClientId ON dbo.DisputeCase(WhmcsClientId);
    CREATE INDEX IX_DisputeCase_CreatedDate ON dbo.DisputeCase(CreatedDate DESC);
    CREATE INDEX IX_DisputeCase_ResponseDeadline ON dbo.DisputeCase(ResponseDeadline);
    CREATE INDEX IX_DisputeCase_PaymentProviderCaseId ON dbo.DisputeCase(PaymentProviderCaseId);

    PRINT '✅ Created table: DisputeCase';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputeCase';
END
GO

-- ============================================================
-- TABLE 2: DisputeEvidence (Evidence Items Collected)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputeEvidence]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputeEvidence (
        DisputeEvidenceId INT IDENTITY(1,1) PRIMARY KEY,
        DisputeCaseId INT NOT NULL,
        
        -- Evidence Source & Type
        EvidenceSource VARCHAR(50) NOT NULL, 
            -- Values: WHMCS, FarmGenie, Intercom, SendGrid, Twilio, Zoom, Manual
        EvidenceType VARCHAR(50) NOT NULL,
            -- Values: ClientDetails, Invoice, Order, Transaction, PaymentHistory,
            --         LoginActivity, ServiceUsage, Conversation, EmailEvent, 
            --         SMSDelivery, CallLog, Screenshot, Document, Note
        
        -- Evidence Details
        EvidenceTitle NVARCHAR(200) NOT NULL,
        EvidenceDescription NVARCHAR(500) NULL,
        EvidenceData NVARCHAR(MAX) NULL, -- JSON blob of raw data
        EvidenceTimestamp DATETIME NULL, -- Timestamp of the evidence itself
        
        -- Evidence Evaluation
        EvidenceStrength INT NULL, -- 1-5 rating (5 = strongest)
        IsKeyFinding BIT DEFAULT 0, -- Highlight as key evidence
        KeyFindingNote NVARCHAR(500) NULL,
        
        -- Document Usage
        IsUsedInDocument BIT DEFAULT 0,
        DocumentSection NVARCHAR(100) NULL, -- Which section it appears in
        
        -- Collection Status
        CollectionStatus VARCHAR(20) DEFAULT 'Collected', -- Collected, Failed, Pending
        CollectionError NVARCHAR(500) NULL,
        
        -- Audit
        CollectedDate DATETIME DEFAULT GETDATE(),
        CollectedBy UNIQUEIDENTIFIER NULL, -- NULL = system automated
        
        CONSTRAINT FK_DisputeEvidence_DisputeCase 
            FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
    );

    CREATE INDEX IX_DisputeEvidence_CaseId ON dbo.DisputeEvidence(DisputeCaseId);
    CREATE INDEX IX_DisputeEvidence_Source ON dbo.DisputeEvidence(EvidenceSource);
    CREATE INDEX IX_DisputeEvidence_KeyFinding ON dbo.DisputeEvidence(IsKeyFinding) WHERE IsKeyFinding = 1;

    PRINT '✅ Created table: DisputeEvidence';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputeEvidence';
END
GO

-- ============================================================
-- TABLE 3: DisputeDocument (Generated Documents)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputeDocument]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputeDocument (
        DisputeDocumentId INT IDENTITY(1,1) PRIMARY KEY,
        DisputeCaseId INT NOT NULL,
        
        -- Document Details
        DocumentType VARCHAR(50) NOT NULL, 
            -- Values: DefenseResponse, EvidencePackage, Screenshot, CustomerLetter, 
            --         PayPalExport, Internal
        DocumentName NVARCHAR(200) NOT NULL,
        DocumentPath NVARCHAR(500) NOT NULL, -- Full path or cloud URL
        DocumentVersion INT NOT NULL DEFAULT 1,
        
        -- File Details
        FileSize BIGINT NULL, -- bytes
        MimeType VARCHAR(100) NULL, -- application/pdf, image/png, etc.
        PageCount INT NULL,
        
        -- Submission Status
        IsSubmitted BIT DEFAULT 0,
        SubmittedDate DATETIME NULL,
        SubmittedTo VARCHAR(100) NULL, -- 'PayPal', 'Bank', etc.
        SubmissionReference NVARCHAR(200) NULL,
        
        -- Template Info
        TemplateName NVARCHAR(100) NULL,
        TemplateVersion NVARCHAR(20) NULL,
        
        -- Audit
        GeneratedBy UNIQUEIDENTIFIER NOT NULL,
        GeneratedDate DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_DisputeDocument_DisputeCase 
            FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
    );

    CREATE INDEX IX_DisputeDocument_CaseId ON dbo.DisputeDocument(DisputeCaseId);
    CREATE INDEX IX_DisputeDocument_Type ON dbo.DisputeDocument(DocumentType);

    PRINT '✅ Created table: DisputeDocument';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputeDocument';
END
GO

-- ============================================================
-- TABLE 4: DisputeActivityLog (Timeline/History)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputeActivityLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputeActivityLog (
        DisputeActivityLogId INT IDENTITY(1,1) PRIMARY KEY,
        DisputeCaseId INT NOT NULL,
        
        -- Activity Details
        ActivityType VARCHAR(50) NOT NULL,
            -- Values: Created, EvidenceStarted, EvidenceCollected, EvidenceCompleted,
            --         DocumentGenerated, NoteAdded, StatusChanged, Submitted, 
            --         OutcomeLogged, Reopened, Deleted
        ActivityTitle NVARCHAR(200) NOT NULL,
        ActivityDescription NVARCHAR(MAX) NULL,
        ActivityData NVARCHAR(MAX) NULL, -- JSON for additional context
        
        -- Actor
        PerformedBy UNIQUEIDENTIFIER NULL, -- NULL = system
        PerformedByName NVARCHAR(200) NULL, -- Denormalized for display
        IsSystemAction BIT DEFAULT 0,
        
        -- Timestamp
        PerformedDate DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_DisputeActivityLog_DisputeCase 
            FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
    );

    CREATE INDEX IX_DisputeActivityLog_CaseId ON dbo.DisputeActivityLog(DisputeCaseId);
    CREATE INDEX IX_DisputeActivityLog_Date ON dbo.DisputeActivityLog(PerformedDate DESC);
    CREATE INDEX IX_DisputeActivityLog_Type ON dbo.DisputeActivityLog(ActivityType);

    PRINT '✅ Created table: DisputeActivityLog';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputeActivityLog';
END
GO

-- ============================================================
-- TABLE 5: DisputeAttachment (User Uploaded Files)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputeAttachment]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputeAttachment (
        DisputeAttachmentId INT IDENTITY(1,1) PRIMARY KEY,
        DisputeCaseId INT NOT NULL,
        
        -- File Details
        FileName NVARCHAR(200) NOT NULL,
        FilePath NVARCHAR(500) NOT NULL,
        FileSize BIGINT NULL,
        MimeType VARCHAR(100) NULL,
        
        -- Metadata
        AttachmentType VARCHAR(50) NULL, -- PayPalScreenshot, BankLetter, Email, Other
        Description NVARCHAR(500) NULL,
        
        -- OCR/Extraction (for PayPal screenshots)
        ExtractedData NVARCHAR(MAX) NULL, -- JSON with extracted invoice #, amounts, etc.
        OcrProcessed BIT DEFAULT 0,
        
        -- Audit
        UploadedBy UNIQUEIDENTIFIER NOT NULL,
        UploadedDate DATETIME DEFAULT GETDATE(),
        IsDeleted BIT DEFAULT 0,
        
        CONSTRAINT FK_DisputeAttachment_DisputeCase 
            FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
    );

    CREATE INDEX IX_DisputeAttachment_CaseId ON dbo.DisputeAttachment(DisputeCaseId);

    PRINT '✅ Created table: DisputeAttachment';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputeAttachment';
END
GO

-- ============================================================
-- TABLE 6: DisputeNote (User Notes on Cases)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputeNote]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputeNote (
        DisputeNoteId INT IDENTITY(1,1) PRIMARY KEY,
        DisputeCaseId INT NOT NULL,
        
        -- Note Content
        NoteText NVARCHAR(MAX) NOT NULL,
        NoteType VARCHAR(30) DEFAULT 'General', -- General, KeyFinding, Strategy, Internal
        IsPinned BIT DEFAULT 0,
        
        -- Audit
        CreatedBy UNIQUEIDENTIFIER NOT NULL,
        CreatedByName NVARCHAR(200) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME NULL,
        IsDeleted BIT DEFAULT 0,
        
        CONSTRAINT FK_DisputeNote_DisputeCase 
            FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
    );

    CREATE INDEX IX_DisputeNote_CaseId ON dbo.DisputeNote(DisputeCaseId);

    PRINT '✅ Created table: DisputeNote';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputeNote';
END
GO

-- ============================================================
-- TABLE 7: DisputePermission (User Access Control)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputePermission]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputePermission (
        DisputePermissionId INT IDENTITY(1,1) PRIMARY KEY,
        
        -- User
        AspNetUserId UNIQUEIDENTIFIER NOT NULL,
        UserEmail NVARCHAR(200) NULL,
        UserName NVARCHAR(200) NULL,
        
        -- Permission Level
        PermissionLevel VARCHAR(20) NOT NULL, 
            -- Values: SuperUser, DisputeManager, Analyst, Viewer
        
        -- Audit
        GrantedBy UNIQUEIDENTIFIER NOT NULL,
        GrantedDate DATETIME DEFAULT GETDATE(),
        RevokedDate DATETIME NULL,
        IsActive BIT DEFAULT 1,
        
        CONSTRAINT UQ_DisputePermission_User UNIQUE (AspNetUserId)
    );

    PRINT '✅ Created table: DisputePermission';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputePermission';
END
GO

-- ============================================================
-- TABLE 8: DisputeProductTemplate (Product-Specific Config)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisputeProductTemplate]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.DisputeProductTemplate (
        DisputeProductTemplateId INT IDENTITY(1,1) PRIMARY KEY,
        
        -- Product Identification
        WhmcsProductId INT NOT NULL,
        ProductName NVARCHAR(200) NOT NULL,
        ProductType VARCHAR(20) NOT NULL, -- 'OneOff' or 'Subscription'
        
        -- Evidence Collection Configuration
        EvidenceConfig NVARCHAR(MAX) NOT NULL, -- JSON defining which evidence sources to query
        
        -- Template Configuration
        TemplatePythonScript NVARCHAR(500) NULL, -- Path to generator script
        TemplateVersion INT NOT NULL DEFAULT 1,
        TemplateNotes NVARCHAR(500) NULL,
        
        -- Status
        IsActive BIT DEFAULT 1,
        
        -- Audit
        CreatedBy UNIQUEIDENTIFIER NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME NULL,
        
        CONSTRAINT UQ_DisputeProductTemplate_Product UNIQUE (WhmcsProductId)
    );

    PRINT '✅ Created table: DisputeProductTemplate';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: DisputeProductTemplate';
END
GO

-- ============================================================
-- TABLE 9: PayPalWebhookLog (Incoming Webhook Events)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PayPalWebhookLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.PayPalWebhookLog (
        PayPalWebhookLogId INT IDENTITY(1,1) PRIMARY KEY,
        
        -- Event Identification
        PayPalEventId VARCHAR(100) NOT NULL, -- PayPal's event ID
        EventType VARCHAR(100) NOT NULL, -- e.g., CUSTOMER.DISPUTE.CREATED
        ResourceType VARCHAR(50) NULL, -- e.g., dispute, payment
        
        -- Event Data
        EventSummary NVARCHAR(500) NULL,
        RawPayload NVARCHAR(MAX) NOT NULL, -- Full JSON payload
        
        -- Processing Status
        ProcessingStatus VARCHAR(20) DEFAULT 'Received', -- Received, Processed, Failed, Ignored
        ProcessingError NVARCHAR(500) NULL,
        ProcessedDate DATETIME NULL,
        
        -- Linked Dispute Case (if applicable)
        DisputeCaseId INT NULL,
        
        -- Audit
        ReceivedDate DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_PayPalWebhookLog_DisputeCase 
            FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
    );

    CREATE INDEX IX_PayPalWebhookLog_EventType ON dbo.PayPalWebhookLog(EventType);
    CREATE INDEX IX_PayPalWebhookLog_ReceivedDate ON dbo.PayPalWebhookLog(ReceivedDate DESC);
    CREATE INDEX IX_PayPalWebhookLog_PayPalEventId ON dbo.PayPalWebhookLog(PayPalEventId);

    PRINT '✅ Created table: PayPalWebhookLog';
END
ELSE
BEGIN
    PRINT '⏭️ Table already exists: PayPalWebhookLog';
END
GO

-- ============================================================
-- SEED DATA: Product Templates
-- ============================================================
PRINT '';
PRINT 'Inserting seed data...';

-- Competition Command Template
IF NOT EXISTS (SELECT 1 FROM dbo.DisputeProductTemplate WHERE WhmcsProductId = 83)
BEGIN
    INSERT INTO dbo.DisputeProductTemplate 
    (WhmcsProductId, ProductName, ProductType, EvidenceConfig, TemplatePythonScript, TemplateNotes)
    VALUES 
    (83, 'Competition Command', 'Subscription', 
     '{"sources":["whmcs","farmgenie","intercom","sendgrid","zoom"],"subscription":{"requirePaymentHistory":true,"requireCancellationSearch":true,"minPaymentsForPattern":3}}',
     'generate_competition_command_response_v5.py',
     'Subscription product - emphasize payment history and cancellation timeline');
    PRINT '✅ Inserted template: Competition Command (Product 83)';
END

-- Listing Command Template (using 0 as placeholder - update with real ID)
IF NOT EXISTS (SELECT 1 FROM dbo.DisputeProductTemplate WHERE ProductName = 'Listing Command Pro')
BEGIN
    INSERT INTO dbo.DisputeProductTemplate 
    (WhmcsProductId, ProductName, ProductType, EvidenceConfig, TemplatePythonScript, TemplateNotes)
    VALUES 
    (0, 'Listing Command Pro', 'OneOff', 
     '{"sources":["whmcs","farmgenie","intercom","sendgrid","twilio","zoom"],"oneoff":{"requireServiceDelivery":true,"requireScreenshots":true,"trackSmsEngagement":true}}',
     'generate_polished_response_v12.py',
     'One-off product - emphasize service delivery and lead generation');
    PRINT '✅ Inserted template: Listing Command Pro';
END
GO

-- ============================================================
-- HELPER FUNCTION: Generate Case Number
-- ============================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GenerateDisputeCaseNumber]') AND type in (N'FN'))
    DROP FUNCTION dbo.fn_GenerateDisputeCaseNumber;
GO

CREATE FUNCTION dbo.fn_GenerateDisputeCaseNumber()
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Year INT = YEAR(GETDATE());
    DECLARE @NextNum INT;
    
    SELECT @NextNum = ISNULL(MAX(
        TRY_CAST(RIGHT(CaseNumber, 5) AS INT)
    ), 0) + 1
    FROM dbo.DisputeCase
    WHERE CaseNumber LIKE 'DC-' + CAST(@Year AS VARCHAR) + '-%';
    
    RETURN 'DC-' + CAST(@Year AS VARCHAR) + '-' + RIGHT('00000' + CAST(@NextNum AS VARCHAR), 5);
END
GO

PRINT '✅ Created function: fn_GenerateDisputeCaseNumber';
GO

-- ============================================================
-- VIEW: Dashboard Statistics
-- ============================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_DisputeDashboardStats')
    DROP VIEW dbo.vw_DisputeDashboardStats;
GO

CREATE VIEW dbo.vw_DisputeDashboardStats
AS
SELECT
    -- Open Cases
    COUNT(CASE WHEN DisputeStatus IN ('Open', 'EvidenceCollecting', 'EvidenceComplete', 'DocumentGenerated') THEN 1 END) AS OpenCases,
    SUM(CASE WHEN DisputeStatus IN ('Open', 'EvidenceCollecting', 'EvidenceComplete', 'DocumentGenerated') THEN DisputeAmount ELSE 0 END) AS OpenAmount,
    
    -- Evidence Pending
    COUNT(CASE WHEN DisputeStatus IN ('EvidenceCollecting') THEN 1 END) AS EvidencePendingCases,
    SUM(CASE WHEN DisputeStatus IN ('EvidenceCollecting') THEN DisputeAmount ELSE 0 END) AS EvidencePendingAmount,
    
    -- Under Review
    COUNT(CASE WHEN DisputeStatus IN ('Submitted', 'UnderReview') THEN 1 END) AS UnderReviewCases,
    SUM(CASE WHEN DisputeStatus IN ('Submitted', 'UnderReview') THEN DisputeAmount ELSE 0 END) AS UnderReviewAmount,
    
    -- Won (Current Year)
    COUNT(CASE WHEN DisputeOutcome = 'Won' AND YEAR(OutcomeDate) = YEAR(GETDATE()) THEN 1 END) AS WonCasesYTD,
    SUM(CASE WHEN DisputeOutcome = 'Won' AND YEAR(OutcomeDate) = YEAR(GETDATE()) THEN ISNULL(OutcomeAmount, DisputeAmount) ELSE 0 END) AS WonAmountYTD,
    
    -- Lost (Current Year)
    COUNT(CASE WHEN DisputeOutcome = 'Lost' AND YEAR(OutcomeDate) = YEAR(GETDATE()) THEN 1 END) AS LostCasesYTD,
    SUM(CASE WHEN DisputeOutcome = 'Lost' AND YEAR(OutcomeDate) = YEAR(GETDATE()) THEN DisputeAmount ELSE 0 END) AS LostAmountYTD,
    
    -- Win Rate
    CASE 
        WHEN COUNT(CASE WHEN DisputeOutcome IN ('Won', 'Lost') AND YEAR(OutcomeDate) = YEAR(GETDATE()) THEN 1 END) > 0
        THEN CAST(COUNT(CASE WHEN DisputeOutcome = 'Won' AND YEAR(OutcomeDate) = YEAR(GETDATE()) THEN 1 END) AS FLOAT) /
             CAST(COUNT(CASE WHEN DisputeOutcome IN ('Won', 'Lost') AND YEAR(OutcomeDate) = YEAR(GETDATE()) THEN 1 END) AS FLOAT) * 100
        ELSE 0 
    END AS WinRatePercentYTD,
    
    -- Deadlines
    COUNT(CASE WHEN DisputeStatus NOT IN ('Won', 'Lost', 'Withdrawn') AND ResponseDeadline < GETDATE() THEN 1 END) AS OverdueCases,
    COUNT(CASE WHEN DisputeStatus NOT IN ('Won', 'Lost', 'Withdrawn') AND ResponseDeadline BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE()) THEN 1 END) AS DueSoon7Days
FROM dbo.DisputeCase
WHERE IsDeleted = 0;
GO

PRINT '✅ Created view: vw_DisputeDashboardStats';
GO

-- ============================================================
-- SUMMARY
-- ============================================================
PRINT '';
PRINT '============================================================';
PRINT 'DISPUTE ADMIN SYSTEM - Schema Creation Complete!';
PRINT 'Completed: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================';
PRINT '';
PRINT 'Tables Created:';
PRINT '  1. DisputeCase - Main dispute tracking';
PRINT '  2. DisputeEvidence - Evidence items collected';
PRINT '  3. DisputeDocument - Generated documents';
PRINT '  4. DisputeActivityLog - Timeline/history';
PRINT '  5. DisputeAttachment - User uploaded files';
PRINT '  6. DisputeNote - User notes on cases';
PRINT '  7. DisputePermission - User access control';
PRINT '  8. DisputeProductTemplate - Product configurations';
PRINT '  9. PayPalWebhookLog - Incoming webhook events';
PRINT '';
PRINT 'Functions Created:';
PRINT '  - fn_GenerateDisputeCaseNumber()';
PRINT '';
PRINT 'Views Created:';
PRINT '  - vw_DisputeDashboardStats';
PRINT '';
PRINT 'Next Steps:';
PRINT '  1. Run this script on FarmGenie database';
PRINT '  2. Grant permissions to application service account';
PRINT '  3. Insert initial Super User permissions';
PRINT '  4. Connect UI to these tables';
PRINT '============================================================';
GO

