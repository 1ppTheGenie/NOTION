# Feature Request Discovery Worksheet
## FR-001: Area Ownership & Waitlist System
### Version 2.0

**Created:** 12/10/2025  
**Updated:** 12/13/2025  
**Status:** Updated with FR-002/FR-003 Integration Questions

---

**Meeting Date:** ____________________

**Attendees:** ____________________

**Facilitator:** ____________________

---

## Purpose
This worksheet captures key decisions needed before development begins on the Area Ownership & Waitlist system upgrade. Please discuss each question and document the decision.

**v2.0 Updates:**
- Added Section E: WHMCS Integration (FR-002)
- Added Section F: Content Configuration (FR-003)
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

### A3. Pain Points
**What are the top 3 problems with the current system?**

1. ________________________________________________________________

2. ________________________________________________________________

3. ________________________________________________________________

---

### A4. Volume
**Approximately how many area-related requests do you handle per month?**

| Request Type | Monthly Volume |
|--------------|----------------|
| New area purchases | ________ |
| Area cancellations | ________ |
| Waitlist inquiries | ________ |
| Transfer requests | ________ |

---

# SECTION B: Business Rules

### B1. Exclusivity
**Can multiple agents own the same zip code area?**

☐ No - Strictly exclusive (one agent per zip)  
☐ Yes - Multiple agents allowed  
☐ Depends on property type (separate SFR vs Condo)  
☐ Other: ____________________

**Notes:**
```
_________________________________________________________________
```

---

### B2. Approval Workflow
**Who approves new area ownership requests?**

☐ Auto-approve (immediate after payment via FR-002)  
☐ Admin review required  
☐ Manager approval  
☐ Payment-triggered (FR-002)  
☐ Other: ____________________

**Approval SLA (if applicable):** ________ hours/days

---

### B3. Cancellation Policy
**When an agent cancels, how quickly should the area become available?**

☐ Immediately  
☐ End of billing period (FR-002)  
☐ 30-day grace period  
☐ After confirmation  
☐ Other: ____________________

**Should there be a "cooling off" period before re-purchase?**

☐ No  
☐ Yes - ________ days

---

### B4. Ownership Limits
**Is there a maximum number of areas one agent can own?**

☐ No limit  
☐ Yes - Maximum: ________ areas

**Is there a maximum number of waitlist positions per agent?**

☐ No limit  
☐ Yes - Maximum: ________ positions

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
☐ 7 days  
☐ Other: ________

**What happens if they don't respond in time?**

☐ Auto-expire, notify next in queue  
☐ Admin follows up manually  
☐ Other: ____________________

---

### C3. Waitlist Visibility
**Should agents on the waitlist see:**

| Information | Yes | No | Admin Only |
|-------------|-----|-----|------------|
| Their queue position | ☐ | ☐ | ☐ |
| Total people waiting | ☐ | ☐ | ☐ |
| Current owner's name | ☐ | ☐ | ☐ |
| Estimated wait time | ☐ | ☐ | ☐ |

---

### C4. Waitlist Pricing
**Should waitlist members pay differently when converting?**

☐ Same price as regular purchase  
☐ Priority premium (pay more)  
☐ Loyalty discount (pay less)  
☐ Deposit required to hold position  
☐ Other: ____________________

**If deposit required, amount:** $________

---

# SECTION D: Notifications

### D1. Notification Channels
**How should agents be notified? (Check all that apply)**

| Event | Email | SMS | In-App | None |
|-------|-------|-----|--------|------|
| Waitlist position available | ☐ | ☐ | ☐ | ☐ |
| Offer expiring soon | ☐ | ☐ | ☐ | ☐ |
| Offer expired | ☐ | ☐ | ☐ | ☐ |
| Request approved | ☐ | ☐ | ☐ | ☐ |
| Ownership ending soon | ☐ | ☐ | ☐ | ☐ |
| Payment failed (FR-002) | ☐ | ☐ | ☐ | ☐ |

---

### D2. Admin Notifications
**Should admins be notified of:**

| Event | Yes | No |
|-------|-----|-----|
| New area requests | ☐ | ☐ |
| Cancellations | ☐ | ☐ |
| Waitlist growing (threshold) | ☐ | ☐ |
| Expired offers | ☐ | ☐ |
| Payment failures (FR-002) | ☐ | ☐ |

**Waitlist alert threshold:** ________ people waiting

---

# SECTION E: WHMCS Integration (FR-002) - NEW v2.0

### E1. Billing Trigger
**When should WHMCS order be created?**

☐ On area request (immediate)  
☐ After admin approval  
☐ Agent-initiated checkout  
☐ Other: ____________________

---

### E2. Base Pricing
**What is the monthly base price per area?**

| Property Type | Monthly Price |
|---------------|---------------|
| SFR (Single Family) | $________ |
| Condo | $________ |
| Townhouse | $________ |
| Multi-Family | $________ |

☐ Same price for all property types: $________

---

### E3. Bundle Discounts
**What discounts should apply for multiple areas?**

| Tier Name | Area Count | Discount % | Approved? |
|-----------|------------|------------|-----------|
| Single | 1 | 0% | ☐ Yes ☐ No |
| Starter | 2-3 | 10% | ☐ Yes ☐ No |
| Pro | 4-6 | 15% | ☐ Yes ☐ No |
| Enterprise | 7+ | 25% | ☐ Yes ☐ No |

**Alternative tier structure:**
```
_________________________________________________________________
```

---

### E4. Promo Codes
**What types of promo codes are needed?**

