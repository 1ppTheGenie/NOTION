# Accurate Detailed Analysis of .MD Files

Total files analyzed: 50

## Files by Classification

### 

**Count:** 4

#### GenieCloud_SystemDocumentation_Business_v2.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieCloud_SystemDocumentation_Business_v2.md`



---

#### GENIE_FILE_CATALOG_v2.md

**File Path:** `GENIE_FILE_CATALOG_v2.md`



---

#### SPEC_OwnedAreas_Report_v2.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_OwnedAreas_Report_v2.md`



---

#### SOP_CC_Monthly_Cost_Report_v1.md

**File Path:** `GenieFeatureRequests\SOP_CC_Monthly_Cost_Report_v1.md`



---

### Development > Documentation

**Count:** 7

#### COMPLETE_FIELD_SPECIFICATION_50_ROWS_v1.md

**File Path:** `drive-download_v1\COMPLETE_FIELD_SPECIFICATION_50_ROWS_v1.md`

Documentation file: Complete Field Specification - 50 Rows Report. Content analysis needed to determine specific value and classification.

---

#### COMPLETE_FIELD_SPECIFICATION_v3.md

**File Path:** `drive-download_v1\COMPLETE_FIELD_SPECIFICATION_v3.md`

Documentation file: Complete Field Specification v3 - Dave Higgins October 2025 Report. Content analysis needed to determine specific value and classification.

---

#### COMPLETE_FIELD_SPECIFICATION_5_ROWS_PER_COLUMN_v1.md

**File Path:** `drive-download_v1\COMPLETE_FIELD_SPECIFICATION_5_ROWS_PER_COLUMN_v1.md`

Documentation file: Complete Field Specification - 5 Rows Per Column. Content analysis needed to determine specific value and classification.

---

#### ACTION_PLAN_v5_VERIFICATION_v1.md

**File Path:** `drive-download_v1\ACTION_PLAN_v5_VERIFICATION_v1.md`

Documentation file: ACTION PLAN: Verify v5 Query Works. Content analysis needed to determine specific value and classification.

---

#### FILE_CATALOG_SUMMARY_v1.md

**File Path:** `FILE_CATALOG_SUMMARY_v1.md`

Documentation file: File Catalog Summary. Content analysis needed to determine specific value and classification.

---

#### GOOGLE_DRIVE_INTEGRATION_OPTIONS_v1.md

**File Path:** `GOOGLE_DRIVE_INTEGRATION_OPTIONS_v1.md`

Documentation file: Google Drive Integration Options for Cursor. Content analysis needed to determine specific value and classification.

---

#### COMPETITION_COMMAND_WORKFLOW_GAP_ANALYSIS_v3.md

**File Path:** `drive-download_v1\COMPETITION_COMMAND_WORKFLOW_GAP_ANALYSIS_v3.md`

Documentation file: Competition Command Workflow - Complete Gap Analysis. Content analysis needed to determine specific value and classification.

---

### Development > Documentation > System Analysis

**Count:** 1

#### Post_Parser_Aggregation_Job_Analysis_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\Post_Parser_Aggregation_Job_Analysis_v1.md`

Analysis Document: Post Parser Aggregation Job (Version 1). This document provides analysis and investigation results for locating and understanding the Post Parser Aggregation Job in the system.

WHAT IT CONTAINS:
- Search Results: Job is NOT a Windows Service but likely a SQL Server Agent Job
- Stored Procedures Found: Complete list of aggregation-related stored procedures:
  * AggregationMlsProcessingQueueInsert (inserts items into aggregation queue)
  * AggregationProcessingComplete (marks processing complete)
  * AggregationProcessingSetMls (sets MLS for processing)
  * AggregationQueueMonitor (monitors queue status)
- Related Procedures: Parser procedures in Master database (del_spMLSParserStatusUpdate, ExportMlsListingsMessageSend, ImportMlsListingsMessageSend)
- Process Flow Inference: Documents likely flow - MLS Parser completes → Updates status → Triggers aggregation → Queues MLS → Processes → Completes
- SQL Queries: Queries to find job in SQL Server Agent, check job steps, query aggregation queue tables
- Alternative Locations: Windows Task Scheduler, service configuration files, service logs
- Next Steps: Where to look, what to check, how to investigate further

WHO USES THIS: Operations team trying to understand how MLS data aggregation works after parsing completes, developers investigating aggregation job location.

WHY IT MATTERS: Essential for understanding the aggregation workflow and locating where the aggregation job is configured and running.

---

### Development > Documentation > Workspace Memory

**Count:** 2

#### WORKSPACE_MEMORY_v4_FINAL.md

**File Path:** `WORKSPACE_MEMORY_v4_FINAL.md`

Workspace Memory - FINAL HANDOFF (Version 4.0 FINAL, 800 words, December 11, 2025). This is the CRITICAL handoff document from previous agent to new agent, capturing all context and decisions.

