# Feature Request: WHMCS Area Billing Integration
## FR-002 | Development Specification
### Version 1.0 | December 2025

---

## Document Purpose
This specification provides iterative development details for implementing WHMCS billing integration for Competition Command area ownership. Each iteration is designed to be independently deployable and testable.

---

# ITERATION 1: Database Schema
## Target: Week 1

### Objective
Create billing tables and WHMCS integration schema.

---

### 1.1 New Tables

#### Table: `CompetitionCommandBilling`
```sql
CREATE TABLE dbo.CompetitionCommandBilling (
    CompetitionCommandBillingId    INT IDENTITY(1,1) PRIMARY KEY,
    AreaOwnershipId               INT NOT NULL,
    AspNetUserId                  NVARCHAR(128) NOT NULL,
    
    -- WHMCS Integration
    WhmcsOrderId                  INT NULL,
    WhmcsClientId                 INT NULL,
    WhmcsProductId                INT NOT NULL,
    WhmcsInvoiceId                INT NULL,
    WhmcsServiceId                INT NULL,
    
    -- Pricing Breakdown
    BasePrice                     DECIMAL(10,2) NOT NULL,
    BundleDiscountAmount          DECIMAL(10,2) NULL DEFAULT 0,
    PromoDiscountAmount           DECIMAL(10,2) NULL DEFAULT 0,
    FinalPrice                    DECIMAL(10,2) NOT NULL,
    
    -- Promo/Bundle Details
    PromoCode                     NVARCHAR(50) NULL,
    PromoCodeId                   INT NULL,
    BundleTierId                  INT NULL,
    AreasInBundle                 INT NULL DEFAULT 1,
    
    -- Billing Cycle
    BillingCycleType              NVARCHAR(20) NOT NULL DEFAULT 'Monthly',
        -- Values: 'OneTime', 'Monthly', 'Quarterly', 'Annual'
    StartDate                     DATETIME2 NULL,
    NextBillingDate               DATETIME2 NULL,
    
    -- Processing Status
    BillingStatus                 NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        -- Values: 'Pending', 'Active', 'Failed', 'Canceled', 'Expired'
    ResponseCode                  INT NULL,
    ResponseDescription           NVARCHAR(500) NULL,
    ProcessedDate                 DATETIME2 NULL,
    CanceledDate                  DATETIME2 NULL,
    CancelReason                  NVARCHAR(100) NULL,
    
    -- Metadata
    CreatedDate                   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate                  DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    -- Constraints
    CONSTRAINT FK_CCBilling_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId),
    CONSTRAINT FK_CCBilling_AspNetUsers 
        FOREIGN KEY (AspNetUserId) REFERENCES dbo.AspNetUsers(Id),
    CONSTRAINT CK_CCBilling_Status 
        CHECK (BillingStatus IN ('Pending', 'Active', 'Failed', 'Canceled', 'Expired'))
);

-- Indexes
CREATE INDEX IX_CCBilling_AreaOwnershipId ON dbo.CompetitionCommandBilling(AreaOwnershipId);
CREATE INDEX IX_CCBilling_AspNetUserId ON dbo.CompetitionCommandBilling(AspNetUserId);
CREATE INDEX IX_CCBilling_WhmcsOrderId ON dbo.CompetitionCommandBilling(WhmcsOrderId);
CREATE INDEX IX_CCBilling_Status ON dbo.CompetitionCommandBilling(BillingStatus);
CREATE INDEX IX_CCBilling_NextBillingDate ON dbo.CompetitionCommandBilling(NextBillingDate) 
    WHERE BillingStatus = 'Active';
```

