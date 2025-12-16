# Facebook Follow CTA - Best Practices

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Best practices for implementing Facebook follow CTA |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial best practices based on Facebook guidelines

---

## ✅ RECOMMENDED APPROACH

### Option 1: Facebook Logo + Clear CTA (BEST)

**Design:**
```
┌─────────────────────────────────────────┐
│  🏘️ Your Neighborhood Updates          │
│                                         │
│  Get weekly insights about your area:   │
│  • Market trends & home values          │
│  • Local events & community news       │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  f  Follow Us on Facebook         │  │ ← Facebook logo + text
│  └───────────────────────────────────┘  │
│                                         │
│  Join 1,247 neighbors already following │
└─────────────────────────────────────────┘
```

**Why This Works:**
- ✅ **Facebook "f" logo** - Official, recognizable
- ✅ **Clear CTA text** - "Follow Us on Facebook" (not ambiguous)
- ✅ **Sets expectations** - User knows they're going to Facebook
- ✅ **Compliant** - Follows Facebook brand guidelines
- ✅ **Trust-building** - Official branding = legitimate

**Button Specs:**
- **Color:** Facebook blue (#1877f2)
- **Logo:** Official Facebook "f" logo (don't modify)
- **Text:** "Follow Us on Facebook" (clear action)
- **Size:** Large, thumb-friendly (mobile)

---

### Option 2: Facebook Icon + Text (Alternative)

**Design:**
```
┌─────────────────────────────────────────┐
│  [Facebook icon] Follow on Facebook    │
└─────────────────────────────────────────┘
```

**When to Use:**
- If space is limited
- Mobile bottom sheet variant
- Secondary CTA (not primary)

---

## 🎨 DESIGN SPECIFICATIONS

### Facebook Branding Guidelines

1. **Use Official "f" Logo**
   - ✅ Use Facebook's official "f" logo
   - ✅ Don't modify design, scale, or color
   - ✅ If color limitations: Use black and white
   - ❌ Don't animate or distort

2. **Button Colors**
   - **Primary:** Facebook blue (#1877f2)
   - **Hover:** Darker blue (#0d5fbf)
   - **Alternative:** White button with blue text

3. **Typography**
   - **Button text:** Bold, 18-20px
   - **Clear action:** "Follow Us on Facebook"
   - **Don't use:** "Like", "Connect", or ambiguous terms

4. **Link Behavior**
   - ✅ Link directly to Facebook page
   - ✅ Open in new tab (preserve landing page)
   - ✅ Track click before redirect

---

## 🔄 USER FLOW

### Step-by-Step

1. **User sees CTA**
   - Facebook logo visible
   - Clear "Follow Us on Facebook" text
   - Social proof: "Join 1,247 neighbors..."

2. **User clicks button**
   - Track engagement: `window.gHub.addLead()` with tags
   - Open Facebook page in new tab
   - Show success message on landing page

3. **User on Facebook**
   - Sees community page for their zip code
   - Clicks "Follow" button on Facebook
   - Now following the page

4. **Back on landing page**
   - Success message: "Thanks! You're now following [Zip Code] Community"
   - Can continue browsing
   - Enter nurture sequence

---

## 📊 IMPLEMENTATION OPTIONS

### Option A: Direct Redirect (SIMPLE)

```javascript
<button onClick={() => {
  // Track engagement
  window.gHub.addLead("Followed Facebook page", {
    genieTags: "SoftOptIn, FollowNeighborhood, FacebookFollow"
  });
  
  // Redirect to Facebook page
  window.open(`https://facebook.com/${facebookPageId}`, '_blank');
  
  // Show success message
  setHasSubmitted(true);
}}>
  <span>f</span> Follow Us on Facebook
</button>
```

**Pros:**
- ✅ Simple implementation
- ✅ Direct to Facebook
- ✅ User follows on Facebook (official)

**Cons:**
- ⚠️ User leaves landing page
- ⚠️ Can't track if they actually followed

---

### Option B: Tracked Redirect (RECOMMENDED)

```javascript
<button onClick={() => {
  // Track engagement first
  window.gHub.addLead("Clicked Facebook follow CTA", {
    genieTags: "SoftOptIn, FollowNeighborhood, FacebookFollowClick"
  });
  
  // Show success message
  setHasSubmitted(true);
  
  // Then redirect (after brief delay)
  setTimeout(() => {
    window.open(`https://facebook.com/${facebookPageId}`, '_blank');
  }, 500);
}}>
  <span>f</span> Follow Us on Facebook
</button>
```

**Pros:**
- ✅ Tracks click engagement
- ✅ Shows success message
- ✅ Then redirects to Facebook
- ✅ Better user experience

**Cons:**
- Slightly more complex

---

### Option C: Facebook SDK (ADVANCED)

```javascript
// Use Facebook SDK for official follow button
FB.ui({
  method: 'page',
  page_id: facebookPageId
}, function(response) {
  if (response && response.success) {
    // User followed the page
    window.gHub.addLead("Followed Facebook page", {
      genieTags: "SoftOptIn, FollowNeighborhood, FacebookFollowConfirmed"
    });
  }
});
```

**Pros:**
- ✅ Official Facebook integration
- ✅ Can confirm if user actually followed
- ✅ Better tracking

**Cons:**
- Requires Facebook SDK
- More complex setup
- Requires app permissions

---

## 🎯 RECOMMENDATION

**Use Option B: Tracked Redirect**

**Why:**
1. ✅ Simple to implement
2. ✅ Tracks engagement
3. ✅ Shows success message
4. ✅ Redirects to Facebook
5. ✅ Good user experience

**Implementation:**
- Track click → Show success → Redirect to Facebook
- Don't need to verify follow (just track click)
- User follows on Facebook (official action)

---

## 📱 MOBILE CONSIDERATIONS

### Mobile Button Specs

- **Size:** Full width, 48px height (thumb-friendly)
- **Logo:** 24px Facebook "f" logo
- **Text:** Bold, 18px
- **Spacing:** 10px between logo and text
- **Color:** Facebook blue (#1877f2)

### Mobile Flow

1. User clicks button
2. Success message shown (brief)
3. Facebook app opens (if installed) OR browser opens
4. User follows on Facebook
5. Can return to landing page

---

## ✅ CHECKLIST

- [ ] Use official Facebook "f" logo
- [ ] Clear CTA: "Follow Us on Facebook"
- [ ] Facebook blue button color (#1877f2)
- [ ] Link directly to Facebook page
- [ ] Track engagement before redirect
- [ ] Show success message
- [ ] Open in new tab (preserve landing page)
- [ ] Mobile-friendly button size
- [ ] Social proof (follower count)
- [ ] Compliant with Facebook guidelines

---

## 🚀 NEXT STEPS

1. **Update mockup** ✅ (Done - see `CTA_MOCKUP_DEMO.html`)
2. **Get Facebook page URLs** for each zip code
3. **Implement Option B** (Tracked Redirect)
4. **Test on mobile** (button size, redirect)
5. **Track engagement** (clicks, follows)

---

**Bottom Line:** Use Facebook logo + "Follow Us on Facebook" text, track click, then redirect to Facebook page. Simple, compliant, effective.

