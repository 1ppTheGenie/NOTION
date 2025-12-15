# Feature Request: Area Ownership & Waitlist System
## FR-001 | Design & Creative Brief
### Version 2.0

**Created:** 12/10/2025  
**Updated:** 12/13/2025  
**Status:** DRAFT - Updated with Source Code Context

---

## 1. Executive Summary

### The Problem
The current Area Ownership system has critical limitations:
- **Hard Deletes**: When an agent cancels, ownership records are permanently deleted
- **No History**: Cannot track who owned what areas and when
- **No Waitlist**: No way to queue agents for exclusive areas that are taken
- **No Request Workflow**: No formal process for requesting new areas
- **Audit Gap**: Cannot reconcile billing with ownership changes
- **No Billing Integration**: Disconnected from WHMCS order processing
- **No Content Control**: Agents cannot customize landing pages or CTAs

### The Solution
A redesigned Area Ownership system with:
- Full ownership history (soft deletes with timestamps)
- Waitlist queue for exclusive areas
- Request/approval workflow
- Admin dashboard for management
- Automated notifications
- **Integration with WHMCS billing (see FR-002)**
- **Integration with Content Configurator (see FR-003)**

### Business Value
| Benefit | Impact |
|---------|--------|
| Revenue Protection | Know who's waiting = predictable pipeline |
| Customer Experience | Agents can "claim their spot" for desired areas |
| Operational Efficiency | Reduce manual tracking/emails |
| Audit & Compliance | Complete ownership trail for billing |
| Billing Automation | Seamless purchase → provisioning flow (FR-002) |
| Content Personalization | Per-area CTA and landing page customization (FR-003) |

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

### Source Code References (v2.0 Addition)
| Component | Path | Purpose |
|-----------|------|---------|
| UserOwnedArea Model | `Smart.Data.SQL/Models/` | Current ownership table |
| WHMCS Billing Handlers | `Smart.Core/BLL/Billing/Workflow/` | Existing billing pattern |
| Area Name Helper | `Smart.Core/BLL/Helper/PolygonHelper.cs` | `GetUserAreaName()` method |
| CTA Configuration | `genie-cloud-1/genie-components/src/utilities/utils.js` | Hardcoded CTA definitions |
| Proxy Layer | `Smart.Data.SQL/Proxy.cs` | Data access layer |

### Current Limitations

| Issue | Current Behavior | Business Impact |
|-------|------------------|-----------------|
| **Hard Delete** | Record deleted on cancel | No history, audit impossible |
| **No EndDate** | Unknown when ownership ended | Can't track churn patterns |
| **No Waitlist** | Manual/email tracking | Lost revenue, poor UX |
| **No Request Flow** | Direct insert by admin | No approval trail |
| **Single Status** | Active only (or deleted) | Can't track pending/suspended |
| **No Billing Link** | No connection to WHMCS | Manual reconciliation |
| **No Content Config** | Hardcoded CTAs in utils.js | No agent customization |

