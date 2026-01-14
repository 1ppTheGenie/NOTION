# PLS Dev Team Onboarding Package - 360° Platform View
**Version:** 1.0  
**Created:** 01/13/2026 10:15 PM  
**Last Updated:** 01/13/2026 10:15 PM  
**Author:** JR (Project Manager)  
**Status:** ✅ ACTIVE - Complete Platform Context for Development Team

---

## 🎯 PURPOSE

This document provides the development team with a **complete 360-degree view** of the existing TheGenie.ai platform that PLS must integrate with. Unlike eRealtor (standalone), PLS is a **feature addition** to an existing platform with strict constraints.

**Critical Understanding:** PLS developers must work **within** existing infrastructure, not build new infrastructure.

**DRA-2026 Compliant:** ✅ Yes - Master document with cataloged exhibits  
**Master Rules Compliant:** ✅ Yes - Proper versioning, headers, change log

---

## ⚠️ CRITICAL DISTINCTION: PLS vs eRealtor

| Aspect | eRealtor | PLS |
|--------|----------|-----|
| **Type** | Standalone application | Feature addition to existing platform |
| **Infrastructure** | Build from scratch | Use existing infrastructure |
| **Database** | New database | Extend existing database |
| **Tech Stack** | Choose technology | Use existing tech stack |
| **UI** | New UI framework | Extend existing UI |
| **Deployment** | New deployment | Deploy within existing application |
| **Constraints** | Minimal | **STRICT - Must work within existing system** |

---

## 📋 ONBOARDING PACKAGE CONTENTS

### Phase 1: Platform Foundation (READ FIRST)
1. **Current Platform Architecture** - How the system works today
2. **Tech Stack Inventory** - What technologies are in use
3. **Database Architecture** - Existing schema and structure
4. **Infrastructure Details** - Servers, IIS, web pools, configuration

### Phase 2: Integration Points (READ SECOND)
5. **Existing API Patterns** - How current APIs work
6. **Authentication & Authorization** - Current auth system
7. **Roles & Permissions System** - How permissions work
8. **UI Framework & Patterns** - Existing UI components

### Phase 3: Constraints & Limitations (READ THIRD)
9. **What Cannot Be Changed** - Hard constraints
10. **What Can Be Extended** - What PLS can add
11. **Compatibility Requirements** - What must be maintained
12. **Legacy System Considerations** - Old code patterns to respect

### Phase 4: Development Environment (READ FOURTH)
13. **Development Setup** - How to set up local environment
14. **Database Access** - How to connect to existing databases
15. **Source Code Structure** - Where PLS code fits
16. **Testing Environment** - Sandbox setup and usage

---

## 🏗️ 1. CURRENT PLATFORM ARCHITECTURE

### 1.1 High-Level System Architecture

