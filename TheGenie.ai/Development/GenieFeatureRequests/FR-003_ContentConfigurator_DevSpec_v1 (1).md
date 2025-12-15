# Feature Request: Content Configurator
## FR-003 | Development Specification
### Version 1.0 | December 2025

---

## Document Purpose
This specification provides iterative development details for implementing the Content Configurator system. Each iteration is designed to be independently deployable and testable.

---

# ITERATION 1: Database Schema & Migration
## Target: Week 1

### Objective
Create database tables for CTA management and migrate existing hardcoded CTAs.

---

### 1.1 New Tables

#### Table: `CloudCTA`
```sql
CREATE TABLE dbo.CloudCTA (
    CloudCTAId              INT IDENTITY(1,1) PRIMARY KEY,
    CTACode                 NVARCHAR(50) NOT NULL,
    CTAName                 NVARCHAR(100) NOT NULL,
    CTAType                 NVARCHAR(30) NOT NULL,
        -- 'HomeValue', 'SocialFollow', 'Newsletter', 'Consultation', 'Custom'
    
    -- Display Content
    CTATitle                NVARCHAR(200) NOT NULL,
    CTASubTitle             NVARCHAR(300) NULL,
    CTABody                 NVARCHAR(500) NULL,
    CTAImageUrl             NVARCHAR(500) NULL,
    CTASubmitButtonText     NVARCHAR(50) NOT NULL DEFAULT 'Submit',
    CTAResponseMessage      NVARCHAR(500) NULL,
    CTADisclaimerJson       NVARCHAR(MAX) NULL, -- JSON array of disclaimer paragraphs
    
    -- Contact Form Settings
    ShowContactForm         BIT NOT NULL DEFAULT 1,
    ContactFormBody         NVARCHAR(500) NULL,
    RequiredFields          NVARCHAR(200) NULL, -- 'name,email,phone'
    
    -- Trigger Configuration
    TriggerDelay            INT NULL DEFAULT 10, -- Seconds
    TriggerScrollUp         INT NULL DEFAULT 15, -- Percentage
    TriggerScrollDown       INT NULL DEFAULT 60, -- Percentage
    ShowMobileBanner        BIT NOT NULL DEFAULT 0,
    
    -- Assignment Filters
    CampaignTypes           NVARCHAR(100) NULL, -- 'CC,LC,NC' or NULL for all
    PropertyTypes           NVARCHAR(100) NULL, -- '0,1,2' or NULL for all
    
    -- Status & Ordering
    IsActive                BIT NOT NULL DEFAULT 1,
    IsDefault               BIT NOT NULL DEFAULT 0,
    DisplayOrder            INT NOT NULL DEFAULT 0,
    
    -- Metadata
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL,
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedByUserId        NVARCHAR(128) NULL,
    
    CONSTRAINT UQ_CloudCTA_Code UNIQUE (CTACode)
);

-- Indexes
CREATE INDEX IX_CloudCTA_Type ON dbo.CloudCTA(CTAType) WHERE IsActive = 1;
CREATE INDEX IX_CloudCTA_Active ON dbo.CloudCTA(IsActive, DisplayOrder);
```

#### Table: `CloudLandingPage`
```sql
CREATE TABLE dbo.CloudLandingPage (
    CloudLandingPageId      INT IDENTITY(1,1) PRIMARY KEY,
    PageCode                NVARCHAR(50) NOT NULL,
    PageName                NVARCHAR(100) NOT NULL,
    PageType                NVARCHAR(30) NOT NULL,
        -- 'JustSold', 'JustListed', 'ActiveMarket', 'OpenHouse', 'AreaStats', 'Custom'
    
    -- Template Reference
    TemplateSlug            NVARCHAR(100) NOT NULL, -- e.g., 'lc-hollywood', 'cc-market'
    TemplateVersion         NVARCHAR(20) NULL,
    ThumbnailUrl            NVARCHAR(500) NULL,
    PreviewUrl              NVARCHAR(500) NULL,
    
    -- Description
    Description             NVARCHAR(500) NULL,
    
    -- Assignment Filters
    CampaignTypes           NVARCHAR(100) NULL,
    PropertyTypes           NVARCHAR(100) NULL,
    
    -- Status
    IsActive                BIT NOT NULL DEFAULT 1,
    IsDefault               BIT NOT NULL DEFAULT 0,
    DisplayOrder            INT NOT NULL DEFAULT 0,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT UQ_CloudLandingPage_Code UNIQUE (PageCode)
);
```

