# PLS Permission & Role Integration
**Version:** 1.0  
**Created:** 01/09/2026  
**Last Updated:** 01/09/2026  
**Author:** Danny (Dev Lead)  
**Status:** ✅ Complete Integration Specification

## Overview

**PLS is a NEW SERVICE** added to the TheGenie.ai permission system, following the same patterns as existing services like **Listing Command** and **Neighborhood Command**. This document specifies how PLS integrates with the role-based permission system.

## Service Architecture Pattern

### Existing Services (Reference)
- **Listing Command** - PropertyCastTypeId=1, uses Permission table for access control
- **Neighborhood Command** - Uses Permission table for access control
- **PLS** - PropertyCastTypeId=4, uses Permission table for access control (NEW SERVICE)

### Common Pattern
All services follow the same pattern:
1. **Permission-based access control** via `FarmGenie.dbo.Permission` table
2. **Role-based features** - Features accessible based on user's role permissions
3. **Stored procedures** for database operations (thread-safe, audit trail)
4. **SmartAuthorize attributes** on controllers for authorization
5. **Ownership tracking** for user-specific data access

## PLS Permissions (NEW)

### Permission Types

| PermissionTypeId | Name | Description | Required Role |
|-------------------|------|-------------|---------------|
| **210** | `ManagePLS` | Create/edit/delete PLS listings | Elite Agent, Ultimate Agent, Super User |
| **211** | `MenuPLS` | Access PLS menu item | All agents with PLS access |
| **212** | `ViewPLSHistory` | View status log/audit trail | Elite Agent, Ultimate Agent, Super User |
| **213** | `PLSRadar` | View all PLS listings across all users (admin) | Super User, Admin |
| **214** | `PLSSubmitWhileImpersonating` | Create/edit listings for other users | Admin only |

### Permission Assignment by Role

| Role | Permissions | Can Create/Edit | Can View All | Can Impersonate |
|------|------------|-----------------|--------------|-----------------|
| **Affiliate Agent** | 211 (Menu PLS) | ❌ No | ❌ No | ❌ No |
| **Core Agent** | 211 (Menu PLS) | ❌ No | ❌ No | ❌ No |
| **Elite Agent** | 210, 211, 212 | ✅ Own listings | ❌ No | ❌ No |
| **Ultimate Agent** | 210, 211, 212 | ✅ Own listings | ❌ No | ❌ No |
| **Super User** | 210, 211, 212, 213 | ✅ Own listings | ✅ Yes (PLS Radar) | ❌ No |
| **Admin** | 210, 211, 212, 213, 214 | ✅ All listings | ✅ Yes (PLS Radar) | ✅ Yes |
| **Title Rep** | 211 (via Title Partner permission) | ❌ No (unless granted 210) | ❌ No | ❌ No |

## Controller Authorization Pattern

### Following Listing Command Pattern

```csharp
[ApiController]
[Route("api/pls")]
[SmartAuthorize(PermissionType.MenuPLS)]  // Base permission for all endpoints
public class PlsController : ControllerBase
{
    // Create/Edit endpoints require ManagePLS permission
    [HttpPost("create")]
    [SmartAuthorize(PermissionType.ManagePLS)]  // Requires Permission 210
    public async Task<IActionResult> CreateListing(...)
    
    // View endpoints use base permission
    [HttpGet("my-listings")]
    [SmartAuthorize(PermissionType.MenuPLS)]  // Requires Permission 211
    public async Task<IActionResult> GetMyListings()
    
    // Admin endpoints require PLS Radar permission
    [HttpGet("radar")]
    [SmartAuthorize(PermissionType.PLSRadar)]  // Requires Permission 213
    public async Task<IActionResult> GetAllListings()
}
```

## Stored Procedures Pattern

### Following Listing Command Stored Procedure Pattern

**Pattern:**
- Thread-safe operations (transactions with UPDLOCK)
- Complete audit trail (status log)
- Permission-aware queries (ownership checks)
- Consistent error handling
- Output parameters for results

