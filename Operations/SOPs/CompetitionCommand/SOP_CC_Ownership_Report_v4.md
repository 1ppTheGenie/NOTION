# SOP: CC Ownership Report Generation

**Version:** 1.0  
**Created:** 2025-12-10  
**Last Updated:** 2025-12-10  
**Author:** Cursor AI  

---

## 1. Purpose

Standard Operating Procedure for generating the Competition Command (CC) Area Ownership Report with live SQL data.

---

## 2. Report Specifications

### 2.1 Output File Naming
```
Genie_CC_Ownership_Full_YYYY-MM-DD_v#.csv
```

### 2.2 Column Order (14 columns)
| # | Column Name | Type | Example | Description |
|---|-------------|------|---------|-------------|
| 1 | UserOwnedAreaId | Integer | 66 | Database ID |
| 2 | AreaId | Integer | 8851 | Area identifier |
| 3 | Zip_Code | String | 94602 | 5-digit zip code only (extracted) |
| 4 | Area_Name | String | Oakland 94602 | With city name override |
| 5 | Customer_Name | String | Jason Barry | Full name |
| 6 | UserName | String | JBarry1 | Login username |
| 7 | Email | String | jason@barryestates.com | Email address |
| 8 | Property_Types | String | SFR + Condo | Combined property types |
| 9 | Ownership_Start | Date | 05-31-2024 | Start date |
| 10 | Ownership_End | Date | (empty if active) | End date |
| 11 | Last_Campaign | Date | 01-19-2025 | Most recent campaign |
| 12 | Total_Campaigns | Integer | 46 | Lifetime campaign count |
| 13 | Days_Since_Campaign | Integer | 325 | Days since last campaign |
| 14 | Status | String | Active / Ended | Current status |

**Note:** Last_Name and First_Name columns removed in v8. Zip_Code column added in v10.

### 2.3 Date Format
```
MM-DD-YYYY
```

---

## 3. Data Transformations

### 3.1 Property Types Combining
When a customer owns both SFR and Condo for the same area, combine into single row:
- **Input:** 2 rows (SFR row + Condo row)
- **Output:** 1 row with `Property_Types = "SFR + Condo"`

Order preference: `SFR + Condo` (not `Condo + SFR`)

### 3.2 Customer Name Resolution
Priority order:
1. `FirstName + ' ' + LastName` (if both exist)
2. `UserName` (fallback)
3. `Email` (last resort)

### 3.3 Area Name Resolution

**Two columns for area identification:**

| Column | Source | Example |
|--------|--------|---------|
| `Zip_Code` | 5-digit zip extracted via regex `\b(\d{5})\b` | 94602 |
| `Area_Name` | After fallback mapping applied | Oakland 94602 |

**Zip_Code Extraction Logic:**
```python
import re
match = re.search(r'\b(\d{5})\b', area_name)
zip_code = match.group(1) if match else area_name
```

**Area_Name Priority order:**
1. `PolygonNameOverride.FriendlyName` (user-customized name)
2. `ViewArea.Name` (system default)
3. **Fallback Mapping** (see Section 4)
4. Raw zip code

---

## 4. Area Name Fallback Mapping

**CRITICAL:** Some areas do not have proper names in `PolygonNameOverride` or `ViewArea`. Use this hardcoded fallback:

```python
AREA_NAME_FALLBACKS = {
    9602: 'Oakland 94602',
    9609: 'Montclair 94610',
    9610: 'Piedmont 94611',
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

## 5. Source SQL Query

**Script:** `build_cc_ownership_LIVE_v2.py`  
**SQL File Reference:** `EXPORT_AllOwnedAreas_WithEndDate_LastCampaign.sql`

### Key Tables
| Table | Purpose |
|-------|---------|
| `UserOwnedArea` | Active area ownership records |
| `UserOwnedAreaDeleted` | Historical/ended ownership records |
| `AspNetUsers` | User accounts |
| `AgentProfile` | First/Last names |
| `ViewArea` | Default area names |
| `PolygonNameOverride` | Custom area names |
| `PropertyCast` | Campaign execution data |
| `AreaOwnershipType` | FarmCaster vs other types |

### Filter: Competition Command Only

**CRITICAL - PropertyCast Trigger Types:**
| TriggerTypeId | Name | Product |
|---------------|------|---------|
| 1 | Listing Sold | (Not CC) |
| 2 | Listing New | **Competition Command** |

```sql
-- Competition Command campaigns use Trigger Type 2 (Listing New)
WHERE pc.PopertyCastTriggerTypeId = 2

-- Ownership type filter
WHERE aot.Name = 'FarmCaster'
```

**NOTE:** Competition Command triggers on NEW listings (Type 2), NOT sold listings (Type 1).

---

## 6. Execution Steps

### 6.1 Prerequisites
- Python 3.x with `pandas`, `pyodbc`, `openpyxl`
- Network access to SQL Server (192.168.29.45)
- Database credentials configured

### 6.2 Run Command
```powershell
cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS
python build_cc_ownership_LIVE_v2.py
```

### 6.3 Output Files
1. `CC_Ownership_RAW_YYYY-MM-DD.csv` - Raw SQL output (137+ rows)
2. `Genie_CC_Ownership_Full_YYYY-MM-DD_v#.csv` - Combined report (95+ rows)

---

## 7. Quality Assurance Checklist

Before delivery, verify:

- [ ] Column headers match spec exactly (15 columns)
- [ ] Date format is MM-DD-YYYY
- [ ] Property_Types shows "SFR + Condo" (not separate rows)
- [ ] Area names include city where applicable
- [ ] No orphaned zip codes for mapped areas (9602, 9609, 9610)
- [ ] UserOwnedAreaId is integer (not float)
- [ ] Ended records have Ownership_End date populated
- [ ] Active records have empty Ownership_End

### Sample Row Verification
Compare against known good data (e.g., David Higgins - Oakland):
```
164,9602,94602,Oakland 94602,David Higgins,DHiggins,david@cushrealestate.com,SFR + Condo,11-18-2024,,12-07-2025,168,3,Active
```
- `Zip_Code`: "94602" (5-digit zip only, extracted via regex)
- `Area_Name`: "Oakland 94602" (with city name fallback applied)

---

## 8. Troubleshooting

### Issue: Area names showing only zip codes
**Cause:** Missing fallback mapping  
**Fix:** Add to `AREA_NAME_FALLBACKS` dictionary

### Issue: Property_Types not combined
**Cause:** Groupby logic failure  
**Fix:** Verify groupby key is `['AspNetUserId', 'AreaId', 'OwnershipStatus']`

### Issue: Dates in wrong format
**Cause:** strftime format string incorrect  
**Fix:** Use `'%m-%d-%Y'`

---

## 9. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1 | 2025-12-10 | Initial SOP creation |
| v1.1 | 2025-12-10 | Removed Last_Name/First_Name columns, added Zip_Code column |
| v1.2 | 2025-12-10 | Fixed Zip_Code to extract 5-digit zip only (no city names) |
| v2.0 | 2025-12-10 | **CRITICAL FIX:** Changed TriggerTypeId from 1 to 2 (CC = Listing New) |

---

## 10. Related Documents

- `SPEC_OwnedAreas_Report_v1.md` - Original report specification
- `SPEC_CompCommand_MonthlyCostReport_v1.md` - Monthly cost report spec
- `FR-001_AreaOwnership_DesignBrief_v1.md` - Feature request for ownership system

