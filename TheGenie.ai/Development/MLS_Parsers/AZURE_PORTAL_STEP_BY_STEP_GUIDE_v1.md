# Azure Portal Query Editor - Step-by-Step Guide

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Purpose:** Guide you through accessing Azure database to get MLS ID 2 RESO credentials

---

## Overview

We're going to use **Azure Portal Query Editor** to query the database. This is the EASIEST method - no firewall changes needed, no VPN required. You just log in and use the built-in query editor in your browser.

**What we're looking for:**
- RESO provider type (Trestle vs Bridge technology)
- Credentials (ClientId, ClientSecret, or ServerToken)
- API endpoints
- Which organization MLS ID 2 connects to

---

## STEP 1: Log Into Azure Portal

### Action:
1. Open your web browser (Chrome, Edge, Firefox - any browser works)
2. Go to: **https://portal.azure.com**
3. Log in with your Azure account credentials

### What You Should See:
- Azure Portal dashboard
- Left sidebar with menu items
- Top search bar
- Your subscription/resource groups

### ✅ Checkpoint:
**After logging in, take a screenshot and send it to me. I'll confirm you're in the right place and guide you to the next step.**

---

## STEP 2: Find the SQL Database

### Action:
1. In the **top search bar** (at the very top of the page), type: `1Parkplace`
2. You should see a result like: **SQL database: 1Parkplace**
3. Click on it

**OR**

1. In the **left sidebar**, look for "SQL databases" (you may need to click "All services" first)
2. Click "SQL databases"
3. Find and click on **"1Parkplace"**

### What You Should See:
- A page with database details
- Overview tab (default)
- Left sidebar with options like: Overview, Activity log, Access control, etc.
- Database information (server name, status, etc.)

### ✅ Checkpoint:
**Take a screenshot of the database page and send it to me. I'll confirm you found the right database.**

---

## STEP 3: Open Query Editor

### Action:
1. In the **left sidebar** on the database page, scroll down and look for **"Query editor (preview)"** or just **"Query editor"**
2. Click on it

### What You Should See:
- A query editor interface
- A login prompt asking for:
  - **SQL authentication** (username/password)
  - OR **Azure Active Directory authentication**

### ✅ Checkpoint:
**Take a screenshot of the query editor/login screen and send it to me. I'll tell you which authentication method to use.**

---

## STEP 4: Authenticate

### Action (Choose ONE based on what you see):

**Option A: SQL Authentication**
- Username: `azure-1parkplace`
- Password: `1pp@zu43$sql`
- Click "OK" or "Connect"

**Option B: Azure Active Directory**
- Use your Azure account (same one you logged into portal with)
- Click "Continue as [your name]"

### What You Should See:
- Query editor loads
- Left sidebar showing database objects (Tables, Views, etc.)
- Main area with a query window
- "Run" button or "Execute" button

### ✅ Checkpoint:
**Take a screenshot of the query editor after logging in and send it to me. I'll give you the first query to run.**

---

## STEP 5: Run First Query (Check MLS ID 2 Settings)

### Action:
1. In the query window (main text area), I'll give you a SQL query to paste
2. Paste the query
3. Click **"Run"** or **"Execute"** button (usually at the top of the query window)

### First Query:
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

### What You Should See:
- Query results in a table format
- Columns: MlsId, ProviderTypeId, CredentialId, Enabled, ProviderName
- One row of data (for MLS ID 2)

### ✅ Checkpoint:
**Take a screenshot of the query results and send it to me. I'll tell you what it means and give you the next query based on the results.**

---

## STEP 6: Get Credentials (Based on Provider Type)

### Action:
I'll give you the appropriate query based on what we found in Step 5:

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

### What You Should See:
- Credentials in the results
- ClientId, ClientSecret (for Trestle) OR ServerToken (for Bridge)
- Endpoint URLs
- Other configuration details

### ✅ Checkpoint:
**Take a screenshot of the credentials (you can blur sensitive parts if you want) and send it to me. I'll document everything.**

---

## STEP 7: Get Query Templates and Endpoints

### Action:
Run this query to get the API query templates:

```sql
SELECT 
    q.Query,
    r.Resource,
    e.Endpoint AS DataEndpoint,
    seg.Segment AS DataSegment
FROM mls.ResoSingleListingResourceQuery q
LEFT JOIN mls.ResoDataResource r ON r.ResoDataResourceId = q.ResoDataResourceId
LEFT JOIN mls.ResoDataEndpoint de ON de.ProviderTypeId = (
    SELECT ProviderTypeId FROM mls.ResoMlsSettings WHERE MlsId = 2
) AND de.ResoDataResourceId = q.ResoDataResourceId
LEFT JOIN mls.ResoEndpoint e ON e.ResoEndpointId = de.ResoEndpointId
LEFT JOIN mls.ResoEndpointSegment seg ON seg.ResoEndpointSegmentId = de.ResoEndpointSegmentId
WHERE q.MlsId = 2 AND q.Enabled = 1;
```

### What You Should See:
- Query templates
- Resource types (Property, OpenHouse, etc.)
- Data endpoint URLs
- Segment paths

### ✅ Checkpoint:
**Take a screenshot and send it to me. I'll document the complete API setup.**

---

## Troubleshooting

### Problem: Can't find "1Parkplace" database
**Solution:**
- Make sure you're in the correct Azure subscription
- Check if database name is slightly different
- Try searching for "parkplace" (lowercase)

### Problem: Query editor not showing
**Solution:**
- Look for "Query editor (preview)" in left sidebar
- May be under "Tools" or "Development tools"
- Try refreshing the page

### Problem: Authentication fails
**Solution:**
- Try SQL authentication first (azure-1parkplace / 1pp@zu43$sql)
- If that fails, try Azure Active Directory
- Make sure you have permissions to access the database

### Problem: Query returns error
**Solution:**
- Check if you're connected to the right database
- Make sure you're in the `1Parkplace` database (not `MlsListing`)
- Check error message - I can help troubleshoot

---

## What We'll Learn

After completing these steps, we'll know:

1. ✅ **Which RESO provider** (Trestle vs Bridge technology)
2. ✅ **Actual credentials** (ClientId/Secret or ServerToken)
3. ✅ **API endpoints** (where to connect)
4. ✅ **Query templates** (how to request data)
5. ✅ **Which organization** MLS ID 2 connects to (based on credentials/endpoints)

---

## Ready to Start?

**Let's begin with STEP 1:**

1. Open your browser
2. Go to: **https://portal.azure.com**
3. Log in
4. **Take a screenshot and send it to me**

I'll guide you through each step as we go! 🚀

---

**File Location:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\AZURE_PORTAL_STEP_BY_STEP_GUIDE_v1.md`

