# Feature Request: Content Configurator
## FR-003 | Development Specification
### Version 1.0

**Created:** 12/13/2025  
**Status:** DRAFT

---

## Document Purpose
This specification provides development details for implementing the Content Configurator system, enabling per-area CTA and landing page customization.

---

# ITERATION 1: Schema & CTA Template Migration
## Target: Week 1

### 1.1 Database Tables

#### Table: `CtaTemplate`
Migrate from hardcoded `utils.js` to database.

```sql
CREATE TABLE dbo.CtaTemplate (
    CtaTemplateId           INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Identity
    CtaName                 NVARCHAR(100) NOT NULL,
    CtaCode                 NVARCHAR(50) NOT NULL,
    CtaCategory             NVARCHAR(50) NOT NULL DEFAULT 'HomeValue',
        -- 'HomeValue', 'Newsletter', 'SocialFollow', 
        -- 'Consultation', 'PropertyAlert', 'Custom'
    
    -- Visible Content (matches current utils.js structure)
    CtaTitle                NVARCHAR(200) NULL,
    CtaSubTitle             NVARCHAR(500) NULL,
    CtaBody                 NVARCHAR(1000) NULL,
    CtaImage                NVARCHAR(500) NULL,
    CtaDisclaimer           NVARCHAR(MAX) NULL,       -- JSON array of paragraphs
    CtaSubmitButtonText     NVARCHAR(100) NULL,
    CtaResponse             NVARCHAR(500) NULL,
    
    -- Contact Form
    CtaShowContactForm      BIT NOT NULL DEFAULT 1,
    CtaContactFormBody      NVARCHAR(500) NULL,
    
    -- Trigger Behavior
    ScrollUpPercentage      INT NULL,                 -- 0-100, NULL = disabled
    ScrollDownPercentage    INT NULL,                 -- 0-100, NULL = disabled
    DelaySeconds            INT NULL,                 -- NULL = no delay trigger
    
    -- Social CTA Specific
    SocialPlatform          NVARCHAR(50) NULL,
    SocialUrl               NVARCHAR(500) NULL,
    SocialButtonStyle       NVARCHAR(100) NULL,       -- CSS class or inline
    
    -- Newsletter CTA Specific
    NewsletterListId        NVARCHAR(100) NULL,       -- Mailchimp/Sendgrid list ID
    NewsletterProvider      NVARCHAR(50) NULL,        -- 'Mailchimp', 'Sendgrid', etc.
    
    -- Consultation CTA Specific
    CalendarUrl             NVARCHAR(500) NULL,       -- Calendly, Acuity, etc.
    
    -- Control
    IsActive                BIT NOT NULL DEFAULT 1,
    IsDefault               BIT NOT NULL DEFAULT 0,
    CampaignTypes           NVARCHAR(50) NULL,        -- 'LC', 'CC', 'BOTH'
    SortOrder               INT NOT NULL DEFAULT 0,
    
    -- Metadata
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL,
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedByUserId        NVARCHAR(128) NULL,
    
    CONSTRAINT UQ_CtaTemplate_Code UNIQUE (CtaCode)
);

-- Indexes
CREATE INDEX IX_CtaTemplate_Category ON dbo.CtaTemplate(CtaCategory);
CREATE INDEX IX_CtaTemplate_Active ON dbo.CtaTemplate(IsActive);
CREATE INDEX IX_CtaTemplate_CampaignType ON dbo.CtaTemplate(CampaignTypes);
```

