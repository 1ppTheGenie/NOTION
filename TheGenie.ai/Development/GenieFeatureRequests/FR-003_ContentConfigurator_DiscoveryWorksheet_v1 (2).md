# Feature Request Discovery Worksheet
## FR-003: Content Configurator
### Version 1.0

**Created:** 12/13/2025  
**Status:** DRAFT

---

**Meeting Date:** ____________________

**Attendees:** ____________________

**Facilitator:** ____________________

---

## Purpose
This worksheet captures key decisions needed before development begins on the Content Configurator system for per-area CTA and landing page customization.

---

# SECTION A: Current State

### A1. Current CTA Usage
**Which CTAs are currently in production?**

| CTA ID | Name | Campaign | Active? |
|--------|------|----------|---------|
| 2 | Home Value Estimate | LC | ☐ Yes ☐ No |
| 3 | Home Value Estimate v2 | LC | ☐ Yes ☐ No |
| 4 | Property Valuation | CC | ☐ Yes ☐ No |
| 5 | Property Valuation v2 | CC | ☐ Yes ☐ No |
| 8 | Just Sold Property | CC | ☐ Yes ☐ No |
| 9 | Just Listed Property | CC | ☐ Yes ☐ No |

**Notes:**
```
_________________________________________________________________
```

---

### A2. Current Performance
**What is the current CTA conversion rate?**

| Metric | Current Value |
|--------|---------------|
| Average display → submission rate | ________ % |
| Average submission → verification rate | ________ % |
| Best performing CTA | ____________ |
| Worst performing CTA | ____________ |

---

### A3. Pain Points
**What are the top problems with the current CTA system?**

1. ________________________________________________________________

2. ________________________________________________________________

3. ________________________________________________________________

---

# SECTION B: Agent Configuration

### B1. Configuration Access
**Should all agents have access to content configuration?**

☐ Yes - All agents can customize  
☐ No - Only premium/enterprise agents  
☐ Tiered access (some options require upgrade)

---

### B2. CTA Selection
**How many CTAs should an agent be able to select?**

| Mode | Max CTAs | Allow? |
|------|----------|--------|
| Single | 1 | ☐ Yes ☐ No |
| A/B Test | 2 | ☐ Yes ☐ No |
| A/B Test | 3+ | ☐ Yes ☐ No |
| Rotation | Unlimited | ☐ Yes ☐ No |

---

### B3. Landing Page Selection
**Should agents be able to select landing page templates?**

☐ Yes - Full selection  
☐ Yes - Limited options  
☐ No - System assigned

**If yes, how many templates should be available?**
- Current templates to include: ____________
- New templates needed: ____________

---

### B4. Custom Content
**Should agents be able to customize CTA text?**

| Field | Customizable? |
|-------|---------------|
| CTA Title | ☐ Yes ☐ No |
| CTA Subtitle | ☐ Yes ☐ No |
| CTA Body | ☐ Yes ☐ No |
| Button Text | ☐ Yes ☐ No |
| Image | ☐ Yes ☐ No |

---

### B5. Preview Capability
**Should agents be able to preview their configuration?**

☐ Yes - Live preview in UI  
☐ Yes - Test link to view  
☐ No - Save and see in production

---

# SECTION C: CTA Types

### C1. New CTA Categories
**Which new CTA types should be supported?**

| CTA Type | Priority (1-5) | Include? |
|----------|----------------|----------|
| Home Value (existing) | ________ | ☐ |
| Newsletter Signup | ________ | ☐ |
| Social Follow (Instagram) | ________ | ☐ |
| Social Follow (Facebook) | ________ | ☐ |
| Consultation Request | ________ | ☐ |
| Property Alerts | ________ | ☐ |
| Custom (agent-defined) | ________ | ☐ |

---

### C2. Newsletter Integration
**If newsletter CTAs are included:**

**Newsletter provider?**
☐ Mailchimp  
☐ Sendgrid  
☐ Constant Contact  
☐ Other: ____________  
☐ Store locally (no integration)

**API credentials available?**
☐ Yes  
☐ No - Need to set up

---

### C3. Social Follow Integration
**If social CTAs are included:**

**Which platforms?**
☐ Instagram  
☐ Facebook  
☐ TikTok  
☐ YouTube  
☐ LinkedIn  
☐ Other: ____________

**Tracking method?**
☐ Click tracking only  
☐ Integration with platform analytics  
☐ UTM parameters

---

### C4. Consultation Request
**If consultation CTAs are included:**

**Calendar integration?**
☐ Calendly  
☐ Acuity  
☐ Google Calendar  
☐ Other: ____________  
☐ Simple form (no calendar)

---

