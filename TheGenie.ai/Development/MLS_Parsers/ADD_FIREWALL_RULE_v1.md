# Add Firewall Rule - Get Direct Database Access

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent

---

## 🎯 GOAL: Add Your IP to Azure SQL Firewall

**Your IP:** `173.172.255.188`  
**Once added, you can connect directly using sqlcmd!**

---

## ✅ STEP-BY-STEP: Add Firewall Rule

### Step 1: Log Into Azure Portal
1. Go to: **https://portal.azure.com**
2. Log in with your Azure account

### Step 2: Find the SQL Server
**Method A: Direct Search**
1. In the **top search bar**, type: `1parkplace-sql`
2. Click on: **SQL server: 1parkplace-sql**

**Method B: Via Database**
1. Search for: `1Parkplace` (SQL database)
2. Click on it
3. Look for **"Server name"** on the Overview page
4. Click the server name link (should be `1parkplace-sql`)

**Method C: Browse**
1. Click **"All resources"** in left sidebar
2. Filter by type: **SQL servers**
3. Find and click: **1parkplace-sql**

### Step 3: Open Networking/Firewall Settings
1. On the SQL server page, look in the **left sidebar**
2. Under **"Security"**, click **"Networking"**
3. OR click **"Firewalls and virtual networks"** (older interface)

### Step 4: Add Your IP
**Option A: Quick Add (Recommended)**
1. Click **"Add client IP"** button
2. Your IP `173.172.255.188` should auto-populate
3. Click **"Save"**
4. Wait 1-2 minutes for rule to take effect

**Option B: Manual Add**
1. Click **"+ Add a firewall rule"** or **"Add client IP"**
2. **Rule name:** `Cursor-Development-IP` (or any name)
3. **Start IP address:** `173.172.255.188`
4. **End IP address:** `173.172.255.188`
5. Click **"OK"** or **"Save"**
6. Wait 1-2 minutes

### Step 5: Verify Rule Added
You should see a new rule in the list:
- **Rule name:** `ClientIPAddress_YYYYMMDD_HHMMSS` (auto-generated) OR your custom name
- **Start IP:** `173.172.255.188`
- **End IP:** `173.172.255.188`

---

## ✅ TEST CONNECTION (After Adding Rule)

### Wait 1-2 Minutes
Firewall rules can take a minute or two to propagate.

### Test with sqlcmd
Run this command:
```powershell
sqlcmd -S 1parkplace-sql.database.windows.net -d 1Parkplace -U azure-1parkplace -P "1pp@zu43$sql" -Q "SELECT TOP 1 MlsId, ProviderTypeId FROM mls.ResoMlsSettings WHERE MlsId = 2" -W -h -1
```

**If it works, you'll see:**
```
2 1
(1 rows affected)
```

**If it still fails:**
- Wait another minute (rules can take time)
- Double-check the IP was added correctly
- Make sure you're using the correct server name

---

## 🚀 ONCE CONNECTED: Get MLS ID 2 Credentials

### Run Query 1: Get Settings
```powershell
sqlcmd -S 1parkplace-sql.database.windows.net -d 1Parkplace -U azure-1parkplace -P "1pp@zu43$sql" -Q "SELECT s.MlsId, s.ProviderTypeId, s.CredentialId, s.Enabled, p.Name AS ProviderName FROM mls.ResoMlsSettings s LEFT JOIN mls.ResoProvider p ON p.ResoProviderTypeId = s.ProviderTypeId WHERE s.MlsId = 2" -W -h -1
```

### Run Query 2A: If ProviderTypeId = 1 (Trestle)
```powershell
sqlcmd -S 1parkplace-sql.database.windows.net -d 1Parkplace -U azure-1parkplace -P "1pp@zu43$sql" -Q "SELECT cr.ClientId, cr.ClientSecret, e.Endpoint AS TokenEndpoint, seg.Segment AS TokenSegment, scp.Scope, gt.GrantType FROM mls.ResoCredentialTrestle cr LEFT JOIN mls.ResoEndpoint e ON e.ResoEndpointId = cr.ResoEndpointId LEFT JOIN mls.ResoEndpointSegment seg ON seg.ResoEndpointSegmentId = cr.TokenSegmentId LEFT JOIN mls.ResoCredentialScope scp ON scp.ResoCredentialScopeId = cr.ScopeId LEFT JOIN mls.ResoCredentialGrantType gt ON gt.ResoCredentialGrantTypeId = cr.GrantTypeId WHERE cr.ResoTrestleCredentialId = (SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2)" -W -h -1
```

### Run Query 2B: If ProviderTypeId = 2 (Bridge)
```powershell
sqlcmd -S 1parkplace-sql.database.windows.net -d 1Parkplace -U azure-1parkplace -P "1pp@zu43$sql" -Q "SELECT cr.ServerToken, cr.TokenCacheInMinutes, br.Name AS DataSetName FROM mls.ResoCredentialBridge cr LEFT JOIN mls.ResoBridgeDataSet br ON br.MlsId = 2 WHERE cr.ResoBridgeCredentialId = (SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2)" -W -h -1
```

---

## 📋 EASIER: Use SQL File

Instead of typing long commands, you can:

1. **Create a file:** `query.sql` with the SQL queries
2. **Run it:**
```powershell
sqlcmd -S 1parkplace-sql.database.windows.net -d 1Parkplace -U azure-1parkplace -P "1pp@zu43$sql" -i "GET_MLS2_CREDENTIALS.sql" -W
```

---

## 🚨 TROUBLESHOOTING

### Problem: Can't Find SQL Server
**Solution:**
- Database might be in a different subscription
- Check all subscriptions you have access to
- Look for subscription ID: `04c791e7-aa21-40bf-b74e-274baa019a6c`

### Problem: "Add client IP" Button Not Available
**Solution:**
- You might not have permissions
- Try "Add a firewall rule" manually
- Or use Azure Portal Query Editor instead (no firewall needed)

### Problem: Connection Still Fails After Adding Rule
**Solutions:**
1. Wait 2-3 minutes (rules can take time)
2. Double-check IP: `173.172.255.188`
3. Make sure you're connecting to: `1parkplace-sql.database.windows.net`
4. Check if your IP changed (if dynamic IP)
5. Try Azure Portal Query Editor (bypasses firewall)

### Problem: IP Changed (Dynamic IP)
**Solution:**
- Add a range instead of single IP
- Or add your current IP again
- Consider using Azure Portal Query Editor (no IP needed)

---

## ✅ ALTERNATIVE: Azure Portal Query Editor

**If firewall doesn't work, use Query Editor:**
- No firewall changes needed
- Works from any IP
- Just log into Azure Portal
- See: `AZURE_PORTAL_MANUAL_ACCESS_v1.md`

---

## 🎯 QUICK SUMMARY

1. **Go to Azure Portal:** https://portal.azure.com
2. **Find SQL Server:** Search `1parkplace-sql`
3. **Open Networking:** Click "Networking" in left sidebar
4. **Add IP:** Click "Add client IP" → `173.172.255.188`
5. **Save:** Wait 1-2 minutes
6. **Test:** Run sqlcmd command above
7. **Get Credentials:** Run queries from `GET_MLS2_CREDENTIALS.sql`

**LET'S DO THIS! 🚀**



