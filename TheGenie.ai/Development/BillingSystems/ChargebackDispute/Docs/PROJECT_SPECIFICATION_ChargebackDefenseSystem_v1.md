# Chargeback Defense System - Project Specification

**Version:** 1.0  
**Created:** 12/27/2025  
**Last Updated:** 12/27/2025  
**Author:** Cursor Opus Agent  
**Status:** Development

---

## Executive Summary

The Chargeback Defense System is a billing module within TheGenie.ai platform that automates the creation of dispute response documentation when payment chargebacks are filed against 1ParkPlace, Inc. The system gathers transaction data, customer activity logs, and evidence from multiple integrated systems to generate professional, bank-perfect dispute response documents.

---

## 1. System Overview

### 1.1 Purpose
Automate chargeback defense workflows to:
- Reduce manual effort in gathering evidence
- Ensure consistent, high-quality dispute responses
- Increase win rate on chargeback disputes
- Maintain comprehensive audit trail

### 1.2 Integration Points

| System | Purpose | Data Retrieved |
|--------|---------|----------------|
| **WHMCS** | Billing/Invoicing | Orders, Invoices, Transactions, Client Info |
| **FarmGenie DB** | Platform Activity | Login logs, Campaign data, SMS delivery |
| **Intercom** | Support Tickets | Customer contact attempts |
| **SendGrid** | Email Delivery | Email open/click tracking (NEEDS INTEGRATION) |
| **Twilio** | SMS Delivery | SMS delivery confirmations |
| **PayPal** | Payment Processing | Transaction IDs, Dispute notifications |
| **Genie Cloud** | Asset Storage | Property images, Landing pages |

---

## 2. User Interface Workflow

### 2.1 Dispute Processing Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                    CHARGEBACK DEFENSE UI                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: SELECT CUSTOMER                                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Search: [___________________________] [🔍 Find]          │    │
│  │ Customer: Chris Plank (cp@pacificapg.com)               │    │
│  │ ASP User ID: f5174e53-8f6e-4d23-9eab-f8d6802b39c9      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  STEP 2: SELECT TRANSACTION (Auto-populated from WHMCS)          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ○ 12/05/2025 | $67.50 | Listing Command | Order #9270  │    │
│  │ ○ 11/15/2025 | $49.00 | Paisley Plus   | Order #9180  │    │
│  │ ○ 10/20/2025 | $29.00 | Competition Cmd| Order #9050  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  STEP 3: DISPUTE DETAILS (User Input Required)                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Dispute Filed Date*: [12/19/2025]                       │    │
│  │ PayPal Case ID*: [PP-D-607760615]                       │    │
│  │ Dispute Reason: [Unauthorized Transaction ▼]            │    │
│  │ Response Deadline: [01/03/2026]                         │    │
│  │ Additional Notes: [_____________________________]       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  STEP 4: EVIDENCE COLLECTION (Auto-generated)                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ✅ Transaction Data (WHMCS)                             │    │
│  │ ✅ Login/Browser History (FarmGenie)                    │    │
│  │ ✅ Campaign Delivery (NotificationQueue)                │    │
│  │ ✅ Email Confirmations (SendGrid - LIMITED)             │    │
│  │ ⚠️ Support Contact (Intercom - No records found)       │    │
│  │ ✅ Terms Acceptance (Checkbox timestamp)                │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  [Generate Defense Document]  [Preview]  [Cancel]                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 2.2 Required User Inputs (Variables Not in System)

| Field | Description | Source |
|-------|-------------|--------|
| `dispute_filed_date` | Date PayPal notified of chargeback | PayPal Resolution Center |
| `paypal_case_id` | PayPal dispute case identifier | PayPal Resolution Center |
| `response_deadline` | Deadline to submit response | PayPal Resolution Center |
| `dispute_reason` | Reason code from card network | PayPal Resolution Center |
| `additional_notes` | Internal notes for case | User input |

### 2.3 Auto-Retrieved Data (From System)

