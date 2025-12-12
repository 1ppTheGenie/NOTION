# Feature Request: Area Ownership & Waitlist System
## FR-001 | Development Specification
### Version 1.0 | December 2025

---

## Document Purpose
This specification provides iterative development details for implementing the Area Ownership & Waitlist system. Each iteration is designed to be independently deployable and testable.

---

# ITERATION 1: Schema Foundation
## Target: Week 1-2

### Objective
Create new database schema with soft deletes and history tracking, migrate existing data.

---

### 1.1 New Tables

#### Table: `AreaOwnership`
Replaces `UserOwnedArea` with soft deletes and status tracking.

```sql
CREATE TABLE dbo.AreaOwnership (
    AreaOwnershipId         INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    AreaId                  INT NOT NULL,
    PropertyTypeId          INT NOT NULL DEFAULT 0,
    AreaOwnershipTypeId     INT NOT NULL DEFAULT 1,
    
    -- Status & Lifecycle
    Status                  NVARCHAR(20) NOT NULL DEFAULT 'Active',
        -- Values: 'Pending', 'Active', 'Suspended', 'Ended'
    
    -- Request/Approval
    RequestDate             DATETIME2 NULL,
    ApprovalDate            DATETIME2 NULL,
    ApprovedByUserId        NVARCHAR(128) NULL,
    
    -- Ownership Period
    StartDate               DATETIME2 NULL,
    EndDate                 DATETIME2 NULL,
    EndReason               NVARCHAR(50) NULL,
        -- Values: 'Canceled', 'Expired', 'Transferred', 'AdminRemoved', 'NonPayment'
    
    -- Metadata
    Notes                   NVARCHAR(500) NULL,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedByUserId        NVARCHAR(128) NULL,
    
    -- Constraints
    CONSTRAINT FK_AreaOwnership_AspNetUsers 
        FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT FK_AreaOwnership_ApprovedBy 
        FOREIGN KEY (ApprovedByUserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT CK_AreaOwnership_Status 
        CHECK (Status IN ('Pending', 'Active', 'Suspended', 'Ended'))
);

-- Indexes
CREATE INDEX IX_AreaOwnership_AspNetUserId ON dbo.AreaOwnership(AspNetUserId);
CREATE INDEX IX_AreaOwnership_AreaId ON dbo.AreaOwnership(AreaId);
CREATE INDEX IX_AreaOwnership_Status ON dbo.AreaOwnership(Status);
CREATE INDEX IX_AreaOwnership_AreaId_Status ON dbo.AreaOwnership(AreaId, Status);

-- Unique constraint: One active owner per Area + PropertyType + OwnershipType
CREATE UNIQUE INDEX IX_AreaOwnership_UniqueActive 
    ON dbo.AreaOwnership(AreaId, PropertyTypeId, AreaOwnershipTypeId) 
    WHERE Status = 'Active';
```

#### Table: `AreaOwnershipHistory`
Audit trail for all ownership changes.

```sql
CREATE TABLE dbo.AreaOwnershipHistory (
    AreaOwnershipHistoryId  INT IDENTITY(1,1) PRIMARY KEY,
    AreaOwnershipId         INT NOT NULL,
    
    -- Action Details
    Action                  NVARCHAR(30) NOT NULL,
        -- Values: 'Created', 'Approved', 'Activated', 'Suspended', 
        --         'Resumed', 'Ended', 'Modified', 'Transferred'
    PreviousStatus          NVARCHAR(20) NULL,
    NewStatus               NVARCHAR(20) NULL,
    
    -- Who & When
    ActionByUserId          NVARCHAR(128) NULL,
    ActionDate              DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    -- Context
    Notes                   NVARCHAR(500) NULL,
    AdditionalData          NVARCHAR(MAX) NULL, -- JSON for extra context
    
    CONSTRAINT FK_AreaOwnershipHistory_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId)
);

CREATE INDEX IX_AreaOwnershipHistory_AreaOwnershipId 
    ON dbo.AreaOwnershipHistory(AreaOwnershipId);
CREATE INDEX IX_AreaOwnershipHistory_ActionDate 
    ON dbo.AreaOwnershipHistory(ActionDate);
```

#### Table: `AreaCampaignHistory`
Tracks all Competition Command campaign activity per ownership period.

```sql
CREATE TABLE dbo.AreaCampaignHistory (
    AreaCampaignHistoryId   INT IDENTITY(1,1) PRIMARY KEY,
    AreaOwnershipId         INT NOT NULL,
    
    -- Campaign Reference
    PropertyCastId          INT NULL,           -- Link to PropertyCast execution
    PropertyCollectionDetailId INT NULL,        -- Link to campaign definition
    
    -- Campaign Details
    CampaignDate            DATETIME2 NOT NULL,
    PropertyTypeId          INT NOT NULL DEFAULT 0,
    
    -- Message Metrics
    MessagesSent            INT NOT NULL DEFAULT 0,
    MessagesDelivered       INT NOT NULL DEFAULT 0,
    MessagesFailed          INT NOT NULL DEFAULT 0,
    
    -- Engagement Metrics
    Clicks                  INT NOT NULL DEFAULT 0,
    CTASubmitted            INT NOT NULL DEFAULT 0,
    CTAVerified             INT NOT NULL DEFAULT 0,
    AgentNotifications      INT NOT NULL DEFAULT 0,
    
    -- Opt-Out Tracking
    OptOuts                 INT NOT NULL DEFAULT 0,
    
    -- Cost Tracking
    TwilioCost              DECIMAL(10,4) NOT NULL DEFAULT 0,
    AgentNotifyCost         DECIMAL(10,4) NOT NULL DEFAULT 0,
    TotalCost               AS (TwilioCost + AgentNotifyCost) PERSISTED,
    
    -- Metadata
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_AreaCampaignHistory_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId),
    CONSTRAINT FK_AreaCampaignHistory_PropertyCast 
        FOREIGN KEY (PropertyCastId) REFERENCES dbo.PropertyCast(PropertyCastId)
);

-- Indexes
CREATE INDEX IX_AreaCampaignHistory_AreaOwnershipId 
    ON dbo.AreaCampaignHistory(AreaOwnershipId);
CREATE INDEX IX_AreaCampaignHistory_CampaignDate 
    ON dbo.AreaCampaignHistory(CampaignDate);
CREATE INDEX IX_AreaCampaignHistory_PropertyCastId 
    ON dbo.AreaCampaignHistory(PropertyCastId);

-- Composite index for reporting
CREATE INDEX IX_AreaCampaignHistory_Ownership_Date 
    ON dbo.AreaCampaignHistory(AreaOwnershipId, CampaignDate);
```