#### Seed Data: Migrate Existing CTAs
```sql
-- Migrate existing CTA definitions from utils.js
INSERT INTO dbo.CtaTemplate 
    (CtaTemplateId, CtaName, CtaCode, CtaCategory, CtaTitle, CtaSubTitle, CtaBody, 
     CtaSubmitButtonText, CtaResponse, CtaShowContactForm, CtaContactFormBody,
     ScrollDownPercentage, DelaySeconds, CampaignTypes, IsActive)
VALUES
    -- CTA ID 2 - Home Value Estimate (LC)
    (2, 'Home Value Estimate', 'HOME_VALUE_V1', 'HomeValue',
     'Personalized Home Value Estimate', 
     'Discover Your Home''s True Worth',
     'Interested in a personalized valuation?',
     'Absolutely!',
     'Great! Your request has been submitted!',
     1, 'Please confirm your contact information',
     75, 5, 'LC', 1),
     
    -- CTA ID 3 - Home Value Estimate v2 (LC)
    (3, 'Home Value Estimate v2', 'HOME_VALUE_V2', 'HomeValue',
     'What''s Your Home Worth Today?',
     'Get Your Free Home Valuation',
     'Find out your home''s current market value',
     'Get My Value!',
     'Thank you! We''ll send your valuation shortly.',
     1, 'Confirm your details',
     65, 3, 'LC', 1),
     
    -- CTA ID 4 - Property Valuation (CC)
    (4, 'Property Valuation', 'PROP_VALUE_V1', 'HomeValue',
     'Free Property Valuation',
     'Know Your Property''s Worth',
     'Get an instant market analysis',
     'Yes, Show Me!',
     'Your valuation is on the way!',
     1, 'Verify your contact info',
     75, 5, 'CC', 1),
     
    -- CTA ID 5 - Property Valuation v2 (CC)
    (5, 'Property Valuation v2', 'PROP_VALUE_V2', 'HomeValue',
     'Property Market Analysis',
     'What''s Your Property Worth?',
     'Discover the current market value',
     'Get My Analysis',
     'Thank you! Check your email.',
     1, 'Please confirm',
     65, 3, 'CC', 1),
     
    -- CTA ID 8 - Just Sold Property Value (CC)
    (8, 'Just Sold Property Value', 'JUST_SOLD_CC', 'HomeValue',
     'Similar Home Just Sold!',
     'Find Out What Yours is Worth',
     'A home nearby sold recently. Curious about your value?',
     'Show Me!',
     'We''ll send your comparison shortly!',
     1, 'Confirm your details',
     50, 4, 'CC', 1),
     
    -- CTA ID 9 - Just Listed Property Value (CC)
    (9, 'Just Listed Property Value', 'JUST_LISTED_CC', 'HomeValue',
     'New Listing in Your Area!',
     'How Does Your Home Compare?',
     'See how your property stacks up',
     'Compare Now',
     'Thanks! Your comparison is coming!',
     1, 'Verify your info',
     50, 4, 'CC', 1);

-- Enable IDENTITY_INSERT for explicit IDs, then turn off
SET IDENTITY_INSERT dbo.CtaTemplate ON;
-- (run inserts above)
SET IDENTITY_INSERT dbo.CtaTemplate OFF;
```

#### Table: `LandingPageTemplate`
```sql
CREATE TABLE dbo.LandingPageTemplate (
    LandingPageTemplateId   INT IDENTITY(1,1) PRIMARY KEY,
    
    TemplateName            NVARCHAR(100) NOT NULL,
    TemplateCode            NVARCHAR(50) NOT NULL,
    Description             NVARCHAR(500) NULL,
    
    -- CLOUD Integration
    CloudRenderId           NVARCHAR(100) NULL,       -- For Genie CLOUD pages
    TemplateUrl             NVARCHAR(500) NULL,       -- Base URL pattern
    
    -- Preview
    ThumbnailUrl            NVARCHAR(500) NULL,
    
    -- Control
    CampaignTypes           NVARCHAR(50) NULL,        -- 'LC', 'CC', 'BOTH'
    IsActive                BIT NOT NULL DEFAULT 1,
    IsDefault               BIT NOT NULL DEFAULT 0,
    SortOrder               INT NOT NULL DEFAULT 0,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT UQ_LandingPageTemplate_Code UNIQUE (TemplateCode)
);
```

