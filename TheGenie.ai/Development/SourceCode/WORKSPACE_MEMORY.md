# Workspace Memory
**Last Updated:** 2025-12-11 (v10 updates)

---

## MASTER RULES (NEVER VIOLATE)

### 1. File Versioning - CRITICAL
- **NEVER overwrite files** - Always save with new version number
- Naming convention: `[Client]_[Deliverable]_[Tone]_vN.ext`
- Example: `Genie_LC_MonthlyPerformance_2025-11_v8.csv`
- If editing a file, save as new version (v1 → v2 → v3...)

### 2. No Assumptions
- If unclear, **STOP and ASK**
- Never use placeholders - all data must be real or confirmed
- Always confirm: File type, Client/User type, Tone

### 3. Documentation Style
- Document as you go - create SOP/SPEC with each report
- Keep SOP/SPEC current with each build iteration
- Update version numbers in specs when changes are made

---

## DATABASE ACCESS

### Connection Details
```python
SERVER = "192.168.29.45"
DATABASE = "FarmGenie"  # Primary
USER = "cursor"
PASSWORD = "1ppINSAyay$"
```

### Secondary Databases
- `MlsListing` - Property addresses (Listing table)

---

## PRODUCTS / SERVICES

| Product | PropertyCastTypeId | Description |
|---------|-------------------|-------------|
| Competition Command (CC) | 1 (FarmCast) | Area-based SMS marketing for sold/new listings |
| Listing Command (LC) | 2 | Listing-based SMS marketing (Active/Pending/Sold) |
| Neighborhood Command (NC) | - | Neighborhood marketing |

---

## KEY TECHNICAL LEARNINGS

### Competition Command (CC)
- Uses **BOTH** `PopertyCastTriggerTypeId = 1` (Listing Sold) AND `= 2` (Listing New)
- Filter by `PropertyCastTypeId = 1` for all CC campaigns
- Area ownership via `UserOwnedArea` table

### Listing Command (LC)
- 1 Order = 1 MLS Number + 1-3 Status selections (Active/Pending/Sold)
- Billing: "Set it and forget it" - charged per status execution, not at order
- Channels: SMS, Facebook, DirectMail (per `ListingCommandConfiguration`)
- Order level from `ListingCommandBilling.MultiStatusOrdered` (1/2/3)

### Click Calculation - CRITICAL
**Clicks = COUNT(DISTINCT GenieLeadId)** = Leads created (people who clicked through)

**WRONG** (AccessCount = page views, not clicks):
```sql
SELECT SUM(sud.AccessCount) as Clicks  -- WRONG!
FROM ShortUrlData sud
```

**CORRECT** (count unique leads created):
```sql
SELECT srsq.SourceMlsNumber, COUNT(DISTINCT gl.GenieLeadId) as Clicks
FROM SmsReportSendQueue srsq
JOIN SmsReportMessageQueuedLog srmql ON srsq.SmsReportSendQueueId = srmql.SmsReportSendQueueId
JOIN ShortUrlDataLead sudl ON srmql.ShortUrlDataId = sudl.ShortUrlDataId
JOIN GenieLead gl ON sudl.GenieLeadId = gl.GenieLeadId
WHERE srsq.UtmSource = 'Listing Command'
GROUP BY srsq.SourceMlsNumber
```

**Expected CTR:** 2-5% (NOT 10-30%)

### LeadTagTypeIds (GenieLeadTagType table)
| ID | Tag | Use For |
|----|-----|---------|
| 48 | OptInContact | CTA_Submitted |
| 51 | OptOutSms | Opt_Outs |
| 52 | CtaContactVerified | CTA_Verified |

---

## REPORT CATALOG

### Completed Reports
| Report | Spec | SOP | Latest Version |
|--------|------|-----|----------------|
| CC Ownership Report | SPEC_OwnedAreas_Report_v2.md | - | v5_iter2 |
| CC Monthly Cost Report | SPEC_CompCommand_MonthlyCostReport_v3.md | SOP_CC_Monthly_Cost_Report_v2.md | v3 |
| LC Monthly Performance | SPEC_LC_MonthlyPerformance_v2.md | SOP_LC_MonthlyPerformance_v1.md | v10 |
| Twilio Invoice Reconciliation | - | SOP_Twilio_Invoice_Reconciliation_v1.md | v1 |

---

## FILE LOCATIONS

### Reports Folder
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\
```

### Feature Requests
```
C:\Cursor\GenieFeatureRequests\
```

### Source Code
```
C:\Cursor\Genie.Source.Code_v1\
```

---

## NOVEMBER 2025 BENCHMARKS

### Competition Command
- Total SMS: 19,875
- Cost: $360.78 (70.5% of SMS)

### Listing Command
- Orders: 21 (22 rows including multi-channel)
- SMS Sent: 3,050
- Clicks (Leads Created): 77
- CTR: 2.5%
- Revenue: ~$1,900
- Profit: ~$1,845 (96.4% margin)

### Twilio Invoice Total
- $722.89

---

## VOICE STACK ALIGNMENT
Strategy voice must align with: Hormozi, Godin, Ogilvy, Serhant, Musk, Keller

---

*This file is permanent. Reaffirm with user before deviating from any rules.*

