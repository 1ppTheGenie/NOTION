# Feature Request: WHMCS Area Billing Integration
## FR-002 | Development Specification
### Version 1.0

**Created:** 12/13/2025  
**Status:** DRAFT

---

## Document Purpose
This specification provides development details for implementing WHMCS billing integration for Competition Command area purchases.

---

# ITERATION 1: Schema & Configuration
## Target: Week 1

### 1.1 Database Tables

#### Table: `CompetitionCommandBilling`
```sql
CREATE TABLE dbo.CompetitionCommandBilling (
    CompetitionCommandBillingId INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Links
    AreaOwnershipId         INT NOT NULL,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    
    -- WHMCS Order Details
    WhmcsOrderId            INT NULL,
    WhmcsInvoiceId          INT NULL,
    WhmcsClientId           INT NULL,
    WhmcsProductId          INT NULL,
    
    -- Pricing Breakdown
    BaseAmount              DECIMAL(10,2) NOT NULL,
    BundleTier              NVARCHAR(50) NULL,
    BundleDiscount          DECIMAL(10,2) NOT NULL DEFAULT 0,
    PromoCodeId             INT NULL,
    PromoCode               NVARCHAR(50) NULL,
    PromoDiscount           DECIMAL(10,2) NOT NULL DEFAULT 0,
    FinalAmount             AS (BaseAmount - BundleDiscount - PromoDiscount),
    
    -- Status
    BillingStatus           NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        -- Values: 'Pending', 'Processing', 'Active', 'Failed', 
        --         'Canceled', 'Suspended', 'PastDue'
    
    -- WHMCS Response
    ResponseCode            INT NULL,
    ResponseMessage         NVARCHAR(500) NULL,
    
    -- Retry Tracking
    RetryCount              INT NOT NULL DEFAULT 0,
    LastRetryDate           DATETIME2 NULL,
    NextRetryDate           DATETIME2 NULL,
    
    -- Billing Period
    BillingStartDate        DATETIME2 NULL,
    BillingEndDate          DATETIME2 NULL,
    NextBillingDate         DATETIME2 NULL,
    BillingCycleMonths      INT NOT NULL DEFAULT 1,
    
    -- Metadata
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    -- Constraints
    CONSTRAINT FK_CCBilling_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId),
    CONSTRAINT FK_CCBilling_AspNetUsers 
        FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id)
);

-- Indexes
CREATE INDEX IX_CCBilling_AreaOwnershipId ON dbo.CompetitionCommandBilling(AreaOwnershipId);
CREATE INDEX IX_CCBilling_AspNetUserId ON dbo.CompetitionCommandBilling(AspNetUserId);
CREATE INDEX IX_CCBilling_Status ON dbo.CompetitionCommandBilling(BillingStatus);
CREATE INDEX IX_CCBilling_WhmcsOrderId ON dbo.CompetitionCommandBilling(WhmcsOrderId);
CREATE INDEX IX_CCBilling_NextRetry ON dbo.CompetitionCommandBilling(NextRetryDate) 
    WHERE BillingStatus = 'Failed';
```

#### Table: `CompetitionCommandPricing`
```sql
CREATE TABLE dbo.CompetitionCommandPricing (
    CompetitionCommandPricingId INT IDENTITY(1,1) PRIMARY KEY,
    
    PricingName             NVARCHAR(100) NOT NULL,
    PropertyTypeId          INT NOT NULL DEFAULT 0,
        -- 0=SFR, 1=Condo, 2=Townhouse, 3=Multi-Family
    
    BaseMonthlyPrice        DECIMAL(10,2) NOT NULL,
    BaseAnnualPrice         DECIMAL(10,2) NULL,  -- Optional annual option
    
    WhmcsProductId          INT NOT NULL,
    
    IsActive                BIT NOT NULL DEFAULT 1,
    EffectiveDate           DATE NOT NULL,
    ExpirationDate          DATE NULL,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL
);

-- Seed initial pricing
INSERT INTO dbo.CompetitionCommandPricing 
    (PricingName, PropertyTypeId, BaseMonthlyPrice, WhmcsProductId, EffectiveDate)
VALUES 
    ('CC Standard - SFR', 0, 99.00, [TBD_PRODUCT_ID], '2025-01-01'),
    ('CC Standard - Condo', 1, 79.00, [TBD_PRODUCT_ID], '2025-01-01'),
    ('CC Standard - Townhouse', 2, 79.00, [TBD_PRODUCT_ID], '2025-01-01'),
    ('CC Standard - Multi-Family', 3, 149.00, [TBD_PRODUCT_ID], '2025-01-01');
```

