# Accurate Analysis of .MD Files

Total files analyzed: 50

## Files by Classification

### 

**Count:** 2

#### GenieCloud_SystemDocumentation_Business_v2.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieCloud_SystemDocumentation_Business_v2.md`



---

#### SPEC_OwnedAreas_Report_v2.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_OwnedAreas_Report_v2.md`



---

### Development > Documentation

**Count:** 10

#### WORKSPACE_MEMORY_v4_FINAL.md

**File Path:** `WORKSPACE_MEMORY_v4_FINAL.md`

Documentation file: Workspace Memory - FINAL HANDOFF. Content analysis needed to determine specific value and detailed summary.

---

#### WORKSPACE_MEMORY_v5.md

**File Path:** `WORKSPACE_MEMORY_v5.md`

Documentation file: Workspace Memory - Complete Reference. Content analysis needed to determine specific value and detailed summary.

---

#### COMPLETE_FIELD_SPECIFICATION_50_ROWS_v1.md

**File Path:** `drive-download_v1\COMPLETE_FIELD_SPECIFICATION_50_ROWS_v1.md`

Documentation file: Complete Field Specification - 50 Rows Report. Content analysis needed to determine specific value and detailed summary.

---

#### COMPLETE_FIELD_SPECIFICATION_v3.md

**File Path:** `drive-download_v1\COMPLETE_FIELD_SPECIFICATION_v3.md`

Documentation file: Complete Field Specification v3 - Dave Higgins October 2025 Report. Content analysis needed to determine specific value and detailed summary.

---

#### COMPLETE_FIELD_SPECIFICATION_5_ROWS_PER_COLUMN_v1.md

**File Path:** `drive-download_v1\COMPLETE_FIELD_SPECIFICATION_5_ROWS_PER_COLUMN_v1.md`

Documentation file: Complete Field Specification - 5 Rows Per Column. Content analysis needed to determine specific value and detailed summary.

---

#### ACTION_PLAN_v5_VERIFICATION_v1.md

**File Path:** `drive-download_v1\ACTION_PLAN_v5_VERIFICATION_v1.md`

Documentation file: ACTION PLAN: Verify v5 Query Works. Content analysis needed to determine specific value and detailed summary.

---

#### FILE_CATALOG_SUMMARY_v1.md

**File Path:** `FILE_CATALOG_SUMMARY_v1.md`

Documentation file: File Catalog Summary. Content analysis needed to determine specific value and detailed summary.

---

#### GOOGLE_DRIVE_INTEGRATION_OPTIONS_v1.md

**File Path:** `GOOGLE_DRIVE_INTEGRATION_OPTIONS_v1.md`

Documentation file: Google Drive Integration Options for Cursor. Content analysis needed to determine specific value and detailed summary.

---

#### COMPETITION_COMMAND_WORKFLOW_GAP_ANALYSIS_v3.md

**File Path:** `drive-download_v1\COMPETITION_COMMAND_WORKFLOW_GAP_ANALYSIS_v3.md`

Documentation file: Competition Command Workflow - Complete Gap Analysis. Content analysis needed to determine specific value and detailed summary.

---

#### REPORT_TEMPLATES_Twilio_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORT_TEMPLATES_Twilio_v1.md`

Documentation file: Twilio Report Templates (v1, 11-14-2025). Content analysis needed to determine specific value and detailed summary.

---

### Development > Documentation > Catalogs

**Count:** 1

#### GENIE_FILE_CATALOG_v2.md

**File Path:** `GENIE_FILE_CATALOG_v2.md`

GENIE WORKSPACE FILE CATALOG (2,850 words). Master index of all relevant files in TheGenie.ai workspace.

ORGANIZED BY:
- Master Index of All Relevant Files
- CC Standard Operating Procedures (SOPs)
- CC Technical Specifications
- CC Python Scripts
- CC Report Outputs (Latest Only)

Includes file versions, dates, sizes, locations, and descriptions. Reference catalog for finding files.

---

### Development > Documentation > System Analysis

**Count:** 1

#### Post_Parser_Aggregation_Job_Analysis_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\Post_Parser_Aggregation_Job_Analysis_v1.md`

POST PARSER AGGREGATION JOB ANALYSIS (510 words). Analysis document for locating and understanding the Post Parser Aggregation Job in the MLS data processing system.

FINDINGS:
- Status: Not found as Windows Service in source code
- Likely Location: SQL Server Agent Job or external scheduler