#### Table: `ContentConfiguration`
```sql
CREATE TABLE dbo.ContentConfiguration (
    ContentConfigurationId  INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Link to FR-001
    AreaOwnershipId         INT NOT NULL,
    
    -- Landing Page
    LandingPageTemplateId   INT NULL,
    CustomLandingPageUrl    NVARCHAR(500) NULL,
    
    -- CTA Mode
    CtaMode                 NVARCHAR(20) NOT NULL DEFAULT 'Single',
        -- 'Single', 'ABTest', 'Rotation'
    
    -- A/B Test Settings
    MinSampleSize           INT NOT NULL DEFAULT 100,  -- Min displays before winner
    AutoSelectWinner        BIT NOT NULL DEFAULT 0,
    WinnerSelectedDate      DATETIME2 NULL,
    
    -- Performance Rollup
    TotalDisplays           INT NOT NULL DEFAULT 0,
    TotalSubmissions        INT NOT NULL DEFAULT 0,
    TotalVerifications      INT NOT NULL DEFAULT 0,
    ConversionRate          AS (CASE WHEN TotalDisplays > 0 
                                 THEN CAST(TotalSubmissions AS DECIMAL(10,4)) / TotalDisplays * 100 
                                 ELSE 0 END),
    
    -- Status
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_ContentConfig_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId),
    CONSTRAINT FK_ContentConfig_LandingPage 
        FOREIGN KEY (LandingPageTemplateId) REFERENCES dbo.LandingPageTemplate(LandingPageTemplateId)
);

CREATE INDEX IX_ContentConfig_AreaOwnershipId ON dbo.ContentConfiguration(AreaOwnershipId);
```

#### Table: `ContentConfigurationCta`
```sql
CREATE TABLE dbo.ContentConfigurationCta (
    ContentConfigurationCtaId INT IDENTITY(1,1) PRIMARY KEY,
    
    ContentConfigurationId  INT NOT NULL,
    CtaTemplateId           INT NOT NULL,
    
    -- A/B Test Weighting
    Weight                  INT NOT NULL DEFAULT 100,
    
    -- Per-CTA Performance
    Displays                INT NOT NULL DEFAULT 0,
    Submissions             INT NOT NULL DEFAULT 0,
    Verifications           INT NOT NULL DEFAULT 0,
    ConversionRate          AS (CASE WHEN Displays > 0 
                                 THEN CAST(Submissions AS DECIMAL(10,4)) / Displays * 100 
                                 ELSE 0 END),
    
    -- Control
    IsActive                BIT NOT NULL DEFAULT 1,
    IsWinner                BIT NOT NULL DEFAULT 0,
    SortOrder               INT NOT NULL DEFAULT 0,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_ContentConfigCta_Config 
        FOREIGN KEY (ContentConfigurationId) REFERENCES dbo.ContentConfiguration(ContentConfigurationId),
    CONSTRAINT FK_ContentConfigCta_Template 
        FOREIGN KEY (CtaTemplateId) REFERENCES dbo.CtaTemplate(CtaTemplateId)
);

CREATE INDEX IX_ContentConfigCta_ConfigId ON dbo.ContentConfigurationCta(ContentConfigurationId);
```

---

### 1.2 Stored Procedures

#### Procedure: `usp_ContentConfiguration_CreateDefault`
Called when area ownership is activated (FR-001/FR-002 integration).

```sql
CREATE PROCEDURE dbo.usp_ContentConfiguration_CreateDefault
    @AreaOwnershipId INT,
    @CampaignType NVARCHAR(10) = 'CC'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create config record
    INSERT INTO dbo.ContentConfiguration (AreaOwnershipId, CtaMode)
    VALUES (@AreaOwnershipId, 'Single');
    
    DECLARE @ConfigId INT = SCOPE_IDENTITY();
    
    -- Get default CTA for campaign type
    DECLARE @DefaultCtaId INT;
    SELECT TOP 1 @DefaultCtaId = CtaTemplateId
    FROM dbo.CtaTemplate
    WHERE IsActive = 1 
      AND IsDefault = 1
      AND (CampaignTypes = @CampaignType OR CampaignTypes = 'BOTH')
    ORDER BY SortOrder;
    
    -- Fallback to first active CTA
    IF @DefaultCtaId IS NULL
    BEGIN
        SELECT TOP 1 @DefaultCtaId = CtaTemplateId
        FROM dbo.CtaTemplate
        WHERE IsActive = 1 
          AND (CampaignTypes = @CampaignType OR CampaignTypes = 'BOTH')
        ORDER BY CtaTemplateId;
    END
    
    -- Link default CTA
    IF @DefaultCtaId IS NOT NULL
    BEGIN
        INSERT INTO dbo.ContentConfigurationCta (ContentConfigurationId, CtaTemplateId, Weight)
        VALUES (@ConfigId, @DefaultCtaId, 100);
    END
    
    SELECT @ConfigId AS ContentConfigurationId;
END;
```