| Data Point | Source | Method |
|------------|--------|--------|
| Customer Name/Email | WHMCS API | `GetClientsDetails` |
| Transaction Amount | WHMCS API | `GetTransactions` |
| Order Date/Time | WHMCS API | `GetOrders` |
| Invoice Details | WHMCS API | `GetInvoice` |
| Login History | FarmGenie.dbo.BrowserUsage | SQL Query |
| Browser/Device Info | FarmGenie.dbo.BrowserUsage | SQL Query |
| IP Address | FarmGenie.dbo.BrowserUsage | SQL Query |
| SMS Campaign Stats | FarmGenie.dbo.NotificationQueue | SQL Query |
| Property Details | FarmGenie.dbo.ListingCommandQueue | SQL Query |
| Lead Count | FarmGenie.dbo.GenieLead | SQL Query |
| Support Contact | Intercom API | Conversation search |
| Email Delivery | SendGrid (FUTURE) | Webhook events |

---

## 3. Product-Specific Templates

### 3.1 Template Variations Required

The system must generate different response documents based on product type:

| Product | Type | Template Differences |
|---------|------|---------------------|
| **Listing Command** | One-time Purchase | Focus on: SMS delivery, leads generated, property data, campaign stats |
| **Paisley Plus** | Subscription | Focus on: Recurring billing consent, usage logs, login frequency, content accessed |
| **Neighborhood Command** | Subscription | Focus on: Data access logs, reports generated, market analysis usage |
| **Competition Command** | Subscription | Focus on: Agent tracking usage, alerts received, feature utilization |

### 3.2 Discovery Items for Template Variations

**DISCOVERY NEEDED:**
1. What specific activity logs exist for each subscription product?
2. What tables track Paisley Plus usage?
3. What tables track Neighborhood Command usage?
4. What tables track Competition Command usage?
5. Are there specific cancellation flows for subscriptions?
6. What is the subscription billing cycle (monthly/annual)?
7. How are subscription renewals processed and logged?
8. What notification emails are sent for subscription renewals?

### 3.3 Common Template Elements (All Products)

- Executive Summary (bullet-point format)
- Transaction Details Reference Table
- Terms of Service acceptance proof
- Login/Authentication evidence
- No merchant contact verification
- Refund policy excerpt

### 3.4 Product-Specific Template Elements

**Listing Command (One-Time):**
- Property listing details (address, MLS, price)
- SMS campaign statistics (sent, delivered, failed)
- Leads generated count and timeline
- Landing page screenshot
- Customer search parameters

**Paisley Plus (Subscription):**
- Subscription start date
- Number of renewal cycles completed
- Login frequency since subscription
- Content/features accessed
- Cancellation policy reminder

**Subscription Products (General):**
- Recurring billing authorization
- Previous successful charges
- Usage metrics for billing period
- Cancellation vs. chargeback distinction

---

## 4. Database Schema Requirements

### 4.1 New Tables Needed

