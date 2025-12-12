# Comprehensive Fixes - All Column Issues

## Issues Identified and Fixes

### ✅ 1. Area Name (Header)
**Problem**: Using raw `Area_9610.0` instead of friendly name
**Fix**: Use `AreaName` from `CC_AreaName.csv.json` (FriendlyName/PolygonNameOverride)
**Status**: FIXED in code

### ✅ 2. Property Type (Column D)
**Problem**: All `N/A` - not joining Property table
**Fix**: 
- Join `PropertyCollection.PropertyId` → `Property.PropertyId` → `Property.Type`
- Or use `PropertyTypeName` from PropertyCastLog if available
- Fallback to "Unknown" if no data (not "N/A" to distinguish from missing data)

### ✅ 3. Listing Status (Column E)
**Problem**: All `N/A` - missing join to Listing/PropertyCast
**Fix**:
- Use `PropertyCastTypeName` from PropertyCastLog (already in query)
- Or `Property.Status` if available
- Show "Unknown" if no listing (not "N/A")

### ✅ 4. Property Collection Count (Column F)
**Problem**: Always `1` instead of `75`
**Fix**: Use `PropertyCount` column directly from CSV (already has 75)
**Status**: FIXED in code

### ✅ 5. Messages Sent (Column G)
**Problem**: All `0` - not linking NotificationQueue correctly
**Fix**:
```python
# Filter NotificationQueue:
# - NotificationChannelId = 2 (SMS)
# - IsAgentNotification = 0 (exclude agent notifications)
# - PropertyCollectionDetailId = campaign_id
# Count distinct MessageSid where status in ('queued','sent','delivered')
```

### ✅ 6. Success Rate % (Column H)
**Problem**: All `0.0%` because Messages Sent = 0
**Fix**:
- Join NotificationQueue → TwilioMessages by MessageSid
- Formula: `(Delivered / Sent) * 100` where Sent > 0
- Delivered = Twilio.Status IN ('delivered','sent')

### ✅ 7. Opt Outs (Column I)
**Problem**: Not linked to PropertyCollectionDetailId
**Fix**:
- Join `OptOuts.PropertyCollectionDetailId` if available
- Fallback to date + user but mark as "(date-level attribution)"

### ✅ 8. Opt Out % (Column J)
**Problem**: Always `0.0%` because Messages Sent = 0
**Fix**: Will auto-calc correctly once Messages Sent is fixed
- Formula: `(OptOuts / MessagesSent) * 100`

### ✅ 9. Initial Click Count (Column K)
**Problem**: Values exist but not linked to PropertyCollectionDetailId
**Fix**:
- Join `0203.CC_SMS_ClickLeads_Daily_ByUser` to campaigns using PropertyCollectionDetailId
- Or match by URL token from NotificationQueue

### ✅ 10. Initial Click % (Column L)
**Problem**: Constant `0.09%` for every row
**Fix**:
```python
row['Initial click % (CTR)'] = (
    row['Initial click count'] / row['Messages sent'] * 100 
    if row['Messages sent'] > 0 else 0
)
```

### ✅ 11. CTA Clicked (Column M)
**Problem**: All zeros - not linked to PropertyCollectionDetailId
**Fix**:
- Pull from `0201.CC_CTA_Daily_ByUserCTA.csv`
- Filter: `EventDay BETWEEN campaign_date AND month_end` AND `PropertyCollectionDetailId = campaign_id`
- Count where Tag LIKE 'Cta%Accept%'

### ✅ 12. CTA Verified (Column N)
**Problem**: All zeros - not linked to PropertyCollectionDetailId
**Fix**:
- Same as CTA Clicked but count where Tag LIKE '%CtaContactVerified%'

### ✅ 13. Agent SMS Notify Count (Column O)
**Problem**: All zeros - not filtering IsAgentNotification = 1
**Fix**:
- Filter NotificationQueue: `IsAgentNotification = 1`, `Channel = 2`, `PropertyCollectionDetailId = campaign_id`
- Count distinct MessageSid

### ✅ 14. Agent Notify Twilio Cost (Column P)
**Problem**: All `$0.00` - no join to TwilioMessages
**Fix**:
- Join NotificationQueue → TwilioMessages by MessageSid
- Filter: IsAgentNotification = 1
- Sum PriceAbs for agent notifications only

### ✅ 15. Total Twilio Cost (Column Q)
**Problem**: All `$0.00` - no join to TwilioMessages
**Fix**:
- Join NotificationQueue → TwilioMessages by MessageSid
- Sum PriceAbs for ALL messages (audience + agent) for this campaign
- De-dupe by MessageSid

## Root Causes

1. **Wrong joins/filters**: Not using PropertyCollectionDetailId consistently
2. **Date-based aggregation only**: Collapsed distinct campaigns
3. **Twilio joins missing**: All message counts and costs = 0
4. **No Property/Listing joins**: Property type and status = N/A
5. **Hard-coded CTR %**: Same for every row

## Implementation Priority

1. **CRITICAL**: Fix Messages Sent (affects Success Rate, Opt Out %, CTR)
2. **CRITICAL**: Fix Twilio joins (affects costs, success rate)
3. **HIGH**: Fix Property Type and Listing Status joins
4. **HIGH**: Fix CTA Clicked/Verified links
5. **MEDIUM**: Fix Area Name friendly name
6. **LOW**: Fix CTR calculation (will auto-fix when Messages Sent is fixed)