#### View: `vw_AreaCampaignSummary`
Aggregated campaign metrics per ownership.

```sql
CREATE VIEW dbo.vw_AreaCampaignSummary AS
SELECT 
    ao.AreaOwnershipId,
    ao.AspNetUserId,
    ao.AreaId,
    ao.PropertyTypeId,
    ao.Status AS OwnershipStatus,
    ao.StartDate AS OwnershipStartDate,
    ao.EndDate AS OwnershipEndDate,
    
    -- Campaign Totals
    COUNT(ach.AreaCampaignHistoryId) AS TotalCampaigns,
    MAX(ach.CampaignDate) AS LastCampaignDate,
    DATEDIFF(DAY, MAX(ach.CampaignDate), GETUTCDATE()) AS DaysSinceLastCampaign,
    
    -- Message Totals
    SUM(ach.MessagesSent) AS TotalMessagesSent,
    SUM(ach.MessagesDelivered) AS TotalDelivered,
    CASE WHEN SUM(ach.MessagesSent) > 0 
         THEN CAST(SUM(ach.MessagesDelivered) AS FLOAT) / SUM(ach.MessagesSent) * 100 
         ELSE 0 END AS DeliveryRate,
    
    -- Engagement Totals
    SUM(ach.Clicks) AS TotalClicks,
    CASE WHEN SUM(ach.MessagesDelivered) > 0 
         THEN CAST(SUM(ach.Clicks) AS FLOAT) / SUM(ach.MessagesDelivered) * 100 
         ELSE 0 END AS ClickRate,
    SUM(ach.CTASubmitted) AS TotalCTASubmitted,
    SUM(ach.CTAVerified) AS TotalCTAVerified,
    SUM(ach.AgentNotifications) AS TotalAgentNotifications,
    
    -- Opt-Out Totals
    SUM(ach.OptOuts) AS TotalOptOuts,
    CASE WHEN SUM(ach.MessagesDelivered) > 0 
         THEN CAST(SUM(ach.OptOuts) AS FLOAT) / SUM(ach.MessagesDelivered) * 100 
         ELSE 0 END AS OptOutRate,
    
    -- Cost Totals
    SUM(ach.TwilioCost) AS TotalTwilioCost,
    SUM(ach.AgentNotifyCost) AS TotalAgentNotifyCost,
    SUM(ach.TotalCost) AS GrandTotalCost,
    
    -- Averages
    AVG(ach.MessagesSent) AS AvgMessagesPerCampaign,
    AVG(ach.TotalCost) AS AvgCostPerCampaign

FROM dbo.AreaOwnership ao
LEFT JOIN dbo.AreaCampaignHistory ach 
    ON ach.AreaOwnershipId = ao.AreaOwnershipId
GROUP BY 
    ao.AreaOwnershipId,
    ao.AspNetUserId,
    ao.AreaId,
    ao.PropertyTypeId,
    ao.Status,
    ao.StartDate,
    ao.EndDate;
```

---

### 1.2 Data Migration Script

