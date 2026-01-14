# RESO Credentials Found in RTK_SYSTEM Database

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent

---

## ✅ CREDENTIALS FOUND

**Location:** `RTK_SYSTEM` database, `dbo.Api` and `dbo.ApiSubscriber` tables

### RESO Wrapper Service Credentials

**Api Table Entry:**
- **ApiID:** 7
- **Name:** "Mls Reso"
- **URL:** `https://1pp-reso.azurewebsites.net/listing/`
- **Description:** "Reso Wrapper"

**ApiSubscriber Table Entry (ApiID = 7):**
- **Username:** `1parkplaceReso`
- **Password:** `r450!sC00!`
- **Email:** `development@1parkplace.com`
- **Company:** `1parkplace`

---

## ⚠️ IMPORTANT NOTE

**These are NOT the actual RESO API credentials.**

These credentials are for accessing the **RESO wrapper service** (`1pp-reso.azurewebsites.net`), which is your internal API that wraps the actual RESO API calls.

**The actual RESO API credentials** (ClientId, ClientSecret for Trestle, or ServerToken for Bridge) are still stored in:
- **Azure Database:** `1parkplace-sql.database.windows.net`
- **Database:** `1Parkplace`
- **Schema:** `mls`
- **Tables:** `ResoCredentialTrestle`, `ResoCredentialBridge`

---

## Azure Database Mystery

**Issue:** IT person has never heard of `1parkplace-sql.database.windows.net`

**Possible Explanations:**
1. Database is in a different Azure subscription/account
2. Set up by a contractor/developer who left
3. Personal Azure account
4. Different organization's Azure

**Publish Profile Shows:**
- Subscription ID: `04c791e7-aa21-40bf-b74e-274baa019a6c`
- Resource Group: `1Parkplace`
- App Service: `1pp` (https://1pp.azurewebsites.net)

**This subscription may be different from the one you have access to in Azure Portal.**

---

## Next Steps

1. **Check if subscription `04c791e7-aa21-40bf-b74e-274baa019a6c` exists in your Azure Portal**
2. **Ask IT if they know who set up Azure subscription `04c791e7-aa21-40bf-b74e-274baa019a6c`**
3. **Check if the application is running and can query credentials through its API endpoints**
4. **Look for application logs that show successful Azure database connections**

---

## What We Still Need

**Actual RESO API Credentials:**
- ClientId / ClientSecret (if using Trestle provider)
- OR ServerToken (if using Bridge provider)
- API endpoints
- Query templates

**These are required to:**
- Understand which MLS organization MLS ID 2 connects to (Bay East vs Bridge MLS)
- Test if Bridge MLS credentials still work
- Document the complete MLS data operation



