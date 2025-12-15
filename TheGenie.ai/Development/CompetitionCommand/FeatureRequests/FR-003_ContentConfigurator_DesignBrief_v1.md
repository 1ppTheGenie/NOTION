# FR-003: Content Configurator
## Design Brief
### Version 1.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FR-003 |
| **Feature Name** | Content Configurator |
| **Design Owner** | TBD |
| **Status** | Discovery |

---

## Problem Statement

The current Genie CLOUD CTA system is **hardcoded in JavaScript** (`utils.js`), creating several issues:

1. **No flexibility** - Adding/modifying CTAs requires code changes
2. **No A/B testing** - Can't optimize CTA performance
3. **No personalization** - Same CTAs for all areas/agents
4. **No tracking** - Limited visibility into CTA performance

---

## Proposed Solution

Create a **database-driven content configuration system** with:
- Admin UI to manage CTA definitions
- Configuration UI to assign CTAs to areas/agents
- Smart rotation with automatic optimization
- Built-in analytics and A/B testing

---

## User Stories

### Admin Stories

| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| US-01 | Admin | Create new CTA types | I can expand marketing options |
| US-02 | Admin | Edit CTA content | I can update messaging |
| US-03 | Admin | Configure default CTAs | All areas have baseline config |
| US-04 | Admin | View CTA performance | I can identify winners |
| US-05 | Admin | Set up A/B tests | I can optimize conversions |

### Agent Stories (Phase 2)

| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| US-06 | Agent | Choose my CTA preferences | I can personalize my experience |
| US-07 | Agent | See which CTAs perform best | I can make informed choices |

---

## UI Concepts

### Admin: CTA Library

