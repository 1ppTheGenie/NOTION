# PLS UI Testing Checklist
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** 🚀 Ready for UI Testing Preparation

## Current Status

### ✅ Completed
- [x] Angular component TypeScript (`pls-create.component.ts`) - Complete with all API integrations
- [x] Angular component HTML (`pls-create.component.html`) - v1.12 workflow UI
- [x] Backend APIs (`PlsController_Complete_v1.cs`, `DataController_PLS_Complete_v1.cs`)
- [x] Database schemas and stored procedures
- [x] Permission integration documentation

### ⚠️ Required Before UI Testing

## Pre-Testing Checklist

### 1. Database Setup (5 minutes)
- [ ] Execute `PLS_COMPLETE_DATABASE_SETUP_v1.sql` OR execute in order:
  - [ ] `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
  - [ ] `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`
  - [ ] `PLS_DATABASE_MASTER_DATA_v3.sql`
- [ ] Execute `PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
- [ ] Verify PLS number generation works:
  ```sql
  DECLARE @PlsNum VARCHAR(10);
  EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
  SELECT @PlsNum; -- Should return: PLS100001A
  ```

### 2. Backend Deployment (10 minutes)
- [ ] Copy `PlsController_Complete_v1.cs` → `Controllers\PlsController.cs`
- [ ] Copy `DataController_PLS_Complete_v1.cs` → `Controllers\DataController.PLS.cs`
- [ ] Add to `Smart.Dashboard.csproj`:
  ```xml
  <Compile Include="Controllers\PlsController.cs" />
  <Compile Include="Controllers\DataController.PLS.cs" />
  ```
- [ ] Add connection strings to `Web.config`:
  ```xml
  <connectionStrings>
    <add name="FarmGenieConnection" connectionString="..." />
    <add name="MlsListingConnection" connectionString="..." />
    <add name="TitleDataConnection" connectionString="..." />
  </connectionStrings>
  ```
- [ ] Build solution (F6) - Verify no compilation errors
- [ ] Test API endpoints (optional but recommended):
  - `POST eshttp://localhost:38949/api/Data/AutoCompleteAddress`
  - `POST http://localhost:38949/api/Data/GetPropertiesFromPlaceKey`
  - `POST http://localhost:38949/api/Data/GetAreaList`

### 3. Angular Component Deployment (5 minutes)
- [ ] Copy `pls-create.component.ts` to Angular app components directory
- [ ] Copy `pls-create.component.html` to Angular app components directory
- [ ] Copy `pls-create.component.scss` (if exists) to Angular app components directory
- [ ] Verify component imports:
  ```typescript
  import { Component, OnInit } from '@angular/core';
  import { FormBuilder, FormGroup, Validators } from '@angular/forms';
  import { HttpClient } from '@angular/common/http';
  import { Router } from '@angular/router';
  import { Observable } from 'rxjs';
  ```

### 4. Angular Routing Setup (5 minutes)
- [ ] Add route to `app-routing.module.ts`:
  ```typescript
  {
    path: 'pls',
    canActivate: [PermissionGuard],  // If using permission guard
    data: { permission: PermissionType.MenuPLS },  // Permission 211
    children: [
      { path: 'create', component: PlsCreateComponent }
    ]
  }
  ```
- [ ] Import `PlsCreateComponent` in routing module
- [ ] Add `PlsCreateComponent` to module declarations

### 5. Permission Guard Setup (if not exists)
- [ ] Verify `PermissionGuard` exists and checks `PermissionType.MenuPLS` (211)
- [ ] If not exists, create or update guard to check PLS permissions

### 6. Menu Integration (2 minutes)
- [ ] Add "Pre-Listing" menu item to main navigation
- [ ] Link to `/pls/create`
- [ ] Show only if user has Permission 211 (Menu PLS)

### 7. Service Dependencies (Verify)
- [ ] Verify `FgHttpBaseService` exists (used in component)
- [ ] Verify `HttpClient` is imported in component
- [ ] Verify `Router` is imported in component
- [ ] Verify `FormBuilder` is imported in component

### 8. API Endpoint Configuration
- [ ] Verify API base URL is correct (should be `/api/Data/` and `/api/pls/`)
- [ ] Verify HTTP interceptor sets `AspNetUserId` in headers (if needed)
- [ ] Verify CORS is configured (if testing from different port)

## Testing Steps (Once Setup Complete)

### Step 1: Navigate to UI
1. Open browser: `http://localhost:38949/pls/create`
2. Verify page loads without errors
3. Check browser console for any errors

### Step 2: Test Address Autocomplete
1. Type "10037 Rebecca Place" in address field
2. Verify dropdown appears with suggestions
3. Select an address
4. Verify property form pre-populates

### Step 3: Test Area Selection
1. Verify areas auto-fetch after address selection
2. Select an area from dropdown
3. Verify area is stored

### Step 4: Test Auto-Generation
1. Verify Mapbox photo appears (or loading state)
2. Verify Paisley description appears (or loading state)
3. Test "Edit Description" button
4. Test "Load Photos" button (optional)

### Step 5: Test Form Submission
1. Complete required fields (price, status)
2. Click "Save & Generate Content Kit"
3. Verify PLS number is generated (e.g., PLS100001A)
4. Verify listing is saved to database

## Known Issues / TODOs

### Backend TODOs (Non-Blocking for Basic UI Test)
- ⚠️ Google Places Details API - Needs implementation in `GetPropertiesFromPlaceKey`
- ⚠️ Mapbox Service - Needs implementation in `GenerateMapboxPhoto`
- ⚠️ Paisley AI Service - Needs implementation in `GenerateDescription`
- ⚠️ Agent Info Query - Needs completion in `GetAgentInfo`

**Note:** These can be stubbed/mocked for initial UI testing. The UI will show loading states or placeholder data.

### Frontend TODOs
- ⚠️ Verify `FgHttpBaseService` pattern matches existing codebase
- ⚠️ Verify HTTP interceptor configuration
- ⚠️ Verify permission guard implementation

## Quick Start (Minimal Setup for UI Test)

If you want to test the UI immediately with minimal backend:

1. **Database:** Execute only master data scripts (StatusType 6, MlsID 777, PropertyCastType 4)
2. **Backend:** Copy controller files, build (even if APIs return mock data)
3. **Frontend:** Copy component files, add route, test UI flow
4. **Expected:** UI will load, show form, but API calls may return errors (which is fine for UI testing)

## Estimated Time to Ready

- **Full Setup:** 30-45 minutes (database + backend + frontend + routing)
- **Minimal Setup (UI Only):** 15-20 minutes (frontend + routing, mock backend)

## Ready to Test When

✅ All items in "Pre-Testing Checklist" sections 1-6 are complete  
✅ No compilation errors in backend or frontend  
✅ Route is accessible: `http://localhost:38949/pls/create`  
✅ Page loads without JavaScript errors

---

**Current Status:** UI components are complete and ready. Need database setup, backend deployment, and routing configuration before testing.

**Next Step:** Execute checklist items 1-6, then proceed with testing steps.