#### Table: `CompetitionCommandPricingTier`
```sql
CREATE TABLE dbo.CompetitionCommandPricingTier (
    PricingTierId           INT IDENTITY(1,1) PRIMARY KEY,
    TierName                NVARCHAR(50) NOT NULL,
    TierCode                NVARCHAR(20) NOT NULL UNIQUE,
    MinAreas                INT NOT NULL,
    MaxAreas                INT NULL, -- NULL = unlimited
    DiscountPercentage      DECIMAL(5,2) NOT NULL DEFAULT 0,
    DiscountFixedAmount     DECIMAL(10,2) NULL,
    DisplayOrder            INT NOT NULL DEFAULT 0,
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Default tiers
INSERT INTO dbo.CompetitionCommandPricingTier 
    (TierName, TierCode, MinAreas, MaxAreas, DiscountPercentage, DisplayOrder, IsActive) 
VALUES
    ('Single Area', 'SINGLE', 1, 1, 0.00, 1, 1),
    ('Starter Bundle', 'STARTER', 2, 3, 10.00, 2, 1),
    ('Pro Bundle', 'PRO', 4, 6, 15.00, 3, 1),
    ('Enterprise Bundle', 'ENTERPRISE', 7, NULL, 25.00, 4, 1);
```

#### Table: `CompetitionCommandPromoCode`
```sql
CREATE TABLE dbo.CompetitionCommandPromoCode (
    PromoCodeId             INT IDENTITY(1,1) PRIMARY KEY,
    Code                    NVARCHAR(50) NOT NULL,
    Description             NVARCHAR(200) NULL,
    
    -- Discount Configuration
    DiscountType            NVARCHAR(20) NOT NULL,
        -- Values: 'Percentage', 'Fixed', 'Trial', 'FreeMonth'
    DiscountValue           DECIMAL(10,2) NOT NULL,
    TrialDays               INT NULL, -- For trial type
    
    -- Usage Limits
    MaxTotalUses            INT NULL, -- NULL = unlimited
    MaxUsesPerUser          INT NOT NULL DEFAULT 1,
    CurrentTotalUses        INT NOT NULL DEFAULT 0,
    
    -- Validity
    ValidFrom               DATETIME2 NULL,
    ValidTo                 DATETIME2 NULL,
    
    -- Restrictions
    RoleTypeId              INT NULL, -- Role-specific codes (Founder, Partner, etc.)
    MinAreas                INT NULL, -- Minimum areas required
    RequiresBundleTierId    INT NULL, -- Must be specific tier
    
    -- Status
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedByUserId         NVARCHAR(128) NULL,
    
    CONSTRAINT UQ_PromoCode_Code UNIQUE (Code)
);

-- Indexes
CREATE INDEX IX_PromoCode_Code ON dbo.CompetitionCommandPromoCode(Code) 
    WHERE IsActive = 1;
CREATE INDEX IX_PromoCode_ValidDates ON dbo.CompetitionCommandPromoCode(ValidFrom, ValidTo) 
    WHERE IsActive = 1;
```

#### Table: `CompetitionCommandPromoCodeUsage`
```sql
CREATE TABLE dbo.CompetitionCommandPromoCodeUsage (
    PromoCodeUsageId        INT IDENTITY(1,1) PRIMARY KEY,
    PromoCodeId             INT NOT NULL,
    AspNetUserId            NVARCHAR(128) NOT NULL,
    CompetitionCommandBillingId INT NOT NULL,
    DiscountApplied         DECIMAL(10,2) NOT NULL,
    UsedDate                DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_PromoUsage_PromoCode 
        FOREIGN KEY (PromoCodeId) REFERENCES dbo.CompetitionCommandPromoCode(PromoCodeId),
    CONSTRAINT FK_PromoUsage_CCBilling 
        FOREIGN KEY (CompetitionCommandBillingId) REFERENCES dbo.CompetitionCommandBilling(CompetitionCommandBillingId)
);

CREATE INDEX IX_PromoUsage_UserId ON dbo.CompetitionCommandPromoCodeUsage(AspNetUserId);
CREATE INDEX IX_PromoUsage_PromoCodeId ON dbo.CompetitionCommandPromoCodeUsage(PromoCodeId);
```

---

### 1.2 Configuration Tables