```
┌─────────────────────────────────────────────────────────┐
│  📚 CTA LIBRARY                      [+ New CTA]        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐ ┌─────────────────┐               │
│  │ 🏠 Home Value   │ │ 📊 Market Report│               │
│  │   Estimate      │ │                 │               │
│  │                 │ │                 │               │
│  │ [Preview][Edit] │ │ [Preview][Edit] │               │
│  │ 👁 12,450 views │ │ 👁 8,230 views  │               │
│  │ ✓ 2.4% convert │ │ ✓ 1.8% convert │               │
│  └─────────────────┘ └─────────────────┘               │
│                                                         │
│  ┌─────────────────┐ ┌─────────────────┐               │
│  │ 🔔 Property     │ │ 📞 Contact      │               │
│  │   Alerts        │ │    Agent        │               │
│  │                 │ │                 │               │
│  │ [Preview][Edit] │ │ [Preview][Edit] │               │
│  │ 👁 6,120 views  │ │ 👁 4,890 views  │               │
│  │ ✓ 3.1% convert │ │ ✓ 2.8% convert │               │
│  └─────────────────┘ └─────────────────┘               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Admin: Create/Edit CTA

```
┌─────────────────────────────────────────────────────────┐
│  ✏️ EDIT CTA: Home Value Estimate                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  BASIC INFO                                             │
│  Name: [Home Value Estimate                        ]    │
│  Type: [Valuation ▼]                                   │
│                                                         │
│  CONTENT                                                │
│  Title:    [Personalized Home Value Estimate      ]    │
│  Subtitle: [Discover Your Home's True Worth       ]    │
│  Body:     [Interested in a personalized...       ]    │
│            [                                      ]    │
│                                                         │
│  BUTTON                                                 │
│  Text: [Get My Estimate            ]                   │
│  After Submit: [Great! Your request has been...]      │
│                                                         │
│  TRIGGER                                                │
│  ○ Delay: [__] seconds after page load                 │
│  ● Scroll: [30]% down the page                         │
│  ○ Exit Intent                                          │
│                                                         │
│  IMAGE                                                  │
│  [📷 Upload Image] or [🔗 Image URL]                   │
│                                                         │
│       [ Cancel ]    [ Preview ]    [ Save Changes ]     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Admin: Smart Rotation Setup

```
┌─────────────────────────────────────────────────────────┐
│  ⚡ SMART ROTATION CONFIGURATION                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  SCOPE                                                  │
│  Apply to: ● All Competition Command Areas              │
│            ○ Specific Areas: [Select...]               │
│                                                         │
│  CTAs IN ROTATION (drag to reorder)                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 1. 🏠 Home Value Estimate                       │   │
│  │    Performance: ⭐⭐⭐⭐ (2.4% conversion)        │   │
│  │    Auto-weight: 35%                              │   │
│  ├─────────────────────────────────────────────────┤   │
│  │ 2. 🔔 Property Alerts                           │   │
│  │    Performance: ⭐⭐⭐⭐⭐ (3.1% conversion)       │   │
│  │    Auto-weight: 40%                              │   │
│  ├─────────────────────────────────────────────────┤   │
│  │ 3. 📞 Contact Agent                             │   │
│  │    Performance: ⭐⭐⭐⭐ (2.8% conversion)        │   │
│  │    Auto-weight: 25%                              │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  [+ Add CTA to Rotation]                                │
│                                                         │
│  OPTIMIZATION                                           │
│  ☑ Auto-optimize weights based on performance          │
│  ☑ Minimum 10% weight for all CTAs                     │
│  ☐ Notify me when a clear winner emerges               │
│                                                         │
│       [ Cancel ]              [ Save & Activate ]       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Analytics Dashboard

```
┌─────────────────────────────────────────────────────────┐
│  📈 CTA PERFORMANCE ANALYTICS                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  DATE RANGE: [Last 30 Days ▼]       [Export CSV]       │
│                                                         │
│  OVERVIEW                                               │
│  ┌────────────┬────────────┬────────────┬────────────┐ │
│  │ IMPRESSIONS│   VIEWS    │ SUBMISSIONS│ CONVERSIONS│ │
│  │   45,230   │   12,450   │   1,890    │    456     │ │
│  │            │   (27.5%)  │   (15.2%)  │   (24.1%)  │ │
│  └────────────┴────────────┴────────────┴────────────┘ │
│                                                         │
│  BY CTA                                                 │
│  ┌────────────────────┬──────┬──────┬──────┬────────┐ │
│  │ CTA                │Views │Submis│Conv. │Rate    │ │
│  ├────────────────────┼──────┼──────┼──────┼────────┤ │
│  │ 🔔 Property Alerts │4,120 │ 680  │ 164  │ 3.98%  │ │
│  │ 🏠 Home Value      │4,890 │ 520  │ 118  │ 2.41%  │ │
│  │ 📞 Contact Agent   │3,440 │ 690  │ 174  │ 5.06%  │ │
│  └────────────────────┴──────┴──────┴──────┴────────┘ │
│                                                         │
│  🏆 TOP PERFORMER: Contact Agent (5.06% conversion)    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| **CTA Conversion Rate** | ~2% | 4% | Submissions / Views |
| **Admin Time to Create CTA** | N/A (code deploy) | < 5 minutes | UI workflow |
| **A/B Test Cycle Time** | N/A | < 2 weeks | Time to statistical significance |
| **Agent Satisfaction** | N/A | 4.5/5 | Survey |

---

## Design Principles

1. **Simplicity** - Agent-facing UI uses friendly terms ("Smart Rotation" not "A/B Test")
2. **Visual Feedback** - Performance indicators use stars and percentages
3. **Drag & Drop** - Reordering CTAs should be intuitive
4. **Preview** - Always show what CTA will look like before saving

---

## Timeline Estimate

| Phase | Duration | Activities |
|-------|----------|------------|
| Discovery | 1 week | Finalize questions, approve design |
| Schema & API | 2 weeks | Database, backend implementation |
| Admin UI | 2 weeks | CTA manager, configuration UI |
| Migration | 1 week | Migrate existing CTAs, testing |
| Analytics | 1 week | Tracking, dashboard |
| **TOTAL** | **7 weeks** | |

---

## Dependencies

| Dependency | Status |
|------------|--------|
| Genie CLOUD codebase | ✅ Available |
| React/Solid.js experience | ✅ Available |
| Cloudflare Images (for uploads) | ✅ Available |

---

*Document Version: 1.0 | Created: 12/13/2025 | Updated: 12/14/2025*

