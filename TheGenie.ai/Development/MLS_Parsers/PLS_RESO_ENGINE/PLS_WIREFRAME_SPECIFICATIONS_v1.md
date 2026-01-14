# PLS RESO Engine - Wireframe Specifications for Figma
**Version:** 1.0  
**Created:** 01/02/2026  
**Last Updated:** 01/02/2026  
**Author:** Cursor AI Agent  
**Purpose:** Complete wireframe specifications for Figma import - all screens, components, and interactions

---

## 🎯 EXECUTIVE SUMMARY

This document provides detailed wireframe specifications that can be imported into Figma. Each screen includes:
- Layout structure
- Component specifications
- Interaction states
- Responsive breakpoints
- Accessibility requirements

---

## 📐 DESIGN SYSTEM FOUNDATION

### Typography

| Element | Font Family | Size | Weight | Line Height |
|---------|-------------|------|--------|-------------|
| **Page Title** | System (Segoe UI) | 24px | 600 | 32px |
| **Section Header** | System | 18px | 600 | 24px |
| **Body Text** | System | 14px | 400 | 20px |
| **Label** | System | 12px | 600 | 16px |
| **Helper Text** | System | 12px | 400 | 16px |

### Colors

| Element | Light Mode | Dark Mode | Usage |
|---------|------------|-----------|-------|
| **Primary** | #3498db | #5dade2 | Buttons, links |
| **Secondary** | #95a5a6 | #bdc3c7 | Secondary actions |
| **Success** | #27ae60 | #2ecc71 | Success states |
| **Error** | #e74c3c | #ec7063 | Errors, warnings |
| **Background** | #ffffff | #1a1a1a | Page background |
| **Surface** | #f8f9fa | #2d2d2d | Card background |
| **Text Primary** | #212529 | #ffffff | Main text |
| **Text Secondary** | #6c757d | #adb5bd | Secondary text |
| **Border** | #dee2e6 | #495057 | Borders, dividers |

### Spacing Scale

| Size | Value | Usage |
|------|-------|-------|
| **XS** | 4px | Tight spacing |
| **SM** | 8px | Component padding |
| **MD** | 16px | Section spacing |
| **LG** | 24px | Card spacing |
| **XL** | 32px | Page spacing |
| **XXL** | 48px | Section separation |

### Component Library

| Component | Variant | Specs |
|-----------|---------|-------|
| **Button** | Primary | Height: 40px, Padding: 12px 24px, Border-radius: 6px |
| **Button** | Secondary | Height: 40px, Padding: 12px 24px, Border: 1px solid |
| **Input** | Text | Height: 40px, Padding: 8px 12px, Border-radius: 4px |
| **Input** | Select | Height: 40px, Padding: 8px 12px, Dropdown arrow |
| **Card** | Default | Padding: 24px, Border-radius: 8px, Shadow: 0 2px 8px rgba(0,0,0,0.08) |
| **Badge** | Status | Height: 24px, Padding: 4px 12px, Border-radius: 12px |

---

## 📱 SCREEN 1: MY PLS LISTINGS (List View)

### Route
`/pls/my-listings`

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  HEADER (Sticky)                                                │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Private Listings                    [Create New Listing] │ │
│  └───────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  CONTENT AREA                                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  LISTING CARD 1                                            │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │  PLS-2025-00001                    [Status Badge]   │ │ │
│  │  │  10037 Rebecca Place                                 │ │ │
│  │  │  Boerne, TX 78006                                    │ │ │
│  │  │  $749,000                                            │ │ │
│  │  │  Created: 12/30/2025                                 │ │ │
│  │  │                                                      │ │ │
│  │  │  [Edit] [View] [Start Campaign] [Delete]            │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                           │ │
│  │  LISTING CARD 2 (same structure)                         │ │
│  │                                                           │ │
│  │  [Empty State: "No listings yet. Create your first..."] │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Component Specifications

#### Header
- **Height:** 64px
- **Background:** Surface color
- **Padding:** 16px 24px
- **Border-bottom:** 1px solid border color
- **Title:** "Private Listings" (Page Title typography)
- **Button:** Primary button, right-aligned

