# PLS Next Testing Steps
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** ✅ Ready for Testing

## Current Status

✅ **Code Complete:**
- Backend controllers (`PlsController.cs`, `DataController.PLS.cs`)
- Angular component (`pls-create.component.ts/html/scss`)
- Database scripts (all SQL files ready)
- Stored procedures (5 procedures complete)

✅ **Documentation Complete:**
- Project Blueprint v1.14 (complete spec)
- Deployment procedures (Section 14)
- Safety verification (integrated)
- Check-in checklist

## Next Steps: Sandbox Deployment & Testing

### Step 1: Deploy to Sandbox (30-45 minutes)

#### 1.1 Database Setup (5-10 minutes)

**Execute SQL Scripts in Order:**
1. `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` → FarmGenie_Sandbox
2. `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` → FarmGenie_Sandbox
3. `PLS_DATABASE_MASTER_DATA_v3.sql` → MlsListing_Sandbox + FarmGenie_Sandbox
4. `PLS_STORED_PROCEDURES_COMPLETE_v1.sql` → FarmGenie_Sandbox

**Verify Database Setup:**
```sql
-- Test PLS number generation
DECLARE @PlsNum VARCHAR(10);
EXEC FarmGenie_Sandbox.dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum; -- Should return: PLS100001A

-- Verify tables created
SELECT COUNT(*) FROM FarmGenie_Sandbox.dbo.pls_status_type;
SELECT COUNT(*) FROM FarmGenie_Sandbox.dbo.pls_source_type;
SELECT COUNT(*) FROM FarmGenie_Sandbox.dbo.pls_tracking;
```

#### 1.2 Backend Deployment (10-15 minutes)

**Copy Files:**
1. `PlsController_Complete_v1.cs` → `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\PlsController.cs`
2. `DataController_PLS_Complete_v1.cs` → `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\DataController.PLS.cs`

**Update Project File:**
- Add to `Smart.Dashboard.csproj`:
  ```xml
  <Compile Include="Controllers\PlsController.cs" />
  <Compile Include="Controllers\DataController.PLS.cs" />
  ```

**Update Web.config:**
- Add connection strings (SANDBOX ONLY):
  ```xml
  <connectionStrings>
    <add name="FarmGenieConnection" connectionString="Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;User Id=sa;Password=neo222;" />
    <add name="MlsListingConnection" connectionString="Server=192.168.29.45,1433;Database=MlsListing_Sandbox;User Id=sa;Password=neo222;" />
    <add name="TitleDataConnection" connectionString="Server=192.168.29.45,1433;Database=TitleData;User Id=sa;Password=neo222;" />
  </connectionStrings>
  ```

**Build Solution:**
- Open Visual Studio
- Build Solution (F6)
- Verify no compilation errors

#### 1.3 Angular Component Deployment (5 minutes)

**Copy Files:**
1. `pls-create.component.ts` → Angular app components directory
2. `pls-create.component.html` → Angular app components directory
3. `pls-create.component.scss` → Angular app components directory

**Update Routing:**
- Add to `app-routing.module.ts`:
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

**Update Module:**
- Add `PlsCreateComponent` to module declarations

#### 1.4 Permission Setup (5 minutes)

**Grant Permissions to Test User:**
```sql
-- Replace 'your-test-user@email.com' with actual test user email
-- Grant Menu PLS (211) - Required for UI access
INSERT INTO FarmGenie_Sandbox.dbo.Permission (UserId, PermissionTypeId)
SELECT Id, 211
FROM FarmGenie_Sandbox.dbo.AspNetUsers
WHERE UserName = 'your-test-user@email.com'
AND NOT EXISTS (
    SELECT 1 FROM FarmGenie_Sandbox.dbo.Permission 
    WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 211
);

-- Grant ManagePLS (210) - Required for create/edit
INSERT INTO FarmGenie_Sandbox.dbo.Permission (UserId, PermissionTypeId)
SELECT Id, 210
FROM FarmGenie_Sandbox.dbo.AspNetUsers
WHERE UserName = 'your-test-user@email.com'
AND NOT EXISTS (
    SELECT 1 FROM FarmGenie_Sandbox.dbo.Permission 
    WHERE UserId = AspNetUsers.Id AND PermissionTypeId = 210
);
```

### Step 2: Basic API Testing (10 minutes)

**Test Endpoints (using Postman or browser):**

