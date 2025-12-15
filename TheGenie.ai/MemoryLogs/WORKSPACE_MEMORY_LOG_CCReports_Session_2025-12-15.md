# Workspace Memory Log - Competition Command KPI Reports Session

---

## EXECUTIVE SUMMARY

| **Element** | **Details** |
|-------------|------------|
| **Purpose** | Document lessons learned, discoveries, and key findings from the 12/15/2025 session focused on finalizing Competition Command Monthly Cost Reports. |
| **Current State** | Session COMPLETE. v1.0 of CC Monthly Cost Report approved and in production folder. |
| **Key Outputs** | FINAL script, SOP, sample reports, roadmap, and this memory log |
| **Remaining Work** | v2.0 Versium costs, v3.0 granular reports, v4.0 global summaries |
| **Last Validated** | 12/15/2025 |

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Author** | Cursor AI |
| **Session Duration** | Extended session |

---

## 1. KEY LESSONS LEARNED

### 1.1 Property Type Handling (CRITICAL)

**THE RULE**: SFR and Condo are **SEPARATE ORDERS** and must appear as **SEPARATE ROWS** in reports.

**Why**: When a customer buys a zip code, they select:
1. Zip code
2. Property type (SFR OR Condo)

So the same zip code can have TWO different owners - one for SFR, one for Condo. These are distinct purchases.

**Implementation**:
- Join on `[AreaId, PropertyTypeId]` to get separate rows
- Do NOT aggregate/combine property types unless specifically building a summary report
- Active and Sold campaigns within the same property type CAN be combined

**Database Reference**:
- `UserOwnedArea.PropertyTypeId`: 0 = SFR, 1 = Condo
- `PropertyCast.PropertyTypeId`: Same mapping

---

### 1.2 Agent Notification Logic (NEW DISCOVERY)

**How It Works**:
1. When a lead clicks a CC campaign → `GenieLead` record created
2. System sends SMS notifications to ALL phone numbers configured for that customer
3. Notifications stored in `NotificationQueue` with `NotificationTypeId = 24` (NewLead)

**Finding GenieLeadId from Notifications**:
The `GenieLeadId` is NOT a direct column in `NotificationQueue`. It's embedded in the `CustomData` JSON field within the `TagLeadDetailUrl`:

```sql
-- Extract GenieLeadId from CustomData
TRY_CONVERT(BIGINT, SUBSTRING(
    CAST(nq.CustomData AS NVARCHAR(MAX)),
    CHARINDEX('/lead-center/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 20,
    PATINDEX('%[^0-9]%', SUBSTRING(
        CAST(nq.CustomData AS NVARCHAR(MAX)), 
        CHARINDEX('/lead-center/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 20, 
        20) + 'X') - 1
))
```

**Example Math**:
- Zip 34786 (Simon Simaan): 10 leads generated in December
- 3 phone numbers configured: Simon, Rein, Steve
- Result: 10 × 3 = 30 agent notifications ✅

---

### 1.3 Finding Notification Recipients

**Query to find who receives lead notifications**:

```sql
SELECT DISTINCT
    JSON_VALUE(nq.CustomData, '$.ToPhoneNumber') AS ToPhoneNumber,
    JSON_VALUE(nq.CustomData, '$.DynamicData.TagRecipientUsername') AS RecipientUsername
FROM NotificationQueue nq WITH (NOLOCK)
WHERE nq.NotificationTypeId = 24  -- NewLead
  AND nq.NotificationChannelId = 2  -- SMS
  AND nq.CreateDate >= '2025-12-01'
  AND CAST(nq.CustomData AS NVARCHAR(MAX)) LIKE '%CustomerName%'
```

**Phone number to user mapping**:
- Check `UserMarketingProfile.Phone` joined to `AspNetUsers` and `AspNetUserProfiles`

---

### 1.4 Cost Methodology

**Two Methods Available**:

| Method | When to Use | Accuracy |
|--------|-------------|----------|
| **Invoice-Based** | After month closes and invoice received | Most accurate |
| **Estimate-Based** | Mid-month (MTD) reports | ~95% accurate |

**Invoice-Based Process**:
1. Load Twilio CSV invoice
2. Extract "Programmable Messaging" costs (Outbound + Carrier Fees)
3. Calculate CC percentage: `CC_SMS / Total_SMS`
4. Allocate: `Invoice_Cost × CC_Percentage`

**Estimate-Based Process**:
1. Use November benchmark: **$0.01815 per message**
2. Calculate: `CC_SMS_Count × $0.01815`

**Proportional Allocation by Property Type**:
Since `SmsReportSendQueue` only tracks at `AreaId` level (not PropertyTypeId):
1. Count campaigns by `AreaId + PropertyTypeId`
2. Calculate proportion for each property type
3. Apply proportion to messages and costs

---

### 1.5 Key Database Identifiers

| Identifier | Table | Value | Meaning |
|------------|-------|-------|---------|
| `PropertyCastTypeId` | PropertyCast | 1 | Competition Command |
| `PropertyCastTypeId` | PropertyCast | 2 | Listing Command |
| `PropertyCastTypeId` | PropertyCast | 3 | Neighborhood Command |
| `PropertyTypeId` | UserOwnedArea | 0 | SFR (Single Family Residential) |
| `PropertyTypeId` | UserOwnedArea | 1 | Condo |
| `NotificationTypeId` | NotificationQueue | 24 | NewLead |
| `NotificationChannelId` | NotificationQueue | 1 | Email |
| `NotificationChannelId` | NotificationQueue | 2 | SMS |
| `UtmSource` | SmsReportSendQueue | 'Competition Command' | CC campaigns |

