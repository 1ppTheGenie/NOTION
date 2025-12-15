-- FINAL Competition Command Report with ALL metrics - November 2025
SET NOCOUNT ON;

PRINT '=============================================================';
PRINT 'COMPETITION COMMAND REPORT - NOVEMBER 2025';
PRINT 'All columns with REAL data from production database';
PRINT '=============================================================';
PRINT '';

;WITH 
-- Competition Command Areas with campaigns in Nov 2025
CCCampaigns AS (
    SELECT 
        pc.AreaId,
        pcd.AspNetUserId,
        COUNT(*) AS Campaign_Count
    FROM dbo.PropertyCollectionDetail pcd WITH (NOLOCK)
    INNER JOIN dbo.PropertyCastWorkflowQueue pcwq WITH (NOLOCK) ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
    INNER JOIN dbo.PropertyCast pc WITH (NOLOCK) ON pc.PropertyCastId = pcwq.PropertyCastId
    WHERE pcd.CreateDate >= '2025-11-01' AND pcd.CreateDate < '2025-12-01'
      AND pc.PropertyCastTypeId = 1  -- CC
      AND pc.AreaId IS NOT NULL
    GROUP BY pc.AreaId, pcd.AspNetUserId
),
-- SMS Sent per Area
SMSSent AS (
    SELECT 
        srsq.AreaId,
        SUM(vsqs.Count) AS Messages_Sent
    FROM SmsReportSendQueue srsq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary vsqs WITH (NOLOCK) ON vsqs.SmsReportSendQueueId = srsq.SmsReportSendQueueId
    WHERE srsq.CreateDate >= '2025-11-01' AND srsq.CreateDate < '2025-12-01'
      AND srsq.AreaId IS NOT NULL
    GROUP BY srsq.AreaId
),
-- Initial Clicks (leads) per Area
Clicks AS (
    SELECT 
        gl.AreaId,
        COUNT(DISTINCT gl.GenieLeadId) AS Initial_Click_Count
    FROM dbo.GenieLead gl WITH (NOLOCK)
    WHERE gl.CreateDate >= '2025-11-01' AND gl.CreateDate < '2025-12-01'
      AND gl.AreaId IS NOT NULL
    GROUP BY gl.AreaId
),
-- CTA events per Area (from GenieLeadTag)
CTAEvents AS (
    SELECT 
        gl.AreaId,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE 'Cta%Accept%' OR ltt.Tag LIKE 'Cta%Submit%' THEN gl.GenieLeadId END) AS CTA_Submitted,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE '%CtaContactVerified%' OR ltt.Tag LIKE '%CtaContactVerfied%' THEN gl.GenieLeadId END) AS CTA_Verified
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    INNER JOIN dbo.GenieLeadTagType ltt WITH (NOLOCK) ON ltt.GenieLeadTagTypeId = glt.LeadTagTypeId
    WHERE gl.CreateDate >= '2025-11-01' AND gl.CreateDate < '2025-12-01'
      AND gl.AreaId IS NOT NULL
      AND ltt.Tag LIKE 'Cta%'
    GROUP BY gl.AreaId
),
-- Agent Notifications per Area (from NewLead SMS notifications)
AgentNotifyRaw AS (
    SELECT 
        nq.NotificationQueueId,
        TRY_CONVERT(BIGINT,
            SUBSTRING(CAST(nq.CustomData AS NVARCHAR(MAX)), 
                 CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8,
                 CHARINDEX('"', CAST(nq.CustomData AS NVARCHAR(MAX)), CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8)
                 - CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) - 8)
        ) AS GenieLeadId,
        ABS(ISNULL(tm.Price, 0)) AS TwilioCost
    FROM dbo.NotificationQueue nq WITH (NOLOCK)
    LEFT JOIN dbo.TwilioMessage tm WITH (NOLOCK) ON tm.Sid = nq.ProviderResponseKey
    WHERE nq.CreateDate >= '2025-11-01' AND nq.CreateDate < '2025-12-01'
      AND nq.NotificationTypeId = 24  -- NewLead
      AND nq.NotificationChannelId = 2  -- SMS
      AND CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) > 0
),
AgentNotify AS (
    SELECT 
        gl.AreaId,
        COUNT(DISTINCT anr.NotificationQueueId) AS Agent_SMS_Notify_Count,
        SUM(anr.TwilioCost) AS Agent_Notify_Twilio_Cost
    FROM AgentNotifyRaw anr
    INNER JOIN dbo.GenieLead gl WITH (NOLOCK) ON gl.GenieLeadId = anr.GenieLeadId
    WHERE gl.AreaId IS NOT NULL AND gl.AreaId > 0
    GROUP BY gl.AreaId
)
SELECT 
    cc.AreaId,
    COALESCE(pno.FriendlyName, va.Name, 'Area ' + CAST(cc.AreaId AS VARCHAR)) AS Area_Name,
    ISNULL(up.FirstName + ' ' + up.LastName, u.UserName) AS Customer_Name,
    u.Email,
    cc.Campaign_Count,
    ISNULL(sms.Messages_Sent, 0) AS Messages_Sent,
    ISNULL(clk.Initial_Click_Count, 0) AS Initial_Click_Count,
    CASE WHEN ISNULL(sms.Messages_Sent, 0) > 0 
         THEN CAST(CAST(ISNULL(clk.Initial_Click_Count, 0) AS FLOAT) / sms.Messages_Sent * 100 AS DECIMAL(5,2))
         ELSE 0 END AS CTR_Pct,
    ISNULL(cta.CTA_Submitted, 0) AS CTA_Submitted,
    ISNULL(cta.CTA_Verified, 0) AS CTA_Verified,
    ISNULL(an.Agent_SMS_Notify_Count, 0) AS Agent_SMS_Notify_Count,
    ISNULL(an.Agent_Notify_Twilio_Cost, 0) AS Agent_Notify_Twilio_Cost