STORED PROCEDURES IDENTIFIED:
- MlsListing Database: AggregationMlsProcessingQueueInsert, AggregationProcessingComplete, AggregationProcessingSetMls, AggregationQueueMonitor
- Master Database: del_spMLSParserStatusUpdate, ExportMlsListingsMessageSend, ImportMlsListingsMessageSend

PROCESS FLOW INFERRED:
1. MLS Parser completes → Updates status via del_spMLSParserStatusUpdate
2. Trigger/Job detects parser completion
3. Calls AggregationMlsProcessingQueueInsert → Queues MLS for aggregation
4. AggregationProcessingSetMls → Sets MLS ID for processing
5. Aggregation processing runs (likely in batches)
6. AggregationProcessingComplete → Marks processing complete
7. AggregationQueueMonitor → Monitors queue status

SQL QUERIES PROVIDED:
- Check SQL Server Agent Jobs for aggregation-related jobs
- Check job steps and commands
- Query aggregation queue tables
- Check stored procedure definitions

NEXT STEPS DOCUMENTED:
1. Check SQL Server Agent Jobs (most likely location)
2. Check Windows Task Scheduler
3. Query aggregation queue tables
4. Check service logs
5. Review stored procedure definitions

Essential for operations team trying to understand how MLS data aggregation works after parsing completes. Provides actionable steps for locating the job.

---

### Development > Feature Requests

**Count:** 3

#### FR-001_AreaOwnership_DesignBrief_v1.md

**File Path:** `GenieFeatureRequests\FR-001_AreaOwnership_DesignBrief_v1.md`

Feature request documentation: Feature Request: Area Ownership & Waitlist System. Describes business need, proposed solution, technical approach, and implementation requirements.

---

#### FR-001_AreaOwnership_DevSpec_v2.md

**File Path:** `GenieFeatureRequests\FR-001_AreaOwnership_DevSpec_v2.md`

FEATURE REQUEST DEVELOPMENT SPECIFICATION: Feature Request: Area Ownership & Waitlist System. Technical specification with iterative development details.

INCLUDES:
- Development Specification version
- Document Purpose
- Target timeline (e.g., Week 1-2)
- Objective and goals
- Iterative development approach
- Each iteration designed to be independently deployable and testable

Used by development teams to implement new features with clear technical requirements.

---

#### FR-001_AreaOwnership_DiscoveryWorksheet_v1.md

**File Path:** `GenieFeatureRequests\FR-001_AreaOwnership_DiscoveryWorksheet_v1.md`

FEATURE REQUEST DISCOVERY WORKSHEET: Feature Request Discovery Worksheet. Captures key decisions needed before development begins.

INCLUDES:
- Purpose and scope
- Current Process (A1)
- Pain Points (A2)
- Volume and scale (A3)
- Key questions requiring decisions
- Decision documentation

Used for gathering requirements and making architectural decisions before development starts.

---

### Development > Platforms > Genie Cloud > APIs > Documentation

**Count:** 1

#### GenieCloud_APIOnboarding_Business_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieCloud_APIOnboarding_Business_v1.md`

Genie Cloud API documentation - reading to understand specific APIs.

---

### Development > Platforms > Genie Cloud > Documentation > Internal

**Count:** 1

#### GenieCloud_SystemDocumentation_Internal_v1.md

**File Path:** `GenieCLOUD_v1\GenieCLOUD\genie-cloud-1\GenieCloud_SystemDocumentation_Internal_v1.md`

GENIE CLOUD PLATFORM DOCUMENTATION (Internal Technical, 4,970 words). Comprehensive system architecture documentation for the Genie Cloud marketing automation platform.

WHAT GENIE CLOUD ACTUALLY IS:
Genie Cloud is an AWS-based serverless platform that generates personalized, branded marketing materials for real estate agents. It transforms raw MLS data and market information into professional PDFs, landing pages, social media graphics, and direct mail pieces.

SYSTEM ARCHITECTURE:
- Runtime: Node.js 18.x on AWS Lambda (serverless)
- Core Components: genie-api (API gateway), genie-processor (XSLT transformer), genie-renderer (Puppeteer/Chrome)
- Storage: AWS S3 for assets, cache, and renders
- Queue: AWS SQS for asynchronous processing
- CDN: AWS CloudFront for content delivery

KEY CAPABILITIES:
- Automated Content Generation: Market reports, listing presentations, marketing materials on-demand
- Multi-Format Output: PDFs, PNG/WebP images, HTML landing pages, MP4 videos
- Personalization Engine: Applies agent branding, themes, customization
- Real-Time Data Integration: Pulls live MLS listings, market statistics, geographic data

