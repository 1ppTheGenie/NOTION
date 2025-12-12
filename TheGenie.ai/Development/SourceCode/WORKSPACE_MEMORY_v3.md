# Workspace Memory - Complete Reference
**Version:** 3.0  
**Last Updated:** 2025-12-11 10:15 AM  
**Session ID:** Deep Dive - Twilio Phone Numbers, Engagement Analysis, File Organization

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

## Rule 5: File Organization (NEW)
- Keep reports in organized folders by system (`Twilio\REPORTS`, etc.)
- Maintain landing page/index for file discovery
- **FILE ORGANIZATION QUESTIONNAIRE:** `TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.docx`

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

## 6. Lead Phone Data (NEW)

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

## 7. Opt-Out System (NEW)

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

## 8. Inbound Message Tracking (NEW)

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

# 📁 WORKSPACE STRUCTURE

## Root Folders
```
C:\Cursor\
├── WORKSPACE_MEMORY_v3.md         # THIS FILE
├── GENIE_FILE_CATALOG_v2.md       # Full file catalog
├── GENIE_FILE_CATALOG_v1.xlsx     # Excel version of catalog
├── TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.docx  # Team survey
│
├── GenieFeatureRequests\          # Feature request documents
│   ├── FR-001_AreaOwnership_DesignBrief_v1.md
│   ├── FR-001_AreaOwnership_DevSpec_v2.md
│   └── FR-001_AreaOwnership_DiscoveryWorksheet_v1.md
│
├── Twilio\                        # Organized Twilio reports (NEW!)
│   └── REPORTS\
│       ├── REPORT_ConversionByAgent_v1.csv
│       ├── REPORT_MissedOpportunities_ByAgent_v1.csv
│       ├── REPORT_PotentialBots_v1.csv
│       ├── REPORT_WarmLeads_ForFollowup_v1.csv
│       ├── Twilio_DeliveryFarm_Complete_2025_v1.csv
│       ├── Twilio_DeliveryFarm_Inbound_Analysis_v1.csv
│       ├── Twilio_DeliveryFarm_Usage2025_v2.csv
│       └── Twilio_DeliveryFarm_Usage_Responses_2025_v1.csv
│
├── Twilio-20251209T200757Z-3-001\Twilio\
│   ├── REPORTS\                   # CC/LC report scripts and outputs
│   ├── _invoices_11-14-2025\      # Twilio invoice CSVs
│   ├── DATABASE_ACCESS_GUIDE.md
│   ├── BLUEPRINT_Twilio_Cost_Audit_v1.md
│   └── REPORT_TEMPLATES_Twilio_v1.md
│
├── Genie.Source.Code_v1\          # C# Source code
├── GenieCLOUD_v1\                 # Cloud/React components
├── APIs-20251209T192241Z-3-001\   # API exports
├── drive-download_v1\             # Downloaded files from Mac
└── reports_v1\                    # Historical reports
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
| **Delivery Farm Complete Analysis** | Monthly breakdown with opt-outs | - | - | delivery_farm_complete_analysis_v1.py | Complete_2025_v1.csv |
| **Engagement Analysis** | Missed opportunities & warm leads | - | - | engagement_analysis_v1.py | Multiple reports |

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

## Lead/Engagement Flow (NEW)

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

---

# 🗂️ FILE ORGANIZATION PROJECT (NEW)

## Status: Discovery Phase

**Questionnaire Created:** `TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.docx`

### Key Decisions Pending:
1. Who accesses files? (Just owner / Team / External)
2. Folder hierarchy? (Product-first / Type-first / Hybrid)
3. Old versions? (Archive / Delete / Keep all)
4. Landing page format? (MD / Excel / HTML / All)
5. Naming convention approval

### Proposed Naming Convention:
```
[System]_[Type]_[Name]_[Date]_v[#].[ext]

Examples:
CC_Report_MonthlyOwnership_2025-12_v2.csv
LC_Spec_Performance_v3.md
Twilio_SOP_InvoiceReconciliation_v1.md
```

---

# ✅ SESSION ACCOMPLISHMENTS

## Today (2025-12-11)
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

## Previous Sessions
1. ✅ Extracted and organized all Mac workspace files
2. ✅ Established database connectivity to SQL Server
3. ✅ Built CC Ownership Report (Lifetime) with 14 columns
4. ✅ Built CC Monthly Cost Report with invoice-based allocation
5. ✅ Built LC Monthly Performance Report with 21 columns
6. ✅ Built Twilio Invoice Reconciliation Report
7. ✅ Created Feature Request FR-001 for Area Ownership System
8. ✅ Fixed critical click calculation error (AccessCount → GenieLeadId)
9. ✅ Fixed Competition Command trigger type filter
10. ✅ Built Twilio Phone Number Inventory Report (122 numbers)
11. ✅ Built Phone Usage Assessment (identified 24 orphan candidates)
12. ✅ Built Delivery Farm Usage & Response Report (73 numbers, 2.77% response rate)
13. ✅ Investigated anomaly phone +1 (408) 351-4056 - identified bot responder
14. ✅ Created SOPs and Specs for all Twilio phone reports

---

# 🎯 NEXT PRIORITIES

1. **Complete File Organization** - Get team responses to questionnaire, build folder structure
2. **Block Bot Numbers** - Execute SQL to add 5 bots to opt-out list
3. **Warm Lead Follow-up Workflow** - Route 6,697 missed opportunities to agents
4. **Fix Agent Matching** - Improve engagement → agent routing logic
5. **Release Orphan Numbers** - Save $355/year by releasing 24 unused numbers

---

*This file is permanent. Reference before starting any task. Update as new learnings are discovered.*

*Last Updated: 2025-12-11 10:15 AM by Cursor AI*

