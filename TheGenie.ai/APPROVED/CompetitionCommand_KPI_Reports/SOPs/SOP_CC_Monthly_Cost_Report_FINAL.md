# Competition Command Monthly Cost Report - Standard Operating Procedure

---

## EXECUTIVE SUMMARY

| **Element** | **Details** |
|-------------|------------|
| **Purpose** | Generate a monthly cost report for Competition Command that ties Twilio messaging costs to individual customers, zip codes, and property types - answering "How much did we spend on each CC customer's area this month?" |
| **Current State** | **100% Complete** for Twilio costs. All 19 columns pulling real data. Agent notifications working. CTA tracking working. |
| **Key Outputs** | CSV report per month with: Customer, Area, Property Type, Campaigns, Messages, Delivery%, Clicks, CTR%, CTA Submitted/Verified, Agent Notifications + Cost, Opt-Outs, Total Twilio Cost |
| **Remaining Work** | **Iteration 2**: Add Versium/Data Append costs → Total Cost of Goods |
| **Last Validated** | 12/15/2025 - December MTD report verified with correct Agent Notify counts (30 msgs for zip 34786 = 10 leads × 3 recipients) |

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 (FINAL) |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Author** | Cursor AI |
| **Status** | PRODUCTION APPROVED |

---

## 1. OVERVIEW

### 1.1 Report Purpose
This report calculates the **Twilio SMS costs** for Competition Command (CC) campaigns on a monthly basis, broken down by:
- **Customer** (account owner)
- **Zip Code / Area**
- **Property Type** (SFR, Condo) - Each is a separate order

The goal is to understand cost of goods sold (COGS) for each CC subscription.

### 1.2 Report Frequency
- **Full Month Reports**: Run on the 1st of following month (after invoice available)
- **MTD Reports**: Can be run mid-month using estimated rates

---

## 2. OUTPUT SPECIFICATION

### 2.1 File Format
- **Format**: CSV
- **Encoding**: UTF-8
- **Naming**: `Genie_CC_MonthlyCost_{MM}-{YYYY}_{FULL|MTD}_{DATE}.csv`

### 2.2 Column Definitions (19 Columns)

| # | Column Name | Type | Description |
|---|-------------|------|-------------|
| 1 | Month | Text | Report period (e.g., "November 2025") |
| 2 | Customer_Name | Text | First + Last name from AspNetUserProfiles |
| 3 | Email | Text | Customer email from AspNetUsers |
| 4 | Area_Name | Text | Zip code/area name from ViewArea |
| 5 | Property_Type | Text | SFR or Condo (separate orders) |
| 6 | Campaigns | Int | Count of campaigns run this month |
| 7 | Msgs_Sent | Int | SMS messages sent (proportional by property type) |
| 8 | Delivered | Int | Successfully delivered messages |
| 9 | Success% | Pct | Delivered / Sent × 100 |
| 10 | Clicks | Int | Leads generated (COUNT DISTINCT GenieLeadId) |
| 11 | CTR% | Pct | Clicks / Sent × 100 |
| 12 | CTA_Submitted | Int | Leads who submitted CTA form |
| 13 | CTA_Verified | Int | Leads who verified contact info |
| 14 | Agent_Notify | Int | SMS notifications sent to agent team |
| 15 | Agent_Notify_Cost | Money | Cost of agent notification SMS |
| 16 | Opt_Outs | Int | Leads who opted out |
| 17 | Opt_Out% | Pct | Opt-outs / Sent × 100 |
| 18 | Twilio_Cost | Money | Proportional share of CC Twilio invoice |
| 19 | Cost_Method | Text | "Invoice" or "Estimate" |

---

## 3. DATA SOURCES

### 3.1 Primary Tables

| Table | Purpose |
|-------|---------|
| `SmsReportSendQueue` | Marketing SMS campaigns (UtmSource = 'Competition Command') |
| `ViewSmsQueueSendSummary` | SMS counts and delivery status |
| `GenieLead` | Leads/clicks from campaigns |
| `GenieLeadTag` | Lead actions (CTA submission, verification) |
| `GenieLeadTagType` | Tag definitions |
| `NotificationQueue` | System notifications (agent alerts) |
| `TwilioMessage` | SMS costs from Twilio API sync |
| `PropertyCast` | Campaign configuration |
| `PropertyCollectionDetail` | Campaign details |
| `UserOwnedArea` | Customer → Area ownership |
| `ViewArea` | Area/zip code names |
| `AspNetUsers` | Customer email |
| `AspNetUserProfiles` | Customer name |

