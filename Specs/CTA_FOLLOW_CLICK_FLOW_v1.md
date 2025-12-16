# What Happens When "Follow" is Clicked?

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Explain the flow when user clicks "Follow" button |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial flow documentation

---

## 🎯 CURRENT MOCKUP (Demo Only)

**What the HTML mockup does:**
- ✅ Shows success message: "You're Following!"
- ✅ Displays confirmation text
- ❌ **Does NOT actually track anything** (it's just a visual demo)

**Purpose:** To show you what it will LOOK LIKE, not what it will DO.

---

## 🔄 WHAT IT SHOULD DO (Real Implementation)

### Step 1: User Clicks "Follow" Button

```javascript
// In _LeadCtaTag.jsx (when button is clicked)
onClick={() => {
  // 1. Track the engagement
  window.gHub.addLead(formattedNote, {
    genieTags: data.ctaTags, // e.g., "SoftOptIn, FollowNeighborhood, Cta10Accept"
  });
  
  // 2. Show success state (no form)
  setHasSubmitted(true);
  
  // 3. Hide mobile banner if visible
  window.gHub.toggleMobileBanner(data, false);
}}
```

### Step 2: `window.gHub.addLead()` Function Executes

**What it does:**
1. **Checks if lead already exists** (from SMS click, previous visit, etc.)
2. **If lead exists:** Updates the lead record with new note and tags
3. **If lead is new:** Creates a new `GenieLead` record

**Data sent to backend:**
```javascript
{
  agentId: settings.agentId,           // Agent who owns the zip code
  areaId: settings.areaId,              // Zip code area
  propertyId: settings.propertyId,      // Property from SMS (if any)
  note: "I would like to follow for neighborhood updates", // CTA note
  genieTags: "SoftOptIn, FollowNeighborhood, Cta10Accept", // Tracking tags
  // NO email/phone required (single-click opt-in)
}
```

### Step 3: Backend Creates/Updates Lead Record

**Database:** `FarmGenie`  
**Table:** `GenieLead`

**What gets saved:**
- Lead record (new or updated)
- Note: "I would like to follow for neighborhood updates"
- Tags: `SoftOptIn`, `FollowNeighborhood`, `Cta10Accept`
- Agent ID (who owns the zip code)
- Area ID (which zip code)
- Property ID (if from SMS click)
- **NO contact info required** (this is the key difference!)

### Step 4: Tracking Events Created

**Database:** `FarmGenie`  
**Table:** `CtaEvent` (or similar engagement tracking)

**Events logged:**
1. `Cta10Display` - CTA was shown
2. `Cta10Accept` - User clicked "Follow"
3. `SoftOptIn` - Single-click opt-in (no form)
4. `FollowNeighborhood` - User wants neighborhood updates

### Step 5: User Sees Success State

**What user sees:**
```
✓ You're Following!

You'll receive weekly updates about your neighborhood.
Check your SMS for your first update coming soon!

[Continue Browsing]
```

**What happens behind the scenes:**
- ✅ Engagement tracked
- ✅ Lead record created/updated
- ✅ Tags applied for segmentation
- ✅ Ready for nurture sequence

---

## 📊 COMPARISON: OLD vs. NEW

### ❌ OLD CTA Flow (Current System)

```
User clicks "Get Home Value"
    ↓
Form appears (name, email, phone required)
    ↓
User fills form (HIGH FRICTION)
    ↓
Form submitted
    ↓
Contact verification required
    ↓
Lead created with contact info
    ↓
Agent notified
```

**Problems:**
- Requires form (high friction)
- Needs contact info upfront
- Two-step process (form → verification)
- Many users bounce at form

---

### ✅ NEW "Follow" Flow (Proposed)

```
User clicks "Follow for Updates"
    ↓
Single click (NO FORM)
    ↓
Success message shown
    ↓
Lead record created/updated (no contact info needed)
    ↓
Tags applied: SoftOptIn, FollowNeighborhood
    ↓
User enters nurture sequence
    ↓
Week 1-3: SMS with value content (no ask)
    ↓
Week 4: Soft ask "Want weekly updates?" → Opt-in
    ↓
Week 5+: Full nurture → Build trust → Convert
```

**Benefits:**
- ✅ No form (low friction)
- ✅ No contact info required upfront
- ✅ Single click = engagement tracked
- ✅ Progressive engagement path
- ✅ Higher conversion potential

---

## 🔄 PROGRESSIVE ENGAGEMENT FLOW

### Week 1: Initial Follow
- **Action:** User clicks "Follow"
- **Tracking:** `SoftOptIn`, `FollowNeighborhood`
- **What happens:** Lead record created, tagged for nurture
- **User gets:** Success message, can continue browsing

### Week 2-3: Value Delivery (No Ask)
- **Action:** System sends SMS with value content
- **Content:** Market Monday insights, Tip Tuesday, etc.
- **Tracking:** SMS opens, clicks tracked
- **What happens:** Build trust, deliver value
- **User gets:** Weekly neighborhood updates (as promised)

### Week 4: Soft Opt-In Ask
- **Action:** SMS with soft CTA: "Want personalized updates for your address?"
- **Tracking:** `ProgressiveOptInOffer`
- **What happens:** Optional contact capture (still low friction)
- **User gets:** Choice to provide email/phone OR continue without

### Week 5+: Full Nurture
- **Action:** Continue value delivery, build relationship
- **Tracking:** Engagement metrics, conversion signals
- **What happens:** Agent handoff when ready (HOT lead signals)
- **User gets:** Ongoing value, natural conversion path

---

## 🗄️ DATABASE IMPACT

### Tables Affected

1. **`GenieLead`**
   - New/updated lead record
   - Note: "I would like to follow for neighborhood updates"
   - Tags: `SoftOptIn`, `FollowNeighborhood`, `Cta10Accept`
   - **No email/phone required** (can be null)

2. **`CtaEvent`** (or engagement tracking table)
   - Event: `Cta10Display` (CTA shown)
   - Event: `Cta10Accept` (Follow clicked)
   - Event: `SoftOptIn` (single-click engagement)

3. **`ShortUrlAccessLog`** (if from SMS)
   - Already exists from SMS click
   - Links to this new engagement

---

## 📱 SMS INTEGRATION

### How SMS Works with "Follow"

**Scenario 1: User clicks SMS link → Lands on page → Clicks Follow**
1. SMS sent with short URL
2. User clicks SMS link → `ShortUrlAccessLog` created
3. Landing page loads → CTA shown
4. User clicks "Follow" → `GenieLead` created/updated
5. Lead now has:
   - Phone number (from SMS)
   - Tags: `SoftOptIn`, `FollowNeighborhood`
   - Ready for nurture SMS sequence

**Scenario 2: User visits page directly → Clicks Follow**
1. Landing page loads (no SMS context)
2. User clicks "Follow" → `GenieLead` created
3. Lead has:
   - No phone number (yet)
   - Tags: `SoftOptIn`, `FollowNeighborhood`
   - Ready for email nurture (if email captured later)

---

## 🎯 KEY DIFFERENCES FROM CURRENT SYSTEM

| Feature | Current CTA | New "Follow" CTA |
|---------|-------------|------------------|
| **Form Required** | ✅ Yes (name, email, phone) | ❌ No (single click) |
| **Contact Info** | Required upfront | Optional (progressive) |
| **Friction Level** | High | Low |
| **Engagement Tracked** | Only if form submitted | Immediately on click |
| **Conversion Path** | Immediate or never | Progressive (7-14 days) |
| **Trust Building** | After form | Before form |
| **Bounce Rate** | High (form = friction) | Lower (no form) |

---

## 🛠️ TECHNICAL IMPLEMENTATION

### Code Changes Needed

**File:** `_LeadCtaTag.jsx`

```javascript
// Current code (requires form):
<Show when={data.ctaShowContactForm && !leadCaptured()}>
  <LeadCaptureForm ... />  // ← Form appears
</Show>

// New code (single-click mode):
<Show when={data.ctaSingleClickOptIn && hasSubmitted() === false}>
  <button onClick={() => {
    window.gHub.addLead(formattedNote, {
      genieTags: data.ctaTags, // "SoftOptIn, FollowNeighborhood"
    });
    setHasSubmitted(true);
    // NO FORM - direct to success state
  }}>
    {data.ctaSubmitButtonText} // "✓ Follow for Updates"
  </button>
</Show>
```

**Key Change:** `ctaShowContactForm: false` + `ctaSingleClickOptIn: true`

---

## 📊 TRACKING & ANALYTICS

### What Gets Tracked

1. **CTA Display**
   - Event: `Cta10Display`
   - When: CTA popup appears
   - Purpose: Measure impressions

2. **Follow Click**
   - Event: `Cta10Accept`
   - Tags: `SoftOptIn`, `FollowNeighborhood`
   - When: User clicks "Follow"
   - Purpose: Measure engagement rate

3. **Progressive Conversion**
   - Event: `SoftOptInToFullOptIn`
   - When: User provides contact after nurture
   - Purpose: Measure conversion funnel

### Metrics to Track

- **Engagement Rate:** Follow clicks / CTA displays
- **Progressive Opt-In Rate:** Full opt-ins / Follow clicks (30 days)
- **SMS Engagement:** Opens/clicks after follow
- **Time to Conversion:** Days from follow → contact

---

## ✅ SUMMARY

**When user clicks "Follow":**

1. ✅ **Single click** (no form required)
2. ✅ **Lead record created/updated** (with tags)
3. ✅ **Engagement tracked** (`SoftOptIn`, `FollowNeighborhood`)
4. ✅ **Success message shown** ("You're Following!")
5. ✅ **User enters nurture sequence** (weekly value content)
6. ✅ **Progressive opt-in** (contact capture after trust built)

**Key Benefit:** Low friction → Higher engagement → Better conversion over time

---

**Next Step:** Implement the code changes to make this real (not just a mockup)!

