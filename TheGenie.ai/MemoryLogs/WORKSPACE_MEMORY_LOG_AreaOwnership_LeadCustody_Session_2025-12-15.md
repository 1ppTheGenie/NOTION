# Workspace Memory Log: Area Ownership & Lead Custody Discovery Session

---

## Executive Summary

| Field | Value |
|-------|-------|
| **Purpose** | Document key discoveries, decisions, and learnings from the Competition Command schema design session |
| **Current State** | 100% Complete - Schema approved, ready for implementation |
| **Key Outputs** | ERD v5, FR-006 Lead Custody spec, Feature Roadmap, SQL scripts, Implementation SOP |
| **Remaining Work** | Execute SQL scripts, migrate data, test, deploy |
| **Last Validated** | 12/15/2025 |

---

## Session Information

| Field | Value |
|-------|-------|
| **Date** | 12/15/2025 |
| **Duration** | Extended session (multiple hours) |
| **Focus Areas** | AreaOwnership schema, Lead Custody, Referral system discovery |
| **Outcome** | Schema v5 approved, implementation plan defined |

---

## Critical Discoveries

### 1. Lead Custody Crisis 🚨

| Finding | Value | Impact |
|---------|-------|--------|
| Total leads in system | 85,554 | Baseline |
| **Orphaned leads** (no area owner) | **56,876 (66.5%)** | CRITICAL - Lost revenue |
| Mismatched leads (wrong owner) | 6,235 (7.3%) | Revenue leakage |
| Transaction/commission tracking | **NONE** | No revenue protection |

**Root Cause:** When agents cancel, `UserOwnedArea` records are deleted but `GenieLead.AspNetUserId` still points to the old agent. Leads become orphaned with no mechanism for reassignment or commission tracking.

**Solution:** Lead Custody model where 1PP ALWAYS owns leads, agents only have "license" to work them.

---

### 2. Referral System Gap

| Metric | Value |
|--------|-------|
| Users with referral links | 79 |
| Users actively sharing (1+ clicks) | 44 |
| Total referral clicks tracked | 587 |
| **Conversions tracked** | **0** |

**Root Cause:** The `shortUrlDataId` is passed in the signup URL but NEVER captured when user creates account. Click is logged, conversion is lost.

**Key Finding:** Referral activity dropped from **469 clicks (2023)** to **14 clicks (2025)** - feature is dying because it's buried and not promoted.

**Top Title Rep Referrers:**
- jmarkovich@firstam.com - 75 clicks
- sd15@ltic.com - 35 clicks
- jeff.morey@ltic.com - 15 clicks
- marco.andrade@fnf.com - 7 clicks

---

### 3. Area Ownership Complexity

**Key Decisions Made:**
1. **PropertyType separation:** SFR and Condo are SEPARATE purchases (separate rows in reports)
2. **Waitlist is pre-ownership:** Part of the ownership lifecycle, not separate
3. **SourceWaitlistId link:** When waitlist converts to ownership, link is preserved
4. **All decision fields use lookups:** No free-text for status, type, reason fields

**Status Categories Defined:**
- WAITLIST: Waiting, Notified, Accepted, Expired, Declined, Canceled
- OWNERSHIP: Pending, Active, Suspended
- HISTORICAL: Ended

---

### 4. Existing Tables Examined

| Table | Records | Purpose | Gaps Identified |
|-------|---------|---------|-----------------|
| GenieLead | 85,554 | Lead storage | No custody tracking |
| UserOwnedArea | ~2,000 | Area ownership | No history, no referral |
| ShortUrlData (Type 3) | 79 | Referral links | No conversion link |
| ShortUrlAccessLog | 587 (referral) | Click tracking | Works correctly |
| GenieLeadTag | Many | Lead actions | Works correctly |
| NotificationQueue | Many | Agent notifications | Works correctly |

---

## Schema Decisions

### AreaOwnership Table - Key Fields