#### Table: `CompetitionCommandBillingConfig`
```sql
CREATE TABLE dbo.CompetitionCommandBillingConfig (
    ConfigId                INT IDENTITY(1,1) PRIMARY KEY,
    ConfigKey               NVARCHAR(50) NOT NULL UNIQUE,
    ConfigValue             NVARCHAR(500) NOT NULL,
    Description             NVARCHAR(200) NULL,
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedByUserId        NVARCHAR(128) NULL
);

-- Default configuration
INSERT INTO dbo.CompetitionCommandBillingConfig (ConfigKey, ConfigValue, Description) VALUES
    ('WhmcsProductId', '0', 'WHMCS Product ID for Competition Command'),
    ('WhmcsCustomFieldId', '0', 'WHMCS Custom Field ID for area description'),
    ('BasePriceSFR', '99.00', 'Base monthly price for SFR areas'),
    ('BasePriceCondo', '79.00', 'Base monthly price for Condo areas'),
    ('DefaultBillingCycle', 'Monthly', 'Default billing cycle for new orders'),
    ('WaitlistAutoProvision', 'true', 'Auto-provision waitlist on cancellation'),
    ('WaitlistOfferHours', '48', 'Hours to accept waitlist offer'),
    ('TrialDaysDefault', '0', 'Default trial period in days');
```

---

### 1.3 Stored Procedures

#### Procedure: `usp_CCBilling_CalculatePrice`
```sql
CREATE PROCEDURE dbo.usp_CCBilling_CalculatePrice
    @AspNetUserId NVARCHAR(128),
    @AreaCount INT,
    @PropertyTypeId INT = 0,
    @PromoCode NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BasePrice DECIMAL(10,2);
    DECLARE @BundleTierId INT;
    DECLARE @BundleDiscount DECIMAL(5,2) = 0;
    DECLARE @PromoCodeId INT = NULL;
    DECLARE @PromoDiscount DECIMAL(10,2) = 0;
    DECLARE @PromoType NVARCHAR(20) = NULL;
    
    -- Get base price by property type
    SELECT @BasePrice = CAST(ConfigValue AS DECIMAL(10,2))
    FROM dbo.CompetitionCommandBillingConfig
    WHERE ConfigKey = CASE @PropertyTypeId
        WHEN 0 THEN 'BasePriceSFR'
        WHEN 1 THEN 'BasePriceCondo'
        ELSE 'BasePriceSFR'
    END;
    
    -- Get bundle tier
    SELECT TOP 1 
        @BundleTierId = PricingTierId,
        @BundleDiscount = DiscountPercentage
    FROM dbo.CompetitionCommandPricingTier
    WHERE IsActive = 1
      AND MinAreas <= @AreaCount
      AND (MaxAreas IS NULL OR MaxAreas >= @AreaCount)
    ORDER BY DiscountPercentage DESC;
    
    -- Validate promo code if provided
    IF @PromoCode IS NOT NULL
    BEGIN
        SELECT 
            @PromoCodeId = PromoCodeId,
            @PromoType = DiscountType,
            @PromoDiscount = CASE DiscountType
                WHEN 'Percentage' THEN (@BasePrice * @AreaCount) * (DiscountValue / 100)
                WHEN 'Fixed' THEN DiscountValue
                ELSE 0
            END
        FROM dbo.CompetitionCommandPromoCode
        WHERE Code = @PromoCode
          AND IsActive = 1
          AND (ValidFrom IS NULL OR ValidFrom <= GETUTCDATE())
          AND (ValidTo IS NULL OR ValidTo >= GETUTCDATE())
          AND (MaxTotalUses IS NULL OR CurrentTotalUses < MaxTotalUses)
          AND (MinAreas IS NULL OR MinAreas <= @AreaCount);
    END
    
    -- Calculate totals
    DECLARE @SubTotal DECIMAL(10,2) = @BasePrice * @AreaCount;
    DECLARE @BundleDiscountAmount DECIMAL(10,2) = @SubTotal * (@BundleDiscount / 100);
    DECLARE @FinalPrice DECIMAL(10,2) = @SubTotal - @BundleDiscountAmount - @PromoDiscount;
    
    -- Return pricing breakdown
    SELECT 
        @BasePrice AS BasePricePerArea,
        @AreaCount AS AreaCount,
        @SubTotal AS SubTotal,
        @BundleTierId AS BundleTierId,
        @BundleDiscount AS BundleDiscountPercentage,
        @BundleDiscountAmount AS BundleDiscountAmount,
        @PromoCodeId AS PromoCodeId,
        @PromoCode AS PromoCode,
        @PromoType AS PromoDiscountType,
        @PromoDiscount AS PromoDiscountAmount,
        @FinalPrice AS FinalMonthlyPrice,
        CASE 
            WHEN @PromoCodeId IS NULL AND @PromoCode IS NOT NULL 
            THEN 'Invalid or expired promo code'
            ELSE NULL 
        END AS PromoCodeError;
END;
```

