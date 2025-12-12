# WORKSPACE MEMORY - MASTER LOG v8
**Complete Reference - All Versions Combined**

**Date:** 2025-12-10  
**Status:** ❌ **NOT COMPLETE - BLOCKED BY AUTHENTICATION**  
**Version History:** v1 → v2 → v3 → v4 → v5 → v5_COMPLETE_HANDOFF → v6 → v7 → **v8 (MASTER)**

**This document combines ALL previous workspace memory versions into a single comprehensive reference.**

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

## Rule 5: NEVER MESS WITH AN EXISTING REPO WITHOUT ASKING - EVER
- Established after user concern about genie-cloud repo
- Always create new repos for new content
- Always ask before modifying existing repositories

## Rule 6: Status Must Be Clear and Unambiguous
- Use: COMPLETE/DONE vs PREPARED/BLOCKED
- Never use ambiguous "ready" language
- Explicitly state what's done vs what's not done

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

## 6. Lead Phone Data

| Table | Available Columns |
|-------|-------------------|
| GenieLead | GenieLeadId, FirstName, LastName, Email, AspNetUserId, CreateDate |
| GenieLeadPhone | GenieLeadPhoneId, GenieLeadId, **Phone** (NOT PhoneNumber!), CreateDate |

```sql
-- Get leads with phone numbers
SELECT gl.*, glp.Phone
FROM GenieLead gl
INNER JOIN GenieLeadPhone glp ON gl.GenieLeadId = glp.GenieLeadId
```

## 7. Opt-Out System

### How Opt-Outs Work
1. Consumer replies "STOP" to a Twilio number
2. Twilio automatically creates opt-out record
3. System records in `SmsOptOut` table
4. **Opt-out blocks the CONSUMER, not the Twilio number**
5. That consumer will never receive SMS from ANY Genie number again

### SmsOptOut Table
| Column | Description |
|--------|-------------|
| ToPhoneNumber | Consumer's phone (who opted out) |
| FromPhoneNumber | Our Twilio number they texted |
| CreateDate | When opt-out was recorded |
| Note | Optional note |

```sql
-- Get opt-outs in 2025
SELECT ToPhoneNumber, FromPhoneNumber, CreateDate
FROM SmsOptOut
WHERE CreateDate >= '2025-01-01'
```

## 8. Inbound Message Tracking

### TwilioMessage Table - Inbound Messages
```sql
-- Find inbound messages (consumer responses)
SELECT 
    [To] as OurPhone,
    [From] as ConsumerPhone,
    DateSent,
    Status
FROM TwilioMessage
WHERE Status = 'received'  -- Inbound message
  AND DateSent >= '2025-01-01'
```

**Note:** `TwilioMessage` does NOT have a `Body` column - only metadata.

## 9. Area Name Resolution

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

## 10. Invoice-Based Cost Allocation

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

# 📁 FILE ORGANIZATION DECISIONS

User completed: `TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.answered.docx`

## Key Decisions:

| Decision | Answer |
|----------|--------|
| **Stakeholders** | Steve Hundley (Owner), Cursor (Dev), Eddie Oddo (Ops) + GROWTH + SUPPORT |
| **Access** | Just Steve for now, team later |
| **Version Display** | Latest only + subtle changelog with links to history |
| **Categories** | Add Marketing/Sales (Growth) for GTM, presentations, creative |
| **Hierarchy** | Product-first: `TheGenie.ai/Operations/Reports/CompetitionCommand/` etc. |
| **Naming** | `[System]_[Type]_[Name]_[Date]_v#.ext` with underscores, dates on ALL files |
| **Landing Page** | Like app.thegenie.ai/help with auto-update |
| **Cleanup** | Reorganize everything NOW |
| **Owner** | Steve Hundley |

## Folder Structure Approved:

```
TheGenie.ai/
├── Operations/
│   ├── Reports/
│   │   ├── CompetitionCommand/
│   │   ├── ListingCommand/
│   │   └── Twilio/
│   ├── SOPs/
│   ├── Specs/
│   └── Scripts/
├── Growth/ (Sales & Marketing)
├── Support/ (Customer Experience)
├── Development/
│   ├── SourceCode/
│   └── FeatureRequests/
├── Applications/
│   ├── CompetitionCommand/
│   ├── ListingCommand/
│   ├── NeighborhoodCommand/
│   ├── TitleGenie/
│   ├── GeoSocialAudienceBuilder/
│   └── AskPaisley/
├── _Archive/
└── _Assets/
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
| Twilio Phone Inventory | All phone numbers with categories | SPEC_Twilio_PhoneNumber_Reports_v1.md | SOP_Twilio_Phone_Inventory_v1.md | analyze_phone_numbers_v1.py | FULL_INVENTORY_v1.csv |
| Twilio Phone Usage Assessment | Orphan/unused number detection | SPEC_Twilio_PhoneNumber_Reports_v1.md | SOP_Twilio_Phone_Inventory_v1.md | assess_phone_usage_v1.py | Usage_Assessment_v1.csv |
| Delivery Farm Usage & Responses | Outbound, inbound, response rates | SPEC_Twilio_PhoneNumber_Reports_v1.md | SOP_Twilio_DeliveryFarm_Usage_v1.md | delivery_farm_with_responses_v1.py | Usage_Responses_2025_v1.csv |
| Delivery Farm Complete Analysis | Monthly breakdown with opt-outs | - | - | delivery_farm_complete_analysis_v1.py | Complete_2025_v1.csv |
| Engagement Analysis | Missed opportunities & warm leads | - | - | engagement_analysis_v1.py | Multiple reports |
| **Inbound Response Analysis** | Classify inbound as Opt-Out vs Engagement | SPEC_Twilio_Inbound_Response_Analysis_v1.md | SOP_Twilio_Inbound_Response_Analysis_v1.md | analyze_inbound_responses_v1.py | Inbound_Analysis_v1.csv |

## NEW: Engagement Analysis Reports (2025-12-11)

| Report File | Description | Records |
|-------------|-------------|---------|
| `REPORT_MissedOpportunities_ByAgent_v1.csv` | Unconverted engagement by agent | By agent |
| `REPORT_WarmLeads_ForFollowup_v1.csv` | Consumer phones ready for follow-up | 5,716 unique |
| `REPORT_PotentialBots_v1.csv` | Suspicious high-frequency responders | 5 bots |
| `REPORT_ConversionByAgent_v1.csv` | Engagement-to-lead conversion rates | By agent |

### Engagement Summary (2025 YTD)
| Metric | Value | % |
|--------|------:|--:|
| Total Inbound Messages | 10,963 | 100% |
| Opt-Outs | 4,437 | 40.5% |
| Engagement Responses | 7,557 | 68.9% |
| Became Leads | 348 | 4.6% |
| Potential Bots | 512 | 6.8% |
| **MISSED OPPORTUNITIES** | **6,697** | **88.6%** |

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

## 🚨 BOTS IDENTIFIED (2025-12-11)

### 5 Potential Bot Numbers to Block

| Consumer Phone | Responses | Target Number | Pattern |
|----------------|-----------|---------------|---------|
| +1 (831) 278-1626 | **336** | +1 (408) 351-4056 | 82.9% of all responses to that number |
| +1 (702) 292-6043 | 63 | +1 (352) 280-3052 | High frequency |
| +1 (818) 926-5280 | 61 | +1 (213) 699-4669 | High frequency |
| +1 (877) 822-1202 | 28 | +1 (805) 243-3571 | Toll-free source |
| +1 (562) 275-5882 | 24 | +1 (562) 685-9265 | High frequency |

### SQL to Block These Bots
```sql
INSERT INTO SmsOptOut (ToPhoneNumber, FromPhoneNumber, Note, CreateDate)
VALUES 
('8312781626', '4083514056', 'Bot detected - 336 responses', GETDATE()),
('7022926043', '3522803052', 'Bot detected - 63 responses', GETDATE()),
('8189265280', '2136994669', 'Bot detected - 61 responses', GETDATE()),
('8778221202', '8052433571', 'Bot detected - 28 responses', GETDATE()),
('5622755882', '5626859265', 'Bot detected - 24 responses', GETDATE());
```

## 🚨 ANOMALY: +1 (408) 351-4056

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

# 📊 KEY FINDINGS (December 2025)

| Metric | Value |
|--------|-------|
| Total Phone Numbers | 122 |
| Orphan Numbers | 24 ($355/yr savings) |
| Bots Identified | 5 (need to block) |
| Missed Opportunities | 6,697 (88.6% of engagement) |
| November CC SMS | 19,875 |
| November Twilio Invoice | $722.89 |

---

# 🔧 INFRASTRUCTURE

| Platform | Details |
|----------|---------|
| AWS S3 | Bucket: `genie-cloud`, Region: `us-west-1`, Profile: `genie-hub-active` |
| Domain | thegenie.ai, app.thegenie.ai |
| Database | SQL Server 2012 at 192.168.29.45 |
| Help Page | ASP.NET MVC at `Smart.Dashboard/Areas/HelpPage/` |
| Notion | Workspace ID: `9b72e4ec-dce0-8155-a440-00039beadab4` (MCP Connected) |
| GitHub | Repository: `1parkplace/genie-cloud`, New repo: `1parkplace/NOTION` |

---

# 📁 KEY FILE LOCATIONS

| File | Path |
|------|------|
| Workspace Memory | `C:\Cursor\WORKSPACE_MEMORY_MASTER_v8.md` (THIS FILE) |
| File Catalog | `C:\Cursor\GENIE_FILE_CATALOG_v2.md` |
| Questionnaire (Answered) | `C:\Cursor\TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.answered.docx` |
| Twilio Reports | `C:\Cursor\Twilio\REPORTS\` |
| Feature Requests | `C:\Cursor\GenieFeatureRequests\` |
| Source Code | `C:\Cursor\Genie.Source.Code_v1\` |
| GenieCLOUD | `C:\Cursor\GenieCLOUD_v1\` |
| Notion Integration | `C:\Cursor\notion_*.py`, `C:\Cursor\NOTION_*.md` |

---

# 🔄 NOTION INTEGRATION

## Notion Workspace
- **Workspace ID:** `9b72e4ec-dce0-8155-a440-00039beadab4`
- **Workspace Name:** "Steve Hundley's Space"
- **Owner:** Steve Hundley
- **Connection Method:** MCP (Model Context Protocol) - Direct integration
- **Status:** ✅ MCP Connected (but page creation currently blocked by authentication)

## Notion Operations Portal
- **Parent Page ID:** `2c72e4ec-dce0-810c-b382-ec8fb8b40136`
- **URL:** https://www.notion.so/2c72e4ecdce0810cb382ec8fb8b40136
- **Purpose:** Navigation hub for all documentation, reports, SOPs, and specs
- **Structure:** TheGenie.ai > Operations/Development/Growth/Support/Applications

## Files Prepared for Notion

### MD Files: 156 total
- **Source:** All `.md` files found in workspace
- **Analysis:** Pre-analyzed with deep descriptions
- **Saved in:** `ALL_MD_FILES_ANALYZED_v20.json`
- **Deep descriptions:** 50 files have detailed summaries in `MD_FILES_ACCURATE_DETAILED_v6.csv`
- **Classification:** Intelligent categorization based on filename and content

**Categories:**
- Operations > SOPs (Notion, Twilio, Competition Command, Listing Command)
- Operations > Reports (Twilio, Competition Command, Listing Command)
- Development > Specs (Competition Command, Listing Command, Twilio)
- Development > Documentation (System, Workspace, APIs)
- Development > Architecture
- Exceptions > Unclassified (20 files for review)

### CSV Files: 18 final/relevant
- **Source:** 329 total CSV files filtered down to 18 final versions
- **Filtering Applied:**
  - ✅ Excluded SQL query CSVs (identified by naming patterns: query_result, sql_output, numbered queries like 0001.GetLead.csv)
  - ✅ Excluded intermediate versions (kept only FINAL/LIVE/COMPLETE or highest version number)
  - ✅ Only files in REPORTS folders

**Final CSV Files:**
1. CC_SMS_Internal_Cost_Report_COMPLETE_FINAL.csv
2. CC_SMS_Internal_Cost_Report_COMPLETE_FINAL_FORMATTED.csv
3. CC_SMS_Internal_Cost_Report_COMPLETE_v1.csv
4. CC_SMS_Internal_Cost_Report_FINAL_COMPLETE.csv
5. DAVE_HIGGINS_OCTOBER_2025_COMPLETE_REPORT_v3.csv
6. Twilio_DeliveryFarm_Complete_2025_v1.csv
7. Twilio_DeliveryFarm_Inbound_Analysis_v1.csv
8. Twilio_DeliveryFarm_Usage2025_v1.csv
9. Twilio_DeliveryFarm_Usage_Responses_2025_v1.csv
10. CC_SMS_Internal_Cost_Report_COMPLETE_FROM_TWILIO.csv
11. CC_SMS_Internal_Cost_Report_FROM_CSV_TWILIO_FINAL.csv
12. Twilio-carrier-undeliverable.report.11.13.2025.csv
13. CC_Ownership_RAW_2025-12-10.csv
14. Genie_CC_Ownership_Full_2025-12-10_LIVE.csv
15. Genie_CC_Ownership_LIFETIME_2025-12-10_v5_iter2.csv
16. Genie_CompCommand_CostsByMonth_10-2025_FAST.csv
17. Genie_CompCommand_CostsByMonth_11-2025_FINAL.csv
18. Genie_CompCommand_CostsByMonth_11-2025_v1.1 - Genie_CompCommand_CostsByMonth_11-2025_v1.csv.csv

## Notion Page Structure (Prepared)

Every Notion page prepared includes:

1. **Title:** Filename
2. **Description Section:**
   - Deep description (up to 3000 chars for MD files with detailed summaries)
   - File structure info for CSV files (rows, columns, sample data)
   - Context based on file path and content
3. **File Location:**
   - Local file path
   - Status indicator (not yet uploaded to GitHub)
4. **Classification:**
   - Shows Notion section/category
5. **Status:**
   - ⚠️ File not yet uploaded to GitHub
   - Local file exists indicator
   - GitHub upload: Pending
   - Notion link: Will be added after GitHub upload

**Note:** Pages prepared but NOT YET CREATED in Notion due to authentication blocker.

## Batch Files Created

**18 batch files created:**
- `NOTION_BATCH_1_v20.json` through `NOTION_BATCH_18_v20.json`
- Each batch contains up to 10 pages
- Total: 174 pages prepared
- Format: Ready for MCP tool or Notion API

## Authentication Requirements

### Option 1: GitHub + Notion API (Recommended)
```powershell
$env:GITHUB_TOKEN="your_token"  # From https://github.com/settings/tokens (repo scope)
$env:NOTION_API_TOKEN="your_token"  # From https://www.notion.so/my-integrations
python load_md_and_relevant_csvs_to_notion_v20.py
```

### Option 2: MCP Tools
- Requires working MCP connection to Notion
- Current status: MCP tool calls failing with "Invalid tool arguments"
- Need to fix MCP connection or tool format

### Option 3: Manual Process
- Upload files to GitHub manually
- Create Notion pages manually using batch JSON files

## Filtering Logic Implemented

### SQL Query CSV Exclusion:
- Files with patterns: `query_result`, `sql_result`, `query_output`, `sql_output`, `query_`, `sql_query`
- Files in folders: `queries`, `query`, `sql`, `results`, `output`, `temp`, `tmp`
- Numbered query files: `0001.GetLead.csv`, `0002.OptinAccept.csv`, etc.
- **Result:** 311 SQL query CSVs excluded

### Version Filtering:
- Groups files by base name (e.g., `file_v1.csv`, `file_v2.csv` → base: `file`)
- Keeps only:
  - Files with `FINAL`, `LIVE`, `COMPLETE` in name (highest priority)
  - Highest version number if no final indicator
- Single version files: kept if in REPORTS folder
- **Result:** 329 CSVs → 18 final versions

### Final Relevance Filtering:
- **MUST** be in REPORTS folder (path contains `reports` or `report`)
- **MUST** have:
  - Final indicators (`final`, `complete`, `live`, `production`) OR
  - Be Twilio/CC/LC report (path or filename contains `twilio`, `cc_`, `lc_`, `competition`, `listing`)
- **EXCLUDES:** Numbered query files (`0001.`, `0002.`, etc.)

---

# ⚠️ COMMON ERRORS & FIXES

## SQL Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Invalid column 'FirstName' | AspNetUsers doesn't have FirstName | Use AspNetUserProfiles |
| Invalid column 'PhoneNumber' | GenieLeadPhone uses 'Phone' | Change to 'Phone' |
| Invalid column 'SendDate' | NotificationQueue uses CreateDate | Change to CreateDate |
| Invalid column 'GenieLeadTagTypeId' | Column is LeadTagTypeId | Change column name |
| Invalid column 'Body' | TwilioMessage doesn't have Body | Remove column |
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

## Lead/Engagement Flow

```
TwilioMessage (Status='received' = inbound)
    ↓
