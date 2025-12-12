# 📚 Genie Workspace File Catalog
**Version:** 1.0  
**Created:** 2025-12-11  
**Total Files Scanned:** 12,960  
**Relevant Files Cataloged:** ~200  

---

# 🗂️ CATALOG ORGANIZATION

## Quick Navigation
| System | SOP | Spec | Report | Script | Intel |
|--------|-----|------|--------|--------|-------|
| [Competition Command](#competition-command-cc) | [CC SOPs](#cc-sops) | [CC Specs](#cc-specifications) | [CC Reports](#cc-reports) | [CC Scripts](#cc-scripts) | [CC Intel](#cc-system-intel) |
| [Listing Command](#listing-command-lc) | [LC SOPs](#lc-sops) | [LC Specs](#lc-specifications) | [LC Reports](#lc-reports) | [LC Scripts](#lc-scripts) | [LC Intel](#lc-system-intel) |
| [Twilio Integration](#twilio-integration) | [Twilio SOPs](#twilio-sops) | [Twilio Specs](#twilio-specifications) | [Twilio Reports](#twilio-reports) | [Twilio Scripts](#twilio-scripts) | - |
| [Genie Core](#genie-core-platform) | - | - | - | - | [Core Intel](#genie-core-intel) |
| [Feature Requests](#feature-requests) | - | [FR Specs](#feature-request-specifications) | - | - | - |

---

# 🎯 COMPETITION COMMAND (CC)

## CC SOPs
*Standard Operating Procedures for Competition Command*

| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **SOP_CC_Ownership_Report_v5.md** | v5 (LATEST) | `GenieFeatureRequests/` | Area ownership report generation |
| **SOP_CC_Monthly_Cost_Report_v2.md** | v2 (LATEST) | `Twilio/.../REPORTS/` | Monthly cost report with invoice allocation |

## CC Specifications
*Technical specifications for CC reports and data*

| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **SPEC_OwnedAreas_Report_v2.md** | v2 (LATEST) | `Twilio/.../REPORTS/` | 14-column ownership report spec |
| **SPEC_CompCommand_MonthlyCostReport_v3.md** | v3 (LATEST) | `Twilio/.../REPORTS/` | Invoice-based cost allocation spec |
| **COMPLETE_FIELD_SPECIFICATION_v3.md** | v3 (LATEST) | `drive-download_v1/` | 21-field SMS report specification |

## CC Reports
*Latest output files (CSV/Excel)*

| Report | Version | Location | Description |
|--------|---------|----------|-------------|
| **Genie_CC_Ownership_LIFETIME_v5_iter2.csv** | v5 iter2 (LATEST) | `Twilio/.../REPORTS/` | Lifetime ownership with SMS/Clicks/CTR |
| **Genie_CompCommand_CostsByMonth_11-2025_v3.csv** | v3 (LATEST) | `Twilio/.../REPORTS/` | November 2025 monthly costs |
| **Genie_CompCommand_CostsByMonth_10-2025_v3.csv** | v3 (LATEST) | `Twilio/.../REPORTS/` | October 2025 monthly costs |
| **Genie_CompCommand_CostsByMonth_01-2025_v1.csv** | v1 | `Twilio/.../REPORTS/` | January 2025 monthly costs |

## CC Scripts
*Python scripts for CC report generation*

| Script | Version | Location | Purpose |
|--------|---------|----------|---------|
| **build_cc_ownership_LIVE_v2.py** | v2 (LATEST) | `Twilio/.../REPORTS/` | Live SQL → Ownership report |
| **build_cc_monthly_report_v3.py** | v3 (LATEST) | `Twilio/.../REPORTS/` | Monthly cost report generator |
| **build_cc_ownership_v2_iter2.py** | v2 iter2 | `Twilio/.../REPORTS/` | Ownership with engagement metrics |
| **analyze_trigger_types_v1.py** | v1 | `Twilio/.../REPORTS/` | CC trigger type analysis |

## CC System Intel
*System understanding and workflow documentation*

| Document | Location | Key Learning |
|----------|----------|--------------|
| **COMPETITION_COMMAND_WORKFLOW_COMPLETE.md** | `drive-download_v1/` | Full CC workflow documentation |
| **COMPETITION_COMMAND_WORKFLOW_GAP_ANALYSIS_v3.md** | `drive-download_v1/` | Workflow gaps and fixes |
| **COMPLETE_BLUEPRINT_COMPETITION_COMMAND_SMS_v1.md** | `drive-download_v1/` | SMS blueprint for CC |

### CC SQL Queries (Latest)
| Query | Location | Purpose |
|-------|----------|---------|
| **AllOwnedAreas_WithEndDate_LastCampaign.sql** | `drive-download_v1/` | Master ownership query |
| **0301.CC_SMS_WithDetails_v2_ULTRA_FAST_v6.sql** | `drive-download_v1/` | Optimized SMS details |
| **CC_SMS_Internal_Cost_Report_FINAL_v1.sql** | `drive-download_v1/` | Internal cost report |

---

# 📋 LISTING COMMAND (LC)

## LC SOPs
| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **SOP_LC_MonthlyPerformance_v1.md** | v1.2 (LATEST) | `Twilio/.../REPORTS/` | LC performance report generation |

## LC Specifications
| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **SPEC_LC_MonthlyPerformance_v2.md** | v2.2 (LATEST) | `Twilio/.../REPORTS/` | 21-column LC performance spec |

## LC Reports
| Report | Version | Location | Description |
|--------|---------|----------|-------------|
| **Genie_LC_MonthlyPerformance_2025-11_v10.csv** | v10 (LATEST) | `Twilio/.../REPORTS/` | November 2025 LC performance |

## LC Scripts
| Script | Version | Location | Purpose |
|--------|---------|----------|---------|
| **build_lc_performance_v10.py** | v10 (LATEST) | `Twilio/.../REPORTS/` | LC performance report generator |
| **investigate_lc_clicks_v1.py** | v1 | `Twilio/.../REPORTS/` | LC click tracking analysis |
| **investigate_lc_details_v2.py** | v2 | `Twilio/.../REPORTS/` | LC property address lookup |

## LC System Intel
*Key C# source files for understanding LC logic*

| File | Location | Purpose |
|------|----------|---------|
| **ListingCommandQueueHandler.cs** | `WindowsService/Smart.Service.ListingCommand/` | Order queuing logic |
| **ListingCommandV2Handler.cs** | `WindowsService/Smart.Service.ListingCommand/` | Action execution (SMS/FB/DM) |
| **ListingCommandProcessor.cs** | `WindowsService/Smart.Service.ListingCommand/` | Main processing logic |
| **ListingCommandService.cs** | `WindowsService/Smart.Service.ListingCommand/` | Service orchestration |

---

# 📞 TWILIO INTEGRATION

## Twilio SOPs
| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **SOP_Twilio_Invoice_Reconciliation_v1.md** | v1 (LATEST) | `Twilio/.../REPORTS/` | Invoice reconciliation process |
| **TWILIO_SETUP_INSTRUCTIONS.md** | v1 | `Twilio/` | API setup guide |

## Twilio Specifications
| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **BLUEPRINT_Twilio_Cost_Audit_v1.md** | v1 | `Twilio/` | Cost audit blueprint |
| **REPORT_TEMPLATES_Twilio_v1.md** | v1 | `Twilio/` | Report template definitions |

## Twilio Reports
| Report | Version | Location | Description |
|--------|---------|----------|-------------|
| **Genie_Twilio_Invoice_Recon_11-2025_COMPLETE.xlsx** | FINAL | `Twilio/.../REPORTS/` | November 2025 reconciliation |
| **Genie_Twilio_SMS_Detail_11-2025_v1.csv** | v1 | `Twilio/.../REPORTS/` | SMS detail breakdown |

## Twilio Scripts
| Script | Version | Location | Purpose |
|--------|---------|----------|---------|
| **final_recon_nov_v1.py** | v1 (LATEST) | `Twilio/.../REPORTS/` | Invoice reconciliation |
| **build_twilio_invoice_recon_v1.py** | v1 | `Twilio/.../REPORTS/` | Reconciliation builder |
| **investigate_twilio_costs_v4.py** | v4 (LATEST) | `Twilio/.../REPORTS/` | Cost investigation |

## Twilio SQL Queries
| Query | Version | Location | Purpose |
|-------|---------|----------|---------|
| **EXPORT_Twilio_ByCampaign_Aggregate_v2.sql** | v2 (LATEST) | `Twilio/` | Campaign-level aggregation |
| **EXPORT_Twilio_ByUser_v2.sql** | v2 (LATEST) | `Twilio/` | User-level export |
| **RECREATE_TWILIO_TABLES_v5_FINAL.sql** | v5 (LATEST) | `Twilio/` | Table creation script |

---

# 🏛️ GENIE CORE PLATFORM

## Genie Core Intel
*System-wide documentation and database guides*

| Document | Location | Description |
|----------|----------|-------------|
| **DATABASE_ACCESS_GUIDE.md** | `Twilio/` | SQL Server connection guide |
| **WORKSPACE_MEMORY_v2.md** | `C:\Cursor\` | Comprehensive session memory |
| **COMPLETE_DATABASE_ECOSYSTEM_AUDIT.md** | `drive-download_v1/` | Database structure analysis |
| **COMPLETE_SYSTEM_WORKFLOW.md** | `drive-download_v1/` | System workflow documentation |

## Genie API Documentation
| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **GenieCloud_SystemDocumentation_Business_v2.md** | v2 (LATEST) | `APIs/` | Cloud system docs |
| **GenieCloud_APIOnboarding_Business_v1.md** | v1 | `APIs/` | API onboarding guide |
| **GenieSource_API_InternalDocumentation_Business_v1.md** | v1 | `APIs/` | Internal API docs |

## MLS Integration
| Document/Query | Version | Location | Description |
|----------------|---------|----------|-------------|
| **MLSListing_Schema_Tables_Overview_v2.sql** | v2 (LATEST) | `APIs/` | MLS table schema |
| **MLSListing_Schema_Columns_Overview_v2.sql** | v2 (LATEST) | `APIs/` | MLS column details |
| **Post_Parser_Aggregation_Job_Analysis_v1.md** | v1 | `APIs/` | Parser job analysis |

---

# 🚀 FEATURE REQUESTS

## Feature Request Specifications
| Document | Version | Location | Description |
|----------|---------|----------|-------------|
| **FR-001_AreaOwnership_DevSpec_v2.md** | v2 (LATEST) | `GenieFeatureRequests/` | Area ownership dev spec |
| **FR-001_AreaOwnership_DesignBrief_v1.md** | v1 | `GenieFeatureRequests/` | Area ownership design |
| **FR-001_AreaOwnership_DiscoveryWorksheet_v1.md** | v1 | `GenieFeatureRequests/` | Discovery questions |

---

# 💻 SOURCE CODE INDEX

## Windows Services (Key Handlers)
*C# source code for background processing*

| Service | Key Files | Location |
|---------|-----------|----------|
| **Listing Command** | ListingCommandQueueHandler.cs, ListingCommandV2Handler.cs, ListingCommandProcessor.cs | `WindowsService/Smart.Service.ListingCommand/` |
| **Property Cast** | PropertyCastHandler.cs, PropertyCastProcessor.cs, PropertyCastWorkflow.cs | `WindowsService/Smart.Service.PropertyCast/` |
| **PropertyCaster Workflow** | PropertyCasterWorkflowHandler.cs, FarmCasterHandler.cs | `WindowsService/Smart.Service.PropertyCasterWorkflow/` |
| **Notification** | NotificationHandler.cs, SmsNotificationHandler.cs | `WindowsService/Smart.Service.Notification/` |
| **Neighborhood Command** | NeighborhoodCommandHandler.cs, NeighborhoodCommandProcessor.cs | `WindowsService/Smart.Service.NeighborhoodCommand/` |

## Cloud Components
*React/JavaScript frontend components*

| Component | Location | Description |
|-----------|----------|-------------|
| **genie-components** | `GenieCLOUD/genie-cloud/genie-components/` | React UI components |
| **genie-renderer** | `GenieCLOUD/genie-cloud/genie-renderer/` | Template rendering |
| **genie-api** | `GenieCLOUD/genie-cloud/genie-api/` | Cloud API layer |
| **public/templates** | `GenieCLOUD/genie-cloud/public/` | XSL templates, assets |

---

# 📊 REPORT INVENTORY BY MONTH

## November 2025 (Complete)
| Report Type | Latest File | Status |
|-------------|-------------|--------|
| CC Ownership Lifetime | Genie_CC_Ownership_LIFETIME_v5_iter2.csv | ✅ Complete |
| CC Monthly Cost | Genie_CompCommand_CostsByMonth_11-2025_v3.csv | ✅ Complete |
| LC Performance | Genie_LC_MonthlyPerformance_2025-11_v10.csv | ✅ Complete |
| Twilio Reconciliation | Genie_Twilio_Invoice_Recon_11-2025_COMPLETE.xlsx | ✅ Complete |

## October 2025
| Report Type | Latest File | Status |
|-------------|-------------|--------|
| CC Monthly Cost | Genie_CompCommand_CostsByMonth_10-2025_v3.csv | ✅ Complete |

## January 2025
| Report Type | Latest File | Status |
|-------------|-------------|--------|
| CC Monthly Cost | Genie_CompCommand_CostsByMonth_01-2025_v1.csv | ✅ Complete |

---

# 🗄️ FOLDER STRUCTURE SUMMARY

```
C:\Cursor\
│
├── 📁 GenieFeatureRequests/        ← Feature request documents, CC SOPs
│   ├── FR-001_AreaOwnership_*.md
│   └── SOP_CC_Ownership_Report_v5.md
│
├── 📁 Twilio-20251209T200757Z-3-001/Twilio/
│   ├── 📁 REPORTS/                 ← All report scripts and outputs
│   │   ├── SOP_*.md
│   │   ├── SPEC_*.md
│   │   ├── build_*.py
│   │   └── Genie_*.csv
│   ├── 📁 _invoices_11-14-2025/    ← Twilio invoice CSVs
│   └── DATABASE_ACCESS_GUIDE.md
│
├── 📁 Genie.Source.Code_v1/        ← C# Source code
│   └── Genie.Source.Code/
│       ├── Web/                    ← APIs and Web apps
│       └── WindowsService/         ← Background services
│
├── 📁 GenieCLOUD_v1/               ← Cloud/React components
│
├── 📁 APIs-20251209T192241Z-3-001/ ← API documentation and SQL
│
├── 📁 drive-download_v1/           ← Mac transferred files, SQL queries
│
├── 📁 reports_v1/                  ← Historical reports (.xlsx, .docx)
│
├── WORKSPACE_MEMORY_v2.md          ← Session memory (comprehensive)
└── GENIE_FILE_CATALOG_v1.md        ← This catalog
```

---

# 🔍 CROSS-REFERENCE INDEX

## By Database Table
| Table | Related Documents |
|-------|-------------------|
| `PropertyCast` | CC SOPs, CC Specs, FR-001_DevSpec |
| `PropertyCollectionDetail` | CC Scripts, CC SQL Queries |
| `ListingCommandQueue` | LC Specs, LC Scripts, ListingCommandQueueHandler.cs |
| `SmsReportSendQueue` | Twilio Scripts, CC/LC Performance Reports |
| `UserOwnedArea` | CC Ownership Report, FR-001_AreaOwnership_* |
| `GenieLead` | LC Performance Report, Click Calculation |
| `GenieLeadTag` | CTA/OptOut tracking in all reports |
| `TwilioMessage` | Twilio Reconciliation, Cost Reports |

## By Business Metric
| Metric | Where Calculated |
|--------|------------------|
| **Clicks** | `COUNT(DISTINCT GenieLeadId)` - LC/CC Performance |
| **CTR** | `Clicks / Msgs_Sent × 100` - All Performance Reports |
| **CTA Submitted** | `LeadTagTypeId = 48` - LC/CC Reports |
| **Opt-Outs** | `LeadTagTypeId = 51` - LC/CC Reports |
| **SMS Cost** | Invoice allocation - Monthly Cost Reports |

---

# ⚠️ SUPERSEDED FILES (DO NOT USE)

These files have been replaced by newer versions:

| Old File | Replaced By |
|----------|-------------|
| SOP_CC_Ownership_Report_v1-v4.md | v5 |
| SPEC_CompCommand_MonthlyCostReport_v1-v2.md | v3 |
| SPEC_OwnedAreas_Report_v1.md | v2 |
| build_lc_performance_v5-v9.py | v10 |
| Genie_CC_Ownership_Full_v1-v11.csv | LIFETIME_v5_iter2 |
| SPEC_LC_MonthlyPerformance_v1.md | v2 |

---

*Catalog generated: 2025-12-11*  
*Next update: After new reports or system changes*

