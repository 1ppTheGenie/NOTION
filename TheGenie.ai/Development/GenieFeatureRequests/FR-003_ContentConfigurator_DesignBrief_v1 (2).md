# Feature Request: Content Configurator
## FR-003 | Design & Creative Brief
### Version 1.0

**Created:** 12/13/2025  
**Status:** DRAFT

---

## 1. Executive Summary

### The Problem
Currently, Competition Command landing pages and Call-To-Actions (CTAs) are configured through:
- **Hardcoded JavaScript**: CTA definitions in `utils.js` cannot be changed without code deployment
- **Limited Options**: Agents cannot choose or customize their CTAs
- **No A/B Testing Control**: Split testing is configured in C# code, not adjustable per area
- **No New CTA Types**: Cannot add newsletter signup, social follow, or custom CTAs without development
- **No Area-Level Customization**: All areas for an agent use the same configuration

### The Solution
A **Content Configurator** system that:
- Allows agents to select landing page templates per area
- Enables CTA selection (single or rotating A/B test)
- Provides admin control over CTA templates and options
- Supports new CTA types (Social Follow, Newsletter Signup, etc.)
- Tracks performance metrics per configuration

### Business Value
| Benefit | Impact |
|---------|--------|
| Agent Empowerment | Personalize content to their market |
| Conversion Optimization | A/B test CTAs per area |
| Product Differentiation | Unique configurations per agent |
| Scalability | Add new CTAs without code changes |
| Data-Driven | Track what works best per area |

---

## 2. Source Code Reference

### Current CTA System Analysis
Based on `SOP_GenieCloud_CTA_Popup_ReverseEngineering_v1.md`:

| Component | Path | Current Behavior |
|-----------|------|------------------|
| CTA Definitions | `genie-cloud-1/genie-components/src/utilities/utils.js` | Hardcoded JS objects |
| CTA Renderer | `genie-cloud-1/genie-components/src/landing/_LeadCtaTag.jsx` | Displays CTA modal |
| CTA Trigger | `genie-cloud-1/genie-components/src/landing/_LandingPages.jsx` | URL param or scroll |
| Backend Split Testing | `Smart.Core/BLL/Hub/Handler/Cloud/CloudCtaSplitHandler.cs` | A/B group assignment |

### Current CTA IDs (from utils.js)
| ID | CTA Type | Campaign Use |
|----|----------|--------------|
| 1 | Disabled | - |
| 2 | Home Value Estimate | Listing Command |
| 3 | Home Value Estimate v2 | Listing Command |
| 4 | Property Valuation | Competition Command |
| 5 | Property Valuation v2 | Competition Command |
| 6 | Just Sold Home Value | Listing Command |
| 7 | Just Listed Home Value | Listing Command |
| 8 | Just Sold Property Value | Competition Command |
| 9 | Just Listed Property Value | Competition Command |

### Current Trigger Mechanisms
1. **URL Parameter**: `?ctaId=X` forces specific CTA
2. **Scroll Trigger**: Percentage of page scrolled (up or down)
3. **Time Delay**: Seconds after page load
4. **A/B Split**: Backend assigns CTA group

---

## 3. Proposed Architecture

### New Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTENT CONFIGURATOR                         │
│                         (FR-003)                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    ADMIN UI                                 ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ ││
│  │  │ CTA Manager │  │ Landing Page│  │ CTA Template        │ ││
│  │  │ • Create    │  │ Templates   │  │ Builder (Future)    │ ││
│  │  │ • Edit      │  │ • CLOUD     │  │ • Visual editor     │ ││
│  │  │ • Activate  │  │ • Custom    │  │ • Preview           │ ││
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    AGENT UI                                 ││
│  │  ┌─────────────────────────────────────────────────────────┐││
│  │  │ Per-Area Configuration                                  │││
│  │  │ • Select landing page template                          │││
│  │  │ • Select CTA(s) - single or A/B test                    │││
│  │  │ • Preview                                               │││
│  │  │ • View performance metrics                              │││
│  │  └─────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    DATABASE                                 ││
│  │  ContentConfiguration ◄─► AreaOwnership (FR-001)           ││
│  │  CtaTemplate ◄─► ContentConfigurationCta                    ││
│  │  ContentConfigurationPerformance                            ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    RUNTIME                                  ││
│  │  Landing Page Request                                       ││
│  │        │                                                    ││
│  │        ▼                                                    ││
│  │  Load ContentConfiguration by AreaOwnershipId               ││
│  │        │                                                    ││
│  │        ▼                                                    ││
│  │  Inject CTA config into page context                        ││
│  │        │                                                    ││
│  │        ▼                                                    ││
│  │  Render CTA (same _LeadCtaTag.jsx component)                ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Database Schema

