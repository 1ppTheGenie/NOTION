# Competition Command Monthly Cost Report Specification
## Version 2.0 | December 2025 | PRODUCTION

---

## 1. Report Overview

### Purpose
The Competition Command Monthly Cost Report provides a comprehensive audit of SMS campaign activity, engagement metrics, and Twilio costs for the Competition Command (FarmCast) service. This report enables billing reconciliation, performance monitoring, and customer usage tracking.

### Report Naming Convention
```
Genie_CompCommand_CostsByMonth_[MM]-[YYYY]_v[#].csv
```
Example: `Genie_CompCommand_CostsByMonth_11-2025_v1.csv`

### Generation Time
Target: **< 2 minutes** using live SQL queries

---

## 2. Report Structure

### Output Format
- **File Type:** CSV (Google Sheets compatible)
- **Encoding:** UTF-8
- **Delimiter:** Comma

### Column Order (16 columns)

| # | Column Name | Data Type | Example | Source |
|---|-------------|-----------|---------|--------|
| 1 | Month | String | "November 2025" | Input parameter |
| 2 | Customer_Name | String | "Mike Chiesl" | AspNetUserProfiles.FirstName + LastName |
| 3 | Area_Name | String | "92028" | AreaId |
| 4 | Campaigns | Integer | 17 | COUNT(PropertyCollectionDetail) |
| 5 | Msgs_Sent | Integer | 1125 | SUM(ViewSmsQueueSendSummary.Count) |
| 6 | Delivered | Integer | 1005 | SUM where ResponseCode = 1 |
| 7 | Success% | Percentage | "89.3%" | Delivered / Msgs_Sent × 100 |
| 8 | Clicks | Integer | 110 | SUM(ShortUrlData.AccessCount) |
| 9 | CTR% | Percentage | "9.78%" | Clicks / Msgs_Sent × 100 |
| 10 | CTA_Submitted | Integer | 6 | COUNT(GenieLeadTag where LeadTagTypeId = 48) |
| 11 | CTA_Verified | Integer | 2 | COUNT(GenieLeadTag where LeadTagTypeId = 52) |
| 12 | Agent_Notify | Integer | 0 | **I2 Placeholder** |
| 13 | Agent_Notify_Cost | Currency | "$0.00" | **I2 Placeholder** |
| 14 | Opt_Outs | Integer | 0 | COUNT(GenieLeadTag where LeadTagTypeId = 51) |
| 15 | Opt_Out% | Percentage | "0.00%" | Opt_Outs / Msgs_Sent × 100 |
| 16 | Twilio_Cost | Currency | "$18.68" | Msgs_Sent × $0.0166 (estimated) |

---

## 3. Competition Command Filter

### CRITICAL: ProductType, NOT TriggerType

```sql
WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command
```

**Competition Command uses BOTH trigger types:**
- **TriggerType 1 (ListingSold):** "A home just SOLD near you"
- **TriggerType 2 (ListingNew):** "A new listing near you"

**DO NOT filter by TriggerTypeId** - this excludes valid CC campaigns.

---

## 4. Data Sources

### 4.1 Campaign Counts
```sql
SELECT 
    pcd.AspNetUserId,
    pcd.AreaId,
    COUNT(DISTINCT pcd.PropertyCollectionDetailId) AS Campaigns
FROM PropertyCollectionDetail pcd
INNER JOIN PropertyCastWorkflowQueue pcwq ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
INNER JOIN PropertyCast pc ON pc.PropertyCastId = pcwq.PropertyCastId
WHERE pc.PropertyCastTypeId = 1
  AND pcd.CreateDate >= @StartDate AND pcd.CreateDate < @EndDate
GROUP BY pcd.AspNetUserId, pcd.AreaId
```

### 4.2 SMS Counts (ACTUAL DATA)
```sql
SELECT 
    srsq.AreaId,
    SUM(vsqs.Count) AS Msgs_Sent,
    SUM(CASE WHEN vsqs.Responsecode = 1 THEN vsqs.Count ELSE 0 END) AS Delivered
FROM SmsReportSendQueue srsq
INNER JOIN ViewSmsQueueSendSummary vsqs ON vsqs.SmsReportSendQueueId = srsq.SmsReportSendQueueId
WHERE srsq.CreateDate >= @StartDate AND srsq.CreateDate < @EndDate
GROUP BY srsq.AreaId
```

### 4.3 Click Data
```sql
SELECT 
    gl.AreaId,
    SUM(sud.AccessCount) AS Clicks
FROM ShortUrlData sud
INNER JOIN ShortUrlDataLead sudl ON sudl.ShortUrlDataId = sud.ShortUrlDataId
INNER JOIN GenieLead gl ON gl.GenieLeadId = sudl.GenieLeadId
WHERE sud.CreateDate >= @StartDate AND sud.CreateDate < @EndDate
GROUP BY gl.AreaId
```

### 4.4 CTA & Opt-Out Tags
```sql
SELECT 
    gl.AreaId,
    SUM(CASE WHEN glt.LeadTagTypeId = 48 THEN 1 ELSE 0 END) AS CTA_Submitted,
    SUM(CASE WHEN glt.LeadTagTypeId = 52 THEN 1 ELSE 0 END) AS CTA_Verified,
    SUM(CASE WHEN glt.LeadTagTypeId = 51 THEN 1 ELSE 0 END) AS Opt_Outs
FROM GenieLeadTag glt
INNER JOIN GenieLead gl ON gl.GenieLeadId = glt.GenieLeadId
WHERE glt.CreateDate >= @StartDate AND glt.CreateDate < @EndDate
  AND glt.LeadTagTypeId IN (48, 51, 52)
GROUP BY gl.AreaId
```

---

## 5. Tag Type Reference

| LeadTagTypeId | Tag Name | Report Column |
|---------------|----------|---------------|
| 48 | OptInContact | CTA_Submitted |
| 51 | OptOutSms | Opt_Outs |
| 52 | CtaContactVerfied | CTA_Verified |

**Note:** Database has typo "Verfied" not "Verified"

---

## 6. Sample Output

```csv
Month,Customer_Name,Area_Name,Campaigns,Msgs_Sent,Delivered,Success%,Clicks,CTR%,CTA_Submitted,CTA_Verified,Agent_Notify,Agent_Notify_Cost,Opt_Outs,Opt_Out%,Twilio_Cost
November 2025,Mike Chiesl,92028,17,1125,1005,89.3%,110,9.78%,6,2,0,$0.00,0,0.00%,$18.68
November 2025,David Higgins,94611,34,1950,1712,87.8%,39,2.00%,4,1,0,$0.00,7,0.36%,$32.37
```

---

## 7. Iteration 2 Enhancements

| Feature | Current (I1) | Planned (I2) |
|---------|--------------|--------------|
| Agent_Notify | Placeholder (0) | Actual count from NotificationQueue |
| Agent_Notify_Cost | Placeholder ($0.00) | Actual Twilio costs |
| Twilio_Cost | Estimated ($0.0166/msg) | Actual from TwilioMessage table |
| Area_Name | Zip code only | City + Zip format |

---

## 8. Script Location

```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\build_cc_monthly_cost_v1.py
```

---

## 9. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | Dec 2025 | Original spec with estimates |
| **v2.0** | **Dec 2025** | **Production version with live SQL data, corrected PropertyCastTypeId filter** |

---

*Document Version: 2.0*
*Last Updated: December 10, 2025*

