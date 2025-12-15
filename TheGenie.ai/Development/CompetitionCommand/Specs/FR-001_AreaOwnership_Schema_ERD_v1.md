# Competition Command Area Ownership - Schema ERD

---

## EXECUTIVE SUMMARY

| **Element** | **Details** |
|-------------|------------|
| **Purpose** | Visual Entity Relationship Diagram for proposed Area Ownership schema. Replaces `UserOwnedArea` with full history tracking, soft deletes, and waitlist functionality. |
| **Current State** | PENDING APPROVAL - No tables created yet. Awaiting sign-off on design. |
| **Key Outputs** | 4 new tables + 1 view to enable ownership lifecycle tracking, campaign history, and waitlist queue. |
| **Remaining Work** | Approve design → Create on local dev → Test → Production deploy |
| **Last Validated** | 12/15/2025 |

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Author** | Cursor AI |
| **Status** | PENDING APPROVAL |

---

## 1. VISUAL SCHEMA DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        COMPETITION COMMAND SCHEMA                                │
│                         (FarmGenie Database)                                     │
└─────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────┐
    │   AspNetUsers       │ (EXISTING)
    │   ═══════════════   │
    │   Id         PK     │◄──────────────────┐
    │   UserName          │                   │
    │   Email             │                   │
    └──────────┬──────────┘                   │
               │                              │
               │ 1:N                          │ 1:N
               │                              │
               ▼                              │
    ┌──────────────────────────────────────┐  │
    │        AreaOwnership (NEW)           │  │
    │   ════════════════════════════════   │  │
    │   AreaOwnershipId      INT PK AI     │  │    ┌───────────────────────┐
    │   AspNetUserId         NVARCHAR(128) │──┘    │   ViewArea (EXISTING) │
    │   AreaId               INT           │◄──────│   ═══════════════════ │
    │   PropertyTypeId       INT           │       │   AreaId       PK     │
    │   AreaOwnershipTypeId  INT           │       │   Name                │
    │   Status               NVARCHAR(20)  │       │   ...                 │
    │   RequestDate          DATETIME2     │       └───────────────────────┘
    │   ApprovalDate         DATETIME2     │
    │   ApprovedByUserId     NVARCHAR(128) │──┐
    │   StartDate            DATETIME2     │  │
    │   EndDate              DATETIME2     │  │ (Self-ref to AspNetUsers)
    │   EndReason            NVARCHAR(50)  │  │
    │   Notes                NVARCHAR(500) │  │
    │   CreatedDate          DATETIME2     │  │
    │   ModifiedDate         DATETIME2     │  │
    │   ModifiedByUserId     NVARCHAR(128) │──┘
    └──────────────────────────────────────┘
               │                    │
               │ 1:N                │ 1:N
               │                    │
               ▼                    ▼
    ┌──────────────────────┐     ┌──────────────────────────────────────────┐
    │ AreaOwnershipHistory │     │        AreaCampaignHistory (NEW)         │
    │       (NEW)          │     │   ════════════════════════════════════   │
    │ ══════════════════   │     │   AreaCampaignHistoryId  INT PK AI       │
    │ AreaOwnershipHist... │     │   AreaOwnershipId        INT FK          │──┐
    │      INT PK AI       │     │   PropertyCastId         INT FK          │  │
    │ AreaOwnershipId      │     │   PropertyCollectionD... INT FK          │  │
    │      INT FK          │     │   CampaignDate           DATETIME2       │  │
    │ Action NVARCHAR(30)  │     │   PropertyTypeId         INT             │  │
    │ PreviousStatus       │     │   MessagesSent           INT             │  │
    │      NVARCHAR(20)    │     │   MessagesDelivered      INT             │  │
    │ NewStatus            │     │   MessagesFailed         INT             │  │
    │      NVARCHAR(20)    │     │   Clicks                 INT             │  │
    │ ActionByUserId       │     │   CTASubmitted           INT             │  │
    │      NVARCHAR(128)   │     │   CTAVerified            INT             │  │
    │ ActionDate DATETIME2 │     │   AgentNotifications     INT             │  │
    │ Notes NVARCHAR(500)  │     │   OptOuts                INT             │  │
    │ AdditionalData       │     │   TwilioCost         DECIMAL(10,4)       │  │
    │      NVARCHAR(MAX)   │     │   AgentNotifyCost    DECIMAL(10,4)       │  │
    └──────────────────────┘     │   TotalCost          AS (Computed)       │  │
                                 │   CreatedDate            DATETIME2       │  │
                                 └──────────────────────────────────────────┘  │
                                              │                                │
                                              │ FK                             │
                                              ▼                                │
                                 ┌───────────────────────────┐                 │
                                 │   PropertyCast (EXISTING) │◄────────────────┘
                                 │   ═══════════════════════ │
                                 │   PropertyCastId     PK   │
                                 │   PropertyCastTypeId      │  (1=CC, 2=LC, 3=NC)
                                 │   AspNetUserId            │
                                 │   AreaId                  │
                                 │   PropertyTypeId          │
                                 │   ...                     │
                                 └───────────────────────────┘


    ┌──────────────────────────────────────┐
    │         AreaWaitlist (NEW)           │
    │   ════════════════════════════════   │
    │   AreaWaitlistId       INT PK AI     │
    │   AspNetUserId         NVARCHAR(128) │──► AspNetUsers
    │   AreaId               INT           │──► ViewArea
    │   PropertyTypeId       INT           │
    │   AreaOwnershipTypeId  INT           │
    │   QueuePosition        INT           │
    │   Status               NVARCHAR(20)  │
    │   RequestDate          DATETIME2     │
    │   NotifiedDate         DATETIME2     │
    │   ExpirationDate       DATETIME2     │
    │   ResolvedDate         DATETIME2     │
    │   Notes                NVARCHAR(500) │
    │   CreatedDate          DATETIME2     │
    └──────────────────────────────────────┘