#### Table: `CtaTemplate`
Replaces hardcoded utils.js definitions.

```sql
CREATE TABLE dbo.CtaTemplate (
    CtaTemplateId           INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Identity
    CtaName                 NVARCHAR(100) NOT NULL,
    CtaCode                 NVARCHAR(50) NOT NULL,  -- Unique identifier
    CtaCategory             NVARCHAR(50) NOT NULL,
        -- Values: 'HomeValue', 'Newsletter', 'SocialFollow', 
        --         'Consultation', 'PropertyAlert', 'Custom'
    
    -- Content (matches current utils.js structure)
    CtaTitle                NVARCHAR(200) NULL,
    CtaSubTitle             NVARCHAR(500) NULL,
    CtaBody                 NVARCHAR(1000) NULL,
    CtaImage                NVARCHAR(500) NULL,      -- URL
    CtaDisclaimer           NVARCHAR(MAX) NULL,      -- JSON array
    CtaSubmitButtonText     NVARCHAR(100) NULL,
    CtaResponse             NVARCHAR(500) NULL,
    
    -- Behavior
    CtaShowContactForm      BIT NOT NULL DEFAULT 1,
    CtaContactFormBody      NVARCHAR(500) NULL,
    ScrollUpPercentage      INT NULL,
    ScrollDownPercentage    INT NULL,
    DelaySeconds            INT NULL,
    
    -- NEW: Social/Newsletter specific
    SocialPlatform          NVARCHAR(50) NULL,       -- Facebook, Instagram, etc.
    SocialUrl               NVARCHAR(500) NULL,
    NewsletterListId        NVARCHAR(100) NULL,      -- Mailchimp/etc list ID
    
    -- Metadata
    IsActive                BIT NOT NULL DEFAULT 1,
    IsDefault               BIT NOT NULL DEFAULT 0,
    CampaignTypes           NVARCHAR(100) NULL,      -- LC, CC, or both
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL,
    
    CONSTRAINT UQ_CtaTemplate_Code UNIQUE (CtaCode)
);
```

#### Table: `ContentConfiguration`
Per-area configuration linking to FR-001.

```sql
CREATE TABLE dbo.ContentConfiguration (
    ContentConfigurationId  INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Link to FR-001
    AreaOwnershipId         INT NOT NULL,
    
    -- Landing Page Selection
    LandingPageTemplateId   INT NULL,
    LandingPageUrl          NVARCHAR(500) NULL,
    
    -- CTA Mode
    CtaMode                 NVARCHAR(20) NOT NULL DEFAULT 'Single',
        -- Values: 'Single', 'ABTest', 'Rotation'
    
    -- Performance Tracking
    TotalDisplays           INT NOT NULL DEFAULT 0,
    TotalSubmissions        INT NOT NULL DEFAULT 0,
    TotalVerifications      INT NOT NULL DEFAULT 0,
    
    -- Metadata
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_ContentConfig_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId)
);
```

#### Table: `ContentConfigurationCta`
Links CTAs to configurations (supports multiple for A/B testing).

```sql
CREATE TABLE dbo.ContentConfigurationCta (
    ContentConfigurationCtaId INT IDENTITY(1,1) PRIMARY KEY,
    
    ContentConfigurationId  INT NOT NULL,
    CtaTemplateId           INT NOT NULL,
    
    -- A/B Test Weighting (if CtaMode = 'ABTest')
    Weight                  INT NOT NULL DEFAULT 100,  -- Percentage weight
    
    -- Performance (per CTA within this config)
    Displays                INT NOT NULL DEFAULT 0,
    Submissions             INT NOT NULL DEFAULT 0,
    Verifications           INT NOT NULL DEFAULT 0,
    
    -- Status
    IsActive                BIT NOT NULL DEFAULT 1,
    SortOrder               INT NOT NULL DEFAULT 0,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_ContentConfigCta_Config 
        FOREIGN KEY (ContentConfigurationId) REFERENCES dbo.ContentConfiguration(ContentConfigurationId),
    CONSTRAINT FK_ContentConfigCta_Template 
        FOREIGN KEY (CtaTemplateId) REFERENCES dbo.CtaTemplate(CtaTemplateId)
);
```

---

## 4. User Stories