### Data Lost on Cancel
When an agent cancels an area today, we lose:
- Original purchase date
- Who the agent was
- Why they canceled (no reason tracking)
- Duration of ownership
- Campaign history attribution

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
EndReason (Canceled, Expired, Transferred, AdminRemoved, NonPayment)
CompetitionCommandBillingId (FK) ← Links to FR-002
ContentConfigurationId (FK) ← Links to FR-003
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
Action (Created, Approved, Activated, Suspended, Ended, Modified, BillingCreated, BillingFailed)
PreviousStatus
NewStatus
ActionByUserId
ActionDate
Notes
AdditionalData (JSON)
```

---

## 4. Related Feature Requests

### Integration Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FR-001: AREA OWNERSHIP                    │
│                    (This Feature Request)                    │
│                                                             │
│  AreaOwnership is the central entity linking to:           │
│                                                             │
│  ┌─────────────────────┐    ┌─────────────────────────────┐│
│  │      FR-002:        │    │        FR-003:              ││
│  │   WHMCS Billing     │◄──►│   Content Configurator      ││
│  │   Integration       │    │   (Landing Pages + CTAs)    ││
│  │                     │    │                             ││
│  │ • Pricing/Bundles   │    │ • Landing page selection    ││
│  │ • Promo codes       │    │ • CTA selection             ││
│  │ • Auto-provision    │    │ • A/B testing               ││
│  │ • Recurring billing │    │ • Performance tracking      ││
│  └─────────────────────┘    └─────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 5. User Stories

### Agent Stories
| ID | As an... | I want to... | So that... | Related FR |
|----|----------|--------------|------------|------------|
| A1 | Agent | See which areas are available | I can purchase exclusive zones | FR-001 |
| A2 | Agent | Join a waitlist for taken areas | I get notified when available | FR-001 |
| A3 | Agent | See my position in waitlist | I know how long to wait | FR-001 |
| A4 | Agent | Cancel my waitlist position | I can free up my queue slot | FR-001 |
| A5 | Agent | View my ownership history | I can see past areas I owned | FR-001 |
| A6 | Agent | Request a new area | I can expand my territory | FR-001 |
| A7 | Agent | Purchase with bundle discount | I save on multiple areas | FR-002 |
| A8 | Agent | Apply promo codes | I get promotional pricing | FR-002 |
| A9 | Agent | Choose my landing page | Content matches my brand | FR-003 |
| A10 | Agent | Select CTAs for my campaigns | I control conversions | FR-003 |

### Admin Stories
| ID | As an... | I want to... | So that... | Related FR |
|----|----------|--------------|------------|------------|
| B1 | Admin | See all area ownership | I can manage the system | FR-001 |
| B2 | Admin | Approve/reject area requests | I control quality | FR-001 |
| B3 | Admin | View waitlist by area | I see demand for each zone | FR-001 |
| B4 | Admin | Transfer ownership between agents | I can handle special cases | FR-001 |
| B5 | Admin | Run ownership history reports | I can audit billing | FR-001 |
| B6 | Admin | Configure pricing tiers | I can set bundle discounts | FR-002 |
| B7 | Admin | Create promo codes | I can run marketing campaigns | FR-002 |
| B8 | Admin | Create/manage CTAs | I can add new CTA types | FR-003 |

### System Stories
| ID | As the... | I want to... | So that... | Related FR |
|----|-----------|--------------|------------|------------|
| C1 | System | Auto-notify waitlist when area opens | Agents respond quickly | FR-001 |
| C2 | System | Auto-expire waitlist offers after X days | Queue keeps moving | FR-001 |
| C3 | System | Log all ownership changes | Audit trail is complete | FR-001 |
| C4 | System | Prevent duplicate ownership | Exclusivity is enforced | FR-001 |
| C5 | System | Auto-provision on payment | No manual activation | FR-002 |
| C6 | System | Cancel billing on area end | Billing stops automatically | FR-002 |
| C7 | System | Apply default content config | New areas have good CTAs | FR-003 |
| C8 | System | Track CTA performance per area | We optimize conversions | FR-003 |

---

## 6. Workflow Diagrams

### Complete Area Purchase Flow (FR-001 + FR-002 + FR-003)

```
Agent Requests Area
        │
        ▼
┌─────────────────────┐
│  Area Available?    │
└────────┬────────────┘
         │
    ┌────┴────┐
    │         │
   YES        NO
    │         │
    ▼         ▼
┌────────────────┐  ┌────────────────┐
│ FR-001: Create │  │ FR-001: Add to │
│ AreaOwnership  │  │ Waitlist       │
│ Status=Pending │  │ Position=#N    │
└───────┬────────┘  └────────────────┘
        │
        ▼
┌────────────────────┐
│ FR-002: Calculate  │
│ Price (bundle,     │
│ promo codes)       │
└───────┬────────────┘
        │
        ▼
┌────────────────────┐
│ FR-002: WHMCS      │
│ AddOrder + Capture │
└───────┬────────────┘
        │
   ┌────┴────┐
   │         │
