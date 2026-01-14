# PLS User Journey - Paisley Pre-Listing Focused Integration

**Version:** 1.0  
**Created:** 01/14/2026 4:30 AM  
**Last Updated:** 01/14/2026 4:30 AM  
**Author:** JR (Project Manager)  
**Status:** ✅ **USER JOURNEY SPECIFICATION**

---

## 🎯 EXECUTIVE SUMMARY

This document defines the **complete user journey** for PLS, showing:
1. **What we REUSE** from existing Paisley Pre-Listing Focused (ChatStartTypeId=3)
2. **Where we EXTEND** to add PLS listing creation functionality
3. **The complete flow** from property lookup to listing creation

---

## 📋 CURRENT PAISLEY PRE-LISTING FOCUSED JOURNEY (What We Reuse)

### Current Flow (ChatStartTypeId=3)

```
1. User navigates to Paisley
   ↓
2. User clicks "Pre-Listing Focused" button
   ↓
3. User enters property address (Google Places autocomplete)
   ↓
4. User selects address from dropdown
   ↓
5. System auto-fetches areas based on selected city
   ↓
6. User selects area (neighborhood/farm area)
   ↓
7. System generates Area Kit via GenieCloud (~20 seconds)
   - 7 Graphical Assets (Facebook Posts, Instagram Posts, Door Hangers, Flyers, Market Reports)
   - Collection URL: https://cloud.thegenie.ai/genie-collection/{GUID}
   ↓
8. System displays Quick Action Buttons:
   - Property Description (generates MLS-style description)
   - Coming Soon Package (flyer content, social ad, blog post, SMS)
   - Seller's Letter (personalized prospecting letter)
   - Market Stats (CMA-level analysis with real data)
   ↓
9. User clicks quick actions to generate content on-demand
   ↓
10. User copies/pastes generated content (no storage in system)
```

### What Paisley Pre-Listing Focused Does Well

| Feature | Current Implementation | Value |
|---------|----------------------|-------|
| **Property Lookup** | Google Places autocomplete | ✅ Reuse |
| **Area Selection** | Auto-fetches areas, user selects | ✅ Reuse |
| **Property Data** | Pre-populates from Attom Assessor data | ✅ Reuse |
| **AI Description** | ChatStartTypeId=3 generates descriptions | ✅ Reuse |
| **Market Stats** | Real area statistics (sales, prices, DOM) | ✅ Reuse |
| **GenieCloud Kit** | Generates 7 graphical assets | ✅ Reuse |
| **Quick Actions** | On-demand content generation | ✅ Reuse |

### Current Limitations

| Limitation | Impact | PLS Solution |
|------------|--------|--------------|
| **No Listing Storage** | Content is generated but not stored | ✅ PLS stores listing in database |
| **No PLS Number** | No unique identifier for pre-listing | ✅ PLS generates PLS100000A |
| **No Listing Command** | Can't trigger circle prospecting | ✅ PLS integrates with Listing Command |
| **No Status Management** | Can't track Coming Soon vs Private | ✅ PLS has StatusTypeID 6/14 |
| **No Listing CRUD** | Can't edit/update/archive | ✅ PLS has full CRUD operations |
| **No Persistent Assets** | Kit URL not linked to listing | ✅ PLS links collection URL to listing |

---

## 🚀 PLS EXTENDED JOURNEY (What We Add)

### Extended Flow (PLS Integration)

```
1. User navigates to Paisley "Pre-Listing Focused" (ChatStartTypeId=3)
   ↓
2. User enters property address (Google Places autocomplete) ← REUSE
   ↓
3. User selects address from dropdown ← REUSE
   ↓
4. System auto-fetches areas based on selected city ← REUSE
   ↓
5. User selects area (neighborhood/farm area) ← REUSE (CRITICAL for Listing Command)
   ↓
6. System pre-populates from TitleData + Historical MLS ← REUSE
   ↓
7. System auto-generates:
   - Mapbox satellite photo (property boundary overlay) ← NEW
   - Paisley AI description (ChatStartTypeId=3) ← REUSE
   ↓
8. User reviews pre-populated data, flags conflicts ← NEW
   ↓
9. User uploads photos (drag-and-drop, at least 1 required) ← NEW
   ↓
10. User selects status:
    - Coming Soon (StatusTypeID=14) ← NEW
    - Private Listing (StatusTypeID=6) ← NEW
   ↓
11. User clicks "Save & Create PLS Listing" ← NEW (replaces "just generate content")
   ↓
12. System creates PLS listing:
    - Generates PLS number (PLS100000A) ← NEW
    - Stores in MlsListing.dbo.Listing (MlsId=777) ← NEW
    - Stores in PlsListingOwnership table ← NEW
    - Stores photos in MlsListing.dbo.Photo ← NEW
   ↓
13. System generates XML per GenieCloud contract ← REUSE (but with PLS data)
   ↓
14. System triggers GenieCloud render ← REUSE
   ↓
15. System queues Listing Command (PropertyCastTypeId=4) ← NEW
   ↓
16. System displays:
    - PLS Number (PLS100000A) ← NEW
    - Collection URL (marketing assets) ← REUSE
    - "View Listing" button ← NEW
    - "Start Campaign" button (Listing Command) ← NEW
```