### Agent Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| A1 | Agent | Select a landing page for my area | Content matches my brand |
| A2 | Agent | Choose which CTA appears on my pages | I control the messaging |
| A3 | Agent | Run A/B tests on CTAs | I find what converts best |
| A4 | Agent | See CTA performance metrics | I can optimize |
| A5 | Agent | Preview my configuration | I know what leads will see |
| A6 | Agent | Revert to default configuration | If I make a mistake |

### Admin Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| B1 | Admin | Create new CTA templates | Agents have options |
| B2 | Admin | Edit existing CTA content | Keep messaging current |
| B3 | Admin | Activate/deactivate CTAs | Control what's available |
| B4 | Admin | Set default CTAs by campaign type | New areas have good defaults |
| B5 | Admin | View performance across all CTAs | I know what works |
| B6 | Admin | Create new CTA categories | Expand beyond Home Value |

### System Stories
| ID | As the... | I want to... | So that... |
|----|-----------|--------------|------------|
| C1 | System | Create default config on area activation | Every area has CTAs |
| C2 | System | Track CTA displays and submissions | Performance is measured |
| C3 | System | Serve CTAs based on configuration | Customization works |
| C4 | System | Fall back to hardcoded if DB fails | Pages still work |

---

## 5. Workflow Diagrams

### Agent Configures Area Content

```
Agent Opens "My Areas"
        │
        ▼
┌─────────────────────┐
│ Select Area to      │
│ Configure           │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Content Configurator│
│ UI Opens            │
└────────┬────────────┘
         │
    ┌────┴────────────────┐
    │                     │
    ▼                     ▼
┌────────────┐     ┌────────────┐
│ Landing    │     │ CTA        │
│ Page Tab   │     │ Selection  │
│            │     │ Tab        │
│ • Template │     │ • Single   │
│ • Preview  │     │ • A/B Test │
└────────────┘     │ • Rotation │
                   └─────┬──────┘
                         │
                         ▼
                   ┌────────────┐
                   │ Save       │
                   │ Configuration│
                   └─────┬──────┘
                         │
                         ▼
                   ┌────────────┐
                   │ View       │
                   │ Performance│
                   │ Metrics    │
                   └────────────┘
```

### Runtime CTA Selection

```
Lead Visits Landing Page
        │
        ▼
┌─────────────────────┐
│ Page loads with     │
│ Area Context        │
│ (AreaOwnershipId)   │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Load Content        │
│ Configuration       │
│ from Database       │
└────────┬────────────┘
         │
    ┌────┴─────┐
    │          │
 FOUND      NOT FOUND
    │          │
    ▼          ▼
┌────────────────┐  ┌────────────────┐
│ Get CTA(s)     │  │ Use Default    │
│ from Config    │  │ Hardcoded CTA  │
└───────┬────────┘  └────────────────┘
        │
        ▼
┌─────────────────────┐
│ CtaMode?            │
└────────┬────────────┘
         │
    ┌────┼────────────┐
    │    │            │
 SINGLE  ABTEST    ROTATION
    │    │            │
    ▼    ▼            ▼
┌──────┐ ┌──────┐ ┌──────┐
│ Use  │ │Random│ │Cycle │
│ First│ │Weight│ │Order │
│ CTA  │ │Select│ │      │
└──────┘ └──────┘ └──────┘
         │
         ▼
┌─────────────────────┐
│ Inject CTA Data     │
│ into Page Context   │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ _LeadCtaTag.jsx     │
│ Renders Modal       │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Track Display       │
│ (increment counter) │
└─────────────────────┘
```

---

## 6. New CTA Types

### Proposed New Categories

| Category | Purpose | CTA Action |
|----------|---------|------------|
| **Newsletter Signup** | Grow email list | Subscribe to newsletter |
| **Social Follow** | Build social audience | Follow on Instagram/Facebook |
| **Consultation Request** | Schedule calls | Book appointment |
| **Property Alerts** | Lead nurturing | Sign up for new listings |
| **Custom** | Flexible | Agent-defined action |

### Social Follow CTA Example
```javascript
{
  ctaTitle: "Stay Connected",
  ctaSubTitle: "Follow for Local Real Estate Updates",
  ctaBody: "Get neighborhood insights, market trends, and exclusive listings",
  ctaImage: "agent-profile-or-social-preview.jpg",
  ctaSubmitButtonText: "Follow on Instagram",
  socialPlatform: "Instagram",
  socialUrl: "https://instagram.com/agent_handle",
  ctaShowContactForm: false  // Just opens social link
}
```

