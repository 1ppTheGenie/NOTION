# SMS Permission Flow - TCPA Compliant

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | TCPA-compliant SMS permission flow for Follow CTA |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial SMS permission flow with TCPA compliance

---

## 🎯 COMPLETE FLOW WITH SMS PERMISSION

### Step 1: User Clicks "Follow Us on Facebook"

**What they see:**
```
┌─────────────────────────────────────────┐
│  🏘️ Your Neighborhood Updates          │
│                                         │
│  Get weekly insights about your area:  │
│  • Market trends & home values          │
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
- Show success state with SMS permission + download offer

---

### Step 2: Success State with SMS Permission

**What they see:**
```
┌─────────────────────────────────────────┐
│  ✓ Thanks for Following!                │
│                                         │
│  Get your free neighborhood market      │
│  report and stay updated:               │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ ☑️ 📱 Get weekly updates via text │  │ ← SMS checkbox
│  │                                    │  │
│  │ By checking this, you agree to     │  │
│  │ receive text messages with          │  │
│  │ neighborhood updates. Message and  │  │
│  │ data rates may apply. Reply STOP   │  │
│  │ to opt out anytime.                │  │
│  └───────────────────────────────────┘  │
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

**Key Elements:**
- ✅ **Checkbox** (pre-checked for convenience, but user can uncheck)
- ✅ **Clear value prop** ("Get weekly updates via text")
- ✅ **TCPA-compliant disclosure** (message rates, opt-out info)
- ✅ **Download button** (immediate value)

---

### Step 3: User Downloads Report

**If SMS checked:**
- Track download + SMS opt-in
- Save SMS consent to database
- Show: "You'll also receive weekly text updates!"

**If SMS unchecked:**
- Track download only
- Show: "Check your downloads folder."

---

## 📱 TCPA COMPLIANCE REQUIREMENTS

### Required Elements

1. **Explicit Consent**
   - ✅ Checkbox (not pre-checked, or clearly opt-in)
   - ✅ User must actively check the box
   - ✅ Cannot be hidden or pre-selected without clear indication

2. **Clear Disclosure**
   - ✅ What they're signing up for ("weekly updates via text")
   - ✅ Message and data rates may apply
   - ✅ How to opt out ("Reply STOP")
   - ✅ Who is sending (your company name)

3. **Opt-Out Mechanism**
   - ✅ "Reply STOP to opt out" (in disclosure)
   - ✅ System must honor opt-out requests
   - ✅ Cannot send after opt-out

4. **Consent Storage**
   - ✅ Save consent timestamp
   - ✅ Save phone number
   - ✅ Save consent method (checkbox, form, etc.)
   - ✅ Track consent source (CTA, landing page, etc.)

---

## 🛠️ IMPLEMENTATION

### Option 1: Checkbox (Pre-Checked) - RECOMMENDED

```javascript
// After follow click
function showSuccess(button) {
  // Track follow
  window.gHub.addLead("Followed Facebook page", {
    genieTags: "SoftOptIn, FollowNeighborhood, FacebookFollow"
  });
  
  // Show success with SMS checkbox (pre-checked)
  <div>
    <label>
      <input type="checkbox" id="smsPermission" checked>
      <div>
        <strong>📱 Get weekly updates via text</strong>
        <small>
          By checking this, you agree to receive text messages with 
          neighborhood updates. Message and data rates may apply. 
          Reply STOP to opt out anytime.
        </small>
      </div>
    </label>
  </div>
  
  <button onClick={() => {
    const smsOptIn = document.getElementById('smsPermission').checked;
    
    // Track download
    window.gHub.addLead("Downloaded market report", {
      genieTags: "MarketReportDownload, FollowNeighborhood"
    });
    
    // Track SMS opt-in if checked
    if (smsOptIn) {
      window.gHub.addLead("SMS opt-in consent", {
        genieTags: "SmsOptIn, FollowNeighborhood, Tcpacompliant",
        phoneNumber: window.gHub.leadPhoneNumber, // From SMS click or form
        consentMethod: "Checkbox",
        consentTimestamp: new Date().toISOString()
      });
    }
    
    // Download PDF
    window.open(`/api/market-report/${zipCode}.pdf`, '_blank');
  }}>
    📊 Get Your Insider Report Now
  </button>
}
```

**Pros:**
- ✅ Convenient (pre-checked)
- ✅ Clear opt-in (user can uncheck)
- ✅ TCPA compliant (explicit consent)
- ✅ Higher opt-in rate

**Cons:**
- ⚠️ Must ensure user sees and understands (clear disclosure)

---

### Option 2: Checkbox (Unchecked) - MORE CONSERVATIVE

```javascript
// Same as Option 1, but checkbox is NOT pre-checked
<input type="checkbox" id="smsPermission"> // No "checked" attribute
```

