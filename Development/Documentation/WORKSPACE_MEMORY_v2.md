# Workspace Memory - Complete Reference
**Version:** 2.0  
**Last Updated:** 2025-12-11  
**Session ID:** Deep Dive - Competition Command & Listing Command Reports

---

# 🚨 MASTER RULES (NEVER VIOLATE)

## Rule 1: File Versioning - CRITICAL
- **NEVER overwrite files** - Always save with new version number
- Naming convention: `[Client]_[Deliverable]_[Tone]_vN.ext`
- Examples:
  - `Genie_LC_MonthlyPerformance_2025-11_v10.csv`
  - `Genie_CC_Ownership_LIFETIME_2025-12-10_v5.csv`
- **Before saving:** Check if version already exists and increment

## Rule 2: No Assumptions
- If unclear, **STOP and ASK**
- Never use placeholders - all data must be real or confirmed
- Always confirm: File type, Client/User type, Tone
- **Study the code BEFORE making assumptions about system behavior**

## Rule 3: Documentation Style
- Document as you go - create SOP/SPEC with each report
- Keep SOP/SPEC current with each build iteration
- Update version numbers in specs when changes are made
- Voice stack alignment: Hormozi, Godin, Ogilvy, Serhant, Musk, Keller

## Rule 4: No Over-Engineering
- Only make changes that are directly requested
- Don't add features, refactor code, or make "improvements" beyond what was asked
- Keep solutions simple and focused

---

# 📊 DATABASE ACCESS

## Connection Details
```python
SERVER = "192.168.29.45"
PORT = 1433
DATABASE = "FarmGenie"  # Primary
USER = "cursor"
PASSWORD = "1ppINSAyay$"
```

## Available Databases
| Database | Purpose |
|----------|---------|
| FarmGenie | Main application database |
| MlsListing | Property/Listing data (full addresses) |
| TitleData | Title/escrow data |

## Python Connection Template
```python
import pyodbc
import pandas as pd

def connect():
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER=192.168.29.45,1433;"
        f"DATABASE=FarmGenie;"
        f"UID=cursor;PWD=1ppINSAyay$;"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)
```

## Important Notes
- **USE `pyodbc`** - pymssql hangs on this server
- SQL Server version: Microsoft SQL Server 2012 (SP4)
- Network: Server is on local network (192.168.29.x)

---

# 🏷️ PRODUCTS / SERVICES

## Product Type IDs (PropertyCastTypeId)

| ProductType | PropertyCastTypeId | Name | Description |
|-------------|-------------------|------|-------------|
| **CC** | 1 | FarmCast | Competition Command - Area-based SMS marketing |
| **LC** | 2 | Listing Command | Listing-based SMS marketing |
| **NC** | 3 | Neighborhood Command | Neighborhood marketing |

## Trigger Type IDs (PopertyCastTriggerTypeId)

| TriggerTypeId | Name | Used By |
|---------------|------|---------|
| 1 | ListingSold | CC (and LC) |
| 2 | ListingNew | CC (and LC) |

## 🚨 CRITICAL: Competition Command Trigger Types

**Competition Command (PropertyCastTypeId = 1) uses BOTH trigger types:**
- **ListingSold (1):** "A home just SOLD near you"
- **ListingNew (2):** "A new listing near you"

**Campaign Counts (as of 2025-12-10):**
- Type 1 (Listing Sold): 5,052 campaigns
- Type 2 (Listing New): 9,898 campaigns
- **Total CC Campaigns: 14,950**

```sql
-- CORRECT: Filter by PRODUCT TYPE, not trigger type
WHERE pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command (BOTH triggers)

-- WRONG: This excludes ~66% of CC campaigns!
WHERE pc.PopertyCastTriggerTypeId = 1  -- Only ListingSold
```

---

# 🔑 CRITICAL TECHNICAL LEARNINGS

## 1. Click Calculation - CRITICAL!

**Clicks = Leads Created** = `COUNT(DISTINCT GenieLeadId)`

### ❌ WRONG - AccessCount = page views, NOT clicks:
```sql
SELECT SUM(sud.AccessCount) as Clicks  -- WRONG!
FROM ShortUrlData sud
```