#### Table: `CTAGroup`
```sql
CREATE TABLE dbo.CTAGroup (
    CTAGroupId              INT IDENTITY(1,1) PRIMARY KEY,
    GroupCode               NVARCHAR(50) NOT NULL,
    GroupName               NVARCHAR(100) NOT NULL,
    Description             NVARCHAR(300) NULL,
    
    -- Rotation Strategy
    RotationType            NVARCHAR(20) NOT NULL DEFAULT 'Random',
        -- 'Random', 'Sequential', 'Weighted', 'TimeBased'
    
    -- For TimeBased rotation
    RotationIntervalMinutes INT NULL,
    
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL,
    
    CONSTRAINT UQ_CTAGroup_Code UNIQUE (GroupCode)
);

CREATE TABLE dbo.CTAGroupMember (
    CTAGroupMemberId        INT IDENTITY(1,1) PRIMARY KEY,
    CTAGroupId              INT NOT NULL,
    CloudCTAId              INT NOT NULL,
    
    -- For weighted rotation
    Weight                  INT NOT NULL DEFAULT 1,
    
    -- Ordering
    DisplayOrder            INT NOT NULL DEFAULT 0,
    
    -- Active within group
    IsActive                BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT FK_CTAGroupMember_Group 
        FOREIGN KEY (CTAGroupId) REFERENCES dbo.CTAGroup(CTAGroupId),
    CONSTRAINT FK_CTAGroupMember_CTA 
        FOREIGN KEY (CloudCTAId) REFERENCES dbo.CloudCTA(CloudCTAId),
    CONSTRAINT UQ_CTAGroupMember UNIQUE (CTAGroupId, CloudCTAId)
);
```

#### Table: `ContentConfiguration`
```sql
CREATE TABLE dbo.ContentConfiguration (
    ContentConfigurationId  INT IDENTITY(1,1) PRIMARY KEY,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    AreaOwnershipId         INT NULL, -- NULL = default for all user's areas
    
    -- Landing Page
    CloudLandingPageId      INT NULL,
    
    -- CTA Strategy
    CTAStrategy             NVARCHAR(20) NOT NULL DEFAULT 'Default',
        -- 'Default', 'Single', 'Rotating'
    
    -- CTA Selection
    SingleCTAId             INT NULL,
    CTAGroupId              INT NULL,
    
    -- Trigger Overrides (NULL = use CTA defaults)
    OverrideTriggerDelay    INT NULL,
    OverrideScrollUp        INT NULL,
    OverrideScrollDown      INT NULL,
    OverrideMobileBanner    BIT NULL,
    
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_ContentConfig_User 
        FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT FK_ContentConfig_LandingPage 
        FOREIGN KEY (CloudLandingPageId) REFERENCES dbo.CloudLandingPage(CloudLandingPageId),
    CONSTRAINT FK_ContentConfig_SingleCTA 
        FOREIGN KEY (SingleCTAId) REFERENCES dbo.CloudCTA(CloudCTAId),
    CONSTRAINT FK_ContentConfig_CTAGroup 
        FOREIGN KEY (CTAGroupId) REFERENCES dbo.CTAGroup(CTAGroupId)
);

CREATE INDEX IX_ContentConfig_User ON dbo.ContentConfiguration(AspNetUserId);
CREATE INDEX IX_ContentConfig_Area ON dbo.ContentConfiguration(AreaOwnershipId) 
    WHERE AreaOwnershipId IS NOT NULL;
```

