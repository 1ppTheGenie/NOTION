# Dispute Admin System - Complete Specification

**Version:** 1.0  
**Created:** 12/28/2025  
**Last Updated:** 12/28/2025  
**Author:** Cursor Opus Agent  
**Status:** SPECIFICATION COMPLETE

---

## Executive Summary

The Dispute Admin System is a comprehensive dashboard and workflow engine for processing chargeback disputes. It provides:

1. **Unified Dashboard** - View all dispute history with outcomes
2. **Conditional Workflows** - Separate evidence collection paths for One-Off vs Subscription products
3. **Full Evidence Integration** - WHMCS, FarmGenie, Intercom, Zoom, SendGrid, Twilio
4. **Super User Permissions** - Role-based access control
5. **Document Generation** - Automated defense kit creation
6. **Outcome Tracking** - Manual/automated dispute resolution logging

---

## 1. Access Control & Permissions

### 1.1 Permission Levels

| Role | Access Level | Capabilities |
|------|-------------|--------------|
| **Super User** | Full Admin | All dispute operations, schema access, outcome logging |
| **Dispute Manager** | Manager | Process disputes, view all cases, generate documents |
| **Viewer** | Read-Only | View dispute history, download documents |
| **Agent Support** | Limited | View own customer disputes only |

### 1.2 Database Permission Table

```sql
-- New table: FarmGenie.dbo.DisputePermission
CREATE TABLE dbo.DisputePermission (
    DisputePermissionId INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId UNIQUEIDENTIFIER NOT NULL,
    PermissionLevel VARCHAR(20) NOT NULL, -- 'SuperUser', 'DisputeManager', 'Viewer', 'AgentSupport'
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    IsActive BIT DEFAULT 1,
    
    FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id)
);
```

### 1.3 Super User Features

Super Users have exclusive access to:
- Configure evidence collection rules
- Add/modify product templates
- Override automated evidence gathering
- Update dispute outcomes
- Export dispute analytics
- Manage user permissions

---

## 2. Evidence Collection Workflow

### 2.1 Master Evidence Checklist

This checklist applies to ALL disputes. Items are marked as:
- ✅ **REQUIRED** - Must collect for every dispute
- ⭐ **CRITICAL** - High-value evidence for winning disputes
- ⚠️ **CONDITIONAL** - Depends on product type
- 🔴 **GAP** - Integration not yet complete

| # | Evidence Source | Data Collected | One-Off | Subscription | Status |
|---|----------------|----------------|---------|--------------|--------|
| 1 | **WHMCS - Client** | Name, email, phone, registration date | ✅ | ✅ | ✅ ACTIVE |
| 2 | **WHMCS - Invoice** | Invoice ID, date, line items, status | ✅ | ✅ | ✅ ACTIVE |
| 3 | **WHMCS - Order** | Order ID, date, product, notes, extras | ✅ | ✅ | ✅ ACTIVE |
| 4 | **WHMCS - Transaction** | Transaction ID, gateway, amount | ✅ | ✅ | ✅ ACTIVE |
| 5 | **WHMCS - Payment History** | All historical payments | ⚠️ Nice-to-have | ⭐ CRITICAL | ✅ ACTIVE |
| 6 | **FarmGenie - User Profile** | AspNetUserId, email, phone, creation date | ✅ | ✅ | ✅ ACTIVE |
| 7 | **FarmGenie - Login Activity** | Login timestamps, IP, device, browser | ⭐ CRITICAL | ⭐ CRITICAL | ✅ ACTIVE |
| 8 | **FarmGenie - Service Usage** | Product-specific activity logs | ⭐ CRITICAL | ⭐ CRITICAL | ✅ ACTIVE |
| 9 | **Intercom - Conversations** | Support tickets, cancellation requests | ⭐ CRITICAL | ⭐ CRITICAL | ✅ ACTIVE |
| 10 | **Intercom - Contact Details** | First contact date, last seen | ✅ | ✅ | ✅ ACTIVE |
| 11 | **Zoom Phone - Call Logs** | Call history to/from customer | ✅ | ✅ | ✅ ACTIVE |
| 12 | **SendGrid - Delivery** | Email delivered timestamp | ⭐ CRITICAL | ⭐ CRITICAL | 🔴 GAP |
| 13 | **SendGrid - Opens** | Email open events with timestamp | ⭐ CRITICAL | ⭐ CRITICAL | 🔴 GAP |
| 14 | **SendGrid - Clicks** | Link click events with timestamp | ⭐ CRITICAL | ⭐ CRITICAL | 🔴 GAP |
| 15 | **Twilio - SMS Delivery** | SMS delivery confirmations | ⚠️ LC Only | N/A | ✅ ACTIVE |
| 16 | **Genie Cloud - Screenshots** | Landing page, property images | ⚠️ LC Only | N/A | ✅ ACTIVE |

