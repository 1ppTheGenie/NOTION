# FR-002: WHMCS Area Billing Integration
## Design Brief
### Version 1.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FR-002 |
| **Feature Name** | WHMCS Area Billing Integration |
| **Design Owner** | TBD |
| **Status** | Discovery |

---

## Problem Statement

Currently, Competition Command area ownership has **no billing integration**. Areas are assigned manually without payment processing. This creates:

1. **No revenue capture** from area ownership
2. **No automated de-provisioning** when payments fail
3. **Manual intervention** required for billing
4. **No bundle/promo code** capability

---

## Proposed Solution

Integrate area purchases with WHMCS billing to:
- Automate payment capture on area purchase
- Support promotional pricing and bundle discounts
- De-provision areas on cancellation/non-payment
- Trigger waitlist notification on release

---

## User Stories

### Agent Stories

| ID | As a... | I want to... | So that... |
|----|---------|--------------|------------|
| US-01 | Agent | See my monthly cost before purchasing | I can budget appropriately |
| US-02 | Agent | Apply a promo code at checkout | I can get any available discounts |
| US-03 | Agent | See bundle pricing for multiple areas | I know I'm getting a volume discount |
| US-04 | Agent | Cancel my area subscription | I can stop billing if I no longer want it |
| US-05 | Agent | Receive invoices via email | I have records for my business |

### Admin Stories

| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| US-06 | Admin | See all area billing records | I can monitor revenue |
| US-07 | Admin | Process refunds | I can handle disputes |
| US-08 | Admin | Update pricing tiers | I can adjust strategy |
| US-09 | Admin | View failed payments | I can follow up with agents |

---

## UI/UX Concepts

### Agent: Area Purchase Flow

```
┌─────────────────────────────────────────────────────────┐
│  🗺️ Purchase Area: 92127 - Rancho Bernardo             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  OWNERSHIP DETAILS                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Area:        92127 - Rancho Bernardo            │   │
│  │ Type:        Competition Command (CC)           │   │
│  │ Property:    SFR + Condo                        │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  PRICING                                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Base Price:           $99.00/month              │   │
│  │ Bundle Discount:      -$10.00 (Growth tier)     │   │
│  │ Promo Code:           [LAUNCH25      ] [Apply]  │   │
│  │                       -$22.25 applied ✓         │   │
│  │ ─────────────────────────────────────────────── │   │
│  │ TOTAL:                $66.75/month              │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  PAYMENT                                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Card on file: •••• •••• •••• 4242              │   │
│  │ [Change Payment Method]                         │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│       [ Cancel ]              [ Complete Purchase ]     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Agent: My Areas - Billing Tab

```
┌─────────────────────────────────────────────────────────┐
│  MY AREAS                          [+ Add New Area]     │
├──────────┬──────────┬──────────┬───────────────────────┤
│ AREA     │ STATUS   │ MONTHLY  │ NEXT BILLING          │
├──────────┼──────────┼──────────┼───────────────────────┤
│ 92127    │ ✅ Active │ $89.00   │ Jan 15, 2026          │
│ 92014    │ ✅ Active │ $89.00   │ Jan 15, 2026          │
│ 92067    │ ✅ Active │ $89.00   │ Jan 15, 2026          │
├──────────┴──────────┴──────────┴───────────────────────┤
│ TOTAL MONTHLY: $267.00 (Growth Tier - 10% off)         │
│                                                         │
│ [ View Invoices ]  [ Update Payment ]  [ Manage Areas ] │
└─────────────────────────────────────────────────────────┘
```

### Admin: Billing Dashboard

```
┌─────────────────────────────────────────────────────────┐
│  AREA BILLING DASHBOARD                                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  MONTHLY REVENUE                                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Active Subscriptions:     89                    │   │
│  │ Total Monthly Revenue:    $7,821.00             │   │
│  │ Avg Revenue/Area:         $87.88                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ALERTS                                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⚠️ 3 payments failed in last 7 days            │   │
│  │ 📧 2 areas released to waitlist today           │   │
│  │ ✅ 5 new subscriptions this week                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  [ View All Billing ]  [ Export Report ]  [ Settings ]  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Conversion Rate** | 60% | Checkout starts → Completed purchases |
| **Payment Success** | 95% | First-attempt payment capture |
| **Churn Rate** | <5%/month | Monthly cancellations / active |
| **Bundle Adoption** | 40% | Multi-area owners / total owners |
| **Promo Usage** | 30% | Purchases with promo code |

---

## Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| FR-001: Area Ownership System | Feature | Required |
| WHMCS Product Configuration | Infrastructure | ⚠️ Blocker |
| Payment Gateway | Infrastructure | ✅ Available |

---

## Timeline Estimate

| Phase | Duration | Activities |
|-------|----------|------------|
| Discovery | 1 week | Finalize pricing, get WHMCS Product ID |
| Development | 2 weeks | Billing handler, DB schema, API endpoints |
| UI/UX | 1 week | Purchase flow, billing dashboard |
| Testing | 1 week | Payment scenarios, edge cases |
| **TOTAL** | **5 weeks** | |

---

## Open Questions

1. Should annual prepay be available at launch?
2. What email templates needed for billing notifications?
3. Integration with existing Intercom/CRM for billing issues?

---

*Document Version: 1.0 | Created: 12/13/2025 | Updated: 12/14/2025*

