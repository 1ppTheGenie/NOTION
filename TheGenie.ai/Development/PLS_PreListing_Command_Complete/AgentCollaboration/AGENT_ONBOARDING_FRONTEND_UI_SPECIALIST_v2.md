# Agent Onboarding: Frontend UI Specialist - Complete Educational Content

**Version:** 2.0  
**Created:** 01/14/2026 3:45 AM  
**Last Updated:** 01/14/2026 3:45 AM  
**Author:** JR (Project Manager)  
**Status:** ✅ **COMPREHENSIVE ONBOARDING - READY FOR AGENT**

---

## 🎯 WELCOME TO THE PLS PROJECT

You've been assigned the **Frontend UI Specialist** role for the PLS (Paisley RESO Listing Engine) project. This is a comprehensive onboarding document with ALL context, prior discovery, ecosystem knowledge, UI/UX specifications, and technical requirements you need to succeed.

**Your Mission:** Build the user interface that enables agents to create, edit, and manage pre-MLS listings with an intuitive, mobile-first experience.

---

## 📚 SECTION 1: PROJECT CONTEXT & VISION

### What is PLS?

**PLS (Paisley RESO Listing Engine)** is a private listing service that enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate full marketing asset kits (landing pages, social ads, brochures) automatically
- Automate circle prospecting campaigns via Listing Command integration
- Future: One-button push to publish listings directly to Bridge/Trestle MLSs via RESO Insert

### Your Role in the System

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   FRONTEND   │────────▶│   BACKEND    │────────▶│   DATABASE   │
│      UI      │  HTTP   │     API      │   SQL   │              │
│ (YOU BUILD)  │         │              │         │              │
└──────────────┘         └──────────────┘         └──────────────┘
        │
        │ User Interactions:
        │ • Create listing
        │ • Upload photos
        │ • Generate AI description
        │ • View listings
        │ • Start campaigns
