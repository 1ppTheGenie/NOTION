# Competition Command Enhancement
## Master Discovery Package
### Version 1.0 | Created: 12/14/2025

---

## Executive Summary

This document consolidates discovery questions and strategic recommendations for the Competition Command product enhancement, spanning three interconnected Feature Requests:

| FR ID | Feature Name | Status | Priority |
|-------|--------------|--------|----------|
| FR-001 | Area Ownership & Waitlist System | Design Complete | High |
| FR-002 | WHMCS Area Billing Integration | Discovery | High |
| FR-003 | Content Configurator | Discovery | Medium |

---

## Strategic Framework

### Guiding Principles

Drawing from:
- **Steve Jobs**: Simplicity, elegant user experience
- **Alex Hormozi**: Value stack, offer engineering, risk reversal
- **Tom Ferry**: Agent psychology, territorial dominance
- **Elon Musk**: 10X thinking, audacious goals

### Core Positioning

> "We're not selling SMS campaigns. We're selling **territorial certainty**."

The agent who owns an area owns the **mindshare** of that community. Every text, every click, every lead reinforces their position as THE local expert.

---

## FR-001: Area Ownership & Waitlist System

### Strategic Context

This feature transforms "buying an area" into "claiming your territory." The waitlist creates **scarcity and urgency**.

### Key Discovery Questions

| # | Question | AI Recommendation | Rationale |
|---|----------|-------------------|-----------|
| 1 | Should areas be exclusive? | **Yes** | Exclusivity = premium pricing power |
| 2 | How long can someone hold an area? | **Indefinite (while paying)** | Encourages loyalty, reduces churn |
| 3 | What happens on cancellation? | **Immediate waitlist notification** | Creates urgency for waitlist |
| 4 | Should waitlist be visible? | **Yes (position only)** | Social proof, urgency |
| 5 | Waitlist acceptance window? | **48 hours** | Creates urgency without being unreasonable |

### Schema Summary

```
AreaOwnership → AreaOwnershipHistory → AreaCampaignHistory
      ↓
AreaWaitlist (FIFO queue with notifications)
```

---

## FR-002: WHMCS Area Billing Integration

### Strategic Context

Billing integration enables **sustainable revenue** from area ownership. The pricing structure should encourage multi-area ownership and reduce churn.

### Pricing Strategy (Hormozi Framework)

**Value Stack:**

| Component | Perceived Value |
|-----------|-----------------|
| Exclusive territory ownership | $500/month |
| Unlimited SMS campaigns | $300/month |
| Lead capture & CTA system | $200/month |
| Agent notifications | $150/month |
| Performance analytics | $100/month |
| **TOTAL PERCEIVED VALUE** | **$1,250/month** |
| **ACTUAL PRICE** | **$99/month** |

**Bundle Tiers:**

| Tier | Areas | Monthly/Area | Savings |
|------|-------|--------------|---------|
| Single | 1 | $99 | - |
| Growth | 2-3 | $89 | 10% |
| Pro | 4-5 | $79 | 20% |
| Enterprise | 6+ | $69 | 30% |

**Risk Reversal:**
- 30-day money-back guarantee
- "Area Swap" - switch areas once in first 90 days
- Performance guarantee: "If you don't get X leads, we'll extend free"

### Key Discovery Questions

| # | Question | AI Recommendation | Blocker? |
|---|----------|-------------------|----------|
| 1 | WHMCS Product ID? | Need from IT | ⚠️ YES |
| 2 | Annual prepay option? | Yes, 20% discount | No |
| 3 | Failed payment handling? | 7-day grace, then suspend | No |
| 4 | Refund policy? | No prorated refunds | No |
| 5 | Existing owner migration? | "Founder Rate" promo | No |

---

## FR-003: Content Configurator

### Strategic Context

CTAs are where **leads are born**. Moving from hardcoded to database-driven enables optimization and personalization.

### CTA Psychology (Tom Ferry Framework)

| CTA Type | Lead Psychology | Use When |
|----------|-----------------|----------|
| Home Value | Passive Intenders | Curious but not ready |
| Property Alerts | Active Searchers | Ready to engage |
| Contact Agent | High Intent | Ready to transact |
| Market Report | Information Seekers | Building trust |
| Social Follow | Relationship Builders | Long-term nurture |

### "Smart Rotation" Concept

Instead of "A/B Testing" (confusing for agents), use **"Smart Rotation"**:
- System automatically cycles through CTAs
- Learns which converts best
- Adjusts weights over time
- Agent sees simple "performance stars"

### Key Discovery Questions

| # | Question | AI Recommendation |
|---|----------|-------------------|
| 1 | Database vs hardcoded? | Database (flexibility) |
| 2 | Agent customization? | Limited (choose from approved) |
| 3 | Per-area config? | Yes (optional override) |
| 4 | Auto-optimization? | Phase 2 |
| 5 | New CTA types? | Social Follow, Newsletter (Phase 2) |

---

## Implementation Roadmap

### Phase 1: Foundation (Sprints 51-53)
- FR-001: Database schema, migration scripts
- FR-001: API endpoints for ownership management
- FR-002: Get WHMCS Product ID (blocker)
- FR-002: Billing handler development

### Phase 2: Integration (Sprints 54-55)
- FR-002: Bundle pricing, promo codes
- FR-003: CTA database schema
- FR-003: Admin UI for CTA management
- FR-003: Migrate existing CTAs

### Phase 3: Optimization (Sprints 56-57)
- FR-003: Smart Rotation implementation
- FR-003: Analytics dashboard
- All: End-to-end testing
- All: Production rollout

---

## Blockers & Action Items

| Item | Owner | Target | Status |
|------|-------|--------|--------|
| WHMCS Product ID for CC | IT Team | ASAP | ⚠️ BLOCKER |
| Existing owner list for migration | Data Team | Week 1 | Pending |
| Design review meeting | Product | Week 1 | Pending |
| Schema approval | Architect | Week 1 | Pending |

---

## Success Metrics

| Metric | Current | Target | Timeframe |
|--------|---------|--------|-----------|
| Area Revenue | $0/month | $10,000/month | Q1 2026 |
| Paid Conversion | 0% | 60% | Launch +30 days |
| Churn Rate | N/A | <5%/month | Ongoing |
| CTA Conversion | ~2% | 4% | Q2 2026 |
| Waitlist Signups | 0 | 50+ | Launch +60 days |

---

## Appendix: Data Insights

### Current Competition Command Performance

From `Genie_CC_Ownership_LIFETIME_2025-12-10_v5_iter2.csv`:

| Metric | Value |
|--------|-------|
| Active Areas | 89 |
| Total Campaigns | 2,000+ |
| Total Texts Sent | 500,000+ |
| Average CTR | 8.5% |
| Top CTR | 12.0% (92101 - Mike Blair) |
| Highest Leads | 888 (92127 - Jason Barry) |

### Top Performing Areas

| Zip | Owner | CTR | Leads |
|-----|-------|-----|-------|
| 92101 | Mike Blair | 12.0% | 316 |
| 91914 | Mike Blair | 9.3% | 302 |
| 92127 | Jason Barry | 9.0% | 888 |

---

## Next Steps

1. **Schedule Discovery Review** - Walk through questions with stakeholders
2. **Get WHMCS Product ID** - Critical blocker for FR-002
3. **Begin Sprint 51** - Start with FR-001 schema development
4. **Design Review** - UI mockups for agent portal changes

---

*Document Version: 1.0 | Created: 12/14/2025*
*Strategic Framework: Jobs • Hormozi • Ferry • Musk*