TECHNOLOGY STACK:
- Saxon-JS: XSLT 3.0 transformations (XML to HTML)
- Puppeteer: Headless Chrome for rendering PDFs and images
- Sharp: Image processing and optimization
- pdf-lib: PDF manipulation and merging
- 400+ XSL templates for different asset types

PROCESSING FLOW:
1. User request → Genie API (Lambda) validates and creates render job
2. SQS queue → Genie Processor (XSLT transform XML to HTML)
3. S3 trigger → Genie Renderer (Puppeteer converts HTML to PDF/PNG/WebP/MP4)
4. Final assets stored in S3 with CloudFront CDN URLs

This is the CRITICAL REFERENCE for understanding the entire Genie Cloud platform architecture, components, data flows, infrastructure, and deployment procedures. Essential for developers, operations, and anyone working with the marketing automation platform.

---

### Development > Platforms > Genie Source > APIs > Documentation

**Count:** 2

#### GenieSource_API_CustomerOnboarding_Business_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieSource_API_CustomerOnboarding_Business_v1.md`

GENIE SOURCE API SYSTEM DOCUMENTATION (Version 1.0, November 2025). Internal engineering documentation for Genie Source API portfolio.

WHAT GENIE SOURCE IS:
Suite of ASP.NET Core and legacy WebAPI services that power internal and partner integrations. Each API is isolated in its own solution under Genie.Source.Code/Web, with shared business logic in Core, Data, and Model projects.

SERVICE INVENTORY (12 APIs):
1. Smart.Api.Authentication: JWT/access token issuance
2. Smart.Api.DataAppend: Contact enrichment (demographics, financial, address, audience)
3. Smart.Api.GenieConnect: External Genie Connect API (lead creation, Zapier, property optimization)
4. Smart.Api.GenieConnectInternal: Internal version with IP allow-list
5. Smart.Api.GenieSocket: SignalR conversation hub and token usage metrics
6. Smart.Api.MlsData: RESO-compliant MLS listing, open house, custom query endpoints
7. Smart.Api.Notification: Email and SMS transactional messaging
8. Smart.Api.Oculus: Legacy MLS bulk feed synchronization
9. Smart.Api.PrintHouse: Bridge between Genie asset generation and print vendors
10. Smart.Api.Storage: Abstraction over storage containers (Azure Blob)
11. Smart.Api.Utility: Internal logging endpoint for multi-service log aggregation
12. Smart.Api.Wrapper: HTTP proxy with shared retry/security policies

TECHNOLOGY:
- Language: .NET 6/7 ASP.NET Core minimal APIs (FastEndpoints) for newer services
- Legacy: Traditional ASP.NET WebAPI for DataAppend, Oculus
- Cross-Cutting: Smart.Authentication.Core, Smart.Common.Model.Cache, Smart.Common.Model.Logging
- Hosting: Web apps expose RESTful endpoints, Windows Services for scheduled processing

AUTHENTICATION PATTERNS:
- JWT tokens via Smart.Api.Authentication
- API key middleware for external APIs
- IP allow-list for internal APIs
- Policy-based authorization

This document catalogs every API surface, endpoint, authentication pattern, and primary dependencies. Used for internal development, refactoring, and scalability planning. Genie Source is DIFFERENT from Genie Cloud - it's the .NET API service layer.

---

#### GenieSource_API_InternalDocumentation_Business_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieSource_API_InternalDocumentation_Business_v1.md`

GENIE SOURCE API SYSTEM DOCUMENTATION (Version 1.0, November 2025). Internal engineering documentation for Genie Source API portfolio.

WHAT GENIE SOURCE IS:
Suite of ASP.NET Core and legacy WebAPI services that power internal and partner integrations. Each API is isolated in its own solution under Genie.Source.Code/Web, with shared business logic in Core, Data, and Model projects.

SERVICE INVENTORY (12 APIs):
1. Smart.Api.Authentication: JWT/access token issuance
2. Smart.Api.DataAppend: Contact enrichment (demographics, financial, address, audience)
3. Smart.Api.GenieConnect: External Genie Connect API (lead creation, Zapier, property optimization)
4. Smart.Api.GenieConnectInternal: Internal version with IP allow-list
5. Smart.Api.GenieSocket: SignalR conversation hub and token usage metrics
6. Smart.Api.MlsData: RESO-compliant MLS listing, open house, custom query endpoints
7. Smart.Api.Notification: Email and SMS transactional messaging
8. Smart.Api.Oculus: Legacy MLS bulk feed synchronization
9. Smart.Api.PrintHouse: Bridge between Genie asset generation and print vendors
10. Smart.Api.Storage: Abstraction over storage containers (Azure Blob)
11. Smart.Api.Utility: Internal logging endpoint for multi-service log aggregation
12. Smart.Api.Wrapper: HTTP proxy with shared retry/security policies

