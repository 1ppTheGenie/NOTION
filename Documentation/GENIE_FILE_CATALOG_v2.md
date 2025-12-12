# 📚 GENIE WORKSPACE FILE CATALOG
## Master Index of All Relevant Files

**Version:** 2.0  
**Created:** 2025-12-11  
**Last Verified:** 2025-12-11 02:30 AM  
**Total Files Scanned:** 12,960  
**Relevant Files Cataloged:** 203  

---

# 📋 TABLE OF CONTENTS

1. [Master Reference Files](#1-master-reference-files)
2. [Competition Command (CC)](#2-competition-command-cc)
3. [Listing Command (LC)](#3-listing-command-lc)
4. [Twilio Integration](#4-twilio-integration)
5. [Genie Core Platform](#5-genie-core-platform)
6. [Feature Requests](#6-feature-requests)
7. [API Documentation](#7-api-documentation)
8. [Source Code Index](#8-source-code-index)
9. [SQL Query Library](#9-sql-query-library)
10. [Report Output Files](#10-report-output-files)
11. [Superseded Files](#11-superseded-files-do-not-use)
12. [Cross-Reference Index](#12-cross-reference-index)

---

# 1. MASTER REFERENCE FILES

*These files should be consulted before starting any task*

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [WORKSPACE_MEMORY_v2.md](WORKSPACE_MEMORY_v2.md) | v2 ✅ | 2025-12-11 01:33 | 16.6 KB | `C:\Cursor\` | Master rules, database access, technical learnings, all benchmarks |
| [GENIE_FILE_CATALOG_v2.md](GENIE_FILE_CATALOG_v2.md) | v2 ✅ | 2025-12-11 02:30 | ~25 KB | `C:\Cursor\` | This catalog - complete file index |
| [DATABASE_ACCESS_GUIDE.md](Twilio-20251209T200757Z-3-001/Twilio/DATABASE_ACCESS_GUIDE.md) | v1 | 2025-12-09 15:43 | 7.8 KB | `Twilio/` | SQL Server connection guide, pyodbc template |

---

# 2. COMPETITION COMMAND (CC)

## 2.1 CC Standard Operating Procedures (SOPs)

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [SOP_CC_Ownership_Report_v5.md](GenieFeatureRequests/SOP_CC_Ownership_Report_v5.md) | v5 ✅ | 2025-12-10 19:56 | 7.5 KB | `GenieFeatureRequests/` | Complete SOP for CC area ownership report generation. Includes PropertyCastTypeId=1 filter fix, area name fallbacks. |
| [SOP_CC_Monthly_Cost_Report_v2.md](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/SOP_CC_Monthly_Cost_Report_v2.md) | v2 ✅ | 2025-12-10 22:14 | 5.6 KB | `Twilio/.../REPORTS/` | Monthly cost report with invoice-based allocation methodology. |

## 2.2 CC Technical Specifications

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [SPEC_CompCommand_MonthlyCostReport_v3.md](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/SPEC_CompCommand_MonthlyCostReport_v3.md) | v3 ✅ | 2025-12-10 22:23 | 7.8 KB | `Twilio/.../REPORTS/` | 17-column spec. Invoice-based cost allocation. Includes UtmSource mapping. |
| [SPEC_OwnedAreas_Report_v2.md](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/SPEC_OwnedAreas_Report_v2.md) | v2 ✅ | 2025-12-10 20:30 | 4.3 KB | `Twilio/.../REPORTS/` | 14-column ownership report spec with SMS/Clicks/CTR metrics (Iteration 2). |
| [COMPLETE_FIELD_SPECIFICATION_v3.md](drive-download_v1/COMPLETE_FIELD_SPECIFICATION_v3.md) | v3 ✅ | 2025-11-07 16:43 | 25.7 KB | `drive-download_v1/` | Comprehensive 21-field SMS report specification from Mac. |

## 2.3 CC Python Scripts

| File Name | Version | Last Modified | Size | Path | Purpose |
|-----------|---------|---------------|------|------|---------|
| [build_cc_ownership_LIVE_v2.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/build_cc_ownership_LIVE_v2.py) | v2 ✅ | 2025-12-10 19:57 | 11.6 KB | `Twilio/.../REPORTS/` | Live SQL → CC Ownership report. Includes area name fallbacks, property type combining. |
| [build_cc_ownership_v2_iter2.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/build_cc_ownership_v2_iter2.py) | v2 iter2 ✅ | 2025-12-10 20:24 | 12.2 KB | `Twilio/.../REPORTS/` | Ownership report with engagement metrics (SMS, Clicks, CTR, Leads). |
| [build_cc_monthly_report_v3.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/build_cc_monthly_report_v3.py) | v3 ✅ | 2025-12-10 22:36 | 11.7 KB | `Twilio/.../REPORTS/` | Monthly cost report with invoice-based allocation. |
| [build_cc_monthly_cost_v2.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/build_cc_monthly_cost_v2.py) | v2 | 2025-12-10 22:14 | 9.6 KB | `Twilio/.../REPORTS/` | Multi-month cost report generator. |
| [analyze_trigger_types_v1.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/analyze_trigger_types_v1.py) | v1 | 2025-12-10 | ~5 KB | `Twilio/.../REPORTS/` | Analysis script proving CC uses BOTH trigger types (1 and 2). |

## 2.4 CC Report Outputs (Latest Only)

| File Name | Version | Last Modified | Path | Description |
|-----------|---------|---------------|------|-------------|
| [Genie_CC_Ownership_LIFETIME_2025-12-10_v5_iter2.csv](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/Genie_CC_Ownership_LIFETIME_2025-12-10_v5_iter2.csv) | v5 iter2 ✅ | 2025-12-10 20:23 | `REPORTS/` | Lifetime ownership with SMS, Clicks, CTR, Leads. 14 columns, 95 rows. |
| [Genie_CompCommand_CostsByMonth_11-2025_v3.csv](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/Genie_CompCommand_CostsByMonth_11-2025_v3.csv) | v3 ✅ | 2025-12-10 22:36 | `REPORTS/` | November 2025 monthly costs. Invoice-based allocation. |
| [Genie_CompCommand_CostsByMonth_10-2025_v3.csv](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/Genie_CompCommand_CostsByMonth_10-2025_v3.csv) | v3 ✅ | 2025-12-10 22:36 | `REPORTS/` | October 2025 monthly costs. |
| [Genie_CompCommand_CostsByMonth_01-2025_v1.csv](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/Genie_CompCommand_CostsByMonth_01-2025_v1.csv) | v1 | 2025-12-10 20:44 | `REPORTS/` | January 2025 monthly costs. |

## 2.5 CC System Intelligence

| File Name | Version | Last Modified | Size | Path | Key Learning |
|-----------|---------|---------------|------|------|--------------|
| [COMPETITION_COMMAND_WORKFLOW_COMPLETE.md](drive-download_v1/COMPETITION_COMMAND_WORKFLOW_COMPLETE.md) | v1 | 2025-11-08 10:36 | 20.6 KB | `drive-download_v1/` | Full CC workflow from listing trigger to SMS delivery. |
| [COMPETITION_COMMAND_WORKFLOW_GAP_ANALYSIS_v3.md](drive-download_v1/COMPETITION_COMMAND_WORKFLOW_GAP_ANALYSIS_v3.md) | v3 ✅ | 2025-11-11 20:26 | 20.7 KB | `drive-download_v1/` | Identified workflow gaps and fixes. |
| [COMPLETE_BLUEPRINT_COMPETITION_COMMAND_SMS_v1.md](drive-download_v1/COMPLETE_BLUEPRINT_COMPETITION_COMMAND_SMS_v1.md) | v1 | 2025-11-08 11:07 | 44.5 KB | `drive-download_v1/` | Comprehensive SMS blueprint for CC. Largest doc. |

---

# 3. LISTING COMMAND (LC)

## 3.1 LC Standard Operating Procedures

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [SOP_LC_MonthlyPerformance_v1.md](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/SOP_LC_MonthlyPerformance_v1.md) | v1.2 ✅ | 2025-12-11 01:27 | 5.0 KB | `Twilio/.../REPORTS/` | LC performance report SOP. Correct click calculation (COUNT DISTINCT GenieLeadId). 21 columns. |

## 3.2 LC Technical Specifications

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [SPEC_LC_MonthlyPerformance_v2.md](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/SPEC_LC_MonthlyPerformance_v2.md) | v2.2 ✅ | 2025-12-11 01:11 | 7.0 KB | `Twilio/.../REPORTS/` | 21-column spec. Order→Status→Channel model. Includes Profit_Pct. LeadTagTypeIds documented. |

## 3.3 LC Python Scripts

| File Name | Version | Last Modified | Size | Path | Purpose |
|-----------|---------|---------------|------|------|---------|
| [build_lc_performance_v10.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/build_lc_performance_v10.py) | v10 ✅ | 2025-12-11 01:15 | 10.3 KB | `Twilio/.../REPORTS/` | Final LC performance script. Correct clicks, channel splitting, all 21 columns. |
| [investigate_lc_clicks_v1.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/investigate_lc_clicks_v1.py) | v1 | 2025-12-10 | ~4 KB | `Twilio/.../REPORTS/` | Click tracking investigation - identified correct join path. |
| [investigate_lc_details_v2.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/investigate_lc_details_v2.py) | v2 ✅ | 2025-12-10 | ~5 KB | `Twilio/.../REPORTS/` | Property address extraction from ListingJson. |
| [get_addresses_from_mlslisting_v1.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/get_addresses_from_mlslisting_v1.py) | v1 | 2025-12-10 | ~3 KB | `Twilio/.../REPORTS/` | Full address lookup from MlsListing database. |

## 3.4 LC Report Outputs (Latest Only)

| File Name | Version | Last Modified | Path | Description |
|-----------|---------|---------------|------|-------------|
| [Genie_LC_MonthlyPerformance_2025-11_v10.csv](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/Genie_LC_MonthlyPerformance_2025-11_v10.csv) | v10 ✅ | 2025-12-11 01:16 | `REPORTS/` | November 2025 LC performance. 21 columns, 22 rows. Correct CTR (2.5%). |

## 3.5 LC Source Code Files (Key Handlers)

| File Name | Path | Summary |
|-----------|------|---------|
| ListingCommandQueueHandler.cs | `WindowsService/Smart.Service.ListingCommand/.../BLL/` | Order queuing logic. 1 Order = 1 MLS + 1-3 statuses. |
| ListingCommandV2Handler.cs | `WindowsService/Smart.Service.ListingCommand/.../Version/Handler/` | Action execution. SmsTarget, DirectMailTarget, FacebookTarget. |
| ListingCommandProcessor.cs | `WindowsService/Smart.Service.ListingCommand/.../BLL/` | Main processing orchestration. |
| ListingCommandService.cs | `WindowsService/Smart.Service.ListingCommand/.../BLL/` | Service layer. |
| ListingCommandWorkflowHandler.cs | `WindowsService/Smart.Service.ListingCommand/.../BLL/` | Workflow coordination. |

---

# 4. TWILIO INTEGRATION

## 4.1 Twilio SOPs

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [SOP_Twilio_Invoice_Reconciliation_v1.md](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/SOP_Twilio_Invoice_Reconciliation_v1.md) | v1 ✅ | 2025-12-10 22:06 | 9.6 KB | `Twilio/.../REPORTS/` | Complete invoice reconciliation process. Achieved 0.1% accuracy. |
| [TWILIO_SETUP_INSTRUCTIONS.md](Twilio-20251209T200757Z-3-001/Twilio/TWILIO_SETUP_INSTRUCTIONS.md) | v1 | 2025-12-09 14:09 | 5.7 KB | `Twilio/` | API setup, .env configuration. |

## 4.2 Twilio Specifications & Blueprints

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [BLUEPRINT_Twilio_Cost_Audit_v1.md](Twilio-20251209T200757Z-3-001/Twilio/BLUEPRINT_Twilio_Cost_Audit_v1.md) | v1 | 2025-12-09 14:09 | 8.2 KB | `Twilio/` | Cost audit blueprint. Data model, linkage, sample SQL. |
| [REPORT_TEMPLATES_Twilio_v1.md](Twilio-20251209T200757Z-3-001/Twilio/REPORT_TEMPLATES_Twilio_v1.md) | v1 | 2025-12-09 14:09 | 6.1 KB | `Twilio/` | 8 report template definitions. |
| [EXECUTION_INSTRUCTIONS_CSV_TWILIO.md](Twilio-20251209T200757Z-3-001/Twilio/EXECUTION_INSTRUCTIONS_CSV_TWILIO.md) | v1 | 2025-12-09 14:09 | 4.0 KB | `Twilio/` | CSV+Twilio report execution guide. |

## 4.3 Twilio Scripts

| File Name | Version | Last Modified | Size | Path | Purpose |
|-----------|---------|---------------|------|------|---------|
| [final_recon_nov_v1.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/final_recon_nov_v1.py) | v1 ✅ | 2025-12-10 | ~8 KB | `Twilio/.../REPORTS/` | November 2025 invoice reconciliation. Final version. |
| [build_twilio_invoice_recon_v1.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/build_twilio_invoice_recon_v1.py) | v1 | 2025-12-10 21:42 | 15.1 KB | `Twilio/.../REPORTS/` | General invoice reconciliation builder. |
| [investigate_twilio_costs_v4.py](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/investigate_twilio_costs_v4.py) | v4 ✅ | 2025-12-10 | ~6 KB | `Twilio/.../REPORTS/` | Cost investigation by service type. |

## 4.4 Twilio Report Outputs (Latest Only)

| File Name | Version | Last Modified | Path | Description |
|-----------|---------|---------------|------|-------------|
| [Genie_Twilio_Invoice_Recon_11-2025_COMPLETE.xlsx](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/Genie_Twilio_Invoice_Recon_11-2025_COMPLETE.xlsx) | FINAL ✅ | 2025-12-10 22:03 | `REPORTS/` | Complete November reconciliation. $722.89 invoice, $0.84 variance (0.1%). |
| [Genie_Twilio_SMS_Detail_11-2025_v1.csv](Twilio-20251209T200757Z-3-001/Twilio/REPORTS/Genie_Twilio_SMS_Detail_11-2025_v1.csv) | v1 | 2025-12-10 21:42 | `REPORTS/` | SMS detail breakdown by service. |

---

# 5. GENIE CORE PLATFORM

## 5.1 Platform Documentation

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [COMPLETE_SYSTEM_WORKFLOW.md](drive-download_v1/COMPLETE_SYSTEM_WORKFLOW.md) | v1 | 2025-11-07 15:04 | 11.5 KB | `drive-download_v1/` | End-to-end system workflow documentation. |
| [COMPLETE_DATABASE_INTERACTION_AUDIT.md](drive-download_v1/COMPLETE_DATABASE_INTERACTION_AUDIT.md) | v1 | 2025-11-08 09:47 | 7.2 KB | `drive-download_v1/` | Database interaction patterns audit. |
| [COMPLETE_WORKFLOW_INVENTORY.md](drive-download_v1/COMPLETE_WORKFLOW_INVENTORY.md) | v1 | 2025-11-08 11:15 | 9.4 KB | `drive-download_v1/` | Complete inventory of all workflows. |
| [DATABASE_ECOSYSTEM_AUDIT_ANALYSIS.md](drive-download_v1/DATABASE_ECOSYSTEM_AUDIT_ANALYSIS.md) | v1 | 2025-11-08 10:17 | 6.2 KB | `drive-download_v1/` | Database ecosystem analysis. |

## 5.2 Area/Zone Documentation

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [AREA_ID_HANDLING_GUIDE.md](drive-download_v1/AREA_ID_HANDLING_GUIDE.md) | v1 | 2025-11-11 18:34 | 5.3 KB | `drive-download_v1/` | How AreaId maps to zip codes. |
| [AREA_ID_VS_AREA_NAME_SPEC.md](drive-download_v1/AREA_ID_VS_AREA_NAME_SPEC.md) | v1 | 2025-11-11 18:34 | 2.8 KB | `drive-download_v1/` | AreaId vs AreaName distinction. |
| [AREA_NAME_DISPLAY_REQUIREMENTS.md](drive-download_v1/AREA_NAME_DISPLAY_REQUIREMENTS.md) | v1 | 2025-11-11 18:27 | 5.6 KB | `drive-download_v1/` | Area name display requirements. |

---

# 6. FEATURE REQUESTS

## 6.1 FR-001: Area Ownership & Waitlist System

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [FR-001_AreaOwnership_DevSpec_v2.md](GenieFeatureRequests/FR-001_AreaOwnership_DevSpec_v2.md) | v2 ✅ | 2025-12-10 19:57 | 38.7 KB | `GenieFeatureRequests/` | Full development spec. 6 iterations. SQL CREATE TABLE, stored procedures. Includes AreaCampaignHistory. |
| [FR-001_AreaOwnership_DesignBrief_v1.md](GenieFeatureRequests/FR-001_AreaOwnership_DesignBrief_v1.md) | v1 | 2025-12-10 15:36 | 13.6 KB | `GenieFeatureRequests/` | Design brief. Problem statement, proposed solution, user stories. |
| [FR-001_AreaOwnership_DiscoveryWorksheet_v1.md](GenieFeatureRequests/FR-001_AreaOwnership_DiscoveryWorksheet_v1.md) | v1 | 2025-12-10 15:36 | 9.1 KB | `GenieFeatureRequests/` | Discovery questions for stakeholder review. |

---

# 7. API DOCUMENTATION

| File Name | Version | Last Modified | Size | Path | Summary |
|-----------|---------|---------------|------|------|---------|
| [GenieCloud_SystemDocumentation_Business_v2.md](APIs-20251209T192241Z-3-001/APIs/GenieCloud_SystemDocumentation_Business_v2.md) | v2 ✅ | 2025-12-09 13:24 | 22.6 KB | `APIs/` | Cloud system architecture. Component relationships. |
| [GenieCloud_APIOnboarding_Business_v1.md](APIs-20251209T192241Z-3-001/APIs/GenieCloud_APIOnboarding_Business_v1.md) | v1 | 2025-12-09 13:24 | 7.5 KB | `APIs/` | API onboarding guide for new integrations. |
| [GenieSource_API_InternalDocumentation_Business_v1.md](APIs-20251209T192241Z-3-001/APIs/GenieSource_API_InternalDocumentation_Business_v1.md) | v1 | 2025-12-09 13:24 | 19.7 KB | `APIs/` | Internal API documentation. |
| [GenieSource_API_CustomerOnboarding_Business_v1.md](APIs-20251209T192241Z-3-001/APIs/GenieSource_API_CustomerOnboarding_Business_v1.md) | v1 | 2025-12-09 13:24 | 16.3 KB | `APIs/` | Customer-facing API onboarding. |
| [Post_Parser_Aggregation_Job_Analysis_v1.md](APIs-20251209T192241Z-3-001/APIs/Post_Parser_Aggregation_Job_Analysis_v1.md) | v1 | 2025-12-09 13:24 | 3.9 KB | `APIs/` | MLS parser job analysis. |

---

# 8. SOURCE CODE INDEX

## 8.1 Windows Services (C# Handlers)

### Listing Command Service
| File Name | Path | Purpose |
|-----------|------|---------|
| ListingCommandQueueHandler.cs | `Smart.Service.ListingCommand/.../BLL/` | Order queuing - 1 order = 1 MLS + 1-3 statuses |
| ListingCommandV2Handler.cs | `Smart.Service.ListingCommand/.../Version/Handler/` | Channel execution (SMS/FB/DM) |
| ListingCommandProcessor.cs | `Smart.Service.ListingCommand/.../BLL/` | Main processor |
| ListingCommandWorkflowHandler.cs | `Smart.Service.ListingCommand/.../BLL/` | Workflow orchestration |
| MlsListingService.cs | `Smart.Service.ListingCommand/.../BLL/` | MLS data integration |

### PropertyCast Service
| File Name | Path | Purpose |
|-----------|------|---------|
| PropertyCastHandler.cs | `Smart.Service.PropertyCast/` | Cast execution handler |
| PropertyCastProcessor.cs | `Smart.Service.PropertyCast/` | Cast processing logic |
| PropertyCastWorkflow.cs | `Smart.Service.PropertyCast/` | Workflow management |

### PropertyCaster Workflow Service
| File Name | Path | Purpose |
|-----------|------|---------|
| PropertyCasterWorkflowHandler.cs | `Smart.Service.PropertyCasterWorkflow/` | Workflow handler |
| FarmCasterHandler.cs | `Smart.Service.PropertyCasterWorkflow/` | FarmCast (CC) specific handler |
| SmsHandler.cs | `Smart.Service.PropertyCasterWorkflow/` | SMS execution handler |

### Notification Service
| File Name | Path | Purpose |
|-----------|------|---------|
| NotificationHandler.cs | `Smart.Service.Notification/` | Notification dispatch |
| SmsNotificationHandler.cs | `Smart.Service.Notification/` | SMS-specific notifications |
| NotificationQueueHandler.cs | `Smart.Service.Notification/` | Queue processing |

### Neighborhood Command Service
| File Name | Path | Purpose |
|-----------|------|---------|
| NeighborhoodCommandHandler.cs | `Smart.Service.NeighborhoodCommand/` | NC order handling |
| NeighborhoodCommandProcessor.cs | `Smart.Service.NeighborhoodCommand/` | NC processing |

## 8.2 Cloud Components (React/JavaScript)

| Component | Path | Purpose |
|-----------|------|---------|
| genie-components/ | `GenieCLOUD/genie-cloud/genie-components/` | React UI components (36 .jsx files) |
| genie-renderer/ | `GenieCLOUD/genie-cloud/genie-renderer/` | Template rendering engine |
| genie-api/ | `GenieCLOUD/genie-cloud/genie-api/` | Cloud API layer (11 .js files) |
| genie-processor/ | `GenieCLOUD/genie-cloud/genie-processor/` | Data processing |
| public/templates/ | `GenieCLOUD/genie-cloud/public/` | 429 XSL templates, 240 CSS files |

---

# 9. SQL QUERY LIBRARY

## 9.1 CC/LC Campaign Queries (Latest)

| File Name | Version | Path | Purpose |
|-----------|---------|------|---------|
| AllOwnedAreas_WithEndDate_LastCampaign.sql | v1 ✅ | `drive-download_v1/` | Master ownership query with end dates |
| 0301.CC_SMS_WithDetails_v2_ULTRA_FAST_v6.sql | v6 ✅ | `drive-download_v1/` | Optimized CC SMS details export |
| CC_SMS_Internal_Cost_Report_FINAL_v1.sql | FINAL ✅ | `drive-download_v1/` | Internal cost report query |
| 00000-all.stored.proceedures.sql | v1 | `drive-download_v1/` | All stored procedures dump |

## 9.2 Twilio Queries (Latest)

| File Name | Version | Path | Purpose |
|-----------|---------|------|---------|
| EXPORT_Twilio_ByCampaign_Aggregate_v2.sql | v2 ✅ | `Twilio/` | Campaign-level aggregation |
| EXPORT_Twilio_ByUser_v2.sql | v2 ✅ | `Twilio/` | User-level export |
| RECREATE_TWILIO_TABLES_v5_FINAL.sql | v5 ✅ | `Twilio/` | Table creation script |
| EXPORT_Twilio_Unlinked_v2.sql | v2 ✅ | `Twilio/` | Unlinked messages export |

## 9.3 MLS/Schema Queries (Latest)

| File Name | Version | Path | Purpose |
|-----------|---------|------|---------|
| MLSListing_Schema_Tables_Overview_v2.sql | v2 ✅ | `APIs/` | MLS table schema overview |
| MLSListing_Schema_Columns_Overview_v2.sql | v2 ✅ | `APIs/` | MLS column details |
| CHECK_SCHEMA_v1.1.sql | v1.1 ✅ | `drive-download_v1/` | General schema check |

---

# 10. REPORT OUTPUT FILES

## 10.1 November 2025 Reports (Complete)

| Report Name | File | Version | Created | Status |
|-------------|------|---------|---------|--------|
| CC Ownership Lifetime | Genie_CC_Ownership_LIFETIME_2025-12-10_v5_iter2.csv | v5 iter2 | 2025-12-10 20:23 | ✅ COMPLETE |
| CC Monthly Cost | Genie_CompCommand_CostsByMonth_11-2025_v3.csv | v3 | 2025-12-10 22:36 | ✅ COMPLETE |
| LC Monthly Performance | Genie_LC_MonthlyPerformance_2025-11_v10.csv | v10 | 2025-12-11 01:16 | ✅ COMPLETE |
| Twilio Invoice Reconciliation | Genie_Twilio_Invoice_Recon_11-2025_COMPLETE.xlsx | FINAL | 2025-12-10 22:03 | ✅ COMPLETE |

## 10.2 October 2025 Reports

| Report Name | File | Version | Created | Status |
|-------------|------|---------|---------|--------|
| CC Monthly Cost | Genie_CompCommand_CostsByMonth_10-2025_v3.csv | v3 | 2025-12-10 22:36 | ✅ COMPLETE |

## 10.3 January 2025 Reports

| Report Name | File | Version | Created | Status |
|-------------|------|---------|---------|--------|
| CC Monthly Cost | Genie_CompCommand_CostsByMonth_01-2025_v1.csv | v1 | 2025-12-10 20:44 | ✅ COMPLETE |

---

# 11. SUPERSEDED FILES (DO NOT USE)

*These files have been replaced by newer versions. Listed for reference only.*

## 11.1 Superseded SOPs

| Old File | Replaced By | Reason |
|----------|-------------|--------|
| SOP_CC_Ownership_Report_v1.md | v5 | Multiple iterations |
| SOP_CC_Ownership_Report_v2.md | v5 | " |
| SOP_CC_Ownership_Report_v3.md | v5 | " |
| SOP_CC_Ownership_Report_v4.md | v5 | " |
| SOP_CC_Monthly_Cost_Report_v1.md | v2 | Invoice-based update |

## 11.2 Superseded Specifications

| Old File | Replaced By | Reason |
|----------|-------------|--------|
| SPEC_CompCommand_MonthlyCostReport_v1.md | v3 | Multiple iterations |
| SPEC_CompCommand_MonthlyCostReport_v2.md | v3 | " |
| SPEC_OwnedAreas_Report_v1.md | v2 | Added iteration 2 metrics |
| SPEC_LC_MonthlyPerformance_v1.md | v2 | Click fix, Profit_Pct |
| FR-001_AreaOwnership_DevSpec_v1.md | v2 | Added AreaCampaignHistory |

## 11.3 Superseded Scripts

| Old File | Replaced By | Reason |
|----------|-------------|--------|
| build_lc_performance_v5-v9.py | v10 | Multiple bug fixes |
| build_cc_ownership_live_v1.py | LIVE_v2 | Area name fallbacks |
| build_cc_monthly_cost_v1.py | v2 | Invoice-based allocation |

## 11.4 Superseded Reports

| Old File | Replaced By | Reason |
|----------|-------------|--------|
| Genie_CC_Ownership_Full_v1-v11.csv | LIFETIME_v5_iter2 | Format fixes, metrics added |
| Genie_LC_MonthlyPerformance_v5-v9.csv | v10 | Click calculation fix |

---

# 12. CROSS-REFERENCE INDEX

## 12.1 By Database Table

| Table | Related Documents |
|-------|-------------------|
| PropertyCast | SOP_CC_Ownership_v5, SPEC_OwnedAreas_v2, FR-001_DevSpec_v2 |
| PropertyCollectionDetail | CC scripts, CC SQL queries |
| PropertyCastWorkflowQueue | FR-001_DevSpec_v2, CC workflow docs |
| ListingCommandQueue | SPEC_LC_MonthlyPerformance_v2, LC scripts, ListingCommandQueueHandler.cs |
| ListingCommandConfiguration | LC scripts, ListingCommandV2Handler.cs |
| SmsReportSendQueue | All performance reports, Twilio reconciliation |
| ViewSmsQueueSendSummary | CC/LC SMS counts |
| UserOwnedArea | CC Ownership Report, FR-001_AreaOwnership_* |
| AspNetUsers | All user reports |
| AspNetUserProfiles | Customer name lookups |
| GenieLead | Click calculation, LC/CC performance |
| GenieLeadTag | CTA/OptOut tracking (48, 51, 52) |
| ShortUrlData | Click tracking (DO NOT use AccessCount for clicks!) |
| ShortUrlDataLead | Lead tracking join table |
| TwilioMessage | Twilio reconciliation |
| MlsListing.Listing | LC property addresses |

## 12.2 By Business Metric

| Metric | Definition | Where Used |
|--------|------------|------------|
| **Clicks** | COUNT(DISTINCT GenieLeadId) | LC/CC Performance Reports |
| **CTR** | Clicks / Msgs_Sent × 100 | All Performance Reports |
| **CTA Submitted** | LeadTagTypeId = 48 | LC/CC Reports |
| **CTA Verified** | LeadTagTypeId = 52 | LC/CC Reports |
| **Opt-Outs** | LeadTagTypeId = 51 | LC/CC Reports |
| **SMS Cost** | Invoice allocation | Monthly Cost Reports |
| **Revenue** | Channel_Target × CostPerUnit | LC Performance |
| **Profit** | Revenue - Twilio_Cost | LC Performance |

## 12.3 By PropertyCastTypeId

| TypeId | Product | Key Files |
|--------|---------|-----------|
| 1 | Competition Command (FarmCast) | All CC_* files |
| 2 | Listing Command | All LC_* files |
| 3 | Neighborhood Command | NC service files |

---

# 📊 STATISTICS

| Category | Count |
|----------|-------|
| Total Files Scanned | 12,960 |
| Documentation Files (.md) | 113 |
| Python Scripts (.py) | 7,580 |
| C# Source Files (.cs) | 4,521 |
| SQL Queries (.sql) | 166 |
| Report Outputs (.csv/.xlsx) | 565 |
| **Relevant Files Cataloged** | **203** |

---

*Catalog Version: 2.0*  
*Last Verified: 2025-12-11 02:30 AM*  
*Next Review: After new reports or system changes*

**Good night! This catalog will be ready for your review. 🌙**

