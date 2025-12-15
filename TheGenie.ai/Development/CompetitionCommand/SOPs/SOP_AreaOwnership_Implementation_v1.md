# SOP: Area Ownership & Lead Custody Implementation

---

## Executive Summary

| Field | Value |
|-------|-------|
| **Purpose** | Step-by-step guide for implementing the AreaOwnership and LeadCustody schema |
| **Current State** | Ready for execution - All scripts created and validated |
| **Key Outputs** | 15 new database tables, 5 views, migrated data from UserOwnedArea, 85K lead custody records |
| **Remaining Work** | Execute scripts, validate data, test, deploy to production |
| **Last Validated** | 12/15/2025 |

---

## Document Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Author** | Cursor AI |

---

## Prerequisites

### Required Access
- [ ] SQL Server Management Studio (SSMS) or Azure Data Studio
- [ ] Database credentials for FarmGenie_Dev (local testing)
- [ ] Database credentials for FarmGenie (production - when ready)
- [ ] Admin access to approve schema changes

### Required Files
All scripts located at: `C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Scripts\SQL\Schema\`

| Script | Purpose |
|--------|---------|
| `01_Lookup_Tables_v1.sql` | Create 8 lookup/reference tables |
| `02_Core_Tables_v1.sql` | Create AreaOwnership, AreaWaitlist |
| `03_History_Tables_v1.sql` | Create AreaOwnershipHistory, AreaCampaignHistory |
| `04_LeadCustody_Tables_v1.sql` | Create LeadCustody, LeadCustodyHistory, LeadTransaction |
| `05_Views_v1.sql` | Create 5 reporting views |

---

## Implementation Checklist

### Phase 1: Local Development Environment

#### Step 1.1: Create Database (if not exists)
```sql
-- Run in SSMS connected to local SQL Server
CREATE DATABASE FarmGenie_Dev;
GO
```
- [ ] Database created
- [ ] Verified connection

#### Step 1.2: Execute Script 01 - Lookup Tables
```powershell
# From command line
sqlcmd -S localhost -d FarmGenie_Dev -i "C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Scripts\SQL\Schema\01_Lookup_Tables_v1.sql"
```
- [ ] Script executed successfully
- [ ] 8 tables created:
  - [ ] PropertyType (2 records)
  - [ ] OwnershipType (6 records)
  - [ ] OwnershipStatusType (10 records)
  - [ ] EndReasonType (7 records)
  - [ ] ActionType (7 records)
  - [ ] ReferralSourceType (5 records)
  - [ ] CustodyStatusType (5 records)
  - [ ] CustodyTransferReason (6 records)

#### Step 1.3: Execute Script 02 - Core Tables
```powershell
sqlcmd -S localhost -d FarmGenie_Dev -i "C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Scripts\SQL\Schema\02_Core_Tables_v1.sql"
```
- [ ] Script executed successfully
- [ ] Tables created:
  - [ ] AreaOwnership
  - [ ] AreaWaitlist
- [ ] Indexes created:
  - [ ] IX_AreaOwnership_ActiveOwner (unique)
  - [ ] IX_AreaOwnership_UserId
  - [ ] IX_AreaOwnership_AreaId
  - [ ] IX_AreaWaitlist_Queue
  - [ ] IX_AreaWaitlist_UserId
- [ ] Foreign keys created

#### Step 1.4: Execute Script 03 - History Tables
```powershell
sqlcmd -S localhost -d FarmGenie_Dev -i "C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Scripts\SQL\Schema\03_History_Tables_v1.sql"
```
- [ ] Script executed successfully
- [ ] Tables created:
  - [ ] AreaOwnershipHistory
  - [ ] AreaCampaignHistory

#### Step 1.5: Execute Script 04 - Lead Custody Tables
```powershell
sqlcmd -S localhost -d FarmGenie_Dev -i "C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Scripts\SQL\Schema\04_LeadCustody_Tables_v1.sql"
```
- [ ] Script executed successfully
- [ ] Tables created:
  - [ ] LeadCustody
  - [ ] LeadCustodyHistory
  - [ ] LeadTransaction

#### Step 1.6: Execute Script 05 - Views
```powershell
sqlcmd -S localhost -d FarmGenie_Dev -i "C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Scripts\SQL\Schema\05_Views_v1.sql"
```
- [ ] Script executed successfully
- [ ] Views created:
  - [ ] vw_AreaAvailability
  - [ ] vw_AreaOwnershipDetail
  - [ ] vw_LeadCustodyDetail
  - [ ] vw_OrphanedLeads
  - [ ] vw_LeadTransactionSummary

---

### Phase 2: Data Migration (Local Testing)

#### Step 2.1: Migrate UserOwnedArea to AreaOwnership
```sql
-- Preview migration (don't commit)
SELECT 
    uoa.UserOwnedAreaId,
    uoa.AreaId,
    uoa.PropertyTypeId,
    uoa.AspNetUserId AS UserId,
    6 AS OwnershipTypeId,  -- Migration
    11 AS OwnershipStatusTypeId,  -- Active
    uoa.CreateDate AS StartDate
FROM UserOwnedArea uoa;

-- Actual migration
INSERT INTO AreaOwnership (
    AreaId, PropertyTypeId, UserId, OwnershipTypeId, 
    OwnershipStatusTypeId, StartDate, LegacyUserOwnedAreaId, CreateDate
)
SELECT 
    uoa.AreaId,
    uoa.PropertyTypeId,
    uoa.AspNetUserId,
    6,  -- Migration type
    11, -- Active status
    uoa.CreateDate,
    uoa.UserOwnedAreaId,
    GETDATE()
FROM UserOwnedArea uoa;
```
- [ ] Preview counts match expected
- [ ] Migration executed
- [ ] Record counts verified

#### Step 2.2: Create LeadCustody Records for All Leads
```sql
-- Preview
SELECT 
    gl.GenieLeadId,
    CASE 
        WHEN ao.AreaOwnershipId IS NOT NULL THEN 2  -- AgentLicensed
        ELSE 1  -- 1PPCustody
    END AS CustodyStatusTypeId,
    CASE 
        WHEN ao.AreaOwnershipId IS NOT NULL THEN ao.UserId
        ELSE NULL
    END AS CurrentLicenseeUserId,
    ao.AreaOwnershipId AS SourceAreaOwnershipId,
    ISNULL(ao.DefaultSplitPercentage, 25.00) AS SplitPercentage
FROM GenieLead gl
LEFT JOIN AreaOwnership ao ON gl.AreaId = ao.AreaId 
    AND ao.OwnershipStatusTypeId = 11 
    AND ao.IsDeleted = 0;

-- Actual migration
INSERT INTO LeadCustody (
    GenieLeadId, CustodyStatusTypeId, CurrentLicenseeUserId,
    SourceAreaOwnershipId, SplitPercentage, CreateDate, LastUpdateDate
)
SELECT 
    gl.GenieLeadId,
    CASE 
        WHEN ao.AreaOwnershipId IS NOT NULL THEN 2
        ELSE 1
    END,
    CASE 
        WHEN ao.AreaOwnershipId IS NOT NULL THEN ao.UserId
        ELSE NULL
    END,
    ao.AreaOwnershipId,
    ISNULL(ao.DefaultSplitPercentage, 25.00),
    GETDATE(),
    GETDATE()
FROM GenieLead gl
LEFT JOIN AreaOwnership ao ON gl.AreaId = ao.AreaId 
    AND ao.OwnershipStatusTypeId = 11 
    AND ao.IsDeleted = 0;
```
- [ ] Preview counts:
  - [ ] Total leads: ______
  - [ ] AgentLicensed: ______
  - [ ] 1PPCustody (orphaned): ______
- [ ] Migration executed
- [ ] Record counts verified

#### Step 2.3: Create Initial History Records for Orphaned Leads
```sql
INSERT INTO LeadCustodyHistory (
    LeadCustodyId, FromUserId, ToUserId, CustodyTransferReasonId,
    TransferredByUserId, TransferDate, Notes
)
SELECT 
    lc.LeadCustodyId,
    gl.AspNetUserId,  -- Original agent
    NULL,             -- Now 1PP custody
    2,                -- AgentCancelled reason
    'SYSTEM',
    GETDATE(),
    'Initial migration - lead was orphaned'
FROM LeadCustody lc
JOIN GenieLead gl ON lc.GenieLeadId = gl.GenieLeadId
WHERE lc.CustodyStatusTypeId = 1  -- 1PPCustody
AND gl.AspNetUserId IS NOT NULL;
```
- [ ] History records created for orphaned leads

---

### Phase 3: Validation

#### Step 3.1: Verify Table Counts
```sql
SELECT 'AreaOwnership' AS TableName, COUNT(*) AS RecordCount FROM AreaOwnership
UNION ALL SELECT 'AreaWaitlist', COUNT(*) FROM AreaWaitlist
UNION ALL SELECT 'LeadCustody', COUNT(*) FROM LeadCustody
UNION ALL SELECT 'LeadCustodyHistory', COUNT(*) FROM LeadCustodyHistory;
```
- [ ] Counts match expected values

#### Step 3.2: Verify Orphaned Lead Recovery
```sql
SELECT 
    CustodyStatusTypeId,
    cst.StatusName,
    COUNT(*) AS LeadCount
FROM LeadCustody lc
JOIN CustodyStatusType cst ON lc.CustodyStatusTypeId = cst.CustodyStatusTypeId
GROUP BY CustodyStatusTypeId, cst.StatusName;
```
- [ ] AgentLicensed count: ______ (expected: ~22,443)
- [ ] 1PPCustody count: ______ (expected: ~56,876)

#### Step 3.3: Test Views
```sql
SELECT TOP 10 * FROM vw_AreaAvailability WHERE AreaStatus = 'AVAILABLE';
SELECT TOP 10 * FROM vw_AreaOwnershipDetail WHERE IsDeleted = 0;
SELECT TOP 10 * FROM vw_LeadCustodyDetail;
SELECT COUNT(*) AS OrphanedCount FROM vw_OrphanedLeads;
```
- [ ] All views return data correctly

---

### Phase 4: Production Deployment

**⚠️ ONLY PROCEED AFTER LOCAL TESTING IS COMPLETE AND APPROVED**

#### Step 4.1: Production Backup
```sql
BACKUP DATABASE FarmGenie TO DISK = 'FarmGenie_PreOwnershipSchema_YYYYMMDD.bak';
```
- [ ] Backup completed
- [ ] Backup verified

#### Step 4.2: Execute Scripts on Production
- [ ] Script 01 executed
- [ ] Script 02 executed
- [ ] Script 03 executed
- [ ] Script 04 executed
- [ ] Script 05 executed

#### Step 4.3: Production Data Migration
- [ ] UserOwnedArea migrated
- [ ] LeadCustody records created
- [ ] History records created

#### Step 4.4: Production Validation
- [ ] All counts verified
- [ ] Views tested
- [ ] Application tested

---

## Rollback Plan

### If Issues Occur During Schema Creation
```sql
-- Drop tables in reverse order
DROP TABLE IF EXISTS LeadTransaction;
DROP TABLE IF EXISTS LeadCustodyHistory;
DROP TABLE IF EXISTS LeadCustody;
DROP TABLE IF EXISTS AreaCampaignHistory;
DROP TABLE IF EXISTS AreaOwnershipHistory;
DROP TABLE IF EXISTS AreaWaitlist;
DROP TABLE IF EXISTS AreaOwnership;
DROP TABLE IF EXISTS CustodyTransferReason;
DROP TABLE IF EXISTS CustodyStatusType;
DROP TABLE IF EXISTS ReferralSourceType;
DROP TABLE IF EXISTS ActionType;
DROP TABLE IF EXISTS EndReasonType;
DROP TABLE IF EXISTS OwnershipStatusType;
DROP TABLE IF EXISTS OwnershipType;
DROP TABLE IF EXISTS PropertyType;
```

### If Issues Occur After Migration
- Restore from backup taken in Step 4.1
- Document what went wrong
- Fix and re-attempt

---

## Post-Implementation Tasks

- [ ] Update application code to use new tables
- [ ] Create admin UI for ownership management
- [ ] Create admin UI for lead custody management
- [ ] Set up automated grace period expiration job
- [ ] Set up WHMCS webhook for cancellation events
- [ ] Document for support team

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/15/2025 | Cursor AI | Initial document creation |


