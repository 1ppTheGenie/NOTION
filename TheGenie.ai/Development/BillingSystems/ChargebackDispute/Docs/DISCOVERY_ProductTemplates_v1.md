# Discovery: Product-Specific Chargeback Templates

**Version:** 1.0  
**Created:** 12/27/2025  
**Last Updated:** 12/27/2025  
**Author:** Cursor Opus Agent  
**Status:** Discovery Phase

---

## Purpose

This document captures discovery questions and requirements for creating product-specific chargeback defense templates. Each product type requires different evidence and messaging to effectively defend against disputes.

---

## 1. Product Inventory

### 1.1 Current Products Requiring Templates

| Product | Billing Type | Chargeback Frequency | Template Status |
|---------|-------------|---------------------|-----------------|
| **Listing Command** | One-time Purchase | Common | ✅ COMPLETE (v7) |
| **Paisley Plus** | Subscription | Common | 🔴 NEEDS TEMPLATE |
| **Neighborhood Command** | Subscription | Rare | 🟡 NEEDS TEMPLATE |
| **Competition Command** | Subscription | Rare | 🟡 NEEDS TEMPLATE |
| **Title Genie** | Per-use/Subscription | Unknown | 🟡 NEEDS TEMPLATE |

---

## 2. Discovery Questions by Product

### 2.1 Paisley Plus

**Product Understanding:**
- [ ] What is included in Paisley Plus subscription?
- [ ] What is the monthly/annual cost?
- [ ] What features are tracked for usage?
- [ ] How is subscription cancellation handled?

**Database Discovery:**
- [ ] What table stores Paisley Plus subscriptions?
- [ ] What table tracks Paisley Plus usage/activity?
- [ ] How are Paisley Plus logins differentiated?
- [ ] What content generation logs exist?

**Evidence Collection:**
- [ ] What proves the customer used the service?
- [ ] Are there AI generation logs per user?
- [ ] Are there content downloads tracked?
- [ ] Are there template usage metrics?

**SQL Queries Needed:**
```sql
-- Find Paisley Plus related tables
SELECT TABLE_NAME, COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME LIKE '%Paisley%' OR COLUMN_NAME LIKE '%Paisley%';

-- Find subscription tables
SELECT TABLE_NAME, COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME LIKE '%Subscription%' OR COLUMN_NAME LIKE '%Subscription%';
```

---

### 2.2 Neighborhood Command

**Product Understanding:**
- [ ] What is included in Neighborhood Command?
- [ ] What is the monthly/annual cost?
- [ ] What data/reports are provided?
- [ ] How is cancellation handled?

**Database Discovery:**
- [ ] What table stores Neighborhood Command subscriptions?
- [ ] What table tracks report generation?
- [ ] What table tracks data access?
- [ ] Are there alert/notification logs?

**Evidence Collection:**
- [ ] What proves the customer accessed neighborhood data?
- [ ] Are there report generation timestamps?
- [ ] Are there email alerts sent?
- [ ] What API calls are logged?

---

### 2.3 Competition Command

**Product Understanding:**
- [ ] What is included in Competition Command?
- [ ] What is the monthly/annual cost?
- [ ] What agent tracking features exist?
- [ ] How is cancellation handled?

**Database Discovery:**
- [ ] What table stores Competition Command subscriptions?
- [ ] What table tracks agent monitoring setup?
- [ ] What table tracks alerts sent to user?
- [ ] Are there watchlist/agent tracking logs?

**Evidence Collection:**
- [ ] What proves the customer set up tracking?
- [ ] What proves alerts were sent?
- [ ] What proves dashboard access?
- [ ] Are there competitor report downloads?

---

## 3. Common Subscription Discovery

### 3.1 Billing Cycle Questions

- [ ] What billing cycles exist (monthly, quarterly, annual)?
- [ ] How are renewals processed in WHMCS?
- [ ] What table tracks renewal history?
- [ ] What emails are sent before renewal?
- [ ] Is there a renewal reminder period?

### 3.2 Cancellation Policy Questions

- [ ] What is the standard cancellation policy?
- [ ] Can users cancel mid-cycle?
- [ ] Are prorated refunds offered?
- [ ] What is the cancellation process?
- [ ] Is cancellation logged in the system?

### 3.3 Terms of Service Differences

