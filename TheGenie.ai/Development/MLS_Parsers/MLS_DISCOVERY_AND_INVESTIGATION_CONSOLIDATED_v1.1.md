# MLS Discovery and Investigation - Consolidated Report
**Version:** 1.1  
**Created:** 12/30/2025 4:00 PM  
**Last Updated:** 01/01/2026 7:15 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ CONSOLIDATED - Single Source of Truth

---

## 🎯 EXECUTIVE SUMMARY

**MLS ID 2 Investigation Results:**
- **Current Organization:** Bay East (not Bridge MLS)
- **Evidence:** Most recent Bay East listing: 2025-12-24 (active); Bridge MLS: 2019-09-11 (inactive)
- **Credentials Location:** Azure SQL Database `1parkplace-sql.database.windows.net` → `1Parkplace` → `mls.ResoCredentialBridge.ServerToken`
- **Access Status:** ❌ Firewall blocked; Azure subscription ownership unknown

---

## 📊 CRITICAL FINDINGS

### MLS ID 2 Organization Determination

**MLS ID 2** is currently named "EBRDI" / "MAX/EBRDI MLS" in the database. After the EBRD/CCAR split:
- **EBRD** became **Bridge MLS** (the organization)
- **CCAR** merged with another to become **Bay East**

**CRITICAL QUESTION:** Which organization is MLS ID 2 currently connected to?

**Answer: Bay East (CCAR)**

**Evidence:**
1. **Recent Activity:**
   - **Bay East:** Most recent listing updated **2025-12-24** (6 days ago) ✅ ACTIVE
   - **Bridge MLS:** Most recent listing updated **2019-09-11** (6+ years ago) ❌ INACTIVE

2. **Database Statistics:**
   - 418 listings with `bridgeMLS` broker name (legacy data)
   - 114 listings with "Bay East" broker name (active data)
   - Total: 508,224 listings in MLS ID 2

3. **IDX Agreements:**
   - **CCAR Agreement (2018):** Signed 06/25/2018 - This is Bay East (CCAR merged)
   - **Bridge MLS Agreement:** Exists but no recent data

---

## 🔍 CREDENTIAL INVESTIGATION

### What We Found

#### 1. Correct API URL
- **Working URL:** `https://1pp.azurewebsites.net/api-mls/`
- **Test Endpoint:** `/Listing/testconnect` returns 200 OK
- **Data Endpoint:** `/Listing/get/{mlsId}/{mlsNumber}` requires authentication

#### 2. Wrapper Service Credentials (RTK_SYSTEM)
- **Username:** `1parkplaceReso`
- **Password:** `r450!sC00!`
- **Location:** `RTK_SYSTEM.dbo.ApiSubscriber` (ApiID = 7)
- **Status:** ❌ Returns 401 Unauthorized when used with Basic Auth

#### 3. Azure Database Location
- **Server:** `1parkplace-sql.database.windows.net`
- **Database:** `1Parkplace`
- **Schema:** `mls`
- **Tables:** `ResoMlsSettings`, `ResoCredentialTrestle`, `ResoCredentialBridge`
- **Connection String:** Found in `Smart.Api.MlsData/appsettings.json`
- **Credentials:** `azure-1parkplace` / `1pp@zu43$sql`
- **Status:** ❌ Firewall blocking IP `173.172.255.188`