**TheGenie.ai Platform Components:**
```
┌─────────────────────────────────────────────────────────────┐
│                    THEGENIE.AI PLATFORM                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   TITLE     │  │   PAISLEY    │  │  ENGAGEMENT  │     │
│  │   GENIE     │  │   AI         │  │   CENTER     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                 │                    │            │
│         └─────────────────┼────────────────────┘            │
│                           │                                  │
│                  ┌────────▼─────────┐                        │
│                  │  SMART DASHBOARD │                        │
│                  │  (Main App)      │                        │
│                  │                  │                        │
│                  │  • Listing      │                        │
│                  │    Command      │                        │
│                  │  • PropertyCast │                        │
│                  │  • PLS (NEW)    │                        │
│                  └──────────────────┘                        │
│                           │                                  │
│                  ┌────────▼─────────┐                        │
│                  │   DATABASES       │                        │
│                  │  • FarmGenie     │                        │
│                  │  • MlsListing    │                        │
│                  │  • TitleData     │                        │
│                  └──────────────────┘                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Application Structure

**Main Application:** Smart.Dashboard (ASP.NET Web API + Angular)

**Key Directories:**
- `Controllers/` - API controllers (existing + PLS additions)
- `Services/` - Business logic services
- `Models/` - Data models
- `App_Data/` - Application data
- `bin/` - Compiled DLLs
- `Content/` - CSS, images
- `Scripts/` - JavaScript libraries
- `Views/` - Server-side views (if any)
- `AngularApp/` - Angular frontend application

**PLS Integration Points:**
- `Controllers/PlsController.cs` - NEW (adds to existing controllers)
- `Controllers/DataController.PLS.cs` - NEW (partial class extension)
- `AngularApp/src/app/pls/` - NEW (adds to existing Angular app)

---

## 💻 2. TECH STACK INVENTORY

### 2.1 Backend Technology Stack

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Framework** | .NET Framework | 4.8 | **NOT .NET Core** - Must use Framework |
| **Web Framework** | ASP.NET Web API | 2.x | REST API (not MVC) |
| **ORM** | Entity Framework | 6.x (if used) | May use ADO.NET directly |
| **Database** | SQL Server | 2016+ | Existing databases |
| **Authentication** | JWT Bearer Tokens | - | Custom implementation |
| **IIS** | Internet Information Services | 10+ | Windows Server |
| **Application Pool** | .NET Framework v4.0 | - | Must match existing |

### 2.2 Frontend Technology Stack

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Framework** | Angular | [Version TBD] | Existing Angular app |
| **Language** | TypeScript | - | TypeScript required |
| **Build Tool** | Angular CLI | - | Existing build process |
| **UI Library** | [TBD] | - | May use existing component library |
| **HTTP Client** | RxJS / HttpClient | - | Angular HTTP client |
| **Routing** | Angular Router | - | Must integrate with existing routes |

### 2.3 Infrastructure Technology Stack

| Component | Technology | Notes |
|-----------|------------|-------|
| **Web Server** | IIS 10+ | Windows Server |
| **Application Pool** | .NET Framework v4.0 | Must match existing pool |
| **Database Server** | SQL Server 2016+ | Shared server, multiple databases |
| **File Storage** | S3 (AWS) | For photos, assets |
| **CDN** | [TBD] | May use existing CDN |

### 2.4 External Services

| Service | Purpose | Integration Method |
|---------|---------|-------------------|
| **GenieCloud** | Asset rendering | REST API (XML → HTML/PNG/PDF) |
| **Paisley AI** | Description generation | REST API (ChatStartTypeId=3) |
| **TitleGenie** | Property data | Database queries (TitleData.dbo.AttomDataAssessor) |
| **Mapbox** | Address lookup | JavaScript SDK |
| **Engagement Center** | Lead capture | UTM tracking, Versium append |

---

## 🗄️ 3. DATABASE ARCHITECTURE

### 3.1 Existing Database Structure

**Database Server:** `192.168.29.45,1433` or `server-mssql1.istrategy.com`

**Databases:**
1. **FarmGenie** - Main application database
2. **MlsListing** - MLS listing data (RESO structure)
3. **TitleData** - Title company and property data

### 3.2 FarmGenie Database (Main App Database)

**Key Tables PLS Must Work With:**

| Table | Purpose | PLS Usage |
|-------|---------|-----------|
| **AspNetUsers** | User accounts | PLS tracks `agent_id` (FK to Id) |
| **AspNetRoles** | Role definitions | PLS uses existing roles |
| **AspNetUserRoles** | User-role assignments | PLS respects existing assignments |
| **Permission** | Permission assignments | PLS uses Permission IDs (210, 211, 213, 214) |
| **PropertyCast** | Listing Command data | PLS integrates with PropertyCastTypeId=4 |

**PLS Extensions (NEW Tables):**
- `pls_tracking` - PLS-specific metadata
- `pls_status_log` - Audit trail
- `pls_status_type` - Status lookup table
- `pls_source_type` - Source lookup table
- `pls_status_mapping` - PLS → MLS status mapping
- `PlsListingOwnership` - Ownership tracking
- `PlsNumberSequence` - PLS number generation

### 3.3 MlsListing Database (RESO Structure)

**Key Table: `MlsListing.dbo.Listing`**

**CRITICAL:** PLS uses this EXISTING table - NO schema changes allowed

| Column | PLS Usage | Constraint |
|--------|-----------|------------|
| **ListingID** | Primary key | PLS references this |
| **MlsID** | Must be `777` for PLS | **CRITICAL:** Cannot change table |
| **MlsNumber** | PLS number format: `PLS100000A` | Must follow format |
| **StatusTypeID** | Must be `6` (Private) or `14` (Coming Soon) | Existing values |
| **DisplayAddress** | Property address | Existing column |
| **93 RESO fields** | All existing RESO fields | **Cannot modify** |

**What PLS CANNOT Do:**
- ❌ Add new columns to `MlsListing.dbo.Listing`
- ❌ Modify existing columns
- ❌ Change data types
- ❌ Add indexes (without DBA approval)
- ❌ Modify existing stored procedures

**What PLS CAN Do:**
- ✅ Insert new rows with `MlsId=777`
- ✅ Use existing columns
- ✅ Reference existing `StatusType` table
- ✅ Create NEW stored procedures in FarmGenie database

### 3.4 TitleData Database (Property Data)

**Key Table: `TitleData.dbo.AttomDataAssessor`**

**PLS Usage:** Pre-populate property data from TitleGenie

**Access:** Read-only queries (no modifications)

---

## 🖥️ 4. INFRASTRUCTURE DETAILS

### 4.1 IIS Configuration

**IIS Version:** 10+ (Windows Server)

**Application Pool Settings:**
- **.NET CLR Version:** v4.0
- **Managed Pipeline Mode:** Integrated
- **Identity:** ApplicationPoolIdentity (or custom service account)
- **Recycling:** Based on existing policy

**CRITICAL Constraints:**
- ✅ Must use existing application pool (cannot create new)
- ✅ Must match .NET Framework version (4.8)
- ✅ Must not break existing application
- ✅ Must follow existing IIS configuration patterns

### 4.2 Web Application Structure

**Application Root:** `C:\Sandbox\1ppDevelopment\Smart.Dashboard\` (Sandbox)

**Key Files:**
- `Web.config` - Application configuration
- `bin\Smart.Dashboard.dll.config` - **CRITICAL** - Connection strings loaded at startup
- `Global.asax` - Application startup
- `App_Start\RouteConfig.cs` - Routing configuration

**PLS Integration:**
- PLS controllers added to `Controllers/` folder
- PLS routes added to existing `RouteConfig.cs`
- PLS Angular components added to `AngularApp/src/app/pls/`

### 4.3 Connection Strings

**Location:** `Web.config` AND `bin\Smart.Dashboard.dll.config` (both must match)

**CRITICAL:** DLL.config is loaded at application startup - if missing, authentication fails

**Format:**
```xml
<connectionStrings>
  <add name="FarmGenieConnection" 
       connectionString="Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;User Id=...;Password=...;" />
  <add name="MlsListingConnection" 
       connectionString="Server=192.168.29.45,1433;Database=MlsListing_Sandbox;User Id=...;Password=...;" />
  <add name="TitleDataConnection" 
       connectionString="Server=192.168.29.45,1433;Database=TitleData;User Id=...;Password=...;" />
