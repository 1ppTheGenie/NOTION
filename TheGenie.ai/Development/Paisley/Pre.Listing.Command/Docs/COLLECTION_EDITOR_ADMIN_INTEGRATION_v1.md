# Collection Editor - Admin Integration Plan

**Version:** 1.0  
**Created:** 12/28/2025  
**Author:** Steve Hundley / Cursor AI  
**Status:** READY FOR IMPLEMENTATION

---

## EXECUTIVE SUMMARY

This document outlines the **iteration path** to get John's Collection Editor working as an **admin-only tool** in the Genie Dashboard. The approach is designed for progressive enhancement - start simple, add security layers iteratively.

---

## 🎯 ITERATION PATH

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COLLECTION EDITOR INTEGRATION ROADMAP                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: FIX & DEPLOY (30 min)          ████████████░░░░░░░░  Done!        │
│  ├── Fix genie-monitor build path bug                                       │
│  ├── Rebuild collection-editor                                              │
│  └── Deploy to production CDN                                               │
│                                                                              │
│  PHASE 2: ADMIN IFRAME (2-4 hrs)         ░░░░░░░░░░░░░░░░░░░░  Next         │
│  ├── Create Angular route /admin/collections                                │
│  ├── Add permission guard (SuperUser only)                                  │
│  └── Embed via iframe                                                       │
│                                                                              │
│  PHASE 3: API AUTH (4-8 hrs)             ░░░░░░░░░░░░░░░░░░░░  Later        │
│  ├── Add userId to API calls                                                │
│  ├── Verify permission server-side                                          │
│  └── Add audit logging                                                      │
│                                                                              │
│  PHASE 4: FULL INTEGRATION (1-2 weeks)   ░░░░░░░░░░░░░░░░░░░░  Future       │
│  ├── Port SolidJS → React (or Angular)                                      │
│  ├── Native Dashboard component                                             │
│  └── User-specific collection overrides                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## PHASE 1: FIX & DEPLOY ✅

### Bug Fix Applied

**File:** `genie-monitor/vite.config.mjs`

```diff
- const __BASE__ = process.env.NODE_ENV === "production"
-     ? "/genie-tools/collection-editor/"
+ const __BASE__ = process.env.NODE_ENV === "production"
+     ? "/genie-tools/monitor/"  // FIXED

- outDir: `../public/genie-tools/collection-editor/`,
+ outDir: `../public/genie-tools/monitor/`,  // FIXED
```

### Deployment Steps (GenieCloud Team)

```bash
# 1. Pull the fix
cd stage.geniecloud
git pull

# 2. Rebuild collection-editor
cd genie-collection-editor
npm install
npm run build

# 3. Verify output
ls ../public/genie-tools/collection-editor/
# Should show: assets/, index.html

# 4. Deploy to S3/CDN
# (Use your normal deployment process)

# 5. Verify production URL works
# https://cloud.thegenie.ai/genie-tools/collection-editor/
```

---

## PHASE 2: ADMIN IFRAME INTEGRATION

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ADMIN-ONLY ACCESS PATTERN                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   User Request                                                               │
│       │                                                                      │
│       ▼                                                                      │
│   Angular Router (/admin/collections)                                        │
│       │                                                                      │
│       ▼                                                                      │
│   FgPermissionGuard                                                          │
│       │                                                                      │
│       ├── Check: User has SuperUser (5) OR GenieBizAdmin (28)?              │
│       │                                                                      │
│       ├── NO  → Redirect to /dashboard (403)                                │
│       │                                                                      │
│       └── YES → Load CollectionEditorComponent                              │
│                     │                                                        │
│                     ▼                                                        │
│               <iframe src="cloud.thegenie.ai/genie-tools/collection-editor/">│
│                                                                              │
│   ⚠️ SECURITY NOTE:                                                          │
│   The iframe is protected by Angular route guard.                           │
│   The underlying URL is still public (Phase 3 fixes this).                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation Files

#### 1. Create Route Module

**File:** `src/app/admin/collection-editor/collection-editor.module.ts`

```typescript
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { CollectionEditorComponent } from './collection-editor.component';
import { FgPermissionGuard } from '@shared/guards/fg-permission.guard';
import { PermissionType } from '@shared/enums/permission-type.enum';

const routes: Routes = [
  {
    path: '',
    component: CollectionEditorComponent,
    canActivate: [FgPermissionGuard],
    data: {
      // ADMIN ONLY: Require SuperUser OR GenieBizAdmin
      permissions: [PermissionType.SuperUser],  // Adjust based on your enum
      anyPermission: true
    }
  }
];

@NgModule({
  declarations: [CollectionEditorComponent],
  imports: [
    CommonModule,
    RouterModule.forChild(routes)
  ]
})
export class CollectionEditorModule { }
```

