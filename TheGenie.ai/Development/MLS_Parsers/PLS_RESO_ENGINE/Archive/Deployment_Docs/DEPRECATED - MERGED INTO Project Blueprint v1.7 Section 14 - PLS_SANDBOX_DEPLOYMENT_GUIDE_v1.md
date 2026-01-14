# PLS Sandbox Deployment Guide
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** 🚀 Ready for Sandbox Deployment

## Overview

Complete deployment guide for setting up a LIVE working PLS prototype in sandbox with all data schemas, functions, features, and connections ready for end-to-end testing.

## Prerequisites

1. **Sandbox Environment:**
   - Smart.Dashboard app running
   - Database access (FarmGenie_Sandbox, MlsListing_Sandbox, TitleData)
   - IIS configured for localhost:38949

2. **API Keys:**
   - Google Places API key
   - Mapbox API key (for satellite photos)
   - Paisley AI access (ChatStartTypeId=3)

3. **Codebase Access:**
   - `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\`
   - Angular app directory

## Deployment Steps

### Step 1: Database Setup

**Execute:** `PLS_COMPLETE_DATABASE_SETUP_v1.sql`

**Or execute in order:**
1. `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` (FarmGenie)
2. `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql` (FarmGenie)
3. `PLS_DATABASE_MASTER_DATA_v3.sql` (MlsListing + FarmGenie)

**Verify:**
```sql
-- Check PLS tables
SELECT COUNT(*) FROM FarmGenie.dbo.pls_status_type;
SELECT COUNT(*) FROM FarmGenie.dbo.pls_source_type;
SELECT COUNT(*) FROM FarmGenie.dbo.pls_tracking;

-- Test PLS number generation
DECLARE @PlsNum VARCHAR(10);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum AS TestPlsNumber;
```

### Step 2: Backend API Implementation

**Files to Copy:**
1. `DataController_PLS_Complete_v1.cs` → `Controllers\DataController.PLS.cs`
2. `PlsController_Complete_v1.cs` → `Controllers\PlsController.cs`

**Actions:**
1. Add `DataController.PLS.cs` as partial class to existing `DataController.cs`
2. Create new `PlsController.cs` file
3. Update `Smart.Dashboard.csproj` to include new files
4. Add connection strings to `Web.config`:
   ```xml
   <connectionStrings>
     <add name="FarmGenieConnection" connectionString="..." />
     <add name="MlsListingConnection" connectionString="..." />
     <add name="TitleDataConnection" connectionString="..." />
   </connectionStrings>
   ```

**Build & Test:**
```bash
# Build solution
# Test endpoints:
POST http://localhost:38949/api/Data/AutoCompleteAddress
POST http://localhost:38949/api/Data/GetPropertiesFromPlaceKey
POST http://localhost:38949/api/Data/GetAreaList
POST http://localhost:38949/api/pls/create
```

### Step 3: Angular Component Deployment

**Files to Copy:**
1. `pls-create.component.ts` (updated)
2. `pls-create.component.html` (updated)
3. `pls-create.component.scss` (if updated)

**Actions:**
1. Copy to Angular app components directory
2. Update routing to include `/pls/create` route
3. Add permission guard for `Menu PLS` (211)
4. Update menu to include "Pre-Listing" option

**Routing Example:**
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

### Step 4: API Integration Implementation

**TODO Items to Complete:**

1. **Google Places Details API:**
   - Implement `GetGooglePlaceDetails()` in `DataController.PLS.cs`
   - Use Google Places Details API to get address components

2. **Mapbox Service:**
   - Create `MapboxService.cs` in BLL layer
   - Implement `GenerateMapboxSatellitePhoto()`
   - Upload to S3 and return URL

3. **Paisley AI Service:**
   - Implement `CallPaisleyAI()` in `PlsController.cs`
   - Use ChatStartTypeId=3 (Pre-Listing Focused)
   - Pass Listing Data + Area Data

4. **Agent Info Query:**
   - Complete `GetAgentInfo()` method
   - Query `AspNetUsers`, `AspNetUserProfiles`, `UserMarketingProfile`

### Step 5: Configuration

**AppSettings.json / Web.config:**
```json
{
  "GooglePlaces": {
    "ApiKey": "YOUR_GOOGLE_PLACES_API_KEY"
  },
  "Mapbox": {
    "ApiKey": "YOUR_MAPBOX_API_KEY",
    "S3Bucket": "genie-cloud",
    "S3Region": "us-west-1"
  },
  "Paisley": {
    "ApiEndpoint": "https://api.paisley.ai/chat",
    "ChatStartTypeId": 3
  }
}
```

### Step 6: Testing End-to-End Workflow

**Test Flow:**
1. Navigate to: `http://localhost:38949/pls/create`
2. Enter address: "10037 Rebecca Place, Boerne, TX"
3. Verify autocomplete works
4. Select address
5. Verify property pre-population from TitleData
6. Verify areas auto-fetch
7. Select area
8. **Verify auto-generation:**
   - Mapbox photo appears (or loading state)
   - Paisley description appears (or loading state)
