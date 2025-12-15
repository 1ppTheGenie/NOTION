# Feature Request: Content Configurator
## FR-003 | Development Specification
### Version 1.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

## Document Purpose
Technical specification for a UI-based content configuration system that allows dynamic selection of landing pages and CTAs from Genie CLOUD for Competition Command campaigns.

---

## Executive Summary

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FR-003 |
| **Feature Name** | Content Configurator |
| **Status** | Discovery |
| **Priority** | Medium |
| **Dependency** | Genie CLOUD CTA System |
| **Sprint Target** | Sprint 54-55 |

---

## Business Requirements

### Core Functionality
1. **Landing Page Selection** - Choose from available CLOUD landing pages
2. **CTA Configuration** - Select which CTAs appear on landing pages
3. **A/B Testing** - Rotate multiple CTAs for conversion optimization
4. **Per-Area Configuration** - Different content per owned area (optional)

### CTA Types Available

| CTA ID | Type | Description |
|--------|------|-------------|
| 2 | Home Value Estimate | Get personalized valuation |
| 3 | Market Report | Download area market data |
| 4 | Property Alert | Sign up for listing alerts |
| 5 | Contact Agent | Direct agent contact form |
| 6 | Schedule Tour | Book property showing |
| 7 | Mortgage Calculator | Financial tool access |
| 8 | Neighborhood Guide | Area information |
| 9 | School Information | School district data |

### Future CTA Types (Phase 2)

| Type | Description |
|------|-------------|
| Social Follow | Follow on Instagram/Facebook/YouTube |
| Newsletter Signup | Subscribe to agent newsletter |
| Video Consultation | Schedule video call |
| Market Snapshot | Quick market stats popup |

---

## Technical Architecture

### Current CTA System (Baseline)

From `SOP_GenieCloud_CTA_Popup_ReverseEngineering_v1.md`:

**Current State:**
- CTAs hardcoded in `utils.js` as JavaScript objects
- Rendered by `_LeadCtaTag.jsx` component
- Controlled by URL parameter `?ctaId=X` or backend split testing
- `CloudCtaSplitHandler.cs` manages A/B test groups

**Problem:**
- No UI for configuration
- Requires code changes to add/modify CTAs
- No per-agent or per-area customization

### Proposed Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Admin Portal                              │
│              (Content Configurator UI)                       │
└─────────────────────┬───────────────────────────────────────┘
                      │ Configure
                      ▼
┌─────────────────────────────────────────────────────────────┐
│            Database Tables (NEW)                            │
│  - ContentConfiguration                                      │
│  - CtaDefinition                                            │
│  - CtaRotationGroup                                         │
└─────────────────────┬───────────────────────────────────────┘
                      │ Load Config
                      ▼
┌─────────────────────────────────────────────────────────────┐
│          ContentConfigurationHandler.cs (NEW)               │
│  - GetConfigurationForArea()                                │
│  - GetNextCtaInRotation()                                   │
│  - TrackCtaImpression()                                     │
└─────────────────────┬───────────────────────────────────────┘
                      │ API Response
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Genie CLOUD Landing Page                       │
│  - Loads CTA config from API (not hardcoded)               │
│  - _LeadCtaTag.jsx renders dynamic CTA                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Schema

### Table: `CtaDefinition`

Master list of all available CTAs.

```sql
CREATE TABLE dbo.CtaDefinition (
    CtaDefinitionId         INT IDENTITY(1,1) PRIMARY KEY,
    CtaName                 NVARCHAR(100) NOT NULL,
    CtaType                 NVARCHAR(50) NOT NULL,
    
    -- Display Content
    CtaTitle                NVARCHAR(200) NULL,
    CtaSubTitle             NVARCHAR(500) NULL,
    CtaBody                 NVARCHAR(1000) NULL,
    CtaImage                NVARCHAR(500) NULL,
    CtaSubmitButtonText     NVARCHAR(100) NULL,
    CtaResponse             NVARCHAR(500) NULL,
    
    -- Behavior
    CtaShowContactForm      BIT NOT NULL DEFAULT 1,
    CtaContactFormBody      NVARCHAR(500) NULL,
    ScrollUpPercentage      INT NULL,
    ScrollDownPercentage    INT NULL,
    DelaySeconds            INT NULL,
    
    -- Disclaimer
    CtaDisclaimer           NVARCHAR(MAX) NULL,
    
    -- Status
    IsActive                BIT NOT NULL DEFAULT 1,
    IsSystem                BIT NOT NULL DEFAULT 0, -- System CTAs can't be deleted
    
    -- Audit
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL,
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedByUserId        NVARCHAR(128) NULL
);

CREATE INDEX IX_CtaDefinition_CtaType ON dbo.CtaDefinition(CtaType);
CREATE INDEX IX_CtaDefinition_IsActive ON dbo.CtaDefinition(IsActive);
```

