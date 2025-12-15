# Feature Request Discovery Worksheet
## FR-003: Content Configurator

---

**Meeting Date:** ____________________

**Attendees:** ____________________

**Facilitator:** ____________________

---

## Purpose
This worksheet captures key decisions needed before development begins on the Content Configurator system. Please discuss each question and document the decision.

---

# SECTION A: CTA Types

### A1. New CTA Types Priority
**Which new CTA types should be implemented first?**

| CTA Type | Priority (1-5) | Phase | Notes |
|----------|----------------|-------|-------|
| Home Value (existing) | 1 | Now | ✅ Already exists |
| Newsletter Signup | _____ | _____ | |
| Social Follow | _____ | _____ | |
| Consultation Request | _____ | _____ | |
| Property Alert Signup | _____ | _____ | |
| Download Brochure | _____ | _____ | |

---

### A2. Newsletter Integration
**If Newsletter CTA is implemented, what email system should it integrate with?**

☐ Mailchimp  
☐ SendGrid  
☐ Constant Contact  
☐ Internal system (build custom)  
☐ Other: ____________________

**Should double opt-in be required?**
☐ Yes ☐ No ☐ Configurable per agent

---

### A3. Social Follow Platforms
**Which social platforms should be supported?**

☐ Facebook  
☐ Instagram  
☐ LinkedIn  
☐ YouTube  
☐ TikTok  
☐ Twitter/X  
☐ Other: ____________________

---

# SECTION B: Landing Pages

### B1. Available Templates
**Which landing page templates should be available for selection?**

| Template | Campaign Type | Priority |
|----------|---------------|----------|
| Just Sold | CC | ☐ High ☐ Med ☐ Low |
| Just Listed | LC | ☐ High ☐ Med ☐ Low |
| Market Activity | CC | ☐ High ☐ Med ☐ Low |
| Open House | LC | ☐ High ☐ Med ☐ Low |
| Area Stats | CC | ☐ High ☐ Med ☐ Low |
| Agent Bio | All | ☐ High ☐ Med ☐ Low |

---

### B2. Custom Templates
**Should agents be able to request custom landing page templates?**

☐ No - Only predefined templates  
☐ Yes - With admin approval  
☐ Yes - Self-service (enterprise tier)

---

# SECTION C: A/B Testing

### C1. Rotation Strategy
**What CTA rotation strategies should be supported?**

☐ Random (equal weight)  
☐ Weighted (configure percentages)  
☐ Sequential (rotate in order)  
☐ Time-based (switch every X hours)  
☐ All of the above

---

### C2. Statistical Significance
**What minimum sample size before declaring a winner?**

☐ 100 displays per variant  
☐ 500 displays per variant  
☐ 1000 displays per variant  
☐ 95% confidence interval calculation  
☐ Admin decision

---

### C3. Auto-Optimization
**Should the system auto-select winning CTAs?**

☐ No - Manual selection only  
☐ Yes - After reaching significance threshold  
☐ Yes - But require admin approval

---

# SECTION D: Configuration Scope

### D1. Configuration Level
**At what level should content be configurable?**

☐ Per agent (same for all areas)  
☐ Per area (different for each owned area)  
☐ Both (agent default + area override)

---

### D2. Who Can Configure?
**Who should be able to modify content configuration?**

| Configuration | Agent | Admin | Both |
|---------------|-------|-------|------|
| Landing page selection | ☐ | ☐ | ☐ |
| CTA selection | ☐ | ☐ | ☐ |
| A/B test setup | ☐ | ☐ | ☐ |
| Trigger settings | ☐ | ☐ | ☐ |
| Create new CTAs | ☐ | ☐ | ☐ |

---

### D3. Defaults
**What should be the default configuration for new agents?**

| Setting | Default Value |
|---------|---------------|
| Landing page | __________________ |
| CTA strategy | ☐ Single ☐ Rotating |
| Default CTA | __________________ |
| Trigger delay | ____ seconds |
| Scroll triggers | ☐ Enabled ☐ Disabled |
| Mobile banner | ☐ Enabled ☐ Disabled |

---

# SECTION E: Tracking & Analytics

### E1. Events to Track
**Which CTA events should be tracked?**

☐ Displayed (CTA shown to user)  
☐ Dismissed (user closed without action)  
☐ Clicked (user interacted)  
☐ Submitted (form submitted)  
☐ Verified (contact verified)  
☐ Converted (lead became client)

---

### E2. Metrics Dashboard
**What metrics should be shown to agents?**

| Metric | Show to Agent? | Show to Admin? |
|--------|----------------|----------------|
| Display count | ☐ | ☐ |
| Submission rate | ☐ | ☐ |
| Verification rate | ☐ | ☐ |
| A/B test results | ☐ | ☐ |
| Best performing CTA | ☐ | ☐ |
| Comparison to average | ☐ | ☐ |

---

### E3. Reporting Period
**What time periods should be available for analysis?**

☐ Last 7 days  
☐ Last 30 days  
☐ Last 90 days  
☐ Custom date range  
☐ All time

---

# SECTION F: Preview & Testing

### F1. Preview Capability
**How should preview work?**

☐ Static preview (screenshot-like)  
☐ Interactive preview (functional)  
☐ Test mode (real page, marked as test)

---

### F2. Testing Before Launch
**Should agents be able to test CTAs before activating?**

☐ No - Activate immediately  
☐ Yes - Preview only  
☐ Yes - Send test to self

---

# SECTION G: Migration & Compatibility

### G1. Existing Campaigns
**What happens to existing CC campaigns when this launches?**

☐ Continue with hardcoded CTAs (no change)  
☐ Migrate to default database CTAs  
☐ Prompt agents to configure on next login

---

### G2. Fallback Behavior
**If database CTA fails to load, what should happen?**

☐ Use hardcoded fallback (current CTAs)  
☐ Skip CTA entirely  
☐ Show error message

---

# SECTION H: Future Considerations

### H1. Expanded CTA Management (FR-004)
**Should we scope a separate FR for comprehensive CTA management?**

☐ Yes - Create FR-004 for CTA Management System  
☐ No - Include everything in FR-003  
☐ Later - After FR-003 is live

**Potential FR-004 scope:**
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### H2. Paisley Integration
**How should this integrate with Paisley AI?**

☐ Paisley can suggest CTAs based on performance  
☐ Paisley can auto-optimize A/B tests  
☐ Paisley handles all content (no configurator needed)  
☐ Separate concern - not integrated initially

---

# Summary of Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Priority CTA types | | |
| Newsletter platform | | |
| Configuration level | | |
| A/B test strategy | | |
| Default configuration | | |
| Fallback behavior | | |

---

## Next Steps

| Action Item | Owner | Due Date |
|-------------|-------|----------|
| Finalize CTA types for Phase 1 | | |
| Design landing page thumbnails | | |
| Create A/B test algorithm spec | | |
| Define tracking event schema | | |

---

**Document Prepared By:** AI Assistant  
**Date:** 12/13/2025  
**Feature Request:** FR-003  
**Version:** 1.0

---

*Please return completed worksheet to development team for specification finalization.*

