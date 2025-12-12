# Notion Architecture Specification
**Version:** 1.0  
**Date:** 2025-12-11  
**Based on:** File Organization Discovery Questionnaire & Library Science Approach

---

## 📚 LIBRARY SCIENCE APPROACH

### Core Principle: **Product-First Hierarchy**

The file organization follows a **Library Science** approach where content is organized by:
1. **Product/System** (primary classification)
2. **Content Type** (secondary classification)
3. **Specific Item** (tertiary classification)

This mirrors how libraries organize books: **Subject → Category → Specific Book**

---

## 🏗️ ORIGINAL FILE ORGANIZATION STRUCTURE (From Questionnaire)

### Approved Structure (From Workspace Memory v4):

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

### Key Decisions:
- ✅ **Hierarchy:** Product-first: `TheGenie.ai/Operations/Reports/CompetitionCommand/`
- ✅ **Naming:** `[System]_[Type]_[Name]_[Date]_v#.ext`
- ✅ **Version Display:** Latest only + subtle changelog with links to history
- ✅ **Categories:** Operations, Growth, Support, Development, Applications

---

## 📋 NOTION ARCHITECTURE SPECIFICATION

### How Cursor Work is Organized (Current State):

#### Local File Structure (C:\Cursor\):

```
C:\Cursor\
├── TheGenie.ai\                    # Organized structure (NEW)
│   ├── Operations\
│   │   ├── Reports\
│   │   │   ├── CompetitionCommand\
│   │   │   ├── ListingCommand\
│   │   │   └── Twilio\
│   │   ├── SOPs\
│   │   ├── Specs\
│   │   └── Scripts\
│   ├── Growth\
│   ├── Support\
│   ├── Development\
│   │   ├── FeatureRequests\
│   │   └── SourceCode\
│   └── Applications\
│
├── Twilio\REPORTS\                 # Legacy location
├── GenieFeatureRequests\            # Legacy location
├── Genie.Source.Code_v1\           # Source code
├── GenieCLOUD_v1\                  # Cloud assets
├── reports_v1\                     # Legacy reports
└── [Various Python scripts]        # Root level scripts
```

#### Content Categories (Library Science Classification):

| Category | Count | Examples | Location |
|----------|------:|----------|----------|
| **SOPs** | ~8 | How to run reports, step-by-step processes | `TheGenie.ai/Operations/SOPs/` |
| **SPECs** | ~10 | Field definitions, data sources, SQL patterns | `TheGenie.ai/Operations/Specs/` |
| **REPORTS** | ~25 | CSV/Excel files with actual business data | `TheGenie.ai/Operations/Reports/[System]/` |
| **SCRIPTS** | ~40 | Code that generates reports | `TheGenie.ai/Operations/Scripts/` |
| **FEATURE REQUESTS** | ~3 | Design briefs, development specs | `TheGenie.ai/Development/FeatureRequests/` |
| **SOURCE CODE** | ~50 | C# handlers, stored procedures | `TheGenie.ai/Development/SourceCode/` |

---

## 🎯 CORRECT NOTION ARCHITECTURE (What Should Have Been Created)

### Structure Based on File Organization Decisions:

```
🏠 Steve Hundley's Workspace
│
├── 🏢 iStrategy / TheGenie.ai
│   │
│   ├── 📊 Operations
│   │   ├── 📈 Reports
│   │   │   ├── Competition Command
│   │   │   │   ├── CC Monthly Ownership Report (v5_iter2)
│   │   │   │   └── CC Monthly Cost Report (v5)
│   │   │   ├── Listing Command
│   │   │   │   └── LC Monthly Performance Report (v10)
│   │   │   └── Twilio
│   │   │       ├── Invoice Reconciliation
│   │   │       ├── Phone Inventory (v1)
│   │   │       ├── Phone Usage Assessment (v1)
│   │   │       ├── Delivery Farm Usage (v2)
│   │   │       └── Engagement Analysis (v1)
│   │   │
│   │   ├── 📋 SOPs
│   │   │   ├── SOP_CC_Ownership_Report_v5
│   │   │   ├── SOP_CC_Monthly_Cost_Report_v2
│   │   │   ├── SOP_LC_MonthlyPerformance_v1
│   │   │   └── SOP_Twilio_* (various)
│   │   │
│   │   ├── 📐 Specs
│   │   │   ├── SPEC_OwnedAreas_Report_v2
│   │   │   ├── SPEC_CompCommand_MonthlyCostReport_v3
│   │   │   ├── SPEC_LC_MonthlyPerformance_v2
│   │   │   └── SPEC_Twilio_PhoneNumber_Reports_v1
│   │   │
│   │   └── 💻 Scripts
│   │       ├── build_cc_ownership_LIVE_v2.py
│   │       ├── build_cc_monthly_report_v3.py
│   │       ├── build_lc_performance_v10.py
│   │       └── [Other Python scripts]
│   │
│   ├── 🚀 Growth
│   │   └── (Sales & Marketing content)
│   │
│   ├── 🛠️ Support
│   │   └── (Customer Experience content)
│   │
│   ├── 💻 Development
│   │   ├── Feature Requests
│   │   │   └── FR-001_AreaOwnership_*
│   │   └── Source Code
│   │       └── (References to Genie.Source.Code_v1)
│   │
│   └── 📱 Applications
│       ├── Competition Command
│       ├── Listing Command
│       ├── Neighborhood Command
│       ├── TitleGenie
│       ├── GeoSocial Audience Builder
│       └── AskPaisley
│
├── 🏡 Inspired Homes
│   └── (Structure TBD)
│
├── 🏠 Home Business
│   └── (Structure TBD)
│
├── 👤 Personal
│   └── (Structure TBD)
│
├── 💬 ChatGPT History
│   ├── Business Chats
│   ├── Personal Chats
│   └── Private Chats
│
└── 🔒 Private Vault
    ├── Credentials
    ├── Personal Notes
    └── Sensitive Business Data
```

---

## ⚠️ WHAT WAS ACTUALLY CREATED (Current State)

### Issues Identified:

1. **Operations Portal Created as Single Page**
   - ❌ Should be: Operations → Reports → [System] → [Report]
   - ✅ Created: Single "Operations Portal" page with all content

2. **Missing Hierarchical Structure**
   - ❌ Should have: Operations/Reports/CompetitionCommand/ structure
   - ✅ Created: Flat structure with Operations Portal as one page

3. **Missing Product-First Organization**
   - ❌ Should have: Reports organized by product (CC, LC, Twilio)
   - ✅ Created: All reports listed in one table

4. **Missing Content Type Separation**
   - ❌ Should have: Separate pages for Reports, SOPs, Specs, Scripts
   - ✅ Created: All mixed in Operations Portal page

---

## ✅ CORRECTED NOTION ARCHITECTURE SPEC

### Proper Structure (Library Science Approach):

```
🏢 iStrategy / TheGenie.ai
│
├── 📊 Operations (Page)
│   │
│   ├── 📈 Reports (Page/Database)
│   │   │
│   │   ├── Competition Command (Page)
│   │   │   ├── CC Monthly Ownership Report (v5_iter2) [Page]
│   │   │   └── CC Monthly Cost Report (v5) [Page]
│   │   │
│   │   ├── Listing Command (Page)
│   │   │   └── LC Monthly Performance Report (v10) [Page]
│   │   │
│   │   └── Twilio (Page)
│   │       ├── Invoice Reconciliation [Page]
│   │       ├── Phone Inventory (v1) [Page]
│   │       ├── Phone Usage Assessment (v1) [Page]
│   │       ├── Delivery Farm Usage (v2) [Page]
│   │       └── Engagement Analysis (v1) [Page]
│   │
│   ├── 📋 SOPs (Page/Database)
│   │   ├── SOP_CC_Ownership_Report_v5 [Page]
│   │   ├── SOP_CC_Monthly_Cost_Report_v2 [Page]
│   │   ├── SOP_LC_MonthlyPerformance_v1 [Page]
│   │   └── SOP_Twilio_* [Pages]
│   │
│   ├── 📐 Specs (Page/Database)
│   │   ├── SPEC_OwnedAreas_Report_v2 [Page]
│   │   ├── SPEC_CompCommand_MonthlyCostReport_v3 [Page]
│   │   ├── SPEC_LC_MonthlyPerformance_v2 [Page]
│   │   └── SPEC_Twilio_PhoneNumber_Reports_v1 [Page]
│   │
│   └── 💻 Scripts (Page/Database)
│       ├── build_cc_ownership_LIVE_v2.py [Page/File]
│       ├── build_cc_monthly_report_v3.py [Page/File]
│       ├── build_lc_performance_v10.py [Page/File]
│       └── [Other scripts] [Pages/Files]
│
├── 🚀 Growth (Page)
│   └── [Content TBD]
│
├── 🛠️ Support (Page)
│   └── [Content TBD]
│
├── 💻 Development (Page)
│   ├── Feature Requests (Page)
│   │   └── FR-001_AreaOwnership_* [Pages]
│   └── Source Code (Page)
│       └── [References to local source code]
│
└── 📱 Applications (Page)
    ├── Competition Command [Page]
    ├── Listing Command [Page]
    ├── Neighborhood Command [Page]
    ├── TitleGenie [Page]
    ├── GeoSocial Audience Builder [Page]
    └── AskPaisley [Page]
```