#### Listing Card
- **Width:** 100% (max-width: 1200px, centered)
- **Padding:** 24px
- **Margin-bottom:** 16px
- **Background:** Surface color
- **Border-radius:** 8px
- **Shadow:** Card shadow

**Card Content:**
- **Row 1:** PLS Number (Body Text, bold) + Status Badge (right-aligned)
- **Row 2:** Display Address (Section Header)
- **Row 3:** City, State, Zip (Body Text, secondary color)
- **Row 4:** Price (Section Header, primary color)
- **Row 5:** Created date (Helper Text)
- **Row 6:** Action buttons (4 buttons, equal width)

#### Status Badge
- **Private Listing:** Background: #9b59b6, Text: white
- **Coming Soon:** Background: #3498db, Text: white
- **Size:** Height: 24px, Padding: 4px 12px

#### Action Buttons
- **Edit:** Secondary button
- **View:** Secondary button (opens external link)
- **Start Campaign:** Primary button
- **Delete:** Secondary button (error color on hover)

#### Empty State
- **Centered:** Vertically and horizontally
- **Icon:** Large icon (64px)
- **Text:** "No listings yet. Create your first private listing to get started."
- **Button:** Primary button "Create New Listing"

### Responsive Breakpoints

| Breakpoint | Width | Changes |
|------------|-------|---------|
| **Desktop** | > 1200px | 3-column grid (if many listings) |
| **Tablet** | 768px - 1200px | 2-column grid |
| **Mobile** | < 768px | 1 column, stacked buttons |

### Interaction States

- **Card Hover:** Shadow increases, slight scale (1.02)
- **Button Hover:** Background color darkens 10%
- **Button Active:** Scale down (0.98)
- **Loading State:** Skeleton cards while fetching

---

## 📝 SCREEN 2: CREATE NEW LISTING (Multi-Step Form)

### Route
`/pls/create`

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  HEADER (Sticky)                                                │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Create New Private Listing    [Cancel] [Save Draft]     │ │
│  └───────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  PROGRESS INDICATOR                                             │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  [1] Address  [2] Details  [3] Status  [4] Photos  ...   │ │
│  └───────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  FORM CONTENT                                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  STEP 1: PROPERTY ADDRESS                                 │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │  Street Number *  [____________]                    │ │ │
│  │  │  Street Name *    [____________]                    │ │ │
│  │  │  City *            [____________]                    │ │ │
│  │  │  State *           [TX ▼]                            │ │ │
│  │  │  Zip *              [78006]                          │ │ │
│  │  │                                                      │ │ │
│  │  │  [Auto-geocode on blur]                             │ │ │
│  │  │  Latitude: 29.72229  Longitude: -98.68958          │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                           │ │
│  │  STEP 2: PROPERTY DETAILS                                 │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │  List Price *        [$749,000]                      │ │ │
│  │  │  Bedrooms *          [4 ▼]                          │ │ │
│  │  │  Bathrooms Full *     [3 ▼]                          │ │ │
│  │  │  Bathrooms Half *     [0 ▼]                          │ │ │
│  │  │  Square Feet *       [3,018]                        │ │ │
│  │  │  Lot Size (sq ft) *  [9,101]                        │ │ │
│  │  │  Year Built *        [2022]                         │ │ │
│  │  │  Property Type *     [Single Family ▼]              │ │ │
│  │  │  Garage Spaces       [3 ▼]                          │ │ │
│  │  │  Parking Spaces      [3 ▼]                          │ │ │
│  │  │                                                      │ │ │
│  │  │  ⚠️ Square Feet conflict detected                    │ │ │
│  │  │     TitleData: 2,500 sqft                            │ │ │
│  │  │     Historical MLS: 3,018 sqft * (recommended)      │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                           │ │
│  │  ... (Steps 3-7)                                          │ │
│  │                                                           │ │
│  │  [← Back]  [Save Listing]  [Save & Generate Content Kit] │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Component Specifications

#### Progress Indicator
- **Type:** Horizontal stepper
- **Steps:** 7 steps (Address, Details, Status, Photos, Description, Area, Agent)
- **Active Step:** Primary color, filled circle
- **Completed Step:** Primary color, checkmark icon
- **Inactive Step:** Secondary color, empty circle
- **Height:** 48px
- **Padding:** 16px 24px

