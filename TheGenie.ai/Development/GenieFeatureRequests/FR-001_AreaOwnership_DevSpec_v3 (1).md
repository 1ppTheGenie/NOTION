# Feature Request: Area Ownership & Waitlist System
## FR-001 | Development Specification
### Version 3.0 | December 2025

---

## Document Purpose
This specification provides iterative development details for implementing the Area Ownership & Waitlist system. Each iteration is designed to be independently deployable and testable.

**v3.0 Updates:**
- Added source code references from `Genie.Source.Code_v1`
- Added WHMCS integration hooks (links to FR-002)
- Added Content Configuration hooks (links to FR-003)
- Updated stored procedures with WHMCS billing context
- Added API endpoint patterns from existing handlers

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
    
    -- WHMCS Billing Link (FR-002)
    CompetitionCommandBillingId INT NULL,
    
    -- Content Configuration Link (FR-003)
    ContentConfigurationId  INT NULL,
    
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
        --         'Resumed', 'Ended', 'Modified', 'Transferred',
        --         'BillingCreated', 'BillingFailed', 'BillingCanceled'
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
    
    -- Campaign Reference (links to existing tables)
    PropertyCastId          INT NULL,           -- Link to PropertyCast execution
    PropertyCollectionDetailId INT NULL,        -- Link to campaign definition
    
    -- Campaign Details
    CampaignDate            DATETIME2 NOT NULL,
    PropertyTypeId          INT NOT NULL DEFAULT 0,
    
    -- Message Metrics (from ViewSmsQueueSendSummary)
    MessagesSent            INT NOT NULL DEFAULT 0,
    MessagesDelivered       INT NOT NULL DEFAULT 0,
    MessagesFailed          INT NOT NULL DEFAULT 0,
    
    -- Engagement Metrics (from GenieLead + ShortUrlData)
    Clicks                  INT NOT NULL DEFAULT 0, -- COUNT(DISTINCT GenieLeadId)
    CTASubmitted            INT NOT NULL DEFAULT 0, -- LeadTagTypeId = 48
    CTAVerified             INT NOT NULL DEFAULT 0, -- LeadTagTypeId = 52
    AgentNotifications      INT NOT NULL DEFAULT 0,
    
    -- Opt-Out Tracking (LeadTagTypeId = 51)
    OptOuts                 INT NOT NULL DEFAULT 0,
    
    -- Cost Tracking (from TwilioMessage + Invoice Allocation)
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

---

### 1.2 Source Code Integration Points

Based on analysis of `Genie.Source.Code_v1`:

#### Existing Tables Referenced
| Table | Location | Relationship |
|-------|----------|--------------|
| `UserOwnedArea` | `Smart.Data.SQL` | **Replaced by AreaOwnership** |
| `PropertyCast` | `Smart.Data.SQL` | Campaign execution |
| `PropertyCollectionDetail` | `Smart.Data.SQL` | Campaign definition |
| `PropertyCastWorkflowQueue` | `Smart.Data.SQL` | Workflow tracking |
| `AspNetUsers` | `Smart.Data.SQL` | User identity |
| `AspNetUserProfiles` | `Smart.Data.SQL` | User details |
| `ViewArea` | `Smart.Data.SQL` | Area names (fallback) |
| `PolygonNameOverride` | `Smart.Data.SQL` | Custom area names |

#### Existing Handlers to Modify
| Handler | Path | Changes Needed |
|---------|------|----------------|
| `ListingCommandBillingHandler.cs` | `Smart.Core/BLL/ListingCommand/Billing/` | **Pattern for FR-002** |
| `HandlerNCBilling.cs` | `Smart.Core/BLL/Billing/Workflow/` | **Template for area billing** |
| `PropertyCasterWorkflowHandler.cs` | `Smart.Service.PropertyCasterWorkflow/` | Add ownership validation |
| `FarmCasterHandler.cs` | `Smart.Service.PropertyCasterWorkflow/` | Link to AreaOwnership |

#### Key Method References
From `HandlerNCBilling.cs` (model for area-based billing):
```csharp
// Get WHMCS client ID
var whmcsClientId = Proxy.GetUserWhmcs(command.AspNetUserId)?.WhmcsClientId;

// Get area name for description
var areaName = PolygonHelper.GetUserAreaName(command.AspNetUserId, command.AreaId.Value);

// Add order to WHMCS
var addOrderResponse = AddOrder(areaName?.DisplayName, billing, whmcsClientId, channels);

// Check for promo code
CheckForPromoCode(billing, role);
```

---

### 1.3 Data Migration Script

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
WHERE pc.PropertyCastTypeId = 1  -- Competition Command (FarmCast)
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

### 1.4 Stored Procedures

