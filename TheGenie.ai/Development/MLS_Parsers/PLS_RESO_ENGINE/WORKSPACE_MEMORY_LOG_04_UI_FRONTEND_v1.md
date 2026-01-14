# PLS RESO Engine - Workspace Memory Log: UI/Frontend Development
**Version:** 1.0  
**Created:** 01/10/2026  
**Last Updated:** 01/10/2026  
**Topic:** Angular Components, Wireframes, User Experience, Mobile-First Design  
**Status:** ✅ Active

---

## 📋 TOPIC OVERVIEW

This memory log captures all discussions, decisions, and documentation related to:
- Angular component design
- User interface wireframes
- User experience flows
- Mobile-first design requirements
- Form validation
- Navigation and routing

---

## 🎨 ANGULAR COMPONENTS

### PlsMyListingsComponent
**Purpose:** Display all PLS listings for current user

**Features:**
- List view with filters (status, date range)
- Search functionality
- Pagination
- Quick actions (Edit, Archive, Render)

**Location:** `Smart.NG.Agent/src/app/pages/pls/pls-my-listings/`

### PlsCreateComponent
**Purpose:** Create new PLS listing

**Features:**
- Address lookup (Mapbox integration)
- Area selection (for Paisley)
- Property pre-population from TitleData
- Form validation
- Photo upload (optional)
- AI description generation

**Location:** `Smart.NG.Agent/src/app/pages/pls/pls-create/`

**Files:**
- `pls-create.component.ts` - Component logic
- `pls-create.component.html` - Template
- `pls-create.component.scss` - Styles

**Status:** ⚠️ Files deleted during rollback - needs to be recreated

### PlsEditComponent
**Purpose:** Edit existing PLS listing

**Features:**
- Pre-populated form with existing data
- Update validation
- Status change workflow
- Photo management

**Location:** `Smart.NG.Agent/src/app/pages/pls/pls-edit/`

### PlsPhotoUploadComponent
**Purpose:** Upload and manage property photos

**Features:**
- Drag-and-drop upload
- Image preview
- Thumbnail generation
- Photo ordering

**Location:** `Smart.NG.Agent/src/app/pages/pls/pls-photo-upload/`

### PlsAreaSelectorComponent
**Purpose:** Select area for Paisley AI description generation

**Features:**
- Area search
- Area selection dropdown
- Area data display

**Location:** `Smart.NG.Agent/src/app/pages/pls/pls-area-selector/`

### PlsAIDescriptionComponent
**Purpose:** Generate and edit AI description using Paisley

**Features:**
- Generate description button
- Edit description textarea
- Tone selection
- Preview

**Location:** `Smart.NG.Agent/src/app/pages/pls/pls-ai-description/`

---

## 🗺️ USER EXPERIENCE FLOW

### Create Listing Flow
1. User navigates to "Pre-Listing" menu
2. Clicks "Create New Listing"
3. Enters address (Mapbox autocomplete)
4. System auto-fetches areas (for Paisley)
5. User selects area
6. System pre-populates property data from TitleData
7. User reviews/edits pre-populated data
8. User uploads photos (optional - "Load Photos" button)
9. System auto-generates Mapbox satellite photo (property boundary + best angle)
10. Paisley auto-generates description (ChatStartTypeId=3) - shows with "Edit" button
11. User reviews description, clicks "Edit" if needed
12. User clicks "Create Listing"
13. System generates PLS number (PLS100000A)
14. System creates listing in MlsListing.dbo.Listing
15. System creates ownership record in PlsListingOwnership
16. User redirected to listing detail page

### Edit Listing Flow
1. User navigates to "My Listings"
2. Clicks on listing to edit
3. Form pre-populated with existing data
4. User makes changes
5. User clicks "Save Changes"
6. System updates listing
7. User sees success message

### Generate Content Kit Flow
1. User navigates to listing detail page
2. Clicks "Generate Content Kit"
3. System calls `/api/pls/{listingNumber}/render`
4. System generates GenieCloud XML
5. System creates collection in GenieCloud
6. System generates marketing assets (social ads, postcards, brochures)
7. User sees preview of all assets
8. User can download or share assets

