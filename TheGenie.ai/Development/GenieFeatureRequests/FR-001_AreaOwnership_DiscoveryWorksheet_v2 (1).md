# Feature Request Discovery Worksheet
## FR-001: Area Ownership & Waitlist System
### Version 2.0 | December 2025

---

**Meeting Date:** ____________________

**Attendees:** ____________________

**Facilitator:** ____________________

---

## Purpose
This worksheet captures key decisions needed before development begins on the Area Ownership & Waitlist system upgrade. Please discuss each question and document the decision.

**v2.0 Updates:**
- Added integration questions for FR-002 (WHMCS Billing)
- Added integration questions for FR-003 (Content Configurator)
- Added source code migration considerations

---

# SECTION A: Current State

### A1. Current Process
**How do you currently track area ownership requests and waitlists?**

☐ Spreadsheet  
☐ Email threads  
☐ CRM notes  
☐ Not tracked  
☐ Other: ____________________

**Notes:**
```
_________________________________________________________________
```

---

### A2. UserOwnedArea Migration
**The current `UserOwnedArea` table will be replaced with `AreaOwnership`. Migration approach:**

☐ Big bang (replace immediately)  
☐ Parallel run (both tables active temporarily)  
☐ Gradual (migrate by user segment)

**Are there any known data quality issues in UserOwnedArea?**
```
_________________________________________________________________
```

---

# SECTION B: Business Rules

### B1. Exclusivity
**Can multiple agents own the same zip code area?**

☐ No - Strictly exclusive (one agent per zip)  
☐ Yes - Multiple agents allowed  
☐ Depends on property type (separate SFR vs Condo)  
☐ Other: ____________________

---

### B2. Approval Workflow
**Who approves new area ownership requests?**

☐ Auto-approve (immediate after payment)  
☐ Admin review required  
☐ Payment-triggered (FR-002)  
☐ Other: ____________________

---

### B3. Cancellation Policy
**When an agent cancels, how quickly should the area become available?**

☐ Immediately  
☐ End of billing period (FR-002)  
☐ 30-day grace period  
☐ Other: ____________________

---

# SECTION C: Waitlist Rules

### C1. Waitlist Priority
**How should waitlist priority be determined?**

☐ First-come, first-served (queue order)  
☐ Highest bidder / premium pricing (FR-002)  
☐ Existing customer priority  
☐ Admin discretion  
☐ Other: ____________________

---

### C2. Offer Window
**How long should a waitlisted agent have to accept an available area?**

☐ 24 hours  
☐ 48 hours  
☐ 72 hours  
☐ Other: ________

---

# SECTION D: WHMCS Integration (FR-002)

### D1. Billing Trigger
**When should WHMCS order be created?**

☐ On area request (immediate)  
☐ After admin approval  
☐ Agent-initiated checkout  
☐ Other: ____________________

---

### D2. Bundle Discount Thresholds
**Confirm or adjust bundle discount tiers:**

| Tier | Area Count | Discount | Approved? |
|------|------------|----------|-----------|
| Single | 1 | 0% | ☐ |
| Starter | 2-3 | 10% | ☐ |
| Pro | 4-6 | 15% | ☐ |
| Enterprise | 7+ | 25% | ☐ |

---

### D3. WHMCS Product Configuration
**Has the WHMCS product been created for Competition Command?**

☐ Yes - Product ID: ________  
☐ No - Needs creation  
☐ Unknown

---

# SECTION E: Content Configuration (FR-003)

### E1. Default Content for New Areas
**What default CTAs should new area owners get?**

☐ Home Value Estimate (current default)  
☐ A/B Test group (Home Value v1 vs v2)  
☐ Agent can choose during purchase  
☐ Admin assigns per property type  
☐ Other: ____________________

---

### E2. Content Configuration Access
**Who can modify content configuration for an area?**

☐ Agent only  
☐ Admin only  
☐ Both agent and admin  

---

### E3. Landing Page Selection
**Should agents be able to choose their landing page template?**

☐ Yes - Self-service  
☐ Yes - But admin must approve  
☐ No - System assigns based on campaign type  

---

# SECTION F: Source Code Integration

### F1. Existing Handler Pattern
**Should the new billing handler follow the existing pattern from:**

☐ `ListingCommandBillingHandler` (per-transaction)  
☐ `HandlerNCBilling` (area-based, recurring)  
☐ New pattern

---

### F2. WHMCS.Net Library
**Status of WHMCS.Net NuGet package/DLL:**

☐ Available in solution  
☐ Need to add from production  
☐ Need to request from IT  

---

### F3. Database Migration Timeline
**Preferred migration approach:**

☐ Scheduled maintenance window  
☐ Rolling migration (no downtime)  
☐ Feature flag (gradual rollout)

---

# SECTION G: Timeline & Priority

### G1. Priority Features
**Rank these features by priority (1=Highest):**

| Feature | Priority |
|---------|----------|
| Soft deletes (keep history) | _____ |
| Waitlist queue | _____ |
| WHMCS billing integration (FR-002) | _____ |
| Content configuration (FR-003) | _____ |
| Admin dashboard | _____ |
| Agent self-service portal | _____ |

---

### G2. Phase 1 Scope
**What should be included in Phase 1 (MVP)?**

☐ AreaOwnership + History tables only  
☐ + Waitlist  
☐ + WHMCS Integration (FR-002)  
☐ + Content Config (FR-003)  
☐ All features

---

# Summary of Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Exclusivity model | | |
| Approval workflow | | |
| Billing trigger | | |
| Bundle discounts | | |
| Default CTA | | |
| Phase 1 scope | | |

---

## Next Steps

| Action Item | Owner | Due Date |
|-------------|-------|----------|
| Finalize discovery | | |
| Create WHMCS product | | |
| Get WHMCS.Net DLL | | |
| Begin database schema | | |

---

**Document Prepared By:** AI Assistant  
**Date:** 12/13/2025  
**Feature Request:** FR-001  
**Version:** 2.0

---

*Please return completed worksheet to development team for specification finalization.*

