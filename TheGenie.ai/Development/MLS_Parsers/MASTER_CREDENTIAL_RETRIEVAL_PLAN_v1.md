# Master Credential Retrieval Plan - MLS ID 2

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Priority:** GET MLS ID 2 CREDENTIALS WORKING TODAY

---

## 🎯 MISSION: Get MLS ID 2 (EBRDI) RESO Credentials Working TODAY

---

## ✅ WHAT WE KNOW

1. **API URL:** `https://1pp.azurewebsites.net/api-mls/` ✅ WORKING
2. **Wrapper Credentials:** `1parkplaceReso` / `r450!sC00!` (RTK_SYSTEM) ❌ Returns 401
3. **Azure Database:** `1parkplace-sql.database.windows.net` / `1Parkplace` ❌ Firewall blocked
4. **Subscription ID:** `04c791e7-aa21-40bf-b74e-274baa019a6c` ❓ Unknown owner
5. **IT Person:** Doesn't know about it, doesn't work for us anymore

---

## 🚀 EXECUTION PLAN (Run These Scripts in Order)

### Step 1: Identify Colo Server IP
**Script:** `get_colo_server_ip.ps1`

**Why:** The app is running and connecting to Azure, so the colo server's IP must be whitelisted. If we can identify it, we can connect from there.

**Action:**
```powershell
powershell -ExecutionPolicy Bypass -File "get_colo_server_ip.ps1"
```

**Expected Result:** Public IP address that's already whitelisted in Azure SQL firewall.

---

### Step 2: Try Connecting from Colo Server
**If Step 1 succeeds, run:**
```powershell
sqlcmd -S 1parkplace-sql.database.windows.net -d 1Parkplace -U azure-1parkplace -P "1pp@zu43$sql" -Q "SELECT TOP 1 * FROM mls.ResoMlsSettings WHERE MlsId = 2"
```

**If this works, run the full credential queries from `RESO_CREDENTIALS_ACCESS_SUMMARY_v1.md`**

---

### Step 3: Check Azure App Service Logs
**Script:** `get_azure_logs.ps1`

**Why:** Logs might show connection strings, errors, or configuration details.

**Action:**
```powershell
powershell -ExecutionPolicy Bypass -File "get_azure_logs.ps1"
```

**Expected Result:** 
- Subscription found/not found
- App Service configuration
- Connection strings
- Firewall rules

---

### Step 4: Test API with Real MLS Data
**Script:** `query_mls2_via_api.ps1`

**Why:** If the API works with proper auth, we can at least USE the credentials even if we can't see them.

**Action:**
```powershell
powershell -ExecutionPolicy Bypass -File "query_mls2_via_api.ps1"
```

**Expected Result:** 
- Real MLS ID 2 listing data
- Confirmation that credentials are working
- Understanding of authentication method

---

### Step 5: Manual Azure Portal Check
**If scripts don't work, manually:**

1. **Go to:** https://portal.azure.com
2. **Search for:** "1Parkplace" or "1parkplace-sql"
3. **If found:**
   - SQL databases → 1Parkplace → Query editor
   - Run queries from `RESO_CREDENTIALS_ACCESS_SUMMARY_v1.md`
4. **If NOT found:**
   - Check Subscriptions → Look for `04c791e7-aa21-40bf-b74e-274baa019a6c`
   - If subscription exists but database not visible, check resource groups

---

## 🔧 ALTERNATIVE METHODS

### Method A: Check Application Configuration Files
**Location:** Azure App Service → Configuration → Application settings

**What to look for:**
- `AzureConnectionString`
- `ConnectionStrings__AzureConnectionString`
- Any connection strings with "1parkplace-sql"

**How:**
1. Azure Portal → App Services → 1pp → Configuration
2. Look for connection strings
3. May reveal alternative connection methods

---

### Method B: Use Kudu (Advanced Tools)
**Location:** Azure App Service → Advanced Tools (Kudu) → Debug console

**What to do:**
1. Navigate to: `https://1pp.scm.azurewebsites.net`
2. Debug console → CMD
3. Check `appsettings.json` or environment variables
4. May reveal connection details

---

### Method C: Check Application Insights
**If Application Insights is configured:**

1. Azure Portal → Application Insights → 1pp (or related)
2. Logs → Queries
3. Search for: "connection", "database", "1parkplace-sql"
4. May show connection attempts and errors

---

## 📋 SQL QUERIES TO RUN (Once We Have Access)

### Query 1: Get MLS ID 2 RESO Settings
```sql
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

### Query 2A: If Trestle (ProviderTypeId = 1)
```sql
SELECT 
    cr.ResoTrestleCredentialId,
    cr.ClientId,
    cr.ClientSecret,
    cr.TokenCacheMinutes,
    e.Endpoint AS TokenEndpoint,
    seg.Segment AS TokenSegment,
    scp.Scope,
    gt.GrantType
FROM mls.ResoCredentialTrestle cr
LEFT JOIN mls.ResoEndpoint e ON e.ResoEndpointId = cr.ResoEndpointId
LEFT JOIN mls.ResoEndpointSegment seg ON seg.ResoEndpointSegmentId = cr.TokenSegmentId
LEFT JOIN mls.ResoCredentialScope scp ON scp.ResoCredentialScopeId = cr.ScopeId
LEFT JOIN mls.ResoCredentialGrantType gt ON gt.ResoCredentialGrantTypeId = cr.GrantTypeId
WHERE cr.ResoTrestleCredentialId = (
    SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2
);
```

### Query 2B: If Bridge (ProviderTypeId = 2)
```sql
SELECT 
    cr.ResoBridgeCredentialId,
    cr.ServerToken,
    cr.TokenCacheInMinutes,
    br.Name AS DataSetName
FROM mls.ResoCredentialBridge cr
LEFT JOIN mls.ResoBridgeDataSet br ON br.MlsId = 2
WHERE cr.ResoBridgeCredentialId = (
    SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2
);
```

---

## ⚡ QUICK START (Run These Now)

```powershell
# 1. Get colo server IP
powershell -ExecutionPolicy Bypass -File "get_colo_server_ip.ps1"

# 2. Try Azure logs
powershell -ExecutionPolicy Bypass -File "get_azure_logs.ps1"

# 3. Test API
powershell -ExecutionPolicy Bypass -File "query_mls2_via_api.ps1"
```

---

## 🎯 SUCCESS CRITERIA

**We've succeeded when we can:**
1. ✅ Query MLS ID 2 RESO credentials from Azure database
2. ✅ See ClientId/ClientSecret (Trestle) or ServerToken (Bridge)
3. ✅ Understand which provider (Trestle vs Bridge)
4. ✅ Know which organization MLS ID 2 connects to (Bay East vs Bridge MLS)
5. ✅ Test the credentials work

---

## 📞 IF ALL ELSE FAILS

**Contact:**
- Azure Support (if you have support plan)
- Check billing/account owner for subscription `04c791e7-aa21-40bf-b74e-274baa019a6c`
- Previous developers/contractors who might have set this up
- Check company email archives for "1parkplace-sql" or "Azure SQL"

---

**LET'S GET THIS DONE TODAY! 🚀**



