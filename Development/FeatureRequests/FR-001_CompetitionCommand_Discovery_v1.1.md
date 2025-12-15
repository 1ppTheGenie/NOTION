# Competition Command Discovery Worksheet
## FR-001: Area Ownership, Waitlist & Product Configuration

---

| Field | Value |
|-------|-------|
| **Version** | 1.1 |
| **Created** | 12/14/2025 |
| **Last Updated** | 12/14/2025 |
| **Author** | Steve Hundley |
| **Facilitator** | Cursor AI |
| **Status** | Draft |

---

# EXECUTIVE SUMMARY

**Product:** Competition Command - Circle prospecting on competitor listings
**Audience:** Invite-only. Top agents with proven market share.
**Model:** Subscription NOW → Transaction partnership FUTURE
**Goal:** Drive LISTINGS and TRANSACTIONS, not just subscriptions
**Parent Brand:** Inspired Homes Network (eventually)

---

# SECTION 1: CURRENT STATE

## Q1: How is area ownership tracked today?

| Aspect | Current State |
|--------|---------------|
| Discovery | Word of mouth (title reps, friends) |
| Lookup | Manual - "Owned Areas Lookup" in Genie admin |
| Acquisition | "Buy Area" button - function unclear |
| Provisioning | None - no order, no fulfillment, no onboarding |
| Tracking | None - once it's in, no history or workflow |
| Active Areas | ~13-14 now (was ~90) |
| Front End | None exists |

**Key Quote:** "There's no front end to it... the process is clunky."

---

## Q2: What happens when an agent leaves?

### Intentional Cancellation
1. Manually cancel order in WHMCS
2. Look up user in Genie
3. Delete owned area from account
4. Turn off Property Casts (unclear what happens)
5. Opposite of onboarding workflow

### Payment Failure
- **Current:** Nothing happens - service keeps running
- **Problem:** No Genie ↔ WHMCS integration for payment status
- **Need:** Auto-stop service, alert admin and customer

### Data After Deletion
- Link between customer (ASP User ID) and area is broken
- Activity data becomes orphaned
- No history of who owned what, when, or why they left

**Key Quote:** "All the data that took place with that customer becomes orphaned."

---

# SECTION 2: BUSINESS RULES

## Q3: Area Ownership Exclusivity

| Rule | Decision |
|------|----------|
| One agent per zip (same property type) | ✅ Current rule |
| Multiple agents, different property types | ✅ Allowed (SFR vs Condo) |
| Multiple agents sharing same zip/property type | ❌ Not on the table |
| Future: Partition zip into sections | 🔮 Architect for it, don't build yet |

---

## Q4: When area is already taken

**Current Reality:**
- No radar/dashboard showing availability
- Must go into customer's account and search
- Can't see WHO owns it - had to guess until recent reports
- Support uses manual spreadsheet - "horrible way to do it"
- No organized waitlist - memory and notepads only

**What's Needed:**

| View | Can See |
|------|---------|
| Customer | "92127 is taken" + waitlist count (no names) |
| Internal | WHO owns it + WHO is in waitlist |

**Key Quote:** "I want a radar... a screen that tells us what zip codes are taken and how many people are in a wait list."

---

## Q5: Waitlist Mechanics

| Rule | Decision |
|------|----------|
| Priority | First come, first served (default) |
| Override | Admin can pick someone else |
| Time Window | Configurable - NOT hardcoded |
| Starting Point | 24 hours (maybe less - even 5 minutes) |
| Clock Starts | Immediately when area available |
| Notification | Text message instantly |

### Deposit & Auto-Accept Option
| Feature | Details |
|---------|---------|
| Deposit | $50 (configurable) to hold spot |
| Auto-Accept | "Instantly grab it when available" checkbox |
| If Auto-Accept ON | Payment processes immediately |
| If Auto-Accept OFF | Text → 1 hour to confirm |

---

# SECTION 3: ONBOARDING

## Q6: What happens when agent is approved?

### Competition Command Specific Setup

| Step | What Happens | Current State |
|------|--------------|---------------|
| 1 | Buy the area | Manual |
| 2 | Create subscription in WHMCS | Manual |
| 3 | Set up Property Casts (by type + status) | Manual |
| 4 | Turn on notifications | Manual |
| 5 | Connect Zapier to CRM | Manual (if requested) |

### Property Casts Configuration
- By Property Type: SFR, Condo
- By Status: Active, Sold
- Each has own triggers for circle prospecting

### What Agent CAN'T Do Today (Gaps)
- Can't pick content
- Can't pick call-to-action
- No wizard/walkthrough
- No onboarding dashboard

