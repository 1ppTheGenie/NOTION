# SOP: Call to Action Strategy Onboarding

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Step-by-step onboarding process for implementing the new CTA strategy |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial onboarding SOP

---

## 🎯 OVERVIEW

This SOP guides you through setting up the new **Genie Engagement Call to Action Strategy** for your zip codes. This includes:
- Facebook community pages
- Soft-touch CTAs
- SMS permission capture
- myneighborhood.re digital reports
- Nurture sequences

---

## 📋 PREREQUISITES

### Before You Start

- [ ] Agent has purchased Competition Command area ownership for zip code
- [ ] Agent has access to Agent Dashboard
- [ ] 1PP has created Facebook community page for zip code (or you'll create it)
- [ ] myneighborhood.re domain is configured
- [ ] SMS infrastructure is operational

---

## 🚀 ONBOARDING STEPS

### Phase 1: Facebook Community Page Setup (One-Time Per Zip Code)

#### Step 1.1: Create Facebook Page (If Not Exists)

**Who:** 1PP Admin (master account)

**Steps:**
1. Log into Facebook Business Manager (master account)
2. Go to Pages → Create New Page
3. Page Name: `[Zip Code] Community` (e.g., "La Jolla Community")
4. Category: Community
5. Add cover photo (neighborhood image)
6. Add page description (community-focused, not sales-focused)
7. Get Page ID from URL (e.g., `facebook.com/123456789012345`)
8. Save Page ID to database

**Database Update:**
```sql
INSERT INTO FacebookCommunityPages (ZipCode, FacebookPageId, FacebookPageUrl, CreatedDate, IsActive)
VALUES ('92037', '123456789012345', 'https://facebook.com/lajollacommunity', GETDATE(), 1);
```

**Time:** 15-20 minutes per page

---

#### Step 1.2: Configure Page Settings

**Settings to Configure:**
- [ ] Enable messaging
- [ ] Set up auto-replies (optional)
- [ ] Add page admins (1PP master account only)
- [ ] Configure page roles (agents can be "Editor" but not "Admin")
- [ ] Set up page insights

**Important:** 1PP owns the page, agents LEASE the audience

---

#### Step 1.3: Initial Content Setup

**Content to Add:**
- [ ] Welcome post (community-focused)
- [ ] About section (neighborhood info)
- [ ] Cover photo (neighborhood image)
- [ ] Profile picture (community logo)

**Content Guidelines:**
- ✅ Community-focused (not sales-focused)
- ✅ Value-driven (tips, insights, events)
- ✅ Hyperlocal (zip code specific)

---

### Phase 2: CTA Configuration

#### Step 2.1: Update CTA Component

**File:** `GenieCLOUD/genie-cloud/genie-components/src/components/_LeadCtaTag.jsx`

**Changes Needed:**
1. Add single-click opt-in mode
2. Add SMS permission checkbox
3. Add Facebook redirect logic
4. Add myneighborhood.re redirect

**Code Updates:**
- See `CTA_IMPLEMENTATION_RECOMMENDATIONS_v1.md` for details

---

#### Step 2.2: Add New CTA Data

**File:** `GenieCLOUD/genie-cloud/genie-components/src/utilities/utils.js`

**Add New CTA Config:**
```javascript
case 10: // Soft Follow CTA
  return {
    ctaId: 10,
    ctaTitle: "Your Neighborhood Updates",
    ctaSubTitle: "Get weekly insights about your area",
    ctaBody: "Market trends • Local events • Home tips",
    ctaSubmitButtonText: "f Follow Us on Facebook",
    ctaShowContactForm: false,
    ctaSingleClickOptIn: true,
    ctaSocialProof: "Join 1,247 neighbors already following",
    ctaFacebookPageUrl: `https://facebook.com/${facebookPageId}`,
    ctaMyNeighborhoodUrl: `https://myneighborhood.re/${zipCode}`,
    delay: 3,
    scrollDownPercentage: 50,
    enabled: true
  };
