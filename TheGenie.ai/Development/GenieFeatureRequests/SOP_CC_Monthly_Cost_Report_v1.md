# SOP: CC Monthly Cost Report Generation

**Version:** 1.0  
**Created:** 2025-12-10  
**Last Updated:** 2025-12-10  
**Author:** Cursor AI  
**Status:** Production Ready (Iteration 1)

---

## 1. Purpose

Standard Operating Procedure for generating the Competition Command (CC) Monthly Cost Report with live SQL data, providing campaign activity, engagement metrics, and estimated costs by customer and area for a specific month.

---

## 2. Report Specifications

### 2.1 Output File Naming
```
Genie_CompCommand_CostsByMonth_[MM]-[YYYY]_v1.csv
```
**Examples:**
- `Genie_CompCommand_CostsByMonth_01-2025_v1.csv`
- `Genie_CompCommand_CostsByMonth_10-2025_v1.csv`
- `Genie_CompCommand_CostsByMonth_11-2025_v1.csv`

### 2.2 Column Order (16 columns)

| # | Column | Type | Example | Description |
|---|--------|------|---------|-------------|
| 1 | Month | string | November 2025 | Full month name + year |
| 2 | Customer_Name | string | Mike Chiesl | Full name from AspNetUserProfiles |
| 3 | Area_Name | string | 92028 | Area/zip code |
| 4 | Campaigns | int | 17 | Count of CC campaigns in month |
| 5 | Msgs_Sent | int | 1125 | Total SMS messages sent |
| 6 | Delivered | int | 1005 | Successfully delivered messages |
| 7 | Success% | string | 89.3% | Delivered / Msgs_Sent × 100 |
| 8 | Clicks | int | 110 | Total link clicks |
| 9 | CTR% | string | 9.78% | Clicks / Msgs_Sent × 100 |
| 10 | CTA_Submitted | int | 6 | Leads with OptInContact tag (ID 48) |
| 11 | CTA_Verified | int | 2 | Leads with CtaContactVerfied tag (ID 52) |
| 12 | Agent_Notify | int | 0 | **Placeholder for I2** |
| 13 | Agent_Notify_Cost | string | $0.00 | **Placeholder for I2** |
| 14 | Opt_Outs | int | 0 | Leads with OptOutSms tag (ID 51) |
| 15 | Opt_Out% | string | 0.00% | Opt_Outs / Msgs_Sent × 100 |
| 16 | Twilio_Cost | string | $18.68 | Estimated: Msgs_Sent × $0.0166 |

---

## 3. Data Sources

### 3.1 Campaign Data
```sql
FROM PropertyCollectionDetail pcd
INNER JOIN PropertyCastWorkflowQueue pcwq ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
INNER JOIN PropertyCast pc ON pc.PropertyCastId = pcwq.PropertyCastId
WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command
  AND pcd.CreateDate >= @StartDate AND pcd.CreateDate < @EndDate
GROUP BY pcd.AspNetUserId, pcd.AreaId
```

### 3.2 SMS Data (Actual Counts)
```sql
FROM SmsReportSendQueue srsq
INNER JOIN ViewSmsQueueSendSummary vsqs ON vsqs.SmsReportSendQueueId = srsq.SmsReportSendQueueId
WHERE srsq.CreateDate >= @StartDate AND srsq.CreateDate < @EndDate
GROUP BY srsq.AreaId
```

### 3.3 Click Data
```sql
FROM ShortUrlData sud
INNER JOIN ShortUrlDataLead sudl ON sudl.ShortUrlDataId = sud.ShortUrlDataId
INNER JOIN GenieLead gl ON gl.GenieLeadId = sudl.GenieLeadId
WHERE sud.CreateDate >= @StartDate AND sud.CreateDate < @EndDate
GROUP BY gl.AreaId
```

### 3.4 CTA/Opt-Out Tags
```sql
FROM GenieLeadTag glt
INNER JOIN GenieLead gl ON gl.GenieLeadId = glt.GenieLeadId
WHERE glt.CreateDate >= @StartDate AND glt.CreateDate < @EndDate
  AND glt.LeadTagTypeId IN (48, 51, 52)  -- OptInContact, OptOutSms, CtaContactVerfied
GROUP BY gl.AreaId
```