**PLS Stored Procedures:**
1. `usp_CreatePlsListing` - Create listing with full workflow (like Listing Command creation)
2. `usp_UpdatePlsStatus` - Update status with audit trail
3. `usp_GetPlsListingDetails` - Get complete listing (permission-aware)
4. `usp_GetPlsListingsByUser` - Get user listings (with permission check)
5. `usp_QueuePlsListingCommand` - Queue for Listing Command workflow (identical pattern)

## Detailed Workflow Steps

### Complete End-to-End Workflow (Following Service Patterns)

#### Phase 1: Paisley Pre-Listing Focus (Entry Point)
1. **User navigates** to "Pre-Listing" menu (Permission 211 required)
2. **System checks permission:** `[SmartAuthorize(PermissionType.MenuPLS)]`
3. **User enters address** → `POST /api/Data/AutoCompleteAddress`
4. **User selects address** → `POST /api/Data/GetPropertiesFromPlaceKey`
   - Google Places Details API
   - TitleData lookup (AttomDataAssessor)
   - Historical MLS lookup (conflict detection)
5. **System auto-fetches areas** → `POST /api/Data/GetAreaList`
6. **User selects area** → Stored for Listing Command integration

#### Phase 2: Property Pre-Population
7. **System pre-populates** property form from TitleData/MLS
8. **System flags conflicts** (sqft, beds/baths differences)
9. **User reviews** pre-populated data, resolves conflicts

#### Phase 3: Auto-Generated Content (v1.12 Workflow)
10. **System auto-generates:**
    - Mapbox satellite photo → `POST /api/pls/generate-mapbox-photo`
    - Paisley description → `POST /api/pls/generate-description` (ChatStartTypeId=3)
11. **Combined UI displays:**
    - Mapbox photo (with property boundary)
    - Paisley description (with "Edit" button)
    - "Load Photos" button (optional)

#### Phase 4: Listing Creation
12. **User completes form** (price, status, optional photos)
13. **User clicks "Save & Generate Content Kit"**
14. **System validates permission:** `[SmartAuthorize(PermissionType.ManagePLS)]`
15. **System calls stored procedure:** `usp_CreatePlsListing`
    - Generates PLS number (usp_GetNextPlsNumber)
    - INSERT into MlsListing.dbo.Listing (MlsID=777, PropertyCastTypeId=4)
    - INSERT into MlsListing.dbo.Photo (Mapbox photo + user photos)
    - INSERT into pls_tracking (status='draft', source='paisley')
    - INSERT into pls_status_log (initial status)
    - INSERT into PlsListingOwnership (OwnershipTypeId=1, Creator)
    - INSERT into ListingCommandQueue (if area selected and status active/coming_soon)
16. **System returns** PLS number (e.g., PLS100001A)

#### Phase 5: XML Generation & GenieCloud Render
17. **System generates XML** per Contract v6.1
18. **System POSTs to GenieCloud** API
19. **System updates** pls_tracking status to 'active' or 'coming_soon'
20. **System logs** status change in pls_status_log

#### Phase 6: Listing Command Integration
21. **Listing Command service** processes queue (PropertyCastTypeId=4)
22. **Circle prospecting** automation (SMS to farm area)
23. **Engagement Center** captures leads
24. **Versium** data append (automatic)

## Role-Based Feature Access

### Listing Agent (Permission 210)
**Features Accessible:**
- ✅ Create PLS listings
- ✅ Edit own listings
- ✅ View own listings
- ✅ Generate content kit
- ✅ Start Listing Command campaign
- ✅ View status log for own listings
- ❌ View all users' listings
- ❌ Impersonate other users

### Title Rep (Permission 211 via Title Partner)
**Features Accessible:**
- ✅ View agent's listings (account-level access)
- ✅ View listing details (read-only)
- ✅ View GenieCloud collection URLs
- ✅ View Listing Command campaign status
- ❌ Create/edit listings (unless granted Permission 210)
- ❌ View all users' listings

### Super User Admin (Permission 213)
**Features Accessible:**
- ✅ View all PLS listings (PLS Radar)
- ✅ View system-wide statistics
- ✅ View complete audit trail
- ✅ Create/edit own listings (Permission 210)
- ❌ Impersonate other users (requires Permission 214)

### Admin (Permission 213 + 214)
**Features Accessible:**
- ✅ All Super User features
- ✅ Create/edit listings for any user (impersonation)
- ✅ Change any listing's status
- ✅ Full system access