9. Review pre-populated data
10. Test "Edit Description" button
11. Test "Load Photos" button (optional)
12. Select status (Coming Soon/Private)
13. Click "Save & Generate Content Kit"
14. Verify PLS number generated (e.g., PLS100001A)
15. Verify listing saved to database
16. Verify XML generation
17. Verify GenieCloud render triggered

## Verification Checklist

### Database
- [ ] All PLS tables created
- [ ] Master data inserted (StatusType 6, MlsID 777, PropertyCastType 4)
- [ ] PLS number sequence working
- [ ] Permissions granted to test user

### Backend APIs
- [ ] `POST /api/Data/AutoCompleteAddress` - Returns address suggestions
- [ ] `POST /api/Data/GetPropertiesFromPlaceKey` - Returns property details with TitleData
- [ ] `POST /api/Data/GetAreaList` - Returns area list
- [ ] `POST /api/pls/create` - Creates listing and returns PLS number
- [ ] `POST /api/pls/generate-description` - Generates Paisley description
- [ ] `POST /api/pls/generate-mapbox-photo` - Generates satellite photo

### Frontend
- [ ] Angular component loads
- [ ] Address autocomplete works
- [ ] Property pre-population works
- [ ] Area selection works
- [ ] Auto-generated photo displays
- [ ] Auto-generated description displays
- [ ] Form submission works
- [ ] PLS number displayed after creation

### Integration
- [ ] TitleData lookup working
- [ ] Historical MLS conflict detection working
- [ ] Mapbox photo generation working
- [ ] Paisley description generation working
- [ ] S3 photo upload working
- [ ] GenieCloud XML generation working

## Troubleshooting

### Database Issues
- **Error:** "Cannot find stored procedure usp_GetNextPlsNumber"
  - **Fix:** Execute `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`

- **Error:** "Invalid column name 'status_type_id'"
  - **Fix:** Execute `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`

### API Issues
- **Error:** 404 on `/api/Data/AutoCompleteAddress`
  - **Fix:** Verify `DataController.PLS.cs` is included in project and compiled

- **Error:** "AgentDashboardManager not found"
  - **Fix:** Verify Paisley services are referenced in project

### Frontend Issues
- **Error:** Component not found
  - **Fix:** Verify routing is configured and component is in correct directory

- **Error:** API calls return 401 Unauthorized
  - **Fix:** Verify JWT token is being sent in HTTP headers

## Next Steps After Deployment

1. **Test with Real Data:**
   - Use actual property addresses
   - Verify TitleData lookup accuracy
   - Test conflict detection

2. **Performance Testing:**
   - Test with multiple concurrent users
   - Verify database query performance
   - Monitor API response times

3. **Error Handling:**
   - Test with invalid addresses
   - Test with missing TitleData
   - Test with API failures

4. **User Acceptance Testing:**
   - Have real estate agents test workflow
   - Collect feedback on UI/UX
   - Document issues and improvements

---

**Reference Documents:**
- [Project Blueprint v1.12](PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md)
- [Implementation Guide](PLS_IMPLEMENTATION_GUIDE_v1.md)
- [Database Schema](PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql)
