# Feature Request: Area Ownership & Waitlist System
## FR-001 | Design & Creative Brief
### Version 1.0 | December 2025

---

## 1. Executive Summary

### The Problem
The current Area Ownership system has critical limitations:
- **Hard Deletes**: When an agent cancels, ownership records are permanently deleted
- **No History**: Cannot track who owned what areas and when
- **No Waitlist**: No way to queue agents for exclusive areas that are taken
- **No Request Workflow**: No formal process for requesting new areas
- **Audit Gap**: Cannot reconcile billing with ownership changes

### The Solution
A redesigned Area Ownership system with:
- Full ownership history (soft deletes with timestamps)
- Waitlist queue for exclusive areas
- Request/approval workflow
- Admin dashboard for management
- Automated notifications

### Business Value
| Benefit | Impact |
|---------|--------|
| Revenue Protection | Know who's waiting = predictable pipeline |
| Customer Experience | Agents can "claim their spot" for desired areas |
| Operational Efficiency | Reduce manual tracking/emails |
| Audit & Compliance | Complete ownership trail for billing |

---

## 2. Current State Analysis

### Existing Schema: `UserOwnedArea`
```
UserOwnedAreaId (PK)
AspNetUserId (FK)
AreaId
PropertyTypeId (0=SFR, 1=Condo, 2=Townhouse, 3=Multi-Family)
AreaOwnershipTypeId (1=FarmCaster/Competition Command)
CreateDate
```

### Current Limitations

| Issue | Current Behavior | Business Impact |
|-------|------------------|-----------------|
| **Hard Delete** | Record deleted on cancel | No history, audit impossible |
| **No EndDate** | Unknown when ownership ended | Can't track churn patterns |
| **No Waitlist** | Manual/email tracking | Lost revenue, poor UX |
| **No Request Flow** | Direct insert by admin | No approval trail |
| **Single Status** | Active only (or deleted) | Can't track pending/suspended |

### Data Lost on Cancel
When an agent cancels an area today, we lose:
- Original purchase date
- Who the agent was
- Why they canceled (no reason tracking)
- Duration of ownership

---

## 3. Proposed Solution Overview

### New Entity: `AreaOwnership` (replaces UserOwnedArea)

```
AreaOwnershipId (PK)
AspNetUserId (FK)
AreaId
PropertyTypeId
AreaOwnershipTypeId
Status (Active, Ended, Suspended, Pending)
RequestDate
ApprovalDate
ApprovedByUserId
StartDate
EndDate
EndReason (Canceled, Expired, Transferred, AdminRemoved)
Notes
CreatedDate
ModifiedDate
ModifiedByUserId
```

### New Entity: `AreaWaitlist`

```
AreaWaitlistId (PK)
AspNetUserId (FK)
AreaId
PropertyTypeId
AreaOwnershipTypeId
QueuePosition
RequestDate
Status (Waiting, Notified, Converted, Expired, Canceled)
NotifiedDate
ExpirationDate
Notes
CreatedDate
```

### New Entity: `AreaOwnershipHistory` (Audit Log)

```
AreaOwnershipHistoryId (PK)
AreaOwnershipId (FK)
Action (Created, Approved, Activated, Suspended, Ended, Modified)
PreviousStatus
NewStatus
ActionByUserId
ActionDate
Notes
```

---

## 4. User Stories

### Agent Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| A1 | Agent | See which areas are available | I can purchase exclusive zones |
| A2 | Agent | Join a waitlist for taken areas | I get notified when available |
| A3 | Agent | See my position in waitlist | I know how long to wait |
| A4 | Agent | Cancel my waitlist position | I can free up my queue slot |
| A5 | Agent | View my ownership history | I can see past areas I owned |
| A6 | Agent | Request a new area | I can expand my territory |

### Admin Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| B1 | Admin | See all area ownership | I can manage the system |
| B2 | Admin | Approve/reject area requests | I control quality |
| B3 | Admin | View waitlist by area | I see demand for each zone |
| B4 | Admin | Transfer ownership between agents | I can handle special cases |
| B5 | Admin | Run ownership history reports | I can audit billing |
| B6 | Admin | Manually add/remove from waitlist | I can handle exceptions |

### System Stories
| ID | As the... | I want to... | So that... |
|----|-----------|--------------|------------|
| C1 | System | Auto-notify waitlist when area opens | Agents respond quickly |
| C2 | System | Auto-expire waitlist offers after X days | Queue keeps moving |
| C3 | System | Log all ownership changes | Audit trail is complete |
| C4 | System | Prevent duplicate ownership | Exclusivity is enforced |

---

## 5. Workflow Diagrams

### Area Request Flow
```
Agent Requests Area
        │
        ▼
┌─────────────────┐
│  Area Available? │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
   YES        NO
    │         │
    ▼         ▼
┌────────┐  ┌────────────┐
│ Approve │  │ Add to     │
│ Request │  │ Waitlist   │
└────┬───┘  └─────┬──────┘
     │            │
     ▼            ▼
┌────────┐  ┌────────────┐
│ Active │  │ Waiting    │
│ Owner  │  │ Position # │
└────────┘  └────────────┘
```

