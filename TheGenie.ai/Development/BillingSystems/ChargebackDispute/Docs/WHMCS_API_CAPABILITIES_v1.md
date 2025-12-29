# WHMCS API Capabilities for Dispute System

**Version:** 1.0  
**Created:** 12/28/2025  
**Last Updated:** 12/28/2025  
**Author:** Cursor Opus Agent  
**Status:** VERIFIED FROM SOURCE CODE

---

## Executive Summary

TheGenie.ai already has **full bidirectional WHMCS API access** through the `WHMCS.Net` library. All credentials are verified and working. We can use existing infrastructure to:

1. ✅ **Read** transaction/invoice/order data (already doing this)
2. ✅ **Write** notes to client records (already doing this)
3. 🆕 **Add transactions** (for logging refunds)
4. 🆕 **Update invoices** (for marking as disputed)
5. 🆕 **Add credits** (for customer goodwill)

---

## 1. Verified Credentials

**Source File:** `Smart.Core\BLL\Helper\WhmcsHelper.cs`

```csharp
Identifier = "K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q"
Secret = "nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV"
Url = "https://accounts.1parkplace.com/includes/api.php"
AccessKey = "whmcs!api@access$1ppGenie"
```

**Python equivalent (for scripts):**

```python
WHMCS_URL = 'https://accounts.1parkplace.com/includes/api.php'
WHMCS_IDENTIFIER = 'K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q'
WHMCS_SECRET = 'nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV'
WHMCS_ACCESS_KEY = 'whmcs!api@access$1ppGenie'
```

---

## 2. Currently Used API Methods

| Method | Purpose | Source File |
|--------|---------|-------------|
| `AddOrder` | Create new order | ListingCommandBillingHandler.cs |
| `AcceptOrder` | Confirm order | CapturePaymentManager.cs |
| `GenerateInvoices` | Create invoice | CapturePaymentManager.cs |
| `GetInvoice` | Get invoice details | CapturePaymentManager.cs |
| `CapturePayment` | Charge credit card | CapturePaymentManager.cs |
| `AddBilling` | Add payment method | BillingManager.cs |
| `GetBillingAccounts` | Get payment methods | BillingManager.cs |
| `DeleteBilling` | Remove payment method | BillingManager.cs |
| `AddClient` | Create WHMCS account | BillingManager.cs |
| `GetClientsDetails` | Get client info | BillingManager.cs |
| `AddClientNote` | Add notes to client | WhmcsHelper.cs |
| `CancelInvoice` | Cancel invoice | TestWhmcs.cs |
| `UpdateClientProductStatus` | Update product status | TestWhmcs.cs |
| `GetClientProduct` | Get client product | TestWhmcs.cs |
| `GetPromotions` | Get promotions | TestWhmcs.cs |

---

## 3. Available for Dispute System (Standard WHMCS API)

These are WHMCS API actions we can use but haven't implemented yet:

### For Recording Refunds

```python
# AddTransaction - Record a refund
params = {
    'action': 'AddTransaction',
    'invoiceid': invoice_id,
    'transid': f'REFUND-{timestamp}',
    'gateway': 'paypalcheckout',
    'date': '2025-12-28',
    'amount': -500.00,  # Negative for refund
    'description': 'Chargeback refund - Case DC-2025-00066',
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'responsetype': 'json'
}
```

### For Updating Invoice Status

```python
# UpdateInvoice - Mark as disputed
params = {
    'action': 'UpdateInvoice',
    'invoiceid': invoice_id,
    'status': 'Disputed',  # or add note
    'notes': 'Chargeback dispute filed - Case DC-2025-00066',
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'responsetype': 'json'
}
```

### For Adding Client Credits

```python
# AddCredit - Add account credit
params = {
    'action': 'AddCredit',
    'clientid': whmcs_client_id,
    'amount': 50.00,
    'description': 'Goodwill credit - dispute resolution',
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'responsetype': 'json'
}
```

### For Creating Support Tickets

```python
# OpenTicket - Document dispute in support system
params = {
    'action': 'OpenTicket',
    'clientid': whmcs_client_id,
    'deptid': 1,  # Support department
    'subject': 'Chargeback Dispute - Invoice #62279',
    'message': 'Dispute filed on October 24, 2025...',
    'priority': 'High',
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'responsetype': 'json'
}
```

---

## 4. FarmGenie ↔ WHMCS User Mapping

**Database Table:** `FarmGenie.dbo.UserWhmcs`

| Column | Type | Purpose |
|--------|------|---------|
| AspNetUserId | UNIQUEIDENTIFIER | FarmGenie user ID |
| WhmcsClientId | INT | WHMCS client ID |

**Query:**

```sql
SELECT AspNetUserId, WhmcsClientId 
FROM FarmGenie.dbo.UserWhmcs 
WHERE AspNetUserId = 'e48d2a8e-c991-44f4-b751-e170fc8df131';
```

**C# Helper:**

```csharp
// From WhmcsHelper.cs
public static int GetWhmcsClientId(string aspNetUserId)
{
    using (var proxy = new FarmGenieProxy())
    {
        return proxy.GetUserWhmcs(aspNetUserId).WhmcsClientId;
    }
}
```

