-- LISTING COMMAND REPORT - DECEMBER 2025 (1-14)
SET NOCOUNT ON;
DECLARE @Dec_Start DATE = '2025-12-01';
DECLARE @Dec_End DATE = '2025-12-15';

;WITH 
LCBase AS (
    SELECT srq.AreaId, uoa.AspNetUserId,
        COUNT(DISTINCT srq.SmsReportSendQueueId) AS Campaigns, SUM(v.Count) AS Msgs_Sent
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    LEFT JOIN UserOwnedArea uoa WITH (NOLOCK) ON uoa.AreaId = srq.AreaId
    WHERE srq.CreateDate >= @Dec_Start AND srq.CreateDate < @Dec_End
      AND srq.UtmSource = 'Listing Command' AND srq.AreaId IS NOT NULL
    GROUP BY srq.AreaId, uoa.AspNetUserId
),
DeliveredCounts AS (
    SELECT srq.AreaId, SUM(v.Count) AS Delivered
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    WHERE srq.CreateDate >= @Dec_Start AND srq.CreateDate < @Dec_End
      AND srq.UtmSource = 'Listing Command' AND v.ResponseCode = 1
    GROUP BY srq.AreaId
),
Clicks AS (
    SELECT gl.AreaId, COUNT(DISTINCT gl.GenieLeadId) AS Clicks
    FROM dbo.GenieLead gl WITH (NOLOCK)
    WHERE gl.CreateDate >= @Dec_Start AND gl.CreateDate < @Dec_End AND gl.AreaId IS NOT NULL
    GROUP BY gl.AreaId
),
CTAEvents AS (
    SELECT gl.AreaId,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE 'Cta%Accept%' OR ltt.Tag LIKE 'Cta%Submit%' THEN gl.GenieLeadId END) AS CTA_Submitted,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE '%CtaContactVerified%' OR ltt.Tag LIKE '%CtaContactVerfied%' THEN gl.GenieLeadId END) AS CTA_Verified
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    INNER JOIN dbo.GenieLeadTagType ltt WITH (NOLOCK) ON ltt.GenieLeadTagTypeId = glt.LeadTagTypeId
    WHERE gl.CreateDate >= @Dec_Start AND gl.CreateDate < @Dec_End AND gl.AreaId IS NOT NULL AND ltt.Tag LIKE 'Cta%'
    GROUP BY gl.AreaId
),
AgentNotifyRaw AS (
    SELECT nq.NotificationQueueId,
        TRY_CONVERT(BIGINT, SUBSTRING(CAST(nq.CustomData AS NVARCHAR(MAX)), 
             CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8,
             CHARINDEX('"', CAST(nq.CustomData AS NVARCHAR(MAX)), CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8)
             - CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) - 8)) AS GenieLeadId,
        ABS(ISNULL(tm.Price, 0)) AS TwilioCost
    FROM dbo.NotificationQueue nq WITH (NOLOCK)
    LEFT JOIN dbo.TwilioMessage tm WITH (NOLOCK) ON tm.Sid = nq.ProviderResponseKey
    WHERE nq.CreateDate >= @Dec_Start AND nq.CreateDate < @Dec_End
      AND nq.NotificationTypeId = 24 AND nq.NotificationChannelId = 2
      AND CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) > 0
),
AgentNotify AS (
    SELECT gl.AreaId, COUNT(DISTINCT anr.NotificationQueueId) AS Agent_Notify, SUM(anr.TwilioCost) AS Agent_Notify_Cost
    FROM AgentNotifyRaw anr
    INNER JOIN dbo.GenieLead gl WITH (NOLOCK) ON gl.GenieLeadId = anr.GenieLeadId
    WHERE gl.AreaId IS NOT NULL AND gl.AreaId > 0
    GROUP BY gl.AreaId
)
SELECT 
    'Listing Command - Dec 2025' AS Report,
    ISNULL(up.FirstName + ' ' + up.LastName, u.UserName) AS Customer_Name,
    COALESCE(pno.FriendlyName, va.Name, CAST(lc.AreaId AS VARCHAR)) AS Area_Name,
    lc.AreaId,
    lc.Campaigns,
    lc.Msgs_Sent,
    ISNULL(dc.Delivered, 0) AS Delivered,
    CAST(CASE WHEN lc.Msgs_Sent > 0 THEN ISNULL(dc.Delivered,0) * 100.0 / lc.Msgs_Sent ELSE 0 END AS VARCHAR) + '%' AS Success_Pct,
    ISNULL(clk.Clicks, 0) AS Clicks,
    CAST(CASE WHEN lc.Msgs_Sent > 0 THEN ISNULL(clk.Clicks,0) * 100.0 / lc.Msgs_Sent ELSE 0 END AS VARCHAR) + '%' AS CTR_Pct,
    ISNULL(cta.CTA_Submitted, 0) AS CTA_Sub,
    ISNULL(cta.CTA_Verified, 0) AS CTA_Ver,
    ISNULL(an.Agent_Notify, 0) AS Agent_Notify,
    '$' + CAST(ISNULL(an.Agent_Notify_Cost, 0) AS VARCHAR) AS Notify_Cost
FROM LCBase lc
LEFT JOIN dbo.AspNetUsers u WITH (NOLOCK) ON u.Id = lc.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up WITH (NOLOCK) ON up.AspNetUserId = lc.AspNetUserId
LEFT JOIN dbo.ViewArea va WITH (NOLOCK) ON va.AreaId = lc.AreaId
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) ON pno.PolygonId = lc.AreaId AND pno.AspNetUserId = lc.AspNetUserId
LEFT JOIN DeliveredCounts dc ON dc.AreaId = lc.AreaId
LEFT JOIN Clicks clk ON clk.AreaId = lc.AreaId
LEFT JOIN CTAEvents cta ON cta.AreaId = lc.AreaId
LEFT JOIN AgentNotify an ON an.AreaId = lc.AreaId
ORDER BY lc.Campaigns DESC;

-- Summary
PRINT '';
PRINT '=== LISTING COMMAND DECEMBER 2025 SUMMARY ===';
SELECT 
    COUNT(*) AS Total_Areas,
    SUM(lc.Campaigns) AS Total_Campaigns,
    SUM(lc.Msgs_Sent) AS Total_Msgs_Sent
FROM (
    SELECT srq.AreaId,
        COUNT(DISTINCT srq.SmsReportSendQueueId) AS Campaigns, SUM(v.Count) AS Msgs_Sent
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    WHERE srq.CreateDate >= @Dec_Start AND srq.CreateDate < @Dec_End
      AND srq.UtmSource = 'Listing Command' AND srq.AreaId IS NOT NULL
    GROUP BY srq.AreaId
) lc;