1. **Address Autocomplete:**
   ```
   POST http://localhost:38949/api/Data/AutoCompleteAddress
   Body: { "query": "10037 Rebecca Place, Boerne" }
   ```

2. **Get Properties from PlaceKey:**
   ```
   POST http://api/Data/GetPropertiesFromPlaceKey
   Body: { "placeKey": "..." }
   ```

3. **Get Area List:**
   ```
   POST http://localhost:38949/api/Data/GetAreaList
   Body: { "latitude": 29.7947, "longitude": -98.7319 }
   ```

4. **Create PLS Listing:**
   ```
   POST http://localhost:38949/api/pls/create
   Body: { ... (see PlsController for request format) }
   ```

### Step 3: UI Testing (15-20 minutes)

**Test URL:** `http://localhost:38949/pls/create`

**Test Flow:**
1. ✅ Navigate to `/pls/create` (should require login + Permission 211)
2. ✅ Enter address: "10037 Rebecca Place, Boerne, TX"
3. ✅ Verify address autocomplete works
4. ✅ Select address from dropdown
5. ✅ Verify property details pre-populate
6. ✅ Verify area list auto-fetches
7. ✅ Select area from dropdown
8. ✅ Verify Mapbox photo auto-generates (or shows placeholder)
9. ✅ Verify Paisley description auto-generates (or shows placeholder)
10. ✅ Click "Save Listing"
11. ✅ Verify listing created in database
12. ✅ Verify PLS number generated (format: PLS100001A)

### Step 4: End-to-End Validation (10 minutes)

**Verify Database:**
```sql
-- Check listing was created
SELECT * FROM MlsListing_Sandbox.dbo.Listing 
WHERE MlsId = 777 
ORDER BY ListDate DESC;

-- Check PLS tracking
SELECT * FROM FarmGenie_Sandbox.dbo.pls_tracking 
ORDER BY created_at DESC;

-- Check ownership
SELECT * FROM FarmGenie_Sandbox.dbo.PlsListingOwnership 
ORDER BY CreatedDate DESC;
```

**Verify PLS Number Format:**
- Should be: `PLS100001A` (6 digits + 1 letter)
- Next call should be: `PLS100001B`

## Testing Checklist

### Database Tests
- [ ] `usp_GetNextPlsNumber` returns "PLS100001A"
- [ ] Can INSERT test listing with MlsId=777
- [ ] Can query PlsListingOwnership table
- [ ] Permissions work (user can see menu with Permission 211)
- [ ] StatusTypeID 6 (Private) and 14 (Coming Soon) exist
- [ ] PropertyCastTypeId 4 (PLS) exists

### API Tests
- [ ] `POST /api/Data/AutoCompleteAddress` returns address suggestions
- [ ] `POST /api/Data/GetPropertiesFromPlaceKey` returns property details
- [ ] `POST /api/Data/GetAreaList` returns area list
- [ ] `POST /api/pls/create` creates listing
- [ ] `GET /api/pls/my-listings` returns user's listings

### UI Tests
- [ ] Can navigate to `/pls/create` (requires Permission 211)
- [ ] Address autocomplete works
- [ ] Property pre-populates after address selection
- [ ] Area list auto-fetches
- [ ] Can select area
- [ ] Mapbox photo auto-generates (or shows placeholder)
- [ ] Paisley description auto-generates (or shows placeholder)
- [ ] Can save listing
- [ ] Form validation works
- [ ] Error messages display correctly

## Known Limitations (Expected)

**These may not work yet (expected for MVP):**
- Mapbox photo generation (needs API key/config)
- Paisley AI description (needs service integration)
- Photo upload to S3 (needs S3 config)
- GenieCloud XML generation (needs service integration)

**These should work:**
- Address autocomplete (Google Places API)
- Property pre-population (TitleData query)
- Area list (database query)
- PLS number generation
- Listing creation
- Database storage

## Next Steps After Testing

1. **Fix any compilation errors**
2. **Fix any API endpoint errors**
3. **Complete Mapbox integration** (if photo generation needed)
4. **Complete Paisley AI integration** (if description needed)
5. **Test with real property data**
6. **Check in to source control** (after testing passes)

## Test Property

**Recommended Test Address:**
- Address: 10037 Rebecca Place, Boerne, TX 78006
- Expected: Should pre-populate from TitleData
- Expected: Should show area options
- Expected: PLS Number: PLS100001A (first call)

---

**Ready to proceed with Step 1: Database Setup**