### ✅ CORRECT - Count unique leads created:
```sql
SELECT srsq.SourceMlsNumber, COUNT(DISTINCT gl.GenieLeadId) as Clicks
FROM SmsReportSendQueue srsq
INNER JOIN SmsReportMessageQueuedLog srmql 
    ON srsq.SmsReportSendQueueId = srmql.SmsReportSendQueueId
INNER JOIN ShortUrlDataLead sudl 
    ON srmql.ShortUrlDataId = sudl.ShortUrlDataId
INNER JOIN GenieLead gl 
    ON sudl.GenieLeadId = gl.GenieLeadId
WHERE srsq.UtmSource = 'Listing Command'
GROUP BY srsq.SourceMlsNumber
```

**Expected CTR:** 2-5% (NOT 10-30%)  
**If CTR > 10%:** Click calculation is WRONG!

## 2. LeadTagTypeIds (GenieLeadTagType table)

| ID | Tag Name | Use For |
|----|----------|---------|
| **48** | OptInContact | CTA_Submitted |
| **51** | OptOutSms | Opt_Outs |
| **52** | CtaContactVerified | CTA_Verified |

**Additional CTA Submit Tags:** 54, 56-64, 75, 77

## 3. Listing Command Data Model

### Order Structure (from source code study)
```
1 ORDER = 1 LISTING (MlsNumber) + 1-3 STATUS SELECTIONS
│
├── Customer places order for their listing
├── Selects 1, 2, or 3 statuses to market:
│     • Active (1) - market when listing goes active
│     • Pending (3) - market when listing goes pending  
│     • Sold (2) - market when listing sells
│
└── For EACH STATUS selected:
      ├── Creates 1 ListingCommandQueue record
      │     └── ListingStatusId = 1, 2, or 3
      │
      └── Each Queue links to 1 ListingCommandConfiguration
            ├── SmsTarget (count of SMS to send)
            ├── DirectMailTarget (count of mailers)
            └── FacebookTarget (count for Facebook ads)
```

### Billing Model ("Set It and Forget It")
- Customer is charged PER STATUS EXECUTION, not at order time
- A 3-status order today may execute over 3+ months as listing progresses
- Each execution = 1 row in the report for that month
- Report shows which level of a multi-status order is executing

## 4. SMS Data Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| SmsReportSendQueue | Marketing SMS batches | UtmSource, AreaId, SourceMlsNumber, CreateDate |
| ViewSmsQueueSendSummary | SMS counts per batch | SmsReportSendQueueId, Count |
| SmsReportMessageQueuedLog | Individual messages | ShortUrlDataId (for click tracking) |
| NotificationQueue | System SMS (notifications) | NotificationChannelId=1 for SMS, CreateDate |

## 5. User Profile Data

| Table | Available Columns |
|-------|-------------------|
| AspNetUsers | Id, UserName, Email (NO FirstName/LastName!) |
| AspNetUserProfiles | AspNetUserId, FirstName, LastName |
| AgentProfile | AspNetUserId, FirstName, LastName |

## 6. Area Name Resolution

**Priority Order:**
1. `PolygonNameOverride.FriendlyName` (user-customized name)
2. `ViewArea.Name` (system default)
3. **Fallback Mapping** (hardcoded for known areas)
4. Raw zip code

**Fallback Mapping (add new ones as discovered):**
```python
AREA_NAME_FALLBACKS = {
    9602: 'Oakland 94602',
    9609: 'Montclair 94610',
    9610: 'Piedmont 94611',
}
```

## 7. Invoice-Based Cost Allocation

**Formula:**
```
Variable_SMS_Cost = Invoice Outbound Base + Invoice Carrier Fees
CC_Percentage = CC_SMS_Count / Total_SMS_Count
CC_Cost = Variable_SMS_Cost × CC_Percentage
```

**November 2025 Example:**
- CC SMS: 19,875 (70.5%)
- Variable SMS Cost: $512.01
- CC Cost: $360.78

---

# 📁 WORKSPACE STRUCTURE

## Root Folders
```
C:\Cursor\
├── WORKSPACE_MEMORY.md          # This file
├── WORKSPACE_MEMORY_v2.md       # Comprehensive version
│
├── GenieFeatureRequests\        # Feature request documents
│   ├── FR-001_AreaOwnership_DesignBrief_v1.md
│   ├── FR-001_AreaOwnership_DevSpec_v2.md
│   ├── FR-001_AreaOwnership_DiscoveryWorksheet_v1.md
│   └── SOP_CC_Ownership_Report_v5.md
│
├── Twilio-20251209T200757Z-3-001\Twilio\
│   ├── REPORTS\                 # All report scripts and outputs
│   ├── _invoices_11-14-2025\    # Twilio invoice CSVs
│   ├── DATABASE_ACCESS_GUIDE.md
│   ├── BLUEPRINT_Twilio_Cost_Audit_v1.md
│   └── REPORT_TEMPLATES_Twilio_v1.md
│
├── Genie.Source.Code_v1\        # C# Source code
│   └── Genie.Source.Code\
│       ├── Web\                 # APIs and Web apps
│       └── WindowsService\      # Background services
│
├── GenieCLOUD_v1\               # Cloud/React components
│
├── APIs-20251209T192241Z-3-001\ # API exports and queries
│
├── drive-download_v1\           # Downloaded files from Mac
│
└── reports_v1\                  # Historical reports (.xlsx, .docx)
```

