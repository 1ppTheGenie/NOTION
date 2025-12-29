# Master Rules: Subscription Chargeback Disputes
**Version:** 1.0  
**Created:** 12/28/2025  
**Last Updated:** 12/28/2025  
**Author:** Cursor AI (Opus) + GPT Advisor Review  
**Status:** ✅ ACTIVE - Production Ready  
**Applies To:** Competition Command, Paisley Plus, Neighborhood Command (Recurring Subscriptions)

---

## 🎯 PURPOSE

These master rules govern the generation of chargeback dispute responses for **recurring subscription products**. Subscription disputes require different optimization than one-off purchases due to issuer psychology and reason code patterns.

---

## 📋 CRITICAL RULES

### Rule #1: TONE DISCIPLINE (Highest Priority)

**NEVER use aggressive or accusatory language.**

Issuers are checklist processors with discretion, not judges. Aggressive language triggers:
- Defensive reading
- "Merchant arguing" bias  
- Increased scrutiny

| ❌ NEVER USE | ✅ USE INSTEAD |
|-------------|----------------|
| "demonstrably false" | "not supported by the documented timeline" |
| "the customer lied" | "contradicted by the customer's own record" |
| "this is fraud" | "the claim does not match our records" |
| "clearly false" | "the timeline does not support this claim" |
| "customer's false claim" | "the stated reason does not align with documented events" |

**Impact:** This single change can improve analyst reception by +0.3 points.

---

### Rule #2: EXECUTIVE SUMMARY STRUCTURE (Subscription-Specific)

The Executive Summary for subscription disputes must answer **ONLY** these three questions:

1. **Was billing authorized?** (Recurring consent, payment history)
2. **When did cancellation occur?** (Relative to billing date)
3. **Does the claim match the timeline?** (Factual comparison)

**DO NOT include in Executive Summary:**
- Usage metrics (move to Service Delivery section)
- Detailed feature descriptions
- Technical implementation details

**STRUCTURE:** Maximum 6-7 bullets, strictly sequenced by timeline:
1. Subscription start date / duration
2. Billing authorization (recurring consent)
3. Payment history summary (X successful payments)
4. Disputed payment date/amount
5. Cancellation request date (relative to payment)
6. Dispute filing date
7. Timeline conclusion (neutral tone)

---

### Rule #3: EMPHASIS CALLOUTS (Use Sparingly)

**Limit "CRITICAL EVIDENCE" or "KEY FINDING" callouts to ONE per document.**

Overuse of emphasis markers:
- Reduces their impact
- Makes the document feel argumentative
- Triggers analyst skepticism

**Placement:** Use the single callout in the Timeline/Cancellation section only.

---

### Rule #4: TERMS OF SERVICE SECTION (Keep Concise)

Issuers only verify:
- Policy existence
- Policy acceptance  
- Timing relative to billing

Issuers do NOT adjudicate:
- Pro-rata fairness
- Customer satisfaction
- Future billing logic

**Keep Terms section to ~200 words maximum.** Focus on:
1. Billing cycle terms
2. Cancellation policy (when request must be made)
3. Proof of acceptance (checkbox, timestamp)

---

### Rule #5: PAYMENT HISTORY TABLE (Required for Subscriptions)

**Always include a complete payment history table** showing:
- All successful prior payments
- Consistent billing cadence
- No prior disputes
- Customer awareness of recurring billing

This demonstrates **behavioral consistency**, which issuers heavily weight.

**Format:**
| # | Date | Amount | Invoice | Status |
|---|------|--------|---------|--------|
| 1 | Feb 14, 2025 | $500.00 | 61246 | PAID |
| ... | ... | ... | ... | ... |
| 9 | Oct 14, 2025 | $500.00 | 62279 | DISPUTED |

---

### Rule #6: CANCELLATION TIMELINE PROOF (Core Win for Subscription Disputes)

Structure the cancellation evidence in this exact order:
1. **Payment date first** (anchor)
2. **Cancellation date second** (relative to payment)
3. **Customer's own words verbatim** (quoted)
4. **Gap calculation** (X days after payment)

This sequence is decisive for defeating "cancelled before being billed" claims.

---

### Rule #7: SUBSCRIPTION VS ONE-OFF DISTINCTION

**Never argue subscriptions like one-offs.**

| Dimension | One-Off (Listing Command) | Subscription (Competition Command) |
|-----------|---------------------------|-----------------------------------|
| Primary Evidence | Service delivery proof | Authorization + Billing pattern |
| Key Question | Was service delivered? | Was billing authorized? When was cancel? |
| Exec Summary Focus | Delivery metrics | Timeline sequencing |
| Usage Metrics | In Executive Summary | In Service Delivery section only |

---

## 📊 DOCUMENT STRUCTURE (Subscription Template)

| Page | Section | Content |
|------|---------|---------|
| 1 | Cover/Header | Reference table, Case details, ONE key finding callout |
| 2 | Executive Summary | 6-7 bullets (timeline-focused), Evidence checklist |
| 3 | Subscription Details | Service info, Payment history table |
| 4 | Cancellation Timeline | Timeline table, Customer quote, Gap analysis |
| 5 | Service Usage | Usage metrics, Device info |
| 6 | Support History | Contact records with timing relative to payment |
| 7 | Terms of Service | Concise policy summary (~200 words) |
| 8 | Merchant Request | Conclusion, Signature block |

---

## ✅ QUALITY CHECKLIST

Before generating any subscription dispute response, verify:

- [ ] No aggressive language ("demonstrably false", "lied", "fraud")
- [ ] Executive Summary is 6-7 bullets maximum, timeline-sequenced
- [ ] Only ONE emphasis callout in entire document
- [ ] Terms section is ~200 words or less
- [ ] Payment history table is complete
- [ ] Cancellation timeline shows: Payment → Cancel → Dispute sequence
- [ ] Customer's own words are quoted verbatim
- [ ] Usage metrics are NOT in Executive Summary

---

## 🎯 TARGET SCORE

Following these rules should produce:
- **Current baseline:** 9.2/10
- **With tone fixes:** 9.5/10
- **With all optimizations:** 9.7-9.8/10 (Subscription Gold Class)

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/28/2025 | Initial subscription dispute rules created from GPT advisor feedback on Susan Featherly Competition Command case. Documented tone discipline, executive summary structure, emphasis limits, and template differences from one-off disputes. |

---

*File: MASTER_RULES_SubscriptionDisputes_v1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\*

