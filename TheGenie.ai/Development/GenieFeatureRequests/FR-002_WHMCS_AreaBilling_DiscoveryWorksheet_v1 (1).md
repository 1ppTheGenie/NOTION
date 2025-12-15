# Feature Request Discovery Worksheet
## FR-002: WHMCS Area Billing Integration
### Version 1.0

**Created:** 12/13/2025  
**Status:** DRAFT

---

**Meeting Date:** ____________________

**Attendees:** ____________________

**Facilitator:** ____________________

---

## Purpose
This worksheet captures key decisions needed before development begins on the WHMCS billing integration for Competition Command area purchases.

---

# SECTION A: WHMCS Configuration

### A1. WHMCS Product Setup
**Has a WHMCS product been created for Competition Command?**

☐ Yes - Product ID: ____________  
☐ No - Needs creation

**If no, what are the product details?**

| Field | Value |
|-------|-------|
| Product Name | Competition Command - Area |
| Product Type | Recurring |
| Billing Cycle | ☐ Monthly ☐ Quarterly ☐ Annual |
| Setup Fee | $________ or ☐ None |

---

### A2. WHMCS API Access
**Is the WHMCS.Net library accessible?**

☐ Yes - DLL path: ____________  
☐ No - Need to obtain  
☐ Unknown

**API Credentials available?**

☐ Yes - Stored in: ____________  
☐ No - Need to create

---

### A3. Custom Fields
**WHMCS custom field for area name?**

☐ Yes - Field ID: ____________  
☐ No - Need to create

**Other custom fields needed?**

| Field | Purpose | Created? |
|-------|---------|----------|
| Area Name | Display zip code/name | ☐ Yes ☐ No |
| Agent ID | Link to AspNetUsers | ☐ Yes ☐ No |
| Property Type | SFR/Condo/etc | ☐ Yes ☐ No |
| Other: ________ | ____________ | ☐ Yes ☐ No |

---

# SECTION B: Pricing Configuration

### B1. Base Monthly Pricing
**What is the base monthly price per area?**

☐ Same for all property types: $____________

☐ Different by property type:

| Property Type | Monthly Price |
|---------------|---------------|
| SFR (Single Family Residence) | $________ |
| Condo | $________ |
| Townhouse | $________ |
| Multi-Family | $________ |

---

### B2. Billing Cycle Options
**What billing cycles should be offered?**

| Cycle | Price | Discount | Offer? |
|-------|-------|----------|--------|
| Monthly | $________ | 0% | ☐ Yes ☐ No |
| Quarterly | $________ | ____% off | ☐ Yes ☐ No |
| Semi-Annual | $________ | ____% off | ☐ Yes ☐ No |
| Annual | $________ | ____% off | ☐ Yes ☐ No |

---

### B3. Setup Fees
**Should there be a one-time setup fee?**

☐ No setup fee  
☐ Yes - $____________  
☐ Waived with promo code

---

# SECTION C: Bundle Discounts

### C1. Bundle Tier Structure
**Should bundle discounts apply for multiple areas?**

☐ No bundle discounts  
☐ Yes - Define tiers:

| Tier Name | Area Count | Discount % | Approved? |
|-----------|------------|------------|-----------|
| Single | 1 | 0% | ☐ |
| ____________ | ____-____ | ____% | ☐ |
| ____________ | ____-____ | ____% | ☐ |
| ____________ | ____-____ | ____% | ☐ |
| ____________ | ____+ | ____% | ☐ |

---

### C2. Bundle Calculation
**How should bundle discounts be applied?**

☐ Discount applies to all areas equally  
☐ Discount applies only to areas above threshold  
☐ Flat amount discount per tier

---

### C3. Bundle Changes
**When an agent adds/removes areas:**

☐ Recalculate immediately (pro-rate current period)  
☐ Apply new tier on next billing cycle  
☐ Grandfather existing areas at old rate

---

# SECTION D: Promo Codes

### D1. Promo Code Types Needed
**Which promo code types should be supported?**

| Type | Example | Support? |
|------|---------|----------|
| Percentage off | 20% off first month | ☐ Yes ☐ No |
| Fixed amount off | $25 off first month | ☐ Yes ☐ No |
| Free trial (X days) | 14 days free | ☐ Yes ☐ No |
| Free month | First month free | ☐ Yes ☐ No |
| Role-based discount | Founders get 50% | ☐ Yes ☐ No |

---

### D2. Promo Code Restrictions
**What restrictions should be configurable?**

| Restriction | Support? |
|-------------|----------|
| Start/end date | ☐ Yes ☐ No |
| Max total uses | ☐ Yes ☐ No |
| Max uses per user | ☐ Yes ☐ No |
| New customers only | ☐ Yes ☐ No |
| Minimum area purchase | ☐ Yes ☐ No |
| Role-based eligibility | ☐ Yes ☐ No |

