/*
=============================================================================
Lead-to-Listing Agent Performance Report
=============================================================================
Purpose: Show win/loss by agent for specified period
Output:  CSV with agent totals, wins, losses, value
Author:  Cursor AI
Date:    12/15/2025
Version: 1.0

Usage:   Modify @StartDate to change analysis window
=============================================================================
*/

SET NOCOUNT ON;

DECLARE @StartDate DATE = DATEADD(month, -2, GETDATE());

SELECT 
    CONCAT(anup.FirstName, ' ', anup.LastName) as Genie_Agent,
    SUM(CASE WHEN l.ListingAgentName = CONCAT(anup.FirstName, ' ', anup.LastName) THEN 1 ELSE 0 END) as Won,
    SUM(CASE WHEN l.ListingAgentName != CONCAT(anup.FirstName, ' ', anup.LastName) THEN 1 ELSE 0 END) as Lost,
    COUNT(DISTINCT la.MlsNumber) as Total_Opportunities,
    CAST(100.0 * SUM(CASE WHEN l.ListingAgentName = CONCAT(anup.FirstName, ' ', anup.LastName) THEN 1 ELSE 0 END) 
         / NULLIF(COUNT(DISTINCT la.MlsNumber), 0) as DECIMAL(5,2)) as Win_Rate_Pct,
    CAST(SUM(l.PriceLow)/1000000 as INT) as Total_Value_M,
    CAST(SUM(CASE WHEN l.ListingAgentName = CONCAT(anup.FirstName, ' ', anup.LastName) THEN l.PriceLow ELSE 0 END)/1000000 as INT) as Won_Value_M,
    CAST(SUM(CASE WHEN l.ListingAgentName != CONCAT(anup.FirstName, ' ', anup.LastName) THEN l.PriceLow ELSE 0 END)/1000000 as INT) as Lost_Value_M
FROM FarmGenie.dbo.LeadPropertyMatch lpm
JOIN FarmGenie.dbo.GenieLead gl ON gl.GenieLeadId = lpm.GenieLeadId
JOIN TitleData.dbo.ViewAssessor_v3 ad ON ad.PropertyID = lpm.PropertyId
JOIN MlsListing.dbo.ListingAssessor la ON la.FIPS = ad.FIPS AND la.FormattedAPN = ad.FormattedAPN
JOIN MlsListing.dbo.Listing l ON l.MlsID = la.MlsID AND l.MlsNumber = la.MlsNumber
JOIN FarmGenie.dbo.AspNetUserProfiles anup ON anup.AspNetUserId = gl.AspNetUserId
JOIN FarmGenie.dbo.AspNetUserRoles anur ON anur.UserId = anup.AspNetUserId
WHERE gl.CreateDate < l.ListDate
AND l.ListDate >= @StartDate
AND DATEDIFF(day, gl.CreateDate, l.ListDate) >= 7
AND anur.RoleId NOT IN (17, 23, 20, 5, 21, 11)
GROUP BY CONCAT(anup.FirstName, ' ', anup.LastName)
HAVING COUNT(DISTINCT la.MlsNumber) >= 5
ORDER BY Total_Opportunities DESC;