**Pros:**
- ✅ More conservative (user must actively opt-in)
- ✅ Clearer explicit consent
- ✅ Lower risk of TCPA issues

**Cons:**
- ⚠️ Lower opt-in rate (users may forget to check)

---

### Option 3: Separate SMS Opt-In Step - MOST CONSERVATIVE

```javascript
// After download, show separate SMS opt-in
function afterDownload() {
  <div>
    <h3>Want weekly updates via text?</h3>
    <p>Get neighborhood insights delivered to your phone</p>
    <button onClick={optInSms}>Yes, Send Me Updates</button>
    <button onClick={skipSms}>No Thanks</button>
  </div>
}
```

**Pros:**
- ✅ Most explicit consent
- ✅ Lowest TCPA risk
- ✅ User fully understands what they're opting into

**Cons:**
- ⚠️ Extra step (adds friction)
- ⚠️ Lower opt-in rate

---

## 🎯 RECOMMENDATION

**Use Option 1: Pre-Checked Checkbox with Clear Disclosure**

**Why:**
1. ✅ TCPA compliant (explicit consent via checkbox)
2. ✅ Convenient (pre-checked, but user can uncheck)
3. ✅ Clear disclosure (message rates, opt-out info)
4. ✅ Higher opt-in rate (convenience + value)
5. ✅ Combined with download (immediate value)

**Key Requirements:**
- ✅ Clear disclosure text (TCPA compliant)
- ✅ User can uncheck if they don't want SMS
- ✅ Save consent with timestamp
- ✅ Honor opt-out requests

---

## 📊 DATABASE STORAGE

### SMS Consent Record

**Table:** `SmsOptIn` or `GenieLead` (add SMS consent fields)

**Fields:**
- `PhoneNumber` (required)
- `ConsentTimestamp` (required)
- `ConsentMethod` ("Checkbox", "Form", etc.)
- `ConsentSource` ("FollowCTA", "LandingPage", etc.)
- `OptOutTimestamp` (null if active)
- `IsActive` (true/false)

**Example:**
```sql
INSERT INTO SmsOptIn (
  PhoneNumber,
  ConsentTimestamp,
  ConsentMethod,
  ConsentSource,
  GenieLeadId,
  IsActive
) VALUES (
  '7145551234',
  '2025-01-15 10:30:00',
  'Checkbox',
  'FollowCTA',
  12345,
  1
)
```

---

## 🔄 COMPLETE USER FLOW

```
User clicks "Follow Us on Facebook"
    ↓
Track engagement (SoftOptIn, FollowNeighborhood)
    ↓
Show success: "Thanks for Following!"
    ↓
Show SMS permission checkbox (pre-checked)
    ↓
User can check/uncheck SMS permission
    ↓
User clicks "Get Your Insider Report Now"
    ↓
If SMS checked:
  - Track SMS opt-in consent
  - Save to database with timestamp
  - Tag: SmsOptIn, Tcpacompliant
    ↓
Download PDF
    ↓
Show confirmation: "You'll receive weekly text updates!"
    ↓
User enters SMS nurture sequence
```

---

## ✅ TCPA COMPLIANCE CHECKLIST

- [ ] Explicit consent (checkbox, not hidden)
- [ ] Clear disclosure (what they're signing up for)
- [ ] Message rates disclosure ("Message and data rates may apply")
- [ ] Opt-out instructions ("Reply STOP to opt out")
- [ ] Company name in disclosure
- [ ] Consent timestamp saved
- [ ] Phone number saved
- [ ] Opt-out mechanism implemented
- [ ] Opt-out requests honored
- [ ] No sending after opt-out

---

## 📱 SMS CONTENT GUIDELINES

### What You Can Send (TCPA Compliant)

✅ **Community Information:**
- Market trends
- Local events
- Neighborhood news
- Home improvement tips
- Community spotlights

❌ **What to Avoid:**
- Sales pitches
- Promotional offers
- Agent contact requests (too early)
- Transactional requests

### Example SMS Messages

**Week 1 (Market Monday):**
```
🏘️ [Zip Code] Market Update:
Home values up 12% this quarter.
See full report: [link]
Reply STOP to opt out.
```

**Week 2 (Tip Tuesday):**
```
💡 Home Tip: Simple curb appeal updates 
can increase home value 5-10%.
Get the guide: [link]
Reply STOP to opt out.
```

---

## 🚀 NEXT STEPS

1. **Update CTA component** (add SMS checkbox)
2. **Add TCPA disclosure text** (compliant language)
3. **Build SMS consent storage** (database table/fields)
4. **Test opt-in flow** (checkbox, consent saving)
5. **Test opt-out mechanism** (STOP keyword handling)
6. **Legal review** (TCPA compliance verification)

---

**Bottom Line:** Add SMS permission checkbox (pre-checked) with clear TCPA-compliant disclosure. User gets immediate value (report download) + ongoing value (SMS updates). Save consent with timestamp for compliance.