#### 2. Create Component

**File:** `src/app/admin/collection-editor/collection-editor.component.ts`

```typescript
import { Component, OnInit } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { environment } from '@environments/environment';

@Component({
  selector: 'app-collection-editor',
  template: `
    <div class="collection-editor-container">
      <div class="header">
        <h1>Collection Editor</h1>
        <span class="admin-badge">ADMIN ONLY</span>
      </div>
      
      <div class="iframe-wrapper">
        <iframe 
          [src]="editorUrl" 
          frameborder="0"
          allowfullscreen>
        </iframe>
      </div>
      
      <div class="footer-warning">
        ⚠️ Changes made here affect ALL users. Use with caution.
      </div>
    </div>
  `,
  styles: [`
    .collection-editor-container {
      height: calc(100vh - 60px);
      display: flex;
      flex-direction: column;
    }
    
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1rem 2rem;
      background: #1a1a2e;
      color: white;
    }
    
    .header h1 {
      margin: 0;
      font-size: 1.5rem;
    }
    
    .admin-badge {
      background: #dc3545;
      color: white;
      padding: 0.25rem 0.75rem;
      border-radius: 4px;
      font-size: 0.75rem;
      font-weight: bold;
    }
    
    .iframe-wrapper {
      flex: 1;
      position: relative;
    }
    
    .iframe-wrapper iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
    
    .footer-warning {
      padding: 0.5rem 1rem;
      background: #fff3cd;
      color: #856404;
      text-align: center;
      font-size: 0.875rem;
    }
  `]
})
export class CollectionEditorComponent implements OnInit {
  editorUrl: SafeResourceUrl;
  
  // Use production GenieCloud URL after Phase 1 deployment
  private readonly EDITOR_URL = 'https://cloud.thegenie.ai/genie-tools/collection-editor/';
  
  // Fallback to Amplify if production not ready
  private readonly FALLBACK_URL = 'https://main.d2jn91nws05uwp.amplifyapp.com/collections';
  
  constructor(private sanitizer: DomSanitizer) {}
  
  ngOnInit(): void {
    // Use production URL (change to FALLBACK_URL if needed during testing)
    this.editorUrl = this.sanitizer.bypassSecurityTrustResourceUrl(this.EDITOR_URL);
  }
}
```

#### 3. Add to Admin Routes

**File:** `src/app/admin/admin-routing.module.ts` (or equivalent)

```typescript
const routes: Routes = [
  // ... existing admin routes
  
  {
    path: 'collections',
    loadChildren: () => import('./collection-editor/collection-editor.module')
      .then(m => m.CollectionEditorModule),
    data: { title: 'Collection Editor' }
  }
];
```

#### 4. Add Menu Item (Admin Section Only)

**File:** `src/app/shared/components/sidebar/sidebar.component.html`

```html
<!-- Only show for admin roles -->
<ng-container *ngIf="hasPermission(PermissionType.SuperUser) || hasPermission(PermissionType.GenieBizAdmin)">
  <li class="nav-item">
    <a routerLink="/admin/collections" routerLinkActive="active">
      <i class="fa fa-cubes"></i>
      <span>Collection Editor</span>
      <span class="badge badge-danger">ADMIN</span>
    </a>
  </li>
</ng-container>
```

### Permissions Required

| RoleId | Role Name | Has Access |
|:------:|-----------|:----------:|
| 5 | Super User | ✅ |
| 28 | Genie Business Admin | ✅ |
| 29 | Genie Customer Service Admin | ✅ (optional) |
| 17 | Genie Customer Service | ❌ |
| * | All Other Roles | ❌ |

---

## PHASE 3: API-LEVEL AUTHENTICATION

### Why This Matters

Phase 2 protects the **Angular route**, but the underlying URLs are still public:
- `cloud.thegenie.ai/genie-tools/collection-editor/` - Anyone can visit
- Lambda API endpoints - No auth verification

Phase 3 adds **server-side protection**.

### Implementation Steps

#### 1. Modify Collection Editor to Pass User Context

**File:** `genie-collection-editor/src/utilities/state.js`

