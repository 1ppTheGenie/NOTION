# Follow + Market Report Download Flow

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Flow for Follow CTA with market report download incentive |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial flow with market report download

---

## 🎯 ENHANCED FLOW

### Step 1: User Clicks "Follow Us on Facebook"

**What they see:**
```
┌─────────────────────────────────────────┐
│  🏘️ Your Neighborhood Updates          │
│                                         │
│  Get weekly insights about your area:  │
│  • Market trends & home values           │
│  • Local events & community news        │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  f  Follow Us on Facebook         │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Get a free market report when you      │
│  follow!                                │
└─────────────────────────────────────────┘
```

**What happens:**
- Track engagement: `window.gHub.addLead()` with tags
- Show success state with download offer

---

### Step 2: Success State with Download Offer

**What they see:**
```
┌─────────────────────────────────────────┐
│  ✓ Thanks for Following!                │
│                                         │
│  Get your free neighborhood market      │
│  report while you're here:              │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  📊 Get Your Insider Report Now  │  │ ← Download button
│  └───────────────────────────────────┘  │
│                                         │
│  Instant download • No email required    │
│                                         │
│  [Continue Browsing]                    │
└─────────────────────────────────────────┘
```

**What happens:**
- User can download report immediately
- No email required (low friction)
- Option to continue browsing

---

### Step 3: Download Report

**What they see:**
```
┌─────────────────────────────────────────┐
│  📊 Report Downloaded!                 │
│                                         │
│  Your neighborhood market report is     │
│  ready. Check your downloads folder.    │
│                                         │
│  [Continue Browsing]                    │
└─────────────────────────────────────────┘
```

**What happens:**
- PDF downloads automatically
- Track download event
- User can continue browsing

---

## 🔄 COMPLETE USER FLOW

```
User clicks "Follow Us on Facebook"
    ↓
Track engagement (SoftOptIn, FollowNeighborhood)
    ↓
Show success: "Thanks for Following!"
    ↓
Offer: "Get Your Insider Report Now"
    ↓
User clicks download button
    ↓
PDF downloads (no email required)
    ↓
Track download event
    ↓
Show confirmation: "Report Downloaded!"
    ↓
User can continue browsing
    ↓
(Optional) Redirect to Facebook page
```

---

## 💡 VALUE PROPOSITION

### Why This Works

1. **Immediate Value**
   - User gets something tangible (market report)
   - Not just "follow us" - actual value delivered

2. **Low Friction**
   - No email required for download
   - Instant gratification
   - Builds trust

3. **Two-Step Engagement**
   - Step 1: Follow (tracked)
   - Step 2: Download (tracked)
   - Double engagement opportunity

4. **Trust Building**
   - Delivers value immediately
   - Shows expertise (market data)
   - Sets expectation for future value

---

## 📊 MARKET REPORT CONTENT

### What to Include

**Neighborhood Market Report (PDF):**
- Market trends (last 30/90 days)
- Average home values
- Sales activity
- Price per square foot
- Days on market
- Inventory levels
- Neighborhood-specific data

**Design:**
- Professional PDF layout
- Charts and graphs
- Hyperlocal data (zip code specific)
- Branded with agent/community name
- 2-4 pages (quick read)

---

## 🛠️ IMPLEMENTATION OPTIONS

### Option 1: No Email Required (LOWEST FRICTION)

```javascript
// After follow click
function showSuccess(button) {
  // Track follow
  window.gHub.addLead("Followed Facebook page", {
    genieTags: "SoftOptIn, FollowNeighborhood, FacebookFollow"
  });
  
  // Show success with download offer
  setHasSubmitted(true);
  
  // Download button
  <button onClick={() => {
    // Track download
    window.gHub.addLead("Downloaded market report", {
      genieTags: "MarketReportDownload, FollowNeighborhood"
    });
    
    // Download PDF directly
    window.open(`/api/market-report/${zipCode}.pdf`, '_blank');
  }}>
    📊 Get Your Insider Report Now
  </button>
}
```

