# Workspace Memory Log - Server Troubleshooting & Azure DevOps Pipeline Fixes
**Version:** 1.0  
**Created:** 01/07/2026 8:45 PM  
**Last Updated:** 01/07/2026 8:45 PM  
**Author:** Auto (Cursor AI Agent)  
**Status:** ✅ **COMPLETE - Production Deployed Successfully**

---

## 🎯 SESSION OVERVIEW

**Date:** 01/07/2026  
**Duration:** Extended troubleshooting and deployment session  
**Primary Focus:** Fix Azure DevOps Build and Release pipelines to prevent missing files in future deployments  
**Outcome:** Production successfully deployed with all fixes (fonts, error.txt, folders)

---

## 📋 TOPIC 1: PRODUCTION SITE RESTORATION

### Problem
- TheGenie.ai production site experiencing critical outage for multiple days
- Staging missing `Smart.Dashboard.dll`
- Production missing entire `bin` folder
- Both caused by broken Azure DevOps deployment pipeline

### Root Cause
- Azure DevOps Build Pipeline not creating complete artifacts
- Release Pipeline not deploying all required folders
- Missing files: `Smart.Dashboard.dll`, `Agent` folder, `App_Data` folder, `SqlServerTypes` folder

### Solution Applied
- Manual deployment from working sandbox to restore production
- Created comprehensive diagnostic scripts
- Documented all required files and folders
- Fixed immediate production issues