```

---

#### Step 2.3: Test CTA Flow

**Testing Checklist:**
- [ ] CTA appears after delay/scroll
- [ ] Follow button works
- [ ] Success state shows SMS checkbox
- [ ] Download button redirects to myneighborhood.re
- [ ] Facebook page opens in new tab
- [ ] SMS consent is saved

---

### Phase 3: myneighborhood.re Setup

#### Step 3.1: Create Report Template

**Location:** `myneighborhood.re/{zipcode}`

**Template Components:**
- Market overview (values, trends, inventory)
- Neighborhood insights (events, tips, community)
- Additional CTAs (email opt-in, Facebook follow)
- Agent contact (soft, not aggressive)

**Design:**
- Community-branded (not agent-branded)
- Mobile-responsive
- Fast loading
- Value-focused

---

#### Step 3.2: Generate Zip Code Reports

**Process:**
1. Pull market data for zip code
2. Generate report HTML/PDF
3. Store at `myneighborhood.re/{zipcode}`
4. Update database with report URL

**Database:**
```sql
UPDATE FacebookCommunityPages 
SET MyNeighborhoodReportUrl = 'https://myneighborhood.re/92037'
WHERE ZipCode = '92037';
```

---

### Phase 4: SMS Nurture Sequence Setup

#### Step 4.1: Create Nurture Templates

**7-Day Content Cycle:**
- **Market Monday:** Market trends, predictions
- **Tip Tuesday:** Home improvement tips
- **Wealth Wednesday:** Investment insights
- **Throwback Thursday:** Community history
- **Fun Friday:** Weekend events
- **Smart Home Saturday:** Tech/innovation
- **Showcase Sunday:** Featured homes

**Template Location:** Create in Nurture Engine system

---

#### Step 4.2: Configure Nurture Triggers

**Triggers:**
- User opts in for SMS → Start Week 1
- User follows Facebook → Start Week 1
- User downloads report → Start Week 1

**Sequence:**
- Week 1-3: Value content (no ask)
- Week 4: Soft opt-in ask (if no email)
- Week 5+: Continue nurture

---

### Phase 5: Agent Onboarding

#### Step 5.1: Agent Training

**Training Topics:**
- New CTA flow (soft touch, not aggressive)
- Facebook community page (they can post, but 1PP owns)
- myneighborhood.re reports (automatic, no action needed)
- Nurture sequence (automatic, they get notified when hot)
- Lead handoff process (structured, tracked)

**Training Materials:**
- Video walkthrough
- Written guide
- Q&A session

---

#### Step 5.2: Agent Dashboard Updates

**New Features:**
- View Facebook page engagement
- View myneighborhood.re report views
- View SMS nurture engagement
- View lead progression (cool → warm → hot)
- Structured handoff scripts

---

## ✅ COMPLETION CHECKLIST

### Technical Setup
- [ ] Facebook page created and configured
- [ ] CTA component updated
- [ ] New CTA data added
- [ ] myneighborhood.re template created
- [ ] Zip code report generated
- [ ] SMS nurture templates created
- [ ] Nurture triggers configured

### Testing
- [ ] CTA flow tested end-to-end
- [ ] SMS permission captured correctly
- [ ] Facebook redirect works
- [ ] myneighborhood.re report loads
- [ ] Nurture sequence starts
- [ ] Tracking events fire correctly

### Agent Onboarding
- [ ] Agent trained on new flow
- [ ] Agent has access to dashboard
- [ ] Agent understands lead handoff process
- [ ] Agent knows how to engage with Facebook page

---

## 📊 SUCCESS METRICS

### Week 1 Metrics
- CTA engagement rate (target: 15-25%)
- SMS opt-in rate (target: 60-80% of CTA clicks)
- myneighborhood.re report views
- Facebook page follows

### Month 1 Metrics
- Total engagements
- Progressive opt-ins (SMS → Email)
- Lead progression (cool → warm → hot)
- Agent handoff rate

---

## 🚨 TROUBLESHOOTING

### CTA Not Appearing
- Check CTA enabled flag
- Check delay/scroll settings
- Check landing page load

### SMS Permission Not Saving
- Check checkbox state
- Check database connection
- Check TCPA compliance fields

### Facebook Redirect Not Working
- Check Facebook page ID
- Check page URL format
- Check popup blocker settings

### myneighborhood.re Not Loading
- Check report generation
- Check URL format
- Check domain configuration

---

## 📚 RELATED DOCUMENTS

- `CTA_IMPLEMENTATION_RECOMMENDATIONS_v1.md` - Technical implementation
- `CTA_COMPLETE_FLOW_MYNEIGHBORHOOD_RE.html` - Visual flow mockup
- `FACEBOOK_FOLLOW_BEST_PRACTICES_v1.md` - Facebook setup guide
- `CRITICAL_QUESTIONS_ANSWERS_v1.md` - FAQ and solutions

---

**Next Steps:** Complete Phase 1 (Facebook page setup) for pilot zip codes, then proceed with CTA configuration.