WHAT IT CONTAINS:
- Critical Next Agent TODO: Immediate task to set up Notion integration (Workspace ID provided in document)
- File Organization Decisions: Complete approved folder structure (TheGenie.ai/Operations/Reports/CompetitionCommand/, etc.), naming conventions ([System]_[Type]_[Name]_[Date]_v#.ext), version display rules
- Master Rules: NEVER VIOLATE rules:
  * NEVER overwrite files - always version (_v1, _v2, etc.)
  * Clicks = COUNT(DISTINCT GenieLeadId) NOT AccessCount
  * CC uses PropertyCastTypeId = 1 with BOTH TriggerTypes 1 and 2
  * LeadTagTypeIds: 48=CTA, 51=OptOut, 52=Verified
  * GenieLeadPhone uses 'Phone' not 'PhoneNumber'
- Database Access: SERVER=192.168.29.45, USER=cursor, databases FarmGenie/MlsListing
- Key Findings: 5 bots to block, 6,697 missed opportunities, 24 orphan phone numbers
- AWS Configuration: bucket genie-cloud, profile genie-hub-active
- Reports Location: C:\Cursor\Twilio\REPORTS\
- Reason for Handoff: Previous agent failed to implement Notion integration

WHO USES THIS: New agent taking over work, current agent resuming, anyone needing complete context from previous sessions.

WHY IT MATTERS: ESSENTIAL for continuity. Contains all critical decisions, rules, configurations, and context. Without this, work is lost and decisions are forgotten.

---

#### WORKSPACE_MEMORY_v5.md

**File Path:** `WORKSPACE_MEMORY_v5.md`

Workspace Memory - Complete Reference (Version 5, 1698 words). Comprehensive reference document capturing all context, decisions, and key information.

WHAT IT CONTAINS:
- Notion Integration Status: MCP connection established, files created, privacy discovery completed
- File Organization: Approved structures, naming conventions, version rules
- Master Rules: Critical rules that must never be violated
- Database Access: Connection strings, credentials, database schemas
- Key Findings: Important discoveries and analysis results
- Configuration: AWS settings, report locations, system configurations
- Context: What was done, why, what worked, what didn't

WHO USES THIS: Agents resuming work, new team members, anyone needing complete context.

WHY IT MATTERS: Critical for maintaining continuity and ensuring nothing is lost between sessions.

---

### Development > Feature Requests

**Count:** 4

#### TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.md

**File Path:** `TheGenie_FileOrganization_DiscoveryQuestionnaire_v1.md`

Feature Request Discovery Worksheet: Area Ownership & Waitlist System (Version 1, 1,210 words). Worksheet capturing key decisions needed before development begins.

WHAT IT CONTAINS:
- Key Questions: Decisions that must be made before development
- Current Process: How things work now (A1)
- Pain Points: What problems exist (A2)
- Volume: Expected usage volumes (A3)
- Decisions: Space to document decisions made

WHO USES THIS: Product team making decisions, developers understanding requirements, stakeholders providing input.

WHY IT MATTERS: Ensures all key decisions are made before development starts, preventing rework and confusion.

---

#### FR-001_AreaOwnership_DesignBrief_v1.md

**File Path:** `GenieFeatureRequests\FR-001_AreaOwnership_DesignBrief_v1.md`

Feature Request Design Brief: Area Ownership & Waitlist System (FR-001, Version 1.0, December 2025, 1,586 words). Design and creative brief defining the design direction for the Area Ownership & Waitlist System feature.

WHAT IT CONTAINS:
- Executive Summary: 
  * The Problem: Current system has hard deletes (no history), no waitlist, no request workflow, audit gap
  * The Solution: Redesigned system with full ownership history (soft deletes), waitlist queue, request/approval workflow, admin dashboard, automated notifications
  * Business Value: Revenue protection, customer experience, operational efficiency, audit & compliance
- Current State Analysis: Existing UserOwnedArea schema and limitations
- Design Direction: How the new system should work
- User Experience: User flows and interactions
- Visual Design: UI/UX design elements

WHO USES THIS: Product team planning the feature, design team creating UI/UX, developers understanding design requirements, stakeholders understanding the vision.

WHY IT MATTERS: Defines the complete design and creative direction for FR-001 before development begins. Ensures everyone understands the problem, solution, and design approach.

---

#### FR-001_AreaOwnership_DevSpec_v2.md

**File Path:** `GenieFeatureRequests\FR-001_AreaOwnership_DevSpec_v2.md`

Feature Request Development Specification: Area Ownership & Waitlist System (Version 2.0, December 2025, 4,007 words). Complete technical specification for implementing FR-001.

WHAT IT CONTAINS:
- Iterative Development: Each iteration designed to be independently deployable and testable
- Target Timeline: Week 1-2 objectives
- Technical Approach: How to implement the feature
- Implementation Details: Complete technical specifications
- Testing: How to test each iteration

WHO USES THIS: Developers implementing the feature, QA team testing, product team tracking progress.

WHY IT MATTERS: Complete technical blueprint for building the feature. Essential for development.

---

#### FR-001_AreaOwnership_DiscoveryWorksheet_v1.md

**File Path:** `GenieFeatureRequests\FR-001_AreaOwnership_DiscoveryWorksheet_v1.md`

Feature Request Discovery Worksheet: Area Ownership & Waitlist System (Version 1, 1,210 words). Worksheet capturing key decisions needed before development begins.

WHAT IT CONTAINS:
- Key Questions: Decisions that must be made before development
- Current Process: How things work now (A1)
- Pain Points: What problems exist (A2)
- Volume: Expected usage volumes (A3)
- Decisions: Space to document decisions made

WHO USES THIS: Product team making decisions, developers understanding requirements, stakeholders providing input.

WHY IT MATTERS: Ensures all key decisions are made before development starts, preventing rework and confusion.

---

### Development > Platforms > Genie Cloud > Documentation > API Integration

**Count:** 1

#### GenieCloud_APIOnboarding_Business_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieCloud_APIOnboarding_Business_v1.md`

Genie Cloud API Onboarding Guide (Version 1.0, November 15, 2025). This document describes how to integrate with TheGenie HTTP APIs (/api/Data/*, /api/webhooks, /api/Zap/*) - these are TheGenie platform APIs, not GenieCloud-specific APIs.

WHAT IT DESCRIBES:
- API Endpoints: TheGenie HTTP APIs published at https://app.thegenie.ai/help:
  * /api/Data/* endpoints (CreateNewLead, GetAreaBoundary, GetAreaStatistics, QueueHubAssetGeneration, etc.)
  * /api/webhooks endpoints (Facebook lead ads webhook processing)
  * /api/Zap/* endpoints (Zapier connector endpoints like /api/Zap/Connect, /api/Zap/CreateLead)
- Onboarding Process: 7-step process (Kick-off call, Provision credentials, Environment validation, Schema mapping, Pilot build, Compliance review, Launch)
- Use Cases: Lead intake & enrichment, Campaign activation, Area & listing intelligence, Workflow rendering, Security & account setup
- Implementation Examples: Lead capture to nurture workflow, Market report generation, Zapier connector launch
- Requirements: Commercial agreement, API keys/OAuth, Production URL https://cloud-api.thegenie.ai/, Team readiness
- Best Practices: Credential hygiene, rate governance, logging, error handling, change management

WHO USES THIS: External API customers (business & technical stakeholders) integrating with TheGenie platform APIs, developers building integrations.

WHY IT MATTERS: Essential guide for customers integrating with TheGenie platform APIs. Note: These are TheGenie platform APIs, not GenieCloud-specific APIs. GenieCloud is the marketing automation platform that USES these APIs.

---

### Development > Platforms > Genie Cloud > Documentation > Internal

**Count:** 1

#### GenieCloud_SystemDocumentation_Internal_v1.md

**File Path:** `GenieCLOUD_v1\GenieCLOUD\genie-cloud-1\GenieCloud_SystemDocumentation_Internal_v1.md`

Genie Cloud System Documentation - Internal Technical (Version 1.0, November 15, 2025, 4,970 words). This is comprehensive documentation of the Genie Cloud marketing automation platform - an AWS-based serverless system that generates marketing materials.

WHAT IT DOCUMENTS:
- System Purpose: Real estate marketing automation platform that generates personalized, branded marketing materials (PDFs, landing pages, social media graphics, direct mail) for real estate agents
- Architecture: AWS serverless architecture using Lambda functions, S3, SQS, CloudFront
- Core Components:
  * genie-api Lambda: Main API gateway and orchestration (validates requests, manages auth, coordinates data fetching, creates render jobs)
  * genie-processor Lambda: XSLT transformer (transforms XML to HTML using Saxon-JS)
  * genie-renderer Lambda: Puppeteer/Chrome renderer (HTML to PDF, screenshots, videos)
- Technology Stack: Node.js version 18, Saxon-JS (XSLT 3.0), Puppeteer (headless Chrome), Sharp (image processing), AWS services
- Processing Flow: User request -> API -> SQS Queue -> Processor (XSLT) -> Renderer (Puppeteer) -> S3 Storage -> CloudFront CDN
- API Endpoints: 20+ endpoints documented for render requests, asset generation, utility functions
- Data Flow: Complete diagrams showing how data flows through the system
- AWS Infrastructure: S3 buckets, Lambda functions, SQS queues, CloudFront distribution
- Deployment: Procedures for deploying Lambda functions and infrastructure

WHO USES THIS: Developers working on Genie Cloud platform, operations team managing AWS infrastructure, anyone needing to understand how the marketing automation platform works.

WHY IT MATTERS: This is THE comprehensive reference for understanding the entire Genie Cloud platform architecture, components, data flows, and deployment. Essential for developers, operations, and system understanding.

---

### Development > Platforms > Genie Source > APIs > Documentation

**Count:** 2

#### GenieSource_API_CustomerOnboarding_Business_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieSource_API_CustomerOnboarding_Business_v1.md`

Genie Source API System Documentation (Version 1.0, November 15, 2025). This documents the Genie Source portfolio - a suite of ASP.NET Core and legacy WebAPI services that power internal and partner integrations.

WHAT IT DOCUMENTS:
- Service Inventory: 12 ASP.NET Core/WebAPI services:
  * Smart.Api.Authentication (JWT token issuance)
  * Smart.Api.DataAppend (Contact enrichment from multiple providers)
  * Smart.Api.GenieConnect (Public Genie Connect API)
  * Smart.Api.GenieConnectInternal (Internal Genie Connect)
  * Smart.Api.GenieSocket (SignalR conversation hub + token usage)
  * Smart.Api.MlsData (RESO-compliant MLS listing APIs)
  * Smart.Api.Notification (Email/SMS transactional messaging)
  * Smart.Api.Oculus (Legacy MLS bulk feeds)
  * Smart.Api.PrintHouse (Print fulfillment bridge)
  * Smart.Api.Storage (Blob storage abstractions)
  * Smart.Api.Utility (Logging endpoint)
  * Smart.Api.Wrapper (Outbound HTTP proxy)
- Architecture: .NET 6/7 ASP.NET Core minimal APIs (FastEndpoints) for newer services, traditional WebAPI for legacy
- Endpoints: Complete endpoint documentation for each service with authentication patterns, request/response formats
- Shared Infrastructure: Smart.Authentication.Core, Smart.Common.Model.Cache, Smart.Common.Model.Logging
- Deployment: Web apps expose RESTful endpoints, Windows Services for background processing

WHO USES THIS: Internal engineering team, platform operations, developers building integrations with Genie Source services.

WHY IT MATTERS: Complete catalog of all Genie Source API services, endpoints, authentication, and architecture. Essential reference for developers working with Genie Source platform.

---

#### GenieSource_API_InternalDocumentation_Business_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\GenieSource_API_InternalDocumentation_Business_v1.md`

Genie Source API System Documentation (Version 1.0, November 15, 2025). This documents the Genie Source portfolio - a suite of ASP.NET Core and legacy WebAPI services that power internal and partner integrations.

WHAT IT DOCUMENTS:
- Service Inventory: 12 ASP.NET Core/WebAPI services:
  * Smart.Api.Authentication (JWT token issuance)
  * Smart.Api.DataAppend (Contact enrichment from multiple providers)
  * Smart.Api.GenieConnect (Public Genie Connect API)
  * Smart.Api.GenieConnectInternal (Internal Genie Connect)
  * Smart.Api.GenieSocket (SignalR conversation hub + token usage)
  * Smart.Api.MlsData (RESO-compliant MLS listing APIs)
  * Smart.Api.Notification (Email/SMS transactional messaging)
  * Smart.Api.Oculus (Legacy MLS bulk feeds)
  * Smart.Api.PrintHouse (Print fulfillment bridge)
  * Smart.Api.Storage (Blob storage abstractions)
  * Smart.Api.Utility (Logging endpoint)
  * Smart.Api.Wrapper (Outbound HTTP proxy)
- Architecture: .NET 6/7 ASP.NET Core minimal APIs (FastEndpoints) for newer services, traditional WebAPI for legacy
- Endpoints: Complete endpoint documentation for each service with authentication patterns, request/response formats
- Shared Infrastructure: Smart.Authentication.Core, Smart.Common.Model.Cache, Smart.Common.Model.Logging
- Deployment: Web apps expose RESTful endpoints, Windows Services for background processing

WHO USES THIS: Internal engineering team, platform operations, developers building integrations with Genie Source services.

WHY IT MATTERS: Complete catalog of all Genie Source API services, endpoints, authentication, and architecture. Essential reference for developers working with Genie Source platform.

---

### Development > Specs > Bug Fixes

**Count:** 3

#### Fix_SMS_Report_Optimization_Error_v1.md

**File Path:** `APIs-20251209T192241Z-3-001\APIs\Fix_SMS_Report_Optimization_Error_v1.md`

Bug Fix Documentation: Fix: "Unable to load recently optimized source data report" Error. Documents bug fix process.

WHAT IT DOCUMENTS:
- Problem: Description and symptoms
- Root Cause: Analysis of why problem occurred
- Solution: How fix was implemented
- Validation: Testing and verification

WHO USES THIS: Developers, QA team, operations team.

WHY IT MATTERS: Documents bug fixes for tracking and preventing regression.

---

#### COMPREHENSIVE_FIX_DOCUMENT_v1.md

**File Path:** `drive-download_v1\COMPREHENSIVE_FIX_DOCUMENT_v1.md`

Bug Fix Documentation: COMPREHENSIVE FIX DOCUMENT - Complete Project Fix (641 words). Comprehensive fix document covering multiple issues and their resolutions.

WHAT IT DOCUMENTS:
- Root Cause: Identified core problems causing issues
- Fixes Required: Complete list of fixes needed (e.g., CTA Metrics Linking Fix, Data Flow Correction)
- Implementation: How each fix was implemented
- Validation: How fixes were tested and verified
- Files Updated: Which files were changed

WHO USES THIS: Developers understanding what was fixed, QA team validating fixes, operations team knowing what changed.

WHY IT MATTERS: Documents complete fix process ensuring all issues are resolved and nothing is missed.

---

#### COMPLETE_FIX_SUMMARY_FINAL_v1.md

**File Path:** `drive-download_v1\COMPLETE_FIX_SUMMARY_FINAL_v1.md`

Bug Fix Documentation: COMPLETE FIX SUMMARY - Final Resolution (641 words). Comprehensive fix document covering multiple issues and their resolutions.

WHAT IT DOCUMENTS:
- Root Cause: Identified core problems causing issues
- Fixes Required: Complete list of fixes needed (e.g., CTA Metrics Linking Fix, Data Flow Correction)
- Implementation: How each fix was implemented
- Validation: How fixes were tested and verified
- Files Updated: Which files were changed

WHO USES THIS: Developers understanding what was fixed, QA team validating fixes, operations team knowing what changed.

WHY IT MATTERS: Documents complete fix process ensuring all issues are resolved and nothing is missed.

---

### Development > Specs > Competition Command

**Count:** 1

#### SPEC_CompCommand_MonthlyCostReport_v3.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_CompCommand_MonthlyCostReport_v3.md`

Technical Specification: Competition Command Monthly Cost Report System (Version 3.0, December 2025, PRODUCTION). This is the complete technical blueprint for developers building and maintaining the Competition Command monthly cost reporting system.

WHAT IT DEFINES:
- Report Structure: Complete 17-column specification (Month, Customer_Name, Area_Name, Campaigns, Msgs_Sent, Delivered, Success%, Clicks, CTR%, CTA_Submitted, CTA_Verified, Agent_Notify, Agent_Notify_Cost, Opt_Outs, Opt_Out%, Twilio_Cost, Cost_Method)
- Cost Allocation Methodology: CRITICAL UPDATE from V2 - Uses ACTUAL Twilio invoice amounts, not estimates. Formula: Variable_SMS_Cost = Invoice Outbound Base + Invoice Carrier Fees, then CC_Cost = Variable_SMS_Cost × (CC_SMS_Count / Total_SMS_Count)
- Database Queries: Complete SQL queries for each data source:
  * Marketing SMS: SmsReportSendQueue + ViewSmsQueueSendSummary (UtmSource = 'Competition Command')
  * System SMS: NotificationQueue (NotificationChannelId = 1)
- Invoice Data Source: Location C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\_invoices_11-14-2025\, with Python code for extracting Variable SMS Cost (Outbound Base + Carrier Fees)
- Report Generation Time: Target < 2 minutes using live SQL queries + invoice data
- File Naming: Genie_CompCommand_CostsByMonth_[MM]-[YYYY]_v[#].csv
- Version History: Documents evolution from V1 (estimated) to V2 (partial invoice) to V3 (full invoice allocation with 0.1% accuracy)

WHO USES THIS: Developers building cost reporting tools, operations team understanding technical requirements, QA team validating report accuracy.

WHY IT MATTERS: This is the definitive technical specification ensuring cost reports are accurate within 0.1% of actual Twilio invoices. V3 fixes V2's 8% underestimate (V2 showed $333.24, V3 shows correct $360.78 for November 2025).

---

### Development > Specs > Listing Command

**Count:** 1

#### SPEC_LC_MonthlyPerformance_v2.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_LC_MonthlyPerformance_v2.md`

Technical Specification: Listing Command Performance Reporting System (Version 2). This document defines the technical requirements for building Listing Command performance dashboards and reports.

WHAT IT DEFINES:
- Performance Metrics: Definitions and calculations for performance metrics
- Data Sources: Database queries and data sources for each metric
- Report Structure: Field definitions and report formats
- Technical Requirements: Performance targets, data refresh rates, error handling

WHO USES THIS: Developers building Listing Command performance dashboards, product team understanding metrics.

WHY IT MATTERS: Technical blueprint ensuring consistent performance reporting across Listing Command product.

---

### Development > Specs > Notion

**Count:** 7

#### NOTION_APPROACH_AND_EXPECTATIONS_v1.md

**File Path:** `NOTION_APPROACH_AND_EXPECTATIONS_v1.md`

Notion + Cursor: Approach, Strategy & What to Expect (1,632 words, December 11, 2025). Document explaining the approach and strategy for using Notion with Cursor.

WHAT IT EXPLAINS:
- What is Notion: Overview of Notion platform and key features
- Approach: Strategy for TheGenie.ai documentation portal
- Vision: How Notion will be used for operations portal
- Content Structure: Based on user's decisions from questionnaire
- Expectations: What to expect from the Notion + Cursor combination

WHO USES THIS: Anyone understanding the Notion strategy, users learning about the approach.

WHY IT MATTERS: Explains the overall approach and sets expectations for how Notion will be used.

---

#### NOTION_QUESTIONNAIRE_SUMMARY_v1.md

**File Path:** `NOTION_QUESTIONNAIRE_SUMMARY_v1.md`

Notion Questionnaire Summary: Notion Privacy & Access Questionnaire - Summary of Answers (501 words, December 11, 2025). Summary of user's answers to Notion privacy and access discovery questionnaire.

WHAT IT CONTAINS:
- User Answers: Summary of all answers provided to privacy and access questions
- Key Decisions: Important decisions made based on questionnaire
- Requirements: Privacy and access requirements identified
- Next Steps: What to do based on answers

WHO USES THIS: Developers implementing privacy features, anyone understanding user requirements.

WHY IT MATTERS: Documents user's requirements for privacy and access control in Notion.

---

#### NOTION_IMPLEMENTATION_PLAN_v1.md

**File Path:** `NOTION_IMPLEMENTATION_PLAN_v1.md`

Notion Implementation Plan (1,108 words, December 11, 2025). Project plan for building the Notion documentation portal.

WHAT IT OUTLINES:
- Approach: Simple and flexible implementation strategy
- Structure Design: How to build the Notion structure
- Migration Plan: How to migrate files to Notion
- Maintenance Procedures: How to maintain the portal
- Step-by-Step Guide: Implementation steps

WHO USES THIS: Project managers, developers implementing the portal, operations team.

WHY IT MATTERS: Project plan ensuring the Notion portal is built correctly and maintained properly.

---

#### NOTION_DELETE_AND_RESTART_PLAN_v1.md

**File Path:** `NOTION_DELETE_AND_RESTART_PLAN_v1.md`

Notion Delete and Restart Plan (296 words, December 11, 2025). Plan for deleting incorrect Notion pages and restarting with correct architecture.

WHAT IT CONTAINS:
- Problem: Architecture was incorrect and didn't match user's answers
- Solution: Delete incorrect pages and restart with methodical 4-step process
- Steps: Catalog files, show architecture from answers, agree on structure, execute pattern matching
- Approach: Methodical process to avoid assumptions and get it right

WHO USES THIS: Anyone implementing the restart plan, developers cleaning up incorrect Notion structure.

WHY IT MATTERS: Documents the plan to fix incorrect architecture and restart with proper structure.

---

#### NOTION_ARCHITECTURE_SPEC_v1.md

**File Path:** `NOTION_ARCHITECTURE_SPEC_v1.md`

Notion Architecture Specification (Version 1.0, December 11, 2025, 1,657 words). This is the MASTER PLAN for organizing all documentation in Notion using Library Science principles.

WHAT IT DEFINES:
- Library Science Approach: Product-first hierarchy (Subject → Category → Item)
- Complete Structure: TheGenie.ai/Operations/Reports/CompetitionCommand/, etc.
- Functional Areas: Operations, Growth, Support, Development
- Content Types: Plans, Reports, SOPs, Presentations, Specs, Scripts
- Platform Hierarchy: Platforms > Applications (proper hierarchy)
- Classification Rules: How to classify files into the structure
- Best Practices: Information architecture and library science best practices

WHO USES THIS: Anyone building the Notion documentation portal, developers implementing the structure, content organizers.

WHY IT MATTERS: This is THE blueprint for the entire Notion operations portal. Every file classification should follow this structure. Essential reference for maintaining organized documentation.

---

#### NOTION_ARCHITECTURE_CORRECTION_v1.md

**File Path:** `NOTION_ARCHITECTURE_CORRECTION_v1.md`

Notion Architecture Correction: Twilio Classification (930 words, December 11, 2025). Document explaining correction made to Notion architecture - specifically that Twilio is a VENDOR, not an application.

WHAT IT EXPLAINS:
- Correction: Twilio is NOT a service or product - it's a VENDOR to 1parkplace for TheGenie.ai
- Classification Error: How Twilio was incorrectly classified at application level
- Correct Classification: Twilio should be classified as vendor/infrastructure, not as application
- Architecture Impact: How this correction affects the overall Notion structure

WHO USES THIS: Anyone understanding the architecture correction, developers implementing the corrected structure.

WHY IT MATTERS: Documents important correction to ensure Twilio is properly classified as vendor, not application.

---

#### NOTION_IMPORT_TheGenie_Operations_Portal_v1.md

**File Path:** `NOTION_IMPORT_TheGenie_Operations_Portal_v1.md`

Notion Import: TheGenie.ai Operations Portal (1,143 words, December 11, 2025). Document describing the vision and structure for the Notion operations portal.

WHAT IT DESCRIBES:
- Vision: Web-based documentation portal with permission-based access
- Structure: How content is organized in the portal
- Auto-Update: AI maintains it - user is never in the middle
- Reference: Structure like https://app.thegenie.ai/help
- Portal Design: How the portal should look and function

WHO USES THIS: Anyone understanding the portal vision, developers building the portal.

WHY IT MATTERS: Defines the vision and structure for the operations portal that will be built in Notion.

---

### Development > Specs > Twilio

**Count:** 1

#### SPEC_Twilio_PhoneNumber_Reports_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SPEC_Twilio_PhoneNumber_Reports_v1.md`

Technical Specification: Twilio Phone Number Reporting System. This document defines the complete technical requirements for building phone number inventory and management tools.

WHAT IT DEFINES:
- Data Sources: Twilio API endpoints, database tables (GenieLeadPhone, etc.)
- Report Structure: Field definitions for phone number inventory reports
- API Integration: How to integrate with Twilio API to fetch phone numbers
- Database Schema: Table relationships and data models
- Technical Requirements: Performance requirements, error handling, data validation

WHO USES THIS: Developers building phone number management systems, operations team understanding technical architecture.

WHY IT MATTERS: Blueprint for building reliable phone number inventory tools that accurately track phone number assets.

---

### Operations > Reports > Audits

**Count:** 2

#### CSV_EXPORT_AUDIT_FINAL_v3.md

**File Path:** `drive-download_v1\CSV_EXPORT_AUDIT_FINAL_v3.md`

Audit Report: CSV Export Audit Report - FINAL. Documents findings from system audit.

WHAT IT DOCUMENTS:
- Findings: What was found in the audit
- Issues: Problems identified
- Recommendations: What should be done
- Status: Current status of exports, processes, etc.

WHO USES THIS: Operations team, compliance team, management.

WHY IT MATTERS: Essential for compliance, quality assurance, and system improvement.

---

#### CSV_EXPORT_AUDIT_REPORT_UPDATED_v2.md

**File Path:** `drive-download_v1\CSV_EXPORT_AUDIT_REPORT_UPDATED_v2.md`

Audit Report: CSV Export Audit Report - UPDATED. Documents findings from system audit.

WHAT IT DOCUMENTS:
- Findings: What was found in the audit
- Issues: Problems identified
- Recommendations: What should be done
- Status: Current status of exports, processes, etc.

WHO USES THIS: Operations team, compliance team, management.

WHY IT MATTERS: Essential for compliance, quality assurance, and system improvement.

---

### Operations > Reports > Competition Command > Blueprints

**Count:** 1

#### COMPLETE_BLUEPRINT_COMPETITION_COMMAND_SMS_v1.md

**File Path:** `drive-download_v1\COMPLETE_BLUEPRINT_COMPETITION_COMMAND_SMS_v1.md`

Complete Blueprint: Competition Command SMS Workflow System (1,265+ lines, November 8, 2025). This is the MASTER REFERENCE document that provides ZERO MYSTERY documentation of the entire Competition Command SMS workflow system.

WHAT IT DOCUMENTS:
- Enumeration Definitions: Complete definitions of PropertyCastType (ID: 1 = CompetitionCommand), PropertyCastWorkflow (ID: 5 = DefaultSms), and ALL 30 WorkflowActionType IDs with their classes, purposes, APIs, and database tables
- Workflow Steps: Detailed breakdown of all 12 workflow steps:
  * Step 1: QueueOptimizePropertyCollection (Action ID 16) - Queues property collection for data append
  * Step 2: CheckOptimizationComplete (Action ID 17) - Polls ReportQueue for completion
  * Step 3-12: Complete documentation of each step including action IDs, C# class names, API endpoints, database tables, input/output, error handling
- Data Flow: Complete data flow diagrams showing how data moves from PropertyCast creation through optimization, asset generation, SMS queuing, sending, and completion
- Database Schema: All database tables involved (PropertyCast, PropertyCastWorkflowQueue, ReportQueue, SmsReportSendQueue, ViewSmsQueueSendSummary, etc.) with relationships
- API Endpoints: Complete API documentation for QueueSmsReportSend, CheckSmsReportSendComplete, and all workflow actions
- Source Code References: C# class names, method signatures, file locations
- Error Handling: Validation logic, retry mechanisms, failure modes

WHO USES THIS: Developers building or maintaining Competition Command system, operations team troubleshooting issues, anyone needing to understand how Competition Command SMS system works end-to-end.

WHY IT MATTERS: This is THE definitive reference. If you need to understand ANY aspect of how Competition Command SMS workflow works - from enum definitions to database tables to API calls to error handling - this document has it. Essential for debugging, development, and system understanding.

---

### Operations > Reports > Twilio > Blueprints

**Count:** 1

#### BLUEPRINT_Twilio_Cost_Audit_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\BLUEPRINT_Twilio_Cost_Audit_v1.md`

Blueprint: Twilio Cost & Usage Audit System (Version 1, November 14, 2025). This document defines the complete workflow and structure for building Twilio cost auditing tools.

WHAT IT DEFINES:
- Audit Workflow: Complete process for auditing Twilio costs and usage
- Data Sources: Invoice extraction, database queries, API integration
- Analysis Methods: How to analyze costs, identify anomalies, track trends
- Reporting Structure: Report formats, field definitions, output specifications

WHO USES THIS: Developers building cost management tools, operations team planning audits.

WHY IT MATTERS: Master plan for building comprehensive Twilio cost auditing and management systems.

---

### Operations > Reports > Twilio > Templates

**Count:** 1

#### REPORT_TEMPLATES_Twilio_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORT_TEMPLATES_Twilio_v1.md`

Twilio Report Templates (Version 1, November 14, 2025, 538 words). Documents the report templates available for Twilio reporting.

WHAT IT CONTAINS:
- Template 1: Campaign Cost Summary (ByCampaign_Summary)
- Template 2: Campaign Cost Detail (ByCampaign_Detail)
- Template 3: User Cost Summary (ByUser_Summary)
- Template 4: Unlinked Spend (Unlinked_ByCampaign)
- Template Structure: What each template contains

WHO USES THIS: Developers building reports, operations team generating reports, users understanding report options.

WHY IT MATTERS: Documents available report templates for Twilio, helping choose the right template for each use case.

---

### Operations > SOPs > Competition Command

**Count:** 2

#### SOP_CC_Ownership_Report_v5.md

**File Path:** `GenieFeatureRequests\SOP_CC_Ownership_Report_v5.md`

SOP: Competition Command Ownership Report Generation (Version 5). This Standard Operating Procedure documents the complete process for generating reports showing which geographic areas are owned by which agents.

WHAT IT CONTAINS:
- Purpose: Identify agent territory ownership and track ownership changes over time
- Data Sources: Database queries to extract area ownership data
- Report Structure: Documents what fields are included in ownership reports
- Script Usage: How to use Python scripts to generate the reports
- Area Coverage: Shows market coverage and agent territory assignments

WHO USES THIS: Operations and management teams needing to understand market coverage and agent territory distribution.

WHY IT MATTERS: Critical for management to track which agents own which geographic areas, plan territory assignments, and understand market coverage.

---

#### SOP_CC_Monthly_Cost_Report_v2.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_CC_Monthly_Cost_Report_v2.md`

SOP: Competition Command Monthly Cost Report Generation (Version 2.0). This Standard Operating Procedure provides complete step-by-step instructions for operations team to generate accurate monthly cost reports for Competition Command SMS campaigns.

WHAT IT CONTAINS:
- Methodology: Uses ACTUAL Twilio invoice costs (not estimates) - Version 2 changed from estimated $0.0083/segment to invoice-based allocation
- Data Sources: 
  * Twilio invoice CSV files located at C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\_invoices_11-14-2025\
  * Database queries against SmsReportSendQueue and ViewSmsQueueSendSummary tables
  * NotificationQueue table for system SMS counts
- Cost Allocation Formula: CC_Percentage = CC_SMS / Total_SMS, then CC_Cost = Variable_SMS_Cost × CC_Percentage
- Report Columns: 17 columns including Month, Customer_Name, Area_Name, Campaigns, Msgs_Sent, Delivered, Success%, Clicks, CTR%, CTA_Submitted, CTA_Verified, Opt_Outs, Twilio_Cost
- Script Execution: Documents how to run build_cc_monthly_cost_v2.py Python script
- Validation: Results must reconcile to invoice within 0.1% accuracy
- Benchmark Data: Includes expected ranges (CC % of Total SMS: 65-75%, Monthly Cost: $300-400)

WHO USES THIS: Operations team members responsible for generating monthly cost reports for management and financial reconciliation.

WHY IT MATTERS: Ensures accurate cost tracking that matches actual Twilio invoices, replacing previous estimation method that was underestimating costs by ~8%.

---

### Operations > SOPs > Listing Command

**Count:** 1

#### SOP_LC_MonthlyPerformance_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_LC_MonthlyPerformance_v1.md`

SOP: Listing Command Monthly Performance Report. This Standard Operating Procedure documents the procedure for generating monthly performance reports for Listing Command product.

WHAT IT CONTAINS:
- Data Extraction: How to extract listing data from database
- Performance Metrics: How to calculate performance metrics (views, clicks, conversions)
- Report Generation: Step-by-step process for creating performance reports
- Data Validation: How to validate report accuracy
- Stakeholder Delivery: How to deliver reports to stakeholders

WHO USES THIS: Operations team generating performance reports for Listing Command product stakeholders.

WHY IT MATTERS: Critical for tracking Listing Command product performance and providing stakeholders with accurate performance data.

---

### Operations > SOPs > Notion

**Count:** 4

#### NOTION_PRIVACY_EXPLAINED_v1.md

**File Path:** `NOTION_PRIVACY_EXPLAINED_v1.md`

Notion Privacy & Private Sections Guide: Notion Privacy & Private Sections - How It Works (1,187 words). Explains how Notion's privacy and access control features work.

WHAT IT EXPLAINS:
- Private Sections: How to create sections that only you can see (unshared pages method)
- Three Levels of Access: Workspace level, page level, block level
- Permission Management: How to control who can view, comment, or edit content
- Security Model: How Notion handles privacy and access control

WHO USES THIS: Anyone needing to understand how to create private content in Notion, developers implementing privacy features.

WHY IT MATTERS: Critical for understanding how to protect sensitive information while sharing other content with team.

---

#### NOTION_SETUP_INSTRUCTIONS_v1.md

**File Path:** `NOTION_SETUP_INSTRUCTIONS_v1.md`

Notion Setup/Quick Start Guide: Notion API Setup Instructions. Step-by-step instructions for setting up Notion integration with Cursor.

WHAT IT PROVIDES:
- API Key Generation: How to create Notion integration and get API key from https://www.notion.so/my-integrations
- Workspace Configuration: How to configure workspace ID (9b72e4ec-dce0-8155-a440-00039beadab4)
- Initial Setup: Step-by-step process to get started in 5 minutes
- Testing: How to test connection and verify integration works
- File Creation: Documents which Python files are created (notion_config_v1.py, notion_api_v1.py)

WHO USES THIS: Anyone setting up Notion integration for the first time, developers getting started with Notion API.

WHY IT MATTERS: Essential first step for getting Notion documentation portal working. Without this, integration cannot be established.

---

#### NOTION_QUICKSTART_v1.md

**File Path:** `NOTION_QUICKSTART_v1.md`

Notion Setup/Quick Start Guide: Notion Integration - Quick Start Guide. Step-by-step instructions for setting up Notion integration with Cursor.

WHAT IT PROVIDES:
- API Key Generation: How to create Notion integration and get API key from https://www.notion.so/my-integrations
- Workspace Configuration: How to configure workspace ID (9b72e4ec-dce0-8155-a440-00039beadab4)
- Initial Setup: Step-by-step process to get started in 5 minutes
- Testing: How to test connection and verify integration works
- File Creation: Documents which Python files are created (notion_config_v1.py, notion_api_v1.py)

WHO USES THIS: Anyone setting up Notion integration for the first time, developers getting started with Notion API.

WHY IT MATTERS: Essential first step for getting Notion documentation portal working. Without this, integration cannot be established.

---

#### NOTION_PRIVACY_AND_ACCESS_DISCOVERY_v1.md

**File Path:** `NOTION_PRIVACY_AND_ACCESS_DISCOVERY_v1.md`

Notion Privacy & Access Control Discovery Questionnaire (2,179 words). Comprehensive questionnaire for understanding privacy and access control requirements for Notion documentation portal.

WHAT IT CONTAINS:
- Privacy Questions: How should sensitive data be organized? Who should NEVER see sensitive data?
- Access Control Questions: What access levels are needed? How should Growth Team access work?
- Granular Access: Questions about page-level, block-level, and workspace-level permissions
- Private Sections: Questions about creating private sections for owner-only content
- Team Access: Questions about sharing with team members, permission levels

WHO USES THIS: User completing questionnaire to define privacy and access requirements, developers implementing access control.

WHY IT MATTERS: Foundation for designing privacy and access control system. Answers determine how content is organized and who can see what.

---

### Operations > SOPs > Twilio

**Count:** 3

#### SOP_Twilio_Phone_Inventory_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_Twilio_Phone_Inventory_v1.md`

SOP: Twilio Phone Number Inventory Report. This Standard Operating Procedure provides complete instructions for generating comprehensive phone number inventory reports from Twilio.

WHAT IT CONTAINS:
- Phone Number Extraction: How to pull all phone numbers from Twilio API
- Database Matching: Process for matching Twilio phone numbers to database records
- Orphan Detection: How to identify phone numbers in Twilio but not in database (orphaned numbers)
- Report Generation: Step-by-step process for creating inventory reports
- Status Tracking: How to track phone number status, usage, and associated costs
- Maintenance Procedures: How to keep phone number database accurate and up-to-date

WHO USES THIS: Operations team members managing SMS infrastructure and phone number assets.

WHY IT MATTERS: Essential for tracking phone number inventory, identifying unused numbers, managing costs, and ensuring database accuracy.

---

#### SOP_Twilio_DeliveryFarm_Usage_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_Twilio_DeliveryFarm_Usage_v1.md`

SOP: Twilio Delivery Farm Usage & Response Report. This Standard Operating Procedure explains how to generate reports tracking SMS delivery performance and response rates.

WHAT IT CONTAINS:
- Delivery Tracking: How to track SMS delivery rates and success percentages
- Response Monitoring: Process for monitoring response rates and engagement metrics
- Anomaly Detection: How to identify delivery anomalies and failures
- Usage Reporting: How to generate reports showing message volume by service (CC, LC, NC)
- Performance Analysis: How to analyze delivery performance over time
- Troubleshooting: Procedures for investigating delivery issues

WHO USES THIS: Operations team monitoring SMS campaign performance and identifying delivery problems.

WHY IT MATTERS: Essential for understanding SMS campaign effectiveness, identifying delivery problems, and optimizing message delivery.

---

#### SOP_Twilio_Invoice_Reconciliation_v1.md

**File Path:** `Twilio-20251209T200757Z-3-001\Twilio\REPORTS\SOP_Twilio_Invoice_Reconciliation_v1.md`

SOP: Twilio Invoice Reconciliation. This Standard Operating Procedure documents the complete process for reconciling Twilio invoices against actual system usage.

WHAT IT CONTAINS:
- Invoice Extraction: How to extract invoice data from Twilio CSV files
- Usage Matching: Process for matching invoice line items to actual database usage
- Cost Validation: How to validate costs against expected amounts
- Discrepancy Identification: Procedures for finding and documenting discrepancies
- Reconciliation Reports: How to generate reconciliation reports showing invoice vs. usage
- Error Handling: What to do when discrepancies are found

WHO USES THIS: Financial operations team responsible for validating Twilio billing and cost tracking.

WHY IT MATTERS: Critical for ensuring accurate billing, identifying billing errors, and maintaining financial accuracy.

---