```

---

## 2. TABLE DEFINITIONS

### 2.1 AreaOwnership (NEW - Replaces UserOwnedArea)

| Column | Type | Null | Default | Key | Description |
|--------|------|------|---------|-----|-------------|
| `AreaOwnershipId` | INT | NO | IDENTITY(1,1) | **PK** | Auto-increment primary key |
| `AspNetUserId` | NVARCHAR(128) | NO | - | **FK** | Owner's user ID |
| `AreaId` | INT | NO | - | **FK** | Zip code / area reference |
| `PropertyTypeId` | INT | NO | 0 | - | 0=SFR, 1=Condo, 2=Townhouse, 3=Multi |
| `AreaOwnershipTypeId` | INT | NO | 1 | - | 1=Competition Command |
| `Status` | NVARCHAR(20) | NO | 'Active' | - | Pending/Active/Suspended/Ended |
| `RequestDate` | DATETIME2 | YES | - | - | When ownership was requested |
| `ApprovalDate` | DATETIME2 | YES | - | - | When approved |
| `ApprovedByUserId` | NVARCHAR(128) | YES | - | **FK** | Who approved |
| `StartDate` | DATETIME2 | YES | - | - | Ownership start |
| `EndDate` | DATETIME2 | YES | - | - | Ownership end (soft delete) |
| `EndReason` | NVARCHAR(50) | YES | - | - | Canceled/Expired/Transferred/AdminRemoved/NonPayment |
| `Notes` | NVARCHAR(500) | YES | - | - | Free-form notes |
| `CreatedDate` | DATETIME2 | NO | GETUTCDATE() | - | Record creation |
| `ModifiedDate` | DATETIME2 | NO | GETUTCDATE() | - | Last modification |
| `ModifiedByUserId` | NVARCHAR(128) | YES | - | **FK** | Who modified |

**Indexes:**
| Index Name | Columns | Type |
|------------|---------|------|
| `PK_AreaOwnership` | AreaOwnershipId | Clustered |
| `IX_AreaOwnership_AspNetUserId` | AspNetUserId | Non-clustered |
| `IX_AreaOwnership_AreaId` | AreaId | Non-clustered |
| `IX_AreaOwnership_Status` | Status | Non-clustered |
| `IX_AreaOwnership_AreaId_Status` | AreaId, Status | Non-clustered |
| `IX_AreaOwnership_UniqueActive` | AreaId, PropertyTypeId, AreaOwnershipTypeId | **Unique** (WHERE Status='Active') |

**Constraints:**
| Constraint | Type | Definition |
|------------|------|------------|
| `FK_AreaOwnership_AspNetUsers` | Foreign Key | AspNetUserId → AspNetUsers(Id) |
| `FK_AreaOwnership_ApprovedBy` | Foreign Key | ApprovedByUserId → AspNetUsers(Id) |
| `CK_AreaOwnership_Status` | Check | Status IN ('Pending','Active','Suspended','Ended') |

---

### 2.2 AreaOwnershipHistory (NEW - Audit Trail)

| Column | Type | Null | Default | Key | Description |
|--------|------|------|---------|-----|-------------|
| `AreaOwnershipHistoryId` | INT | NO | IDENTITY(1,1) | **PK** | Auto-increment |
| `AreaOwnershipId` | INT | NO | - | **FK** | Parent ownership record |
| `Action` | NVARCHAR(30) | NO | - | - | Created/Approved/Activated/Suspended/Resumed/Ended/Modified/Transferred |
| `PreviousStatus` | NVARCHAR(20) | YES | - | - | Status before change |
| `NewStatus` | NVARCHAR(20) | YES | - | - | Status after change |
| `ActionByUserId` | NVARCHAR(128) | YES | - | **FK** | Who made the change |
| `ActionDate` | DATETIME2 | NO | GETUTCDATE() | - | When change occurred |
| `Notes` | NVARCHAR(500) | YES | - | - | Context |
| `AdditionalData` | NVARCHAR(MAX) | YES | - | - | JSON for extra context |

**Indexes:**
| Index Name | Columns | Type |
|------------|---------|------|
| `PK_AreaOwnershipHistory` | AreaOwnershipHistoryId | Clustered |
| `IX_AreaOwnershipHistory_AreaOwnershipId` | AreaOwnershipId | Non-clustered |
| `IX_AreaOwnershipHistory_ActionDate` | ActionDate | Non-clustered |

---

### 2.3 AreaCampaignHistory (NEW - Campaign Metrics)

| Column | Type | Null | Default | Key | Description |
|--------|------|------|---------|-----|-------------|
| `AreaCampaignHistoryId` | INT | NO | IDENTITY(1,1) | **PK** | Auto-increment |
| `AreaOwnershipId` | INT | NO | - | **FK** | Parent ownership |
| `PropertyCastId` | INT | YES | - | **FK** | Campaign execution ref |
| `PropertyCollectionDetailId` | INT | YES | - | **FK** | Campaign definition ref |
| `CampaignDate` | DATETIME2 | NO | - | - | When campaign ran |
| `PropertyTypeId` | INT | NO | 0 | - | SFR/Condo |
| `MessagesSent` | INT | NO | 0 | - | SMS count sent |
| `MessagesDelivered` | INT | NO | 0 | - | SMS delivered |
| `MessagesFailed` | INT | NO | 0 | - | SMS failed |
| `Clicks` | INT | NO | 0 | - | Lead clicks |
| `CTASubmitted` | INT | NO | 0 | - | CTA form submissions |
| `CTAVerified` | INT | NO | 0 | - | Verified contacts |
| `AgentNotifications` | INT | NO | 0 | - | Agent SMS alerts |
| `OptOuts` | INT | NO | 0 | - | Opt-out count |
| `TwilioCost` | DECIMAL(10,4) | NO | 0 | - | Campaign SMS cost |
| `AgentNotifyCost` | DECIMAL(10,4) | NO | 0 | - | Agent notification cost |
| `TotalCost` | DECIMAL(11,4) | - | **COMPUTED** | - | TwilioCost + AgentNotifyCost |
| `CreatedDate` | DATETIME2 | NO | GETUTCDATE() | - | Record creation |

**Indexes:**
| Index Name | Columns | Type |
|------------|---------|------|
| `PK_AreaCampaignHistory` | AreaCampaignHistoryId | Clustered |
| `IX_AreaCampaignHistory_AreaOwnershipId` | AreaOwnershipId | Non-clustered |
| `IX_AreaCampaignHistory_CampaignDate` | CampaignDate | Non-clustered |
| `IX_AreaCampaignHistory_PropertyCastId` | PropertyCastId | Non-clustered |
| `IX_AreaCampaignHistory_Ownership_Date` | AreaOwnershipId, CampaignDate | Non-clustered (composite) |

---

### 2.4 AreaWaitlist (NEW - Queue System)

| Column | Type | Null | Default | Key | Description |
|--------|------|------|---------|-----|-------------|
| `AreaWaitlistId` | INT | NO | IDENTITY(1,1) | **PK** | Auto-increment |
| `AspNetUserId` | NVARCHAR(128) | NO | - | **FK** | Waiting user |
| `AreaId` | INT | NO | - | - | Desired area |
| `PropertyTypeId` | INT | NO | 0 | - | SFR/Condo |
| `AreaOwnershipTypeId` | INT | NO | 1 | - | Product type |
| `QueuePosition` | INT | NO | - | - | Place in line |
| `Status` | NVARCHAR(20) | NO | 'Waiting' | - | Waiting/Notified/Accepted/Expired/Canceled |
| `RequestDate` | DATETIME2 | NO | GETUTCDATE() | - | When joined queue |
| `NotifiedDate` | DATETIME2 | YES | - | - | When notified available |
| `ExpirationDate` | DATETIME2 | YES | - | - | Offer expires |
| `ResolvedDate` | DATETIME2 | YES | - | - | Final resolution |
| `Notes` | NVARCHAR(500) | YES | - | - | Context |
| `CreatedDate` | DATETIME2 | NO | GETUTCDATE() | - | Record creation |

**Indexes:**
| Index Name | Columns | Type |
|------------|---------|------|
| `PK_AreaWaitlist` | AreaWaitlistId | Clustered |
| `IX_AreaWaitlist_AspNetUserId` | AspNetUserId | Non-clustered |
| `IX_AreaWaitlist_AreaId` | AreaId | Non-clustered |
| `IX_AreaWaitlist_Status` | Status | Non-clustered |
| `IX_AreaWaitlist_AreaId_Status_Position` | AreaId, Status, QueuePosition | Non-clustered (composite) |
| `IX_AreaWaitlist_UniqueWaiting` | AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId | **Unique** (WHERE Status IN ('Waiting','Notified')) |

**Constraints:**
| Constraint | Type | Definition |
|------------|------|------------|
| `FK_AreaWaitlist_AspNetUsers` | Foreign Key | AspNetUserId → AspNetUsers(Id) |
| `CK_AreaWaitlist_Status` | Check | Status IN ('Waiting','Notified','Accepted','Expired','Canceled') |

---

## 3. RELATIONSHIP DIAGRAM (SIMPLIFIED)

```
                    ┌───────────────────┐
                    │   AspNetUsers     │
                    │   (EXISTING)      │
                    └────────┬──────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────┐  ┌───────────────┐  ┌───────────────────┐
