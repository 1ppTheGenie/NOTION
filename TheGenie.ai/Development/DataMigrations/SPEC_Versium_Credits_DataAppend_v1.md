# Versium Credits & Data Append System
## Technical Specification
### Version 1.0 | Date: 12/14/2025

---

## Document Purpose

This specification documents the Versium data append credit system used by TheGenie for Competition Command and other products, including credit consumption per API call, package configurations, and cost tracking.

---

## 1. Overview

### 1.1 What is Versium?

Versium is a third-party data append provider that enriches property records with:
- **Contact Information** (Email, Phone)
- **Demographics** (Age, Income, etc.)
- **Financial Data** (Mortgage, Home Value, etc.)

### 1.2 How TheGenie Uses Versium

When Competition Command sends SMS campaigns, the system:
1. Loads properties from the target area
2. Appends contact data via Versium APIs
3. Caches results to avoid duplicate charges
4. Sends SMS to matched phone numbers

---

## 2. Data Append Packages

### 2.1 Available Packages

| PackageId | Package Name | Description | Enabled |
|-----------|--------------|-------------|---------|
| 1 | Standard Package | Basic append | Yes |
| 2 | Discount Standard | Reduced cost standard | Yes |
| 3 | **Booster** | Full data suite (CC uses this) | Yes |
| 4 | Discount Booster | Reduced cost booster | Yes |

### 2.2 Competition Command Package

**Competition Command uses Package ID 3 (Booster)**

---

## 3. Credit Consumption

### 3.1 Credits Per Property (Booster Package)

| Data Type | Credits | Versium API |
|-----------|---------|-------------|
| **Email** | 7 | VersiumEmail |
| **Phone** | 7 | VersiumPhone |
| **Demographics** | 4 | VersiumDemographics |
| **Financial** | 4 | VersiumFinancial |
| **TOTAL** | **22** | 4 API calls |

### 3.2 Package Comparison

| Package | Email | Phone | Demo | Financial | **Total/Property** |
|---------|-------|-------|------|-----------|-------------------|
| Standard | 7 | 7 | 0 | 0 | **14** |
| Discount Standard | 5 | 5 | 0 | 0 | **10** |
| **Booster** | **7** | **7** | **4** | **4** | **22** |
| Discount Booster | 5 | 5 | 3 | 3 | **16** |

### 3.3 Role-Based Overrides

Certain roles may have discounted credit costs:

| Role | Package | Email | Phone | Demo | Financial | Total |
|------|---------|-------|-------|------|-----------|-------|
| RoleId 5 | Booster | 1 | 3 | 2 | 2 | **8** |

---

## 4. November 2025 Usage Analysis

### 4.1 Versium API Calls

| API Type | Action ID | API Calls | Matches | Match Rate |
|----------|-----------|-----------|---------|------------|
| VersiumEmail | 9 | 45,515 | 30,601 | 67.2% |
| VersiumDemographics | 11 | 36,159 | 28,570 | 79.0% |
| VersiumFinancial | 12 | 35,755 | 29,291 | 81.9% |
| **TOTAL** | - | **117,429** | **88,462** | **75.3%** |

### 4.2 Properties Processed

| Metric | Value |
|--------|-------|
| Total Collections | 344 |
| Total Properties | 28,362 |
| Collection Type | TargetProperty (CC Campaigns) |

### 4.3 Cache Records Created

| Metric | Value |
|--------|-------|
| New cache entries (Nov 2025) | 10,849 |
| Cache prevents re-charges for same property+owner |

---

## 5. Credit Tracking Tables

### 5.1 DataAppendLog

Tracks every Versium API call.

| Column | Description |
|--------|-------------|
| DataAppendLogId | Primary key |
| AspNetUserId | User who initiated |
| DataAppendProviderId | 3 = Versium |
| DataAppendActionTypeId | Type of API call |
| CreateDate | When call was made |

### 5.2 DataAppendAudit

Tracks billing/success for each call.

| Column | Description |
|--------|-------------|
| DataAppendAuditId | Primary key |
| DataAppendLogId | Links to log |
| HasTargetData | 1 = Match found (billable) |