```javascript
async function apiCall(endpoint, data = null, method = "POST") {
    const url = `${settings.endpoint}${endpoint}`;
    
    const headers = new Headers();
    headers.append("Content-Type", "application/json");
    headers.append("Accept", "application/json");
    
    // NEW: Get user context from parent window (when in iframe)
    let userId = null;
    try {
        userId = window.parent?.genieAuth?.userId || null;
    } catch (e) {
        // Cross-origin - use postMessage instead
        console.warn('Could not access parent auth context');
    }
    
    const args = {
        method: method,
        mode: "cors",
        cache: "no-cache",
        headers: headers,
        referrerPolicy: "no-referrer",
    };
    
    if (method === "POST") {
        // Include userId in all requests
        const payload = data ? { ...data, userId } : { userId };
        args.body = JSON.stringify(payload);
    }
    
    const response = await fetch(url, args);
    return response.json();
}
```

#### 2. Add Permission Check to API

**File:** `genie-api/src/utils/cloudHubAPI.js`

```javascript
import { getUser } from './../genieAI.js';

// Admin-only permission IDs
const ADMIN_PERMISSIONS = [
    'SuperUser',           // Permission 5
    'GenieBizAdmin',       // Permission 28
    'ManageCollections'    // Permission 220 (new)
];

const hasAdminAccess = (user) => {
    if (!user || !user.permissions) return false;
    return ADMIN_PERMISSIONS.some(p => user.permissions.includes(p));
};

export const cloudHubAPI = async (route, params) => {
    // Routes that require admin access
    const adminRoutes = ['get-collections', 'save-collection', 'get-assets'];
    
    if (adminRoutes.includes(route)) {
        if (!params.userId) {
            return { error: true, code: 'AUTH_REQUIRED', message: 'User ID required' };
        }
        
        const user = await getUser(params.userId);
        if (!hasAdminAccess(user)) {
            return { error: true, code: 'FORBIDDEN', message: 'Admin access required' };
        }
        
        // Log admin action for audit
        console.log(`[AUDIT] ${route} by user ${params.userId} at ${new Date().toISOString()}`);
    }
    
    // ... rest of existing switch/case logic
};
```

#### 3. Add Audit Logging (Optional but Recommended)

```javascript
// Log to S3 for audit trail
const logAdminAction = async (action, userId, details) => {
    const logEntry = {
        timestamp: new Date().toISOString(),
        action,
        userId,
        details
    };
    
    await toS3(
        `_audit/collection-editor/${new Date().toISOString().split('T')[0]}/${Date.now()}.json`,
        Buffer.from(JSON.stringify(logEntry))
    );
};
```

---

## PHASE 4: FULL NATIVE INTEGRATION (Future)

### When to Do This

- When iframe approach causes UX issues
- When you need tight integration with Dashboard state
- When you want user-specific collection preferences

### Options

| Approach | Effort | Pros | Cons |
|----------|:------:|------|------|
| **Port to Angular** | 2-3 weeks | Native integration, full control | High effort |
| **Port to React** | 1-2 weeks | Reuse existing React skills | Still needs wrapper |
| **Keep SolidJS + postMessage** | 1 week | Minimal changes | Complex communication |

---

## SECURITY CHECKLIST

### Phase 2 (Iframe) ✓

- [x] Angular route protected by FgPermissionGuard
- [x] Only SuperUser/GenieBizAdmin can access
- [x] Menu item hidden for non-admins
- [ ] ⚠️ Underlying URL still public (acceptable for internal tool)

### Phase 3 (API Auth) ✓

- [ ] userId passed with every API call
- [ ] Server validates user permissions
- [ ] Audit log captures all changes
- [ ] Rate limiting on save-collection

### Phase 4 (Full) ✓

- [ ] No public URLs
- [ ] Full session management
- [ ] Per-user change tracking
- [ ] Rollback capability

---

## QUICK START COMMANDS

### For GenieCloud Team (John)

```bash
# 1. Fix is already in the repo, just rebuild
cd genie-collection-editor
npm run build

# 2. Deploy to production
# (your deployment process)
```

### For Dashboard Team

```bash
# 1. Create the component files (copy from above)
# 2. Add route to admin module
# 3. Add menu item with permission check
# 4. Test with SuperUser account
```

---

## URLS SUMMARY

| Environment | URL | Status |
|-------------|-----|:------:|
| **Amplify (Working)** | `https://main.d2jn91nws05uwp.amplifyapp.com/collections` | ✅ |
| **Production (After Fix)** | `https://cloud.thegenie.ai/genie-tools/collection-editor/` | 🔄 After deploy |
| **Dashboard (After Phase 2)** | `https://app.thegenie.ai/admin/collections` | 🔄 After integration |

---

## CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/28/2025 | Cursor AI | Initial document with 4-phase iteration plan |

---

*This document provides a progressive path from "broken" to "production-ready admin tool".*

