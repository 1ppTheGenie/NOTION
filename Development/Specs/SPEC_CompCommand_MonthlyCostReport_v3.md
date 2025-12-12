# Competition Command Monthly Cost Report Specification
## Version 3.0 | December 2025 | PRODUCTION

---

## 1. Report Overview

### Purpose
The Competition Command Monthly Cost Report provides accurate SMS campaign costs by allocating **actual Twilio invoice amounts** proportionally based on message volume. This ensures cost accuracy within 0.1% of invoiced amounts.

### Report Naming Convention
```
Genie_CompCommand_CostsByMonth_[MM]-[YYYY]_v[#].csv
```
Example: `Genie_CompCommand_CostsByMonth_11-2025_v1.csv`

### Generation Time
Target: **< 2 minutes** using live SQL queries + invoice data

---

## 2. Version 3 Changes

### CRITICAL UPDATE: Invoice-Based Cost Allocation

| Aspect | V2 (Deprecated) | V3 (Current) |
|--------|-----------------|--------------|
| Cost Method | Estimated ($0.0166/msg) | Actual invoice allocation |
| November CC Cost | $333.24 (wrong) | **$360.78** (correct) |
| Accuracy | ~8% underestimate | Within 0.1% of invoice |
| Carrier Fees | Partially included | Fully included |

### Cost Allocation Formula
```
Variable_SMS_Cost = Invoice Outbound Base + Invoice Carrier Fees

CC_Percentage = CC_SMS_Count / Total_SMS_Count

CC_Cost = Variable_SMS_Cost × CC_Percentage
```

---

## 3. Report Structure

### Output Format
- **File Type:** CSV (Google Sheets compatible)
- **Encoding:** UTF-8
- **Delimiter:** Comma

### Column Order (17 columns)

| # | Column Name | Data Type | Example | Source |
|---|-------------|-----------|---------|--------|
| 1 | Month | String | "November 2025" | Input parameter |
| 2 | Customer_Name | String | "Mike Chiesl" | AspNetUserProfiles.FirstName + LastName |
| 3 | Area_Name | String | "Fallbrook 92028" | ViewArea.Name or Fallback |
| 4 | Campaigns | Integer | 17 | COUNT(SmsReportSendQueue batches) |
| 5 | Msgs_Sent | Integer | 1125 | SUM(ViewSmsQueueSendSummary.Count) |
| 6 | Delivered | Integer | 1005 | SUM where ResponseCode = 1 |
| 7 | Success% | Percentage | "89.3%" | Delivered / Msgs_Sent × 100 |
| 8 | Clicks | Integer | 110 | SUM(ShortUrlData.AccessCount) |
| 9 | CTR% | Percentage | "9.78%" | Clicks / Msgs_Sent × 100 |
| 10 | CTA_Submitted | Integer | 6 | COUNT(GenieLeadTag LeadTagTypeId = 48) |
| 11 | CTA_Verified | Integer | 2 | COUNT(GenieLeadTag LeadTagTypeId = 52) |
| 12 | Agent_Notify | Integer | 0 | **I2 Placeholder** |
| 13 | Agent_Notify_Cost | Currency | "$0.00" | **I2 Placeholder** |
| 14 | Opt_Outs | Integer | 0 | COUNT(GenieLeadTag LeadTagTypeId = 51) |
| 15 | Opt_Out% | Percentage | "0.00%" | Opt_Outs / Msgs_Sent × 100 |
| 16 | Twilio_Cost | Currency | "$18.68" | **Invoice-Allocated** |
| 17 | Cost_Method | String | "Invoice" | Indicates allocation method |

---

## 4. Invoice Data Source

### Invoice Location
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\_invoices_11-14-2025\
```

### Invoice File Mapping
```python
INVOICE_FILES = {
    '2025-01': 'invoices/csv/ACe8281c...-2025-01-IV....csv',
    '2025-02': 'invoices/csv/ACe8281c...-2025-02-IV....csv',
    # ... through ...
    '2025-11': 'november_extract/invoices/csv/ACe8281c...-2025-11-IV....csv',
}
```

### Extracting Variable SMS Cost
```python
# Load invoice CSV
df = pd.read_csv(invoice_path)
df_sum = df[df['Project'] == 'All Accounts Combined'].copy()
df_sum['Amt'] = df_sum['Amount (USD)'].str.replace('$','').str.replace(',','').astype(float)