## Database Integration

### Permission Table Integration

```sql
-- Grant PLS permissions to roles
INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
SELECT u.Id, 210  -- ManagePLS
FROM dbo.AspNetUsers u
INNER JOIN dbo.AspNetUserRoles ur ON ur.UserId = u.Id
INNER JOIN dbo.AspNetRoles r ON r.Id = ur.RoleId
WHERE r.Name IN ('Elite Agent', 'Ultimate Agent', 'Super User', 'Admin');

INSERT INTO FarmGenie.dbo.Permission (UserId, PermissionTypeId)
SELECT u.Id, 211  -- Menu PLS
FROM dbo.AspNetUsers u
INNER JOIN dbo.AspNetUserRoles ur ON ur.UserId = u.Id
INNER JOIN dbo.AspNetRoles r ON r.Id = ur.RoleId
WHERE r.Name IN ('Affiliate Agent', 'Core Agent', 'Elite Agent', 'Ultimate Agent', 'Super User', 'Admin');
```

### Ownership Verification Pattern

```sql
-- Verify ownership (following Listing Command pattern)
SELECT COUNT(*)
FROM dbo.pls_tracking pt
WHERE pt.listing_id = @ListingId
  AND pt.agent_id = @AspNetUserId

-- OR admin permission check
SELECT COUNT(*)
FROM dbo.Permission p
INNER JOIN dbo.PermissionType pt ON pt.PermissionTypeId = p.PermissionTypeId
WHERE p.UserId = @AspNetUserId
  AND pt.PermissionTypeId IN (213, 214)  -- PLS Radar or Impersonate
```

## Code Consistency with Existing Services

### Controller Pattern (Following Listing Command)
- ✅ `[SmartAuthorize]` attributes on controller and methods
- ✅ Permission checks in business logic
- ✅ Ownership verification before updates
- ✅ Stored procedure calls for database operations
- ✅ Consistent error handling

### Stored Procedure Pattern (Following Listing Command)
- ✅ Thread-safe transactions (UPDLOCK, ROWLOCK)
- ✅ Output parameters for results
- ✅ Error handling with TRY/CATCH
- ✅ Audit trail logging
- ✅ Permission-aware queries

### Service Integration Pattern
- ✅ PropertyCastTypeId=4 for Listing Command integration
- ✅ Reuse existing ListingCommandQueue table
- ✅ Reuse existing ListingCommandInitiateComponent UI
- ✅ Same workflow as Listing Command (circle prospecting, SMS, lead capture)

## Implementation Checklist

### Permission Setup
- [ ] Insert PermissionType 210-214 into PermissionType table
- [ ] Grant Permission 210 to Elite Agent, Ultimate Agent, Super User, Admin roles
- [ ] Grant Permission 211 to all agent roles
- [ ] Grant Permission 212 to Elite Agent, Ultimate Agent, Super User, Admin roles
- [ ] Grant Permission 213 to Super User, Admin roles
- [ ] Grant Permission 214 to Admin role only

### Controller Implementation
- [ ] Add `[SmartAuthorize]` attributes to PlsController
- [ ] Implement permission checks in business logic
- [ ] Implement ownership verification
- [ ] Follow Listing Command controller patterns

### Stored Procedures
- [ ] Create `usp_CreatePlsListing` (following Listing Command pattern)
- [ ] Create `usp_UpdatePlsStatus` (with audit trail)
- [ ] Create `usp_GetPlsListingDetails` (permission-aware)
- [ ] Create `usp_GetPlsListingsByUser` (with permission check)
- [ ] Create `usp_QueuePlsListingCommand` (identical to Listing Command)

### Testing
- [ ] Test permission enforcement (users without Permission 210 cannot create)
- [ ] Test ownership verification (users can only edit own listings)
- [ ] Test admin access (Permission 213 can view all)
- [ ] Test impersonation (Permission 214 can create for others)
- [ ] Test Title Rep access (account-level, not listing-specific)

---

**Key Point:** PLS is a NEW SERVICE that integrates into the existing permission system, following the same patterns as Listing Command and Neighborhood Command. All access is controlled via the Permission table, and features are accessible based on role permissions.