#### Procedure: `usp_ContentConfiguration_GetForArea`
Runtime procedure to load configuration for page rendering.

```sql
CREATE PROCEDURE dbo.usp_ContentConfiguration_GetForArea
    @AreaOwnershipId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get config
    SELECT 
        cc.ContentConfigurationId,
        cc.AreaOwnershipId,
        cc.LandingPageTemplateId,
        cc.CustomLandingPageUrl,
        cc.CtaMode,
        cc.TotalDisplays,
        cc.TotalSubmissions,
        lpt.TemplateCode AS LandingPageCode,
        lpt.CloudRenderId
    FROM dbo.ContentConfiguration cc
    LEFT JOIN dbo.LandingPageTemplate lpt 
        ON lpt.LandingPageTemplateId = cc.LandingPageTemplateId
    WHERE cc.AreaOwnershipId = @AreaOwnershipId
      AND cc.IsActive = 1;
    
    -- Get CTAs
    SELECT 
        ccc.ContentConfigurationCtaId,
        ccc.CtaTemplateId,
        ccc.Weight,
        ccc.Displays,
        ccc.Submissions,
        ccc.IsWinner,
        ct.CtaCode,
        ct.CtaName,
        ct.CtaCategory,
        ct.CtaTitle,
        ct.CtaSubTitle,
        ct.CtaBody,
        ct.CtaImage,
        ct.CtaDisclaimer,
        ct.CtaSubmitButtonText,
        ct.CtaResponse,
        ct.CtaShowContactForm,
        ct.CtaContactFormBody,
        ct.ScrollUpPercentage,
        ct.ScrollDownPercentage,
        ct.DelaySeconds,
        ct.SocialPlatform,
        ct.SocialUrl,
        ct.NewsletterListId,
        ct.CalendarUrl
    FROM dbo.ContentConfigurationCta ccc
    INNER JOIN dbo.CtaTemplate ct ON ct.CtaTemplateId = ccc.CtaTemplateId
    INNER JOIN dbo.ContentConfiguration cc ON cc.ContentConfigurationId = ccc.ContentConfigurationId
    WHERE cc.AreaOwnershipId = @AreaOwnershipId
      AND cc.IsActive = 1
      AND ccc.IsActive = 1
      AND ct.IsActive = 1
    ORDER BY ccc.SortOrder, ccc.CtaTemplateId;
END;
```

#### Procedure: `usp_ContentConfiguration_SelectCta`
Runtime procedure to select CTA based on mode.

