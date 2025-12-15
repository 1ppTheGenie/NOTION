# Feature Request Discovery Worksheet
## FR-001: Area Ownership & Waitlist System
### Version 2.0 | Created: 12/10/2025 | Updated: 12/14/2025

---

**GitHub:** [FR-001_AreaOwnership_DiscoveryWorksheet_v2.md](https://github.com/1ppTheGenie/NOTION/blob/main/TheGenie.ai/Development/FeatureRequests/FR-001_AreaOwnership_DiscoveryWorksheet_v2.md)

---

## Purpose
This worksheet contains AI-recommended answers for each discovery question. Review each recommendation, then mark: ✅ Agree | ❌ Disagree | ✏️ Modify

---

# SECTION A: Current State

### A1. How do you currently track area ownership requests and waitlists?

**AI ANSWER:** Based on source code analysis, current tracking is:
- `UserOwnedArea` table (no history, hard deletes)
- No formal waitlist exists in the system
- Requests likely tracked via email/spreadsheet outside the system
- `OwnedAreaManager.cs` shows basic CRUD only - no workflow

**RECOMMENDATION:** This is a major gap. The new system addresses it with `AreaOwnership` + `AreaWaitlist` tables.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### A2. What are the top 3 problems with the current system?

**AI ANSWER:** Based on code review and reports:

1. **No History** - When an agent cancels, all data is lost. We can't track who owned what, when, or why they left. This kills our ability to do churn analysis or win-back campaigns.

2. **No Waitlist** - Interested agents have no way to queue up for taken areas. We're losing potential revenue and creating friction.

3. **No Soft Deletes** - Hard deletes mean we can't recover from mistakes, can't audit, can't report on historical ownership.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### A3. Monthly Volume Estimates

**AI ANSWER:** Based on `Genie_CC_Ownership_LIFETIME` report:

| Request Type | Estimated Monthly Volume |
|--------------|-------------------------|
| New area purchases | 5-10 (growth phase) |
| Area cancellations | 2-3 (low churn observed) |
| Waitlist inquiries | Unknown (no system exists) |
| Transfer requests | Rare (manual process) |

**RECOMMENDATION:** Volume is manageable. System should be built for 10x scale.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION B: Business Rules

### B1. Can multiple agents own the same zip code area?

**AI ANSWER:** **No - Strictly exclusive (one agent per zip)**

**RATIONALE (Steve Jobs - Simplicity):**
- Exclusivity is the core value proposition
- "You OWN this territory" - powerful positioning
- Simplifies billing, reporting, and messaging
- Creates scarcity → higher perceived value → premium pricing

**RATIONALE (Hormozi - Offer Engineering):**
- Exclusivity = "Category of One" positioning
- Agents pay MORE for exclusive vs shared
- Waitlist creates urgency and FOMO

**EXCEPTION:** SFR and Condo could be separate ownership (per `PropertyTypeId`). This doubles inventory without diluting exclusivity.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### B2. Who approves new area ownership requests?

**AI ANSWER:** **Payment-triggered (auto-approve on successful payment)**

**RATIONALE:**
- Removes friction from purchase flow
- Current `ListingCommandBillingHandler.cs` pattern: payment = provisioning
- Admin review adds delay, hurts conversion
- WHMCS handles payment validation

**EXCEPTION:** Could require admin approval for:
- First-time buyers (fraud check)
- Premium/high-demand areas
- Enterprise (6+) bulk purchases

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### B3. When an agent cancels, how quickly should the area become available?

**AI ANSWER:** **Immediately upon cancellation confirmation**

**RATIONALE (Hormozi - Urgency):**
- Instant availability creates urgency for waitlist
- "The moment someone leaves, you're in" - powerful messaging
- Waiting periods create awkward gaps in coverage

**FLOW:**
1. Agent confirms cancellation
2. `AreaOwnership.Status` → 'Ended', `EndDate` = NOW
3. System immediately notifies first waitlist position
4. 48-hour acceptance window starts

**COOLING OFF PERIOD:** No. If they cancel, they can rejoin waitlist like everyone else.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### B4. Is there a maximum number of areas one agent can own?

**AI ANSWER:** **No limit - encourage expansion**

**RATIONALE (Hormozi - LTV Maximization):**
- More areas = higher revenue per customer
- Bundle discounts incentivize expansion
- Top performers (Jason Barry: 3 areas) prove model works
- Limiting would cap our revenue

**WAITLIST LIMIT:** Also no limit. Let them queue for as many as they want.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION C: Waitlist Rules

### C1. How should waitlist priority be determined?

**AI ANSWER:** **First-come, first-served (FIFO queue)**

**RATIONALE (Tom Ferry - Fairness):**
- Agents understand and accept queue fairness
- Prevents pay-to-play perception
- Simple to implement and explain
- Creates predictable expectation

**ALTERNATIVE CONSIDERED:** Premium pricing for priority. Rejected because:
- Adds complexity
- Could alienate price-sensitive agents
- Current focus is adoption, not extraction

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### C2. How long should a waitlisted agent have to accept an available area?

**AI ANSWER:** **48 hours**

**RATIONALE:**
- 24 hours too short (weekend/travel issues)
- 72+ hours delays revenue too long
- 48 hours is industry standard for offers
- Allows business day consideration

**EXPIRATION FLOW:**
1. Offer sent (email + SMS + in-app)
2. 24-hour reminder if no action
3. Hour 47 final warning
4. Hour 48 auto-expire → next in queue notified

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### C3. What should waitlisted agents see?

**AI ANSWER:**

| Information | Visible? | Rationale |
|-------------|----------|-----------|
| Their queue position | ✅ YES | Transparency, manages expectations |
| Total people waiting | ✅ YES | Social proof ("5 others want this!") |
| Current owner's name | ❌ NO | Privacy, prevents poaching |
| Estimated wait time | ❌ NO | Unpredictable, sets wrong expectations |

**MESSAGING EXAMPLE:** "You're #3 of 7 waiting for 92127"

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### C4. Should waitlist members pay differently?

**AI ANSWER:** **Same price as regular purchase**

**RATIONALE:**
- Waitlist is already a "cost" (time, uncertainty)
- Charging more punishes patience
- Charging less devalues the product
- Keep it simple

**DEPOSIT:** No deposit required. They pay when they accept.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION D: Notifications

### D1. How should agents be notified?

**AI ANSWER:**

| Event | Email | SMS | In-App |
|-------|:-----:|:---:|:------:|
| Waitlist position available | ✅ | ✅ | ✅ |
| Offer expiring (24hr warning) | ✅ | ✅ | ✅ |
| Offer expired | ✅ | ❌ | ✅ |
| Request approved | ✅ | ❌ | ✅ |
| Ownership ending soon (renewal) | ✅ | ✅ | ✅ |

**RATIONALE:** 
- Critical actions (available, expiring) = all channels
- Informational (expired, approved) = email + in-app
- SMS for urgency only (don't spam)

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### D2. Admin Notifications

**AI ANSWER:**

| Event | Notify Admin? |
|-------|:-------------:|
| New area requests | ❌ (auto-process) |
| Cancellations | ✅ (churn alert) |
| Waitlist > 5 people | ✅ (demand signal) |
| Expired offers | ✅ (follow-up opportunity) |

**RATIONALE:** Only notify admins for actionable items. Don't create noise.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION E: Special Cases

### E1. Should area ownership be transferable?

**AI ANSWER:** **Yes - Admin only, no fee**

**RATIONALE:**
- Enables team/brokerage transitions
- Handles agent departures gracefully
- Admin control prevents abuse
- No fee (keep it simple for now)

**FUTURE:** Could add self-service transfer with fee (Phase 2)

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### E2. Should ownership be suspendable (pause)?

**AI ANSWER:** **Yes - Admin only, max 30 days**

**RATIONALE:**
- Handles payment issues gracefully
- Allows vacation/illness accommodation
- Prevents permanent holds (30-day max)
- Admin control prevents abuse

**DURING SUSPENSION:**
- Area stays "taken" (not released)
- No campaigns sent
- Billing paused
- Waitlist NOT notified

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### E3. Historical data for past owners?

**AI ANSWER:** **Reconstruct from campaign data (best effort)**

**APPROACH:**
1. Query `PropertyCast` for historical campaigns by area
2. Match to `AspNetUserId` 
3. Infer ownership periods from campaign dates
4. Create `AreaOwnershipHistory` records marked as "Reconstructed"

**SQL EXISTS:** Migration script in `FR-001_AreaOwnership_DevSpec_v2.md`

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION F: Reporting

### F1. Required Reports (Priority Ranked)

**AI ANSWER:**

| Report | Priority | Frequency | Rationale |
|--------|:--------:|-----------|-----------|
| Current ownership by area | 1 | Real-time | Core operational need |
| Revenue by area | 2 | Monthly | Financial tracking |
| Churn analysis | 3 | Monthly | Retention strategy |
| Waitlist by area | 4 | Weekly | Demand visibility |
| Agent portfolio summary | 5 | On-demand | Account management |
| Ownership history | 6 | On-demand | Audit/support |

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### F2. Export Formats

**AI ANSWER:** CSV + Excel

**RATIONALE:**
- CSV for data analysis/import
- Excel for formatted reports
- PDF not needed (print from Excel)
- API access (Phase 2)

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION G: Timeline & Priority

### G1. Feature Priority (Ranked)

**AI ANSWER:**

| Feature | Priority | Rationale |
|---------|:--------:|-----------|
| 1. Soft deletes (history) | 1 | Foundation - everything else needs this |
| 2. Waitlist queue | 2 | Revenue opportunity, competitive advantage |
| 3. Automated notifications | 3 | Operational efficiency |
| 4. Admin dashboard | 4 | Management visibility |
| 5. Reporting/analytics | 5 | Business intelligence |
| 6. Agent self-service | 6 | Nice-to-have, reduces support |
| 7. Transfer capability | 7 | Edge case handling |

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### G2. Phased Rollout?

**AI ANSWER:** **Yes - Launch core features first**

**PHASE 1 (Sprint 51-53):**
- Database schema + migration
- Soft deletes + history tracking
- Basic admin dashboard

**PHASE 2 (Sprint 54-55):**
- Waitlist queue
- Automated notifications
- Agent portal updates

**PHASE 3 (Sprint 56-57):**
- Reporting/analytics
- Self-service features
- Optimization

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### G3. Migration Approach

**AI ANSWER:** **Parallel run (old + new systems)**

**RATIONALE:**
- Zero downtime risk
- Validate new system before cutover
- Rollback capability
- 2-week parallel period recommended

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION H: Success Criteria

### H1. How will we know this project is successful?

**AI ANSWER:**

| Metric | Current | Target | Timeframe |
|--------|---------|--------|-----------|
| Area revenue | $0/mo | $5,000/mo | 90 days post-launch |
| Waitlist signups | 0 | 25+ | 60 days post-launch |
| Ownership churn | Unknown | <5%/mo | Ongoing |
| Support tickets (area issues) | Unknown | -50% | 30 days post-launch |
| Time to provision area | Manual | <1 min | At launch |

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# Summary of AI Recommendations

| Question | AI Recommendation |
|----------|-------------------|
| Exclusivity | Yes - one agent per zip (SFR/Condo separate) |
| Approval | Payment-triggered (auto) |
| Cancellation | Immediate release |
| Area limits | No limit |
| Waitlist priority | FIFO (first-come) |
| Offer window | 48 hours |
| Waitlist visibility | Position + total waiting (not owner name) |
| Transfers | Admin only, no fee |
| Suspensions | Admin only, max 30 days |
| Phase 1 priority | Soft deletes + history |

---

## Reviewer Sign-off

**Reviewed By:** ____________________

**Date:** ____________________

**Overall Status:** [ ] Approved [ ] Approved with Changes [ ] Needs Discussion

**Notes:**
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

*Document Version: 2.0 | Created: 12/10/2025 | Updated: 12/14/2025*
*AI Recommendations by: Cursor AI*
*Strategic Frameworks: Steve Jobs (Simplicity) • Alex Hormozi (Offer Engineering) • Tom Ferry (Agent Psychology)*