### Area Cancellation Flow
```
Agent Cancels Area
        │
        ▼
┌─────────────────┐
│ Set EndDate     │
│ Status = Ended  │
│ Log History     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Waitlist Exist? │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
   YES        NO
    │         │
    ▼         ▼
┌────────────┐  ┌────────┐
│ Notify #1  │  │ Area   │
│ in Queue   │  │ Open   │
└─────┬──────┘  └────────┘
      │
      ▼
┌────────────────┐
│ 48hr to Accept │
│ or Auto-Expire │
└────────────────┘
```

---

## 6. UI/UX Concepts

### Agent Portal: My Areas

```
┌─────────────────────────────────────────────────────────┐
│  MY AREAS                                    [+ Request] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ACTIVE (3)                                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📍 Moorpark 93021        SFR    Since 10-02-2024│   │
│  │    104 campaigns         [Manage] [Cancel]      │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📍 Thousand Oaks 91360   SFR    Since 10-02-2024│   │
│  │    107 campaigns         [Manage] [Cancel]      │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  WAITLIST (1)                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⏳ Beverly Hills 90210   SFR    Position: #2    │   │
│  │    Requested 11-15-2024         [Cancel]        │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  HISTORY                                    [View All]  │
│  • Ventura 93003 - Ended 09-28-2025 (20 campaigns)     │
│  • Brentwood 90049 - Ended 01-05-2025 (25 campaigns)   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Admin Portal: Area Management

```
┌─────────────────────────────────────────────────────────┐
│  AREA MANAGEMENT                        [Export] [Add]  │
├─────────────────────────────────────────────────────────┤
│  🔍 Search: [____________] [Filter ▼]                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Area          Owner           Status    Waitlist       │
│  ─────────────────────────────────────────────────────  │
│  90210         Gary Gold       Active    3 waiting      │
│  90211         —               Open      1 waiting      │
│  90212         Jason Barry     Active    0 waiting      │
│  93021         Debbie Gates    Active    2 waiting      │
│                                                         │
│  [◀ Prev]  Page 1 of 45  [Next ▶]                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 7. Success Metrics

| Metric | Current | Target | How Measured |
|--------|---------|--------|--------------|
| Ownership history completeness | 0% | 100% | Records with EndDate |
| Waitlist conversion rate | N/A | 40%+ | Waitlist → Active |
| Time to fill open area | Unknown | < 48 hrs | Notification → Acceptance |
| Admin manual interventions | High | -50% | Support tickets |
| Billing audit accuracy | ~80% | 100% | Reconciliation errors |

---

## 8. Open Questions (Discovery Needed)

| # | Question | Options | Decision |
|---|----------|---------|----------|
| 1 | Approval workflow needed? | Auto-approve / Admin review | TBD |
| 2 | Waitlist max per agent? | Unlimited / 3 / 5 / 10 | TBD |
| 3 | Waitlist offer expiration? | 24hr / 48hr / 72hr / 7 days | TBD |
| 4 | Show current owner to waitlist? | Yes / No (privacy) | TBD |
| 5 | Transfer ownership feature? | Yes / No / Phase 2 | TBD |
| 6 | Suspend vs Cancel distinction? | Yes / No | TBD |
| 7 | Waitlist priority pricing? | Same price / Premium / Discount | TBD |
| 8 | Notification channels? | Email / SMS / In-app / All | TBD |

---

## 9. Dependencies & Risks

### Dependencies
| Dependency | Owner | Status |
|------------|-------|--------|
| Database schema changes | DBA | Not Started |
| API updates | Backend | Not Started |
| Agent Portal UI | Frontend | Not Started |
| Admin Portal UI | Frontend | Not Started |
| Notification service | Backend | Exists (extend) |

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Data migration errors | Medium | High | Thorough testing, rollback plan |
| Agent confusion | Medium | Medium | Clear communication, training |
| Performance impact | Low | Medium | Index optimization |
| Waitlist gaming | Low | Low | Position rules, admin override |

---

## 10. Timeline Estimate (Rough)

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 1: Design** | 1-2 weeks | Final spec, schema design, API contracts |
| **Phase 2: Backend** | 2-3 weeks | New tables, stored procs, API endpoints |
| **Phase 3: Migration** | 1 week | Data migration, validation |
| **Phase 4: Frontend** | 2-3 weeks | Agent portal, admin portal |
| **Phase 5: Testing** | 1-2 weeks | QA, UAT, bug fixes |
| **Phase 6: Launch** | 1 week | Deployment, monitoring, support |

**Total Estimate:** 8-12 weeks

---

## 11. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Technical Lead | | | |
| Business Stakeholder | | | |

---

*Document Version: 1.0*
*Created: December 10, 2025*
*Status: DRAFT - Pending Discovery*
*Recovered from Cursor History: December 10, 2025*