```sql
-- ============================================
-- Migration: UserOwnedArea → AreaOwnership
-- Run Date: [TBD]
-- ============================================

BEGIN TRANSACTION;

-- Step 1: Insert active records from UserOwnedArea
INSERT INTO dbo.AreaOwnership (
    AspNetUserId,
    AreaId,
    PropertyTypeId,
    AreaOwnershipTypeId,
    Status,
    StartDate,
    CreatedDate,
    ModifiedDate
)
SELECT 
    uoa.AspNetUserId,
    uoa.AreaId,
    uoa.PropertyTypeId,
    uoa.AreaOwnershipTypeId,
    'Active' AS Status,
    uoa.CreateDate AS StartDate,
    uoa.CreateDate AS CreatedDate,
    GETUTCDATE() AS ModifiedDate
FROM dbo.UserOwnedArea uoa;

-- Step 2: Log migration in history
INSERT INTO dbo.AreaOwnershipHistory (
    AreaOwnershipId,
    Action,
    NewStatus,
    ActionDate,
    Notes
)
SELECT 
    ao.AreaOwnershipId,
    'Migrated' AS Action,
    'Active' AS NewStatus,
    GETUTCDATE() AS ActionDate,
    'Migrated from UserOwnedArea table' AS Notes
FROM dbo.AreaOwnership ao;

-- Step 3: Reconstruct ended ownership from PropertyCollectionDetail
-- (Areas with campaigns but no UserOwnedArea record)
INSERT INTO dbo.AreaOwnership (
    AspNetUserId,
    AreaId,
    PropertyTypeId,
    AreaOwnershipTypeId,
    Status,
    EndDate,
    EndReason,
    CreatedDate,
    ModifiedDate,
    Notes
)
SELECT DISTINCT
    pcd.AspNetUserId,
    pcd.AreaId,
    0 AS PropertyTypeId, -- Unknown, default to SFR
    1 AS AreaOwnershipTypeId, -- FarmCaster
    'Ended' AS Status,
    MAX(pcd.CreateDate) AS EndDate, -- Last campaign as proxy for end
    'Unknown' AS EndReason,
    GETUTCDATE() AS CreatedDate,
    GETUTCDATE() AS ModifiedDate,
    'Reconstructed from campaign history - original ownership record deleted' AS Notes
FROM dbo.PropertyCollectionDetail pcd
INNER JOIN dbo.PropertyCastWorkflowQueue pcwq 
    ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
INNER JOIN dbo.PropertyCast pc 
    ON pc.PropertyCastId = pcwq.PropertyCastId
WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command (both trigger types) -- Competition Command only
    AND pcd.AreaId IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 FROM dbo.UserOwnedArea uoa
        WHERE uoa.AspNetUserId = pcd.AspNetUserId
          AND uoa.AreaId = pcd.AreaId
    )
GROUP BY pcd.AspNetUserId, pcd.AreaId;

COMMIT TRANSACTION;

-- Validation
SELECT 
    'UserOwnedArea' AS Source, COUNT(*) AS RecordCount 
FROM dbo.UserOwnedArea
UNION ALL
SELECT 
    'AreaOwnership (Active)' AS Source, COUNT(*) AS RecordCount 
FROM dbo.AreaOwnership WHERE Status = 'Active'
UNION ALL
SELECT 
    'AreaOwnership (Ended)' AS Source, COUNT(*) AS RecordCount 
FROM dbo.AreaOwnership WHERE Status = 'Ended';
```

---

### 1.3 Stored Procedures

#### Procedure: `usp_AreaOwnership_End`
```sql
CREATE PROCEDURE dbo.usp_AreaOwnership_End
    @AreaOwnershipId INT,
    @EndReason NVARCHAR(50),
    @EndedByUserId NVARCHAR(128),
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @PreviousStatus NVARCHAR(20);
    
    -- Get current status
    SELECT @PreviousStatus = Status 
    FROM dbo.AreaOwnership 
    WHERE AreaOwnershipId = @AreaOwnershipId;
    
    -- Update ownership
    UPDATE dbo.AreaOwnership
    SET 
        Status = 'Ended',
        EndDate = GETUTCDATE(),
        EndReason = @EndReason,
        ModifiedDate = GETUTCDATE(),
        ModifiedByUserId = @EndedByUserId,
        Notes = COALESCE(@Notes, Notes)
    WHERE AreaOwnershipId = @AreaOwnershipId;
    
    -- Log history
    INSERT INTO dbo.AreaOwnershipHistory (
        AreaOwnershipId, Action, PreviousStatus, NewStatus,
        ActionByUserId, ActionDate, Notes
    )
    VALUES (
        @AreaOwnershipId, 'Ended', @PreviousStatus, 'Ended',
        @EndedByUserId, GETUTCDATE(), @Notes
    );
    
    -- Return the AreaId for waitlist processing
    SELECT AreaId, PropertyTypeId, AreaOwnershipTypeId
    FROM dbo.AreaOwnership
    WHERE AreaOwnershipId = @AreaOwnershipId;
END;
```

#### Procedure: `usp_AreaOwnership_GetHistory`
```sql
CREATE PROCEDURE dbo.usp_AreaOwnership_GetHistory
    @AspNetUserId NVARCHAR(128) = NULL,
    @AreaId INT = NULL,
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ao.AreaOwnershipId,
        ao.AspNetUserId,
        u.UserName,
        up.FirstName + ' ' + up.LastName AS CustomerName,
        ao.AreaId,
        COALESCE(pno.FriendlyName, va.Name) AS AreaName,
        ao.PropertyTypeId,
        CASE ao.PropertyTypeId
            WHEN 0 THEN 'SFR'
            WHEN 1 THEN 'Condo'
            WHEN 2 THEN 'Townhouse'
            WHEN 3 THEN 'Multi-Family'
        END AS PropertyTypeName,
        ao.Status,
        ao.StartDate,
        ao.EndDate,
        ao.EndReason,
        DATEDIFF(DAY, ao.StartDate, COALESCE(ao.EndDate, GETUTCDATE())) AS DaysOwned,
        ao.CreatedDate
    FROM dbo.AreaOwnership ao
    LEFT JOIN dbo.AspNetUsers u ON u.Id = ao.AspNetUserId
    LEFT JOIN dbo.AspNetUserProfiles up ON up.AspNetUserId = ao.AspNetUserId
    LEFT JOIN dbo.ViewArea va ON va.AreaId = ao.AreaId
    LEFT JOIN dbo.PolygonNameOverride pno 
        ON pno.PolygonId = ao.AreaId AND pno.AspNetUserId = ao.AspNetUserId
    WHERE (@AspNetUserId IS NULL OR ao.AspNetUserId = @AspNetUserId)
      AND (@AreaId IS NULL OR ao.AreaId = @AreaId)
      AND (@StartDate IS NULL OR ao.CreatedDate >= @StartDate)
      AND (@EndDate IS NULL OR ao.CreatedDate <= @EndDate)
    ORDER BY ao.CreatedDate DESC;
END;
```