#### Procedure: `usp_CCBilling_CreateOrder`
```sql
CREATE PROCEDURE dbo.usp_CCBilling_CreateOrder
    @AreaOwnershipId INT,
    @AspNetUserId NVARCHAR(128),
    @WhmcsProductId INT,
    @BasePrice DECIMAL(10,2),
    @BundleDiscountAmount DECIMAL(10,2) = 0,
    @PromoDiscountAmount DECIMAL(10,2) = 0,
    @FinalPrice DECIMAL(10,2),
    @PromoCode NVARCHAR(50) = NULL,
    @PromoCodeId INT = NULL,
    @BundleTierId INT = NULL,
    @AreasInBundle INT = 1,
    @BillingCycleType NVARCHAR(20) = 'Monthly'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BillingId INT;
    
    -- Create billing record
    INSERT INTO dbo.CompetitionCommandBilling (
        AreaOwnershipId, AspNetUserId, WhmcsProductId,
        BasePrice, BundleDiscountAmount, PromoDiscountAmount, FinalPrice,
        PromoCode, PromoCodeId, BundleTierId, AreasInBundle,
        BillingCycleType, BillingStatus, StartDate
    )
    VALUES (
        @AreaOwnershipId, @AspNetUserId, @WhmcsProductId,
        @BasePrice, @BundleDiscountAmount, @PromoDiscountAmount, @FinalPrice,
        @PromoCode, @PromoCodeId, @BundleTierId, @AreasInBundle,
        @BillingCycleType, 'Pending', GETUTCDATE()
    );
    
    SET @BillingId = SCOPE_IDENTITY();
    
    -- Record promo code usage if applicable
    IF @PromoCodeId IS NOT NULL
    BEGIN
        INSERT INTO dbo.CompetitionCommandPromoCodeUsage (
            PromoCodeId, AspNetUserId, CompetitionCommandBillingId, DiscountApplied
        )
        VALUES (
            @PromoCodeId, @AspNetUserId, @BillingId, @PromoDiscountAmount
        );
        
        -- Increment usage counter
        UPDATE dbo.CompetitionCommandPromoCode
        SET CurrentTotalUses = CurrentTotalUses + 1
        WHERE PromoCodeId = @PromoCodeId;
    END
    
    SELECT @BillingId AS CompetitionCommandBillingId;
END;
```

