# PLS Visual Studio Check-In Checklist
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** ✅ Ready for Check-In

## Files to Check In (After Copying to Project)

### ⚠️ IMPORTANT: Copy Files First, Then Check In

**These files are in the workspace but need to be copied to the actual project locations before check-in:**

### 1. Backend C# Files (Required)

**Source Files (in workspace):**
- `PlsController_Complete_v1.cs`
- `DataController_PLS_Complete_v1.cs`

**Copy to Project:**
1. Copy `PlsController_Complete_v1.cs` → `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\PlsController.cs`
2. Copy `DataController_PLS_Complete_v1.cs` → `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\DataController.PLS.cs`

**Check In:**
- ✅ `Controllers\PlsController.cs` (NEW FILE)
- ✅ `Controllers\DataController.PLS.cs` (NEW FILE)

### 2. Project File Changes (Required)

**File:** `Smart.Dashboard.csproj`

**Add these lines:**
```xml
<Compile Include="Controllers\PlsController.cs" />
<Compile Include="Controllers\DataController.PLS.cs" />
```

**Check In:**
- ✅ `Smart.Dashboard.csproj` (MODIFIED)

### 3. Web.config Changes (Required)

**File:** `Web.config`

**Add connection strings:**
```xml
<connectionStrings>
  <add name="FarmGenieConnection" connectionString="Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;..." />
  <add name="MlsListingConnection" connectionString="Server=192.168.29.45,1433;Database=MlsListing_Sandbox;..." />
  <add name="TitleDataConnection" connectionString="Server=192.168.29.45,1433;Database=TitleData;..." />
</connectionStrings>
```

**Check In:**
- ✅ `Web.config` (MODIFIED)

### 4. Angular Component Files (Required)

**Source Files (in workspace):**
- `pls-create.component.ts`
- `pls-create.component.html`
- `pls-create.component.scss` (if exists)

**Copy to Angular Project:**
- Copy to Angular app components directory (location depends on your Angular project structure)

**Check In:**
- ✅ `pls-create.component.ts` (NEW FILE)
- ✅ `pls-create.component.html` (NEW FILE)
- ✅ `pls-create.component.scss` (NEW FILE, if exists)

### 5. Routing Module Changes (Required)

**File:** `app-routing.module.ts` (or equivalent)

**Add route:**
```typescript
{
  path: 'pls',
  canActivate: [PermissionGuard],
  data: { permission: PermissionType.MenuPLS },
  children: [
    { path: 'create', component: PlsCreateComponent }
  ]
}
```

**Check In:**
- ✅ `app-routing.module.ts` (MODIFIED)

## ⚠️ CRITICAL: SANDBOX-ONLY DEPLOYMENT

### **100% SANDBOX-SAFE - NO PRODUCTION/STAGING IMPACT**

**Verified Safety Measures:**
- ✅ All connection strings use `*_Sandbox` databases (FarmGenie_Sandbox, MlsListing_Sandbox)
- ✅ All file paths are sandbox paths (`C:\Sandbox\...`)
- ✅ All code reads from `Web.config` (no hardcoded connections)
- ✅ Database scripts execute on sandbox server (sandbox databases)
- ✅ Production deployment is separate step with backup required

**See:** `PLS_SANDBOX_SAFETY_VERIFICATION_v1.md` for complete safety verification.

## Pre-Check-In Checklist

### Before Checking In:

- [ ] **Verify Environment:** Confirm you are working in SANDBOX, not Production
- [ ] **Verify Connection Strings:** Check `Web.config` uses `*_Sandbox` databases
- [ ] **Build Solution** - Verify no compilation errors (F6 in Visual Studio)
- [ ] **Test Locally** - Verify endpoints work (optional but recommended)
- [ ] **Verify File Locations** - Files copied to correct SANDBOX project directories
- [ ] **Review Changes** - Review all modified files in Visual Studio
- [ ] **Update Comments** - Ensure file headers are correct

## Visual Studio Check-In Steps

### Step 1: Open Team Explorer
1. In Visual Studio, open **Team Explorer** (View → Team Explorer)
2. Navigate to **Pending Changes**

### Step 2: Review Changes
1. **Included Changes** should show:
   - `Controllers\PlsController.cs` (Add)
   - `Controllers\DataController.PLS.cs` (Add)
   - `Smart.Dashboard.csproj` (Edit)
   - `Web.config` (Edit)
   - Angular component files (Add)
   - Routing module (Edit)

2. **Excluded Changes** - Verify no unwanted files are included

### Step 3: Add Check-In Comment
```
PLS RESO Engine - Initial Implementation

Backend:
- Added PlsController.cs (complete PLS API endpoints)
- Added DataController.PLS.cs (address lookup with TitleData/MLS integration)
- Updated Smart.Dashboard.csproj to include new controllers
- Updated Web.config with PLS connection strings

Frontend:
- Added pls-create.component.ts (complete Angular component)
- Added pls-create.component.html (v1.12 workflow UI)
- Updated app-routing.module.ts (added /pls/create route)

Features:
- Address autocomplete (Google Places via Paisley service)
- Property pre-population (TitleData + Historical MLS)
- Area selection (Paisley service)
- Auto-generated Mapbox satellite photo
- Auto-generated Paisley AI description (ChatStartTypeId=3)
- Complete PLS listing creation workflow
- Permission-based access control (PermissionType.ManagePLS, MenuPLS)
- Stored procedure integration (usp_CreatePlsListing, usp_GetNextPlsNumber)

Following patterns from Listing Command and Neighborhood Command services.
```

### Step 4: Check In
1. Click **Check In**
2. Verify changeset number
3. Confirm check-in successful

## Post-Check-In Verification

### Verify in Source Control:
- [ ] Files appear in source control history
- [ ] Changeset comment is correct
- [ ] All files are included

### Verify Build:
- [ ] Get latest version on another machine (if available)
- [ ] Build solution - should compile successfully
- [ ] No missing file errors

## Files NOT to Check In

**These files stay in workspace only (documentation/SQL):**
- ❌ `*.md` files (documentation - stay in workspace)
- ❌ `*.sql` files (database scripts - execute manually, not in source control)
- ❌ `*.html` files (prototypes - stay in workspace)
- ❌ `PLS_*.md` files (all documentation files)

**Note:** SQL scripts are executed manually by DBA, not checked into source control.

## Summary

### Files to Check In:
1. ✅ `Controllers\PlsController.cs` (NEW)
2. ✅ `Controllers\DataController.PLS.cs` (NEW)
3. ✅ `Smart.Dashboard.csproj` (MODIFIED)
4. ✅ `Web.config` (MODIFIED)
5. ✅ Angular component files (NEW)
6. ✅ Routing module (MODIFIED)

### Estimated Check-In Size:
- ~2,000 lines of C# code
- ~500 lines of TypeScript/HTML
- 2 project file modifications

---

**Ready to check in after:**
1. Files copied to project locations
2. Solution builds successfully
3. All changes reviewed