#### Procedure: `usp_AreaCampaignHistory_Record`
Records campaign activity after each PropertyCast execution.

```sql
CREATE PROCEDURE dbo.usp_AreaCampaignHistory_Record
    @PropertyCastId INT,
    @PropertyCollectionDetailId INT,
    @AreaId INT,
    @AspNetUserId NVARCHAR(128),
    @PropertyTypeId INT,
    @CampaignDate DATETIME2,
    @MessagesSent INT,
    @MessagesDelivered INT,
    @MessagesFailed INT,
    @Clicks INT = 0,
    @CTASubmitted INT = 0,
    @CTAVerified INT = 0,
    @AgentNotifications INT = 0,
    @OptOuts INT = 0,
    @TwilioCost DECIMAL(10,4) = 0,
    @AgentNotifyCost DECIMAL(10,4) = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @AreaOwnershipId INT;
    
    -- Find matching ownership record (active at campaign date)
    SELECT TOP 1 @AreaOwnershipId = AreaOwnershipId
    FROM dbo.AreaOwnership
    WHERE AspNetUserId = @AspNetUserId
      AND AreaId = @AreaId
      AND PropertyTypeId = @PropertyTypeId
      AND (StartDate IS NULL OR StartDate <= @CampaignDate)
      AND (EndDate IS NULL OR EndDate >= @CampaignDate)
    ORDER BY StartDate DESC;
    
    -- If no exact match, try to find any ownership for this user/area
    IF @AreaOwnershipId IS NULL
    BEGIN
        SELECT TOP 1 @AreaOwnershipId = AreaOwnershipId
        FROM dbo.AreaOwnership
        WHERE AspNetUserId = @AspNetUserId
          AND AreaId = @AreaId
        ORDER BY 
            CASE WHEN Status = 'Active' THEN 0 ELSE 1 END,
            StartDate DESC;
    END
    
    -- If still no match, cannot record (orphaned campaign)
    IF @AreaOwnershipId IS NULL
    BEGIN
        -- Log warning but don't fail
        PRINT 'Warning: No ownership found for campaign ' + 
              CAST(@PropertyCastId AS NVARCHAR(20));
        RETURN;
    END
    
    -- Insert campaign history
    INSERT INTO dbo.AreaCampaignHistory (
        AreaOwnershipId,
        PropertyCastId,
        PropertyCollectionDetailId,
        CampaignDate,
        PropertyTypeId,
        MessagesSent,
        MessagesDelivered,
        MessagesFailed,
        Clicks,
        CTASubmitted,
        CTAVerified,
        AgentNotifications,
        OptOuts,
        TwilioCost,
        AgentNotifyCost
    )
    VALUES (
        @AreaOwnershipId,
        @PropertyCastId,
        @PropertyCollectionDetailId,
        @CampaignDate,
        @PropertyTypeId,
        @MessagesSent,
        @MessagesDelivered,
        @MessagesFailed,
        @Clicks,
        @CTASubmitted,
        @CTAVerified,
        @AgentNotifications,
        @OptOuts,
        @TwilioCost,
        @AgentNotifyCost
    );
    
    SELECT SCOPE_IDENTITY() AS AreaCampaignHistoryId;
END;
```

#### Procedure: `usp_AreaCampaignHistory_GetByOwnership`
Get campaign history for a specific ownership period.

```sql
CREATE PROCEDURE dbo.usp_AreaCampaignHistory_GetByOwnership
    @AreaOwnershipId INT = NULL,
    @AspNetUserId NVARCHAR(128) = NULL,
    @AreaId INT = NULL,
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ach.AreaCampaignHistoryId,
        ach.AreaOwnershipId,
        ao.AspNetUserId,
        u.UserName,
        COALESCE(ap.FirstName + ' ' + ap.LastName, u.UserName) AS CustomerName,
        ao.AreaId,
        COALESCE(pno.FriendlyName, va.Name) AS AreaName,
        ach.PropertyCastId,
        ach.CampaignDate,
        CASE ach.PropertyTypeId
            WHEN 0 THEN 'SFR'
            WHEN 1 THEN 'Condo'
            ELSE 'Unknown'
        END AS PropertyType,
        ach.MessagesSent,
        ach.MessagesDelivered,
        ach.MessagesFailed,
        CASE WHEN ach.MessagesSent > 0 
             THEN CAST(ach.MessagesDelivered AS FLOAT) / ach.MessagesSent * 100 
             ELSE 0 END AS DeliveryRate,
        ach.Clicks,
        CASE WHEN ach.MessagesDelivered > 0 
             THEN CAST(ach.Clicks AS FLOAT) / ach.MessagesDelivered * 100 
             ELSE 0 END AS ClickRate,
        ach.CTASubmitted,
        ach.CTAVerified,
        ach.AgentNotifications,
        ach.OptOuts,
        CASE WHEN ach.MessagesDelivered > 0 
             THEN CAST(ach.OptOuts AS FLOAT) / ach.MessagesDelivered * 100 
             ELSE 0 END AS OptOutRate,
        ach.TwilioCost,
        ach.AgentNotifyCost,
        ach.TotalCost,
        ach.CreatedDate
    FROM dbo.AreaCampaignHistory ach
    INNER JOIN dbo.AreaOwnership ao ON ao.AreaOwnershipId = ach.AreaOwnershipId
    INNER JOIN dbo.AspNetUsers u ON u.Id = ao.AspNetUserId
    LEFT JOIN dbo.AgentProfile ap ON ap.AspNetUserId = ao.AspNetUserId
    LEFT JOIN dbo.ViewArea va ON va.AreaId = ao.AreaId
    LEFT JOIN dbo.PolygonNameOverride pno 
        ON pno.PolygonId = ao.AreaId AND pno.AspNetUserId = ao.AspNetUserId
    WHERE (@AreaOwnershipId IS NULL OR ach.AreaOwnershipId = @AreaOwnershipId)
      AND (@AspNetUserId IS NULL OR ao.AspNetUserId = @AspNetUserId)
      AND (@AreaId IS NULL OR ao.AreaId = @AreaId)
      AND (@StartDate IS NULL OR ach.CampaignDate >= @StartDate)
      AND (@EndDate IS NULL OR ach.CampaignDate <= @EndDate)
    ORDER BY ach.CampaignDate DESC;
END;
```

