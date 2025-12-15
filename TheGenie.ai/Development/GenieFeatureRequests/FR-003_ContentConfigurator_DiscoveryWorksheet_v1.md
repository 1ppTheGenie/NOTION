# FR-003: Content Configurator
## Discovery Worksheet
### Version 1.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

## Purpose
Discovery questions and AI-recommended answers for the Content Configurator feature that enables dynamic CTA and landing page selection.

---

## Section 1: CTA Configuration

### Q1: Should CTAs be managed in database vs hardcoded JavaScript?

**Recommendation:** Database-driven

**Rationale:**
- Enables UI-based management without code deployments
- Supports A/B testing with tracking
- Allows per-area customization
- Historical tracking of CTA performance

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q2: What CTA modes should be supported?

**Recommendation:** Three modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **Single** | One CTA always shown | Simple, consistent experience |
| **Rotation** | Cycle through CTAs | Variety, prevent banner blindness |
| **A/B Test** | Weighted random with tracking | Optimize for conversions |

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q3: Should "Smart Rotation" auto-optimize based on performance?

**Recommendation:** Yes (Phase 2)

**Logic:**
1. Track impressions and conversions per CTA
2. After 1000 impressions, calculate conversion rate
3. Increase weight for higher-performing CTAs
4. Never fully eliminate any CTA (minimum 10% weight)

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 2: Agent Customization

### Q4: Should agents be able to customize their own CTAs?

**Recommendation:** Limited customization

**Allowed:**
- Select from pre-approved CTA types
- Choose rotation vs single mode
- Set preferred CTA order

**Not Allowed (Admin Only):**
- Create new CTA types
- Modify CTA content/imagery
- Access A/B test analytics

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q5: Can agents have different configurations per area?

**Recommendation:** Yes, optional

**Default Behavior:**
- Agent's global setting applies to all areas
- Can override per-area if desired
- Fallback: System default if no agent config

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 3: Tracking & Analytics

### Q6: What metrics should be tracked for CTAs?

**Recommendation:**

| Metric | Description | Tracked At |
|--------|-------------|------------|
| Impressions | CTA displayed on page | Page load |
| Views | CTA popup shown (scroll/delay trigger) | Popup open |
| Interactions | User clicks any button | Button click |
| Submissions | Form submitted | Form submit |
| Conversions | Verified lead created | Backend |

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q7: How long should A/B tests run before declaring a winner?

**Recommendation:** 
- Minimum: 500 impressions per variant
- Maximum: 30 days
- Statistical significance: 95% confidence

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 4: Future CTAs (Phase 2)

### Q8: What new CTA types should be added?

**Recommendation:**

| CTA Type | Priority | Description |
|----------|----------|-------------|
| **Social Follow** | High | Follow agent on Instagram/Facebook |
| **Newsletter Signup** | High | Subscribe to market updates |
| **Video Consultation** | Medium | Schedule Zoom/video call |
| **Market Snapshot** | Medium | Quick stats popup (no form) |
| **Mortgage Pre-Qual** | Low | Partner lender integration |

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q9: Should custom CTA images be uploadable?

**Recommendation:** Phase 2

**Considerations:**
- Image moderation requirements
- Storage (Cloudflare Images existing)
- Performance impact
- Brand consistency concerns

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 5: Technical Considerations

### Q10: How to migrate from hardcoded CTAs without downtime?

**Recommendation:** Feature flag rollout

**Steps:**
1. Deploy database tables and API (feature flag OFF)
2. Migrate existing CTAs to database
3. Enable feature flag for internal testing
4. Gradual rollout by area/agent
5. Full production after 1 week validation

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

### Q11: Should CTA config be cached?

**Recommendation:** Yes, with short TTL

**Caching Strategy:**
- Cache config in Redis for 5 minutes
- Invalidate on config update
- Fallback to database on cache miss
- Include cache-buster for testing

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Section 6: Naming Considerations

### Q12: What should we call "A/B Testing" in the UI?

**Recommendation:** "Smart Rotation"

**Rationale (Tom Ferry principle):**
- Agents don't understand A/B testing
- "Smart Rotation" implies intelligence
- Emphasizes that system is helping them
- Reduces intimidation factor

**Status:** [ ] Confirmed [ ] Modified [ ] Rejected

---

## Summary

| Section | Questions | Confirmed | Pending |
|---------|-----------|-----------|---------|
| CTA Configuration | 3 | 0 | 3 |
| Agent Customization | 2 | 0 | 2 |
| Tracking & Analytics | 2 | 0 | 2 |
| Future CTAs | 2 | 0 | 2 |
| Technical | 2 | 0 | 2 |
| Naming | 1 | 0 | 1 |
| **TOTAL** | **12** | **0** | **12** |

---

## Dependencies

| Dependency | Status |
|------------|--------|
| Genie CLOUD access | ✅ Available |
| `utils.js` CTA definitions | ✅ Documented |
| Database schema approval | Pending |

---

*Document Version: 1.0 | Created: 12/13/2025 | Updated: 12/14/2025*

