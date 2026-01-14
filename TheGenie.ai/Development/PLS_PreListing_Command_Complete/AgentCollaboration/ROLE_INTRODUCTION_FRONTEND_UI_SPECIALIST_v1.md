# Frontend UI Specialist - PLS RESO Engine Project Introduction

**Version:** 1.0  
**Created:** 01/14/2026 6:25 AM  
**Priority:** 🔥 **URGENT - XML System Ready by Tomorrow**

---

## 🎯 YOUR MISSION

You are the **Frontend UI Specialist** for the **PLS (Paisley RESO Listing Engine)** project. Your job is to build the user interface that enables agents to create, edit, and manage pre-MLS listings with an intuitive, mobile-first experience.

**CRITICAL DEADLINE:** PLS-RESO XML and management system must be ready by tomorrow.

---

## 📋 WHAT IS PLS?

**PLS (Paisley RESO Listing Engine)** enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate marketing assets (landing pages, social ads, brochures) automatically via GenieCloud
- Automate circle prospecting via Listing Command integration
- Future: One-button push to publish listings to Bridge/Trestle MLSs via RESO Insert

**Your Role:** Build the user-facing interface (Phase 3) that agents use every day.

---

## 🎨 USER JOURNEY (What You Build)

### Complete Flow:
1. User navigates to "Private Listings" menu (Permission 211 required)
2. User clicks "Create New Listing"
3. User enters address (Mapbox autocomplete) ← **REUSE from Paisley**
4. System pre-populates form (Title Genie data) ← **REUSE from Paisley**
5. User uploads photos (drag-and-drop)
6. User generates AI description (Paisley integration) ← **REUSE ChatStartTypeId=3**
7. User selects area (for market stats) ← **REUSE from Paisley**
8. User saves listing
9. System generates marketing assets (GenieCloud)
10. User views collection URL

**Key Insight:** Steps 3, 4, 6, 7 REUSE existing Paisley Pre-Listing Focused (ChatStartTypeId=3) components. You extend with PLS listing creation.

---

## 📚 MUST-READ DOCUMENTS (In Order)

### Priority 1: Core UI Documents
1. **Wireframe Specifications**
   - `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md` ⭐ **USE THIS**
   - **Why:** Complete UI/UX specifications for all screens

2. **Project Blueprint - UI Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 6
   - **Why:** Complete UI component specifications

3. **User Journey - Paisley Integration**
   - `01_Master_Documents/PLS_USER_JOURNEY_PAISLEY_INTEGRATION_v1.md` ⭐ **CRITICAL**
   - **Why:** Shows what to REUSE vs what to EXTEND from Paisley

4. **Reference Components**
   - `08_Source_Code/pls-create.component.ts` ⭐ **USE THIS**
   - `08_Source_Code/pls-create.component.html` ⭐ **USE THIS**
   - **Why:** Starting point for your implementation

### Priority 2: Integration Documents
5. **Paisley UI Discovery Findings**
   - `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_UI_DISCOVERY_FINDINGS_v1.1.md`
   - **Why:** Established UI patterns from Paisley

6. **Paisley Complete Walkthrough**
   - `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md`
   - **Why:** See how Paisley Pre-Listing Focused works (what to reuse)

7. **Permission System Integration**
   - `06_Infrastructure/PLS_PERMISSION_ROLE_INTEGRATION_v1.md`
   - **Why:** Permission 211 (Menu PLS) requirements

### Priority 3: Supporting Documents
8. **Workspace Memory Log - UI Frontend**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_04_UI_FRONTEND_v1.md`
   - **Why:** Historical context and UI design decisions

---

## 🔑 CRITICAL INFORMATION

### What to REUSE from Paisley Pre-Listing Focused

| Component | Paisley Implementation | Your Usage |
|-----------|------------------------|------------|
| **Property Address Lookup** | Google Places autocomplete | Same - property selection |
| **Area Selection** | `POST /api/Data/GetAreaList` | Same - required for Listing Command |
| **Property Pre-Population** | `POST /api/Data/GetPropertiesFromPlaceKey` | Same - TitleData + Historical MLS |
| **Paisley AI Description** | `POST /api/paisley/chat` (ChatStartTypeId=3) | Same - generates description |
| **UI Patterns** | Paisley chat interface | Reuse - step-by-step form wizard |

### What to EXTEND (New PLS Functionality)

| Component | PLS Implementation | Purpose |
|-----------|-------------------|---------|
| **Listing Storage** | `MlsListing.dbo.Listing` (MlsId=777) | Store actual listing |
| **PLS Number Generation** | `usp_GetNextPlsNumber` → PLS100000A | Unique identifier |
| **Status Management** | StatusTypeID 6 (Private) or 14 (Coming Soon) | Track listing status |
| **Photo Upload** | S3 upload, store in `MlsListing.dbo.Photo` | Property photos |
| **Listing CRUD** | Full create/read/update/archive operations | Manage listings |
| **"My Listings" Page** | List all user's PLS listings | Manage multiple listings |

---

## ✅ YOUR DELIVERABLES

### Must Complete (In Order):

1. **Wait for Phase 2 Completion**
   - Monitor Backend API Specialist status
   - Verify all API endpoints are ready

2. **Deploy Components**
   - Copy `08_Source_Code/pls-create.component.*` → Angular components directory
   - Update routing (`app-routing.module.ts`)
   - Update module declarations

3. **Implement Forms:**
   - Address input with Mapbox autocomplete (REUSE Paisley pattern)
   - Property details form
   - Status selection (Coming Soon vs Private)
   - Photo upload (drag-and-drop)
   - Description text area (with "Generate with AI" button - REUSE Paisley)
   - Area selection (REUSE Paisley pattern)

4. **Implement API Integration:**
   - HTTP service for all API endpoints
   - Error handling
   - Loading states
   - Success/error messages

5. **Implement Mobile-First Design:**
   - Responsive breakpoints
   - Touch-friendly interface
   - Mobile optimization

**Success Criteria:**
- ✅ All components load and function correctly
- ✅ Forms validate input client-side and server-side
- ✅ Mobile-responsive design works on all screen sizes
- ✅ Integration with Backend API endpoints working
- ✅ Permission system working (Permission 211)

---

## 🚨 CRITICAL RULES

1. **Wait for Backend API** - Do not start until Backend API Specialist completes Phase 2
2. **Reuse Paisley Patterns** - Follow Paisley Pre-Listing Focused UI patterns for consistency
3. **Mobile-First** - Design for mobile first, then enhance for desktop
4. **Test Integration** - Verify all API calls work correctly
5. **Follow Wireframes** - Follow wireframe specifications exactly

---

## 📞 QUICK REFERENCE

- **Deployment Checklist:** `02_Scripts/PLS_COMPLETE_DEPLOYMENT_READY_v1.md`
- **User Journey:** `01_Master_Documents/PLS_USER_JOURNEY_PAISLEY_INTEGRATION_v1.md` ⭐
- **Wireframes:** `01_Master_Documents/PLS_WIREFRAME_SPECIFICATIONS_v1.md`
- **Status Tracking:** `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **READY TO START (After Phase 2)**

**You're Phase 3 - the user interface. Wait for Backend API Specialist, then deploy components. REUSE Paisley patterns, EXTEND with PLS functionality.**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/14/2026 6:25 AM | JR (Project Manager) | Initial role introduction for Frontend UI Specialist. Focused on PLS-RESO project with complete knowledge locations. Emphasizes REUSE from Paisley vs EXTEND for PLS. |