---

## 🔄 REUSE vs EXTEND Matrix

### ✅ REUSE (From Paisley Pre-Listing Focused)

| Component | Current Location | PLS Usage |
|-----------|-----------------|-----------|
| **Property Address Lookup** | Google Places autocomplete | Same - property selection |
| **Area Selection** | `POST /api/Data/GetAreaList` | Same - required for Listing Command |
| **Property Pre-Population** | `POST /api/Data/GetPropertiesFromPlaceKey` | Same - TitleData + Historical MLS |
| **Paisley AI Description** | `POST /api/paisley/chat` (ChatStartTypeId=3) | Same - generates description |
| **GenieCloud Asset Generation** | GenieCloud API | Same - but with PLS XML structure |
| **Market Stats Display** | Area statistics API | Same - shows market context |
| **UI Patterns** | Paisley chat interface | Reuse - step-by-step form wizard |

### 🆕 EXTEND (New PLS Functionality)

| Component | PLS Implementation | Purpose |
|-----------|-------------------|---------|
| **Listing Storage** | `MlsListing.dbo.Listing` (MlsId=777) | Store actual listing |
| **PLS Number Generation** | `usp_GetNextPlsNumber` → PLS100000A | Unique identifier |
| **Status Management** | StatusTypeID 6 (Private) or 14 (Coming Soon) | Track listing status |
| **Photo Upload** | S3 upload, store in `MlsListing.dbo.Photo` | Property photos |
| **Listing CRUD** | Full create/read/update/archive operations | Manage listings |
| **Listing Command Integration** | `ListingCommandQueue` (PropertyCastTypeId=4) | Circle prospecting |
| **Collection URL Linking** | Store collection URL with listing | Link assets to listing |
| **"My Listings" Page** | List all user's PLS listings | Manage multiple listings |

---

## 📊 SIDE-BY-SIDE COMPARISON

### Paisley Pre-Listing Focused (Current)

**Purpose:** Content generation tool  
**Output:** Marketing content (descriptions, social posts, flyers)  
**Storage:** None (user copies/pastes)  
**Workflow:** One-time content generation  
**Integration:** GenieCloud (assets only)

**User Journey:**
```
Property → Area → Generate Content → Copy/Paste → Done
```

### PLS (Extended)

**Purpose:** Listing creation system  
**Output:** Actual listing + marketing assets  
**Storage:** Database (MlsListing.dbo.Listing)  
**Workflow:** Create → Manage → Campaign → MLS (future)  
**Integration:** GenieCloud + Listing Command + Database

**User Journey:**
```
Property → Area → Create Listing → Manage → Campaign → Assets
```

---

## 🎯 KEY DIFFERENCES

### 1. Storage

| Aspect | Paisley Pre-Listing | PLS |
|--------|-------------------|-----|
| **Content Storage** | ❌ None | ✅ Database |
| **Listing Record** | ❌ None | ✅ MlsListing.dbo.Listing |
| **Photos** | ❌ None | ✅ MlsListing.dbo.Photo |
| **Ownership** | ❌ None | ✅ PlsListingOwnership |

### 2. Workflow

| Aspect | Paisley Pre-Listing | PLS |
|--------|-------------------|-----|
| **Purpose** | Generate content | Create listing |
| **Persistence** | One-time use | Persistent record |
| **Management** | ❌ Can't edit | ✅ Full CRUD |
| **Campaigns** | ❌ Manual | ✅ Automated (Listing Command) |

### 3. Integration

| Aspect | Paisley Pre-Listing | PLS |
|--------|-------------------|-----|
| **GenieCloud** | ✅ Assets only | ✅ Assets + Collection linked to listing |
| **Listing Command** | ❌ None | ✅ Automatic queue (PropertyCastTypeId=4) |
| **Database** | ❌ None | ✅ Full database integration |
| **Future MLS Push** | ❌ None | ✅ RESO Insert (future) |

