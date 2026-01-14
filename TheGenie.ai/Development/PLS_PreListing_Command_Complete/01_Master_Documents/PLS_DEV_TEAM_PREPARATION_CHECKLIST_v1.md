# PLS Dev Team Preparation Checklist
**Version:** 1.0  
**Created:** 01/13/2026 10:20 PM  
**Last Updated:** 01/13/2026 10:20 PM  
**Author:** JR (Project Manager)  
**Status:** ✅ ACTIVE - Preparation Checklist for Dev Team

---

## 🎯 PURPOSE

This checklist identifies what documentation and information must be gathered/prepared to give the PLS development team a complete 360-degree view of the existing platform.

**Critical Understanding:** PLS is a **feature addition** to existing platform - dev team needs complete context of what they're integrating with.

---

## ✅ WHAT WE HAVE (Documented)

### Platform Documentation (Found)
- ✅ **GLOBAL_MASTER_INDEX.md** - Complete documentation index
- ✅ **GLOBAL_MASTER_RULES.md** - Development rules and standards
- ✅ **DRA_2026_POLICY_v1.md** - Document management policy
- ✅ **DevOpsEcosystemManagement/** - Deployment procedures, CI/CD pipelines
- ✅ **Master Troubleshooting Guide** - Server access, diagnostics
- ✅ **Deployment Prompt v5.0** - Complete deployment workflow

### PLS-Specific Documentation (Complete)
- ✅ **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md** - Complete PLS specification
- ✅ **PLS_DATABASE_SCHEMA_RELATIONAL_v1.md** - Database schema
- ✅ **CONTRACT_PLS_to_GenieCloud_v6.1.md** - GenieCloud integration
- ✅ **PLS_WIREFRAME_SPECIFICATIONS_v1.md** - UI specifications

### Infrastructure Documentation (Partial)
- ✅ **DevOpsEcosystemManagement/** - Deployment, pipelines, troubleshooting
- ⚠️ **Server architecture** - Some details, may need more
- ⚠️ **IIS configuration** - Referenced but not detailed
- ⚠️ **Application pool settings** - Not documented

---

## ❌ WHAT WE NEED (Missing or Incomplete)

### 1. Existing Application Documentation

#### 1.1 Smart.Dashboard Application
**Status:** ⚠️ **NEED TO LOCATE**

**What's Needed:**
- [ ] Application architecture diagram
- [ ] Current API endpoint inventory
- [ ] Existing controller patterns
- [ ] Existing service layer patterns
- [ ] Existing data access patterns
- [ ] Current routing configuration
- [ ] Current authentication implementation details

**Where to Find:**
- [ ] Source code repository
- [ ] Existing API documentation
- [ ] Developer handoff documents
- [ ] Architecture diagrams

#### 1.2 Angular Application Structure
**Status:** ⚠️ **NEED TO DOCUMENT**

**What's Needed:**
- [ ] Current Angular version
- [ ] Component library being used
- [ ] Existing component patterns
- [ ] Existing service patterns
- [ ] Current routing structure
- [ ] Current navigation structure
- [ ] UI framework/library (Bootstrap, Material, etc.)
- [ ] Styling approach (SCSS, CSS, etc.)

**Where to Find:**
- [ ] `AngularApp/package.json` - Version and dependencies
- [ ] `AngularApp/src/app/` - Component structure
- [ ] `AngularApp/src/app/shared/` - Shared components
- [ ] Existing component examples

#### 1.3 Existing API Patterns
**Status:** ⚠️ **NEED TO DOCUMENT**

**What's Needed:**
- [ ] Complete API endpoint list
- [ ] Request/response format examples
- [ ] Error handling patterns
- [ ] Validation patterns
- [ ] Authentication patterns
- [ ] Authorization patterns
- [ ] API versioning approach

**Where to Find:**
- [ ] `Controllers/` folder - Existing controllers
- [ ] API documentation (if exists)
- [ ] Postman collections (if exists)
- [ ] Swagger/OpenAPI docs (if exists)

---

### 2. Database Documentation

#### 2.1 Existing Database Schema
**Status:** ⚠️ **PARTIAL - Need Complete**

**What We Have:**
- ✅ PLS extensions documented
- ✅ MlsListing.dbo.Listing structure referenced
- ⚠️ Complete FarmGenie schema not documented
- ⚠️ Complete MlsListing schema not documented
- ⚠️ TitleData schema not documented

**What's Needed:**
- [ ] Complete FarmGenie database schema diagram
- [ ] Complete MlsListing database schema diagram
- [ ] Complete TitleData database schema diagram
- [ ] All existing stored procedures catalog
- [ ] All existing views catalog
- [ ] All existing indexes documentation
- [ ] Foreign key relationships diagram

**Where to Find:**
- [ ] SQL Server Management Studio - Generate diagrams
- [ ] Existing schema documentation
- [ ] Database scripts
- [ ] DBA documentation

#### 2.2 Existing Stored Procedures
**Status:** ⚠️ **NEED TO CATALOG**

**What's Needed:**
- [ ] Complete list of all stored procedures in FarmGenie
- [ ] Complete list of all stored procedures in MlsListing
- [ ] Procedure parameters and return values
- [ ] Procedure usage examples
- [ ] Which procedures PLS might use

**Where to Find:**
- [ ] SQL Server - Query system tables
- [ ] Existing stored procedure scripts
- [ ] DBA documentation

---

### 3. Infrastructure Documentation

#### 3.1 Server Architecture
**Status:** ⚠️ **PARTIAL**

**What We Have:**
- ✅ Database server: `192.168.29.45,1433`
- ⚠️ Web server details incomplete
- ⚠️ Application server details incomplete

**What's Needed:**
- [ ] Web server names/IPs (Sandbox, Stage, Production)
- [ ] Application server names/IPs
- [ ] Server roles and purposes
- [ ] Load balancer configuration
- [ ] Network architecture diagram

**Where to Find:**
- [ ] DevOps team
- [ ] Infrastructure documentation
- [ ] Server inventory
- [ ] Network diagrams

#### 3.2 IIS Configuration
**Status:** ⚠️ **NEED TO DOCUMENT**

**What's Needed:**
- [ ] Application pool name
- [ ] Application pool settings (.NET version, pipeline mode, identity)
- [ ] Application pool recycling policy
- [ ] IIS site configuration
- [ ] Virtual directory structure
- [ ] SSL certificate configuration
- [ ] URL rewrite rules (if any)

**Where to Find:**
- [ ] IIS Manager on server
- [ ] Server configuration documentation
- [ ] DevOps team

#### 3.3 Configuration Files
**Status:** ⚠️ **NEED EXAMPLES**

**What's Needed:**
- [ ] Complete Web.config example (sanitized)
- [ ] Complete DLL.config example (sanitized)
- [ ] Connection string formats
- [ ] App settings structure
- [ ] Environment-specific configurations

**Where to Find:**
- [ ] Sandbox server - Copy Web.config (sanitize)
- [ ] Source code repository
- [ ] Configuration management system

---

### 4. Authentication & Authorization

#### 4.1 Current Authentication Implementation
**Status:** ⚠️ **NEED DETAILS**

**What's Needed:**
- [ ] JWT token generation code/flow
- [ ] JWT token validation code/flow
- [ ] Token expiration configuration
- [ ] Refresh token implementation (if exists)
- [ ] Login endpoint details
- [ ] Logout endpoint details

**Where to Find:**
- [ ] `AuthController.cs` - Authentication controller
- [ ] `AuthService.cs` - Authentication service
- [ ] JWT configuration in Web.config

#### 4.2 Current Authorization Implementation
**Status:** ⚠️ **NEED DETAILS**

**What's Needed:**
- [ ] `SmartAuthorize` attribute implementation
- [ ] Permission check logic
- [ ] Permission table structure (complete)
- [ ] Permission assignment process
- [ ] Role-based access control implementation

**Where to Find:**
- [ ] `SmartAuthorizeAttribute.cs` - Authorization attribute
- [ ] Permission service
- [ ] Database Permission table

---

### 5. UI Framework & Patterns

#### 5.1 Angular Application Details
**Status:** ⚠️ **NEED TO INSPECT**

**What's Needed:**
- [ ] Angular version (from package.json)
- [ ] Component library (Bootstrap, Material, etc.)
- [ ] UI framework version
- [ ] Styling approach
- [ ] Build process
- [ ] Deployment process

**Where to Find:**
- [ ] `AngularApp/package.json`
- [ ] `AngularApp/angular.json`
- [ ] Existing component examples

#### 5.2 Existing UI Components
**Status:** ⚠️ **NEED TO CATALOG**

**What's Needed:**
- [ ] List of existing shared components
- [ ] Component usage examples
- [ ] Component API documentation
- [ ] Styling patterns
- [ ] Form patterns
- [ ] Navigation patterns

**Where to Find:**
- [ ] `AngularApp/src/app/shared/` - Shared components
- [ ] Existing component examples
- [ ] UI component library documentation

---

### 6. Integration Points

#### 6.1 Listing Command Integration
**Status:** ⚠️ **NEED TO DOCUMENT**

**What's Needed:**
- [ ] Listing Command workflow documentation
- [ ] PropertyCast system documentation
- [ ] How PLS integrates with Listing Command
- [ ] PropertyCastTypeId=4 usage
- [ ] Queue system documentation

**Where to Find:**
- [ ] Listing Command documentation
- [ ] PropertyCast code
- [ ] Queue table structure

#### 6.2 GenieCloud Integration
**Status:** ✅ **DOCUMENTED**

**What We Have:**
- ✅ CONTRACT_PLS_to_GenieCloud_v6.1.md
- ✅ XML mapping documentation

#### 6.3 Paisley AI Integration
**Status:** ⚠️ **PARTIAL**

**What's Needed:**
- [ ] Complete Paisley API documentation
- [ ] ChatStartTypeId=3 implementation details
- [ ] API endpoint details
- [ ] Authentication for Paisley API

**Where to Find:**
- [ ] Paisley documentation
- [ ] Existing Paisley integration code

---

### 7. Development Environment

#### 7.1 Local Development Setup
**Status:** ⚠️ **NEED TO DOCUMENT**

**What's Needed:**
- [ ] Step-by-step local setup instructions
- [ ] Required software versions
- [ ] Database setup for local development
- [ ] Configuration for local development
- [ ] How to run locally
- [ ] How to debug locally

**Where to Find:**
- [ ] Existing developer documentation
- [ ] Setup scripts
- [ ] README files

#### 7.2 Source Code Access
**Status:** ⚠️ **NEED TO DOCUMENT**

**What's Needed:**
- [ ] Repository location (Git, TFS, etc.)
- [ ] Branching strategy
- [ ] Check-in process
- [ ] Code review process
- [ ] Build process
- [ ] Testing process

**Where to Find:**
- [ ] Source control system
- [ ] DevOps team
- [ ] Existing developer documentation

---

## 📋 PREPARATION TASKS

### Task 1: Gather Existing Application Documentation
**Priority:** 🔴 **CRITICAL**

**Actions:**
1. [ ] Locate Smart.Dashboard source code
2. [ ] Document current API endpoints
3. [ ] Document existing controller patterns
4. [ ] Document existing service patterns
5. [ ] Document existing data access patterns
6. [ ] Create API endpoint inventory

**Deliverable:** `PLS_EXISTING_APPLICATION_DOCUMENTATION_v1.md`

---

### Task 2: Document Database Schema (Complete)
**Priority:** 🔴 **CRITICAL**

**Actions:**
1. [ ] Generate complete FarmGenie schema diagram
2. [ ] Generate complete MlsListing schema diagram
3. [ ] Generate complete TitleData schema diagram
4. [ ] Catalog all stored procedures
5. [ ] Document all foreign key relationships
6. [ ] Create database reference guide

**Deliverable:** `PLS_EXISTING_DATABASE_REFERENCE_v1.md`

---

### Task 3: Document Infrastructure Details
**Priority:** 🔴 **CRITICAL**

**Actions:**
1. [ ] Document server architecture (all environments)
2. [ ] Document IIS configuration
3. [ ] Document application pool settings
4. [ ] Document configuration file structure
5. [ ] Document connection string formats
6. [ ] Create infrastructure reference guide

**Deliverable:** `PLS_INFRASTRUCTURE_REFERENCE_v1.md`

---

### Task 4: Document Authentication & Authorization
**Priority:** ✅ **COMPLETE** - Documentation Found

**Status:** ✅ **EXISTING DOCUMENTATION FOUND**

**Found Documents:**
- ✅ `06_Infrastructure/PLS_PERMISSION_ROLE_INTEGRATION_v1.md` - Complete permission system specification
- ✅ `01_Master_Documents/PLS_MASTER_SPECIFICATION_v3.md` - Includes permission details

**What's Documented:**
- ✅ Permission types (210-214)
- ✅ Role-based access control
- ✅ Controller authorization patterns
- ✅ Stored procedure permission patterns
- ✅ Database integration SQL scripts
- ✅ Implementation checklist

**What May Still Need:**
- [ ] JWT token generation/validation code examples
- [ ] SmartAuthorize attribute implementation details
- [ ] PermissionGuard Angular implementation details

**Deliverable:** ✅ Already exists - `PLS_PERMISSION_ROLE_INTEGRATION_v1.md`

---

### Task 5: Document UI Framework & Patterns
**Priority:** 🟡 **HIGH**

**Actions:**
1. [ ] Inspect Angular application structure
2. [ ] Document component library
3. [ ] Document UI patterns
4. [ ] Document navigation structure
5. [ ] Create UI reference guide

**Deliverable:** `PLS_UI_FRAMEWORK_REFERENCE_v1.md`

---

### Task 6: Document Integration Points
**Priority:** 🟡 **HIGH**

**Actions:**
1. [ ] Document Listing Command integration
2. [ ] Document PropertyCast integration
3. [ ] Document Paisley AI integration (complete)
4. [ ] Document TitleGenie integration
5. [ ] Create integration reference guide

**Deliverable:** `PLS_INTEGRATION_POINTS_REFERENCE_v1.md`

---

### Task 7: Create Visual Diagrams
**Priority:** 🟢 **MEDIUM**

**Actions:**
1. [ ] Create platform architecture diagram
2. [ ] Create database relationship diagram (existing + PLS)
3. [ ] Create integration points diagram
4. [ ] Create deployment architecture diagram

**Deliverable:** Diagrams in `06_Infrastructure/Diagrams/`

---

### Task 8: Create Development Environment Guide
**Priority:** 🟢 **MEDIUM**

**Actions:**
1. [ ] Document local setup process
2. [ ] Document source code access
3. [ ] Document build process
4. [ ] Document testing process
5. [ ] Create developer setup guide

**Deliverable:** `PLS_DEVELOPER_SETUP_GUIDE_v1.md`

---

## 📊 PREPARATION STATUS

### Critical (Blocks Development)
- [ ] **Existing Application Documentation** - 0% complete
- [ ] **Complete Database Schema** - 30% complete (PLS extensions done, existing schema needed)
- [ ] **Infrastructure Details** - 40% complete (some details, need complete)

### High Priority (Slows Development)
- [ ] **Authentication & Authorization** - 20% complete (mentioned, need details)
- [ ] **UI Framework & Patterns** - 10% complete (need to inspect)
- [ ] **Integration Points** - 50% complete (GenieCloud done, others needed)

### Medium Priority (Nice to Have)
- [ ] **Visual Diagrams** - 0% complete
- [ ] **Development Environment Guide** - 0% complete

---

## 🎯 RECOMMENDED APPROACH

### Phase 1: Critical Documentation (Week 1)
**Goal:** Give dev team enough to start development

1. **Day 1-2:** Gather existing application documentation
   - Inspect source code
   - Document API patterns
   - Document controller patterns

2. **Day 3-4:** Complete database documentation
   - Generate schema diagrams
   - Catalog stored procedures
   - Document relationships

3. **Day 5:** Infrastructure details
   - Document servers
   - Document IIS configuration
   - Document configuration files

**Deliverable:** Complete onboarding package with critical sections

### Phase 2: Integration Documentation (Week 2)
**Goal:** Complete integration context

1. Document all integration points
2. Document authentication/authorization
3. Document UI framework
4. Create visual diagrams

**Deliverable:** Complete integration reference guides

### Phase 3: Development Tools (Week 3)
**Goal:** Enable smooth development

1. Create developer setup guide
2. Document build process
3. Document testing process
4. Create troubleshooting guide

**Deliverable:** Complete developer tools documentation

---

## 📚 EXISTING DOCUMENTATION TO REVIEW

### Master Documents
- `GLOBAL_MASTER_INDEX.md` - May have links to existing app docs
- `GLOBAL_MASTER_RULES.md` - Development standards

### DevOps Documentation
- `DevOpsEcosystemManagement/CI_CD_Pipelines/` - Build/deploy process
- `DevOpsEcosystemManagement/Monitoring/Server Troubleshooting/` - Server access
- `DevOpsEcosystemManagement/Deployments/` - Deployment procedures

### PLS Documentation
- `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` - PLS specification
- `PLS_DEV_TEAM_ONBOARDING_PACKAGE_v1.md` - Onboarding package (this document's companion)

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/13/2026 10:20 PM | **INITIAL VERSION:** Created comprehensive preparation checklist. Identified what documentation exists vs what's missing. Created 8 preparation tasks with priorities. Defined 3-phase approach to complete documentation. This checklist guides what needs to be gathered/prepared before dev team starts. |

---

**Status:** ✅ ACTIVE - Preparation Checklist

**Location:** `01_Master_Documents/PLS_DEV_TEAM_PREPARATION_CHECKLIST_v1.md`

**DRA-2026 Compliant:** ✅ Yes - Master document with cataloged exhibits

**Priority:** 🔴 **CRITICAL** - Must complete before dev team starts
