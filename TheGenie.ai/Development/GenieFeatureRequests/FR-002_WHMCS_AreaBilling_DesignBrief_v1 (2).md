# Feature Request: WHMCS Area Billing Integration
## FR-002 | Design & Creative Brief
### Version 1.0 | December 2025

---

## 1. Executive Summary

### The Problem
Competition Command area ownership is currently managed separately from billing:
- **No Automated Provisioning**: Area purchases are not linked to WHMCS order creation
- **Manual Deprovisioning**: When agents cancel, areas are manually released
- **No Bundle Pricing**: Cannot offer discounts for multiple zip code purchases
- **No Promo Codes**: No mechanism for promotional pricing on area subscriptions
- **No Waitlist Integration**: Cancellation doesn't automatically provision next waitlist agent
- **Future: No Commission Split**: Cannot track revenue sharing on transactions (3+ months out)

### The Solution
A fully integrated WHMCS billing system for Competition Command area ownership:
- Automated order creation on area purchase
- Automated deprovisioning on cancellation
- Bundle pricing (multi-zip discounts)
- Promo code support
- Waitlist auto-provisioning on cancellation
- Foundation for future commission split model

### Business Value
| Benefit | Impact |
|---------|--------|
| Revenue Optimization | Bundle pricing increases multi-area sales |
| Operational Efficiency | Automated provisioning reduces manual work |
| Customer Experience | Seamless purchase flow, instant activation |
| Revenue Predictability | Subscription model with recurring billing |
| Partner Revenue | Foundation for commission split partnerships |

---

## 2. Current State Analysis

### Existing WHMCS Integration Pattern
Based on source code analysis of `ListingCommandBillingHandler.cs` and `HandlerNCBilling.cs`:

```csharp
// Current pattern for Listing Command billing
var order = new AddOrder
{
    ClientID = whmcsClientId.Value,
    ProductID = Config.WhmcsProductId,
    PromoCode = promoCode,
    PriceOverride = amount,
    BillingCycle = BillingCycleType.OneTime,
    SendInvoice = true,
    CustomFields = new Hashtable
    {
        { Config.WhmcsCustomFieldId, description }
    }
};
var response = WhmcsApi.AddOrder(order);
```

### Current Competition Command Gap
| Component | Listing Command | Competition Command |
|-----------|-----------------|---------------------|
| Billing Table | `ListingCommandBilling` | **MISSING** |
| Billing Handler | `ListingCommandBillingHandler` | **MISSING** |
| WHMCS Product ID | `ListingCommandWhmcsProductId` | **NEEDS CREATION** |
| Promo Code Support | ✅ Role-based | **MISSING** |
| Order Tracking | `WhmcsOrderId` stored | **MISSING** |

### Key Source Files Referenced
| File | Purpose |
|------|---------|
| `Smart.Core/BLL/ListingCommand/Billing/ListingCommandBillingHandler.cs` | Template for billing pattern |
| `Smart.Core/BLL/Billing/Workflow/HandlerNCBilling.cs` | Area-based billing example |
| `Smart.Core/BLL/Billing/Workflow/HandlerWorkflowBillingBase.cs` | Base class for billing |
| `WHMCS.Net` | NuGet package for WHMCS API |

---

## 3. Proposed Solution Overview