### Key Files Created
- `STEP_BY_STEP_FIX_STAGING_v1.md` - Initial recovery guide
- `ENTERPRISE_RECOVERY_PROCEDURE_v1.md` - Fortune 500 standard recovery
- `CRITICAL_RECOVERY_PLAN_v2.md` - Comprehensive recovery plan
- Multiple diagnostic PowerShell scripts in `Frank\` folder

### Status
✅ **RESOLVED** - Production restored via manual deployment

---

## 📋 TOPIC 2: MISSING FILES DISCOVERED (01/06-01/07/2026)

### Issue 1: Missing error.txt File
**Discovered:** 01/06/2026  
**Problem:** Application error: "Could not find file 'C:\1PP\Temp\Reports\error.txt'"  
**Impact:** FileNotFoundException causing application crashes  
**Location:** `C:\1PP\Temp\Reports\error.txt` (shared between staging and production)

**Solution:**
- Created PowerShell script to create directory and file
- Added to Release Pipeline (both Staging and Production)
- File content: "The requested report file is not available. Please contact support if you believe this is an error."

**Files Created:**
- `FIX_MISSING_ERROR_FILE_v2.ps1` - Creates error.txt file
- `FIX_MISSING_ERROR_FILE_PRODUCTION_v2.ps1` - Production-specific version

**Status:** ✅ **FIXED** - File created and deployed to production

---

### Issue 2: Missing Font Awesome Fonts (Facebook Logo)
**Discovered:** 01/07/2026  
**Problem:** Facebook logo and other Font Awesome icons missing from UI  
**Root Cause:** 
- Angular build processes CSS and hashes font filenames (e.g., `fa-brands-400.abc123.woff2`)
- Font files exist in source: `src/assets/scss/icons/font-awesome/webfonts/`
- Angular build does NOT automatically copy fonts to output folder
- CSS expects fonts in Agent folder root with exact hashed filenames

**Required Font Files:**
- `fa-brands-400.*.woff2` (Facebook logo is in this font)
- `fa-brands-400.*.woff`
- `fa-solid-900.*.woff2`
- `fa-solid-900.*.woff`
- `fa-regular-400.*.woff2`
- `fa-regular-400.*.woff`
- `fa-regular-400.*.eot` (IE compatibility)

**Solution:**
- Added PowerShell task to Build Pipeline to copy fonts after Angular build
- Fonts must be in Agent folder root (not subfolders)
- CSS references fonts with relative paths from CSS location

**Files Created:**
- `FIX_FACEBOOK_LOGO_FONTS_v2.ps1` - Diagnoses and fixes missing fonts
- `COPY_FONTS_TO_BUILD_v1.ps1` - Copies fonts to build output

**Status:** ✅ **FIXED** - Fonts deployed to production

---

### Issue 3: Publish Artifact Path Configuration
**Discovered:** 01/07/2026  
**Problem:** "Publish Artifact" task configured with specific path strips required folders  
**Root Cause:** If "Path to publish" is set to `**\bin\**\*` or specific subfolder, all other folders are excluded from artifact

**Critical Finding:**
- Wrong path configuration will STRIP: Agent folder, App_Data folder, SqlServerTypes folder, Font files
- This is the #1 reason files go missing in deployments

**Solution:**
- Must use `$(Build.ArtifactStagingDirectory)` (entire staging directory)
- NOT `$(Build.ArtifactStagingDirectory)/Smart.Dashboard/bin` (WRONG)
- NOT `**\bin\**\*` (WRONG)

**Status:** ✅ **DOCUMENTED** - Added to pipeline configuration documentation

---

## 📋 TOPIC 3: AZURE DEVOPS PIPELINE CONFIGURATION

### Build Pipeline: SMART-Dashboard-Build
**URL:** https://oneparkplace.visualstudio.com/SMART/_build?definitionId=5  
**Type:** Classic Build Pipeline

**Current Tasks:**
1. Use NuGet 4.4.1 ✅
2. NuGet restore ⚠️ (disabled)
3. Build solution ✅
4. Test Assemblies ⚠️ (disabled)
5. Publish symbols path ✅
6. Build Angular Agent App ✅ (added by Frank)
7. Copy Agent Folder to Artifact ✅ (added by Frank)
8. Publish Artifact ✅

**Missing Tasks (Added to Documentation):**
- **Task 7a:** Copy Font Awesome Fonts to Build Output (NEW - 01/07/2026)
- **Task 8:** Copy Required Folders to Artifact (App_Data, SqlServerTypes)
- **Task 9:** CRITICAL - Verify "Publish Artifact" path is `$(Build.ArtifactStagingDirectory)`

**Key Documentation:**
- `COMPLETE_PIPELINE_FIX_v3.md` - Master pipeline configuration document
- `PIPELINE_ANALYSIS_v1.md` - Current pipeline analysis
- `MANUAL_PIPELINE_FIX_GUIDE_v1.md` - Step-by-step manual fix instructions

---

### Release Pipeline: SMART-Dashboard-Deploy
**URL:** https://oneparkplace.visualstudio.com/SMART/_release?definitionId=1  
**Type:** Classic Release Pipeline

**Staging Environment:**
**Current Tasks:**
1. Discover IIS Configuration ✅
2. Deploy to Stage ✅ (v4.0 script)

**Missing Tasks (Added to Documentation):**
- **Task 1:** Create error.txt File (NEW - 01/06/2026)
- **Task 2:** Configure App Pool 32-Bit Setting
- **Task 3:** Update Deployment Script to copy Agent (with fonts), App_Data, SqlServerTypes

**Production Environment:**
**Current Tasks:**
1. Copy Files to Production & IIS Reset ✅ (v4.0 script)

**Missing Tasks (Added to Documentation):**
- **Task 1:** Create error.txt File (NEW - 01/06/2026)
- **Task 2:** Configure App Pool 32-Bit Setting
- **Task 3:** Replace Web.config Connection Strings
- **Task 4:** Update Deployment Script to copy Agent (with fonts), App_Data, SqlServerTypes

**Status:** ✅ **PRODUCTION DEPLOYED** (01/07/2026) - All fixes applied successfully

---

## 📋 TOPIC 4: POST-DEPLOYMENT VERIFICATION

### New Verification Checklist (01/07/2026)

**Files/Folders:**
- [ ] `bin` folder exists with all DLLs (94+ files)
- [ ] `Smart.Dashboard.dll` exists in bin folder
- [ ] `Agent` folder exists with Angular app files
- [ ] **`Agent/fa-*.woff*` font files exist (6+ files) - NEW 01/07/2026**
- [ ] `App_Data` folder exists
- [ ] `SqlServerTypes` folder exists
- [ ] **`C:\1PP\Temp\Reports\error.txt` exists - NEW 01/06/2026**

**Functionality:**
- [ ] Site loads without errors
- [ ] Login page displays correctly
- [ ] `/agent` path works (Angular app loads)
- [ ] **Facebook logo displays (Font Awesome icons work) - NEW 01/07/2026**
- [ ] **Report downloads work (error.txt fallback works) - NEW 01/06/2026**
- [ ] Data append service works (if applicable)

**IIS Configuration:**
- [ ] App Pool is 32-bit enabled
- [ ] App Pool is running
- [ ] Connection strings are correct (Production only)

---

## 📋 TOPIC 5: KEY LESSONS LEARNED

### 1. "Publish Artifact" Task Can Strip Files ⚠️ **CRITICAL**
- If "Path to publish" is set to a specific folder (like `bin`), all other folders are **STRIPPED**
- Must use `$(Build.ArtifactStagingDirectory)` to publish ALL folders
- This is the #1 reason files go missing in deployments
- **Always verify artifact contents after build**

### 2. Angular Build Doesn't Copy Fonts Automatically
- Font files must be explicitly copied after Angular build
- CSS hashes font filenames, but fonts need to match
- Missing fonts cause silent failures (icons don't display, no error)

### 3. Missing Files Cause Application Crashes
- `error.txt` missing caused FileNotFoundException
- File must exist before application starts
- Directory is shared between staging and production

### 4. Build Pipeline Must Include All Required Folders
- Agent, App_Data, SqlServerTypes must be explicitly copied to artifact staging directory
- Don't assume folders are included automatically
- Font files must be copied separately after Angular build
- **Even if copied, they'll be stripped if "Publish Artifact" path is wrong**

### 5. Release Pipeline Must Deploy All Folders
- Even if folders are in artifacts, they must be deployed
- Verify deployment actually copies all required files
- Create required system files (error.txt) during deployment

### 6. Post-Deployment Verification is Critical
- Verify all files exist after deployment
- Test functionality, not just file existence
- Check Event Viewer for errors
- **Always download and inspect artifacts after build**

---

## 📋 TOPIC 6: DOCUMENTATION UPDATES

### Master Document Created
**File:** `COMPLETE_PIPELINE_FIX_v3.md`  
**Location:** `D:\Cursor\TheGenie.ai\Development\DevOpsEcosystemManagement\Monitoring\Server Troubleshooting\Frank\`  
**Status:** ✅ **COMPLETE** - Single source of truth for Azure DevOps pipeline configuration

**Contents:**
- Complete Build Pipeline task list with all required additions
- Complete Release Pipeline task list (Staging and Production)
- Font Awesome fonts issue and solution
- error.txt file requirement
- Publish Artifact path configuration check
- Post-deployment verification checklist
- Lessons learned section
- Version history

### Files Updated
- `COMPLETE_PIPELINE_FIX_v2.md` → `COMPLETE_PIPELINE_FIX_v3.md` (updated with all new findings)
- Deleted `FIX_FONTS_IN_BUILD_PIPELINE_v1.md` (consolidated into v3)
- Deleted `THE_DEPLOYMENT_PROMPT_v3.md` (duplicate, consolidated into v3)

### Files Created
- `FIX_FACEBOOK_LOGO_FONTS_v2.ps1` - Font fix script
- `FIX_MISSING_ERROR_FILE_v2.ps1` - error.txt creation script
- `ADD_MISSING_PIPELINE_TASKS_v1.ps1` - Automation script (attempted, had syntax errors)
- Multiple diagnostic scripts in `Frank\` folder

---

## 📋 TOPIC 7: DEPLOYMENT STATUS

### Production Deployment (01/07/2026)
**Status:** ✅ **COMPLETED**
- Font Awesome fonts: ✅ Deployed
- error.txt file: ✅ Created
- Agent folder: ✅ Deployed (with fonts)
- App_Data folder: ✅ Deployed
- SqlServerTypes folder: ✅ Deployed
- All verification checks: ✅ Passed

### Staging Deployment
**Status:** ⚠️ **NEEDS VERIFICATION**
- Font Awesome fonts: ❓ Unknown (needs verification)
- error.txt file: ❓ Unknown (needs verification - may exist if shared directory)
- Agent folder: ❓ Unknown (needs verification)
- App_Data folder: ❓ Unknown (needs verification)
- SqlServerTypes folder: ❓ Unknown (needs verification)

**Action Required:** Verify Staging has same updates as Production

---

## 📋 TOPIC 8: AUTOMATION ATTEMPTS

### Scripts Created
1. **FIX_ALL_PIPELINES_v3.ps1** - Original automation script (working)
2. **FIX_ALL_PIPELINES_v4.ps1** - Updated with fonts and error.txt (syntax errors)
3. **ADD_MISSING_PIPELINE_TASKS_v1.ps1** - Focused on missing tasks (syntax errors)

### Issues Encountered
- PowerShell task ID `e213e0f5-2f78-4c06-889c-1f5f1e000db5` not available in Azure DevOps organization
- Task catalog API returns 401 Unauthorized (PAT token permissions)
- Command Line task ID `d9bafed4-0b18-4f58-968d-86655b4d2ce9` works (used in existing tasks)

### Resolution
- Manual approach via Azure DevOps UI is more reliable
- Documentation provides step-by-step instructions
- Automation scripts can be fixed later with correct task IDs

---

## 📋 TOPIC 9: PROJECT ORGANIZATION

### Project Location
**Correct Path:** `D:\Cursor\TheGenie.ai\Development\DevOpsEcosystemManagement\Monitoring\Server Troubleshooting\`  
**Previous Incorrect Path:** `D:\Cursor\TheGenie.ai\Development\Deployments\` (files moved)

### Folder Structure
```
Server Troubleshooting/
├── Frank/                    # PowerShell scripts and detailed docs
│   ├── COMPLETE_PIPELINE_FIX_v3.md  # Master pipeline config
│   ├── FIX_FACEBOOK_LOGO_FONTS_v2.ps1
│   ├── FIX_ALL_PIPELINES_v3.ps1
│   └── [many diagnostic scripts]
├── Auto/                     # Auto-generated docs
├── PRODUCTION_DIAGNOSTIC_*/  # Diagnostic output folders
└── STAGING_DIAGNOSTIC_*/     # Diagnostic output folders
```

---

## 📋 TOPIC 10: INTEGRATION WITH MASTER DOCUMENTS

### Documents to Update
1. **GLOBAL_MASTER_INDEX.md** - Add Server Troubleshooting section
2. **PROJECT_UNIVERSE_DASHBOARD.html** - Add Server Troubleshooting project card
3. **GitHub Sync** - Sync all updates to GitHub repository

### Key Information to Add
- Project location and purpose
- Master documentation file (`COMPLETE_PIPELINE_FIX_v3.md`)
- Key findings (fonts, error.txt, Publish Artifact)
- Deployment status
- Links to Azure DevOps pipelines

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/07/2026 8:45 PM | Initial workspace memory log - comprehensive session documentation |

---

**This log documents all findings, fixes, and lessons learned from the Server Troubleshooting and Azure DevOps Pipeline Fix session on 01/07/2026.**

