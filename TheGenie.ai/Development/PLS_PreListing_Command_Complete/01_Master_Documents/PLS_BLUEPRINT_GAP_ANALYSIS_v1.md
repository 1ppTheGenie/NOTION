# PLS Blueprint Gap Analysis - What's Missing vs eRealtor Spec
**Version:** 1.0  
**Created:** 01/13/2026 10:00 PM  
**Last Updated:** 01/13/2026 10:00 PM  
**Author:** JR (Project Manager)  
**Status:** ✅ ACTIVE - Gap Analysis for Blueprint Completion

---

## 🎯 PURPOSE

This document identifies what the **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md** lacks compared to the **eRealtorMSv1i1 Tech Design.pdf** specification structure. This analysis will help complete the blueprint to make it buildable.

---

## 📊 COMPARISON: eRealtor vs PLS Blueprint

### What PLS Blueprint HAS (✅)

| Section | PLS Blueprint | Status |
|---------|---------------|--------|
| **Executive Summary** | ✅ Section 1: Project Vision & Goals | Complete |
| **System Architecture** | ✅ Section 2: System Architecture | Complete |
| **Database Design** | ✅ Section 8: Database Design | Complete |
| **API Specifications** | ✅ Section 9: API Design | Complete |
| **UI Design** | ✅ Section 10: UI Design | Complete |
| **Workflow Diagrams** | ✅ Section 11: Data Flow Diagrams | Complete |
| **Integration Points** | ✅ Section 7: Integration Points | Complete |
| **Testing Strategy** | ✅ Section 13: Testing Strategy | Complete |
| **Deployment Plan** | ✅ Section 14: Deployment Plan | Partial |
| **Risk Assessment** | ✅ Section 15: Risk Assessment | Complete |

---

## ❌ WHAT PLS BLUEPRINT LACKS (Compared to eRealtor)

### 1. **Deployment Package Contents** (eRealtor STRATEGY 2-3)

**eRealtor Has:**
- Exact file list: `MSXML3.EXE`, `PROXYCFG.EXE`, `ISIVBSP4Run.EXE`, `HBv1Site.EXE`, `HBv1SQL.EXE`
- Purpose of each file
- Installation order
- Package delivery method (CD or .zip)

**PLS Blueprint Has:**
- ⚠️ Deployment plan mentions scripts but not specific package contents
- ⚠️ No file list with purposes
- ⚠️ No installation order
- ⚠️ No package delivery specification

**What's Needed:**
```
## DEPLOYMENT PACKAGE CONTENTS

### Required Files
- `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` - Database schema
- `PLS_STORED_PROCEDURES_COMPLETE_v1.sql` - Stored procedures
- `PLS_DATABASE_MASTER_DATA_v3.sql` - Master data inserts
- `PlsController_Complete_v1.cs` - API controller
- `pls-create.component.*` - Angular components
- `Web.config` - Application configuration
- `DLL.config` - Connection strings (CRITICAL)
- [etc...]
```

---

### 2. **Step-by-Step Server Build Instructions** (eRealtor STRATEGY 2-3)

**eRealtor Has:**
- Numbered steps: "1. Build Windows2000 Advanced Server"
- Sub-steps: "a. Click on Start / Programs..."
- Exact installation procedures
- Configuration steps
- SQL Server build instructions

**PLS Blueprint Has:**
- ⚠️ Section 14 has deployment steps but not as detailed
- ⚠️ No server build instructions
- ⚠️ No step-by-step installation guide
- ⚠️ No configuration file setup details

**What's Needed:**
```
## BUILDING THE APPLICATION SERVERS

1. Build Windows Server [version]
2. Install IIS and required services
   a. [Exact steps]
   b. [Configuration]
3. Install .NET Framework 4.8
   a. [Steps]
4. Configure connection strings
   a. [Web.config setup]
   b. [DLL.config setup - CRITICAL]
5. Deploy application
   a. [Steps]
```

---

### 3. **Coding Standards Section** (eRealtor STRATEGY 5)

**eRealtor Has:**
- "Option Explicit is not an option"
- "All include files and workflows must be accounted for"
- "When developing include files follow best practices"
- Change documentation requirements

**PLS Blueprint Has:**
- ⚠️ No dedicated coding standards section
- ⚠️ References Master Rules but not integrated
- ⚠️ No code organization patterns documented
- ⚠️ No change documentation process

**What's Needed:**
```
## CODING STANDARDS

### Requirements
- All code must follow Master Rules (file versioning, no placeholders, etc.)
- All service classes must be documented
- All API endpoints must have XML documentation
- All stored procedures must have comments
- Change documentation process: [steps]
```

---

### 4. **Session Management Details** (eRealtor STRATEGY 6)

**eRealtor Has:**
- Exact session data structure table
- Field descriptions
- Session lifespan (10 minutes, configurable)
- Session management component (`isSessionManagement`)

