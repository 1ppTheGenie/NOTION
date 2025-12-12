# Fix: "Unable to load recently optimized source data report" Error

## Problem Summary

**Error:** `Unable to load recently optimized source data report`  
**Impact:** SMS reports fail, causing workflows to timeout after 8+ hours  
**Root Cause:** SMS report processing requires reports to be optimized within a lookback window (likely 24 hours). Reports older than this window fail.

## Root Cause Analysis

### Code Location
`Smart.Core.BLL.Report.Sms.SmsReportQueueServiceManager.cs` - Line 63-69

```csharp
var report = GetRecentlyOptimizedReport(smsQueueItem.ReportId, serviceData.ServiceConfig.ReportLookBackHours);

if (report == null)
{
    SetError(smsQueueItem, "Unable to load recently optimized source data report");
    return;
}
```

### Validation Logic (Line 112-125)
The `GetRecentlyOptimizedReport()` method requires:
1. ✅ Report exists
2. ✅ `ResponseCode == Success`
3. ✅ `AppendData == true`
4. ✅ `ProcessDate` is within `ReportLookBackHours` window (likely 24 hours)

**Problem:** If SMS report processing is delayed (service down, queue backup), reports age out of the window and fail permanently.

## Fix Options

### Option 1: Increase ReportLookBackHours (Quick Fix)
**Pros:** Fast, no code changes  
**Cons:** Doesn't solve underlying issue, just delays it

**Steps:**
1. Find `SmsReportServiceConfig` in configuration (likely in `ConfigurationSetting` table or config file)
2. Increase `ReportLookBackHours` from 24 to 168 (7 days) or 720 (30 days)
3. Restart SMS Report Queue Service

**SQL Query to Find Config:**
```sql
-- Find the configuration
SELECT * FROM FarmGenie.dbo.ConfigurationSetting 
WHERE ConfigurationSettingTypeID = [SmsReportServiceConfig Type ID]
  AND Name LIKE '%ReportLookBackHours%' OR ConfigurationJson LIKE '%ReportLookBackHours%';
```

### Option 2: Remove Time Restriction (Recommended)
**Pros:** Solves the root cause, allows any successfully optimized report  
**Cons:** Requires code change and deployment

**Code Change:**
```csharp
// File: SmsReportQueueServiceManager.cs
// Line 112-125: Modify GetRecentlyOptimizedReport()

private Data.SQL.ReportQueue GetRecentlyOptimizedReport(int reportId, int reportLookBackHours)
{
    using(var proxy = new AgentAnalyzerProxy())
    {
        var report = proxy.GetReportById(reportId);

        // REMOVE TIME RESTRICTION - Allow any successfully optimized report
        var successfullyOptimized = report != null
            && report.ResponseCode == (int)ResponseCodeReserved.Success
            && (report.AppendData ?? false);
            // REMOVED: && report.ProcessDate > DateTime.Now.AddHours(-reportLookBackHours);

        return successfullyOptimized ? report : null;
    }
}
```

**Alternative:** Make time check configurable (allow override to disable):
```csharp
private Data.SQL.ReportQueue GetRecentlyOptimizedReport(int reportId, int reportLookBackHours)
{
    using(var proxy = new AgentAnalyzerProxy())
    {
        var report = proxy.GetReportById(reportId);

        if (report == null)
            return null;

        var isSuccess = report.ResponseCode == (int)ResponseCodeReserved.Success
            && (report.AppendData ?? false);

        if (!isSuccess)
            return null;

        // Only check time if ReportLookBackHours > 0 (0 = disabled)
        if (reportLookBackHours > 0)
        {
            var isRecent = report.ProcessDate > DateTime.Now.AddHours(-reportLookBackHours);
            return isRecent ? report : null;
        }

        return report; // Time check disabled, allow any optimized report
    }
}
```

### Option 3: Re-optimize Stale Reports (Best Long-term)
**Pros:** Ensures data freshness, handles edge cases  
**Cons:** More complex, requires optimization service integration

**Code Change:**
```csharp
private Data.SQL.ReportQueue GetRecentlyOptimizedReport(int reportId, int reportLookBackHours)
{
    using(var proxy = new AgentAnalyzerProxy())
    {
        var report = proxy.GetReportById(reportId);

        if (report == null)
            return null;

        var isSuccess = report.ResponseCode == (int)ResponseCodeReserved.Success
            && (report.AppendData ?? false);

        if (!isSuccess)
            return null;

        // Check if report is stale
        var isRecent = report.ProcessDate > DateTime.Now.AddHours(-reportLookBackHours);
        
        if (!isRecent)
        {
            // Re-optimize the report
            Logger.LogWarning($"Report {reportId} is stale ({report.ProcessDate}), re-optimizing...");
            var reoptimizeResponse = ReoptimizeReport(reportId);
            
            if (reoptimizeResponse.Success)
            {
                // Reload the report
                report = proxy.GetReportById(reportId);
                isRecent = report?.ProcessDate > DateTime.Now.AddHours(-reportLookBackHours);
            }
        }

        return isRecent ? report : null;
    }
}
```

### Option 4: Fail Fast with Better Error (Immediate)
**Pros:** Prevents 8-hour timeouts, provides actionable errors  
**Cons:** Doesn't fix the root cause, but improves UX

