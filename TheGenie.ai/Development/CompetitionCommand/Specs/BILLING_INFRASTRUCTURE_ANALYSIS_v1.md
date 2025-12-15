# Genie Billing Infrastructure Analysis
## Version 1.0 | Created: 12/14/2025

---

## Executive Summary

This document analyzes the existing billing infrastructure for NC, LC, and the Credit system to inform the Competition Command billing implementation and potential Shopping Cart feature.

---

## 1. WHMCS Product IDs

| Product | WHMCS Product ID | Billing Type |
|---------|------------------|--------------|
| **Competition Command** | 83 | Monthly Subscription (TBD) |
| **Listing Command** | 84 | Per-Use (OneTime) |
| **Neighborhood Command** | 85 | Per-Use (OneTime) |
| **Credits** | 57 | Package Purchase |

---

## 2. Current Pricing Structure

### 2.1 Per-Channel Costs (NC & LC)

| Channel | Cost Per Unit | Notes |
|---------|---------------|-------|
| **SMS** | $0.50/message | Same for NC and LC |
| **Facebook** | $0.02-0.25/impression | NC=$0.02, LC=$0.25 |
| **Direct Mail** | $1.35/piece | Same for NC and LC |
| **Facebook Minimum** | Configurable | NC can have minimum spend |

### 2.2 How Pricing is Calculated

```
Total = (SMS Target × SMS Cost) + (FB Target × FB Cost) + (DM Target × DM Cost)

Example NC Campaign:
  500 SMS × $0.50 = $250.00
  + 0 FB × $0.02 = $0.00
  + 0 DM × $1.35 = $0.00
  = $250.00 total
```

### 2.3 Credit System (Data Append / ListMiner)

**Purchase Tiers with Bonus Credits:**

| Credits Purchased | Bonus Credits | Effective Discount |
|-------------------|---------------|-------------------|
| 1,000 | 0 | 0% |
| 7,500 | 75 | 1% |
| 15,000 | 300 | 2% |
| 30,000 | 1,200 | 4% |
| 50,000 | 2,500 | 5% |
| 65,000 | 3,900 | 6% |
| 90,000 | 6,300 | 7% |
| 105,000 | 8,400 | 8% |
| 120,000 | 10,800 | 9% |
| 140,000 | 14,000 | 10% |
| 250,000 | 37,500 | 15% |

**Data Append Package Credit Costs:**

| Package | Email | Phone | Demographic | Financial |
|---------|-------|-------|-------------|-----------|
| Itemized | 15 credits | 15 credits | 6 credits | 6 credits |
| Standard | 10 credits | 10 credits | 0 credits | 0 credits |
| Booster | 7 credits | 7 credits | 4 credits | 4 credits |

---

## 3. Billing Flow Architecture

### 3.1 NC/LC Billing Flow

```
┌─────────────────┐
│ User Creates    │
│ NC/LC Campaign  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Create Billing  │  ← NeighborhoodCommandBilling / ListingCommandBilling
│ Record (Pending)│     BillingTypeId = 1 (Dollar) or 2 (Credit)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Workflow Queue  │  ← Billing step in PropertyCastWorkflowQueue
│ Picks Up        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ BillingHandler  │  ← HandlerNCBilling / ListingCommandBillingHandler
│ Processes       │
└────────┬────────┘
         │
         ├── Calculate Amount (channels × costs)
         ├── Check PromoCode (role-based discounts)
         ├── Get WhmcsClientId
         │
         ▼
┌─────────────────┐
│ WHMCS AddOrder  │  ← Uses PriceOverride (Genie controls price!)
│ API Call        │     BillingCycle = OneTime
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ CapturePayment  │  ← Attempts to charge saved payment method
│ Manager         │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
Success    Failure
    │         │
    ▼         ▼
┌────────┐ ┌────────────────┐
│ Update │ │ Delete Order   │
│ Billing│ │ Send Failed    │
│ Record │ │ Notification   │
└────────┘ └────────────────┘
```

### 3.2 Key Code Files

| Component | File Path |
|-----------|-----------|
| **LC Billing Handler** | `Smart.Core\BLL\ListingCommand\Billing\ListingCommandBillingHandler.cs` |
| **NC Billing Handler** | `Smart.Core\BLL\Billing\Workflow\HandlerNCBilling.cs` |
| **Billing Factory** | `Smart.Core\BLL\Billing\Workflow\WorkflowBillingFactory.cs` |
| **Payment Capture** | `Smart.Core\BLL\Billing\CapturePaymentManager.cs` |
| **Credit Manager** | `Smart.Core\BLL\DataAppend\Order\DataAppendCreditOrderManager.cs` |

---

## 4. Key Patterns to Reuse for CC

### 4.1 Billing Record Pattern