#### Table: `CompetitionCommandBundle`
```sql
CREATE TABLE dbo.CompetitionCommandBundle (
    CompetitionCommandBundleId INT IDENTITY(1,1) PRIMARY KEY,
    
    BundleName              NVARCHAR(100) NOT NULL,
    BundleCode              NVARCHAR(20) NOT NULL,  -- Internal identifier
    
    MinAreas                INT NOT NULL,
    MaxAreas                INT NULL,  -- NULL = no upper limit
    
    DiscountType            NVARCHAR(20) NOT NULL DEFAULT 'Percent',
        -- Values: 'Percent', 'FixedPerArea', 'FixedTotal'
    DiscountValue           DECIMAL(10,2) NOT NULL,
    
    IsActive                BIT NOT NULL DEFAULT 1,
    SortOrder               INT NOT NULL DEFAULT 0,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Seed bundle tiers
INSERT INTO dbo.CompetitionCommandBundle 
    (BundleName, BundleCode, MinAreas, MaxAreas, DiscountType, DiscountValue, SortOrder)
VALUES 
    ('Single', 'SINGLE', 1, 1, 'Percent', 0, 1),
    ('Starter Pack', 'STARTER', 2, 3, 'Percent', 10, 2),
    ('Pro Pack', 'PRO', 4, 6, 'Percent', 15, 3),
    ('Enterprise', 'ENTERPRISE', 7, NULL, 'Percent', 25, 4);
```

#### Table: `CompetitionCommandPromoCode`
```sql
CREATE TABLE dbo.CompetitionCommandPromoCode (
    CompetitionCommandPromoCodeId INT IDENTITY(1,1) PRIMARY KEY,
    
    PromoCode               NVARCHAR(50) NOT NULL,
    Description             NVARCHAR(200) NULL,
    
    DiscountType            NVARCHAR(20) NOT NULL,
        -- Values: 'Percent', 'FixedAmount', 'FreeMonth', 'FreeTrial'
    DiscountValue           DECIMAL(10,2) NOT NULL,
    TrialDays               INT NULL,  -- For FreeTrial type
    
    -- Validity
    StartDate               DATETIME2 NOT NULL,
    EndDate                 DATETIME2 NULL,
    
    -- Usage Limits
    MaxTotalUses            INT NULL,  -- NULL = unlimited
    MaxUsesPerUser          INT NOT NULL DEFAULT 1,
    CurrentUses             INT NOT NULL DEFAULT 0,
    
    -- Restrictions
    NewCustomersOnly        BIT NOT NULL DEFAULT 0,
    MinAreas                INT NULL,  -- Minimum areas required
    AllowedRoles            NVARCHAR(200) NULL,  -- Comma-separated role IDs
    
    IsActive                BIT NOT NULL DEFAULT 1,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL,
    
    CONSTRAINT UQ_CCPromoCode UNIQUE (PromoCode)
);

CREATE INDEX IX_CCPromoCode_Active ON dbo.CompetitionCommandPromoCode(PromoCode, IsActive);
```

