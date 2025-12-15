# Feature Request: WHMCS Area Billing Integration
## FR-002 | Design & Creative Brief
### Version 1.0

**Created:** 12/13/2025  
**Status:** DRAFT

---

## 1. Executive Summary

### The Problem
Currently, area purchases for Competition Command are not integrated with the WHMCS billing system:
- **Manual Provisioning**: Admins manually activate areas after payment verification
- **No Bundle Pricing**: Cannot offer discounts for multiple area purchases
- **Promo Codes Disconnected**: Promotional pricing requires manual calculation
- **No Auto-Deprovision**: When billing stops, area remains active (revenue leak)
- **Waitlist Disconnect**: Area cancellation doesn't auto-notify waitlist

### The Solution
Full integration with WHMCS billing system to:
- Auto-provision area ownership on successful payment
- Auto-deprovision on cancellation/non-payment
- Support bundle pricing (discounts for multiple areas)
- Process promo codes automatically
- Trigger waitlist notification on area release
- Future: Commission split on transactions (Phase 2 - Q2 2026)

### Business Value
| Benefit | Impact |
|---------|--------|
| Revenue Protection | Immediate deactivation on non-payment |
| Increased ARPU | Bundle pricing encourages more purchases |
| Conversion | Promo codes drive new signups |
| Operational Efficiency | Zero manual provisioning |
| Customer Experience | Instant activation after payment |
| Future Revenue | Commission split model (Q2 2026) |

---

## 2. Source Code Reference

### Existing WHMCS Patterns
Analysis of `Genie.Source.Code_v1` reveals established billing patterns:

| Component | Path | Pattern Used |
|-----------|------|--------------|
| Listing Command Billing | `Smart.Core/BLL/ListingCommand/Billing/ListingCommandBillingHandler.cs` | AddOrder → CapturePayment |
| Neighborhood Command | `Smart.Core/BLL/Billing/Workflow/HandlerNCBilling.cs` | Area-based billing |
| Base Handler | `Smart.Core/BLL/Billing/Workflow/HandlerWorkflowBillingBase.cs` | Abstract pattern |
| WHMCS API | `WHMCS.Net` library | AddOrder, CapturePayment |

### Key Code Pattern (from ListingCommandBillingHandler.cs)
```csharp
// 1. Get WHMCS client
var whmcsClientId = Proxy.GetUserWhmcs(aspNetUserId)?.WhmcsClientId;

// 2. Check promo codes
CheckForPromoCode(billing, role);

// 3. Add order to WHMCS
var addOrderResponse = WhmcsApi.AddOrder(order);

// 4. Capture payment
var capture = new CapturePaymentManager(whmcsClientId, productId);
capture.ProcessNewOrder(orderResponse);

// 5. Handle failure
if (!whmcsOrderResponse.Success) {
    FailedPaymentCaptureManager.RegisterFailedPayment(...);
}
```

---

## 3. Proposed Architecture

### New Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPETITION COMMAND BILLING                   │
│                         (FR-002)                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐│
│  │ CompetitionCommand  │    │    Pricing Engine               ││
│  │ BillingHandler      │◄──►│    • Base Price                 ││
│  │                     │    │    • Bundle Calculator          ││
│  │ • Process()         │    │    • Promo Code Validator       ││
│  │ • CheckForPromo()   │    └─────────────────────────────────┘│
│  │ • AddOrder()        │                                       │
│  │ • CapturePayment()  │    ┌─────────────────────────────────┐│
│  └──────────┬──────────┘    │    WHMCS Integration            ││
│             │               │    • WHMCS.Net AddOrder         ││
│             ▼               │    • CapturePaymentManager      ││
│  ┌─────────────────────┐    │    • FailedPaymentManager       ││
│  │ Competition Command │    └─────────────────────────────────┘│
│  │ CancellationHandler │                                       │
│  │                     │    ┌─────────────────────────────────┐│
│  │ • CancelArea()      │    │    FR-001 Integration           ││
│  │ • TriggerWaitlist() │◄──►│    • usp_AreaOwnership_Activate ││
│  └─────────────────────┘    │    • usp_AreaOwnership_End      ││
│                             │    • usp_AreaWaitlist_NotifyNext││
│                             └─────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Database Schema

