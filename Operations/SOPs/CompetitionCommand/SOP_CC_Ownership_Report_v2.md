# SOP: CC Ownership Report Generation

**Version:** 2.0  
**Created:** 2025-12-10  
**Last Updated:** 2025-12-10  
**Author:** Cursor AI  

---

## 1. Purpose

Standard Operating Procedure for generating the Competition Command (CC) Area Ownership Report with live SQL data, including engagement metrics (SMS, Clicks, CTR, Leads).

---

## 2. Report Specifications

### 2.1 Output File Naming
```
Genie_CC_Ownership_LIFETIME_YYYY-MM-DD_v#_iter2.csv
```

### 2.2 Column Order (14 columns)
| # | Column Name | Type | Example | Description |
|---|-------------|------|---------|-------------|
| 1 | UserOwnedAreaId | Integer | 205 | Database ID |
| 2 | AreaId | Integer | 8859 | Area identifier |
| 3 | Zip_Code | String | 92028 | 5-digit zip code only (extracted) |
| 4 | Area_Name | String | Fallbrook 92028 | With city name (format: City Zip) |
| 5 | Customer_Name | String | Mike Chiesl | Full name |
| 6 | Property_Types | String | SFR + Condo | Combined property types |
| 7 | Ownership_Start | Date | 09-10-2025 | Start date |
| 8 | Total_Campaigns | Integer | 29 | Lifetime campaign count |
| 9 | Last_Campaign | Date | 11-25-2025 | Most recent campaign |
| 10 | Texts_Sent | Integer | 2175 | Total SMS messages sent to area |
| 11 | Clicks | Integer | 203 | Total link clicks tracked |
| 12 | CTR | String | 9.3% | Click-Through Rate |
| 13 | Leads_Generated | Integer | 115 | Total leads captured |
| 14 | Ownership_Status | String | Active / Ended | Current status |

### 2.3 Date Format
```
MM-DD-YYYY
```

---

## 3. Data Sources

### 3.1 Primary Data (Ownership & Campaigns)
| Table | Purpose |
|-------|---------|
| `UserOwnedArea` | Active area ownership records |
| `AspNetUsers` | User accounts |
| `AspNetUserProfiles` | First/Last names |
| `ViewArea` | Default area names |
| `PolygonNameOverride` | Custom area names |
| `PropertyCollectionDetail` | Campaign execution data |
| `PropertyCastWorkflowQueue` | Links campaigns to PropertyCast |
| `PropertyCast` | Product type (FarmCast = CC) |

### 3.2 Engagement Metrics Data
| Metric | Source Tables | Join Key |
|--------|---------------|----------|
| **Texts_Sent** | `SmsReportSendQueue` + `ViewSmsQueueSendSummary` | `AreaId` |
| **Clicks** | `ShortUrlData` + `ShortUrlDataLead` + `GenieLead` | `AreaId` |
| **Leads_Generated** | `GenieLead` | `AreaId` |

### 3.3 CTR Calculation
```python
CTR = (Clicks / Texts_Sent * 100) if Texts_Sent > 0 else 0.0
# Format: "9.3%"
```

---

## 4. Data Transformations

### 4.1 Property Types Combining
When a customer owns both SFR and Condo for the same area, combine into single row:
- **Input:** 2 rows (SFR row + Condo row)
- **Output:** 1 row with `Property_Types = "SFR + Condo"`

Order preference: `SFR + Condo` (not `Condo + SFR`)

### 4.2 Customer Name Resolution
Priority order:
1. `FirstName + ' ' + LastName` (if both exist in AspNetUserProfiles)
2. `UserName` (fallback from AspNetUsers)
3. `Email` (last resort)

### 4.3 Area Name Resolution

**Two columns for area identification:**

| Column | Source | Example |
|--------|--------|---------|
| `Zip_Code` | 5-digit zip extracted via regex `\b(\d{5})\b` | 92028 |
| `Area_Name` | After fallback mapping applied | Fallbrook 92028 |

**Area_Name Format:** "City Zip" (e.g., "Fallbrook 92028")

If raw data is "92028 Fallbrook", flip to "Fallbrook 92028".

**Area_Name Priority order:**
1. `PolygonNameOverride.FriendlyName` (user-customized name)
2. `ViewArea.Name` (system default)
3. **Fallback Mapping** (see Section 5)
4. Raw zip code

---

## 5. Area Name Fallback Mapping

**CRITICAL:** Some areas do not have proper names in `PolygonNameOverride` or `ViewArea`. Use this hardcoded fallback:

```python
AREA_NAME_FALLBACKS = {
    92028: 'Fallbrook 92028',
    94602: 'Oakland 94602',
    94605: 'Oakland 94605',
    94610: 'Montclair 94610',
}
```