---

### 1.4 Campaign History Migration Script

Backfill historical campaign data from existing tables.

```sql
-- ============================================
-- Migration: Backfill AreaCampaignHistory
-- Run AFTER AreaOwnership migration completes
-- ============================================

BEGIN TRANSACTION;

-- Backfill from PropertyCast + related tables
INSERT INTO dbo.AreaCampaignHistory (
    AreaOwnershipId,
    PropertyCastId,
    PropertyCollectionDetailId,
    CampaignDate,
    PropertyTypeId,
    MessagesSent,
    MessagesDelivered,
    MessagesFailed,
    Clicks,
    CTASubmitted,
    CTAVerified,
    AgentNotifications,
    OptOuts,
    TwilioCost,
    AgentNotifyCost
)
SELECT 
    ao.AreaOwnershipId,
    pc.PropertyCastId,
    pcd.PropertyCollectionDetailId,
    pc.CreateDate AS CampaignDate,
    ISNULL(pcd.PropertyTypeId, 0) AS PropertyTypeId,
    
    -- Message counts from SmsRecipientSendQueue
    ISNULL(sms.MessagesSent, 0) AS MessagesSent,
    ISNULL(sms.MessagesDelivered, 0) AS MessagesDelivered,
    ISNULL(sms.MessagesFailed, 0) AS MessagesFailed,
    
    -- Engagement from GenieLead
    ISNULL(gl.Clicks, 0) AS Clicks,
    ISNULL(gl.CTASubmitted, 0) AS CTASubmitted,
    ISNULL(gl.CTAVerified, 0) AS CTAVerified,
    0 AS AgentNotifications, -- Will need separate calculation
    
    -- Opt-outs from TwilioMessage or similar
    ISNULL(sms.OptOuts, 0) AS OptOuts,
    
    -- Costs from TwilioMessage
    ISNULL(sms.TwilioCost, 0) AS TwilioCost,
    0 AS AgentNotifyCost -- Will need separate calculation

FROM dbo.PropertyCast pc
INNER JOIN dbo.PropertyCastWorkflowQueue pcwq 
    ON pcwq.PropertyCastId = pc.PropertyCastId
INNER JOIN dbo.PropertyCollectionDetail pcd 
    ON pcd.PropertyCollectionDetailId = pcwq.CollectionId
INNER JOIN dbo.AreaOwnership ao 
    ON ao.AspNetUserId = pcd.AspNetUserId 
    AND ao.AreaId = pcd.AreaId

-- Aggregate SMS metrics
OUTER APPLY (
    SELECT 
        COUNT(*) AS MessagesSent,
        SUM(CASE WHEN srsq.DeliveryStatus = 'delivered' THEN 1 ELSE 0 END) AS MessagesDelivered,
        SUM(CASE WHEN srsq.DeliveryStatus = 'failed' THEN 1 ELSE 0 END) AS MessagesFailed,
        SUM(CASE WHEN srsq.OptOut = 1 THEN 1 ELSE 0 END) AS OptOuts,
        SUM(ISNULL(tm.Price, 0)) AS TwilioCost
    FROM dbo.SmsRecipientSendQueue srsq
    LEFT JOIN dbo.TwilioMessage tm ON tm.SmsSid = srsq.SmsSid
    WHERE srsq.PropertyCastId = pc.PropertyCastId
) sms

-- Aggregate Lead metrics
OUTER APPLY (
    SELECT 
        SUM(CASE WHEN gl.ClickDate IS NOT NULL THEN 1 ELSE 0 END) AS Clicks,
        SUM(CASE WHEN gl.CTASubmitDate IS NOT NULL THEN 1 ELSE 0 END) AS CTASubmitted,
        SUM(CASE WHEN gl.VerifiedDate IS NOT NULL THEN 1 ELSE 0 END) AS CTAVerified
    FROM dbo.GenieLead gl
    WHERE gl.PropertyCastId = pc.PropertyCastId
) gl

WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command (both trigger types) -- Competition Command only
  AND NOT EXISTS (
      SELECT 1 FROM dbo.AreaCampaignHistory ach 
      WHERE ach.PropertyCastId = pc.PropertyCastId
  );

-- Log migration
INSERT INTO dbo.AreaOwnershipHistory (
    AreaOwnershipId, Action, ActionDate, Notes
)
SELECT DISTINCT
    ao.AreaOwnershipId,
    'CampaignHistoryBackfill',
    GETUTCDATE(),
    'Backfilled ' + CAST(COUNT(*) AS NVARCHAR(10)) + ' campaign records'
FROM dbo.AreaCampaignHistory ach
INNER JOIN dbo.AreaOwnership ao ON ao.AreaOwnershipId = ach.AreaOwnershipId
GROUP BY ao.AreaOwnershipId;

COMMIT TRANSACTION;

-- Validation
SELECT 
    'PropertyCast (CC only)' AS Source, 
    COUNT(*) AS RecordCount 
FROM dbo.PropertyCast 
WHERE PropertyCastTypeId = 1  -- FarmCast = Competition Command (both trigger types)
UNION ALL
SELECT 
    'AreaCampaignHistory' AS Source, 
    COUNT(*) AS RecordCount 
FROM dbo.AreaCampaignHistory;
```