#### Table: `CTAPerformance`
```sql
CREATE TABLE dbo.CTAPerformance (
    CTAPerformanceId        BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- CTA Reference
    CloudCTAId              INT NOT NULL,
    CTAGroupId              INT NULL,
    
    -- Context
    PropertyCastId          INT NULL,
    GenieLeadId             INT NULL,
    ShortUrlDataId          INT NULL,
    AspNetUserId            NVARCHAR(128) NULL, -- Agent who owns the area
    
    -- Event
    EventType               NVARCHAR(20) NOT NULL,
        -- 'Displayed', 'Dismissed', 'Clicked', 'Submitted', 'Verified', 'Converted'
    
    -- Session Info
    SessionId               NVARCHAR(100) NULL,
    LandingPageUrl          NVARCHAR(500) NULL,
    
    -- Device Info
    UserAgent               NVARCHAR(500) NULL,
    IsMobile                BIT NULL,
    DeviceType              NVARCHAR(20) NULL, -- 'Desktop', 'Mobile', 'Tablet'
    
    -- Timing
    TimeOnPageSeconds       INT NULL,
    ScrollDepthPercent      INT NULL,
    
    EventDate               DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_CTAPerformance_CTA 
        FOREIGN KEY (CloudCTAId) REFERENCES dbo.CloudCTA(CloudCTAId)
);

-- Partitioned indexes for performance
CREATE INDEX IX_CTAPerformance_CTAEvent ON dbo.CTAPerformance(CloudCTAId, EventType, EventDate);
CREATE INDEX IX_CTAPerformance_Date ON dbo.CTAPerformance(EventDate);
CREATE INDEX IX_CTAPerformance_Group ON dbo.CTAPerformance(CTAGroupId, EventType) 
    WHERE CTAGroupId IS NOT NULL;
CREATE INDEX IX_CTAPerformance_User ON dbo.CTAPerformance(AspNetUserId, EventDate) 
    WHERE AspNetUserId IS NOT NULL;
```

---

### 1.2 Migration: Existing CTAs to Database

```sql
-- Migrate hardcoded CTAs from utils.js to database
INSERT INTO dbo.CloudCTA (
    CTACode, CTAName, CTAType,
    CTATitle, CTASubTitle, CTABody, CTASubmitButtonText, CTAResponseMessage,
    ShowContactForm, ContactFormBody,
    TriggerDelay, TriggerScrollUp, TriggerScrollDown, ShowMobileBanner,
    CampaignTypes, IsActive, IsDefault, DisplayOrder
) VALUES
-- CTA ID 2 (LC, Delay 1s)
('HV-LC-QUICK-V1', 'Home Value - LC Quick v1', 'HomeValue',
 'Personalized Home Value Estimate', 'Discover Your Home''s True Worth',
 'Interested in a personalized valuation of your home?', 'Absolutely!',
 'Great! Your request has been submitted!',
 1, 'Please confirm your contact information.',
 1, 0, 0, 0, 'LC', 1, 0, 1),

-- CTA ID 3 (LC, Delay 2s)
('HV-LC-QUICK-V2', 'Home Value - LC Quick v2', 'HomeValue',
 'Accurate Home Valuation', 'What''s Your Home Really Worth?',
 'Would you like an accurate valuation of your property?', 'Yes, Please!',
 'Thank you! We''ll be in touch shortly.',
 1, 'Please confirm your contact information.',
 2, 0, 0, 0, 'LC', 1, 0, 2),

-- CTA ID 4 (CC, Delay 1s)
('HV-CC-QUICK-V1', 'Home Value - CC Quick v1', 'HomeValue',
 'Personalized Home Value Estimate', 'Discover Your Home''s True Worth',
 'Interested in a personalized valuation of your home?', 'Absolutely!',
 'Great! Your request has been submitted!',
 1, 'Please confirm your contact information.',
 1, 0, 0, 0, 'CC', 1, 0, 3),

-- CTA ID 5 (CC, Delay 2s)
('HV-CC-QUICK-V2', 'Home Value - CC Quick v2', 'HomeValue',
 'Accurate Home Valuation', 'What''s Your Home Really Worth?',
 'Would you like an accurate valuation of your property?', 'Yes, Please!',
 'Thank you! We''ll be in touch shortly.',
 1, 'Please confirm your contact information.',
 2, 0, 0, 0, 'CC', 1, 0, 4),

-- CTA ID 6 (LC, Full triggers)
('HV-LC-FULL-V1', 'Home Value - LC Full v1', 'HomeValue',
 'Personalized Home Value Estimate', 'Discover Your Home''s True Worth',
 'Interested in a personalized valuation of your home?', 'Absolutely!',
 'Great! Your request has been submitted!',
 1, 'Please confirm your contact information.',
 10, 15, 60, 1, 'LC', 1, 1, 5), -- Default for LC

-- CTA ID 7 (LC, Full triggers v2)
('HV-LC-FULL-V2', 'Home Value - LC Full v2', 'HomeValue',
 'Accurate Home Valuation', 'What''s Your Home Really Worth?',
 'Would you like an accurate valuation of your property?', 'Yes, Please!',
 'Thank you! We''ll be in touch shortly.',
 1, 'Please confirm your contact information.',
 10, 15, 60, 0, 'LC', 1, 0, 6),

-- CTA ID 8 (CC, Full triggers) - DEFAULT
('HV-CC-FULL-V1', 'Home Value - CC Full v1', 'HomeValue',
 'Personalized Home Value Estimate', 'Discover Your Home''s True Worth',
 'Interested in a personalized valuation of your home?', 'Absolutely!',
 'Great! Your request has been submitted!',
 1, 'Please confirm your contact information.',
 10, 15, 60, 1, 'CC', 1, 1, 7), -- Default for CC

-- CTA ID 9 (CC, Full triggers v2)
('HV-CC-FULL-V2', 'Home Value - CC Full v2', 'HomeValue',
 'Accurate Home Valuation', 'What''s Your Home Really Worth?',
 'Would you like an accurate valuation of your property?', 'Yes, Please!',
 'Thank you! We''ll be in touch shortly.',
 1, 'Please confirm your contact information.',
 10, 15, 60, 0, 'CC', 1, 0, 8);

-- Create default A/B test groups
INSERT INTO dbo.CTAGroup (GroupCode, GroupName, Description, RotationType) VALUES
('CC-AB-DEFAULT', 'CC Default A/B Test', 'Competition Command home value A/B test', 'Random'),
('LC-AB-DEFAULT', 'LC Default A/B Test', 'Listing Command home value A/B test', 'Random');

-- Add members to groups
INSERT INTO dbo.CTAGroupMember (CTAGroupId, CloudCTAId, Weight, DisplayOrder)
SELECT g.CTAGroupId, c.CloudCTAId, 1, c.DisplayOrder
FROM dbo.CTAGroup g
CROSS JOIN dbo.CloudCTA c
WHERE g.GroupCode = 'CC-AB-DEFAULT' AND c.CTACode LIKE 'HV-CC-FULL%'
UNION ALL
SELECT g.CTAGroupId, c.CloudCTAId, 1, c.DisplayOrder
FROM dbo.CTAGroup g
CROSS JOIN dbo.CloudCTA c
WHERE g.GroupCode = 'LC-AB-DEFAULT' AND c.CTACode LIKE 'HV-LC-FULL%';
```