- [ ] Do subscription products have different ToS?
- [ ] Is there a recurring billing consent checkbox?
- [ ] Are there different refund policies per product?
- [ ] How is the ToS acceptance stored per product?

---

## 4. Template Differences Matrix

| Element | Listing Command | Paisley Plus | Neighborhood | Competition |
|---------|----------------|--------------|--------------|-------------|
| **Billing Type** | One-time | Recurring | Recurring | Recurring |
| **Primary Evidence** | Campaign delivery | Content generation | Data access | Agent tracking |
| **Secondary Evidence** | Leads generated | Login frequency | Reports viewed | Alerts received |
| **Cancellation Mention** | N/A | Required | Required | Required |
| **Renewal Consent** | N/A | Required | Required | Required |
| **Usage Metrics** | SMS count, leads | AI generations | Reports, queries | Agents tracked |
| **Delivery Proof** | SMS logs, landing page | Content files | PDF reports | Alert emails |

---

## 5. Template Messaging Differences

### 5.1 Listing Command (One-Time)

**Key Messages:**
- "This was a one-time, non-recurring purchase"
- "Service was fully delivered within X minutes"
- "X SMS messages were sent, Y leads were generated"
- "Customer search parameters resulted in this campaign"

### 5.2 Subscription Products

**Key Messages (Common):**
- "This is an authorized recurring subscription"
- "Customer explicitly agreed to recurring billing"
- "Customer has been billed successfully X times prior"
- "Service has been accessible since subscription start"
- "Customer did not request cancellation before this dispute"
- "Cancellation is available through [method]"

**Paisley Plus Specific:**
- "Customer generated X pieces of content using the service"
- "Customer logged in X times during the billing period"
- "AI-powered features were accessed on [dates]"

**Neighborhood Command Specific:**
- "Customer accessed neighborhood data X times"
- "X market reports were generated"
- "Customer received X data update alerts"

**Competition Command Specific:**
- "Customer is tracking X agents in their market"
- "X competitive alerts were sent during billing period"
- "Dashboard was accessed X times"

---

## 6. Evidence Collection Queries (To Be Developed)

### 6.1 Generic Subscription Evidence Query

```sql
-- Template for subscription usage evidence
-- Replace {ProductTable} and {UsageTable} with actual table names

SELECT 
    s.SubscriptionId,
    s.StartDate,
    s.LastRenewalDate,
    COUNT(u.UsageId) as UsageCount,
    MAX(u.UsageDate) as LastUsageDate
FROM {ProductTable}_Subscription s
LEFT JOIN {ProductTable}_Usage u ON s.SubscriptionId = u.SubscriptionId
WHERE s.AspNetUserId = @UserId
GROUP BY s.SubscriptionId, s.StartDate, s.LastRenewalDate;
```

### 6.2 Renewal History Query

```sql
-- Get all successful renewals for a subscription
-- Requires WHMCS database access

SELECT 
    t.TransactionId,
    t.Amount,
    t.TransactionDate,
    t.Gateway,
    t.TransactionId as PaymentReference
FROM WhmcsTransactions t
WHERE t.ClientId = @ClientId
AND t.Description LIKE '%renewal%'
ORDER BY t.TransactionDate DESC;
```

---

## 7. Next Steps

### Immediate Actions
1. [ ] Run database discovery queries to find product-specific tables
2. [ ] Document table schemas for each product
3. [ ] Identify unique evidence types per product
4. [ ] Create evidence collection scripts per product

### Template Development Order
1. **Paisley Plus** - High priority (most chargebacks after Listing Command)
2. **Neighborhood Command** - Medium priority
3. **Competition Command** - Lower priority
4. **Title Genie** - As needed

### Resources Needed
- [ ] Access to product documentation
- [ ] Sample chargebacks for each product type
- [ ] Product manager input on usage metrics
- [ ] Legal review of subscription-specific messaging

---

## 8. Questions for Product Team

1. Which products have the highest chargeback rate?
2. What are the most common dispute reasons per product?
3. Are there any product-specific cancellation challenges?
4. What usage data is most compelling for each product?
5. Are there product-specific Terms of Service documents?

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/27/2025 | Cursor Opus | Initial discovery document |

---

*This document is part of the Chargeback Defense System project within TheGenie.ai Development ecosystem.*

