/*
=============================================================================
Lead-to-Listing By Year Trend Report
=============================================================================
Purpose: Show win rate trends by year (deduplicated)
Output:  CSV with yearly totals, wins, losses, win rate
Author:  Cursor AI
Date:    12/15/2025
Version: 1.0
=============================================================================
*/

SET NOCOUNT ON;

;WITH RankedListings AS (
    SELECT 
        la.MlsNumber,
        l.ListDate,
        l.PriceLow,
        l.ListingAgentName,
        CONCAT(anup.FirstName, ' ', anup.LastName) as GenieAgent,
        ROW_NUMBER() OVER (PARTITION BY la.MlsNumber ORDER BY gl.CreateDate) as RowNum
    FROM FarmGenie.dbo.LeadPropertyMatch lpm
    JOIN FarmGenie.dbo.GenieLead gl ON gl.GenieLeadId = lpm.GenieLeadId
    JOIN TitleData.dbo.ViewAssessor_v3 ad ON ad.PropertyID = lpm.PropertyId
    JOIN MlsListing.dbo.ListingAssessor la ON la.FIPS = ad.FIPS AND la.FormattedAPN = ad.FormattedAPN
    JOIN MlsListing.dbo.Listing l ON l.MlsID = la.MlsID AND l.MlsNumber = la.MlsNumber
    JOIN FarmGenie.dbo.AspNetUserProfiles anup ON anup.AspNetUserId = gl.AspNetUserId
    JOIN FarmGenie.dbo.AspNetUserRoles anur ON anur.UserId = anup.AspNetUserId
    WHERE gl.CreateDate < l.ListDate
    AND DATEDIFF(day, gl.CreateDate, l.ListDate) >= 7
    AND anur.RoleId NOT IN (17, 23, 20, 5, 21, 11)
)
SELECT 
    YEAR(ListDate) as Year,
    COUNT(*) as Total_Listings,
    SUM(CASE WHEN ListingAgentName = GenieAgent THEN 1 ELSE 0 END) as Our_Agent_Won,
    SUM(CASE WHEN ListingAgentName != GenieAgent THEN 1 ELSE 0 END) as Other_Agent_Won,
    CAST(100.0 * SUM(CASE WHEN ListingAgentName = GenieAgent THEN 1 ELSE 0 END) / COUNT(*) as DECIMAL(5,2)) as Win_Rate_Pct,
    CAST(SUM(CAST(PriceLow as BIGINT))/1000000 as INT) as Total_Value_Millions,
    CAST(SUM(CASE WHEN ListingAgentName = GenieAgent THEN PriceLow ELSE 0 END)/1000000 as INT) as Won_Value_Millions,
    CAST(SUM(CASE WHEN ListingAgentName != GenieAgent THEN PriceLow ELSE 0 END)/1000000 as INT) as Lost_Value_Millions
FROM RankedListings
WHERE RowNum = 1
GROUP BY YEAR(ListDate)
ORDER BY YEAR(ListDate) DESC;