**PLS Blueprint Has:**
- ⚠️ Mentions JWT tokens but not detailed structure
- ⚠️ No session data field definitions
- ⚠️ No token lifespan specification
- ⚠️ No JWT claims structure documented

**What's Needed:**
```
## SESSION MANAGEMENT (JWT TOKENS)

### JWT Token Structure
| Claim | Description | Example |
|-------|-------------|---------|
| `sub` | User ID | "user-123" |
| `email` | User email | "user@example.com" |
| `role` | User role | "Agent" |
| `permissions` | Permission array | ["ManagePLS", "MenuPLS"] |
| `exp` | Expiration | Unix timestamp |
| `iat` | Issued at | Unix timestamp |

### Token Lifespan
- Access token: 60 minutes
- Refresh token: 7 days
- Configurable via `Web.config`
```

---

### 5. **Code Organization Pattern** (eRealtor STRATEGY 7)

**eRealtor Has:**
- Specific include files: `_AuthCheck.inc`, `_Constants.inc`, `_SessionRead.inc`
- Purpose of each file
- Usage pattern
- Sample code showing include pattern

**PLS Blueprint Has:**
- ⚠️ Mentions "PlsService" but not detailed structure
- ⚠️ No specific service class names
- ⚠️ No code organization pattern documented
- ⚠️ No reusable component list

**What's Needed:**
```
## CODE ORGANIZATION PATTERN

### Service Layer Structure
- `PlsService` - Business logic
- `PlsDataService` - Data access
- `PlsValidationService` - Validation logic
- `PlsXmlService` - XML generation
- `PlsAuthService` - Authentication/authorization

### Usage Pattern
```csharp
// Example: Controller uses service layer
public class PlsController : ApiController
{
    private readonly IPlsService _plsService;
    
    public PlsController(IPlsService plsService)
    {
        _plsService = plsService;
    }
}
```
```

---

### 6. **Complete API Request/Response Examples** (eRealtor STRATEGY 8)

**eRealtor Has:**
- Complete SOAP XML request examples
- Complete SOAP XML response examples
- Field-by-field documentation
- Error response examples

**PLS Blueprint Has:**
- ✅ Section 9 has API specifications
- ⚠️ May not have complete request/response examples for all endpoints
- ⚠️ May not have error response examples
- ⚠️ May not have field-by-field documentation

**What's Needed:**
```
## COMPLETE API EXAMPLES

### POST /api/pls/create

**Request:**
```json
{
  "address": "123 Main St",
  "city": "Austin",
  "state": "TX",
  "zip": "78701",
  "statusTypeId": 3,
  "sourceTypeId": 1
}
```

**Success Response (200):**
```json
{
  "listingId": 12345,
  "plsNumber": "PLS100000A",
  "status": "created",
  "createdAt": "2026-01-13T10:00:00Z"
}
```

**Error Response (400):**
```json
{
  "error": "Validation failed",
  "errors": [
    {
      "field": "address",
      "message": "Address is required"
    }
  ]
}
```
```

---

### 7. **Configuration File Details** (eRealtor STRATEGY 4)

**eRealtor Has:**
- Specific configuration files mentioned
- Configuration structure
- Deployment configuration details

**PLS Blueprint Has:**
- ⚠️ Mentions `Web.config` and `DLL.config` but not detailed structure
- ⚠️ No configuration file examples
- ⚠️ No environment-specific configuration details
- ⚠️ No connection string format documentation

**What's Needed:**
```
## CONFIGURATION FILES

### Web.config Structure
```xml
<configuration>
  <connectionStrings>
    <add name="FarmGenie" connectionString="..." />
    <add name="MlsListing" connectionString="..." />
  </connectionStrings>
  <appSettings>
    <add key="JwtSecret" value="..." />
    <add key="JwtExpirationMinutes" value="60" />
  </appSettings>
</configuration>
```

### DLL.config Structure (CRITICAL)
```xml
<configuration>
  <connectionStrings>
    <!-- Same as Web.config but loaded at startup -->
  </connectionStrings>
</configuration>
```

### Environment-Specific Configuration
- Sandbox: [details]
- Stage: [details]
- Production: [details]
```

---

### 8. **Database Build Instructions** (eRealtor STRATEGY 2-3)

**eRealtor Has:**
- "Building the SQL Server" section
- Step-by-step database installation
- SQL script execution order
- Database setup verification

**PLS Blueprint Has:**
- ✅ Section 14 mentions database setup
- ⚠️ Not as detailed step-by-step
- ⚠️ No SQL script execution order
- ⚠️ No database verification checklist

**What's Needed:**
```
## BUILDING THE DATABASE SERVER

1. Connect to SQL Server
2. Execute scripts in order:
   a. `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
   b. `PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql`
   c. `PLS_DATABASE_MASTER_DATA_v3.sql`
   d. `PLS_STORED_PROCEDURES_COMPLETE_v1.sql`
