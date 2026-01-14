# PLS Integration Discovery - Credentials & Existing Functionality
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** 🔍 Discovery In Progress

## Discovery Summary

### 1. Mapbox Credentials ✅ FOUND

**Status:** ✅ **FOUND** - Mapbox credentials discovered in Title Genie Pre Listing Command demo

**Master Credential Tracker Location:** `D:\Cursor\TheGenie.ai\CREDENTIALS\Master_Credential_Tracker_v4.md` (Updated to v5.3)

**Credentials Found:**
- **Public Token:** `pk.eyJ1IjoiMXBhcmtwbGFjZSIsImEiOiJjbHZxc2R6NDMwZncxMmlxaW41MzVrdzV2In0.fl0G_yHPzEc_rzAaJ58v6Q`
- **Location:** `D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\HTML\pls-10037-rebecca-final-mvp.html`
- **Also Found In:** `Pre.Listing.Command\XML\pls-10037-rebecca.xml`
- **Status:** ✅ Tested and verified working in Title Genie Pre Listing Command demo

**Action Completed:**
- ✅ Updated Master Credential Tracker v5.3 with Mapbox credentials
- ✅ Updated Mapbox Complete Reference document v1.1
- ✅ Credentials ready for PLS implementation

### 2. Paisley AI Description Generation ✅ NEEDS DISCOVERY

**User Guidance:**
- "Paisley already has this capability"
- "May be found in a different focus"
- "We will make it better and smarter with updated prompting controls"

**Current Understanding:**
- ChatStartTypeId=3 (Pre-Listing Focused) identified
- Uses Assessor data (TitleData)
- May exist in different focus (not necessarily ChatStartTypeId=3)

**Action Needed:**
- Search codebase for existing Paisley Chat service
- Find ChatStartTypeId implementations
- Locate AskPaisley component/service
- Find existing description generation patterns
- Check for other ChatStartTypeIds that generate descriptions

**Search Locations:**
- `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\PaisleyController.cs`
- `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\BLL\PaisleyService.cs`
- Angular components: `Smart.NG.Agent\**\*paisley*.ts`
- Search for `/api/Paisley` endpoints

### 3. S3 Photo Upload (Listing Command) ✅ NEEDS DISCOVERY

**User Guidance:**
- "Listing Command - Customize Listing UI"
- "UI is limited to a single photo, but backend should allow much more"
- "Use our current AWS connectivity"

**AWS Credentials Found:**
- **Location:** `D:\Cursor\TheGenie.ai\CREDENTIALS\Master_Credential_Tracker_v4.md`
- **Access Key ID:** `AKIAS42SWEZUNUEWDJFE`
- **Region:** `us-west-1`
- **S3 Bucket:** `genie-cloud`
- **Profile:** `genie-hub-active`
- **Credentials File:** `C:\Users\Simulator\.aws\credentials`
- **Status:** ✅ ACTIVE (verified working 12/25/2025)

**Action Needed:**
- Find Listing Command Customize Listing component
- Find photo upload service/component
- Locate S3 upload implementation
- Check backend API endpoint for photo upload
- Review existing S3 upload service/helper

**Search Locations:**
- Angular: `Smart.NG.Agent\**\*customize*.ts` or `*listing*.ts`
- Backend: `Smart.Dashboard\Controllers\ListingCommandController.cs`
- Backend: `Smart.Dashboard\BLL\*S3*.cs` or `*Upload*.cs`
- Search for `/api/ListingCommand` endpoints

**AWS Credentials Found:**
- **Location:** `D:\Cursor\TheGenie.ai\CREDENTIALS\Master_Credential_Tracker_v4.md`
- **Access Key ID:** `AKIAS42SWEZUNUEWDJFE`
- **Region:** `us-west-1`
- **S3 Bucket:** `genie-cloud`
- **Profile:** `genie-hub-active`
- **Credentials File:** `C:\Users\Simulator\.aws\credentials`

**Search Terms:**
- `CustomizeListing`
- `ListingCommand.*Photo`
- `PhotoUpload`
- `S3Upload`
- `AWS.*S3`

## Next Steps (Manual Search Required)

**Due to large codebase, manual searches needed:**

1. **Mapbox Credentials:**
   - Check `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config`
   - Check `appsettings.json` files
   - Search for "mapbox" in Visual Studio (Ctrl+Shift+F)

2. **Paisley Chat Service:**
   - Open `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\PaisleyController.cs` (if exists)
   - Search for "ChatStartTypeId" in Visual Studio
   - Search for "AskPaisley" component in Angular app

3. **Listing Command Photo Upload:**
   - Find "Customize Listing" component in Angular app
   - Search for photo upload endpoints in `ListingCommandController.cs`
   - Find S3 upload service/helper class

4. **Update Implementation:**
   - Once found, update `PlsController_Complete_v1.cs` with actual implementations
   - Update `pls-create.component.ts` to use existing photo upload component
   - Integrate Paisley Chat service call

---

**Status:** ⚠️ Manual discovery required - codebase too large for automated search
