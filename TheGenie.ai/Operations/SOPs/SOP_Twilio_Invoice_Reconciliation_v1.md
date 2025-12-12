# SOP: Twilio Invoice Reconciliation

**Version:** 1.0  
**Created:** 2025-12-10  
**Author:** Genie Analytics Team  
**Status:** Active

---

## 1. Purpose

This SOP defines the standard process for reconciling monthly Twilio invoices against database records to:
- Attribute SMS costs to specific Genie services (Competition Command, Listing Command, Neighborhood Command)
- Identify system/notification SMS costs
- Verify invoice accuracy
- Detect billing anomalies or cost leaks

---

## 2. Scope

Applies to all monthly Twilio invoices for the 1ParkPlace/Genie platform.

---

## 3. Prerequisites

### 3.1 Required Access
- SQL Server access to `FarmGenie` database
- Twilio invoice CSV files (downloaded from Twilio Console)

### 3.2 Required Tools
- Python 3.x with `pandas`, `pyodbc`, `openpyxl`
- Database connection string:
  ```
  DRIVER={ODBC Driver 17 for SQL Server};
  SERVER=192.168.29.45,1433;
  DATABASE=FarmGenie;
  UID=cursor;PWD=1ppINSAyay$;
  Encrypt=yes;TrustServerCertificate=yes
  ```

### 3.3 Invoice Location
- Download from Twilio Console → Billing → Invoices → Download CSV
- Store in: `C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\_invoices_11-14-2025\invoices\csv\`

---

## 4. Invoice Structure

### 4.1 Key Invoice Fields
| Field | Description |
|-------|-------------|
| `Project` | Filter to "All Accounts Combined" for summary |
| `Item Category` | "Service" or "Taxes" |
| `Item Group` | Cost category (Programmable Messaging, Phone Numbers, etc.) |
| `Item` | Specific line item description |
| `Quantity` | Units (segments, minutes, numbers) |
| `Amount (USD)` | Cost in dollars |

### 4.2 Item Group Categories
| Item Group | Type | Description |
|------------|------|-------------|
| Programmable Messaging | Variable | SMS/MMS costs |
| Phone Numbers | Fixed | Monthly phone number rental |
| Recording Storage | Fixed | Call recording storage |
| Lookups | Variable | Carrier lookups for number validation |
| Calls | Variable | Voice minutes |
| MMS Messages | Variable | MMS costs |
| MMS Messaging - Carrier Fees | Variable | MMS carrier surcharges |

---

## 5. Cost Categories

### 5.1 Variable SMS Costs
These costs scale with message volume:

| Cost Type | Invoice Item Contains | Description |
|-----------|----------------------|-------------|
| Outbound Base | "Outbound SMS" (not "Carrier Fee") | Per-segment Twilio charge |
| Carrier Fees | "Carrier Fee" | A2P/10DLC carrier surcharges |
| Inbound | "Inbound SMS" | Received messages |
| Failed | "Failed Message" | Failed delivery attempts |

**Formula:** `Variable SMS Cost = Outbound Base + Carrier Fees`

### 5.2 Fixed/Shared Costs
These are monthly fixed costs or shared across all services:

| Cost Type | Description | Typical Monthly |
|-----------|-------------|-----------------|
| Phone Numbers | 123 local + toll-free numbers | ~$144 |
| Recording Storage | Call recordings | ~$23 |
| Carrier Lookups | Number validation | ~$36 |
| Calls | Voice minutes | ~$1 |
| MMS | Multimedia messages | <$1 |
| Taxes | Regulatory fees | <$1 |
| Inbound SMS | Customer replies | ~$5 |

---

## 6. Database Data Sources

### 6.1 Marketing SMS (Campaign SMS)
**Table:** `SmsReportSendQueue` joined with `ViewSmsQueueSendSummary`

```sql
SELECT 
    srq.UtmSource as Service,
    SUM(v.Count) as SMS
FROM SmsReportSendQueue srq WITH (NOLOCK)
INNER JOIN ViewSmsQueueSendSummary v 
    ON srq.SmsReportSendQueueId = v.SmsReportSendQueueId
WHERE srq.CreateDate >= @StartDate 
  AND srq.CreateDate < @EndDate
GROUP BY srq.UtmSource
```

**Service Mapping:**
| UtmSource | Genie Service |
|-----------|---------------|
| Competition Command | Competition Command (CC) |
| Listing Command | Listing Command (LC) |
| Neighborhood Command | Neighborhood Command (NC) |

### 6.2 System/Notification SMS
**Table:** `NotificationQueue` joined with `NotificationType`

```sql
SELECT 
    nt.Description as Service,
    COUNT(*) as SMS
FROM NotificationQueue nq WITH (NOLOCK)
LEFT JOIN NotificationType nt 
    ON nq.NotificationTypeId = nt.NotificationTypeId
WHERE nq.NotificationChannelId = 1  -- SMS channel
  AND nq.ProcessDate >= @StartDate 
  AND nq.ProcessDate < @EndDate