### 3.2 Key Identifiers

| Field | Table | Description |
|-------|-------|-------------|
| `PropertyCastTypeId = 1` | PropertyCast | Competition Command |
| `PropertyCastTypeId = 2` | PropertyCast | Listing Command |
| `PropertyCastTypeId = 3` | PropertyCast | Neighborhood Command |
| `PropertyTypeId = 0` | UserOwnedArea | SFR |
| `PropertyTypeId = 1` | UserOwnedArea | Condo |
| `NotificationTypeId = 24` | NotificationQueue | NewLead SMS |
| `NotificationChannelId = 2` | NotificationQueue | SMS channel |

---

## 4. COST ALLOCATION METHODOLOGY

### 4.1 Invoice-Based (Preferred)
When Twilio invoice is available:

1. Load CSV invoice from `_invoices_11-14-2025/` folder
2. Extract "Programmable Messaging" line items:
   - Outbound SMS costs
   - Carrier fees
3. Calculate CC percentage: `CC_SMS_Count / Total_SMS_Count`
4. Allocate: `Invoice_Variable_Cost × CC_Percentage`
5. Distribute to areas proportionally by `Msgs_Sent`

### 4.2 Estimate-Based (Mid-Month)
When no invoice available:

1. Use November benchmark rate: **$0.01815/message**
2. Calculate: `CC_SMS_Count × $0.01815`
3. Distribute to areas proportionally

### 4.3 Property Type Proportional Allocation
Since `SmsReportSendQueue` only tracks at AreaId level:

1. Get campaign counts by AreaId + PropertyTypeId
2. Calculate proportion: `Campaigns_ThisPropType / Campaigns_TotalForArea`
3. Apply proportion to Msgs_Sent and Cost

---

## 5. EXECUTION

### 5.1 Prerequisites
- Python 3.10+
- Required packages: `pandas`, `pyodbc`
- Database access: `FarmGenie` on 192.168.29.45

### 5.2 Running the Report

```bash
cd C:\Cursor\TheGenie.ai\APPROVED\CompetitionCommand_KPI_Reports\Scripts
python build_cc_monthly_cost_report_FINAL.py
```

### 5.3 Modifying Parameters
Edit the `__main__` section at bottom of script:

```python
# Full month (with invoice)
generate_monthly_report(2025, 11)

# Month-to-date (no invoice yet)
generate_monthly_report(2025, 12, end_day=14)
```

---

## 6. VALIDATION CHECKLIST

- [ ] Total Twilio Cost matches CC percentage of invoice
- [ ] Row count matches unique Customer + Area + PropertyType combinations
- [ ] Agent_Notify count = Leads × Recipients_Configured
- [ ] No zero columns (all data sources connected)
- [ ] Property types shown separately (SFR and Condo are distinct rows)

---

## 7. KNOWN BEHAVIORS

### 7.1 Separate Property Type Rows
**Intentional**: SFR and Condo appear as separate rows even for the same zip code because they represent distinct orders/purchases.

### 7.2 Agent Notifications > Leads
**Normal**: If a customer has 3 phone numbers configured for lead alerts, each lead triggers 3 SMS notifications. So 10 leads × 3 phones = 30 notifications.

### 7.3 Proportional Cost Allocation
**By Design**: SMS messages are sent at the AreaId level, not PropertyTypeId. Costs are allocated proportionally based on campaign activity per property type.

---

## 8. CHANGE LOG

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/15/2025 | Initial FINAL version. All 19 columns with real data. Agent notifications implemented via NewLead + GenieLeadId parsing. |

---

## 9. ROADMAP (Iterations)

| Iteration | Status | Description |
|-----------|--------|-------------|
| **1.0** | ✅ COMPLETE | Twilio costs for campaigns + agent notifications |
| **2.0** | 🔜 NEXT | Add Versium/Data Append costs |
| **3.0** | Planned | Granular agent reports (by campaign type: Active/Sold) |
| **4.0** | Planned | Global summary reports (all CC customers aggregated) |

---

*End of SOP*