## Reports Folder Structure
```
Twilio-20251209T200757Z-3-001\Twilio\REPORTS\
├── SPECS (Specifications)
│   ├── SPEC_OwnedAreas_Report_v2.md
│   ├── SPEC_CompCommand_MonthlyCostReport_v3.md
│   └── SPEC_LC_MonthlyPerformance_v2.md
│
├── SOPs (Standard Operating Procedures)
│   ├── SOP_CC_Monthly_Cost_Report_v2.md
│   ├── SOP_LC_MonthlyPerformance_v1.md
│   └── SOP_Twilio_Invoice_Reconciliation_v1.md
│
├── SCRIPTS (Python)
│   ├── build_cc_ownership_LIVE_v2.py
│   ├── build_cc_monthly_report_v3.py
│   ├── build_lc_performance_v10.py
│   └── [investigation scripts...]
│
└── REPORTS (CSV/Excel output)
    ├── Genie_CC_Ownership_LIFETIME_*.csv
    ├── Genie_CompCommand_CostsByMonth_*.csv
    ├── Genie_LC_MonthlyPerformance_*.csv
    └── Genie_Twilio_Invoice_Recon_*.xlsx
```

---

# 📋 REPORT CATALOG

## Completed Reports

| Report | Description | Spec | SOP | Latest Script | Latest Output |
|--------|-------------|------|-----|---------------|---------------|
| CC Ownership (Lifetime) | All CC area ownership with campaign stats | SPEC_OwnedAreas_Report_v2.md | SOP_CC_Ownership_Report_v5.md | build_cc_ownership_LIVE_v2.py | v5_iter2.csv |
| CC Monthly Cost | Monthly CC costs by user/area | SPEC_CompCommand_MonthlyCostReport_v3.md | SOP_CC_Monthly_Cost_Report_v2.md | build_cc_monthly_report_v3.py | v5.csv |
| LC Monthly Performance | LC orders, revenue, performance | SPEC_LC_MonthlyPerformance_v2.md | SOP_LC_MonthlyPerformance_v1.md | build_lc_performance_v10.py | v10.csv |
| Twilio Invoice Reconciliation | Invoice cost breakdown | - | SOP_Twilio_Invoice_Reconciliation_v1.md | final_recon_nov_v1.py | COMPLETE.xlsx |
| **Twilio Phone Inventory** | All phone numbers with categories | SPEC_Twilio_PhoneNumber_Reports_v1.md | SOP_Twilio_Phone_Inventory_v1.md | analyze_phone_numbers_v1.py | FULL_INVENTORY_v1.csv |
| **Twilio Phone Usage Assessment** | Orphan/unused number detection | SPEC_Twilio_PhoneNumber_Reports_v1.md | SOP_Twilio_Phone_Inventory_v1.md | assess_phone_usage_v1.py | Usage_Assessment_v1.csv |
| **Delivery Farm Usage & Responses** | Outbound, inbound, response rates | SPEC_Twilio_PhoneNumber_Reports_v1.md | SOP_Twilio_DeliveryFarm_Usage_v1.md | delivery_farm_with_responses_v1.py | Usage_Responses_2025_v1.csv |

## Report Column Specs

### CC Ownership Report (14 columns)
1. UserOwnedAreaId, 2. AreaId, 3. Zip_Code, 4. Area_Name, 5. Customer_Name,
6. Property_Types, 7. Ownership_Start, 8. Total_Campaigns, 9. Last_Campaign,
10. Texts_Sent, 11. Clicks, 12. CTR, 13. Leads_Generated, 14. Ownership_Status

