-- Detailed export of FarmGenie users with MLS ID 2
-- Includes company address and all relevant information
-- This should show ~199 users (or fewer with proper filters)

USE FarmGenie;
GO

SELECT 
    -- User Information
    ISNULL(up.FirstName + ' ' + up.LastName, u.UserName) AS Name,
    ISNULL(uo.CompanyName, ISNULL(org.Name, '')) AS Company,
    ISNULL(uo.Address, '') AS CompanyAddress,
    ISNULL(uo.UnitSuite, '') AS CompanyUnitSuite,
    ISNULL(uo.City, '') AS CompanyCity,
    ISNULL(uo.State, '') AS CompanyState,
    ISNULL(uo.Zip, '') AS CompanyZip,
    ISNULL(u.Email, '') AS Contact,
    ISNULL(ump.LicenseNumberDisplay, '') AS LicenseNumber,
    
    -- MLS Information
    uac.MlsID AS MLSID,
    uac.AgentCode AS AgentCode,
    
    -- Role Information
    ISNULL(r.Name, 'No Role') AS Role,
    
    -- Status Information
    CASE 
        WHEN u.LockoutEndDateUtc IS NOT NULL AND u.LockoutEndDateUtc > GETUTCDATE() THEN 'Disabled'
        WHEN u.PasswordHash IS NULL AND u.EmailConfirmed = 0 THEN 'Invited'
        WHEN u.EmailConfirmed = 1 OR u.PasswordHash IS NOT NULL THEN 'Active'
        ELSE 'Unknown'
    END AS Status,
    
    -- Dates
    CASE 
        WHEN up.CreateDate IS NOT NULL THEN CONVERT(VARCHAR(10), up.CreateDate, 120)
        ELSE ''
    END AS DateAdded,
    CASE 
        WHEN ump.LastUpdate IS NOT NULL THEN CONVERT(VARCHAR(10), ump.LastUpdate, 120)
        ELSE 'Never'
    END AS LastLogin,
    
    -- MLS Roster Information
    a.AgentStatusID,
    a.AgentType,
    a.LicenseNumber AS MlsLicenseNumber,
    
    -- Transaction Counts
    (SELECT COUNT(*) FROM MlsListing.dbo.Listing l 
     WHERE l.MlsID = 2 
       AND (l.ListingAgentID = uac.AgentCode OR LTRIM(RTRIM(l.ListingAgentID)) = LTRIM(RTRIM(uac.AgentCode)))
       AND (l.ListDate >= DATEADD(day, -365, GETDATE()) OR l.SoldDate >= DATEADD(day, -365, GETDATE()) OR l.StatusTypeID = 1)
    ) as SellTransactionCount,
    (SELECT COUNT(*) FROM MlsListing.dbo.Listing l 
     WHERE l.MlsID = 2 
       AND (l.BuyersAgentID = uac.AgentCode OR LTRIM(RTRIM(l.BuyersAgentID)) = LTRIM(RTRIM(uac.AgentCode)))
       AND (l.ListDate >= DATEADD(day, -365, GETDATE()) OR l.SoldDate >= DATEADD(day, -365, GETDATE()) OR l.StatusTypeID = 1)
    ) as BuyTransactionCount
    
FROM dbo.UserAgentCode uac
INNER JOIN dbo.AspNetUsers u ON u.Id = uac.AspNetUserId
LEFT JOIN dbo.AspNetUserProfiles up ON up.AspNetUserId = u.Id
LEFT JOIN dbo.UserMarketingProfile ump ON ump.AspNetUserId = u.Id
LEFT JOIN dbo.UserOffice uo ON uo.AspNetUserId = u.Id
LEFT JOIN dbo.UserOrganization uorg ON uorg.AspNetUserId = u.Id
LEFT JOIN dbo.Organization org ON org.OrganizationId = uorg.OrganizationId
LEFT JOIN dbo.AspNetUserRoles ur ON ur.UserId = u.Id
LEFT JOIN dbo.AspNetRoles r ON r.Id = ur.RoleId

-- Match to MLS roster agent with SAME MLS ID
INNER JOIN MlsListing.dbo.MlsListingAgent a ON a.MlsID = uac.MlsID
  AND a.MlsID = 2
  AND (
    a.UserCode = uac.AgentCode
    OR LTRIM(RTRIM(a.UserCode)) = LTRIM(RTRIM(uac.AgentCode))
  )

WHERE uac.MlsID = 2
  AND uac.AgentCode IS NOT NULL
  AND uac.AgentCode != ''
  -- Agent Status: Active only
  AND a.AgentStatusID = 1
  -- Licensed agent
  AND a.LicenseNumber IS NOT NULL
  AND a.LicenseNumber != ''
  AND a.LicenseNumber != '0'
  -- Exclude assistants/affiliates/appraisers
  AND (a.AgentType IS NULL OR a.AgentType = '' OR (
    a.AgentType NOT LIKE '%Assistant%'
    AND a.AgentType NOT LIKE '%Affiliate%'
    AND a.AgentType NOT LIKE '%Secretary%'
    AND a.AgentType NOT LIKE '%Staff%'
    AND a.AgentType NOT LIKE '%Appraiser%'
    AND a.AgentType NOT LIKE 'Appr%'
  ))
  -- Has buy OR sell transaction in last 365 days
  AND EXISTS (
    SELECT 1
    FROM MlsListing.dbo.Listing l
    WHERE l.MlsID = 2
      AND (
        (l.ListingAgentID = uac.AgentCode OR LTRIM(RTRIM(l.ListingAgentID)) = LTRIM(RTRIM(uac.AgentCode)))
        OR
        (l.BuyersAgentID = uac.AgentCode OR LTRIM(RTRIM(l.BuyersAgentID)) = LTRIM(RTRIM(uac.AgentCode)))
      )
      AND (
        (l.ListDate >= DATEADD(day, -365, GETDATE()))
        OR
        (l.SoldDate >= DATEADD(day, -365, GETDATE()))
        OR
        (l.StatusTypeID = 1)
      )
  )

ORDER BY up.FirstName, up.LastName;
GO

