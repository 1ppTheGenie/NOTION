# PLS ↔ GenieCloud Data Contract

**Version:** 4.0  
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
13. [**Genie Collection Editor (EXISTING TOOL)**](#genie-collection-editor-existing-tool) ⭐ NEW
14. [CTA System](#call-to-action-cta-system-critical-priority)
15. [Asset Selection System (HubAssetSetting)](#asset-selection-system-hubasset-setting)
16. [Production References](#production-references)
17. [Document Locations](#document-locations)
18. [Change Log](#change-log)

---

## PURPOSE

This document defines the **data handshake** between PLS (Pre-Listing System) and GenieCloud (Asset Rendering Engine). It is the single source of truth for:

- XML data structure that PLS must provide
- Fields that GenieCloud expects to render assets
- Status codes and their meanings
- API endpoints for triggering renders
- Collection System architecture and UI requirements
- **Genie Collection Editor - Existing standalone tool for managing collections** (NEW in v4.0)
- CTA System architecture and implementation
- Asset Selection System (HubAssetSetting) - How orders get assigned to landing pages/collections

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
│                                      │      │  • Collection Editor (standalone)    │
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
| **Collection Editor Tool** | | **✅ (Built)** |
| Define XML contract | ✅ | ✅ |
| Validate against contract | ✅ | ✅ |
| Manage HubAssetSettings | | ✅ |
| Build Asset Selection UI | ✅ | |
| **Integrate Collection Editor into Dashboard** | **✅** | |

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

### The Problem (SOLVED - See Next Section)

~~**No admin UI exists** for configuring which landing pages, CTAs, or social ads are included in a collection.~~ 

**UPDATE v4.0:** John has built a standalone Collection Editor tool! See next section.

Currently:

- Collections are JSON files stored in S3
- Location: `s3://genie-cloud/genie-tools/collections/{name}.json`
- ~~Hardcoded behind the scenes - customers have no control~~ → **Admin tool now exists**

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
│  2. COLLECTION DEFINITIONS (JSON) - ✅ EDITOR EXISTS                      │
│     Location: S3 → genie-tools/collections/{name}.json                   │
│     - Defines which ASSETS are included                                   │
│     - Sections, sort order, descriptions                                  │
│     - Links to collection template (XSL)                                  │
│                                                                           │
│  3. API ENDPOINTS - GenieCloud owns                                       │
│     Lambda URL (eu-west-2):                                              │
│     - get-collections     → List all collections                          │
│     - save-collection     → Create/update collection                      │
│     - get-assets          → List all XSL assets                          │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

### Example Collection JSON

```json
{
  "name": "Listing Command Proof Kit",
  "version": 3,
  "template": "listing-command-proof",
  "sections": [
    {
      "sort": 1,
      "name": "Listing Command Proof Kit",
      "meta": {
        "caption": "Automating your Listing Marketing Workflow!",
        "description": "You can choose any one of the postcards below."
      },
      "assets": [
        {
          "sort": 1,
          "asset": "direct-mail/qr-code-postcard-combine-2022-2",
          "name": "Stats & Pics Postcard",
          "qrUrl": "lc-hollywood"
        },
        {
          "sort": 2,
          "asset": "direct-mail/krg-double-photo-content-combine",
          "name": "Hungry Buyers Postcard",
          "qrUrl": "lc-hollywood"
        }
      ]
    },
    {
      "sort": 2,
      "name": "Social Media Assets",
      "assets": [
        {"sort": 1, "asset": "social-marketing-graphics/lc-prop-post-06", "name": "Simple"},
        {"sort": 2, "asset": "social-marketing-graphics/lc-prop-post-03", "name": "Cash Buyers"}
      ]
    },
    {
      "sort": 3,
      "name": "Landing Pages",
      "assets": [
        {"sort": 1, "asset": "landing-pages/lc-hollywood", "name": "FB/IG Property Landing"},
        {"sort": 2, "asset": "landing-pages/property-compare", "name": "QR Property Compare"}
      ]
    },
    {
      "sort": 4,
      "name": "Deliverables",
      "assets": [
        {"sort": 1, "asset": "area-insider-reports/market-insider", "name": "Market Insider Report"}
      ]
    }
  ]
}
```

---

## GENIE COLLECTION EDITOR (EXISTING TOOL) ⭐

> **NEW IN v4.0** - Discovery that John has already built a complete Collection Editor tool!

### 🎉 Tool Already Exists!

John (GenieCloud UK) has built a **complete, working Collection Editor** hosted on AWS Amplify.

### Access URLs

| Page | URL | Purpose |
|------|-----|---------|
| **Themes Browser** | [/themes](https://main.d2jn91nws05uwp.amplifyapp.com/themes) | Browse all 97 themes |
| **Collections List** | [/collections](https://main.d2jn91nws05uwp.amplifyapp.com/collections) | View/select collections to edit |
| **Collection Editor** | [/collections/{name}.json](https://main.d2jn91nws05uwp.amplifyapp.com/collections/listing-command-sample.json) | Edit a specific collection |
| **Assets Browser** | [/assets](https://main.d2jn91nws05uwp.amplifyapp.com/assets) | Browse all 400+ XSL assets |

**Base URL:** `https://main.d2jn91nws05uwp.amplifyapp.com`

### Features

| Feature | Status | Description |
|---------|:------:|-------------|
| List all collections | ✅ | Shows 30+ collection JSON files |
| Edit collection name | ✅ | Inline editing |
| Select template | ✅ | Dropdown of collection XSL templates |
| Add/remove sections | ✅ | "+ Section" button |
| Add/remove assets per section | ✅ | "+ Add Asset" button |
| Drag to reorder | ✅ | Sort order management |
| Raw JSON view | ✅ | Toggle to see/edit JSON directly |
| Save to S3 | ✅ | "Save" button persists changes |
| Duplicate collection | ✅ | Clone with new name |
| Reset changes | ✅ | Discard unsaved edits |
| Filter/search assets | ✅ | Quick find in 400+ assets |
| Browse themes | ✅ | View all 97 themes |

### Source Code Location

```
D:\Cursor\_SourceCode\stage.geniecloud\genie-collection-editor\
├── src/
│   ├── components/
│   │   ├── Collection.jsx      ← Main editor (name, template, sections)
│   │   ├── Collections.jsx     ← List view of all collections
│   │   ├── Section.jsx         ← Section editor (assets, metadata)
│   │   ├── Asset.jsx           ← Individual asset display
│   │   ├── NewAsset.jsx        ← Add new asset dialog
│   │   ├── Dropdown.jsx        ← Template selector
│   │   └── Editable.jsx        ← Inline edit component
│   ├── utilities/
│   │   ├── state.js            ← SolidJS store + API calls
│   │   ├── notify.js           ← Toast notifications
│   │   └── index.js            ← Exports
│   ├── assets/                  ← SVG icons
│   ├── index.jsx               ← App entry point
│   └── index.css               ← Styles
├── dist/                        ← Built version (deployed to Amplify)
├── settings.json               ← API endpoint config
├── package.json                ← SolidJS + Vite
└── vite.config.js              ← Build config
```

### Technology Stack

| Component | Technology |
|-----------|------------|
| Frontend Framework | **SolidJS** (not React) |
| Build Tool | Vite |
| Hosting | AWS Amplify |
| API Backend | AWS Lambda (eu-west-2) |
| Storage | S3 (genie-tools/collections/) |

### API Configuration

From `settings.json`:

```json
{
  "endpoint": "https://dqohcd54xpkdwnueu2wn2nkxge0aboae.lambda-url.eu-west-2.on.aws/"
}
```

### API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `get-collections` | POST | List all collection JSON files |
| `save-collection` | POST | Save collection to S3 |
| `get-assets` | POST | List all XSL assets |

### Integration Requirements

**Current State:** Standalone tool on Amplify - not integrated into Genie Dashboard

**To integrate into Dashboard:**

| Task | Owner | Priority |
|------|-------|----------|
| Port SolidJS → React (or embed as iframe) | PLS Team | HIGH |
| Add authentication/permissions | PLS Team | HIGH |
| Connect to user context | PLS Team | MEDIUM |
| Add per-user collection overrides | BOTH | MEDIUM |

### Available Collections (32 total)

From the Collections page:

- `area-marketing-postcards.json`
- `farm-domination-kit.json`
- `just-listed-kit.json`
- `just-listed-kit-paisley-plus.json`
- `listing-command-sample.json`
- `listing-command-sample-single-photo.json`
- `market-report-kit.json`
- `market-report-kit-paisley-plus.json`
- `neighborhood-command-sample.json`
- `neighborhood-command-sample-paisley-plus.json`
- `oh-marketing-kit.json`
- `pls-social-collection-v1.json` ← **PLS Collection**
- `razzle-dazzle-kit.json`
- ... and more

---

## CALL-TO-ACTION (CTA) SYSTEM (CRITICAL PRIORITY)

> This section documents the CTA system architecture with clear scope separation.

### The Problem

Current CTAs are high-friction forms (2-5% engagement). Need soft-touch CTAs (target 15-25%).

### Scope Separation (CRITICAL)

| Scope | Owner | Responsibilities |
|-------|-------|------------------|
| **CTA Design & Selection** | GenieCloud + Customer Configurator | Build amazing CTAs, configure which ones appear where, preview rendering |
| **CTA Execution & Tracking** | PLS/Genie Application Team | Engagement Center integration, UTM tracking, lead capture, Versium append |

### CTA Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              CTA SYSTEM ARCHITECTURE                                      │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                           │
│  ┌────────────────────────────────────────────────────────────────────────────────────┐  │
│  │              GENIECLOUD SCOPE (CTA Design & Selection)                              │  │
│  ├────────────────────────────────────────────────────────────────────────────────────┤  │
│  │                                                                                      │  │
│  │  CTA ASSETS (What They Look Like)         CTA TRIGGERS (When They Appear)           │  │
│  │  ├── Soft Follow Popup                    ├── Immediate (on page load)              │  │
│  │  ├── Home Value Modal                     ├── Delay (3s, 5s, 10s)                   │  │
│  │  ├── SMS Brochure Request                 ├── Scroll (25%, 50%, 75%)                │  │
│  │  ├── Schedule Showing                     ├── Exit Intent                           │  │
│  │  ├── Exclusive Preview CTA                └── Mobile Banner                         │  │
│  │  └── CTA Rotation / A/B Collection                                                  │  │
│  │                                                                                      │  │
│  │  Components:                                                                         │  │
│  │  ├── _LeadCtaTag.jsx         - Renders CTA popup                                    │  │
│  │  ├── _LandingPages.jsx       - Triggers CTAs, manages window.gHub                   │  │
│  │  ├── LeadCaptureForm.jsx     - Form component                                       │  │
│  │  └── utils.js → getCtaData() - CTA configurations (IDs 1-14)                       │  │
│  │                                                                                      │  │
│  └────────────────────────────────────────────────────────────────────────────────────┘  │
│                                        │                                                  │
│                                        ▼                                                  │
│  ┌────────────────────────────────────────────────────────────────────────────────────┐  │
│  │              PLS/GENIE APPLICATION TEAM SCOPE (Execution & Tracking)                │  │
│  ├────────────────────────────────────────────────────────────────────────────────────┤  │
│  │                                                                                      │  │
│  │  EXECUTION                           TRACKING                                        │  │
│  │  ├── Provide ctaId in render         ├── UTM parameters                             │  │
│  │  ├── Submit to Engagement Center     ├── LeadTagTypeId assignment                   │  │
│  │  ├── Trigger Versium append          ├── Source labeling                            │  │
│  │  └── SMS/Email delivery              └── Conversion attribution                     │  │
│  │                                                                                      │  │
│  └────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                           │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Deployment Paths

| Path | Trigger | Flow | Examples |
|------|---------|------|----------|
| **Automated (FarmCast)** | System event | Order → Workflow → SMS → Landing Page → CTA | Listing Command, Neighborhood Command, Comp Command |
| **Non-Automated (Static)** | Human distribution | Handout/QR → Landing Page → CTA | Door-to-door flyers, Open House, Print brochures |

Both paths use the **same CTA configuration** - only the entry point differs.

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

| ID | Name | Friction | Target Engagement | Status | Best For |
|:--:|------|:--------:|:-----------------:|--------|----------|
| 10 | Soft Follow (Tom Ferry) | LOW | 15-25% | 🔴 TO BUILD | All landing pages |
| 11 | Home Value Request | MEDIUM | 5-10% | 🔴 TO BUILD | Property Compare, NC |
| 12 | SMS Brochure Request | LOW | 10-15% | 🔴 TO BUILD | LC Hollywood, PLS |
| 13 | Private Showing Request | MEDIUM | 8-12% | 🔴 TO BUILD | LC, PLS Coming Soon |
| 14 | Get Notified | LOW | 12-18% | 🔴 TO BUILD | PLS Private/Coming Soon |
| 0 | No CTA | - | - | ✅ EXISTS | Testing, specific use |
| 2 | Home Value (Current Full Form) | HIGH | 2-5% | ✅ EXISTS | Legacy compatibility |

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

## ASSET SELECTION SYSTEM (HubAssetSetting)

> This section documents HOW the backend decides which landing page/collection to render for each order. Critical for understanding why all LC SMS orders currently get the same landing page.

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

### Collection JSON Location

All collections are stored in S3 and editable via the Collection Editor:

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
├── pls-social-collection-v1.json   ← PLS Collection
└── ... (32 total)
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
- **Collection Editor:** `https://main.d2jn91nws05uwp.amplifyapp.com/collections`

---

## DOCUMENT LOCATIONS

This contract is maintained in TWO locations:

1. **PLS Team:** `D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\Docs\CONTRACT_PLS_to_GenieCloud_v4.md`
2. **GenieCloud Team:** `D:\Cursor\_SourceCode\stage.geniecloud\CONTRACT_PLS_to_GenieCloud_v4.md`

**Any changes must be synced to both locations.**

---

## CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| **4.1** | **12/28/2025** | **Cursor AI** | **CTA SYSTEM EXPANSION:** Clarified scope separation (GenieCloud = Design & Selection, PLS/Genie App = Execution & Tracking). Added deployment paths (Automated via FarmCast vs Non-Automated/Static). Updated CTA architecture diagram with full scope breakdown. Added CTA ID 14 (Get Notified). Added "Best For" column to CTA options table. |
| 4.0 | 12/28/2025 | Cursor AI | Added complete Section 13 "Genie Collection Editor (EXISTING TOOL)" documenting John's standalone collection management app on AWS Amplify. Includes: Live URLs, feature list, source code location, tech stack, API endpoints, integration requirements. Updated Section 12 and Responsibility Matrix. |
| 3.0 | 12/28/2025 | Cursor AI | Added complete Asset Selection System (HubAssetSetting) section documenting: HubAssetSetting table structure, HubAssetSettingOverride mechanism, Workflow → AssetMap → HubAssetSettingId flow, SQL scripts for adding PLS landing pages. |
| 2.0 | 12/28/2025 | Cursor AI | Added Collection System section (architecture, JSON schema, UI requirements), Added CTA System section (architecture, 5 CTA options, tagging, mobile requirements) |
| 1.0 | 12/28/2025 | Cursor AI | Initial contract from discovery |

---

*This contract is the handshake between PLS and GenieCloud. Both teams must agree on changes.*

