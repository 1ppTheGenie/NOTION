# TheGenie.ai - Role & Permission System
# Complete Framework Documentation

**Version:** 1.0  
**Created:** December 28, 2025  
**Author:** Cursor AI  
**Purpose:** Comprehensive guide for implementing permission-protected features in the Genie Dashboard

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Database Schema](#3-database-schema)
4. [Role Types (Complete List)](#4-role-types-complete-list)
5. [Permission Types (Complete List)](#5-permission-types-complete-list)
6. [How Permissions Are Checked](#6-how-permissions-are-checked)
7. [Frontend Implementation](#7-frontend-implementation)
8. [Backend Implementation](#8-backend-implementation)
9. [Step-by-Step: Adding a New Permission](#9-step-by-step-adding-a-new-permission)
10. [Step-by-Step: Protecting a New Admin Tab](#10-step-by-step-protecting-a-new-admin-tab)
11. [Admin UI for Managing Permissions](#11-admin-ui-for-managing-permissions)
12. [Examples from Existing Features](#12-examples-from-existing-features)
13. [Quick Reference for Credit Card Dispute Feature](#13-quick-reference-for-credit-card-dispute-feature)

---

## 1. EXECUTIVE SUMMARY

The Genie Dashboard uses a **Role-Based Access Control (RBAC)** system with the following key concepts:

| Concept | Description |
|---------|-------------|
| **User** | Has one Role (via AspNetUserRoles) |
| **Role** | Has many Permissions (via RolePermission) |
| **Permission** | Grants access to a specific feature/action |
| **Custom Permission** | Individual user override (UserCustomPermission) |

### Flow Diagram
```
User Login
    ↓
Load User's Role (AspNetUserRoles)
    ↓
Load Role's Permissions (RolePermission)
    ↓
Merge Custom Permissions (UserCustomPermission)
    ↓
Store in Frontend (PermissionType[] array)
    ↓
Check hasPermission(PermissionType.X) before showing features
```

### Key Files for Implementation

| Layer | File | Purpose |
|-------|------|---------|
| **Frontend Enum** | `Smart.NG.Agent/src/app/models/permission.model.ts` | TypeScript enum of all permissions |
| **Backend Enum** | `Smart.Model/Permission/PermissionType.cs` | C# enum of all permissions |
| **Permission Service** | `Smart.NG.Agent/src/app/core/services/helper/fg-permission.service.ts` | `hasPermission()` method |
| **Route Guard** | `Smart.NG.Agent/src/app/core/services/guard/fg-permission.guard.ts` | Protects routes |
| **Database Access** | `Smart.Data/BLL/FarmGenieProxy/FarmGenieProxy.Permission.cs` | SQL queries |

---

## 2. ARCHITECTURE OVERVIEW

### 2.1 Permission Resolution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER LOGIN                                │
│                    (AspNetUserId: GUID)                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    LOOKUP USER'S ROLE                           │
│                                                                  │
│  SELECT RoleId FROM AspNetUserRoles WHERE UserId = @userId      │
│                                                                  │
│  Example: RoleId = "5" (Super User)                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                 LOOKUP ROLE PERMISSIONS                          │
│                                                                  │
│  SELECT p.PermissionID FROM Permission p                        │
│  JOIN RolePermission rp ON p.PermissionID = rp.PermissionID     │
│  WHERE rp.RoleID = @roleId                                      │
│                                                                  │
│  Result: [1, 3, 5, 13, 50, 142, 164, ...]                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│               MERGE CUSTOM USER PERMISSIONS                      │
│                                                                  │
│  SELECT PermissionId FROM UserCustomPermission                  │
│  WHERE AspNetUserId = @userId                                    │
│                                                                  │
│  Union with role permissions for final list                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              FRONTEND STORES PERMISSIONS                         │
│                                                                  │
│  permissions: PermissionType[] = [1, 3, 5, 13, 50, 142, ...]   │
│                                                                  │
│  Stored in localStorage and service                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  UI CHECKS PERMISSION                            │
│                                                                  │
│  if (permissionService.hasPermission(PermissionType.Feature))   │
│      showFeature();                                              │
│  else                                                            │
│      hideFeature();                                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. DATABASE SCHEMA

### 3.1 Core Tables

All tables are in the `FarmGenie` database.

#### AspNetRoles
```sql
-- Role definitions
CREATE TABLE AspNetRoles (
    Id NVARCHAR(128) PRIMARY KEY,  -- "1", "2", "5", etc.
    Name NVARCHAR(256)              -- "Emerging Agent", "Super User", etc.
);
```

#### AspNetUserRoles
```sql
-- Links users to roles (one role per user)
CREATE TABLE AspNetUserRoles (
    UserId NVARCHAR(128),           -- FK to AspNetUsers.Id
    RoleId NVARCHAR(128),           -- FK to AspNetRoles.Id
    PRIMARY KEY (UserId, RoleId)
);
```

#### Permission
```sql
-- All available permissions in the system
CREATE TABLE Permission (
    PermissionID INT PRIMARY KEY,   -- Matches enum value
    Description NVARCHAR(255),      -- Display name (e.g., "ManageListingCommand")
    Notes NVARCHAR(MAX)             -- Detailed description
);
```

#### RolePermission
```sql
-- Links roles to permissions (many-to-many)
CREATE TABLE RolePermission (
    RoleID NVARCHAR(128),           -- FK to AspNetRoles.Id
    PermissionID INT,               -- FK to Permission.PermissionID
    PRIMARY KEY (RoleID, PermissionID)
);
```

#### UserCustomPermission
```sql
-- Individual user permission overrides
CREATE TABLE UserCustomPermission (
    AspNetUserId NVARCHAR(128),     -- FK to AspNetUsers.Id
    PermissionId INT                -- FK to Permission.PermissionID
);
```

### 3.2 Entity Relationship Diagram

```
┌──────────────────┐       ┌─────────────────────┐       ┌─────────────────┐
│   AspNetUsers    │       │   AspNetUserRoles   │       │   AspNetRoles   │
├──────────────────┤       ├─────────────────────┤       ├─────────────────┤
│ Id (PK)          │──────>│ UserId (FK)         │<──────│ Id (PK)         │
│ Email            │       │ RoleId (FK)         │       │ Name            │
│ UserName         │       └─────────────────────┘       └────────┬────────┘
└──────────────────┘                                              │
         │                                                        │
         │                                                        ▼
         │                 ┌─────────────────────┐       ┌─────────────────┐
         │                 │   RolePermission    │       │   Permission    │
         │                 ├─────────────────────┤       ├─────────────────┤
         │                 │ RoleID (FK)         │──────>│ PermissionID(PK)│
         │                 │ PermissionID (FK)   │       │ Description     │
         │                 └─────────────────────┘       │ Notes           │
         │                                               └─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  UserCustomPermission    │
├──────────────────────────┤
│ AspNetUserId (FK)        │
│ PermissionId (FK)        │──────> (overrides role permissions)
└──────────────────────────┘
```

---

## 4. ROLE TYPES (COMPLETE LIST)

From `EnumRoleType.cs`:

| RoleId | Name | Description | Typical Use |
|--------|------|-------------|-------------|
| -1 | NotSet | No role assigned | Error state |
| **1** | EmergingAgent | New agent | Free tier |
| **2** | Affiliate | Title Rep | Partner users |
| **3** | AffiliateTerritoryAdmin | Regional Title Rep Manager | Partner management |
| **4** | AffiliateAdmin | Title Rep Manager | Partner administration |
| **5** | **SuperUser** | Full admin access | **Internal staff** |
| 6 | AffiliateBetaUser | Affiliate Beta | Testing |
| 7 | Ultimate | Ultimate Agent | Premium paid tier |
| **8** | Basic (Core Agent) | Basic Agent | Paid tier |
| 9 | Lender | Lender user | Lender access |
| 10 | AgentNoAccess | Agent Invited | Pending invitation |
| 11 | UtilityUser | Utility User | Temporary/special handling |
| **12** | EstablishedAgent | Established Agent | Mid-tier agent |
| 13 | LenderNoAccess | Lender No Access | Lender pending |
| **14** | Broker | Broker | Broker role |
| 15 | BrokerNoAccess | Broker No Access | Broker pending |
| 16 | AffiliateNoAccess | Affiliate No Access | Title Rep pending |
| **17** | InternalCustomerService | Genie Customer Service | Support staff |
| **18** | BrokerAdmin | Broker Admin | Broker management |
| 19 | LenderAdmin | Lender Admin | Lender management |
| **20** | InternalSalesTeam | Genie Sales Team | Sales staff |
| 21 | UtilityAgentUser | Agent | Temporary/special |
| **22** | EliteAgent | Elite Agent | Top-tier agent |
| 23 | GenieMlsDemo | Demo user | Demos |
| 24 | DataBuyer | Data Buyer | Data purchase users |
| 25 | MarketingAffiliate | Marketing Affiliate | Marketing partners |
| 26 | MarketingAffiliateNoAccess | Marketing Affiliate (No Access) | Pending |

### SuperUser-Only Features
For the Credit Card Dispute feature, you want to restrict to **SuperUser (RoleId = 5)** only.

---

## 5. PERMISSION TYPES (COMPLETE LIST)

From `PermissionType.cs` - Current highest ID is **209**. 

### Key Admin Permissions:

| ID | Name | Description |
|----|------|-------------|
| 13 | ImpersonateUser | Impersonate other users |
| 18 | SuperAdminPowers | (DEPRECATED) |
| 50 | ManageRolePermission | Edit role permissions |
| 51 | ManageUserCustomPermission | Edit user custom permissions |
| 64 | AdminUserLookup | Search for users |
| 65 | CreditAdjust | Adjust user credits |
| 83 | AdminToolbox | Access admin toolbox |
| 96 | SAAdminMenu | SA Admin Menu |
| 97 | SAActivityMenu | SA Activity Menu |
| 99 | PermissionManagement | Manage permissions |
| 149 | UpdateOtherUsersPassword | Reset user passwords |
| 152 | ToggleUserStatus | Enable/disable users |
| 155 | AssignSuperUser | Assign SuperUser role |

### Example Feature Permissions:

| ID | Name | Description |
|----|------|-------------|
| 142 | ManageListingCommand | Submit Listing Commands |
| 164 | MenuListingCommand | See LC in menu |
| 147 | LCRadar | Admin LC radar view |
| 195 | ManageNC | Neighborhood Command |
| 193 | NCRadar | NC admin radar |

### Next Available ID: **210+**

---

## 6. HOW PERMISSIONS ARE CHECKED

### 6.1 Backend (C#)

```csharp
// FarmGenieProxy.Permission.cs
public List<Permission> GetPermissions(string aspNetUserID)
{
    // 1. Get permissions from user's role
    var rolePermissions =
    (
        from p in _context.Permissions
        join r in _context.RolePermissions on p.PermissionID equals r.PermissionID
        join u in _context.AspNetUserRoles on r.RoleID equals u.RoleId
        where u.UserId == aspNetUserID
        select p
    ).Distinct().ToList();

    // 2. Get custom permissions for this specific user
    var customPermissions =
    (
        from p in _context.Permissions
        join c in _context.UserCustomPermissions on p.PermissionID equals c.PermissionId
        where c.AspNetUserId == aspNetUserID
        select p
    ).Distinct().ToList();

    // 3. Merge them
    if (customPermissions != null && customPermissions.Count > 0)
    {
        rolePermissions = rolePermissions.Union(customPermissions).ToList();
    }

    return rolePermissions;
}
```

### 6.2 Frontend (TypeScript)

```typescript
// fg-permission.service.ts
hasPermission(permissionToCheck: PermissionType): boolean {
    if (!this.permissionsLoaded) {
        return this.checkLocalStorage(permissionToCheck);
    }

    if (!this.permissions) {
        return false;
    }

    // permissions is an array of PermissionType enum values
    return this.permissions.indexOf(permissionToCheck) > -1;
}
```

---

## 7. FRONTEND IMPLEMENTATION

### 7.1 The Permission Enum (TypeScript)

Location: `Smart.NG.Agent/src/app/models/permission.model.ts`

```typescript
export enum PermissionType {
    CreateUser = 1,
    AssignRole = 2,
    Dashboard = 3,
    // ... hundreds more ...
    ManageListingCommand = 142,
    LCRadar = 147,
    // ADD YOUR NEW PERMISSION HERE:
    ManageDisputeGeneration = 210  // Example for new feature
}
```

### 7.2 The Permission Service

Location: `Smart.NG.Agent/src/app/core/services/helper/fg-permission.service.ts`

**Usage in Components:**

```typescript
import { FgPermissionService } from '../../core/services/helper/fg-permission.service';
import { PermissionType } from '../../models/permission.model';

@Component({...})
export class MyComponent {
    canAccessDispute = false;

    constructor(private permissionService: FgPermissionService) {
        this.canAccessDispute = this.permissionService.hasPermission(
            PermissionType.ManageDisputeGeneration
        );
    }
}
```

**Usage in Templates:**

```html
<div *ngIf="canAccessDispute">
    <button>Generate Dispute</button>
</div>
```

### 7.3 The Route Guard

Location: `Smart.NG.Agent/src/app/core/services/guard/fg-permission.guard.ts`

**How it works:**
1. Route config specifies `data: { permissions: [PermissionType.X] }`
2. Guard reads the permission from route data
3. Checks if user has that permission
4. Allows or redirects

---

## 8. BACKEND IMPLEMENTATION

### 8.1 The Permission Enum (C#)

Location: `Smart.Model/Permission/PermissionType.cs`

```csharp
public enum PermissionType
{
    NotSet = -1,
    CreateUser = 1,
    AssignRole = 2,
    // ... hundreds more ...
    ManageListingCommand = 142,
    LCRadar = 147,
    // ADD YOUR NEW PERMISSION HERE:
    ManageDisputeGeneration = 210  // Example for new feature
}
```

### 8.2 Checking Permission in Controllers

```csharp
// Example: Only allow if user has permission
public ActionResult GenerateDispute(string userId)
{
    var permissions = GetUserPermissions(userId);
    
    if (!permissions.Any(p => p.PermissionID == (int)PermissionType.ManageDisputeGeneration))
    {
        return Unauthorized();
    }
    
    // ... proceed with feature ...
}
```

---

## 9. STEP-BY-STEP: ADDING A NEW PERMISSION

### Step 1: Choose a Permission ID

Look at the highest current ID in `PermissionType.cs` (currently 209). Use the next number.

**For Credit Card Dispute:** Use **210**

### Step 2: Add to Database

```sql
-- Run this on FarmGenie database
INSERT INTO FarmGenie.dbo.Permission (PermissionID, Description, Notes) 
VALUES (210, 'ManageDisputeGeneration', 'Admin - Generate credit card dispute documents');
```

### Step 3: Add to C# Enum

Location: `Smart.Model/Permission/PermissionType.cs`

```csharp
// Add at the end of the enum, before the closing brace
ManageDisputeGeneration = 210
```

### Step 4: Add to TypeScript Enum

Location: `Smart.NG.Agent/src/app/models/permission.model.ts`

```typescript
// Add at the end of the enum
ManageDisputeGeneration = 210
```

### Step 5: Assign Permission to SuperUser Role

```sql
-- Give SuperUsers this permission
INSERT INTO FarmGenie.dbo.RolePermission (RoleID, PermissionID)
VALUES ('5', 210);  -- '5' is SuperUser
```

**Or use the Admin UI:** Navigate to `/admin/permission`, select "Super User" role, toggle on your new permission.

---

## 10. STEP-BY-STEP: PROTECTING A NEW ADMIN TAB

### Example: Adding "Dispute Generation" Tab to Admin Section

### Step 1: Create the Component

```typescript
// dispute-generation.component.ts
import { Component, OnInit } from '@angular/core';
import { FgPermissionService } from '../../../core/services/helper/fg-permission.service';
import { PermissionType } from '../../../models/permission.model';

@Component({
    selector: 'app-dispute-generation',
    templateUrl: './dispute-generation.component.html'
})
export class DisputeGenerationComponent implements OnInit {
    constructor(private permissionService: FgPermissionService) {}
    
    ngOnInit() {
        // Component logic here
    }
}
```

### Step 2: Add Route with Permission Guard

```typescript
// admin.routing.ts (or wherever your admin routes are)
import { FgPermissionGuard } from '../../core/services/guard/fg-permission.guard';
import { PermissionType } from '../../models/permission.model';
import { DisputeGenerationComponent } from './dispute-generation/dispute-generation.component';

const routes: Routes = [
    // ... other admin routes ...
    {
        path: 'dispute-generation',
        canActivate: [FgPermissionGuard],
        component: DisputeGenerationComponent,
        data: {
            title: 'TheGenie.ai | Dispute Generation',
            permissions: [PermissionType.ManageDisputeGeneration]
        }
    }
];
```

### Step 3: Add Menu Item (Conditional)

```typescript
// In your sidebar or navigation component
import { PermissionType } from '../../../models/permission.model';

export class SidebarComponent {
    showDisputeTab = false;
    
    constructor(private permissionService: FgPermissionService) {
        this.showDisputeTab = this.permissionService.hasPermission(
            PermissionType.ManageDisputeGeneration
        );
    }
}
```

```html
<!-- sidebar.component.html -->
<li *ngIf="showDisputeTab">
    <a routerLink="/admin/dispute-generation">
        <i class="fa fa-credit-card"></i>
        <span>Dispute Generation</span>
    </a>
</li>
```

---

## 11. ADMIN UI FOR MANAGING PERMISSIONS

### Location
Dashboard URL: `/admin/permission`

### How It Works
1. Select a Role from dropdown
2. See all available permissions as toggles
3. Toggle ON = INSERT into RolePermission
4. Toggle OFF = DELETE from RolePermission

### Source Code
- `Smart.NG.Agent/src/app/pages/admin/permission/permission.component.ts`
- `Smart.NG.Agent/src/app/pages/admin/permission/permission.component.html`

### Clone Feature
The UI also supports cloning all permissions from one role to another:
- Select "From Role"
- Select "To Role"
- Click "Clone"

---

## 12. EXAMPLES FROM EXISTING FEATURES

### Example 1: Listing Command Protection

**Route:**
```typescript
{
    path: '',
    canActivate: [FgPermissionGuard],
    component: ListingCommandWizardWrapperComponent,
    data: { 
        title: 'TheGenie.ai | Listing Command',
        permissions: [PermissionType.ManageListingCommand]  // ID 142
    }
}
```

### Example 2: Admin Radar (Multiple Permissions)

```typescript
// A component that requires LCRadar permission (ID 147)
this.hasRadarPermission = this.permissionService.hasPermission(
    PermissionType.LCRadar
);
```

### Example 3: Conditional Button in Template

```html
<button 
    *ngIf="permissionService.hasPermission(permissionTypes.ListingCommandForceRun)"
    (click)="forceRun()">
    Force Run
</button>
```

---

## 13. QUICK REFERENCE FOR CREDIT CARD DISPUTE FEATURE

### Summary: What You Need To Do

| Step | Action | Location |
|------|--------|----------|
| 1 | Add Permission to DB | SQL: `INSERT INTO Permission (210, 'ManageDisputeGeneration', '...')` |
| 2 | Add to C# Enum | `Smart.Model/Permission/PermissionType.cs` |
| 3 | Add to TS Enum | `Smart.NG.Agent/src/app/models/permission.model.ts` |
| 4 | Assign to SuperUser | SQL: `INSERT INTO RolePermission ('5', 210)` |
| 5 | Create Component | `dispute-generation.component.ts` |
| 6 | Add Protected Route | Use `FgPermissionGuard` with `data.permissions` |
| 7 | Add Menu Item | Use `*ngIf="hasPermission"` |

### SQL Script (Ready to Run)

```sql
-- Step 1: Add the permission
INSERT INTO FarmGenie.dbo.Permission (PermissionID, Description, Notes) 
VALUES (210, 'ManageDisputeGeneration', 'Admin - Generate credit card dispute documents for WHMCS transactions');

-- Step 2: Assign to SuperUser role only
INSERT INTO FarmGenie.dbo.RolePermission (RoleID, PermissionID)
VALUES ('5', 210);

-- Verify
SELECT * FROM FarmGenie.dbo.Permission WHERE PermissionID = 210;
SELECT * FROM FarmGenie.dbo.RolePermission WHERE PermissionID = 210;
```

### TypeScript Additions

```typescript
// permission.model.ts - add to enum
ManageDisputeGeneration = 210

// In your component
import { PermissionType } from '../../models/permission.model';

canAccessDispute = this.permissionService.hasPermission(PermissionType.ManageDisputeGeneration);
```

### Route Configuration

```typescript
{
    path: 'dispute-generation',
    canActivate: [FgPermissionGuard],
    component: DisputeGenerationComponent,
    data: {
        title: 'TheGenie.ai | Dispute Generation',
        permissions: [PermissionType.ManageDisputeGeneration]
    }
}
```

---

## CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/28/2025 | Cursor AI | Initial comprehensive documentation |

---

*This document provides everything needed to implement permission-protected features in the Genie Dashboard.*

