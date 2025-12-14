# Feature Request Discovery Worksheet
## FR-002: WHMCS Area Billing Integration
### Version 2.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

**GitHub:** [FR-002_WHMCS_AreaBilling_DiscoveryWorksheet_v2.md](https://github.com/1ppTheGenie/NOTION/blob/main/TheGenie.ai/Development/FeatureRequests/FR-002_WHMCS_AreaBilling_DiscoveryWorksheet_v2.md)

---

## Purpose
AI-recommended answers for WHMCS billing integration. Review each recommendation, then mark: ✅ Agree | ❌ Disagree | ✏️ Modify

---

# SECTION 1: Pricing Strategy

### Q1. What is the base monthly price for a single area?

**AI ANSWER:** **$99/month**

**RATIONALE (Hormozi - Value Stack):**

| Component | Perceived Value |
|-----------|---------------:|
| Exclusive territory ownership | $500/mo |
| Unlimited SMS campaigns to neighbors | $300/mo |
| Lead capture + CTA popups | $200/mo |
| Real-time agent notifications | $150/mo |
| Performance analytics | $100/mo |
| **TOTAL PERCEIVED VALUE** | **$1,250/mo** |
| **YOUR PRICE** | **$99/mo** |

**COMPETITOR ANCHORING:**
- Zillow Premier Agent: $300-1000/mo per zip
- Realtor.com: $200-500/mo per zip
- Facebook/Google Ads: $500-2000/mo for equivalent reach

**MARGIN ANALYSIS:**
- Twilio cost per area: ~$8-15/mo (based on Nov 2025 data)
- Versium cost per area: ~$5-10/mo (22 credits × volume)
- **Gross margin: 75-85%**

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q2. How should bundle discounts be structured?

**AI ANSWER:**

| Tier | Areas | Price/Area | Monthly Total | Savings vs Single |
|------|:-----:|:----------:|:-------------:|:-----------------:|
| **Starter** | 1 | $99 | $99 | - |
| **Growth** | 2-3 | $89 | $178-267 | 10% ($10-30/mo) |
| **Pro** | 4-5 | $79 | $316-395 | 20% ($80-100/mo) |
| **Enterprise** | 6+ | $69 | $414+ | 30% ($180+/mo) |

**RATIONALE (Hormozi - Ascension Model):**
- Starter gets them in the door
- Growth rewards commitment
- Pro is the sweet spot (most profitable tier)
- Enterprise for power users (Jason Barry type)

**PSYCHOLOGY (Tom Ferry):**
- Agents think in territories: "I want Del Mar AND Rancho Santa Fe"
- Bundle discount removes friction to expand
- "Get your second area at 10% off" = easy upsell

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q3. Should we offer annual prepay?

**AI ANSWER:** **Yes - 20% discount (2 months free)**

**PRICING:**
| Plan | Monthly | Annual | Annual Savings |
|------|:-------:|:------:|:--------------:|
| Single | $99 | $950 | $238 (2.4 mo free) |
| Growth (2) | $178 | $1,710 | $426 |
| Pro (4) | $316 | $3,034 | $758 |

**RATIONALE:**
- Cash flow: Collect 10 months upfront
- Commitment: 12-month lock-in reduces churn
- LTV: Even at discount, guaranteed revenue

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q4. What promotional codes should be available at launch?

**AI ANSWER:**

| Code | Discount | Target | Expires |
|------|----------|--------|---------|
| `FOUNDER40` | 40% off forever | Existing owners (6+ mo) | 30 days |
| `FOUNDER25` | 25% off 1 year | Existing owners (3-6 mo) | 30 days |
| `LAUNCH25` | 25% off first month | New customers | 60 days |
| `SECOND50` | 50% off 2nd area | Expansion | Ongoing |
| `ANNUAL20` | 20% off annual | Annual conversion | Ongoing |

**RATIONALE (Hormozi - Risk Reversal):**
- Founders feel valued, reduces cancellation risk
- Launch discount reduces first-purchase friction
- Second50 drives multi-area adoption

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 2: WHMCS Configuration

### Q5. What WHMCS Product ID should be used?

**AI ANSWER:** **⚠️ BLOCKER - Need IT to create/identify**

**REQUIRED ACTION:**
1. IT creates new WHMCS product: "Competition Command - Area Ownership"
2. Product type: Recurring subscription
3. Billing cycle: Monthly (default) + Annual option
4. Product ID returned to development team

**EXISTING REFERENCE:**
- `Config.ListingCommandWhmcsProductId` - pattern to follow
- `Config.WhmcsProductId` (Neighborhood Command)

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q6. Should we use existing WHMCS client records?

**AI ANSWER:** **Yes - Use existing WhmcsClientId**

**RATIONALE:**
- Agents already have WHMCS accounts from Listing Command, NC, etc.
- Single billing relationship = simpler for agent
- Pattern established in `ListingCommandBillingHandler.cs`:
```csharp
var whmcsClientId = Proxy.GetUserWhmcs(command.AspNetUserId)?.WhmcsClientId;
```

**EDGE CASE:** If no WHMCS account exists, create one during first area purchase (existing flow handles this).

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q7. How should the billing handler be structured?

**AI ANSWER:** Follow existing pattern - new handler class

**PROPOSED:** `CompetitionCommandBillingHandler.cs`

**KEY METHODS (from LC pattern):**
1. `Process()` - Main billing flow
2. `CheckForPromoCode()` - Validate/apply discounts
3. `AddOrder()` - Create WHMCS order
4. `CapturePayment()` - Process payment
5. `UpdateBilling()` - Record result

**ADDITIONS FOR CC:**
- Bundle pricing calculation
- Multi-area discount logic
- Area provisioning trigger

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 3: Payment Handling

### Q8. How should failed payments be handled?

**AI ANSWER:**

| Day | Action | Channel |
|:---:|--------|---------|
| 0 | Payment fails | Email + SMS |
| 3 | First reminder | Email |
| 7 | **SUSPEND** area (no campaigns) | Email + SMS + In-App |
| 14 | Final warning | Email + SMS |
| 21 | **RELEASE** to waitlist | Email |

**DURING SUSPENSION (Day 7-21):**
- Area stays "reserved" (not given to waitlist yet)
- No SMS campaigns sent
- Agent notifications paused
- Dashboard shows "Payment Required" banner

**AFTER RELEASE (Day 21):**
- `AreaOwnership.Status` = 'Ended'
- `EndReason` = 'Payment Failure'
- First waitlist member notified
- Former owner can rejoin waitlist

**RATIONALE:**
- 7 days = reasonable grace period
- 21 days = matches credit card retry cycles
- Suspension before release = retention opportunity

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q9. Should there be prorated refunds for mid-cycle cancellation?

**AI ANSWER:** **No prorated refunds**

**RATIONALE:**
- Standard SaaS practice
- Simplifies billing reconciliation
- Clear in terms of service
- Agent keeps access until period ends

**EXCEPTION:** Admin discretion for disputes/errors

**TERMS LANGUAGE:** "Cancellation takes effect at end of current billing period. No partial refunds."

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 4: Existing Owner Migration

### Q10. How should current area owners be transitioned to billing?

**AI ANSWER:**

**TIMELINE:**
| Day | Action |
|:---:|--------|
| -30 | Announcement email: "Billing coming, Founder discount available" |
| -14 | Reminder: "2 weeks to lock in Founder rate" |
| -7 | Final warning: "Last week for Founder discount" |
| 0 | **BILLING STARTS** - Must have payment method |
| +7 | Grace period ends - Suspend if no payment |
| +14 | Release to waitlist if still unpaid |

**FOUNDER RATES:**

| Current Tenure | Discount | Duration |
|----------------|:--------:|----------|
| 6+ months | 40% off | Forever |
| 3-6 months | 25% off | 1 year |
| < 3 months | 15% off | 6 months |

**RATIONALE (Hormozi - Grandfather Clause):**
- Rewards loyalty
- Reduces cancellation shock
- "Forever" creates lock-in for best customers
- Tiered approach is fair

**ESTIMATED IMPACT:**
- 89 active areas (from report)
- If 60% convert at avg $79/mo = $4,200/mo new revenue
- If 40% churn = 35 areas for waitlist

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q11. What payment methods should be accepted?

**AI ANSWER:** **Credit Card only (via WHMCS)**

**RATIONALE:**
- WHMCS already handles CC processing
- Automatic recurring billing
- Retry logic built-in
- No manual invoicing needed

**FUTURE (Phase 2):**
- ACH/Bank transfer for Enterprise
- Invoice billing for large accounts

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 5: Billing Triggers

### Q12. What triggers area provisioning?

**AI ANSWER:**

**FLOW:**
1. Agent selects area in portal
2. System checks availability (`AreaOwnership` table)
3. If available → Payment form displayed
4. Payment captured via WHMCS
5. On success:
   - Create `AreaOwnership` record (Status = 'Active')
   - Create `AreaCampaignHistory` initial record
   - Send confirmation email
   - Enable area in agent dashboard
6. On failure:
   - Show error message
   - No records created
   - Suggest retry/contact support

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q13. What triggers area de-provisioning?

**AI ANSWER:**

**CANCELLATION FLOW:**
1. Agent requests cancellation (or payment fails Day 21)
2. `AreaOwnership.Status` = 'Ended'
3. `AreaOwnership.EndDate` = End of billing period (or immediate for payment failure)
4. `AreaOwnership.EndReason` = 'Cancelled' or 'Payment Failure'
5. Waitlist notification triggered
6. Campaigns stop at `EndDate`

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 6: Future Scope (Q2 2026)

### Q14. Commission split model requirements?

**AI ANSWER:** **Scope for Q2 2026 - Not Phase 1**

**CONCEPT:**
- Agent pays reduced monthly ($49) + commission on closed transactions
- Commission: 10-15% of referral fee received
- Requires: Lead → Transaction tracking integration
- Requires: MLS transaction data matching

**CONSIDERATIONS:**
- Complex revenue recognition
- Dispute handling process
- Agent trust issues ("prove the lead was mine")
- Longer sales cycles (RE transactions take months)

**RECOMMENDATION:** Build robust lead tracking now (FR-001/FR-003) to enable commission model later.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 7: Reporting Requirements

### Q15. What billing reports are needed?

**AI ANSWER:**

| Report | Priority | Frequency |
|--------|:--------:|-----------|
| Monthly Revenue by Area | 1 | Monthly |
| Payment Failure Report | 2 | Weekly |
| Churn Analysis | 3 | Monthly |
| Promo Code Usage | 4 | Monthly |
| Bundle Tier Distribution | 5 | Quarterly |

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# Summary of AI Recommendations

| Question | AI Recommendation |
|----------|-------------------|
| Base price | $99/month |
| Bundle discount | 10-30% based on tier |
| Annual prepay | Yes, 20% off |
| WHMCS Product ID | BLOCKER - Need from IT |
| Payment failure | 7-day grace, 21-day release |
| Prorated refunds | No |
| Migration approach | 30-day notice + Founder rates |
| Commission split | Phase 2 (Q2 2026) |

---

## Blockers

| # | Blocker | Owner | Status |
|:-:|---------|-------|--------|
| 1 | WHMCS Product ID | IT Team | ⚠️ WAITING |
| 2 | Existing owner list | Data Team | Pending |
| 3 | Legal review of terms | Legal | Pending |

---

## Reviewer Sign-off

**Reviewed By:** ____________________

**Date:** ____________________

**Overall Status:** [ ] Approved [ ] Approved with Changes [ ] Needs Discussion

---

*Document Version: 2.0 | Created: 12/13/2025 | Updated: 12/14/2025*
*AI Recommendations by: Cursor AI*
*Strategic Frameworks: Alex Hormozi (Pricing/Offers) • Tom Ferry (Agent Psychology)*