3. Verify installation:
   - [ ] All tables created
   - [ ] All stored procedures created
   - [ ] Master data inserted
   - [ ] PLS number generation tested
```

---

### 9. **Constants Management** (eRealtor STRATEGY 7: _Constants.inc)

**eRealtor Has:**
- "Never use magic numbers"
- Constants file pattern
- All constants documented

**PLS Blueprint Has:**
- ✅ Uses lookup tables (better than constants)
- ⚠️ But no documentation of lookup table values
- ⚠️ No "magic number" reference guide
- ⚠️ No StatusTypeID mapping documentation

**What's Needed:**
```
## CONSTANTS & LOOKUP VALUES

### PLS Status Types (pls_status_type)
| ID | Code | Name | Description |
|----|------|------|-------------|
| 1 | incomplete | Incomplete | Listing not yet complete |
| 2 | draft | Draft | Draft listing |
| 3 | active | Active | Active listing |
| 4 | coming_soon | Coming Soon | Coming soon listing |
| 5 | lost_opportunity | Lost Opportunity | Lost opportunity |
| 6 | published_to_mls | Published to MLS | Published to MLS |

### MLS StatusTypeID Mapping
| PLS Status | MLS StatusTypeID | Notes |
|------------|------------------|-------|
| active | 6 | Private Listing |
| coming_soon | 14 | Coming Soon |
| incomplete | NULL | Not published |
| draft | NULL | Not published |

### Source Types (pls_source_type)
[Table with all values]

### Permission IDs
| ID | Name | Description |
|----|------|-------------|
| 210 | ManagePLS | Can create/edit PLS listings |
| 211 | MenuPLS | Can see PLS menu |
| 213 | PLS Radar | Admin access |
| 214 | PLS Submit While Impersonating | Admin feature |
```

---

### 10. **Authentication/Authorization Details** (eRealtor STRATEGY 7: _AuthCheck.inc)

**eRealtor Has:**
- Authentication check pattern
- Authorization logic
- Redirect behavior

**PLS Blueprint Has:**
- ⚠️ Mentions JWT but not detailed auth flow
- ⚠️ No authorization attribute documentation
- ⚠️ No permission check implementation details
- ⚠️ No auth failure handling

**What's Needed:**
```
## AUTHENTICATION & AUTHORIZATION

### JWT Authentication Flow
1. User logs in → Receives JWT token
2. Token included in Authorization header: `Bearer {token}`
3. API validates token on each request
4. Token claims checked for permissions

### Authorization Attributes
```csharp
[SmartAuthorize(PermissionType.ManagePLS)]
public IHttpActionResult CreateListing(...)
{
    // Only users with ManagePLS permission can access
}
```

### Permission Check Implementation
- Frontend: `PermissionGuard` route guard
- Backend: `SmartAuthorize` attribute
- Database: `Permission` table lookup
```

---

## 📋 SUMMARY: Critical Missing Sections

### High Priority (Blocks Implementation)
1. ❌ **Deployment Package Contents** - Can't deploy without knowing what files
2. ❌ **Step-by-Step Server Build Instructions** - Can't build servers without steps
3. ❌ **Database Build Instructions** - Can't set up database without order
4. ❌ **Configuration File Details** - Can't configure without structure
5. ❌ **Complete API Examples** - Can't integrate without examples

### Medium Priority (Slows Implementation)
6. ❌ **Session Management Details** - JWT structure needed
7. ❌ **Code Organization Pattern** - Service layer structure needed
8. ❌ **Constants/Lookup Values** - Reference guide needed
9. ❌ **Authentication/Authorization Details** - Auth flow needed

### Low Priority (Nice to Have)
10. ❌ **Coding Standards Section** - Can reference Master Rules

---

## 🎯 RECOMMENDATION

**Add these sections to PLS Blueprint:**

1. **Section 22: Deployment Package Contents** (NEW)
2. **Section 23: Server Build Instructions** (NEW)
3. **Section 24: Database Build Instructions** (NEW)
4. **Section 25: Configuration Files** (NEW)
5. **Section 26: Coding Standards** (NEW)
6. **Section 27: Session Management Details** (NEW)
7. **Section 28: Code Organization Pattern** (NEW)
8. **Section 29: Constants & Lookup Values Reference** (NEW)
9. **Section 30: Authentication & Authorization** (NEW)
10. **Enhance Section 9: API Design** - Add complete request/response examples

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/13/2026 10:00 PM | **INITIAL VERSION:** Created gap analysis comparing PLS Blueprint v1.7 to eRealtor spec. Identified 10 critical missing sections. Prioritized by implementation blocking level. Provided detailed examples of what's needed for each gap. |

---

**Status:** ✅ ACTIVE - Gap Analysis Complete

**Location:** `01_Master_Documents/PLS_BLUEPRINT_GAP_ANALYSIS_v1.md`

**DRA-2026 Compliant:** ✅ Yes - Master document with cataloged exhibits