### LC Monthly Performance Report (21 columns)
1. Order_ID, 2. Customer_Name, 3. MLS_Number, 4. Property_Address,
5. Order_Status_Count, 6. Execution_Status, 7. Order_Date, 8. Execution_Date,
9. Channel, 10. Channel_Target, 11. Msgs_Sent, 12. Clicks, 13. CTR_Pct,
14. CTA_Submitted, 15. CTA_Verified, 16. Opt_Outs, 17. Opt_Out_Pct,
18. Revenue_Charged, 19. Twilio_Cost, 20. Profit, 21. Profit_Pct

---

# 📞 TWILIO PHONE NUMBER INVENTORY

## Summary (as of 12-11-2025)

| Metric | Value |
|--------|-------|
| Total Phone Numbers | 122 |
| Monthly Cost | $143.30 |
| Delivery Farm Pool | 73 numbers |
| User Assigned | 32 numbers |
| SMS/Number Farm Pools | 14 numbers |
| Other/System | 3 numbers |

## Delivery Farm 2025 Activity

| State | Numbers | Outbound | Inbound | Response Rate |
|-------|---------|----------|---------|---------------|
| CA | 61 | 290,673 | 7,967 | 2.74% |
| FL | 7 | 5,718 | 211 | 3.69% |
| TX | 5 | 5,980 | 194 | 3.24% |
| **TOTAL** | **73** | **302,371** | **8,372** | **2.77%** |

## Orphan Numbers (Release Candidates)

| Status | Count | Monthly Savings |
|--------|-------|-----------------|
| Never Used | 8 | $10.20 |
| Dormant (>1 year) | 1 | $1.15 |
| Stale (90d-1yr) | 15 | $18.25 |
| **TOTAL** | **24** | **$29.60/mo = $355.20/yr** |

## 🚨 ANOMALY DETECTED: +1 (408) 351-4056

**Issue:** 22.27% response rate (vs 2.77% average)

**Root Cause:** Single phone number `+1 (831) 278-1626` sent **315 out of 380** responses (82.9%)

**Pattern:**
- Activity spiked in July-September 2025
- September: 190 inbound vs 84 outbound (226% rate!)
- All responses logged at Hour 0 (midnight UTC)
- Number is used for FarmCast (Competition Command) campaigns

**Likely Explanation:** Bot activity or automated response system attached to a lead

**Investigation Script:** `investigate_bot_number_v1.py`

---

# 📊 NOVEMBER 2025 BENCHMARKS

## Competition Command
- Total SMS: 19,875
- Cost: $360.78 (70.5% of SMS)
- Trigger Type 1: 5,052 campaigns
- Trigger Type 2: 9,898 campaigns

## Listing Command
- Orders: 21 (22 rows including multi-channel)
- SMS Sent: 3,050
- Clicks (Leads Created): 77
- CTR: 2.5%
- Revenue: ~$1,900
- Profit: ~$1,845 (96.4% margin)

## Twilio Invoice Total
- November 2025: $722.89
- Variable SMS Cost: $512.01
- Fixed Costs: $211.72

---

# ⚠️ COMMON ERRORS & FIXES

## SQL Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Invalid column 'FirstName' | AspNetUsers doesn't have FirstName | Use AspNetUserProfiles |
| Invalid column 'SendDate' | NotificationQueue uses CreateDate | Change to CreateDate |
| Invalid column 'GenieLeadTagTypeId' | Column is LeadTagTypeId | Change column name |
| STRING_AGG WITHIN GROUP error | SQL 2012 compatibility | Remove WITHIN GROUP |
| Login failed for 'TheGenie' | Wrong database name | Use 'FarmGenie' |

## Python Errors

| Error | Cause | Fix |
|-------|-------|-----|
| UnicodeEncodeError | Emojis in print statements | Remove emojis |
| KeyError in groupby | Column is groupby key | Access differently |
| Division by zero | Empty data | Add NULLIF or CASE |

## Report Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Wrong campaign counts | Filtering by TriggerTypeId | Filter by PropertyCastTypeId=1 |
| Inflated clicks | Using AccessCount | Use COUNT(DISTINCT GenieLeadId) |
| Missing addresses | Only checking FarmGenie | Query MlsListing.Listing |
| Duplicate rows | Multiple ListingCommandQueue records | Use ROW_NUMBER() to get latest |

---

# 🔧 KEY DATABASE TABLES

## Campaign/SMS Flow

```
PropertyCast (trigger/execution)
    ↓
PropertyCastWorkflowQueue (links cast to collection)
    ↓
PropertyCollectionDetail (campaign definition)
    ↓
SmsReportSendQueue (SMS batch)
    ↓
ViewSmsQueueSendSummary (SMS counts)
    ↓
SmsReportMessageQueuedLog (individual messages)
    ↓
ShortUrlData (tracking URLs)
    ↓
ShortUrlDataLead → GenieLead (leads created)
    ↓
GenieLeadTag (CTA/OptOut tags)
```