### Newsletter Signup CTA Example
```javascript
{
  ctaTitle: "Market Insider Newsletter",
  ctaSubTitle: "Weekly Neighborhood Insights",
  ctaBody: "Get exclusive market analysis delivered to your inbox",
  ctaSubmitButtonText: "Subscribe Now",
  ctaShowContactForm: true,  // Collect email
  newsletterListId: "mailchimp_list_123"
}
```

---

## 7. UI Mockups

### Agent Portal: Content Configurator

```
┌─────────────────────────────────────────────────────────────────┐
│  MY AREAS > 90210 Beverly Hills > Content Settings              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐  ┌─────────────────────────────────┐  │
│  │ LANDING PAGE        │  │ PREVIEW                         │  │
│  │                     │  │                                 │  │
│  │ Template:           │  │  [Landing Page Preview]         │  │
│  │ ┌─────────────────┐ │  │                                 │  │
│  │ │ Modern Sold  ▼  │ │  │       ┌─────────────────┐       │  │
│  │ └─────────────────┘ │  │       │  CTA Modal      │       │  │
│  │                     │  │       │  [Preview]      │       │  │
│  └─────────────────────┘  │       └─────────────────┘       │  │
│                           │                                 │  │
│  ┌─────────────────────┐  │                                 │  │
│  │ CTA SETTINGS        │  │                                 │  │
│  │                     │  │                                 │  │
│  │ Mode:               │  │                                 │  │
│  │ ○ Single CTA        │  │                                 │  │
│  │ ● A/B Test          │  │                                 │  │
│  │ ○ Rotation          │  │                                 │  │
│  │                     │  │                                 │  │
│  │ Selected CTAs:      │  │                                 │  │
│  │ ┌─────────────────┐ │  │                                 │  │
│  │ │☑ Home Value (50%)│ │  └─────────────────────────────────┘  │
│  │ │☑ Newsletter (50%)│ │                                      │
│  │ │☐ Social Follow   │ │  ┌─────────────────────────────────┐  │
│  │ │☐ Consultation    │ │  │ PERFORMANCE (Last 30 days)      │  │
│  │ └─────────────────┘ │  │                                 │  │
│  │                     │  │ Home Value:    523 displays     │  │
│  │ [Save Configuration]│  │                42 submissions   │  │
│  └─────────────────────┘  │                8.0% rate        │  │
│                           │                                 │  │
│                           │ Newsletter:    489 displays     │  │
│                           │                67 submissions   │  │
│                           │                13.7% rate ★     │  │
│                           └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Success Metrics

| Metric | Target | How Measured |
|--------|--------|--------------|
| Configuration adoption | 25%+ | Areas with custom config |
| A/B test usage | 10%+ | Configs with 2+ CTAs |
| CTA conversion lift | +15% | Avg conversion rate |
| Newsletter signups | 1000/month | New CTA category |
| Social follows | 500/month | New CTA category |
| Agent satisfaction | 4.5/5 | Survey rating |

---

## 9. Dependencies & Risks

### Dependencies
| Dependency | Owner | Status |
|------------|-------|--------|
| FR-001 AreaOwnership | Backend | In Progress |
| Genie CLOUD access | Cloud Team | Exists |
| Newsletter integration | Marketing | Need Mailchimp API |
| Social platform APIs | Dev | Research needed |

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing CTAs | Medium | High | Fallback to hardcoded |
| Performance impact | Low | Medium | Caching, lazy load |
| Agent confusion | Medium | Medium | Simple UI, defaults |
| Social API changes | Medium | Low | Graceful degradation |

---

## 10. Timeline Estimate

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 1: Schema** | 1 week | CTA templates, config tables |
| **Phase 2: Admin UI** | 2 weeks | CTA template management |
| **Phase 3: Agent UI** | 2 weeks | Content configurator |
| **Phase 4: Runtime** | 1 week | CTA loading, fallback |
| **Phase 5: New CTAs** | 2 weeks | Newsletter, Social Follow |
| **Phase 6: Test** | 1 week | End-to-end testing |

**Total Estimate:** 9 weeks

---

## 11. Related: CTA Management Design Brief

**Side Task Noted:** Create separate design brief for expanded CTA management system including:
- Visual CTA template builder (drag-and-drop)
- Dynamic field configuration
- Multi-language support
- Agent branding/customization

*This will be part of Genie Cloud and Paisley Dev agenda.*

---

## 12. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Technical Lead | | | |
| Cloud Team Lead | | | |

---

**Document Version:** 1.0  
**Created:** 12/13/2025  
**Status:** DRAFT

