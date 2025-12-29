# PayPal Webhook Deployment Guide

**Version:** 1.0  
**Created:** 12/28/2025 at 7:45 PM PST  
**Last Updated:** 12/28/2025 at 7:45 PM PST  
**Author:** Cursor Opus Agent  
**Status:** READY FOR DEPLOYMENT

---

## Executive Summary

This guide documents the PayPal webhook integration created for TheGenie.ai Billing System. Three new files have been added to the FarmGenie source code to receive webhook notifications from PayPal for disputes, payments, subscriptions, and invoices.

**Endpoint URL (after deployment):** `https://app.thegenie.ai/api/webhooks/paypal`

---

## 1. Files Created

### Location: `D:\Cursor\_SourceCode\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\`

| File | Path | Purpose |
|------|------|---------|
| **PayPalWebhooksController.cs** | `Smart.Dashboard/Controllers/` | API controller - receives webhook POST requests |
| **PayPalWebhookManager.cs** | `Smart.Dashboard/BLL/PayPal/` | Business logic - processes events by type |
| **PayPalWebhookEvent.cs** | `Smart.Model/PayPal/` | Model - deserializes PayPal JSON payloads |

---

## 2. Pattern Used

These files follow the **exact pattern** of the existing Facebook webhook implementation:

| Facebook (Existing) | PayPal (New) |
|---------------------|--------------|
| `WebhooksController.cs` | `PayPalWebhooksController.cs` |
| `FacebookWebhookManager.cs` | `PayPalWebhookManager.cs` |
| `JsonData.cs` (Facebook model) | `PayPalWebhookEvent.cs` |
| Route: `/api/webhooks` | Route: `/api/webhooks/paypal` |

**Key difference:** New route `/api/webhooks/paypal` keeps it separate from Facebook's `/api/webhooks`.

---

## 3. Supported Event Types

### Dispute Events (Chargeback)
- `CUSTOMER.DISPUTE.CREATED` - New dispute filed
- `CUSTOMER.DISPUTE.RESOLVED` - Dispute resolved
- `CUSTOMER.DISPUTE.UPDATED` - Dispute status changed

### Payment Events
- `PAYMENT.CAPTURE.COMPLETED` - Payment captured
- `PAYMENT.CAPTURE.DENIED` - Payment denied
- `PAYMENT.CAPTURE.REFUNDED` - Refund processed

### Subscription Events
- `BILLING.SUBSCRIPTION.CREATED` - New subscription
- `BILLING.SUBSCRIPTION.CANCELLED` - Subscription cancelled
- `BILLING.SUBSCRIPTION.PAYMENT.FAILED` - Payment failed

### Invoice Events
- `INVOICING.INVOICE.PAID` - Invoice paid
- `INVOICING.INVOICE.CANCELLED` - Invoice cancelled
- `INVOICING.INVOICE.CREATED` - Invoice created

---

## 4. Deployment Steps

### Step 1: Code Review
Have development team review the three files:
- `PayPalWebhooksController.cs`
- `PayPalWebhookManager.cs`
- `PayPalWebhookEvent.cs`

### Step 2: Add to Solution
Ensure files are included in the Visual Studio solution:
- Right-click `Smart.Dashboard` → Add → Existing Item → select `PayPalWebhooksController.cs`
- Right-click `Smart.Dashboard/BLL` → New Folder → `PayPal` → Add `PayPalWebhookManager.cs`
- Right-click `Smart.Model` → New Folder → `PayPal` → Add `PayPalWebhookEvent.cs`

### Step 3: Build and Test Locally
```bash
# Build solution
msbuild FarmGenie.sln /p:Configuration=Release

# Verify no build errors
```

### Step 4: Deploy to Staging
Deploy to staging environment first:
- Verify endpoint responds: `GET https://staging.thegenie.ai/api/webhooks/paypal`
- Should return: `{"status":"active","service":"TheGenie.ai PayPal Webhook","version":"1.0"}`

### Step 5: Configure PayPal Webhook
1. Go to PayPal Developer Portal: https://developer.paypal.com
2. Login as Steve Hundley
3. Switch to **Live** mode (not Sandbox)
4. Go to Apps & Credentials → NVP SOAP Webhooks → Manage Webhooks
5. Click "Add Webhook"
6. Enter URL: `https://app.thegenie.ai/api/webhooks/paypal`
7. Select event types (see Section 3)
8. Save

### Step 6: Test Webhook
Use PayPal's "Simulate Webhook Event" feature to send a test event and verify it's received.

---

## 5. PayPal Developer Portal Credentials

**Account:** Steve Hundley  
**Primary Email:** jill@1parkplace.com

### NVP/SOAP App (Live)
- **Display Name:** NVP SOAP Webhooks
- **Client ID:** `AW-K06kTd6z6EoBjDBUzkgHZ8sn1aysinBduYYcA ef6077XwNnq4xmTRDdvGtbXw9ZgTsHdFNJOWOCvn`
- **Secret:** (hidden - visible in portal)

### Features Enabled
- ✅ Customer disputes
- ✅ Save payment methods
- ✅ Subscriptions
- ✅ Payment links and buttons
- ✅ Payouts

---

## 6. Temporary Testing URL

Until production deployment, use webhook.site for testing:

**Webhook.site URL:** `https://webhook.site/e3f4040c-ee62-41f0-b058-972e6319da94`

This URL is active and ready to receive test events from PayPal.

---

## 7. Database Table (Future)

For Phase 2, create a log table:

```sql
CREATE TABLE FarmGenie.dbo.PayPalWebhookLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    WebhookId NVARCHAR(100),
    EventType NVARCHAR(100),
    ResourceType NVARCHAR(50),
    ResourceId NVARCHAR(100),
    Status NVARCHAR(50),
    RawPayload NVARCHAR(MAX),
    ProcessedDate DATETIME DEFAULT GETDATE(),
    ProcessingNotes NVARCHAR(500)
);

CREATE INDEX IX_PayPalWebhookLog_EventType ON FarmGenie.dbo.PayPalWebhookLog(EventType);
CREATE INDEX IX_PayPalWebhookLog_ResourceId ON FarmGenie.dbo.PayPalWebhookLog(ResourceId);
```

---

## 8. Integration with Dispute Admin

Once deployed, the webhook will automatically:

1. **Log all events** for audit trail
2. **Create DisputeCase records** when `CUSTOMER.DISPUTE.CREATED` received
3. **Update Money Management** when `PAYMENT.CAPTURE.REFUNDED` received
4. **Notify admins** via existing Logger infrastructure

---

## 9. Security Considerations

### Webhook Signature Verification (Phase 2)
PayPal sends a signature in headers that should be verified:
- `PAYPAL-TRANSMISSION-ID`
- `PAYPAL-TRANSMISSION-TIME`
- `PAYPAL-TRANSMISSION-SIG`
- `PAYPAL-CERT-URL`

Implementation requires calling PayPal's `/v1/notifications/verify-webhook-signature` endpoint.

### Rate Limiting
PayPal will retry failed webhooks (non-200 response) up to 25 times over 3 days. The current implementation always returns 200 OK even on errors to prevent retry storms.

---

## 10. Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/28/2025 | Initial creation - 3 files for webhook processing |

---

*File: PAYPAL_WEBHOOK_DEPLOYMENT_GUIDE_v1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*

