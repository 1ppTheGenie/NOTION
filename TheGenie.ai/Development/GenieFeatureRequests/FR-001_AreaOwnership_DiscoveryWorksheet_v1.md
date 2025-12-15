# Feature Request Discovery Worksheet
## FR-001: Area Ownership & Waitlist System

---

**Meeting Date:** ____________________

**Attendees:** ____________________

**Facilitator:** ____________________

---

## Purpose
This worksheet captures key decisions needed before development begins on the Area Ownership & Waitlist system upgrade. Please discuss each question and document the decision.

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

_________________________________________________________________

_________________________________________________________________
```

---

### A2. Pain Points
**What are the top 3 problems with the current system?**

1. ________________________________________________________________

2. ________________________________________________________________

3. ________________________________________________________________

---

### A3. Volume
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

_________________________________________________________________
```

---

### B2. Approval Workflow
**Who approves new area ownership requests?**

☐ Auto-approve (immediate)  
☐ Admin review required  
☐ Manager approval  
☐ Payment-triggered  
☐ Other: ____________________

**Approval SLA (if applicable):** ________ hours/days

---

### B3. Cancellation Policy
**When an agent cancels, how quickly should the area become available?**

☐ Immediately  
☐ End of billing period  
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
☐ Highest bidder / premium pricing  
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

---

### D2. Admin Notifications
**Should admins be notified of:**

| Event | Yes | No |
|-------|-----|-----|
| New area requests | ☐ | ☐ |
| Cancellations | ☐ | ☐ |
| Waitlist growing (threshold) | ☐ | ☐ |
| Expired offers | ☐ | ☐ |

**Waitlist alert threshold:** ________ people waiting

---

# SECTION E: Special Cases

### E1. Transfers
**Should area ownership be transferable between agents?**

☐ No - Never  
☐ Yes - Admin only  
☐ Yes - Agent can initiate  
☐ Yes - With fee: $________

---

### E2. Suspensions
**Should ownership be suspendable (pause without canceling)?**

☐ No  
☐ Yes - Admin only  
☐ Yes - Agent can request

**If yes, maximum suspension period:** ________ days

**Does suspension affect waitlist?**

☐ No - Area stays "taken"  
☐ Yes - Notify waitlist during suspension

---

### E3. Historical Data
**For agents who canceled before this system, should we:**

☐ Reconstruct history from campaign data (best effort)  
☐ Start fresh (no historical records)  
☐ Manual data entry for key accounts

---

# SECTION F: Reporting

### F1. Required Reports
**Which reports are needed? (Rank 1-5, 1=Most Important)**

| Report | Priority | Frequency |
|--------|----------|-----------|
| Current ownership by area | _____ | _________ |
| Waitlist by area | _____ | _________ |
| Ownership history | _____ | _________ |
| Churn analysis | _____ | _________ |
| Revenue by area | _____ | _________ |
| Agent portfolio summary | _____ | _________ |

---

### F2. Export Requirements
**What export formats are needed?**

☐ CSV (Google Sheets)  
☐ Excel (.xlsx)  
☐ PDF  
☐ API access  
☐ Other: ____________________

---

# SECTION G: Timeline & Priority

### G1. Priority Features
**Rank these features by priority (1=Highest):**

| Feature | Priority |
|---------|----------|
| Soft deletes (keep history) | _____ |
| Waitlist queue | _____ |
| Automated notifications | _____ |
| Admin dashboard | _____ |
| Agent self-service portal | _____ |
| Transfer capability | _____ |
| Reporting/analytics | _____ |

---

### G2. Timeline
**Target launch date:** ____________________

**Is phased rollout acceptable?**

☐ Yes - Launch core features first  
☐ No - Need all features at once

---

### G3. Migration
**Preferred migration approach:**

☐ Big bang (switch over completely)  
☐ Parallel run (old + new systems)  
☐ Gradual rollout (by customer segment)

---

# SECTION H: Open Discussion

### H1. Additional Requirements
**Any other features or requirements not covered above?**

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### H2. Concerns or Risks
**What concerns do you have about this project?**

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### H3. Success Criteria
**How will we know this project is successful?**

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

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
| Priority feature | | |
| Target launch | | |

---

## Next Steps

| Action Item | Owner | Due Date |
|-------------|-------|----------|
| | | |
| | | |
| | | |
| | | |

---

**Document Prepared By:** AI Assistant  
**Date:** 12-10-2025  
**Feature Request:** FR-001  
**Version:** 1.0

---

*Please return completed worksheet to development team for specification finalization.*
*Recovered from Cursor History: December 10, 2025*