---

### 1.5 Iteration 1 Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | New tables created | `AreaOwnership`, `AreaOwnershipHistory`, `AreaCampaignHistory` exist |
| 2 | View created | `vw_AreaCampaignSummary` returns data |
| 3 | Ownership migration completes | Zero errors, count matches `UserOwnedArea` |
| 4 | Historical ownership reconstructed | Ended records exist for orphaned campaigns |
| 5 | Campaign history backfilled | `AreaCampaignHistory` count matches `PropertyCast` (CC only) |
| 6 | Unique constraint enforced | Cannot insert duplicate active ownership |
| 7 | End procedure logs history | `AreaOwnershipHistory` record created |
| 8 | Campaign record procedure works | `usp_AreaCampaignHistory_Record` inserts correctly |
| 9 | Campaign summary view accurate | Totals match manual SUM queries |
| 10 | Rollback tested | Can restore `UserOwnedArea` if needed |

---

# ITERATION 2: Waitlist Foundation
## Target: Week 3-4

### Objective
Add waitlist table and basic queue management.

---

### 2.1 New Tables

#### Table: `AreaWaitlist`
```sql
CREATE TABLE dbo.AreaWaitlist (
    AreaWaitlistId          INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    AreaId                  INT NOT NULL,
    PropertyTypeId          INT NOT NULL DEFAULT 0,
    AreaOwnershipTypeId     INT NOT NULL DEFAULT 1,
    
    -- Queue Position
    QueuePosition           INT NOT NULL,
    
    -- Status & Lifecycle
    Status                  NVARCHAR(20) NOT NULL DEFAULT 'Waiting',
        -- Values: 'Waiting', 'Notified', 'Accepted', 'Expired', 'Canceled'
    
    -- Dates
    RequestDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    NotifiedDate            DATETIME2 NULL,
    ExpirationDate          DATETIME2 NULL,
    ResolvedDate            DATETIME2 NULL,
    
    -- Metadata
    Notes                   NVARCHAR(500) NULL,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_AreaWaitlist_AspNetUsers 
        FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT CK_AreaWaitlist_Status 
        CHECK (Status IN ('Waiting', 'Notified', 'Accepted', 'Expired', 'Canceled'))
);

-- Indexes
CREATE INDEX IX_AreaWaitlist_AspNetUserId ON dbo.AreaWaitlist(AspNetUserId);
CREATE INDEX IX_AreaWaitlist_AreaId ON dbo.AreaWaitlist(AreaId);
CREATE INDEX IX_AreaWaitlist_Status ON dbo.AreaWaitlist(Status);
CREATE INDEX IX_AreaWaitlist_AreaId_Status_Position 
    ON dbo.AreaWaitlist(AreaId, Status, QueuePosition);

-- Unique constraint: One waitlist entry per user per area
CREATE UNIQUE INDEX IX_AreaWaitlist_UniqueWaiting 
    ON dbo.AreaWaitlist(AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId) 
    WHERE Status IN ('Waiting', 'Notified');
```

---

### 2.2 Stored Procedures

#### Procedure: `usp_AreaWaitlist_Add`
```sql
CREATE PROCEDURE dbo.usp_AreaWaitlist_Add
    @AspNetUserId NVARCHAR(128),
    @AreaId INT,
    @PropertyTypeId INT = 0,
    @AreaOwnershipTypeId INT = 1,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if area is available (no active owner)
    IF NOT EXISTS (
        SELECT 1 FROM dbo.AreaOwnership
        WHERE AreaId = @AreaId 
          AND PropertyTypeId = @PropertyTypeId
          AND AreaOwnershipTypeId = @AreaOwnershipTypeId
          AND Status = 'Active'
    )
    BEGIN
        -- Area is available, return message
        SELECT 0 AS WaitlistId, 'Area is available - no waitlist needed' AS Message;
        RETURN;
    END
    
    -- Check if user already on waitlist
    IF EXISTS (
        SELECT 1 FROM dbo.AreaWaitlist
        WHERE AspNetUserId = @AspNetUserId
          AND AreaId = @AreaId
          AND PropertyTypeId = @PropertyTypeId
          AND Status IN ('Waiting', 'Notified')
    )
    BEGIN
        SELECT 0 AS WaitlistId, 'Already on waitlist for this area' AS Message;
        RETURN;
    END
    
    -- Get next queue position
    DECLARE @NextPosition INT;
    SELECT @NextPosition = ISNULL(MAX(QueuePosition), 0) + 1
    FROM dbo.AreaWaitlist
    WHERE AreaId = @AreaId
      AND PropertyTypeId = @PropertyTypeId
      AND AreaOwnershipTypeId = @AreaOwnershipTypeId
      AND Status IN ('Waiting', 'Notified');
    
    -- Insert waitlist entry
    INSERT INTO dbo.AreaWaitlist (
        AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId,
        QueuePosition, Status, RequestDate, Notes
    )
    VALUES (
        @AspNetUserId, @AreaId, @PropertyTypeId, @AreaOwnershipTypeId,
        @NextPosition, 'Waiting', GETUTCDATE(), @Notes
    );
    
    SELECT SCOPE_IDENTITY() AS WaitlistId, 
           @NextPosition AS QueuePosition,
           'Added to waitlist' AS Message;
END;
```