#### Table: `CompetitionCommandPromoCodeUsage`
```sql
CREATE TABLE dbo.CompetitionCommandPromoCodeUsage (
    CompetitionCommandPromoCodeUsageId INT IDENTITY(1,1) PRIMARY KEY,
    
    PromoCodeId             INT NOT NULL,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    CompetitionCommandBillingId INT NOT NULL,
    
    DiscountApplied         DECIMAL(10,2) NOT NULL,
    UsedDate                DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_CCPromoUsage_Promo 
        FOREIGN KEY (PromoCodeId) REFERENCES dbo.CompetitionCommandPromoCode(CompetitionCommandPromoCodeId),
    CONSTRAINT FK_CCPromoUsage_User 
        FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id)
);
```

---

### 1.2 Configuration Values

```sql
-- Add to application config or web.config
-- CompetitionCommandWhmcsProductId = [TBD]
-- CompetitionCommandMaxRetries = 3
-- CompetitionCommandRetryIntervalDays = 2
-- CompetitionCommandGracePeriodDays = 7
```

---

# ITERATION 2: Billing Handler
## Target: Week 2-3

### 2.1 Handler: `CompetitionCommandBillingHandler.cs`

Based on existing pattern from `ListingCommandBillingHandler.cs`:

```csharp
namespace Smart.Core.BLL.CompetitionCommand.Billing
{
    public class CompetitionCommandBillingHandler : HandlerWorkflowBillingBase
    {
        private readonly ICompetitionCommandPricingService _pricingService;
        private readonly ICompetitionCommandBundleService _bundleService;
        private readonly ICompetitionCommandPromoService _promoService;
        
        public override ResponseWithKey Process(
            string aspNetUserId, 
            int areaOwnershipId, 
            int? promoCodeId = null)
        {
            var response = ResponseHelper.GetSuccess<ResponseWithKey>();
            
            // 1. Load area ownership (from FR-001)
            var ownership = Proxy.GetAreaOwnership(areaOwnershipId);
            if (ownership == null || ownership.Status != "Pending")
            {
                response.Message = "Invalid ownership or not pending";
                return response;
            }
            
            // 2. Get WHMCS client
            var whmcsClientId = Proxy.GetUserWhmcs(aspNetUserId)?.WhmcsClientId;
            if (!whmcsClientId.HasValue)
            {
                response.Message = "User has no WHMCS account";
                return response;
            }
            
            // 3. Calculate pricing
            var pricing = CalculatePricing(aspNetUserId, ownership, promoCodeId);
            
            // 4. Create billing record
            var billing = CreateBillingRecord(ownership, pricing);
            
            // 5. Add WHMCS order
            var addOrderResponse = AddOrder(ownership, billing, whmcsClientId.Value);
            
            if (!WhmcsHelper.IsWhmcsSuccess(addOrderResponse))
            {
                billing.BillingStatus = "Failed";
                billing.ResponseCode = addOrderResponse.Result;
                billing.ResponseMessage = addOrderResponse.Message;
                UpdateBilling(billing);
                
                // Log history
                LogOwnershipHistory(areaOwnershipId, "BillingFailed", addOrderResponse.Message);
                
                response.Message = addOrderResponse.Message;
                return response;
            }
            
            var whmcsOrderResponse = ResponseHelper.GetSuccess<ResponseWhmcsOrder>();
            whmcsOrderResponse.WhmcsOrderId = addOrderResponse.OrderID;
            
            // 6. Capture payment
            var capture = new CapturePaymentManager(whmcsClientId.Value, Config.CompetitionCommandWhmcsProductId);
            capture.ProcessNewOrder(whmcsOrderResponse);
            
            if (!whmcsOrderResponse.Success)
            {
                HandleFailedPayment(billing, whmcsOrderResponse, areaOwnershipId);
                response.Message = "Payment capture failed";
                return response;
            }
            
            // 7. Success - update billing
            billing.WhmcsOrderId = whmcsOrderResponse.WhmcsOrderId;
            billing.BillingStatus = "Active";
            billing.BillingStartDate = DateTime.UtcNow;
            billing.NextBillingDate = DateTime.UtcNow.AddMonths(billing.BillingCycleMonths);
            UpdateBilling(billing);
            
            // 8. Activate ownership (FR-001 integration)
            ActivateAreaOwnership(areaOwnershipId, billing.CompetitionCommandBillingId);
            
            // 9. Create default content config (FR-003 integration)
            CreateDefaultContentConfiguration(areaOwnershipId);
            
            response.Key = billing.CompetitionCommandBillingId;
            return response;
        }
        
        private BillingPricing CalculatePricing(
            string aspNetUserId, 
            AreaOwnership ownership,
            int? promoCodeId)
        {
            var pricing = new BillingPricing();
            
            // Get base price by property type
            pricing.BaseAmount = _pricingService.GetBasePrice(ownership.PropertyTypeId);
            
            // Get agent's current active area count
            var activeAreas = Proxy.GetActiveAreaCount(aspNetUserId);
            
            // Calculate bundle discount
            var bundle = _bundleService.GetBundleForCount(activeAreas + 1);
            if (bundle != null && bundle.DiscountValue > 0)
            {
                pricing.BundleTier = bundle.BundleCode;
                pricing.BundleDiscount = CalculateBundleDiscount(
                    pricing.BaseAmount, bundle);
            }
            
            // Apply promo code
            if (promoCodeId.HasValue)
            {
                var promo = _promoService.ValidateAndApply(
                    promoCodeId.Value, aspNetUserId, pricing.BaseAmount - pricing.BundleDiscount);
                
                if (promo.IsValid)
                {
                    pricing.PromoCodeId = promoCodeId;
                    pricing.PromoCode = promo.Code;
                    pricing.PromoDiscount = promo.DiscountAmount;
                }
            }
            
            return pricing;
        }
        
        private void HandleFailedPayment(
            CompetitionCommandBilling billing,
            ResponseWhmcsOrder response,
            int areaOwnershipId)
        {
            billing.BillingStatus = "Failed";
            billing.ResponseCode = response.ResponseCode;
            billing.ResponseMessage = response.Message;
            billing.RetryCount = 0;
            billing.NextRetryDate = DateTime.UtcNow.AddDays(Config.CompetitionCommandRetryIntervalDays);
            UpdateBilling(billing);
            
            // Register for retry queue
            FailedPaymentCaptureManager.RegisterFailedPayment(
                billing.WhmcsClientId.Value,
                Config.CompetitionCommandWhmcsProductId,
                billing.CompetitionCommandBillingId);
            
            // Log history
            LogOwnershipHistory(areaOwnershipId, "BillingFailed", response.Message);
        }
        
        private void ActivateAreaOwnership(int areaOwnershipId, int billingId)
        {
            // Call FR-001 stored procedure
            // usp_AreaOwnership_Activate(@AreaOwnershipId, @BillingId, @ContentConfigId)
            Proxy.ActivateAreaOwnership(areaOwnershipId, billingId, null);
        }
    }
}
```

