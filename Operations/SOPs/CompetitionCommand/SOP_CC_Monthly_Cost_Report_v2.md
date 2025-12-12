# SOP: Competition Command Monthly Cost Report

**Version:** 2.0  
**Created:** 2025-12-10  
**Updated:** 2025-12-10  
**Status:** Active

---

## 1. Purpose

Generate accurate monthly cost reports for Competition Command by allocating actual Twilio invoice costs proportionally based on SMS message volume.

---

## 2. Methodology Change (V2)

### Previous Method (V1) - DEPRECATED
- Estimated costs using fixed per-segment rates ($0.0083 × 1.5 segment multiplier)
- Result: **$333.24** for November 2025 (underestimate)

### Current Method (V2) - ACTIVE
- Uses actual Twilio invoice amounts
- Allocates variable SMS costs proportionally by message count
- Result: **$360.78** for November 2025 (accurate)

**Why V2 is Better:**
- Based on actual invoiced costs, not estimates
- Includes all carrier fees automatically
- Accounts for real segment ratios
- Reconciles to invoice within 0.1%

---

## 3. Data Sources

### 3.1 Invoice Data
**Location:** `C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\_invoices_11-14-2025\`

**Extract from invoice:**
```python
# Variable SMS Cost = Outbound Base + Carrier Fees
outbound_base = df[(df['Item Group'] == 'Programmable Messaging') & 
                   (df['Item'].str.contains('Outbound')) & 
                   (~df['Item'].str.contains('Carrier Fee'))]['Amt'].sum()

carrier_fees = df[(df['Item Group'] == 'Programmable Messaging') & 
                  (df['Item'].str.contains('Carrier Fee'))]['Amt'].sum()

variable_sms_cost = outbound_base + carrier_fees
```

### 3.2 Marketing SMS Counts
**Table:** `SmsReportSendQueue` + `ViewSmsQueueSendSummary`

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

### 3.3 System SMS Counts
**Table:** `NotificationQueue`

```sql
SELECT COUNT(*) as SMS
FROM NotificationQueue nq WITH (NOLOCK)
WHERE nq.NotificationChannelId = 1 
  AND nq.ProcessDate >= @StartDate 
  AND nq.ProcessDate < @EndDate
```

---

## 4. Cost Allocation Formula

```
Total SMS = Marketing SMS + System SMS

CC Percentage = CC SMS / Total SMS

CC Cost = Variable SMS Cost × CC Percentage
```

### Example (November 2025):
```
Total SMS:          28,206
CC SMS:             19,875
CC Percentage:      70.5%

Variable SMS Cost:  $512.01
CC Cost:            $512.01 × 0.705 = $360.78
```

---

## 5. Report Columns

| Column | Description |
|--------|-------------|
| Month | YYYY-MM format |
| CC_Campaigns | Number of CC batches sent |
| CC_SMS | Competition Command SMS count |
| CC_Pct | CC percentage of total SMS |
| CC_Cost | Allocated CC cost (from invoice) |
| LC_SMS | Listing Command SMS count |
| LC_Cost | Allocated LC cost |
| NC_SMS | Neighborhood Command SMS count |
| NC_Cost | Allocated NC cost |
| System_SMS | System notification SMS count |
| System_Cost | Allocated system cost |
| Total_SMS | Total SMS for month |
| Total_Variable_Cost | Total variable SMS from invoice |
| Total_Invoice | Complete invoice amount |
| Segment_Ratio | Invoice segments / DB messages |

---

## 6. Benchmark Data

### Monthly Trends (2025)

| Month | CC SMS | CC Cost | Total Invoice |
|-------|--------|---------|---------------|
| October | 17,850 | $320.22 | $677.54 |
| November | 19,875 | $360.78 | $722.89 |

### Expected Ranges

| Metric | Typical Range |
|--------|---------------|
| CC % of Total SMS | 65-75% |
| CC Monthly Cost | $300-400 |
| Segment Ratio | 1.5-1.6x |
| Total Invoice | $650-750 |

---

## 7. Script Execution

### Primary Script
`build_cc_monthly_cost_v2.py`

### Location
`C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\`

### Run Command
```powershell
cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS
python build_cc_monthly_cost_v2.py
```

### Output
`Genie_CC_MonthlyCost_InvoiceBased_YYYY-MM-DD_v2.xlsx`

---

## 8. Adding New Months

### Step 1: Download Invoice
1. Log into Twilio Console
2. Navigate to Billing → Invoices
3. Download CSV for the month
4. Save to invoice directory

### Step 2: Update Invoice Mapping
Add entry to `INVOICE_FILES` dictionary in script:
```python
INVOICE_FILES = {
    ...
    '2025-12': 'invoices/csv/ACe8281c...-2025-12-IV...csv',
}
```

### Step 3: Update Months to Run
```python
months_to_run = ['2025-10', '2025-11', '2025-12']
```

### Step 4: Execute Script
```powershell
python build_cc_monthly_cost_v2.py
```

---

## 9. Troubleshooting

### Invoice Not Found
- Verify invoice file exists in correct location
- Check filename matches pattern in `INVOICE_FILES`
- Ensure correct month format (YYYY-MM)

### SMS Counts Don't Match
- Verify date range filters
- Check for timezone differences
- Confirm `UtmSource` values match expected services

### Cost Variance > 1%
- Review invoice for unusual line items
- Check for subaccount activity
- Verify no SMS types are missing from counts

---

## 10. Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial version with estimated rates |
| 2.0 | 2025-12-10 | Updated to invoice-based allocation |

---

## 11. Related Documents

- `SOP_Twilio_Invoice_Reconciliation_v1.md` - Master reconciliation process
- `SPEC_CompCommand_MonthlyCostReport_v2.md` - Technical specification