```sql
CREATE PROCEDURE dbo.usp_ContentConfiguration_SelectCta
    @ContentConfigurationId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CtaMode NVARCHAR(20);
    DECLARE @SelectedCtaId INT;
    
    SELECT @CtaMode = CtaMode 
    FROM dbo.ContentConfiguration 
    WHERE ContentConfigurationId = @ContentConfigurationId;
    
    IF @CtaMode = 'Single'
    BEGIN
        -- Return first (only) CTA
        SELECT TOP 1 @SelectedCtaId = CtaTemplateId
        FROM dbo.ContentConfigurationCta
        WHERE ContentConfigurationId = @ContentConfigurationId
          AND IsActive = 1
        ORDER BY SortOrder;
    END
    ELSE IF @CtaMode = 'ABTest'
    BEGIN
        -- Check if winner already selected
        SELECT @SelectedCtaId = CtaTemplateId
        FROM dbo.ContentConfigurationCta
        WHERE ContentConfigurationId = @ContentConfigurationId
          AND IsWinner = 1;
        
        IF @SelectedCtaId IS NULL
        BEGIN
            -- Weighted random selection
            DECLARE @TotalWeight INT;
            SELECT @TotalWeight = SUM(Weight)
            FROM dbo.ContentConfigurationCta
            WHERE ContentConfigurationId = @ContentConfigurationId
              AND IsActive = 1;
            
            DECLARE @Random INT = ABS(CHECKSUM(NEWID())) % @TotalWeight;
            DECLARE @RunningTotal INT = 0;
            
            SELECT TOP 1 @SelectedCtaId = CtaTemplateId
            FROM (
                SELECT 
                    CtaTemplateId,
                    Weight,
                    SUM(Weight) OVER (ORDER BY SortOrder) AS CumulativeWeight
                FROM dbo.ContentConfigurationCta
                WHERE ContentConfigurationId = @ContentConfigurationId
                  AND IsActive = 1
            ) AS Weighted
            WHERE CumulativeWeight > @Random
            ORDER BY CumulativeWeight;
        END
    END
    ELSE IF @CtaMode = 'Rotation'
    BEGIN
        -- Cycle through in order (use display count to determine next)
        SELECT TOP 1 @SelectedCtaId = CtaTemplateId
        FROM dbo.ContentConfigurationCta
        WHERE ContentConfigurationId = @ContentConfigurationId
          AND IsActive = 1
        ORDER BY Displays, SortOrder;  -- Least displayed first
    END
    
    -- Return full CTA data
    SELECT 
        ct.CtaTemplateId,
        ct.CtaCode,
        ct.CtaCategory,
        ct.CtaTitle,
        ct.CtaSubTitle,
        ct.CtaBody,
        ct.CtaImage,
        ct.CtaDisclaimer,
        ct.CtaSubmitButtonText,
        ct.CtaResponse,
        ct.CtaShowContactForm,
        ct.CtaContactFormBody,
        ct.ScrollUpPercentage,
        ct.ScrollDownPercentage,
        ct.DelaySeconds,
        ct.SocialPlatform,
        ct.SocialUrl,
        ct.NewsletterListId,
        ct.CalendarUrl
    FROM dbo.CtaTemplate ct
    WHERE ct.CtaTemplateId = @SelectedCtaId;
END;
```

#### Procedure: `usp_ContentConfiguration_RecordDisplay`
Track CTA display for performance.

```sql
CREATE PROCEDURE dbo.usp_ContentConfiguration_RecordDisplay
    @ContentConfigurationId INT,
    @CtaTemplateId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Increment display count on CTA link
    UPDATE dbo.ContentConfigurationCta
    SET Displays = Displays + 1
    WHERE ContentConfigurationId = @ContentConfigurationId
      AND CtaTemplateId = @CtaTemplateId;
    
    -- Increment display count on config
    UPDATE dbo.ContentConfiguration
    SET TotalDisplays = TotalDisplays + 1,
        ModifiedDate = GETUTCDATE()
    WHERE ContentConfigurationId = @ContentConfigurationId;
END;
```

---

# ITERATION 2: Admin CTA Template Management
## Target: Week 2-3

### 2.1 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/cta-templates` | List all CTA templates |
| GET | `/api/admin/cta-templates/{id}` | Get single template |
| POST | `/api/admin/cta-templates` | Create template |
| PUT | `/api/admin/cta-templates/{id}` | Update template |
| DELETE | `/api/admin/cta-templates/{id}` | Deactivate template |
| POST | `/api/admin/cta-templates/{id}/duplicate` | Clone template |

### 2.2 Controller: `CtaTemplateAdminController.cs`

