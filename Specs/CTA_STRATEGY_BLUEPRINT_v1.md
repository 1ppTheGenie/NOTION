# Call to Action Strategy - Complete Blueprint

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Complete blueprint for implementing the Genie Engagement Call to Action Strategy |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial blueprint

---

## 🎯 EXECUTIVE SUMMARY

**Project Name:** Genie Engagement Call to Action Strategy  
**Goal:** Replace high-friction CTAs with soft-touch, value-first engagement  
**Target:** 15-25% engagement rate (vs. current 2-5%)  
**Timeline:** Phase 0 (Christmas 2025) - 3 pilot zip codes

---

## 🏗️ ARCHITECTURE OVERVIEW

### System Components

```
┌─────────────────────────────────────────────────┐
│           SMS Campaign (Existing)               │
│         Community Info → Short URL               │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│         Landing Page (Genie Cloud)              │
│      Property Details + Neighborhood Info        │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│         CTA Popup (New Component)               │
│    "Follow Us on Facebook" (Single Click)        │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│      Success State (SMS Permission + Report)     │
│  SMS Checkbox + "Get Your Insider Report" Button │
└──────────────────┬──────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
┌──────────────┐    ┌──────────────────────┐
│ myneighborhood.re │    │  Facebook Page (New Tab) │
│  Digital Report   │    │  Community Page Follow   │
│  + More CTAs      │    │                          │
└──────────┬─────────┘    └──────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────┐
│        Nurture Sequence (SMS)                   │
│  7-Day Content Cycle → Trust Building            │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│        Agent Handoff (When Hot)                  │
│    Structured Process + Tracking                 │
└─────────────────────────────────────────────────┘
```

---

## 📊 DATA FLOW

### Engagement Tracking

```
User Action → Event → Database Record → Tags
```

**Events:**
1. **CTA Display** → `CtaEvent` → `Cta10Display`
2. **Follow Click** → `CtaEvent` → `SoftOptIn, FollowNeighborhood, FacebookFollow`
3. **SMS Opt-In** → `SmsOptIn` → `SmsOptIn, Tcpacompliant`
4. **Report View** → `CtaEvent` → `ReportViewed, NeighborhoodInsights`
5. **Facebook Follow** → Track separately (Facebook API)

### Database Schema

**New Tables:**
```sql
-- Facebook Community Pages
CREATE TABLE FacebookCommunityPages (
  ZipCode VARCHAR(10) PRIMARY KEY,
  FacebookPageId VARCHAR(50),
  FacebookPageUrl VARCHAR(255),
  MyNeighborhoodReportUrl VARCHAR(255),
  CreatedDate DATETIME,
  IsActive BIT
);

-- SMS Opt-In (if new table needed)
CREATE TABLE SmsOptIn (
  SmsOptInId INT PRIMARY KEY IDENTITY,
  GenieLeadId INT,
  PhoneNumber VARCHAR(20),
  ConsentTimestamp DATETIME,
  ConsentMethod VARCHAR(50), -- 'Checkbox', 'Form', etc.
  ConsentSource VARCHAR(50), -- 'FollowCTA', 'LandingPage', etc.
  OptOutTimestamp DATETIME NULL,
  IsActive BIT
);
```

**Updated Tables:**
- `GenieLead` - Add new tags for tracking
- `CtaEvent` - Track new CTA events
- `NotificationQueue` - SMS nurture sequence

---

## 🔌 API & INTEGRATION POINTS

### Facebook API

**Available:**
- ✅ `GetPages` - Get existing pages
- ✅ `GetPage` - Get page details
- ✅ `GetPageInsights` - Get engagement metrics
- ✅ Post to page (with permissions)
- ❌ `CreatePage` - NOT allowed (manual only)

**Implementation:**
```javascript
// Get Facebook page URL from database
const facebookPageUrl = await getFacebookPageUrl(zipCode);

// Redirect to page
window.open(facebookPageUrl, '_blank');
```

### SMS/Twilio API

**Existing:**
- ✅ Send SMS
- ✅ Track delivery
- ✅ Opt-out handling

**New:**
- ⏳ SMS opt-in storage
- ⏳ Nurture sequence triggers
- ⏳ 7-day content cycle automation

### myneighborhood.re API

**Needed:**
- ⏳ Report generation endpoint
- ⏳ Zip code data endpoint
- ⏳ CTA tracking endpoint

**Implementation:**
```javascript
// Generate report URL
const reportUrl = `https://myneighborhood.re/${zipCode}`;

