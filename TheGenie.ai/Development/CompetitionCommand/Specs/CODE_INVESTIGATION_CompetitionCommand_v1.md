# Code Investigation: Competition Command Enhancement
## Technical Findings from Source Code Analysis

---

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/14/2025 |
| **Last Updated** | 12/14/2025 |
| **Author** | Steve Hundley |
| **Facilitator** | Cursor AI |
| **Status** | Complete |

---

# EXECUTIVE SUMMARY

This document captures the findings from investigating the TheGenie codebase to understand existing patterns for:
1. **Area Ownership** - How areas are managed today
2. **Neighborhood Command (NC)** - Subscription workflow pattern to follow
3. **Listing Command (LC)** - Billing handler pattern to follow

**Key Finding:** The existing `OwnedAreaManager.cs` is extremely basic - it supports only CRUD with hard deletes. No history, no waitlist, no workflow. We need to build the full system.

---

# INVESTIGATION 1: OwnedAreaManager.cs

## File Location
```
C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Core\BLL\OwnedArea\OwnedAreaManager.cs
```

## Current Capabilities

| Method | What It Does | Limitation |
|--------|--------------|------------|
| `CreateUserOwnedArea()` | Creates new area ownership record | No validation, no payment |
| `DeleteUserOwnedArea()` | **HARD DELETES** the record | Loses all history |
| `GetUserOwnedAreas()` | Lists user's owned areas | No admin view of ALL areas |
| `CheckAreaAvailable()` | Checks if area is taken | Returns true/false only, no waitlist |

## Critical Code Analysis

### CreateUserOwnedArea (Lines 20-42)
```csharp
public ResponseWithKey CreateUserOwnedArea(int areaId, int ownershipTypeId, int propertyTypeId, string aspNetUserId)
{
    var area = Proxy.CreateUserOwnedArea();
    area.AreaId = areaId;
    area.AreaOwnershipTypeId = ownershipTypeId;
    area.PropertyTypeId = propertyTypeId;
    area.AspNetUserId = aspNetUserId;
    
    Proxy.UpdateDataContext();
    // ...
}
```

**Problems Identified:**
- ❌ No billing/payment integration
- ❌ No availability check before creation
- ❌ No history tracking
- ❌ No notification system

### DeleteUserOwnedArea (Lines 44-72)
```csharp
public ResponseWithKey DeleteUserOwnedArea(int userOwnedAreaId)
{
    var deleteResponse = Proxy.DeleteByUserOwnedAreaId(userOwnedAreaId);
    // ...
}
```

**Problems Identified:**
- ❌ **HARD DELETE** - Data is permanently lost
- ❌ No soft delete with EndDate/EndReason
- ❌ No waitlist notification on delete
- ❌ No history preservation

### CheckAreaAvailable (Lines 126-141)
```csharp
public ResponseAreaAvailable CheckAreaAvailable(int areaId, int ownershipTypeId, int propertyTypeId)
{
    var area = Proxy.GetUserOwnedArea(areaId, ownershipTypeId, propertyTypeId);
    response.IsAvailable = area == null;
    return response;
}
```

**Current Output:** Simple boolean (available/not available)
**What's Needed:** Waitlist count, position, owner info (admin only)

## Summary: What OwnedAreaManager Needs

| Feature | Current | Required |
|---------|---------|----------|
| Create with billing | ❌ | ✅ WHMCS integration |
| Soft delete | ❌ | ✅ Status + EndDate + EndReason |
| History tracking | ❌ | ✅ AreaOwnershipHistory table |
| Availability check | Basic | ✅ Include waitlist info |
| Waitlist queue | ❌ | ✅ Full FIFO system |
| Admin radar | ❌ | ✅ Dashboard of all areas |
| Notifications | ❌ | ✅ SMS/Email on availability |

---

# INVESTIGATION 2: Neighborhood Command Workflow