│  AreaOwnership  │  │  AreaWaitlist │  │ AreaOwnership     │
│  (owner link)   │  │  (queue for   │  │ History           │
│                 │  │   area)       │  │ (audit trail)     │
└────────┬────────┘  └───────────────┘  └───────────────────┘
         │
         │
         ▼
┌─────────────────────┐
│ AreaCampaignHistory │
│ (campaign metrics   │
│  per ownership)     │
└─────────┬───────────┘
          │
          ▼
┌───────────────────┐
│   PropertyCast    │
│   (EXISTING)      │
└───────────────────┘
```

---

## 4. KEY DESIGN DECISIONS

### 4.1 Soft Deletes vs Hard Deletes

| Current (`UserOwnedArea`) | Proposed (`AreaOwnership`) |
|---------------------------|----------------------------|
| Record deleted on cancel | `Status` set to 'Ended', `EndDate` populated |
| No history | Full audit trail in `AreaOwnershipHistory` |
| Cannot track churn | Can analyze ownership patterns |

### 4.2 Unique Active Constraint

**Purpose**: Ensure only ONE active owner per Area + PropertyType + OwnershipType

```sql
CREATE UNIQUE INDEX IX_AreaOwnership_UniqueActive 
    ON dbo.AreaOwnership(AreaId, PropertyTypeId, AreaOwnershipTypeId) 
    WHERE Status = 'Active';