---

### 2.2 Product-Specific Workflows

#### ONE-OFF PRODUCTS (Listing Command, Optimization, etc.)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ONE-OFF DISPUTE WORKFLOW                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: TRANSACTION VERIFICATION                                   │
│  ├── Query WHMCS for order/invoice/transaction                     │
│  ├── Verify transaction ID matches disputed amount                  │
│  └── Extract order date, time, product details                      │
│                                                                      │
│  STEP 2: CUSTOMER AUTHORIZATION                                     │
│  ├── Query FarmGenie for login at time of order                    │
│  ├── Extract IP address, browser, device                           │
│  └── Correlate IP with customer's known IPs                        │
│                                                                      │
│  STEP 3: SERVICE DELIVERY PROOF                                     │
│  ├── Query product-specific tables:                                │
│  │   ├── Listing Command: SmsReportSendQueue, ListingCommandQueue  │
│  │   ├── Optimization: [optimization tables]                       │
│  │   └── Postcard: [postcard delivery tables]                      │
│  ├── Verify service was executed                                   │
│  └── Calculate delivery metrics (SMS sent, leads generated, etc.)  │
│                                                                      │
│  STEP 4: EMAIL VERIFICATION [CRITICAL]                              │
│  ├── Query SendGrid for confirmation email delivery                │
│  ├── Check for email opens/clicks                                  │
│  └── Document customer awareness of service                        │
│                                                                      │
│  STEP 5: SUPPORT CONTACT CHECK                                      │
│  ├── Search Intercom for customer conversations                    │
│  ├── Search Zoom for call records                                  │
│  └── Note: Zero contact = strong evidence                          │
│                                                                      │
│  STEP 6: GENERATE DEFENSE KIT                                       │
│  ├── Compile all evidence                                          │
│  ├── Generate PDF document                                         │
│  └── Package screenshots and attachments                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### SUBSCRIPTION PRODUCTS (Competition Command, Paisley Plus, etc.)

```
┌─────────────────────────────────────────────────────────────────────┐
│                  SUBSCRIPTION DISPUTE WORKFLOW                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: SUBSCRIPTION HISTORY                                       │
│  ├── Query WHMCS for complete payment history                      │
│  ├── Count total payments made                                     │
│  ├── Calculate total amount paid                                   │
│  └── Identify subscription start date and billing cycle            │
│                                                                      │
│  STEP 2: DISPUTED PAYMENT CONTEXT                                   │
│  ├── Verify disputed payment is part of recurring cycle            │
│  ├── Document previous successful payments (no disputes)           │
│  └── Calculate payment consistency pattern                         │
│                                                                      │
│  STEP 3: CANCELLATION TIMELINE [CRITICAL FOR SUBSCRIPTIONS]        │
│  ├── Search Intercom for cancellation requests                     │
│  ├── Extract exact timestamp of any cancellation message           │
│  ├── Compare cancellation date vs. billing date                    │
│  └── Quote customer's own words verbatim                           │
│                                                                      │
│  STEP 4: ONGOING SERVICE DELIVERY                                   │
│  ├── Query service usage AFTER disputed billing date               │
│  ├── Document continued service access                             │
│  └── Show post-billing activity = implicit acceptance              │
│                                                                      │
│  STEP 5: EMAIL VERIFICATION [CRITICAL]                              │
│  ├── Query SendGrid for billing notification emails                │
│  ├── Check for opens (proves customer awareness)                   │
│  └── Monthly billing reminders if configured                       │
│                                                                      │
│  STEP 6: TERMS OF SERVICE                                           │
│  ├── Reference subscription terms                                  │
│  ├── Document cancellation policy                                  │
│  └── Explain billing cutoff mechanics                              │
│                                                                      │
│  STEP 7: GENERATE DEFENSE KIT                                       │
│  ├── Use subscription-specific template                            │
│  ├── Emphasize payment history pattern                             │
│  └── Highlight cancellation timeline contradiction                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Database Schema

### 3.1 Core Tables

```sql
-- ============================================
-- DISPUTE ADMIN SYSTEM - DATABASE SCHEMA
-- Database: FarmGenie
-- ============================================

