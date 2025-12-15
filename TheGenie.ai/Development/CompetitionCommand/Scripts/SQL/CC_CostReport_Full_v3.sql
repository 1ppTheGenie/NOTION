-- ============================================================================
-- COMPETITION COMMAND FULL COST REPORT - Multi-Month (Fixed v3)
-- Version: 3.0 | Generated: 2025-12-14
-- Includes ALL 17 columns per SPEC_CompCommand_MonthlyCostReport_v3.md
-- ============================================================================

SET NOCOUNT ON;

-- Create temp table for results
IF OBJECT_ID('tempdb..#CCReport') IS NOT NULL DROP TABLE #CCReport;

CREATE TABLE #CCReport (
    Month VARCHAR(50),
    Customer_Name NVARCHAR(200),
    Area_Name NVARCHAR(200),
    AreaId INT,
    Campaigns INT,
    Msgs_Sent INT,
    Delivered INT,
    Success_Pct DECIMAL(5,2),
    Clicks INT,
    CTR_Pct DECIMAL(5,2),
    CTA_Submitted INT,
    CTA_Verified INT,
    Agent_Notify INT,
    Agent_Notify_Cost DECIMAL(10,4),
    Opt_Outs INT,
    Opt_Out_Pct DECIMAL(5,2),
    Audience_Twilio_Cost DECIMAL(10,4)
);

-- ============================================================================
-- NOVEMBER 2025
-- ============================================================================
DECLARE @Nov_Start DATE = '2025-11-01';
DECLARE @Nov_End DATE = '2025-12-01';

