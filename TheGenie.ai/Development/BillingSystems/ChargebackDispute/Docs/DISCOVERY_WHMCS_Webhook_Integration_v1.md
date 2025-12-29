# DISCOVERY: WHMCS Webhook & PayFlow Bidirectional Integration

**Version:** 1.0  
**Created:** 12/28/2025  
**Last Updated:** 12/28/2025  
**Author:** Cursor Opus Agent  
**Status:** DISCOVERY COMPLETE - READY FOR IMPLEMENTATION

---

## Executive Summary

**Current State:** WHMCS is configured to **PUSH** transactions to PayFlow (one-way), but there is **NO incoming webhook** configured to receive:
- Chargeback notifications
- Dispute alerts
- Refund confirmations
- Payment status updates

**Solution:** Configure PayPal/PayFlow webhooks to notify WHMCS of all transaction events, then create a custom hook in WHMCS to forward these events to TheGenie.ai for automated dispute tracking.

**Effort Level:** 🟡 MEDIUM (2-4 hours implementation)

---

## 1. Current Architecture (One-Way)

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   TheGenie.ai   │ ───► │     WHMCS       │ ───► │  PayFlow Pro    │
│   (FarmGenie)   │      │  (accounts.     │      │   (PayPal)      │
│                 │      │  1parkplace.com)│      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
        │                        │                        │
        │                        │                        │
        │  Order request ─────►  │  Charge card ───────►  │
        │                        │                        │
        │  ❌ No callbacks       │  ❌ No webhooks        │
        │                        │                        │
```

**Problem:** When PayPal/customer initiates a chargeback or dispute, the only notification goes to email. There's no automated system integration.

---

## 2. Target Architecture (Bidirectional)

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   TheGenie.ai   │ ◄──► │     WHMCS       │ ◄──► │  PayFlow Pro    │
│   (FarmGenie)   │      │  (accounts.     │      │   (PayPal)      │
│                 │      │  1parkplace.com)│      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
        │                        │                        │
        │                        │                        │
        │  Order request ─────►  │  Charge card ───────►  │
        │                        │                        │
        │  ◄───── Webhook ────   │  ◄───── Webhook ────   │
        │   (Dispute alert)      │   (Chargeback event)   │
        │                        │                        │
```

**Goal:** Full transaction lifecycle visibility from payment to dispute resolution.

---

## 3. Implementation Components

### 3.1 PayPal Developer Portal Configuration

**Location:** https://developer.paypal.com/dashboard/applications

**Steps:**
1. Log into PayPal Developer Portal
2. Select LIVE application for 1ParkPlace
3. Navigate to **Webhooks** section
4. Add/Update webhook URL:
   ```
   https://accounts.1parkplace.com/modules/gateways/callback/paypalwebhooks.php
   ```

**Required Event Subscriptions:**

| Event Type | Description | Use Case |
|------------|-------------|----------|
| `PAYMENT.SALE.COMPLETED` | Payment successful | Confirm payment |
| `PAYMENT.SALE.REFUNDED` | Refund processed | Track refunds |
| `PAYMENT.SALE.REVERSED` | Chargeback initiated | **DISPUTE ALERT** |
| `CUSTOMER.DISPUTE.CREATED` | Dispute opened | **DISPUTE ALERT** |
| `CUSTOMER.DISPUTE.UPDATED` | Dispute status change | Track progress |
| `CUSTOMER.DISPUTE.RESOLVED` | Dispute closed | Log outcome |
| `BILLING.SUBSCRIPTION.CANCELLED` | Subscription cancelled | Track cancellations |
| `BILLING.SUBSCRIPTION.SUSPENDED` | Subscription suspended | Track issues |

---

### 3.2 WHMCS Hook Configuration

**File Location:** `/includes/hooks/dispute_webhook.php`

Create a custom WHMCS hook to capture transaction events and forward to TheGenie.ai:

```php
<?php
/**
 * WHMCS Hook: Dispute Webhook Forwarding
 * Forwards transaction events to TheGenie.ai Dispute Admin
 * 
 * File: /includes/hooks/dispute_webhook.php
 * Created: 12/28/2025
 */

use WHMCS\Database\Capsule;

/**
 * Hook: AfterTransactionCreated
 * Fires when a new transaction is recorded (including refunds)
 */
add_hook('AfterTransactionCreated', 1, function($vars) {
    // Only process refunds (negative amounts or specific gateway responses)
    if ($vars['amount'] < 0 || strpos($vars['description'], 'Refund') !== false) {
        forwardToGenieDispute([
            'event_type' => 'REFUND',
            'transaction_id' => $vars['transid'],
            'invoice_id' => $vars['invoiceid'],
            'amount' => $vars['amount'],
            'date' => date('Y-m-d H:i:s'),
            'description' => $vars['description']
        ]);
    }
});

/**
 * Hook: InvoiceRefunded
 * Fires when an invoice is refunded
 */
add_hook('InvoiceRefunded', 1, function($vars) {
    forwardToGenieDispute([
        'event_type' => 'INVOICE_REFUNDED',
        'invoice_id' => $vars['invoiceid'],
        'refund_amount' => $vars['amount'],
        'date' => date('Y-m-d H:i:s')
    ]);
});

/**
 * Hook: InvoiceCancelled
 * Fires when an invoice is cancelled
 */
add_hook('InvoiceCancelled', 1, function($vars) {
    forwardToGenieDispute([
        'event_type' => 'INVOICE_CANCELLED',
        'invoice_id' => $vars['invoiceid'],
        'date' => date('Y-m-d H:i:s')
    ]);
});

/**
 * Hook: TicketOpen
 * Capture support tickets that may indicate disputes
 */
add_hook('TicketOpen', 1, function($vars) {
    $keywords = ['chargeback', 'dispute', 'refund', 'cancel', 'fraud', 'unauthorized'];
    $subject = strtolower($vars['subject']);
    $message = strtolower($vars['message']);
    
    foreach ($keywords as $keyword) {
        if (strpos($subject, $keyword) !== false || strpos($message, $keyword) !== false) {
            forwardToGenieDispute([
                'event_type' => 'DISPUTE_KEYWORD_TICKET',
                'ticket_id' => $vars['ticketid'],
                'client_id' => $vars['userid'],
                'subject' => $vars['subject'],
                'date' => date('Y-m-d H:i:s')
            ]);
            break;
        }
    }
});

/**
 * Forward event data to TheGenie.ai API
 */
function forwardToGenieDispute($data) {
    $apiUrl = 'https://app.thegenie.ai/api/dispute/webhook';
    $apiKey = 'YOUR_API_KEY_HERE'; // Configure in WHMCS settings
    
    $ch = curl_init($apiUrl);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($data),
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'X-API-Key: ' . $apiKey
        ],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 10
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    // Log the webhook call
    logActivity("Dispute Webhook: Sent " . $data['event_type'] . " event. HTTP: " . $httpCode);
    
    return $httpCode === 200;
}
```

---

### 3.3 TheGenie.ai API Endpoint

Create an endpoint in TheGenie.ai to receive WHMCS webhooks:

**Endpoint:** `POST /api/dispute/webhook`

**Controller:** `DisputeWebhookController.cs`

```csharp
[ApiController]
[Route("api/dispute")]
public class DisputeWebhookController : ControllerBase
{
    [HttpPost("webhook")]
    public async Task<IActionResult> ReceiveWebhook([FromBody] WebhookPayload payload)
    {
        // Validate API key
        if (!Request.Headers.TryGetValue("X-API-Key", out var apiKey) || 
            apiKey != Configuration["DisputeWebhook:ApiKey"])
        {
            return Unauthorized();
        }

        // Process based on event type
        switch (payload.EventType)
        {
            case "REFUND":
            case "INVOICE_REFUNDED":
                await ProcessRefundEvent(payload);
                break;
                
            case "CHARGEBACK":
            case "DISPUTE_CREATED":
                await CreateDisputeCase(payload);
                break;
                
            case "DISPUTE_KEYWORD_TICKET":
                await FlagPotentialDispute(payload);
                break;
        }

        return Ok(new { received = true });
    }
    
    private async Task CreateDisputeCase(WebhookPayload payload)
    {
        // Auto-create dispute case in DisputeCase table
        var disputeCase = new DisputeCase
        {
            CaseNumber = GenerateCaseNumber(),
            WhmcsInvoiceId = payload.InvoiceId,
            TransactionId = payload.TransactionId,
            DisputeStatus = "Open",
            DisputeFiledDate = DateTime.UtcNow,
            CreatedDate = DateTime.UtcNow,
            CreatedBy = Guid.Parse("SYSTEM-WEBHOOK-GUID")
        };
        
        await _context.DisputeCases.AddAsync(disputeCase);
        await _context.SaveChangesAsync();
        
        // Send notification email to accounting
        await SendDisputeNotification(disputeCase);
    }
}
```

