# PLS Quick Start - Deploy to Sandbox NOW
**Version:** 1.0  
**Created:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** 🚀 Ready to Deploy

## 5-Minute Quick Start

### Step 1: Database (2 minutes)
```sql
-- Execute in order:
1. PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql (FarmGenie)
2. PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql (FarmGenie)
3. PLS_DATABASE_MASTER_DATA_v3.sql (MlsListing + FarmGenie)

-- Quick test:
DECLARE @PlsNum VARCHAR(10);
EXEC dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum; -- Should return: PLS100001A
```

### Step 2: Backend (2 minutes)
```bash
# Copy files:
DataController_PLS_Complete_v1.cs → Controllers\DataController.PLS.cs
PlsController_Complete_v1.cs → Controllers\PlsController.cs

# Add to Smart.Dashboard.csproj:
<Compile Include="Controllers\DataController.PLS.cs" />
<Compile Include="Controllers\PlsController.cs" />

# Build:
# Visual Studio: Build Solution (F6)
# Verify: No compilation errors
```

### Step 3: Frontend (1 minute)
```bash
# Copy files:
pls-create.component.ts → Angular app components directory
pls-create.component.html → Angular app components directory

# Add route (if not exists):
{ path: 'pls/create', component: PlsCreateComponent }
```

### Step 4: Test (30 seconds)
```
1. Navigate: http://localhost:38949/pls/create
2. Enter: "10037 Rebecca Place, Boerne, TX"
3. Select address
4. Verify property pre-populates
5. Select area
6. Verify auto-generation triggers
7. Fill form and save
8. Verify PLS number generated
```

## File Locations

**Database Scripts:**
- `PLS_COMPLETE_DATABASE_SETUP_v1.sql` (master script)
- `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
- `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`
- `PLS_DATABASE_MASTER_DATA_v3.sql`

**Backend:**
- `DataController_PLS_Complete_v1.cs` → `Controllers\DataController.PLS.cs`
- `PlsController_Complete_v1.cs` → `Controllers\PlsController.cs`

**Frontend:**
- `pls-create.component.ts` → Angular components
- `pls-create.component.html` → Angular components

## Connection Strings Needed

Add to `Web.config`:
```xml
<connectionStrings>
  <add name="FarmGenieConnection" 
       connectionString="Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;..." />
  <add name="MlsListingConnection" 
       connectionString="Server=192.168.29.45,1433;Database=MlsListing_Sandbox;..." />
  <add name="TitleDataConnection" 
       connectionString="Server=192.168.29.45,1433;Database=TitleData;..." />
</connectionStrings>
```

## API Keys Needed

Add to `appsettings.json` or `Web.config`:
- Google Places API key
- Mapbox API key
- Paisley AI endpoint (if different from default)

## What Works NOW

✅ **Database:** All schemas, sequences, master data  
✅ **Backend APIs:** All endpoints implemented  
✅ **Frontend:** Complete component with API integration  
✅ **Workflow:** End-to-end flow ready  

## What Needs Implementation

⚠️ **Google Places Details API** - Parse address components  
⚠️ **Mapbox Service** - Generate satellite photos  
⚠️ **Paisley AI** - Generate descriptions (ChatStartTypeId=3)  
⚠️ **Agent Info Query** - Get user profile data  

**Note:** These are marked with TODO comments in code. The structure is complete - just need to implement the actual API calls.

## Test First Listing

1. **Navigate:** `http://localhost:38949/pls/create`
2. **Enter Address:** "10037 Rebecca Place, Boerne, TX 78006"
3. **Select Address** from autocomplete
4. **Verify:** Property pre-populates from TitleData
5. **Select Area:** "Balcones Creek" or similar
6. **Review:** Auto-generated photo and description (may show loading)
7. **Complete Form:** Fill any missing fields
8. **Click:** "Save & Generate Content Kit"
9. **Verify:** PLS number generated (e.g., PLS100001A)
10. **Check Database:** Verify listing saved

## Troubleshooting

**404 on API endpoints:**
- Verify files copied to Controllers directory
- Verify project file updated
- Rebuild solution

**Database errors:**
- Verify scripts executed in correct order
- Check connection strings
- Verify user has permissions

**Component not loading:**
- Verify routing configured
- Check browser console for errors
- Verify Angular app built

---

**Ready to deploy! All files are in this workspace.**
