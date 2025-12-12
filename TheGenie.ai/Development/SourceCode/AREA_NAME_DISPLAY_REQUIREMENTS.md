# AREA NAME DISPLAY REQUIREMENTS

## Purpose
Area Name is a **HEADER FIELD** (not a data column) that shows the marketing-friendly name of the geographic area where campaigns were run.

---

## Priority Order (CRITICAL)

Area Name must be resolved using this exact priority (3 levels only):

1. **PolygonNameOverride.FriendlyName** (agent's custom name override)
2. **ViewArea.AreaName** (default marketing name)
3. **ViewArea.PolygonName** (polygon name)

**NO FALLBACK** - If all 3 are NULL, AreaName will be NULL.

**SQL Pattern:**
```sql
COALESCE(pno.FriendlyName, va.AreaName, va.PolygonName) AS AreaName
```

---

## Required Data Sources

### 1. Database Tables (for SQL export)
- `PropertyCollectionDetail` (has `AreaId` and `AspNetUserId`)
- `ViewArea` (has `AreaId`, `AreaName`, `PolygonName`)
- `PolygonNameOverride` (has `PolygonId` = `AreaId`, `FriendlyName`, `AspNetUserId`)

### 2. CSV Export (for Python script)
**File:** `AreaNames_ForCampaigns.csv`

**Required Columns:**
- `AreaId` (INT)
- `AreaName` (VARCHAR) - resolved using priority order above

**Export Query:** `EXPORT_AreaNames_ForCampaigns_v1.sql`

---

## Export Query Requirements

The export query MUST:

1. **Join PropertyCollectionDetail → ViewArea → PolygonNameOverride**
   ```sql
   FROM dbo.PropertyCollectionDetail pcd
   LEFT JOIN dbo.ViewArea va ON va.AreaId = pcd.AreaId
   LEFT JOIN dbo.PolygonNameOverride pno 
       ON pno.PolygonId = pcd.AreaId 
       AND pno.AspNetUserId = pcd.AspNetUserId  -- CRITICAL: Agent-specific override
   ```

2. **Use COALESCE with priority order**
   ```sql
   COALESCE(pno.FriendlyName, va.AreaName, va.PolygonName, 'Unknown Area') AS AreaName
   ```

3. **Filter by date range** (if needed)
   ```sql
   WHERE pcd.CreateDate >= @MonthStart
     AND pcd.CreateDate < DATEADD(DAY, 1, @MonthEnd)
     AND pcd.AreaId IS NOT NULL
   ```

4. **Include agent filter** (if exporting for specific agent)
   ```sql
   AND pcd.AspNetUserId = @AgentId
   ```

---

## Python Script Requirements

### Current Implementation Status

✅ **Area Name Lookup:**
- Loads from `AreaNames_ForCampaigns.csv` (if exists)
- Falls back to `0302.CC_PropertyCollection_Details.csv` if `AreaName` column exists
- Uses 'Unknown Area' as final fallback

✅ **AreaId Filtering:**
- AreaId is PRIMARY FILTER (#1 criteria)
- Filters campaigns by AreaId when `--areaId` parameter provided

✅ **Area Name Storage:**
- Captured in `metrics['AreaName']` for potential header use
- **NOT included in data columns** (per original spec - 21 fields only)

---

## Display Requirements

### Header Display (per original spec)

Area Name should appear in the **REPORT HEADER** section:

```
For: David Higgins
Date Range: 10/01/2025 - 10/31/2025
Area Name: Piedmont | 94611
```

### Data Columns

Area Name is **NOT** a data column. The report has exactly **21 data columns**:
1. Campaign Date
2. Campaign Type
3. Subject Property
... (through 21)

---

## Verification Checklist

To ensure Area Name displays properly:

- [ ] `EXPORT_AreaNames_ForCampaigns_v1.sql` has been run
- [ ] `AreaNames_ForCampaigns.csv` exists in the working directory
- [ ] CSV has both `AreaId` and `AreaName` columns
- [ ] `AreaName` values follow priority order (FriendlyName > AreaName > PolygonName)
- [ ] Agent-specific overrides are included (PolygonNameOverride filtered by AspNetUserId)
- [ ] Python script loads Area Names successfully (check console output)
- [ ] Area Name is available for header display (stored in `metrics['AreaName']`)

---

## Common Issues

### Issue: "Unknown Area" appears
**Causes:**
- `AreaNames_ForCampaigns.csv` not exported
- CSV missing `AreaName` column
- All AreaName values are NULL/empty
- ViewArea table has no matching AreaId

**Solution:**
1. Run `EXPORT_AreaNames_ForCampaigns_v1.sql`
2. Verify CSV has data
3. Check that AreaId values exist in ViewArea table

### Issue: Agent's custom name not showing
**Causes:**
- PolygonNameOverride join missing `AspNetUserId` filter
- Agent hasn't set a custom name
- PolygonNameOverride.FriendlyName is NULL

**Solution:**
- Ensure export query includes: `AND pno.AspNetUserId = pcd.AspNetUserId`
- Check PolygonNameOverride table for agent's custom names

### Issue: Area Name not in header
**Causes:**
- Python script doesn't output header section
- Area Name only stored in metrics, not displayed

**Solution:**
- Add header output to Python script (if needed)
- Area Name is available in `metrics['AreaName']` for header generation

---

## Example: Dave Higgins Area 9610

**Expected Area Name:** "Piedmont | 94611" (from PolygonNameOverride.FriendlyName)

**Query to verify:**
```sql
SELECT TOP 1 
    COALESCE(pno.FriendlyName, va.AreaName, va.PolygonName, 'Unknown Area') AS AreaName
FROM dbo.PropertyCollectionDetail pcd
INNER JOIN dbo.ViewArea va ON va.AreaId = pcd.AreaId
LEFT JOIN dbo.PolygonNameOverride pno 
    ON pno.PolygonId = va.AreaId 
    AND pno.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.AreaId = 9610
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01';
```

**Expected Result:** "Piedmont | 94611"

---

## Summary

**Requirements:**
1. ✅ Export `AreaNames_ForCampaigns.csv` using `EXPORT_AreaNames_ForCampaigns_v1.sql`
2. ✅ Use COALESCE with priority: FriendlyName > AreaName > PolygonName > 'Unknown Area'
3. ✅ Include agent-specific filter for PolygonNameOverride
4. ✅ Python script loads CSV and creates lookup dictionary
5. ✅ Area Name available for header display (not in data columns)

**Current Status:**
- ✅ Export query created
- ✅ Python script loads Area Names
- ✅ Priority order implemented
- ⚠️  CSV must be exported before running Python script