---

## 4. Key Business Rules

### 4.1 Competition Command Filter
- **Product Type:** `PropertyCastTypeId = 1` (FarmCast)
- **Includes:** BOTH `ListingSold (1)` AND `ListingNew (2)` trigger types

### 4.2 Date Range
- **Start:** First day of month at 00:00:00
- **End:** First day of next month at 00:00:00 (exclusive)
- **Example:** November 2025 → `>= '2025-11-01' AND < '2025-12-01'`

### 4.3 Grouping
- One row per **Customer + Area** combination for the month

### 4.4 Tag Type IDs
| ID | Tag Name | Report Column |
|----|----------|---------------|
| 48 | OptInContact | CTA_Submitted |
| 51 | OptOutSms | Opt_Outs |
| 52 | CtaContactVerfied | CTA_Verified |

---

## 5. Execution

### 5.1 Prerequisites
- Python 3.x with `pandas`, `pyodbc`
- Network access to SQL Server (192.168.29.45)
- Database credentials configured

### 5.2 Run Command
```powershell
cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS
python build_cc_monthly_cost_v1.py
```

### 5.3 Run Single Month
```python
from build_cc_monthly_cost_v1 import generate_monthly_report
df = generate_monthly_report(2025, 10)  # October 2025
```

### 5.4 Output Location
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\
```

---

## 6. Sample Output

### November 2025 (16 rows, 9 customers)
```csv
Month,Customer_Name,Area_Name,Campaigns,Msgs_Sent,Delivered,Success%,Clicks,CTR%,CTA_Submitted,CTA_Verified,Agent_Notify,Agent_Notify_Cost,Opt_Outs,Opt_Out%,Twilio_Cost
November 2025,Mike Chiesl,92028,17,1125,1005,89.3%,110,9.78%,6,2,0,$0.00,0,0.00%,$18.68
November 2025,David Higgins,94611,34,1950,1712,87.8%,39,2.00%,4,1,0,$0.00,7,0.36%,$32.37
```

---

## 7. Quality Assurance Checklist

Before delivery, verify:

- [ ] Column headers match spec exactly (16 columns)
- [ ] Month format is "Month YYYY" (e.g., "November 2025")
- [ ] Percentage columns include % symbol
- [ ] Currency columns include $ symbol
- [ ] No negative values
- [ ] CTR% and Success% are reasonable (0-100%)
- [ ] All customers have campaigns > 0

---

## 8. Iteration 2 Enhancements (Planned)

| Column | Current | I2 Enhancement |
|--------|---------|----------------|
| Agent_Notify | Placeholder (0) | Actual agent SMS notification count |
| Agent_Notify_Cost | Placeholder ($0.00) | Actual Twilio cost for agent notifications |
| Twilio_Cost | Estimated ($0.0166/msg) | Actual Twilio costs from TwilioMessage table |
| Area_Name | Zip code only | City + Zip format (e.g., "Fallbrook 92028") |

---

## 9. Historical Metrics

| Month | Customers | Areas | Campaigns | Messages | Clicks | Avg CTR |
|-------|-----------|-------|-----------|----------|--------|---------|
| January 2025 | 18 | 44 | 1,078 | 81,264 | 8,438 | ~10.4% |
| October 2025 | 8 | 14 | 246 | 17,850 | 790 | ~4.4% |
| November 2025 | 9 | 16 | 322 | 20,075 | 741 | ~3.7% |

---

## 10. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2025-12-10 | Initial production release with live SQL data |

---

## 11. Related Documents

- `SPEC_CompCommand_MonthlyCostReport_v1.md` - Technical specification
- `SOP_CC_Ownership_Report_v2.md` - Ownership report with engagement metrics
- `build_cc_monthly_cost_v1.py` - Production script

---

## 12. Script Location

**Production Script:** 
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\build_cc_monthly_cost_v1.py
```