```

**You are the user-facing layer** that:
- Presents forms and data to users
- Handles user input and validation
- Calls Backend API endpoints
- Displays responses and errors
- Provides intuitive navigation

---

## 📚 SECTION 2: ECOSYSTEM INTEGRATION CONTEXT

### UI Integration Points

| System | Integration Point | Your Responsibility |
|--------|------------------|---------------------|
| **Backend API** | HTTP REST calls | Call all API endpoints, handle responses |
| **Mapbox** | Address autocomplete | Integrate Mapbox API for address lookup |
| **S3/GenieCloud** | Photo upload | Upload photos, display upload progress |
| **Paisley AI** | Description generation | "Generate with AI" button, display loading state |
| **Listing Command** | Campaign initiation | Reuse existing `ListingCommandInitiateComponent` |

### User Flow Context

**Complete User Journey:**
1. User navigates to "Private Listings" menu (Permission 211 required)
2. User clicks "Create New Listing"
3. User enters address (Mapbox autocomplete)
4. System pre-populates form (Title Genie data)
5. User uploads photos (drag-and-drop)
6. User generates AI description (Paisley integration)
7. User selects area (for market stats)
8. User saves listing
9. System generates marketing assets (GenieCloud)
10. User views collection URL

**Your Job:** Build UI components for steps 1-10

---

## 📚 SECTION 3: ANGULAR COMPONENTS - COMPLETE SPECIFICATIONS

### Component Architecture

```
PlsModule
├── PlsMyListingsComponent (List view)
├── PlsCreateComponent (Create form - 7 steps)
├── PlsEditComponent (Edit form - same as create)
├── PlsPhotoUploadComponent (Reusable photo uploader)
├── PlsAreaSelectorComponent (Area picker)
└── PlsAIDescriptionComponent (AI description generator)
```

### 1. PlsMyListingsComponent

**Route:** `/pls/my-listings`

**Purpose:** Display all PLS listings for current user

**API Endpoint:** `GET /api/pls/my-listings`

**Features:**
- List view with cards
- Status badges (Private Listing, Coming Soon)
- Action buttons: Edit, View, Start Campaign, Delete
- Empty state message
- Loading state
- Error handling

**Wireframe Reference:** `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md` - Screen 1

**Data Structure:**
```typescript
interface PlsListing {
  plsNumber: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  price: number;
  statusTypeId: number; // 6=Private, 14=Coming Soon
  createdAt: string;
  collectionUrl?: string;
}
```

### 2. PlsCreateComponent

**Route:** `/pls/create`

**Purpose:** Create new PLS listing (7-step form)

**API Endpoints:**
- `POST /api/pls/pre-populate` (Step 1: Address lookup)
- `POST /api/pls/create` (Step 7: Save listing)

**Form Steps:**
1. **Address Input** - Mapbox autocomplete
2. **Property Details** - Pre-populated from Title Genie
3. **Status Selection** - Coming Soon (14) vs Private Listing (6)
4. **Photos** - Drag-and-drop uploader (at least 1 required)
5. **Description** - Manual entry OR "Generate with AI" button
6. **Area Selection** - Search/select area (for market stats)
7. **Review & Save** - Review all data, save listing

**Wireframe Reference:** `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md` - Screen 2

**Validation:**
- Address: Required
- Price: Required, > 0
- Bedrooms: Required, > 0
- Bathrooms: Required, > 0
- Photos: At least 1 required
- Description: Required
- Area: Required

### 3. PlsEditComponent

**Route:** `/pls/edit/:plsNumber`

**Purpose:** Edit existing PLS listing

**API Endpoints:**
- `GET /api/pls/{listingNumber}` (Load existing data)
- `PUT /api/pls/{listingNumber}` (Update listing)

**Same as Create form, but:**
- Pre-populated with existing data
- Shows PLS Number (read-only)
- Shows Created Date (read-only)
- "Save Changes" button
- "Re-generate Content Kit" button (if already rendered)

### 4. PlsPhotoUploadComponent

**Purpose:** Reusable photo upload component

**API Endpoint:** `POST /api/pls/upload-photo`

**Features:**
- Drag-and-drop uploader
- File browser fallback
- Photo thumbnails with reordering
- Primary photo selection
- Delete photo
- Upload progress indicator
- File type validation (jpg, png)
- File size validation (max 10MB per photo)

**Wireframe Reference:** `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md` - Photo Upload Section

### 5. PlsAreaSelectorComponent

**Purpose:** Area/neighborhood picker

**API Endpoint:** `POST /api/Data/GetAreaList` (Paisley API)

**Features:**
- Search/filter areas
- Display area name, ID
- Used for market stats widgets on landing page
- Required for Listing Command integration

### 6. PlsAIDescriptionComponent

**Purpose:** AI description generator

**API Endpoint:** `POST /api/pls/generate-description`

**Features:**
- "Generate with AI" button
- Loading state during generation
- Populate text area with generated description
- User can edit after generation
- Error handling if generation fails

**Wireframe Reference:** `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md` - AI Description Section

---

## 📚 SECTION 4: PRIOR DISCOVERY FINDINGS

### What Was Discovered Before You

#### 1. Paisley UI Patterns Discovery

**Finding:** Paisley has established UI patterns for pre-listing workflows

**Reference:** `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_UI_DISCOVERY_FINDINGS_v1.1.md`

**Key Patterns:**
- Mobile-first responsive design
- Step-by-step form wizards
- Address autocomplete (Google Places)
- Area selection dropdowns
- Photo upload with drag-and-drop

**Your Usage:** Follow Paisley UI patterns for consistency

#### 2. Address Lookup Prototype Discovery

**Finding:** Address lookup prototype already built

**Reference:** `09_Prototypes/PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html`

**Features:**
- Mapbox integration
- Google Places autocomplete
- Address validation
- PlaceKey extraction

**Your Usage:** Reference prototype for address lookup implementation

#### 3. Permission System Discovery

**Finding:** PLS requires Permission 211 (Menu PLS)

**Implementation:**
- Check permission in route guard
- Hide menu item if no permission
- Show error if user tries to access without permission

**Reference:** `06_Infrastructure/PLS_PERMISSION_ROLE_INTEGRATION_v1.md`

#### 4. Mobile-First Design Discovery

**Finding:** 60%+ of users access on mobile devices

**Requirements:**
- Mobile-first responsive design
- Touch-friendly interface
- Fast loading (< 3 seconds)
- Offline capability (future)

**Wireframe Reference:** `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md` - Responsive Breakpoints

---

## 📚 SECTION 5: YOUR DELIVERABLES - PHASE 3

### Must Complete (In Order)

1. **Wait for Phase 2 Completion**
   - Monitor Backend API Specialist status
   - Verify all API endpoints are ready
   - Test API endpoints with Postman

2. **Create Component Structure**
   - `PlsMyListingsComponent` - List view
   - `PlsCreateComponent` - Create form (7 steps)
   - `PlsEditComponent` - Edit form
   - `PlsPhotoUploadComponent` - Photo uploader
   - `PlsAreaSelectorComponent` - Area picker
   - `PlsAIDescriptionComponent` - AI description generator

3. **Implement Routing**
   - Add routes to Angular routing module
   - Add permission guard (Permission 211)
   - Add menu item (left navigation)

4. **Implement Forms**
   - Address input with Mapbox autocomplete
   - Property details form
   - Status selection
   - Photo upload (drag-and-drop)
   - Description text area
   - Area selection
   - Form validation (client-side)

5. **Implement API Integration**
   - HTTP service for all API endpoints
   - Error handling
   - Loading states
   - Success/error messages

6. **Implement Mobile-First Design**
   - Responsive breakpoints
   - Touch-friendly interface
   - Mobile optimization

7. **Testing**
   - Component unit tests
   - Integration tests
   - E2E tests
   - Mobile device testing

8. **Documentation**
   - Update status file
   - Announce Phase 3 complete

### Success Criteria

- ✅ All components load and function correctly
- ✅ Forms validate input client-side and server-side
- ✅ Mobile-responsive design works on all screen sizes
- ✅ Integration with Backend API endpoints working
- ✅ Permission system working (Permission 211)
- ✅ Error handling and user feedback working

---

## 📚 SECTION 6: CRITICAL TECHNICAL SPECIFICATIONS

### Angular Version

**Framework:** Angular (version from existing project)

**Reference:** Check existing Angular components in project

### API Service Pattern

**Create HTTP Service:**
```typescript
@Injectable()
export class PlsApiService {
  private baseUrl = '/api/pls';
  
