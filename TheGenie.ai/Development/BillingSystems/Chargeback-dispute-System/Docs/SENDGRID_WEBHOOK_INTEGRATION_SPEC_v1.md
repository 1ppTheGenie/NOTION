# SendGrid Webhook Integration Specification

**Version:** 1.0  
**Created:** 12/29/2025  
**Last Updated:** 12/29/2025  
**Author:** Cursor Opus Agent  
**Status:** 🟡 READY FOR IMPLEMENTATION

---

## Executive Summary

**DISCOVERY:** The SendGrid webhook infrastructure **ALREADY EXISTS** in the codebase but is **NOT ACTIVE**.

### What Already Exists (Built but Not Connected)

| Component | Status | Location |
|-----------|--------|----------|
| `EmailEventStatus` table | ✅ EXISTS | FarmGenie.dbo.EmailEventStatus |
| `EmailEventMessageClick` table | ✅ EXISTS | FarmGenie.dbo.EmailEventMessageClick |
| `EmailEventMessageBounce` table | ✅ EXISTS | FarmGenie.dbo.EmailEventMessageBounce |
| `EmailEventMessageSpam` table | ✅ EXISTS | FarmGenie.dbo.EmailEventMessageSpam |
| `EmailEventMessageUnsubscribe` table | ✅ EXISTS | FarmGenie.dbo.EmailEventMessageUnsubscribe |
| `EmailLog` table | ✅ EXISTS | FarmGenie.dbo.EmailLog |
| `EmailWebhookService` | ✅ EXISTS | Smart.Notification.Core.Business |
| `EventWriterFactory` | ✅ EXISTS | Handles 8+ event types |
| SendGrid API Key | ✅ EXISTS | appsettings.json |

### What's Broken/Missing

| Issue | Problem | Fix Required |
|-------|---------|--------------|
| **Wrong HTTP Method** | Endpoint uses `[HttpGet]` | Change to `[HttpPost]` |
| **SendGrid Not Configured** | No webhook URL set in SendGrid | Configure in SendGrid Dashboard |
| **Open Tracking Disabled** | Open events require pixel tracking enabled | Enable in SendGrid settings |
| **Click Tracking Disabled** | Click events require link tracking enabled | Enable in SendGrid settings |

---

## Current Code Analysis

### Webhook Endpoint (NEEDS FIX)

**File:** `Smart.Api.Notification/Controllers/EmailController.cs`

```csharp
// CURRENT (BROKEN) - Uses HttpGet but SendGrid sends POST
[AllowAnonymous]
[HttpGet("eventwebhook")]  // ❌ WRONG - Should be HttpPost
public IActionResult EventWebhook()
{
    _webhookService.ProcessEvents(Request.Body);
    return Ok("Events Processed");
}
```

**FIX REQUIRED:**

```csharp
// FIXED - Use HttpPost for SendGrid webhooks
[AllowAnonymous]
[HttpPost("eventwebhook")]  // ✅ CORRECT
public IActionResult EventWebhook()
{
    _webhookService.ProcessEvents(Request.Body);
    return Ok("Events Processed");
}
```

### EmailWebhookService (Already Working)

**File:** `Smart.Notification.Core/Business/EmailWebhookService.cs`

The service is **fully implemented** and uses the StrongGrid library to parse SendGrid webhook events:

- Parses incoming webhook JSON
- Routes events to appropriate EventWriter classes
- Saves events to database tables

### EventWriterFactory (Already Working)

**File:** `Smart.Notification.Core/Business/EventWriter/EventWriterFactory.cs`

Handles these SendGrid event types:

| Event Type | Handler Class | Database Table |
|------------|---------------|----------------|
| `open` | EventWriterStatus | EmailEventStatus |
| `delivered` | EventWriterStatus | EmailEventStatus |
| `dropped` | EventWriterStatus | EmailEventStatus |
| `processed` | EventWriterStatus | EmailEventStatus |
| `click` | EventWriterClick | EmailEventMessageClick |
| `bounce` | EventWriterBounce | EmailEventMessageBounce |
| `spamreport` | EventWriterSpam | EmailEventMessageSpam |
| `unsubscribe` | EventWriterUnsubscribe | EmailEventMessageUnsubscribe |
| `deferred` | EventWriterDeferred | EmailEventStatus |

---

## Implementation Steps

### Step 1: Fix the HTTP Method (CODE CHANGE)

**Single line change in EmailController.cs:**

Change line 42:
```csharp
[HttpGet("eventwebhook")]  // Change to [HttpPost("eventwebhook")]
```

**Deployment:** This is a 1-line code change to `Smart.Api.Notification`

### Step 2: Configure SendGrid Dashboard

1. Log in to [SendGrid Dashboard](https://app.sendgrid.com)
2. Navigate to **Settings → Mail Settings → Event Webhook**
3. Enable the webhook
4. Enter HTTP POST URL: `https://notification-api.thegenie.ai/email/eventwebhook`
5. Select events to track:
   - ✅ Processed
   - ✅ Dropped
   - ✅ Delivered
   - ✅ Deferred
   - ✅ Bounce
   - ✅ Open
   - ✅ Click
   - ✅ Spam Report
   - ✅ Unsubscribe

### Step 3: Enable Tracking Features

In SendGrid Dashboard → Settings → Tracking:

1. **Click Tracking** → Enable
2. **Open Tracking** → Enable
3. **Subscription Tracking** → Enable (optional)

### Step 4: Verify Data Flow

After configuration, send a test email and verify:

```sql
-- Check EmailEventStatus for delivery/open events
SELECT TOP 10 * FROM FarmGenie.dbo.EmailEventStatus 
ORDER BY CreateDate DESC;

-- Check EmailEventMessageClick for click events
SELECT TOP 10 * FROM FarmGenie.dbo.EmailEventMessageClick 
ORDER BY CreateDate DESC;
```

---

## Webhook URL

The Notification API is deployed at:

| Environment | URL |
|-------------|-----|
| **Production** | https://notification-api.thegenie.ai/email/eventwebhook |
| **Staging** | https://notification-api-stage.thegenie.ai/email/eventwebhook |

---

## Database Schema (Already Exists)

### EmailEventStatus

```sql
CREATE TABLE EmailEventStatus (
    EmailEventStatusId BIGINT IDENTITY PRIMARY KEY,
    EventType INT NOT NULL,          -- 1=Processed, 2=Dropped, 3=Delivered, 4=Deferred, 5=Open
    EmailAddress VARCHAR(250),
    ExternalEventId VARCHAR(250),    -- SendGrid event ID
    ExternalMessageId VARCHAR(250),  -- SendGrid message ID (sg_message_id)
    Attempt INT,
    CreateDate DATETIME
);
```

### EmailEventMessageClick

```sql
CREATE TABLE EmailEventMessageClick (
    EmailEventMessageClickId INT IDENTITY PRIMARY KEY,
    EmailAddress VARCHAR(250),
    ExternalEventId VARCHAR(250),
    ExternalMessageId VARCHAR(250),
    Url VARCHAR(500),                -- The link that was clicked
    CreateDate DATETIME
);
```

### EmailEventMessageBounce

```sql
CREATE TABLE EmailEventMessageBounce (
    EmailEventMessageBounceId INT IDENTITY PRIMARY KEY,
    EmailAddress VARCHAR(250),
    ExternalEventId VARCHAR(250),
    ExternalMessageId VARCHAR(250),
    Type VARCHAR(150),               -- hard/soft
    Status VARCHAR(150),
    Reason VARCHAR(250),
    CreateDate DATETIME
);
```

---

## Impact on Dispute Evidence

Once activated, we can prove:

| Evidence | Query | Dispute Value |
|----------|-------|---------------|
| Email Delivered | `SELECT * FROM EmailEventStatus WHERE EventType=3 AND EmailAddress='customer@email.com'` | ⭐⭐⭐⭐ Proves delivery |
| Email Opened | `SELECT * FROM EmailEventStatus WHERE EventType=5 AND EmailAddress='customer@email.com'` | ⭐⭐⭐⭐⭐ Proves awareness |
| Link Clicked | `SELECT * FROM EmailEventMessageClick WHERE EmailAddress='customer@email.com'` | ⭐⭐⭐⭐⭐ Proves engagement |
| Email Bounced | `SELECT * FROM EmailEventMessageBounce WHERE EmailAddress='customer@email.com'` | ⭐⭐ Explains non-delivery |

---

## Extended Vision: Transactional Email Catalog

### Goal

Track EVERY transactional email the system sends:

- Order confirmations
- Billing receipts
- Service delivery notifications
- Password resets
- Chargeback notifications
- Credit card decline alerts
- Subscription renewal reminders

### Proposed Enhancement: EmailTemplate Table

```sql
CREATE TABLE EmailTemplate (
    EmailTemplateId INT IDENTITY PRIMARY KEY,
    TemplateName VARCHAR(100),           -- e.g., "ORDER_CONFIRMATION"
    SendGridTemplateId VARCHAR(50),      -- SendGrid template ID
    Category VARCHAR(50),                -- BILLING, SERVICE, ACCOUNT, ALERT
    Description VARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreateDate DATETIME DEFAULT GETDATE()
);

-- Sample data
INSERT INTO EmailTemplate VALUES
('ORDER_CONFIRMATION', 'd-abc123', 'BILLING', 'Sent after purchase', 1, GETDATE()),
('LISTING_COMMAND_RECAP', 'd-def456', 'SERVICE', 'Campaign completion summary', 1, GETDATE()),
('PAYMENT_DECLINED', 'd-ghi789', 'ALERT', 'Credit card decline notification', 1, GETDATE()),
('CHARGEBACK_RECEIVED', 'd-jkl012', 'ALERT', 'Dispute filed notification', 1, GETDATE());
```

### Proposed Enhancement: EmailLog Extensions

The existing `EmailLog` table should be enhanced to track:

```sql
ALTER TABLE EmailLog ADD
    EmailTemplateId INT NULL,
    AspNetUserId NVARCHAR(128) NULL,
    WhmcsClientId INT NULL,
    Category VARCHAR(50) NULL,
    Subject VARCHAR(500) NULL;
```

---

## Credentials Reference

### SendGrid API Key

```
[REDACTED - See Master Credential Tracker or Smart.Api.Notification/appsettings.json]
```

Location: `Smart.Api.Notification/appsettings.json`

### SendGrid Dashboard Access

URL: https://app.sendgrid.com  
(Credentials in Master Credential Tracker)

---

## Priority & Effort

| Task | Priority | Effort | Owner |
|------|----------|--------|-------|
| Fix HttpGet → HttpPost | 🔴 HIGH | 5 min | Dev |
| Deploy Smart.Api.Notification | 🔴 HIGH | 15 min | Ankit |
| Configure SendGrid Webhook | 🔴 HIGH | 10 min | Steve |
| Enable Click/Open Tracking | 🟡 MEDIUM | 5 min | Steve |
| Verify Data Flow | 🟡 MEDIUM | 10 min | Steve |
| Update Dispute Evidence Queries | 🟢 LOW | 30 min | Future |

**Total Estimated Time:** ~1 hour to fully activate

---

## Feature Runway Integration

This resolves **Billing System Feature #8** from Project Universe Dashboard:

> "SendGrid email tracking integration for dispute evidence"

Once active:
- Dispute Admin UI can show email timeline
- Evidence workflow will include email opens/clicks
- Email health dashboard can show bounce rates

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/29/2025 | Initial specification - discovered existing infrastructure |

---

*File: SENDGRID_WEBHOOK_INTEGRATION_SPEC_v1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*

