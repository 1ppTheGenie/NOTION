# Engagement Enrichment: Data Sources Mapping
## Version 1.0 | Created: 12/15/2025 | Last Updated: 12/15/2025
## Author: AI Assistant + RC

---

## Executive Summary

| Section | Details |
|---------|---------|
| **Purpose** | Map all available data sources for enriching lead engagements beyond basic contact info |
| **Current State** | 80% - All data sources identified and mapped |
| **Key Outputs** | Field mappings for Attom, Versium, and internal sources |
| **Remaining Work** | Integration implementation, scoring algorithm design |
| **Last Validated** | 12/15/2025 - Database table structures confirmed |

---

## 1. DATA SOURCE OVERVIEW

| Source | Type | Records | Status | Priority |
|--------|------|---------|--------|----------|
| **Attom Pre-Foreclosure** | External - Files | 590,834 | ✅ LOADED | CRITICAL |
| **Attom Recorder** | External - Files | 11,273,914 | ✅ LOADED | HIGH |
| **Attom Tax Assessor** | External - Files | Millions | ✅ LOADED | HIGH |
| **Versium Contact Append** | External - API | On-demand | ✅ ACTIVE | HIGH |
| **Versium Demographic** | External - API | On-demand | ⚠️ PARTIAL | HIGH |
| **Internal CTA Tracking** | Internal DB | ~20,000+ | ✅ LOADED | HIGH |
| **Internal Visit Tracking** | Internal DB | Millions | ✅ LOADED | MEDIUM |

---

## 2. ATTOM PRE-FORECLOSURE DATA

**Database Table:** `TitleData.dbo.AttomDataPreForeclosure`
**Records:** 590,834
**Date Range:** 1999 - June 2025
**Primary States:** CA (466K), TX (124K)

### Key Fields for Engagement Enrichment

| Field | Description | Enrichment Signal |
|-------|-------------|-------------------|
| `RecordType` | Type of default (NOD, Lis Pendens) | 🔴 DISTRESS - High motivation |
| `ForeclosureRecordingDate` | When default was recorded | Recency = urgency |
| `DefaultAmount` | Amount in arrears | Severity of distress |
| `LoanBalance` | Remaining loan balance | Equity calculation |
| `OriginalLoanAmount` | Original loan amount | Equity calculation |
| `LoanMaturityDate` | When loan matures | ARM reset risk |
| `AuctionDate` | Scheduled foreclosure auction | ⏰ DEADLINE - Highest urgency |
| `EstimatedValue` | Attom AVM | Equity = Value - LoanBalance |
| `BorrowerNameOwner` | Name on default | Match to lead |
| `LenderNameFullStandardized` | Which bank | Loss mitigation contact |

### Join Strategy
```sql
-- Match leads to pre-foreclosure records
SELECT gl.*, pf.*
FROM FarmGenie.dbo.GenieLead gl
JOIN TitleData.dbo.AttomDataPreForeclosure pf
  ON gl.SitusZip = pf.PropertyAddressZIP
 AND SOUNDEX(gl.LastName) = SOUNDEX(LEFT(pf.BorrowerNameOwner, CHARINDEX(' ', pf.BorrowerNameOwner + ' ')))
```

---

## 3. ATTOM RECORDER DATA (Mortgages/Deeds)

**Database Table:** `TitleData.dbo.AttomDataRecorder`
**Records:** 11,273,914

### Key Fields for Engagement Enrichment

| Field | Description | Enrichment Signal |
|-------|-------------|-------------------|
| `RecordingDate` | When deed/mortgage recorded | Ownership tenure |
| `TransferAmount` | Sale price | Purchase basis |
| `Mortgage1Amount` | First mortgage amount | Current loan |
| `Mortgage1InterestRate` | Interest rate | Refi candidate? |
| `Mortgage1Term` | Loan term (years) | ARM vs Fixed |
| `Mortgage1TermDate` | Loan maturity date | ARM reset risk |
| `Mortgage2Amount` | Second mortgage/HELOC | Total debt |
| `TransferInfoPurchaseLoanToValue` | Original LTV | Equity indicator |
| `TransferInfoPurchaseDownPayment` | Down payment | Equity indicator |
| `Mortgage1LenderNameFullStandardized` | Lender name | Refinance pattern |
| `ForeclosureAuctionSale` | Was REO sale? | Distress history |
| `TransferInfoDistressCircumstanceCode` | Distress type code | Financial stress |