#### Form Section
- **Background:** Surface color
- **Padding:** 24px
- **Margin-bottom:** 24px
- **Border-radius:** 8px
- **Section Header:** Section Header typography, margin-bottom: 16px

#### Input Field
- **Label:** Label typography, margin-bottom: 8px
- **Required Indicator:** Red asterisk (*) after label
- **Input:** Input component specs
- **Helper Text:** Helper Text typography, margin-top: 4px
- **Error State:** Red border, error message below input

#### Conflict Warning
- **Background:** #fff3cd (warning yellow, light mode) / #856404 (dark mode)
- **Border:** 1px solid #ffc107
- **Padding:** 12px 16px
- **Border-radius:** 4px
- **Icon:** Warning icon (16px)
- **Text:** Body Text, margin-left: 8px

#### Photo Upload Area
- **Border:** 2px dashed border color
- **Border-radius:** 8px
- **Padding:** 48px
- **Background:** Surface color (lighter)
- **Text:** "Drag & Drop Photos Here" (centered)
- **Button:** "Browse Files" (secondary button)
- **Min Height:** 200px

#### Photo Thumbnails Grid
- **Layout:** Grid, 4 columns (desktop), 2 columns (tablet), 1 column (mobile)
- **Item Size:** 120px x 120px
- **Border-radius:** 4px
- **Overlay:** On hover, show "Set Primary" and "Delete" buttons
- **Primary Indicator:** Green checkmark badge in top-right corner

### Step-by-Step Specifications

#### Step 1: Property Address
- **Fields:** Street Number, Street Name, City, State (dropdown), Zip
- **Auto-geocode:** Trigger on blur of Zip field
- **Display:** Latitude/Longitude (read-only, below form)

#### Step 2: Property Details
- **Fields:** List Price, Bedrooms, Bathrooms (Full/Half), Square Feet, Lot Size, Year Built, Property Type, Garage, Parking
- **Conflict Detection:** Show warning if TitleData differs from Historical MLS
- **Data Source Indicator:** Small icon showing data source (TitleData vs Historical MLS)

#### Step 3: Listing Status
- **Type:** Radio buttons (2 options)
- **Options:**
  - Coming Soon (StatusTypeID=14) - "Pre-market listing - will go to MLS soon"
  - Private Listing (StatusTypeID=6) - "Off-market/exclusive - not going to MLS"
- **Layout:** Vertical stack, each option in a card

#### Step 4: Photos
- **Upload Area:** Drag-and-drop zone
- **Thumbnails:** Grid of uploaded photos
- **Actions:** Reorder (drag handles), Set Primary (button), Delete (button)
- **Validation:** At least 1 photo required

#### Step 5: Description
- **Type:** Textarea (min-height: 200px)
- **Actions:** "Generate with AI" button (primary), "Manual Entry" toggle
- **AI Loading State:** Spinner, "Generating description..." text
- **Character Count:** Display below textarea (optional)

#### Step 6: Area Selection
- **Type:** Searchable dropdown
- **Search:** Type-ahead search for area names
- **Display:** Selected area name, Area ID (read-only)
- **Helper Text:** "Used for market stats widgets on landing page"

#### Step 7: Agent Selection
- **Type:** Dropdown (pre-filled with logged-in user)
- **Display:** Agent name, company, license number
- **Helper Text:** "If Title Rep: Can select from sponsored agents"

### Form Actions (Bottom)
- **Cancel:** Secondary button (left)
- **Save Listing:** Secondary button (center)
- **Save & Generate Content Kit:** Primary button (right)

### Validation States

- **Field Error:** Red border, error message below
- **Form Error:** Error banner at top of form
- **Success:** Success message, redirect to list view

---

## ✏️ SCREEN 3: EDIT LISTING

### Route
`/pls/edit/{plsNumber}`

### Layout
Same as Create form, but:
- **Pre-populated:** All fields filled with existing data
- **Read-only Fields:** PLS Number, Created Date
- **Actions:** "Save Changes" (instead of "Save Listing"), "Re-generate Content Kit" (if already rendered)

---

## 🎨 COMPONENT LIBRARY

