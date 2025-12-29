# PLS ↔ GenieCloud Data Contract

**Version:** 3.0  
**Created:** 12/28/2025  
**Author:** Steve Hundley / Cursor AI  
**Last Updated:** 12/28/2025  
**Status:** SHARED CONTRACT - Owned by BOTH teams

---

## TABLE OF CONTENTS

1. [Purpose](#purpose)
2. [Architecture Overview](#architecture-overview)
3. [Responsibility Matrix](#responsibility-matrix)
4. [XML Data Structure](#xml-data-structure)
5. [Status Type Codes](#status-type-codes)
6. [API Endpoints](#api-endpoints)
7. [Validation Rules](#validation-rules)
8. [Error Handling](#error-handling)
9. [Theme + Hue Guidance](#theme--hue-guidance)
10. [User Role Requirements](#user-role-requirements)
11. [Testing Checklist](#testing-checklist)
12. [Collection System](#collection-system-critical-priority)
13. [CTA System](#call-to-action-cta-system-critical-priority)
14. [**Asset Selection System (HubAssetSetting)**](#asset-selection-system-hubasset-setting) ⭐ NEW
15. [Production References](#production-references)
16. [Document Locations](#document-locations)
17. [Change Log](#change-log)

---

## PURPOSE

This document defines the **data handshake** between PLS (Pre-Listing System) and GenieCloud (Asset Rendering Engine). It is the single source of truth for:

- XML data structure that PLS must provide
- Fields that GenieCloud expects to render assets
- Status codes and their meanings
- API endpoints for triggering renders
- Collection System architecture and UI requirements
- CTA System architecture and implementation
- **Asset Selection System (HubAssetSetting) - How orders get assigned to landing pages/collections** (NEW in v3.0)

**Both teams must agree on changes to this contract.**

---

## ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────┐      ┌─────────────────────────────────────┐
│           PLS DOMAIN                 │      │        GENIECLOUD DOMAIN            │
│                                      │      │                                      │
│  • Property data collection          │      │  • XSL template rendering            │
│  • Photo uploads                     │      │  • Theme application                 │
│  • Agent selection                   │      │  • PNG/PDF generation                │
│  • XML generation                    │      │  • S3 storage                        │
│  • Status management                 │      │  • Collection page creation          │
│                                      │      │                                      │
│  Owner: PLS Team                     │      │  Owner: GenieCloud Team (John/UK)    │
└──────────────────┬───────────────────┘      └──────────────────┬───────────────────┘
                   │                                              │
                   │         ┌─────────────────────────┐         │
                   └────────►│   XML DATA CONTRACT     │◄────────┘
                             │                         │
                             │  • Structure definition │
                             │  • Field requirements   │
                             │  • Status codes         │
                             │  • Validation rules     │
                             │                         │
                             │  Owner: BOTH TEAMS      │
                             └─────────────────────────┘
```

---

## RESPONSIBILITY MATRIX

| Responsibility | PLS Team | GenieCloud Team |
|---------------|:--------:|:---------------:|
| Collect property data | ✅ | |
| Upload photos to S3 | ✅ | |
| Generate XML data | ✅ | |
| Validate XML structure | ✅ | |
| Provide agent marketing data | ✅ | |
| Transform XML → HTML/SVG | | ✅ |
| Apply themes | | ✅ |
| Render PNG/PDF | | ✅ |
| Store rendered assets | | ✅ |
| Generate collection page | | ✅ |
| Define XML contract | ✅ | ✅ |
| Validate against contract | ✅ | ✅ |
| **Manage HubAssetSettings** | | **✅** |
| **Build Asset Selection UI** | **✅** | |

---

## XML DATA STRUCTURE

### Root Element

```xml
<renderRoot>
    <output ... />     <!-- Render settings -->
    <date ... />       <!-- Date period info -->
    <xslAsset>...</xslAsset>  <!-- Template to use -->
    <agents>...</agents>       <!-- Agent data -->
    <areas>...</areas>         <!-- Area/neighborhood data -->
    <single>...</single>       <!-- Property data -->
</renderRoot>
```

### Output Attributes (Required)

```xml
<output 
    apiUrl="https://cloud-api.thegenie.ai/"
    siteUrl="https://cloud.thegenie.ai/"
    year="2025"
    renderId="pls-{unique-id}"
    userId="{asp-user-id}"
    version="3.0.0"
    size="instagram-square"
    theme="apple-black"
    themeHue="light"
    propertyType="0"
    withBleed="false"
    withCrops="false"
    blurPrice="false"
    hideAVM="true"
    requireSignin="false"
    isLeadCapture="false"
/>
```

| Attribute | Type | Required | Description | PLS Provides |
|-----------|------|:--------:|-------------|:------------:|
| `userId` | UUID | ✅ | ASP.NET User ID | ✅ |
| `theme` | string | ✅ | CSS theme name | ✅ |
| `themeHue` | string | ✅ | `light` or `dark` | ✅ |
| `size` | string | ✅ | Asset dimensions | ✅ |
| `renderId` | string | ✅ | Unique render job ID | ✅ |
| `siteUrl` | URL | ✅ | Base URL for assets | ✅ |

### Agent Data (Required)

```xml
<agents>
    <agent>
        <firstName>Steve</firstName>
        <lastName>Hundley</lastName>
        <role>Listing Agent</role>
        <photo>https://imagedelivery.net/.../public</photo>
        <personalLogoLight>https://imagedelivery.net/.../user_logo_light</personalLogoLight>
        <personalLogoDark>https://imagedelivery.net/.../user_logo_dark</personalLogoDark>
        <companyLogoLight>https://imagedelivery.net/.../company_logo_light</companyLogoLight>
        <companyLogoDark>https://imagedelivery.net/.../company_logo_dark</companyLogoDark>
        <mobile>619.507.4404</mobile>
        <email>steve@inspired.re</email>
        <website>www.Inspired.RE</website>
        <agentId>{asp-user-id}</agentId>
        <marketingName>Steve Hundley</marketingName>
        <marketingTitle>Luxury Specialist</marketingTitle>
        <marketingLicense>TREC# 671645</marketingLicense>
        <address>
            <company>Inspired Real Estate, Inc</company>
            <street>123 Main St</street>
            <city>Boerne</city>
            <state>TX</state>
            <zip>78006</zip>
        </address>
    </agent>
</agents>
```

**CRITICAL - Logo URL Logic:**

The logo naming is **intentionally swapped** in production:

| XML Field | Actually Contains | Use On |
|-----------|-------------------|--------|
| `companyLogoLight` | DARK text logo | Light backgrounds |
| `companyLogoDark` | LIGHT/WHITE logo | Dark backgrounds |

PLS must fetch these dynamically using Marketing Image Type IDs:

```javascript
// Marketing Image Type IDs
photo: findImage(1),              // Profile Photo
personalLogoLight: findImage(2),  // ID 2 = dark logo
personalLogoDark: findImage(3),   // ID 3 = light logo
companyLogoLight: findImage(4),   // ID 4 = dark logo
companyLogoDark: findImage(6),    // ID 6 = light logo
```

### Property Data (Required)

```xml
<single>
    <mlsNumber>PLS-2025-00001</mlsNumber>
    <mlsId>0</mlsId>
    <price>749000</price>
    <salePrice></salePrice>
    <listed>12/25/2024</listed>
    <soldDate></soldDate>
    <daysOnMarket>0</daysOnMarket>
    <type>Home</type>
    <listingStatus>Private Listing</listingStatus>
    <listingAgent>Steve Hundley</listingAgent>
    <statusTypeID>6</statusTypeID>
    <description>Property description text...</description>
    <photoPrimary>https://.../.../front-of-home.jpg</photoPrimary>
    <squareFeet>3018</squareFeet>
    <lotSize>9101</lotSize>
    <acres>0.209</acres>
    <built>2022</built>
    <latitude>29.7221</latitude>
    <longitude>-98.6896</longitude>
    
    <bedrooms count="4"/>
    <bathrooms total="3" full="3" half="0"/>
    <parking spaces="3" garage="3"/>
    
    <address>
        <streetNumber>10037</streetNumber>
        <street>10037 Rebecca Place</street>
        <city>Boerne</city>
        <state>TX</state>
        <zip>78006</zip>
        <streetName>Rebecca Place</streetName>
    </address>
    
    <images>
        <image src="https://.../.../front-of-home.jpg"/>
        <image src="https://.../.../kitchen.jpg"/>
        <image src="https://.../.../living-room.jpg"/>
    </images>
</single>
```

**CRITICAL Format Requirements:**

| Field | Format | Example | Notes |
|-------|--------|---------|-------|
| `bedrooms` | Attribute | `<bedrooms count="4"/>` | NOT `<bedrooms>4</bedrooms>` |
| `bathrooms` | Attributes | `<bathrooms total="3" full="3" half="0"/>` | Multiple attributes |
| `images` | Child elements | `<image src="..."/>` | NOT just URLs |
| `statusTypeID` | Number | `6` | See Status Codes below |

---

## STATUS TYPE CODES

| StatusTypeID | Name | PLS Use | XSL Caption | XSL Color |
|:------------:|------|:-------:|-------------|-----------|
| 1 | Active | ❌ | "For Sale" | `--active-green` |
| 2 | Sold | ❌ | "Just Sold" | `--sold-red` |
| 3 | Pending | ❌ | "In Escrow" | `--pending-yellow` |
| **6** | **Private Listing** | **✅** | "Private Listing" | `--theme-emphasis-color` |
| **14** | **Coming Soon** | **✅** | "Coming Soon" | `--coming-soon-blue` |

**PLS should ONLY use StatusTypeID 6 or 14.**

---

## API ENDPOINTS

### Trigger Asset Render

```http
POST /api/render
Content-Type: application/json

{
    "listingId": "pls-2025-00001",
    "userId": "{asp-user-id}",
    "assets": [
        "social-marketing-graphics/lc-prop-post-03",
        "social-marketing-graphics/lc-prop-post-01-vip",
        "landing-pages/pls-hollywood"
    ],
    "theme": "apple-black",
    "themeHue": "light"
}
```

### Get Render Status

```http
GET /api/render/{renderId}/status

Response:
{
    "renderId": "pls-2025-00001",
    "status": "complete",
    "assets": [
        {
            "name": "lc-prop-post-03",
            "url": "https://cloud.thegenie.ai/genie-files/.../lc-prop-post-03.png"
        }
    ],
    "collectionUrl": "https://cloud.thegenie.ai/genie-collection/{id}"
}
```

---

## VALIDATION RULES

### PLS Must Validate Before Sending

| Rule | Field | Validation |
|------|-------|------------|
| Required | `userId` | Must be valid UUID |
| Required | `statusTypeID` | Must be 6 or 14 |
| Required | `price` | Must be positive integer |
| Required | `address/*` | All address fields required |
| Required | `photoPrimary` | Valid HTTPS URL |
| Format | `bedrooms` | Must use `count` attribute |
| Format | `bathrooms` | Must use `total`, `full`, `half` attributes |
| Format | `images/image` | Must use `src` attribute |

### GenieCloud Validates on Receive

| Rule | Action on Failure |
|------|-------------------|
| Missing required fields | Return 400 with field list |
| Invalid statusTypeID | Default to "Other" caption |
| Invalid image URLs | Show "PICTURE PENDING" |
| Missing theme | Default to "compass" |

---

## ERROR HANDLING

### Error Response Format

```json
{
    "error": true,
    "code": "VALIDATION_ERROR",
    "message": "Required field missing",
    "details": {
        "missingFields": ["statusTypeID", "price"]
    }
}
```

### Error Codes

| Code | Description | Owner to Fix |
|------|-------------|--------------|
| `VALIDATION_ERROR` | Missing/invalid fields | PLS |
| `USER_NOT_FOUND` | Invalid userId | PLS |
| `TEMPLATE_NOT_FOUND` | Invalid XSL path | GenieCloud |
| `RENDER_FAILED` | Puppeteer error | GenieCloud |
| `STORAGE_ERROR` | S3 upload failed | GenieCloud |

---

## THEME + HUE GUIDANCE

**For Social Ads (1080x1080):**
- Use `themeHue="light"` to get dark headers
- This is counterintuitive but correct

**For Landing Pages:**
- Use `themeHue="dark"` for dark mode pages
- Use `themeHue="light"` for light mode pages

---

## USER ROLE REQUIREMENTS

⚠️ **CRITICAL DISCOVERY:** User roles affect rendering!

### Roles That Work

| Role | Works? | Notes |
|------|:------:|-------|
| Broker Admin | ✅ | Full access |
| Agent | ✅ | Core agent plan |
| Agent Elite Plan | ✅ | Full marketing |
| MLS Demo User | ❌ | **Restricted** |

### Theme Availability

Themes are restricted by `HubThemeAvailability` table. PLS must ensure:

1. User has appropriate role
2. Theme is available to user's account
3. Logos are uploaded in Marketing Settings

---

## TESTING CHECKLIST

### PLS Team Before Handoff

- [ ] XML validates against contract structure
- [ ] `statusTypeID` is 6 or 14
- [ ] All required fields present
- [ ] Image URLs are accessible HTTPS
- [ ] User has correct role
- [ ] Logos uploaded in Marketing Settings

### GenieCloud Team on Receive

- [ ] XML parses successfully
- [ ] Theme CSS loads
- [ ] Images render (no "PICTURE PENDING")
- [ ] Status caption correct ("Private Listing")
- [ ] Logos display correctly
- [ ] Output dimensions correct (1080x1080)

---

## COLLECTION SYSTEM (CRITICAL PRIORITY)

> This section documents the Collection configuration system.

### The Problem

**No admin UI exists** for configuring which landing pages, CTAs, or social ads are included in a collection. Currently:

- Collections are JSON files stored in S3
- Location: `s3://genie-cloud/genie-tools/collections/{name}.json`
- Hardcoded behind the scenes - customers have no control

### Current Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     COLLECTION CONFIGURATION                              │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  1. COLLECTION TEMPLATES (XSL) - GenieCloud owns                         │
│     Location: _assets/_xsl/collections/                                   │
│     ├── default.xsl                                                       │
│     ├── farm-domination-kit.xsl                                           │
│     ├── just-listed-kit.xsl                                               │
│     ├── listing-command-proof.xsl                                         │
│     ├── marketing-steps-lc1.xsl                                           │
│     └── open-house-lc1.xsl                                                │
│                                                                           │
│  2. COLLECTION DEFINITIONS (JSON) - Currently no UI                       │
│     Location: S3 → genie-tools/collections/{name}.json                   │
│     - Defines which ASSETS are included                                   │
│     - Sections, sort order, descriptions                                  │
│     - Links to collection template (XSL)                                  │
│                                                                           │
│  3. API ENDPOINTS - GenieCloud owns                                       │
│     cloudHubAPI.js:                                                       │
│     - get-collections     → List all collections                          │
│     - save-collection     → Create/update collection                      │
│     - get-collection-templates → List XSL templates                       │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

### Example Collection JSON

```json
{
  "name": "Listing Command Proof Kit",
  "template": "listing-command-proof",
  "sections": {
    "social-ads": {
      "meta": { "caption": "Social Media Graphics" },
      "assets": [
        "social-marketing-graphics/lc-prop-post-01",
        "social-marketing-graphics/lc-prop-post-03"
      ]
    },
    "landing-pages": {
      "meta": { "caption": "Landing Pages" },
      "assets": ["landing-pages/lc-hollywood"]
    }
  }
}
```

### Required: Collection Manager UI

**Owner:** PLS Team (UI) + GenieCloud Team (API)

| Component | Owner | Status |
|-----------|-------|--------|
| UI Component (`CollectionManager.jsx`) | PLS | 🔴 NOT BUILT |
| API Endpoints | GenieCloud | ✅ Exist |
| Collection JSON Schema | BOTH | ✅ Defined above |
| Preview Mode | GenieCloud | 🔴 NOT BUILT |

---

## CALL-TO-ACTION (CTA) SYSTEM (CRITICAL PRIORITY)

> This section documents the CTA system architecture.

### The Problem

Current CTAs are high-friction forms (2-5% engagement). Need soft-touch CTAs (target 15-25%).

### CTA Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CTA SYSTEM                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  GenieCloud Components:                                                  │
│  ├── _LeadCtaTag.jsx         - Renders CTA popup                        │
│  ├── _LandingPages.jsx       - Triggers CTAs, manages window.gHub       │
│  ├── LeadCaptureForm.jsx     - Form component                           │
│  └── utils.js → getCtaData() - CTA configurations (IDs 1-11)           │
│                                                                          │
│  PLS Responsibilities:                                                   │
│  ├── Provide ctaId in render request                                    │
│  ├── Configure which CTA appears on which page                          │
│  └── Set trigger parameters (delay, scroll %, mobile banner)            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### CTA Data Contract

PLS passes CTA configuration to GenieCloud via render parameters:

```json
{
  "ctaId": 10,
  "ctaDelay": 3,
  "ctaScrollPercent": 50,
  "ctaShowMobileBanner": true
}
```

### Available CTA Options

| ID | Name | Friction | Target Engagement | Status |
|:--:|------|:--------:|:-----------------:|--------|
| 10 | Soft Follow (Tom Ferry) | LOW | 15-25% | 🔴 TO BUILD |
| 11 | Home Value Request | MEDIUM | 5-10% | 🔴 TO BUILD |
| 12 | Open House RSVP | MEDIUM | 10-15% | 🔴 TO BUILD |
| 13 | Private Showing Request | MEDIUM | 8-12% | 🔴 TO BUILD |
| 0 | No CTA | - | - | ✅ EXISTS |
| 2 | Home Value (Current) | HIGH | 2-5% | ✅ EXISTS |

### CTA 10: Soft Follow (Tom Ferry) - RECOMMENDED

**Flow:**
```
User clicks SMS link → Landing Page → CTA Popup ("Follow Us")
    ↓
Single click (NO FORM) → Engagement tracked
    ↓
Success + SMS Permission checkbox + Market Report download
    ↓
Week 1-3: Value SMS content (no ask)
    ↓
Week 4: Soft opt-in ask
```

---

## ASSET SELECTION SYSTEM (HubAssetSetting) ⭐

> **NEW IN v3.0** - This section documents HOW the backend decides which landing page/collection to render for each order. Critical for understanding why all LC SMS orders currently get the same landing page.

### The Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ASSET SELECTION DATA FLOW                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. ORDER CREATED (Listing Command, NC, etc.)                               │
│       │                                                                      │
│       ▼                                                                      │
│  2. WORKFLOW SELECTED (WorkflowId from PropertyCastWorkflow table)          │
│       │   • LC SMS = WorkflowId 6                                           │
│       │   • LC Facebook = WorkflowId 7                                      │
│       │   • LC Direct Mail = WorkflowId 8                                   │
│       │   • NC SMS = WorkflowId 11                                          │
│       │   • NC Direct Mail = WorkflowId 12                                  │
│       │                                                                      │
│       ▼                                                                      │
│  3. WORKFLOW ACTIONS EXECUTE (PropertyCastWorkflowAction table)             │
│       │   Each step has ConfigurationJson with settings                     │
│       │                                                                      │
│       ▼                                                                      │
│  4. "Queue Mapped HUB Asset Generation" STEP (ActionTypeId=21)              │
│       │   ConfigurationJson contains AssetMap array:                        │
│       │                                                                      │
│       │   {                                                                  │
│       │     "AssetMap": [                                                    │
│       │       {"ListingStatusId": 1, "HubAssetSettingId": 10},              │
│       │       {"ListingStatusId": 2, "HubAssetSettingId": 10},              │
│       │       {"ListingStatusId": 3, "HubAssetSettingId": 10}               │
│       │     ]                                                                │
│       │   }                                                                  │
│       │                                                                      │
│       ▼                                                                      │
│  5. HUBASSET SETTING LOOKUP (FarmGenie.dbo.HubAssetSetting table)           │
│       │   HubAssetSettingId=10 → Folder: landing-pages                      │
│       │                       → StyleSheet: property-compare                 │
│       │                       → AssetCollection: NULL (single asset)        │
│       │                                                                      │
│       ▼                                                                      │
│  6. OVERRIDE CHECK (FarmGenie.dbo.HubAssetSettingOverride table)            │
│       │   • Check for user-specific override (AspNetUserId match)           │
│       │   • Check for role-based override (RoleId match)                    │
│       │   • If found, use MapsToHubAssetSettingId instead                   │
│       │                                                                      │
│       ▼                                                                      │
│  7. GENIECLOUD API CALLED                                                   │
│       └── asset: "landing-pages/property-compare"                           │
│           OR                                                                 │
│           collection: "listing-command-sample" (if AssetCollection set)     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Database Tables

#### HubAssetSetting (FarmGenie)

```sql
-- This table defines ALL available assets/collections
CREATE TABLE HubAssetSetting (
    HubAssetSettingId INT PRIMARY KEY,
    Description NVARCHAR(255),          -- "LC Landing Default"
    Theme NVARCHAR(50),                  -- Optional theme override
    Folder NVARCHAR(100),                -- "landing-pages"
    StyleSheet NVARCHAR(100),            -- "property-compare"
    Size NVARCHAR(50),                   -- "landing-page"
    AssetCollection NVARCHAR(100),       -- "listing-command-sample" (or NULL)
    QrCode NVARCHAR(50),                 -- "skip" = no QR
    BlurPrice BIT,
    RequiresSignIn BIT,
    IsLeadCapture BIT,
    HideAvm BIT,
    -- ... other fields
    CreateDate DATETIME
);
```

#### Critical HubAssetSetting Records

| ID | Description | Type | Asset/Collection |
|----|-------------|------|------------------|
| 9 | LC Landing FB | Single Asset | `landing-pages/lc-hollywood` |
| **10** | **LC Landing Default** | **Single Asset** | `landing-pages/property-compare` |
| 15 | LC Landing Single Property | Single Asset | `landing-pages/lc-hollywood` |
| 20 | Just Listed Kit | Collection | `just-listed-kit` |
| 21 | Market Insider Kit | Collection | `market-report-kit` |
| **24** | **Listing Command Proofs Kit** | **Collection** | `listing-command-sample` |
| 53 | Neighborhood Command Proof | Collection | `neighborhood-command-sample` |

**⚠️ KEY INSIGHT:** LC SMS orders currently use HubAssetSettingId=10, which renders `property-compare`. To change the default landing page, we need to either:
1. Update the workflow ConfigurationJson
2. Create an override for specific users/roles

#### HubAssetSettingOverride (FarmGenie)

```sql
-- This table allows per-user or per-role customization
CREATE TABLE HubAssetSettingOverride (
    HubAssetSettingOverrideId INT PRIMARY KEY,
    HubAssetSettingId INT,           -- The DEFAULT being overridden
    MapsToHubAssetSettingId INT,     -- The NEW setting to use
    AspNetUserId NVARCHAR(128),      -- If set, applies to this user only
    RoleId INT,                       -- If set, applies to all users with role
    CreateDate DATETIME
);
```

#### Current Production Overrides

| Default | Maps To | Applies To | Purpose |
|---------|---------|------------|---------|
| 21 (Market Insider Kit) | 30 (Market Insider Kit Paisley+) | RoleId=7 (Ultimate) | Premium users get Paisley+ |
| 20 (Just Listed Kit) | 25 (Just Listed Kit Paisley+) | RoleId=7 (Ultimate) | Premium users get Paisley+ |

### Workflow Configurations

#### LC SMS Workflow (WorkflowId=6)

| Step | ActionType | HubAssetSettingId | Result |
|------|------------|-------------------|--------|
| 400 | Queue Mapped HUB Asset Generation | 10 | `property-compare` landing page |

#### LC Facebook Workflow (WorkflowId=7)

| Step | ActionType | HubAssetSettingId | Result |
|------|------------|-------------------|--------|
| TBD | Queue Mapped HUB Asset Generation | 9 | `lc-hollywood` landing page |

#### NC SMS Workflow (WorkflowId=11)

| Step | ActionType | HubAssetSettingId | Result |
|------|------------|-------------------|--------|
| TBD | Queue Mapped HUB Asset Generation | 21 | `market-report-kit` collection |

### Adding PLS Landing Page Support

To make `pls-hollywood` available for PLS orders:

**Step 1: Create HubAssetSetting**
```sql
INSERT INTO FarmGenie.dbo.HubAssetSetting 
(Description, Folder, StyleSheet, Size, AreaPeriod, WithBleed, WithCrop, 
 MapKey, MapIcon, MapStyle, BlurPrice, RequiresSignIn, IsLeadCapture, HideAvm, CreateDate)
VALUES 
('PLS Hollywood Landing', 'landing-pages', 'pls-hollywood', 'landing-page', 12, 0, 0,
 0, 'flag', 'satellite-v9', 1, 1, 1, 1, GETDATE());
-- Returns HubAssetSettingId (e.g., 70)
```

**Step 2: Create PLS Collection**
```sql
INSERT INTO FarmGenie.dbo.HubAssetSetting 
(Description, AssetCollection, AreaPeriod, WithBleed, WithCrop, 
 MapKey, MapIcon, MapStyle, HideAvm, CreateDate)
VALUES 
('PLS Proof Kit', 'pls-social-collection-v1', 12, 0, 0,
 0, 'flag', 'satellite-v9', 1, GETDATE());
-- Returns HubAssetSettingId (e.g., 71)
```

**Step 3: (Option A) Create Role-Based Override**
```sql
-- Give EliteAgent (RoleId=22) the PLS landing page
INSERT INTO FarmGenie.dbo.HubAssetSettingOverride
(HubAssetSettingId, MapsToHubAssetSettingId, RoleId, CreateDate)
VALUES (10, 70, 22, GETDATE());
```

**Step 3: (Option B) Create User-Specific Override**
```sql
-- Give specific user the PLS landing page
INSERT INTO FarmGenie.dbo.HubAssetSettingOverride
(HubAssetSettingId, MapsToHubAssetSettingId, AspNetUserId, CreateDate)
VALUES (10, 70, 'user-guid-here', GETDATE());
```

### Required: Asset Selection UI

**Current State:** No UI exists for customers or admins to select landing pages

**Future State:**

| Feature | Owner | Priority |
|---------|-------|----------|
| Order-time landing page dropdown | PLS Team | HIGH |
| Admin override manager | PLS Team | MEDIUM |
| User profile default preferences | PLS Team | LOW |
| Preview rendered asset | GenieCloud | MEDIUM |

**Proposed UI Location:** Listing Command checkout flow, before payment

```
┌─────────────────────────────────────────────────────────┐
│  LISTING COMMAND - STEP 3: CUSTOMIZE                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Landing Page Style: [▼ Property Compare (Default)    ] │
│                      ├── Property Compare              │
│                      ├── Hollywood (Listing Focused)   │
│                      └── PLS Hollywood (Private/CS)    │
│                                                          │
│  [Preview Landing Page]                                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Collection JSON Location

All collections are stored in S3:

```
s3://genie-cloud/genie-tools/collections/
├── listing-command-sample.json     ← LC Proof Kit
├── neighborhood-command-sample.json ← NC Proof Kit
├── market-report-kit.json          ← Market Insider Kit
├── market-report-kit-paisley-plus.json
├── just-listed-kit.json
├── just-listed-kit-paisley-plus.json
├── oh-marketing-kit.json
├── farm-domination-kit.json
├── pls-social-collection-v1.json   ← NEW for PLS
└── ...
```

---

## PRODUCTION REFERENCES

**Working Examples:**

| Example | Collection ID | Notes |
|---------|---------------|-------|
| Dainelle Scott | `15a521b8-3fbf-4042-bce3-58e378cd9a52` | Gold standard |
| Production Test | `49d3421e-e538-40c5-a54f-52218602f6db` | Full pipeline test |
| 10037 Rebecca PLS | `pls-10037-rebecca-place` | PLS MVP |

**URLs:**
- Collection: `https://cloud.thegenie.ai/genie-collection/{id}`
- Asset: `https://cloud.thegenie.ai/genie-files/{id}/{theme}/{asset}.png`
- PLS MVP: `https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html`

---

## DOCUMENT LOCATIONS

This contract is maintained in TWO locations:

1. **PLS Team:** `D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\Docs\CONTRACT_PLS_to_GenieCloud_v3.md`
2. **GenieCloud Team:** `D:\Cursor\_SourceCode\stage.geniecloud\CONTRACT_PLS_to_GenieCloud_v3.md`

**Any changes must be synced to both locations.**

---

## CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 3.0 | 12/28/2025 | Cursor AI | **MAJOR:** Added complete Asset Selection System (HubAssetSetting) section documenting: HubAssetSetting table structure, HubAssetSettingOverride mechanism, Workflow → AssetMap → HubAssetSettingId flow, SQL scripts for adding PLS landing pages, Future UI requirements for asset selection. Added Table of Contents. |
| 2.0 | 12/28/2025 | Cursor AI | Added Collection System section (architecture, JSON schema, UI requirements), Added CTA System section (architecture, 5 CTA options, tagging, mobile requirements) |
| 1.0 | 12/28/2025 | Cursor AI | Initial contract from discovery |

---

*This contract is the handshake between PLS and GenieCloud. Both teams must agree on changes.*