---

### D3. Existing Promo Codes
**Are there any existing promo codes to migrate?**

☐ No - Starting fresh  
☐ Yes - List below:

| Code | Type | Value | Status |
|------|------|-------|--------|
| ____________ | ____________ | ________ | ☐ Active ☐ Expired |
| ____________ | ____________ | ________ | ☐ Active ☐ Expired |
| ____________ | ____________ | ________ | ☐ Active ☐ Expired |

---

# SECTION E: Payment Handling

### E1. Accepted Payment Methods
**Which payment methods should be accepted?**

☐ Credit Card (via WHMCS)  
☐ PayPal  
☐ ACH/Bank Transfer  
☐ Invoice/Net Terms  
☐ Other: ____________

---

### E2. Failed Payment Handling
**What happens when a payment fails?**

**Retry Logic:**
- Number of retries: ________ attempts  
- Retry interval: ________ days between retries  
- Grace period before suspension: ________ days

**After max retries:**
☐ Cancel area immediately  
☐ Suspend area (can reactivate on payment)  
☐ Notify admin for manual handling

---

### E3. Payment Failure Notifications
**Who should be notified of failed payments?**

| Recipient | Email | SMS | In-App |
|-----------|-------|-----|--------|
| Agent/Customer | ☐ | ☐ | ☐ |
| Admin | ☐ | ☐ | ☐ |
| Billing Team | ☐ | ☐ | ☐ |

---

# SECTION F: Cancellation Rules

### F1. Cancellation Window
**When can an agent cancel an area?**

☐ Anytime  
☐ Only at end of billing period  
☐ X days notice required: ________ days

---

### F2. Refund Policy
**What is the refund policy on cancellation?**

☐ No refunds (use through end of paid period)  
☐ Pro-rated refund  
☐ Full refund within X days: ________ days  
☐ Case-by-case (admin discretion)

---

### F3. Re-purchase Restrictions
**After canceling, can an agent immediately re-purchase?**

☐ Yes - No restrictions  
☐ No - Cooling off period: ________ days  
☐ No - Same promo code cannot be reused

---

# SECTION G: FR-001 Integration

### G1. Area Ownership Activation
**Should area ownership be auto-activated on successful payment?**

☐ Yes - Immediate activation  
☐ No - Admin approval required after payment

---

### G2. Waitlist Integration
**When an area is canceled, should the waitlist be auto-notified?**

☐ Yes - Notify #1 in queue immediately  
☐ Yes - After a delay of ________ hours  
☐ No - Admin manually notifies

---

### G3. Content Configuration (FR-003)
**Should a default content configuration be created on activation?**

☐ Yes - Use default CTA set  
☐ Yes - Agent chooses during purchase  
☐ No - Agent configures later

---

# SECTION H: Reporting

### H1. Required Reports
**Which billing reports are needed?**

| Report | Priority (1-5) |
|--------|----------------|
| Revenue by area/month | ________ |
| Failed payments | ________ |
| Promo code usage | ________ |
| Bundle tier distribution | ________ |
| Churn/cancellation rate | ________ |
| Average revenue per agent | ________ |

---

### H2. Integration with External Systems
**Should billing data sync to other systems?**

☐ QuickBooks  
☐ Xero  
☐ Custom reporting database  
☐ None - WHMCS is the source of truth

---

# SECTION I: Future: Commission Split (Q2 2026)

### I1. Commission Model Interest
**Is the team interested in exploring a commission split model?**

☐ Yes - High priority  
☐ Yes - But not urgent  
☐ No - Not interested

---

### I2. Commission Split Concept
**If yes, what is the initial concept?**

| Lead Source | Commission % |
|-------------|--------------|
| Competition Command Lead | ________ % |
| Agent self-generated | ________ % |
| Referral | ________ % |

**Notes:**
```
_________________________________________________________________
_________________________________________________________________
```

---

# Summary of Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Base monthly price | | |
| Bundle tiers | | |
| Promo code types | | |
| Failed payment retries | | |
| Refund policy | | |
| Auto-activation | | |
| Waitlist notification | | |

---

## Next Steps

| Action Item | Owner | Due Date |
|-------------|-------|----------|
| Create WHMCS product | | |
| Get WHMCS.Net DLL | | |
| Confirm API credentials | | |
| Finalize pricing tiers | | |
| Create seed promo codes | | |

---

**Document Prepared By:** AI Assistant  
**Date:** 12/13/2025  
**Feature Request:** FR-002  
**Version:** 1.0

---

*Please return completed worksheet to development team for specification finalization.*