```

**Why Filtered Unique Index?**
- Allows multiple 'Ended' records for same area (history)
- Prevents duplicate 'Active' owners
- SQL Server feature (not available in all RDBMS)

### 4.3 PropertyTypeId Handling

**CRITICAL**: Per our session learnings, SFR (0) and Condo (1) are **separate orders**.

The unique constraint respects this:
- User A can own Zip 34786 for SFR
- User B can own Zip 34786 for Condo
- Both are valid, separate ownerships

### 4.4 Computed Column for TotalCost

```sql
TotalCost AS (TwilioCost + AgentNotifyCost) PERSISTED
```

**Why PERSISTED?**
- Calculated once on insert/update
- Stored physically (not recalculated on read)
- Indexable if needed

---

## 5. COMPARISON: OLD vs NEW

| Feature | UserOwnedArea (Current) | AreaOwnership (Proposed) |
|---------|------------------------|--------------------------|
| Soft Delete | ❌ No | ✅ Yes (Status + EndDate) |
| History | ❌ None | ✅ Full (AreaOwnershipHistory) |
| Campaign Tracking | ❌ None | ✅ Full (AreaCampaignHistory) |
| Waitlist | ❌ None | ✅ Yes (AreaWaitlist) |
| Status Lifecycle | ❌ Binary (exists/deleted) | ✅ Pending→Active→Suspended→Ended |
| Approval Workflow | ❌ None | ✅ RequestDate, ApprovalDate, ApprovedBy |
| End Reason | ❌ Lost on delete | ✅ Stored (Canceled, NonPayment, etc.) |
| Audit Trail | ❌ None | ✅ Every change logged |
| Cost Tracking | ❌ None | ✅ Per campaign (Twilio + Agent Notify) |

---

## 6. QUESTIONS FOR REVIEW

Before creating these tables, please confirm:

1. **Data Types**: Are INT keys sufficient, or should any be BIGINT?
2. **EndReason Values**: The proposed values are Canceled/Expired/Transferred/AdminRemoved/NonPayment. Any additions?
3. **AreaOwnershipTypeId**: Currently 1=Competition Command. Are there other types planned?
4. **Waitlist Expiration**: Default is 48 hours. Is this correct?
5. **Campaign History**: Should we track by individual campaign or aggregate by day?
6. **Additional Fields**: Any fields missing for billing integration (WHMCS)?

---

## 7. NEXT STEPS (Upon Approval)

1. ✅ **You Approve** this schema design
2. **Create tables on FarmGenie_Dev** (local)
3. **Run test data scenarios**
4. **Create stored procedures**
5. **Migrate existing UserOwnedArea data**
6. **Validate with reports**
7. **Production deployment plan**

---

## CHANGE LOG

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/15/2025 | Initial ERD document created for approval |

---

*End of ERD Document*

