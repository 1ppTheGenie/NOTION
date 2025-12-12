# Genie Cloud System Documentation
**Internal Technical Documentation**  
**Version:** 1.0  
**Date:** November 15, 2025  
**Document Type:** System Architecture & Reverse Engineering

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [System Components](#system-components)
4. [Processing Flow](#processing-flow)
5. [API Endpoints Reference](#api-endpoints-reference)
6. [Component Deep Dives](#component-deep-dives)
7. [Data Flow Diagrams](#data-flow-diagrams)
8. [AWS Infrastructure](#aws-infrastructure)
9. [Deployment Procedures](#deployment-procedures)
10. [File Catalog](#file-catalog)

---

## Executive Summary

### Purpose
The Genie Cloud system is a comprehensive real estate marketing automation platform that generates personalized, branded marketing materials for real estate agents. The system transforms raw MLS data and market information into professional PDFs, landing pages, social media graphics, and direct mail pieces through an AWS-based serverless architecture.

### Key Capabilities
- **Automated Content Generation**: Creates market reports, listing presentations, and marketing materials on-demand
- **Multi-Format Output**: Produces PDFs, PNG/WebP images, HTML landing pages, and MP4 videos
- **Personalization Engine**: Applies agent branding, themes, and customization to all outputs
- **Scalable Architecture**: Serverless AWS infrastructure handles concurrent render requests
- **Real-Time Data Integration**: Pulls live MLS listings, market statistics, and geographic data

### Business Value
The platform enables real estate professionals to:
- Generate professional marketing materials in minutes instead of hours
- Maintain brand consistency across all marketing channels
- Access real-time market data for client presentations
- Create lead-capture landing pages with QR code integration
- Automate direct mail campaigns with personalized postcards and flyers

---

## Architecture Overview

### High-Level System Design

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER REQUEST (API Call)                      │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
                    ┌────────────────────┐
                    │   GENIE API        │
                    │   (AWS Lambda)     │
                    │   - Validation     │
                    │   - Cache Check    │
                    │   - Job Creation   │
                    └─────────┬──────────┘
                              ↓
                    ┌────────────────────┐
                    │   SQS QUEUE        │
                    │   (Message Broker) │
                    └─────────┬──────────┘
                              ↓
          ┌───────────────────┴───────────────────┐
          ↓                                       ↓
┌──────────────────────┐              ┌──────────────────────┐
│  GENIE PROCESSOR     │              │  GENIE API           │
│  (XSLT Transform)    │◄─────────────│  (Prepare Stage)     │
│  - XML to HTML       │              │  - Data Fetching     │
│  - Apply Templates   │              │  - Parameter Setup   │
└──────────┬───────────┘              └──────────────────────┘
           ↓                                       
           │  Triggers via S3 Event                
           ↓                                       
┌──────────────────────┐
│  GENIE RENDERER      │
│  (Puppeteer/Chrome)  │
│  - HTML to PDF       │
│  - Screenshot PNG    │
│  - Video Creation    │
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│   S3 STORAGE         │
│   + CloudFront CDN   │
│   - Final Assets     │
│   - Public URLs      │
└──────────────────────┘
```

### Technology Stack

**Backend Services:**
- **Runtime**: Node.js 18.x
- **AWS Lambda**: Serverless compute for all processing
- **AWS S3**: Object storage for assets, cache, and renders
- **AWS SQS**: Message queuing for asynchronous processing
- **AWS CloudFront**: CDN for content delivery

**Key Libraries:**
- **Saxon-JS**: XSLT 3.0 transformations (XML to HTML)
- **Puppeteer**: Headless Chrome for rendering
- **Sharp**: Image processing and optimization
- **pdf-lib**: PDF manipulation and merging
- **Luxon**: Date/time handling
- **SolidJS**: Frontend UI components

**Build Tools:**
- **Vite**: Frontend build system
- **esbuild**: JavaScript bundling for Lambda functions

---

## System Components

### Core Lambda Functions

#### 1. **genie-api** (v1.1.8g)
**Purpose**: Main API gateway and orchestration layer

**Key Responsibilities:**
- Validates incoming render requests
- Manages user authentication and impersonation
- Coordinates data fetching from Genie AI API
- Creates render jobs and queues them for processing
- Handles re-rendering and cache invalidation
- Provides utility endpoints (thumbnails, QR codes)

**Key Files:**
- `src/index.js`: Main API handler with routing logic
- `src/genieAI.js`: Integration with Genie AI backend
- `src/utils/cloudHubAPI.js`: Admin API endpoints
- `src/utils/embedsAPI.js`: Embed component API
- `src/utils/aws.js`: AWS service integrations

**Endpoints:** 20+ routes (detailed in API Reference section)

---

#### 2. **genie-processor** (XSLT Transformer)
**Purpose**: Transforms XML data into styled HTML using XSL templates

**Processing Flow:**
1. Receives JSON from S3 trigger (containing XML data and XSL path)
2. Loads XSL template from S3
3. Performs XSLT 3.0 transformation using Saxon-JS
4. Outputs HTML with embedded styles and data
5. Saves transformed HTML to S3
6. Triggers renderer for final output

**Key Features:**
- Supports 400+ XSL templates for different asset types
- Imports shared XSL components from `_xsl_imports/`
- Handles conditional rendering based on data availability
- Applies theming and brand customization

**Dependencies:**
- Saxon-JS (XSLT 3.0 processor)
- AWS SDK for S3 operations

---

#### 3. **genie-renderer** (Puppeteer Renderer)
**Purpose**: Converts HTML to final output formats (PDF, PNG, WebP, MP4)

**Rendering Capabilities:**
- **PDF Generation**: Uses Puppeteer's PDF engine with custom page sizes
- **Image Screenshots**: PNG/WebP with Sharp optimization
- **Multi-page PDFs**: Merges individual pages with pdf-lib
- **Video Creation**: Frame-by-frame rendering for MP4s

**Key Features:**
- Headless Chrome (Chromium layer for Lambda)
- Custom viewport and DPI settings
- Clipping and cropping support
- Watermarking for sample/unpermissioned content
- CloudFront cache invalidation

**Performance:**
- 15-second timeout per render
- Viewport dimensions: Configurable (default 1200x628)
- Device scale factor support for high-DPI outputs

---

### Frontend Applications

#### 4. **genie-components** (v2.5.9b)
**Purpose**: SolidJS-based embeddable components for landing pages and market reports

**Component Categories:**

**Embeds** (13 components):
- `FastFacts.jsx`: Key market statistics display
- `MarketActivity.jsx`: Active listings and market trends
- `MarketRadar.jsx`: Visual market health indicators
- `MarketTrending.jsx`: Price and inventory trends
- `MarketUpdate.jsx`: Comprehensive market overview
- `ListingMapStyleOne/Two.jsx`: Interactive listing maps
- `ListToSold.jsx`: Days on market analysis
- `LeadMarketIsShifting.jsx`: Lead capture with market insights
- `PeopleBuying.jsx`: Buyer activity metrics

**Core Components** (22 components):
- `AutoComplete.jsx`: Address search with predictions
- `LeadCaptureForm.jsx`: Contact form with validation
- `ListingsGrid/Table.jsx`: Property listing displays
- `LeafletMap.jsx`: Interactive maps with Leaflet.js
- `LineChart.jsx`: Data visualization
- `HomeValuation.jsx`: Property value estimator
- `DataPeriod/DataAccess.jsx`: Data controls

**Asset Management:**
- 24 CSS theme files
- SVG icons and graphics
- Font assets (77 files)
- Image library (333 files)

---

#### 5. **genie-collection-editor** (v1.2.12)
**Purpose**: Admin tool for creating and managing asset collections

**Functionality:**
- Create marketing "kits" (collections of related assets)
- Define page layouts and ordering
- Configure QR code destinations
- Set collection metadata and templates
- Export collection JSON files

**Current Collections:** 16 predefined kits
- Just Listed Kit
- Open House Kit
- Farm Domination Kit
- Market Report Kit
- Listing Command samples

---

#### 6. **genie-theme-editor**
**Purpose**: Visual editor for creating and managing CSS themes

**Features:**
- Live theme preview
- Color palette management
- Typography settings
- Export theme CSS files

**Theme Structure:**
- Base themes: Light and Dark variants
- Custom agent themes
- 95+ theme files in production

---

#### 7. **genie-monitor**
**Purpose**: System health monitoring and error tracking dashboard

**Monitoring Capabilities:**
- Real-time render status
- Error log viewing
- Performance metrics
- S3 storage utilization

---

#### 8. **genie-errors**
**Purpose**: Error visualization and debugging interface

**Features:**
- Parse and display error logs from S3
- Group errors by type and date
- Stack trace visualization
- Render parameter inspection

---

## Processing Flow

### Complete Render Pipeline

#### Stage 1: Request Initiation
```
User/System → POST /create
             ↓
Validation:
  - userId exists?
  - areaId OR mlsNumber provided?
  - asset/collection/pages specified?
  - area boundary size check
             ↓
Generate renderId (UUID)
Set theme defaults
Create S3 key structure
             ↓
Pre-cache Genie AI data:
  - User profile
  - MLS listing (if applicable)
  - Area information
  - Market statistics
             ↓
Save render.json to S3
Create lookup records
Queue 'prepare' message
             ↓
Return: {
  success: true,
  availableAt: "URL",
  reRender: "URL",
  renderId: "UUID"
}
```

#### Stage 2: Preparation (SQS → API /prepare)
```
Receive 'prepare' message
             ↓
Load render.json from S3
             ↓
If COLLECTION:
  ├─ Prepare collection template
  ├─ For each section:
  │   └─ For each asset in section:
  │       ├─ Resolve QR codes
  │       ├─ Generate asset params
  │       └─ Call prepareAsset()
             ↓
If SINGLE ASSET:
  └─ Load asset settings
      ├─ Determine pages (single or multi)
      ├─ Calculate dimensions
      ├─ Set output format (PDF/PNG/WebP/MP4)
      ├─ Generate download links (if applicable)
      └─ For each page:
          └─ Save {asset}-p{N}-prep.json to S3
             ↓
Create _lookup records for re-rendering
```

#### Stage 3: Processing (S3 Trigger → Processor /process)
```
S3 Event: {asset}-prep.json created
             ↓
Load prep.json
Load render.json
             ↓
Fetch render data:
  - Genie AI API calls
  - Market data
  - Listing information
  - Agent details
  - Geographic boundaries
             ↓
Build XML structure:
  <renderRoot>
    <output>
      <agent/>
      <area/>
      <market/>
      <listings/>
      <customizations/>
    </output>
  </renderRoot>
             ↓
XSLT Transformation:
  - Load XSL template from S3
  - Apply transformation with Saxon-JS
  - Inject theme CSS
  - Render conditional content
             ↓
Save transformed HTML to S3
Save {asset}-xslt.json (with HTML/params)
             ↓
Trigger renderer (next stage)
```

#### Stage 4: Rendering (S3 Trigger → Renderer)
```
S3 Event: {asset}-puppeteer.json created
             ↓
Launch Puppeteer/Chrome
Set viewport dimensions
             ↓
Load HTML from S3 URL
Wait for fonts/resources
             ↓
Based on output format:
  ├─ PDF: page.pdf() → Buffer
  ├─ PNG: page.screenshot() → Buffer
  ├─ WebP: screenshot() → Sharp → Buffer
  └─ MP4: Multiple screenshots → frames
             ↓
If MULTI-PAGE PDF:
  ├─ Save each page to /interim/
  ├─ Wait for all pages
  ├─ Merge with pdf-lib
  └─ Upload final PDF
             ↓
Upload to S3
Invalidate CloudFront cache
             ↓
Generate thumbnail (webp preview)
             ↓
Clean up temporary files
Return success
```

### Re-Render Process
```
Trigger: POST /re-render
Params: renderId OR userId OR areaId OR mlsNumber
             ↓
If userId/areaId/mlsNumber:
  ├─ Delete cached data
  ├─ Lookup all affected renderIds
  └─ Process each renderId below
             ↓
If renderId:
  ├─ Load original render.json
  ├─ Apply override params (if provided)
  ├─ Queue 'prepare' message
  └─ Trigger CloudFront invalidation
             ↓
System starts at Stage 2 (Preparation)
```

---

## API Endpoints Reference

### Base URL
- **Production**: `https://cloud-api.thegenie.ai/`
- **Format**: GET or POST (interchangeable)

### Core Endpoints

#### `/create`
**Purpose**: Creates a new render job

**Required Parameters:**
- `userId` (string): Genie AI user ID
- `areaId` (integer) OR `mlsNumber` (string): Location identifier

**Asset Selection** (one required):
- `asset` (string): Single asset path (e.g., "direct-mail/postcard-01")
- `collection` (string): Collection slug
- `pages` (array): Array of asset paths for PDF compilation
- `assets` (array): Multiple assets to render

**Optional Parameters:**
```javascript
{
  skipCache: false,              // Bypass cached data
  debug: false,                  // Enable debug logging
  ignoreBoundaryError: false,    // Skip area size validation
  
  // Output customization
  size: "facebook",              // Output dimensions
  theme: "_default-light",       // Visual theme
  additionalAgents: [],          // Co-agents to display
  
  // Map settings
  mapStyle: "satellite-streets-v9",
  mapIcon: "dot",
  mapKey: false,
  
  // Display options
  pricePercent: "percent",
  listingStatus: "all",
  listingCount: 10,
  withBleed: false,
  withCrops: false,
  blurPrice: false,
  hideAVM: false,
  
  // Landing page options
  requireSignin: false,
  customerName: null,
  isLeadCapture: false,
  downloadUrl: "",
  
  // Property customization
  propertyType: 0,               // 0=Homes, 1=Condos
  propertyCaption: null,
  propertyCaptionSingular: null,
  
  // Scheduling
  reRenderUntil: null            // Auto-refresh until date
}
```

**Response:**
```javascript
{
  success: true,
  availableAt: "https://genie-cloud.s3.../genie-pages/{renderId}/",
  reRender: "https://cloud-api.thegenie.ai/re-render?renderId={UUID}",
  renderId: "{UUID}",
  preCache: { /* cached data summary */ }
}
```

---

#### `/re-render`
**Purpose**: Triggers re-rendering of existing content

**Parameters** (one required):
- `renderId` (string): Re-render specific item
- `userId` (string): Re-render all user's content
- `areaId` (integer): Re-render all content for area
- `mlsNumber` (string): Re-render all content for listing

**Additional:**
- Any parameter from `/create` can be passed as override

**Response:**
```javascript
{
  success: true,
  msg: "5 re-renders underway. 12 cache items deleted.",
  reRenders: ["UUID1", "UUID2", "UUID3", "UUID4", "UUID5"]
}
```

---

#### `/get-assets`
**Purpose**: List all available asset templates

**Response:**
```javascript
{
  success: true,
  assets: [
    {
      id: "direct-mail/postcard-01",
      name: "Modern Market Update Postcard",
      category: "direct-mail",
      sizes: ["4x6", "6x9", "6x11"],
      supports: ["AsPDF", "WithBleed"],
      permission: null,
      defaultDownload: null
    }
    // ... 400+ assets
  ]
}
```

---

#### `/get-collections`
**Purpose**: List all available collection templates

**Response:**
```javascript
{
  success: true,
  collections: [
    {
      slug: "just-listed-kit",
      name: "Just Listed Marketing Kit",
      template: "just-listed-template",
      sections: [
        {
          name: "Social Media",
          assets: [/* array of asset configs */]
        }
      ]
    }
  ]
}
```

---

#### `/get-themes`
**Purpose**: List all CSS themes and metadata

**Response:**
```javascript
{
  success: true,
  themes: [
    {
      slug: "_default-light",
      name: "Default Light",
      colors: { primary: "#...", secondary: "#..." }
    }
  ]
}
```

---

#### `/thumbnail`
**Purpose**: Generate optimized image thumbnails

**Parameters:**
- `url` (string, required): Source image URL
- `width` (integer): Target width in pixels (default: 300)
- `height` (integer): Target height in pixels
- `quality` (integer): WebP quality 1-100 (default: 90)

**Response:** Base64-encoded WebP image

---

#### `/make-qrcode`
**Purpose**: Generate QR code SVG

**Parameters:**
- `url` (string): Destination URL for QR code

**Response:**
```javascript
{
  success: true,
  svg: "<svg>...</svg>",
  url: "s3://..."
}
```

---

#### `/log`
**Purpose**: Track asset access and trigger updates

**Parameters:**
- `renderId` (string)
- `assetId` (string)

**Response:**
```javascript
{
  success: true,
  renderId: "{UUID}"
}
```

---

#### `/cleanup-renders`
**Purpose**: Admin tool to cleanup old render files

**Parameters:**
- `userId` (string, required)

**Response:**
```javascript
{
  success: true,
  message: "Cleanup complete for user {userId}. 150 files deleted.",
  filesToDelete: [/* array of S3 keys */]
}
```

---

#### `/inspect-renders`
**Purpose**: Analyze render storage by user

**Response:**
```javascript
{
  success: true,
  message: "Processed 1500 render.json files",
  userAssetsData: [
    { userId: "...", assetCount: 250, assets: [] }
  ]
}
```

---

### Embed API Endpoints

**Base Path**: `/genie-embed/v2/`

These endpoints provide data for interactive components:
- Market statistics
- Active listings
- Sold listings
- Price trends
- Area comparisons

---

### Admin API Endpoints

**Base Path**: `/genie-admin/v2/`

Internal endpoints for:
- Asset management
- Collection management
- Theme administration
- User permissions

---

## Component Deep Dives

### 1. Asset Settings System

**Location**: `src/utils/render-data.js`

**Asset Configuration Structure:**
```javascript
{
  id: "asset-folder/asset-name",
  name: "Display Name",
  category: "direct-mail",
  
  sizes: ["4x6", "6x9", "6x11"],           // Available output sizes
  pages: [],                                // Sub-pages for multi-page assets
  
  supports: [                               // Feature flags
    "AsPDF",                                // Force PDF output
    "WithBleed",                            // Print bleed marks
    "WithCrops",                            // Crop marks
    "LeadCapture"                           // Includes form
  ],
  
  permission: "premium",                    // Access control
  defaultDownload: "asset-folder/download", // Companion download asset
  renderKey: "AREASLUG-PROPTYPE-REPORTDATE" // S3 path template
}
```

**Render Key Templates:**
- `REPORTDATE`: Current month/year (e.g., "Nov-2025")
- `AREASLUG`: Area name sanitized for URLs
- `PROPTYPE`: Property type caption (Homes/Condos)
- `MLSNUMBER`: Listing MLS number
- `LISTSTATUS`: Listing status (active/pending/sold)

---

### 2. Theme System

**Storage**: `public/_assets/themes/*.css`

**Theme Application Flow:**
1. User request specifies `theme` parameter
2. System checks for agent-specific theme in database
3. Falls back to `_default-light` or `_default-dark`
4. Theme slug split into name + hue (e.g., "luxury-dark" → "luxury" theme, "dark" hue)
5. CSS loaded and injected into XSLT transformation
6. Variables applied: colors, fonts, spacing

**Theme Structure:**
```css
:root {
  --primary-color: #1a73e8;
  --secondary-color: #34a853;
  --text-color: #202124;
  --background-color: #ffffff;
  --font-family-heading: 'Montserrat', sans-serif;
  --font-family-body: 'Open Sans', sans-serif;
}
```

---

### 3. Caching Strategy

**Cache Locations:**
- **S3 Standard**: `_cache/` folder
- **S3 Directory Bucket**: High-performance cache (fallback to Standard)

**Cache Keys:**
```javascript
{endpoint}-{userId}-{areaId}-{mlsNumber}-{params-hash}
```

**Cache TTLs:**
- User data: 36 hours
- Area boundaries: 36 hours
- Market statistics: 30 minutes
- MLS listings: 30 minutes
- Saved searches: 36 hours

**Cache Invalidation:**
- Automatic on `/re-render`
- Manual via `skipCache: true` parameter
- User-level: Deletes all cache for userId
- Area-level: Deletes all cache for areaId
- Listing-level: Deletes all cache for mlsNumber

---

### 4. QR Code Integration

**Use Cases:**
1. Print materials → Landing pages
2. Postcards → Property details
3. Signs → Virtual tours
4. Flyers → Lead capture forms

**Generation Process:**
1. Asset specifies `qrUrl` or `qrDestination`
2. API generates SVG QR code (qrcode-svg library)
3. QR saved to `genie-files/{renderId}/{asset}-qr.svg`
4. XSLT embeds QR in layout
5. QR points to final rendered landing page URL

---

### 5. Multi-Page PDF Assembly

**Process:**
1. Each page rendered independently as single-page PDF
2. Saved to `{s3Key}/interim/page-{N}.pdf`
3. Renderer monitors interim folder for completeness
4. When `totalPages` count reached:
   - Load all pages
   - Natural sort by page number
   - Merge with pdf-lib
   - Upload final merged PDF
   - Delete interim files

**Blank Page Handling:**
- XSLT can return "false" for `include-in-render` template
- Page marked with `-blank.txt` extension
- Excluded from final merge

---

### 6. Data Flow from Genie AI

**API Integration**: `src/genieAI.js`

**Key API Calls:**
```javascript
// User data
GET /GetUser/{userId}

// Listing data
GET /GetListing/{mlsId}/{mlsNumber}
GET /GetListingPhotos/{mlsId}/{mlsNumber}

// Area data
GET /GetArea/{areaId}
GET /GetAreaBoundary/{areaId}
GET /GetAreaSurrounding/{areaId}

// Market statistics
POST /GetMarketStats
POST /GetActiveListings
POST /GetSoldListings
POST /GetMarketTrends

// Address services
POST /GetAddressPredictions
POST /GetPlaceDetails
```

**Error Handling:**
- Fallback to cached data on API failure
- Graceful degradation (render with available data)
- Error logging to `_errors/` folder with full context

---

## Data Flow Diagrams

### High-Level Data Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL DATA SOURCES                     │
├─────────────────────────────────────────────────────────────┤
│  • Genie AI API (app.thegenie.ai)                           │
│    - User profiles & permissions                             │
│    - MLS listing data                                        │
│    - Market statistics                                       │
│    - Geographic boundaries                                   │
│                                                              │
│  • Third-party APIs                                          │
│    - Google Places (address lookup)                          │
│    - Mapbox (map tiles)                                      │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                     GENIE CLOUD CACHE                        │
├─────────────────────────────────────────────────────────────┤
│  S3 Bucket: genie-cloud/_cache/                             │
│  • Keyed by endpoint + params                                │
│  • TTL: 30min - 36hrs depending on data type                │
│  • Directory Bucket for high-frequency access                │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                   PROCESSING PIPELINE                        │
├─────────────────────────────────────────────────────────────┤
│  _processing/{renderId}/                                     │
│  ├─ render.json          [Master render configuration]      │
│  ├─ {asset}-p0-prep.json [Preparation params per page]      │
│  ├─ {asset}-p0-xslt.json [Transformed data + HTML]          │
│  └─ {asset}-p0-puppeteer.json [Render params]               │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                     FINAL OUTPUTS                            │
├─────────────────────────────────────────────────────────────┤
│  genie-files/{renderId}/     [Static assets: PDF/PNG/WebP]  │
│  genie-pages/{renderId}/     [Landing pages: HTML]          │
│  genie-collection/{renderId}/ [Multi-asset collections]     │
│                                                              │
│  Delivered via CloudFront CDN                                │
│  • Cache headers: max-age=30                                 │
│  • Automatic invalidation on update                          │
└─────────────────────────────────────────────────────────────┘
```

### Lookup System for Re-Rendering

```
_lookup/
├─ renders/              [All render IDs]
│   └─ {renderId}        [Empty marker file]
│
├─ users/                [Renders by user]
│   └─ {userId}/
│       └─ {renderId}    [Lookup marker]
│
├─ areas/                [Renders by area]
│   └─ {areaId}/
│       └─ {renderId}
│
├─ mlsNumber/            [Renders by listing]
│   └─ {mlsId}/{mlsNumber}/
│       └─ {renderId}
│
├─ asset/                [Renders by asset type]
│   └─ {asset-path}/
│       └─ {renderId}
│
└─ re-render/            [Recent re-render timestamps]
    └─ {renderId}
```

**Usage:**
- Fast lookup of all renders for a given user/area/listing
- Enables bulk re-rendering
- Tracking and analytics

---

## AWS Infrastructure

### S3 Bucket Structure

**Primary Bucket**: `genie-cloud` (US-West-1)

```
genie-cloud/
├─ _assets/                    [Static resources]
│   ├─ _css/                   [44 stylesheets]
│   ├─ _fonts/                 [77 font files]
│   ├─ _img/                   [333 images]
│   ├─ _js/                    [5 JavaScript libraries]
│   ├─ _mp3/                   [2 audio files]
│   ├─ _xsl/                   [400 XSL templates]
│   ├─ _xsl_imports/           [29 shared XSL components]
│   ├─ themes/                 [95 theme CSS files]
│   └─ landing-pages/          [Compiled landing page bundles]
│
├─ _cache/                     [API response cache]
│   └─ {cache-key-hash}.json
│
├─ _processing/                [Transient render data]
│   └─ {renderId}/
│       ├─ render.json
│       └─ {asset}-*.json
│
├─ _lookup/                    [Reverse lookup indexes]
│   ├─ users/
│   ├─ areas/
│   ├─ mlsNumber/
│   └─ asset/
│
├─ _errors/                    [Error logs by date]
│   └─ {YYYY-MM-DD}/
│       └─ {renderId}-{timestamp}-{type}.json
│
├─ genie-files/                [Rendered PDFs/images]
│   └─ {renderId}/
│       ├─ {theme}/
│       │   └─ {filename}.{pdf|png|webp}
│       └─ {asset}-qr.svg
│
├─ genie-pages/                [Landing pages]
│   └─ {renderId}/
│       ├─ {page-name}/
│       │   ├─ index.html
│       │   └─ -grab-0.webp   [Thumbnail]
│       └─ access.json         [Access tracking]
│
├─ genie-collection/           [Collections]
│   └─ {renderId}/
│       └─ index.html
│
└─ genie-tools/                [Admin tools]
    ├─ collection-editor/
    ├─ collections/            [Collection JSON files]
    └─ error-viewer/
```

### Lambda Functions Configuration

#### genie-api
- **Memory**: 1024 MB
- **Timeout**: 30 seconds
- **Layers**: AWS SDK v3
- **Triggers**: API Gateway (HTTP API)
- **Environment Variables**:
  - `BUCKET`: genie-cloud
  - `REGION`: us-west-1
  - `GENIE_URL`: https://app.thegenie.ai/api/Data/
  - `GENIE_USER`: genieApiHub2
  - `GENIE_PASS`: [encrypted]

#### genie-processor
- **Memory**: 512 MB
- **Timeout**: 60 seconds
- **Layers**: Saxon-JS
- **Triggers**: S3 Object Created (`*-prep.json`)
- **Environment Variables**:
  - `BUCKET`: genie-cloud
  - `TEMP_DIR`: /tmp/
  - `GENIE_URL`: S3 bucket URL

#### genie-renderer
- **Memory**: 3008 MB (max)
- **Timeout**: 90 seconds
- **Layers**: 
  - Chromium (v119)
  - Sharp (image processing)
- **Triggers**: S3 Object Created (`*-puppeteer.json`)
- **Environment Variables**:
  - `BUCKET`: genie-cloud
  - `SQS_QUEUE`: genie-renders
  - `CLOUDFRONT_DISTRIBUTION_ID`: [CloudFront ID]

### SQS Queue Configuration

**Queue Name**: `genie-renders`

**Message Types:**
1. `prepare`: Trigger asset preparation
2. `clear-cache`: Invalidate CloudFront cache
3. `genie-retry`: Retry failed renders (30s delay)

**Configuration:**
- Visibility Timeout: 120 seconds
- Message Retention: 4 days
- Dead Letter Queue: Enabled (after 3 retries)

### CloudFront Distribution

**Distribution ID**: [Production ID]

**Behaviors:**
- Default: S3 origin (genie-cloud bucket)
- Cache Policy: 
  - Headers: None
  - Query Strings: All
  - Cookies: None
- TTL: 30 seconds (for dynamic content)
- Compression: Enabled (Gzip, Brotli)

**Invalidation Strategy:**
- Automatic on file upload (renderer)
- Manual via `/re-render` endpoint
- Paths: `/{s3Key}` (specific file invalidation)

### IAM Roles & Permissions

#### genie_renderer Role
**Trusted Entity**: lambda.amazonaws.com

**Policies:**
- S3: GetObject, PutObject, DeleteObject, ListBucket
- SQS: SendMessage, ReceiveMessage, DeleteMessage
- CloudFront: CreateInvalidation
- CloudWatch: Logs (PutLogEvents, CreateLogStream)

#### genie_api Role
**Policies:**
- S3: Full access to genie-cloud bucket
- SQS: SendMessage to genie-renders queue
- Lambda: InvokeFunction (for internal calls)
- CloudWatch: Logs

---

## Deployment Procedures

### Prerequisites

**Required Tools:**
- AWS CLI v2
- Node.js 18.x
- npm or pnpm
- Git

**AWS Credentials:**
- Profile: `genie-hub-active`
- Region: `us-west-1`
- Account: 199352526440

### Deployment Scripts

#### 1. Deploy genie-api

```bash
cd genie-api

# Build and package
npm run preaws-us      # Builds and creates genie-api.zip

# Deploy to Lambda
npm run aws-us         # Updates Lambda function code
```

**Build Process** (`build.mjs`):
- Bundles with esbuild
- Resolves path aliases
- Minifies code
- Output: `build/index.js`

---

#### 2. Deploy genie-processor

```bash
cd genie-processor

# Build and package
npm run preaws         # Creates genie-xslt.zip

# Deploy to Lambda
npm run aws            # Updates Lambda function
```

---

#### 3. Deploy genie-renderer

```bash
cd genie-renderer

# Build and package
npm run preaws         # Creates genie-renderer.zip

# Deploy to Lambda
npm run aws            # Updates Lambda function
```

**Note**: Chromium layer must be pre-deployed (size limitations)

---

#### 4. Deploy Frontend Components

##### genie-components (Landing Pages)

```bash
cd genie-components

# Install dependencies
pnpm install

# Build for production
pnpm run build         # Outputs to dist/

# Deploy to S3
# (Manual or via CI/CD)
aws s3 sync dist/ s3://genie-cloud/public/_assets/landing-pages/ --profile genie-hub-active --region us-west-1
```

---

##### genie-collection-editor

```bash
cd genie-collection-editor

pnpm install
pnpm run build

# Deploy to S3
aws s3 sync dist/ s3://genie-cloud/public/genie-tools/collection-editor/ --profile genie-hub-active --region us-west-1
```

---

##### genie-theme-editor

```bash
cd genie-theme-editor

pnpm install
pnpm run build

# Deploy to S3
aws s3 sync dist/ s3://genie-cloud/public/genie-tools/theme-editor/ --profile genie-hub-active --region us-west-1
```

---

### Asset Deployment

#### Upload Static Assets

```bash
# Windows batch script
up-assets.bat          # Uploads _assets folder to S3
```

#### Upload Admin Tools

```bash
# Windows batch script
up-tools.bat           # Uploads genie-tools to S3
```

---

### Version Management

**Lambda Function Versions:**
- Each deployment creates a new version
- Alias `production` points to stable version
- Rollback by updating alias pointer

**Asset Versioning:**
- `public/_assets/version.txt` tracks deployment timestamp
- XSL templates versioned inline with comments
- Collections versioned in JSON (e.g., v1.2.12)

---

### Monitoring Post-Deployment

**CloudWatch Logs:**
```bash
# View API logs
aws logs tail /aws/lambda/GenieAPI --follow --profile genie-hub-active --region us-west-1

# View renderer logs
aws logs tail /aws/lambda/GenieRenderer --follow --profile genie-hub-active --region us-west-1

# View processor logs
aws logs tail /aws/lambda/GenieProcessor --follow --profile genie-hub-active --region us-west-1
```

**Health Checks:**
1. Test `/build-version` endpoint
2. Create test render with known data
3. Verify S3 uploads
4. Check CloudFront invalidation
5. Review error logs in S3

**Rollback Procedure:**
1. Identify last known good version
2. Update Lambda alias or redeploy previous code
3. Clear CloudFront cache if needed
4. Verify system functionality

---

## File Catalog

### Lambda Functions (3 core services)

| File Path | Purpose | Lines of Code | Key Dependencies |
|-----------|---------|---------------|------------------|
| `genie-api/src/index.js` | Main API handler & routing | 1,502 | AWS SDK, Luxon, jstoxml |
| `genie-api/src/genieAI.js` | Genie AI API integration | 690 | Caching system |
| `genie-api/src/utils/aws.js` | AWS service wrappers | ~500 | S3, SQS, CloudFront clients |
| `genie-api/src/utils/cloudHubAPI.js` | Admin API endpoints | ~300 | Asset management |
| `genie-api/src/utils/embedsAPI.js` | Embed component data | ~250 | Market data aggregation |
| `genie-api/src/utils/render-data.js` | Render data assembly | ~800 | Data transformation |
| `genie-processor/src/index.js` | XSLT transformation | 440 | Saxon-JS |
| `genie-renderer/src/index.js` | Puppeteer rendering | 460 | Puppeteer, pdf-lib, Sharp |

### Frontend Applications (7 apps)

| Application | Version | Components | Build Tool | Output |
|-------------|---------|------------|------------|--------|
| genie-components | 2.5.9b | 36 JSX files | Vite | Landing pages |
| genie-collection-editor | 1.2.12 | 8 components | Vite | Admin tool |
| genie-theme-editor | - | 4 components | Vite | Admin tool |
| genie-monitor | - | 2 components | Vite | Monitoring dashboard |
| genie-errors | - | 1 component | Vite | Error viewer |

### Asset Templates (400+ XSL files)

**Categories:**

| Category | Count | Description |
|----------|-------|-------------|
| Direct Mail | 75 | Postcards, flyers, brochures |
| Social Marketing Graphics | 85 | Facebook, Instagram posts |
| Report Pages | 82 | Market report pages |
| Report Pages (Letter) | 25 | Letter-sized reports |
| Landing Pages | 28 | Web pages with lead capture |
| Flyers | 35 | Property flyers |
| Area Insider Reports | 8 | Hyperlocal market reports |
| Charts | 4 | Data visualization |
| Banner Ads | 3 | Digital advertising |
| Collections | 6 | Multi-asset templates |

### Collections (16 predefined kits)

| Collection | Assets | Purpose |
|------------|--------|---------|
| just-listed-kit | 12 | Complete listing launch campaign |
| open-house-kit | 8 | Open house marketing materials |
| farm-domination-kit | 15 | Geographic farming campaign |
| market-report-kit | 10 | Market report distribution |
| listing-command-sample | 6 | Listing presentation |
| neighborhood-command-sample | 5 | Area expertise showcase |

### Static Assets

| Asset Type | Count | Location |
|------------|-------|----------|
| CSS Stylesheets | 44 | `_assets/_css/` |
| Fonts | 77 | `_assets/_fonts/` |
| Images | 333 | `_assets/_img/` |
| JavaScript Libraries | 5 | `_assets/_js/` |
| Audio Files | 2 | `_assets/_mp3/` |
| Theme CSS | 95 | `_assets/themes/` |
| XSL Imports | 29 | `_assets/_xsl_imports/` |
| SVG Icons | 134 | Various locations |

---

## Appendix A: Technology Decisions

### Why XSLT?
- **Separation of Concerns**: Data (XML) separate from presentation (XSL)
- **Powerful Templating**: Conditional logic, loops, functions
- **Version Control Friendly**: XSL files are text-based and diffable
- **Reusability**: Import shared components across templates
- **Industry Standard**: Well-documented, mature technology

### Why Puppeteer?
- **Accurate Rendering**: Uses real Chrome engine
- **PDF Fidelity**: Browser-native PDF generation
- **CSS Support**: Full modern CSS3 support
- **Fonts**: Accurate font rendering with anti-aliasing
- **Screenshots**: High-quality image capture

### Why Serverless?
- **Cost Efficiency**: Pay per render, not for idle servers
- **Scalability**: Automatic scaling to thousands of concurrent renders
- **Maintenance**: No server patching or management
- **Reliability**: AWS-managed infrastructure with built-in redundancy

### Why S3 for Processing State?
- **Trigger Mechanism**: S3 events naturally trigger Lambda functions
- **Durability**: Data persists even if Lambda fails
- **Debugging**: Can inspect intermediate files
- **Retry Logic**: Easy to re-process failed renders

---

## Appendix B: Common Issues & Solutions

### Issue: Render Timeout
**Symptoms**: Lambda timeout after 90 seconds

**Causes:**
- Complex XSLT transformation
- Large PDF (100+ pages)
- Slow API response from Genie AI

**Solutions:**
- Increase Lambda timeout (max 15 minutes for API)
- Break large PDFs into smaller batches
- Enable `skipCache: false` to use cached data

---

### Issue: Missing Data in Output
**Symptoms**: Blank sections or "N/A" values

**Causes:**
- API returned null/empty data
- Cache contains stale data
- Area boundary too large (API fails)

**Solutions:**
- Check `_errors/` folder for API failures
- Re-render with `skipCache: true`
- Use `ignoreBoundaryError: true` for large areas

---

### Issue: Font Rendering Issues
**Symptoms**: Wrong fonts or missing characters

**Causes:**
- Font not loaded by Puppeteer
- Font file corrupted in S3
- CSS font-family typo

**Solutions:**
- Verify font files in `_assets/_fonts/`
- Check XSLT includes correct font CSS
- Add `await page.evaluateHandle("document.fonts.ready")` in renderer

---

### Issue: CloudFront Serving Stale Content
**Symptoms**: Old version of asset displayed

**Causes:**
- Cache not invalidated
- Browser caching

**Solutions:**
- Trigger re-render (automatic invalidation)
- Manual invalidation: `POST /clear-cache`
- Hard refresh browser (Ctrl+Shift+R)

---

## Appendix C: Performance Benchmarks

**Typical Render Times:**

| Asset Type | Complexity | Avg Time | 95th Percentile |
|------------|------------|----------|-----------------|
| Single PDF (1 page) | Simple | 8 sec | 12 sec |
| Multi-page PDF (10 pages) | Medium | 25 sec | 40 sec |
| Landing Page HTML | Simple | 5 sec | 8 sec |
| Collection (15 assets) | Complex | 60 sec | 90 sec |
| Social Media PNG | Simple | 6 sec | 10 sec |

**Cost per Render:**
- Lambda execution: $0.002 - $0.008
- S3 storage: $0.0001
- CloudFront delivery: $0.0001
- API calls: $0
- **Total**: ~$0.003 per simple render

---

## Appendix D: Glossary

**Asset**: A single template (XSL file) that produces one output file

**Collection**: A group of related assets rendered together as a package

**Render**: The complete process from API request to final output

**RenderId**: Unique UUID identifying a specific render job

**XSLT**: eXtensible Stylesheet Language Transformations

**Puppeteer**: Headless browser automation library

**S3 Key**: Full path to an object in S3 bucket

**Theme**: CSS stylesheet defining colors, fonts, and visual style

**LPO**: Landing Page Optimization (specific landing page destination)

**AVM**: Automated Valuation Model (property value estimate)

**Bleed**: Extra image area beyond trim for printing

**Crop Marks**: Printer guides for cutting

**QR Code**: Quick Response code linking to digital content

**CloudFront**: AWS Content Delivery Network (CDN)

**SQS**: Simple Queue Service (AWS message queue)

**Lambda**: AWS serverless compute service

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-15 | Internal Team | Initial comprehensive documentation |

---

**End of Documentation**

For questions or updates, contact the development team.