```sql
-- Chargeback Cases Table
CREATE TABLE dbo.ChargebackCase (
    ChargebackCaseId INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId UNIQUEIDENTIFIER NOT NULL,
    WhmcsClientId INT NOT NULL,
    WhmcsOrderId INT NULL,
    WhmcsInvoiceId INT NULL,
    WhmcsTransactionId INT NULL,
    PayPalCaseId VARCHAR(50) NOT NULL,
    PayPalTransactionId VARCHAR(50) NULL,
    DisputeAmount DECIMAL(10,2) NOT NULL,
    DisputeReason VARCHAR(100) NOT NULL,
    DisputeFiledDate DATETIME NOT NULL,
    ResponseDeadline DATETIME NOT NULL,
    ProductType VARCHAR(50) NOT NULL,  -- 'ListingCommand', 'PaisleyPlus', etc.
    CaseStatus VARCHAR(20) DEFAULT 'Pending',  -- Pending, Submitted, Won, Lost
    ResponseGeneratedDate DATETIME NULL,
    ResponseSubmittedDate DATETIME NULL,
    ResolutionDate DATETIME NULL,
    ResolutionOutcome VARCHAR(20) NULL,  -- Won, Lost, Withdrawn
    InternalNotes NVARCHAR(MAX) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy UNIQUEIDENTIFIER NULL
);

-- Chargeback Evidence Table
CREATE TABLE dbo.ChargebackEvidence (
    ChargebackEvidenceId INT IDENTITY(1,1) PRIMARY KEY,
    ChargebackCaseId INT FOREIGN KEY REFERENCES dbo.ChargebackCase(ChargebackCaseId),
    EvidenceType VARCHAR(50) NOT NULL,  -- 'Transaction', 'Login', 'SMS', 'Email', 'Support', 'Screenshot'
    EvidenceDescription NVARCHAR(500) NULL,
    EvidenceData NVARCHAR(MAX) NULL,  -- JSON data
    EvidenceUrl VARCHAR(500) NULL,  -- For screenshots/files
    CapturedDate DATETIME DEFAULT GETDATE(),
    IsIncludedInResponse BIT DEFAULT 1
);

-- Chargeback Response Documents Table
CREATE TABLE dbo.ChargebackDocument (
    ChargebackDocumentId INT IDENTITY(1,1) PRIMARY KEY,
    ChargebackCaseId INT FOREIGN KEY REFERENCES dbo.ChargebackCase(ChargebackCaseId),
    DocumentVersion INT NOT NULL,
    DocumentType VARCHAR(20) NOT NULL,  -- 'PDF', 'DOCX'
    DocumentPath VARCHAR(500) NOT NULL,
    DocumentUrl VARCHAR(500) NULL,
    GeneratedDate DATETIME DEFAULT GETDATE(),
    GeneratedBy UNIQUEIDENTIFIER NULL,
    FileSize INT NULL,
    PageCount INT NULL
);

-- Chargeback Activity Log
CREATE TABLE dbo.ChargebackActivityLog (
    ActivityLogId INT IDENTITY(1,1) PRIMARY KEY,
    ChargebackCaseId INT FOREIGN KEY REFERENCES dbo.ChargebackCase(ChargebackCaseId),
    ActivityType VARCHAR(50) NOT NULL,
    ActivityDescription NVARCHAR(500) NOT NULL,
    PerformedBy UNIQUEIDENTIFIER NULL,
    PerformedDate DATETIME DEFAULT GETDATE(),
    Metadata NVARCHAR(MAX) NULL  -- JSON for additional data
);
```

### 4.2 Views for Evidence Collection

```sql
-- View for quick evidence collection per case
CREATE VIEW vw_ChargebackEvidenceSummary AS
SELECT 
    cc.ChargebackCaseId,
    cc.PayPalCaseId,
    cc.AspNetUserId,
    -- Transaction Evidence
    (SELECT COUNT(*) FROM WhmcsTransactions WHERE ClientId = cc.WhmcsClientId) as TransactionCount,
    -- Login Evidence
    (SELECT COUNT(*) FROM BrowserUsage WHERE UserId = cc.AspNetUserId) as LoginCount,
    -- SMS Evidence (for Listing Command)
    (SELECT COUNT(*) FROM NotificationQueue nq 
     INNER JOIN ListingCommandQueue lcq ON nq.ListingCommandQueueId = lcq.Id
     WHERE lcq.AspNetUserId = cc.AspNetUserId) as SmsCount,
    -- Lead Evidence
    (SELECT COUNT(*) FROM GenieLead gl WHERE gl.AspNetUserId = cc.AspNetUserId) as LeadCount
FROM dbo.ChargebackCase cc;
```

---

## 5. API Endpoints (Future)

### 5.1 Chargeback API Routes

```
POST   /api/chargeback/cases                 - Create new case
GET    /api/chargeback/cases                 - List all cases
GET    /api/chargeback/cases/{id}            - Get case details
PUT    /api/chargeback/cases/{id}            - Update case
DELETE /api/chargeback/cases/{id}            - Delete case

POST   /api/chargeback/cases/{id}/evidence   - Add evidence
GET    /api/chargeback/cases/{id}/evidence   - Get all evidence

POST   /api/chargeback/cases/{id}/generate   - Generate response document
GET    /api/chargeback/cases/{id}/documents  - List documents

GET    /api/chargeback/customers/{email}     - Search customer
GET    /api/chargeback/transactions/{clientId} - Get transactions
```

### 5.2 Webhook Endpoints (Future)

```
POST   /api/webhooks/paypal/dispute          - Receive PayPal dispute notification
POST   /api/webhooks/stripe/dispute          - Receive Stripe dispute notification
```

---

## 6. Role-Based Access Control

### 6.1 Service Roles