#### Procedure: `usp_CCBilling_UpdateWhmcsOrder`
```sql
CREATE PROCEDURE dbo.usp_CCBilling_UpdateWhmcsOrder
    @CompetitionCommandBillingId INT,
    @WhmcsOrderId INT,
    @WhmcsInvoiceId INT = NULL,
    @WhmcsServiceId INT = NULL,
    @WhmcsClientId INT = NULL,
    @ResponseCode INT,
    @ResponseDescription NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dbo.CompetitionCommandBilling
    SET 
        WhmcsOrderId = @WhmcsOrderId,
        WhmcsInvoiceId = @WhmcsInvoiceId,
        WhmcsServiceId = @WhmcsServiceId,
        WhmcsClientId = @WhmcsClientId,
        ResponseCode = @ResponseCode,
        ResponseDescription = @ResponseDescription,
        ProcessedDate = GETUTCDATE(),
        BillingStatus = CASE 
            WHEN @ResponseCode = 1 THEN 'Active'
            ELSE 'Failed'
        END,
        NextBillingDate = CASE 
            WHEN @ResponseCode = 1 THEN 
                CASE BillingCycleType
                    WHEN 'Monthly' THEN DATEADD(MONTH, 1, GETUTCDATE())
                    WHEN 'Quarterly' THEN DATEADD(MONTH, 3, GETUTCDATE())
                    WHEN 'Annual' THEN DATEADD(YEAR, 1, GETUTCDATE())
                    ELSE NULL
                END
            ELSE NULL
        END,
        ModifiedDate = GETUTCDATE()
    WHERE CompetitionCommandBillingId = @CompetitionCommandBillingId;
    
    -- If successful, also activate the ownership
    IF @ResponseCode = 1
    BEGIN
        DECLARE @AreaOwnershipId INT;
        SELECT @AreaOwnershipId = AreaOwnershipId 
        FROM dbo.CompetitionCommandBilling 
        WHERE CompetitionCommandBillingId = @CompetitionCommandBillingId;
        
        UPDATE dbo.AreaOwnership
        SET 
            Status = 'Active',
            ApprovalDate = GETUTCDATE(),
            StartDate = GETUTCDATE(),
            ModifiedDate = GETUTCDATE()
        WHERE AreaOwnershipId = @AreaOwnershipId
          AND Status = 'Pending';
    END
END;
```

#### Procedure: `usp_CCBilling_CancelSubscription`
```sql
CREATE PROCEDURE dbo.usp_CCBilling_CancelSubscription
    @AreaOwnershipId INT,
    @CancelReason NVARCHAR(100),
    @CanceledByUserId NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @WhmcsOrderId INT;
    DECLARE @AspNetUserId NVARCHAR(128);
    DECLARE @AreaId INT;
    
    -- Get billing and ownership info
    SELECT 
        @WhmcsOrderId = b.WhmcsOrderId,
        @AspNetUserId = b.AspNetUserId,
        @AreaId = ao.AreaId
    FROM dbo.CompetitionCommandBilling b
    INNER JOIN dbo.AreaOwnership ao ON ao.AreaOwnershipId = b.AreaOwnershipId
    WHERE b.AreaOwnershipId = @AreaOwnershipId
      AND b.BillingStatus = 'Active';
    
    -- Update billing record
    UPDATE dbo.CompetitionCommandBilling
    SET 
        BillingStatus = 'Canceled',
        CanceledDate = GETUTCDATE(),
        CancelReason = @CancelReason,
        ModifiedDate = GETUTCDATE()
    WHERE AreaOwnershipId = @AreaOwnershipId
      AND BillingStatus = 'Active';
    
    -- Return WHMCS order ID for API cancellation
    SELECT 
        @WhmcsOrderId AS WhmcsOrderId,
        @AspNetUserId AS AspNetUserId,
        @AreaId AS AreaId,
        'Canceled' AS NewStatus;
END;
```

---

### 1.4 Iteration 1 Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | Billing table created | `CompetitionCommandBilling` exists |
| 2 | Pricing tiers configured | 4 default tiers inserted |
| 3 | Promo code table created | `CompetitionCommandPromoCode` exists |
| 4 | Price calculation works | `usp_CCBilling_CalculatePrice` returns correct totals |
| 5 | Bundle discount applies | 4 areas = 15% discount |
| 6 | Promo code validates | Invalid codes rejected |
| 7 | Config table populated | All default settings exist |

---

# ITERATION 2: Billing Handler
## Target: Week 2-3