| Type | Example | Approved? |
|------|---------|-----------|
| Percentage off | 20% off first month | ☐ |
| Fixed amount | $25 off | ☐ |
| Free trial | 14 days free | ☐ |
| Free month | First month free | ☐ |
| Role-based (Founders) | 50% off | ☐ |

---

### E5. WHMCS Product Configuration
**Has the WHMCS product been created for Competition Command?**

☐ Yes - Product ID: ________  
☐ No - Needs creation  
☐ Unknown

**Custom Field ID for area name:** ________

---

### E6. Failed Payment Handling
**What happens when payment fails?**

☐ Retry automatically (how many times? ____)  
☐ Send notification and wait  
☐ Suspend area immediately  
☐ Grace period of ____ days

---

# SECTION F: Content Configuration (FR-003) - NEW v2.0

### F1. Default Content for New Areas
**What default CTAs should new area owners get?**

☐ Home Value Estimate (current default)  
☐ A/B Test group (Home Value v1 vs v2)  
☐ Agent can choose during purchase  
☐ Admin assigns per property type  
☐ Other: ____________________

---

### F2. Landing Page Selection
**Should agents be able to choose their landing page template?**

☐ Yes - Self-service  
☐ Yes - But admin must approve  
☐ No - System assigns based on campaign type

---

### F3. CTA Types Priority
**Which CTA types should be available? (Rank 1-5)**

| CTA Type | Priority | Include? |
|----------|----------|----------|
| Home Value Estimate (existing) | _____ | ☐ |
| Newsletter Signup | _____ | ☐ |
| Social Follow | _____ | ☐ |
| Consultation Request | _____ | ☐ |
| Property Alert Signup | _____ | ☐ |

---

### F4. A/B Testing
**Should agents be able to run A/B tests on CTAs?**

☐ Yes - Self-service  
☐ Yes - Admin setup only  
☐ No - Single CTA only

**Minimum sample size before declaring winner:** ________ displays

---

# SECTION G: Special Cases

### G1. Transfers
**Should area ownership be transferable between agents?**

☐ No - Never  
☐ Yes - Admin only  
☐ Yes - Agent can initiate  
☐ Yes - With fee: $________

---

### G2. Suspensions
**Should ownership be suspendable (pause without canceling)?**

☐ No  
☐ Yes - Admin only  
☐ Yes - Agent can request

**If yes, maximum suspension period:** ________ days

**Does suspension affect waitlist?**

☐ No - Area stays "taken"  
☐ Yes - Notify waitlist during suspension

---

### G3. Historical Data
**For agents who canceled before this system, should we:**

☐ Reconstruct history from campaign data (best effort)  
☐ Start fresh (no historical records)  
☐ Manual data entry for key accounts

---

# SECTION H: Reporting

### H1. Required Reports
**Which reports are needed? (Rank 1-5, 1=Most Important)**

| Report | Priority | Frequency |
|--------|----------|-----------|
| Current ownership by area | _____ | _________ |
| Waitlist by area | _____ | _________ |
| Ownership history | _____ | _________ |
| Churn analysis | _____ | _________ |
| Revenue by area (FR-002) | _____ | _________ |
| Agent portfolio summary | _____ | _________ |
| CTA performance (FR-003) | _____ | _________ |

---

### H2. Export Requirements
**What export formats are needed?**

☐ CSV (Google Sheets)  
☐ Excel (.xlsx)  
☐ PDF  
☐ API access  
☐ Other: ____________________

---

# SECTION I: Timeline & Priority

### I1. Priority Features
**Rank these features by priority (1=Highest):**

| Feature | Priority |
|---------|----------|
| Soft deletes (keep history) | _____ |
| Waitlist queue | _____ |
| WHMCS billing integration (FR-002) | _____ |
| Content configuration (FR-003) | _____ |
| Automated notifications | _____ |
| Admin dashboard | _____ |
| Agent self-service portal | _____ |
| Transfer capability | _____ |
| Reporting/analytics | _____ |

---

### I2. Phase 1 Scope
**What should be included in Phase 1 (MVP)?**

☐ AreaOwnership + History tables only  
☐ + Waitlist  
☐ + WHMCS Integration (FR-002)  
☐ + Content Config (FR-003)  
☐ All features

---

### I3. Timeline
**Target launch date:** ____________________

**Is phased rollout acceptable?**

☐ Yes - Launch core features first  
☐ No - Need all features at once

---

### I4. Migration
**Preferred migration approach:**

☐ Big bang (switch over completely)  
☐ Parallel run (old + new systems)  
☐ Gradual rollout (by customer segment)

---

# Summary of Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Exclusivity model | | |
| Approval workflow | | |
| Cancellation policy | | |
| Waitlist offer window | | |
| Notification channels | | |
| Transfer capability | | |
| Base price per area (FR-002) | | |
| Bundle discounts (FR-002) | | |
| Default CTA (FR-003) | | |
| Phase 1 scope | | |
| Target launch | | |

---

## Next Steps

| Action Item | Owner | Due Date |
|-------------|-------|----------|
| Finalize discovery decisions | | |
| Create WHMCS product | | |
| Get WHMCS.Net DLL | | |
| Design CTA templates | | |
| Begin database schema | | |

---

**Document Prepared By:** AI Assistant  
**Date:** 12/10/2025  
**Updated:** 12/13/2025  
**Feature Request:** FR-001  
**Version:** 2.0

---

**v2.0 Changes:**
- Added Section E: WHMCS Integration (FR-002)
- Added Section F: Content Configuration (FR-003)
- Added source code migration question (A2)
- Added payment failed notification option
- Added revenue by area and CTA performance reports
- Updated priority features to include FR-002 and FR-003
- Updated Phase 1 scope options

---

*Please return completed worksheet to development team for specification finalization.*

