# Standard Operating Procedure: Listing Command Chargeback Defense

---

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/27/2025 |
| **Last Updated** | 12/27/2025 |
| **Author** | Cursor AI (Opus) |
| **Product** | Listing Command (One-Time Service) |
| **Status** | ✅ COMPLETE - Production Ready |

---

## 1. PURPOSE

This SOP documents the complete process for generating chargeback dispute response packages for **Listing Command** - a one-time, non-recurring SMS marketing service sold through TheGenie.ai platform owned by 1ParkPlace, Inc.

---

## 2. SCOPE

### In Scope
- Listing Command one-time purchases ($67.50 typical)
- PayPal-processed transactions
- Disputes filed via Visa, Mastercard, Amex, Discover

### Out of Scope (Separate Templates Needed)
- Paisley Plus subscriptions ($50/month)
- Neighborhood Command subscriptions
- Competition Command services
- Direct optimization services (one-time, different workflow)

---

## 3. KEY SYSTEM FILES

### Master Script (v12 - FINAL)
```
D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\generate_polished_response_v12.py
```

### Master Template Location
```
D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Templates\ListingCommand\DisputeResponse_MasterTemplate_v1.0.py
```
**ACTION REQUIRED**: Update to v12 with dynamic page counting

### Output Location
```
D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\DefenseKits\DefenseKit_{CASE_ID}_{TIMESTAMP}\
```

---

## 4. DATA SOURCES & QUERIES

### 4.1 Customer Identification
```sql
-- Find customer by email
SELECT AspNetUserId, FirstName, LastName, Email 
FROM FarmGenie.dbo.AspNetUserProfiles 
WHERE Email = 'customer@email.com'
```

### 4.2 Transaction Lookup (WHMCS API)
```python
# WHMCS API credentials (from WhmcsHelper.cs)
API_URL = "https://accounts.1parkplace.com/includes/api.php"
API_IDENTIFIER = "[REDACTED - See Master Credential Tracker]"
API_SECRET = "[REDACTED - See Master Credential Tracker]"

# Key API actions:
# - GetClients (search by email)
# - GetTransactions (by clientid)
# - GetInvoices (by invoiceid)
# - GetOrders (by userid)
```

### 4.3 Listing Command Campaign Data
```sql
-- Get campaign details by AspNetUserId
SELECT 
    q.ListingCommandQueueId,
    q.MlsId,
    q.MlsNumber,
    q.CreatedOn AS OrderDate,
    q.ProcessedOn AS CampaignDate,
    q.StatusTypeId,
    c.ListingCommandUserConfigurationId
FROM FarmGenie.dbo.ListingCommandQueue q
JOIN FarmGenie.dbo.ListingCommandUserConfiguration c 
    ON q.ListingCommandUserConfigurationId = c.ListingCommandUserConfigurationId
WHERE c.AspNetUserId = '{customer_asp_user_id}'
ORDER BY q.CreatedOn DESC
```

### 4.4 SMS Campaign Statistics
```sql
-- Get SMS send details
SELECT 
    SmsReportSendQueueId,
    ScheduledOn,
    ProcessedOn,
    NumberOfRecipients,
    NumberOfQueued,
    NumberOfFailed
FROM FarmGenie.dbo.SmsReportSendQueue
WHERE ListingCommandQueueId = {queue_id}
```

### 4.5 Engagement Count (CRITICAL - UI Match)
```sql
-- This matches what the UI shows as "Engagements"
-- Engagements = Unique leads who clicked SMS links
-- Source: ListingCommandHistorySmsEngagementsHandler.cs

-- First get ShortUrlDataIds from message queue
SELECT ShortUrlDataId 
FROM FarmGenie.dbo.SmsReportMessageQueueLog
WHERE SmsReportSendQueueId = {sms_queue_id}
  AND ShortUrlDataId IS NOT NULL

-- Then count leads from those URLs
SELECT COUNT(DISTINCT GenieLeadId)
FROM FarmGenie.dbo.GenieLead
WHERE ShortUrlDataId IN ({shortUrlDataIds})
```

### 4.6 Property Image URL
```sql
-- Get property image from Cloudflare
SELECT 
    m.ImageUrl,
    REPLACE(m.ImageUrl, 'https://cdn-photos.rets.ly/mls/', 
            'https://images.listings.thegenie.ai/') AS CloudflareUrl
FROM MlsListing.dbo.MlsListingMaster m
WHERE m.MlsNumber = '{mls_number}'
```

### 4.7 Browser/Session Data
```sql
-- Get login and session info
SELECT TOP 10
    b.CreatedOn,
    b.Browser,
    b.BrowserVersion,
    b.OS,
    b.OSVersion,
    b.Platform,
    b.UserAgent,
    b.IpAddress
FROM FarmGenie.dbo.BrowserUsage b
WHERE b.AspNetUserId = '{asp_user_id}'
ORDER BY b.CreatedOn DESC
```

---

## 5. CASE_DATA DICTIONARY

All variables that must be populated for document generation:

| Variable | Source | Description |
|----------|--------|-------------|
| `customer_name` | AspNetUserProfiles | Full name |
| `customer_email` | AspNetUserProfiles | Email address |
| `asp_user_id` | AspNetUserProfiles | GUID |
| `transaction_id` | WHMCS/PayPal | PayPal Transaction ID |
| `transaction_date` | WHMCS GetTransactions | Payment date |
| `transaction_amount` | WHMCS | '$67.50' typical |
| `order_date` | ListingCommandQueue.CreatedOn | When order was placed |
| `order_time` | ListingCommandQueue.CreatedOn | Time portion |
| `order_id` | WHMCS GetOrders | WHMCS Order ID |
| `invoice_id` | WHMCS GetInvoices | WHMCS Invoice ID |
| `case_id` | PayPal Notification | PP-R-XXX-XXXXXXXXX |
| `dispute_filed` | **MANUAL INPUT** | Date dispute was filed |
| `response_deadline` | PayPal Notification | When response is due |
| `property_address` | MlsListingMaster | Full address |
| `mls_number` | ListingCommandQueue | MLS ID |
| `campaign_date` | SmsReportSendQueue.ProcessedOn | When SMS sent |
| `campaign_time` | SmsReportSendQueue.ProcessedOn | Time portion |
| `sms_target` | SmsReportSendQueue.NumberOfRecipients | Target count |
| `sms_sent` | SmsReportSendQueue.NumberOfQueued | Actual sent |
| `sms_failed` | SmsReportSendQueue.NumberOfFailed | Failed count |
| `engagements` | ShortUrlDataLeadsCount | Unique clicks (matches UI) |
| `search_radius` | ListingCommandUserConfiguration | Miles |
| `search_beds_min/max` | ListingCommandUserConfiguration | Bedroom filter |
| `ip_address` | BrowserUsage | Login IP |
| `browser` | BrowserUsage | Chrome, Safari, etc. |
| `os` | BrowserUsage | Windows, Mac, etc. |
| `user_agent` | BrowserUsage | Full UA string |

---

## 6. CRITICAL TECHNICAL RULES

### 6.1 Page Counting (NEVER HARDCODE)
```python
# WRONG - Will break when document changes
TOTAL_PAGES = 12

# CORRECT - Use NumberedCanvas for two-pass build
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """Two-pass page counting - ALWAYS use this"""
    def __init__(self, *args, **kwargs):
        canvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []
    
    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()
    
    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_footer(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

# Build with dynamic page counting
doc.build(story, canvasmaker=NumberedCanvas)
```

### 6.2 URLs in Documents (NEVER USE HOT LINKS)
```python
# WRONG - Clicking creates false leads
landing_page_url = "https://cloud.thegenie.ai/genie-pages/..."

# CORRECT - Use generic placeholder
"[Unique tracking URL generated for each recipient]"
```
**MASTER RULE**: Never include clickable tracking URLs in dispute documents. They trigger lead tracking and create false data.

### 6.3 Widow Prevention (Typography)
- Never allow single words to wrap to a new line alone
- Shorten bullet points if wrapping occurs
- Test each version visually

### 6.4 Phone Numbers (Never "Upon Request")
```python
# WRONG
"Phone: Available upon request"

# CORRECT
"Phone: 888-425-2300"
```

### 6.5 Branding
- Company: **1ParkPlace, Inc.** (one word, numeral 1)
- Product: **TheGenie.ai** 
- Email: **wecare@thegenie.ai** (not support@listingcommand.com)
- Footer: **Powered by 1ParkPlace**
- Invoices/Billing: Always "1ParkPlace", never "TheGenie"

---

## 7. DOCUMENT STRUCTURE (Current v12)

| Page | Content |
|------|---------|
| 1 | Reference Table (Case ID, Transaction, Customer, Property) |
| 2 | Executive Summary (8 bullets) + Evidence Checklist |
| 3 | Order Details + Order Review Screenshot |
| 4 | Proof of Authorization (Timeline + Session Data) |
| 5 | Proof of Delivery (Campaign Stats + Landing Page) |
| 6 | No Merchant Contact + Terms |
| 7 | Merchant Request to Issuer |
| 8 | Appendix A: Email Confirmations |
| 9 | Appendix B: Landing Page Screenshot |
| 10 | Appendix C: Terms & Conditions (Full) |
| 11 | End of Document |

---

## 8. EXECUTIVE SUMMARY FORMAT

8 concise bullets, no widows:

1. Authenticated session + existing account
2. One-time purchase, not subscription
3. Terms explicitly accepted at checkout
4. Payment processed successfully
5. Service delivered within [X] minutes
6. Campaign executed with confirmed delivery
7. No contact attempts recorded
8. Dispute filed [X] days after delivery

---

## 9. INTEGRATION GAPS (TO BE ADDRESSED)

### 9.1 SendGrid Webhooks
- **Status**: NOT CONFIGURED
- **Impact**: Cannot prove email opens/clicks
- **Current Workaround**: Show as "SENT" not "DELIVERED"
- **Resolution**: Configure SendGrid webhooks, create EmailEvent tables
- **Gap Document**: `INTEGRATION_GAP_SendGrid_v1.md`

### 9.2 PayFlow Statement Descriptor
- **Status**: NEEDS VERIFICATION
- **Impact**: Customers may not recognize "1ParkPlace" on statement
- **Location**: WHMCS Admin → Settings → Payment Gateways → PayPal
- **Action**: Verify descriptor shows company name clearly

---

## 10. FUTURE ENHANCEMENTS

1. **Customer Pre-Notification Letter** - Send to customer when dispute filed
2. **UI for Dispute Processing** - Web form to select transaction, input dispute date
3. **Product-Specific Templates** - Paisley Plus, Neighborhood Command variants
4. **Webhook Automation** - Auto-trigger on PayPal dispute notification
5. **Win/Loss Tracking** - Record outcomes for optimization

---

## 11. DISCOVERY QUESTIONS FOR FUTURE TEMPLATES

### Paisley Plus (Subscription)
- What's the cancellation policy?
- Is there a trial period?
- What usage evidence exists? (logins, reports, exports)
- Typical dispute: 3-4 months clawback

### General
- Should customer letter go out before or after evidence package?
- Email only or also SMS/phone outreach?

---

## CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/27/2025 | Initial SOP created from v12 development. Comprehensive documentation of all queries, data sources, technical rules, and integration gaps. |

---

*File: SOP_ListingCommand_ChargebackDefense_v1.md*
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*