-- Main Dispute Case Table
CREATE TABLE dbo.DisputeCase (
    DisputeCaseId INT IDENTITY(1,1) PRIMARY KEY,
    CaseNumber VARCHAR(50) NOT NULL UNIQUE, -- e.g., 'DC-2025-00001'
    PaymentProviderCaseId VARCHAR(100) NULL, -- PayPal case ID, Stripe dispute ID, etc.
    
    -- Customer Information
    WhmcsClientId INT NOT NULL,
    AspNetUserId UNIQUEIDENTIFIER NULL,
    CustomerName NVARCHAR(200) NOT NULL,
    CustomerEmail NVARCHAR(200) NOT NULL,
    
    -- Transaction Details
    WhmcsTransactionId INT NOT NULL,
    WhmcsInvoiceId INT NOT NULL,
    WhmcsOrderId INT NULL,
    TransactionId VARCHAR(100) NOT NULL, -- Gateway transaction ID
    TransactionAmount DECIMAL(10,2) NOT NULL,
    TransactionDate DATETIME NOT NULL,
    
    -- Product Information
    ProductType VARCHAR(20) NOT NULL, -- 'OneOff' or 'Subscription'
    ProductName NVARCHAR(200) NOT NULL,
    WhmcsProductId INT NOT NULL,
    
    -- Dispute Information
    DisputeReason NVARCHAR(500) NOT NULL,
    DisputeReasonCode VARCHAR(50) NULL, -- Visa/MC reason code if available
    DisputeFiledDate DATETIME NOT NULL,
    DisputeAmount DECIMAL(10,2) NOT NULL,
    
    -- Status & Outcome
    DisputeStatus VARCHAR(30) NOT NULL DEFAULT 'Open', -- Open, EvidenceSubmitted, UnderReview, Won, Lost, Withdrawn
    DisputeOutcome VARCHAR(20) NULL, -- Won, Lost, Partial, Withdrawn
    OutcomeDate DATETIME NULL,
    OutcomeAmount DECIMAL(10,2) NULL, -- Amount recovered if partial
    OutcomeNotes NVARCHAR(MAX) NULL,
    
    -- Document Generation
    DefenseKitPath NVARCHAR(500) NULL,
    DefenseKitGeneratedDate DATETIME NULL,
    DefenseKitVersion INT NULL,
    
    -- Evidence Collection Status
    EvidenceCollectionStarted DATETIME NULL,
    EvidenceCollectionCompleted DATETIME NULL,
    EvidenceScore INT NULL, -- 0-100 strength score
    
    -- Audit
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    
    -- Response deadline
    ResponseDeadline DATETIME NULL,
    
    INDEX IX_DisputeCase_CaseNumber (CaseNumber),
    INDEX IX_DisputeCase_Status (DisputeStatus),
    INDEX IX_DisputeCase_CustomerEmail (CustomerEmail),
    INDEX IX_DisputeCase_TransactionId (TransactionId)
);

-- Evidence Log Table
CREATE TABLE dbo.DisputeEvidence (
    DisputeEvidenceId INT IDENTITY(1,1) PRIMARY KEY,
    DisputeCaseId INT NOT NULL,
    
    EvidenceSource VARCHAR(50) NOT NULL, -- 'WHMCS', 'FarmGenie', 'Intercom', 'SendGrid', 'Twilio', 'Zoom'
    EvidenceType VARCHAR(50) NOT NULL, -- 'LoginLog', 'Invoice', 'Email', 'Conversation', etc.
    EvidenceDescription NVARCHAR(500) NOT NULL,
    EvidenceData NVARCHAR(MAX) NULL, -- JSON blob of raw data
    EvidenceTimestamp DATETIME NULL, -- Timestamp of the evidence itself
    
    CollectedDate DATETIME DEFAULT GETDATE(),
    CollectedBy UNIQUEIDENTIFIER NULL,
    
    IsUsedInDocument BIT DEFAULT 0,
    EvidenceStrength INT NULL, -- 1-5 rating
    
    FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
);

