# PayPal Webhook Deployment Guide
## TheGenie.ai Billing System - Bidirectional PayFlow Integration

**Version:** 2.0  
**Created:** 12/28/2025  
**Last Updated:** 12/28/2025  
**Author:** Cursor Opus Agent  
**Status:** ✅ SANDBOX VERIFIED

---

## 📋 Summary

This document provides complete deployment instructions for the PayPal webhook endpoint that enables bidirectional communication between TheGenie.ai and PayPal/PayFlow for:
- Chargeback/dispute notifications
- Payment events (refunds, captures)
- Subscription events
- Invoice events

---

## ✅ Sandbox Verification (12/28/2025)

| Test | Endpoint | Status |
|------|----------|--------|
| Health Check (GET) | `http://localhost:38949/api/paypal/webhook` | ✅ PASS |
| Webhook POST | `http://localhost:38949/api/paypal/webhook` | ✅ PASS |

**Response from Health Check:**
```json
{"status":"active","service":"TheGenie.ai PayPal Webhook","version":"1.0"}
```

---

## 📁 Code Files Created

### Location: `C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\`

| File | Path | Purpose |
|------|------|---------|
| **PayPalWebhooksController.cs** | `Smart.Dashboard\Controllers\` | API endpoint controller |
| **PayPalWebhookManager.cs** | `Smart.Dashboard\BLL\PayPal\` | Event processing logic |
| **PayPalWebhookEvent.cs** | `Smart.Model\PayPal\` | JSON model for PayPal payloads |

### Backup Location (D: Drive):
`D:\Cursor\_SourceCode\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\`

---

## 🔌 Endpoint Details

### Production URL (after deployment):
```
https://app.thegenie.ai/api/paypal/webhook
```

### Sandbox URL:
```
http://localhost:38949/api/paypal/webhook
```

### Supported HTTP Methods:
- **GET** - Health check / verification
- **POST** - Receive webhook events from PayPal

---

## 📡 Supported PayPal Event Types

### Dispute Events (CUSTOMER.DISPUTE.*)
- `CUSTOMER.DISPUTE.CREATED` - New chargeback initiated
- `CUSTOMER.DISPUTE.RESOLVED` - Dispute resolved (won/lost)
- `CUSTOMER.DISPUTE.UPDATED` - Dispute status changed

### Payment Events (PAYMENT.*)
- `PAYMENT.CAPTURE.COMPLETED` - Payment successful
- `PAYMENT.CAPTURE.DENIED` - Payment declined
- `PAYMENT.CAPTURE.REFUNDED` - Refund processed

### Subscription Events (BILLING.SUBSCRIPTION.*)
- `BILLING.SUBSCRIPTION.CREATED` - New subscription
- `BILLING.SUBSCRIPTION.CANCELLED` - Subscription cancelled
- `BILLING.SUBSCRIPTION.PAYMENT.FAILED` - Payment failed

### Invoice Events (INVOICING.*)
- `INVOICING.INVOICE.PAID` - Invoice paid
- `INVOICING.INVOICE.CANCELLED` - Invoice cancelled
- `INVOICING.INVOICE.CREATED` - New invoice created

---

## 🚀 Production Deployment Steps

### Step 1: Deploy Code to Production
The code is already in the solution. Deploy using normal Azure DevOps / Web Deploy pipeline:
1. Build Release configuration
2. Deploy Smart.Dashboard to `app.thegenie.ai`
3. Verify endpoint: `https://app.thegenie.ai/api/paypal/webhook`

### Step 2: Configure PayPal Developer Portal

1. **Log in to PayPal Developer Portal:**
   [https://developer.paypal.com/dashboard/applications/live](https://developer.paypal.com/dashboard/applications/live)

2. **Navigate to Webhooks:**
   - Select your application
   - Go to "Webhooks" section

3. **Add Webhook URL:**
   ```
   https://app.thegenie.ai/api/paypal/webhook
   ```

4. **Select Event Types to Subscribe:**
   Recommended events to enable:
   - ✅ `CUSTOMER.DISPUTE.CREATED`
   - ✅ `CUSTOMER.DISPUTE.RESOLVED`
   - ✅ `CUSTOMER.DISPUTE.UPDATED`
   - ✅ `PAYMENT.CAPTURE.COMPLETED`
   - ✅ `PAYMENT.CAPTURE.DENIED`
   - ✅ `PAYMENT.CAPTURE.REFUNDED`
   - ✅ `BILLING.SUBSCRIPTION.CANCELLED`
   - ✅ `BILLING.SUBSCRIPTION.PAYMENT.FAILED`

5. **Save and Test:**
   - Use PayPal's "Send test webhook" feature
   - Verify in TheGenie logs

---

## 🔐 Security Considerations

### Future Enhancements (Phase 2):
1. **Webhook Signature Verification** - Validate PayPal webhook signatures
2. **IP Whitelisting** - Only allow PayPal IP ranges
3. **Rate Limiting** - Prevent abuse

### Current Implementation:
- Returns 200 OK to prevent PayPal retries
- Logs all events for audit trail
- No sensitive data exposed

---

## 📊 Database Tables (Future Phase 2)

### Proposed: `FarmGenie.dbo.PayPalWebhookLog`
```sql
CREATE TABLE PayPalWebhookLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PayPalEventId NVARCHAR(100),
    EventType NVARCHAR(100),
    ResourceId NVARCHAR(100),
    Status NVARCHAR(50),
    RawPayload NVARCHAR(MAX),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ProcessedDate DATETIME NULL
)
```

### Proposed: `FarmGenie.dbo.DisputeCase`
```sql
CREATE TABLE DisputeCase (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PayPalDisputeId NVARCHAR(100),
    WhmcsInvoiceId INT,
    WhmcsClientId INT,
    AspNetUserId NVARCHAR(100),
    DisputeReason NVARCHAR(200),
    DisputeAmount DECIMAL(10,2),
    Status NVARCHAR(50), -- Open, InProgress, Won, Lost
    CreatedDate DATETIME DEFAULT GETDATE(),
    ResolvedDate DATETIME NULL,
    Outcome NVARCHAR(50)
)
```

---

## 📝 Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/28/2025 | Initial webhook endpoint created |
| 2.0 | 12/28/2025 | Sandbox verified, deployment guide complete |

---

## 🔗 Related Documents

- [WHMCS API Capabilities](./WHMCS_API_CAPABILITIES_v1.md)
- [Dispute Admin System Specification](./DISPUTE_ADMIN_SYSTEM_SPECIFICATION_v1.md)
- [Master Evidence Workflow](./MASTER_EVIDENCE_WORKFLOW_v1.md)
- [Project Universe Dashboard](file:///D:/Cursor/TheGenie.ai/Development/PROJECT_UNIVERSE_DASHBOARD_v1.html)