TECHNOLOGY:
- Language: .NET 6/7 ASP.NET Core minimal APIs (FastEndpoints) for newer services
- Legacy: Traditional ASP.NET WebAPI for DataAppend, Oculus
- Cross-Cutting: Smart.Authentication.Core, Smart.Common.Model.Cache, Smart.Common.Model.Logging
- Hosting: Web apps expose RESTful endpoints, Windows Services for scheduled processing

AUTHENTICATION PATTERNS:
- JWT tokens via Smart.Api.Authentication
- API key middleware for external APIs
- IP allow-list for internal APIs
- Policy-based authorization

This document catalogs every API surface, endpoint, authentication pattern, and primary dependencies. Used for internal development, refactoring, and scalability planning. Genie Source is DIFFERENT from Genie Cloud - it's the .NET API service layer.

---

### Development > Specs > Bug Fixes

**Count:** 3

#### Fix_SMS_Report_Optimization_Error_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\Fix_SMS_Report_Optimization_Error_v1.md`

Bug fix documentation: Fix: "Unable to load recently optimized source data report" Error. Documents problem, root cause analysis, solution approach, and implementation steps.

TYPICALLY INCLUDES:
- Problem Summary and symptoms
- Root Cause Analysis
- Code Location of issue
- Validation Logic
- Fix Options and implementation

Used for tracking issues, documenting resolutions, and preventing regression.

---

#### COMPREHENSIVE_FIX_DOCUMENT_v1.md

**File Path:** `drive-download_v1\COMPREHENSIVE_FIX_DOCUMENT_v1.md`

COMPREHENSIVE FIX DOCUMENTATION. Documents multiple bug fixes and their resolutions in a single document.

TYPICALLY INCLUDES:
- ROOT CAUSE IDENTIFIED for multiple issues
- The Core Problem affecting system
- FIXES REQUIRED with implementation steps
- DATA FLOW CORRECTION procedures
- Files updated and changes made

Provides complete picture of problems and solutions implemented. Used for tracking multiple related issues and their resolutions.

---

#### COMPLETE_FIX_SUMMARY_FINAL_v1.md

**File Path:** `drive-download_v1\COMPLETE_FIX_SUMMARY_FINAL_v1.md`

COMPREHENSIVE FIX DOCUMENTATION. Documents multiple bug fixes and their resolutions in a single document.

TYPICALLY INCLUDES:
- ROOT CAUSE IDENTIFIED for multiple issues
- The Core Problem affecting system
- FIXES REQUIRED with implementation steps
- DATA FLOW CORRECTION procedures
- Files updated and changes made

Provides complete picture of problems and solutions implemented. Used for tracking multiple related issues and their resolutions.

---

### Development > Specs > Competition Command

**Count:** 1

#### SPEC_CompCommand_MonthlyCostReport_v3.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_CompCommand_MonthlyCostReport_v3.md`

TECHNICAL SPECIFICATION: Competition Command Monthly Cost Report (Version 3.0, PRODUCTION, December 2025). Complete technical blueprint for building and maintaining the cost reporting system.

REPORT STRUCTURE (17 columns):
1. Month (YYYY-MM format)
2. Customer_Name (from AspNetUserProfiles)
3. Area_Name (from ViewArea.Name with fallback logic)
4. Campaigns (COUNT of SmsReportSendQueue batches)
5. Msgs_Sent (SUM of ViewSmsQueueSendSummary.Count)
6. Delivered (SUM where ResponseCode = 1)
7. Success% (Delivered / Msgs_Sent × 100)
8. Clicks (SUM of ShortUrlData.AccessCount)
9. CTR% (Clicks / Msgs_Sent × 100)
10. CTA_Submitted (COUNT GenieLeadTag where LeadTagTypeId = 48)
11. CTA_Verified (COUNT GenieLeadTag where LeadTagTypeId = 52)
12. Agent_Notify (placeholder for I2)
13. Agent_Notify_Cost (placeholder)
14. Opt_Outs (COUNT GenieLeadTag where LeadTagTypeId = 51)
15. Opt_Out% (Opt_Outs / Msgs_Sent × 100)
16. Twilio_Cost (Invoice-allocated, not estimated)
17. Cost_Method (indicates 'Invoice' allocation method)