### If NEW Customer
- Upload photograph
- Upload company logos
- Verify marketing email
- Write bio
- Add retargeting snippets (Google, Meta)

---

## Q7: Cast Configuration & Monthly Commitment

### Expectation vs Reality

| Aspect | Expectation | Reality |
|--------|-------------|---------|
| Monthly commitment | 2,000 SMS per area | Unknown |
| Per-cast size | Dynamic based on volume | Hardcoded ~75? |
| Throttling | Auto-adjust to 2,000 goal | None visible |

**ACTION ITEM:** Investigate actual cast logic in code.

### Current Manual Throttling (You Do This)
| Area Volume | What You Turn On |
|-------------|------------------|
| High volume | Active OR Sold (one) |
| Low volume | Active AND Sold (both) |

### What's Wanted
- Phase 1: Easy admin interface in wizard
- Phase 2: Customer-facing toggle (optional)

---

# SECTION 4: NOTIFICATIONS

## Q8: What agents get notified about

### Current Notifications

| Event | Notified? |
|-------|:---------:|
| SMS sent | ❌ |
| Who received SMS | ❌ |
| Someone clicks (Level 1) | ✅ |
| Someone triggers CTA (Level 2) | ✅ |
| Someone verifies (Level 3) | ✅ |
| Someone replies "STOP" | ❌ (auto-handled) |
| Someone replies "Call me" | ❌ **5,700 missed opportunities/year!** |

### Delivery Channels
- Text (notifier): Real-time
- Email: Real-time
- CRM (Zapier): Depends on plan

### What's Missing
- No rolled-up summary/report
- No KPI dashboard
- Response texts not surfaced
- No "Lead to List" tracking

---

## Q8A: What agent should see about each lead

### Already Have (Need Better Display)
- Name, Address, Phone
- Property that triggered SMS
- Click count, Engagement history
- Demographics, Birth date

### Should Add (Easy Wins)
| Data | Source | Value |
|------|--------|-------|
| Is home listed now? | MLS | Hot lead signal |
| Was it listed before? | MLS | Motivation signal |
| Did listing expire? | MLS | Frustrated seller |
| Equity amount | Attom | Ability to sell |
| Years in home | Attom | Motivation timeline |
| Interest rate | Attom | Refinance motivation |

### Future (AI/ML)
- Motivation to sell score
- Pattern detection
- Active prospector technology

**Key Quote:** "If we could just do a deep dive on what value we can give the agent on a full picture of a potential home seller, that would be amazing."

---

# SECTION 5: PRICING & BUSINESS MODEL

## Q9: Pricing Structure

### Launch Promotion
| Element | Details |
|---------|---------|
| Bundle | 3-4 zip codes |
| Term | 6 months or 1 year |
| Includes | 100 SMS commands/month |
| Value | $2,500 |
| Price | $1,000 |
| Goal | 100 customers immediately |

### Current Pricing
- 1 area: $500/month
- Volume discounts at scale (TBD)

### Ultimate Vision: Partnership Model
- Subscription = "gas in the tank"
- Real revenue = piece of transaction
- Example: 30% referral on $1M home = ~$9,000
- 2-3 transactions = pays back annual subscription

### Commission Structure (Future)
| Scenario | Split |
|----------|:-----:|
| Lead already in agent's CRM | 10% |
| NEW lead (not in orbit) | 25-35% |

---

# SECTION 6: CTA CONTROL

## Q12: Agent Customization Rights

### SMS (Competition Command)
| Capability | Allowed? |
|------------|:--------:|
| Pick from menu of CTAs | ❌ |
| Customize text | ❌ |
| Upload own image | ❌ |
| Pick template/style/color | ✅ |
| Round-robin approved templates | ✅ |

**Reason:** TCPA compliance. Must be community information, not promotion.

### Social (Future)
- More flexibility allowed
- Can choose graphics
- Can potentially upload own

---

# SECTION 7: QUALIFICATION

## Q13: Who qualifies for Competition Command?

### Criteria
| Requirement | Details |
|-------------|---------|
| Top 10 in zip | Must appear in Genie algorithm |
| OR Emerging | Enough activity to prove trajectory |
| OR Section Leader | Top for a section (future) |
| Proven trust | Already has mindshare with homeowners |

### Process
- Verification via Genie algorithm
- Your manual approval
- Invite only

### Current CC Agents
- Mike Chisel (Fallbrook) ✅
- David Higgins (Oakland) ✅
- Ed Kaminski (Manhattan Beach) ✅

**Key Quote:** "An agent that's already invested in a marketplace, already has mind share, already has proven to earn trust, elevates our ability to generate transactions much faster."