### Objective
Create C# billing handler modeled after `ListingCommandBillingHandler`.

---

### 2.1 C# Implementation

#### Class: `CompetitionCommandBillingHandler`
```csharp
using Smart.Config.BLL;
using Smart.Core.BLL.Billing;
using Smart.Core.BLL.Billing.Workflow;
using Smart.Core.BLL.Helper;
using Smart.Data.SQL;
using Smart.Model.Common;
using Smart.Model.Config;
using Smart.Model.Response;
using System;
using WHMCS.Net;
using WHMCS.Net.Models;
using WHMCS.Net.Models.Enums;

namespace Smart.Core.BLL.CompetitionCommand.Billing
{
    public class CompetitionCommandBillingHandler : HandlerWorkflowBillingBase
    {
        private readonly CompetitionCommandBillingConfig Config;

        public CompetitionCommandBillingHandler()
        {
            Config = SmartConfigurationManager.Get<CompetitionCommandBillingConfig>(
                ConfigSettingType.CompetitionCommandBillingConfig);
        }

        public ResponseWithKey ProcessAreaPurchase(
            string aspNetUserId, 
            int areaOwnershipId,
            RoleType role)
        {
            var response = ResponseHelper.GetSuccess<ResponseWithKey>();

            // Load ownership record
            var ownership = Proxy.GetAreaOwnership(areaOwnershipId, aspNetUserId);
            if (ownership == null || ownership.AspNetUserId != aspNetUserId)
                return ResponseHelper.GetError<ResponseWithKey>(
                    "Unable to load area ownership for billing");

            // Load or create billing record
            var billing = Proxy.GetCompetitionCommandBilling(areaOwnershipId);
            if (billing == null)
            {
                billing = CreateBillingRecord(ownership);
            }

            // Don't reprocess successful orders
            if (billing.ResponseCode == (int)ResponseCodeReserved.Success)
            {
                response.Key = billing.WhmcsOrderId.GetValueOrDefault();
                return response;
            }

            // Validate billing state
            if (billing.ResponseCode != null)
                return ResponseHelper.GetError<ResponseWithKey>(
                    "Billing is not in valid state, please investigate");

            // Get WHMCS client ID
            var whmcsClientId = Proxy.GetUserWhmcs(aspNetUserId)?.WhmcsClientId;
            if (!whmcsClientId.HasValue)
            {
                response = ResponseHelper.GetError<ResponseWithKey>(
                    "Unable to load WHMCS Client Id");
                UpdateBilling(billing, response);
                return response;
            }

            // Check for role-based promo code
            CheckForPromoCode(billing, role);

            // Get area name for order description
            var areaName = PolygonHelper.GetUserAreaName(aspNetUserId, ownership.AreaId);

            // Create WHMCS order
            var addOrderResponse = AddOrder(
                areaName?.DisplayName, 
                billing, 
                whmcsClientId);

            if (!WhmcsHelper.IsWhmcsSuccess(addOrderResponse))
            {
                response = ResponseHelper.GetError<ResponseWithKey>(
                    addOrderResponse?.Message ?? "WHMCS Add Order Response Empty");
                UpdateBilling(billing, response);
                return response;
            }

            var whmcsOrderResponse = ResponseHelper.GetSuccess<ResponseWhmcsOrder>();
            whmcsOrderResponse.WhmcsOrderId = addOrderResponse.OrderID;

            // Capture payment
            var capture = new CapturePaymentManager(
                whmcsClientId.Value, 
                Config.WhmcsProductId);
            capture.ProcessNewOrder(whmcsOrderResponse);

            if (!whmcsOrderResponse.Success)
            {
                response = ResponseHelper.GetError<ResponseWithKey>(
                    whmcsOrderResponse.ResponseDescription);
                UpdateBilling(billing, response);

                // Delete failed order
                var failCapture = new FailedPaymentCaptureManager();
                failCapture.DeleteOrder(whmcsOrderResponse, "CC Area Purchase");

                // Notify user
                Notify(aspNetUserId, 
                    $"Payment failed for area: {areaName?.DisplayName}");

                return response;
            }

            response.Key = whmcsOrderResponse.WhmcsOrderId;
            UpdateBilling(billing, response);

            // Activate ownership
            ActivateOwnership(ownership);

            return response;
        }

        private void CheckForPromoCode(CompetitionCommandBilling billing, RoleType role)
        {
            if (!string.IsNullOrWhiteSpace(billing.PromoCode))
                return;

            if (Config.RoleDiscounts.TryGetValue((int)role, out var discountItem))
                billing.PromoCode = discountItem.PromoCode;
        }

        private AddOrderResponse AddOrder(
            string areaName, 
            CompetitionCommandBilling billing, 
            int? whmcsClientId)
        {
            var description = $"Competition Command - Area: {areaName}";
            var order = InitializeOrder(
                whmcsClientId, 
                billing.PromoCode, 
                (float)billing.FinalPrice, 
                description);
            return WhmcsApi.AddOrder(order);
        }

        private AddOrder InitializeOrder(
            int? whmcsClientId, 
            string promoCode, 
            float amount, 
            string description)
        {
            return new AddOrder
            {
                ClientID = whmcsClientId.Value,
                ProductID = Config.WhmcsProductId,
                PromoCode = promoCode,
                PriceOverride = amount,
                BillingCycle = GetBillingCycle(),
                SendInvoice = true,
                CustomFields = new System.Collections.Hashtable
                {
                    { Config.WhmcsCustomFieldId.ToString(), description }
                }
            };
        }

        private BillingCycleType GetBillingCycle()
        {
            return Config.DefaultBillingCycle switch
            {
                "Monthly" => BillingCycleType.Monthly,
                "Quarterly" => BillingCycleType.Quarterly,
                "Annual" => BillingCycleType.Annually,
                _ => BillingCycleType.Monthly
            };
        }

        private void UpdateBilling(
            CompetitionCommandBilling billing, 
            ResponseWithKey response)
        {
            billing.ProcessedDate = DateTime.Now;
            billing.ResponseCode = response.ResponseCode;
            billing.ResponseDescription = response.ResponseDescription;

            if (response.Success && response.Key > 0)
            {
                billing.WhmcsOrderId = response.Key;
                billing.BillingStatus = "Active";
                billing.NextBillingDate = CalculateNextBillingDate();
            }
            else
            {
                billing.BillingStatus = "Failed";
            }

            Proxy.UpdateDataContext();
        }

        private void ActivateOwnership(AreaOwnership ownership)
        {
            ownership.Status = "Active";
            ownership.ApprovalDate = DateTime.UtcNow;
            ownership.StartDate = DateTime.UtcNow;
            ownership.ModifiedDate = DateTime.UtcNow;
            
            Proxy.UpdateDataContext();
            
            // Log history
            Proxy.InsertAreaOwnershipHistory(
                ownership.AreaOwnershipId,
                "Activated",
                "Pending",
                "Active",
                ownership.AspNetUserId,
                "Payment successful, area activated");
        }

        private DateTime CalculateNextBillingDate()
        {
            return Config.DefaultBillingCycle switch
            {
                "Monthly" => DateTime.UtcNow.AddMonths(1),
                "Quarterly" => DateTime.UtcNow.AddMonths(3),
                "Annual" => DateTime.UtcNow.AddYears(1),
                _ => DateTime.UtcNow.AddMonths(1)
            };
        }
    }
}
```