FROM CCCampaigns cc
LEFT JOIN dbo.AspNetUsers u WITH (NOLOCK) ON u.Id = cc.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up WITH (NOLOCK) ON up.AspNetUserId = cc.AspNetUserId
LEFT JOIN dbo.ViewArea va WITH (NOLOCK) ON va.AreaId = cc.AreaId
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) ON pno.PolygonId = cc.AreaId AND pno.AspNetUserId = cc.AspNetUserId
LEFT JOIN SMSSent sms ON sms.AreaId = cc.AreaId
LEFT JOIN Clicks clk ON clk.AreaId = cc.AreaId
LEFT JOIN CTAEvents cta ON cta.AreaId = cc.AreaId
LEFT JOIN AgentNotify an ON an.AreaId = cc.AreaId
ORDER BY cc.Campaign_Count DESC;

PRINT '';
PRINT '=============================================================';
PRINT 'SUMMARY TOTALS';
PRINT '=============================================================';

;WITH 
CCCampaigns AS (
    SELECT DISTINCT pc.AreaId
    FROM dbo.PropertyCollectionDetail pcd WITH (NOLOCK)
    INNER JOIN dbo.PropertyCastWorkflowQueue pcwq WITH (NOLOCK) ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
    INNER JOIN dbo.PropertyCast pc WITH (NOLOCK) ON pc.PropertyCastId = pcwq.PropertyCastId
    WHERE pcd.CreateDate >= '2025-11-01' AND pcd.CreateDate < '2025-12-01'
      AND pc.PropertyCastTypeId = 1
      AND pc.AreaId IS NOT NULL
),
CTAEvents AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE 'Cta%Accept%' OR ltt.Tag LIKE 'Cta%Submit%' THEN gl.GenieLeadId END) AS Total_CTA_Submitted,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE '%CtaContactVerified%' OR ltt.Tag LIKE '%CtaContactVerfied%' THEN gl.GenieLeadId END) AS Total_CTA_Verified
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    INNER JOIN dbo.GenieLeadTagType ltt WITH (NOLOCK) ON ltt.GenieLeadTagTypeId = glt.LeadTagTypeId
    WHERE gl.CreateDate >= '2025-11-01' AND gl.CreateDate < '2025-12-01'
      AND gl.AreaId IN (SELECT AreaId FROM CCCampaigns)
      AND ltt.Tag LIKE 'Cta%'
),
AgentNotifyRaw AS (
    SELECT 
        nq.NotificationQueueId,
        TRY_CONVERT(BIGINT,
            SUBSTRING(CAST(nq.CustomData AS NVARCHAR(MAX)), 
                 CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8,
                 CHARINDEX('"', CAST(nq.CustomData AS NVARCHAR(MAX)), CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8)
                 - CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) - 8)
        ) AS GenieLeadId,
        ABS(ISNULL(tm.Price, 0)) AS TwilioCost
    FROM dbo.NotificationQueue nq WITH (NOLOCK)
    LEFT JOIN dbo.TwilioMessage tm WITH (NOLOCK) ON tm.Sid = nq.ProviderResponseKey
    WHERE nq.CreateDate >= '2025-11-01' AND nq.CreateDate < '2025-12-01'
      AND nq.NotificationTypeId = 24
      AND nq.NotificationChannelId = 2
      AND CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) > 0
),
AgentNotify AS (
    SELECT 
        COUNT(DISTINCT anr.NotificationQueueId) AS Total_Agent_Notify,
        SUM(anr.TwilioCost) AS Total_Agent_Notify_Cost
    FROM AgentNotifyRaw anr
    INNER JOIN dbo.GenieLead gl WITH (NOLOCK) ON gl.GenieLeadId = anr.GenieLeadId
    WHERE gl.AreaId IN (SELECT AreaId FROM CCCampaigns)
)
SELECT 
    cta.Total_CTA_Submitted,
    cta.Total_CTA_Verified,
    an.Total_Agent_Notify,
    an.Total_Agent_Notify_Cost
FROM CTAEvents cta, AgentNotify an;

