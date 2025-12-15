# Feature Request Discovery Worksheet
## FR-002: WHMCS Area Billing Integration

---

**Meeting Date:** ____________________

**Attendees:** ____________________

**Facilitator:** ____________________

---

## Purpose
This worksheet captures key decisions needed before development begins on the WHMCS Area Billing Integration for Competition Command. Please discuss each question and document the decision.

---

# SECTION A: Pricing Configuration

### A1. Base Pricing
**What is the monthly base price per area?**

| Property Type | Proposed Price | Notes |
|---------------|----------------|-------|
| SFR (Single Family) | $________ | |
| Condo | $________ | |
| Townhouse | $________ | |
| Multi-Family | $________ | |

☐ Same price for all property types: $________

---

### A2. Bundle Discounts
**What discounts should apply for multiple areas?**

| Tier Name | Area Count | Discount % | Approved |
|-----------|------------|------------|----------|
| Single | 1 | 0% | ☐ Yes ☐ No |
| Starter | 2-3 | 10% | ☐ Yes ☐ No |
| Pro | 4-6 | 15% | ☐ Yes ☐ No |
| Enterprise | 7+ | 25% | ☐ Yes ☐ No |

**Alternative tier structure:**
```
_________________________________________________________________

_________________________________________________________________
```

---

### A3. Billing Cycle
**What billing cycles should be offered?**

☐ Monthly only  
☐ Monthly + Quarterly (5% discount)  
☐ Monthly + Quarterly + Annual (10% discount)  
☐ Other: ____________________

**Default billing cycle:** ____________________

---

# SECTION B: WHMCS Configuration

### B1. Product Setup
**WHMCS Product Details:**

| Setting | Value |
|---------|-------|
| Product Name | ________________________ |
| Product Group | ________________________ |
| Product ID (after creation) | ________ |
| Custom Field ID (for area name) | ________ |

---

### B2. Promo Code Strategy
**What types of promo codes are needed?**

| Type | Example | Who Can Create | Approved |
|------|---------|----------------|----------|
| Percentage off | 20% off first month | ☐ Admin ☐ Marketing | ☐ |
| Fixed amount | $25 off | ☐ Admin ☐ Marketing | ☐ |
| Free trial | 14 days free | ☐ Admin ☐ Marketing | ☐ |
| Free month | First month free | ☐ Admin ☐ Marketing | ☐ |
| Role-based | Founders get 50% | ☐ Admin only | ☐ |

---

### B3. Role-Based Discounts
**Should certain user roles get automatic discounts?**

| Role | Discount | Promo Code |
|------|----------|------------|
| Founder | ___% | ____________ |
| Partner | ___% | ____________ |
| Beta Tester | ___% | ____________ |
| Enterprise | ___% | ____________ |

---

# SECTION C: Provisioning & Deprovisioning

### C1. Order Processing
**When should the area be activated?**

☐ Immediately after payment capture  
☐ After admin review  
☐ After trial period ends  
☐ Other: ____________________

---

### C2. Failed Payment Handling
**What happens when payment fails?**

☐ Retry automatically (how many times? ____)  
☐ Send notification and wait  
☐ Suspend area immediately  
☐ Grace period of ____ days

---

### C3. Cancellation Policy
**When an agent cancels:**

| Question | Answer |
|----------|--------|
| When does billing stop? | ☐ Immediately ☐ End of period |
| Refund policy? | ☐ No refund ☐ Pro-rated ☐ Full if <7 days |
| When is area released? | ☐ Immediately ☐ End of period ☐ ____ days |
| Auto-provision waitlist? | ☐ Yes ☐ No ☐ Admin review |

---

### C4. Subscription Renewal
**Renewal handling:**

☐ Auto-renew (default)  
☐ Manual renewal required  
☐ Send reminder ____ days before

---

# SECTION D: Waitlist Integration

### D1. Auto-Provisioning
**When an area becomes available, should the system automatically provision the next waitlist person?**

☐ Yes - Fully automatic  
☐ Yes - After payment confirmation  
☐ No - Admin must approve  
☐ Other: ____________________

---

### D2. Waitlist Offer Window
**How long should a waitlisted agent have to accept?**

☐ 24 hours  
☐ 48 hours  
☐ 72 hours  
☐ Other: ________

**What happens if they don't respond?**

☐ Offer expires, notify next in queue  
☐ Extend once, then expire  
☐ Admin follows up manually

---

# SECTION E: Future - Commission Split (3+ Months Out)

### E1. Commission Split Interest
**Is commission split on transactions a priority?**

☐ High priority - Start scoping now  
☐ Medium priority - Scope after billing is live  
☐ Low priority - Future consideration

---

### E2. Split Model Preferences
**What split models should be supported?**

☐ Fixed percentage (e.g., 25% to TheGenie)  
☐ Tiered (higher volume = lower split)  
☐ Per-transaction fee (e.g., $500/transaction)  
☐ Hybrid (base + percentage)

**Notes:**
```
_________________________________________________________________

_________________________________________________________________
```

---

# SECTION F: Reporting & Monitoring

### F1. Required Reports
**Which billing reports are needed?**

| Report | Priority (1-5) | Frequency |
|--------|----------------|-----------|
| Revenue by area | _____ | _________ |
| Churn analysis | _____ | _________ |
| Bundle adoption | _____ | _________ |
| Promo code usage | _____ | _________ |
| Failed payments | _____ | _________ |
| MRR dashboard | _____ | _________ |

---

### F2. Alerts
**What automated alerts are needed?**

| Event | Alert Recipient | Method |
|-------|-----------------|--------|
| Failed payment | ☐ Admin ☐ Agent | ☐ Email ☐ SMS |
| Subscription canceled | ☐ Admin ☐ Agent | ☐ Email ☐ SMS |
| Waitlist provisioned | ☐ Admin ☐ Agent | ☐ Email ☐ SMS |
| Renewal upcoming | ☐ Agent | ☐ Email ☐ SMS |

---

# SECTION G: Technical Decisions

### G1. WHMCS.Net Library
**Current WHMCS.Net status:**

☐ Have DLL from production  
☐ Need to request from IT  
☐ Will use public NuGet (may need customization)

---

### G2. Existing Billing Handlers
**Should we follow the existing pattern from:**

☐ ListingCommandBillingHandler (transaction-based)  
☐ HandlerNCBilling (area-based) ← Recommended  
☐ New pattern

---

# Summary of Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Base price | | |
| Bundle discounts | | |
| Billing cycle | | |
| Cancellation policy | | |
| Waitlist auto-provision | | |
| Offer window | | |
| Commission split timing | | |

---

## Next Steps

| Action Item | Owner | Due Date |
|-------------|-------|----------|
| Create WHMCS product | | |
| Get WHMCS.Net DLL | | |
| Finalize pricing tiers | | |
| Create test promo codes | | |

---

**Document Prepared By:** AI Assistant  
**Date:** 12/13/2025  
**Feature Request:** FR-002  
**Version:** 1.0

---

*Please return completed worksheet to development team for specification finalization.*