---

### 2.2 Iteration 2 Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | Handler creates WHMCS order | Order ID returned |
| 2 | Payment capture works | Invoice paid |
| 3 | Failed payments handled | Order deleted, user notified |
| 4 | Promo codes applied | Discount in WHMCS order |
| 5 | Billing record updated | Status = Active |
| 6 | Ownership activated | Status = Active |

---

# ITERATION 3: Cancellation & Waitlist
## Target: Week 4

### Objective
Handle area cancellation, WHMCS order cancellation, and auto-provision waitlist.

---

### 3.1 Cancellation Handler

```csharp
public class CompetitionCommandCancellationHandler
{
    public async Task<ResponseBase> CancelArea(
        int areaOwnershipId,
        string canceledByUserId,
        string cancelReason)
    {
        var response = ResponseHelper.GetSuccess<ResponseBase>();

        // 1. Cancel WHMCS subscription
        var billing = Proxy.GetActiveBilling(areaOwnershipId);
        if (billing?.WhmcsOrderId > 0)
        {
            var cancelResult = await WhmcsApi.CancelOrderAsync(
                billing.WhmcsOrderId.Value);
            
            if (!cancelResult.Success)
            {
                // Log but don't block - manual cleanup may be needed
                Logger.Warn($"WHMCS cancel failed: {cancelResult.Message}");
            }
        }

        // 2. Update billing status
        Proxy.CancelBilling(areaOwnershipId, cancelReason, canceledByUserId);

        // 3. End ownership (soft delete)
        var ownership = Proxy.GetAreaOwnership(areaOwnershipId);
        Proxy.EndOwnership(
            areaOwnershipId, 
            cancelReason, 
            canceledByUserId);

        // 4. Check and provision waitlist
        await ProvisionNextInWaitlist(ownership.AreaId, ownership.PropertyTypeId);

        return response;
    }

    private async Task ProvisionNextInWaitlist(int areaId, int propertyTypeId)
    {
        var config = GetConfig();
        if (!config.WaitlistAutoProvision)
            return;

        // Get next in queue
        var nextInLine = Proxy.GetNextWaitlistEntry(areaId, propertyTypeId);
        if (nextInLine == null)
            return;

        // Notify and set expiration
        await NotificationService.SendWaitlistOfferAsync(nextInLine);
        
        Proxy.UpdateWaitlistStatus(
            nextInLine.AreaWaitlistId,
            "Notified",
            DateTime.UtcNow.AddHours(config.WaitlistOfferHours));
    }
}
```

