# Competition Command Monthly Cost Report Specification
## Version 1.0 | December 2025

---

## 1. Report Overview

### Purpose
The Competition Command Monthly Cost Report provides a comprehensive audit of SMS campaign activity, engagement metrics, and Twilio costs for the Competition Command (FarmCast) service. This report enables billing reconciliation, performance monitoring, and customer usage tracking.

### Report Naming Convention
```
Genie_CompCommand_CostsByMonth_[MM-YYYY]_v[#].csv
```
Example: `Genie_CompCommand_CostsByMonth_11-2025_v1.csv`

### Generation Time
Target: **< 5 seconds** using optimized query stack approach

---

## 2. Report Structure

### Output Format
- **File Type:** CSV (Google Sheets compatible)
- **Encoding:** UTF-8
- **Delimiter:** Comma
- **Quote Character:** Double quote (for fields containing commas)

### Column Order (16 columns)

| # | Column Name | Data Type | Example |
|---|-------------|-----------|---------|
| 1 | Month | String | "November 2025" |
| 2 | Customer_Name | String | "Debbie Gates" |
| 3 | Area_Name | String | "Moorpark 93021" |
| 4 | Campaigns | Integer | 21 |
| 5 | Msgs_Sent | Integer | 1553 |
| 6 | Delivered | Integer | 91 |
| 7 | Success% | Percentage | "5.9%" |
| 8 | Clicks | Integer | 22 |
| 9 | CTR% | Percentage | "1.42%" |
| 10 | CTA_Submitted | Integer | 9 |
| 11 | CTA_Verified | Integer | 0 |
| 12 | Agent_Notify | Integer | 0 |
| 13 | Agent_Notify_Cost | Currency | "$0.00" |
| 14 | Opt_Outs | Integer | 36 |
| 15 | Opt_Out% | Percentage | "2.32%" |
| 16 | Twilio_Cost | Currency | "$2.39" |

---

## 3. Sample Data (November 2025)

```csv
Month,Customer_Name,Area_Name,Campaigns,Msgs_Sent,Delivered,Success%,Clicks,CTR%,CTA_Submitted,CTA_Verified,Agent_Notify,Agent_Notify_Cost,Opt_Outs,Opt_Out%,Twilio_Cost
November 2025,Debbie Gates,Moorpark 93021,21,1553,91,5.9%,22,1.42%,9,0,0,$0.00,36,2.32%,$2.39
November 2025,Debbie Gates,Simi Valley 93065,24,1673,180,10.8%,40,2.39%,7,0,0,$0.00,21,1.25%,$4.73
November 2025,Debbie Gates,Thousand Oaks 91360,21,1405,205,14.6%,15,1.07%,10,0,0,$0.00,15,1.07%,$4.58
November 2025,David Higgins,Oakland 94602,14,931,63,6.8%,8,0.86%,3,1,0,$0.00,1,0.11%,$1.23
November 2025,David Higgins,Piedmont 94611,27,1740,203,11.7%,17,0.98%,4,1,0,$0.00,7,0.40%,$4.12
```

---

## 4. Data Sources

### Primary Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `SmsReportSendQueue` | Competition Command campaigns | SmsReportSendQueueId, AreaId, UtmSource, CreateDate |
| `UserOwnedArea` | Customer-to-Area ownership | AspNetUserId, AreaId |
| `AspNetUsers` | User accounts | Id, UserName, Email |
| `AspNetUserProfiles` | User names | AspNetUserId, FirstName, LastName |
| `PolygonNameOverride` | Custom area names | PolygonId, AspNetUserId, FriendlyName |
| `AreaDataCache` | Default area names (zip codes) | AreaId, AreaData (JSON with AreaName) |
| `GenieLead` | Lead/engagement records | GenieLeadId, AreaId, Note, CreateDate |
| `GenieLeadTag` | Lead tags (CTA, OptOut) | GenieLeadId, LeadTagTypeId, CreateDate |
| `GenieLeadTagType` | Tag type definitions | GenieLeadTagTypeId, Tag |

### Key Tag Types (GenieLeadTagType)

| ID | Tag Name | Report Column |
|----|----------|---------------|
| 48 | OptInContact | CTA_Submitted |
| 52 | CtaContactVerfied | CTA_Verified |
| 51 | OptOutSms | Opt_Outs |