### Table: `ContentConfiguration`

Per-area or default content configuration.

```sql
CREATE TABLE dbo.ContentConfiguration (
    ContentConfigurationId  INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Scope (NULL = default for all)
    AreaOwnershipId         INT NULL,
    AspNetUserId            NVARCHAR(128) NULL,
    PropertyCastTypeId      INT NULL, -- 1 = Competition Command
    
    -- Landing Page
    LandingPageTemplate     NVARCHAR(100) NULL,
    
    -- CTA Settings
    CtaMode                 NVARCHAR(20) NOT NULL DEFAULT 'Single',
        -- Values: 'Single', 'Rotation', 'ABTest'
    PrimaryCtaId            INT NULL,
    
    -- Status
    IsActive                BIT NOT NULL DEFAULT 1,
    
    -- Audit
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_ContentConfig_AreaOwnership
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId),
    CONSTRAINT FK_ContentConfig_PrimaryCta
        FOREIGN KEY (PrimaryCtaId) REFERENCES dbo.CtaDefinition(CtaDefinitionId)
);

CREATE INDEX IX_ContentConfig_AreaOwnershipId ON dbo.ContentConfiguration(AreaOwnershipId);
CREATE INDEX IX_ContentConfig_PropertyCastTypeId ON dbo.ContentConfiguration(PropertyCastTypeId);
```

### Table: `CtaRotationGroup`

CTAs in a rotation/A-B test group.

```sql
CREATE TABLE dbo.CtaRotationGroup (
    CtaRotationGroupId      INT IDENTITY(1,1) PRIMARY KEY,
    ContentConfigurationId  INT NOT NULL,
    CtaDefinitionId         INT NOT NULL,
    
    -- Rotation Settings
    Weight                  INT NOT NULL DEFAULT 1, -- For weighted rotation
    SortOrder               INT NOT NULL DEFAULT 0,
    
    -- A/B Test Tracking
    Impressions             INT NOT NULL DEFAULT 0,
    Conversions             INT NOT NULL DEFAULT 0,
    
    -- Status
    IsActive                BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT FK_CtaRotation_ContentConfig
        FOREIGN KEY (ContentConfigurationId) REFERENCES dbo.ContentConfiguration(ContentConfigurationId),
    CONSTRAINT FK_CtaRotation_CtaDefinition
        FOREIGN KEY (CtaDefinitionId) REFERENCES dbo.CtaDefinition(CtaDefinitionId)
);

CREATE INDEX IX_CtaRotation_ContentConfigId ON dbo.CtaRotationGroup(ContentConfigurationId);
```

---

## API Endpoints

### Public API (Landing Page)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/content/cta/{renderId}` | Get CTA config for landing page |
| POST | `/api/content/impression` | Track CTA impression |
| POST | `/api/content/conversion` | Track CTA conversion |

### Admin API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/content/cta` | List all CTA definitions |
| POST | `/api/admin/content/cta` | Create new CTA |
| PUT | `/api/admin/content/cta/{id}` | Update CTA |
| DELETE | `/api/admin/content/cta/{id}` | Delete CTA (soft) |
| GET | `/api/admin/content/config` | List content configurations |
| POST | `/api/admin/content/config` | Create/update configuration |
| GET | `/api/admin/content/stats/{configId}` | A/B test results |

---

## Implementation: ContentConfigurationHandler.cs

```csharp
namespace Smart.Core.BLL.Content
{
    public class ContentConfigurationHandler
    {
        public CtaConfiguration GetCtaForLandingPage(string renderId, int? areaId)
        {
            // 1. Get content configuration for this area
            var config = GetConfiguration(areaId);
            
            if (config == null)
            {
                // Use default configuration
                config = GetDefaultConfiguration();
            }
            
            // 2. Determine which CTA to show
            CtaDefinition cta;
            
            switch (config.CtaMode)
            {
                case "Single":
                    cta = GetCtaById(config.PrimaryCtaId);
                    break;
                    
                case "Rotation":
                    cta = GetNextCtaInRotation(config.ContentConfigurationId);
                    break;
                    
                case "ABTest":
                    cta = GetRandomCtaFromGroup(config.ContentConfigurationId);
                    break;
                    
                default:
                    cta = GetCtaById(config.PrimaryCtaId);
                    break;
            }
            
            // 3. Track impression
            TrackImpression(config.ContentConfigurationId, cta.CtaDefinitionId);
            
            // 4. Return CTA configuration
            return MapToCtaConfiguration(cta);
        }
        
        private CtaDefinition GetNextCtaInRotation(int configId)
        {
            // Round-robin through CTAs in rotation group
            var group = GetRotationGroup(configId);
            var lastShown = GetLastShownIndex(configId);
            var nextIndex = (lastShown + 1) % group.Count;
            
            UpdateLastShownIndex(configId, nextIndex);
            
            return group[nextIndex].CtaDefinition;
        }
        
        private CtaDefinition GetRandomCtaFromGroup(int configId)
        {
            // Weighted random selection for A/B testing
            var group = GetRotationGroup(configId);
            var totalWeight = group.Sum(g => g.Weight);
            var random = new Random().Next(totalWeight);
            
            var cumulative = 0;
            foreach (var item in group)
            {
                cumulative += item.Weight;
                if (random < cumulative)
                    return item.CtaDefinition;
            }
            
            return group.First().CtaDefinition;
        }
    }
}
```

