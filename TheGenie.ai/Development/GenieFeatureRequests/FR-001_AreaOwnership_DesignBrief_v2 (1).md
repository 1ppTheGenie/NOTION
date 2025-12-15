# Feature Request: Area Ownership & Waitlist System
## FR-001 | Design & Creative Brief
### Version 2.0 | December 2025

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

### The Solution
A redesigned Area Ownership system with:
- Full ownership history (soft deletes with timestamps)
- Waitlist queue for exclusive areas
- Request/approval workflow
- **WHMCS billing integration (FR-002)**
- **Content configuration options (FR-003)**
- Admin dashboard for management
- Automated notifications

### Business Value
| Benefit | Impact |
|---------|--------|
| Revenue Protection | Know who's waiting = predictable pipeline |
| Customer Experience | Agents can "claim their spot" for desired areas |
| Operational Efficiency | Reduce manual tracking/emails |
| Audit & Compliance | Complete ownership trail for billing |
| **Billing Automation** | Seamless purchase → provisioning flow |
| **Content Personalization** | Per-area CTA and landing page customization |

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

### Source Code References (v2.0 Update)
| Component | Path | Notes |
|-----------|------|-------|
| UserOwnedArea Model | `Smart.Data.SQL/Models/` | Current ownership table |
| WHMCS Integration | `Smart.Core/BLL/Billing/` | Billing handlers |
| Area Name Helper | `Smart.Core/BLL/Helper/PolygonHelper.cs` | `GetUserAreaName()` |
| Proxy Layer | `Smart.Data.SQL/Proxy.cs` | Data access |

### Current Limitations

| Issue | Current Behavior | Business Impact |
|-------|------------------|-----------------|
| **Hard Delete** | Record deleted on cancel | No history, audit impossible |
| **No EndDate** | Unknown when ownership ended | Can't track churn patterns |
| **No Waitlist** | Manual/email tracking | Lost revenue, poor UX |
| **No Request Flow** | Direct insert by admin | No approval trail |
| **Single Status** | Active only (or deleted) | Can't track pending/suspended |
| **No Billing Link** | No connection to WHMCS | Manual reconciliation |

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
CompetitionCommandBillingId (FK → FR-002)  ← NEW v2.0
ContentConfigurationId (FK → FR-003)       ← NEW v2.0
Notes
CreatedDate
ModifiedDate
ModifiedByUserId
```

### Integration with Related Feature Requests

```
┌─────────────────────────────────────────────────────────────┐
│                    FR-001: AREA OWNERSHIP                    │
│                                                             │
│  AreaOwnership table is the central entity linking to:     │
│                                                             │
│  ┌─────────────────┐        ┌─────────────────────────────┐│
│  │   FR-002:       │        │   FR-003:                   ││
│  │   WHMCS Billing │◄──────►│   Content Configurator      ││
│  │   Integration   │        │   (Landing Pages + CTAs)    ││
│  │                 │        │                             ││
│  │ • Pricing       │        │ • Landing page selection    ││
│  │ • Promo codes   │        │ • CTA selection             ││
│  │ • Bundles       │        │ • A/B testing               ││
│  │ • Recurring     │        │ • Performance tracking      ││
│  └─────────────────┘        └─────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Updated User Stories

### Agent Stories (v2.0 Updates)
| ID | As an... | I want to... | So that... | Related FR |
|----|----------|--------------|------------|------------|
| A1 | Agent | See which areas are available | I can purchase exclusive zones | FR-001 |
| A2 | Agent | Join a waitlist for taken areas | I get notified when available | FR-001 |
| A3 | Agent | Purchase with bundle discount | I save on multiple areas | **FR-002** |
| A4 | Agent | Apply promo codes | I get promotional pricing | **FR-002** |
| A5 | Agent | Choose my landing page | Content matches my brand | **FR-003** |
| A6 | Agent | Select CTAs for my campaigns | I control conversions | **FR-003** |
| A7 | Agent | View my ownership history | I see past areas I owned | FR-001 |

### System Stories (v2.0 Updates)
| ID | As the... | I want to... | So that... | Related FR |
|----|-----------|--------------|------------|------------|
| C1 | System | Auto-provision on payment | No manual activation | **FR-002** |
| C2 | System | Cancel billing on area end | Billing stops automatically | **FR-002** |
| C3 | System | Apply default content config | New areas have good CTAs | **FR-003** |
| C4 | System | Track CTA performance per area | We optimize conversions | **FR-003** |

---

## 5. Integration Workflow

### Complete Purchase Flow (FR-001 + FR-002 + FR-003)

```
Agent Selects Area
        │
        ▼
┌─────────────────────┐
│ FR-001: Create      │
│ AreaOwnership       │
│ (Status = Pending)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ FR-002: Calculate   │
│ Price (bundle,      │
│ promo codes)        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ FR-002: WHMCS       │
│ AddOrder + Capture  │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
  SUCCESS     FAILED
     │           │
     ▼           ▼
┌─────────────┐  ┌─────────────┐
│ FR-001:     │  │ Notify User │
│ Activate    │  │ Keep Pending│
│ Ownership   │  └─────────────┘
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ FR-003: Create      │
│ Default Content     │
│ Configuration       │
└──────────┬──────────┘
       │
       ▼
┌─────────────────────┐
│ AREA ACTIVE         │
│ Campaigns can run   │
└─────────────────────┘
```

---

## 6. Success Metrics (Updated)

| Metric | Current | Target | How Measured |
|--------|---------|--------|--------------|
| Ownership history completeness | 0% | 100% | Records with EndDate |
| Waitlist conversion rate | N/A | 40%+ | Waitlist → Active |
| Time to fill open area | Unknown | < 48 hrs | Notification → Acceptance |
| **Bundle adoption** | N/A | 30%+ | Multi-area purchases (FR-002) |
| **Content customization** | 0% | 25%+ | Custom config vs default (FR-003) |
| **CTA conversion improvement** | 3.5% | 5%+ | A/B test results (FR-003) |

---

## 7. Timeline Estimate (Updated with Dependencies)

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

## 8. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Technical Lead | | | |
| Business Stakeholder | | | |

---

*Document Version: 2.0*
*Created: 12/10/2025*
*Updated: 12/13/2025*
*Status: DRAFT - Pending Discovery*

**v2.0 Changes:**
- Added source code references from `Genie.Source.Code_v1`
- Added integration with FR-002 (WHMCS Billing)
- Added integration with FR-003 (Content Configurator)
- Updated user stories with related FRs
- Added complete purchase flow diagram
- Updated success metrics with billing and content goals
- Updated timeline with dependencies

