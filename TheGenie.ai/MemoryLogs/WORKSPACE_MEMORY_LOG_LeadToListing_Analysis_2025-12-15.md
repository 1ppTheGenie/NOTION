# Workspace Memory Log: Lead-to-Listing Analysis

## Executive Summary
| Item | Details |
|------|---------|
| **Purpose** | Analyze lead generation to listing conversion, identify transition/handoff gaps, and quantify lost revenue |
| **Current State** | Analysis COMPLETE - Critical findings documented, 0.26% win rate in recent months confirmed |
| **Key Outputs** | Deduplicated reports, engagement enrichment framework, decision framework |
| **Remaining Work** | Interview top converters, build lead scorecard, implement engagement enrichment |
| **Last Validated** | 12/15/2025 |

---

## 1. Session Overview

**Date:** December 15, 2025
**Focus:** Lead-to-Listing conversion analysis using production data

### Key Questions Answered
1. How many leads become listings? **7.1% of CC leads**
2. How many listings do OUR agents get? **1% win rate**
3. What's the trend? **Declining (11.7% in 2021 → 0.26% in Dec 2025)**
4. What's the revenue impact? **$29.75M+ in lost referral fees**

---

## 2. Data Sources Used

| Source | Table/View | Purpose |
|--------|------------|---------|
| Leads | FarmGenie.dbo.GenieLead | Lead records |
| Lead Types | FarmGenie.dbo.GenieLeadType | Source classification |
| Property Match | FarmGenie.dbo.LeadPropertyMatch | Lead-to-property link |
| Assessor Data | TitleData.dbo.ViewAssessor_v3 | Property details, ownership |
| MLS Listings | MlsListing.dbo.Listing | Listing outcomes |
| MLS Assessor Link | MlsListing.dbo.ListingAssessor | Property-to-MLS link |
| CTA Engagement | FarmGenie.dbo.GenieLeadTag | Engagement depth tracking |
| Tag Types | FarmGenie.dbo.GenieLeadTagType | Tag definitions |
| User Profiles | FarmGenie.dbo.AspNetUserProfiles | Agent information |

---

## 3. Key Findings

### 3.1 Competition Command Funnel (Unique People by Phone)

| Stage | Unique People | % |
|-------|--------------|---|
| CC Leads Generated | 39,700 | 100% |
| Matched to Property | 39,691 | 99.98% |
| Property Listed (7+ days later) | 2,817 | 7.1% |
| Our Agent Won | 28 | **1.0%** |
| Still Incubating | 36,874 | 92.9% |

### 3.2 Incubating Leads by Freshness

| Lead Age | Unique People | Actionable? |
|----------|--------------|-------------|
| Hot (0-30 days) | 434 | **YES - Call Now** |
| Warm (31-90 days) | 678 | **YES - Re-engage** |
| Cool (91-180 days) | 2,033 | Maybe - Nurture |
| Cold (6-12 months) | 10,637 | Long-term |
| Stale (1-2 years) | 18,470 | Low priority |
| Dead (2+ years) | 7,399 | Archive |

### 3.3 November/December 2025 Reality

| Metric | Value |
|--------|-------|
| Total Listings from Our Leads | 380 |
| Won by Our Agents | **1** |
| Lost to Other Agents | 379 |
| Win Rate | **0.26%** |
| Value Lost | $530 Million |

### 3.4 The ONE Recent Win (Jason Barry)

| Field | Value |
|-------|-------|
| Property | 6686 Camino Saucito, Rancho Santa Fe |
| Price | $3,995,000 |
| Lead Created | 10/10/2024 |
| Listed | 11/19/2025 |
| Days Nurture | 405 days |
| Lead Name | Allison Ecker |
| Owner on Title | James Cannon Huber (DIFFERENT) |
| CTA Engagement | Stealth + CTA Display only |

---

## 4. Engagement Enrichment Framework

### Concept: Beyond Data Enrichment
Traditional data enrichment = contact info, demographics
**Engagement Enrichment** = full picture of individual situation:
- Property data (tenure, equity, improvements)
- Behavioral data (clicks, returns, CTA depth)
- Life events (mortgage, liens, defaults, permits)
- MLS history (previous listings, price changes)

### Available Data Points (EASY)

| Signal | Source | Ready? |
|--------|--------|--------|
| Years Owned | ViewAssessor_v3.CurrSaleRecordingDate | ✅ |
| Owner vs Clicker Name | Lead + Title comparison | ✅ |
| Owner Occupied | ViewAssessor_v3.OwnerOccupied | ✅ |
| Purchase Price | ViewAssessor_v3.CurrSalesPrice | ✅ |
| Current Value | ViewAssessor_v3.MarketTotalValue | ⚠️ Partial |
| CTA Engagement Depth | GenieLeadTag | ✅ |
| Return Visits | Count by Phone | ✅ |
| MLS History | ListingAssessor | ✅ |

