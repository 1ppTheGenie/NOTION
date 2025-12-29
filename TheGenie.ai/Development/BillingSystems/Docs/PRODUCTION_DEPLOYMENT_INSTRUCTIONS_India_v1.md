# PRODUCTION DEPLOYMENT INSTRUCTIONS
## PayPal Webhook - For India Team

**Version:** 1.0  
**Created:** 12/29/2025  
**Author:** Steve Hundley / Cursor AI  
**Priority:** 🔴 HIGH - Deploy TODAY  
**Changeset:** 4678

---

## ✅ PRE-DEPLOYMENT CHECKLIST

| Step | Action | Status |
|:----:|--------|:------:|
| 1 | Code checked into TFVC | ✅ DONE (Changeset 4678) |
| 2 | Files verified in source control | ✅ DONE |
| 3 | Sandbox tested | ✅ DONE |
| 4 | Deploy to Staging | ⏳ YOUR TASK |
| 5 | Test Staging endpoint | ⏳ YOUR TASK |
| 6 | Deploy to Production | ⏳ YOUR TASK |
| 7 | Test Production endpoint | ⏳ YOUR TASK |
| 8 | Configure PayPal webhooks | ⏳ YOUR TASK |

---

## 📁 FILES TO DEPLOY (Changeset 4678)

Three new files were added to source control:

```
$/SMART/1ppDevelopment/Application/Web/Smart.Web.FarmGenie/
├── Smart.Dashboard/
│   ├── Controllers/
│   │   └── PayPalWebhooksController.cs     ← NEW (Controller)
│   └── BLL/
│       └── PayPal/
│           └── PayPalWebhookManager.cs     ← NEW (Business Logic)
└── Smart.Model/
    └── PayPal/
        └── PayPalWebhookEvent.cs           ← NEW (Data Model)
```

---

## 🚀 DEPLOYMENT STEPS

### STEP 1: Get Latest from Source Control

```
1. Open Visual Studio
2. Open Team Explorer → Connect to oneparkplace.visualstudio.com/SMART
3. Go to Source Control Explorer
4. Right-click on $/SMART → "Get Latest Version"
5. Verify Changeset 4678 files are downloaded
```

### STEP 2: Build the Solution

```
1. Open FarmGenie.sln (or Smart.Dashboard solution)
2. Build → Clean Solution
3. Build → Rebuild Solution
4. Verify: 0 errors, 0 warnings related to PayPal files
```

### STEP 3: Verify Files Are Included

Check that these files are visible in Solution Explorer:

**Smart.Dashboard project:**
- `Controllers/PayPalWebhooksController.cs`
- `BLL/PayPal/PayPalWebhookManager.cs`

**Smart.Model project:**
- `PayPal/PayPalWebhookEvent.cs`

If files are NOT visible:
1. Click "Show All Files" in Solution Explorer toolbar
2. Right-click each file → "Include In Project"
3. Save and rebuild

### STEP 4: Deploy to Staging

Deploy Smart.Dashboard to **stage.thegenie.ai** using your normal deployment process:
- Visual Studio Publish Profile
- Azure DevOps Pipeline
- Web Deploy
- (Whatever your standard process is)

### STEP 5: Test Staging Endpoint

Open a browser and test:

```
GET https://stage.thegenie.ai/api/paypal/webhook
```

**Expected Response:**
```json
{"status":"active","service":"TheGenie.ai PayPal Webhook","version":"1.0"}
```

If you get a 404:
- Verify the deployment completed
- Check IIS application pool is running
- Check web.config for routing issues

### STEP 6: Deploy to Production

After staging verification, deploy to **app.thegenie.ai** using the same process.

### STEP 7: Test Production Endpoint

```
GET https://app.thegenie.ai/api/paypal/webhook
```

**Expected Response:**
```json
{"status":"active","service":"TheGenie.ai PayPal Webhook","version":"1.0"}
```

---

## 🔧 PAYPAL DEVELOPER PORTAL CONFIGURATION

**IMPORTANT:** Only do this AFTER production endpoint is verified working.

### Step 1: Log into PayPal Developer Portal

```
URL: https://developer.paypal.com/dashboard/applications/live
Account: (Use 1ParkPlace PayPal business account)
```

### Step 2: Select Your Application

Navigate to: **Apps & Credentials → Live**

### Step 3: Add Webhook