#### Procedure: `usp_AreaOwnership_Create`
```sql
CREATE PROCEDURE dbo.usp_AreaOwnership_Create
    @AspNetUserId NVARCHAR(128),
    @AreaId INT,
    @PropertyTypeId INT = 0,
    @AreaOwnershipTypeId INT = 1,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if area is already owned
    IF EXISTS (
        SELECT 1 FROM dbo.AreaOwnership
        WHERE AreaId = @AreaId 
          AND PropertyTypeId = @PropertyTypeId
          AND AreaOwnershipTypeId = @AreaOwnershipTypeId
          AND Status = 'Active'
    )
    BEGIN
        SELECT 0 AS AreaOwnershipId, 'Area is already owned' AS Message, 'Waitlist' AS Action;
        RETURN;
    END
    
    -- Create ownership record (Pending until payment)
    INSERT INTO dbo.AreaOwnership (
        AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId,
        Status, RequestDate, Notes
    )
    VALUES (
        @AspNetUserId, @AreaId, @PropertyTypeId, @AreaOwnershipTypeId,
        'Pending', GETUTCDATE(), @Notes
    );
    
    DECLARE @OwnershipId INT = SCOPE_IDENTITY();
    
    -- Log history
    INSERT INTO dbo.AreaOwnershipHistory (
        AreaOwnershipId, Action, NewStatus, ActionByUserId, Notes
    )
    VALUES (
        @OwnershipId, 'Created', 'Pending', @AspNetUserId, 
        'Ownership request created, pending billing'
    );
    
    SELECT @OwnershipId AS AreaOwnershipId, 'Created' AS Message, 'Billing' AS Action;
END;
```

#### Procedure: `usp_AreaOwnership_Activate`
Called after successful WHMCS billing (FR-002 integration).

```sql
CREATE PROCEDURE dbo.usp_AreaOwnership_Activate
    @AreaOwnershipId INT,
    @CompetitionCommandBillingId INT,
    @ApprovedByUserId NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @PreviousStatus NVARCHAR(20);
    
    SELECT @PreviousStatus = Status 
    FROM dbo.AreaOwnership 
    WHERE AreaOwnershipId = @AreaOwnershipId;
    
    UPDATE dbo.AreaOwnership
    SET 
        Status = 'Active',
        ApprovalDate = GETUTCDATE(),
        ApprovedByUserId = @ApprovedByUserId,
        StartDate = GETUTCDATE(),
        CompetitionCommandBillingId = @CompetitionCommandBillingId,
        ModifiedDate = GETUTCDATE()
    WHERE AreaOwnershipId = @AreaOwnershipId;
    
    -- Log history
    INSERT INTO dbo.AreaOwnershipHistory (
        AreaOwnershipId, Action, PreviousStatus, NewStatus,
        ActionByUserId, Notes, AdditionalData
    )
    VALUES (
        @AreaOwnershipId, 'Activated', @PreviousStatus, 'Active',
        @ApprovedByUserId, 'Payment successful, area activated',
        JSON_QUERY('{"billingId": ' + CAST(@CompetitionCommandBillingId AS NVARCHAR(20)) + '}')
    );
END;
```

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
    DECLARE @AreaId INT;
    DECLARE @PropertyTypeId INT;
    DECLARE @AreaOwnershipTypeId INT;
    
    -- Get current info
    SELECT 
        @PreviousStatus = Status,
        @AreaId = AreaId,
        @PropertyTypeId = PropertyTypeId,
        @AreaOwnershipTypeId = AreaOwnershipTypeId
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
    
    -- Return area info for waitlist processing
    SELECT 
        @AreaId AS AreaId, 
        @PropertyTypeId AS PropertyTypeId, 
        @AreaOwnershipTypeId AS AreaOwnershipTypeId;
END;
```

---

### 1.5 Iteration 1 Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | New tables created | `AreaOwnership`, `AreaOwnershipHistory`, `AreaCampaignHistory` exist |
| 2 | Ownership migration completes | Zero errors, count matches `UserOwnedArea` |
| 3 | Historical ownership reconstructed | Ended records exist for orphaned campaigns |
| 4 | Unique constraint enforced | Cannot insert duplicate active ownership |
| 5 | Create procedure works | Returns OwnershipId |
| 6 | Activate procedure links billing | BillingId stored |
| 7 | End procedure logs history | AreaOwnershipHistory record created |

---

# ITERATION 2: Waitlist Foundation
## Target: Week 3-4

*(Content unchanged from v2 - see original document)*

---

# ITERATION 3: WHMCS Billing Integration
## Target: Week 5-6

### Objective
Connect AreaOwnership to CompetitionCommandBilling (FR-002).

### 3.1 Integration Flow

```
Agent Requests Area
        │
        ▼
┌─────────────────────┐
│ usp_AreaOwnership   │
│ _Create             │
│ (Status = Pending)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ FR-002: Calculate   │
│ Billing (price,     │
│ bundle, promo)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ FR-002: Create      │
│ WHMCS Order         │
│ (AddOrder API)      │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
  SUCCESS     FAILED
     │           │
     ▼           ▼