Consumer phone → SmsOptOut (check if opted out)
    ↓
Consumer phone → GenieLeadPhone.Phone → GenieLead (check if converted)
    ↓
NotificationQueue.AspNetUserIdTo (find agent who sent)
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

# ✅ SESSION ACCOMPLISHMENTS (Historical)

## v1 (2025-12-10)
1. ✅ Initial workspace memory created
2. ✅ Database connectivity established
3. ✅ Basic product/service documentation

## v2 (2025-12-11)
1. ✅ Built CC Ownership Report (Lifetime) with 14 columns
2. ✅ Built CC Monthly Cost Report with invoice-based allocation
3. ✅ Built LC Monthly Performance Report with 21 columns
4. ✅ Built Twilio Invoice Reconciliation Report
5. ✅ Fixed critical click calculation error (AccessCount → GenieLeadId)
6. ✅ Fixed Competition Command trigger type filter
7. ✅ Built Twilio Phone Number Inventory Report (122 numbers)
8. ✅ Built Phone Usage Assessment (identified 24 orphan candidates)
9. ✅ Built Delivery Farm Usage & Response Report (73 numbers, 2.77% response rate)
10. ✅ Investigated anomaly phone +1 (408) 351-4056 - identified bot responder
11. ✅ Created SOPs and Specs for all Twilio phone reports