---

# SECTION 8: SYSTEM ARCHITECTURE

## Q15: Integration Status

| Integration | Status |
|-------------|--------|
| Genie ↔ WHMCS | ✅ Exists |
| Genie ↔ Twilio | ✅ Exists |
| Genie ↔ Versium | ✅ Exists |
| Genie ↔ MLS | ✅ Exists |
| Genie ↔ Attom | ✅ Exists |

**The Problem:** Competition Command not CONFIGURED into these workflows like other products.

### Models to Follow
- Neighborhood Command (subscription)
- Paisley Plus (subscription)
- Listing Command (wizard for MLS connection)

### What's Needed
- Database schema adjustments
- Billing handler code
- Admin UI
- Provisioning workflow
- UN-provisioning workflow (nothing auto-cancels today)

---

# SECTION 9: LEAD TO LIST TRACKING

## Q17: Attribution Tracking

### What We Know On Every Lead
- Homeowner name
- Property/Parcel ID
- Timestamp of engagement
- Which campaign touched them
- Click history

### The Process Needed
1. MLS update comes in (2-3x daily)
2. Scan all leads in CC system
3. Match: Did any lead's property just get listed?
4. If YES → Who listed it?

### Two Outcomes
| Outcome | Meaning | Action |
|---------|---------|--------|
| Our agent listed it | SUCCESS | Track for commission |
| Other agent listed it | We lost it | Investigate, learn |

## Q18: Handling Lost Listings
- Log internally
- Alert admin
- Investigate with agent
- Document lessons learned

**Key Quote:** "We should have got the listing if we touched them with our system."

---

# SECTION 10: SUCCESS METRICS

## Q19: One Year Targets

| Metric | Target |
|--------|--------|
| Agents on platform | 100 |
| Monthly revenue per agent | $1,000 |
| Monthly Recurring Revenue | $100,000 |
| Transaction conversion | 2% of leads → listings |

### Future Campaigns
- Empty Nester (20+ years, high equity, kids gone)
- Improve-to-Move (we fix deferred maintenance, get 6-7% listing)
- Lifestyle Upgrade specialist

---

# SECTION 11: RISK

## Q20: What Could Kill This Product

| Risk | Mitigation |
|------|------------|
| **TCPA / Spam texting** | Structure as community information |
| SMS channel blocked | Backup: Social, direct mail |
| Direct mail limitation | Can't advertise other's listing in print |

**The Protection:** Community information, not promotion.

---

# PRODUCT VISION: INSPIRED HOMES NETWORK

## The Trifecta

| Product | Role | Branding |
|---------|------|----------|
| Competition Command | Circle prospecting on OTHER agents' listings | Generic (IDX rules) |
| Neighborhood Command | Farming content in area | Agent-branded |
| Listing Command | Marketing agent's OWN listings | Full branding |

**When someone joins CC → They get ALL THREE.**

**Goal:** Drive TRANSACTIONS through full-spectrum marketing.

---

# ACTION ITEMS

## Immediate Investigation
| # | Task |
|:-:|------|
| 1 | Investigate "Buy Area" button code |
| 2 | Review Neighborhood Command subscription workflow |
| 3 | Review Listing Command wizard (MLS, content selection) |
| 4 | Document current CTA tracking |
| 5 | Review pixel/retargeting setup (GA, Facebook) |

## Build Priorities
| Priority | Feature |
|:--------:|---------|
| 1 | Area ownership with history (soft deletes) |
| 2 | Waitlist system |
| 3 | Radar dashboard |
| 4 | Onboarding wizard |
| 5 | CTA tracking improvements |
| 6 | Lead to List matching |
| 7 | Customer-facing reports |

---

# SEPARATE FEATURE REQUESTS (Noted)

| FR# | Feature |
|-----|---------|
| TBD | CRM Plugins (FollowUpBoss, Lofty) |
| TBD | GoHighLevel-like CRM |
| TBD | GeoSocial standalone product |
| TBD | Retargeting/remarketing (Phase 2) |

---

## Document Sign-off

**Reviewed By:** ____________________

**Date:** ____________________

**Status:** [ ] Approved [ ] Approved with Changes [ ] Needs Discussion

---

# CHANGE LOG

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 1.0 | 12/14/2025 | Cursor AI | Initial document from discovery session |
| 1.1 | 12/14/2025 | Cursor AI | Added version header, author, timestamp, change log |

---

*Document: FR-001_CompetitionCommand_Discovery_v1.1.md*
*Session Date: 12/14/2025*
*Author: Steve Hundley*
*Facilitator: Cursor AI*
*Source: Direct discovery session with product owner*