</connectionStrings>
```

**Environments:**
- **Sandbox:** `*_Sandbox` databases
- **Stage:** `*_Stage` databases (if exists)
- **Production:** `*` (no suffix) databases

### 4.4 Server Architecture

**Web Servers:**
- **Sandbox:** `[TBD - need server name/IP]`
- **Stage:** `[TBD - need server name/IP]`
- **Production:** `[TBD - need server name/IP]`

**Database Server:**
- **Server:** `192.168.29.45,1433` or `server-mssql1.istrategy.com`
- **Access:** SQL Server Authentication
- **Credentials:** [In Master Credential Tracker]

---

## 🔌 5. EXISTING API PATTERNS

### 5.1 Current API Structure

**Base URL:** `/api/`

**Existing Controllers:**
- `DataController` - Data access endpoints
- `ListingController` - Listing operations (if exists)
- `PropertyCastController` - Listing Command operations
- `AuthController` - Authentication endpoints

### 5.2 API Pattern PLS Must Follow

**Controller Pattern:**
```csharp
[Route("api/pls")]
[Authorize] // Uses existing auth
public class PlsController : ApiController
{
    private readonly IPlsService _plsService;
    
    public PlsController(IPlsService plsService)
    {
        _plsService = plsService;
    }
    
    [HttpPost]
    [Route("create")]
    [SmartAuthorize(PermissionType.ManagePLS)] // Uses existing permission system
    public IHttpActionResult CreateListing([FromBody] CreateListingRequest request)
    {
        // Implementation
    }
}
```

**Key Patterns:**
- ✅ Use existing `[Authorize]` attribute
- ✅ Use existing `[SmartAuthorize]` for permissions
- ✅ Follow existing error handling patterns
- ✅ Use existing response formats
- ✅ Follow existing validation patterns

### 5.3 DataController Extension Pattern

**Existing:** `DataController.cs` (partial class)

**PLS Extension:** `DataController.PLS.cs` (partial class)

**Pattern:**
```csharp
// DataController.PLS.cs
public partial class DataController : ApiController
{
    [HttpPost]
    [Route("api/Data/PrePopulatePls")]
    public IHttpActionResult PrePopulatePls([FromBody] AddressRequest request)
    {
        // PLS-specific data endpoints
    }
}
```

**CRITICAL:** Must use `partial class` to extend existing controller without modifying original file.

---

## 🔐 6. AUTHENTICATION & AUTHORIZATION

### 6.1 Current Authentication System

**Method:** JWT Bearer Tokens

**Flow:**
1. User logs in → Receives JWT token
2. Token included in `Authorization: Bearer {token}` header
3. API validates token on each request
4. Token claims checked for permissions

**Token Structure:**
- `sub` - User ID
- `email` - User email
- `role` - User role
- `permissions` - Permission array
- `exp` - Expiration (60 minutes)
- `iat` - Issued at

**CRITICAL:** PLS must use existing JWT system - cannot create new auth.

### 6.2 Current Authorization System

**Permission-Based Access Control:**

**Permission Table:** `FarmGenie.dbo.Permission`

**Permission IDs Used by PLS:**
- **210** - `ManagePLS` - Can create/edit PLS listings
- **211** - `MenuPLS` - Can see PLS menu item
- **212** - `ViewPLSHistory` - View status log/audit trail
- **213** - `PLSRadar` - Admin access to all PLS listings
- **214** - `PLSSubmitWhileImpersonating` - Admin feature

**Authorization Attribute:**
```csharp
[SmartAuthorize(PermissionType.ManagePLS)]
public IHttpActionResult CreateListing(...)
{
    // Only users with ManagePLS permission can access
}
```

**CRITICAL:** PLS must use existing permission system - cannot create new permissions without approval.

**📚 COMPLETE DOCUMENTATION:** See `06_Infrastructure/PLS_PERMISSION_ROLE_INTEGRATION_v1.md` for detailed permission system specification.

---

## 👥 7. ROLES & PERMISSIONS SYSTEM

### 7.1 Current Role System

**Roles Table:** `FarmGenie.dbo.AspNetRoles`

**Existing Roles:**
- Affiliate Agent (Title Rep)
- Core Agent
- Elite Agent
- Ultimate Agent
- Super User
- Admin
- Broker Admin
- Genie Customer Service

**Role Assignment:** `FarmGenie.dbo.AspNetUserRoles`

**Role Details:** `FarmGenie.dbo.AspNetRoleDetails` (display names, descriptions)

**CRITICAL:** PLS does NOT create new roles - uses existing roles.

### 7.2 Permission System

**Permission Tables:**
- `FarmGenie.dbo.Permission` - All feature permissions (PermissionID, Description, Notes)
- `FarmGenie.dbo.RolePermission` - Role-to-permission mapping (RoleID, PermissionID)
- `FarmGenie.dbo.UserCustomPermission` - Individual user overrides (UserId, PermissionID)

**Permission Flow:**
```
USER LOGIN (AspNetUserId)
    ↓