## File Locations
```
Smart.Service.NeighborhoodCommand\Smart.NeighborhoodCommand.Core\BLL\
├── NeighborhoodCommandService.cs    ← Entry point
├── NeighborhoodCommandHandler.cs    ← Main processing logic
└── Api\GenieApiService.cs           ← API calls

Smart.NeighborhoodCommand.Data\NC\SQL\Models\
├── NeighborhoodCommand.cs           ← Main entity
├── NeighborhoodCommandBilling.cs    ← Billing tracking
├── NeighborhoodCommandConfiguration.cs ← Per-user config
└── NeighborhoodCommandQueue.cs      ← Execution queue
```

## Service Architecture Pattern

### 1. Service Entry Point (NeighborhoodCommandService.cs)
```csharp
public ResponseServiceRun Run()
{
    using (var repo = new RepositoryNeighborhoodCommand(_config.GenieConnectionString))
    {
        var commands = repo.GetNeighborhoodCommands();
        if (commands.Any())
        {
            ProcessNeighborhoodCommand(commands);
        }
    }
}
```

**Pattern to Follow:**
- Windows Service that polls for work
- Repository pattern for data access
- Configuration-driven behavior

### 2. Handler Processing (NeighborhoodCommandHandler.cs)
```csharp
internal void Process(int neighborhoodCommandId)
{
    var command = _repo.GetNeighborhoodCommand(neighborhoodCommandId);
    
    foreach (var date in _targetDates)
    {
        Process(command, date);
    }
}

private void Process(Data.NC.SQL.Models.NeighborhoodCommand command, DateTime contextDate)
{
    var response = _api.GetTargetDate(command.AspNetUserId, command.NeighborhoodCommandId, contextDate);
    
    if (contextDate.Date != response.Key.Date)
        return; // not a match to run
    
    var workflows = GetWorkflowsToCommand(command.NeighborhoodCommandConfigurationId);
    
    if (workflows != null && workflows.Any())
    {
        var billingId = CreateBilling();
        
        foreach (var workflow in workflows)
        {
            QueueCommand(command, workflow, billingId, response.Key);
        }
    }
}
```

**Key Patterns:**
1. Check target dates (scheduling)
2. Create billing record BEFORE execution
3. Queue workflows for processing
4. Update command state after queueing

### 3. Billing Model (NeighborhoodCommandBilling.cs)
```csharp
public partial class NeighborhoodCommandBilling
{
    public int NeighborhoodCommandBillingId { get; set; }
    public int BillingTypeId { get; set; }
    public string PromoCode { get; set; }
    public int? WhmcsOrderId { get; set; }
    public long? CreditTransactionQueueId { get; set; }
    public int? ResponseCode { get; set; }
    public string ResponseDescription { get; set; }
    public DateTime CreateDate { get; set; }
    public DateTime? ProcessDate { get; set; }
}
```

**What to Reuse for CC:**
- Same billing fields (WhmcsOrderId, PromoCode, ResponseCode)
- Same pattern of creating billing record before processing

---

# INVESTIGATION 3: Listing Command Billing

## File Location
```
C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Core\BLL\ListingCommand\Billing\ListingCommandBillingHandler.cs
```

## Billing Handler Pattern (THE MODEL TO FOLLOW)

### Key Method: Process()
```csharp
public override ResponseWithKey Process(string aspNetUserId, int listingCommandQueueId, int workflowQueueId, RoleType role)
{
    // 1. Load the queue item
    var queue = Proxy.GetListingCommandQueue(listingCommandQueueId, aspNetUserId);
    
    // 2. Load billing record
    var billing = Proxy.GetListingCommandBilling(queue.ListingCommandBillingId.GetValueOrDefault());
    
    // 3. Don't reprocess successful payments
    if (billing.ResponseCode == (int)ResponseCodeReserved.Success)
    { 
        response.Key = billing.WhmcsOrderId.GetValueOrDefault();
        return response;
    }
    
    // 4. Get WHMCS Client ID
    var whmcsClientId = Proxy.GetUserWhmcs(queue.AspNetUserId)?.WhmcsClientId;
    
    // 5. Check for promo codes
    CheckForPromoCode(billing, role);
    
    // 6. Add the order to WHMCS
    var addOrderResponse = AddOrder(queue, billing, whmcsClientId, channels);
    
    // 7. Capture payment
    var capture = new CapturePaymentManager(whmcsClientId.Value, Config.ListingCommandWhmcsProductId);
    capture.ProcessNewOrder(whmcsOrderResponse);
    
    // 8. Handle failure - delete order
    if (!whmcsOrderResponse.Success)
    {
        var failCapture = new FailedPaymentCaptureManager();
        failCapture.DeleteOrder(whmcsOrderResponse, "LC Purchase");
        Notify(queue.AspNetUserId, $"Your Listing MLS#: {queue.MlsNumber}");
        return response;
    }
    
    // 9. Update billing record with success
    UpdateBilling(billing, response);
    
    return response;
}
```