---

## UI Mockups

### Admin: CTA Manager

```
┌─────────────────────────────────────────────────────────┐
│  CTA MANAGER                          [+ Create New CTA]│
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ACTIVE CTAs                                            │
│  ┌────┬──────────────────┬──────────┬─────────────────┐│
│  │ ID │ Name             │ Type     │ Actions         ││
│  ├────┼──────────────────┼──────────┼─────────────────┤│
│  │ 2  │ Home Value Est.  │ Valuation│ [Edit] [Preview]││
│  │ 3  │ Market Report    │ Download │ [Edit] [Preview]││
│  │ 4  │ Property Alert   │ Signup   │ [Edit] [Preview]││
│  │ 5  │ Contact Agent    │ Contact  │ [Edit] [Preview]││
│  └────┴──────────────────┴──────────┴─────────────────┘│
│                                                         │
│  [ Import CTA ]  [ Export All ]                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Admin: Content Configuration

```
┌─────────────────────────────────────────────────────────┐
│  CONTENT CONFIGURATION                                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  SCOPE                                                  │
│  ○ Default (All Areas)                                  │
│  ○ Specific Area: [92127 - Rancho Bernardo ▼]          │
│  ○ Specific Agent: [Select Agent... ▼]                 │
│                                                         │
│  LANDING PAGE                                           │
│  Template: [lc-hollywood ▼]                             │
│                                                         │
│  CTA MODE                                               │
│  ○ Single CTA: [Home Value Estimate ▼]                 │
│  ● Smart Rotation (recommended)                         │
│  ○ A/B Test                                            │
│                                                         │
│  ROTATION CTAs (drag to reorder)                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ☰ Home Value Estimate     Weight: [1]  [Remove] │   │
│  │ ☰ Market Report           Weight: [1]  [Remove] │   │
│  │ ☰ Property Alert          Weight: [1]  [Remove] │   │
│  └─────────────────────────────────────────────────┘   │
│  [+ Add CTA to Rotation]                                │
│                                                         │
│       [ Cancel ]              [ Save Configuration ]    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Migration from Hardcoded CTAs

### Step 1: Seed CtaDefinition from utils.js

```sql
-- Migrate existing CTAs from hardcoded JavaScript to database
INSERT INTO dbo.CtaDefinition (CtaName, CtaType, CtaTitle, CtaSubTitle, CtaBody, ...)
SELECT 
    'Home Value Estimate',
    'Valuation',
    'Personalized Home Value Estimate',
    'Discover Your Home''s True Worth',
    'Interested in a personalized valuation?',
    ...
-- Repeat for all existing CTAs
```

### Step 2: Create Default Configuration

```sql
-- Default configuration for Competition Command
INSERT INTO dbo.ContentConfiguration (PropertyCastTypeId, CtaMode, PrimaryCtaId, IsActive)
VALUES (1, 'Rotation', 2, 1); -- CC, Rotation mode, Home Value as primary

-- Add CTAs to rotation
INSERT INTO dbo.CtaRotationGroup (ContentConfigurationId, CtaDefinitionId, Weight, SortOrder)
VALUES 
    (1, 2, 1, 1), -- Home Value
    (1, 4, 1, 2), -- Property Alert
    (1, 5, 1, 3); -- Contact Agent
```

### Step 3: Update Landing Page Code

Modify `_LandingPages.jsx` to fetch CTA config from API instead of hardcoded `utils.js`.

---

## Open Questions

| # | Question | Status |
|---|----------|--------|
| 1 | Should agents be able to configure their own CTAs? | Open |
| 2 | Default rotation vs A/B test mode? | Recommend: Rotation |
| 3 | How long should A/B tests run before declaring winner? | Open |
| 4 | Should we support custom CTA images? | Phase 2 |

---

## Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| Genie CLOUD codebase | Required | ✅ Available |
| `_LeadCtaTag.jsx` component | Modify | Required |
| `utils.js` CTA definitions | Migrate | Required |

---

*Document Version: 1.0 | Created: 12/13/2025 | Updated: 12/14/2025*