### Button Component

**Variants:**
- **Primary:** Background: Primary color, Text: White
- **Secondary:** Background: Transparent, Border: 1px solid, Text: Primary color
- **Danger:** Background: Error color, Text: White
- **Ghost:** Background: Transparent, Text: Primary color

**States:**
- **Default:** Base styles
- **Hover:** Background darkens 10%
- **Active:** Scale: 0.98
- **Disabled:** Opacity: 0.5, cursor: not-allowed
- **Loading:** Spinner icon, text hidden

### Input Component

**Variants:**
- **Text:** Standard text input
- **Number:** Numeric input with increment/decrement buttons
- **Select:** Dropdown with search
- **Textarea:** Multi-line text input

**States:**
- **Default:** Border: 1px solid border color
- **Focus:** Border: 2px solid primary color
- **Error:** Border: 2px solid error color
- **Disabled:** Background: Surface color, cursor: not-allowed

### Card Component

**Variants:**
- **Default:** White background, shadow
- **Elevated:** Larger shadow
- **Outlined:** Border instead of shadow

### Badge Component

**Variants:**
- **Status:** Colored background (Private: Purple, Coming Soon: Blue)
- **Info:** Blue background
- **Success:** Green background
- **Warning:** Yellow background
- **Error:** Red background

---

## 📱 RESPONSIVE BREAKPOINTS

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| **Mobile** | < 768px | Single column, stacked buttons, full-width cards |
| **Tablet** | 768px - 1200px | 2-column grid where applicable |
| **Desktop** | > 1200px | 3-column grid, side-by-side forms |

---

## ♿ ACCESSIBILITY REQUIREMENTS

### WCAG 2.1 AA Compliance

- **Color Contrast:** Minimum 4.5:1 for text, 3:1 for UI components
- **Keyboard Navigation:** All interactive elements keyboard accessible
- **Screen Readers:** ARIA labels on all form fields and buttons
- **Focus Indicators:** Visible focus rings (2px solid primary color)
- **Error Messages:** Associated with form fields via `aria-describedby`

### ARIA Labels

```html
<!-- Form field -->
<label for="streetNumber">Street Number *</label>
<input 
  id="streetNumber" 
  aria-required="true"
  aria-describedby="streetNumber-error"
/>
<span id="streetNumber-error" role="alert">Error message</span>

<!-- Button -->
<button aria-label="Create new private listing">Create New Listing</button>

<!-- Status badge -->
<span role="status" aria-label="Private Listing">Private Listing</span>
```

---

## 🎯 FIGMA IMPORT INSTRUCTIONS

### Layer Structure

```
Figma File: PLS_RESO_Engine_Wireframes
├── Pages
│   ├── 01_My_Listings
│   ├── 02_Create_Listing
│   ├── 03_Edit_Listing
│   └── 04_Components
├── Components
│   ├── Button (Primary, Secondary, Danger, Ghost)
│   ├── Input (Text, Number, Select, Textarea)
│   ├── Card
│   ├── Badge
│   └── Progress_Indicator
└── Design System
    ├── Colors
    ├── Typography
    ├── Spacing
    └── Shadows
```

### Naming Convention

- **Frames:** `ScreenName_State` (e.g., `CreateListing_Step1`, `CreateListing_Error`)
- **Components:** `ComponentName_Variant` (e.g., `Button_Primary`, `Input_Text`)
- **Layers:** Descriptive names (e.g., `Header_Title`, `Form_StreetNumber_Input`)

### Auto-Layout Settings

- **Cards:** Auto-layout vertical, padding: 24px, gap: 16px
- **Form Sections:** Auto-layout vertical, padding: 24px, gap: 16px
- **Button Groups:** Auto-layout horizontal, gap: 12px
- **Photo Grid:** Auto-layout grid, gap: 16px

---

## 📝 REFERENCE DOCUMENTS

- **UI Specification:** `PLS_UI_SPECIFICATION_v1.md`
- **Contract:** `CONTRACT_PLS_to_GenieCloud_v6.1.md`

---

**Status:** ✅ Wireframe Specs Complete - Ready for Figma Import

**Next Action:** Import into Figma, create high-fidelity designs, get stakeholder approval.

