# Competition Command Enhancement
## Master Discovery Package
### All Feature Requests - Consolidated Questions with AI Recommendations

**Created:** 12/14/2025  
**Version:** 1.0  
**Status:** PENDING STAKEHOLDER REVIEW

---

## How to Use This Document

Each question has:
- **Question**: The decision needed
- **Options**: Available choices
- **AI Recommendation**: My recommended answer with rationale
- **Decision**: [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

# EXECUTIVE SUMMARY

## Feature Requests Included

| FR | Name | Purpose | Priority |
|----|------|---------|----------|
| FR-001 | Area Ownership & Waitlist | Soft deletes, history, waitlist queue | HIGH |
| FR-002 | WHMCS Area Billing | Pricing, promo codes, bundles, auto-provision | HIGH |
| FR-003 | Content Configurator | Per-area CTA and landing page customization | MEDIUM |

## Key Business Metrics (from CC Ownership Reports)

| Metric | Current Value | Source |
|--------|---------------|--------|
| Active Areas | ~95 | Genie_CC_Ownership_LIFETIME report |
| Total Campaigns | 14,950 | SOP_CC_Ownership_Report_v5 |
| Average CTR | 7.5% | Report analysis |
| Leads per Area (avg) | 350+ | Report analysis |
| Top Performer CTR | 13.0% | Steve Hundley 92064 |
| Top Leads | 1,032 | Chris Heller 92024 |

---

# FR-001: AREA OWNERSHIP & WAITLIST SYSTEM

## Section A: Current State

### A1. Migration Strategy
**Question:** How should we migrate from `UserOwnedArea` to `AreaOwnership`?

**Options:**
- Big bang (replace immediately)
- Parallel run (both tables active)
- Gradual rollout

**AI Recommendation:** **Parallel run (both tables active)**

**Rationale:** Based on source code analysis, `UserOwnedArea` is referenced in multiple handlers (`Proxy.cs`, billing workflows). A parallel run allows testing without breaking existing functionality. The existing 95+ active areas should continue working during transition.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### A2. Historical Data Reconstruction
**Question:** Should we reconstruct ownership history from campaign data for agents who already canceled?

**AI Recommendation:** **Yes - Best effort reconstruction**

**Rationale:** The CC Ownership report already shows "Ended" records (e.g., Kim Ewing, Susan Featherly). These records have valuable data: Total_Campaigns, Texts_Sent, Clicks, Leads_Generated. This history informs billing reconciliation and waitlist priority decisions.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section B: Business Rules

### B1. Area Exclusivity
**Question:** Can multiple agents own the same zip code area?

**Options:**
- Strictly exclusive (one agent per zip)
- Multiple agents allowed
- Separate by property type (SFR vs Condo)

**AI Recommendation:** **Strictly exclusive (one agent per zip per property type)**

**Rationale:** Current data shows agents own areas with "SFR + Condo" combined (e.g., Jason Barry owns 92127 with "SFR + Condo"). The business model is "exclusive farm areas" - this is what differentiates Competition Command from Listing Command. However, SFR and Condo could be sold separately to different agents if desired.

**Risk Note:** Allowing multiple agents per area would dilute the "exclusive territory" value proposition.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B2. Approval Workflow
**Question:** Who approves new area ownership requests?

**Options:**
- Auto-approve (immediate after payment)
- Admin review required
- Payment-triggered via FR-002

**AI Recommendation:** **Payment-triggered auto-approve (via FR-002)**

**Rationale:** Based on `ListingCommandBillingHandler.cs` pattern, the workflow is:
1. Agent requests area → Status = Pending
2. WHMCS AddOrder + CapturePayment
3. Success → Auto-activate ownership
4. No admin intervention needed for standard purchases

This reduces manual work while ensuring payment before activation.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B3. Cancellation Policy
**Question:** When an agent cancels, how quickly should the area become available?

**Options:**
- Immediately
- End of billing period
- 30-day grace period

**AI Recommendation:** **End of billing period (prorated)**

**Rationale:** 
1. Agent paid for the month - honor their purchase
2. Gives time to notify waitlist
3. Prevents "refund gaming" (buy → cancel → refund → rejoin waitlist)
4. Consistent with WHMCS recurring billing model

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B4. Ownership Limits
**Question:** Is there a maximum number of areas one agent can own?

**AI Recommendation:** **No limit (but bundle pricing applies via FR-002)**

**Rationale:** Current data shows agents with 1-6 areas. Top performers have more:
- Jason Barry: 3 areas
- Mike Blair: 5 areas
- David Higgins: 3 areas
- Debbie Gates: 3 areas

More areas = more revenue. Bundle pricing (FR-002) incentivizes growth rather than limiting it.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B5. Waitlist Maximum per Agent
**Question:** How many waitlist positions can one agent hold?

**Options:**
- Unlimited
- 3 positions
- 5 positions
- 10 positions

**AI Recommendation:** **5 positions maximum**

**Rationale:** Prevents "waitlist hoarding" while allowing reasonable planning. An agent with 3 owned areas can queue for 5 more = potential portfolio of 8. This is sufficient for growth without blocking other agents.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section C: Waitlist Rules

### C1. Waitlist Priority
**Question:** How should waitlist priority be determined?

**Options:**
- First-come, first-served
- Highest bidder
- Existing customer priority

**AI Recommendation:** **First-come, first-served (with existing customer bonus)**

**Rationale:** 
- Fair and transparent
- Existing customers (already paying for other areas) get 24-hour advance notification before new customers
- This rewards loyalty without auction complexity

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### C2. Waitlist Offer Window
**Question:** How long should a waitlisted agent have to accept an available area?

**Options:**
- 24 hours
- 48 hours
- 72 hours
- 7 days

**AI Recommendation:** **48 hours**

**Rationale:**
- Long enough to check email and make payment decision
- Short enough to keep queue moving
- If no response, auto-notify next in queue
- 7 days is too long - delays revenue

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### C3. Waitlist Visibility
**Question:** What should agents see about the waitlist?

| Information | AI Recommendation |
|-------------|-------------------|
| Their queue position | ✅ Yes |
| Total people waiting | ✅ Yes (number only) |
| Current owner's name | ❌ No (privacy) |
| Estimated wait time | ❌ No (unpredictable) |

**Rationale:** Position and queue size help agents decide if waiting is worthwhile. Owner name and wait time could create awkward situations or unrealistic expectations.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section D: Notifications

### D1. Notification Channels
**Question:** How should agents be notified?

| Event | AI Recommendation |
|-------|-------------------|
| Waitlist position available | Email + SMS + In-App |
| Offer expiring soon (12hr left) | Email + SMS |
| Offer expired | Email |
| Area approved/activated | Email + In-App |
| Ownership ending soon | Email (7 days) + Email (3 days) |

**Rationale:** Critical events (available area) need multi-channel. Routine events (expiry) need one channel. SMS for urgency only.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

# FR-002: WHMCS AREA BILLING INTEGRATION

## Section A: WHMCS Configuration

### A1. WHMCS Product ID
**Question:** Has a WHMCS product been created for Competition Command?

**AI Recommendation:** **Create new product: "Competition Command - Area Subscription"**

**Rationale:** Based on `ListingCommandBillingHandler.cs`, each product type has its own `WhmcsProductId` stored in config. CC needs a separate product from LC for proper revenue tracking.

**Action Required:** IT to create product in WHMCS and provide Product ID.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### A2. WHMCS.Net Library
**Question:** Is the WHMCS.Net library accessible?

**Current Status:** 🔴 BLOCKED per Sandbox Setup SOP

**AI Recommendation:** Request from IT:
1. The actual `WHMCS.Net.dll` from production servers, OR
2. Full source code from `Smart.Common.Whmcs` project

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section B: Pricing

### B1. Base Monthly Price per Area
**Question:** What is the monthly base price per area?

**AI Recommendation:**

| Property Type | Monthly Price | Rationale |
|---------------|---------------|-----------|
| SFR (Single Family) | **$99** | Core product, premium pricing |
| Condo | **$79** | Lower volume typically |
| Townhouse | **$79** | Similar to Condo |
| Multi-Family | **$149** | Higher value transactions |

**Alternative:** Same price for all: **$99/month**

**Rationale:** Based on CC report data:
- Average area generates 350+ leads
- At $99/month, cost per lead = ~$0.28
- This is excellent ROI for agents
- $99 is a psychological "under $100" price point

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B2. Bundle Tier Structure
**Question:** What bundle discounts should apply for multiple areas?

**AI Recommendation:**

| Tier | Area Count | Discount | Monthly/Area | Rationale |
|------|------------|----------|--------------|-----------|
| Single | 1 | 0% | $99 | Entry point |
| Starter | 2-3 | 10% | $89.10 | Encourage 2nd area |
| Pro | 4-6 | 15% | $84.15 | Power users |
| Enterprise | 7+ | 25% | $74.25 | Top performers |

**Rationale:** 
- Current data shows most agents have 1-5 areas
- 10% at tier 2 encourages upgrade without major revenue hit
- Enterprise tier (25% off) still profitable at scale

**Sample Math:**
- Agent with 4 areas at Pro: 4 × $84.15 = $336.60/month
- Agent with 4 areas at Single: 4 × $99 = $396/month
- Discount: $59.40/month, but keeps customer

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B3. Billing Cycle Options
**Question:** What billing cycles should be offered?

**AI Recommendation:**

| Cycle | Offer? | Discount | Price (SFR) |
|-------|--------|----------|-------------|
| Monthly | ✅ Yes | 0% | $99/month |
| Quarterly | ❌ No | - | - |
| Annual | ✅ Yes | 20% | $79.20/month ($950/year) |

**Rationale:**
- Monthly is default (matches current WHMCS pattern)
- Annual lock-in improves retention, justifies discount
- Quarterly adds complexity without major benefit

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section C: Promo Codes

### C1. Promo Code Types
**Question:** What promo code types should be supported?

**AI Recommendation:**

| Type | Support? | Example |
|------|----------|---------|
| Percentage off | ✅ Yes | 20% off first month |
| Fixed amount | ✅ Yes | $25 off first month |
| Free trial (X days) | ✅ Yes | 14 days free |
| Free month | ✅ Yes | First month free |
| Role-based | ✅ Yes | Founders 50% off |

**Rationale:** All types exist in `ListingCommandBillingHandler.cs` pattern. Role-based promo allows internal pricing (Founders, Beta testers).

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### C2. Initial Promo Codes to Create
**Question:** What promo codes should be seeded at launch?

**AI Recommendation:**

| Code | Type | Value | Target | Duration |
|------|------|-------|--------|----------|
| `CCLAUNCH` | Free Month | 100% | New customers | 90 days |
| `FOUNDERS50` | Percentage | 50% | Founders role | Permanent |
| `REFER25` | Fixed | $25 | Referrals | Permanent |
| `SECONDAREA` | Percentage | 15% | Existing customers | 30 days |

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section D: Payment Handling

### D1. Failed Payment Retry
**Question:** How should failed payments be handled?

**AI Recommendation:**

| Setting | Value | Rationale |
|---------|-------|-----------|
| Retry attempts | 3 | Industry standard |
| Retry interval | Every 3 days | Not too aggressive |
| Grace period | 7 days | Before suspension |
| Action after max retries | Suspend (not cancel) | Can reactivate on payment |

**Rationale:** Based on `FailedPaymentCaptureManager` pattern in source code. Suspension preserves the record; cancellation triggers waitlist.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### D2. Waitlist Auto-Provision on Cancel
**Question:** When billing is canceled, should waitlist be auto-notified?

**AI Recommendation:** **Yes - 24 hours after cancellation is final**

**Rationale:**
1. Cancellation finalized at end of billing period
2. Wait 24 hours for any "I changed my mind" reversals
3. Then auto-trigger `usp_AreaWaitlist_NotifyNext`
4. Waitlist #1 gets 48-hour offer window

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

# FR-003: CONTENT CONFIGURATOR

## Section A: CTA Types

### A1. Which CTA Types to Support
**Question:** Which CTA categories should be available?

**AI Recommendation:**

| CTA Type | Phase 1 | Priority | Rationale |
|----------|---------|----------|-----------|
| Home Value Estimate | ✅ | 1 | Current CTAs 2-9, proven performer |
| Newsletter Signup | ✅ | 2 | New lead nurturing channel |
| Social Follow | ✅ | 3 | Build agent's audience |
| Consultation Request | ⏳ Phase 2 | 4 | Requires calendar integration |
| Property Alerts | ⏳ Phase 2 | 5 | Requires listing feed |
| Custom | ⏳ Phase 2 | 6 | Complex, requires builder UI |

**Rationale:** 
- Home Value is proven (8 versions exist)
- Newsletter/Social are simple to implement
- Consultation needs Calendly/Acuity API
- Custom needs visual builder (significant effort)

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### A2. Default CTA for New Areas
**Question:** What CTA should new areas get by default?

**AI Recommendation:** **A/B Test: CTA 4 vs CTA 5 (Competition Command variants)**

**Rationale:** Based on current system:
- CTA 4: "Personalized Home Value Estimate" (delay: 1s)
- CTA 5: "Accurate Home Valuation" (delay: 2s)

Start new areas with A/B test to gather data, then auto-select winner after 100 displays.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### A3. Newsletter Integration
**Question:** Which newsletter provider should we integrate?

**AI Recommendation:** **Mailchimp (with local fallback)**

**Rationale:**
- Mailchimp has excellent API, widely used
- Agents may already have Mailchimp lists
- Local fallback stores emails if API fails (manual export)

**Alternative:** GoHighLevel integration if agents use that CRM

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section B: Agent Configuration

### B1. Agent Access Level
**Question:** Should all agents have access to content configuration?

**AI Recommendation:** **All agents - self-service**

**Rationale:** 
- Reduces support burden
- Agents can experiment with CTAs
- Default config is always available if they're unsure

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B2. A/B Testing for Agents
**Question:** Should agents be able to run A/B tests on CTAs?

**AI Recommendation:** **Yes - self-service with 2-3 CTA limit**

| Setting | Value |
|---------|-------|
| Max CTAs in A/B test | 3 |
| Minimum sample size | 100 displays |
| Auto-select winner | Optional (agent choice) |

**Rationale:** 
- More than 3 CTAs dilutes sample
- 100 displays gives statistical significance
- Agent can override if they have preference

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### B3. Custom CTA Text
**Question:** Should agents be able to customize CTA text?

**AI Recommendation:** **No (Phase 1) - Template selection only**

| Phase 1 | Phase 2+ |
|---------|----------|
| Select from templates | Customize title/body |
| No text editing | Add agent branding |
| Simple UI | Visual builder |

**Rationale:** 
- Custom text could break conversion (bad copy)
- Templates are proven performers
- Saves significant dev time
- Phase 2 can add customization once we have more data

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section C: Performance Tracking

### C1. Metrics to Track
**Question:** Which metrics should be visible to agents?

**AI Recommendation:**

| Metric | Track | Show to Agent |
|--------|-------|---------------|
| Displays (CTA shown) | ✅ | ✅ |
| Submissions (CTA clicked) | ✅ | ✅ |
| Verifications (contact confirmed) | ✅ | ✅ |
| Conversion rate | ✅ | ✅ |
| Comparison to area average | ✅ | ⚠️ Carefully |

**Note on "Comparison to average":** Showing if agent is above/below average can be motivating or discouraging. Consider showing only if agent is above average.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### C2. Performance Reporting Period
**Question:** What time periods should be available?

**AI Recommendation:**
- Last 7 days ✅
- Last 30 days ✅ (default)
- Last 90 days ✅
- All time ✅
- Custom date range ❌ (overkill for v1)

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

## Section D: Technical

### D1. Configuration Caching
**Question:** How long should configurations be cached?

**AI Recommendation:** **5 minutes**

**Rationale:**
- Long enough to reduce DB load
- Short enough that changes appear quickly
- Agent changes config → visible within 5 min

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### D2. Fallback Behavior
**Question:** If database configuration fails, what happens?

**AI Recommendation:** **Fallback to hardcoded CTA 4**

**Rationale:** 
- CTA 4 is the default CC CTA
- Exists in `utils.js` as backup
- Page still works, leads still captured
- Log error for monitoring

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

# INTEGRATION QUESTIONS

## Timeline Priority

### Q1. Development Sequence
**Question:** In what order should we develop the features?

**AI Recommendation:**

| Phase | Weeks | Features |
|-------|-------|----------|
| 1 | 1-2 | FR-001 Schema (AreaOwnership, history tables) |
| 2 | 3-4 | FR-001 Waitlist + FR-002 Billing Handler (parallel) |
| 3 | 5-6 | FR-002 Promo + Bundle + FR-003 CTA Templates |
| 4 | 7-8 | FR-003 Agent UI + Integration Testing |
| 5 | 9 | UAT + Launch |

**Total:** 9 weeks

**Rationale:** FR-001 schema is foundation for both FR-002 and FR-003. Once schema exists, billing and content can develop in parallel.

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

### Q2. Launch Strategy
**Question:** How should we launch?

**AI Recommendation:** **Phased rollout by customer segment**

| Week | Segment | Count |
|------|---------|-------|
| 1 | Internal (Steve Hundley test area) | 1 |
| 2 | Beta (top 5 agents by volume) | 5 |
| 3 | Early Adopters (agents with 3+ areas) | ~15 |
| 4 | General Availability | All |

**Rationale:** Catch issues early with friendly users. Jason Barry, David Higgins, Chris Heller are good beta candidates (high volume, engaged).

**Decision:** [ ] Agree | [ ] Disagree | [ ] Modify: ____________

---

# SUMMARY: DECISION CHECKLIST

## FR-001: Area Ownership
| # | Question | AI Rec | Decision |
|---|----------|--------|----------|
| 1 | Migration strategy | Parallel run | [ ] A [ ] D [ ] M |
| 2 | Reconstruct history | Yes | [ ] A [ ] D [ ] M |
| 3 | Exclusivity | Exclusive per zip/property | [ ] A [ ] D [ ] M |
| 4 | Approval workflow | Payment-triggered | [ ] A [ ] D [ ] M |
| 5 | Cancellation timing | End of billing period | [ ] A [ ] D [ ] M |
| 6 | Ownership limit | No limit | [ ] A [ ] D [ ] M |
| 7 | Waitlist max | 5 positions | [ ] A [ ] D [ ] M |
| 8 | Waitlist priority | FIFO + customer bonus | [ ] A [ ] D [ ] M |
| 9 | Waitlist offer window | 48 hours | [ ] A [ ] D [ ] M |

## FR-002: WHMCS Billing
| # | Question | AI Rec | Decision |
|---|----------|--------|----------|
| 10 | Base price (SFR) | $99/month | [ ] A [ ] D [ ] M |
| 11 | Bundle tiers | 10%/15%/25% | [ ] A [ ] D [ ] M |
| 12 | Annual option | 20% discount | [ ] A [ ] D [ ] M |
| 13 | Promo code types | All 5 types | [ ] A [ ] D [ ] M |
| 14 | Failed payment retries | 3 retries, 7-day grace | [ ] A [ ] D [ ] M |
| 15 | Waitlist auto-notify | Yes, 24hr after cancel | [ ] A [ ] D [ ] M |

## FR-003: Content Configurator
| # | Question | AI Rec | Decision |
|---|----------|--------|----------|
| 16 | Phase 1 CTA types | Home Value + Newsletter + Social | [ ] A [ ] D [ ] M |
| 17 | Default CTA | A/B Test (4 vs 5) | [ ] A [ ] D [ ] M |
| 18 | Newsletter provider | Mailchimp | [ ] A [ ] D [ ] M |
| 19 | Agent access | All agents, self-service | [ ] A [ ] D [ ] M |
| 20 | Custom CTA text | No (Phase 1) | [ ] A [ ] D [ ] M |
| 21 | Cache duration | 5 minutes | [ ] A [ ] D [ ] M |

## Timeline
| # | Question | AI Rec | Decision |
|---|----------|--------|----------|
| 22 | Total duration | 9 weeks | [ ] A [ ] D [ ] M |
| 23 | Launch strategy | Phased rollout | [ ] A [ ] D [ ] M |

---

**A = Agree | D = Disagree | M = Modify**

---

## Next Steps After Review

1. **Stakeholder signs off** on all decisions
2. **IT provides** WHMCS Product ID and WHMCS.Net library
3. **Begin Sprint 51** with FR-001 Schema development
4. **Create sandbox** environment for testing

---

**Document Version:** 1.0  
**Created:** 12/14/2025  
**Author:** AI Assistant  
**Status:** PENDING STAKEHOLDER REVIEW