---

## 🔧 IMPLEMENTATION STRATEGY

### Phase 1: Reuse Existing Paisley Components

**What to Reuse:**
1. Property address lookup (Google Places autocomplete)
2. Area selection (`POST /api/Data/GetAreaList`)
3. Property pre-population (`POST /api/Data/GetPropertiesFromPlaceKey`)
4. Paisley AI description generation (`POST /api/paisley/chat` with ChatStartTypeId=3)
5. GenieCloud asset generation (but with PLS XML structure)

**How to Reuse:**
- Call existing Paisley API endpoints
- Reuse UI components/patterns from Paisley
- Follow same data flow patterns

### Phase 2: Extend with PLS Functionality

**What to Add:**
1. PLS listing creation (`POST /api/pls/create`)
2. PLS number generation (`usp_GetNextPlsNumber`)
3. Photo upload (`POST /api/pls/upload-photo`)
4. Status selection (Coming Soon vs Private)
5. Listing storage (MlsListing.dbo.Listing)
6. Listing Command integration (PropertyCastTypeId=4)
7. "My Listings" page (`GET /api/pls/my-listings`)

**How to Add:**
- New PLS API endpoints
- New database tables (PlsListingOwnership, etc.)
- New UI components (PlsCreateComponent, PlsMyListingsComponent)
- Integration with Listing Command queue

---

## 📝 USER JOURNEY DETAILED STEPS

### Step 1-6: Property Lookup (REUSE from Paisley)

**Current Paisley Flow:**
1. User enters address → Google Places autocomplete
2. User selects address
3. System fetches areas
4. User selects area
5. System pre-populates property data
6. System generates Area Kit

**PLS Extension:**
- Same flow, but instead of just generating kit, we proceed to create listing

### Step 7-10: Listing Creation (NEW PLS)

**New PLS Steps:**
7. System auto-generates:
   - Mapbox satellite photo (NEW)
   - Paisley AI description (REUSE ChatStartTypeId=3)
8. User reviews pre-populated data, flags conflicts (NEW)
9. User uploads photos (NEW - at least 1 required)
10. User selects status: Coming Soon (14) or Private (6) (NEW)

### Step 11-16: Save & Generate (EXTENDED)

**Current Paisley:** User copies/pastes content, done

**PLS Extended:**
11. User clicks "Save & Create PLS Listing" (NEW)
12. System creates listing in database (NEW)
13. System generates XML (REUSE GenieCloud, but PLS structure)
14. System triggers GenieCloud render (REUSE)
15. System queues Listing Command (NEW)
16. System displays PLS number + collection URL (NEW)

---

## 🎨 UI/UX CONSIDERATIONS

### What to Keep from Paisley

- **Step-by-step wizard** - Users are familiar with this
- **Property lookup** - Same autocomplete experience
- **Area selection** - Same dropdown experience
- **Pre-population display** - Same data presentation
- **AI description** - Same generation experience

### What to Improve

- **Better visibility** - Make PLS creation option more prominent
- **Status selection** - Clear Coming Soon vs Private distinction
- **Photo upload** - Drag-and-drop (not in current Paisley)
- **Listing management** - "My Listings" page (not in current Paisley)
- **Campaign integration** - "Start Campaign" button (not in current Paisley)

---

## ✅ SUCCESS CRITERIA

### Reuse Success

- ✅ Property lookup works same as Paisley
- ✅ Area selection works same as Paisley
- ✅ Pre-population works same as Paisley
- ✅ AI description generation works same as Paisley
- ✅ GenieCloud assets generate same as Paisley

### Extension Success

- ✅ Listing stored in database with PLS number
- ✅ Photos uploaded and stored
- ✅ Status correctly set (6 or 14)
- ✅ Listing Command queue triggered
- ✅ Collection URL linked to listing
- ✅ "My Listings" page shows all user's PLS listings

---

## 📚 REFERENCE DOCUMENTS

- **Paisley Walkthrough:** `D:\Cursor\TheGenie.ai\Development\Paisley\PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md`
- **PLS Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 10
- **GenieCloud Contract:** `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md`
- **Database Schema:** `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/14/2026 4:30 AM | JR (Project Manager) | Initial user journey specification showing reuse from Paisley Pre-Listing Focused and PLS extensions. |