  getMyListings(): Observable<PlsListing[]> { ... }
  createListing(data: CreateListingDto): Observable<PlsListing> { ... }
  updateListing(plsNumber: string, data: UpdateListingDto): Observable<PlsListing> { ... }
  getListing(plsNumber: string): Observable<PlsListing> { ... }
  prePopulate(placeKey: string): Observable<PrePopulateResponse> { ... }
  generateDescription(data: GenerateDescriptionDto): Observable<DescriptionResponse> { ... }
  uploadPhoto(file: File): Observable<PhotoResponse> { ... }
  renderContentKit(plsNumber: string): Observable<RenderResponse> { ... }
}
```

### Permission Guard

**Implementation:**
```typescript
@Injectable()
export class PlsPermissionGuard implements CanActivate {
  canActivate(): boolean {
    // Check Permission 211 (Menu PLS)
    return this.permissionService.hasPermission(211);
  }
}
```

### Routing Configuration

```typescript
const routes: Routes = [
  {
    path: 'pls',
    canActivate: [PlsPermissionGuard],
    children: [
      { path: 'my-listings', component: PlsMyListingsComponent },
      { path: 'create', component: PlsCreateComponent },
      { path: 'edit/:plsNumber', component: PlsEditComponent },
    ],
  },
];
```

### Mapbox Integration

**Address Autocomplete:**
- Use Mapbox Geocoding API
- Display autocomplete dropdown
- Extract PlaceKey from selected address
- Call `POST /api/pls/pre-populate` with PlaceKey

**Reference:** `09_Prototypes/PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html`

---

## 📚 SECTION 7: MUST-READ DOCUMENTS (In Priority Order)

### Priority 1: Core UI Documents (READ FIRST)

1. **Your Role Definition**
   - `AgentCollaboration/AGENT_ROLE_FRONTEND_UI_SPECIALIST_v1.md`
   - **Why:** Your exact responsibilities and deliverables

2. **Wireframe Specifications**
   - `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md`
   - **Why:** Complete UI/UX specifications for all screens

3. **Project Blueprint - UI Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 6
   - **Why:** Complete UI component specifications

4. **Reference Prototypes**
   - `09_Prototypes/PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html`
   - **Why:** Working prototype for address lookup

5. **Reference Components**
   - `08_Source_Code/pls-create.component.ts`
   - `08_Source_Code/pls-create.component.html`
   - **Why:** Starting point for your implementation

### Priority 2: Integration Documents (CRITICAL)

6. **Paisley UI Discovery Findings**
   - `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_UI_DISCOVERY_FINDINGS_v1.1.md`
   - **Why:** Established UI patterns from Paisley

7. **Backend API Documentation**
   - Wait for Backend API Specialist to provide API documentation
   - **Why:** All API endpoints you'll call

8. **Permission System Integration**
   - `06_Infrastructure/PLS_PERMISSION_ROLE_INTEGRATION_v1.md`
   - **Why:** Permission 211 (Menu PLS) requirements

### Priority 3: Supporting Documents (Reference)

9. **Workspace Memory Log - UI Frontend**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_04_UI_FRONTEND_v1.md`
   - **Why:** Historical context and UI design decisions

10. **UI Testing Checklist**
    - `05_Verification_Audits/PLS_UI_TESTING_CHECKLIST_v1.md`
    - **Why:** Testing requirements

### Priority 4: Ecosystem Context (Reference)

11. **Ecosystem Document Catalog**
    - `01_Master_Documents/PLS_ECOSYSTEM_DOCUMENT_CATALOG_v1.md`
    - **Why:** Understand how PLS fits with other systems

---

