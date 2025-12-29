# Master Evidence Collection Workflow

**Version:** 1.0  
**Created:** 12/28/2025  
**Last Updated:** 12/28/2025  
**Author:** Cursor Opus Agent  
**Status:** PRODUCTION READY

---

## Purpose

This document defines the **complete evidence collection workflow** for all chargeback disputes. It ensures NO evidence source is missed and provides conditional logic for One-Off vs Subscription product types.

---

## 1. Master Evidence Checklist

### ALL DISPUTES - Required Evidence Sources

| # | Source | Data Points | Importance | Status |
|---|--------|-------------|------------|--------|
| 1 | **WHMCS Client** | Name, email, phone, registration date, client ID | ✅ REQUIRED | ✅ ACTIVE |
| 2 | **WHMCS Invoice** | Invoice ID, line items, status, dates | ✅ REQUIRED | ✅ ACTIVE |
| 3 | **WHMCS Order** | Order ID, product, notes, extras (e.g., ZIP code) | ✅ REQUIRED | ✅ ACTIVE |
| 4 | **WHMCS Transaction** | Transaction ID, gateway, amount, timestamp | ✅ REQUIRED | ✅ ACTIVE |
| 5 | **FarmGenie User** | AspNetUserId, email, creation date | ✅ REQUIRED | ✅ ACTIVE |
| 6 | **FarmGenie Login** | Login timestamps, IP, browser, device, OS | ⭐ CRITICAL | ✅ ACTIVE |
| 7 | **Intercom Conversations** | Support tickets, messages, timestamps | ⭐ CRITICAL | ✅ ACTIVE |
| 8 | **Zoom Phone Calls** | Call logs to/from customer phone | ✅ REQUIRED | ✅ ACTIVE |
| 9 | **SendGrid Delivery** | Email delivered events | ⭐ CRITICAL | 🔴 GAP |
| 10 | **SendGrid Opens** | Email open events with timestamp | ⭐ CRITICAL | 🔴 GAP |
| 11 | **SendGrid Clicks** | Link click events | ⭐ CRITICAL | 🔴 GAP |

---

## 2. Product-Specific Evidence

### ONE-OFF PRODUCTS (Listing Command, Optimization, Postcards)

| Evidence | Description | Query Location |
|----------|-------------|----------------|
| **Service Delivery Proof** | Campaign execution, SMS sent, leads generated | FarmGenie.dbo.ListingCommandQueue, SmsReportSendQueue |
| **Property/Campaign Details** | MLS, address, target count | Order notes, campaign records |
| **Screenshots** | Landing page, property image | Genie Cloud storage |
| **Twilio SMS Delivery** | SMS delivery confirmations | FarmGenie.dbo.SmsReportSendQueue |
| **Confirmation Email** | Order confirmation sent | SendGrid events |
| **Recap Email** | Service completion email | SendGrid events |

### SUBSCRIPTION PRODUCTS (Competition Command, Paisley Plus, Neighborhood Command)

| Evidence | Description | Query Location |
|----------|-------------|----------------|
| **Payment History** | All historical payments | WHMCS GetTransactions |
| **Total Payments Count** | Number of successful payments | WHMCS GetTransactions |
| **Cancellation Request** | Any cancellation message | Intercom conversations |
| **Cancellation Timeline** | Date comparison: payment vs cancellation | Intercom timestamp vs invoice date |
| **Ongoing Service Usage** | Activity AFTER disputed billing | FarmGenie activity tables |
| **Subscription Start Date** | First payment date | WHMCS payment history |
| **Billing Cycle** | Monthly/Annual | WHMCS product details |

---

## 3. Evidence Collection Order

### Phase 1: Transaction Verification (WHMCS)

```
1.1 GetClientsDetails(clientid)
    → Customer name, email, phone, registration date

1.2 GetInvoice(invoiceid)
    → Invoice details, line items, dates

1.3 GetOrders(invoiceid)
    → Order ID, product name, notes, extras

1.4 GetTransactions(clientid)
    → All payment history
```

### Phase 2: Customer Identity (FarmGenie)

```
2.1 Query AspNetUserProfiles
    → Find AspNetUserId by name or email

2.2 Query UserWhmcs
    → Link FarmGenie user to WHMCS client

2.3 Query BrowserUsage
    → Login sessions, IP, browser, device
```

### Phase 3: Service Delivery (Product-Specific)

**For Listing Command:**
```
3.1 Query ListingCommandQueue
    → Campaign status, MLS, property

3.2 Query SmsReportSendQueue
    → SMS sent count, delivery status

3.3 Query FarmCastLog (if applicable)
    → Engagement data, leads
```

