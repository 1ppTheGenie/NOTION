/*
================================================================================
FR-001 & FR-006: Area Ownership & Lead Custody Schema
Script 05: Views
================================================================================
Version: 1.0
Created: 12/15/2025
Author: Cursor AI
Database: FarmGenie (or FarmGenie_Dev for local testing)

PREREQUISITES:
- Run Scripts 01-04 first

CHANGE LOG:
- v1.0 (12/15/2025): Initial creation
================================================================================
*/

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'Script 05: Creating Views';
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

-- ============================================================================
-- 1. vw_AreaAvailability - Shows all areas and their current status
-- ============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_AreaAvailability')
    DROP VIEW [dbo].[vw_AreaAvailability];
GO

CREATE VIEW [dbo].[vw_AreaAvailability] AS
SELECT 
    va.AreaId,
    va.Area_Name,
    pt.PropertyTypeId,
    pt.PropertyTypeName,
    CASE 
        WHEN ao.OwnershipStatusTypeId = 11 THEN 'TAKEN'
        WHEN aw.WaitlistCount > 0 THEN 'AVAILABLE (Waitlist Pending)'
        ELSE 'AVAILABLE'
    END AS AreaStatus,
    ao.AreaOwnershipId,
    ao.UserId AS CurrentOwnerId,
    ao.StartDate AS OwnedSince,
    ao.OwnershipStatusTypeId,
    ost.StatusName AS OwnershipStatus,
    ISNULL(aw.WaitlistCount, 0) AS WaitlistCount,
    prev.EndDate AS LastAvailableDate
FROM ViewArea va
CROSS JOIN [dbo].[PropertyType] pt
LEFT JOIN [dbo].[AreaOwnership] ao 
    ON va.AreaId = ao.AreaId 
    AND pt.PropertyTypeId = ao.PropertyTypeId
    AND ao.OwnershipStatusTypeId = 11  -- Active only
    AND ao.IsDeleted = 0
LEFT JOIN [dbo].[OwnershipStatusType] ost 
    ON ao.OwnershipStatusTypeId = ost.OwnershipStatusTypeId
LEFT JOIN (
    SELECT AreaId, PropertyTypeId, MAX(EndDate) AS EndDate
    FROM [dbo].[AreaOwnership]
    WHERE OwnershipStatusTypeId = 20  -- Ended
    AND IsDeleted = 0
    GROUP BY AreaId, PropertyTypeId
) prev ON va.AreaId = prev.AreaId AND pt.PropertyTypeId = prev.PropertyTypeId
LEFT JOIN (
    SELECT AreaId, PropertyTypeId, COUNT(*) AS WaitlistCount
    FROM [dbo].[AreaWaitlist]
    WHERE WaitlistStatusTypeId = 1  -- Waiting
    GROUP BY AreaId, PropertyTypeId
) aw ON va.AreaId = aw.AreaId AND pt.PropertyTypeId = aw.PropertyTypeId
WHERE pt.IsActive = 1;
GO

PRINT 'Created view: vw_AreaAvailability';
GO

-- ============================================================================
-- 2. vw_AreaOwnershipDetail - Full ownership details with lookups resolved
-- ============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_AreaOwnershipDetail')
    DROP VIEW [dbo].[vw_AreaOwnershipDetail];
GO

CREATE VIEW [dbo].[vw_AreaOwnershipDetail] AS
SELECT 
    ao.AreaOwnershipId,
    ao.AreaId,
    va.Area_Name,
    pno.PolygonNameOverride AS AreaNameOverride,
    ISNULL(pno.PolygonNameOverride, va.Area_Name) AS DisplayName,
    ao.PropertyTypeId,
    pt.PropertyTypeName,
    ao.UserId,
    u.Email AS OwnerEmail,
    ISNULL(up.FirstName + ' ' + up.LastName, u.Email) AS OwnerName,
    ao.OwnershipTypeId,
    ot.OwnershipTypeName,
    ao.OwnershipStatusTypeId,
    ost.StatusName AS OwnershipStatus,
    ost.StatusCategory,
    ost.AllowsCampaigns,
    ao.StartDate,
    ao.EndDate,
    ao.EndReasonTypeId,
    ert.EndReasonName,
    ao.ApprovedByUserId,
    ao.ApprovedDate,
    ao.ReferredByUserId,
    ref_u.Email AS ReferrerEmail,
    ao.ReferralSourceTypeId,
    rst.SourceTypeName AS ReferralSource,
    ao.SourceWaitlistId,
    ao.LeadCustodyEnabled,
    ao.DefaultSplitPercentage,
    ao.LegacyUserOwnedAreaId,
    ao.CreateDate,
    ao.LastUpdateDate,
    ao.IsDeleted