---

### 3.2 Iteration 3 Acceptance Criteria

| # | Criteria | Test |
|---|----------|------|
| 1 | WHMCS order canceled | API call succeeds |
| 2 | Billing marked canceled | Status = Canceled |
| 3 | Ownership ended | Status = Ended, EndDate set |
| 4 | History logged | AreaOwnershipHistory record |
| 5 | Waitlist notified | Next person gets email |
| 6 | Offer expiration set | 48hr window |

---

# ITERATION 4: API Endpoints
## Target: Week 5

### 4.1 Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/cc/billing/calculate` | Calculate price for areas |
| POST | `/api/cc/billing/purchase` | Purchase area(s) |
| GET | `/api/cc/billing/history` | Get billing history |
| POST | `/api/cc/billing/cancel` | Cancel subscription |
| GET | `/api/cc/promo/validate` | Validate promo code |
| POST | `/api/admin/cc/promo` | Create promo code |
| GET | `/api/admin/cc/tiers` | Get pricing tiers |

---

## Appendix: WHMCS Product Setup

### Required WHMCS Configuration
1. Create Product: "Competition Command Area Subscription"
2. Set pricing: Monthly recurring
3. Create Custom Field: "Area Description"
4. Note Product ID for config

### Config Values Needed
```json
{
  "CompetitionCommandBillingConfig": {
    "WhmcsProductId": 123,
    "WhmcsCustomFieldId": 456,
    "BasePrices": {
      "SFR": 99.00,
      "Condo": 79.00
    },
    "DefaultBillingCycle": "Monthly",
    "WaitlistAutoProvision": true,
    "WaitlistOfferHours": 48
  }
}
```

---

*Document Version: 1.0*
*Created: 12/13/2025*
*Status: DRAFT - Ready for Review*
*Related: FR-001 (AreaOwnership), FR-003 (ContentConfigurator)*