SUCCESS    FAILED
   │         │
   ▼         ▼
┌──────────────┐  ┌──────────────┐
│ FR-001:      │  │ Notify User  │
│ Activate     │  │ Keep Pending │
│ Ownership    │  └──────────────┘
└──────┬───────┘
       │
       ▼
┌────────────────────┐
│ FR-003: Create     │
│ Default Content    │
│ Configuration      │
└───────┬────────────┘
        │
        ▼
┌────────────────────┐
│ AREA ACTIVE        │
│ Campaigns can run  │
└────────────────────┘
```

### Area Cancellation Flow

```
Agent Cancels Area
        │
        ▼
┌─────────────────┐
│ FR-001: Set     │
│ EndDate         │
│ Status = Ended  │
│ Log History     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ FR-002: Cancel  │
│ WHMCS Order     │
│ Stop Billing    │
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

## 7. Success Metrics

| Metric | Current | Target | How Measured |
|--------|---------|--------|--------------|
| Ownership history completeness | 0% | 100% | Records with EndDate |
| Waitlist conversion rate | N/A | 40%+ | Waitlist → Active |
| Time to fill open area | Unknown | < 48 hrs | Notification → Acceptance |
| Admin manual interventions | High | -50% | Support tickets |
| Billing audit accuracy | ~80% | 100% | Reconciliation errors |
| Bundle adoption rate | N/A | 30%+ | Multi-area purchases (FR-002) |
| Content customization rate | 0% | 25%+ | Custom config vs default (FR-003) |
| CTA conversion improvement | 3.5% | 5%+ | A/B test results (FR-003) |

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
| 9 | Base price per area? | $49 / $79 / $99 / $149 (FR-002) | TBD |
| 10 | Default CTA for new areas? | Home Value / A/B Test (FR-003) | TBD |

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
| WHMCS.Net library | IT | Exists (need DLL) |
| Genie CLOUD templates | Cloud Team | Exists |

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Data migration errors | Medium | High | Thorough testing, rollback plan |
| Agent confusion | Medium | Medium | Clear communication, training |
| Performance impact | Low | Medium | Index optimization |
| Waitlist gaming | Low | Low | Position rules, admin override |
| WHMCS API changes | Low | High | Version lock, test suite |
| CTA breaking changes | Medium | High | Fallback to hardcoded |

---

## 10. Timeline Estimate

| Phase | Duration | Deliverables | Dependencies |
|-------|----------|--------------|--------------|
| **Phase 1: FR-001 Schema** | 2 weeks | New tables, migration | None |
| **Phase 2: FR-001 Waitlist** | 2 weeks | Queue, notifications | Phase 1 |
| **Phase 3: FR-002 Billing** | 3 weeks | WHMCS integration | Phase 1 |
| **Phase 4: FR-003 Content** | 3 weeks | CTA/Landing config | Phase 1 |
| **Phase 5: Integration** | 2 weeks | Full flow testing | Phases 2-4 |
| **Phase 6: Launch** | 1 week | Deployment, monitoring | Phase 5 |

**Total Estimate:** 13-14 weeks (parallel execution of FR-002 and FR-003)

---

## 11. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Technical Lead | | | |
| Business Stakeholder | | | |

---

**Document Version:** 2.0  
**Created:** 12/10/2025  
**Updated:** 12/13/2025  
**Status:** DRAFT - Updated with Source Code Context

**v2.0 Changes:**
- Added source code references from Genie.Source.Code_v1
- Added integration with FR-002 (WHMCS Billing)
- Added integration with FR-003 (Content Configurator)
- Added CompetitionCommandBillingId and ContentConfigurationId to AreaOwnership schema
- Updated user stories with FR-002/FR-003 references
- Added complete purchase flow diagram showing all 3 FRs
- Updated success metrics with billing and content goals
- Updated timeline with dependencies
- Added new open questions for FR-002/FR-003 decisions