### 5.3 DataAppendPackage

Defines credit costs per package.

```sql
SELECT 
    DataAppendPackageId,
    PackageName,
    EmailCreditCost,
    PhoneCreditCost,
    DemographicCreditCost,
    FinancialCreditCost
FROM DataAppendPackage;
```

### 5.4 Credit Balance

| Column | Description |
|--------|-------------|
| CreditId | Primary key |
| AspNetUserId | User's credit account |
| OrganizationId | Org's credit account |
| CreditBalance | Current balance |
| CanOverDraft | Allow negative balance |

---

## 6. API Configuration

### 6.1 Versium API Credentials

**Source:** `Smart.DataAppend.Core/BLL/Actions/Versium/ActionVersiumBase.cs`

| Setting | Value |
|---------|-------|
| API Key | `a3c3f048-da5a-45a2-a384-699172964481` |
| Base URL | `https://api.versium.com/v2/` |

### 6.2 API Endpoints Used

| Endpoint | Purpose |
|----------|---------|
| `/contact` | Email and Phone lookup |
| `/demographic` | Demographic data |
| `/financial` | Financial data |

---

## 7. Caching System

### 7.1 Cache Mechanism

- **Table:** `DataAppendContactLookup`
- **Key Format:** `::PID-{PropertyId}::L-{LastName}::F-{FirstName}`
- **TTL:** Indefinite (configurable via LookbackDays)

### 7.2 Cache Hit Logic

```csharp
// From ActionCacheCheck.cs
private void LoadCacheProperty(DataAppendInput input)
{
    var lookupKey = Utility.GetLookupCacheKeyReadable(
        input.PropertyId, 
        input.FirstName, 
        input.LastName);
    
    LoadCache(lookupKey);
}
```

### 7.3 When Cache is Bypassed

Cache lookup is skipped when:
1. PropertyID changes (ownership change detected)
2. Owner name changes (new owner)
3. Cache entry older than LookbackDays (if configured)

---

## 8. Cost Estimation

### 8.1 Per Campaign Cost

For a typical CC campaign with 100 properties:

| Metric | Value |
|--------|-------|
| Properties | 100 |
| Match Rate | ~75% |
| Matched Properties | 75 |
| Credits per match | 22 |
| **Total Credits** | **1,650** |

### 8.2 Monthly Cost (November 2025 Example)

| Metric | Value |
|--------|-------|
| Total API Calls | 117,429 |
| Successful Matches | 88,462 |
| Credits Consumed | ~1.9M |

---

## 9. Versium Portal Access

### 9.1 REACH Portal

- **URL:** https://app.versium.com/login
- **Purpose:** View credit balance, usage statistics, invoices

### 9.2 Credit Balance

Note: Versium API does not expose credit balance. Must check via portal.

---

## 10. Related Documents

| Document | Location |
|----------|----------|
| Cache Architecture Audit | `docs/AUDIT_VersiumCache_Architecture_v1.md` |
| Cache Migration SOP | `docs/SOP_VersiumCache_Migration_v1.md` |
| SQL Migration Script | `SQL/usp_MigrateVersiumCache_DataTreeToAttom_v1.sql` |

---

## 11. Source Code References

| File | Purpose |
|------|---------|
| `Smart.DataAppend.Core/BLL/Actions/Versium/ActionVersiumBase.cs` | API base class |
| `Smart.DataAppend.Core/BLL/Actions/ActionCacheCheck.cs` | Cache lookup |
| `Smart.DataAppend.Core/BLL/Utility.cs` | Key generation |
| `Smart.CastWorkflow.Model/DataAppend/EnumDataAppendPackage.cs` | Package enums |

---

## Appendix A: Action Types

| ActionTypeId | Name | Description |
|--------------|------|-------------|
| 9 | VersiumEmail | Email + Phone lookup |
| 11 | VersiumDemographics | Demographic data |
| 12 | VersiumFinancial | Financial data |

---

*Document Version: 1.0 | Created: 12/14/2025*

