# LC Monthly Performance Report Specification
## Version 2.2 | December 2025 | PRODUCTION

---

## 1. Report Overview

**Purpose:** Track all Listing Command campaign executions by month, showing revenue, costs, profit, and performance metrics.

**Product:** Listing Command (LC)  
**Frequency:** Monthly  
**Output:** CSV/Excel

---

## 2. Listing Command Data Model

### Order Structure (from source code study)
```
1 ORDER = 1 LISTING (MlsNumber) + 1-3 STATUS SELECTIONS
│
├── Customer places order for their listing
├── Selects 1, 2, or 3 statuses to market:
│     • Active (1) - market when listing goes active
│     • Pending (3) - market when listing goes pending  
│     • Sold (2) - market when listing sells
│
└── For EACH STATUS selected:
      ├── Creates 1 ListingCommandQueue record
      │     └── ListingStatusId = 1, 2, or 3
      │
      └── Each Queue links to 1 ListingCommandConfiguration
            ├── SmsTarget (count of SMS to send)
            ├── DirectMailTarget (count of mailers)
            └── FacebookTarget (count for Facebook ads)
```

### Billing Model ("Set It and Forget It")
- Customer is charged PER STATUS EXECUTION, not at order time
- A 3-status order today may execute over 3+ months as listing progresses
- Each execution = 1 row in the report for that month
- Report shows which level of a multi-status order is executing

---

## 3. Column Specification

| # | Column Name | Description | Source |
|---|-------------|-------------|--------|
| 1 | Customer_Name | Agent who placed the order | AspNetUserProfiles |
| 2 | MLS_Number | Listing MLS number | ListingCommandQueue.MlsNumber |
| 3 | Property_Address | Full mailable address | MlsListing.Listing |
| 4 | Order_Status_Count | 1=Single, 2=Double, 3=Trifecta | ListingCommandBilling.MultiStatusOrdered |
| 5 | Execution_Status | Which status triggered (Active/Pending/Sold) | ListingCommandQueue.ListingStatusId |
| 6 | Order_Date | When customer placed the order | ListingCommandQueue.CreateDate |
| 7 | Execution_Date | When this status triggered | ListingCommandQueue.ProcessedDate |
| 8 | Channel | Marketing channel (SMS/FB/DM) | ListingCommandConfiguration |
| 9 | Channel_Target | Number ordered for this channel | ListingCommandConfiguration.*Target |
| 10 | Msgs_Sent | Actual SMS delivered | SmsReportSendQueue + ViewSmsQueueSendSummary grouped by SourceMlsNumber |
| 11 | Clicks | Leads created (clicked through) | COUNT(DISTINCT GenieLeadId) via ShortUrlDataLead |
| 12 | CTR_Pct | Click-through rate | Calculated: Clicks / Msgs_Sent (expect 2-5% range) |
| 13 | CTA_Submitted | Landing page submissions | GenieLeadTag (LeadTagTypeId=48 OptInContact) |
| 14 | CTA_Verified | Verified leads | GenieLeadTag (LeadTagTypeId=52 CtaContactVerified) |
| 15 | Opt_Outs | Unsubscribes | GenieLeadTag (LeadTagTypeId=51 OptOutSms) |
| 16 | Opt_Out_Pct | Opt-out rate | Calculated: Opt_Outs / Msgs_Sent |
| 17 | Revenue_Charged | What we charged customer | Channel_Target × CostPerUnit |
| 18 | Twilio_Cost | Our SMS cost | Invoice-based allocation |
| 19 | Profit | Net profit | Revenue - Twilio_Cost |
| 20 | Profit_Pct | Profit margin | (Profit / Revenue) × 100 |

---

## 4. Row Logic

**One row per CHANNEL EXECUTION:**
- If a customer ordered SMS + FB + DM for "Sold" status, when the listing sells:
  - Row 1: SMS execution
  - Row 2: FB execution  
  - Row 3: DM execution