---

## 5. Column Definitions & Calculations

### 5.1 Month
- **Source:** Input parameter
- **Format:** "Month YYYY" (e.g., "November 2025")

### Date Format Standard
- **All date columns:** `mm-dd-yyyy` (e.g., 11-18-2024)
- **No timestamps** - date only, no time component

### 5.2 Customer_Name
- **Source:** `AspNetUserProfiles.FirstName` + `AspNetUserProfiles.LastName`
- **Fallback:** `AspNetUsers.UserName` if profile name is empty
- **Logic:**
```sql
CASE 
    WHEN ISNULL(ap.FirstName, '') = '' THEN u.UserName
    ELSE ISNULL(ap.FirstName, '') + ' ' + ISNULL(ap.LastName, '')
END AS CustomerName
```

### 5.3 Area_Name
- **Priority Order:**
  1. `PolygonNameOverride.FriendlyName` (user-specific override)
  2. `AreaDataCache.AreaData` → JSON parse → `AreaName` field (zip code)
  3. Hardcoded fallback mapping (for missing entries)
  4. "Area {AreaId}" as last resort

- **Fallback Mapping:**
```python
AREA_NAME_FALLBACKS = {
    9602: 'Oakland 94602',
    9609: 'Montclair 94609',
}
```

- **Post-processing:** Replace `|` with space, trim whitespace

### 5.4 Campaigns
- **Source:** `COUNT(DISTINCT SmsReportSendQueue.SmsReportSendQueueId)`
- **Filter:** `UtmSource = 'Competition Command'`
- **Group By:** AreaId, AspNetUserId

### 5.5 Msgs_Sent
- **Source:** Count of SMS messages sent per campaign
- **Current Implementation:** Estimated as `Campaigns × 75`
- **Future Enhancement:** Direct count from TwilioMessage via ShortUrlData join

### 5.6 Delivered
- **Source:** Count of SMS messages with `Status = 'delivered'`
- **Current Implementation:** Estimated as `Campaigns × 15` (20% rate)
- **Future Enhancement:** Direct count from TwilioMessage

### 5.7 Success%
- **Calculation:** `(Delivered / Msgs_Sent) × 100`
- **Format:** "XX.X%"
- **Handle:** Division by zero returns 0

### 5.8 Clicks
- **Source:** `GenieLead` records with `Note LIKE '%SMS engagement%'`
- **Filter:** By AreaId and CreateDate within month
- **Logic:**
```sql
SELECT gl.AreaId, COUNT(DISTINCT gl.GenieLeadId) AS Clicks
FROM GenieLead gl
WHERE gl.Note LIKE '%SMS engagement%'
  AND gl.AreaId IS NOT NULL
GROUP BY gl.AreaId
```

### 5.9 CTR%
- **Calculation:** `(Clicks / Msgs_Sent) × 100`
- **Format:** "X.XX%"

### 5.10 CTA_Submitted
- **Source:** `GenieLeadTag` with `LeadTagTypeId = 48` (OptInContact)
- **Critical:** Use `GenieLeadTag.CreateDate` for filtering (not GenieLead.CreateDate)
- **Reason:** Leads may return in subsequent months; tag date is authoritative
```sql
SELECT gl.AreaId, COUNT(*) AS CTA_Submitted
FROM GenieLeadTag glt
JOIN GenieLead gl ON gl.GenieLeadId = glt.GenieLeadId
WHERE glt.LeadTagTypeId = 48
  AND glt.CreateDate >= @StartDate AND glt.CreateDate < @EndDate
GROUP BY gl.AreaId
```

### 5.11 CTA_Verified
- **Source:** `GenieLeadTag` with `LeadTagTypeId = 52` (CtaContactVerfied)
- **Note:** Database has typo "Verfied" not "Verified"
- **Filter:** Same as CTA_Submitted using tag CreateDate

### 5.12 Agent_Notify
- **Source:** Agent SMS notifications triggered by Competition Command leads
- **Status:** v2 Stretch Goal - requires complex join through lead attribution
- **Current Value:** 0 (placeholder)