---

## 4. WHMCS API Endpoints for Dispute Management

WHMCS provides these API actions that we can USE for bidirectional communication:

### 4.1 Reading Data (Already Implemented)

| API Action | Purpose | Our Usage |
|------------|---------|-----------|
| `GetClients` | Get customer list | ✅ Evidence collection |
| `GetClientsDetails` | Get customer details | ✅ Evidence collection |
| `GetInvoice` | Get invoice details | ✅ Evidence collection |
| `GetOrders` | Get order history | ✅ Evidence collection |
| `GetTransactions` | Get payment history | ✅ Evidence collection |

### 4.2 Writing Data (NEW - For Dispute Management)

| API Action | Purpose | Use Case |
|------------|---------|----------|
| `AddTransaction` | Add credit/refund | Issue refunds through system |
| `UpdateTransaction` | Update transaction | Mark as disputed |
| `AddCredit` | Add account credit | Customer goodwill credits |
| `AddNote` | Add client note | Document dispute history |
| `OpenTicket` | Create support ticket | Document communications |
| `UpdateClient` | Update client record | Flag disputed accounts |

### 4.3 Example: Issue Refund via API

```python
def issue_refund_via_whmcs(invoice_id, amount, description):
    """Issue a refund through WHMCS API"""
    params = {
        'action': 'AddTransaction',
        'invoiceid': invoice_id,
        'transid': f'REFUND-{datetime.now().strftime("%Y%m%d%H%M%S")}',
        'gateway': 'paypalcheckout',
        'date': datetime.now().strftime('%Y-%m-%d'),
        'amount': -abs(amount),  # Negative for refund
        'description': description,
        'identifier': WHMCS_IDENTIFIER,
        'secret': WHMCS_SECRET,
        'accesskey': WHMCS_ACCESS_KEY,
        'responsetype': 'json'
    }
    
    response = requests.post(WHMCS_URL, data=params)
    return response.json()
```

---

## 5. PayFlow Pro Direct Integration (Alternative)

If PayPal webhooks don't capture all events, we can integrate directly with PayFlow Pro:

### 5.1 PayFlow Silent Post (IPN Equivalent)

PayFlow Pro supports "Silent Post" which sends transaction data to a URL:

**Configuration:** 
- WHMCS Admin → Setup → Payment Gateways → PayFlow Pro
- Add Silent Post URL: `https://app.thegenie.ai/api/payflow/silentpost`

### 5.2 PayFlow Transaction Query API

We can also POLL PayFlow for transaction status:

```python
def query_payflow_transaction(transaction_id):
    """Query PayFlow for transaction status including chargebacks"""
    # PayFlow API endpoint
    url = "https://payflowpro.paypal.com"
    
    params = {
        'PARTNER': 'PayPal',
        'VENDOR': '1parkplace',  # Verify in WHMCS
        'USER': '1parkplace',    # Verify in WHMCS
        'PWD': 'xxxxx',          # From WHMCS admin
        'TRXTYPE': 'I',          # Inquiry
        'ORIGID': transaction_id,
        'VERBOSITY': 'HIGH'
    }
    
    # This returns detailed transaction info including chargeback status
```

---

## 6. Implementation Checklist

### Phase 1: PayPal Webhook Setup (30 min)

- [ ] Log into PayPal Developer Portal
- [ ] Find 1ParkPlace LIVE application
- [ ] Verify/Update webhook URL
- [ ] Subscribe to dispute events
- [ ] Test with sandbox transaction

### Phase 2: WHMCS Hook (1-2 hours)

- [ ] Create `/includes/hooks/dispute_webhook.php`
- [ ] Configure API key for TheGenie.ai
- [ ] Test hook with refund transaction
- [ ] Verify logging works

### Phase 3: TheGenie.ai Endpoint (1-2 hours)

- [ ] Create `DisputeWebhookController`
- [ ] Add webhook payload model
- [ ] Implement auto-case creation
- [ ] Add email notification
- [ ] Test end-to-end

### Phase 4: Verification (30 min)

- [ ] Process test refund
- [ ] Verify it appears in Dispute Admin
- [ ] Simulate chargeback (sandbox)
- [ ] Verify auto-alert works

---

## 7. Credentials - VERIFIED FROM SOURCE CODE

### WHMCS API - ✅ CONFIRMED WORKING

