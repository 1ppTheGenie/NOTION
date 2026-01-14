# PLS Complete Deployment - Ready to Execute

**Version:** 1.0  
**Created:** 01/14/2026 4:45 AM  
**Last Updated:** 01/14/2026 4:45 AM  
**Author:** JR (Project Manager)  
**Status:** ✅ **READY FOR DEPLOYMENT**

---

## 🎯 EXECUTIVE SUMMARY

This document provides the **complete deployment checklist** for PLS on Sandbox. All scripts, code, and documentation are ready. Follow this checklist in order - do not skip steps.

---

## ✅ PRE-DEPLOYMENT CHECKLIST

### Phase 1: Database Setup (15-20 minutes)

**Server:** Production SQL 2012 (`192.168.29.45,1433`)  
**Databases:** `FarmGenie`, `MlsListing`, `TitleData`

#### Step 1.1: Execute Schema Extensions
- [ ] **Script:** `02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
- [ ] **Database:** `FarmGenie`
- [ ] **Verify:** All tables created (check `pls_tracking`, `pls_status_type`, `pls_source_type`, `pls_status_log`, `pls_status_mapping`, `PlsListingOwnership`)

#### Step 1.2: Execute PLS Number Sequence
- [ ] **Script:** `02_Scripts/PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`
- [ ] **Database:** `FarmGenie`
- [ ] **Verify:** `PlsNumberSequence` table created, `usp_GetNextPlsNumber` procedure created
- [ ] **Test:** `EXEC dbo.usp_GetNextPlsNumber` returns `PLS100000A`

#### Step 1.3: Execute Master Data
- [ ] **Script:** `02_Scripts/PLS_DATABASE_MASTER_DATA_v3.sql`
- [ ] **Databases:** `MlsListing` and `FarmGenie`
- [ ] **Verify:** StatusTypeID 6 (Private Listing) exists, all lookup data inserted

#### Step 1.4: Execute Stored Procedures
- [ ] **Script:** `02_Scripts/PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
- [ ] **Database:** `FarmGenie`
- [ ] **Verify:** All stored procedures created

**✅ Phase 1 Complete When:** All scripts executed, PLS number generation tested, all tables verified

---

### Phase 2: Backend API Deployment (20-30 minutes)