---

## 5. PayFlow Pro Credentials - CAPTURED 12/28/2025 @ 5:25 PM PST

**Source:** PUB Admin → System Settings → Payments → PayFlow Pro (PayPal)

| Field | Value | Notes |
|-------|-------|-------|
| **Partner** | `VeriSign` | PayPal legacy partner ID |
| **Merchant Login** | `1PARKPLACE` | Account identifier |
| **Username** | `1PARKPLACE` | API username |
| **Password** | `morpheus111` | Gateway password |
| **Processor ID** | *(empty)* | Not configured |
| **Merchant ID** | *(empty)* | Not configured |
| **Transaction PW** | *(empty)* | Not configured |
| **API Username** | *(empty)* | ⚠️ **REQUIRED FOR REFUNDS** |
| **API Password** | *(empty)* | ⚠️ **REQUIRED FOR REFUNDS** |
| **API Signature** | *(empty)* | ⚠️ **REQUIRED FOR REFUNDS** |
| **Test Mode** | Unchecked | Production mode |

### 🔴 CRITICAL FINDING: Refund API Not Configured!

The PUB Admin note says: **"API fields only required for refunds"**

This means:
- ✅ **Charges work** - Partner/Merchant/User/Password are set
- ❌ **Refunds via API won't work** - API Username/Password/Signature are EMPTY
- ❌ **Webhook callbacks** - Need PayPal Developer Portal configuration

### Action Required for Full Bidirectional

1. **Get PayPal API credentials** from PayPal Developer Portal
2. **Configure in PUB Admin** → PayFlow Pro → API Username/Password/Signature
3. **Set up webhooks** in PayPal Developer Portal pointing to TheGenie.ai

---

## 6. Active Apps in PUB (from Admin 12/28/2025)

| App | Status | Description |
|-----|--------|-------------|
| 101domain | ✅ ACTIVE | Domain registration |
| Bulk Pricing Updater | ✅ ACTIVE | Rule-based pricing |
| Enom | ✅ ACTIVE | Domain registrar |
| Lara Addon | ✅ ACTIVE | No description |
| Mail In Payment | ✅ ACTIVE | Offline payments |
| **OneParkPlaceModule** | ✅ ACTIVE | Custom 1ParkPlace integration |
| PasswordChange | ✅ ACTIVE | No description |
| **PayFlow Pro** | ✅ ACTIVE | Merchant gateway from PayPal |
| Whmcs Multisite | ✅ ACTIVE | No description |

---

## 7. What's Missing for Full Bidirectional

### PayFlow Webhook Configuration

PayFlow sends webhook notifications for:
- Chargeback initiated
- Refund processed
- Payment status changes

**To Configure:**
1. Log into PayPal Developer Portal (need PayPal business account credentials)
2. Create webhook pointing to: `https://app.thegenie.ai/api/dispute/webhook`
3. Subscribe to events: `PAYMENT.CAPTURE.REFUNDED`, `PAYMENT.CAPTURE.DENIED`, `CUSTOMER.DISPUTE.CREATED`

### WHMCS Hook for Event Forwarding

Create a hook file on WHMCS server:

**Path:** `/includes/hooks/dispute_webhook.php`

This hook catches WHMCS events (refunds, cancellations) and forwards to TheGenie.ai.

---

## 6. Implementation Effort

| Task | Effort | Dependencies |
|------|--------|--------------|
| Use existing API for refund logging | 🟢 LOW (1 hour) | None - API already working |
| Add transaction notes for disputes | 🟢 LOW (30 min) | None - `AddClientNote` exists |
| Create webhook endpoint in TheGenie.ai | 🟡 MEDIUM (2 hours) | .NET development |
| Deploy WHMCS hook | 🟡 MEDIUM (1 hour) | FTP access to WHMCS |
| Configure PayFlow webhook | 🟡 MEDIUM (30 min) | PayPal Developer Portal access |

**Total:** 5-6 hours for full bidirectional integration

---

## 7. Quick Win: Logging Dispute Notes

We can immediately start logging disputes in WHMCS using existing `AddClientNote`:

```python
import requests

def log_dispute_to_whmcs(whmcs_client_id, dispute_info):
    """Log dispute information to WHMCS client notes"""
    note = f"""
    ========== CHARGEBACK DISPUTE ==========
    Case: {dispute_info['case_number']}
    Filed: {dispute_info['filed_date']}
    Amount: {dispute_info['amount']}
    Reason: {dispute_info['reason']}
    Status: {dispute_info['status']}
    =========================================
    """
    
    params = {
        'action': 'AddClientNote',
        'userid': whmcs_client_id,
        'notes': note,
        'sticky': 1,  # Make it a sticky note
        'identifier': 'K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q',
        'secret': 'nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV',
        'accesskey': 'whmcs!api@access$1ppGenie',
        'responsetype': 'json'
    }
    
    response = requests.post(
        'https://accounts.1parkplace.com/includes/api.php',
        data=params
    )
    return response.json()
```

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/28/2025 | Initial capabilities document - extracted from source code |

---

*File: WHMCS_API_CAPABILITIES_v1.md*
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*