---

### 1.3 Stored Procedures

#### Procedure: `usp_CTA_GetForCampaign`
```sql
CREATE PROCEDURE dbo.usp_CTA_GetForCampaign
    @AspNetUserId NVARCHAR(128),
    @AreaOwnershipId INT = NULL,
    @CampaignType NVARCHAR(10) = 'CC',
    @PropertyTypeId INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CloudCTAId INT;
    DECLARE @CTAGroupId INT;
    DECLARE @Strategy NVARCHAR(20);
    
    -- Check for user/area configuration
    SELECT TOP 1
        @Strategy = CTAStrategy,
        @CloudCTAId = SingleCTAId,
        @CTAGroupId = CTAGroupId
    FROM dbo.ContentConfiguration
    WHERE AspNetUserId = @AspNetUserId
      AND IsActive = 1
      AND (AreaOwnershipId = @AreaOwnershipId OR AreaOwnershipId IS NULL)
    ORDER BY 
        CASE WHEN AreaOwnershipId = @AreaOwnershipId THEN 0 ELSE 1 END;
    
    -- If no config, use defaults
    IF @Strategy IS NULL OR @Strategy = 'Default'
    BEGIN
        -- Get default CTA for campaign type
        SELECT TOP 1 @CloudCTAId = CloudCTAId
        FROM dbo.CloudCTA
        WHERE IsActive = 1
          AND IsDefault = 1
          AND (CampaignTypes IS NULL OR CampaignTypes LIKE '%' + @CampaignType + '%');
    END
    ELSE IF @Strategy = 'Rotating' AND @CTAGroupId IS NOT NULL
    BEGIN
        -- Get random CTA from group
        SELECT TOP 1 @CloudCTAId = gm.CloudCTAId
        FROM dbo.CTAGroupMember gm
        INNER JOIN dbo.CloudCTA c ON c.CloudCTAId = gm.CloudCTAId
        WHERE gm.CTAGroupId = @CTAGroupId
          AND gm.IsActive = 1
          AND c.IsActive = 1
        ORDER BY NEWID(); -- Random selection
    END
    
    -- Return full CTA data
    SELECT 
        c.CloudCTAId,
        c.CTACode,
        c.CTAType,
        c.CTATitle,
        c.CTASubTitle,
        c.CTABody,
        c.CTAImageUrl,
        c.CTASubmitButtonText,
        c.CTAResponseMessage,
        c.CTADisclaimerJson,
        c.ShowContactForm,
        c.ContactFormBody,
        c.TriggerDelay,
        c.TriggerScrollUp,
        c.TriggerScrollDown,
        c.ShowMobileBanner,
        @CTAGroupId AS CTAGroupId,
        @Strategy AS Strategy
    FROM dbo.CloudCTA c
    WHERE c.CloudCTAId = @CloudCTAId;
END;
```