## v3 (2025-12-11)
1. ✅ Built Delivery Farm Monthly Usage with Opt-Outs Report
2. ✅ Investigated opt-out system mechanics
3. ✅ Built Engagement Analysis Report (7,557 engagement responses)
4. ✅ Identified 5 potential bot phone numbers to block
5. ✅ Identified 6,697 missed opportunities (88.6% of engagement)
6. ✅ Created Warm Leads report for follow-up
7. ✅ Created Conversion by Agent report
8. ✅ Organized Twilio reports into `C:\Cursor\Twilio\REPORTS\`
9. ✅ Created File Organization Discovery Questionnaire (.docx)
10. ✅ Updated Workspace Memory to v3

## v4 (2025-12-11)
1. ✅ Created FINAL handoff document
2. ✅ Documented file organization decisions from questionnaire
3. ✅ Captured all master rules and technical learnings
4. ✅ Documented key findings and infrastructure

## v5 (2025-12-11)
1. ✅ **Notion MCP connection established** - Direct integration working
2. ✅ Created Notion API helper files (backup if needed)
3. ✅ Created comprehensive setup and approach documentation
4. ✅ Created privacy/access discovery questionnaire
5. ✅ Explained private sections functionality
6. ✅ Documented Notion approach and expectations
7. ✅ Researched Google Drive integration options
8. ✅ Created comprehensive Google Drive options guide

## v6 (2025-12-10)
1. ✅ Identified 156 MD files for Notion
2. ✅ Filtered 329 CSV files down to 18 final/relevant
3. ✅ Created deep descriptions for MD files
4. ✅ Created filtering logic (SQL query exclusion, version filtering)
5. ✅ Created script to upload and create Notion pages
6. ✅ Prepared 18 batch files for Notion page creation

## v7 (2025-12-10)
1. ✅ Created new SOP/SPEC for Inbound Response Analysis
2. ✅ Updated workspace memory with current status
3. ✅ Clarified authentication blockers
4. ✅ Documented all files prepared for Notion

---

# 🎯 CURRENT STATUS (v7/v8)

## ❌ NOT COMPLETE - BLOCKED BY AUTHENTICATION

**CURRENT STATUS:**
- ❌ **Files NOT uploaded to GitHub** - 0/174 uploaded
- ❌ **Notion pages NOT created** - 0/174 created  
- ❌ **Links NOT working** - Files don't exist in GitHub yet
- ✅ **Files analyzed and prepared** - 174 total (156 MD + 18 CSV)
- ✅ **Batch files created** - 18 batches ready for Notion
- ✅ **Scripts created** - Ready to execute when authenticated

**BLOCKER:** Authentication required
- GitHub upload requires: GITHUB_TOKEN (not set)
- Notion page creation requires: NOTION_API_TOKEN (not set) OR working MCP connection
- MCP tool calls failing: "Invalid tool arguments" error

## NEXT STEPS TO COMPLETE

1. **Set Authentication:**
   - Get GITHUB_TOKEN from GitHub settings (repo scope)
   - Get NOTION_API_TOKEN from Notion integrations
   - Set environment variables OR fix MCP connection

2. **Execute Upload:**
   - Run `load_md_and_relevant_csvs_to_notion_v20.py`
   - OR use batch files with MCP tools
   - OR upload manually

3. **Verify Results:**
   - Check GitHub NOTION repo for uploaded files
   - Check Notion Operations Portal for created pages
   - Test clickable links to ensure files open correctly

4. **Update Links:**
   - Once files are in GitHub, update Notion pages with working GitHub URLs
   - Replace "pending" status with actual file links

---

# 📚 KEY FILES CREATED

## Notion Integration Files
- `notion_config_v1.py` - Configuration
- `notion_api_v1.py` - API helper
- `sync_to_notion_v1.py` - Sync script
- `NOTION_SETUP_INSTRUCTIONS_v1.md` - Setup guide
- `NOTION_QUICKSTART_v1.md` - Quick start
- `NOTION_APPROACH_AND_EXPECTATIONS_v1.md` - Approach explanation
- `NOTION_PRIVACY_AND_ACCESS_DISCOVERY_v1.md` - Privacy questionnaire
- `NOTION_PRIVACY_EXPLAINED_v1.md` - Private sections guide

## Notion Load Scripts (v20)
- `load_all_md_files_to_notion_v20.py` - Initial MD-only loader
- `load_md_and_relevant_csvs_to_notion_v20.py` - Complete solution (MD + CSV)
- `filter_final_csvs_only_v20.py` - CSV filtering utility
- `execute_notion_creation_all_files_v20.py` - Batch file creator
- `create_notion_pages_batch_mcp_v20.py` - MCP preparation script

## Data Files
- `ALL_MD_FILES_ANALYZED_v20.json` - Pre-analyzed MD files
- `ALL_FILES_READY_FOR_NOTION_v20.json` - Complete file list
- `MD_FILES_ACCURATE_DETAILED_v6.csv` - 50 MD files with deep summaries
- `NOTION_BATCH_1_v20.json` through `NOTION_BATCH_18_v20.json` - 18 batch files

## Status Files
- `STATUS_NOTION_PAGES_v20.md` - Clear status report
- `WORKSPACE_MEMORY_v7_CURRENT_STATUS.md` - Previous status
- `WORKSPACE_MEMORY_MASTER_v8.md` - THIS FILE (master log)

## New SOP/SPEC Created
- `SOP_Twilio_Inbound_Response_Analysis_v1.md` - New SOP
- `SPEC_Twilio_Inbound_Response_Analysis_v1.md` - New SPEC

---

# 📝 CHANGELOG

| Version | Date | Major Changes |
|---------|------|---------------|
| v8 (MASTER) | 2025-12-10 | Combined all previous versions into single master log |
| v7 | 2025-12-10 | Current status, new SOP/SPEC, authentication blockers |
| v6 | 2025-12-10 | Notion load preparation, filtering logic, batch files |
| v5_COMPLETE_HANDOFF | 2025-12-11 | Report cataloging, GitHub solution, AWS config |
| v5 | 2025-12-11 | Notion MCP connected, privacy docs created, Google Drive options |
| v4 FINAL | 2025-12-11 | Handoff document, file organization decisions, master rules |
| v3 | 2025-12-11 | Engagement analysis, bot detection, file organization questionnaire |
| v2 | 2025-12-11 | CC/LC reports, Twilio analysis, technical learnings |
| v1 | 2025-12-10 | Initial workspace memory |

---

**Status:** ❌ **NOT COMPLETE - BLOCKED BY AUTHENTICATION**  
**Files in Notion:** 0/174  
**Working Links:** 0/174  
**Last Updated:** 2025-12-10  
**Version:** v8 (MASTER - All Versions Combined)

---

*This is the complete master log combining all workspace memory versions. Reference this document for all historical context, technical learnings, and current status.*