-- Activity Log Table
CREATE TABLE dbo.DisputeActivityLog (
    DisputeActivityLogId INT IDENTITY(1,1) PRIMARY KEY,
    DisputeCaseId INT NOT NULL,
    
    ActivityType VARCHAR(50) NOT NULL, -- 'Created', 'EvidenceCollected', 'DocumentGenerated', 'Submitted', 'OutcomeLogged'
    ActivityDescription NVARCHAR(500) NOT NULL,
    ActivityData NVARCHAR(MAX) NULL, -- JSON for additional context
    
    PerformedBy UNIQUEIDENTIFIER NOT NULL,
    PerformedDate DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
);

-- Document Version Table
CREATE TABLE dbo.DisputeDocument (
    DisputeDocumentId INT IDENTITY(1,1) PRIMARY KEY,
    DisputeCaseId INT NOT NULL,
    
    DocumentType VARCHAR(50) NOT NULL, -- 'DefenseResponse', 'Evidence', 'Screenshot', 'CustomerLetter'
    DocumentName NVARCHAR(200) NOT NULL,
    DocumentPath NVARCHAR(500) NOT NULL,
    DocumentVersion INT NOT NULL,
    FileSize BIGINT NULL,
    MimeType VARCHAR(100) NULL,
    
    GeneratedBy UNIQUEIDENTIFIER NOT NULL,
    GeneratedDate DATETIME DEFAULT GETDATE(),
    
    IsSubmitted BIT DEFAULT 0,
    SubmittedDate DATETIME NULL,
    
    FOREIGN KEY (DisputeCaseId) REFERENCES dbo.DisputeCase(DisputeCaseId)
);

-- Product Template Configuration
CREATE TABLE dbo.DisputeProductTemplate (
    DisputeProductTemplateId INT IDENTITY(1,1) PRIMARY KEY,
    
    WhmcsProductId INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    ProductType VARCHAR(20) NOT NULL, -- 'OneOff' or 'Subscription'
    
    -- Evidence Collection Config (JSON)
    EvidenceConfig NVARCHAR(MAX) NOT NULL, -- JSON defining which evidence sources to query
    
    -- Template Config
    TemplatePythonScript NVARCHAR(500) NULL, -- Path to generator script
    TemplateVersion INT NOT NULL DEFAULT 1,
    
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);
```

### 3.2 Initial Product Templates

```sql
-- Seed data for product templates
INSERT INTO dbo.DisputeProductTemplate (WhmcsProductId, ProductName, ProductType, EvidenceConfig, TemplatePythonScript) VALUES
(83, 'Competition Command', 'Subscription', '{"sources":["whmcs","farmgenie","intercom","sendgrid","zoom"],"subscription":{"requirePaymentHistory":true,"requireCancellationSearch":true}}', 'generate_competition_command_response_v5.py'),
(0, 'Listing Command Pro', 'OneOff', '{"sources":["whmcs","farmgenie","intercom","sendgrid","twilio","zoom"],"oneoff":{"requireServiceDelivery":true,"requireScreenshots":true}}', 'generate_polished_response_v12.py');
```

---

## 4. SendGrid Integration

### 4.1 Current Gap

SendGrid webhooks are NOT configured. Email events are not being captured.

### 4.2 Required Integration

| Event Type | Table | Use Case |
|------------|-------|----------|
| `delivered` | EmailEventStatus | Prove email reached inbox |
| `open` | EmailEventStatus | Prove customer saw email |
| `click` | EmailEventMessageClick | Prove customer engaged |
| `bounce` | EmailEventStatus | Explain delivery failure |

### 4.3 Credential

```
API Key: [REDACTED - See Master Credential Tracker]
```

### 4.4 Evidence Collection Query (Once Integrated)

```sql
-- Query email events for a customer
SELECT 
    ees.EventType,
    ees.Email,
    ees.EventTimestamp,
    ees.MessageId,
    ees.UserAgent,
    ees.IpAddress
FROM dbo.EmailEventStatus ees
WHERE ees.Email = @CustomerEmail
    AND ees.EventTimestamp BETWEEN @OrderDate AND @DisputeDate