#### Procedure: `usp_AreaWaitlist_NotifyNext`
```sql
CREATE PROCEDURE dbo.usp_AreaWaitlist_NotifyNext
    @AreaId INT,
    @PropertyTypeId INT,
    @AreaOwnershipTypeId INT,
    @ExpirationHours INT = 48
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @WaitlistId INT;
    DECLARE @AspNetUserId NVARCHAR(128);
    
    -- Get first in queue
    SELECT TOP 1 
        @WaitlistId = AreaWaitlistId,
        @AspNetUserId = AspNetUserId
    FROM dbo.AreaWaitlist
    WHERE AreaId = @AreaId
      AND PropertyTypeId = @PropertyTypeId
      AND AreaOwnershipTypeId = @AreaOwnershipTypeId
      AND Status = 'Waiting'
    ORDER BY QueuePosition;
    
    IF @WaitlistId IS NULL
    BEGIN
        SELECT NULL AS WaitlistId, NULL AS AspNetUserId, 
               'No one on waitlist' AS Message;
        RETURN;
    END
    
    -- Update to Notified status
    UPDATE dbo.AreaWaitlist
    SET 
        Status = 'Notified',
        NotifiedDate = GETUTCDATE(),
        ExpirationDate = DATEADD(HOUR, @ExpirationHours, GETUTCDATE())
    WHERE AreaWaitlistId = @WaitlistId;
    
    -- Return info for notification
    SELECT 
        w.AreaWaitlistId,
        w.AspNetUserId,
        u.Email,
        up.FirstName,
        up.LastName,
        w.AreaId,
        COALESCE(pno.FriendlyName, va.Name) AS AreaName,
        w.ExpirationDate,
        'Notified - awaiting response' AS Message
    FROM dbo.AreaWaitlist w
    LEFT JOIN dbo.AspNetUsers u ON u.Id = w.AspNetUserId
    LEFT JOIN dbo.AspNetUserProfiles up ON up.AspNetUserId = w.AspNetUserId
    LEFT JOIN dbo.ViewArea va ON va.AreaId = w.AreaId
    LEFT JOIN dbo.PolygonNameOverride pno 
        ON pno.PolygonId = w.AreaId AND pno.AspNetUserId = w.AspNetUserId
    WHERE w.AreaWaitlistId = @WaitlistId;
END;
```

#### Procedure: `usp_AreaWaitlist_Accept`
```sql
CREATE PROCEDURE dbo.usp_AreaWaitlist_Accept
    @WaitlistId INT,
    @AcceptedByUserId NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @AspNetUserId NVARCHAR(128);
    DECLARE @AreaId INT;
    DECLARE @PropertyTypeId INT;
    DECLARE @AreaOwnershipTypeId INT;
    
    -- Get waitlist details
    SELECT 
        @AspNetUserId = AspNetUserId,
        @AreaId = AreaId,
        @PropertyTypeId = PropertyTypeId,
        @AreaOwnershipTypeId = AreaOwnershipTypeId
    FROM dbo.AreaWaitlist
    WHERE AreaWaitlistId = @WaitlistId
      AND Status = 'Notified';
    
    IF @AspNetUserId IS NULL
    BEGIN
        SELECT 0 AS Success, 'Invalid or expired waitlist entry' AS Message;
        RETURN;
    END
    
    -- Check area still available
    IF EXISTS (
        SELECT 1 FROM dbo.AreaOwnership
        WHERE AreaId = @AreaId 
          AND PropertyTypeId = @PropertyTypeId
          AND Status = 'Active'
    )
    BEGIN
        SELECT 0 AS Success, 'Area no longer available' AS Message;
        RETURN;
    END
    
    BEGIN TRANSACTION;
    
    -- Create ownership
    INSERT INTO dbo.AreaOwnership (
        AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId,
        Status, RequestDate, ApprovalDate, ApprovedByUserId, StartDate
    )
    VALUES (
        @AspNetUserId, @AreaId, @PropertyTypeId, @AreaOwnershipTypeId,
        'Active', GETUTCDATE(), GETUTCDATE(), @AcceptedByUserId, GETUTCDATE()
    );
    
    DECLARE @NewOwnershipId INT = SCOPE_IDENTITY();
    
    -- Log history
    INSERT INTO dbo.AreaOwnershipHistory (
        AreaOwnershipId, Action, NewStatus, ActionByUserId, Notes
    )
    VALUES (
        @NewOwnershipId, 'Created', 'Active', @AcceptedByUserId, 
        'Converted from waitlist #' + CAST(@WaitlistId AS NVARCHAR(10))
    );
    
    -- Update waitlist
    UPDATE dbo.AreaWaitlist
    SET 
        Status = 'Accepted',
        ResolvedDate = GETUTCDATE()
    WHERE AreaWaitlistId = @WaitlistId;
    
    COMMIT TRANSACTION;
    
    SELECT 1 AS Success, @NewOwnershipId AS AreaOwnershipId, 
           'Ownership created from waitlist' AS Message;
END;
```

---

### 2.3 Iteration 2 Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | Can add to waitlist | Insert succeeds |
| 2 | Cannot duplicate waitlist entry | Unique constraint enforced |
| 3 | Queue position auto-increments | Position = N+1 |
| 4 | Notify next updates status | Status = Notified |
| 5 | Accept creates ownership | AreaOwnership record created |
| 6 | Accept updates waitlist | Status = Accepted |
| 7 | Cannot accept expired entry | Returns error |

---

# ITERATION 3: API Endpoints
## Target: Week 5-6

