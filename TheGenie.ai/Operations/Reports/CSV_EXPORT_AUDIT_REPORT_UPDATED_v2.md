# CSV Export Audit Report - UPDATED
**Date:** 2025-11-11 (Updated)  
**Purpose:** Inventory of CSV exports vs. expected SQL query exports

---

## ✅ **ALL PRIMARY EXPORTS COMPLETE**

| SQL Query | Expected Filename | Status | Found Filename |
|-----------|------------------|--------|----------------|
| `EXPORT_AllOwnedAreas_WithEndDate_LastCampaign_v1.sql` | `AllOwnedAreas_WithEndDate_LastCampaign.csv` | ✅ **FOUND** | `AllOwnedAreas_WithEndDate_LastCampaign.csv` |
| `EXPORT_AllOwnedAreas_ByAllAgents_v1.sql` | `AllOwnedAreas_ByAllAgents.csv` | ✅ **FOUND** | `AllOwnedAreas_ByAllAgents.csv` |
| `EXPORT_AllOwnedAreas_FullHistory_v1.sql` | `AllOwnedAreas_FullHistory.csv` | ✅ **FOUND** | `AllOwnedAreas_FullHistory.csv` |
| `EXPORT_PropertyCastWorkflowQueue_v1.sql` | `PropertyCastWorkflowQueue.csv` | ✅ **FOUND** | `PropertyCastWorkflowQueue.csv` |
| `EXPORT_PropertyCastWorkflowQueueItem_v1.sql` | `PropertyCastWorkflowQueueItem.csv` | ✅ **FOUND** | `PropertyCastWorkflowQueueItem.csv` |
| `EXPORT_ReportQueue_v1.sql` | `ReportQueue.csv` | ✅ **FOUND** | `ReportQueue.csv` |
| `EXPORT_SmsReportSendQueue_v1.sql` | `SmsReportSendQueue.csv` | ✅ **FOUND** | `SmsReportSendQueue.csv` |
| `EXPORT_AreaNames_ForCampaigns_v1.sql` | `AreaNames_ForCampaigns.csv` | ✅ **FOUND** | `AreaNames_ForCampaigns.csv` |
| `EXPORT_CTA_EVENTS_Oct2025_v1.sql` | `CTA_Events_Oct2025.csv` | ✅ **FOUND** | `CTA_Events_Oct2025.csv` |
| `EXPORT_SmsOptOut_Oct2025_v1.sql` | `SmsOptOut_Oct2025.csv` | ✅ **FOUND** | `SmsOptOut_Oct2025.csv` |
| `EXPORT_AgentNotifications_Oct2025_v1.sql` | `AgentNotifications.csv` | ✅ **FOUND** | `AgentNotifications.csv` |

---

## 📋 **SUMMARY**

**Status:** ✅ **ALL PRIMARY EXPORTS COMPLETE**

- ✅ **11/11 primary exports found** (100%)
- ❌ **0 exports missing**

---

## 📝 **ADDITIONAL FILES FOUND**

The following additional CSV files were found (may be from alternative queries or previous exports):

- `AgentNotifications2.csv` - Additional agent notifications export
- `AgentNotifications_ALTERNATIVE.csv` - Alternative version export
- `CTA_Events.csv` - Generic CTA events (may be from different query)
- `SmsOptOut_Columns.csv` - Schema export, not data export

---

## 🎯 **NEXT STEPS**

All primary export queries have been successfully exported to CSV. The project is ready for report generation using these data sources.

**Note:** The export filenames may differ slightly from the SQL query headers (e.g., `AgentNotifications.csv` instead of `AgentNotifications_Oct2025.csv`), but all required data exports are present.

