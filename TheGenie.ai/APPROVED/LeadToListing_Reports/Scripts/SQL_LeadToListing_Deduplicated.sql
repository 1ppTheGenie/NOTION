/*
=============================================================================
Lead-to-Listing Deduplicated Report
=============================================================================
Purpose: Generate all listings from TheGenie leads, one row per MLS number
Output:  CSV with listing details, lead source, outcome (WON/LOST)
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
        ad.SitusStdFullStreetAddress,
        ad.SitusStdCity,
        ad.SitusStdState,
        l.PriceLow,
        l.ListingAgentName,
        CONCAT(anup.FirstName, ' ', anup.LastName) as GenieAgent,
        anu.Email as GenieAgentEmail,
        gl.GenieLeadId,
        gl.CreateDate as LeadCreated,
        glt.Description as LeadSource,
        ad.CurrSalesPrice,
        ad.CurrSaleRecordingDate,
        ad.OwnerOccupied,
        ROW_NUMBER() OVER (PARTITION BY la.MlsNumber ORDER BY gl.CreateDate) as RowNum
    FROM FarmGenie.dbo.LeadPropertyMatch lpm
    JOIN FarmGenie.dbo.GenieLead gl ON gl.GenieLeadId = lpm.GenieLeadId
    JOIN FarmGenie.dbo.GenieLeadType glt ON glt.GenieLeadTypeId = gl.LeadTypeId
    JOIN TitleData.dbo.ViewAssessor_v3 ad ON ad.PropertyID = lpm.PropertyId
    JOIN MlsListing.dbo.ListingAssessor la ON la.FIPS = ad.FIPS AND la.FormattedAPN = ad.FormattedAPN
    JOIN MlsListing.dbo.Listing l ON l.MlsID = la.MlsID AND l.MlsNumber = la.MlsNumber
    JOIN FarmGenie.dbo.AspNetUserProfiles anup ON anup.AspNetUserId = gl.AspNetUserId
    JOIN FarmGenie.dbo.AspNetUserRoles anur ON anur.UserId = anup.AspNetUserId
    JOIN FarmGenie.dbo.AspNetUsers anu ON anu.Id = anup.AspNetUserId
    WHERE gl.CreateDate < l.ListDate
    AND DATEDIFF(day, gl.CreateDate, l.ListDate) >= 7
    AND anur.RoleId NOT IN (17, 23, 20, 5, 21, 11)
)
SELECT 
    MlsNumber,
    FORMAT(ListDate, 'MM/dd/yyyy') as List_Date,
    YEAR(ListDate) as List_Year,
    REPLACE(SitusStdFullStreetAddress, ',', '') as Property_Address,
    SitusStdCity as City,
    SitusStdState as State,
    PriceLow as List_Price,
    REPLACE(ListingAgentName, ',', '') as Listing_Agent,
    GenieAgent as Genie_Agent,
    GenieAgentEmail as Genie_Agent_Email,
    CASE WHEN ListingAgentName = GenieAgent THEN 'WON' ELSE 'LOST' END as Outcome,
    FORMAT(LeadCreated, 'MM/dd/yyyy') as Lead_Created,
    LeadSource as Lead_Source,
    DATEDIFF(day, LeadCreated, ListDate) as Days_To_Listing,
    DATEDIFF(year, CurrSaleRecordingDate, ListDate) as Years_Owned,
    OwnerOccupied as Owner_Occupied
FROM RankedListings
WHERE RowNum = 1
ORDER BY Outcome DESC, ListDate DESC;

