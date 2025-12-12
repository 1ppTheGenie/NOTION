# AREA ID vs AREA NAME - CRITICAL SPECIFICATION

## CRITICAL RULE: NEVER DISPLAY OR REQUIRE AREA ID FROM USERS

### AreaId = INTERNAL ONLY
- **Purpose:** Database filter (#1 PRIMARY FILTER criteria)
- **Visibility:** NEVER displayed to users
- **User Input:** NEVER ask users for AreaId
- **Display:** NEVER show AreaId in reports, headers, or output

### Area Name = USER-FACING ONLY
- **Purpose:** What users see and understand
- **User Input:** Users provide Area Name (e.g., "Piedmont | 94611")
- **Display:** Area Name appears in report HEADER
- **Lookup:** System converts Area Name → AreaId internally for filtering

---

## WORKFLOW

1. **User provides:** Area Name (e.g., "Piedmont | 94611")
2. **System looks up:** AreaId from Area Name (via AreaNames_ForCampaigns.csv or database)
3. **System filters:** Campaigns by AreaId (internal, never shown)
4. **System displays:** Area Name in report header (user-friendly)

---

## SPECIFICATION UPDATES

### Python Script Parameters
**WRONG:**
```bash
--areaId 9610  # ❌ NEVER - users don't know AreaIds
```

**CORRECT:**
```bash
--areaName "Piedmont | 94611"  # ✅ Users know Area Names
```

### Report Output
**WRONG:**
```
Report for Area 9610  # ❌ NEVER show AreaId
```

**CORRECT:**
```
Report for: Piedmont | 94611  # ✅ Show Area Name
```

---

## IMPLEMENTATION REQUIREMENTS

1. **Script must accept `--areaName` parameter** (not `--areaId`)
2. **Script must lookup AreaId from Area Name** internally
3. **AreaId used only for filtering** (never displayed)
4. **Area Name displayed in report header** (user-friendly)
5. **Error handling:** If Area Name not found, show error with available Area Names

---

## AREA NAME LOOKUP

The script must:
1. Load `AreaNames_ForCampaigns.csv` (AreaId → AreaName mapping)
2. Create reverse lookup: AreaName → AreaId
3. Use AreaId for filtering campaigns
4. Display Area Name in header

**Lookup Pattern:**
```python
# Load Area Names CSV
area_names = pd.read_csv("AreaNames_ForCampaigns.csv")
area_lookup = dict(zip(area_names['AreaName'], area_names['AreaId']))

# User provides Area Name
user_area_name = "Piedmont | 94611"

# Lookup AreaId internally
area_id = area_lookup.get(user_area_name)

# Filter by AreaId (internal)
campaigns = campaigns[campaigns['AreaId'] == area_id]

# Display Area Name (user-facing)
header['Area Name'] = user_area_name
```

---

## ERROR HANDLING

If Area Name not found:
1. Show available Area Names for the agent
2. Ask user to select from list
3. NEVER show AreaIds to user

---

## SUMMARY

✅ **AreaId:** Internal filter only - NEVER displayed, NEVER asked from users  
✅ **Area Name:** User-facing - ALWAYS displayed, ALWAYS used for input  
✅ **Conversion:** Area Name → AreaId (internal lookup)  
✅ **Display:** Area Name in header, AreaId never shown