---

### 2.2 Handler: `CompetitionCommandCancellationHandler.cs`

```csharp
namespace Smart.Core.BLL.CompetitionCommand.Billing
{
    public class CompetitionCommandCancellationHandler
    {
        public ResponseBase CancelArea(int areaOwnershipId, string canceledByUserId, string reason)
        {
            var response = ResponseHelper.GetSuccess<ResponseBase>();
            
            // 1. Get billing record
            var billing = Proxy.GetBillingByOwnership(areaOwnershipId);
            if (billing == null)
            {
                response.Message = "No billing record found";
                return response;
            }
            
            // 2. Cancel WHMCS order
            if (billing.WhmcsOrderId.HasValue)
            {
                // Cancel in WHMCS - stop future billing
                WhmcsApi.CancelOrder(billing.WhmcsOrderId.Value);
            }
            
            // 3. Update billing status
            billing.BillingStatus = "Canceled";
            billing.BillingEndDate = DateTime.UtcNow;
            UpdateBilling(billing);
            
            // 4. End ownership (FR-001 integration)
            var areaInfo = EndAreaOwnership(areaOwnershipId, canceledByUserId, reason);
            
            // 5. Process waitlist (FR-001 integration)
            ProcessWaitlist(areaInfo.AreaId, areaInfo.PropertyTypeId, areaInfo.AreaOwnershipTypeId);
            
            return response;
        }
        
        private AreaInfo EndAreaOwnership(int areaOwnershipId, string userId, string reason)
        {
            // Call FR-001 stored procedure
            // Returns AreaId, PropertyTypeId, AreaOwnershipTypeId for waitlist processing
            return Proxy.EndAreaOwnership(areaOwnershipId, reason, userId);
        }
        
        private void ProcessWaitlist(int areaId, int propertyTypeId, int ownershipTypeId)
        {
            // Call FR-001 stored procedure
            // usp_AreaWaitlist_NotifyNext
            var nextInQueue = Proxy.NotifyNextWaitlist(areaId, propertyTypeId, ownershipTypeId);
            
            if (nextInQueue != null)
            {
                // Send notification to user
                NotificationService.SendWaitlistAvailable(nextInQueue.AspNetUserId, areaId);
            }
        }
    }
}
```