ORDER BY ees.EventTimestamp;
```

---

## 5. UI Wireframe Specification

### 5.1 Navigation

Add to TheGenie.ai Admin menu:

```
Admin
├── Activity Tracker
├── Credits Adjust
├── Organizations
├── Permissions
├── Invitations
├── TPP
├── Distribution Lists
├── Direct Mail Radar
└── 🆕 Dispute Admin      ← NEW
```

### 5.2 Dashboard Layout

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  DISPUTE ADMIN DASHBOARD                           [+ New Dispute] [Export]  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │   OPEN      │ │  PENDING    │ │    WON      │ │    LOST     │            │
│  │     12      │ │      5      │ │     47      │ │      3      │            │
│  │   $8,500    │ │   $3,200    │ │  $32,450    │ │   $1,800    │            │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘            │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  FILTERS: [All Status ▼] [All Products ▼] [Date Range] [Search...]    │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │ Case #        │ Customer       │ Product        │ Amount  │ Status    │ │
│  ├────────────────────────────────────────────────────────────────────────┤ │
│  │ DC-2025-00067 │ Chris Plank    │ Listing Cmd    │ $67.50  │ 🟢 WON    │ │
│  │ DC-2025-00066 │ Susan Featherly│ Competition Cmd│ $500.00 │ 🟡 OPEN   │ │
│  │ DC-2025-00065 │ John Doe       │ Paisley Plus   │ $99.00  │ 🟡 OPEN   │ │
│  │ DC-2025-00064 │ Jane Smith     │ Listing Cmd    │ $45.00  │ 🟢 WON    │ │
│  │ DC-2025-00063 │ Mike Johnson   │ Competition Cmd│ $500.00 │ 🔴 LOST   │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ◀ Previous                                           Page 1 of 5   Next ▶  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 New Dispute Form

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  CREATE NEW DISPUTE CASE                                           [Cancel] │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  STEP 1: IDENTIFY TRANSACTION                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  Payment Provider Case ID: [PP-R-NVE-599340890____________]            │ │
│  │  Transaction ID:           [0XN48732G1786400J________________]         │ │
│  │                                                        [🔍 Lookup]     │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ─── OR ───                                                                  │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  Customer Email: [susan.featherly@gmail.com_______________]            │ │
│  │  Invoice ID:     [62279_______]                                        │ │
│  │                                                        [🔍 Lookup]     │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│                                                                              │
│  STEP 2: TRANSACTION DETAILS (Auto-populated)                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  Customer Name:     Susan Featherly                                    │ │
│  │  Customer Email:    homesbypeter.susan@gmail.com                       │ │
│  │  Product:           Competition Command - Monthly Subscription         │ │
│  │  Product Type:      ● Subscription  ○ One-Off                          │ │
│  │  Transaction Date:  October 14, 2025                                   │ │
│  │  Transaction Amount: $500.00                                           │ │
│  │  Invoice ID:        62279                                              │ │
│  │  Order ID:          8923                                               │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  STEP 3: DISPUTE INFORMATION                                                │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  Dispute Reason:    [Cancelled before being billed___________▼]       │ │
│  │  Dispute Filed:     [10/24/2025______]                                 │ │
│  │  Response Deadline: [11/08/2025______]                                 │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  [Start Evidence Collection]    [Save Draft]    [Cancel]              │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 5.4 Case Detail View

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  CASE: DC-2025-00066                                    [Edit] [Close Case] │
│  Susan Featherly - Competition Command                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  STATUS: 🟡 OPEN                 EVIDENCE SCORE: 95/100               │  │
│  │  Deadline: Nov 8, 2025 (11 days remaining)                            │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌─────────────────────────────────────────┬────────────────────────────┐   │
│  │ TABS: [Summary] [Evidence] [Documents] [Activity Log]                │   │
│  ├─────────────────────────────────────────┴────────────────────────────┤   │
│  │                                                                       │   │
│  │  EVIDENCE COLLECTION STATUS                                          │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐│   │
│  │  │ ✅ WHMCS Client Details         Collected 12/28/2025 10:23 AM  ││   │
│  │  │ ✅ WHMCS Invoice 62279          Collected 12/28/2025 10:23 AM  ││   │
│  │  │ ✅ WHMCS Payment History        9 payments found               ││   │
│  │  │ ✅ FarmGenie Login Activity     6 sessions found               ││   │
│  │  │ ✅ FarmGenie Service Usage      15,750 events found            ││   │
│  │  │ ✅ Intercom Conversations       6 conversations found          ││   │
│  │  │    └─ ⭐ Cancellation request: Oct 23, 2025 (AFTER billing)    ││   │
│  │  │ ✅ Zoom Phone Calls             0 calls found                  ││   │
│  │  │ ⚠️ SendGrid Email Events       NOT CONFIGURED                 ││   │
│  │  └─────────────────────────────────────────────────────────────────┘│   │
│  │                                                                       │   │
│  │  KEY FINDING                                                         │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐│   │
│  │  │  Cancellation request was submitted 9 DAYS AFTER the           ││   │
│  │  │  disputed billing date. This directly contradicts the          ││   │
│  │  │  customer's claim of "cancelled before being billed."          ││   │
│  │  └─────────────────────────────────────────────────────────────────┘│   │
│  │                                                                       │   │
│  │  DOCUMENTS                                                           │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐│   │
│  │  │  📄 SusanFeatherly_Dispute_Response_v5.pdf    [View] [Download]││   │
│  │  │     Generated: 12/28/2025 11:45 AM                             ││   │
│  │  │     Status: Ready for Submission                               ││   │
│  │  └─────────────────────────────────────────────────────────────────┘│   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐│   │
│  │  │  [Generate New Version]    [Submit to PayPal]    [Log Outcome] ││   │
│  │  └─────────────────────────────────────────────────────────────────┘│   │
│  │                                                                       │   │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ACTIVITY LOG                                                                │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ 12/28/2025 11:45 AM │ Document v5 generated          │ Steve H.     │   │
│  │ 12/28/2025 10:30 AM │ Evidence collection completed  │ System       │   │
│  │ 12/28/2025 10:23 AM │ Evidence collection started    │ Steve H.     │   │
│  │ 12/28/2025 10:20 AM │ Case created                   │ Steve H.     │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 5.5 Log Outcome Modal

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  LOG DISPUTE OUTCOME                                               [Close]  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Case: DC-2025-00066                                                         │
│  Customer: Susan Featherly                                                   │
│  Amount: $500.00                                                             │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  Outcome:     ○ Won (Full Amount)                                      │ │
│  │               ○ Won (Partial Amount)                                   │ │
│  │               ○ Lost                                                   │ │
│  │               ○ Withdrawn by Customer                                  │ │
│  │                                                                        │ │
│  │  Outcome Date: [12/28/2025______]                                      │ │
│  │                                                                        │ │
│  │  Amount Recovered: [$500.00_______] (if partial)                       │ │
│  │                                                                        │ │
│  │  Notes:                                                                │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │ │
│  │  │ PayPal ruled in favor of merchant. Full amount restored.         │ │ │
│  │  │ Cited customer's cancellation request dated after billing.       │ │ │
│  │  └──────────────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                          [Save Outcome]    [Cancel]                   │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Implementation Phases

### Phase 1: Database & Core API (Week 1)
- [ ] Create database tables
- [ ] Build core API endpoints
- [ ] Implement evidence collection automation

### Phase 2: UI Development (Week 2)
- [ ] Dashboard view
- [ ] Case creation form
- [ ] Case detail view
- [ ] Outcome logging

### Phase 3: Integration & Testing (Week 3)
- [ ] SendGrid webhook integration
- [ ] Document generation automation
- [ ] End-to-end testing

### Phase 4: Permissions & Launch (Week 4)
- [ ] Super user permissions
- [ ] Role-based access control
- [ ] Production deployment

---

## 7. API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/disputes` | List all disputes with filtering |
| GET | `/api/disputes/{id}` | Get dispute details |
| POST | `/api/disputes` | Create new dispute case |
| PUT | `/api/disputes/{id}` | Update dispute case |
| POST | `/api/disputes/{id}/collect-evidence` | Trigger evidence collection |
| POST | `/api/disputes/{id}/generate-document` | Generate defense document |
| POST | `/api/disputes/{id}/log-outcome` | Log dispute outcome |
| GET | `/api/disputes/stats` | Get dashboard statistics |

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/28/2025 | Initial specification - Full system design |

---

*File: DISPUTE_ADMIN_SYSTEM_SPECIFICATION_v1.md*
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*