### 5.13 Agent_Notify_Cost
- **Source:** Twilio cost for agent notification SMS
- **Status:** v2 Stretch Goal
- **Current Value:** "$0.00" (placeholder)

### 5.14 Opt_Outs
- **Source:** `GenieLeadTag` with `LeadTagTypeId = 51` (OptOutSms)
- **Filter:** By AreaId and tag CreateDate within month
```sql
SELECT gl.AreaId, COUNT(*) AS Opt_Outs
FROM GenieLeadTag glt
JOIN GenieLead gl ON gl.GenieLeadId = glt.GenieLeadId
WHERE glt.LeadTagTypeId = 51
  AND glt.CreateDate >= @StartDate AND glt.CreateDate < @EndDate
GROUP BY gl.AreaId
```

### 5.15 Opt_Out%
- **Calculation:** `(Opt_Outs / Msgs_Sent) × 100`
- **Format:** "X.XX%"

### 5.16 Twilio_Cost
- **Source:** Sum of `TwilioMessage.Price` for campaign SMS
- **Current Implementation:** Estimated as `Campaigns × $0.25`
- **Future Enhancement:** Direct sum from TwilioMessage via ShortUrlData join
- **Format:** "$X.XX"

---

## 6. Query Execution Order

The report uses a "query stack" approach for performance:

```
Step 1: Get campaign data (SmsReportSendQueue + UserOwnedArea + User info)
Step 2: Get area name overrides (PolygonNameOverride)
Step 3: Get default area names (AreaDataCache)
Step 4: Get SMS stats (estimated or actual)
Step 5: Get click data (GenieLead)
Step 6: Get CTA data (GenieLeadTag where LeadTagTypeId IN (48, 52))
Step 7: Get opt-out data (GenieLeadTag where LeadTagTypeId = 51)
Step 8: Merge all data in Python/pandas
Step 9: Calculate percentages
Step 10: Format output and save CSV
```

---

## 7. Filters & Business Rules

### Competition Command Filter
```sql
WHERE srsq.UtmSource = 'Competition Command'
```

### Date Range Filter
- **Start:** First day of month at 00:00:00
- **End:** First day of next month at 00:00:00 (exclusive)
- **Example:** November 2025 → `>= '2025-11-01' AND < '2025-12-01'`

### Customer Inclusion
- Include all customers with `> 0` campaigns in the month
- Include partial-month customers (e.g., started mid-month)

### Row Grouping
- One row per **Customer + Area** combination
- Multiple areas per customer = multiple rows

---

## 8. Performance Considerations

### Slow Operations (Avoid)
- `CHARINDEX` on JSON fields (e.g., ShortUrlData.Data)
- Large table scans without date filters
- Cross-database joins

### Fast Operations (Preferred)
- Indexed column lookups (AreaId, AspNetUserId, CreateDate)
- Separate queries merged in Python
- Date-filtered subqueries

### Target Performance
- Total execution time: **< 5 seconds**
- Individual query time: **< 2 seconds each**

---

## 9. Future Enhancements (v2)

### Agent_Notify Implementation
- Trace Competition Command leads to agent notification SMS
- Link via GenieLead → NotificationQueue → TwilioMessage
- Requires understanding of lead-to-notification attribution

### Actual SMS Counts
- Replace estimates with actual TwilioMessage counts
- Requires optimized join through ShortUrlData
- May need server-side indexing improvements

### Property Type Breakdown
- Add SFR/Condo split per area
- Requires PropertyCast configuration lookup
- Creates multiple rows per area

---

## 10. Error Handling

### Missing Area Names
- Use fallback mapping for known missing areas
- Log unknown areas for manual addition

### Database Timeouts
- Implement retry logic (3 attempts)
- Use WITH (NOLOCK) hints for read operations
- Break large queries into smaller chunks

### Data Validation
- Check for negative values (should not occur)
- Validate percentage calculations (0-100%)
- Verify customer name resolution

---

## 11. File Locations

### Script Location
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\build_report_fast_v4.py
```

### Output Location
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\Genie_CompCommand_CostsByMonth_[MM-YYYY]_v[#].csv
```

---

## 12. Approval & Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Report Author | | | |
| Data Validation | | | |
| Business Owner | | | |

---

*Document Version: 1.0*
*Last Updated: December 10, 2025*