#### Table: `CompetitionCommandBilling`
```sql
CREATE TABLE dbo.CompetitionCommandBilling (
    CompetitionCommandBillingId INT IDENTITY(1,1) PRIMARY KEY,
    AreaOwnershipId         INT NOT NULL,           -- FK to FR-001
    AspNetUserId            NVARCHAR(128) NOT NULL,
    
    -- WHMCS Order
    WhmcsOrderId            INT NULL,
    WhmcsInvoiceId          INT NULL,
    WhmcsClientId           INT NULL,
    
    -- Pricing
    BaseAmount              DECIMAL(10,2) NOT NULL,
    BundleDiscount          DECIMAL(10,2) NOT NULL DEFAULT 0,
    PromoDiscount           DECIMAL(10,2) NOT NULL DEFAULT 0,
    FinalAmount             AS (BaseAmount - BundleDiscount - PromoDiscount),
    
    -- Promo Code
    PromoCodeId             INT NULL,
    PromoCode               NVARCHAR(50) NULL,
    
    -- Status
    BillingStatus           NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        -- Values: 'Pending', 'Active', 'Failed', 'Canceled', 'Suspended'
    
    -- Response Tracking
    ResponseCode            INT NULL,
    ResponseMessage         NVARCHAR(500) NULL,
    
    -- Dates
    BillingStartDate        DATETIME2 NULL,
    BillingEndDate          DATETIME2 NULL,
    NextBillingDate         DATETIME2 NULL,
    
    -- Metadata
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_CCBilling_AreaOwnership 
        FOREIGN KEY (AreaOwnershipId) REFERENCES dbo.AreaOwnership(AreaOwnershipId)
);
```

#### Table: `CompetitionCommandPricing`
```sql
CREATE TABLE dbo.CompetitionCommandPricing (
    CompetitionCommandPricingId INT IDENTITY(1,1) PRIMARY KEY,
    PricingName             NVARCHAR(100) NOT NULL,
    PropertyTypeId          INT NOT NULL DEFAULT 0,
    BaseMonthlyPrice        DECIMAL(10,2) NOT NULL,
    IsActive                BIT NOT NULL DEFAULT 1,
    EffectiveDate           DATE NOT NULL,
    ExpirationDate          DATE NULL,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
```

#### Table: `CompetitionCommandBundle`
```sql
CREATE TABLE dbo.CompetitionCommandBundle (
    CompetitionCommandBundleId INT IDENTITY(1,1) PRIMARY KEY,
    BundleName              NVARCHAR(100) NOT NULL,
    MinAreas                INT NOT NULL,
    MaxAreas                INT NULL,  -- NULL = unlimited
    DiscountPercent         DECIMAL(5,2) NOT NULL,
    IsActive                BIT NOT NULL DEFAULT 1,
    CreatedDate             DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Seed Data
INSERT INTO dbo.CompetitionCommandBundle (BundleName, MinAreas, MaxAreas, DiscountPercent)
VALUES 
    ('Single', 1, 1, 0),
    ('Starter', 2, 3, 10),
    ('Pro', 4, 6, 15),
    ('Enterprise', 7, NULL, 25);
```

---

## 4. User Stories

### Agent Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| A1 | Agent | Purchase an area with credit card | I get instant access |
| A2 | Agent | Apply a promo code | I save money |
| A3 | Agent | See bundle discounts | I'm incentivized to buy more |
| A4 | Agent | View my billing history | I can track expenses |
| A5 | Agent | Update my payment method | I don't lose my areas |
| A6 | Agent | Cancel an area | I stop getting charged |

### Admin Stories
| ID | As an... | I want to... | So that... |
|----|----------|--------------|------------|
| B1 | Admin | Create promo codes | I can run promotions |
| B2 | Admin | Set pricing tiers | I can adjust revenue |
| B3 | Admin | Configure bundles | I can incentivize growth |
| B4 | Admin | View billing reports | I can track revenue |
| B5 | Admin | Override pricing | I can handle special cases |

### System Stories
| ID | As the... | I want to... | So that... |
|----|-----------|--------------|------------|
| C1 | System | Auto-provision on payment | No manual activation |
| C2 | System | Auto-cancel on failed payment | Revenue is protected |
| C3 | System | Notify waitlist on cancel | Areas get reused |
| C4 | System | Retry failed payments | Recovery is automated |

---

## 5. Workflow Diagrams

### New Area Purchase Flow

