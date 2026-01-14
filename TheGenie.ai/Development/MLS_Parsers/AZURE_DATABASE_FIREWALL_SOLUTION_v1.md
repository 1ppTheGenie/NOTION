# Azure Database Firewall Access Solution

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent

---

## Problem

**Azure SQL Database:** `1parkplace-sql.database.windows.net`  
**Database:** `1Parkplace`  
**Error:** `Client with IP address '173.172.255.188' is not allowed to access the server`

**Impact:** Cannot query RESO credentials stored in `mls` schema tables.

---

## Solutions

### Option 1: Add IP to Azure SQL Firewall (RECOMMENDED)

**Steps:**
1. Log into Azure Portal: https://portal.azure.com
2. Navigate to: SQL databases → `1Parkplace` → Networking
3. Under "Firewall rules", click "Add client IP"
4. Or manually add rule:
   - Rule name: `Cursor-Development-IP`
   - Start IP: `173.172.255.188`
   - End IP: `173.172.255.188`
5. Click "Save"
6. Wait 1-2 minutes for rule to take effect

**Note:** IP may change if using dynamic IP. Consider using Option 2 for permanent solution.

---

### Option 2: Use VPN Connection

If you have VPN access to the network:
1. Connect to VPN
2. Use VPN IP address (likely already whitelisted)
3. Connect to Azure database

---

### Option 3: Azure Portal Query Editor

**Steps:**
1. Log into Azure Portal: https://portal.azure.com
2. Navigate to: SQL databases → `1Parkplace` → Query editor
3. Use Azure Portal's built-in query editor
4. Execute SQL queries directly in browser
5. No firewall restrictions (uses Azure authentication)

**Limitation:** May have query timeout limits, but good for credential lookups.

---

### Option 4: Use Existing Application Connection

**If the application (`Smart.Api.MlsData`) is already running and can access the database:**
1. Check if application logs show successful connections
2. May be able to query through application API endpoints
3. Or check application configuration for connection pooling

---

### Option 5: Temporary IP Range Whitelist

**For development flexibility:**
1. Add IP range instead of single IP:
   - Start IP: `173.172.255.0`
   - End IP: `173.172.255.255`
2. Covers entire subnet
3. **Security Note:** Only use for development, not production

---

## Current IP Address

**Last Known IP:** `173.172.255.188` (from error message)  
**Note:** This may change if using dynamic IP. Check current IP with:
```powershell
(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content
```

---

## Required Queries (Once Access Granted)

```sql
-- Get MLS 2 RESO settings
SELECT 
    s.MlsId,
    s.ProviderTypeId,
    s.CredentialId,
    s.Enabled,
    p.Name AS ProviderName
FROM mls.ResoMlsSettings s
LEFT JOIN mls.ResoProvider p ON p.ResoProviderTypeId = s.ProviderTypeId
WHERE s.MlsId = 2;

-- Get provider type (1=Trestle, 2=Bridge technology)
-- Then query appropriate credential table based on ProviderTypeId
```

---

## Next Steps

1. **IMMEDIATE:** Try Azure Portal Query Editor (Option 3) - fastest, no firewall changes needed
2. **SHORT TERM:** Add current IP to firewall (Option 1)
3. **LONG TERM:** Set up VPN or static IP for development access

---

**File Location:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\AZURE_DATABASE_FIREWALL_SOLUTION_v1.md`

