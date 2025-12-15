# Lead-to-Listing Reports Package

## Executive Summary
| Item | Details |
|------|---------|
| **Purpose** | Track conversion of TheGenie leads to MLS listings, measure agent win rates, identify revenue leakage |
| **Current State** | APPROVED - Ready for production use |
| **Key Outputs** | Deduplicated listing reports, year-over-year trends, agent performance, engagement analysis |
| **Last Validated** | 12/15/2025 |

---

## Overview

This package provides SQL queries and SOPs for generating Lead-to-Listing conversion reports. These reports answer:

1. **How many leads become listings?** (~7% of matched leads)
2. **How many listings does OUR agent get?** (~1% win rate)
3. **What's the trend?** (Declining from 11.7% in 2021 to <1% in 2025)
4. **How much revenue is lost?** ($29.75M+ in referral fees)

---

## Package Contents

```
APPROVED/LeadToListing_Reports/
├── README_LeadToListing_Reports.md     # This file
├── SOPs/
│   └── SOP_LeadToListing_Report_Generation.md
└── Scripts/
    ├── SQL_LeadToListing_Deduplicated.sql
    ├── SQL_LeadToListing_ByYear.sql
    ├── SQL_LeadToListing_RecentWins.sql
    └── SQL_LeadToListing_AgentPerformance.sql
```

---

## Key Metrics

| Metric | Current Value | Target |
|--------|---------------|--------|
| Lead-to-Listing Rate | 7.1% | 10%+ |
| Agent Win Rate | 1.0% | 10%+ |
| Referral Fees Earned | ~$5M | $50M+ |
| Referral Fees Lost | ~$30M | $0 |

---

## Data Flow

```
GenieLead (Lead Created)
    ↓
LeadPropertyMatch (Property Identified)
    ↓
ViewAssessor_v3 (Property Details via FIPS + FormattedAPN)
    ↓
ListingAssessor (MLS Link via FIPS + FormattedAPN)
    ↓
Listing (Listing Outcome)
    ↓
COMPARE: ListingAgentName vs GenieAgent → WON or LOST
```

---

## Deduplication Logic

Each listing (MLS Number) should be counted **once**, even if multiple leads touched the property.

```sql
ROW_NUMBER() OVER (PARTITION BY la.MlsNumber ORDER BY gl.CreateDate) as RowNum
-- Then filter: WHERE RowNum = 1
```

---

## Usage

1. Run SQL scripts against production database (192.168.29.45)
2. Export results to CSV
3. Save to: `C:\Cursor\TheGenie.ai\Development\NurtureEngine\Discovery\`
4. Push to GitHub: `TheGenie.ai/Development/NurtureEngine/Discovery/`

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/15/2025 | Cursor AI | Initial approved version |

---

## Related Documents

- [Workspace Memory Log](../../MemoryLogs/WORKSPACE_MEMORY_LOG_LeadToListing_Analysis_2025-12-15.md)
- [NurtureEngine Discovery](../../Development/NurtureEngine/Discovery/)

