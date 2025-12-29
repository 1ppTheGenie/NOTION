# PLS (Pre-Listing System) - Master Specification

**Version:** 1.0  
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
9. [Dependencies & Next Steps](#9-dependencies--next-steps)
10. [Change Log](#10-change-log)

---

## 1. EXECUTIVE SUMMARY

| Element | Details |
|---------|---------|
| **Purpose** | Create a "Paisley Listing Service" (PLS) - a parallel listing database for Coming Soon and Private Listings that mimics MLS structure |
| **Business Goal** | Title Reps can offer agents the ability to market properties BEFORE they hit MLS |
| **Technical Goal** | Leverage existing ListingCommand/PropertyCast patterns to process PLS listings through the same workflow engine |
| **Key Insight** | PLS should behave like a new PropertyCastType (4) and use the same billing, SMS, asset generation infrastructure as Listing Command |
| **Status** | Discovery complete. Ready for iterative development. |

### What PLS Delivers

- **Coming Soon Pages** - Pre-market listings with full marketing assets
- **Private Listing Pages** - Off-market/exclusive listings
- **XML Generator UI** - Web form to create listing data without manual editing
- **Asset Generation** - Social ads, brochures, landing pages via GenieCloud
- **Lead Capture** - Full integration with Engagement Center

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

### 2.2 Key Databases

| Database | Purpose | Key Tables |
|----------|---------|------------|
| **FarmGenie** | Main application | AspNetUsers, UserMarketingProfile, ListingCommandQueue, GenieLead |
| **MlsListing** | MLS data | Listing, StatusType, PropertyType |
| **TitleData** | Property data | AttomDataAssessor, ViewAssessor_v3 |
| **WHMCS** | Billing | tblclients, tblorders, tbltransactions |

### 2.3 Database Connection

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

| StatusTypeID | Name | XSL Behavior |
|--------------|------|--------------|
| 1 | Active | "For Sale" messaging |
| 2 | Sold | "Just Sold" messaging |
| 3, 4, 12 | Pending | "In Escrow" messaging |
| **6** | **Private Listing** | **"Private Listing" label** |
| **14** | **Coming Soon** | **"Coming Soon" label** |

**Note:** StatusTypeID 6 and 14 already exist - no DB changes needed.

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

### PHASE 1: XML Interface (Next Sprint)

**Goal:** Web form to generate XML file without manual editing

| Feature | Priority | Complexity |
|---------|----------|------------|
| Property data input form | HIGH | Medium |
| Agent selector (from database) | HIGH | Medium |
| Photo uploader to S3 | HIGH | Medium |
| Area selector | HIGH | Low |
| Status selector (Coming Soon/Private) | HIGH | Low |
| Description writer (AI Paisley) | MEDIUM | Medium |
| XML preview/download | HIGH | Low |
| One-click deploy | HIGH | Medium |

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

### 8.1 All MLS Sources (68 Total)

Key ones for PLS:

| MlsID | Name | DisplayName |
|-------|------|-------------|
| 0 | Sandicor | San Diego MLS |
| 26 | NTREIS | North Texas Real Estate Info Systems |
| 68 | Sabor | San Antonio Board of Realtors |
| 82 | Austin | Austin Board of Realtors |
| **999** | **PLS (NEW)** | **Paisley Listing Service** |

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

---

## 9. DEPENDENCIES & NEXT STEPS

### 9.1 Dependencies

| Dependency | Status | Owner |
|------------|--------|-------|
| GenieCloud team for render integration | ✅ Connected | GenieCloud |
| Test database clone | ⏳ Needed | IT |
| WHMCS Product ID for PLS | ⏳ Needed | IT |
| StatusType 6/14 verification | ✅ Verified | - |
| Apple Black theme | ✅ Created | - |

### 9.2 Open Questions

1. **Database Location:** Should PlsListing tables go in FarmGenie (recommended) or MlsListing?
2. **Billing Model:** One-time purchase (like LC) or subscription (like NC)?
3. **Title Rep Flow:** Can Title Reps create on behalf of agents, or just enable?
4. **Conversion Workflow:** Manual MLS number entry or auto-detect by address?

### 9.3 Immediate Next Steps

1. ✅ Consolidate documentation (this document)
2. ⏳ IT: Create test database clone
3. ⏳ IT: Create WHMCS Product ID for PLS
4. ⏳ Development: Begin Phase 1 (Database schema)
5. ⏳ Development: Build XML Interface UI

---

## 10. CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/28/2025 | Cursor AI | Initial consolidated specification from multiple source documents |

---

## DOCUMENTS CONSOLIDATED INTO THIS SPEC

The following documents were merged into this master spec:

1. `MASTER_FEATURE_BACKLOG_PLS_v1.md` - Feature phases
2. `PLS_COMPREHENSIVE_BLUEPRINT_v1.md` - System architecture
3. `PLS_REFERENCE_TABLES_v1.md` - Database reference tables
4. `PLS_DEEP_DISCOVERY_SCHEMA_v1.md` - Permission system
5. `SOP_PLS_Hollywood_MVP_Creation_v1.md` - MVP creation steps
6. `PLS_Hollywood_Workspace_Memory_Log_v1.md` - Session logs

---

*This is the SINGLE SOURCE OF TRUTH for PLS development. All other documents in this folder should reference this master spec.*