# SECTION D: A/B Testing

### D1. A/B Test Configuration
**Should agents be able to run A/B tests?**

☐ Yes - Self-service  
☐ Yes - Admin setup required  
☐ No - Single CTA only

---

### D2. A/B Test Settings
**If A/B testing is enabled:**

**Minimum sample size before declaring winner?**
☐ 50 displays  
☐ 100 displays  
☐ 500 displays  
☐ Custom: ____________

**Auto-select winner?**
☐ Yes - System picks winner at sample size  
☐ No - Agent manually selects

---

### D3. A/B Test Weighting
**Should agents be able to set custom weights?**

☐ Yes - 0-100% per CTA  
☐ No - Equal split only

---

# SECTION E: Performance Tracking

### E1. Metrics to Track
**Which metrics should be visible to agents?**

| Metric | Track? | Show to Agent? |
|--------|--------|----------------|
| Displays | ☐ Yes ☐ No | ☐ Yes ☐ No |
| Submissions (CTA click) | ☐ Yes ☐ No | ☐ Yes ☐ No |
| Verifications | ☐ Yes ☐ No | ☐ Yes ☐ No |
| Conversion rate | ☐ Yes ☐ No | ☐ Yes ☐ No |
| Comparison to average | ☐ Yes ☐ No | ☐ Yes ☐ No |

---

### E2. Reporting Period
**What time periods should be available?**

☐ Last 7 days  
☐ Last 30 days  
☐ Last 90 days  
☐ Custom date range  
☐ All time

---

# SECTION F: Default Configuration

### F1. Default CTA for New Areas
**What should be the default CTA for new areas?**

☐ Home Value Estimate (CTA ID 4)  
☐ Property Valuation v2 (CTA ID 5)  
☐ Admin configurable default  
☐ A/B test (randomized)

---

### F2. Default Landing Page
**What should be the default landing page?**

☐ Standard Competition Command page  
☐ Modern theme  
☐ Agent selects during purchase

---

### F3. Override Capability
**Should admins be able to override agent configurations?**

☐ Yes - Full override  
☐ Yes - For specific areas only  
☐ No - Agent control only

---

# SECTION G: Technical Considerations

### G1. Caching
**How long should configurations be cached?**

☐ No caching (real-time)  
☐ 1 minute  
☐ 5 minutes  
☐ 15 minutes  
☐ Other: ____________

---

### G2. Fallback Behavior
**If database configuration fails:**

☐ Use hardcoded default CTA  
☐ Show no CTA  
☐ Retry with timeout

---

### G3. Migration Strategy
**How should existing areas get configurations?**

☐ Create default config for all existing areas now  
☐ Create config lazily on first access  
☐ Admin manually assigns

---

# SECTION H: UI/UX

### H1. Configuration Location
**Where should agents access content configuration?**

☐ "My Areas" page - per area settings  
☐ Separate "Content" section in dashboard  
☐ During area purchase flow  
☐ All of the above

---

### H2. Complexity Level
**How complex should the UI be?**

☐ Simple - just pick from list  
☐ Intermediate - some customization  
☐ Advanced - full control

---

### H3. Help/Guidance
**Should there be guidance for agents?**

☐ Tooltips on each option  
☐ "Recommended" badges  
☐ Best practices documentation  
☐ Video tutorial  
☐ None needed

---

# SECTION I: Future Scope

### I1. Visual CTA Builder
**Is a visual CTA builder (drag-and-drop) desired?**

☐ Yes - High priority  
☐ Yes - Future phase  
☐ No - Not needed

---

### I2. Agent Branding
**Should agents be able to add their branding?**

| Element | Allow? |
|---------|--------|
| Logo | ☐ Yes ☐ No |
| Colors | ☐ Yes ☐ No |
| Photo | ☐ Yes ☐ No |
| Tagline | ☐ Yes ☐ No |

---

### I3. Multi-Language Support
**Is multi-language CTA support needed?**

☐ Yes - Launch requirement  
☐ Yes - Future phase  
☐ No - English only

---

# Summary of Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Agent access level | | |
| CTA types to include | | |
| A/B testing enabled | | |
| Newsletter provider | | |
| Default CTA | | |
| Cache duration | | |
| UI complexity | | |

---

## Next Steps

| Action Item | Owner | Due Date |
|-------------|-------|----------|
| Finalize CTA types | | |
| Set up newsletter integration | | |
| Create landing page templates | | |
| Design agent UI mockups | | |
| Begin database schema | | |

---

**Document Prepared By:** AI Assistant  
**Date:** 12/13/2025  
**Feature Request:** FR-003  
**Version:** 1.0

---

*Please return completed worksheet to development team for specification finalization.*