#### 4. Azure Subscription Mystery
- **Subscription ID:** `04c791e7-aa21-40bf-b74e-274baa019a6c`
- **Resource Group:** `1Parkplace`
- **App Service:** `1pp` (https://1pp.azurewebsites.net)
- **Status:** ❌ IT person has never heard of this database
- **Likely:** Different Azure account/subscription, or set up by contractor who left

#### 5. Provider Type Confirmed
- **EBRDI Uses Bridge Provider** (confirmed in source code: `TestConfiguration.cs` line 1422)
- **Provider Type:** Bridge (not Trestle)
- **Credential Type Needed:** ServerToken (not ClientId/ClientSecret)

---

## 🔎 SEARCH RESULTS

### Local File Search
- ✅ Searched all source code
- ✅ Searched config files
- ✅ Searched documentation
- ❌ No credentials found locally

### Connection Strings Found
- All point to Azure: `1parkplace-sql.database.windows.net`
- No local database with credentials

**Conclusion:** Credentials are ONLY in Azure database. We CANNOT get them without Azure access.

---

## 💡 PRACTICAL OPTIONS

### Option 1: Search Email Archives (MOST LIKELY TO WORK)
**Search development@1parkplace.com emails for:**
- "ServerToken"
- "Bridge"
- "EBRDI" 
- "MLS 2"
- "RESO"
- "1parkplace-sql"
- "Azure SQL"
- "credentials"
- "API key"

**Timeframe:** Search last 2-3 years of emails  
**Why this might work:** Someone may have emailed credentials or setup instructions

---

### Option 2: Contact Bridge MLS Directly
**What to ask:**
- "We need our RESO API ServerToken for EBRDI/CCAR"
- "Can you look up our account and provide the ServerToken?"
- "Or can you reset/regenerate it?"

**Contact info needed:**
- Bridge MLS support/technical contact
- May be in IDX agreements we found

---

### Option 3: Try Azure Portal Access
**Since development@1parkplace.com goes to you:**
1. Go to: https://portal.azure.com
2. Log in with development@1parkplace.com (or your Azure account)
3. Search for: "1Parkplace"
4. If you can see it → Use Query Editor (no firewall needed!)

---

### Option 4: Contact Bay East (CCAR)
**Since MLS ID 2 is actually connected to Bay East:**
- Contact Bay East support
- Request RESO API credentials
- May need to renew 2018 agreement

**Contact Information (From CCAR Agreement):**
- **Organization:** Contra Costa Association of REALTORS® (CCAR) → **Now Bay East**
- **Company:** 1parkplace Inc.
- **Contact:** Steve Hundley, CEO
- **Phone:** 888-425-2300 Opt 2
- **Address:** PO Box 501682, San Diego, CA 92150
- **Company URL:** http://www.1parkplace.com
- **Server IP (RETS):** 69.43.128.180
- **Agreement Date:** 06/25/2018
- **Access Type:** RETS ACCESS

---

## 📋 CONTACT INFORMATION

### Bay East (CCAR) - Primary Contact
| Item | Value |
|------|-------|
| **Organization** | Contra Costa Association of REALTORS® (CCAR) → **Now Bay East** |
| **Company** | 1parkplace Inc. |
| **Contact** | Steve Hundley, CEO |
| **Phone** | 888-425-2300 Opt 2 |
| **Address** | PO Box 501682, San Diego, CA 92150 |
| **Company URL** | http://www.1parkplace.com |
| **Server IP (RETS)** | 69.43.128.180 |
| **Agreement Date** | 06/25/2018 |
| **Access Type** | RETS ACCESS |

**⚠️ NEED TO FIND:**
- Current Bay East website/portal URL
- Bay East support contact email
- Bay East API/RESO credentials portal
- Current agreement status (2018 agreement may need renewal)

---

## 🚨 THE REALITY CHECK

**The Situation:**
- ✅ Credentials exist in Azure database (`1Parkplace` → `mls.ResoCredentialBridge.ServerToken`)
- ❌ No one currently has Azure access to that subscription
- ❌ Ex-employee who set it up is gone
- ❌ Lead developer (Andrew) who probably set it up has passed away
- ❌ IT doesn't know about it
- ❌ development@1parkplace.com is just email forward, not Azure account
- ❌ No credentials found in local files

**We're locked out of Azure, but the app IS working, so credentials exist and are valid.**

---

## 📝 NEXT STEPS

### Immediate Actions:
1. **Search Email Archives** - Most likely to find credentials
2. **Try Azure Portal Access** - Use development@1parkplace.com login
3. **Contact Bay East** - Request RESO API credentials (since MLS ID 2 is connected to Bay East)
4. **Contact Bridge MLS** - As backup option

### Long-term Actions:
1. **Document Azure Subscription Ownership** - Identify who owns subscription `04c791e7-aa21-40bf-b74e-274baa019a6c`
2. **Establish Azure Access** - Get proper access to Azure subscription
3. **Renew Agreements** - Verify 2018 Bay East agreement is still valid
4. **Document Credentials** - Once found, document in secure credential management system

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.1 | 01/01/2026 7:15 PM | **CONSOLIDATED** - Merged EXECUTIVE_SUMMARY_MLS_2_INVESTIGATION_v1.md, MLS_2_ORGANIZATION_DETERMINATION_v1.md, CRACKING_THE_CODE_SUMMARY_v1.md, SEARCH_ALL_LOCATIONS_v1.md, SEARCH_RESULTS_SUMMARY_v1.md, and REALITY_CHECK_AND_OPTIONS_v1.md into single comprehensive MLS discovery document. Includes organization determination, credential investigation, search results, practical options, and contact information. |
| 1.0 | 12/30/2025 4:00 PM | Initial investigation documents (now consolidated) |

---

*File: MLS_DISCOVERY_AND_INVESTIGATION_CONSOLIDATED_v1.1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\MLS_Parsers\*

