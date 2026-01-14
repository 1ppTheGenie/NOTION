# Testing Plan: Bridge MLS Access

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent

---

## Objective

**Test if we still have access to Bridge MLS data** using credentials from Azure database.

---

## Current Understanding

### ✅ Confirmed:
1. **We had both** - EBRD (Bridge MLS) and CCAR (Bay East) agreements
2. **We might still have both** - Agreements may still be valid
3. **We're only grabbing from one** - Currently getting Bay East data (active)
4. **Bridge MLS data is old** - Last update: 2019-09-11 (6+ years ago)

### ❓ Unknown:
- Do Bridge MLS credentials still work?
- Are credentials still in Azure database?
- Is the feed still active but we're just not using it?
- Or did Bridge MLS revoke/expire our access?

---

## Testing Steps

### Step 1: Get Credentials from Azure Database

**Method:** Azure Portal Query Editor (no firewall changes needed)

**Query:**
```sql
-- Check if MLS ID 2 has RESO settings
SELECT 
    s.MlsId,
    s.ProviderTypeId,
    s.CredentialId,
    s.Enabled,
    p.Name AS ProviderName
FROM mls.ResoMlsSettings s
LEFT JOIN mls.ResoProvider p ON p.ResoProviderTypeId = s.ProviderTypeId
WHERE s.MlsId = 2;
```

**Expected Results:**
- If `Enabled = 1` → Credentials are active
- If `Enabled = 0` → Credentials exist but disabled
- If no row → No credentials configured

**Then get actual credentials based on ProviderTypeId:**
- If `ProviderTypeId = 1` (Trestle): Get ClientId, ClientSecret
- If `ProviderTypeId = 2` (Bridge): Get ServerToken

---

### Step 2: Test Bridge MLS API Access

**If credentials found:**

1. **Test Trestle (if ProviderTypeId = 1):**
   - Use ClientId + ClientSecret
   - Call OAuth token endpoint
   - Try to get listing data
   - Check if we get data or error

2. **Test Bridge (if ProviderTypeId = 2):**
   - Use ServerToken
   - Call Bridge API endpoint
   - Try to get listing data
   - Check if we get data or error

**Expected Outcomes:**
- ✅ **Success:** We still have access, just not using it
- ❌ **401/403 Error:** Credentials expired/revoked
- ❌ **404 Error:** Endpoint changed or feed disabled
- ❌ **Other Error:** Need to investigate

---

### Step 3: Check for Separate Bridge MLS MLS ID

**Query:**
```sql
-- Check if there's a separate MLS ID for Bridge MLS
SELECT MlsID, Name, DisplayName 
FROM dbo.Mls 
WHERE Name LIKE '%Bridge%' 
   OR DisplayName LIKE '%Bridge%'
   OR Name LIKE '%EBRD%'
ORDER BY MlsID;
```

**Possible Scenarios:**
- **Scenario A:** MLS ID 2 is Bridge MLS, Bay East uses different ID
- **Scenario B:** MLS ID 2 is Bay East, Bridge MLS uses different ID
- **Scenario C:** Both use MLS ID 2 (unlikely given data patterns)

---

### Step 4: Test RETS Server (Legacy)

**Server IP Found:** `69.43.128.180`

**Test:**
1. Try accessing: `http://69.43.128.180` or `https://69.43.128.180`
2. Check if RETS server is still active
3. May need RETS username/password (not in PDFs, may be in Azure or config)

**Note:** RETS is legacy protocol, may have been replaced by RESO API.

---

## What We'll Learn

### If Credentials Work:
- ✅ We still have access to Bridge MLS
- ✅ We can start pulling Bridge MLS data again
- ✅ Need to determine why we stopped using it

### If Credentials Don't Work:
- ❌ Access was revoked/expired
- ❌ Need to contact Bridge MLS to renew
- ❌ May need new agreement

### If No Credentials Found:
- ❓ Never had Bridge MLS RESO credentials
- ❓ Only had RETS access (legacy)
- ❓ Need to set up new RESO access

---

## Next Steps

1. **IMMEDIATE:** Access Azure database via Portal Query Editor
2. **Get credentials** for MLS ID 2
3. **Test API access** with those credentials
4. **Document results** - working or not working
5. **If working:** Determine why we're not using Bridge MLS data
6. **If not working:** Contact Bridge MLS to renew access

---

**File Location:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\TESTING_PLAN_BRIDGE_MLS_v1.md`

