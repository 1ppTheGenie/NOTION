# Facebook Redirect Timing - When Does It Happen?

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Clarify when Facebook redirect happens in the Follow CTA flow |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial timing documentation

---

## 🎯 RECOMMENDED FLOW

### When User Clicks "Follow Us on Facebook"

**Timeline:**
```
0.0s: User clicks "Follow" button
  ↓
0.1s: Track engagement (window.gHub.addLead)
  ↓
0.2s: Show success message ("Thanks for Following!")
  ↓
1.5s: Facebook page opens in NEW TAB (automatic)
  ↓
User sees: Success message + SMS permission + Download offer
User can: Follow on Facebook (in new tab) + Download report (current tab)
```

---

## 🔄 COMPLETE SEQUENCE

### Step-by-Step

1. **User clicks "Follow Us on Facebook"**
   - Button click event fires
   - Engagement tracked immediately

2. **Success message appears (0.2s)**
   - "Thanks for Following!" message
   - SMS permission checkbox
   - Download offer

3. **Facebook redirect (1.5s delay)**
   - Opens Facebook page in **NEW TAB**
   - User can follow the page there
   - Original tab stays open (showing success message)

4. **User can do both:**
   - Follow on Facebook (in new tab)
   - Download report (in current tab)
   - Opt-in for SMS (in current tab)

---

## 💡 WHY THIS TIMING?

### Benefits of 1.5 Second Delay

1. **User sees confirmation first**
   - Success message appears immediately
   - User knows their click was registered
   - Builds trust

2. **Then redirect happens**
   - Facebook opens in new tab
   - User can follow there
   - Original tab stays open

3. **User can multitask**
   - Follow on Facebook (new tab)
   - Download report (current tab)
   - Best of both worlds

---

## 🛠️ IMPLEMENTATION

### Code Example

```javascript
function handleFollowClick() {
  // 1. Track engagement immediately
  window.gHub.addLead("Followed Facebook page", {
    genieTags: "SoftOptIn, FollowNeighborhood, FacebookFollow"
  });
  
  // 2. Show success state
  setHasSubmitted(true);
  
  // 3. Redirect to Facebook after 1.5 seconds (in new tab)
  setTimeout(() => {
    const facebookPageUrl = `https://facebook.com/${facebookPageId}`;
    window.open(facebookPageUrl, '_blank');
  }, 1500);
}
```

---

## 📊 ALTERNATIVE OPTIONS

### Option 1: Immediate Redirect (NOT RECOMMENDED)

```javascript
// Redirect immediately
window.open(facebookPageUrl, '_blank');
setHasSubmitted(true);
```

**Problems:**
- ❌ User doesn't see success message
- ❌ Feels abrupt
- ❌ User might miss download offer

---

### Option 2: Redirect After Download (ALSO VALID)

```javascript
// Show success → User downloads → Then redirect
function downloadReport() {
  // Download PDF
  window.open(`/api/market-report/${zipCode}.pdf`, '_blank');
  
  // Then redirect to Facebook
  setTimeout(() => {
    window.open(facebookPageUrl, '_blank');
  }, 1000);
}
```

**Pros:**
- ✅ User gets value first (report)
- ✅ Then redirects to Facebook
- ✅ Natural flow

**Cons:**
- ⚠️ User might close tab before redirect

---

### Option 3: Redirect After SMS Opt-In (ALSO VALID)

```javascript
// Show success → User opts in for SMS → Then redirect
function handleSmsOptIn() {
  // Save SMS consent
  // Then redirect to Facebook
  window.open(facebookPageUrl, '_blank');
}
```

**Pros:**
- ✅ User completes all actions first
- ✅ Then redirects
- ✅ Higher engagement

**Cons:**
- ⚠️ More steps before redirect

---

## 🎯 RECOMMENDATION

**Use: 1.5 Second Delay After Success Message**

**Why:**
1. ✅ User sees confirmation (builds trust)
2. ✅ Facebook opens in new tab (doesn't interrupt)
3. ✅ User can do both (follow + download)
4. ✅ Best user experience

**Flow:**
```
Click Follow → Track → Show Success → (1.5s) → Facebook Opens (new tab)
```

---

## 📱 MOBILE CONSIDERATIONS

### Mobile Behavior

**If Facebook app installed:**
- Opens Facebook app (not browser)
- User can follow in app
- Original browser tab stays open

**If no Facebook app:**
- Opens Facebook in new browser tab
- User can follow there
- Original tab stays open

**Both cases:**
- Original tab stays open
- User can return to download report
- User can opt-in for SMS

---

## ✅ CHECKLIST

- [ ] Track engagement immediately on click
- [ ] Show success message (0.2s)
- [ ] Redirect to Facebook after 1.5s delay
- [ ] Open in NEW TAB (not same tab)
- [ ] Keep original tab open
- [ ] User can follow on Facebook
- [ ] User can download report
- [ ] User can opt-in for SMS

---

## 🚀 NEXT STEPS

1. **Update CTA component** (add redirect logic)
2. **Get Facebook page URLs** for each zip code
3. **Test redirect timing** (1.5s feels right?)
4. **Test on mobile** (app vs browser behavior)
5. **Measure engagement** (follow rate, download rate)

---

**Bottom Line:** Click Follow → Track → Show Success (0.2s) → Redirect to Facebook in NEW TAB (1.5s delay). User can follow on Facebook AND download report. Best of both worlds!