**Pros:**
- ✅ Lowest friction
- ✅ Instant download
- ✅ No form required

**Cons:**
- ⚠️ Can't follow up via email
- ⚠️ Can't personalize report

---

### Option 2: Optional Email (PROGRESSIVE)

```javascript
// After follow click
function showSuccess(button) {
  // Show download offer
  <button onClick={() => {
    // Show optional email form
    <div>
      <input type="email" placeholder="Email (optional)" />
      <button onClick={downloadReport}>Download Now</button>
      <button onClick={downloadWithoutEmail}>Skip - Download Free</button>
    </div>
  }}>
    📊 Get Your Insider Report Now
  </button>
}
```

**Pros:**
- ✅ Optional email capture
- ✅ Can personalize report
- ✅ Can follow up
- ✅ Still low friction (optional)

**Cons:**
- Slightly more complex

---

### Option 3: Email Required (HIGHER VALUE)

```javascript
// After follow click
function showSuccess(button) {
  // Show email form
  <div>
    <input type="email" placeholder="Email for report" required />
    <button onClick={downloadReport}>Get Report</button>
  </div>
}
```

**Pros:**
- ✅ Email captured
- ✅ Can personalize
- ✅ Can nurture via email

**Cons:**
- ⚠️ Adds friction
- ⚠️ Some users may skip

---

## 🎯 RECOMMENDATION

**Use Option 1: No Email Required (for now)**

**Why:**
1. ✅ Lowest friction (matches "soft first touch" strategy)
2. ✅ Immediate value delivery
3. ✅ Builds trust
4. ✅ Can add email later (progressive)

**Then add Option 2 later:**
- After testing, add optional email
- "Get personalized updates via email?" (optional)
- Progressive engagement

---

## 📊 TRACKING EVENTS

### Events to Track

1. **Follow Click**
   - Event: `FacebookFollowClick`
   - Tags: `SoftOptIn`, `FollowNeighborhood`

2. **Download Click**
   - Event: `MarketReportDownloadClick`
   - Tags: `MarketReportDownload`, `FollowNeighborhood`

3. **Download Complete**
   - Event: `MarketReportDownloaded`
   - Tags: `MarketReportDownload`, `FollowNeighborhood`

4. **Progressive Opt-In** (if email added)
   - Event: `EmailOptInAfterDownload`
   - Tags: `ProgressiveOptIn`, `EmailCapture`

---

## 🎨 DESIGN SPECIFICATIONS

### Download Button

- **Color:** Orange/Gold gradient (#f39c12 → #e67e22)
- **Icon:** 📊 (chart/graph)
- **Text:** "Get Your Insider Report Now"
- **Size:** Full width, 48px height
- **Style:** Bold, attention-grabbing

### Success Messages

- **After Follow:** "Thanks for Following!"
- **Download Offer:** "Get your free neighborhood market report while you're here"
- **After Download:** "Report Downloaded! Check your downloads folder"

---

## 📱 MOBILE CONSIDERATIONS

### Mobile Flow

1. User clicks "Follow"
2. Success message shown
3. Download button (full width, thumb-friendly)
4. PDF downloads (mobile-friendly PDF)
5. Can open in browser or save

### PDF Design

- **Mobile-optimized:** Single column layout
- **Quick read:** 2-4 pages max
- **Charts:** Large, readable
- **Text:** 14px minimum

---

## ✅ CHECKLIST

- [ ] Create market report PDF template
- [ ] Generate zip code-specific reports
- [ ] Add download button to success state
- [ ] Track download events
- [ ] Test PDF download on mobile
- [ ] Add "Get free report when you follow" text
- [ ] Design download button (orange/gold)
- [ ] Test complete flow

---

## 🚀 NEXT STEPS

1. **Create report template** (PDF design)
2. **Build report generator** (zip code-specific data)
3. **Update CTA component** (add download offer)
4. **Test flow** (follow → download)
5. **Measure engagement** (follow rate, download rate)

---

**Bottom Line:** Add market report download as immediate value after follow. No email required initially (lowest friction), can add optional email later for progressive engagement.

