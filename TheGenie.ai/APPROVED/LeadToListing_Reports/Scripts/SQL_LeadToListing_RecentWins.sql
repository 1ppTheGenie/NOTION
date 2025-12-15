/*
=============================================================================
Lead-to-Listing Recent Wins Analysis
=============================================================================
Purpose: Deep dive on recent wins (last 90 days) with engagement data
Output:  CSV with win details, lead journey, property enrichment
Author:  Cursor AI
Date:    12/15/2025
Version: 1.0

Usage:   Modify @StartDate to change analysis window
=============================================================================
*/

SET NOCOUNT ON;

DECLARE @StartDate DATE = DATEADD(day, -90, GETDATE());

;WITH RecentWins AS (
    SELECT 
        la.MlsNumber,
        l.ListDate,
        gl.GenieLeadId,
        gl.CreateDate as LeadCreated,
        DATEDIFF(day, gl.CreateDate, l.ListDate) as Days_Nurture,
        CONCAT(gl.FirstName, ' ', gl.LastName) as Lead_Name,
        gl.Phone as Lead_Phone,
        gl.Email as Lead_Email,
        glt.Description as Lead_Source,
        ad.SitusStdFullStreetAddress as Property,
        ad.SitusStdCity as City,
        l.PriceLow as List_Price,
        CONCAT(anup.FirstName, ' ', anup.LastName) as Genie_Agent,
        l.ListingAgentName as Listing_Agent,
        ad.OwnerStdNAME1FULL as Owner_on_Title,
        DATEDIFF(year, ad.CurrSaleRecordingDate, l.ListDate) as Years_Owned,
        ad.OwnerOccupied,
        ROW_NUMBER() OVER (PARTITION BY la.MlsNumber ORDER BY gl.CreateDate) as rn
    FROM FarmGenie.dbo.LeadPropertyMatch lpm
    JOIN FarmGenie.dbo.GenieLead gl ON gl.GenieLeadId = lpm.GenieLeadId
    JOIN FarmGenie.dbo.GenieLeadType glt ON glt.GenieLeadTypeId = gl.LeadTypeId
    JOIN TitleData.dbo.ViewAssessor_v3 ad ON ad.PropertyID = lpm.PropertyId
    JOIN MlsListing.dbo.ListingAssessor la ON la.FIPS = ad.FIPS AND la.FormattedAPN = ad.FormattedAPN
    JOIN MlsListing.dbo.Listing l ON l.MlsID = la.MlsID AND l.MlsNumber = la.MlsNumber
    JOIN FarmGenie.dbo.AspNetUserProfiles anup ON anup.AspNetUserId = gl.AspNetUserId
    WHERE gl.CreateDate < l.ListDate
    AND l.ListDate >= @StartDate
    AND l.ListingAgentName = CONCAT(anup.FirstName, ' ', anup.LastName)
    AND DATEDIFF(day, gl.CreateDate, l.ListDate) >= 7
)
SELECT 
    MlsNumber,
    FORMAT(ListDate, 'MM/dd/yyyy') as List_Date,
    FORMAT(LeadCreated, 'MM/dd/yyyy') as Lead_Date,
    Days_Nurture,
    Lead_Name,
    Lead_Phone,
    Lead_Email,
    Lead_Source,
    REPLACE(Property, ',', '') as Property,
    City,
    List_Price,
    Genie_Agent,
    LEFT(Owner_on_Title, 30) as Owner_on_Title,
    CASE WHEN Lead_Name LIKE '%' + LEFT(Owner_on_Title, 5) + '%' 
         OR Owner_on_Title LIKE '%' + LEFT(Lead_Name, 5) + '%'
         THEN 'MATCH' ELSE 'DIFF' END as Name_Match,
    Years_Owned,
    OwnerOccupied as OO
FROM RecentWins
WHERE rn = 1
ORDER BY ListDate DESC;