## Listing Command Flow

```
ListingCommandQueue (order + status)
    ↓
ListingCommandConfiguration (channels + costs)
    ↓
ListingCommandBilling (MultiStatusOrdered 1/2/3)
    ↓
SmsReportSendQueue (via SourceMlsNumber)
    ↓
MlsListing.Listing (property addresses)
```

## User/Area Flow

```
AspNetUsers (account)
    ↓
AspNetUserProfiles (FirstName, LastName)
    ↓
UserOwnedArea (area ownership)
    ↓
ViewArea / PolygonNameOverride (area names)
```

---

# 📝 FEATURE REQUESTS IN PROGRESS

## FR-001: Area Ownership & Waitlist System

**Status:** Design Complete, Ready for Development

**Key Documents:**
- `FR-001_AreaOwnership_DesignBrief_v1.md` - Problem/Solution overview
- `FR-001_AreaOwnership_DevSpec_v2.md` - Technical specification
- `FR-001_AreaOwnership_DiscoveryWorksheet_v1.md` - Open questions

**New Tables Proposed:**
- `AreaOwnership` - Replaces UserOwnedArea with soft deletes
- `AreaOwnershipHistory` - Audit trail
- `AreaCampaignHistory` - Campaign activity tracking
- `AreaWaitlist` - Queue management

**Key Stored Procedures:**
- `usp_AreaOwnership_End` - End ownership with history
- `usp_AreaOwnership_GetHistory` - Get ownership history
- `usp_AreaCampaignHistory_Record` - Record campaign activity
- `usp_AreaCampaignHistory_GetByOwnership` - Get campaign history

---

# 🔗 SOURCE CODE KEY FILES

## Listing Command Handlers
```
Genie.Source.Code_v1\Genie.Source.Code\WindowsService\
├── Smart.Service.ListingCommand\
│   ├── ListingCommandQueueHandler.cs  # Order queuing logic
│   └── ListingCommandV2Handler.cs     # Action execution (SMS/FB/DM)
```

## PropertyCast Workflows
```
Genie.Source.Code_v1\Genie.Source.Code\WindowsService\
├── Smart.Service.PropertyCast\
│   └── [Cast execution logic]
├── Smart.Service.PropertyCasterWorkflow\
│   └── [Workflow orchestration]
```

## Cloud Templates (Landing Pages/CTAs)
```
GenieCLOUD_v1\GenieCLOUD\genie-cloud\
├── genie-components\  # React components
├── genie-renderer\    # Template rendering
└── public\           # XSL templates, CSS, assets
```

---

# 📌 QUICK REFERENCE COMMANDS

## Run Reports
```powershell
cd C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS

# CC Ownership Report
python build_cc_ownership_LIVE_v2.py

# CC Monthly Cost Report
python build_cc_monthly_report_v3.py

# LC Monthly Performance Report
python build_lc_performance_v10.py
```

## Check Database Connection
```python
import pyodbc
drivers = pyodbc.drivers()
print([d for d in drivers if "ODBC" in d])
```

---

# ✅ SESSION ACCOMPLISHMENTS

1. ✅ Extracted and organized all Mac workspace files
2. ✅ Established database connectivity to SQL Server
3. ✅ Built CC Ownership Report (Lifetime) with 14 columns
4. ✅ Built CC Monthly Cost Report with invoice-based allocation
5. ✅ Built LC Monthly Performance Report with 21 columns
6. ✅ Built Twilio Invoice Reconciliation Report
7. ✅ Created Feature Request FR-001 for Area Ownership System
8. ✅ Fixed critical click calculation error (AccessCount → GenieLeadId)
9. ✅ Fixed Competition Command trigger type filter
10. ✅ Documented all technical learnings in WORKSPACE_MEMORY
11. ✅ Built Twilio Phone Number Inventory Report (122 numbers)
12. ✅ Built Phone Usage Assessment (identified 24 orphan candidates)
13. ✅ Built Delivery Farm Usage & Response Report (73 numbers, 2.77% response rate)
14. ✅ Investigated anomaly phone +1 (408) 351-4056 - identified bot responder
15. ✅ Created SOPs and Specs for all Twilio phone reports

---

*This file is permanent. Reference before starting any task. Update as new learnings are discovered.*

*Last Updated: 2025-12-11 by Cursor AI*

