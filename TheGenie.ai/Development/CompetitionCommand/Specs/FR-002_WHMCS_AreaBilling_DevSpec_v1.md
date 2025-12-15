# Feature Request: WHMCS Area Billing Integration
## FR-002 | Development Specification
### Version 1.0 | Created: 12/13/2025 | Updated: 12/14/2025

---

## Document Purpose
Technical specification for integrating Competition Command area purchases with WHMCS billing system. Includes pricing configuration, promo codes, bundle discounts, order provisioning, and de-provisioning on cancellation.

---

## Executive Summary

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FR-002 |
| **Feature Name** | WHMCS Area Billing Integration |
| **Status** | Discovery |
| **Priority** | High |
| **Dependency** | FR-001 (Area Ownership System) |
| **Sprint Target** | Sprint 52-53 |

---

## Business Requirements

### Core Functionality
1. **Order Provisioning** - When agent purchases area, create WHMCS order
2. **Payment Capture** - Process payment via existing WHMCS infrastructure
3. **Promo Code Support** - Apply promotional discounts at checkout
4. **Bundle Pricing** - Discounts for multiple zip codes
5. **De-provisioning** - On cancellation, release area to waitlist

### Pricing Model

| Tier | Zip Codes | Monthly Price | Discount |
|------|-----------|---------------|----------|
| **Single** | 1 | $99/month | - |
| **Growth** | 2-3 | $89/month each | 10% off |
| **Pro** | 4-5 | $79/month each | 20% off |
| **Enterprise** | 6+ | $69/month each | 30% off |

### Promo Codes (Proposed)

| Code | Discount | Conditions |
|------|----------|------------|
| `LAUNCH25` | 25% off first month | New customers only |
| `SECOND50` | 50% off second area | Existing owners |
| `ANNUAL20` | 20% off | Annual prepay |
| `REFER50` | $50 credit | Referral reward |

---

## Technical Architecture

### Existing Patterns to Follow

The implementation follows existing WHMCS integration patterns found in:
- `ListingCommandBillingHandler.cs`
- `HandlerNCBilling.cs` (Neighborhood Command)

### Key Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Agent Portal                              │
│                 (My Areas / Buy Area)                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              AreaBillingHandler.cs (NEW)                    │
│  - CheckForPromoCode()                                      │
│  - CalculateBundleDiscount()                                │
│  - AddOrder()                                               │
│  - CapturePayment()                                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                WHMCS.Net Library                            │
│  - WhmcsApi.AddOrder()                                      │
│  - CapturePaymentManager.ProcessNewOrder()                  │
│  - FailedPaymentCaptureManager (on failure)                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  WHMCS API                                  │
│             accounts.1parkplace.com                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Schema

### New Table: `AreaBilling`

```sql
CREATE TABLE dbo.AreaBilling (
    AreaBillingId           INT IDENTITY(1,1) PRIMARY KEY,
    AreaOwnershipId         INT NOT NULL,
    
    -- WHMCS References
    WhmcsOrderId            INT NULL,
    WhmcsClientId           INT NULL,
    WhmcsProductId          INT NOT NULL,
    
    -- Pricing
    BaseAmount              DECIMAL(10,2) NOT NULL,
    DiscountAmount          DECIMAL(10,2) NOT NULL DEFAULT 0,
    DiscountReason          NVARCHAR(100) NULL,
    FinalAmount             DECIMAL(10,2) NOT NULL,
    PromoCode               NVARCHAR(50) NULL,
    
    -- Status
    BillingStatus           NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        -- Values: 'Pending', 'Active', 'Failed', 'Canceled', 'Refunded'
    ResponseCode            INT NULL,
    ResponseMessage         NVARCHAR(500) NULL,
    
    -- Dates
    BillingCycleStart       DATETIME2 NULL,
    BillingCycleEnd         DATETIME2 NULL,
    NextBillingDate         DATETIME2 NULL,
    
    -- Audit
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_AreaBilling_AreaOwnership
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId)
);

CREATE INDEX IX_AreaBilling_AreaOwnershipId ON dbo.AreaBilling(AreaOwnershipId);
CREATE INDEX IX_AreaBilling_WhmcsOrderId ON dbo.AreaBilling(WhmcsOrderId);
CREATE INDEX IX_AreaBilling_Status ON dbo.AreaBilling(BillingStatus);
```

### New Table: `AreaBundlePricing`

```sql
CREATE TABLE dbo.AreaBundlePricing (
    AreaBundlePricingId     INT IDENTITY(1,1) PRIMARY KEY,
    MinAreas                INT NOT NULL,
    MaxAreas                INT NOT NULL,
    MonthlyPricePerArea     DECIMAL(10,2) NOT NULL,
    DiscountPercent         DECIMAL(5,2) NOT NULL,
    TierName                NVARCHAR(50) NOT NULL,
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Seed data
INSERT INTO dbo.AreaBundlePricing (MinAreas, MaxAreas, MonthlyPricePerArea, DiscountPercent, TierName)
VALUES 
    (1, 1, 99.00, 0, 'Single'),
    (2, 3, 89.00, 10, 'Growth'),
    (4, 5, 79.00, 20, 'Pro'),
    (6, 999, 69.00, 30, 'Enterprise');
```

---

## API Endpoints

