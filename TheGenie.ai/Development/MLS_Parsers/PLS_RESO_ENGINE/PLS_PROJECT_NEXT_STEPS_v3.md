# PLS Project - Next Steps
**Version:** 3.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Clear next steps after database schema completion

---

## ✅ COMPLETED (Database Layer)

### Schema Design (100% Complete)
- [x] **v3.0 Normalized Schema** - `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
  - `pls_tracking` - Lifecycle/metadata tracking
  - `pls_status_log` - Complete audit trail
  - Lookup tables (status_type, source_type, status_mapping)
  - Helper views for backward compatibility

- [x] **PlsListingOwnership Table** - `PLS_DATABASE_OWNERSHIP_TABLE_v3.sql`
  - Flexible ownership model (Creator + CoAgent)
  - Ready for future expansion

- [x] **PLS Number Sequence** - `PLS_DATABASE_PLSNUMBER_SEQUENCE_v3.sql`
  - `PlsNumberSequence` table
  - `usp_GetNextPlsNumber` stored procedure

- [x] **Master Data Scripts** - `PLS_DATABASE_MASTER_DATA_v3.sql`
  - StatusTypeID 6 (Private Listing)
  - MlsID 777 (PLS identifier)
  - PropertyCastTypeId 4 (PLS)
  - Permissions 210-214

- [x] **Documentation**
  - Schema diagrams
  - Change logs
  - Checklists

---

## 🎯 NEXT: PHASE 1 - FOUNDATION (Week 1-2)

### Goal
Database infrastructure and basic API endpoints

### Immediate Tasks

#### 1. Database Execution (DBA Task)
**Priority:** 🔴 **CRITICAL - DO FIRST**

**Scripts to Execute (in order):**
1. `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql` - Core PLS tables
2. `PLS_DATABASE_OWNERSHIP_TABLE_v3.sql` - Ownership table
3. `PLS_DATABASE_PLSNUMBER_SEQUENCE_v3.sql` - Number generation
4. `PLS_DATABASE_MASTER_DATA_v3.sql` - Master data inserts

**Verification:**
- [ ] All tables created successfully
- [ ] All indexes created
- [ ] Master data inserted (verify StatusTypeID 6, MlsID 777, etc.)
- [ ] Stored procedure `usp_GetNextPlsNumber` works
- [ ] Test PLS number generation: `EXEC usp_GetNextPlsNumber`

**Owner:** DBA Team  
**Estimated Time:** 2-4 hours

---

#### 2. Backend: Create PlsController Skeleton
**Priority:** 🟡 **HIGH**

**Location:** `Smart.Dashboard/Controllers/PlsController.cs`

**Endpoints to Create (skeleton only - return mock data):**
```csharp
[ApiController]
[Route("api/pls")]
public class PlsController : ControllerBase
{
    // GET /api/pls/my-listings
    [HttpGet("my-listings")]
    public IActionResult GetMyListings() { ... }
    
    // GET /api/pls/{listingNumber}
    [HttpGet("{listingNumber}")]
    public IActionResult GetListing(string listingNumber) { ... }
    
    // POST /api/pls/create
    [HttpPost("create")]
    public IActionResult CreateListing([FromBody] CreatePlsListingRequest request) { ... }
    
    // PUT /api/pls/{listingNumber}
    [HttpPut("{listingNumber}")]
    public IActionResult UpdateListing(string listingNumber, [FromBody] UpdatePlsListingRequest request) { ... }
}
```

**Owner:** Backend Developer  
**Estimated Time:** 4-6 hours

---

#### 3. Backend: Create PlsService Skeleton
**Priority:** 🟡 **HIGH**

**Location:** `Smart.Dashboard/Services/PlsService.cs`

**Methods to Create (skeleton only):**
```csharp
public class PlsService
{
    // Database operations
    public Task<string> GetNextPlsNumberAsync() { ... }
    public Task<PlsListingDto> GetListingByNumberAsync(string plsNumber) { ... }
    public Task<List<PlsListingDto>> GetUserListingsAsync(string userId) { ... }
    public Task<PlsListingDto> CreateListingAsync(CreatePlsListingRequest request) { ... }
    public Task<PlsListingDto> UpdateListingAsync(string plsNumber, UpdatePlsListingRequest request) { ... }
    
    // Ownership operations
    public Task<bool> VerifyOwnershipAsync(string userId, int listingId) { ... }
    public Task CreateOwnershipRecordAsync(string userId, int listingId, string plsNumber, int ownershipTypeId) { ... }
    