# Variable SMS = Outbound Base + Carrier Fees
outbound_base = df_sum[
    (df_sum['Item Group'] == 'Programmable Messaging') & 
    (df_sum['Item'].str.contains('Outbound', case=False)) & 
    (~df_sum['Item'].str.contains('Carrier Fee', case=False))
]['Amt'].sum()

carrier_fees = df_sum[
    (df_sum['Item Group'] == 'Programmable Messaging') & 
    (df_sum['Item'].str.contains('Carrier Fee', case=False))
]['Amt'].sum()

variable_sms_cost = outbound_base + carrier_fees
```

---

## 5. Database Data Sources

### 5.1 Marketing SMS Counts
**Tables:** `SmsReportSendQueue` + `ViewSmsQueueSendSummary`

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

**UtmSource Values:**
| UtmSource | Service |
|-----------|---------|
| Competition Command | CC |
| Listing Command | LC |
| Neighborhood Command | NC |

### 5.2 System SMS Counts
**Table:** `NotificationQueue`

```sql
SELECT COUNT(*) as SMS
FROM NotificationQueue nq WITH (NOLOCK)
WHERE nq.NotificationChannelId = 1  -- SMS
  AND nq.ProcessDate >= @StartDate 
  AND nq.ProcessDate < @EndDate
```

### 5.3 Total SMS for Allocation
```
Total_SMS = Marketing_SMS + System_SMS
```

---

## 6. Cost Allocation Logic

### Step 1: Get Invoice Variable Cost
```python
variable_sms_cost = outbound_base + carrier_fees
# November 2025: $364.21 + $147.80 = $512.01
```

### Step 2: Get Total SMS from Database
```python
cc_sms = 19,875      # Competition Command
lc_sms = 3,050       # Listing Command
nc_sms = 500         # Neighborhood Command
sys_sms = 4,781      # System Notifications
total_sms = 28,206
```

### Step 3: Calculate Percentage & Allocate
```python
cc_pct = cc_sms / total_sms  # 70.5%
cc_cost = variable_sms_cost * cc_pct  # $512.01 × 0.705 = $360.78
```

---

## 7. Competition Command Filter

### CRITICAL: PropertyCastTypeId, NOT TriggerTypeId

```sql
WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command
```

**Competition Command uses BOTH trigger types:**
- **TriggerType 1 (ListingSold):** "A home just SOLD near you"
- **TriggerType 2 (ListingNew):** "A new listing near you"

**DO NOT filter by TriggerTypeId** - this excludes valid CC campaigns.

---

## 8. Benchmark Data

### Monthly Cost Trends (2025)

| Month | CC SMS | CC % | Variable Cost | CC Cost |
|-------|--------|------|---------------|---------|
| October | 17,850 | 68.4% | $468.20 | $320.22 |
| November | 19,875 | 70.5% | $512.01 | $360.78 |

### Expected Ranges

| Metric | Typical Range |
|--------|---------------|
| CC % of Total SMS | 65-75% |
| CC Monthly Cost | $300-400 |
| Segment Ratio | 1.5-1.6x |

---

## 9. Sample Output

```csv
Month,Customer_Name,Area_Name,Campaigns,Msgs_Sent,Delivered,Success%,Clicks,CTR%,CTA_Submitted,CTA_Verified,Agent_Notify,Agent_Notify_Cost,Opt_Outs,Opt_Out%,Twilio_Cost,Cost_Method
November 2025,Mike Chiesl,Fallbrook 92028,17,1125,1005,89.3%,110,9.78%,6,2,0,$0.00,0,0.00%,$18.68,Invoice
November 2025,David Higgins,Oakland 94611,34,1950,1712,87.8%,39,2.00%,4,1,0,$0.00,7,0.36%,$32.37,Invoice
```

---

## 10. Script Location

**Primary Script:** `build_cc_monthly_cost_v2.py`

```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\
```

**Run Command:**
```powershell
cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS
python build_cc_monthly_cost_v2.py
```

---

## 11. Iteration 2 Enhancements (Planned)

| Feature | Current (I1) | Planned (I2) |
|---------|--------------|--------------|
| Agent_Notify | Placeholder (0) | Actual count from NotificationQueue |
| Agent_Notify_Cost | Placeholder ($0.00) | Invoice-allocated |
| Per-Customer Cost | Monthly total only | Breakdown by customer |

---

## 12. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | Dec 2025 | Original spec with estimates |
| v2.0 | Dec 2025 | Live SQL data, PropertyCastTypeId filter |
| **v3.0** | **Dec 2025** | **Invoice-based cost allocation** |

---

*Document Version: 3.0*  
*Last Updated: December 10, 2025*