---

### 2.3 Retry Job: `CompetitionCommandPaymentRetryJob.cs`

```csharp
namespace Smart.Core.Jobs
{
    public class CompetitionCommandPaymentRetryJob : IScheduledJob
    {
        // Runs daily or hourly
        public void Execute()
        {
            var failedPayments = Proxy.GetPendingRetries();
            
            foreach (var billing in failedPayments)
            {
                if (billing.RetryCount >= Config.CompetitionCommandMaxRetries)
                {
                    // Max retries exceeded - cancel
                    var handler = new CompetitionCommandCancellationHandler();
                    handler.CancelArea(billing.AreaOwnershipId, "SYSTEM", "NonPayment");
                    continue;
                }
                
                // Attempt retry
                var capture = new CapturePaymentManager(
                    billing.WhmcsClientId.Value, 
                    Config.CompetitionCommandWhmcsProductId);
                
                var result = capture.RetryCapture(billing.WhmcsOrderId.Value);
                
                if (result.Success)
                {
                    billing.BillingStatus = "Active";
                    billing.RetryCount = 0;
                    billing.NextRetryDate = null;
                    
                    // Reactivate ownership
                    Proxy.ActivateAreaOwnership(billing.AreaOwnershipId, billing.CompetitionCommandBillingId, null);
                }
                else
                {
                    billing.RetryCount++;
                    billing.LastRetryDate = DateTime.UtcNow;
                    billing.NextRetryDate = DateTime.UtcNow.AddDays(Config.CompetitionCommandRetryIntervalDays);
                }
                
                UpdateBilling(billing);
            }
        }
    }
}
```

---

# ITERATION 3: Bundle Calculator
## Target: Week 4

### 3.1 Service: `CompetitionCommandBundleService.cs`

```csharp
namespace Smart.Core.BLL.CompetitionCommand.Services
{
    public class CompetitionCommandBundleService : ICompetitionCommandBundleService
    {
        public BundleInfo GetBundleForCount(int areaCount)
        {
            var bundles = Proxy.GetActiveBundles()
                .OrderByDescending(b => b.MinAreas)
                .ToList();
            
            foreach (var bundle in bundles)
            {
                if (areaCount >= bundle.MinAreas && 
                    (!bundle.MaxAreas.HasValue || areaCount <= bundle.MaxAreas))
                {
                    return bundle;
                }
            }
            
            return null;
        }
        
        public decimal CalculateDiscount(decimal baseAmount, BundleInfo bundle)
        {
            switch (bundle.DiscountType)
            {
                case "Percent":
                    return baseAmount * (bundle.DiscountValue / 100);
                    
                case "FixedPerArea":
                    return bundle.DiscountValue;
                    
                case "FixedTotal":
                    return bundle.DiscountValue;
                    
                default:
                    return 0;
            }
        }
        
        public void RecalculateBundleTier(string aspNetUserId)
        {
            // Called when agent adds/removes area
            // May trigger upgrade/downgrade of bundle tier for all their areas
            
            var activeAreas = Proxy.GetActiveAreasWithBilling(aspNetUserId);
            var newBundle = GetBundleForCount(activeAreas.Count);
            
            foreach (var billing in activeAreas)
            {
                if (billing.BundleTier != newBundle?.BundleCode)
                {
                    // Mark for adjustment on next billing cycle
                    billing.PendingBundleChange = newBundle?.BundleCode;
                    UpdateBilling(billing);
                }
            }
        }
    }
}
```