LOOKUP ROLES (AspNetUserRoles)
    ↓
CHECK PERMISSIONS (RolePermission)
    ↓
FRONTEND CHECKS hasPermission(PermissionType.ManagePLS)
    ↓
SHOW/HIDE FEATURES ACCORDINGLY
```

**Permission Assignment by Role (PLS):**

| Role | Permissions | Can Create/Edit | Can View All | Can Impersonate |
|------|------------|-----------------|--------------|-----------------|
| **Affiliate Agent** | 211 (Menu PLS) | ❌ No | ❌ No | ❌ No |
| **Core Agent** | 211 (Menu PLS) | ❌ No | ❌ No | ❌ No |
| **Elite Agent** | 210, 211, 212 | ✅ Own listings | ❌ No | ❌ No |
| **Ultimate Agent** | 210, 211, 212 | ✅ Own listings | ❌ No | ❌ No |
| **Super User** | 210, 211, 212, 213 | ✅ Own listings | ✅ Yes (PLS Radar) | ❌ No |
| **Admin** | 210, 211, 212, 213, 214 | ✅ All listings | ✅ Yes (PLS Radar) | ✅ Yes |
| **Title Rep** | 211 (via Title Partner) | ❌ No (unless granted 210) | ❌ No | ❌ No |

**Permission Check Pattern:**
```csharp
// Backend
[SmartAuthorize(PermissionType.ManagePLS)]

