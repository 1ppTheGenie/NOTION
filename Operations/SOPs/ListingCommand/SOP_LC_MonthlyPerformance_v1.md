# SOP: LC Monthly Performance Report
**Version:** 1.2  
**Created:** 2025-12-11  
**Updated:** 2025-12-11  
**Status:** Active

---

## 1. Purpose

Generate a monthly Listing Command performance report showing all LC orders executed, their SMS/click performance, CTA conversions, revenue, costs, and profit.

---

## 2. Prerequisites

- Database access to FarmGenie and MlsListing databases
- Python with pandas, pyodbc
- Connection credentials (see DATABASE_ACCESS_GUIDE.md)

---

## 3. Report Specifications

| Attribute | Value |
|-----------|-------|
| Report Name | Genie_LC_MonthlyPerformance_MM-YYYY_vN.csv |
| Columns | 20 |
| Primary Key | Order_ID (ListingCommandQueueId) |
| Spec Document | SPEC_LC_MonthlyPerformance_v2.md |

---

## 4. Data Sources

### Primary Tables (FarmGenie)
| Table | Purpose |
|-------|---------|
| ListingCommandQueue | Order records |
| ListingCommandConfiguration | Channel targets, costs |
| ListingCommandBilling | MultiStatusOrdered (1/2/3) |
| AspNetUserProfiles | Customer names |
| SmsReportSendQueue | SMS batch tracking (SourceMlsNumber key) |
| ViewSmsQueueSendSummary | SMS counts |
| SmsReportMessageQueuedLog | Links to ShortUrlData |
| ShortUrlData | Click counts (AccessCount) |
| ShortUrlDataLead | Links to GenieLead |
| GenieLead | Lead records |
| GenieLeadTag | CTA/Opt-out tags |

### Secondary Database (MlsListing)
| Table | Purpose |
|-------|---------|
| Listing | Property addresses |

---

## 5. Critical Implementation Notes

### Click Calculation (CRITICAL!)
**Clicks = Leads Created** = COUNT(DISTINCT GenieLeadId)

**DO NOT use AccessCount** - that counts page views, not actual clicks!

```sql
SELECT srsq.SourceMlsNumber, COUNT(DISTINCT gl.GenieLeadId) as Clicks
FROM SmsReportSendQueue srsq
INNER JOIN SmsReportMessageQueuedLog srmql 
    ON srsq.SmsReportSendQueueId = srmql.SmsReportSendQueueId
INNER JOIN ShortUrlDataLead sudl 
    ON srmql.ShortUrlDataId = sudl.ShortUrlDataId
INNER JOIN GenieLead gl 
    ON sudl.GenieLeadId = gl.GenieLeadId
WHERE srsq.UtmSource = 'Listing Command'
  AND srsq.CreateDate >= @StartDate AND srsq.CreateDate < @EndDate
GROUP BY srsq.SourceMlsNumber
```

**Expected CTR Range:** 2-5%  
**If CTR > 10%:** Click calculation is WRONG!

### LeadTagTypeIds
- **48** = OptInContact → CTA_Submitted
- **51** = OptOutSms → Opt_Outs
- **52** = CtaContactVerified → CTA_Verified

### Order Status Count
From `ListingCommandBilling.MultiStatusOrdered`:
- 1 = Single status order
- 2 = Double status order
- 3 = Trifecta (all three statuses)

---

## 6. Execution Steps

1. **Set month parameters**
   ```python
   MONTH = "2025-11"
   START_DATE = "2025-11-01"
   END_DATE = "2025-12-01"
   ```

2. **Run report script**
   ```bash
   cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS
   python build_lc_performance_v10.py
   ```

3. **Verify output**
   - Check row count matches expected orders
   - Verify CTR is in 2-5% range
   - Confirm revenue totals

4. **Save report**
   - File: `Genie_LC_MonthlyPerformance_MM-YYYY_v10.csv`
   - Location: `REPORTS` folder

---

## 7. Output Columns (21)

| # | Column | Format |
|---|--------|--------|
| 1 | Order_ID | Integer |
| 2 | Customer_Name | Text |
| 3 | MLS_Number | Text |
| 4 | Property_Address | Text |
| 5 | Order_Status_Count | 1/2/3 |
| 6 | Execution_Status | Active/Pending/Sold |
| 7 | Order_Date | MM-DD-YYYY |
| 8 | Execution_Date | MM-DD-YYYY |
| 9 | Channel | SMS/Facebook/DirectMail |
| 10 | Channel_Target | Integer |
| 11 | Msgs_Sent | Integer |
| 12 | Clicks | Integer |
| 13 | CTR_Pct | XX.X% |
| 14 | CTA_Submitted | Integer |
| 15 | CTA_Verified | Integer |
| 16 | Opt_Outs | Integer |
| 17 | Opt_Out_Pct | X.XX% |
| 18 | Revenue_Charged | $X,XXX.XX |
| 19 | Twilio_Cost | $X.XX |
| 20 | Profit | $X,XXX.XX |
| 21 | Profit_Pct | XX.X% |

---

## 8. Quality Checks

- [ ] CTR between 10-30%
- [ ] All addresses populated
- [ ] Revenue = Channel_Target × CostPerUnit
- [ ] Profit = Revenue - Twilio_Cost
- [ ] No duplicate Order_IDs (unless multi-channel)

---

## 9. November 2025 Benchmark

| Metric | Value |
|--------|-------|
| Total Rows | 22 (includes multi-channel orders) |
| Unique Orders | 21 |
| Unique Listings | 18 |
| Unique Customers | 14 |
| Total SMS | 3,050 |
| Total Clicks (Leads Created) | 77 |
| Overall CTR | 2.5% |
| Total CTA Submitted | 10 |
| Total CTA Verified | 6 |
| Total Opt-Outs | 2 |
| Total Revenue | ~$1,900 |
| Total Twilio Cost | ~$55 |
| Total Profit | ~$1,845 |

---

## 10. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2025-12-11 | Initial SOP based on v7 script |
| v1.1 | 2025-12-11 | Added Profit_Pct column (21 columns total) |
| v1.2 | 2025-12-11 | **CRITICAL FIX**: Clicks = COUNT(DISTINCT GenieLeadId), updated CTR to 2-5%, fixed benchmarks |