// Redirect to report
window.location.href = reportUrl;
```

### Genie Cloud API

**Existing:**
- ✅ Landing page generation
- ✅ CTA component rendering
- ✅ Lead creation/update

**Updates Needed:**
- ⏳ New CTA component (single-click mode)
- ⏳ SMS permission capture
- ⏳ Facebook redirect logic

---

## 🎨 UI/UX COMPONENTS

### CTA Popup Component

**File:** `_LeadCtaTag.jsx`

**Features:**
- Single-click opt-in mode
- SMS permission checkbox
- Facebook redirect
- myneighborhood.re redirect
- Success state management

**Props:**
```javascript
{
  ctaId: 10,
  ctaTitle: "Your Neighborhood Updates",
  ctaSubTitle: "Get weekly insights about your area",
  ctaBody: "Market trends • Local events • Home tips",
  ctaSubmitButtonText: "f Follow Us on Facebook",
  ctaShowContactForm: false,
  ctaSingleClickOptIn: true,
  ctaSocialProof: "Join 1,247 neighbors already following",
  ctaFacebookPageUrl: "https://facebook.com/...",
  ctaMyNeighborhoodUrl: "https://myneighborhood.re/...",
  delay: 3,
  scrollDownPercentage: 50
}
```

### myneighborhood.re Template

**Components:**
- Market overview section
- Neighborhood insights
- Additional CTAs (email, Facebook)
- Agent contact (soft)

**Design:**
- Community-branded
- Mobile-responsive
- Fast loading
- Value-focused

---

## 🔄 WORKFLOW AUTOMATION

### Nurture Sequence

**Trigger:** SMS opt-in OR Follow click OR Report download

**Sequence:**
```
Week 1: Market Monday SMS
  → Value content, no ask
  
Week 2: Tip Tuesday SMS
  → Home improvement tips
  
Week 3: Community Spotlight SMS
  → Local events, community news
  
Week 4: Soft Opt-In Ask
  → "Want personalized updates?" (optional email)
  
Week 5+: Continue Nurture
  → Build trust, deliver value
```

**Automation:**
- Scheduled SMS sends
- Content rotation (7-day cycle)
- Engagement tracking
- Lead progression (cool → warm → hot)

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 0: Pilot (Christmas 2025)

**Setup:**
- [ ] Create 3-5 Facebook pages (manual)
- [ ] Store page IDs in database
- [ ] Update CTA component
- [ ] Add new CTA config
- [ ] Create myneighborhood.re template
- [ ] Generate reports for pilot zip codes
- [ ] Test complete flow

**Deployment:**
- [ ] Deploy to 3 pilot zip codes
- [ ] Monitor engagement rates
- [ ] Collect feedback
- [ ] Iterate based on data

### Phase 1: Scale (Q1 2026)

**Expansion:**
- [ ] Create Facebook pages for all active zip codes
- [ ] Generate reports for all zip codes
- [ ] Train agents on new flow
- [ ] Roll out to all areas

**Optimization:**
- [ ] A/B test CTA variants
- [ ] Optimize timing/delay
- [ ] Improve SMS content
- [ ] Enhance myneighborhood.re reports

---

## 🎯 SUCCESS METRICS

### Engagement Metrics

| Metric | Current | Target | How to Measure |
|--------|---------|--------|---------------|
| CTA Engagement Rate | 2-5% | 15-25% | CTA clicks / CTA displays |
| SMS Opt-In Rate | N/A | 60-80% | SMS opt-ins / CTA clicks |
| Report View Rate | N/A | 80%+ | Report views / Downloads |
| Facebook Follow Rate | N/A | Track | Facebook API |

### Conversion Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Progressive Opt-In | 30% in 30 days | SMS → Email opt-in |
| Lead Progression | Track | Cool → Warm → Hot |
| Agent Handoff Rate | When hot | Structured handoff |
| Transaction Conversion | Track | Lead → Closing |

---

## 🚨 RISKS & MITIGATION

### Risk 1: Facebook Page Creation Time

**Risk:** Manual page creation is time-consuming

**Mitigation:**
- Create pages in batches
- Use templates for consistency
- Request Facebook approval for automation (long-term)

### Risk 2: TCPA Compliance

**Risk:** SMS permission not captured correctly

**Mitigation:**
- Clear disclosure text
- Explicit consent (checkbox)
- Save consent with timestamp
- Legal review before launch

### Risk 3: Low Engagement Rate

**Risk:** New CTAs don't improve engagement

**Mitigation:**
- A/B test old vs. new
- Iterate based on data
- Optimize timing/content
- Monitor closely

---

## 📚 RELATED DOCUMENTS

**Specs:**
- `TURNING_POINT_CTA_IMPROVEMENT_v1.md`
- `CTA_IMPLEMENTATION_RECOMMENDATIONS_v1.md`
- `CTA_SMS_PERMISSION_FLOW_v1.md`
- `FACEBOOK_FOLLOW_BEST_PRACTICES_v1.md`

**Wireframes:**
- `CTA_COMPLETE_FLOW_MYNEIGHBORHOOD_RE.html`
- `CTA_MOCKUP_DEMO.html`

**SOPs:**
- `SOP_CTA_STRATEGY_ONBOARDING_v1.md`

**Memory Logs:**
- `WORKSPACE_MEMORY_LOG_CTA_STRATEGY_2025-01-15.md`

---

## 🚀 NEXT STEPS

1. **Review Blueprint** - Ensure all components understood
2. **Create Facebook Pages** - 3-5 pilot zip codes
3. **Update Code** - CTA component + config
4. **Create Reports** - myneighborhood.re templates
5. **Test Flow** - End-to-end testing
6. **Deploy Pilot** - 3 zip codes for Christmas
7. **Measure & Iterate** - Based on data

---

**Status:** Blueprint complete. Ready for implementation. All components defined, APIs identified, workflows documented.

