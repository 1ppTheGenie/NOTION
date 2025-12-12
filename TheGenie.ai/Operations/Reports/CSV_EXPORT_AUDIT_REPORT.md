# CSV Export Audit Report
**Date:** 2025-11-11  
**Purpose:** Inventory of CSV exports vs. expected SQL query exports

---

## ✅ **EXPORTED AND FOUND**

| SQL Query | Expected Filename | Status | Found Filename |
|-----------|------------------|--------|----------------|
| `EXPORT_AllOwnedAreas_WithEndDate_LastCampaign_v1.sql` | `AllOwnedAreas_WithEndDate_LastCampaign.csv` | ✅ **FOUND** | `AllOwnedAreas_WithEndDate_LastCampaign.csv` |
| `EXPORT_AllOwnedAreas_ByAllAgents_v1.sql` | `AllOwnedAreas_ByAllAgents.csv` | ✅ **FOUND** | `AllOwnedAreas_ByAllAgents.csv` |
| `EXPORT_AllOwnedAreas_FullHistory_v1.sql` | `AllOwnedAreas_FullHistory.csv` | ✅ **FOUND** | `AllOwnedAreas_FullHistory.csv` |
| `EXPORT_PropertyCastWorkflowQueue_v1.sql` | `PropertyCastWorkflowQueue.csv` | ✅ **FOUND** | `PropertyCastWorkflowQueue.csv` |
| `EXPORT_PropertyCastWorkflowQueueItem_v1.sql` | `PropertyCastWorkflowQueueItem.csv` | ✅ **FOUND** | `PropertyCastWorkflowQueueItem.csv` |
| `EXPORT_ReportQueue_v1.sql` | `ReportQueue.csv` | ✅ **FOUND** | `ReportQueue.csv` |
| `EXPORT_SmsReportSendQueue_v1.sql` | `SmsReportSendQueue.csv` | ✅ **FOUND** | `SmsReportSendQueue.csv` |

---

## ❌ **MISSING EXPORTS**

| SQL Query | Expected Filename | Status | Notes |
|-----------|------------------|--------|-------|
| `EXPORT_AreaNames_ForCampaigns_v1.sql` | `AreaNames_ForCampaigns.csv` | ❌ **MISSING** | Area Name lookup for all campaigns |
| `EXPORT_CTA_EVENTS_Oct2025_v1.sql` | `CTA_Events_Oct2025.csv` | ❌ **MISSING** | CTA events (clicked/verified) for October 2025 |
| `EXPORT_SmsOptOut_Oct2025_v1.sql` | `SmsOptOut_Oct2025.csv` | ❌ **MISSING** | SMS opt-outs for October 2025 |
| `EXPORT_AgentNotifications_Oct2025_v1.sql` | `AgentNotifications_Oct2025.csv` | ❌ **MISSING** | Agent notification SMS for October 2025 |

---

## 📝 **NOTES**

1. **EXPORT_AreaNames_ForAgent_v1.sql**: This query was renamed to `EXPORT_AllOwnedAreas_ByAllAgents_v1.sql` and exports to `AllOwnedAreas_ByAllAgents.csv` (already found ✅)

2. **Similar filenames found but not exact matches:**
   - `SmsOptOut_Columns.csv` - This appears to be a schema export, not the data export from `EXPORT_SmsOptOut_Oct2025_v1.sql`
   - `0101.CTA_Events_Daily_ByUserCTA.csv` - Different query/format, not the expected `CTA_Events_Oct2025.csv`

3. **Total Status:**
   - ✅ **7 exports found** (58%)
   - ❌ **4 exports missing** (42%)

---

## 🎯 **ACTION REQUIRED**

Please run and export the following 4 SQL queries:

1. **EXPORT_AreaNames_ForCampaigns_v1.sql** → `AreaNames_ForCampaigns.csv`
2. **EXPORT_CTA_EVENTS_Oct2025_v1.sql** → `CTA_Events_Oct2025.csv`
3. **EXPORT_SmsOptOut_Oct2025_v1.sql** → `SmsOptOut_Oct2025.csv`
4. **EXPORT_AgentNotifications_Oct2025_v1.sql** → `AgentNotifications_Oct2025.csv`

---

## 📋 **SUMMARY**

**Found:** 7/11 exports (64%)  
**Missing:** 4/11 exports (36%)

All workflow validation exports are complete. Missing exports are primarily data exports needed for the report generation.

