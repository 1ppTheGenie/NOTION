# PLS (Pre-Listing System) - Master Specification

**Version:** 3.0  
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
6. [Status Types & MLS Sources](#6-status-types--mls-sources)
7. [Complete Permission Inventory](#7-complete-permission-inventory)
8. [Complete Role Inventory](#8-complete-role-inventory)
9. [UI & Navigation](#9-ui--navigation)
10. [Feature Backlog by Phase](#10-feature-backlog-by-phase)
11. [XML Interface Specification](#11-xml-interface-specification)
12. [GenieCloud Render Pipeline](#12-geniecloud-render-pipeline)
13. [Engagement Center Integration](#13-engagement-center-integration)
14. [Production Examples & References](#14-production-examples--references)
15. [Critical Technical Discoveries](#15-critical-technical-discoveries)
16. [Data Flow Diagrams](#16-data-flow-diagrams)
17. [**TITLE GENIE INTEGRATION (PRE-LISTING COMMAND)**](#17-title-genie-integration-pre-listing-command) ⭐ NEW
18. [Dependencies & Next Steps](#18-dependencies--next-steps)
19. [Change Log](#19-change-log)

---

## 1. EXECUTIVE SUMMARY

| Element | Details |
|---------|---------|
| **Purpose** | Create a "Paisley Listing Service" (PLS) - a parallel listing database for Coming Soon and Private Listings that mimics MLS structure |
| **Business Goal** | Title Reps can offer agents the ability to market properties BEFORE they hit MLS |
| **Technical Goal** | Leverage existing ListingCommand/PropertyCast patterns to process PLS listings through the same workflow engine |
| **Key Insight** | PLS should behave like Listing Command with a different PropertyCastType (4) and listing source (MlsId=999) |
| **Database Strategy** | Store PLS listings in `MlsListing.dbo.Listing` with `MlsId=999` to leverage existing infrastructure |
| **Status** | MVP Complete (10037 Rebecca Place). Ready for Phase 1 (XML Interface) development. |

### What PLS Delivers

- **Coming Soon Pages** - Pre-market listings with full marketing assets (StatusTypeID=14)
- **Private Listing Pages** - Off-market/exclusive listings (StatusTypeID=6)
- **XML Generator UI** - Web form to create listing data without manual editing
- **Asset Generation** - Social ads, brochures, landing pages via GenieCloud
- **Lead Capture** - Full integration with Engagement Center
- **Listing Lifecycle** - Track from PLS → Active MLS → Sold

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
│  │   Research   │    │ • ChatStart3 │    │ • Workflows   │               │
│  └──────────────┘    └──────────────┘    └──────────────┘               │
│         │                   │                    ▲                       │
│         ▼                   ▼                    │                       │
│  ┌──────────────────────────────────────────────┴───────────┐           │
│  │              PRE-LISTING COMMAND (PLS)                    │           │
│  │                                                           │           │
│  │  • Coming Soon Pages      • PropertyCastType = 4          │           │
│  │  • Private Listing Pages  • MlsListing.dbo.Listing        │           │
│  │  • XML Generator UI       • MlsId = 999                   │           │
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

### 2.2 Paisley Chat Types (Relevant for PLS)

From `EnumChatMessageRequirement`:

| ChatStartTypeId | Name | Data Requirement | PLS Relevance |
|-----------------|------|------------------|---------------|
| 1 | Area Statistics | Oculus API | Market data for widgets |
| 2 | MLS Listing | MLS API | NOT for PLS (no MLS data) |
| **3** | **Pre-Listing Focused** | **Assessor Property** | **PLS uses this - Attom data** |
| 4 | User Profile | FarmGenie DB | Agent marketing data |
| 7 | Listing Kit | GenieCloud | Asset generation |

**Key Insight:** ChatStartTypeId=3 (Pre-Listing Focused) uses **Assessor data, not MLS data** - perfect foundation for PLS descriptions!

### 2.3 Key Databases

| Database | Purpose | Key Tables for PLS |
|----------|---------|-------------------|
| **FarmGenie** | Main application | AspNetUsers, UserMarketingProfile, ListingCommandQueue, PlsListingOwnership |
| **MlsListing** | Listing data | Listing (MlsId=999), Photo, StatusType |
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
CHECK PERMISSIONS (RolePermission)
    ↓
FRONTEND CHECKS hasPermission(PermissionType.ManagePLS)
    ↓
SHOW/HIDE FEATURES ACCORDINGLY
```

### 3.2 Key Permission Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `AspNetRoles` | Role definitions | Id (varchar), Name |
| `AspNetRoleDetails` | Display names | RoleId, DisplayName, PartnerDescription |
| `AspNetUserRoles` | User-to-role mapping | UserId, RoleId |
| `Permission` | All feature permissions | PermissionID, Description, Notes |
| `RolePermission` | Role-to-permission mapping | RoleID, PermissionID |
| `UserCustomPermission` | Individual user overrides | UserId, PermissionID |

### 3.3 How to Add PLS to a Role (Admin UI)

1. Navigate to `/admin/permission` page
2. Select a role (e.g., "Affiliate")
3. Find the permission toggle (e.g., "ManagePLS")
4. Toggle ON = INSERT into RolePermission
5. Toggle OFF = DELETE from RolePermission

The frontend dynamically checks if the logged-in user's role has that permission.

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

### 3.5 Roles That Should Get PLS Access

| Role | RoleId | LC Access | PLS Access (Proposed) |
|------|--------|-----------|----------------------|
| Affiliate (Title Rep) | 2 | ✅ Full | ✅ Full |
| Affiliate Admin | 4 | ✅ Full | ✅ Full |
| Core Agent | 8 | ✅ Full | ✅ Full |
| Elite Agent | 22 | ✅ Full | ✅ Full |
| Ultimate Agent | 7 | ✅ Full | ✅ Full |
| Broker Admin | 18 | ✅ Full | ✅ Full |
| Super User | 5 | ✅ Full | ✅ Full |
| Genie Customer Service | 17 | ✅ Full | ✅ Full |

---

## 4. PROPERTYCAST INTEGRATION

### 4.1 Current PropertyCast Types

| PropertyCastTypeId | Name | Description | Billing |
|--------------------|------|-------------|---------|
| 1 | Farm Cast | Circle prospecting around a property | One-time |
| 2 | Listing Command | Marketing campaign for MLS listings | One-time |
| 3 | Neighborhood Command | Farm marketing for an area | Subscription |
| **4** | **PLS (NEW)** | **Paisley Listing Service** | **One-time (like LC)** |

### 4.2 Why PLS Uses Listing Command Pattern

- Both are **one-time purchases** per listing
- Both use the same **asset generation** (social, landing pages, brochures)
- Both feed into the same **SMS campaign infrastructure**
- Both create **GenieLead** records for lead capture
- PLS just uses **MlsId=999** instead of a real MLS source

### 4.3 ListingCommand Tables We Reuse

| Table | Purpose | How PLS Uses It |
|-------|---------|-----------------|
| `ListingCommandQueue` | Campaign queue | Same table, MlsId=999 |
| `ListingCommandListingSnapshot` | Listing JSON at queue time | Same table |
| `ListingCommandUserConfiguration` | User settings | Same table |
| `ListingCommandBilling` | Payment tracking | Same table |
| `SmsReportSendQueue` | SMS delivery | Reuse as-is |

### 4.4 Pattern to Follow (From ListingCommandBillingHandler.cs)

1. Load queue item
2. Load billing record
3. Check if already processed (prevent double-charge)
4. Get WHMCS Client ID
5. Check for promo codes
6. Add order to WHMCS
7. Capture payment
8. Update billing record with success/failure

---

## 5. DATABASE DESIGN

### 5.1 CRITICAL DECISION: MlsListing.dbo.Listing with MlsId=999

**NOT creating new tables for listings.** Instead:
- PLS listings go in `MlsListing.dbo.Listing` with `MlsId=999`
- This leverages the existing 94-column schema
- Photos go in `MlsListing.dbo.Photo`
- Ownership tracked in `FarmGenie.dbo.PlsListingOwnership`

**Why?**
- Listing Command already knows how to query `MlsListing.dbo.Listing`
- The `ListingCommandListingSnapshot` stores listing JSON - same format works
- Photo table structure already supports multiple photos per listing
- No changes needed to XSL templates - they read from same XML structure

### 5.2 New Table: PlsListingOwnership (FarmGenie)

```sql
-- Links users to their PLS listings (since MLS listings use agent email matching)
CREATE TABLE FarmGenie.dbo.PlsListingOwnership (
    PlsListingOwnershipId INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId NVARCHAR(128) NOT NULL,
    MlsId INT NOT NULL DEFAULT 999,
    MlsNumber VARCHAR(50) NOT NULL,  -- 'PLS-2025-00001'
    ListingId INT NOT NULL,           -- FK to MlsListing.dbo.Listing
    OwnershipTypeId INT NOT NULL DEFAULT 1,  -- 1=Creator, 2=CoAgent
    IsActive BIT NOT NULL DEFAULT 1,
    CreateDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastUpdate DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_PlsOwnership_User FOREIGN KEY (AspNetUserId) 
        REFERENCES FarmGenie.dbo.AspNetUsers(Id),
    CONSTRAINT UQ_PlsOwnership UNIQUE (AspNetUserId, MlsId, MlsNumber)
);
```

### 5.3 New Table: PlsNumberSequence (FarmGenie)

```sql
-- Generates unique PLS-YYYY-NNNNN numbers
CREATE TABLE FarmGenie.dbo.PlsNumberSequence (
    Year INT PRIMARY KEY,
    NextNumber INT NOT NULL DEFAULT 1,
    LastUpdate DATETIME NOT NULL DEFAULT GETDATE()
);

-- Stored procedure to get next PLS number
CREATE PROCEDURE dbo.usp_GetNextPlsNumber
AS
BEGIN
    DECLARE @Year INT = YEAR(GETDATE());
    DECLARE @NextNum INT;
    
    BEGIN TRANSACTION;
    
    IF NOT EXISTS (SELECT 1 FROM PlsNumberSequence WHERE Year = @Year)
        INSERT INTO PlsNumberSequence (Year, NextNumber) VALUES (@Year, 1);
    
    SELECT @NextNum = NextNumber FROM PlsNumberSequence WHERE Year = @Year;
    UPDATE PlsNumberSequence SET NextNumber = NextNumber + 1, LastUpdate = GETDATE() WHERE Year = @Year;
    
    COMMIT;
    
    SELECT 'PLS-' + CAST(@Year AS VARCHAR) + '-' + RIGHT('00000' + CAST(@NextNum AS VARCHAR), 5) AS PlsNumber;
END
```

### 5.4 Required Database Inserts

```sql
-- 1. Add Private Listing status type (DOES NOT EXIST - verified via query)
INSERT INTO MlsListing.dbo.StatusType (StatusTypeID, Name) 
VALUES (6, 'Private Listing');

-- 2. Add PLS as MLS source
INSERT INTO MlsListing.dbo.Mls (MlsID, ParserID, Name, DisplayName) 
VALUES (999, 0, 'PLS', 'Paisley Listing Service');

-- 3. Add PLS PropertyCastType
INSERT INTO FarmGenie.dbo.PropertyCastType (PropertyCastTypeId, Name) 
VALUES (4, 'PLS (Paisley Listing Service)');

-- 4. Add PLS permissions (see Section 3.4)
```

### 5.5 Unique Identifier Format

**Format:** `PLS-{YEAR}-{SEQUENCE}`

Example: `PLS-2025-00001`

- `PLS` = Paisley Listing Service prefix
- `2025` = Year
- `00001` = Sequential 5-digit number (auto-increment per year)

---

## 6. STATUS TYPES & MLS SOURCES

### 6.1 Current StatusType Table (MlsListing.dbo.StatusType)

**Verified via database query:**

| StatusTypeID | Name | PLS Use | Notes |
|--------------|------|:-------:|-------|
| 1 | Active | ❌ | Standard active listing |
| 2 | Sold | ❌ | Completed sale |
| 3 | Pending | ❌ | Under contract |
| 4 | Contingent | ❌ | Under contract with contingencies |
| 12 | Active With Contingency | ❌ | Active but with contingencies |
| 13 | Expired | ❌ | Listing expired without sale |
| 14 | Coming Soon | **✅** | Pre-market listing - **EXISTS** |
| **6** | **Private Listing** | **✅** | **NEEDS INSERT - Does NOT exist** |

### 6.2 PLS Status Lifecycle

```
PLS Created → Coming Soon (14) or Private Listing (6)
     │
     ↓ [Gets MLS approval / goes on market]
     │
Active (1) → Pending (3) → Sold (2)
```

User can change status at any time through the management UI.

### 6.3 MLS Sources (MlsListing.dbo.Mls)

**68 total MLS sources (IDs 0-107 with gaps)**

Key ones for reference:

| MlsID | Name | DisplayName |
|-------|------|-------------|
| 0 | Sandicor | San Diego MLS |
| 26 | NTREIS | North Texas Real Estate Info Systems |
| 68 | Sabor | San Antonio Board of Realtors |
| 82 | Austin | Austin Board of Realtors |
| **999** | **PLS (NEW)** | **Paisley Listing Service** |

---

## 7. COMPLETE PERMISSION INVENTORY

### 7.1 Listing Command Permissions (Pattern for PLS)

| PermissionID | Name | Description |
|--------------|------|-------------|
| 142 | ManageListingCommand | Submit listings to LC |
| 164 | Menu Listing Command | See LC in menu |
| 146 | View LC History | See past LC submissions |
| 147 | LC Radar | ADMIN - View all LC across users |
| 188 | LC Force Run | ADMIN - Kick off service run |
| 189 | LC Submit While Impersonating | ADMIN - Submit for other users |

### 7.2 Proposed PLS Permissions (Mirroring LC)

| PermissionID | Name | Description |
|--------------|------|-------------|
| 210 | ManagePLS | Create/edit PLS listings |
| 211 | Menu PLS | View PLS menu |
| 212 | View PLS History | View past PLS listings |
| 213 | PLS Radar | ADMIN - View all PLS |
| 214 | PLS Submit While Impersonating | ADMIN - Create for others |

### 7.3 Related Permission Categories

| Category | Key Permissions |
|----------|-----------------|
| **Dashboard** | 3 (Dashboard), 95 (HubDashboard) |
| **Marketing** | 143 (ManageMarketingProfile), 208 (Menu Marketing) |
| **My Listings** | 166 (Menu My Listings), 177 (Actions), 178 (Customize) |
| **Paisley** | 171 (ChatGPT), 174 (Quick Actions), 175 (Chat Input) |
| **Lead Center** | 77 (Lead Center), 81 (View Lead Property) |
| **User Management** | 1 (Create User), 13 (Impersonate User) |

---

## 8. COMPLETE ROLE INVENTORY

### 8.1 Agent Roles

| RoleId | Name | DisplayName | Can Use LC | PLS Access (Proposed) |
|--------|------|-------------|:----------:|:---------------------:|
| 1 | Emerging Agent | Agent - Open House Plan | Menu Only | Menu Only |
| 8 | Core Agent | Core Agent | ✅ Full | ✅ Full |
| 12 | Established Agent | Agent - Engagement Plan | Menu Only | Menu Only |
| 7 | Ultimate Agent | Agent - Lead Generation Plan | ✅ Full | ✅ Full |
| 22 | Elite Agent | Agent - Elite Plan | ✅ Full | ✅ Full |
| 10 | Agent No Access | Agent Invited | ❌ | ❌ |

### 8.2 Affiliate Roles (Title Reps) - PRIMARY TARGET

| RoleId | Name | DisplayName | Can Use LC | PLS Access (Proposed) |
|--------|------|-------------|:----------:|:---------------------:|
| 2 | Affiliate | Affiliate | ✅ Full | ✅ Full |
| 6 | Affiliate (Beta User) | Affiliate (Beta User) | ✅ Full | ✅ Full |
| 4 | Affiliate Admin | Affiliate Admin | ✅ Full | ✅ Full |
| 3 | Affiliate Territory Admin | Affiliate Territory Admin | ✅ Full | ✅ Full |
| 27 | Affiliate Limited | Affiliate Limited | Limited | Limited |
| 16 | Affiliate No Access | Affiliate No Access | ❌ | ❌ |

### 8.3 Broker Roles

| RoleId | Name | DisplayName | Can Use LC | PLS Access (Proposed) |
|--------|------|-------------|:----------:|:---------------------:|
| 14 | Broker | Broker | Menu Only | Menu Only |
| 18 | Broker Admin | Broker Admin | ✅ Full | ✅ Full |
| 15 | Broker No Access | Broker No Access | ❌ | ❌ |

### 8.4 Internal / Admin Roles

| RoleId | Name | DisplayName | Can Use LC | PLS Access (Proposed) |
|--------|------|-------------|:----------:|:---------------------:|
| 5 | Super User | Super User | ✅ Full | ✅ Full |
| 17 | Genie Customer Service | Genie Customer Service | ✅ Full | ✅ Full |
| 29 | Genie Customer Service Admin | Genie Customer Service Admin | ✅ Full | ✅ Full |
| 28 | Genie Business Admin | Genie Business Admin | ✅ Full | ✅ Full |
| 20 | Genie Sales Team | Genie Sales Team | View Only | View Only |

---

## 9. UI & NAVIGATION

### 9.1 Dashboard Integration

```
GENIE DASHBOARD (Left Nav)
├── Dashboard
├── Leads
├── Areas
├── Campaigns
├── Reports
├── My Listings
├── **Private Listings** ← NEW (requires Menu PLS permission)
│   ├── My Listings
│   ├── Create New
│   └── [Title Rep] My Agents' Listings
└── Settings
    └── Marketing Settings
```

### 9.2 Proposed Angular Routes

```typescript
// pls.routing.ts
const routes: Routes = [
  {
    path: 'pls',
    canActivate: [FgPermissionGuard],
    data: { permissions: [PermissionType.ManagePLS] },  // 210
    children: [
      { path: 'create', component: PlsCreateComponent },
      { path: 'edit/:plsNumber', component: PlsEditComponent },
      { path: 'my-listings', component: PlsMyListingsComponent },
      { path: 'initiate/:plsNumber', component: ListingCommandInitiateComponent },  // REUSE LC!
    ]
  }
];
```

### 9.3 Role-Based Views

| Role | Can See |
|------|---------|
| Agent | Own listings only |
| Title Rep (Affiliate) | Own + sponsored agents' listings |
| Broker Admin | Own + brokerage agents' listings |
| SuperUser / CS | All listings |

---

## 10. FEATURE BACKLOG BY PHASE

### PHASE 1: XML Interface (NEXT SPRINT) ⭐

**Goal:** Web form to generate XML file without manual editing

| Feature | Priority | Complexity | Status |
|---------|----------|------------|--------|
| Property data input form | HIGH | Medium | ⏳ |
| Agent selector (from database) | HIGH | Medium | ⏳ |
| Photo uploader to S3 | HIGH | Medium | ⏳ |
| Area selector | HIGH | Low | ⏳ |
| Status selector (Coming Soon/Private) | HIGH | Low | ⏳ |
| Description writer (AI Paisley - ChatStartTypeId=3) | MEDIUM | Medium | ⏳ |
| XML preview/download | HIGH | Low | ⏳ |
| One-click deploy | HIGH | Medium | ⏳ |

**Reusable Components:**
- Photo uploader from `MarketingImageUploader`
- Agent data from `UserMarketingProfile`
- Area selector from existing area components
- Theme selector from `HubTheme` table

### PHASE 2: Listing Command Integration

**Goal:** Route PLS through existing LC workflow

| Feature | Priority | Complexity |
|---------|----------|------------|
| Save to MlsListing.dbo.Listing (MlsId=999) | HIGH | Medium |
| Queue to ListingCommandQueue | HIGH | Low |
| Billing through WHMCS | HIGH | Medium |
| SMS campaign trigger | HIGH | Low |

### PHASE 3: Asset Generation

**Goal:** Auto-generate all marketing assets

| Feature | Priority | Complexity |
|---------|----------|------------|
| Trigger genie-api render | HIGH | High |
| Landing page (pls-hollywood) | HIGH | Low |
| Social ads (lc-prop-post-*) | HIGH | Low |
| Brochure PDF | MEDIUM | Medium |
| Collection page | MEDIUM | Low |

### PHASE 4: Engagement Center

**Goal:** Full lead tracking and workflow

| Feature | Priority | Complexity |
|---------|----------|------------|
| UTM parameter handling | HIGH | Medium |
| Lead tagging (PlsLead) | HIGH | Low |
| window.gHub.addLead() integration | HIGH | Medium |
| Notification routing | MEDIUM | Medium |

### PHASE 5: Management UI

**Goal:** CRUD interface for PLS listings

| Feature | Priority | Complexity |
|---------|----------|------------|
| List my PLS listings | HIGH | Medium |
| Edit existing listing | MEDIUM | Medium |
| Change status (Private ↔ Coming Soon) | HIGH | Low |
| Archive/delete | LOW | Low |
| Convert to MLS (link real MLS#) | MEDIUM | Medium |

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
        year="2025"
        renderId="pls-{unique-id}"
        version="3.0.0"
    />
    
    <date period="Dec 2024 to Dec 2025" />
    
    <xslAsset>landing-pages/pls-hollywood</xslAsset>
    
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
    
    <areas>
        <area>
            <areaId>407559</areaId>
            <areaName>Balcones Creek - All Neighborhoods</areaName>
        </area>
    </areas>
    
    <single>
        <mlsNumber>PLS-2025-00001</mlsNumber>
        <mlsId>999</mlsId>
        <statusTypeID>6</statusTypeID>
        <listingStatus>Private Listing</listingStatus>
        <price>749000</price>
        <squareFeet>3018</squareFeet>
        <lotSize>9101</lotSize>
        <built>2022</built>
        <description>Property description...</description>
        <photoPrimary>https://.../.../front-of-home.jpg</photoPrimary>
        <latitude>29.7221</latitude>
        <longitude>-98.6896</longitude>
        
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
    
    <mlsDisplay>
        <mlsId>999</mlsId>
        <mlsName>PLS</mlsName>
        <mlsDisplayName>Paisley Listing Service</mlsDisplayName>
    </mlsDisplay>
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
| Area | `<areas><area>...</area></areas>` | ✅ | For widgets |

---

## 12. GENIECLOUD RENDER PIPELINE

### 12.1 How It Works

```
PLS UI CREATES XML DATA
    ↓
POST TO /api/pls/render (or reuse /api/listing-command/render)
    ↓
GENIECLOUD PROCESSOR (JSON → XML)
    ↓
XSL TRANSFORM (XML → HTML/SVG)
    ↓
PUPPETEER (HTML → PDF/PNG)
    ↓
S3 UPLOAD (genie-cloud bucket)
    ↓
COLLECTION PAGE GENERATED
```

### 12.2 Render Pipeline (from render-data.js)

1. `/create` endpoint receives render params (userId, areaId, mlsNumber, asset/collection)
2. Generates unique `renderId` (UUID)
3. Saves to `_processing/{renderId}/render.json`
4. Queues `prepare` message to SQS
5. `/prepare` loads collection/asset definitions
6. `/process` calls `getRenderJSON()` to build XML with agents, areas, listings
7. genie-processor does XSLT transformation
8. Result uploaded to S3

### 12.3 Key Insight for PLS

For regular listings: `getListing()` fetches from MLS API
For PLS: We provide the listing data directly (it's in our database with MlsId=999)

**The XML is the intermediate format** - the real deliverable is the rendered assets.

### 12.4 Available Templates

| Template | XSL Path | Use For |
|----------|----------|---------|
| Hollywood Landing | `landing-pages/pls-hollywood` | Main landing page |
| Cash Buyers | `social-marketing-graphics/lc-prop-post-03` | Social ad |
| Modern VIP | `social-marketing-graphics/lc-prop-post-01-vip` | Social ad |
| Just Listed | `social-marketing-graphics/just-listed-01` | Announcement |
| Brochure | `marketing-collateral/lc-brochure-01` | PDF download |

---

## 13. ENGAGEMENT CENTER INTEGRATION

### 13.1 Lead Capture Flow

```
USER CLICKS LANDING PAGE CTA
    ↓
window.gHub.addLead() CALLED
    ↓
CREATE GenieLead RECORD
    ↓
TAG LEAD (GenieLeadTag)
    ↓
NOTIFY AGENT (NotificationQueue)
    ↓
SMS/EMAIL SENT
```

### 13.2 Key Tables

| Table | Purpose |
|-------|---------|
| `GenieLead` | Main lead record |
| `GenieLeadTag` | Tags attached to leads |
| `GenieLeadTagType` | Tag definitions |
| `NotificationQueue` | Notification queue |
| `ShortUrlData` | SMS tracking URLs |

### 13.3 Lead Tags for PLS

| Tag | LeadTagTypeId | Purpose |
|-----|---------------|---------|
| CtaContactSubmit | 48 | CTA submitted |
| OptOut | 51 | User opted out |
| CtaContactVerified | 52 | Contact verified |
| **PlsLead (NEW)** | TBD | PLS-specific lead |
| **ComingSoon (NEW)** | TBD | Coming Soon lead |
| **PrivateListing (NEW)** | TBD | Private Listing lead |

---

## 14. PRODUCTION EXAMPLES & REFERENCES

### 14.1 Live PLS Example (Our MVP)

| Field | Value |
|-------|-------|
| **Live URL** | [https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html](https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html) |
| **Property** | 10037 Rebecca Place, Boerne, TX 78006 |
| **Agent** | Steve Hundley (Inspired Real Estate) |
| **Theme** | Compass Dark |
| **StatusTypeID** | 6 (Private Listing) |
| **Status** | ✅ LIVE |

### 14.2 Gold Standard Reference (Dainelle Scott Collection)

| Field | Value |
|-------|-------|
| **Collection URL** | [https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52](https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52) |
| **Property** | 28827 Balcones Crk, Boerne |
| **MLS** | 1917644 |
| **Theme** | Compass |
| **Collection ID** | 15a521b8-3fbf-4042-bce3-58e378cd9a52 |

### 14.3 Key Test User Accounts

| User | ASP User ID | Theme | Use Case |
|------|-------------|-------|----------|
| **Dainelle Scott** | 9f750957-4d66-4151-bd37-9588d17d4fb8 | compass | Production reference, widget spoofing |
| **Ed Kaminsky** | 4865455f-29a0-4c8f-9938-8c4bab261ef6 | ed-kaminsky | High-volume agent |
| **Steve Hundley (TX)** | 2d0bd648-3f05-4e9a-bec9-1fb050d5170b | inspired-re | PLS test account |

---

## 15. CRITICAL TECHNICAL DISCOVERIES

**⚠️ HARD-WON LESSONS from the MVP build:**

### 15.1 StatusTypeID = 6 DOES NOT EXIST

**Database verified:** StatusType 6 (Private Listing) is NOT in the StatusType table. StatusType 14 (Coming Soon) EXISTS but has 0 listings.

**Required action:**
```sql
INSERT INTO MlsListing.dbo.StatusType (StatusTypeID, Name) VALUES (6, 'Private Listing');
```

### 15.2 XSL Templates Didn't Handle StatusTypeID=6

We had to add:
```xml
<xsl:when test="number(//single/statusTypeID)=6">Private Listing</xsl:when>
```

Without this, private listings displayed as "Expired".

### 15.3 Theme + Hue Paradox

**COUNTERINTUITIVE:** For social ads with dark headers, use `themeHue="light"`:

| Desired Visual | Set `themeHue` to |
|----------------|-------------------|
| Dark headers (social ads) | `light` |
| Dark background (landing pages) | `dark` |

### 15.4 XML Format for Beds/Baths/Images

**WRONG:**
```xml
<bedrooms>4</bedrooms>
```

**CORRECT:**
```xml
<bedrooms count="4"/>
<bathrooms total="3" full="3" half="0"/>
<images><image src="..."/></images>
```

### 15.5 Logo URL Naming is Swapped

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

### 15.6 API Endpoint

**CORRECT:** `https://cloud-api.thegenie.ai/`

**DEPRECATED:** `genie-api.dynamicarray.co.uk`

### 15.7 ListingCommandListingSnapshot Uses JSON

The listing data is stored as a **JSON blob** in `ListingCommandListingSnapshot.ListingJson`. This is exactly what PLS will do - no schema changes needed.

---

## 16. DATA FLOW DIAGRAMS

### 16.1 PLS Creation Flow

```
 STEP 1: USER CREATES PLS LISTING
 ════════════════════════════════
 
 ┌──────────────────────────────────┐
 │     Angular UI (New Component)   │
 │  ─────────────────────────────── │
 │  • Property address form         │
 │  • Price, beds, baths, sqft      │
 │  • Photo uploader (→ S3)         │
 │  • Status: Private or ComingSoon │
 │  • AI Description (Paisley)      │
 └──────────────┬───────────────────┘
                │
                │ POST /api/pls/create
                ▼
 ┌──────────────────────────────────┐
 │     Smart.Dashboard API          │
 │  ─────────────────────────────── │
 │  • Validate ManagePLS (210)      │
 │  • Generate PLS-YYYY-NNNNN       │
 │  • Upload photos to S3           │
 │  • Geocode address               │
 └──────────────┬───────────────────┘
                │
                │ INSERT
                ▼
 ┌────────────────────────────────────────────────────────────────────────┐
 │                          DATABASE INSERTS                               │
 │ ─────────────────────────────────────────────────────────────────────── │
 │ 1. MlsListing.dbo.Listing (MlsId=999, StatusTypeId=6 or 14)            │
 │ 2. MlsListing.dbo.Photo (1-N rows per listing)                          │
 │ 3. FarmGenie.dbo.PlsListingOwnership (AspNetUserId → ListingId)        │
 └────────────────────────────────────────────────────────────────────────┘
```

### 16.2 PLS Campaign Activation Flow

```
 STEP 2: USER ACTIVATES CAMPAIGN
 ═══════════════════════════════
 
 ┌──────────────────────────────────┐
 │    "My PLS Listings" Page        │
 │  ─────────────────────────────── │
 │  • Shows all user's PLS          │
 │  • "Start Campaign" button       │
 └──────────────┬───────────────────┘
                │
                │ Click "Start Campaign"
                ▼
 ┌──────────────────────────────────┐
 │    REUSE: ListingCommandInitiate │
 │  ─────────────────────────────── │
 │  • Same component as MLS LC      │
 │  • Route: /pls/initiate/:pls#    │
 │  • User selects area, options    │
 └──────────────┬───────────────────┘
                │
                │ Submit (after payment)
                ▼
 ┌────────────────────────────────────────────────────────────────────────┐
 │                      LISTING COMMAND QUEUE                              │
 │ ─────────────────────────────────────────────────────────────────────── │
 │ ListingCommandQueue.MlsId = 999                                         │
 │ ListingCommandQueue.MlsNumber = "PLS-2025-00001"                        │
 │ ListingCommandListingSnapshot.ListingJson = {full property data}        │
 └──────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ Windows Service picks up
                                    ▼
 ┌──────────────────────────────────┐
 │  PropertyCast Workflow Service   │
 │  ─────────────────────────────── │
 │  • Same workflow as MLS LC       │
 │  • PropertyCastTypeId = 4        │
 │  • Generates assets              │
 │  • Sends SMS to farm             │
 └──────────────┬───────────────────┘
                │
                ▼
 ┌──────────────────────────────────┐
 │        GenieCloud Render         │
 │  ─────────────────────────────── │
 │  • XML from ListingSnapshot      │
 │  • XSL: pls-hollywood.xsl        │
 │  • Output: Landing page + assets │
 │  • S3: genie-cloud bucket        │
 └──────────────────────────────────┘
```

---

## 17. TITLE GENIE INTEGRATION (PRE-LISTING COMMAND) ⭐

### 17.1 The Title Genie + PLS Connection

**This is the CRITICAL business model for PLS adoption.**

Title Genie is a **Market Share Generation Platform for Title Reps** that enables them to attract agents, open doors, and close more title orders. PLS is a key component of this value proposition.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TITLE GENIE + PLS VALUE CHAIN                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  TITLE REP                                                                   │
│     │                                                                        │
│     │ Pays $250/month for TitleGenie                                        │
│     │ Gets: Farm Analyzer, Agent Scorecard, Paisley AI, 4 Listing Commands  │
│     ▼                                                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    TITLE REP OFFERS PLS TO AGENT                      │   │
│  │                                                                       │   │
│  │  "I can help you market your Coming Soon / Private Listing BEFORE    │   │
│  │   it hits MLS. I'll gift you a FREE Pre-Listing Command."            │   │
│  │                                                                       │   │
│  │  Title Rep uploads Property Profile → PLS generates assets           │   │
│  └───────────────────────────────────┬──────────────────────────────────┘   │
│                                      │                                       │
│                                      ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    AGENT GETS PRE-LISTING MARKETING                   │   │
│  │                                                                       │   │
│  │  • Coming Soon landing page (pls-hollywood)                          │   │
│  │  • Social media graphics ("Cash Buyers", "Modern VIP", etc.)         │   │
│  │  • Market reports (Market Insider PDFs)                              │   │
│  │  • SMS campaign to farm area                                         │   │
│  │  • Lead capture → Engagement Center                                  │   │
│  └───────────────────────────────────┬──────────────────────────────────┘   │
│                                      │                                       │
│                                      ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    AGENT WINS LISTING                                 │   │
│  │                                                                       │   │
│  │  • Agent uses TheGenie tools → Gets more listings                    │   │
│  │  • Agent recommends Title Rep to sellers                             │   │
│  │  • Title Rep gets TITLE ORDERS                                       │   │
│  │  • Title Rep earns COMMISSION                                        │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  RESULT: Title Rep ROI = More title orders than $250/month investment       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 17.2 Title Genie Offer Structure

| What Title Reps Get | Value | Description |
|---------------------|-------|-------------|
| **TitleGenie Dashboard** | Core | Farm Analyzer, Agent Scorecard, Agent Mining |
| **Paisley AI Access** | Core | Content generation, pre-listing intel, marketing support |
| **Agent Invitation System** | Core | Invite up to 50 agents, lock them to your account |
| **4 Listing Commands/month** | $400 | Gift 4 agents a $100 Listing Command each month |
| **PLS (Pre-Listing Command)** | NEW | Create Coming Soon / Private Listing pages BEFORE MLS |
| **Ongoing Support** | Core | Office hours, training, certification |

**Annual Option:** $2,500/year (2 months free)

### 17.3 The 4 Listing Commands Explained (Including PLS)

| Detail | Answer |
|--------|--------|
| **What is it?** | A $100 marketing package for the agent's listing |
| **Who pays for it?** | 1ParkPlace — NOT the title rep |
| **Who gives it to the agent?** | TheGenie system delivers it |
| **Title rep's role?** | They RECOMMEND and REFER the agent to the platform |
| **Why is this compliant?** | Title rep gives nothing of value — they refer, we deliver |

**Compliance Language:** Title reps are allowed to **recommend and refer** agents to tools and services. This is standard industry practice. **Knowledge is NOT regulated.**

### 17.4 Title Rep → Agent → PLS Workflow

```
TITLE REP MEETING WORKFLOW (Plan A - CEO Meeting)
══════════════════════════════════════════════════

1. Title Rep schedules meeting via "Meet the Genie" calendar link
   • Agent must have 6+ listings in past 12 months
   • Title Rep must be on the Zoom
   
2. Pre-meeting: 1PP CE Team "Raz Daz" the agent's Genie account
   • Set up branding
   • Configure settings
   
3. Meeting takes place → Takeaway worksheet completed
   • Sub Path I: No Action (not a fit)
   • Sub Path II: 1 Free Listing Command (BRAND APPROVAL ONLY) ← PLS CAN GO HERE
   • Sub Path III: Full Farm System Execution (FULL ONBOARDING)

ALTERNATE WORKFLOW (Plan B - Pre-Launch First)
══════════════════════════════════════════════════

1. Title Rep requests a Pre-Listing Command (PLS) for agent BEFORE CEO meeting
2. 1PP CE Team sets up agent's Genie pre-LC Launch
3. Based on results, agent decides yes/no to CEO meeting
4. If YES → CEO meeting → Full onboarding

SERVICES AVAILABLE
═══════════════════
• Listing Command (MLS listings)
• PRE-LISTING COMMAND (Coming Soon / Private Listing) ← NEW
• Neighborhood Command
• List Miner
• Title Genie - FarmGenie
• Paisley
• Marketing Hub
• Custom Themes
```

### 17.5 Pre-Listing Intelligence (Paisley ChatStartTypeId=3)

PLS leverages **Paisley's Pre-Listing Focused chat type** which:

- Uses **Assessor data (Attom)** - NOT MLS data (because it's not listed yet!)
- Pulls from `TitleData.dbo.ViewAssessor_v3`
- Generates property descriptions
- Provides market analysis
- Supports CMAs and pre-listing presentations

| EnumChatMessageRequirement | ID | Purpose for PLS |
|----------------------------|----|-----------------| 
| AssessorProperty | 5 | Property data from Attom |
| AreaStatistics | 1 | Market data for widgets |
| UserMarketingProfile | 3 | Agent branding data |
| UserProfile | 4 | Agent info |

**Key Insight:** The infrastructure for pre-listing content ALREADY EXISTS. PLS is the ASSET GENERATION layer on top of it!

### 17.6 Knowledge Is Power (Compliance Model)

> **"KNOWLEDGE IS POWER. Empower Agents. Grow Relationships. Close More Title Orders."**
>
> TitleGenie by TheGenie.ai is a business development platform designed to help Title Representatives build trust, open doors, and secure more title orders by delivering unmatched value to real estate professionals.
>
> **KNOWLEDGE is NOT REGULATED.**

**How TitleGenie Helps Title Reps Succeed:**

| Strategy | What It Means |
|----------|---------------|
| **Open Doors with Data** | Farm Analyzer + Agent Scorecard = business intelligence to the right agents |
| **Build Trust with Paisley AI** | Refer agents to AskPaisley — AI-powered marketing assistant |
| **Support the Listing Process** | Pre-listing intelligence (PLS) + local homeowner insights — NO marketing dollars touched |
| **Close Title Orders Early** | Positioned BEFORE the MLS = first in line for title business |

**CRITICAL:** 
- 🚫 No co-marketing
- 🚫 No lead buying
- ✅ 100% RESPA-safe

### 17.7 Production Examples (Manhattan Beach / Hermosa Beach Area)

From the Discovery folder, Title Reps have already created property profiles for:

| Property | File | Status |
|----------|------|--------|
| 1728 Goodman Ave, Redondo Beach, CA 90278 | `1728 GOODMAN AVE REDONDO BEACH_ CA 90278.PDF` | Property Profile |
| 563 2nd St, Hermosa Beach, CA 90254 | `563 2ND ST HERMOSA BEACH_ CA 90254.PDF` | Property Profile |
| Marketing Kit 9630 | `_- Marketing Kit 9630 -1765568230.pdf` | Full Kit |

**These are examples of Title Reps uploading property profiles for agents to generate pre-listing assets!**

### 17.8 Title Rep Dashboard Screens for PLS

From `TITLEGENIE_PAISLEY_DASHBOARD_DESIGN_v1.md`:

**Screen 6: Listing Command Management**
- View monthly allocation (4 per month for Listing Commands)
- Gift a Listing Command to an agent
- Track gifted this month
- History of past gifts
- What is a Listing Command / Pre-Listing Command?

**PLS Enhancement:**
- Add "Pre-Listing Command" as a separate gift option
- Track PLS gifts separately from MLS LC gifts
- Show PLS results (Coming Soon pages, Private Listing pages)

### 17.9 Title Rep Roles (From Section 8.2)

| RoleId | Name | DisplayName | LC Access | PLS Access |
|--------|------|-------------|:---------:|:----------:|
| **2** | **Affiliate** | **Affiliate** | **✅ Full** | **✅ Full** |
| **4** | **Affiliate Admin** | **Affiliate Admin** | **✅ Full** | **✅ Full** |
| 3 | Affiliate Territory Admin | Affiliate Territory Admin | ✅ Full | ✅ Full |
| 6 | Affiliate (Beta User) | Affiliate (Beta User) | ✅ Full | ✅ Full |
| 27 | Affiliate Limited | Affiliate Limited | Limited | Limited |
| 16 | Affiliate No Access | Affiliate No Access | ❌ | ❌ |

**Title Reps (Affiliates) get FULL PLS ACCESS by default when we add the permissions.**

### 17.10 Technical Integration Points

| System | Integration Point | What PLS Uses |
|--------|-------------------|---------------|
| **Title Genie Dashboard** | Menu item | "Pre-Listing Command" under Listing Commands |
| **Paisley AI** | ChatStartTypeId=3 | Pre-Listing Focused chat for descriptions |
| **TitleData** | ViewAssessor_v3 | Property data lookup (Attom) |
| **UserPartner** | PartnerTypeId=2 | Title Rep → Agent relationship |
| **InvitationManager** | Agent invitations | Title Rep invites agents to platform |
| **WHMCS** | Product ID TBD | PLS billing (or included in $250/month) |
| **GenieCloud** | pls-hollywood.xsl | Asset rendering |

### 17.11 Title Rep PLS Use Cases

| Use Case | Description | Workflow |
|----------|-------------|----------|
| **Gift to New Agent** | Title Rep gives PLS to attract a new agent relationship | TR invites agent → Creates PLS for agent's listing → Agent sees value → Recommends TR for title business |
| **Support Existing Agent** | Title Rep helps partnered agent market a pre-MLS listing | TR selects agent from roster → Creates PLS → Agent gets marketing assets |
| **Mega Team CEO Meeting** | Title Rep brings agent to strategy session | CEO meeting → PLS as "free taste" → Full onboarding if interested |
| **Pre-Launch Teaser** | Generate buzz before MLS | Private Listing status → SMS to farm → Convert to Coming Soon → Convert to Active |

### 17.12 Title Genie GTM with PLS

From `TITLEGENIE_MVP_ROADMAP_GTM_PLAN_v2.md`:

**Phase 1 Goal:** 100 Title Reps onboarded by end of January 2026

**PLS as Differentiator:**
- Competitors (Title Toolbox, Venutech, Title 24) = Farming platforms
- **TitleGenie = Market Share Generation Platform**
- PLS enables "pre-MLS positioning" = unique value prop

**Lead Sources:**
1. Primary: Intercom database (1,000-2,000 past title reps)
2. Secondary: Current active users, word of mouth
3. Tertiary: Website inbound, content marketing

---

## 18. DEPENDENCIES & NEXT STEPS

### 18.1 Dependencies

| Dependency | Status | Owner |
|------------|--------|-------|
| GenieCloud team for render integration | ✅ Connected | GenieCloud/UK |
| StatusTypeID 6 XSL handling | ✅ Added | - |
| StatusTypeID 14 XSL handling | ✅ Exists | - |
| CONTRACT_PLS_to_GenieCloud | ✅ Created | Both teams |
| StatusType 6 in database | ❌ NEEDS INSERT | IT |
| MlsId 999 in database | ❌ NEEDS INSERT | IT |
| PropertyCastTypeId 4 | ❌ NEEDS INSERT | IT |
| Test database clone | ⏳ Requested | IT |
| WHMCS Product ID for PLS | ⏳ Needed | IT |
| Apple Black theme | ✅ Created | - |

### 18.2 Resolved Questions

| Question | Answer |
|----------|--------|
| Database location for listings | MlsListing.dbo.Listing with MlsId=999 |
| Billing model | One-time (like Listing Command) |
| Title Rep flow | Both - can create for agents AND enable agents |
| Coming Soon vs Private | StatusTypeID in same table (6=Private, 14=ComingSoon) |
| Photo storage | MlsListing.dbo.Photo (existing table) |

### 18.3 Immediate Next Steps

1. ✅ Consolidate documentation (this document)
2. ✅ Create CONTRACT_PLS_to_GenieCloud
3. ✅ Build MVP proof of concept (10037 Rebecca Place)
4. ⏳ Run database INSERTs (StatusType 6, MlsId 999, PropertyCastType 4)
5. ⏳ Create PlsListingOwnership and PlsNumberSequence tables
6. ⏳ Add PLS permissions (210-214)
7. ⏳ Begin Phase 1 (XML Interface UI)

---

## 19. CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/28/2025 | Cursor AI | Initial consolidated specification from multiple source documents |
| 2.0 | 12/28/2025 | Cursor AI | Added: Production Examples, Critical Technical Discoveries, XML Interface Specification |
| 3.0 | 12/28/2025 | Cursor AI | **Major update:** Added complete Permission inventory, Role inventory, Status Types verified from DB, MLS Sources table, Paisley ChatStartType integration, GenieCloud render pipeline, Engagement Center integration, Data Flow diagrams, Resolved database location (MlsListing.dbo.Listing with MlsId=999), PlsListingOwnership table design |
| 3.1 | 12/28/2025 | Cursor AI | **NEW SECTION 17: TITLE GENIE INTEGRATION** - Comprehensive documentation of the Title Genie + PLS connection including: Value chain (Title Rep → Agent → PLS → Title Orders), $250/month offer structure, 4 Listing Commands workflow, CEO Meeting process (Plan A/B), Pre-Listing Intelligence (Paisley ChatStartTypeId=3), Knowledge Is Power compliance model, Manhattan Beach/Hermosa Beach property profile examples, Title Rep dashboard screens, GTM strategy alignment, technical integration points |

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
| Source Code | `D:\Cursor\_SourceCode\` |

---

*This is the SINGLE SOURCE OF TRUTH for PLS development. All other documents in this folder should reference this master spec.*


