# PLS (Pre-Listing System) - Master Specification

**Version:** 2.0  
**Created:** 12/28/2025  
**Author:** Steve Hundley / Cursor AI  
**Last Updated:** 12/28/2025  
**Status:** CONSOLIDATED - Single Source of Truth for PLS Development

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [System Context & Ecosystem](#2-system-context--ecosystem)
3. [Role & Permission System](#3-role--permission-system)
4. [PropertyCast Integration](#4-propertycast-integration)
5. [Database Design](#5-database-design)
6. [UI & Navigation](#6-ui--navigation)
7. [Feature Backlog by Phase](#7-feature-backlog-by-phase)
8. [Reference Tables](#8-reference-tables)
9. [Production Examples & References](#9-production-examples--references)
10. [Critical Technical Discoveries](#10-critical-technical-discoveries)
11. [XML Interface Specification](#11-xml-interface-specification)
12. [Dependencies & Next Steps](#12-dependencies--next-steps)
13. [Change Log](#13-change-log)

---

## 1. EXECUTIVE SUMMARY

| Element | Details |
|---------|---------|
| **Purpose** | Create a "Paisley Listing Service" (PLS) - a parallel listing database for Coming Soon and Private Listings that mimics MLS structure |
| **Business Goal** | Title Reps can offer agents the ability to market properties BEFORE they hit MLS |
| **Technical Goal** | Leverage existing ListingCommand/PropertyCast patterns to process PLS listings through the same workflow engine |
| **Key Insight** | PLS should behave like a new PropertyCastType (4) and use the same billing, SMS, asset generation infrastructure as Listing Command |
| **Status** | MVP Complete (10037 Rebecca Place). Ready for Phase 1 (XML Interface) development. |

### What PLS Delivers

- **Coming Soon Pages** - Pre-market listings with full marketing assets
- **Private Listing Pages** - Off-market/exclusive listings
- **XML Generator UI** - Web form to create listing data without manual editing
- **Asset Generation** - Social ads, brochures, landing pages via GenieCloud
- **Lead Capture** - Full integration with Engagement Center

### MVP Proof of Concept

| Field | Value |
|-------|-------|
| **Live URL** | [https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html](https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html) |
| **Property** | 10037 Rebecca Place, Boerne, TX 78006 |
| **Status** | Private Listing (StatusTypeID=6) |
| **Theme** | Compass Dark |
| **Status** | ✅ LIVE in Production |

---

## 2. SYSTEM CONTEXT & ECOSYSTEM

### 2.1 Ecosystem Position

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        THEGENIE.AI ECOSYSTEM                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐               │
│  │ TITLE GENIE  │    │   PAISLEY    │    │  ENGAGEMENT  │               │
│  │              │    │              │    │    CENTER    │               │
│  │ • Attom Data │───▶│ • AI Content │    │              │               │
│  │ • MLS Data   │    │ • Templates  │    │ • Lead Capture│              │
│  │ • Property   │    │ • 7 Chat Types│   │ • Notifications│             │
│  │   Research   │    │              │    │ • Workflows   │               │
│  └──────────────┘    └──────────────┘    └──────────────┘               │
│         │                   │                    ▲                       │
│         ▼                   ▼                    │                       │
│  ┌──────────────────────────────────────────────┴───────────┐           │
│  │              PRE-LISTING COMMAND (PLS)                    │           │
│  │                                                           │           │
│  │  • Coming Soon Pages      • PropertyCastType = 4          │           │
│  │  • Private Listing Pages  • PlsListing Database           │           │
│  │  • XML Generator UI       • Same workflow as LC           │           │
│  │  • Asset Generation       • Role-based Access             │           │
│  └───────────────────────────────────────────────────────────┘           │
│                                    │                                     │
│                                    ▼                                     │
│  ┌───────────────────────────────────────────────────────────┐           │
│  │                     GENIE CLOUD                            │           │
│  │  • XSL Templates  • Puppeteer Renderer  • S3 Storage      │           │
│  │  • PDF/PNG Gen    • Landing Pages       • Collections     │           │
│  └───────────────────────────────────────────────────────────┘           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Four System Integration Points

| System | What It Provides to PLS | What PLS Provides Back |
|--------|-------------------------|------------------------|
| **Title Genie** | Property data (Attom), MLS lookups | Property context for pre-listing |
| **Paisley** | AI content generation, description writing | Listing descriptions for assets |
| **Engagement Center** | Lead capture, UTM tracking, workflows | Lead sources from PLS pages |
| **GenieCloud** | XSL rendering, PDF/PNG generation | XML data, rendering requests |

### 2.3 Key Databases

| Database | Purpose | Key Tables |
|----------|---------|------------|
| **FarmGenie** | Main application | AspNetUsers, UserMarketingProfile, ListingCommandQueue, GenieLead |
| **MlsListing** | MLS data | Listing, StatusType, PropertyType |
| **TitleData** | Property data | AttomDataAssessor, ViewAssessor_v3 |
| **WHMCS** | Billing | tblclients, tblorders, tbltransactions |

### 2.4 Database Connection

```
Server: 192.168.29.45,1433 (or server-mssql1.istrategy.com)
Read-Only: cursor / 1ppINSAyay$
Write Access: sa / neo222
```

---

## 3. ROLE & PERMISSION SYSTEM

### 3.1 Permission Flow Architecture

```
USER LOGIN (AspNetUserId)
    ↓
LOOKUP ROLES (AspNetUserRoles)
    ↓
MAP ROLE → CHAT GROUP (ChatGroupRole)
    ↓
GET ALLOWED FEATURES (ChatStartChatGroup)
    ↓
FRONTEND DISPLAYS ONLY PERMITTED FEATURES
```

### 3.2 Key Permission Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `AspNetRoles` | Role definitions | RoleId, Name |
| `AspNetUserRoles` | User-to-role mapping | UserId, RoleId |
| `Permission` | All feature permissions | PermissionID, Description |
| `RolePermission` | Role-to-permission mapping | RoleID, PermissionID |

### 3.3 Roles That Can Use PLS

| Role | RoleId | Notes |
|------|--------|-------|
| Affiliate (Title Rep) | 2 | Primary target user |
| Affiliate Admin | 4 | Full access |
| Super User | 5 | Full access |
| Core Agent | 8 | Agent-level access |
| Elite Agent | 22 | Premium agent access |
| Genie Customer Service | 17 | Support access |

### 3.4 Proposed PLS Permissions

```sql
-- Insert new permissions for PLS
INSERT INTO FarmGenie.dbo.Permission (PermissionID, Description, Notes) VALUES
(210, 'ManagePLS', 'Allow user to create and edit PLS listings'),
(211, 'Menu PLS', 'Allows user to view PLS menu'),
(212, 'View PLS History', 'View past PLS listings'),
(213, 'PLS Radar', 'ADMIN - View PLS across all users'),
(214, 'PLS Submit While Impersonating', 'ADMIN - Create PLS for other users');
```

---

## 4. PROPERTYCAST INTEGRATION

### 4.1 Current PropertyCast Types

| PropertyCastTypeId | Name | Description |
|--------------------|------|-------------|
| 1 | Farm Cast | Circle prospecting around a property |
| 2 | Listing Command | Marketing campaign for MLS listings |
| 3 | Neighborhood Command | Farm marketing for an area |
| **4** | **PLS (NEW)** | **Paisley Listing Service** |

### 4.2 Pattern to Follow (From Listing Command)

From `ListingCommandBillingHandler.cs`:

1. Load queue item
2. Load billing record
3. Check if already processed (prevent double-charge)
4. Get WHMCS Client ID
5. Check for promo codes
6. Add order to WHMCS
7. Capture payment
8. Update billing record with success/failure

### 4.3 Status Types (Listing Statuses)

| StatusTypeID | Name | XSL Behavior | XSL Caption |
|--------------|------|--------------|-------------|
| 1 | Active | "For Sale" messaging | "For Sale" |
| 2 | Sold | "Just Sold" messaging | "Just Sold" |
| 3, 4, 12 | Pending | "In Escrow" messaging | "In Escrow" |
| **6** | **Private Listing** | **Private badge** | **"Private Listing"** |
| **14** | **Coming Soon** | **Coming Soon badge** | **"Coming Soon"** |

**⚠️ CRITICAL:** StatusTypeID 6 was NOT handled in original XSL templates - we had to add it. PLS should ONLY use StatusTypeID 6 or 14.

---

## 5. DATABASE DESIGN

### 5.1 Proposed Tables (In FarmGenie)

```sql
-- Main PLS Listing Table
CREATE TABLE FarmGenie.dbo.PlsListing (
    PlsListingId INT IDENTITY PRIMARY KEY,
    PlsNumber VARCHAR(50) NOT NULL,  -- 'PLS-2025-00001'
    StatusTypeId INT NOT NULL,        -- 6=Private, 14=ComingSoon
    AspNetUserId VARCHAR(128) NOT NULL,
    PropertyTypeId INT NOT NULL,
    
    -- Address fields
    StreetNumber VARCHAR(25),
    StreetName VARCHAR(250),
    City VARCHAR(50),
    State VARCHAR(2),
    Zip VARCHAR(5),
    
    -- Property details
    Bedrooms INT,
    BathroomsFull INT,
    BathroomsHalf INT,
    Sqft INT,
    YearBuilt INT,
    LotSqft INT,
    Acres DECIMAL(8,2),
    GarageSpaces INT,
    
    -- Pricing
    ListPrice INT,
    
    -- Geo
    Latitude DECIMAL(8,5),
    Longitude DECIMAL(8,5),
    
    -- Content
    Description NVARCHAR(MAX),
    PhotoPrimaryUrl VARCHAR(500),
    
    -- Additional Fields (from MVP)
    SchoolDistrict VARCHAR(100),
    Neighborhood VARCHAR(100),
    HomeCondition VARCHAR(50),  -- 'Like New', 'New Construction', etc.
    
    -- Metadata
    CreateDate DATETIME DEFAULT GETDATE(),
    UpdateDate DATETIME,
    PublishDate DATETIME,
    
    -- Link to MLS when converted
    ConvertedMlsNumber VARCHAR(50),
    ConvertedMlsId INT,
    ConvertedDate DATETIME
);

-- PLS Photos
CREATE TABLE FarmGenie.dbo.PlsListingPhoto (
    PlsListingPhotoId INT IDENTITY PRIMARY KEY,
    PlsListingId INT FOREIGN KEY REFERENCES PlsListing,
    PhotoUrl VARCHAR(500),
    DisplayOrder INT,
    IsPrimary BIT DEFAULT 0,
    CreateDate DATETIME DEFAULT GETDATE()
);

-- PLS Queue (mirrors ListingCommandQueue)
CREATE TABLE FarmGenie.dbo.PlsQueue (
    PlsQueueId INT IDENTITY PRIMARY KEY,
    AspNetUserId VARCHAR(128) NOT NULL,
    PlsListingId INT FOREIGN KEY REFERENCES PlsListing,
    StatusId INT DEFAULT 0,  -- 0=Queued, 1=Processing, 2=Complete, 3=Error
    ResponseCode INT,
    ResponseDesc VARCHAR(500),
    CreateDate DATETIME DEFAULT GETDATE(),
    ProcessedDate DATETIME
);

-- PLS Billing (mirrors ListingCommandBilling)
CREATE TABLE FarmGenie.dbo.PlsBilling (
    PlsBillingId INT IDENTITY PRIMARY KEY,
    PlsQueueId INT FOREIGN KEY REFERENCES PlsQueue,
    WhmcsClientId INT,
    WhmcsOrderId INT,
    WhmcsInvoiceId INT,
    Amount DECIMAL(10,2),
    PromoCode VARCHAR(50),
    Status INT DEFAULT 0,  -- 0=Pending, 1=Paid, 2=Failed
    CreateDate DATETIME DEFAULT GETDATE(),
    ProcessedDate DATETIME
);
```

### 5.2 Unique Identifier Format

**Format:** `PLS-{YEAR}-{SEQUENCE}`

Example: `PLS-2025-00001`

Components:
- `PLS` = Paisley Listing Service prefix
- `2025` = Year
- `00001` = Sequential 5-digit number (auto-increment)

---

## 6. UI & NAVIGATION

### 6.1 Dashboard Integration

```
GENIE DASHBOARD (Left Nav)
├── Dashboard
├── Leads
├── Areas
├── Campaigns
├── Reports
├── **Private Listings** ← NEW
│   ├── My Listings
│   ├── Create New
│   └── [Title Rep] My Agents' Listings
└── Settings
```

### 6.2 Role-Based Views

| Role | Can See |
|------|---------|
| Agent | Own listings only |
| Title Rep (Partner) | Sponsored agents' listings |
| SuperUser | All listings |
| InternalCS | All listings (read only) |

### 6.3 Mobile Considerations

- Responsive design (mobile-first)
- Touch-friendly inputs
- Photo upload from device camera
- Apple-inspired clean aesthetic (Apple Black theme)

---

## 7. FEATURE BACKLOG BY PHASE

### PHASE 1: XML Interface (Next Sprint) ⭐ PRIORITY

**Goal:** Web form to generate XML file without manual editing

| Feature | Priority | Complexity | Status |
|---------|----------|------------|--------|
| Property data input form | HIGH | Medium | ⏳ |
| Agent selector (from database) | HIGH | Medium | ⏳ |
| Photo uploader to S3 | HIGH | Medium | ⏳ |
| Area selector | HIGH | Low | ⏳ |
| Status selector (Coming Soon/Private) | HIGH | Low | ⏳ |
| Description writer (AI Paisley) | MEDIUM | Medium | ⏳ |
| XML preview/download | HIGH | Low | ⏳ |
| One-click deploy | HIGH | Medium | ⏳ |

### PHASE 2: Brochure Auto-Generation

**Goal:** Auto-generate PDF brochure when page is created

| Feature | Priority | Complexity |
|---------|----------|------------|
| Trigger genie-api render | HIGH | High |
| Use lc-brochure-01 XSL | HIGH | Low |
| Upload PDF to S3 | HIGH | Medium |
| Update downloadUrl in HTML | HIGH | Low |

### PHASE 3: Engagement Center Integration

**Goal:** Full lead tracking and workflow integration

| Feature | Priority | Complexity |
|---------|----------|------------|
| UTM parameter handling | HIGH | Medium |
| Source labeling | HIGH | Medium |
| CTA tagging | HIGH | Low |
| Lead data append (Versium) | MEDIUM | High |
| Text message routing | MEDIUM | Medium |
| Email notification | MEDIUM | Low |

### PHASE 4: Genie Navigation Integration

**Goal:** Access PLS from within TheGenie.ai interface

| Feature | Priority | Complexity |
|---------|----------|------------|
| Add PLS to agent dashboard | HIGH | Medium |
| List existing PLS pages | HIGH | Medium |
| Edit existing PLS page | MEDIUM | Medium |
| Delete/archive PLS page | LOW | Low |
| Analytics/views tracking | MEDIUM | High |

### PHASE 5: Advanced Features

| Feature | Priority | Complexity |
|---------|----------|------------|
| Multiple templates | LOW | Medium |
| Custom Theme Creation | HIGH | Medium |
| Open house scheduling | MEDIUM | Medium |
| Virtual tour embed | LOW | Low |
| Comparable properties | MEDIUM | High |

---

## 8. REFERENCE TABLES

### 8.1 PLS-Specific MLS Source

| MlsID | Name | DisplayName |
|-------|------|-------------|
| **999** | **PLS** | **Paisley Listing Service** |

### 8.2 PLS-Specific Permissions (Proposed)

| PermissionID | Name | Description |
|--------------|------|-------------|
| 210 | ManagePLS | Create/edit PLS listings |
| 211 | Menu PLS | View PLS menu |
| 212 | View PLS History | View past PLS listings |
| 213 | PLS Radar | ADMIN - View all PLS |
| 214 | PLS Submit While Impersonating | ADMIN - Create for others |

### 8.3 Lead Tag Types for PLS

| Tag | LeadTagTypeId | Purpose |
|-----|---------------|---------|
| CtaContactSubmit | 48 | CTA submitted |
| OptOut | 51 | User opted out |
| CtaContactVerified | 52 | Contact verified |
| **PlsLead (NEW)** | TBD | PLS-specific lead |

### 8.4 Theme Availability Table

The `HubThemeAvailability` table controls which themes a user can access:

```sql
-- Make Apple Black theme available to specific users
INSERT INTO FarmGenie.dbo.HubThemeAvailability 
(HubThemeId, AspNetUserId, CreateDate)
VALUES 
(@AppleBlackThemeId, 'user-guid-here', GETDATE());
```

---

## 9. PRODUCTION EXAMPLES & REFERENCES

### 9.1 Live PLS Example (Our MVP)

| Field | Value |
|-------|-------|
| **Live URL** | [https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html](https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html) |
| **Property** | 10037 Rebecca Place, Boerne, TX 78006 |
| **Agent** | Steve Hundley (Inspired Real Estate) |
| **Theme** | Compass Dark |
| **StatusTypeID** | 6 (Private Listing) |
| **Status** | ✅ LIVE |

### 9.2 Gold Standard Reference (Dainelle Scott Collection)

**THE reference for how assets should look:**

| Field | Value |
|-------|-------|
| **Collection URL** | [https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52](https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52) |
| **Property** | 28827 Balcones Crk, Boerne |
| **MLS** | 1917644 |
| **Theme** | Compass |
| **Collection ID** | 15a521b8-3fbf-4042-bce3-58e378cd9a52 |

#### Direct Asset URLs:

| Asset Type | URL |
|------------|-----|
| Social - Cash Buyers | [lc-prop-post-03.png](https://cloud.thegenie.ai/genie-files/15a521b8-3fbf-4042-bce3-58e378cd9a52/compass/lc-prop-post-03.png) |
| Social - Modern VIP | [lc-prop-post-01-vip.png](https://cloud.thegenie.ai/genie-files/15a521b8-3fbf-4042-bce3-58e378cd9a52/compass/lc-prop-post-01-vip.png) |
| Landing Page - Hollywood | [lc-hollywood](https://cloud.thegenie.ai/genie-pages/15a521b8-3fbf-4042-bce3-58e378cd9a52/lc-hollywood/index.html) |
| Market Report | [Market Insider PDF](https://cloud.thegenie.ai/genie-files/15a521b8-3fbf-4042-bce3-58e378cd9a52/compass/TheGenie-Market-Insider-Balcones-Creek-All-Neighborhoods-Homes-Dec-2025.pdf) |

### 9.3 Key Test User Accounts

| User | ASP User ID | Theme | Use Case |
|------|-------------|-------|----------|
| **Dainelle Scott** | 9f750957-4d66-4151-bd37-9588d17d4fb8 | compass | Production reference |
| **Ed Kaminsky** | 4865455f-29a0-4c8f-9938-8c4bab261ef6 | ed-kaminsky | High-volume agent |
| **Steve Hundley (TX)** | 2d0bd648-3f05-4e9a-bec9-1fb050d5170b | inspired-re | PLS test account |

---

## 10. CRITICAL TECHNICAL DISCOVERIES

**⚠️ HARD-WON LESSONS from the MVP build:**

### 10.1 StatusTypeID = 6 Was Missing

The XSL templates did NOT originally handle StatusTypeID=6 (Private Listing). We had to add:

```xml
<xsl:when test="number(//single/statusTypeID)=6">Private Listing</xsl:when>
```

**Impact:** Without this, private listings displayed as "Expired" - completely wrong.

### 10.2 Theme + Hue Paradox

**COUNTERINTUITIVE:** For social ads with dark headers, use `themeHue="light"`:

| Desired Visual | Set `themeHue` to |
|----------------|-------------------|
| Dark headers (social ads) | `light` |
| Dark background (landing pages) | `dark` |

### 10.3 XML Format for Beds/Baths/Images

**WRONG:**
```xml
<bedrooms>4</bedrooms>
<bathrooms>3</bathrooms>
```

**CORRECT:**
```xml
<bedrooms count="4"/>
<bathrooms total="3" full="3" half="0"/>
<images>
    <image src="https://...photo1.jpg"/>
</images>
```

### 10.4 Logo URL Naming is Swapped

**Production Reality:**

| XML Field | Actually Contains | Use On |
|-----------|-------------------|--------|
| `companyLogoLight` | DARK text logo | Light backgrounds |
| `companyLogoDark` | LIGHT/WHITE logo | Dark backgrounds |

Marketing Image Type IDs:
- ID 1 = Profile Photo
- ID 2 = Personal Logo Dark (appears light)
- ID 3 = Personal Logo Light (appears dark)
- ID 4 = Company Logo Dark (appears light)
- ID 6 = Company Logo Light (appears dark)

### 10.5 API Endpoint

**CORRECT:** `https://cloud-api.thegenie.ai/`

**DEPRECATED (DO NOT USE):** `genie-api.dynamicarray.co.uk`

### 10.6 Widget Data Spoofing

The PLS system requires "spoofing" another user's ID to pull live widget data:

```xml
<output userId="9f750957-4d66-4151-bd37-9588d17d4fb8" ... />
```

This uses Dainelle Scott's userId because she has active MLS data that populates widgets.

### 10.7 Theme Class in HTML

The body element MUST have correct classes:

```html
<body class="lc-hollywood pls-hollywood compass dark">
```

If you see blue/orange colors instead of black/white, check that `dark` is in the class list, not `light`.

---

## 11. XML INTERFACE SPECIFICATION

### 11.1 Required XML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<renderRoot>
    <output 
        apiUrl="https://cloud-api.thegenie.ai/"
        siteUrl="https://cloud.thegenie.ai/"
        userId="{asp-user-id}"
        theme="compass"
        themeHue="dark"
        size="instagram-square"
    />
    
    <agents>
        <agent>
            <firstName>Steve</firstName>
            <lastName>Hundley</lastName>
            <role>Listing Agent</role>
            <photo>https://imagedelivery.net/.../public</photo>
            <personalLogoLight>https://...</personalLogoLight>
            <personalLogoDark>https://...</personalLogoDark>
            <companyLogoLight>https://...</companyLogoLight>
            <companyLogoDark>https://...</companyLogoDark>
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
    
    <single>
        <mlsNumber>PLS-2025-00001</mlsNumber>
        <statusTypeID>6</statusTypeID>
        <listingStatus>Private Listing</listingStatus>
        <price>749000</price>
        <squareFeet>3018</squareFeet>
        <lotSize>9101</lotSize>
        <built>2022</built>
        <description>Property description...</description>
        <photoPrimary>https://.../.../front-of-home.jpg</photoPrimary>
        
        <bedrooms count="4"/>
        <bathrooms total="3" full="3" half="0"/>
        <parking spaces="3" garage="3"/>
        
        <address>
            <streetNumber>10037</streetNumber>
            <street>10037 Rebecca Place</street>
            <streetName>Rebecca Place</streetName>
            <city>Boerne</city>
            <state>TX</state>
            <zip>78006</zip>
        </address>
        
        <images>
            <image src="https://.../.../photo1.jpg"/>
            <image src="https://.../.../photo2.jpg"/>
        </images>
    </single>
</renderRoot>
```

### 11.2 Field Mapping from UI to XML

| UI Field | XML Element | Required | Notes |
|----------|-------------|:--------:|-------|
| Address | `<address>/*` | ✅ | All sub-fields required |
| List Price | `<price>` | ✅ | Integer, no formatting |
| Bedrooms | `<bedrooms count="X"/>` | ✅ | Attribute format |
| Bathrooms | `<bathrooms total="X" full="Y" half="Z"/>` | ✅ | All attributes |
| Square Feet | `<squareFeet>` | ✅ | |
| Year Built | `<built>` | ✅ | |
| Status | `<statusTypeID>` | ✅ | 6 or 14 only |
| Photos | `<images><image src="..."/></images>` | ✅ | `src` attribute |
| Description | `<description>` | ✅ | AI-generated option |

---

## 12. DEPENDENCIES & NEXT STEPS

### 12.1 Dependencies

| Dependency | Status | Owner |
|------------|--------|-------|
| GenieCloud team for render integration | ✅ Connected | GenieCloud/UK |
| StatusTypeID 6/14 XSL handling | ✅ Verified | - |
| CONTRACT_PLS_to_GenieCloud | ✅ Created | Both teams |
| Test database clone | ⏳ Needed | IT |
| WHMCS Product ID for PLS | ⏳ Needed | IT |
| Apple Black theme | ✅ Created | - |

### 12.2 Open Questions

1. **Database Location:** Should PlsListing tables go in FarmGenie (recommended) or MlsListing?
2. **Billing Model:** One-time purchase (like LC) or subscription (like NC)?
3. **Title Rep Flow:** Can Title Reps create on behalf of agents, or just enable?
4. **Conversion Workflow:** Manual MLS number entry or auto-detect by address?

### 12.3 Immediate Next Steps

1. ✅ Consolidate documentation (this document)
2. ✅ Create CONTRACT_PLS_to_GenieCloud
3. ✅ Build MVP proof of concept (10037 Rebecca Place)
4. ⏳ IT: Create test database clone
5. ⏳ IT: Create WHMCS Product ID for PLS
6. ⏳ Development: Begin Phase 1 (XML Interface UI)

---

## 13. CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/28/2025 | Cursor AI | Initial consolidated specification from multiple source documents |
| 2.0 | 12/28/2025 | Cursor AI | Added: Production Examples section, Critical Technical Discoveries, XML Interface Specification, MVP completion status, hard-won lessons from build |

---

## RELATED DOCUMENTS

| Document | Location | Purpose |
|----------|----------|---------|
| **CONTRACT_PLS_to_GenieCloud_v1.md** | Same folder + stage.geniecloud | Shared contract with GenieCloud team |
| **MASTER_PRODUCTION_REFERENCE_INDEX_v1.md** | Same folder | Live production example URLs |
| **PLS_Hollywood_Workspace_Memory_Log_v1.md** | Same folder | Session history |
| **SOP_PLS_Hollywood_MVP_Creation_v1.md** | Same folder | MVP creation steps |
| **GENIECLOUD_ASSET_DEVELOPMENT_v1.md** | stage.geniecloud | GenieCloud team's master doc |

---

## LOCAL FILE PATHS

| Component | Path |
|-----------|------|
| PLS Docs | `D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\Docs\` |
| GenieCloud Source | `D:\Cursor\_SourceCode\stage.geniecloud\` |
| XSL Templates | `D:\Cursor\_SourceCode\stage.geniecloud\public\_assets\_xsl\` |
| Theme CSS | `D:\Cursor\_SourceCode\stage.geniecloud\public\_assets\themes\` |
| Reference XML | `D:\Cursor\_SourceCode\stage.geniecloud\public\_assets\_reference\` |

---

*This is the SINGLE SOURCE OF TRUTH for PLS development. All other documents in this folder should reference this master spec.*


