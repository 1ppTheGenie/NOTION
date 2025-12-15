# Competition Command Feature Enhancement Roadmap

---

## Executive Summary

| Field | Value |
|-------|-------|
| **Purpose** | Define the complete feature roadmap for Competition Command enhancements including area ownership, lead custody, referrals, and billing integration |
| **Current State** | Discovery 90% complete - Multiple feature specs drafted, schema designs in progress |
| **Key Outputs** | 6 feature request documents, unified schema design, implementation plan |
| **Remaining Work** | Schema approval, implementation phases, testing, deployment |
| **Last Validated** | 12/15/2025 - Feature prioritization confirmed with stakeholder |

---

## Document Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Author** | Cursor AI |

---

## Feature Request Overview

| FR # | Name | Status | Priority | Est. Effort |
|------|------|--------|----------|-------------|
| FR-001 | AreaOwnership Schema | 📝 Schema v5 Complete | **HIGH** | 2 weeks |
| FR-002 | Monthly Cost Reports (KPI) | ✅ **APPROVED** | HIGH | Complete |
| FR-003 | WHMCS Billing Integration | 📋 Discovery | Medium | 2 weeks |
| FR-004 | Shopping Cart Concept | 📋 Concept | Low | 4 weeks |
| FR-005 | Referral & Incentive System | 📋 Discovery | Medium | 3 weeks |
| FR-006 | Lead Custody System | 📝 Spec v1 Complete | **HIGH** | 4 weeks |

---

## Dependency Map

```
                    ┌─────────────────────────────────────────────────┐
                    │            FR-001: AreaOwnership                 │
                    │         (Foundation - Must Do First)             │
                    └─────────────────────┬───────────────────────────┘
                                          │
              ┌───────────────────────────┼───────────────────────────┐
              │                           │                           │
              ▼                           ▼                           ▼
┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
│   FR-006: Lead Custody  │ │   FR-003: WHMCS Billing │ │   FR-005: Referrals     │
│   (Revenue Protection)  │ │   (Payment Integration) │ │   (Growth Engine)       │
└───────────┬─────────────┘ └───────────┬─────────────┘ └───────────┬─────────────┘
            │                           │                           │
            └───────────────────────────┼───────────────────────────┘
                                        │
                                        ▼
                          ┌─────────────────────────────┐
                          │   FR-004: Shopping Cart     │
                          │   (User Experience)         │
                          └─────────────────────────────┘
                                        │
                                        ▼
                          ┌─────────────────────────────┐
                          │   FR-002: KPI Reports       │
                          │   (Already Complete!)       │
                          │   ✅ APPROVED               │
                          └─────────────────────────────┘
```

---

## Implementation Timeline

### Phase 1: Foundation (Weeks 1-3)
**Focus: FR-001 AreaOwnership Schema**

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 1 | Schema review & approval | Signed-off ERD v5 |
| 1 | Create lookup tables | 8 lookup tables populated |
| 2 | Create core tables | AreaOwnership, AreaWaitlist, History |
| 2 | Create stored procedures | Status transitions, waitlist management |
| 3 | Migrate UserOwnedArea data | All existing ownership migrated |
| 3 | Testing & validation | QA sign-off |

### Phase 2: Revenue Protection (Weeks 4-7)
**Focus: FR-006 Lead Custody System**

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 4 | Create Lead Custody tables | LeadCustody, LeadCustodyHistory, LeadTransaction |
| 5 | Migrate 85K existing leads | All leads have custody records |
| 5 | Recover 56K orphaned leads | All orphaned leads in 1PP custody |
| 6 | Build business rules engine | Cancellation triggers, grace periods |
| 7 | Admin UI for lead management | Dashboard, reassignment tools |

### Phase 3: Billing Integration (Weeks 8-10)
**Focus: FR-003 WHMCS Integration**

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 8 | WHMCS API integration | Real-time product status sync |
| 9 | Payment event triggers | Cancellation → Lead custody update |
| 10 | Billing reports | Invoice reconciliation, revenue tracking |

### Phase 4: Growth Features (Weeks 11-14)
**Focus: FR-005 Referrals + FR-004 Shopping Cart**