```csharp
[Route("api/admin/cta-templates")]
[Authorize(Roles = "Admin")]
public class CtaTemplateAdminController : ApiController
{
    [HttpGet]
    public IHttpActionResult GetAll([FromUri] CtaTemplateFilter filter)
    {
        var templates = Proxy.GetCtaTemplates(filter);
        return Ok(templates);
    }
    
    [HttpGet("{id}")]
    public IHttpActionResult Get(int id)
    {
        var template = Proxy.GetCtaTemplate(id);
        if (template == null)
            return NotFound();
        return Ok(template);
    }
    
    [HttpPost]
    public IHttpActionResult Create([FromBody] CtaTemplateCreateRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);
        
        // Generate unique code
        request.CtaCode = GenerateCtaCode(request.CtaName);
        
        var id = Proxy.CreateCtaTemplate(request, User.Identity.GetUserId());
        return CreatedAtRoute("GetCtaTemplate", new { id }, new { CtaTemplateId = id });
    }
    
    [HttpPut("{id}")]
    public IHttpActionResult Update(int id, [FromBody] CtaTemplateUpdateRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);
        
        var existing = Proxy.GetCtaTemplate(id);
        if (existing == null)
            return NotFound();
        
        Proxy.UpdateCtaTemplate(id, request, User.Identity.GetUserId());
        return Ok();
    }
    
    [HttpDelete("{id}")]
    public IHttpActionResult Delete(int id)
    {
        // Soft delete - check if in use
        var usageCount = Proxy.GetCtaTemplateUsageCount(id);
        if (usageCount > 0)
        {
            // Deactivate instead of delete
            Proxy.DeactivateCtaTemplate(id, User.Identity.GetUserId());
            return Ok(new { Message = $"Template deactivated. In use by {usageCount} configurations." });
        }
        
        Proxy.DeleteCtaTemplate(id);
        return Ok();
    }
    
    [HttpPost("{id}/duplicate")]
    public IHttpActionResult Duplicate(int id)
    {
        var existing = Proxy.GetCtaTemplate(id);
        if (existing == null)
            return NotFound();
        
        var newId = Proxy.DuplicateCtaTemplate(id, User.Identity.GetUserId());
        return Ok(new { CtaTemplateId = newId });
    }
}
```

---

# ITERATION 3: Agent Content Configurator UI
## Target: Week 4-5

### 3.1 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/content-config/{areaOwnershipId}` | Get area configuration |
| PUT | `/api/content-config/{areaOwnershipId}` | Update configuration |
| GET | `/api/content-config/{areaOwnershipId}/preview` | Get preview data |
| GET | `/api/content-config/{areaOwnershipId}/performance` | Get metrics |
| POST | `/api/content-config/{areaOwnershipId}/reset` | Reset to default |

### 3.2 Controller: `ContentConfigurationController.cs`

