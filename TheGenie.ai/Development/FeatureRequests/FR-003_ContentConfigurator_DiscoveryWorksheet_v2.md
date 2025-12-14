# Feature Request Discovery Worksheet
## FR-003: Content Configurator
### Version 2.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

**GitHub:** [FR-003_ContentConfigurator_DiscoveryWorksheet_v2.md](https://github.com/1ppTheGenie/NOTION/blob/main/TheGenie.ai/Development/FeatureRequests/FR-003_ContentConfigurator_DiscoveryWorksheet_v2.md)

---

## Purpose
AI-recommended answers for Content Configurator feature. Review each recommendation, then mark: ✅ Agree | ❌ Disagree | ✏️ Modify

---

# SECTION 1: Architecture Decision

### Q1. Should CTAs be database-driven or stay hardcoded in JavaScript?

**AI ANSWER:** **Database-driven**

**CURRENT STATE (from `utils.js` analysis):**
- 9 CTAs hardcoded in JavaScript
- Changes require code deployment
- No per-agent or per-area customization
- No A/B testing capability
- No performance tracking

**PROPOSED STATE:**
- CTAs stored in SQL database
- Admin UI for CRUD operations
- Per-agent configuration optional
- A/B testing with statistical tracking
- Real-time performance dashboards

**RATIONALE (Steve Jobs - Flexibility):**
- "It just works" - Admins can tweak without developers
- Faster iteration on what converts
- Enables personalization at scale

**MIGRATION PATH:**
1. Create database tables
2. Migrate existing 9 CTAs to database
3. Update `utils.js` to fetch from API (or embed at build)
4. Feature flag rollout

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q2. What CTA configuration modes should be supported?

**AI ANSWER:**

| Mode | Description | Use Case |
|------|-------------|----------|
| **Single** | One CTA always shown | Simplicity, brand consistency |
| **Rotation** | Cycle through CTAs sequentially | Variety, prevent banner blindness |
| **Smart Rotation** | Weighted random based on performance | Optimization, maximize conversions |

**SMART ROTATION LOGIC:**
1. All CTAs start with equal weight (100)
2. Track: Impressions, Clicks, Submissions, Conversions
3. After 500 impressions, recalculate weights:
   - Higher conversion = higher weight
   - Minimum weight = 10 (never fully eliminate)
4. Weekly recalculation

**WHY "SMART ROTATION" NOT "A/B TEST" (Tom Ferry):**
- Agents don't understand statistics
- "Smart" implies the system is helping them
- Removes intimidation factor
- Same result, better perception

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 2: CTA Configuration

### Q3. What CTA properties should be configurable?

**AI ANSWER:**

**VISIBLE TO USER:**
| Property | Type | Example |
|----------|------|---------|
| `ctaTitle` | string | "Personalized Home Value Estimate" |
| `ctaSubTitle` | string | "Discover Your Home's True Worth" |
| `ctaBody` | string | "Interested in a personalized valuation?" |
| `ctaImage` | URL | Cloudflare Images URL |
| `ctaDisclaimer` | string[] | Legal text paragraphs |
| `ctaSubmitButtonText` | string | "Yes, I'm Interested!" |
| `ctaResponse` | string | "Great! Your request has been submitted!" |

**BEHAVIOR:**
| Property | Type | Example |
|----------|------|---------|
| `scrollUpPercentage` | int | 0 (disabled) |
| `scrollDownPercentage` | int | 30 (trigger at 30% scroll) |
| `delay` | int | 5 (seconds before popup) |
| `ctaShowContactForm` | bool | true |
| `enabled` | bool | true |

**TRACKING:**
| Property | Type | Purpose |
|----------|------|---------|
| `ctaId` | int | Unique identifier |
| `ctaName` | string | Internal name for reporting |
| `LeadTagTypeId` | int | Tag applied to lead on submit |

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q4. What CTAs exist today and should be migrated?

**AI ANSWER:** Based on `utils.js` analysis:

| ctaId | Name | LeadTagTypeId | Used By |
|:-----:|------|:-------------:|---------|
| 1 | Property Alerts | 48 | - |
| 2 | Home Value | 48 | LC |
| 3 | Alert Signup | 48 | LC |
| 4 | Insider Access | 48 | CC |
| 5 | Market Pulse | 48 | CC |
| 6 | Property Search | 48 | LC |
| 7 | Neighborhood Intel | 48 | LC |
| 8 | Market Watch | 48 | CC |
| 9 | Property Scout | 48 | CC |

**OBSERVATIONS:**
- All use LeadTagTypeId = 48 (CTA Submitted)
- LC uses: 2, 3, 6, 7
- CC uses: 4, 5, 8, 9
- CTA 1 appears unused

**MIGRATION:** Direct 1:1 migration to database, no content changes.

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 3: Agent Customization

### Q5. Should agents be able to customize their CTAs?

**AI ANSWER:** **Limited customization**

**ALLOWED:**
| Capability | Agent | Admin |
|------------|:-----:|:-----:|
| Select from approved CTAs | ✅ | ✅ |
| Choose Single vs Rotation | ✅ | ✅ |
| Set preferred CTA order | ✅ | ✅ |
| Enable/disable specific CTAs | ✅ | ✅ |
| Create new CTA types | ❌ | ✅ |
| Modify CTA content/images | ❌ | ✅ |
| Access A/B analytics | ❌ | ✅ |

**RATIONALE (Steve Jobs - Constraint = Freedom):**
- Too many options = paralysis
- Curated choices = quality control
- Agents focus on selling, not configuring
- Admins optimize based on data

**DEFAULT BEHAVIOR:**
1. System default applies if no agent config
2. Agent config overrides system default
3. Per-area config overrides agent default

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q6. Can agents have different configurations per area?

**AI ANSWER:** **Yes, optional override**

**HIERARCHY:**
```
System Default
    ↓ (override)
Agent Default
    ↓ (override)
Area-Specific Config
```

**USE CASE:**
- Agent owns 92127 (affluent) and 91914 (starter homes)
- 92127: Home Value CTA (luxury positioning)
- 91914: Property Alerts CTA (active searchers)

**IMPLEMENTATION:**
- `AgentCtaConfig` table (agent-level)
- `AreaCtaConfig` table (area-level override)
- Fallback logic in API

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 4: Tracking & Analytics

### Q7. What metrics should be tracked for each CTA?

**AI ANSWER:**

| Metric | Definition | Tracked When |
|--------|------------|--------------|
| **Impressions** | CTA code loaded on page | Page load with CTA enabled |
| **Views** | Popup actually displayed | Scroll/delay trigger fires |
| **Interactions** | User clicks any element | Button click in popup |
| **Submissions** | Form submitted | Form submit event |
| **Conversions** | Verified lead created | Backend lead verification |

**CALCULATED METRICS:**
| Metric | Formula |
|--------|---------|
| View Rate | Views / Impressions |
| Interaction Rate | Interactions / Views |
| Submission Rate | Submissions / Views |
| Conversion Rate | Conversions / Submissions |

**CURRENT TRACKING GAP:**
- LeadTagTypeId 48 = CTA Submitted (exists)
- LeadTagTypeId 51 = Opt Out (exists)
- LeadTagTypeId 52 = Verified (exists)
- **MISSING:** Impression and View tracking

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q8. How long should A/B tests run before declaring a winner?

**AI ANSWER:**

| Criteria | Threshold |
|----------|-----------|
| Minimum impressions per variant | 500 |
| Maximum test duration | 30 days |
| Statistical confidence required | 95% |

**LOGIC:**
1. Test runs until EITHER 500 impressions per variant OR 30 days
2. Calculate conversion rates
3. Apply chi-squared test for significance
4. If 95% confidence: Declare winner, increase weight
5. If not significant: Continue test OR inconclusive

**REPORTING:**
- Daily: Raw counts
- Weekly: Performance trends
- End of test: Winner recommendation

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 5: New CTA Types (Phase 2)

### Q9. What new CTA types should be added?

**AI ANSWER:**

| CTA Type | Priority | Description | Lead Value |
|----------|:--------:|-------------|------------|
| **Social Follow** | HIGH | Follow agent on Instagram/Facebook | Low (nurture) |
| **Newsletter Signup** | HIGH | Subscribe to market updates | Medium (engagement) |
| **Video Consultation** | MEDIUM | Schedule Zoom/video call | High (intent) |
| **Market Snapshot** | MEDIUM | Quick stats popup (no form) | None (engagement) |
| **Mortgage Pre-Qual** | LOW | Partner lender integration | High (qualified) |

**SOCIAL FOLLOW DETAILS:**
- Links to agent's social profiles
- No form required (just click to follow)
- Tracks clicks per platform
- Enables retargeting audiences

**NEWSLETTER SIGNUP DETAILS:**
- Email only (no phone required)
- Lower friction than full CTA
- Drip campaign integration
- Monthly market update template

**RATIONALE (Tom Ferry - Relationship Ladder):**
1. Social Follow = Awareness
2. Newsletter = Interest
3. Home Value CTA = Consideration
4. Contact Agent = Decision

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q10. Should custom CTA images be uploadable?

**AI ANSWER:** **Phase 2 - Admin only**

**CONCERNS:**
- Image moderation needed (inappropriate content)
- File size limits (performance)
- Aspect ratio consistency (UI breaking)
- Brand dilution risk

**RECOMMENDATION:**
1. Phase 1: Curated image library (20-30 options)
2. Phase 2: Admin upload with:
   - Auto-resize to standard dimensions
   - Content moderation (manual or AI)
   - Cloudflare Images storage (existing)

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 6: Technical Implementation

### Q11. How to migrate from hardcoded CTAs without downtime?

**AI ANSWER:** **Feature flag rollout**

**STEPS:**
| Step | Action | Duration |
|:----:|--------|----------|
| 1 | Deploy database tables + API (flag OFF) | Day 1 |
| 2 | Migrate existing CTAs to database | Day 2 |
| 3 | Enable flag for internal testing | Day 3-5 |
| 4 | Enable for 10% of traffic | Day 6-8 |
| 5 | Monitor, fix issues | Day 9-12 |
| 6 | Enable for 50% of traffic | Day 13-15 |
| 7 | Full production rollout | Day 16+ |

**ROLLBACK PLAN:**
- Flag OFF = instant revert to hardcoded
- No data loss (database persists)
- 5-minute recovery time

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q12. Should CTA configuration be cached?

**AI ANSWER:** **Yes - Redis with 5-minute TTL**

**STRATEGY:**
| Layer | Cache | TTL |
|-------|-------|-----|
| Browser | LocalStorage | Session |
| CDN | Cloudflare | 1 minute |
| API | Redis | 5 minutes |
| Database | Source of truth | N/A |

**INVALIDATION:**
- On CTA update: Clear Redis key
- On agent config change: Clear agent-specific key
- Cache-buster param for testing: `?ctaRefresh=1`

**PERFORMANCE:**
- Current: ~50ms (hardcoded)
- Target: <100ms (cached)
- Fallback: <500ms (database direct)

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

### Q13. What database schema is needed?

**AI ANSWER:**

**TABLES:**
```
CtaDefinition (master CTA library)
├── CtaId (PK)
├── CtaName
├── CtaTitle, CtaSubTitle, CtaBody, etc.
├── LeadTagTypeId
├── IsActive
├── CreatedDate, ModifiedDate

CtaGroup (for rotation sets)
├── CtaGroupId (PK)
├── GroupName
├── RotationMode (Single/Rotation/Smart)
├── IsDefault

CtaGroupMember (CTAs in a group)
├── CtaGroupId (FK)
├── CtaId (FK)
├── Weight (for Smart Rotation)
├── SortOrder

AgentCtaConfig (agent preferences)
├── AspNetUserId (FK)
├── CtaGroupId (FK)
├── IsActive

AreaCtaConfig (area overrides)
├── AreaOwnershipId (FK)
├── CtaGroupId (FK)

CtaPerformance (tracking)
├── CtaId (FK)
├── Date
├── Impressions, Views, Interactions, Submissions, Conversions
```

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# SECTION 7: Naming & UX

### Q14. What should we call "A/B Testing" in the agent UI?

**AI ANSWER:** **"Smart Rotation"**

**RATIONALE (Tom Ferry - Agent Psychology):**
- Agents are NOT data scientists
- "A/B Testing" sounds technical, scary
- "Smart" implies AI/intelligence helping them
- "Rotation" is intuitive (things cycle)

**UI COPY:**
- ❌ "Enable A/B Testing"
- ✅ "Use Smart Rotation to find what works best"

**TOOLTIP:**
> "Smart Rotation automatically shows different offers to visitors and learns which ones get the best response. We'll optimize for you over time."

**Your Decision:** [ ] Agree [ ] Disagree [ ] Modify: _______________

---

# Summary of AI Recommendations

| Question | AI Recommendation |
|----------|-------------------|
| Architecture | Database-driven (not hardcoded) |
| CTA modes | Single, Rotation, Smart Rotation |
| Agent customization | Limited (choose from approved) |
| Per-area config | Yes, optional override |
| Tracking metrics | Impressions → Views → Submissions → Conversions |
| A/B test duration | 500 impressions OR 30 days, 95% confidence |
| New CTA types (Phase 2) | Social Follow, Newsletter Signup |
| Custom images | Phase 2, Admin only |
| Migration approach | Feature flag rollout |
| Caching | Redis, 5-minute TTL |
| UI naming | "Smart Rotation" (not A/B Testing) |

---

## Dependencies

| Dependency | Status |
|------------|--------|
| Genie CLOUD access | ✅ Available |
| `utils.js` CTA definitions | ✅ Documented |
| Redis caching infrastructure | ✅ Existing |
| Cloudflare Images | ✅ Existing |
| Database schema approval | ⏳ Pending |

---

## Reviewer Sign-off

**Reviewed By:** ____________________

**Date:** ____________________

**Overall Status:** [ ] Approved [ ] Approved with Changes [ ] Needs Discussion

---

*Document Version: 2.0 | Created: 12/13/2025 | Updated: 12/14/2025*
*AI Recommendations by: Cursor AI*
*Strategic Frameworks: Steve Jobs (Simplicity) • Tom Ferry (Agent Psychology)*