### WHMCS Order Creation
```csharp
private AddOrder InitializeOrder(int? whmcsClientId, string promoCode, float amount, string description)
{
    return new AddOrder
    {
        ClientID = whmcsClientId.Value,
        ProductID = Config.ListingCommandWhmcsProductId,  // <-- NEED THIS FOR CC
        PromoCode = promoCode,
        PriceOverride = amount,
        BillingCycle = WHMCS.Net.Models.Enums.BillingCycleType.OneTime,
        SendInvoice = true,
        CustomFields = new System.Collections.Hashtable
        {
            { Config.WhmcsCustomFieldId.ToString(), description }
        }
    };
}
```

**Configuration Dependency:**
```csharp
Config.ListingCommandWhmcsProductId  // <-- WE NEED: Config.CompetitionCommandWhmcsProductId
Config.WhmcsCustomFieldId            // <-- WE NEED: CC-specific custom field
```

### Promo Code Handling
```csharp
private void CheckForPromoCode(ListingCommandBilling billing, RoleType role)
{
    if (!string.IsNullOrWhiteSpace(billing.PromoCode))
        return;
    
    if (Config.RoleDiscounts.TryGetValue((int)role, out var discountItem))
        billing.PromoCode = discountItem.PromoCode;
}
```

**What This Means for CC:**
- Can implement FOUNDER40, FOUNDER25, LAUNCH25 promo codes
- Role-based discounts already supported in pattern

---

# RECOMMENDED APPROACH FOR CC ENHANCEMENT

## New Files to Create

### 1. CompetitionCommandBillingHandler.cs
**Location:** `Smart.Core\BLL\CompetitionCommand\Billing\`
**Pattern:** Follow `ListingCommandBillingHandler.cs` exactly

### 2. AreaOwnershipService.cs
**Location:** `Smart.Service.CompetitionCommand\` (new service)
**Pattern:** Follow `NeighborhoodCommandService.cs`

### 3. Database Tables (from FR-001 DevSpec)
- `AreaOwnership` (replace UserOwnedArea)
- `AreaOwnershipHistory` (soft delete tracking)
- `AreaWaitlist` (FIFO queue)
- `AreaCampaignHistory` (campaign tracking)

## Config Needed from IT

| Config Item | Purpose | Status |
|-------------|---------|--------|
| `CompetitionCommandWhmcsProductId` | WHMCS Product ID for CC subscriptions | ⚠️ BLOCKER |
| `CCWhmcsCustomFieldId` | Custom field for area description | Pending |
| Promo codes in WHMCS | FOUNDER40, FOUNDER25, LAUNCH25 | Pending |

---

# NEXT STEPS

## Immediate Actions
1. ✅ Code investigation complete
2. ⏳ Request WHMCS Product ID from IT
3. Create database migration script
4. Create `CompetitionCommandBillingHandler.cs`

## Development Sequence
1. **Sprint 51-52:** Database schema + migration
2. **Sprint 52-53:** Billing handler + WHMCS integration
3. **Sprint 53-54:** Waitlist system
4. **Sprint 54-55:** Admin radar dashboard
5. **Sprint 55-56:** Agent portal updates

---

# CHANGE LOG

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 1.0 | 12/14/2025 | Cursor AI | Initial code investigation complete |

---

*Document: CODE_INVESTIGATION_CompetitionCommand_v1.md*
*Location: C:\Cursor\TheGenie.ai\Development\CompetitionCommand\Specs\*