**Location:** `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\`

#### Step 2.1: Deploy Controllers
- [ ] Copy `08_Source_Code/PlsController_Complete_v1.cs` → `Controllers/PlsController.cs`
- [ ] Copy `08_Source_Code/DataController_PLS_Complete_v1.cs` → `Controllers/DataController.PLS.cs`
- [ ] Verify `DataController.PLS.cs` is partial class (works with existing `DataController.cs`)

#### Step 2.2: Update Project File
- [ ] Open `Smart.Dashboard.csproj`
- [ ] Add:
  ```xml
  <Compile Include="Controllers\PlsController.cs" />
  <Compile Include="Controllers\DataController.PLS.cs" />
  ```

#### Step 2.3: Update Connection Strings
- [ ] Open `Web.config`
- [ ] Verify connection strings exist:
  ```xml
  <add name="FarmGenieConnection" connectionString="Server=192.168.29.45,1433;Database=FarmGenie;..." />
  <add name="MlsListingConnection" connectionString="Server=192.168.29.45,1433;Database=MlsListing;..." />
  <add name="TitleDataConnection" connectionString="Server=192.168.29.45,1433;Database=TitleData;..." />
  ```

#### Step 2.4: Build Solution
- [ ] Build solution (F6 or `dotnet build`)
- [ ] **CRITICAL:** Verify NO compilation errors
- [ ] Fix any errors before proceeding

**✅ Phase 2 Complete When:** Solution builds successfully, no errors

---

### Phase 3: Frontend UI Deployment (15-20 minutes)

**Location:** Angular app components directory

#### Step 3.1: Deploy Components
- [ ] Copy `08_Source_Code/pls-create.component.ts` → Angular components directory
- [ ] Copy `08_Source_Code/pls-create.component.html` → Angular components directory
- [ ] Copy `08_Source_Code/pls-create.component.scss` (if exists) → Angular components directory

#### Step 3.2: Update Routing
- [ ] Open `app-routing.module.ts`
- [ ] Add route:
  ```typescript
  {
    path: 'pls',
    canActivate: [PermissionGuard],
    data: { permission: PermissionType.MenuPLS },
    children: [
      { path: 'create', component: PlsCreateComponent },
      { path: 'my-listings', component: PlsMyListingsComponent }
    ]
  }
  ```

#### Step 3.3: Update Module
- [ ] Add `PlsCreateComponent` to module declarations
- [ ] Import required modules (FormsModule, HttpClientModule, etc.)

#### Step 3.4: Add Menu Item (Optional)
- [ ] Add "Private Listings" menu item to left navigation
- [ ] Set permission check: `PermissionType.MenuPLS` (211)

**✅ Phase 3 Complete When:** Components deployed, routing configured, no build errors

---

### Phase 4: Permissions Setup (5 minutes)

#### Step 4.1: Grant Test User Permissions
- [ ] Execute SQL:
  ```sql
  -- Grant Menu PLS (211)
  INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
  SELECT Id, 211
  FROM dbo.AspNetUsers
  WHERE UserName = 'your-test-user@email.com'
  AND NOT EXISTS (
      SELECT 1 FROM dbo.Permission
      WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 211
  );

  -- Grant ManagePLS (210)
  INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
  SELECT Id, 210
  FROM dbo.AspNetUsers
  WHERE UserName = 'your-test-user@email.com'
  AND NOT EXISTS (
      SELECT 1 FROM dbo.Permission
      WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 210
  );
  ```

**✅ Phase 4 Complete When:** Permissions granted to test user

---

## 🧪 TESTING CHECKLIST

### Test 1: Database Verification
- [ ] `EXEC dbo.usp_GetNextPlsNumber` returns `PLS100000A`
- [ ] Can query `FarmGenie.dbo.pls_status_type` (should have data)
- [ ] Can query `FarmGenie.dbo.pls_source_type` (should have data)
- [ ] StatusTypeID 6 exists in `MlsListing.dbo.StatusType`

### Test 2: API Endpoints
- [ ] `POST http://localhost:38949/api/Data/AutoCompleteAddress` - Address autocomplete works
- [ ] `POST http://localhost:38949/api/Data/GetPropertiesFromPlaceKey` - Property pre-population works
- [ ] `POST http://localhost:38949/api/Data/GetAreaList` - Area list works
- [ ] `POST http://localhost:38949/api/pls/create` - Create listing works (test with Postman)

### Test 3: UI Components
- [ ] Navigate to `/pls/create` - Form loads
- [ ] Enter address - Autocomplete works
- [ ] Select address - Pre-population works
- [ ] Select area - Area dropdown works
- [ ] Upload photo - Photo upload works
- [ ] Save listing - Listing created, PLS number generated

### Test 4: Integration
- [ ] Paisley AI description generation works (ChatStartTypeId=3)
- [ ] GenieCloud render triggered (if XML generation ready)
- [ ] Listing Command queue triggered (PropertyCastTypeId=4)

---

## 🚨 TROUBLESHOOTING

### Issue: PLS Number Generation Fails
**Solution:** Verify `PlsNumberSequence` table exists, `usp_GetNextPlsNumber` procedure exists

### Issue: API Endpoints Return 404
**Solution:** Verify controllers are in project file, solution rebuilt, IIS restarted

### Issue: Permission Denied
**Solution:** Verify Permission 211 (Menu PLS) granted to test user

### Issue: Pre-Population Returns Empty
**Solution:** Verify TitleData connection string, verify property exists in TitleData

---

## 📋 POST-DEPLOYMENT VALIDATION

### Must Verify:
- [ ] All database tables created
- [ ] All stored procedures created
- [ ] API endpoints responding
- [ ] UI components loading
- [ ] Property lookup working
- [ ] PLS number generation working
- [ ] Listing creation working

---

## 📝 DEPLOYMENT LOG

| Step | Status | Notes | Time |
|------|--------|-------|------|
| Phase 1: Database | ⏳ | | |
| Phase 2: Backend API | ⏳ | | |
| Phase 3: Frontend UI | ⏳ | | |
| Phase 4: Permissions | ⏳ | | |
| Testing | ⏳ | | |

---

**Status:** ✅ **READY FOR DEPLOYMENT**

**All scripts, code, and documentation are ready. Follow this checklist in order.**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/14/2026 4:45 AM | JR (Project Manager) | Initial deployment checklist - complete ready-to-deploy package. |
