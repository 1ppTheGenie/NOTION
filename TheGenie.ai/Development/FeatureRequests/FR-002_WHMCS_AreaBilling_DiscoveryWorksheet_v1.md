# FR-002: WHMCS Area Billing Integration
## Discovery Worksheet
### Version 1.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

## Purpose
This worksheet documents discovery questions, stakeholder answers, and AI-recommended approaches for the WHMCS Area Billing Integration feature.

---

## Section 1: Pricing & Offer Engineering

### Q1: What is the base monthly price for a single area?

**Recommendation:** $99/month

**Rationale (Hormozi Framework):**
- Value Stack: $1,250/month perceived value for $99
- Includes: Exclusive territory, unlimited campaigns, lead capture, agent notifications
- Price anchored against competitor ad spend ($500-2000/month on Zillow)

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q2: How should bundle discounts be structured?

**Recommendation:**

| Tier | Areas | Price/Area | Total Savings |
|------|-------|------------|---------------|
| Single | 1 | $99 | - |
| Growth | 2-3 | $89 | Up to $30/mo |
| Pro | 4-5 | $79 | Up to $100/mo |
| Enterprise | 6+ | $69 | Up to $180+/mo |

**Rationale:** Encourages multi-area ownership → higher LTV, lower churn

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q3: What promotional codes should be available at launch?

**Recommendation:**

| Code | Discount | Use Case |
|------|----------|----------|
| `LAUNCH25` | 25% first month | Initial adoption |
| `SECOND50` | 50% off 2nd area | Expansion incentive |
| `ANNUAL20` | 20% off annual | Cash flow, commitment |
| `REFER50` | $50 credit | Referral program |

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 2: WHMCS Integration

### Q4: What WHMCS Product ID should be used for Competition Command areas?

**Status:** ⚠️ BLOCKER - Awaiting IT response

**Action Required:** Request from IT team to create/identify WHMCS product

---

### Q5: Should we use the existing WHMCS client or create new billing records?

**Recommendation:** Use existing WHMCS client record

**Rationale:** 
- Agents already have WHMCS accounts from other products
- Single billing relationship simplifies agent experience
- Follow pattern from `ListingCommandBillingHandler.cs`

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q6: How should payment failures be handled?

**Recommendation:**
1. Grace period: 7 days to update payment method
2. Suspension: Area paused, not released
3. Final warning: Day 14 email
4. Release: Day 21, area goes to waitlist

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 3: Cancellation & De-provisioning

### Q7: When an area is canceled, how quickly should it be released to waitlist?

**Recommendation:** Immediate release, 48-hour acceptance window

**Flow:**
1. Owner cancels → Area status = "Ended"
2. System notifies first in waitlist immediately
3. Waitlist member has 48 hours to accept
4. If declined/expired → Next in line notified

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q8: Should there be a prorated refund for mid-cycle cancellations?

**Recommendation:** No prorated refunds

**Rationale:**
- Standard SaaS practice
- Simplifies billing
- Clear in terms of service
- Exception: Admin discretion for disputes

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 4: Existing Owner Migration

### Q9: How should existing area owners be transitioned to billing?

**Recommendation:** Grandfather period + opt-in

**Approach:**
1. Notify existing owners of upcoming billing
2. 30-day grace period to activate billing
3. Special "Founder Rate" promo code
4. Auto-release if not activated after 30 days

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q10: Should current owners get any special pricing?

**Recommendation:** Yes - "FOUNDER" rate

| Tenure | Discount |
|--------|----------|
| 6+ months | 40% off (forever) |
| 3-6 months | 25% off (1 year) |
| < 3 months | 15% off (6 months) |

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 5: Future Scope (Q2 2026)

### Q11: Commission split model requirements?

**Recommendation:** Scope for Q2 2026

**Initial Framework:**
- Agent pays reduced monthly ($49) + commission on transactions
- Commission: 10-15% of referral fee received
- Tracking via GenieLeadId → TransactionId mapping
- Requires MLS transaction data integration

**Status:** [ ] Future Scope [ ] Modified [ ] Rejected

---

## Summary

| Section | Questions | Confirmed | Pending |
|---------|-----------|-----------|---------|
| Pricing | 3 | 0 | 3 |
| WHMCS Integration | 3 | 0 | 3 |
| Cancellation | 2 | 0 | 2 |
| Migration | 2 | 0 | 2 |
| Future | 1 | 0 | 1 |
| **TOTAL** | **11** | **0** | **11** |

---

## Blockers

| # | Issue | Owner | Target Date |
|---|-------|-------|-------------|
| 1 | WHMCS Product ID needed | IT Team | ASAP |
| 2 | Existing owner list for migration planning | Data Team | Before launch |

---

*Document Version: 1.0 | Created: 12/13/2025 | Updated: 12/14/2025*