### Objective
Create REST API endpoints for ownership and waitlist management.

---

### 3.1 API Endpoints

#### Ownership Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/ownership` | List user's areas |
| GET | `/api/ownership/{id}` | Get single ownership |
| GET | `/api/ownership/history` | Get ownership history |
| POST | `/api/ownership` | Request new area |
| PUT | `/api/ownership/{id}/cancel` | Cancel ownership |
| PUT | `/api/ownership/{id}/suspend` | Suspend ownership |

#### Waitlist Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/waitlist` | List user's waitlist |
| GET | `/api/waitlist/area/{areaId}` | Get waitlist for area |
| POST | `/api/waitlist` | Join waitlist |
| PUT | `/api/waitlist/{id}/accept` | Accept waitlist offer |
| DELETE | `/api/waitlist/{id}` | Cancel waitlist |

#### Admin Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/ownership` | List all ownership |
| GET | `/api/admin/waitlist` | List all waitlists |
| PUT | `/api/admin/ownership/{id}/approve` | Approve request |
| PUT | `/api/admin/ownership/{id}/transfer` | Transfer ownership |
| POST | `/api/admin/waitlist/notify` | Manual notify |

---

### 3.2 Request/Response Models

```csharp
// Ownership Models
public class AreaOwnershipResponse
{
    public int AreaOwnershipId { get; set; }
    public int AreaId { get; set; }
    public string AreaName { get; set; }
    public string PropertyType { get; set; }
    public string Status { get; set; }
    public string StartDate { get; set; }  // mm-dd-yyyy
    public string EndDate { get; set; }    // mm-dd-yyyy
    public int TotalCampaigns { get; set; }
}

public class AreaOwnershipRequest
{
    public int AreaId { get; set; }
    public int PropertyTypeId { get; set; }
    public string Notes { get; set; }
}

// Waitlist Models
public class WaitlistResponse
{
    public int WaitlistId { get; set; }
    public int AreaId { get; set; }
    public string AreaName { get; set; }
    public int QueuePosition { get; set; }
    public string Status { get; set; }
    public string RequestDate { get; set; }  // mm-dd-yyyy
    public string ExpirationDate { get; set; }
}

public class WaitlistRequest
{
    public int AreaId { get; set; }
    public int PropertyTypeId { get; set; }
}
```

---

# ITERATION 4: Agent Portal UI
## Target: Week 7-8

### Objective
Build agent-facing UI for area management.

---

### 4.1 Components

| Component | Route | Features |
|-----------|-------|----------|
| MyAreasPage | `/areas` | List active, waitlist, history |
| AreaDetailPage | `/areas/{id}` | View/manage single area |
| AreaSearchPage | `/areas/search` | Find available areas |
| WaitlistPage | `/areas/waitlist` | Manage waitlist positions |

### 4.2 UI State Management

```typescript
interface AreaState {
  activeAreas: AreaOwnership[];
  waitlistAreas: WaitlistEntry[];
  historyAreas: AreaOwnership[];
  loading: boolean;
  error: string | null;
}

interface AreaOwnership {
  areaOwnershipId: number;
  areaId: number;
  areaName: string;
  propertyType: string;
  status: 'Active' | 'Pending' | 'Suspended';
  startDate: string;
  totalCampaigns: number;
}

interface WaitlistEntry {
  waitlistId: number;
  areaId: number;
  areaName: string;
  queuePosition: number;
  status: 'Waiting' | 'Notified';
  requestDate: string;
  expirationDate?: string;
}
```

---

# ITERATION 5: Admin Portal UI
## Target: Week 9-10

### Objective
Build admin-facing UI for system management.

---

### 5.1 Admin Components

| Component | Route | Features |
|-----------|-------|----------|
| OwnershipDashboard | `/admin/ownership` | Overview, metrics |
| OwnershipListPage | `/admin/ownership/list` | All ownership records |
| WaitlistDashboard | `/admin/waitlist` | Waitlist management |
| AreaDetailAdmin | `/admin/areas/{id}` | Full area management |
| ReportsPage | `/admin/reports` | Ownership reports |

---

# ITERATION 6: Notifications & Automation
## Target: Week 11-12

### Objective
Automated notifications and background processing.

---

### 6.1 Notification Types

| Trigger | Channel | Template |
|---------|---------|----------|
| Waitlist position available | Email + SMS | "Your area is available!" |
| Waitlist offer expiring | Email | "24 hours remaining" |
| Waitlist offer expired | Email | "Offer expired, moved to next" |
| Ownership approved | Email | "Welcome to your new area" |
| Ownership ending soon | Email | "Renewal reminder" |

### 6.2 Background Jobs

| Job | Schedule | Action |
|-----|----------|--------|
| ExpireWaitlistOffers | Every hour | Set expired offers to Expired |
| NotifyExpiringOffers | Every 6 hours | Send 24hr warning |
| RequeueExpiredOffers | Every hour | Notify next in queue |
| OwnershipRenewalReminder | Daily | Send 30-day renewal notice |

---

## Appendix: Template Usage

This document serves as a template for future Feature Requests. Key sections:

1. **Design Brief** (`*_BRIEF_v1.md`)
   - Executive Summary
   - Current State Analysis
   - Proposed Solution
   - User Stories
   - Open Questions

2. **Development Spec** (`*_DEVSPEC_v1.md`)
   - Iterative phases
   - Schema/table definitions
   - Stored procedures
   - API contracts
   - Acceptance criteria

---

*Document Version: 1.0*
*Created: December 10, 2025*
*Status: DRAFT - Ready for Review*
*Recovered from Cursor History: December 10, 2025*