---

## 📊 MAPPING: Local Files → Notion Structure

### Current Cursor Work Organization:

| Local Path | Content Type | Should Map To Notion |
|------------|--------------|----------------------|
| `TheGenie.ai/Operations/Reports/CompetitionCommand/` | Reports | `Operations → Reports → Competition Command → [Report Pages]` |
| `TheGenie.ai/Operations/Reports/ListingCommand/` | Reports | `Operations → Reports → Listing Command → [Report Pages]` |
| `TheGenie.ai/Operations/Reports/Twilio/` | Reports | `Operations → Reports → Twilio → [Report Pages]` |
| `TheGenie.ai/Operations/SOPs/` | SOPs | `Operations → SOPs → [SOP Pages]` |
| `TheGenie.ai/Operations/Specs/` | Specs | `Operations → Specs → [Spec Pages]` |
| `TheGenie.ai/Operations/Scripts/` | Scripts | `Operations → Scripts → [Script Pages/Files]` |
| `TheGenie.ai/Development/FeatureRequests/` | Feature Requests | `Development → Feature Requests → [FR Pages]` |
| `GenieFeatureRequests/` | Feature Requests | `Development → Feature Requests → [FR Pages]` |
| `Twilio/REPORTS/` | Reports | `Operations → Reports → Twilio → [Report Pages]` |

---

## 🎯 LIBRARY SCIENCE PRINCIPLES APPLIED

### Classification System:

**Level 1: Business/Organization**
- iStrategy / TheGenie.ai
- Inspired Homes
- Home Business
- Personal

**Level 2: Functional Area**
- Operations
- Growth
- Support
- Development
- Applications

**Level 3: Content Type**
- Reports
- SOPs
- Specs
- Scripts
- Feature Requests

**Level 4: Product/System**
- Competition Command
- Listing Command
- Twilio
- [Other systems]

**Level 5: Specific Item**
- Individual reports
- Individual SOPs
- Individual specs
- Individual scripts

### Naming Convention (Applied):
```
[System]_[Type]_[Name]_[Date]_v[#].[ext]
```

**Examples:**
- `CC_Report_MonthlyOwnership_2025-12_v5_iter2.csv`
- `LC_Spec_Performance_v2.md`
- `Twilio_SOP_InvoiceReconciliation_v1.md`

---

## 📋 WHAT NEEDS TO BE FIXED

### Immediate Corrections Needed:

1. **Restructure Operations Portal**
   - ❌ Current: Single page with all content
   - ✅ Should be: Operations → Reports → [System] → [Report]

2. **Create Proper Hierarchy**
   - Create Operations page
   - Create Reports sub-page
   - Create Competition Command, Listing Command, Twilio sub-pages
   - Create individual report pages

3. **Separate Content Types**
   - Create separate SOPs page/database
   - Create separate Specs page/database
   - Create separate Scripts page/database

4. **Maintain Product-First Organization**
   - Reports organized by product (CC, LC, Twilio)
   - Each product has its own section
   - Each report is its own page

---

## ✅ CORRECTED IMPLEMENTATION PLAN

### Phase 1: Fix Structure
1. Create Operations page (not "Operations Portal")
2. Create Reports page under Operations
3. Create product sub-pages (Competition Command, Listing Command, Twilio)
4. Create individual report pages

### Phase 2: Migrate Content
1. Migrate reports to proper structure
2. Create SOPs page and migrate SOPs
3. Create Specs page and migrate Specs
4. Create Scripts page and link scripts

### Phase 3: Organize
1. Link related content (cross-links)
2. Add version history
3. Add changelogs
4. Organize by product

---

## 📚 LIBRARY SCIENCE METADATA

### Each Item Should Have:

**Report Metadata:**
- System (CC, LC, Twilio)
- Version (v5, v10, etc.)
- Date (2025-12-11)
- Script reference (link to script)
- SOP reference (link to SOP)
- Spec reference (link to spec)

**SOP Metadata:**
- Related Report
- Related Spec
- Version
- Last Updated

**Spec Metadata:**
- Related Report
- Related SOP
- Version
- Field definitions

---

*This spec defines the correct architecture based on the Library Science approach and file organization decisions.*