```csharp
// Create billing record when area is purchased
public class CompetitionCommandBilling
{
    public int CompetitionCommandBillingId { get; set; }
    public int BillingTypeId { get; set; }           // 1=Dollar, 2=Credit
    public string PromoCode { get; set; }             // For discounts
    public int? WhmcsOrderId { get; set; }            // From WHMCS
    public long? CreditTransactionQueueId { get; set; } // If paying with credits
    public int? ResponseCode { get; set; }            // Success/Failure
    public string ResponseDescription { get; set; }
    public DateTime CreateDate { get; set; }
    public DateTime? ProcessDate { get; set; }
}
```

### 4.2 PriceOverride Pattern

The most important pattern: **Genie controls pricing, WHMCS just processes payment**.

```csharp
var order = new AddOrder
{
    ClientID = whmcsClientId.Value,
    ProductID = 83,  // CC Product ID
    PromoCode = promoCode,
    PriceOverride = calculatedAmount,  // ← Genie sets the price!
    BillingCycle = BillingCycleType.Monthly,  // For CC subscription
    SendInvoice = true
};
```

### 4.3 Role-Based Discounts

```csharp
// Config has role → promo code mapping
if (Config.RoleDiscounts.TryGetValue((int)role, out var discountItem))
    billing.PromoCode = discountItem.PromoCode;
```

---

## 5. Shopping Cart Concept - Implementation Options

### Option A: Extend Existing Pattern (Recommended Start)

**How it would work:**
1. User selects zip codes (like selecting NC areas)
2. Each zip creates a `CompetitionCommandBilling` record
3. Calculate total with quantity discount
4. Single WHMCS order with bundled price

**Quantity Discount Table (proposed):**
```sql
CREATE TABLE dbo.CompetitionCommandPricingTier (
    TierId INT PRIMARY KEY,
    MinZips INT,
    MaxZips INT,
    PricePerZip DECIMAL(10,2),
    IsEnabled BIT
);

-- Example tiers
INSERT INTO CompetitionCommandPricingTier VALUES
(1, 1, 1, 149.00, 1),    -- 1 zip = $149
(2, 2, 2, 124.50, 1),    -- 2 zips = $124.50 each
(3, 3, 4, 116.33, 1),    -- 3-4 zips = $116.33 each
(4, 5, 99, 99.00, 1);    -- 5+ zips = $99 each
```

### Option B: Full Shopping Cart

**New Components Needed:**
1. `GenieCart` - Shopping cart model
2. `GenieCartItem` - Line items (CC zips, LC allotments, etc.)
3. `GenieBundle` - Pre-defined packages
4. `GenieBundlePricing` - Bundle discount rules
5. Cart UI in Angular

**Bundle Examples:**
```sql
CREATE TABLE dbo.GenieBundle (
    BundleId INT PRIMARY KEY,
    BundleName VARCHAR(100),
    MonthlyPrice DECIMAL(10,2),
    CCZipsIncluded INT,
    LCMonthlyAllotment INT,
    IsEnabled BIT
);

INSERT INTO GenieBundle VALUES
(1, 'Starter', 199.00, 1, 2, 1),
(2, 'Pro', 449.00, 3, 5, 1),
(3, 'Elite', 699.00, 5, 10, 1);
```

### Option C: Credit-Based (Like Data Append)

User buys credits, uses them for any product:
- 1 CC zip = 300 credits/month
- 1 LC use = 50 credits
- Credits never expire but don't roll over monthly allotments

---

## 6. Recommendations for CC Billing

### Phase 1: Simple (FR-002)
1. Create `CompetitionCommandBilling` table
2. Create `CompetitionCommandBillingHandler` following NC pattern
3. Use PriceOverride with flat $149/zip/month
4. WHMCS Product ID 83 with Monthly billing cycle

### Phase 2: Quantity Discounts
1. Add `CompetitionCommandPricingTier` table
2. Calculate discounted price based on total zips
3. Apply discount at checkout

### Phase 3: Shopping Cart (FR-004)
1. Full cart infrastructure
2. Bundle support
3. Cross-product (CC + LC) bundling
4. Monthly subscription management

---

## 7. Database Tables Summary

### Existing (Reuse Patterns)
- `NeighborhoodCommandBilling` - NC billing records
- `ListingCommandBilling` - LC billing records
- `GenieBillingType` - Dollar vs Credit
- `CreditPurchaseTier` - Credit volume discounts
- `UserWhmcs` - Links AspNetUsers to WHMCS

### New for CC (Proposed)
- `CompetitionCommandBilling` - CC billing records
- `CompetitionCommandPricingTier` - Quantity discounts

### Future Shopping Cart
- `GenieCart`
- `GenieCartItem`
- `GenieBundle`
- `GenieBundlePricing`

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/14/2025 | Initial analysis of NC, LC, and Credit billing systems |

---

*File: BILLING_INFRASTRUCTURE_ANALYSIS_v1.md*
*Location: C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Specs\*