### When to Apply Fallback
Apply when:
- `PolygonNameOverride.FriendlyName` is NULL
- `ViewArea.Name` returns only a zip code (all digits)

### Adding New Fallbacks
If a new area appears with only a zip code:
1. Look up the city for that zip code
2. Add to `AREA_NAME_FALLBACKS` dictionary
3. Update this SOP with the new mapping
4. Increment script version

---

## 6. Competition Command Filter

**CRITICAL - Understanding PropertyCast Types:**

| Concept | Column | Values |
|---------|--------|--------|
| **Product Type** | `PropertyCastTypeId` | 1=FarmCast (CC), 2=ListingCommand, 3=NeighborhoodCommand |
| **Trigger Type** | `PopertyCastTriggerTypeId` | 1=ListingSold, 2=ListingNew |

**Competition Command (FarmCast) uses BOTH trigger types:**
- **ListingSold (1):** "A home just SOLD near you" - triggers on sold listings
- **ListingNew (2):** "A new listing near you" - triggers on active listings

```sql
-- CORRECT: Filter by PRODUCT TYPE, not trigger type
WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command
-- (includes both ListingSold and ListingNew triggers)
```

**Campaign Totals (as of 2025-12-10):**
- Type 1 (Listing Sold): 5,052 campaigns
- Type 2 (Listing New): 9,898 campaigns
- **Total CC Campaigns: 14,950**

---

## 7. Execution Steps

### 7.1 Prerequisites
- Python 3.x with `pandas`, `pyodbc`
- Network access to SQL Server (192.168.29.45)
- Database credentials configured

### 7.2 Run Command
```powershell
cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS
python build_cc_ownership_v2_iter2.py
```

### 7.3 Output Files
`Genie_CC_Ownership_LIFETIME_YYYY-MM-DD_v5_iter2.csv` - Full report with engagement metrics

---

## 8. Quality Assurance Checklist

Before delivery, verify:

- [ ] Column headers match spec exactly (14 columns)
- [ ] Date format is MM-DD-YYYY
- [ ] Property_Types shows "SFR + Condo" (not separate rows)
- [ ] Area names in "City Zip" format (not "Zip City")
- [ ] No orphaned zip codes for mapped areas
- [ ] UserOwnedAreaId is integer (not float)
- [ ] Texts_Sent, Clicks, Leads_Generated are integers (0 if no data)
- [ ] CTR shows percentage format (e.g., "9.3%")

### Sample Row Verification
Compare against known good data (Mike Chiesl - Fallbrook):
```
205,8859,92028,Fallbrook 92028,Mike Chiesl,SFR,09-10-2025,29,11-25-2025,2175,203,9.3%,115,Active
```

---

## 9. Report Metrics Summary

| Metric | System-Wide Total (2025-12-10) |
|--------|--------------------------------|
| Total Rows | 95 (75 Active, 20 Ended) |
| Total Campaigns | 10,641 |
| Total Texts Sent | 900,621 |
| Total Clicks | 72,129 |
| Overall CTR | 8.0% |
| Total Leads | 33,509 |

---

## 10. Troubleshooting

### Issue: Area names showing only zip codes
**Cause:** Missing fallback mapping  
**Fix:** Add to `AREA_NAME_FALLBACKS` dictionary

### Issue: Property_Types not combined
**Cause:** Groupby logic failure  
**Fix:** Verify groupby key is `['AspNetUserId', 'AreaId', 'OwnershipStatus']`

### Issue: Engagement metrics all zero
**Cause:** AreaId mismatch between tables  
**Fix:** Verify joins use correct AreaId column

### Issue: CTR shows "inf%" or error
**Cause:** Division by zero (Texts_Sent = 0)  
**Fix:** Add check for Texts_Sent > 0 before calculation

---

## 11. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2025-12-10 | Initial SOP creation |
| v1.1 | 2025-12-10 | Removed Last_Name/First_Name columns, added Zip_Code |
| v1.2 | 2025-12-10 | Fixed Zip_Code to extract 5-digit zip only |
| v2.0 | 2025-12-10 | Changed TriggerTypeId filter (incorrect) |
| v3.0 | 2025-12-10 | **CORRECT FIX:** Filter by PropertyCastTypeId=1 |
| **v4.0** | **2025-12-10** | **Added Iteration 2:** Texts_Sent, Clicks, CTR, Leads_Generated columns |

---

## 12. Related Documents

- `SPEC_OwnedAreas_Report_v1.md` - Original report specification
- `FR-001_AreaOwnership_DesignBrief_v1.md` - Feature request for ownership system
- `FR-001_AreaOwnership_DevSpec_v2.md` - Development specification with campaign history

---

## 13. Script Location

**Production Script:** 
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\build_cc_ownership_v2_iter2.py
```

**Dependencies:**
- `pandas`
- `pyodbc`
- `re` (regex for zip extraction)
