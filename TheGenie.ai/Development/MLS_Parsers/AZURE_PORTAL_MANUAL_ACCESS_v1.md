# Azure Portal Manual Access - Get MLS ID 2 Credentials TODAY

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Priority:** GET CREDENTIALS NOW

---

## 🎯 YOUR MISSION: Get MLS ID 2 RESO Credentials

**Your Current IP:** `173.172.255.188`  
**This IP needs to be whitelisted OR you need to use Azure Portal Query Editor**

---

## ✅ OPTION 1: Azure Portal Query Editor (FASTEST - No Firewall Changes)

### Step 1: Log Into Azure Portal
1. Go to: **https://portal.azure.com**
2. Log in with your Azure account

### Step 2: Find the Database
**Method A: Direct Search**
1. In the **top search bar**, type: `1Parkplace`
2. Click on: **SQL database: 1Parkplace**

**Method B: Browse**
1. Click **"All resources"** in left sidebar
2. Filter by type: **SQL databases**
3. Find and click: **1Parkplace**

**Method C: If Not Found**
1. Click **"Subscriptions"** in left sidebar
2. Look for subscription: `04c791e7-aa21-40bf-b74e-274baa019a6c`
3. If found, click it and search for "1Parkplace"
4. If NOT found, the database is in a different account (see Option 2)

### Step 3: Open Query Editor
1. On the **1Parkplace** database page, look in the **left sidebar**
2. Find: **"Query editor (preview)"** or **"Query editor"**
3. Click it

### Step 4: Authenticate
1. Choose: **SQL authentication**
2. Username: `azure-1parkplace`
3. Password: `1pp@zu43$sql`
4. Click **OK**

### Step 5: Run These Queries (Copy/Paste from `GET_MLS2_CREDENTIALS.sql`)

**Query 1: Get MLS ID 2 Settings**
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

**Query 2: Get Credentials (Run AFTER Query 1 to see ProviderTypeId)**

**If ProviderTypeId = 1 (Trestle):**
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

**If ProviderTypeId = 2 (Bridge):**
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

### Step 6: Copy the Results
- **Copy the ClientId, ClientSecret (Trestle) OR ServerToken (Bridge)**
- **Save them immediately!**

---

## ✅ OPTION 2: Add Your IP to Firewall

### Step 1: Find the Database
1. Azure Portal → SQL databases → **1Parkplace**

### Step 2: Add Firewall Rule
1. Click **"Networking"** in left sidebar
2. Under **"Firewall rules"**, click **"Add client IP"**
3. Your IP `173.172.255.188` should auto-populate
4. Click **"Save"**
5. Wait 1-2 minutes

### Step 3: Connect
```powershell
sqlcmd -S 1parkplace-sql.database.windows.net -d 1Parkplace -U azure-1parkplace -P "1pp@zu43$sql" -Q "SELECT TOP 1 * FROM mls.ResoMlsSettings WHERE MlsId = 2"
```

---

## ✅ OPTION 3: Find Subscription Owner

**If database is NOT in your Azure account:**

1. **Check Billing:**
   - Azure Portal → Cost Management + Billing
   - Look for subscription `04c791e7-aa21-40bf-b74e-274baa019a6c`
   - See who's paying for it

2. **Check Email Archives:**
   - Search for: "1parkplace-sql", "Azure SQL", "04c791e7"
   - Look for setup emails, invoices, or documentation

3. **Check Company Records:**
   - Who set up Azure resources?
   - Previous developers/contractors?
   - IT department records?

4. **Contact Azure Support:**
   - If you have a support plan
   - They can help identify subscription owner

---

## 🚨 IF DATABASE NOT FOUND IN AZURE PORTAL

**This means:**
- Database is in a different Azure account/subscription
- Set up by someone else (contractor, previous employee)
- Personal Azure account

**Next Steps:**
1. Check all Azure subscriptions you have access to
2. Ask team: "Who set up the 1pp App Service?"
3. Check billing records for Azure charges
4. Search email for "Azure" + "1parkplace"

---

## 📋 QUICK REFERENCE

**Database:** `1parkplace-sql.database.windows.net`  
**Database Name:** `1Parkplace`  
**Username:** `azure-1parkplace`  
**Password:** `1pp@zu43$sql`  
**Schema:** `mls`  
**Tables:** `ResoMlsSettings`, `ResoCredentialTrestle`, `ResoCredentialBridge`  
**Subscription ID:** `04c791e7-aa21-40bf-b74e-274baa019a6c`  
**Your IP:** `173.172.255.188`

---

## ✅ SUCCESS CHECKLIST

- [ ] Found database in Azure Portal
- [ ] Opened Query Editor
- [ ] Ran Query 1 (got ProviderTypeId)
- [ ] Ran Query 2 (got credentials)
- [ ] Copied ClientId/ClientSecret OR ServerToken
- [ ] Documented which provider (Trestle vs Bridge)
- [ ] Tested credentials work

---

**GO GET THOSE CREDENTIALS! 🚀**