// Frontend (Angular)
canActivate: [PermissionGuard],
data: { permission: PermissionType.MenuPLS }
```

**CRITICAL:** PLS must check permissions using existing system.

**📚 COMPLETE DOCUMENTATION:** See `06_Infrastructure/PLS_PERMISSION_ROLE_INTEGRATION_v1.md` for:
- Complete permission specification
- Controller authorization patterns
- Stored procedure permission patterns
- Database integration SQL scripts
- Implementation checklist

---

## 🎨 8. UI FRAMEWORK & PATTERNS

### 8.1 Current Angular Application

**Location:** `AngularApp/src/app/`

**Existing Structure:**
- Components organized by feature
- Shared components in `shared/`
- Services in `services/`
- Routing in `app-routing.module.ts`

**PLS Integration:**
- PLS components in `AngularApp/src/app/pls/`
- PLS routes added to existing routing
- PLS services follow existing service patterns

### 8.2 UI Component Patterns

**Existing Patterns (PLS Must Follow):**
- Component structure (`.ts`, `.html`, `.scss`)
- Service injection pattern
- HTTP client usage
- Error handling
- Loading states
- Form validation

**CRITICAL:** PLS components must match existing UI style and patterns.

### 8.3 Navigation Integration

**Existing Menu:** [TBD - need to document existing menu structure]

**PLS Menu Item:**
- Requires `MenuPLS` permission (211)
- Route: `/pls/my-listings`
- Must integrate with existing navigation

---

## 🚫 9. WHAT CANNOT BE CHANGED

### 9.1 Database Constraints

**Cannot Modify:**
- ❌ `MlsListing.dbo.Listing` table structure
- ❌ Existing stored procedures in MlsListing database
- ❌ Existing indexes (without DBA approval)
- ❌ Existing table relationships
- ❌ Existing data types

**Can Create:**
- ✅ New tables in FarmGenie database
- ✅ New stored procedures in FarmGenie database
- ✅ New views in FarmGenie database
- ✅ New indexes in FarmGenie database (with approval)

### 9.2 Code Constraints

**Cannot Modify:**
- ❌ Existing controllers (except via partial classes)
- ❌ Existing services (must create new)
- ❌ Existing authentication system
- ❌ Existing permission system
- ❌ Existing routing (must add to existing)
- ❌ Existing Angular app structure (must add to existing)

**Can Create:**
- ✅ New controllers (PlsController)
- ✅ New services (PlsService)
- ✅ New Angular components
- ✅ New routes (added to existing routing)

### 9.3 Infrastructure Constraints

**Cannot Modify:**
- ❌ IIS application pool settings
- ❌ .NET Framework version (must use 4.8)
- ❌ Web.config structure (must add to existing)
- ❌ Existing connection strings (must add new ones)
- ❌ Existing deployment process (must follow)

**Can Add:**
- ✅ New connection strings
- ✅ New app settings
- ✅ New routes
- ✅ New DLLs (must not conflict)

---

## ✅ 10. WHAT CAN BE EXTENDED

### 10.1 Database Extensions

**Can Add:**
- ✅ New tables in FarmGenie database
- ✅ New stored procedures
- ✅ New views
- ✅ New indexes (with approval)
- ✅ Foreign keys to existing tables

### 10.2 Code Extensions

**Can Add:**
- ✅ New API controllers
- ✅ Partial class extensions (DataController.PLS.cs)
- ✅ New services
- ✅ New Angular components
- ✅ New routes
- ✅ New models/DTOs

### 10.3 Configuration Extensions

**Can Add:**
- ✅ New connection strings
- ✅ New app settings
- ✅ New route configurations
- ✅ New permission types (with approval)

---

## 🔄 11. COMPATIBILITY REQUIREMENTS

### 11.1 Backward Compatibility

**Must Maintain:**
- ✅ Existing API endpoints continue to work
- ✅ Existing UI components continue to work
- ✅ Existing database queries continue to work
- ✅ Existing authentication continues to work
- ✅ Existing permissions continue to work

**CRITICAL:** PLS cannot break existing functionality.

### 11.2 Version Compatibility

**Must Match:**
- ✅ .NET Framework 4.8
- ✅ ASP.NET Web API 2.x
- ✅ SQL Server 2016+ compatibility
- ✅ Angular version (match existing)
- ✅ TypeScript version (match existing)

### 11.3 Integration Compatibility

**Must Work With:**
- ✅ Existing Listing Command workflow
- ✅ Existing PropertyCast system
- ✅ Existing GenieCloud integration
- ✅ Existing Paisley AI integration
- ✅ Existing TitleGenie integration

---

## 📚 12. LEGACY SYSTEM CONSIDERATIONS

### 12.1 Existing Code Patterns

**Patterns to Respect:**
- Existing controller patterns
- Existing service patterns
- Existing data access patterns
- Existing error handling patterns
- Existing logging patterns

**CRITICAL:** PLS code must follow existing patterns, not create new patterns.

### 12.2 Technical Debt Awareness

**Known Issues:**
- [TBD - document known technical debt]
- [TBD - document workarounds in use]
- [TBD - document deprecated patterns to avoid]

**CRITICAL:** PLS should not introduce new technical debt.

---

## 💻 13. DEVELOPMENT ENVIRONMENT SETUP

### 13.1 Local Development Setup

**Required Software:**
- Visual Studio 2019+ (or 2022)
- .NET Framework 4.8 SDK
- SQL Server Management Studio (SSMS)
- Node.js and npm (for Angular)
- Angular CLI

**Setup Steps:**
1. Clone repository
2. Open solution in Visual Studio
3. Restore NuGet packages
4. Configure connection strings (local or sandbox)
5. Build solution
6. Run Angular app (`ng serve`)
7. Run API (F5 in Visual Studio)

### 13.2 Database Access

**Sandbox Database:**
- Server: `192.168.29.45,1433`
- Database: `FarmGenie_Sandbox`, `MlsListing_Sandbox`
- Credentials: [In Master Credential Tracker]

**Local Database (Optional):**
- Can restore sandbox databases locally
- Use for offline development

### 13.3 Source Code Structure

**Where PLS Code Lives:**
```
Smart.Dashboard/
├── Controllers/
│   ├── PlsController.cs (NEW)
│   └── DataController.PLS.cs (NEW - partial)
├── Services/
│   └── PlsService.cs (NEW)
├── Models/
│   └── PlsModels.cs (NEW)
└── AngularApp/
    └── src/
        └── app/
            └── pls/ (NEW)
                ├── pls-my-listings/
                ├── pls-create/
                └── pls-edit/