---

# ITERATION 4: Promo Code Validation
## Target: Week 5

### 4.1 Service: `CompetitionCommandPromoService.cs`

```csharp
namespace Smart.Core.BLL.CompetitionCommand.Services
{
    public class CompetitionCommandPromoService : ICompetitionCommandPromoService
    {
        public PromoValidationResult ValidateAndApply(
            int promoCodeId, 
            string aspNetUserId, 
            decimal amountBeforePromo)
        {
            var result = new PromoValidationResult { IsValid = false };
            
            var promo = Proxy.GetPromoCode(promoCodeId);
            if (promo == null || !promo.IsActive)
            {
                result.Error = "Promo code not found or inactive";
                return result;
            }
            
            // Check date validity
            var now = DateTime.UtcNow;
            if (now < promo.StartDate || (promo.EndDate.HasValue && now > promo.EndDate))
            {
                result.Error = "Promo code has expired";
                return result;
            }
            
            // Check usage limits
            if (promo.MaxTotalUses.HasValue && promo.CurrentUses >= promo.MaxTotalUses)
            {
                result.Error = "Promo code usage limit reached";
                return result;
            }
            
            // Check per-user limit
            var userUsage = Proxy.GetPromoCodeUsageCount(promoCodeId, aspNetUserId);
            if (userUsage >= promo.MaxUsesPerUser)
            {
                result.Error = "You have already used this promo code";
                return result;
            }
            
            // Check new customer restriction
            if (promo.NewCustomersOnly)
            {
                var hasPriorPurchase = Proxy.HasPriorCompetitionCommandPurchase(aspNetUserId);
                if (hasPriorPurchase)
                {
                    result.Error = "Promo code is for new customers only";
                    return result;
                }
            }
            
            // Check role restriction
            if (!string.IsNullOrEmpty(promo.AllowedRoles))
            {
                var userRoles = Proxy.GetUserRoles(aspNetUserId);
                var allowedRoles = promo.AllowedRoles.Split(',');
                if (!userRoles.Any(r => allowedRoles.Contains(r)))
                {
                    result.Error = "Promo code not available for your account type";
                    return result;
                }
            }
            
            // Calculate discount
            result.IsValid = true;
            result.Code = promo.PromoCode;
            result.DiscountType = promo.DiscountType;
            
            switch (promo.DiscountType)
            {
                case "Percent":
                    result.DiscountAmount = amountBeforePromo * (promo.DiscountValue / 100);
                    break;
                    
                case "FixedAmount":
                    result.DiscountAmount = Math.Min(promo.DiscountValue, amountBeforePromo);
                    break;
                    
                case "FreeMonth":
                    result.DiscountAmount = amountBeforePromo;
                    result.FreeMonths = 1;
                    break;
                    
                case "FreeTrial":
                    result.DiscountAmount = 0; // No immediate discount
                    result.TrialDays = promo.TrialDays ?? 14;
                    break;
            }
            
            return result;
        }
        
        public void RecordUsage(int promoCodeId, string aspNetUserId, int billingId, decimal discountApplied)
        {
            // Insert usage record
            Proxy.InsertPromoCodeUsage(promoCodeId, aspNetUserId, billingId, discountApplied);
            
            // Increment usage count
            Proxy.IncrementPromoCodeUsage(promoCodeId);
        }
    }
}
```

---

# ITERATION 5: API Endpoints
## Target: Week 6