### Future Data Points (HARD)

| Signal | Source | Status |
|--------|--------|--------|
| Real-time AVM | Attom AVM API | Not integrated |
| Mortgage Balance | Title/Lien feed | Not available |
| Notice of Default | Title feed | Not available |
| Permit Data | County records | Not integrated |
| Demographics | Versium (parse JSON) | Available but complex |

---

## 5. Key Patterns Discovered

### 5.1 Stealth Leads Win
- 80% of recent wins were "Stealth Leads"
- They clicked but did NOT complete CTA
- The wins came from awareness, not engagement

### 5.2 Name Mismatch Pattern
- 70% of wins: Lead Name ≠ Owner on Title
- Someone OTHER than the owner is clicking
- Could be spouse, family, friend, tenant

### 5.3 Return Visitors
- 1,651 people engaged 2+ times
- These are warmer leads
- Mike Blair's win had 1 return visit

### 5.4 Hyperlocal Domination
- Top converters focus on ONE city
- Rachael Hughel: 91% in Oceanside
- David Higgins: 34% in Oakland
- Spread thin = low conversion

---

## 6. Reports Generated

### Location: C:\Cursor\TheGenie.ai\Development\NurtureEngine\Discovery\

| File | Description |
|------|-------------|
| LEAD_TO_LISTING_EXECUTIVE_SUMMARY_v2_2025-12-15.md | Complete summary |
| Lead_To_Listing_DEDUPLICATED_2025-12-15.csv | 6,482 unique listings |
| Lead_To_Listing_ByYear_2025-12-15.csv | Year-over-year trends |
| CTA_Analysis_2024_2025_2025-12-15.csv | CTA effectiveness |
| TopConverters_ByYear_2025-12-15.csv | Top agent analysis |

### GitHub: https://github.com/1ppTheGenie/NOTION/tree/main/TheGenie.ai/Development/NurtureEngine/Discovery

---

## 7. SQL Query Reference

### Core Lead-to-Listing Query (Deduplicated)

```sql
;WITH RankedListings AS (
    SELECT 
        la.MlsNumber,
        l.ListDate,
        gl.GenieLeadId,
        gl.CreateDate as LeadCreated,
        CONCAT(anup.FirstName, ' ', anup.LastName) as GenieAgent,
        l.ListingAgentName,
        l.PriceLow,
        ROW_NUMBER() OVER (PARTITION BY la.MlsNumber ORDER BY gl.CreateDate) as RowNum
    FROM FarmGenie.dbo.LeadPropertyMatch lpm
    JOIN FarmGenie.dbo.GenieLead gl ON gl.GenieLeadId = lpm.GenieLeadId
    JOIN TitleData.dbo.ViewAssessor_v3 ad ON ad.PropertyID = lpm.PropertyId
    JOIN MlsListing.dbo.ListingAssessor la ON la.FIPS = ad.FIPS AND la.FormattedAPN = ad.FormattedAPN
    JOIN MlsListing.dbo.Listing l ON l.MlsID = la.MlsID AND l.MlsNumber = la.MlsNumber
    JOIN FarmGenie.dbo.AspNetUserProfiles anup ON anup.AspNetUserId = gl.AspNetUserId
    WHERE gl.CreateDate < l.ListDate
    AND DATEDIFF(day, gl.CreateDate, l.ListDate) >= 7
)
SELECT * FROM RankedListings WHERE RowNum = 1
```

---

## 8. Decision Framework

### Immediate Actions (This Week)
1. **Interview Jason Barry** - How did he win the Rancho Santa Fe listing?
2. **Prioritize 1,112 Hot/Warm Leads** - Last 90 days, no listing yet
3. **Build Lead Scorecard** - Combine tenure + name match + CTA depth + returns

### Short-Term (This Month)
1. **Engagement Enrichment Report** - Add property data to lead exports
2. **Return Visitor Alert** - Flag multi-touch leads for priority follow-up
3. **Long-Tenure Alert** - Flag properties owned 15+ years

### Medium-Term (Q1 2026)
1. **Integrate AVM Data** - Real-time equity calculations
2. **Permit Data Feed** - Improvement signals
3. **Nurture Engine Build** - Automated follow-up sequences

---

## 9. Open Questions

1. **How did Jason Barry win?** - Need to interview
2. **Why are stealth leads winning?** - Awareness without commitment?
3. **What's the ideal nurture cadence?** - Need A/B testing
4. **Should we change CTAs?** - Soft touch vs. aggressive

---

## 10. Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/15/2025 | Initial analysis, deduplicated reports, engagement enrichment framework |

---

*Session saved for future reference.*

