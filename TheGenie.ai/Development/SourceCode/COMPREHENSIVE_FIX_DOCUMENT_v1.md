# COMPREHENSIVE FIX DOCUMENT - Complete Project Fix
**Date:** November 12, 2025  
**Status:** CRITICAL FIXES REQUIRED

---

## ROOT CAUSE IDENTIFIED

### The Core Problem
The `0301.CC_SMS_WithDetails_v2.csv` file extracts `PropertyCollectionDetailId` from `GenieLead.PropertyCollectionDetailId`, which is **WRONG** for returning leads.

**Why This Breaks Everything:**
1. When a returning lead clicks a link from an October 2025 campaign, the `GenieLead` record still has the **original** `PropertyCollectionDetailId` from when they first engaged (e.g., August 2024)
2. This causes the report to show zero CTA metrics because:
   - We're looking for CTA tags on leads linked to October campaigns
   - But the leads are linked to old campaigns (from GenieLead.PropertyCollectionDetailId)
   - The actual campaign that sent the message is in `NotificationQueue.CustomData` (`TagLeadPropertyCollectionDetailId`)

**Evidence:**
- Screenshots show leads (Robert Fischer, Jeffrey Mackler) with CTA tags
- These leads have PropertyCollectionDetailId 7133, 8513 (old campaigns)
- But October 2025 messages are from campaigns 15408, 15538, 16581, etc.
- Zero overlap = zero CTA metrics in report

---

## FIXES REQUIRED

### 1. SQL Query Fix: `0301.CC_SMS_WithDetails_v2.sql` ✅ FIXED

**Change:** Extract `PropertyCollectionDetailId` from `CustomData` (`TagLeadPropertyCollectionDetailId`) instead of from `GenieLead`.

**Status:** Query has been updated. **ACTION REQUIRED:** Re-run query and export new CSV.

**File:** `0301.CC_SMS_WithDetails_v2.sql` (lines 58-74)

---

### 2. Python Script Fix: `build_report_from_csv_and_twilio_FINAL.py`

**Issue:** Script relies on CSV having correct PropertyCollectionDetailId, but also needs fallback extraction.

**Fix Required:** Add extraction from `RawCustomData` as primary source, fallback to CSV column.

**Status:** Needs update.

---

### 3. CTA Metrics Linking Fix

**Issue:** CTA tags are on GenieLead records, but we're filtering by campaigns that sent messages. Need to:
1. Get campaigns from messages (correct PropertyCollectionDetailId from CustomData)
2. Find ALL GenieLead records (any date) linked to those campaigns
3. Count CTA tags on those leads

**Status:** Logic needs update in Python script.

---

## DATA FLOW CORRECTION

### Correct Flow:
```
1. NotificationQueue.CustomData contains TagLeadPropertyCollectionDetailId (campaign that SENT message)
2. Extract PropertyCollectionDetailId from CustomData (NOT from GenieLead)
3. Link messages to campaigns using this PropertyCollectionDetailId
4. Find GenieLead records with CTA tags linked to these campaigns
5. Count CTA metrics per campaign
```

### Previous (WRONG) Flow:
```
1. NotificationQueue → GenieLead (via GenieLeadId)
2. Get PropertyCollectionDetailId from GenieLead (OLD campaign)
3. Try to link to October campaigns (NO MATCH)
4. Result: Zero CTA metrics
```

---

## ACTION ITEMS

### Immediate (Before Report Generation):
1. ✅ **DONE:** Fixed `0301.CC_SMS_WithDetails_v2.sql` to extract PropertyCollectionDetailId from CustomData
2. ⏳ **PENDING:** Re-run `0301.CC_SMS_WithDetails_v2.sql` and export new CSV
3. ⏳ **PENDING:** Update Python script to extract PropertyCollectionDetailId from RawCustomData as primary source
4. ⏳ **PENDING:** Fix CTA metrics linking to use campaigns from messages (not from GenieLead)

### Verification:
1. Check that new CSV has PropertyCollectionDetailId matching TagLeadPropertyCollectionDetailId in CustomData
2. Verify October 2025 campaigns match between messages and GenieLead records
3. Confirm CTA tags are found on leads linked to October campaigns

---

## EXPECTED RESULTS AFTER FIX

### Before Fix:
- 8 campaigns with messages in October 2025
- 0 CTA Clicked (all zeros)
- 0 CTA Verified (all zeros)
- 21 Initial Click Count (but wrong campaigns)

### After Fix:
- 8 campaigns with messages in October 2025
- CTA Clicked > 0 (leads with Cta*Accept tags linked to correct campaigns)
- CTA Verified > 0 (leads with CtaContactVerfied tags linked to correct campaigns)
- Initial Click Count matches actual October engagements

---

## FILES TO UPDATE

1. ✅ `0301.CC_SMS_WithDetails_v2.sql` - FIXED
2. ⏳ `build_report_from_csv_and_twilio_FINAL.py` - NEEDS UPDATE
3. ⏳ `0301.CC_SMS_WithDetails_v2.csv` - NEEDS RE-EXPORT

---

## TESTING CHECKLIST

After fixes:
- [ ] New CSV has PropertyCollectionDetailId extracted from CustomData
- [ ] October 2025 campaigns match between messages and GenieLead
- [ ] CTA tags found on leads linked to October campaigns
- [ ] Report shows non-zero CTA metrics
- [ ] All 21 fields populated correctly
- [ ] No zero columns (except Opt Outs which can be zero)