```csharp
[Route("api/content-config")]
[Authorize]
public class ContentConfigurationController : ApiController
{
    [HttpGet("{areaOwnershipId}")]
    public IHttpActionResult Get(int areaOwnershipId)
    {
        // Verify ownership belongs to user
        var ownership = Proxy.GetAreaOwnership(areaOwnershipId);
        if (ownership == null || ownership.AspNetUserId != User.Identity.GetUserId())
            return NotFound();
        
        var config = ContentConfigService.GetConfiguration(areaOwnershipId);
        
        // Include available CTAs for selection
        var availableCtas = Proxy.GetActiveCtaTemplates("CC");
        var availableLandingPages = Proxy.GetActiveLandingPageTemplates("CC");
        
        return Ok(new {
            Configuration = config,
            AvailableCtas = availableCtas,
            AvailableLandingPages = availableLandingPages
        });
    }
    
    [HttpPut("{areaOwnershipId}")]
    public IHttpActionResult Update(int areaOwnershipId, [FromBody] ContentConfigUpdateRequest request)
    {
        // Verify ownership
        var ownership = Proxy.GetAreaOwnership(areaOwnershipId);
        if (ownership == null || ownership.AspNetUserId != User.Identity.GetUserId())
            return NotFound();
        
        if (!ModelState.IsValid)
            return BadRequest(ModelState);
        
        // Validate CTA mode
        if (request.CtaMode == "Single" && request.SelectedCtaIds.Count != 1)
            return BadRequest("Single mode requires exactly one CTA");
        
        if (request.CtaMode == "ABTest" && request.SelectedCtaIds.Count < 2)
            return BadRequest("A/B Test mode requires at least two CTAs");
        
        ContentConfigService.UpdateConfiguration(areaOwnershipId, request);
        return Ok();
    }
    
    [HttpGet("{areaOwnershipId}/preview")]
    public IHttpActionResult Preview(int areaOwnershipId, [FromUri] int? ctaTemplateId = null)
    {
        // Verify ownership
        var ownership = Proxy.GetAreaOwnership(areaOwnershipId);
        if (ownership == null || ownership.AspNetUserId != User.Identity.GetUserId())
            return NotFound();
        
        var previewData = ContentConfigService.GetPreviewData(areaOwnershipId, ctaTemplateId);
        return Ok(previewData);
    }
    
    [HttpGet("{areaOwnershipId}/performance")]
    public IHttpActionResult GetPerformance(int areaOwnershipId, [FromUri] int days = 30)
    {
        // Verify ownership
        var ownership = Proxy.GetAreaOwnership(areaOwnershipId);
        if (ownership == null || ownership.AspNetUserId != User.Identity.GetUserId())
            return NotFound();
        
        var performance = ContentConfigService.GetPerformanceMetrics(areaOwnershipId, days);
        return Ok(performance);
    }
    
    [HttpPost("{areaOwnershipId}/reset")]
    public IHttpActionResult Reset(int areaOwnershipId)
    {
        // Verify ownership
        var ownership = Proxy.GetAreaOwnership(areaOwnershipId);
        if (ownership == null || ownership.AspNetUserId != User.Identity.GetUserId())
            return NotFound();
        
        ContentConfigService.ResetToDefault(areaOwnershipId);
        return Ok();
    }
}
```

---

# ITERATION 4: Runtime CTA Loading
## Target: Week 6

### 4.1 Service: `ContentConfigurationRuntimeService.cs`

```csharp
namespace Smart.Core.BLL.ContentConfiguration
{
    public class ContentConfigurationRuntimeService
    {
        private readonly ICache _cache;
        private readonly TimeSpan _cacheDuration = TimeSpan.FromMinutes(5);
        
        public CtaData GetCtaForArea(int areaOwnershipId)
        {
            // Try cache first
            var cacheKey = $"cta_config_{areaOwnershipId}";
            var cached = _cache.Get<CtaData>(cacheKey);
            if (cached != null)
                return cached;
            
            // Load from database
            var config = Proxy.GetContentConfiguration(areaOwnershipId);
            
            if (config == null)
            {
                // No configuration - use fallback
                return GetFallbackCta();
            }
            
            // Select CTA based on mode
            var selectedCta = SelectCta(config);
            
            // Track display asynchronously
            Task.Run(() => RecordDisplay(config.ContentConfigurationId, selectedCta.CtaTemplateId));
            
            // Cache and return
            _cache.Set(cacheKey, selectedCta, _cacheDuration);
            return selectedCta;
        }
        
        private CtaData SelectCta(ContentConfigurationData config)
        {
            switch (config.CtaMode)
            {
                case "Single":
                    return config.Ctas.First();
                    
                case "ABTest":
                    return SelectWeightedRandom(config.Ctas);
                    
                case "Rotation":
                    return SelectLeastDisplayed(config.Ctas);
                    
                default:
                    return config.Ctas.FirstOrDefault() ?? GetFallbackCta();
            }
        }
        
        private CtaData SelectWeightedRandom(List<CtaConfigData> ctas)
        {
            var totalWeight = ctas.Sum(c => c.Weight);
            var random = new Random().Next(totalWeight);
            var runningTotal = 0;
            
            foreach (var cta in ctas)
            {
                runningTotal += cta.Weight;
                if (random < runningTotal)
                    return cta.CtaData;
            }
            
            return ctas.First().CtaData;
        }
        
        private CtaData SelectLeastDisplayed(List<CtaConfigData> ctas)
        {
            return ctas.OrderBy(c => c.Displays).First().CtaData;
        }
        
        private CtaData GetFallbackCta()
        {
            // Return hardcoded default (same as utils.js CTA ID 4)
            return new CtaData
            {
                CtaTemplateId = 4,
                CtaCode = "PROP_VALUE_V1",
                CtaTitle = "Free Property Valuation",
                CtaSubTitle = "Know Your Property's Worth",
                CtaBody = "Get an instant market analysis",
                CtaSubmitButtonText = "Yes, Show Me!",
                CtaResponse = "Your valuation is on the way!",
                CtaShowContactForm = true,
                ScrollDownPercentage = 75,
                DelaySeconds = 5
            };
        }
        
        private void RecordDisplay(int configId, int ctaTemplateId)
        {
            try
            {
                Proxy.RecordCtaDisplay(configId, ctaTemplateId);
            }
            catch (Exception ex)
            {
                // Log but don't fail - display tracking is not critical
                Logger.Error("Failed to record CTA display", ex);
            }
        }
    }
}
```

