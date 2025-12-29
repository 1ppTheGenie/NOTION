# Billing Systems (PUB)
## TheGenie.ai Billing Infrastructure

**Last Updated:** 12/28/2025  
**Internal Name:** PUB (WHMCS billing system)

---

## 📁 Project Structure

```
BillingSystems/
├── README.md                    ← You are here
├── ChargebackDispute/           ← Dispute Admin System
│   ├── Docs/                    ← All documentation
│   ├── Scripts/                 ← Python evidence collectors & PDF generators
│   ├── Wireframes/              ← UI mockups
│   └── SourceCode/              ← C# webhook code (ready for deployment)
│       ├── Controllers/         ← PayPalWebhooksController.cs
│       ├── BLL/                 ← PayPalWebhookManager.cs
│       └── Model/               ← PayPalWebhookEvent.cs
```

---

## 🎯 Current Projects

### 1. Chargeback Dispute System
**Status:** ✅ Sandbox Verified, Ready for Production

| Component | Status | Description |
|-----------|--------|-------------|
| PDF Generator (One-Time) | ✅ Gold Standard | `generate_polished_response_v12.py` |
| PDF Generator (Subscription) | ✅ Gold Standard | `generate_competition_command_response_v5.py` |
| PayPal Webhook | ✅ Sandbox Verified | Bidirectional PayFlow integration |
| Dispute Admin UI | 📋 Wireframe Complete | User lookup → Order → Dispute flow |
| Database Schema | 📋 Designed | DisputeCase, PayPalWebhookLog tables |

---

## 🔌 PayPal Webhook (PRIORITY DEPLOYMENT)

### Files to Deploy
Located in: `ChargebackDispute/SourceCode/`

| File | Deploy To | Purpose |
|------|-----------|---------|
| `PayPalWebhooksController.cs` | Smart.Dashboard\Controllers\ | API endpoint |
| `PayPalWebhookManager.cs` | Smart.Dashboard\BLL\PayPal\ | Event processing |
| `PayPalWebhookEvent.cs` | Smart.Model\PayPal\ | Data model |

### Endpoint
- **Sandbox:** `http://localhost:38949/api/paypal/webhook` ✅ VERIFIED
- **Production:** `https://app.thegenie.ai/api/paypal/webhook`

### Deployment Guide
See: `ChargebackDispute/Docs/HANDOFF_PayPal_Webhook_Deployment_v1.md`

---

## 🛤️ Feature Runway

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | Dispute Admin Interface | HIGH | 📋 Wireframe Complete |
| 2 | PayPal Webhook | HIGH | ✅ SANDBOX VERIFIED |
| 3 | Service Naming Update | MEDIUM | 📋 Planning |
| 4 | Client Invoice Integration | MEDIUM | 📋 Planning |
| 5 | Promotions & Credits UI | LOW | 📋 Backlog |
| 6 | Money Management Reports | LOW | 📋 Backlog |
| 7 | Customer Account UI | LOW | 📋 Backlog |

---

## 📚 Key Documents

### For India Team (Deployment)
- **HANDOFF_PayPal_Webhook_Deployment_v1.md** - Step-by-step deployment guide
- **PAYPAL_WEBHOOK_DEPLOYMENT_GUIDE_v2.md** - Full technical documentation

### For Development
- **DISPUTE_ADMIN_SYSTEM_SPECIFICATION_v1.md** - Full system design
- **WHMCS_API_CAPABILITIES_v1.md** - All available PUB API methods
- **MASTER_EVIDENCE_WORKFLOW_v1.md** - Evidence collection logic

### Reference
- **SOP_ListingCommand_ChargebackDefense_v1.md** - How to process disputes
- **MASTER_RULES_SubscriptionDisputes_v1.md** - GPT advisor recommendations

---

## 🔗 Related Systems

| System | Purpose | Integration |
|--------|---------|-------------|
| WHMCS (PUB) | Billing, invoices, orders | API - full access |
| PayFlow Pro | Payment processing | Webhook - NEW |
| FarmGenie | User activity, login logs | Database - direct |
| Intercom | Support conversations | API - verified |
| SendGrid | Email delivery | ⚠️ Webhook not configured |

---

## 📞 Contacts

- **Business Owner:** Steve Hundley
- **Development:** India Team (Midnight PST)
- **AI Assistant:** Cursor Agent

---

*Last synced to GitHub: 12/28/2025*