## 📚 SECTION 8: COMMON PITFALLS & SOLUTIONS

### Pitfall 1: Not Waiting for Backend API

**❌ WRONG:** Starting UI development before API is ready  
**✅ CORRECT:** Wait for Backend API Specialist to complete Phase 2, test endpoints first

### Pitfall 2: Not Following Wireframes

**❌ WRONG:** Creating custom UI without referencing wireframes  
**✅ CORRECT:** Follow wireframe specifications exactly

### Pitfall 3: Not Implementing Mobile-First

**❌ WRONG:** Building desktop-first, mobile as afterthought  
**✅ CORRECT:** Design for mobile first, then enhance for desktop

### Pitfall 4: Not Handling Errors

**❌ WRONG:** Silent failures, no user feedback  
**✅ CORRECT:** Display error messages, loading states, success confirmations

### Pitfall 5: Not Testing on Mobile Devices

**❌ WRONG:** Only testing on desktop browser  
**✅ CORRECT:** Test on actual mobile devices (iOS, Android)

---

## 📚 SECTION 9: DAILY WORKFLOW

### Morning (5 minutes)
1. Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for project status
2. Check Backend API Specialist status for Phase 2 completion
3. Check `AgentCollaboration/BLOCKERS_v1.md` for blockers
4. Review your status file: `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md`

### During Work
1. Implement components using wireframes and prototypes
2. Test each component independently
3. Integrate with Backend API endpoints
4. Test on mobile devices
5. Update progress in status file

### End of Day (5 minutes)
1. Update `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md` with progress
2. Document any blockers in `AgentCollaboration/BLOCKERS_v1.md`
3. Update deliverables checklist

---

## 📚 SECTION 10: COLLABORATION & HANDOFFS

### Dependencies
- **Backend API Specialist** - Must wait for Phase 2 completion (API endpoints)

### Handoffs TO
- **DevOps Specialist** - Provides deployment requirements for frontend assets

### Communication
- **Daily:** Update `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md`
- **Blockers:** Document in `AgentCollaboration/BLOCKERS_v1.md`
- **Completions:** Announce in `AgentCollaboration/HANDOFFS_v1.md`

---

## ✅ ONBOARDING CHECKLIST

Before you start work, verify you've completed:

- [ ] Read this entire onboarding document
- [ ] Read your role definition (`AGENT_ROLE_FRONTEND_UI_SPECIALIST_v1.md`)
- [ ] Read Wireframe Specifications
- [ ] Read Project Blueprint Section 6 (UI Components)
- [ ] Reviewed reference prototypes
- [ ] Reviewed reference components
- [ ] Read Paisley UI Discovery Findings
- [ ] Understood permission system (Permission 211)
- [ ] Set up status tracking file
- [ ] Waiting for Phase 2 completion (Backend API Specialist)

---

## 🎯 NEXT STEPS

1. **Complete onboarding checklist above**
2. **Wait for Phase 2 completion** - Monitor Backend API Specialist status
3. **Review wireframes** - Understand all UI requirements
4. **Review prototypes** - See working examples
5. **Plan component structure** - Organize Angular components
6. **Begin implementation** - Start with PlsMyListingsComponent
7. **Test each component** - Verify independently
8. **Integrate with API** - Connect to Backend API endpoints
9. **Test on mobile** - Verify responsive design
10. **Update status and announce Phase 3 complete**

---

## 📞 ESCALATION

**If Blocked:**
1. Document in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag Backend API Specialist if endpoint issues
3. Tag Project Manager (JR) if needed
4. Update status file with blocker details

**Questions?**
- Review your role definition first
- Check workspace memory logs for historical context
- Review wireframes and prototypes
- Document questions in blockers file if needed

---

## 📚 REFERENCE QUICK LINKS

- **Your Role:** `AgentCollaboration/AGENT_ROLE_FRONTEND_UI_SPECIALIST_v1.md`
- **Wireframes:** `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md`
- **Project Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md`
- **Prototypes:** `09_Prototypes/`
- **Reference Code:** `08_Source_Code/`
- **Paisley UI Patterns:** `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_UI_DISCOVERY_FINDINGS_v1.1.md`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **COMPREHENSIVE ONBOARDING COMPLETE**

**Welcome to the team! You're building the user-facing interface that agents will use every day. You have all the context and knowledge you need. Let's build this right!**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | 01/14/2026 3:45 AM | JR (Project Manager) | Comprehensive rewrite with full ecosystem context, prior discovery findings, complete UI specifications, component architecture, integration points, common pitfalls, and educational content. This is the complete educational package for Frontend UI Specialist onboarding. |
| 1.0 | 01/13/2026 | JR (Project Manager) | Initial Frontend UI Specialist role definition. |
