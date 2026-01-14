# PLS UI - Ready to Test Status
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** ⏳ **Almost Ready - 30-45 minutes of setup needed**

## Current Status: ✅ UI Components Complete

### What's Ready
- ✅ **Angular Component TypeScript** (`pls-create.component.ts`) - Complete with all API integrations
- ✅ **Angular Component HTML** (`pls-create.component.html`) - Complete v1.12 workflow UI
- ✅ **Backend Controllers** (`PlsController_Complete_v1.cs`, `DataController_PLS_Complete_v1.cs`) - Complete
- ✅ **Database Scripts** - All ready to execute
- ✅ **Stored Procedures** - All ready to execute

### What's Needed Before Testing

## Pre-Testing Setup (30-45 minutes)

### 1. Database Setup (5-10 minutes) ⚠️ REQUIRED
**Status:** Scripts ready, need execution

**Execute:**
1. `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` (FarmGenie)
2. `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` (FarmGenie)
3. `PLS_DATABASE_MASTER_DATA_v3.sql` (MlsListing + FarmGenie)
4. `PLS_STORED_PROCEDURES_COMPLETE_v1.sql` (FarmGenie)

**Verify:**
```sql
-- Test PLS number generation
DECLARE @PlsNum VARCHAR(10);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum; -- Should return: PLS100001A
```

### 2. Backend Deployment (10-15 minutes) ⚠️ REQUIRED
**Status:** Code ready, need deployment

**Actions:**
1. Copy `PlsController_Complete_v1.cs` → `Controllers\PlsController.cs`
2. Copy `DataController_PLS_Complete_v1.cs` → `Controllers\DataController.PLS.cs`
3. Add to `Smart.Dashboard.csproj`:
   ```xml
   <Compile Include="Controllers\PlsController.cs" />
   <Compile Include="Controllers\DataController.PLS.cs" />
   ```
4. Add connection strings to `Web.config`:
   ```xml
   <connectionStrings>
     <add name="FarmGenieConnection" connectionString="Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;..." />
     <add name="MlsListingConnection" connectionString="Server=192.168.29.45,1433;Database=MlsListing_Sandbox;..." />
     <add name="TitleDataConnection" connectionString="Server=192.168.29.45,1433;Database=TitleData;..." />
   </connectionStrings>
   ```
5. Build solution (F6) - Verify no errors

### 3. Angular Component Deployment (5 minutes) ⚠️ REQUIRED
**Status:** Components ready, need deployment

**Actions:**
1. Copy `pls-create.component.ts` to Angular app components directory
2. Copy `pls-create.component.html` to Angular app components directory
3. Verify component is in correct module

### 4. Routing Setup (5 minutes) ⚠️ REQUIRED
**Status:** Need to add route

**Add to `app-routing.module.ts`:**
```typescript
import { PlsCreateComponent } from './components/pls-create/pls-create.component';

const routes: Routes = [
  {
    path: 'pls',
    canActivate: [PermissionGuard],  // If using permission guard
    data: { permission: PermissionType.MenuPLS },  // Permission 211
    children: [
      { path: 'create', component: PlsCreateComponent }
    ]
  }
];
```

**Or simpler (if no permission guard yet):**
```typescript
{ path: 'pls/create', component: PlsCreateComponent }
```

### 5. Menu Integration (2 minutes) ⚠️ OPTIONAL (for easy access)
**Status:** Optional but recommended

**Add to main navigation menu:**
- Menu item: "Pre-Listing" or "Private Listings"
- Link: `/pls/create`
- Show only if user has Permission 211 (Menu PLS)

### 6. Permission Setup (5 minutes) ⚠️ REQUIRED (for full functionality)
**Status:** Need to grant permissions

**Grant Permission 211 (Menu PLS) to test user:**
```sql
-- Grant Menu PLS permission to test user
INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
SELECT Id, 211  -- Menu PLS
FROM dbo.AspNetUsers
WHERE UserName = 'your-test-user@email.com'
AND NOT EXISTS (
    SELECT 1 FROM dbo.Permission 
    WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 211
);
```

**For create/edit functionality, also grant Permission 210:**
```sql
INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
SELECT Id, 210  -- ManagePLS
FROM dbo.AspNetUsers
WHERE UserName = 'your-test-user@email.com'
AND NOT EXISTS (
    SELECT 1 FROM dbo.Permission 
    WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 210
);
```

## Testing Readiness Checklist

### Minimum Requirements (UI Loads)
- [ ] Database scripts executed (at least master data)
- [ ] Backend controllers deployed and built
- [ ] Angular component deployed
- [ ] Route added to routing module
- [ ] Angular app builds without errors

### Full Functionality (End-to-End Test)
- [ ] All database scripts executed (schemas, sequences, stored procedures)
- [ ] Backend controllers deployed with connection strings
- [ ] Angular component deployed
- [ ] Route added with permission guard (if using)
- [ ] Permissions granted to test user (211 for view, 210 for create)
- [ ] Menu item added (optional)

## When You Can Test

### ✅ Ready for Basic UI Test (15-20 minutes)
**After completing:**
- Database master data (StatusType 6, MlsID 777, PropertyCastType 4)
- Backend controllers deployed (even if APIs return mock data)
- Angular component deployed
- Route added

**What works:**
- UI loads and displays
- Form fields visible
- Navigation works
- API calls may return errors (expected - can test UI flow)

### ✅ Ready for Full End-to-End Test (30-45 minutes)
**After completing all checklist items:**
- All database scripts executed
- All stored procedures created
- Backend fully deployed with connection strings
- Permissions granted
- Routing configured

**What works:**
- Complete workflow from address entry to listing creation
- PLS number generation
- Database saves
- All API integrations

## Quick Test (Once Setup Complete)

1. **Navigate:** `http://localhost:38949/pls/create`
2. **Verify:** Page loads without errors
3. **Test Address:** Type "10037 Rebecca Place, Boerne, TX"
4. **Verify:** Autocomplete dropdown appears
5. **Select Address:** Click on suggestion
6. **Verify:** Property form pre-populates
7. **Select Area:** Choose from area dropdown
8. **Complete Form:** Fill price, select status
9. **Save:** Click "Save & Generate Content Kit"
10. **Verify:** PLS number generated (e.g., PLS100001A)

## Known Limitations (Non-Blocking)

These features have TODO placeholders but won't block UI testing:

- ⚠️ **Google Places Details API** - May return mock data initially
- ⚠️ **Mapbox Photo Generation** - May show loading state
- ⚠️ **Paisley Description Generation** - May show loading state

**Note:** UI will still work - these will show loading states or placeholder data.

## Estimated Time to Ready

- **Minimum (UI Loads):** 15-20 minutes
- **Full Functionality:** 30-45 minutes

## Next Steps

1. **Execute database scripts** (5-10 min)
2. **Deploy backend controllers** (10-15 min)
3. **Deploy Angular component** (5 min)
4. **Add routing** (5 min)
5. **Grant permissions** (5 min)
6. **Test!** 🚀

---

**Status:** UI components are 100% complete. Need 30-45 minutes of deployment setup before testing.

**Ready when:** All items in "Pre-Testing Setup" sections 1-4 are complete.