---

## 📱 MOBILE-FIRST DESIGN

### Design Principles
1. **Mobile-First** - Design for mobile, enhance for desktop
2. **Touch-Friendly** - Large tap targets (44px minimum)
3. **Responsive** - Works on all screen sizes
4. **Fast Loading** - Optimize images and assets
5. **Accessible** - WCAG 2.1 AA compliance

### Breakpoints
- **Mobile:** < 768px
- **Tablet:** 768px - 1024px
- **Desktop:** > 1024px

### Component Considerations
- **Forms** - Stack vertically on mobile, horizontal on desktop
- **Tables** - Convert to cards on mobile
- **Navigation** - Hamburger menu on mobile
- **Photos** - Grid layout, swipeable on mobile

---

## 🎯 WIREFRAME SPECIFICATIONS

### Reference Document
**PLS_WIREFRAME_SPECIFICATIONS_v1.md** - Figma-ready wireframe specs

### Key Screens
1. **My Listings** - List view with filters
2. **Create Listing** - Multi-step form
3. **Edit Listing** - Pre-populated form
4. **Listing Detail** - View listing with actions
5. **Content Kit** - Marketing assets preview

---

## 🔗 ROUTING

### Routes
```typescript
{
  path: 'pls',
  children: [
    { path: 'my-listings', component: PlsMyListingsComponent },
    { path: 'create', component: PlsCreateComponent },
    { path: 'edit/:listingNumber', component: PlsEditComponent },
    { path: ':listingNumber', component: PlsDetailComponent }
  ]
}
```

### Navigation
- **Menu Item:** "Pre-Listing" (not "Private Listings")
- **Breadcrumbs:** Home > Pre-Listing > [Page]
- **Back Button:** Returns to previous page

---

## 🎨 DESIGN SYSTEM

### Colors
- **Primary:** Brand colors (from existing TheGenie design system)
- **Success:** Green (#28a745)
- **Error:** Red (#dc3545)
- **Warning:** Yellow (#ffc107)

### Typography
- **Headings:** Existing font stack
- **Body:** Existing font stack
- **Sizes:** Responsive (rem units)

### Components
- **Buttons:** Primary, Secondary, Danger variants
- **Forms:** Input, Select, Textarea, Checkbox, Radio
- **Cards:** For listing display
- **Modals:** For confirmations and details

---

## 📚 KEY DOCUMENTS

| Document | Version | Purpose |
|----------|---------|---------|
| **PLS_WIREFRAME_SPECIFICATIONS_v1.md** | 1.0 | Figma-ready wireframe specs |
| **PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html** | 4.0 | Address lookup prototype (Mapbox) |
| **PLS_GENIECLOUD_XML_MAPPING_v1.md** | 1.0 | XML mapping for GenieCloud |

---

## 🔑 KEY DECISIONS

1. **Angular Framework** - Use existing Smart.NG.Agent Angular app
2. **Mobile-First** - Design for mobile, enhance for desktop
3. **Mapbox Integration** - Address lookup and satellite photos
4. **Paisley Integration** - ChatStartTypeId=3 for description generation
5. **Auto-Generation** - System auto-generates photos and descriptions
6. **Optional Photo Upload** - User can upload or use auto-generated

---

## ⚠️ CRITICAL NOTES

1. **pls-create.component.ts/html** were deleted during rollback - needs to be recreated
2. **All components must be tested in Sandbox first** before Production
3. **Form validation** must occur client-side and server-side
4. **Error handling** must show user-friendly messages
5. **Loading states** must be shown during API calls

---

## 📝 CHANGELOG

- **2026-01-10:** Initial workspace memory log created
- **2026-01-09:** Workflow updated - auto-generation of photos and descriptions
- **2026-01-06:** Mobile-first design requirements added
- **2026-01-02:** Initial UI design completed

---

**Status:** ✅ Active - All UI/frontend design decisions documented
