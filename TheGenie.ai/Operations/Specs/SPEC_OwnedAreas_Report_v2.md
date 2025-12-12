# SPEC: Genie Owned Areas Report (Iteration 2)

**Version:** 2.0  
**Created:** 2025-12-10  
**Last Updated:** 2025-12-10  
**Product:** Competition Command (FarmCast) Only  

---

## 1. Purpose

Generate a comprehensive report of all Competition Command area ownership with campaign activity and engagement metrics (SMS, Clicks, CTR, Leads).

---

## 2. Report Output

### 2.1 File Naming
```
Genie_CC_Ownership_LIFETIME_YYYY-MM-DD_v#_iter2.csv
```

### 2.2 Column Specification (14 Columns)

| # | Column | Type | Example | Source |
|---|--------|------|---------|--------|
| 1 | UserOwnedAreaId | int | 205 | `UserOwnedArea.UserOwnedAreaId` |
| 2 | AreaId | int | 8859 | `UserOwnedArea.AreaId` |
| 3 | Zip_Code | string | 92028 | Extracted via regex from AreaName |
| 4 | Area_Name | string | Fallbrook 92028 | `ViewArea.Name` + fallback mapping |
| 5 | Customer_Name | string | Mike Chiesl | `AspNetUserProfiles.FirstName + LastName` |
| 6 | Property_Types | string | SFR + Condo | Combined from PropertyTypeId |
| 7 | Ownership_Start | date | 09-10-2025 | `UserOwnedArea.CreateDate` |
| 8 | Total_Campaigns | int | 29 | COUNT of `PropertyCollectionDetail` |
| 9 | Last_Campaign | date | 11-25-2025 | MAX of `PropertyCollectionDetail.CreateDate` |
| 10 | **Texts_Sent** | int | 2175 | SUM from `ViewSmsQueueSendSummary` |
| 11 | **Clicks** | int | 203 | SUM of `ShortUrlData.AccessCount` |
| 12 | **CTR** | string | 9.3% | Clicks / Texts_Sent × 100 |
| 13 | **Leads_Generated** | int | 115 | COUNT from `GenieLead` |
| 14 | Ownership_Status | string | Active | Active / Ended |

---

## 3. Data Sources

### 3.1 Ownership Data
```sql
FROM UserOwnedArea uoa
INNER JOIN AspNetUsers u ON u.Id = uoa.AspNetUserId
LEFT JOIN AspNetUserProfiles up ON up.AspNetUserId = uoa.AspNetUserId
LEFT JOIN ViewArea va ON va.AreaId = uoa.AreaId
LEFT JOIN PolygonNameOverride pno ON pno.PolygonId = uoa.AreaId
```

### 3.2 Campaign Data
```sql
FROM PropertyCollectionDetail pcd
INNER JOIN PropertyCastWorkflowQueue pcwq ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
INNER JOIN PropertyCast pc ON pc.PropertyCastId = pcwq.PropertyCastId
WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command
```

### 3.3 SMS Data (Texts Sent)
```sql
SELECT srsq.AreaId, SUM(vsqs.Count) AS TextsSent
FROM SmsReportSendQueue srsq
INNER JOIN ViewSmsQueueSendSummary vsqs 
  ON vsqs.SmsReportSendQueueId = srsq.SmsReportSendQueueId
GROUP BY srsq.AreaId
```

### 3.4 Click Data
```sql
SELECT gl.AreaId, SUM(sud.AccessCount) AS Clicks
FROM ShortUrlData sud
INNER JOIN ShortUrlDataLead sudl ON sudl.ShortUrlDataId = sud.ShortUrlDataId
INNER JOIN GenieLead gl ON gl.GenieLeadId = sudl.GenieLeadId
GROUP BY gl.AreaId
```

### 3.5 Lead Data
```sql
SELECT AreaId, COUNT(*) AS LeadsGenerated
FROM GenieLead
WHERE AreaId IS NOT NULL
GROUP BY AreaId
```

---

## 4. Key Business Rules

### 4.1 Competition Command Filter
- **ProductType:** `PropertyCastTypeId = 1` (FarmCast)
- **Trigger Types:** BOTH `ListingSold (1)` AND `ListingNew (2)` are valid CC triggers
- **Ownership Type:** `AreaOwnershipTypeId = 1` (FarmCaster)

### 4.2 Property Type Combining
| PropertyTypeId | Name |
|----------------|------|
| 0 | SFR |
| 1 | Condo |
| 2 | Townhouse |
| 3 | Multi-Family |

When combining: `SFR + Condo` (alphabetical order)

### 4.3 Engagement Metrics Aggregation
- All metrics are aggregated by **AreaId** (not by PropertyTypeId)
- Metrics represent lifetime totals for the area across all property types
- CTR = 0.0% when Texts_Sent = 0

---

## 5. Sample Output

```csv
UserOwnedAreaId,AreaId,Zip_Code,Area_Name,Customer_Name,Property_Types,Ownership_Start,Total_Campaigns,Last_Campaign,Texts_Sent,Clicks,CTR,Leads_Generated,Ownership_Status
205,8859,92028,Fallbrook 92028,Mike Chiesl,SFR,09-10-2025,29,11-25-2025,2175,203,9.3%,115,Active
```

---

## 6. Script

**File:** `build_cc_ownership_v2_iter2.py`  
**Location:** `C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\`

---

## 7. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2025-12-10 | Initial spec with 12 columns |
| v2.0 | 2025-12-10 | Added Texts_Sent, Clicks, CTR, Leads_Generated (Iteration 2) |