| Field | Type | Purpose |
|-------|------|---------|
| AreaOwnershipId | INT PK | Primary key |
| AreaId | INT FK | Link to ViewArea |
| PropertyTypeId | INT FK | SFR (0) or Condo (1) |
| UserId | NVARCHAR FK | Owner agent |
| OwnershipStatusTypeId | INT FK | Current status |
| ReferredByUserId | NVARCHAR FK | Who referred this purchase |
| ReferralSourceTypeId | INT FK | GenieUser, TitleRep, etc. |
| SourceWaitlistId | INT FK | If came from waitlist |
| LeadCustodyEnabled | BIT | Enable lead custody for this ownership |
| DefaultSplitPercentage | DECIMAL | 1PP's cut when leads convert |

### LeadCustody Table - Key Fields

| Field | Type | Purpose |
|-------|------|---------|
| LeadCustodyId | BIGINT PK | Primary key |
| GenieLeadId | BIGINT FK | Link to GenieLead |
| CustodyStatusTypeId | INT FK | 1PPCustody, AgentLicensed, etc. |
| CurrentLicenseeUserId | NVARCHAR FK | Current agent (NULL = 1PP) |
| SourceAreaOwnershipId | INT FK | Link to AreaOwnership |
| SplitPercentage | DECIMAL | 1PP's cut if transaction happens |
| GracePeriodEndDate | DATETIME | When grace period expires |

---

## Business Rules Confirmed

| Rule ID | Rule | Description |
|---------|------|-------------|
| BR-001 | 1PP Always Owns | Leads are 1PP assets, agents have licenses |
| BR-002 | License Follows Payment | Cancel = license expires |
| BR-003 | 30-Day Grace | Agent has 30 days post-cancel to convert |
| BR-004 | Split Survives Transfer | 1PP gets split regardless of current licensee |
| BR-005 | Area Ownership Link | Leads tie to AreaOwnership, not just AreaId |
| BR-006 | Performance Reclaim | Can reclaim from non-performers |
| BR-007 | PropertyType = Separate Order | SFR and Condo are distinct purchases |
| BR-008 | Waitlist = Pre-Ownership | Same status table, different category |

---

## Files Created This Session

| File | Path | Purpose |
|------|------|---------|
| ERD v5 HTML | `Development/CompetitionCommand/Specs/FR-001_AreaOwnership_Schema_ERD_v5.html` | Visual schema diagram |
| FR-006 Spec | `Development/LeadCustody/FR-006_LeadCustody_System_v1.md` | Lead Custody feature request |
| Feature Roadmap | `Development/CompetitionCommand/ROADMAP_CompetitionCommand_Features_v1.md` | Overall feature plan |
| This Memory Log | `MemoryLogs/WORKSPACE_MEMORY_LOG_AreaOwnership_LeadCustody_Session_2025-12-15.md` | Session documentation |
| SQL Scripts | `Development/CompetitionCommand/Scripts/SQL/Schema/` | Implementation scripts |
| Implementation SOP | `Development/CompetitionCommand/SOPs/SOP_AreaOwnership_Implementation_v1.md` | Step-by-step guide |

---

## Database Connection Info

| Resource | Value |
|----------|-------|
| Production Server | 192.168.29.45,1433 |
| Database | FarmGenie |
| User | cursor |
| Password | (stored in scripts) |
| Local Dev DB | FarmGenie_Dev (SQL Express) |

---

## Key Table Counts (Production)

| Table | Count | Notes |
|-------|-------|-------|
| GenieLead | 85,554 | Total leads |
| UserOwnedArea | ~2,000 | Current ownership (to migrate) |
| AspNetUsers | Many | User accounts |
| ViewArea | 2,817 | Unique areas with leads |
| ShortUrlData (Type 3) | 79 | Referral links |

---

## Lessons Learned

1. **Always check for orphaned data** - 66.5% of leads were orphaned without anyone knowing
2. **Referral systems need visibility** - Feature died because it was buried
3. **PropertyType matters** - SFR and Condo are separate business transactions
4. **Custody vs. Assignment** - Critical distinction for revenue protection
5. **Grace periods are important** - Give agents time to convert before reclaiming
6. **Lookup tables for everything** - No free-text fields for decisions

---

## Next Session Priorities

1. Execute SQL scripts to create schema (local dev first)
2. Run data migration for UserOwnedArea → AreaOwnership
3. Create LeadCustody records for all 85K leads
4. Recover 56K orphaned leads
5. Validate data integrity
6. Plan production deployment

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/15/2025 | Cursor AI | Initial document creation |