┌─────────────┐  ┌─────────────┐
│ usp_Area    │  │ Log failure │
│ Ownership   │  │ Keep Pending│
│ _Activate   │  └─────────────┘
└─────────────┘
```

### 3.2 Handler Integration

```csharp
// In CompetitionCommandBillingHandler (FR-002)
private void ActivateOwnership(int areaOwnershipId, int billingId, string userId)
{
    // Call stored procedure
    Proxy.ActivateAreaOwnership(areaOwnershipId, billingId, userId);
    
    // Log to history
    Proxy.InsertAreaOwnershipHistory(
        areaOwnershipId,
        "BillingCreated",
        "Pending",
        "Active",
        userId,
        $"WHMCS billing created, BillingId: {billingId}");
}
```

---

# ITERATION 4: Content Configuration Integration
## Target: Week 7

### Objective
Connect AreaOwnership to ContentConfiguration (FR-003).

### 4.1 Default Configuration on Activation

```sql
CREATE PROCEDURE dbo.usp_AreaOwnership_CreateDefaultContent
    @AreaOwnershipId INT,
    @AspNetUserId NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if user already has a default config
    IF NOT EXISTS (
        SELECT 1 FROM dbo.ContentConfiguration
        WHERE AspNetUserId = @AspNetUserId
          AND AreaOwnershipId IS NULL
    )
    BEGIN
        -- Create default configuration
        INSERT INTO dbo.ContentConfiguration (
            AspNetUserId, AreaOwnershipId, CTAStrategy
        )
        VALUES (
            @AspNetUserId, NULL, 'Default'
        );
    END
    
    -- Link to ownership
    DECLARE @ConfigId INT;
    SELECT @ConfigId = ContentConfigurationId
    FROM dbo.ContentConfiguration
    WHERE AspNetUserId = @AspNetUserId
      AND AreaOwnershipId IS NULL;
    
    UPDATE dbo.AreaOwnership
    SET ContentConfigurationId = @ConfigId
    WHERE AreaOwnershipId = @AreaOwnershipId;
END;
```

---

# ITERATION 5: API Endpoints
## Target: Week 8

### 5.1 API Endpoints (Based on existing patterns)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/ownership` | List user's areas |
| GET | `/api/ownership/{id}` | Get single ownership |
| GET | `/api/ownership/history` | Get ownership history |
| POST | `/api/ownership` | Request new area (creates Pending, triggers FR-002) |
| PUT | `/api/ownership/{id}/cancel` | Cancel ownership (triggers FR-002 cancel) |
| GET | `/api/ownership/{id}/campaigns` | Get campaign history |

### 5.2 Controller Pattern (from existing codebase)

```csharp
[Route("api/ownership")]
[Authorize]
public class AreaOwnershipController : SmartControllerBase
{
    [HttpPost]
    public async Task<IActionResult> RequestArea([FromBody] AreaOwnershipRequest request)
    {
        var userId = GetUserId();
        
        // Step 1: Create ownership (Pending)
        var ownership = await _ownershipService.CreateAsync(
            userId, 
            request.AreaId, 
            request.PropertyTypeId);
        
        if (ownership.Action == "Waitlist")
        {
            return Ok(new { 
                success = false, 
                action = "waitlist",
                message = ownership.Message 
            });
        }
        
        // Step 2: Trigger billing (FR-002)
        var billingResult = await _billingHandler.ProcessAreaPurchase(
            userId,
            ownership.AreaOwnershipId,
            GetUserRole());
        
        if (!billingResult.Success)
        {
            return BadRequest(new { 
                success = false, 
                message = billingResult.ResponseDescription 
            });
        }
        
        return Ok(new { 
            success = true, 
            areaOwnershipId = ownership.AreaOwnershipId,
            whmcsOrderId = billingResult.Key
        });
    }
}
```

---

## Appendix: Cross-Reference to Related FRs

| Feature Request | Relationship |
|-----------------|--------------|
| **FR-002: WHMCS Billing** | AreaOwnership.CompetitionCommandBillingId links to billing |
| **FR-003: Content Configurator** | AreaOwnership.ContentConfigurationId links to content |

---

*Document Version: 3.0*
*Created: 12/10/2025*
*Updated: 12/13/2025*
*Status: DRAFT - Ready for Review*

**v3.0 Changes:**
- Added source code integration points from `Genie.Source.Code_v1`
- Added WHMCS billing link column (`CompetitionCommandBillingId`)
- Added Content Configuration link column (`ContentConfigurationId`)
- Added `usp_AreaOwnership_Activate` with billing integration
- Added Iteration 3: WHMCS Billing Integration
- Added Iteration 4: Content Configuration Integration
- Added API endpoint patterns based on existing controllers
- Added cross-reference to FR-002 and FR-003

