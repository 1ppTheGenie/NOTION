# PLS RESO Engine - Iterative Test Plan
**Version:** 1.0  
**Created:** 01/10/2026  
**Author:** Danny (Dev Lead)  
**Status:** 🎯 ITERATIVE APPROACH - Start Basic, Build Incrementally

---

## 📋 EXECUTIVE SUMMARY

**Problem:** Previous deployment attempt failed because we tried to deploy everything at once without proper testing.

**Solution:** Iterative approach - test each component in isolation before integrating.

**Strategy:** Start with the most basic functionality, verify it works, then add the next layer.

---

## 🔄 ITERATION 1: DATABASE FOUNDATION (BASIC)

### Goal
Verify database schema and stored procedures work correctly.

### Steps
1. **Execute Database Scripts (Sandbox Only)**
   - `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` → FarmGenie_Sandbox
   - `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` → FarmGenie_Sandbox
   - `PLS_DATABASE_MASTER_DATA_v3.sql` → MlsListing_Sandbox + FarmGenie_Sandbox
   - `PLS_STORED_PROCEDURES_COMPLETE_v1.sql` → FarmGenie_Sandbox

2. **Verify Database Setup**
   ```sql
   -- Test PLS number generation
   DECLARE @PlsNum VARCHAR(10);
   EXEC FarmGenie_Sandbox.dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
   SELECT @PlsNum; -- Should return: PLS100001A
   
   -- Verify tables exist
   SELECT COUNT(*) FROM FarmGenie_Sandbox.dbo.pls_status_type;
   SELECT COUNT(*) FROM FarmGenie_Sandbox.dbo.pls_tracking;
   ```

3. **Success Criteria**
   - ✅ All tables created
   - ✅ Master data inserted
   - ✅ PLS number sequence works
   - ✅ Stored procedures compile

**Time Estimate:** 15-20 minutes  
**No Code Changes:** Database only

---

## 🔄 ITERATION 2: SINGLE API ENDPOINT (BASIC)

### Goal
Get ONE endpoint working end-to-end before adding more.

### Steps
1. **Implement ONE Endpoint: `POST /api/Data/AutoCompleteAddress`**
   - Create `DataController.PLS.cs` as partial class
   - Implement ONLY the AutoCompleteAddress method
   - Use existing `AgentDashboardManager.AutocompleteAddress()`
   - Follow existing `DataController` patterns exactly

2. **Add to Project**
   - Add `<Compile Include="Controllers\DataController.PLS.cs" />` to `Smart.Dashboard.csproj`
   - Build solution - fix any compilation errors

3. **Test Endpoint**
   - Start application
   - Test with Postman/browser:
     ```json
     POST http://localhost:38949/api/Data/AutoCompleteAddress
     {
       "AspNetUserId": "",
       "AddressKey": "10037 Rebecca"
     }
     ```
   - Verify response (not 404, not 500)

4. **Success Criteria**
   - ✅ Endpoint returns 200 OK
   - ✅ Response contains address suggestions
   - ✅ No compilation errors
   - ✅ No runtime errors

**Time Estimate:** 30-45 minutes  
**Code Changes:** ONE file, ONE method

---

## 🔄 ITERATION 3: SECOND API ENDPOINT

### Goal
Add second endpoint after first one is proven to work.

### Steps
1. **Implement `POST /api/Data/GetPropertiesFromPlaceKey`**
   - Add method to existing `DataController.PLS.cs`
   - Use `PlacePropertiesManager.GetProperties()`
   - Query TitleData for property details

2. **Test Endpoint**
   - Test with Postman/browser
   - Verify property details returned

3. **Success Criteria**
   - ✅ Endpoint returns 200 OK
   - ✅ Property details returned correctly
   - ✅ First endpoint still works

**Time Estimate:** 30-45 minutes

---

## 🔄 ITERATION 4: THIRD API ENDPOINT

### Goal
Complete the three Paisley lookup endpoints.

### Steps
1. **Implement `POST /api/Data/GetAreaList`**
   - Add method to existing `DataController.PLS.cs`
   - Use `DashboardAutoCompleteManager.GetAreas()`
   - **CRITICAL:** Use `Models.External.ApiArea` (NOT `ApiAreaItem`)
   - **CRITICAL:** `AreaType` is string, NOT int

2. **Test Endpoint**
   - Test with Postman/browser
   - Verify areas returned

3. **Success Criteria**
   - ✅ All 3 endpoints work
   - ✅ No duplicate classes
   - ✅ No namespace conflicts

**Time Estimate:** 30-45 minutes

---

## 🔄 ITERATION 5: PROTOTYPE HTML TEST

### Goal
Verify prototype HTML can call all 3 endpoints.

### Steps
1. **Test Prototype**
   - Open `PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html` in browser
   - Test address autocomplete
   - Test property details retrieval
   - Test area lookup

2. **Success Criteria**
   - ✅ All 3 API calls succeed
   - ✅ UI displays results correctly
   - ✅ No console errors

**Time Estimate:** 15-20 minutes

---

## 🔄 ITERATION 6: PLS CONTROLLER (BASIC)

### Goal
Create PlsController with ONE endpoint first.

### Steps
1. **Implement `POST /api/pls/create`**
   - Create `PlsController.cs`
   - Implement ONLY the CreateListing method
   - Use stored procedure `usp_CreatePlsListing`
   - Follow .NET Framework 4.8 Web API patterns (NOT Core)