```

---

## 🧪 14. TESTING ENVIRONMENT

### 14.1 Sandbox Environment

**Purpose:** Pre-production testing

**Access:**
- URL: `[TBD - sandbox URL]`
- Database: `*_Sandbox` databases
- Credentials: [In Master Credential Tracker]

**Usage:**
- Test all PLS features
- Verify integration with existing systems
- Performance testing
- User acceptance testing

### 14.2 Testing Constraints

**Must Test:**
- ✅ PLS features work correctly
- ✅ Existing features still work (regression testing)
- ✅ Integration with Listing Command
- ✅ Integration with GenieCloud
- ✅ Permission system works
- ✅ Authentication works

---

## 📋 15. DOCUMENTATION REQUIREMENTS

### 15.1 Code Documentation

**Required:**
- XML documentation on all public methods
- Comments on complex logic
- README for new components
- API documentation updates

### 15.2 Change Documentation

**Required:**
- Document all database changes
- Document all API changes
- Document all UI changes
- Update this onboarding package if platform changes

---

## 🎯 16. KEY SUCCESS FACTORS

### 16.1 Integration Success

**Must Achieve:**
- ✅ PLS works seamlessly with existing system
- ✅ No breaking changes to existing functionality
- ✅ Performance impact is minimal
- ✅ User experience is consistent

### 16.2 Technical Success

**Must Achieve:**
- ✅ Code follows existing patterns
- ✅ Database changes are minimal and safe
- ✅ Deployment process is smooth
- ✅ Rollback procedure works

---

## 📚 17. REFERENCE DOCUMENTS

### 17.1 Platform Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| **GLOBAL_MASTER_INDEX.md** | `_MASTER_DOCUMENTS/` | Complete documentation index |
| **GLOBAL_MASTER_RULES.md** | `_MASTER_DOCUMENTS/` | Development rules |
| **Master Credential Tracker** | `G:\My Drive\` | Database credentials, API keys |

### 17.2 PLS-Specific Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md** | `01_Master_Documents/` | Complete PLS specification |
| **PLS_DATABASE_SCHEMA_RELATIONAL_v1.md** | `01_Master_Documents/` | Database schema |
| **CONTRACT_PLS_to_GenieCloud_v6.1.md** | `01_Master_Documents/` | GenieCloud integration contract |
| **PLS_PERMISSION_ROLE_INTEGRATION_v1.md** | `06_Infrastructure/` | ✅ **COMPLETE** - Roles & permissions specification |
| **PLS_MASTER_SPECIFICATION_v3.md** | `01_Master_Documents/` | Master specification with permission details |

### 17.3 Existing System Documentation

| Document | Location | Status |
|----------|----------|--------|
| **Listing Command Documentation** | [TBD] | Need to locate |
| **PropertyCast Documentation** | [TBD] | Need to locate |
| **API Documentation** | [TBD] | Need to locate |
| **UI Component Library** | [TBD] | Need to locate |

---

## ⚠️ 18. CRITICAL WARNINGS

### 18.1 Never Do These

1. ❌ **Never modify `MlsListing.dbo.Listing` table structure**
2. ❌ **Never break existing API endpoints**
3. ❌ **Never modify existing authentication system**
4. ❌ **Never create new application pool**
5. ❌ **Never change .NET Framework version**
6. ❌ **Never deploy to production without sandbox testing**
7. ❌ **Never skip backup before deployment**
8. ❌ **Never forget DLL.config in backups**

### 18.2 Always Do These

1. ✅ **Always test in sandbox first**
2. ✅ **Always backup before deployment**
3. ✅ **Always include DLL.config in backups**
4. ✅ **Always verify connection strings**
5. ✅ **Always test existing functionality after PLS changes**
6. ✅ **Always document all changes**
7. ✅ **Always follow existing code patterns**
8. ✅ **Always check permissions before allowing access**

---

## 📋 19. ONBOARDING CHECKLIST

### For New Developers

- [ ] Read this onboarding package (all sections)
- [ ] Read PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md
- [ ] Read GLOBAL_MASTER_RULES.md
- [ ] Set up local development environment
- [ ] Connect to sandbox database
- [ ] Review existing code structure
- [ ] Review existing API patterns
- [ ] Review existing UI patterns
- [ ] Understand permission system
- [ ] Understand authentication flow
- [ ] Review database schema (existing + PLS)
- [ ] Review integration points
- [ ] Ask questions about constraints

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/13/2026 10:15 PM | **INITIAL VERSION:** Created comprehensive dev team onboarding package. Provides 360-degree view of existing platform that PLS must integrate with. Documents all constraints, integration points, tech stack, infrastructure, and development environment. Addresses critical distinction: PLS is feature addition (not standalone) with strict constraints. |

---

## 📝 NEXT STEPS

### Immediate Actions

1. ⏳ **Locate Missing Documentation:**
   - Listing Command documentation
   - PropertyCast documentation
   - Existing API documentation
   - UI component library documentation
   - Server architecture diagrams

2. ⏳ **Complete Infrastructure Details:**
   - Server names/IPs for all environments
   - IIS configuration details
   - Application pool settings
   - Web.config examples

3. ⏳ **Document Existing Patterns:**
   - Complete API request/response examples
   - Complete UI component examples
   - Complete service layer examples

4. ⏳ **Create Visual Diagrams:**
   - Current platform architecture
   - Database relationships (existing + PLS)
   - Integration points diagram

---

**Status:** ✅ ACTIVE - Onboarding Package v1.0

**Location:** `01_Master_Documents/PLS_DEV_TEAM_ONBOARDING_PACKAGE_v1.md`

**DRA-2026 Compliant:** ✅ Yes - Master document with cataloged exhibits

**Priority:** 🔴 **CRITICAL** - Required reading for all PLS developers
