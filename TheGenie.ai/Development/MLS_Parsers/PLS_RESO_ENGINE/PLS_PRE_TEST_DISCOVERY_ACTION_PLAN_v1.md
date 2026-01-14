# PLS Pre-Test Discovery Action Plan
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** 🔍 Active Discovery

## Mission: Find All Missing Pieces Before Testing

### 1. Mapbox Credentials ✅ MUST FIND

**User Confirmation:** "100% discovered for Title Genie project - tested - previous agent failed to update credential log"

**Search Strategy:**
1. **Check Config Files:**
   - `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config`
   - `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\appsettings.json`
   - Any `*.config` files in Title Genie related projects

2. **Check Source Code:**
   - Search for "mapbox" in Visual Studio (Ctrl+Shift+F)
   - Check for `pk.` prefix (Mapbox public token format)
   - Check for `access_token` or `MapboxToken` variables

3. **Check Title Genie Project Files:**
   - Review all Title Genie discovery documents
   - Check workspace memory logs
   - Check implementation files

**Once Found:**
- ✅ Update `D:\Cursor\TheGenie.ai\CREDENTIALS\Master_Credential_Tracker_v4.md`
- ✅ Add Mapbox section with credentials
- ✅ Create Mapbox Webhook Complete Reference document (following SOP)

### 2. Paisley AI Description Generation ✅ MUST FIND

**User Guidance:**
- "Paisley already has this capability"
- "May be found in a different focus"
- "We will make it better and smarter with updated prompting controls"

**Search Strategy:**
1. **Find Paisley Chat Service:**
   - `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\PaisleyController.cs`
   - `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\BLL\*Paisley*.cs`
   - Search for "ChatStartTypeId" in codebase

2. **Find AskPaisley Component:**
   - Angular: `Smart.NG.Agent\**\*paisley*.ts`
   - Search for "AskPaisley" or "ChatStartTypeId"

3. **Review Existing Chat Types:**
   - Check database: `FarmGenie.dbo.ChatItem`
   - Check for description generation patterns
   - Review ChatStartTypeId values and their purposes

**Once Found:**
- ✅ Document existing implementation
- ✅ Update `PlsController_Complete_v1.cs` with actual Paisley call
- ✅ Test integration

### 3. Listing Command Photo Upload ✅ MUST FIND

**User Guidance:**
- "Listing Command - Customize Listing UI"
- "UI is limited to a single photo, but backend should allow much more"
- "Use our current AWS connectivity"

**AWS Credentials (Already Found):**
- Access Key: `AKIAS42SWEZUNUEWDJFE`
- Bucket: `genie-cloud` (us-west-1)
- Profile: `genie-hub-active`

**Search Strategy:**
1. **Find Customize Listing Component:**
   - Angular: `Smart.NG.Agent\**\*customize*.ts` or `*listing*.ts`
   - Search for "CustomizeListing" or "ListingCommand" components

2. **Find Photo Upload Service:**
   - Backend: `Smart.Dashboard\Controllers\ListingCommandController.cs`
   - Backend: `Smart.Dashboard\BLL\*S3*.cs` or `*Upload*.cs`
   - Search for `/api/ListingCommand` endpoints

3. **Find S3 Upload Helper:**
   - Search for "S3Upload" or "UploadPhoto" methods
   - Check for AWS SDK usage

**Once Found:**
- ✅ Document existing implementation
- ✅ Reuse photo upload component/service for PLS
- ✅ Update `PlsController_Complete_v1.cs` with S3 upload logic
- ✅ Update `pls-create.component.ts` to use existing photo upload component

## Action Items Checklist

### Immediate (Before Testing):

- [ ] **Find Mapbox Credentials**
  - [ ] Search config files manually
  - [ ] Search source code for Mapbox usage
  - [ ] Update Master Credential Tracker
  - [ ] Create Mapbox Webhook Complete Reference

- [ ] **Find Paisley Chat Service**
  - [ ] Locate PaisleyController or Chat service
  - [ ] Document ChatStartTypeId implementations
  - [ ] Find description generation pattern
  - [ ] Update PlsController with actual implementation

- [ ] **Find Listing Command Photo Upload**
  - [ ] Locate Customize Listing component
  - [ ] Find S3 upload service/helper
  - [ ] Document existing implementation
  - [ ] Integrate into PLS workflow

### After Discovery:

- [ ] **Update Implementations:**
  - [ ] Update `PlsController_Complete_v1.cs` with Mapbox service
  - [ ] Update `PlsController_Complete_v1.cs` with Paisley Chat call
  - [ ] Update `PlsController_Complete_v1.cs` with S3 upload logic
  - [ ] Update `pls-create.component.ts` to use existing photo upload

- [ ] **Create Documentation:**
  - [ ] Mapbox Webhook Complete Reference (following SOP)
  - [ ] Update integration discovery document with findings

- [ ] **Ready for Testing:**
  - [ ] All credentials found and documented
  - [ ] All services integrated
  - [ ] Code ready for deployment

## Manual Search Commands

### For Mapbox (Run in Visual Studio or File Explorer):

1. **Visual Studio Search (Ctrl+Shift+F):**
   - Search: `mapbox` (case-insensitive)
   - Search: `pk.` (Mapbox token prefix)
   - Search: `MapboxToken` or `MapboxKey`

2. **File Explorer:**
   - Navigate to: `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\`
   - Search for: `*.config` files
   - Open and search for "mapbox"

### For Paisley (Run in Visual Studio):

1. **Search:**
   - `ChatStartTypeId`
   - `PaisleyController`
   - `AskPaisley`
   - `/api/Paisley`

### For Photo Upload (Run in Visual Studio):

1. **Search:**
   - `CustomizeListing`
   - `PhotoUpload`
   - `S3Upload`
   - `UploadPhoto`
   - `/api/ListingCommand`

---

**Status:** Ready for manual discovery - all search strategies documented