#### Procedure: `usp_CTA_LogEvent`
```sql
CREATE PROCEDURE dbo.usp_CTA_LogEvent
    @CloudCTAId INT,
    @EventType NVARCHAR(20),
    @CTAGroupId INT = NULL,
    @PropertyCastId INT = NULL,
    @GenieLeadId INT = NULL,
    @ShortUrlDataId INT = NULL,
    @AspNetUserId NVARCHAR(128) = NULL,
    @SessionId NVARCHAR(100) = NULL,
    @LandingPageUrl NVARCHAR(500) = NULL,
    @UserAgent NVARCHAR(500) = NULL,
    @IsMobile BIT = NULL,
    @TimeOnPageSeconds INT = NULL,
    @ScrollDepthPercent INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.CTAPerformance (
        CloudCTAId, CTAGroupId, PropertyCastId, GenieLeadId, ShortUrlDataId,
        AspNetUserId, EventType, SessionId, LandingPageUrl,
        UserAgent, IsMobile, TimeOnPageSeconds, ScrollDepthPercent
    )
    VALUES (
        @CloudCTAId, @CTAGroupId, @PropertyCastId, @GenieLeadId, @ShortUrlDataId,
        @AspNetUserId, @EventType, @SessionId, @LandingPageUrl,
        @UserAgent, @IsMobile, @TimeOnPageSeconds, @ScrollDepthPercent
    );
END;
```

#### Procedure: `usp_CTA_GetPerformance`
```sql
CREATE PROCEDURE dbo.usp_CTA_GetPerformance
    @CloudCTAId INT = NULL,
    @CTAGroupId INT = NULL,
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL SET @StartDate = DATEADD(DAY, -30, GETUTCDATE());
    IF @EndDate IS NULL SET @EndDate = GETUTCDATE();
    
    SELECT 
        c.CloudCTAId,
        c.CTACode,
        c.CTAName,
        c.CTAType,
        COUNT(CASE WHEN p.EventType = 'Displayed' THEN 1 END) AS Displays,
        COUNT(CASE WHEN p.EventType = 'Dismissed' THEN 1 END) AS Dismissals,
        COUNT(CASE WHEN p.EventType = 'Submitted' THEN 1 END) AS Submissions,
        COUNT(CASE WHEN p.EventType = 'Verified' THEN 1 END) AS Verified,
        CAST(
            COUNT(CASE WHEN p.EventType = 'Submitted' THEN 1 END) * 100.0 / 
            NULLIF(COUNT(CASE WHEN p.EventType = 'Displayed' THEN 1 END), 0) 
        AS DECIMAL(5,2)) AS SubmissionRate,
        CAST(
            COUNT(CASE WHEN p.EventType = 'Verified' THEN 1 END) * 100.0 / 
            NULLIF(COUNT(CASE WHEN p.EventType = 'Submitted' THEN 1 END), 0) 
        AS DECIMAL(5,2)) AS VerificationRate,
        AVG(p.TimeOnPageSeconds) AS AvgTimeOnPage,
        AVG(p.ScrollDepthPercent) AS AvgScrollDepth
    FROM dbo.CloudCTA c
    LEFT JOIN dbo.CTAPerformance p ON p.CloudCTAId = c.CloudCTAId
        AND p.EventDate >= @StartDate
        AND p.EventDate <= @EndDate
    WHERE (@CloudCTAId IS NULL OR c.CloudCTAId = @CloudCTAId)
      AND (@CTAGroupId IS NULL OR p.CTAGroupId = @CTAGroupId)
    GROUP BY c.CloudCTAId, c.CTACode, c.CTAName, c.CTAType
    ORDER BY Displays DESC;
END;
```

---