CRITICAL METHODOLOGY CHANGE:
- V2 (Deprecated): Estimated costs using $0.0166/msg → Resulted in $333.24 for November (8% underestimate)
- V3 (Current): Actual invoice allocation → Result: $360.78 for November (within 0.1% of invoice)

COST ALLOCATION FORMULA:
Variable_SMS_Cost = Invoice Outbound Base + Invoice Carrier Fees
CC_Percentage = CC_SMS_Count / Total_SMS_Count
CC_Cost = Variable_SMS_Cost × CC_Percentage

DATA SOURCES SPECIFIED:
- Invoice files: C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\_invoices_11-14-2025\
- Database tables: SmsReportSendQueue, ViewSmsQueueSendSummary, NotificationQueue, GenieLeadTag, ShortUrlData
- SQL queries provided for each data source

TECHNICAL REQUIREMENTS:
- Report generation time: < 2 minutes using live SQL queries + invoice data
- File naming: Genie_CompCommand_CostsByMonth_[MM]-[YYYY]_v[#].csv
- Output format: CSV, UTF-8, comma-delimited, Google Sheets compatible

This specification is the technical blueprint for developers. Includes complete database schema references, SQL query examples, invoice extraction procedures, and validation rules. Version history documents evolution from estimated costs to invoice-allocated methodology.

---

### Development > Specs > File Organization

**Count:** 1

#### TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.md

**File Path:** `TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.md`

FILE ORGANIZATION SYSTEM SPECIFICATION. Defines how files should be structured, named, and organized in TheGenie.ai workspace.

INCLUDES:
- Discovery Questionnaire for understanding requirements
- Organizational principles and best practices
- Naming conventions
- Folder structure
- Classification system
- Library science approach

Blueprint for maintaining organized documentation and file structure. Foundation for making organizational decisions.

---

### Development > Specs > Listing Command

**Count:** 1

#### SPEC_LC_MonthlyPerformance_v2.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_LC_MonthlyPerformance_v2.md`

TECHNICAL SPECIFICATION: Listing Command Monthly Performance Report (Version 2). Defines technical requirements for performance reporting system.

SPECIFICATION INCLUDES:
- Performance metrics definitions and calculations
- Data sources: MlsListing database, listing views, engagement tracking
- Report structure with all field definitions
- Database queries for each metric
- Technical requirements for dashboard development

Blueprint for building Listing Command performance dashboards and reporting tools.

---

### Development > Specs > Notion

**Count:** 6

#### NOTION_APPROACH_AND_EXPECTATIONS_v1.md

**File Path:** `NOTION_APPROACH_AND_EXPECTATIONS_v1.md`

NOTION APPROACH & EXPECTATIONS. Explains what Notion is, key features, and the approach for TheGenie.ai documentation portal.

COVERS:
- What is Notion? (workspace, pages, databases, collaboration)
- Key features and capabilities
- Vision for TheGenie.ai operations portal
- Content structure based on user decisions
- What to expect from Notion + Cursor combination

Provides context and sets expectations for the Notion integration project.

---

#### NOTION_IMPLEMENTATION_PLAN_v1.md

**File Path:** `NOTION_IMPLEMENTATION_PLAN_v1.md`

NOTION IMPLEMENTATION PLAN. Outlines approach, strategy, migration plan, and maintenance procedures for building Notion documentation portal.

INCLUDES:
- Implementation approach and strategy
- Migration plan from current file structure
- Structure design based on library science
- Maintenance procedures
- Step-by-step implementation guide

Project plan for building the operations portal.

---

#### NOTION_DELETE_AND_RESTART_PLAN_v1.md

**File Path:** `NOTION_DELETE_AND_RESTART_PLAN_v1.md`

NOTION IMPLEMENTATION PLAN. Outlines approach, strategy, migration plan, and maintenance procedures for building Notion documentation portal.

INCLUDES:
- Implementation approach and strategy
- Migration plan from current file structure
- Structure design based on library science
- Maintenance procedures
- Step-by-step implementation guide

Project plan for building the operations portal.

---

#### NOTION_ARCHITECTURE_SPEC_v1.md

**File Path:** `NOTION_ARCHITECTURE_SPEC_v1.md`

NOTION ARCHITECTURE SPECIFICATION. Defines the complete structure and organization system for TheGenie.ai documentation portal in Notion.

ARCHITECTURE INCLUDES:
- Library science approach to classification
- Functional areas: Operations, Growth, Support, Development
- Content types: Plans, Reports, SOPs, Presentations, Specs, Scripts
- Platform hierarchy: Platforms > Applications (proper taxonomy)
- Classification rules and pattern matching
- Best practices from information architecture

This is the master plan for organizing all documentation in Notion. Blueprint for the operations portal structure.

---

#### NOTION_ARCHITECTURE_CORRECTION_v1.md

**File Path:** `NOTION_ARCHITECTURE_CORRECTION_v1.md`

NOTION ARCHITECTURE SPECIFICATION. Defines the complete structure and organization system for TheGenie.ai documentation portal in Notion.

ARCHITECTURE INCLUDES:
- Library science approach to classification
- Functional areas: Operations, Growth, Support, Development
- Content types: Plans, Reports, SOPs, Presentations, Specs, Scripts
- Platform hierarchy: Platforms > Applications (proper taxonomy)
- Classification rules and pattern matching
- Best practices from information architecture

This is the master plan for organizing all documentation in Notion. Blueprint for the operations portal structure.

---

#### NOTION_IMPORT_TheGenie_Operations_Portal_v1.md

**File Path:** `NOTION_IMPORT_TheGenie_Operations_Portal_v1.md`

NOTION IMPLEMENTATION PLAN. Outlines approach, strategy, migration plan, and maintenance procedures for building Notion documentation portal.

INCLUDES:
- Implementation approach and strategy
- Migration plan from current file structure
- Structure design based on library science
- Maintenance procedures
- Step-by-step implementation guide

Project plan for building the operations portal.

---

### Development > Specs > Twilio

**Count:** 1

#### SPEC_Twilio_PhoneNumber_Reports_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_Twilio_PhoneNumber_Reports_v1.md`

TECHNICAL SPECIFICATION: Twilio Phone Number Reports. Defines the complete technical architecture for phone number inventory and reporting system.

SPECIFICATION INCLUDES:
- Data sources: Twilio API endpoints, FarmGenie database tables
- Report structure and field definitions
- API integration patterns and authentication
- Database schema relationships (phone numbers to leads, campaigns, usage)
- Technical requirements for building phone number management tools
- Error handling and validation logic

Blueprint for developers building phone number inventory, tracking, and management systems.

---

### Operations > Reports > Audits

**Count:** 2

#### CSV_EXPORT_AUDIT_FINAL_v3.md

**File Path:** `drive-download_v1\CSV_EXPORT_AUDIT_FINAL_v3.md`

Audit report. Reading to understand specific audit findings.

---

#### CSV_EXPORT_AUDIT_REPORT_UPDATED_v2.md

**File Path:** `drive-download_v1\CSV_EXPORT_AUDIT_REPORT_UPDATED_v2.md`

Audit report. Reading to understand specific audit findings.

---

### Operations > Reports > Competition Command > Blueprints

**Count:** 1

#### COMPLETE_BLUEPRINT_COMPETITION_COMMAND_SMS_v1.md

**File Path:** `drive-download_v1\COMPLETE_BLUEPRINT_COMPETITION_COMMAND_SMS_v1.md`

COMPLETE BLUEPRINT: Competition Command SMS Workflow (1,265+ lines, November 8, 2025). Master reference document providing ZERO MYSTERY documentation of every element in the Competition Command SMS system.

WHAT THIS DOCUMENTS:
Complete end-to-end workflow for Competition Command SMS campaigns. Documents every enumeration, every workflow step, every database table, every API call, every class and method involved in the SMS sending process.

ENUMERATION DEFINITIONS:
- EnumPropertyCastType (ID: 1 = CompetitionCommand): Marketing campaign targeting property owners near subject property
- EnumPropertyCastWorkflow (ID: 5 = DefaultSms): Competition Command + SMS channel workflow template
- EnumWorkflowActionType (IDs 1-30): All 30 action types with class names, purposes, APIs, database tables

WORKFLOW STEP BREAKDOWN (12 Steps):
Each step documented with:
- WorkflowActionId and sequence
- Action class name and namespace
- Purpose and business logic
- API endpoints called
- Database tables read/written
- Input/output data structures
- Error handling and validation

DATA FLOW DIAGRAMS:
- How data moves from PropertyCast creation through optimization, asset generation, SMS queuing, delivery, and completion
- Database relationships and foreign keys
- Queue processing and status tracking

SOURCE CODE REFERENCES:
- Complete class names with namespaces
- Method signatures
- Configuration settings
- Error handling patterns

DATABASE SCHEMA:
- Every table involved: PropertyCast, PropertyCastWorkflowQueue, ReportQueue, SmsReportSendQueue, ViewSmsQueueSendSummary, GenieLeadTag, ShortUrlData
- Column definitions and relationships
- Index usage and query patterns

This is the MASTER REFERENCE for understanding how Competition Command SMS system works. Essential for developers building features, operations troubleshooting issues, and anyone needing complete system understanding. Documents every element with zero mystery.

---

### Operations > Reports > Twilio > Blueprints

**Count:** 1

#### BLUEPRINT_Twilio_Cost_Audit_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\BLUEPRINT_Twilio_Cost_Audit_v1.md`

BLUEPRINT: Twilio Cost & Usage Audit System (Version 1, November 14, 2025). Master plan for building comprehensive Twilio cost management and auditing tools.

BLUEPRINT INCLUDES:
- Complete workflow for cost auditing
- Data sources: Twilio API, invoice CSV files, database usage records
- Analysis methods: Cost allocation, usage tracking, anomaly detection
- Reporting structure: Cost reports, usage reports, reconciliation reports
- Technical architecture for building cost management tools

Used as the master plan for developing Twilio cost tracking and optimization systems.

---

### Operations > SOPs > Competition Command

**Count:** 3

#### SOP_CC_Monthly_Cost_Report_v1.md

**File Path:** `GenieFeatureRequests\SOP_CC_Monthly_Cost_Report_v1.md`

SOP for Competition Command cost reporting. Read file to understand specific procedures.

---

#### SOP_CC_Ownership_Report_v5.md

**File Path:** `GenieFeatureRequests\SOP_CC_Ownership_Report_v5.md`

SOP: Competition Command Ownership Report Generation (Version 5). Documents the complete operational procedure for generating reports showing which geographic areas are owned by which agents. 

PROCEDURES COVERED:
- Extracting area ownership data from database
- Identifying ownership changes over time
- Running Python scripts to generate ownership reports
- Validating area name fallbacks and data accuracy

Essential for management to understand market coverage and agent territory assignments. Used for tracking which agents own which geographic markets.

---

#### SOP_CC_Monthly_Cost_Report_v2.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_CC_Monthly_Cost_Report_v2.md`

SOP: Competition Command Monthly Cost Report Generation (Version 2.0). This operational procedure document provides complete step-by-step instructions for generating accurate monthly cost reports that reconcile actual Twilio invoice costs to Competition Command SMS usage. 

KEY PROCEDURES:
- Extracting variable SMS costs from Twilio invoice CSV files (Outbound Base + Carrier Fees)
- Querying database for Competition Command SMS counts from SmsReportSendQueue and ViewSmsQueueSendSummary tables
- Calculating proportional cost allocation: CC_Percentage = CC_SMS / Total_SMS, then CC_Cost = Variable_SMS_Cost × CC_Percentage
- Running Python script build_cc_monthly_cost_v2.py to generate CSV reports
- Validating results achieve 0.1% accuracy against invoice totals
- Understanding methodology change from V1 (estimated $0.0083/segment) to V2 (invoice-allocated)

DATA SOURCES DOCUMENTED:
- Invoice location: C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\_invoices_11-14-2025\
- Database tables: SmsReportSendQueue (UtmSource='Competition Command'), ViewSmsQueueSendSummary, NotificationQueue
- Report columns: Month, CC_Campaigns, CC_SMS, CC_Pct, CC_Cost, LC_SMS, LC_Cost, NC_SMS, NC_Cost, System_SMS, Total_SMS, Total_Variable_Cost, Segment_Ratio

BENCHMARK DATA INCLUDED:
- October 2025: 17,850 CC SMS, $320.22 cost
- November 2025: 19,875 CC SMS, $360.78 cost
- Expected ranges: 65-75% CC percentage, $300-400 monthly cost, 1.5-1.6x segment ratio

This SOP is essential for operations team to generate financial reports that accurately reflect actual Twilio costs rather than estimates. Includes troubleshooting steps and validation procedures.

---

### Operations > SOPs > Listing Command

**Count:** 1

#### SOP_LC_MonthlyPerformance_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_LC_MonthlyPerformance_v1.md`

SOP: Listing Command Monthly Performance Report. Documents procedure for generating monthly performance reports for Listing Command product.

PROCEDURES:
- Extracting listing data from MlsListing database
- Calculating performance metrics (views, clicks, conversions, engagement rates)
- Generating reports for stakeholders
- Validating data accuracy and completeness

Essential for tracking Listing Command product performance and providing insights to management.

---

### Operations > SOPs > Notion

**Count:** 5

#### NOTION_PRIVACY_EXPLAINED_v1.md

**File Path:** `NOTION_PRIVACY_EXPLAINED_v1.md`

NOTION PRIVACY EXPLAINED (1,187 words). Explains how Notion's privacy and access control features work.

KEY CONCEPTS:
- 🔒 Yes! Notion Has Private Sections
- 🛡️ How Notion Privacy Works
- Three Levels of Access Control (workspace, page, block)
- 🔐 Creating Private Sections
- Method 1: Unshared Pages (Recommended) - pages are private by default
- Method 2: Private Sections within shared pages
- Permission management and sharing controls

CRITICAL FOR:
Understanding security model, controlling who can see what content, creating private vaults for sensitive data (passwords, API keys, personal details).

---

#### NOTION_SETUP_INSTRUCTIONS_v1.md

**File Path:** `NOTION_SETUP_INSTRUCTIONS_v1.md`

NOTION SETUP GUIDE. Step-by-step instructions for setting up Notion integration with Cursor.

PROCEDURES:
- Creating Notion integration and getting API key
- Setting API token in configuration
- Sharing pages with integration
- Testing connection
- Quick start guide for 5-minute setup

Essential for getting started with Notion documentation portal.

---

#### NOTION_QUICKSTART_v1.md

**File Path:** `NOTION_QUICKSTART_v1.md`

NOTION SETUP GUIDE. Step-by-step instructions for setting up Notion integration with Cursor.

PROCEDURES:
- Creating Notion integration and getting API key
- Setting API token in configuration
- Sharing pages with integration
- Testing connection
- Quick start guide for 5-minute setup

Essential for getting started with Notion documentation portal.

---

#### NOTION_PRIVACY_AND_ACCESS_DISCOVERY_v1.md

**File Path:** `NOTION_PRIVACY_AND_ACCESS_DISCOVERY_v1.md`

NOTION PRIVACY & ACCESS DISCOVERY QUESTIONNAIRE. Comprehensive questionnaire for understanding privacy and access control requirements.

QUESTIONS COVER:
- Sensitive data types (credentials, API keys, personal info)
- Who should NEVER see sensitive data
- Access control requirements
- Private section structure needs
- Security and compliance requirements
- Workflow for managing private content

Used for gathering requirements before implementing privacy controls.

---

#### NOTION_QUESTIONNAIRE_SUMMARY_v1.md

**File Path:** `NOTION_QUESTIONNAIRE_SUMMARY_v1.md`

NOTION PRIVACY & ACCESS DISCOVERY QUESTIONNAIRE. Comprehensive questionnaire for understanding privacy and access control requirements.

QUESTIONS COVER:
- Sensitive data types (credentials, API keys, personal info)
- Who should NEVER see sensitive data
- Access control requirements
- Private section structure needs
- Security and compliance requirements
- Workflow for managing private content

Used for gathering requirements before implementing privacy controls.

---

### Operations > SOPs > Twilio

**Count:** 3

#### SOP_Twilio_Phone_Inventory_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_Twilio_Phone_Inventory_v1.md`

SOP: Twilio Phone Number Inventory Report. Complete step-by-step procedure for generating comprehensive phone number inventory reports.

PROCEDURES:
- Extracting all phone numbers from Twilio API
- Matching phone numbers to database records in FarmGenie database
- Identifying orphaned numbers (exist in Twilio but not in database)
- Generating inventory reports showing number status, usage patterns, and associated costs
- Maintaining phone number database accuracy

Used by operations team to manage SMS infrastructure assets and track phone number utilization.

---

#### SOP_Twilio_DeliveryFarm_Usage_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_Twilio_DeliveryFarm_Usage_v1.md`

SOP: Twilio Delivery Farm Usage & Response Report. Operational procedure for monitoring SMS delivery performance.

PROCEDURES:
- Tracking SMS delivery rates and success percentages
- Monitoring response rates and engagement metrics
- Identifying delivery anomalies and failures
- Generating usage reports showing message volume by service (Competition Command, Listing Command, Neighborhood Command)
- Analyzing delivery performance trends over time

Used for monitoring SMS campaign performance, identifying delivery issues, and optimizing message delivery rates.

---

#### SOP_Twilio_Invoice_Reconciliation_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_Twilio_Invoice_Reconciliation_v1.md`

SOP: Twilio Invoice Reconciliation. Documents the complete financial reconciliation process.

PROCEDURES:
- Extracting invoice data from Twilio CSV files
- Matching invoice line items to actual SMS usage in database
- Validating costs against expected amounts based on message volume
- Identifying discrepancies and cost anomalies
- Generating reconciliation reports for financial review

Critical for financial operations to ensure accurate billing, cost tracking, and budget management.

---

