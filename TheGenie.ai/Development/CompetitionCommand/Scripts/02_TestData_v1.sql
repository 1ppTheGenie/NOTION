-- ============================================
-- Competition Command: Test Data
-- Version 1.0 | Created: 12/14/2025
-- Database: FarmGenie_Dev
-- ============================================

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE FarmGenie_Dev;
GO

PRINT 'Inserting test data...';

-- Insert test ownership record
INSERT INTO dbo.AreaOwnership (AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId, Status, StartDate, Notes)
VALUES ('test-user-001', 12345, 0, 1, 'Active', GETUTCDATE(), 'Test ownership record - SFR in Area 12345');

-- Log to history
INSERT INTO dbo.AreaOwnershipHistory (AreaOwnershipId, Action, NewStatus, Notes)
SELECT AreaOwnershipId, 'Created', 'Active', 'Initial test record'
FROM dbo.AreaOwnership WHERE AspNetUserId = 'test-user-001';

-- Insert test campaign history
INSERT INTO dbo.AreaCampaignHistory (AreaOwnershipId, CampaignDate, PropertyTypeId, MessagesSent, MessagesDelivered, Clicks, TwilioCost)
SELECT AreaOwnershipId, DATEADD(DAY, -7, GETUTCDATE()), 0, 150, 142, 23, 12.50
FROM dbo.AreaOwnership WHERE AspNetUserId = 'test-user-001';

-- Insert test waitlist entry
INSERT INTO dbo.AreaWaitlist (AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId, QueuePosition, Status, Notes)
VALUES ('test-user-002', 12345, 0, 1, 1, 'Waiting', 'First in queue for Area 12345');

PRINT '✓ Test data inserted';
GO

-- Verify data
SELECT 'AreaOwnership' AS TableName, COUNT(*) AS Records FROM dbo.AreaOwnership
UNION ALL
SELECT 'AreaOwnershipHistory', COUNT(*) FROM dbo.AreaOwnershipHistory
UNION ALL
SELECT 'AreaCampaignHistory', COUNT(*) FROM dbo.AreaCampaignHistory
UNION ALL
SELECT 'AreaWaitlist', COUNT(*) FROM dbo.AreaWaitlist;

-- Show ownership details
SELECT 
    ao.AreaOwnershipId,
    ao.AspNetUserId,
    ao.AreaId,
    ao.Status,
    ao.StartDate,
    cs.TotalCampaigns,
    cs.TotalMessagesSent,
    cs.TotalClicks
FROM dbo.AreaOwnership ao
LEFT JOIN dbo.vw_AreaCampaignSummary cs ON cs.AreaOwnershipId = ao.AreaOwnershipId;

PRINT '';
PRINT 'Schema validation complete!';
GO