### Calculated Fields

| Calculated Field | Formula | Signal |
|------------------|---------|--------|
| **Estimated Equity** | AVM - Mortgage1Amount - Mortgage2Amount | Motivation to sell |
| **LTV** | (Mortgage1Amount + Mortgage2Amount) / AVM | Underwater = stuck |
| **Years Since Refi** | DATEDIFF(year, Mortgage1RecordingDate, GETDATE()) | Stale loan = refi candidate |
| **ARM Reset Risk** | Mortgage1TermDate < DATEADD(year, 1, GETDATE()) | Rate shock coming |

---

## 4. VERSIUM DATA (API)

**Database Table:** `FarmGenie.dbo.DataAppendContactLookup`
**Records:** ~17.7 million cached lookups
**API Key:** GenieVersiumApiKey (ID: 220)

### Currently Retrieved Fields

| Field | Description | Enrichment Signal |
|-------|-------------|-------------------|
| `PhoneList` | Verified phone numbers | Contact info |
| `MobilePhoneList` | Mobile phones | SMS-able |
| `EmailList` | Email addresses | Email marketing |
| `FirstName` / `LastName` | Verified name | Name matching |
| `Address` / `City` / `State` / `Zip` | Verified address | Address verification |

### Demographic Fields (Available but Underutilized)

| Field | Description | Enrichment Signal |
|-------|-------------|-------------------|
| `EstimatedHouseholdIncome` | Income range ($100K-149K, etc.) | Affluence |
| `LengthOfResidence` | How long at address (11-15 years) | 🏠 EMPTY NESTER potential |
| `HomePurchaseDate` | When they bought (198307 = July 1983) | Long-term owner |
| `HomePurchasePrice` | What they paid | Equity = Now - Then |
| `HomeValue` | Estimated current value | AVM verification |
| `EstWealth` | Estimated net worth | Affluence tier |
| `Gender` | M/F/Unknown | Personalization |
| `EstimatedAge` | Age range | Life stage |
| `CreditRating` | Credit tier | Qualification |
| `Hispanic` | Hispanic indicator | Marketing compliance |
| `Language` | Preferred language | Personalization |

### Versium API Endpoints Available (from portal screenshot)

| API | What It Does | Cost | Priority |
|-----|--------------|------|----------|
| **Contact Append** | Phone + Email from name/address | Credits | ✅ ACTIVE |
| **Demographic Append** | Income, age, wealth, homeowner | Credits | ⚠️ USE MORE |
| **B2C Online Audience Append** | Social/digital presence | Credits | LOW |
| **Data Prep** | Clean/standardize data | Credits | LOW |

---

## 5. INTERNAL DATA SOURCES

### 5.1 CTA Engagement Tracking

**Tables:** `CtaDetail`, `CtaGroupDetail`, `GenieLeadTag`

| Field | Description | Enrichment Signal |
|-------|-------------|-------------------|
| `GenieLeadTagTypeId = 48` | CTA Submitted | Active intent |
| `GenieLeadTagTypeId = 51` | Opted Out | Cold lead |
| `GenieLeadTagTypeId = 52` | CTA Verified | Hot lead |
| `CreateDate` | When engaged | Recency |

### 5.2 Return Visitor Tracking

**Tables:** `ShortUrlData`, `ShortUrlDataLead`

| Field | Description | Enrichment Signal |
|-------|-------------|-------------------|
| Visit count | Multiple returns | High interest |
| `IPAddress` | Device fingerprint | Same person? |
| Time gaps | Days between visits | Nurture stage |

### 5.3 MLS Transaction History

**Database:** `MlsListing`

| Field | Description | Enrichment Signal |
|-------|-------------|-------------------|
| Past listings | Was property listed before? | Expired/withdrawn |
| Days on market | How long listed | Motivated? |
| Price changes | Reductions | Desperation |
| Listing agent | Who listed before | Competition |

---

## 6. ENGAGEMENT SCORING MODEL (Proposed)

### Tier 1: Distress Signals (Highest Weight)

| Signal | Points | Source |
|--------|--------|--------|
| Active Pre-Foreclosure (NOD) | +100 | Attom Pre-Foreclosure |
| Auction scheduled < 30 days | +150 | Attom Pre-Foreclosure |
| Underwater (LTV > 100%) | +50 | Attom Recorder |
| Recent lis pendens | +80 | Attom Pre-Foreclosure |