GROUP BY nt.Description
```

**Common System Notification Types:**
| NotificationTypeId | Description | Purpose |
|-------------------|-------------|---------|
| 18 | FileRefreshReminder | Agent file refresh reminders |
| 24 | NewLead | New lead notifications |
| 63 | MarketReportAreaAgentSubscription | Market report alerts |
| 57 | MarketReportPartner | Partner report notifications |
| 60 | ListingCommanded | LC confirmation |
| 61 | ListingCommandedRecap | LC summary |

---

## 7. Reconciliation Process

### Step 1: Load Invoice
```python
df = pd.read_csv(INVOICE_FILE)
df_sum = df[df['Project'] == 'All Accounts Combined'].copy()
df_sum['Amt'] = df_sum['Amount (USD)'].str.replace('$','').str.replace(',','').astype(float)
```

### Step 2: Extract Cost Categories
```python
# Variable SMS
outbound_base = df_sum[(df_sum['Item Group'] == 'Programmable Messaging') & 
                       (df_sum['Item'].str.contains('Outbound', case=False)) & 
                       (~df_sum['Item'].str.contains('Carrier Fee', case=False))]['Amt'].sum()

carrier_fees = df_sum[(df_sum['Item Group'] == 'Programmable Messaging') & 
                      (df_sum['Item'].str.contains('Carrier Fee', case=False))]['Amt'].sum()

sms_var_cost = outbound_base + carrier_fees
```

### Step 3: Query Database for SMS Counts
Run queries from Section 6.1 and 6.2 for the invoice month.

### Step 4: Calculate Cost Allocation
```python
total_db_sms = marketing_sms + system_sms

# For each service:
service_pct = service_sms / total_db_sms
service_cost = sms_var_cost * service_pct
```

### Step 5: Verify Reconciliation
```
Calculated Total = Variable SMS + Fixed Costs
Difference = Calculated Total - Invoice Total
```

**Acceptable variance:** < 1% or < $5

---

## 8. Segment Ratio Analysis

Twilio bills by **segments** (160 chars per segment), not messages.

**Formula:** `Segment Ratio = Invoice Segments / DB Messages`

| Ratio | Interpretation |
|-------|----------------|
| 1.0x | All messages ≤160 chars |
| 1.5x | Average message ~240 chars (1.5 segments) |
| 2.0x | Average message ~320 chars (2 segments) |

**November 2025 Example:**
- Invoice Segments: 43,880
- DB Messages: 28,206
- Ratio: 1.56x (avg message = ~250 chars)

---

## 9. Output Report Format

### 9.1 File Naming
```
Genie_Twilio_Invoice_Recon_[MM]-[YYYY]_v[N].xlsx
```
Example: `Genie_Twilio_Invoice_Recon_11-2025_v1.xlsx`

### 9.2 Excel Sheets

**Sheet 1: SMS_By_Service**
| Column | Description |
|--------|-------------|
| Category | "Marketing" or "System" |
| Service | Service name |
| Messages | SMS count from database |
| Pct | Percentage of total |
| Cost | Allocated cost |

**Sheet 2: Invoice_Detail**
| Column | Description |
|--------|-------------|
| Item Group | Twilio category |
| Item | Line item description |
| Qty | Quantity |
| Amt | Amount (USD) |

---

## 10. Expected Cost Benchmarks (November 2025)

| Service | % of SMS | % of Variable Cost |
|---------|----------|-------------------|
| Competition Command | 70-75% | ~$350-400 |
| Listing Command | 10-15% | ~$50-75 |
| Neighborhood Command | 1-3% | ~$5-15 |
| System Notifications | 15-20% | ~$80-100 |

| Fixed Cost | Monthly Range |
|------------|---------------|
| Phone Numbers | $140-150 |
| Lookups | $30-40 |
| Recording Storage | $20-25 |
| Other | <$10 |

**Total Monthly Invoice:** $700-800 (typical)

---

## 11. Troubleshooting

### 11.1 High Variance (>5%)
1. Check for missing SMS in database queries
2. Verify date range matches invoice period
3. Look for new notification types not mapped
4. Check for subaccount activity

### 11.2 Missing SMS Data
- Marketing SMS not in `SmsReportSendQueue` → Check `PropertyCastWorkflowQueue`
- System SMS not in `NotificationQueue` → Check `TwilioMessage` table

### 11.3 Segment Ratio Too High (>2.0x)
- Review SMS templates for message length
- Check for concatenated messages or special characters

---

## 12. Script Location

**Primary Script:** `final_recon_nov_v1.py`  
**Location:** `C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\`

**To run:**
```powershell
cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS
python final_recon_nov_v1.py
```

---

## 13. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-10 | Analytics Team | Initial version |

---

## 14. Appendix: November 2025 Reconciliation Summary

```
INVOICE TOTAL:                      $722.89

VARIABLE SMS:
  Competition Command (19,875 msgs): $360.78
  Listing Command (3,050 msgs):      $55.37
  Neighborhood Command (500 msgs):   $9.08
  System Notifications (4,781 msgs): $86.79
  SUBTOTAL:                          $512.01

FIXED COSTS:
  Phone Numbers:                     $144.20
  Carrier Lookups:                   $36.24
  Recording Storage:                 $22.71
  Inbound SMS:                       $5.46
  Other:                             $3.11
  SUBTOTAL:                          $211.72

CALCULATED TOTAL:                    $723.73
DIFFERENCE:                          $0.84 (0.1%) ✅
```