**For Competition Command:**
```
3.1 Query FarmCast (Type=1)
    → Active configurations for user

3.2 Query FarmCastLog
    → Tracking execution events

3.3 Query ActivityTracker
    → Platform usage after billing
```

### Phase 4: Communications

```
4.1 Intercom Search
    → All conversations for customer email
    → Look for cancellation keywords
    → Extract timestamps

4.2 Zoom Phone Search
    → Call logs to/from customer number
    → Document zero calls if applicable
```

### Phase 5: Email Verification (SendGrid) 🔴 GAP

```
5.1 Query EmailEventStatus
    → Delivery events for customer email

5.2 Query opens/clicks
    → Customer engagement proof

⚠️ NOTE: SendGrid webhooks NOT configured
   Tables exist but are empty
   See: INTEGRATION_GAP_SendGrid_v1.md
```

---

## 4. Credential Reference

All credentials from Master Credential Tracker (v5):

### WHMCS API

```python
WHMCS_URL = 'https://accounts.1parkplace.com/includes/api.php'
WHMCS_IDENTIFIER = '[REDACTED - See Master Credential Tracker]'
WHMCS_SECRET = '[REDACTED - See Master Credential Tracker]'
WHMCS_ACCESS_KEY = '1ppINSAyay$'
```

### FarmGenie Database

```
Server: 192.168.29.45,1433
Database: FarmGenie
User (Read): cursor / 1ppINSAyay$
User (Write): sa / neo222
```

### Intercom

```python
INTERCOM_TOKEN = '[REDACTED - See Master Credential Tracker]'
INTERCOM_BASE_URL = 'https://api.intercom.io'
```

### SendGrid

```python
SENDGRID_API_KEY = '[REDACTED - See Master Credential Tracker]'
```

### Twilio

```
Account SID: [REDACTED - See Master Credential Tracker]
Auth Token: [REDACTED - See Master Credential Tracker]
From Phone: +16193043643
```

### Zoom Phone

```
See Zoom API credentials in application config
```

---

## 5. Evidence Scoring

Each dispute receives an Evidence Score (0-100):

| Category | Max Points | Criteria |
|----------|------------|----------|
| Transaction Verified | 15 | WHMCS data complete |
| Login Activity Found | 15 | At least 1 login near transaction |
| Service Delivered | 20 | Product-specific delivery proof |
| Email Verification | 15 | SendGrid open/click (if available) |
| Support History | 15 | Intercom/Zoom records retrieved |
| Timeline Logic | 20 | Evidence contradicts claim |

**Score Interpretation:**
- **90-100**: Very strong case
- **80-89**: Strong case
- **70-79**: Good case
- **60-69**: Moderate case
- **Below 60**: Weak case, may need additional evidence

---

## 6. Output Requirements

### Defense Kit Contents

1. **PDF Response Document**
   - Executive Summary (5-6 bullets max)
   - Transaction Details
   - Evidence Sections
   - Timeline
   - Terms Reference
   - Merchant Request

2. **Screenshots** (if applicable)
   - Landing page
   - Order confirmation
   - Email delivery proof

3. **Activity Log**
   - Evidence collection timestamps
   - Sources queried
   - Data retrieved

---

## 7. Workflow Diagram

```
                    ┌─────────────────────┐
                    │   DISPUTE RECEIVED  │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  IDENTIFY PRODUCT   │
                    │      TYPE           │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                                 │
     ┌────────▼────────┐             ┌─────────▼────────┐
     │    ONE-OFF      │             │   SUBSCRIPTION   │
     │ (Listing Cmd)   │             │ (Competition Cmd)│
     └────────┬────────┘             └─────────┬────────┘
              │                                 │
     ┌────────▼────────┐             ┌─────────▼────────┐
     │ Collect Evidence│             │ Collect Evidence │
     │ - Transaction   │             │ - Transaction    │
     │ - Login/IP      │             │ - Payment History│
     │ - Service Del.  │             │ - Cancellation   │
     │ - SMS Proof     │             │ - Ongoing Usage  │
     │ - Screenshots   │             │ - Login Activity │
     │ - Emails        │             │ - Emails         │
     │ - Support       │             │ - Support        │
     └────────┬────────┘             └─────────┬────────┘
              │                                 │
              └────────────────┬────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  SENDGRID CHECK     │
                    │  (Gap - Document)   │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │ CALCULATE EVIDENCE  │
                    │      SCORE          │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │ GENERATE DEFENSE    │
                    │     DOCUMENT        │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  SUBMIT & TRACK     │
                    │    OUTCOME          │
                    └─────────────────────┘
```

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/28/2025 | Initial workflow document |

---

*File: MASTER_EVIDENCE_WORKFLOW_v1.md*
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*