### New Entity: `CompetitionCommandBilling`

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
    
    -- Pricing
    BasePrice                     DECIMAL(10,2) NOT NULL,
    BundleDiscount                DECIMAL(10,2) NULL,
    PromoCodeDiscount             DECIMAL(10,2) NULL,
    FinalPrice                    DECIMAL(10,2) NOT NULL,
    
    -- Promo/Bundle
    PromoCode                     NVARCHAR(50) NULL,
    BundleTierId                  INT NULL,
    AreasInBundle                 INT NULL,
    
    -- Billing Cycle
    BillingCycleType              NVARCHAR(20) NOT NULL DEFAULT 'Monthly',
    NextBillingDate               DATETIME2 NULL,
    
    -- Processing
    ResponseCode                  INT NULL,
    ResponseDescription           NVARCHAR(500) NULL,
    ProcessedDate                 DATETIME2 NULL,
    
    -- Metadata
    CreatedDate                   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate                  DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_CCBilling_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId)
);
```

### New Entity: `CompetitionCommandPricingTier`

```sql
CREATE TABLE dbo.CompetitionCommandPricingTier (
    PricingTierId       INT IDENTITY(1,1) PRIMARY KEY,
    TierName            NVARCHAR(50) NOT NULL,
    MinAreas            INT NOT NULL,
    MaxAreas            INT NULL,
    DiscountPercentage  DECIMAL(5,2) NOT NULL,
    DiscountFixed       DECIMAL(10,2) NULL,
    IsActive            BIT NOT NULL DEFAULT 1,
    CreatedDate         DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Sample data
INSERT INTO dbo.CompetitionCommandPricingTier VALUES
('Single', 1, 1, 0.00, NULL, 1, GETUTCDATE()),
('Starter Bundle', 2, 3, 10.00, NULL, 1, GETUTCDATE()),
('Pro Bundle', 4, 6, 15.00, NULL, 1, GETUTCDATE()),
('Enterprise Bundle', 7, NULL, 25.00, NULL, 1, GETUTCDATE());
```

### New Entity: `CompetitionCommandPromoCode`

```sql
CREATE TABLE dbo.CompetitionCommandPromoCode (
    PromoCodeId         INT IDENTITY(1,1) PRIMARY KEY,
    Code                NVARCHAR(50) NOT NULL UNIQUE,
    Description         NVARCHAR(200) NULL,
    DiscountType        NVARCHAR(20) NOT NULL, -- 'Percentage', 'Fixed', 'Trial'
    DiscountValue       DECIMAL(10,2) NOT NULL,
    MaxUses             INT NULL,
    CurrentUses         INT NOT NULL DEFAULT 0,
    ValidFrom           DATETIME2 NULL,
    ValidTo             DATETIME2 NULL,
    RoleTypeId          INT NULL, -- Role-specific codes
    IsActive            BIT NOT NULL DEFAULT 1,
    CreatedDate         DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
```

---

## 4. User Stories

### Agent Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| A1 | Agent | Purchase multiple areas with bundle pricing | I save money on volume |
| A2 | Agent | Apply a promo code at checkout | I get promotional discounts |
| A3 | Agent | See my billing history per area | I understand my costs |
| A4 | Agent | Cancel and have my area auto-released | Next person in waitlist can get it |
| A5 | Agent | Manage my payment method | I can update billing info |

### Admin Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| B1 | Admin | Create bundle pricing tiers | I can incentivize volume purchases |
| B2 | Admin | Create promo codes | I can run marketing campaigns |
| B3 | Admin | See all billing history | I can audit revenue |
| B4 | Admin | Manually override pricing | I can handle special cases |
| B5 | Admin | Configure WHMCS product mapping | I can map areas to products |

### System Stories
| ID | As the... | I want to... | So that... |
|----|-----------|--------------|------------|
| C1 | System | Auto-create WHMCS order on area purchase | Billing is instant |
| C2 | System | Auto-cancel WHMCS subscription on area cancellation | Billing stops |
| C3 | System | Auto-provision waitlist agent on cancellation | Area doesn't sit empty |
| C4 | System | Calculate bundle pricing automatically | Discounts apply correctly |
| C5 | System | Process recurring billing | Subscriptions renew |

---

## 5. Pricing Model

### Base Pricing (Per Area/Month)
| Property Type | Monthly Price |
|---------------|---------------|
| SFR (Single Family) | $[TBD] |
| Condo | $[TBD] |
| Townhouse | $[TBD] |
| Multi-Family | $[TBD] |

### Bundle Discounts
| Tier | Areas | Discount |
|------|-------|----------|
| Single | 1 | 0% |
| Starter | 2-3 | 10% |
| Pro | 4-6 | 15% |
| Enterprise | 7+ | 25% |

### Example Calculation
```
Agent buys 4 areas at $99/month each:
- Base: 4 × $99 = $396/month
- Pro Bundle (15%): -$59.40
- Final: $336.60/month
```

---

## 6. Workflow Diagrams

### Area Purchase Flow
```
Agent Selects Area(s)
        │
        ▼
┌─────────────────────┐
│ Calculate Pricing   │
│ • Base price        │
│ • Bundle discount   │
│ • Promo code        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Create WHMCS Order  │
│ • AddOrder API      │
│ • ProductID mapping │
│ • CustomFields      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Capture Payment     │
│ • CapturePayment    │
│ • Handle failure    │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
  SUCCESS     FAILED
     │           │
     ▼           ▼
┌─────────┐  ┌─────────────┐
│ Activate│  │ Notify User │
│ Area    │  │ Delete Order│
└─────────┘  └─────────────┘
```

### Cancellation & Waitlist Flow
```
Agent Cancels Area
        │
        ▼
┌─────────────────────┐
│ Update AreaOwnership│
│ • Status = Ended    │
│ • EndDate = Now     │
│ • Log History       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Cancel WHMCS Sub    │
│ • CancelOrder API   │
│ • Stop billing      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Check Waitlist      │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
  WAITING      EMPTY
     │           │
     ▼           ▼
┌──────────────┐  ┌────────┐
│ Notify #1    │  │ Area   │
│ Auto-Provision│  │ Open   │
└──────────────┘  └────────┘
```

---

## 7. Future: Commission Split Model (Phase 2 - 3+ Months Out)

### Concept Overview
Allow agents and partners to share transaction revenue:
- Agent gets lead from Competition Command
- Lead converts to closed transaction
- Revenue split between TheGenie and Agent/Partner

### Data Model Sketch
```sql
-- Future: Phase 2
CREATE TABLE dbo.CompetitionCommandCommissionSplit (
    CommissionSplitId       INT IDENTITY(1,1) PRIMARY KEY,
    AreaOwnershipId         INT NOT NULL,
    PartnerAspNetUserId     NVARCHAR(128) NULL,
    
    -- Split Configuration
    SplitType               NVARCHAR(20), -- 'Percentage', 'Fixed'
    TheGenieSplit           DECIMAL(5,2),
    AgentSplit              DECIMAL(5,2),
    PartnerSplit            DECIMAL(5,2),
    
    -- Transaction Tracking
    TransactionId           INT NULL,
    TransactionAmount       DECIMAL(12,2) NULL,
    CommissionAmount        DECIMAL(12,2) NULL,
    
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
```

**Note:** This is scoped for Phase 2. Discovery and detailed specification will be done in 3+ months.

---

## 8. Success Metrics

| Metric | Current | Target | How Measured |
|--------|---------|--------|--------------|
| Manual provisioning time | ~15 min | < 1 min | Order to activation time |
| Bundle conversion rate | N/A | 30%+ | % of multi-area purchases |
| Promo code usage | N/A | Track all | WHMCS promo report |
| Waitlist conversion | N/A | 48hr | Cancel to new owner time |
| Revenue per agent | $[X] | +20% | Bundle upsell impact |

---

## 9. Dependencies & Risks

### Dependencies
| Dependency | Owner | Status |
|------------|-------|--------|
| FR-001: AreaOwnership table | Dev | In Progress |
| WHMCS.Net library access | IT | ⚠️ Needs DLL from prod |
| WHMCS Product ID creation | Admin | Not Started |
| Payment gateway config | Finance | Exists |

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| WHMCS API changes | Low | High | Version lock, test suite |
| Payment capture failures | Medium | High | Retry logic, notifications |
| Bundle calculation errors | Medium | Medium | Comprehensive unit tests |
| Promo code abuse | Low | Low | Usage limits, expiry dates |

---

## 10. Open Questions (Discovery Needed)

| # | Question | Options | Decision |
|---|----------|---------|----------|
| 1 | Base price per area? | $49 / $79 / $99 / $149 | TBD |
| 2 | Billing cycle? | Monthly / Quarterly / Annual | TBD |
| 3 | Bundle tier discounts? | 10-15-25% / Other | TBD |
| 4 | WHMCS product ID for CC? | Existing / New product | TBD |
| 5 | Auto-provision waitlist? | Yes / Admin review | TBD |
| 6 | Trial period for new areas? | None / 7 days / 14 days | TBD |
| 7 | Refund policy on cancel? | No refund / Pro-rated | TBD |

---

## 11. Timeline Estimate

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 1: Design** | 1 week | Final spec, WHMCS product setup |
| **Phase 2: Database** | 1 week | New tables, stored procedures |
| **Phase 3: Billing Handler** | 2 weeks | CompetitionCommandBillingHandler |
| **Phase 4: Bundle/Promo** | 1 week | Pricing engine, promo validation |
| **Phase 5: Waitlist Integration** | 1 week | Auto-provision on cancel |
| **Phase 6: Testing** | 1 week | End-to-end billing tests |

**Total Estimate:** 7-8 weeks

---

## 12. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Technical Lead | | | |
| Finance | | | |

---

*Document Version: 1.0*
*Created: 12/13/2025*
*Status: DRAFT - Pending Discovery*
*Related: FR-001 (AreaOwnership), FR-003 (ContentConfigurator)*