| Week | Tasks | Deliverables |
|------|-------|--------------|
| 11 | Fix referral tracking gap | Signup captures referrer |
| 12 | Build referral dashboard | Who referred whom, click tracking |
| 13 | Design shopping cart UX | Bundle pricing, quantity discounts |
| 14 | Implement shopping cart | Purchase flow improvements |

---

## Key Discoveries from This Session

### 1. Lead Custody Crisis
- **56,876 leads (66.5%)** are orphaned with no owner
- **6,235 leads** have mismatched ownership
- **$0** transaction/commission tracking exists
- **CRITICAL** revenue protection gap

### 2. Referral System Gap
- Referral links exist (79 users with links, 587 clicks)
- **But:** No tracking of who actually signed up from referrals
- **But:** No conversion tracking
- Feature is "buried" in navigation, not promoted
- Activity dropped from 469 clicks (2023) to 14 clicks (2025)

### 3. Area Ownership Complexity
- Need to track SFR and Condo as **separate purchases**
- Waitlist is a **pre-ownership** state
- Multiple status types needed (Pending, Active, Suspended, Ended)
- History/audit trail essential

### 4. Cost Tracking Working
- FR-002 Monthly Cost Reports are **APPROVED**
- Twilio costs calculated and allocated
- Agent notifications tracked
- Ready for Versium cost integration (Iteration 2)

---

## Database Tables Summary

### New Tables to Create

| Schema Section | Table | Purpose |
|----------------|-------|---------|
| **Ownership** | AreaOwnership | Core ownership records |
| **Ownership** | AreaWaitlist | Queue for interested parties |
| **Ownership** | AreaOwnershipHistory | Audit trail |
| **Ownership** | AreaCampaignHistory | Monthly campaign metrics |
| **Lead Custody** | LeadCustody | Custody status per lead |
| **Lead Custody** | LeadCustodyHistory | Transfer audit trail |
| **Lead Custody** | LeadTransaction | Closed deals & commissions |
| **Lookups** | PropertyType | SFR, Condo |
| **Lookups** | OwnershipType | Purchase, WaitlistConversion, etc. |
| **Lookups** | OwnershipStatusType | Pending, Active, Suspended, Ended |
| **Lookups** | EndReasonType | Cancelled, NonPayment, etc. |
| **Lookups** | ActionType | Created, StatusChanged, etc. |
| **Lookups** | ReferralSourceType | GenieUser, TitleRep, etc. |
| **Lookups** | CustodyStatusType | 1PPCustody, AgentLicensed, etc. |
| **Lookups** | CustodyTransferReason | InitialAssignment, AgentCancelled, etc. |

### Existing Tables to Modify

| Table | Modification |
|-------|--------------|
| GenieLead | Add FK to LeadCustody |
| ViewArea | Reference for AreaId (no changes needed) |
| AspNetUsers | Reference for UserId (no changes needed) |

---

## Files Created This Session

| File | Location | Description |
|------|----------|-------------|
| ERD v5 HTML | `Development/CompetitionCommand/Specs/FR-001_AreaOwnership_Schema_ERD_v5.html` | Visual schema with Lead Custody |
| FR-006 Spec | `Development/LeadCustody/FR-006_LeadCustody_System_v1.md` | Lead Custody feature request |
| This Roadmap | `Development/CompetitionCommand/ROADMAP_CompetitionCommand_Features_v1.md` | Feature roadmap |
| KPI Report Script | `APPROVED/CompetitionCommand_KPI_Reports/Scripts/build_cc_monthly_cost_report_FINAL.py` | Monthly cost report |
| KPI Report SOP | `APPROVED/CompetitionCommand_KPI_Reports/SOPs/SOP_CC_Monthly_Cost_Report_FINAL.md` | Report generation procedure |
| Memory Log | `MemoryLogs/WORKSPACE_MEMORY_LOG_CCReports_Session_2025-12-15.md` | Session learnings |

---

## Next Steps

1. **Immediate:** Review ERD v5 HTML and FR-006 spec
2. **This Week:** Get schema approval before any database changes
3. **Next:** Prioritize FR-001 + FR-006 implementation together
4. **Later:** Address referral gap and shopping cart

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/15/2025 | Cursor AI | Initial document creation |


