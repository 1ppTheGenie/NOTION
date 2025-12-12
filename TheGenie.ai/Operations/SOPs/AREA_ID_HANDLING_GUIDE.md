# AREA ID HANDLING GUIDE

## CRITICAL: Area Name is User Input, AreaId is Internal Filter Only

### CRITICAL RULE: NEVER DISPLAY OR REQUIRE AREA ID FROM USERS
- **AreaId:** Internal database filter only - NEVER displayed, NEVER asked from users
- **Area Name:** User-facing - ALWAYS displayed, ALWAYS used for input
- **Conversion:** System converts Area Name → AreaId internally

### Filter Priority Order:
1. **Area Name** (user provides) → converts to **AreaId** (internal filter - #1 criteria)
2. Agent ID
3. Date Range

---

## How Area IDs Work

### 1. Finding Area IDs for an Agent

**Query to find all Area IDs for an agent in a date range:**
```sql
SELECT DISTINCT
    pcd.AreaId,
    COUNT(*) AS CampaignCount
FROM dbo.PropertyCollectionDetail pcd WITH (NOLOCK)
WHERE pcd.AspNetUserId = @AgentId
  AND pcd.CreateDate >= @MonthStart
  AND pcd.CreateDate < DATEADD(DAY, 1, @MonthEnd)
GROUP BY pcd.AreaId
ORDER BY CampaignCount DESC;
```

**Example: Dave Higgins (23d254fe-792f-44b2-b40f-9b1d7a12189d) in October 2025:**
- AreaId **9610**: 1500 campaigns (most common)
- AreaId **9609**: 975 campaigns
- AreaId **9573**: 850 campaigns
- AreaId **9602**: 750 campaigns
- AreaId **336487**: 650 campaigns

---

### 2. Getting Area Name from Area ID

**Priority order for Area Name (3 levels only):**
1. `PolygonNameOverride.FriendlyName` (user-specific override)
2. `ViewArea.AreaName`
3. `ViewArea.PolygonName`

**NO FALLBACK** - If all 3 are NULL, AreaName will be NULL.

**SQL Query to get Area Name:**
```sql
SELECT TOP 1 
    COALESCE(pno.FriendlyName, va.AreaName, va.PolygonName) AS AreaName
FROM dbo.PropertyCollectionDetail pcd WITH (NOLOCK)
INNER JOIN dbo.ViewArea va WITH (NOLOCK) ON va.AreaId = pcd.AreaId
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) 
    ON pno.PolygonId = va.AreaId 
    AND pno.AspNetUserId = @AgentId
WHERE pcd.AspNetUserId = @AgentId
  AND pcd.AreaId = @AreaId
  AND pcd.CreateDate >= @MonthStart
  AND pcd.CreateDate < DATEADD(DAY, 1, @MonthEnd);
```

---

### 3. Exporting Area Names for CSV Reports

**Run this query to export Area Names:**
```sql
-- EXPORT_AreaNames_ForCampaigns_v1.sql
SELECT DISTINCT
  pcd.AreaId,
  COALESCE(pno.FriendlyName, va.AreaName, va.PolygonName) AS AreaName
FROM dbo.PropertyCollectionDetail pcd WITH (NOLOCK)
LEFT JOIN dbo.ViewArea va WITH (NOLOCK) 
  ON va.AreaId = pcd.AreaId
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) 
  ON pno.PolygonId = pcd.AreaId 
  AND pno.AspNetUserId = pcd.AspNetUserId
WHERE pcd.CreateDate >= '2025-10-01'
  AND pcd.CreateDate < '2025-11-01'
  AND pcd.AreaId IS NOT NULL
ORDER BY pcd.AreaId;
```

**Save as:** `AreaNames_ForCampaigns.csv`

---

## Python Script Usage

### Required Parameters:
```bash
python3 build_report_from_csv_and_twilio_FINAL.py \
  --agentId "23d254fe-792f-44b2-b40f-9b1d7a12189d" \
  --areaName "Piedmont | 94611" \
  --fromDate "10/01/2025" \
  --thruDate "10/31/2025"
```

### Key Points:
- **`--areaName` is user input** - Users provide Area Name (e.g., "Piedmont | 94611")
- **AreaId is looked up internally** - System converts Area Name → AreaId for filtering
- **AreaId is NEVER displayed** - Only Area Name appears in report header
- If `--areaName` is not provided, the script will include ALL areas
- Area Name will be displayed in the report HEADER (not in data columns)

---

## Report Output

The report will include:
- **Area Name** column (3rd column, after "Campaign Type")
- All campaigns filtered by the specified AreaId
- Area Name comes from the `AreaNames_ForCampaigns.csv` file or campaigns CSV

---

## Workflow

1. **Identify Agent ID** (e.g., Dave Higgins: `23d254fe-792f-44b2-b40f-9b1d7a12189d`)
2. **Find Area IDs** for that agent in the date range (run query above)
3. **Export Area Names** (run `EXPORT_AreaNames_ForCampaigns_v1.sql`)
4. **Run Python script** with `--areaId` parameter
5. **Verify** Area Name appears correctly in the report

---

## Common Issues

### Issue: "Area Name" column shows "Unknown Area"
**Solution:** 
- Export `AreaNames_ForCampaigns.csv` using the SQL query above
- Ensure the CSV has both `AreaId` and `AreaName` columns
- Place the CSV in the same directory as the Python script

### Issue: Report includes campaigns from wrong area
**Solution:**
- Always specify `--areaId` parameter
- Verify the AreaId matches the campaigns you want
- Check that campaigns CSV has correct AreaId values

### Issue: Multiple areas in one report
**Solution:**
- Run the script separately for each AreaId
- Each AreaId requires its own report run
- Combine reports in Excel if needed

---

## Example: Dave Higgins October 2025

**Most common area:**
```bash
python3 build_report_from_csv_and_twilio_FINAL.py \
  --agentId "23d254fe-792f-44b2-b40f-9b1d7a12189d" \
  --areaId 9610 \
  --fromDate "10/01/2025" \
  --thruDate "10/31/2025" \
  --out "Dave_Higgins_Area9610_Oct2025_v1.csv"
```

**Other areas:**
```bash
# Area 9609
python3 build_report_from_csv_and_twilio_FINAL.py \
  --agentId "23d254fe-792f-44b2-b40f-9b1d7a12189d" \
  --areaId 9609 \
  --fromDate "10/01/2025" \
  --thruDate "10/31/2025" \
  --out "Dave_Higgins_Area9609_Oct2025_v1.csv"
```

---

## Summary

✅ **AreaId is PRIMARY FILTER (#1 criteria)**
✅ **Always specify `--areaId` when running the script**
✅ **Export Area Names CSV before running report**
✅ **Area Name appears in report as 3rd column**
✅ **One AreaId = One Report (run separately for each area)**