    // Status operations
    public Task UpdateStatusAsync(int listingId, string fromStatus, string toStatus, string changedBy) { ... }
    public Task<List<StatusLogDto>> GetStatusHistoryAsync(int listingId) { ... }
}
```

**Owner:** Backend Developer  
**Estimated Time:** 6-8 hours

---

#### 4. Backend: Implement Basic CRUD Operations
**Priority:** 🟡 **HIGH**

**Implement These First (in order):**

**4.1. POST /api/pls/create**
- Generate PLS number (`usp_GetNextPlsNumber`)
- Insert into `MlsListing.dbo.Listing` (MlsID=777, StatusTypeID=6 or 14)
- Insert into `pls_tracking` (status='draft', source='paisley' or 'manual')
- Insert into `PlsListingOwnership` (OwnershipTypeId=1, Creator)
- Insert into `pls_status_log` (initial status change)
- Return created listing

**4.2. GET /api/pls/my-listings**
- Query `PlsListingOwnership` for user's listings
- JOIN with `MlsListing.dbo.Listing` and `pls_tracking`
- Filter by `IsActive=1`
- Return list with status, address, PLS number

**4.3. GET /api/pls/{listingNumber}**
- Find listing by PLS number
- JOIN all related tables
- Verify ownership (authorization check)
- Return full listing details

**4.4. PUT /api/pls/{listingNumber}**
- Verify ownership
- Update `MlsListing.dbo.Listing` fields
- Update `pls_tracking.updated_at`
- Log status change if status changed
- Return updated listing

**Owner:** Backend Developer  
**Estimated Time:** 16-20 hours

---

#### 5. Backend: Error Handling & Validation
**Priority:** 🟢 **MEDIUM**

**Add:**
- Input validation (required fields, data types)
- Ownership verification (authorization)
- Error responses (400, 401, 403, 404, 500)
- Logging (errors, status changes)

**Owner:** Backend Developer  
**Estimated Time:** 4-6 hours

---

### Phase 1 Deliverables

- [ ] Database tables created and verified
- [ ] `PlsController` skeleton created
- [ ] `PlsService` skeleton created
- [ ] Basic CRUD operations working
- [ ] API endpoints tested via Postman
- [ ] Error handling in place

**Total Estimated Time:** 32-44 hours (1-2 weeks)

---

## 📋 SUBSEQUENT PHASES (After Phase 1)

### Phase 2: Data Pre-Population (Week 3-4)
- TitleData query service
- Historical MLS query service
- Conflict resolution logic
- Pre-population API endpoint
- Frontend: Create form with pre-population

### Phase 3: Photo Upload (Week 5)
- S3 upload service
- Photo upload API
- Frontend: Drag-and-drop uploader

### Phase 4: XML Generation (Week 6-7)
- XML generation service
- GenieCloud API integration
- Render status polling

### Phase 5: UI Completion (Week 8-9)
- Angular components
- Routing
- Form validation
- Permission checks

### Phase 6: AI Integration (Week 10)
- Paisley AI API integration
- Description generation

### Phase 7: Listing Command Integration (Week 11)
- ListingCommandQueue integration
- Campaign initiation

### Phase 8: Testing & Polish (Week 12)
- End-to-end testing
- Bug fixes
- Performance optimization

---

## 🚨 CRITICAL NOTES

### MlsID Change
- **Blueprint says:** `MlsID = 999`
- **v3.0 Schema uses:** `MlsID = 777`
- **Action Required:** Update blueprint references OR verify which ID to use

### Data Type Consistency
- `AspNetUsers.Id` = `NVARCHAR(450)` (ASP.NET Core standard)
- All FK references must match this

### Cross-Database Foreign Keys
- SQL Server doesn't support cross-database FKs
- Application layer must validate `listing_id` exists before INSERT
- Consider creating validation stored procedures

### Permissions
- Verify `PermissionType` table structure before executing master data script
- May need to adjust inserts based on actual schema

---

## 📚 REFERENCE DOCUMENTS

- **Project Blueprint:** `PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.2.md`
- **Database Schema:** `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql`
- **API Design:** See blueprint Section 9
- **UI Design:** See blueprint Section 10
- **3-Layer Gap Analysis:** `PLS_3_LAYER_GAP_ANALYSIS_v1.md`

---

## 🎯 IMMEDIATE ACTION ITEMS

1. **DBA:** Execute database scripts (4 files)
2. **Backend:** Create `PlsController` skeleton
3. **Backend:** Create `PlsService` skeleton
4. **Backend:** Implement POST /api/pls/create
5. **Backend:** Implement GET /api/pls/my-listings
6. **Backend:** Test endpoints via Postman

**Start with:** Database execution (DBA task) - everything else depends on this.

---

**Change Log:**
- **v3.0 (01/05/2026):** Created after database schema completion, aligned with Phase 1 of blueprint

