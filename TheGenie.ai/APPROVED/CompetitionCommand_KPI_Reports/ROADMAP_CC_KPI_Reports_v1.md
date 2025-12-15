# Competition Command KPI Reports - Roadmap & Discovery

---

## EXECUTIVE SUMMARY

| **Element** | **Details** |
|-------------|------------|
| **Purpose** | Define the complete roadmap for Competition Command KPI reporting, including cost tracking, performance metrics, and customer/global views. |
| **Current State** | **v1.0 COMPLETE** - Monthly cost report with Twilio costs by customer + zip + property type. |
| **Key Outputs** | A suite of reports that answer: What does each CC subscription cost us? How are they performing? What's the ROI? |
| **Remaining Work** | v2.0 (Versium costs), v3.0 (Granular agent reports), v4.0 (Global summary) |
| **Last Validated** | 12/15/2025 |

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Author** | Cursor AI |
| **Status** | ACTIVE |

---

## DELIVERABLES COMPLETED (v1.0)

### ✅ Monthly Cost Report (FINAL)

| Item | Location |
|------|----------|
| **Script** | `Scripts/build_cc_monthly_cost_report_FINAL.py` |
| **SOP** | `SOPs/SOP_CC_Monthly_Cost_Report_FINAL.md` |
| **Sample Report** | `Reports/Genie_CC_MonthlyCost_12-2025_MTD_2025-12-15.csv` |

**Capabilities Delivered:**
- ✅ Customer name, email, zip code, property type
- ✅ Campaign counts and message volumes
- ✅ Delivery success rate
- ✅ Click tracking (leads generated)
- ✅ CTR percentage
- ✅ CTA Submitted / CTA Verified counts
- ✅ Agent SMS Notification counts + costs
- ✅ Opt-out tracking
- ✅ Proportional Twilio cost allocation (invoice or estimate)
- ✅ Property types as separate rows (distinct orders)

---

## ITERATION ROADMAP

### 🔜 Iteration 2.0: Versium/Data Append Costs

**Status**: NEXT UP

**Objective**: Add data append costs to the report so we know **Total Cost of Goods** = Twilio + Data

**Requirements**:
- [ ] Obtain Versium invoice or API access
- [ ] Map data append credits to CC campaigns (PropertyCollectionDetailId)
- [ ] Calculate per-lead or per-campaign data cost
- [ ] Add columns: `Data_Cost`, `Total_COGS`

**Blocked By**: Versium invoice/pricing access

**Estimated Effort**: 4-6 hours once access granted

---

### 📋 Iteration 3.0: Granular Agent Reports

**Status**: PLANNED

**Objective**: Create per-agent reports with campaign-type breakdown

**New Columns/Breakdowns**:
- SFR Active campaigns
- SFR Sold campaigns
- Condo Active campaigns
- Condo Sold campaigns
- Cost per campaign type

**Use Case**: Agent-level P&L, understanding which campaign types perform best

**Estimated Effort**: 6-8 hours

---

### 📋 Iteration 4.0: Global Summary Reports

**Status**: PLANNED

**Objective**: High-level executive dashboard showing CC program health

**Metrics**:
- Total CC customers
- Total zip codes under management
- Total messages sent (month, quarter, YTD)
- Total Twilio spend
- Total Data spend
- Average cost per customer
- Average cost per lead
- Conversion funnel: Sent → Clicked → CTA → Verified → Won

**Format**: 
- Single-page PDF/dashboard
- Month-over-month trends

**Estimated Effort**: 8-12 hours

---

### 📋 Iteration 5.0: ROI & Performance Tracking

**Status**: FUTURE

**Objective**: Connect costs to revenue outcomes

**Requirements**:
- [ ] Integrate WHMCS billing data (subscription revenue)
- [ ] Track lead → client conversions (if available)
- [ ] Calculate: Revenue per zip, Profit per zip, Customer lifetime value

**Note**: Requires additional data sources beyond current FarmGenie scope

---

## PUNCH LIST (Immediate Action Items)

| # | Task | Priority | Status | Notes |
|---|------|----------|--------|-------|
| 1 | ✅ Finalize v1.0 Monthly Cost Report | HIGH | DONE | Script + SOP + Sample in APPROVED folder |
| 2 | ✅ Document Agent Notification logic | HIGH | DONE | NewLead (24) + GenieLeadId parsing |
| 3 | Get Versium invoice/pricing access | HIGH | PENDING | Required for v2.0 |
| 4 | Fix Steve Hundley email in system | LOW | NOTED | Wrong email: arshadjahsh@gmail.com |
| 5 | Fix Rein Morgadez email (Gmail vs 1PP) | LOW | NOTED | Should use @1parkplace.com |
| 6 | Run November FULL report for archive | MED | TODO | For reference/validation |
| 7 | Create v2.0 spec when Versium ready | MED | PENDING | Waiting on access |

---

## FOLDER STRUCTURE

```
C:\Cursor\TheGenie.ai\APPROVED\CompetitionCommand_KPI_Reports\
├── Scripts/
│   └── build_cc_monthly_cost_report_FINAL.py
├── SOPs/
│   └── SOP_CC_Monthly_Cost_Report_FINAL.md
├── Reports/
│   └── Genie_CC_MonthlyCost_12-2025_MTD_2025-12-15.csv
└── ROADMAP_CC_KPI_Reports_v1.md (this file)
```

---

## NOTES FROM DISCOVERY

### Extra Credit Findings (12/15/2025)

**Agent Notification Recipients for Zip 34786 (Simon Simaan):**

| Phone | Owner | Role |
|-------|-------|------|
| (407) 558-1396 | Simon Simaan | Account Owner |
| (310) 774-2414 | Rein Morgadez | Customer Service |
| (619) 507-4404 | Steve Hundley | [You!] |

**Math**: 10 leads × 3 recipients = 30 agent notifications ✅

This confirms the notification system works correctly - each lead triggers one SMS per configured phone number.

---

## CHANGE LOG

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/15/2025 | Initial roadmap created. v1.0 deliverables complete. |

---

*End of Roadmap*