FROM [dbo].[AreaOwnership] ao
INNER JOIN ViewArea va ON ao.AreaId = va.AreaId
INNER JOIN [dbo].[PropertyType] pt ON ao.PropertyTypeId = pt.PropertyTypeId
INNER JOIN AspNetUsers u ON ao.UserId = u.Id
LEFT JOIN AspNetUserProfiles up ON ao.UserId = up.AspNetUserId
INNER JOIN [dbo].[OwnershipType] ot ON ao.OwnershipTypeId = ot.OwnershipTypeId
INNER JOIN [dbo].[OwnershipStatusType] ost ON ao.OwnershipStatusTypeId = ost.OwnershipStatusTypeId
LEFT JOIN [dbo].[EndReasonType] ert ON ao.EndReasonTypeId = ert.EndReasonTypeId
LEFT JOIN [dbo].[ReferralSourceType] rst ON ao.ReferralSourceTypeId = rst.ReferralSourceTypeId
LEFT JOIN AspNetUsers ref_u ON ao.ReferredByUserId = ref_u.Id
LEFT JOIN PolygonNameOverride pno ON ao.AreaId = pno.PolygonId;
GO

PRINT 'Created view: vw_AreaOwnershipDetail';
GO

-- ============================================================================
-- 3. vw_LeadCustodyDetail - Full custody details with lookups resolved
-- ============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_LeadCustodyDetail')
    DROP VIEW [dbo].[vw_LeadCustodyDetail];
GO

CREATE VIEW [dbo].[vw_LeadCustodyDetail] AS
SELECT 
    lc.LeadCustodyId,
    lc.GenieLeadId,
    gl.FirstName AS LeadFirstName,
    gl.LastName AS LeadLastName,
    gl.Email AS LeadEmail,
    gl.Phone AS LeadPhone,
    gl.AreaId,
    gl.CreateDate AS LeadCreateDate,
    lc.CustodyStatusTypeId,
    cst.StatusName AS CustodyStatus,
    lc.CurrentLicenseeUserId,
    lic_u.Email AS LicenseeEmail,
    ISNULL(lic_up.FirstName + ' ' + lic_up.LastName, lic_u.Email) AS LicenseeName,
    lc.SourceAreaOwnershipId,
    lc.SplitPercentage,
    lc.GracePeriodEndDate,
    CASE 
        WHEN lc.GracePeriodEndDate IS NOT NULL AND lc.GracePeriodEndDate < GETDATE() 
        THEN 1 ELSE 0 
    END AS IsGracePeriodExpired,
    lc.CreateDate AS CustodyCreateDate,
    lc.LastUpdateDate AS CustodyLastUpdate
FROM [dbo].[LeadCustody] lc
INNER JOIN GenieLead gl ON lc.GenieLeadId = gl.GenieLeadId
INNER JOIN [dbo].[CustodyStatusType] cst ON lc.CustodyStatusTypeId = cst.CustodyStatusTypeId
LEFT JOIN AspNetUsers lic_u ON lc.CurrentLicenseeUserId = lic_u.Id
LEFT JOIN AspNetUserProfiles lic_up ON lc.CurrentLicenseeUserId = lic_up.AspNetUserId;
GO

PRINT 'Created view: vw_LeadCustodyDetail';
GO

-- ============================================================================
-- 4. vw_OrphanedLeads - Leads in 1PP custody available for reassignment
-- ============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_OrphanedLeads')
    DROP VIEW [dbo].[vw_OrphanedLeads];
GO

CREATE VIEW [dbo].[vw_OrphanedLeads] AS
SELECT 
    lc.LeadCustodyId,
    lc.GenieLeadId,
    gl.FirstName + ' ' + gl.LastName AS LeadName,
    gl.Email AS LeadEmail,
    gl.Phone AS LeadPhone,
    gl.AreaId,
    va.Area_Name,
    gl.CreateDate AS LeadCreateDate,
    lc.SplitPercentage,
    lc.CreateDate AS CustodyCreateDate,
    DATEDIFF(DAY, gl.CreateDate, GETDATE()) AS DaysSinceLeadCreated
FROM [dbo].[LeadCustody] lc
INNER JOIN GenieLead gl ON lc.GenieLeadId = gl.GenieLeadId
LEFT JOIN ViewArea va ON gl.AreaId = va.AreaId
WHERE lc.CustodyStatusTypeId = 1  -- 1PPCustody
AND lc.CurrentLicenseeUserId IS NULL;
GO

PRINT 'Created view: vw_OrphanedLeads';
GO

-- ============================================================================
-- 5. vw_LeadTransactionSummary - Transaction reporting view
-- ============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_LeadTransactionSummary')
    DROP VIEW [dbo].[vw_LeadTransactionSummary];
GO

CREATE VIEW [dbo].[vw_LeadTransactionSummary] AS
SELECT 
    YEAR(lt.TransactionDate) AS TransactionYear,
    MONTH(lt.TransactionDate) AS TransactionMonth,
    COUNT(*) AS TransactionCount,
    SUM(lt.TransactionAmount) AS TotalTransactionAmount,
    SUM(lt.CommissionTotal) AS TotalCommission,
    SUM(lt.SplitTo1PP) AS Total1PPRevenue,
    SUM(lt.SplitToAgent) AS TotalAgentRevenue,
    AVG(lt.SplitPercentageTo1PP) AS AvgSplitPercentage
FROM [dbo].[LeadTransaction] lt
GROUP BY YEAR(lt.TransactionDate), MONTH(lt.TransactionDate);
GO

PRINT 'Created view: vw_LeadTransactionSummary';
GO

PRINT '========================================';
PRINT 'Script 05: Views COMPLETE';
PRINT 'Finished: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