---

### 1.6 CTA Tracking

**Tag-Based Identification**:

```sql
-- CTA Submitted
ltt.Tag LIKE 'Cta%Accept%' OR ltt.Tag LIKE 'Cta%Submit%'

-- CTA Verified (note the typo in production!)
ltt.Tag LIKE '%CtaContactVerified%' OR ltt.Tag LIKE '%CtaContactVerfied%'
```

**Join Path**: `GenieLead` → `GenieLeadTag` → `GenieLeadTagType`

---

## 2. FILE ORGANIZATION RULES

### 2.1 Never Dump to Root

**WRONG**: Putting files directly in `C:\Cursor\`
**RIGHT**: Use organized structure under `C:\Cursor\TheGenie.ai\`

### 2.2 Approved Folder Structure

```
C:\Cursor\TheGenie.ai\APPROVED\
└── CompetitionCommand_KPI_Reports\
    ├── Scripts/      ← Python scripts
    ├── SOPs/         ← Documentation
    ├── Reports/      ← Sample/archive reports
    └── ROADMAP_*.md  ← Planning docs
```

### 2.3 Versioning Rules (Reminder)

- Minor changes: v1.0 → v1.1
- Major changes: v1.1 → v2.0
- NEVER overwrite files - always increment version
- FINAL versions go to APPROVED folder

---

## 3. DOCUMENTATION RULES

### 3.1 Executive Summary (NEW MASTER RULE)

Every approved document MUST have an Executive Summary with:
1. **Purpose** - One sentence: What problem does this solve?
2. **Current State** - Completion % and what's working
3. **Key Outputs** - What the document produces
4. **Remaining Work** - What iterations are planned
5. **Last Validated** - Date and what was confirmed

**Goal**: 5-second understanding when opening any file

---

## 4. DATA QUALITY NOTES

### 4.1 Known Issues Found

| Issue | Location | Status |
|-------|----------|--------|
| Steve Hundley email wrong | UserMarketingProfile | `arshadjahsh@gmail.com` should be fixed |
| Rein Morgadez using Gmail | UserMarketingProfile | Should be @1parkplace.com |

### 4.2 Validation Checks

Before approving any report:
- [ ] No columns with all zeros (indicates broken data source)
- [ ] Total cost matches invoice allocation
- [ ] Property types shown separately
- [ ] Agent notifications = Leads × Recipients

---

## 5. DISCOVERIES FROM EXTRA CREDIT

### 5.1 Notification Recipients for Zip 34786 (Simon Simaan)

| Phone | Owner | Role |
|-------|-------|------|
| (407) 558-1396 | Simon Simaan | Account Owner |
| (310) 774-2414 | Rein Morgadez | Customer Service |
| (619) 507-4404 | Steve Hundley | Operations |

**Finding Owner from Phone**: Query `UserMarketingProfile` joined to `AspNetUsers` and `AspNetUserProfiles`

---

## 6. TECHNICAL GOTCHAS

### 6.1 SQL Server JSON Parsing

The `CustomData` column in `NotificationQueue` is NVARCHAR containing JSON. Use:
- `JSON_VALUE(CustomData, '$.FieldName')` for simple values
- `CAST(CustomData AS NVARCHAR(MAX))` before string operations
- `CHARINDEX` + `SUBSTRING` for complex parsing (like URLs)

### 6.2 Twilio Cost in December

`TwilioMessage.Price` may be NULL for recent messages (sync delay). Fall back to estimate.

### 6.3 Pandas Warning

`pd.read_sql()` with pyodbc throws a warning about SQLAlchemy. Safe to ignore - data reads correctly.

---

## 7. DELIVERABLES FROM THIS SESSION

| Item | Location | Status |
|------|----------|--------|
| FINAL Script | `APPROVED/CompetitionCommand_KPI_Reports/Scripts/build_cc_monthly_cost_report_FINAL.py` | ✅ |
| FINAL SOP | `APPROVED/CompetitionCommand_KPI_Reports/SOPs/SOP_CC_Monthly_Cost_Report_FINAL.md` | ✅ |
| November Report | `APPROVED/CompetitionCommand_KPI_Reports/Reports/Genie_CC_MonthlyCost_11-2025_FULL_*.csv` | ✅ |
| December Report | `APPROVED/CompetitionCommand_KPI_Reports/Reports/Genie_CC_MonthlyCost_12-2025_MTD_*.csv` | ✅ |
| Roadmap | `APPROVED/CompetitionCommand_KPI_Reports/ROADMAP_CC_KPI_Reports_v1.md` | ✅ |
| Memory Log | `TheGenie.ai/MemoryLogs/WORKSPACE_MEMORY_LOG_CCReports_Session_2025-12-15.md` | ✅ |

---

## 8. NEXT STEPS (ITERATION 2)

1. **Get Versium invoice/API access** (blocked on this)
2. Map data append credits to PropertyCollectionDetailId
3. Add `Data_Cost` column to report
4. Calculate `Total_COGS = Twilio_Cost + Data_Cost`

---

## 9. QUOTES & CONTEXT

**User clarification on Property Types**:
> "When we sell a zip code today, you'll notice in the buy section, you select Zip code. Then you select property type. So one person today can buy condos and another person could buy single-family. So in that case, I want to keep the zip code as if there's two different orders, one per property type."

**User on Executive Summaries**:
> "Having like a summary at the top, an executive summary, for someone to look at it and say... exactly what the intent of the report is for and what we have next to do to it."

---

## CHANGE LOG

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/15/2025 | Initial session memory log created |

---

*End of Memory Log*