**Code Change:**
```csharp
// In ProcessItem() method, add better error handling
private void ProcessItem(SmsReportSendQueue smsQueueItem, SmsReportServiceData serviceData)
{
    try
    {                
        smsQueueItem.StartDate = DateTime.Now;

        var report = GetRecentlyOptimizedReport(smsQueueItem.ReportId, serviceData.ServiceConfig.ReportLookBackHours);

        if (report == null)
        {
            // Get report details for better error message
            using(var proxy = new AgentAnalyzerProxy())
            {
                var reportDetails = proxy.GetReportById(smsQueueItem.ReportId);
                
                if (reportDetails == null)
                    SetError(smsQueueItem, $"Report {smsQueueItem.ReportId} not found");
                else if (reportDetails.ResponseCode != (int)ResponseCodeReserved.Success)
                    SetError(smsQueueItem, $"Report {smsQueueItem.ReportId} optimization failed: {reportDetails.ResponseDescription}");
                else if (!(reportDetails.AppendData ?? false))
                    SetError(smsQueueItem, $"Report {smsQueueItem.ReportId} missing append data");
                else
                {
                    var ageHours = (DateTime.Now - reportDetails.ProcessDate.Value).TotalHours;
                    SetError(smsQueueItem, $"Report {smsQueueItem.ReportId} is {ageHours:F1} hours old (max: {serviceData.ServiceConfig.ReportLookBackHours} hours)");
                }
            }
            return;
        }
        // ... rest of method
    }
}
```

## Recommended Fix Strategy

### Immediate (Today)
1. **Increase ReportLookBackHours to 168 hours (7 days)** via configuration
2. **Deploy Option 4** (better error messages) to fail fast instead of timing out
3. **Monitor** for stuck reports using the health check queries

### Short-term (This Week)
1. **Deploy Option 2** (remove time restriction) - allows any successfully optimized report
2. **Add monitoring/alerting** for reports approaching the lookback window
3. **Add retry logic** for failed SMS reports

### Long-term (This Month)
1. **Implement Option 3** (re-optimize stale reports) for data freshness
2. **Add dead-letter queue** for permanently failed reports
3. **Improve workflow timeout handling** - fail workflows immediately when SMS report fails

## SQL Queries to Diagnose & Monitor

### Find Stale Reports (Reports that will fail)
```sql
SELECT 
    srsq.SmsReportSendQueueId,
    srsq.ReportId,
    srsq.CreateDate AS QueuedDate,
    rq.ProcessDate AS ReportOptimizedDate,
    DATEDIFF(HOUR, rq.ProcessDate, GETDATE()) AS HoursSinceOptimization,
    CASE 
        WHEN rq.ProcessDate IS NULL THEN 'Report Not Found'
        WHEN rq.ResponseCode != 1 THEN 'Report Failed'
        WHEN (rq.AppendData = 0 OR rq.AppendData IS NULL) THEN 'Missing Append Data'
        WHEN DATEDIFF(HOUR, rq.ProcessDate, GETDATE()) > 24 THEN 'Stale (>24 hours)'
        ELSE 'OK'
    END AS Status
FROM FarmGenie.dbo.SmsReportSendQueue srsq WITH (NOLOCK)
LEFT JOIN MlsListing.dbo.ReportQueue rq WITH (NOLOCK)
    ON rq.ReportQueueID = srsq.ReportId
WHERE srsq.ProcessDate IS NULL
  AND srsq.CreateDate >= DATEADD(DAY, -7, GETDATE())
ORDER BY srsq.CreateDate DESC;
```

### Check Current Configuration
```sql
-- Find SmsReportServiceConfig
SELECT * FROM FarmGenie.dbo.ConfigurationSetting 
WHERE ConfigurationSettingTypeID IN (
    SELECT ConfigurationSettingTypeID FROM FarmGenie.dbo.ConfigurationSettingType
    WHERE Name LIKE '%SmsReport%'
)
ORDER BY ConfigurationSettingID DESC;
```

### Find Failed Reports by Reason
```sql
SELECT 
    ResponseDescription,
    COUNT(*) AS FailureCount,
    MIN(CreateDate) AS FirstFailure,
    MAX(CreateDate) AS LastFailure
FROM FarmGenie.dbo.SmsReportSendQueue WITH (NOLOCK)
WHERE ResponseCode = 2  -- Error
  AND ProcessDate >= DATEADD(DAY, -7, GETDATE())
GROUP BY ResponseDescription
ORDER BY FailureCount DESC;
```

## Testing Checklist

After deploying fix:
- [ ] Verify SMS reports process successfully for reports older than 24 hours
- [ ] Verify error messages are clear and actionable
- [ ] Verify workflows fail fast (within minutes) instead of timing out after 8 hours
- [ ] Monitor for 24 hours to ensure no regressions
- [ ] Check that successful workflows complete normally

## Rollback Plan

If fix causes issues:
1. Revert configuration change (set ReportLookBackHours back to 24)
2. Revert code changes if Option 2/3/4 deployed
3. Restart SMS Report Queue Service
4. Monitor for 1 hour

## Related Files

- `Smart.Core.BLL.Report.Sms.SmsReportQueueServiceManager.cs` - Main processing logic
- `Smart.Model.Config.Sms.SmsReportServiceConfig.cs` - Configuration model
- `Smart.CasterWorkflow.Core.Business.Workflow.CheckSmsReport.CheckSmsReportSendComplete.cs` - Workflow action
- `FarmGenie.dbo.SmsReportSendQueue` - Database table
- `MlsListing.dbo.ReportQueue` - Report optimization table