### Tier 2: Life Event Signals

| Signal | Points | Source |
|--------|--------|--------|
| Long tenure (15+ years) | +40 | Versium |
| High equity (AVM - Loan > $200K) | +30 | Calculated |
| Empty nester age (55-70) | +25 | Versium |
| Recent permit (improvements) | +20 | Future: Attom |

### Tier 3: Engagement Signals

| Signal | Points | Source |
|--------|--------|--------|
| CTA Verified | +60 | GenieLeadTag |
| CTA Submitted | +30 | GenieLeadTag |
| Multiple visits (3+) | +20 | ShortUrlDataLead |
| Recent visit (< 7 days) | +15 | ShortUrlDataLead |

### Tier 4: Contact Quality

| Signal | Points | Source |
|--------|--------|--------|
| Mobile phone confirmed | +10 | Versium |
| Email confirmed | +5 | Versium |
| Name match to title | +15 | Calculated |

---

## 7. IMPLEMENTATION ROADMAP

### Phase 1: Quick Wins (1-2 weeks)
- [ ] Query Pre-Foreclosure data for leads in existing campaigns
- [ ] Create stored procedure to join leads to foreclosure records
- [ ] Add foreclosure flag to lead display

### Phase 2: Versium Enhancement (2-3 weeks)
- [ ] Start calling Demographic Append API for new leads
- [ ] Parse existing JSON responses to extract demographic fields
- [ ] Create demographic summary view

### Phase 3: Scoring Engine (3-4 weeks)
- [ ] Build scoring stored procedure
- [ ] Create daily scoring job
- [ ] Add score to agent notifications

### Phase 4: Dashboard (4-6 weeks)
- [ ] Build enrichment dashboard in UI
- [ ] Visualize lead scores
- [ ] Agent priority queue based on score

---

## 8. CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/15/2025 | AI + RC | Initial creation - all data sources mapped |

---

## 9. APPENDIX: SQL Examples

### A. Find Leads in Pre-Foreclosure

```sql
SELECT 
    gl.GenieLeadId,
    gl.FirstName,
    gl.LastName,
    gl.SitusCity,
    gl.SitusState,
    gl.SitusZip,
    pf.RecordType,
    pf.ForeclosureRecordingDate,
    pf.DefaultAmount,
    pf.LoanBalance,
    pf.AuctionDate,
    pf.EstimatedValue
FROM FarmGenie.dbo.GenieLead gl
JOIN TitleData.dbo.AttomDataPreForeclosure pf
    ON gl.SitusZip = pf.PropertyAddressZIP
   AND gl.SitusCity = pf.PropertyAddressCity
WHERE pf.AuctionDate > GETDATE()  -- Upcoming auctions
ORDER BY pf.AuctionDate ASC;
```

### B. Parse Versium Demographics from Cached Response

```sql
SELECT 
    LookupKeyReadable,
    JSON_VALUE(Response, '$.EstimatedHouseholdIncome') as Income,
    JSON_VALUE(Response, '$.LengthOfResidence') as YearsAtAddress,
    JSON_VALUE(Response, '$.HomeValue') as HomeValue,
    JSON_VALUE(Response, '$.EstWealth') as Wealth,
    JSON_VALUE(Response, '$.HomePurchaseDate') as PurchaseDate
FROM FarmGenie.dbo.DataAppendContactLookup
WHERE Response LIKE '%EstimatedHouseholdIncome%'
  AND CreateDate > DATEADD(day, -30, GETDATE());
```

### C. Calculate Equity from Recorder Data

```sql
SELECT 
    PropertyAddressFull,
    TransferAmount as PurchasePrice,
    Mortgage1Amount as CurrentLoan,
    Mortgage2Amount as SecondLoan,
    -- Estimated equity (need to join with AVM for current value)
    (SELECT TOP 1 CurrAVMValue 
     FROM TitleData.dbo.ViewAssessor_v3 a 
     WHERE a.AttomId = r.AttomId) - Mortgage1Amount - ISNULL(Mortgage2Amount, 0) as EstEquity
FROM TitleData.dbo.AttomDataRecorder r
WHERE RecordingDate > '2020-01-01';
```

---

*This document is part of the TheGenie.ai Nurture Engine project.*