### Agent Portal

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/area/pricing` | Get current pricing tiers |
| POST | `/api/area/calculate` | Calculate price with promo code |
| POST | `/api/area/purchase` | Process area purchase |
| GET | `/api/area/billing/{areaOwnershipId}` | Get billing details |

### Admin Portal

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/area/billing` | List all area billing records |
| POST | `/api/admin/area/refund` | Process refund |
| POST | `/api/admin/area/cancel` | Cancel subscription |
| PUT | `/api/admin/area/pricing` | Update pricing tiers |

---

## Implementation Classes

### AreaBillingHandler.cs (NEW)

```csharp
namespace Smart.Core.BLL.Area.Billing
{
    public class AreaBillingHandler : HandlerBase<ResponseWithKey>
    {
        public override ResponseWithKey Process(
            string aspNetUserId, 
            int areaOwnershipId,
            int workflowQueueId, 
            RoleType role)
        {
            // Load billing details
            var billing = LoadAreaBilling(areaOwnershipId);
            
            // Don't reprocess successful orders
            if (billing.ResponseCode == (int)ResponseCodeReserved.Success)
            { 
                response.Key = billing.WhmcsOrderId.GetValueOrDefault();
                return response;
            }
            
            // Get WHMCS client ID
            var whmcsClientId = Proxy.GetUserWhmcs(aspNetUserId)?.WhmcsClientId;
            
            // Apply promo code if provided
            CheckForPromoCode(billing, role);
            
            // Calculate bundle discount
            CalculateBundleDiscount(billing, aspNetUserId);
            
            // Add order to WHMCS
            var addOrderResponse = AddOrder(billing, whmcsClientId);
            
            if (!WhmcsHelper.IsWhmcsSuccess(addOrderResponse))
            {
                HandleFailedOrder(billing, addOrderResponse);
                return response;
            }
            
            // Capture payment
            var capture = new CapturePaymentManager(
                whmcsClientId.Value, 
                Config.AreaOwnershipWhmcsProductId);
            capture.ProcessNewOrder(whmcsOrderResponse);
            
            // Update billing record
            UpdateBilling(billing, response);
            
            // Activate area ownership
            ActivateAreaOwnership(areaOwnershipId);
            
            return response;
        }
        
        private void CalculateBundleDiscount(AreaBilling billing, string aspNetUserId)
        {
            // Count user's total active areas
            var activeAreaCount = Proxy.GetActiveAreaCount(aspNetUserId);
            
            // Get applicable pricing tier
            var tier = Proxy.GetBundlePricingTier(activeAreaCount + 1);
            
            if (tier.DiscountPercent > 0)
            {
                billing.DiscountAmount = billing.BaseAmount * (tier.DiscountPercent / 100);
                billing.DiscountReason = $"Bundle: {tier.TierName} ({tier.DiscountPercent}% off)";
                billing.FinalAmount = billing.BaseAmount - billing.DiscountAmount;
            }
        }
    }
}
```

---

## Workflow Integration

### Purchase Flow

```
1. Agent selects area(s) → UI calculates price with bundles
2. Agent applies promo code (optional) → Validate and apply
3. Agent confirms purchase → Create AreaOwnership (Status: Pending)
4. System creates WHMCS order → AreaBillingHandler.Process()
5. Payment captured → Update AreaOwnership (Status: Active)
6. Failure → FailedPaymentCaptureManager → Notify agent
```

### Cancellation Flow

```
1. Agent or Admin cancels → Update AreaOwnership (Status: Ended)
2. Trigger WHMCS cancellation → Cancel recurring billing
3. Check waitlist → usp_AreaWaitlist_NotifyNext
4. First in waitlist notified → 48-hour window to accept
```

---

## Configuration Settings

```csharp
// Config/AreaBillingConfig.cs
public class AreaBillingConfig
{
    public int WhmcsProductId { get; set; }  // REQUIRED FROM IT
    public decimal BaseMonthlyPrice { get; set; } = 99.00m;
    public int BillingCycleDays { get; set; } = 30;
    public int GracePeriodDays { get; set; } = 7;
    public bool EnableBundleDiscounts { get; set; } = true;
    public bool EnablePromoCodes { get; set; } = true;
}
```

---

## Open Questions / Blockers

| # | Question | Status | Owner |
|---|----------|--------|-------|
| 1 | What is the WHMCS Product ID for Competition Command areas? | ⚠️ BLOCKER | IT Team |
| 2 | Should bundle pricing recalculate monthly as areas change? | Open | Product |
| 3 | What happens to existing owners when we enable billing? | Open | Product |
| 4 | Commission split model scope (Q2 2026)? | Future | Product |

---

## Testing Checklist

- [ ] Single area purchase - no promo, no bundle
- [ ] Multi-area purchase - bundle discount applies
- [ ] Promo code - valid code reduces price
- [ ] Promo code - invalid/expired rejected
- [ ] Payment failure - proper error handling
- [ ] Cancellation - area released, waitlist notified
- [ ] Refund - partial and full

---

## Dependencies

| Dependency | Status |
|------------|--------|
| FR-001: Area Ownership System | Required |
| WHMCS Product ID | ⚠️ Blocker |
| WHMCS.Net Library | ✅ Available |
| CapturePaymentManager | ✅ Available |

---

*Document Version: 1.0 | Created: 12/13/2025 | Updated: 12/14/2025*