;WITH 
-- Base CC Areas (from SmsReportSendQueue + UserOwnedArea for user info)
CCBase AS (
    SELECT 
        srq.AreaId,
        uoa.AspNetUserId,
        COUNT(DISTINCT srq.SmsReportSendQueueId) AS Campaigns,
        SUM(v.Count) AS Msgs_Sent
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    LEFT JOIN UserOwnedArea uoa WITH (NOLOCK) ON uoa.AreaId = srq.AreaId AND uoa.AreaOwnershipTypeId = 1
    WHERE srq.CreateDate >= @Nov_Start AND srq.CreateDate < @Nov_End
      AND srq.UtmSource = 'Competition Command'
      AND srq.AreaId IS NOT NULL
    GROUP BY srq.AreaId, uoa.AspNetUserId
),
-- Delivered count
DeliveredCounts AS (
    SELECT srq.AreaId, SUM(v.Count) AS Delivered
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    WHERE srq.CreateDate >= @Nov_Start AND srq.CreateDate < @Nov_End
      AND srq.UtmSource = 'Competition Command' AND v.ResponseCode = 1
    GROUP BY srq.AreaId
),
-- Clicks from GenieLead
Clicks AS (
    SELECT gl.AreaId, COUNT(DISTINCT gl.GenieLeadId) AS Clicks
    FROM dbo.GenieLead gl WITH (NOLOCK)
    WHERE gl.CreateDate >= @Nov_Start AND gl.CreateDate < @Nov_End AND gl.AreaId IS NOT NULL
    GROUP BY gl.AreaId
),
-- CTA Events
CTAEvents AS (
    SELECT gl.AreaId,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE 'Cta%Accept%' OR ltt.Tag LIKE 'Cta%Submit%' THEN gl.GenieLeadId END) AS CTA_Submitted,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE '%CtaContactVerified%' OR ltt.Tag LIKE '%CtaContactVerfied%' THEN gl.GenieLeadId END) AS CTA_Verified
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    INNER JOIN dbo.GenieLeadTagType ltt WITH (NOLOCK) ON ltt.GenieLeadTagTypeId = glt.LeadTagTypeId
    WHERE gl.CreateDate >= @Nov_Start AND gl.CreateDate < @Nov_End AND gl.AreaId IS NOT NULL AND ltt.Tag LIKE 'Cta%'
    GROUP BY gl.AreaId
),
-- Opt Outs
OptOuts AS (
    SELECT gl.AreaId, COUNT(DISTINCT gl.GenieLeadId) AS Opt_Outs
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    WHERE gl.CreateDate >= @Nov_Start AND gl.CreateDate < @Nov_End AND gl.AreaId IS NOT NULL AND glt.LeadTagTypeId = 51
    GROUP BY gl.AreaId
),
-- Agent Notify
AgentNotifyRaw AS (
    SELECT nq.NotificationQueueId,
        TRY_CONVERT(BIGINT, SUBSTRING(CAST(nq.CustomData AS NVARCHAR(MAX)), 
             CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8,
             CHARINDEX('"', CAST(nq.CustomData AS NVARCHAR(MAX)), CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) + 8)
             - CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) - 8)) AS GenieLeadId,
        ABS(ISNULL(tm.Price, 0)) AS TwilioCost
    FROM dbo.NotificationQueue nq WITH (NOLOCK)
    LEFT JOIN dbo.TwilioMessage tm WITH (NOLOCK) ON tm.Sid = nq.ProviderResponseKey
    WHERE nq.CreateDate >= @Nov_Start AND nq.CreateDate < @Nov_End
      AND nq.NotificationTypeId = 24 AND nq.NotificationChannelId = 2
      AND CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) > 0
),
AgentNotify AS (
    SELECT gl.AreaId, COUNT(DISTINCT anr.NotificationQueueId) AS Agent_Notify, SUM(anr.TwilioCost) AS Agent_Notify_Cost
    FROM AgentNotifyRaw anr
    INNER JOIN dbo.GenieLead gl WITH (NOLOCK) ON gl.GenieLeadId = anr.GenieLeadId
    WHERE gl.AreaId IS NOT NULL AND gl.AreaId > 0
    GROUP BY gl.AreaId
),
-- Audience Twilio Cost (via SmsReportMessageQueuedLog -> NotificationQueue -> TwilioMessage)
AudienceTwilioCost AS (
    SELECT srq.AreaId, SUM(ABS(ISNULL(tm.Price, 0))) AS Twilio_Cost
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN SmsReportMessageQueuedLog srmql WITH (NOLOCK) ON srmql.SmsReportSendQueueId = srq.SmsReportSendQueueId
    INNER JOIN NotificationQueue nq WITH (NOLOCK) ON nq.NotificationQueueId = srmql.NotificationQueueId
    LEFT JOIN TwilioMessage tm WITH (NOLOCK) ON tm.Sid = nq.ProviderResponseKey
    WHERE srq.CreateDate >= @Nov_Start AND srq.CreateDate < @Nov_End AND srq.UtmSource = 'Competition Command'
    GROUP BY srq.AreaId
)
INSERT INTO #CCReport
SELECT 
    'November 2025' AS Month,
    ISNULL(up.FirstName + ' ' + up.LastName, u.UserName) AS Customer_Name,
    COALESCE(pno.FriendlyName, va.Name, CAST(cc.AreaId AS VARCHAR)) AS Area_Name,
    cc.AreaId, cc.Campaigns, cc.Msgs_Sent, ISNULL(dc.Delivered, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(dc.Delivered,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(clk.Clicks, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(clk.Clicks,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(cta.CTA_Submitted, 0), ISNULL(cta.CTA_Verified, 0),
    ISNULL(an.Agent_Notify, 0), ISNULL(an.Agent_Notify_Cost, 0),
    ISNULL(op.Opt_Outs, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(op.Opt_Outs,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(atc.Twilio_Cost, 0)
FROM CCBase cc
LEFT JOIN dbo.AspNetUsers u WITH (NOLOCK) ON u.Id = cc.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up WITH (NOLOCK) ON up.AspNetUserId = cc.AspNetUserId
LEFT JOIN dbo.ViewArea va WITH (NOLOCK) ON va.AreaId = cc.AreaId
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) ON pno.PolygonId = cc.AreaId AND pno.AspNetUserId = cc.AspNetUserId
LEFT JOIN DeliveredCounts dc ON dc.AreaId = cc.AreaId
LEFT JOIN Clicks clk ON clk.AreaId = cc.AreaId
LEFT JOIN CTAEvents cta ON cta.AreaId = cc.AreaId
LEFT JOIN AgentNotify an ON an.AreaId = cc.AreaId
LEFT JOIN OptOuts op ON op.AreaId = cc.AreaId
LEFT JOIN AudienceTwilioCost atc ON atc.AreaId = cc.AreaId;

-- ============================================================================
-- SEPTEMBER 2025
-- ============================================================================
DECLARE @Sep_Start DATE = '2025-09-01';
DECLARE @Sep_End DATE = '2025-10-01';

;WITH 
CCBase AS (
    SELECT srq.AreaId, uoa.AspNetUserId,
        COUNT(DISTINCT srq.SmsReportSendQueueId) AS Campaigns, SUM(v.Count) AS Msgs_Sent
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    LEFT JOIN UserOwnedArea uoa WITH (NOLOCK) ON uoa.AreaId = srq.AreaId AND uoa.AreaOwnershipTypeId = 1
    WHERE srq.CreateDate >= @Sep_Start AND srq.CreateDate < @Sep_End
      AND srq.UtmSource = 'Competition Command' AND srq.AreaId IS NOT NULL
    GROUP BY srq.AreaId, uoa.AspNetUserId
),
DeliveredCounts AS (
    SELECT srq.AreaId, SUM(v.Count) AS Delivered
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    WHERE srq.CreateDate >= @Sep_Start AND srq.CreateDate < @Sep_End
      AND srq.UtmSource = 'Competition Command' AND v.ResponseCode = 1
    GROUP BY srq.AreaId
),
Clicks AS (
    SELECT gl.AreaId, COUNT(DISTINCT gl.GenieLeadId) AS Clicks
    FROM dbo.GenieLead gl WITH (NOLOCK)
    WHERE gl.CreateDate >= @Sep_Start AND gl.CreateDate < @Sep_End AND gl.AreaId IS NOT NULL
    GROUP BY gl.AreaId
),
CTAEvents AS (
    SELECT gl.AreaId,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE 'Cta%Accept%' OR ltt.Tag LIKE 'Cta%Submit%' THEN gl.GenieLeadId END) AS CTA_Submitted,
        COUNT(DISTINCT CASE WHEN ltt.Tag LIKE '%CtaContactVerified%' OR ltt.Tag LIKE '%CtaContactVerfied%' THEN gl.GenieLeadId END) AS CTA_Verified
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    INNER JOIN dbo.GenieLeadTagType ltt WITH (NOLOCK) ON ltt.GenieLeadTagTypeId = glt.LeadTagTypeId
    WHERE gl.CreateDate >= @Sep_Start AND gl.CreateDate < @Sep_End AND gl.AreaId IS NOT NULL AND ltt.Tag LIKE 'Cta%'
    GROUP BY gl.AreaId
),
OptOuts AS (
    SELECT gl.AreaId, COUNT(DISTINCT gl.GenieLeadId) AS Opt_Outs
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    WHERE gl.CreateDate >= @Sep_Start AND gl.CreateDate < @Sep_End AND gl.AreaId IS NOT NULL AND glt.LeadTagTypeId = 51
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
    WHERE nq.CreateDate >= @Sep_Start AND nq.CreateDate < @Sep_End
      AND nq.NotificationTypeId = 24 AND nq.NotificationChannelId = 2
      AND CHARINDEX('/detail/', CAST(nq.CustomData AS NVARCHAR(MAX))) > 0
),
AgentNotify AS (
    SELECT gl.AreaId, COUNT(DISTINCT anr.NotificationQueueId) AS Agent_Notify, SUM(anr.TwilioCost) AS Agent_Notify_Cost
    FROM AgentNotifyRaw anr
    INNER JOIN dbo.GenieLead gl WITH (NOLOCK) ON gl.GenieLeadId = anr.GenieLeadId
    WHERE gl.AreaId IS NOT NULL AND gl.AreaId > 0
    GROUP BY gl.AreaId
),
AudienceTwilioCost AS (
    SELECT srq.AreaId, SUM(ABS(ISNULL(tm.Price, 0))) AS Twilio_Cost
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN SmsReportMessageQueuedLog srmql WITH (NOLOCK) ON srmql.SmsReportSendQueueId = srq.SmsReportSendQueueId
    INNER JOIN NotificationQueue nq WITH (NOLOCK) ON nq.NotificationQueueId = srmql.NotificationQueueId
    LEFT JOIN TwilioMessage tm WITH (NOLOCK) ON tm.Sid = nq.ProviderResponseKey
    WHERE srq.CreateDate >= @Sep_Start AND srq.CreateDate < @Sep_End AND srq.UtmSource = 'Competition Command'
    GROUP BY srq.AreaId
)
INSERT INTO #CCReport
SELECT 
    'September 2025' AS Month,
    ISNULL(up.FirstName + ' ' + up.LastName, u.UserName) AS Customer_Name,
    COALESCE(pno.FriendlyName, va.Name, CAST(cc.AreaId AS VARCHAR)) AS Area_Name,
    cc.AreaId, cc.Campaigns, cc.Msgs_Sent, ISNULL(dc.Delivered, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(dc.Delivered,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(clk.Clicks, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(clk.Clicks,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(cta.CTA_Submitted, 0), ISNULL(cta.CTA_Verified, 0),
    ISNULL(an.Agent_Notify, 0), ISNULL(an.Agent_Notify_Cost, 0),
    ISNULL(op.Opt_Outs, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(op.Opt_Outs,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(atc.Twilio_Cost, 0)
FROM CCBase cc
LEFT JOIN dbo.AspNetUsers u WITH (NOLOCK) ON u.Id = cc.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up WITH (NOLOCK) ON up.AspNetUserId = cc.AspNetUserId
LEFT JOIN dbo.ViewArea va WITH (NOLOCK) ON va.AreaId = cc.AreaId
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) ON pno.PolygonId = cc.AreaId AND pno.AspNetUserId = cc.AspNetUserId
LEFT JOIN DeliveredCounts dc ON dc.AreaId = cc.AreaId
LEFT JOIN Clicks clk ON clk.AreaId = cc.AreaId
LEFT JOIN CTAEvents cta ON cta.AreaId = cc.AreaId
LEFT JOIN AgentNotify an ON an.AreaId = cc.AreaId
LEFT JOIN OptOuts op ON op.AreaId = cc.AreaId
LEFT JOIN AudienceTwilioCost atc ON atc.AreaId = cc.AreaId;

-- ============================================================================
-- DECEMBER 2025 (1-14)
-- ============================================================================
DECLARE @Dec_Start DATE = '2025-12-01';
DECLARE @Dec_End DATE = '2025-12-15';

;WITH 
CCBase AS (
    SELECT srq.AreaId, uoa.AspNetUserId,
        COUNT(DISTINCT srq.SmsReportSendQueueId) AS Campaigns, SUM(v.Count) AS Msgs_Sent
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    LEFT JOIN UserOwnedArea uoa WITH (NOLOCK) ON uoa.AreaId = srq.AreaId AND uoa.AreaOwnershipTypeId = 1
    WHERE srq.CreateDate >= @Dec_Start AND srq.CreateDate < @Dec_End
      AND srq.UtmSource = 'Competition Command' AND srq.AreaId IS NOT NULL
    GROUP BY srq.AreaId, uoa.AspNetUserId
),
DeliveredCounts AS (
    SELECT srq.AreaId, SUM(v.Count) AS Delivered
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN ViewSmsQueueSendSummary v ON v.SmsReportSendQueueId = srq.SmsReportSendQueueId
    WHERE srq.CreateDate >= @Dec_Start AND srq.CreateDate < @Dec_End
      AND srq.UtmSource = 'Competition Command' AND v.ResponseCode = 1
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
OptOuts AS (
    SELECT gl.AreaId, COUNT(DISTINCT gl.GenieLeadId) AS Opt_Outs
    FROM dbo.GenieLead gl WITH (NOLOCK)
    INNER JOIN dbo.GenieLeadTag glt WITH (NOLOCK) ON glt.GenieLeadId = gl.GenieLeadId
    WHERE gl.CreateDate >= @Dec_Start AND gl.CreateDate < @Dec_End AND gl.AreaId IS NOT NULL AND glt.LeadTagTypeId = 51
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
),
AudienceTwilioCost AS (
    SELECT srq.AreaId, SUM(ABS(ISNULL(tm.Price, 0))) AS Twilio_Cost
    FROM SmsReportSendQueue srq WITH (NOLOCK)
    INNER JOIN SmsReportMessageQueuedLog srmql WITH (NOLOCK) ON srmql.SmsReportSendQueueId = srq.SmsReportSendQueueId
    INNER JOIN NotificationQueue nq WITH (NOLOCK) ON nq.NotificationQueueId = srmql.NotificationQueueId
    LEFT JOIN TwilioMessage tm WITH (NOLOCK) ON tm.Sid = nq.ProviderResponseKey
    WHERE srq.CreateDate >= @Dec_Start AND srq.CreateDate < @Dec_End AND srq.UtmSource = 'Competition Command'
    GROUP BY srq.AreaId
)
INSERT INTO #CCReport
SELECT 
    'December 2025 (1-14)' AS Month,
    ISNULL(up.FirstName + ' ' + up.LastName, u.UserName) AS Customer_Name,
    COALESCE(pno.FriendlyName, va.Name, CAST(cc.AreaId AS VARCHAR)) AS Area_Name,
    cc.AreaId, cc.Campaigns, cc.Msgs_Sent, ISNULL(dc.Delivered, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(dc.Delivered,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(clk.Clicks, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(clk.Clicks,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(cta.CTA_Submitted, 0), ISNULL(cta.CTA_Verified, 0),
    ISNULL(an.Agent_Notify, 0), ISNULL(an.Agent_Notify_Cost, 0),
    ISNULL(op.Opt_Outs, 0),
    CASE WHEN cc.Msgs_Sent > 0 THEN CAST(ISNULL(op.Opt_Outs,0) * 100.0 / cc.Msgs_Sent AS DECIMAL(5,2)) ELSE 0 END,
    ISNULL(atc.Twilio_Cost, 0)
FROM CCBase cc
LEFT JOIN dbo.AspNetUsers u WITH (NOLOCK) ON u.Id = cc.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up WITH (NOLOCK) ON up.AspNetUserId = cc.AspNetUserId
LEFT JOIN dbo.ViewArea va WITH (NOLOCK) ON va.AreaId = cc.AreaId
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) ON pno.PolygonId = cc.AreaId AND pno.AspNetUserId = cc.AspNetUserId
LEFT JOIN DeliveredCounts dc ON dc.AreaId = cc.AreaId
LEFT JOIN Clicks clk ON clk.AreaId = cc.AreaId
LEFT JOIN CTAEvents cta ON cta.AreaId = cc.AreaId
LEFT JOIN AgentNotify an ON an.AreaId = cc.AreaId
LEFT JOIN OptOuts op ON op.AreaId = cc.AreaId
LEFT JOIN AudienceTwilioCost atc ON atc.AreaId = cc.AreaId;

-- ============================================================================
-- OUTPUT FINAL REPORT
-- ============================================================================
SELECT 
    Month,
    Customer_Name,
    Area_Name,
    AreaId,
    Campaigns,
    Msgs_Sent,
    Delivered,
    CAST(Success_Pct AS VARCHAR) + '%' AS Success_Pct,
    Clicks,
    CAST(CTR_Pct AS VARCHAR) + '%' AS CTR_Pct,
    CTA_Submitted,
    CTA_Verified,
    Agent_Notify,
    '$' + CAST(Agent_Notify_Cost AS VARCHAR) AS Agent_Notify_Cost,
    Opt_Outs,
    CAST(Opt_Out_Pct AS VARCHAR) + '%' AS Opt_Out_Pct,
    '$' + CAST(Audience_Twilio_Cost AS VARCHAR) AS Audience_Twilio_Cost
FROM #CCReport
ORDER BY 
    CASE Month 
        WHEN 'September 2025' THEN 1 
        WHEN 'November 2025' THEN 2 
        WHEN 'December 2025 (1-14)' THEN 3 
    END,
    Campaigns DESC;

-- Summary by Month
PRINT '';
PRINT '=============================================================';
PRINT 'MONTHLY SUMMARY';
PRINT '=============================================================';
SELECT 
    Month,
    COUNT(*) AS Areas,
    SUM(Campaigns) AS Total_Campaigns,
    SUM(Msgs_Sent) AS Total_Msgs_Sent,
    SUM(Delivered) AS Total_Delivered,
    SUM(Clicks) AS Total_Clicks,
    SUM(CTA_Submitted) AS Total_CTA_Submitted,
    SUM(CTA_Verified) AS Total_CTA_Verified,
    SUM(Agent_Notify) AS Total_Agent_Notify,
    '$' + CAST(SUM(Agent_Notify_Cost) AS VARCHAR) AS Total_Agent_Notify_Cost,
    SUM(Opt_Outs) AS Total_Opt_Outs,
    '$' + CAST(SUM(Audience_Twilio_Cost) AS VARCHAR) AS Total_Audience_Twilio_Cost
FROM #CCReport
GROUP BY Month
ORDER BY 
    CASE Month 
        WHEN 'September 2025' THEN 1 
        WHEN 'November 2025' THEN 2 
        WHEN 'December 2025 (1-14)' THEN 3 
    END;

DROP TABLE #CCReport;
SET NOCOUNT OFF;