```
Agent Selects Area
        │
        ▼
┌─────────────────────┐
│ FR-001: Create      │
│ AreaOwnership       │
│ Status = Pending    │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Calculate Price     │
│ • Base price        │
│ • Check agent's     │
│   active areas      │
│ • Apply bundle tier │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Apply Promo Code    │
│ (if provided)       │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Create Billing      │
│ Record (Pending)    │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ WHMCS AddOrder()    │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ CapturePayment()    │
└────────┬────────────┘
         │
    ┌────┴────┐
    │         │
SUCCESS     FAILED
    │         │
    ▼         ▼
┌──────────────┐  ┌──────────────────────┐
│ FR-001:      │  │ Register Failed      │
│ Activate     │  │ Payment              │
│ Ownership    │  │ Retry 3x over 7 days │
│ FR-003:      │  │ Then cancel          │
│ Default CTA  │  └──────────────────────┘
└──────────────┘
```

### Cancellation Flow

```
Agent Cancels OR Payment Fails
        │
        ▼
┌─────────────────────┐
│ CompetitionCommand  │
│ CancellationHandler │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Cancel WHMCS Order  │
│ Stop future billing │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Update Billing      │
│ Status = Canceled   │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ FR-001:             │
│ usp_AreaOwnership_  │
│ End                 │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Check Waitlist      │
│ for this area       │
└────────┬────────────┘
         │
    ┌────┴────┐
    │         │
 EXISTS      NONE
    │         │
    ▼         ▼
┌────────────┐  ┌────────────┐
│ Notify #1  │  │ Area now   │
│ in queue   │  │ available  │
│ 48hr offer │  │ for anyone │
└────────────┘  └────────────┘
```

---

## 6. Bundle Pricing Example

| Agent's Areas | Tier | Base Price | Discount | Per-Area Price |
|---------------|------|------------|----------|----------------|
| 1 | Single | $99 | 0% | $99 |
| 2 | Starter | $99 | 10% | $89.10 |
| 3 | Starter | $99 | 10% | $89.10 |
| 4 | Pro | $99 | 15% | $84.15 |
| 7 | Enterprise | $99 | 25% | $74.25 |

**Note:** When an agent adds an area, existing areas may upgrade to a new tier, requiring billing adjustment on next cycle.

---

## 7. Promo Code Types

| Type | Description | Example |
|------|-------------|---------|
| Percentage | X% off first month | SAVE20 (20% off) |
| Fixed Amount | $X off first month | WELCOME25 ($25 off) |
| Free Trial | X days free before billing | TRIAL14 (14 days free) |
| Free Month | First month free | FREEMONTH |
| Role-Based | Auto-apply by user role | FOUNDERS (50% off) |

---

## 8. Success Metrics

| Metric | Target | How Measured |
|--------|--------|--------------|
| Auto-provision rate | 100% | Orders → Active Areas |
| Failed payment recovery | 40%+ | Retries → Success |
| Bundle adoption | 30%+ | Multi-area purchases |
| Promo conversion | 15%+ | Promo trials → Paid |
| Time to activation | < 30 sec | Payment → Active |
| Manual intervention | 0 | Support tickets for billing |

---

## 9. Future Scope: Commission Split (Q2 2026)

### Concept
Share revenue with agents when their leads result in closed transactions.

### High-Level Model
- Track leads from Competition Command areas
- Match leads to closed transactions (MLS or manual)
- Calculate commission based on sale price
- Credit agent account or issue payment

**Note:** This is 3+ months out. Full specification to follow in FR-002 Phase 2.

---

## 10. Dependencies & Risks

### Dependencies
| Dependency | Owner | Status |
|------------|-------|--------|
| FR-001 AreaOwnership table | Backend | In Progress |
| WHMCS.Net DLL access | IT | Need to confirm |
| WHMCS Product ID for CC | Billing | To be created |
| Payment gateway setup | Finance | Existing |

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| WHMCS API changes | Low | High | Version lock, test suite |
| Promo code abuse | Medium | Medium | Usage limits, validation |
| Bundle tier changes | Low | Medium | Billing adjustment logic |
| Failed payment spike | Medium | High | Retry logic, notifications |

---

## 11. Timeline Estimate

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 1: Schema** | 1 week | Billing tables, pricing config |
| **Phase 2: Handler** | 2 weeks | BillingHandler, CancellationHandler |
| **Phase 3: Promo** | 1 week | Promo code validation |
| **Phase 4: Bundle** | 1 week | Bundle calculator |
| **Phase 5: Integration** | 1 week | FR-001 hooks, waitlist trigger |
| **Phase 6: Test** | 1 week | End-to-end testing |

**Total Estimate:** 7 weeks

---

## 12. Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Technical Lead | | | |
| Finance | | | |

---

**Document Version:** 1.0  
**Created:** 12/13/2025  
**Status:** DRAFT