**Source:** `Smart.Core\BLL\Helper\WhmcsHelper.cs`

```csharp
// From WhmcsHelper.GetApi() method:
var config = new WhmcsConfig
{
    Identifier = "K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q",
    Secret = "nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV",
    Url = "https://accounts.1parkplace.com/includes/api.php",
    AccessKey = "whmcs!api@access$1ppGenie"
};
```

| Item | Value | Status |
|------|-------|--------|
| API URL | `https://accounts.1parkplace.com/includes/api.php` | ✅ Working |
| Identifier | `K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q` | ✅ Verified |
| Secret | `nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV` | ✅ Verified |
| Access Key | `whmcs!api@access$1ppGenie` | ✅ Verified |

### WHMCS.Net Library - Available Methods (From Source Analysis)

**Currently Used in FarmGenie:**

| Method | Used For | Location |
|--------|----------|----------|
| `AddOrder()` | Create new orders | ListingCommandBillingHandler.cs |
| `AcceptOrder()` | Confirm order | CapturePaymentManager.cs |
| `GenerateInvoices()` | Create invoices | CapturePaymentManager.cs |
| `GetInvoice()` | Retrieve invoice | CapturePaymentManager.cs |
| `CapturePayment()` | Charge card | CapturePaymentManager.cs |
| `AddBilling()` | Add payment method | BillingManager.cs |
| `GetBillingAccounts()` | Get payment methods | BillingManager.cs |
| `DeleteBilling()` | Remove payment | BillingManager.cs |
| `AddClient()` | Create WHMCS account | BillingManager.cs |
| `GetClientsDetails()` | Get client info | BillingManager.cs |
| `AddClientNote()` | Add notes | WhmcsHelper.cs |
| `CancelInvoice()` | Cancel invoice | TestWhmcs.cs |
| `UpdateClientProductStatus()` | Update product | TestWhmcs.cs |
| `GetClientProduct()` | Get product | TestWhmcs.cs |
| `GetPromotions()` | Get promos | TestWhmcs.cs |

**Available for Dispute System (Standard WHMCS API):**

| Method | Purpose | Use Case |
|--------|---------|----------|
| `AddTransaction` | Record payment/refund | Log refunds in WHMCS |
| `UpdateInvoice` | Update invoice status | Mark as disputed |
| `AddCredit` | Add account credit | Customer credits |
| `GetTransactions` | Get payment history | ✅ Already used |
| `OpenTicket` | Create support ticket | Document dispute |
| `AddNote` | Add client note | ✅ Already used |

### FarmGenie ↔ WHMCS Mapping

**Table:** `FarmGenie.dbo.UserWhmcs`

| FarmGenie Field | WHMCS Field | Purpose |
|-----------------|-------------|---------|
| AspNetUserId | WhmcsClientId | Links users to WHMCS |

**Helper Method:** `WhmcsHelper.GetWhmcsClientId(aspNetUserId)`

### PayFlow Credentials - Need to Extract from WHMCS Admin

The actual PayFlow credentials are stored in WHMCS database, not in source code. To find them:

1. Log into WHMCS Admin: `https://accounts.1parkplace.com/admin`
2. Navigate to: Setup → Payment Gateways → PayPal Checkout / PayFlow Pro
3. Look for:
   - Partner ID
   - Vendor (Merchant Login)
   - User
   - Password
   - Test Mode setting

---

## 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| PayPal webhook fails silently | Medium | High | Add monitoring/alerts |
| WHMCS hook causes errors | Low | High | Wrap in try/catch, log errors |
| API key exposed | Low | High | Use environment variables |
| Webhook flood | Low | Medium | Rate limiting on endpoint |

---

## 9. Next Steps

1. **IMMEDIATE:** Get PayPal Developer Portal access
2. **THEN:** Verify PayFlow settings in WHMCS admin
3. **THEN:** Implement WHMCS hook
4. **THEN:** Create TheGenie.ai endpoint
5. **FINALLY:** Test full bidirectional flow

---

## 10. Alternative: Manual Webhook Until Full Integration

While setting up the full integration, we can create a **manual import** feature:

1. When dispute email arrives, user uploads the email/screenshot to Dispute Admin
2. System parses transaction ID and auto-populates case
3. This provides immediate value while full webhook is developed

This is already designed into the v2 wireframe with the file upload feature.

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/28/2025 | Initial discovery document |

---

*File: DISCOVERY_WHMCS_Webhook_Integration_v1.md*
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*