### 5.1 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/competition-command/purchase` | Purchase area (triggers billing) |
| POST | `/api/competition-command/cancel` | Cancel area |
| GET | `/api/competition-command/pricing` | Get pricing and bundles |
| POST | `/api/competition-command/validate-promo` | Validate promo code |
| GET | `/api/competition-command/billing/{id}` | Get billing details |
| GET | `/api/competition-command/billing` | List user's billing |

---

### 5.2 API Controller: `CompetitionCommandBillingController.cs`

```csharp
[Route("api/competition-command")]
public class CompetitionCommandBillingController : ApiController
{
    [HttpPost("purchase")]
    public IHttpActionResult Purchase([FromBody] AreaPurchaseRequest request)
    {
        // Validate request
        if (!ModelState.IsValid)
            return BadRequest(ModelState);
        
        // Create pending ownership (FR-001)
        var ownershipResult = AreaOwnershipService.Create(
            User.Identity.GetUserId(),
            request.AreaId,
            request.PropertyTypeId,
            1 // AreaOwnershipTypeId = FarmCaster/CC
        );
        
        if (ownershipResult.Action == "Waitlist")
        {
            return Ok(new { 
                Status = "Waitlist", 
                Message = "Area not available, added to waitlist" 
            });
        }
        
        // Process billing
        var handler = new CompetitionCommandBillingHandler();
        var result = handler.Process(
            User.Identity.GetUserId(),
            ownershipResult.AreaOwnershipId,
            request.PromoCodeId
        );
        
        if (!result.Success)
            return BadRequest(result.Message);
        
        return Ok(new { 
            Status = "Active", 
            BillingId = result.Key,
            AreaOwnershipId = ownershipResult.AreaOwnershipId
        });
    }
    
    [HttpPost("cancel")]
    public IHttpActionResult Cancel([FromBody] AreaCancelRequest request)
    {
        var handler = new CompetitionCommandCancellationHandler();
        var result = handler.CancelArea(
            request.AreaOwnershipId,
            User.Identity.GetUserId(),
            request.Reason
        );
        
        if (!result.Success)
            return BadRequest(result.Message);
        
        return Ok(new { Status = "Canceled" });
    }
    
    [HttpGet("pricing")]
    public IHttpActionResult GetPricing()
    {
        var userId = User.Identity.GetUserId();
        var activeAreas = Proxy.GetActiveAreaCount(userId);
        
        var pricing = PricingService.GetAllActive();
        var bundles = BundleService.GetAllActive();
        var currentTier = BundleService.GetBundleForCount(activeAreas);
        var nextTier = BundleService.GetBundleForCount(activeAreas + 1);
        
        return Ok(new {
            Pricing = pricing,
            Bundles = bundles,
            CurrentTier = currentTier,
            NextTier = nextTier,
            ActiveAreaCount = activeAreas
        });
    }
    
    [HttpPost("validate-promo")]
    public IHttpActionResult ValidatePromo([FromBody] PromoValidateRequest request)
    {
        var result = PromoService.Validate(
            request.PromoCode,
            User.Identity.GetUserId(),
            request.BaseAmount
        );
        
        return Ok(result);
    }
}
```

---

## Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | Billing tables created | All 5 tables exist with correct schema |
| 2 | Base pricing works | Correct price by PropertyTypeId |
| 3 | Bundle discount applies | Correct tier based on area count |
| 4 | Promo code validates | All restriction checks work |
| 5 | WHMCS order created | OrderId stored in billing record |
| 6 | Payment capture works | Success triggers activation |
| 7 | Failed payment retries | 3 retries over 7 days |
| 8 | Failed payment cancels | Auto-cancel after max retries |
| 9 | Cancellation stops billing | WHMCS order canceled |
| 10 | Waitlist triggered | Next in queue notified on cancel |
| 11 | FR-001 integration | Ownership activated on success |

---

**Document Version:** 1.0  
**Created:** 12/13/2025  
**Status:** DRAFT