**Multi-status orders across months:**
- Order placed Oct 1 for Active + Pending + Sold
- Oct report: 1 row for Active execution (shows "3-status order, Active")
- Nov report: 1 row for Pending execution (shows "3-status order, Pending")
- Dec report: 1 row for Sold execution (shows "3-status order, Sold")

---

## 5. Data Sources

| Table | Purpose |
|-------|---------|
| ListingCommandQueue | Order records, status, dates |
| ListingCommandConfiguration | Channel targets and costs |
| ListingCommandBilling | MultiStatusOrdered (1/2/3) |
| AspNetUserProfiles | Customer first/last name |
| MlsListing.Listing | Property address |
| SmsReportSendQueue | SMS batch tracking |
| ViewSmsQueueSendSummary | SMS counts |
| SmsReportMessageQueuedLog | Links to ShortUrlData |
| ShortUrlData | Click tracking |
| ShortUrlDataLead | Lead tracking |
| GenieLeadTag | CTA submissions, opt-outs |

---

## 6. SQL Join Path for Performance Metrics

```
ListingCommandQueue
  → ListingCommandConfiguration (channels)
  → ListingCommandBilling (order level)
  → SmsReportSendQueue (via MlsNumber + date range)
    → ViewSmsQueueSendSummary (SMS counts)
    → SmsReportMessageQueuedLog (message IDs)
      → ShortUrlData (clicks)
      → ShortUrlDataLead (leads)
        → GenieLeadTag (CTA/opt-out tags)
```

---

## 7. File Naming Convention

```
Genie_ListingCommand_CostsByMonth_MM-YYYY_vN.csv
```

Example: `Genie_ListingCommand_CostsByMonth_11-2025_v5.csv`

---

## 8. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1 | 2025-12-10 | Initial spec with basic columns |
| v2 | 2025-12-10 | Added Property Address, performance metrics |
| v3 | 2025-12-10 | Added Revenue, Profit, Channel column |
| v4 | 2025-12-10 | Fixed data model understanding |
| v5 | 2025-12-10 | Added Order_Status_Count, Execution_Status, per-channel rows |
| v6 | 2025-12-11 | Fixed LeadTagTypeIds (48=CTA, 51=OptOut, 52=Verified) |
| v7 | 2025-12-11 | **CRITICAL FIX**: Clicks must be grouped by SourceMlsNumber, not per-message |
| v7.1 | 2025-12-11 | Added Profit_Pct column (profit margin) |
| v9 | 2025-12-11 | **CRITICAL FIX**: Clicks = COUNT(DISTINCT GenieLeadId), not AccessCount |

---

## 9. Critical Implementation Notes

### Click Calculation (CRITICAL!)
**Clicks = Leads Created** = COUNT(DISTINCT GenieLeadId)

**WRONG** - AccessCount = page views, NOT clicks:
```sql
SELECT SUM(sud.AccessCount) as Clicks  -- WRONG! This is page views
FROM ShortUrlData sud
```

**CORRECT** - Count unique leads created (people who clicked through):
```sql
SELECT srsq.SourceMlsNumber, COUNT(DISTINCT gl.GenieLeadId) as Clicks
FROM SmsReportSendQueue srsq
INNER JOIN SmsReportMessageQueuedLog srmql ON srsq.SmsReportSendQueueId = srmql.SmsReportSendQueueId
INNER JOIN ShortUrlDataLead sudl ON srmql.ShortUrlDataId = sudl.ShortUrlDataId
INNER JOIN GenieLead gl ON sudl.GenieLeadId = gl.GenieLeadId
WHERE srsq.UtmSource = 'Listing Command'
GROUP BY srsq.SourceMlsNumber
```

**Expected CTR:** 2-5% (NOT 10-30%)

### LeadTagTypeIds (from GenieLeadTagType table)
- **48** = OptInContact (CTA Submitted)
- **51** = OptOutSms (Opt-Outs)
- **52** = CtaContactVerified (Verified Leads)

---

## 10. Open Items

- [ ] Facebook and Direct Mail execution tracking (separate from SMS)
- [ ] Actual Twilio cost from invoice vs estimated
- [x] Click tracking join path verified (v7)