### 1.4 Iteration 1 Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | Tables created | All 6 tables exist |
| 2 | Existing CTAs migrated | 8 CTAs in CloudCTA |
| 3 | Default groups created | CC and LC A/B groups exist |
| 4 | Get CTA procedure works | Returns correct CTA |
| 5 | Event logging works | Performance record created |
| 6 | Performance query works | Returns stats |

---

# ITERATION 2: Backend API
## Target: Week 2

### 2.1 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/cta` | List all active CTAs |
| GET | `/api/cta/{id}` | Get single CTA |
| GET | `/api/cta/for-campaign` | Get CTA for specific campaign |
| POST | `/api/cta/event` | Log CTA event |
| GET | `/api/cta/performance` | Get CTA performance stats |
| GET | `/api/landing-pages` | List available landing pages |
| GET | `/api/content-config` | Get user's content configuration |
| POST | `/api/content-config` | Save content configuration |

### Admin Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/admin/cta` | Create CTA |
| PUT | `/api/admin/cta/{id}` | Update CTA |
| DELETE | `/api/admin/cta/{id}` | Deactivate CTA |
| POST | `/api/admin/cta-group` | Create CTA group |
| PUT | `/api/admin/cta-group/{id}/members` | Manage group members |

---

# ITERATION 3: Frontend Integration
## Target: Week 3-4

### 3.1 Modify `utils.js` to Load from Database

```javascript
// Replace hardcoded CTAs with database fetch
export const getCtaData = async (ctaId) => {
    if (!ctaId) return { enabled: false };
    
    try {
        const response = await fetch(`/api/cta/${ctaId}`);
        if (!response.ok) {
            console.warn('CTA fetch failed, using fallback');
            return getFallbackCta(ctaId);
        }
        const data = await response.json();
        return mapCtaResponse(data);
    } catch (error) {
        console.error('CTA load error:', error);
        return getFallbackCta(ctaId);
    }
};

// For campaigns, get CTA based on config
export const getCtaForCampaign = async (userId, areaOwnershipId, campaignType) => {
    const params = new URLSearchParams({
        userId,
        areaOwnershipId: areaOwnershipId || '',
        campaignType
    });
    
    const response = await fetch(`/api/cta/for-campaign?${params}`);
    return response.json();
};

// Event tracking
export const logCtaEvent = async (eventData) => {
    await fetch('/api/cta/event', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData)
    });
};
```

---

# ITERATION 4: Agent UI - Content Configurator
## Target: Week 5-6

### 4.1 Angular Component Structure

```
content-configurator/
├── content-configurator.module.ts
├── content-configurator.component.ts
├── content-configurator.component.html
├── content-configurator.component.scss
├── components/
│   ├── landing-page-selector/
│   ├── cta-strategy-selector/
│   ├── cta-picker/
│   ├── trigger-settings/
│   └── preview-panel/
└── services/
    └── content-config.service.ts
```

---

## Appendix: New CTA Type Templates

### Newsletter Signup CTA
```sql
INSERT INTO dbo.CloudCTA (
    CTACode, CTAName, CTAType,
    CTATitle, CTASubTitle, CTABody, CTASubmitButtonText, CTAResponseMessage,
    ShowContactForm, RequiredFields,
    TriggerDelay, ShowMobileBanner, IsActive
) VALUES (
    'NL-WEEKLY-V1', 'Newsletter - Weekly Market', 'Newsletter',
    'Market Insider Newsletter', 'Weekly Real Estate Insights',
    'Get exclusive market reports, listing alerts, and expert tips delivered to your inbox.',
    'Subscribe', 'Welcome! Check your inbox for confirmation.',
    1, 'email,firstName',
    15, 0, 1
);
```

### Social Follow CTA
```sql
INSERT INTO dbo.CloudCTA (
    CTACode, CTAName, CTAType,
    CTATitle, CTASubTitle, CTABody, CTASubmitButtonText, CTAResponseMessage,
    ShowContactForm,
    TriggerDelay, ShowMobileBanner, IsActive
) VALUES (
    'SOC-FOLLOW-V1', 'Social Follow - Multi', 'SocialFollow',
    'Stay Connected!', 'Follow Us for Market Updates',
    'Get the latest real estate insights delivered to your feed.',
    'Follow Now', 'Thanks for following! See you on social.',
    0,
    20, 0, 1
);
```

---

*Document Version: 1.0*
*Created: 12/13/2025*
*Status: DRAFT - Ready for Review*