1. Scroll to **Webhooks** section
2. Click **Add Webhook**
3. Enter URL: `https://app.thegenie.ai/api/paypal/webhook`
4. Select event types (see below)
5. Click **Save**

### Step 4: Select These Event Types

Check ALL of these:

**Disputes (CRITICAL):**
- ✅ CUSTOMER.DISPUTE.CREATED
- ✅ CUSTOMER.DISPUTE.RESOLVED
- ✅ CUSTOMER.DISPUTE.UPDATED

**Payments:**
- ✅ PAYMENT.CAPTURE.COMPLETED
- ✅ PAYMENT.CAPTURE.DENIED
- ✅ PAYMENT.CAPTURE.REFUNDED

**Subscriptions:**
- ✅ BILLING.SUBSCRIPTION.CANCELLED
- ✅ BILLING.SUBSCRIPTION.PAYMENT.FAILED
- ✅ BILLING.SUBSCRIPTION.SUSPENDED

**Invoicing:**
- ✅ INVOICING.INVOICE.PAID
- ✅ INVOICING.INVOICE.CANCELLED

### Step 5: Verify Webhook

PayPal may send a test event. Check logs for:
- Title: "PayPal Webhook Received"
- Entry with event type

---

## 📊 VERIFICATION CHECKLIST

After deployment, verify each step:

| # | Check | How to Verify | Expected Result |
|:-:|-------|---------------|-----------------|
| 1 | Staging endpoint | GET https://stage.thegenie.ai/api/paypal/webhook | 200 OK + JSON |
| 2 | Production endpoint | GET https://app.thegenie.ai/api/paypal/webhook | 200 OK + JSON |
| 3 | POST accepted | POST with empty JSON `{}` | 200 OK |
| 4 | Logs working | Check application logs | "PayPal Webhook" entries |
| 5 | PayPal configured | Check PayPal Developer Portal | Webhook shows as Active |

---

## 🔍 LOGGING

All webhook events are logged using the existing `Logger.Log()` infrastructure.

**Log Titles to Search:**
- `PayPal Webhook Received` - Every incoming event
- `PayPal Dispute` - Dispute-related events
- `PayPal Payment` - Payment events
- `PayPal Subscription` - Subscription events
- `PayPal Invoice` - Invoice events
- `PayPal Webhook Error` - Any errors

**Where to Check:**
- Application log files
- Database logging table (if configured)
- Azure App Insights (if configured)

---

## ⚠️ TROUBLESHOOTING

### Error: 404 Not Found

**Possible causes:**
1. Files not deployed
2. Files not included in project
3. Route not registered

**Solution:**
- Verify files exist in deployed folder
- Check Smart.Dashboard.csproj includes the files
- Restart application pool

### Error: 500 Internal Server Error

**Possible causes:**
1. Missing dependencies
2. Newtonsoft.Json version conflict
3. Logger not available

**Solution:**
- Check detailed error in logs
- Verify all NuGet packages are deployed
- Check Smart.Core is deployed (contains Logger)

### Error: PayPal Webhook Not Receiving Events

**Possible causes:**
1. Wrong URL in PayPal
2. Firewall blocking PayPal IPs
3. SSL certificate issues

**Solution:**
- Verify URL exactly matches: `https://app.thegenie.ai/api/paypal/webhook`
- Ensure HTTPS is working
- Check PayPal webhook logs for delivery status

---

## 📞 CONTACTS

| Role | Contact | For |
|------|---------|-----|
| Business Owner | Steve Hundley | Requirements, PayPal access |
| Development | India Team | Deployment, debugging |
| Documentation | Cursor AI | Code questions |

---

## 📋 QUICK REFERENCE

**Endpoint URL:** `https://app.thegenie.ai/api/paypal/webhook`

**HTTP Methods:**
- `GET` - Health check (returns status JSON)
- `POST` - Receives webhook events from PayPal

**Source Control:**
- Server: oneparkplace.visualstudio.com
- Project: SMART
- Changeset: 4678

**Related Files:**
- `PayPalWebhooksController.cs` - Controller
- `PayPalWebhookManager.cs` - Business logic
- `PayPalWebhookEvent.cs` - Data model

---

## 📝 Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/29/2025 | Initial deployment instructions for India team |

---

*Document: PRODUCTION_DEPLOYMENT_INSTRUCTIONS_India_v1.md*
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*