| Role | Permissions |
|------|-------------|
| **Billing Admin** | Full access - create, edit, delete cases, generate documents |
| **Billing Agent** | Create cases, add evidence, generate documents |
| **Billing Viewer** | View cases and documents only |
| **System** | Automated evidence collection, webhook processing |

### 6.2 Integration with TheGenie.ai Roles

The Chargeback Defense System should integrate with the existing role-based service architecture in TheGenie.ai. This follows the pattern established by other billing services.

---

## 7. Files and Locations

### 7.1 Current Project Files

| File | Purpose |
|------|---------|
| `generate_polished_response_v7.py` | Current document generator (Gold Standard) |
| `generate_polished_response_v6.py` | Previous version with order review screenshot |
| `generate_polished_response_v5.py` | Version with branding updates |
| `collect_evidence_enhanced.py` | Evidence collection script |
| `verify_whmcs_transaction.py` | WHMCS API verification script |
| `verify_all_dates_v1.py` | Date verification across systems |

### 7.2 Output Directory Structure

```
DefenseKits/
└── DefenseKit_{PayPalCaseId}_{Timestamp}/
    ├── ChrisPlank_Dispute_Response_v7.pdf
    ├── order_review_screenshot.png
    ├── landing_page_screenshot.png
    ├── email_confirmation_screenshot.png
    ├── email_recap_screenshot.png
    ├── workflow_timeline.png
    └── evidence/
        ├── transaction_data.json
        ├── browser_usage.json
        ├── sms_campaign.json
        └── intercom_search.json
```

### 7.3 Template Location (Future)

```
Templates/
├── ListingCommand/
│   └── dispute_response_template.py
├── PaisleyPlus/
│   └── dispute_response_template.py
├── NeighborhoodCommand/
│   └── dispute_response_template.py
├── CompetitionCommand/
│   └── dispute_response_template.py
└── Common/
    ├── header_template.py
    ├── footer_template.py
    ├── terms_excerpt.py
    └── evidence_section.py
```

---

## 8. Known Gaps & Integration Issues

### 8.1 SendGrid Integration Gap

**Status:** 🔴 CRITICAL  
**Issue:** SendGrid webhook events are NOT being captured in database  
**Impact:** Cannot prove email opens/clicks  
**Documentation:** `INTEGRATION_GAP_SendGrid_v1.md`

### 8.2 PayFlow Statement Descriptor

**Status:** 🟡 NEEDS INVESTIGATION  
**Issue:** Unknown if "1ParkPlace" appears on customer statements  
**Impact:** May cause confusion leading to chargebacks  
**Action:** Need to access WHMCS → Payment Gateways → PayFlow settings

### 8.3 Intercom API Access

**Status:** ✅ VERIFIED  
**Documentation:** `DISCOVERY_Intercom_Verified_v2.md`

### 8.4 WHMCS API Access

**Status:** ✅ VERIFIED  
**Documentation:** `DISCOVERY_WHMCS_Verified_v2.md`

---

## 9. Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Dispute Win Rate | >85% | TBD (first case pending) |
| Document Generation Time | <5 minutes | ~30 seconds |
| Evidence Collection | 100% automated | ~90% (some manual inputs) |
| Template Coverage | All products | Listing Command only |

---

## 10. Roadmap

### Phase 1: MVP (CURRENT) ✅
- [x] Manual evidence collection scripts
- [x] PDF document generation (v7 - Gold Standard)
- [x] Listing Command template
- [x] WHMCS integration
- [x] FarmGenie database queries

### Phase 2: UI Development
- [ ] React-based case management UI
- [ ] Customer/transaction lookup
- [ ] Evidence preview panel
- [ ] Document generation trigger

### Phase 3: Template Expansion
- [ ] Paisley Plus template
- [ ] Neighborhood Command template
- [ ] Competition Command template
- [ ] Common component library

### Phase 4: Automation
- [ ] PayPal webhook integration
- [ ] Auto-case creation on dispute
- [ ] SendGrid event capture
- [ ] Scheduled evidence collection

### Phase 5: Analytics & Optimization
- [ ] Win/loss tracking
- [ ] Pattern analysis
- [ ] Template optimization
- [ ] Predictive dispute detection

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/27/2025 | Cursor Opus | Initial specification document |

---

*This document is part of the Chargeback Defense System project within TheGenie.ai Development ecosystem.*