### 4.2 Handler Update: `CloudCtaSplitHandler.cs`

Modify existing handler to check database config first:

```csharp
public int GetCtaId(int? areaOwnershipId)
{
    // NEW: Check database configuration first
    if (areaOwnershipId.HasValue)
    {
        var runtimeService = new ContentConfigurationRuntimeService();
        var ctaData = runtimeService.GetCtaForArea(areaOwnershipId.Value);
        
        if (ctaData != null)
            return ctaData.CtaTemplateId;
    }
    
    // EXISTING: Fall back to original split logic
    if (IsSingleCta)
        return CtaSplit.First();
    
    // Cycle through CTAs
    return GetNextInRotation();
}
```

---

# ITERATION 5: New CTA Types
## Target: Week 7-8

### 5.1 Newsletter Signup Integration

```csharp
public class NewsletterCtaHandler
{
    public async Task<ResponseBase> ProcessSubmission(int ctaTemplateId, LeadData lead)
    {
        var template = Proxy.GetCtaTemplate(ctaTemplateId);
        
        if (template.CtaCategory != "Newsletter")
            return ResponseHelper.GetError("Not a newsletter CTA");
        
        switch (template.NewsletterProvider)
        {
            case "Mailchimp":
                return await MailchimpService.Subscribe(
                    template.NewsletterListId, 
                    lead.Email, 
                    lead.FirstName, 
                    lead.LastName);
                    
            case "Sendgrid":
                return await SendgridService.Subscribe(
                    template.NewsletterListId, 
                    lead.Email);
                    
            default:
                // Store locally for manual export
                return Proxy.AddToLocalNewsletter(lead);
        }
    }
}
```

### 5.2 Social Follow CTA

```csharp
public class SocialFollowCtaHandler
{
    public SocialFollowResult ProcessClick(int ctaTemplateId)
    {
        var template = Proxy.GetCtaTemplate(ctaTemplateId);
        
        if (template.CtaCategory != "SocialFollow")
            return null;
        
        // Track the click
        Proxy.RecordSocialClick(ctaTemplateId, template.SocialPlatform);
        
        // Return URL for redirect
        return new SocialFollowResult
        {
            Platform = template.SocialPlatform,
            Url = template.SocialUrl,
            ButtonStyle = template.SocialButtonStyle
        };
    }
}
```

---

## Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | CTA templates in database | All 6 current CTAs migrated |
| 2 | Default config created | On area activation (FR-001) |
| 3 | Single mode works | Returns configured CTA |
| 4 | A/B Test mode works | Weighted random selection |
| 5 | Rotation mode works | Cycles through CTAs |
| 6 | Display tracking | Counts increment on display |
| 7 | Submission tracking | Counts increment on submit |
| 8 | Agent can configure | UI saves to database |
| 9 | Preview works | Shows selected CTA |
| 10 | Fallback works | Returns hardcoded if DB fails |
| 11 | Newsletter CTA | Email subscribed to list |
| 12 | Social CTA | Redirect to social profile |

---

**Document Version:** 1.0  
**Created:** 12/13/2025  
**Status:** DRAFT