2. **Test Endpoint**
   - Test with Postman/browser
   - Verify listing created in database

3. **Success Criteria**
   - ✅ Listing created successfully
   - ✅ PLS number generated
   - ✅ Database records inserted

**Time Estimate:** 45-60 minutes

---

## 🔄 ITERATION 7: ANGULAR COMPONENT (BASIC)

### Goal
Create basic Angular component that can call the APIs.

### Steps
1. **Create `pls-create.component.ts`**
   - Basic form structure
   - Call address autocomplete API
   - Display results

2. **Add Route**
   - Add route to `app-routing.module.ts`
   - Test navigation

3. **Success Criteria**
   - ✅ Component loads
   - ✅ API calls work
   - ✅ Form displays

**Time Estimate:** 45-60 minutes

---

## 🔄 ITERATION 8: FULL WORKFLOW (INTEGRATION)

### Goal
Connect all pieces together.

### Steps
1. **Complete Angular Component**
   - Add all form fields
   - Add area selection
   - Add property pre-population
   - Add save functionality

2. **Test Full Workflow**
   - Enter address
   - Select area
   - Review pre-populated data
   - Save listing

3. **Success Criteria**
   - ✅ Full workflow works end-to-end
   - ✅ Listing created in database
   - ✅ All APIs working

**Time Estimate:** 2-3 hours

---

## 📊 TESTING CHECKLIST

### Before Each Iteration
- [ ] Verify previous iteration still works
- [ ] Check for compilation errors
- [ ] Verify database state

### After Each Iteration
- [ ] Test the new functionality
- [ ] Verify no regressions
- [ ] Document any issues
- [ ] Get approval before next iteration

---

## 🚨 LESSONS LEARNED FROM FAILED DEPLOYMENT

### Mistakes Made
1. **Tried to deploy everything at once**
   - ❌ Added all controllers, routes, configs simultaneously
   - ✅ Should have tested one component at a time

2. **Changed connection strings without understanding impact**
   - ❌ Changed `DefaultConnection` to sandbox (broke login)
   - ✅ Should have verified authentication still works

3. **Modified routing without testing**
   - ❌ Added `IgnoreRoute` for `pls/*` without understanding Angular routing
   - ✅ Should have tested routing changes in isolation

4. **Didn't verify system still works after changes**
   - ❌ Assumed changes were correct
   - ✅ Should have tested login, dashboard, existing features

5. **Didn't follow iterative approach**
   - ❌ Tried to build entire feature at once
   - ✅ Should have built incrementally

### What We'll Do Differently
1. **Test each component in isolation**
2. **Verify system still works after each change**
3. **Get approval before moving to next iteration**
4. **Document what works and what doesn't**
5. **Rollback immediately if something breaks**

---

## 🎯 SUCCESS METRICS

### Iteration 1 Success
- Database scripts execute without errors
- Stored procedures compile
- PLS number generation works

### Iteration 2-4 Success
- Each endpoint returns 200 OK
- Response data is correct
- No compilation errors

### Iteration 5 Success
- Prototype HTML can call all APIs
- UI displays results correctly

### Iteration 6 Success
- Listing can be created via API
- Database records are correct

### Iteration 7 Success
- Angular component loads
- Can navigate to component
- API calls work from component

### Iteration 8 Success
- Full workflow works end-to-end
- User can create a PLS listing
- All data is saved correctly

---

## 📝 NEXT STEPS

1. **Review this plan with Steve**
2. **Get approval to proceed with Iteration 1**
3. **Execute Iteration 1 (Database Foundation)**
4. **Test and verify**
5. **Get approval for Iteration 2**
6. **Repeat for each iteration**

---

## 🔄 PRODUCTION/STAGING SYNC REQUIREMENT

**CRITICAL:** Before starting PLS work, ensure sandbox is synced with production/staging changes.

### Email Confirmation Fix (01/09/2026 - Changeset 4705)
- **Timeline:** 
  - Morning: First implemented and tested with single user (Mariia Aleksa)
  - Morning: Changeset 4705 checked in
  - 12:05:24 PM Central: DLL built in RELEASE mode
  - After 12:05 PM: Deployed to Staging (tested first)
  - Same day: Deployed to Production
- **Changeset:** 4705 (confirmed from deployment thread)
- **Key Fix:** Auto-confirm email after password reset (prevents login issues when EmailConfirmed = False)
- **Location:** `AccountController.cs` - `ResetPassword` method (lines 251-260)
- **Status:** ✅ Verified in sandbox, staging, and production - fix is present
- **Documentation:** See `PASSWORD_FORGOT_DEPLOYMENT_TIMELINE_v1.md` for detailed timeline

**Verification:**
```csharp
// AUTO-CONFIRM EMAIL AFTER PASSWORD RESET
// Prevents login issues when EmailConfirmed = False
if (!user.EmailConfirmed)
{
    user.EmailConfirmed = true;
    await UserManager.UpdateAsync(user);
}
```

**Action Required:** 
- ✅ Sandbox already has the fix (verified 01/10/2026)
- ✅ No sync needed - sandbox is up to date

---

**Change Log:**
- **v1.1 (01/10/2026):** Added production/staging sync verification - Password Forgot fix confirmed in sandbox
- **v1.0 (01/10/2026):** Initial iterative test plan created after failed deployment
