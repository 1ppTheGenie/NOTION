# Complete Workflow Inventory - TheGenie.ai System

**Date:** November 8, 2025  
**Source:** Source Code Analysis + Stored Procedures Audit

---

## 📋 WORKFLOW TYPES (Product Types)

### Property Cast Types (`EnumPropertyCastType`)
1. **Competition Command** (ID: 1)
   - Product for targeting property owners near recently sold or active listings
   - Uses subject property to find nearby properties
   
2. **Listing Command** (ID: 2)
   - Product for targeting property owners when a new listing appears
   - Triggered by new MLS listings
   
3. **Neighborhood Command** (ID: 3)
   - Product for area-based marketing campaigns
   - Targets all properties in a defined area

---

## 🔄 WORKFLOW CONFIGURATIONS (Channel + Product Combinations)

### EnumPropertyCastWorkflow
These are the **configured workflow templates** that combine Product Type + Channel:

1. **DefaultDirectMail** (ID: 1)
   - Competition Command + Direct Mail channel
   
2. **DefaultFacebook** (ID: 4)
   - Competition Command + Facebook Ad channel
   
3. **DefaultSms** (ID: 5)
   - Competition Command + SMS channel
   
4. **ListingCommandSms** (ID: 6)
   - Listing Command + SMS channel
   
5. **ListingCommandFacebook** (ID: 7)
   - Listing Command + Facebook Ad channel
   
6. **ListingCommandDirectMail** (ID: 8)
   - Listing Command + Direct Mail channel
   
7. **Test** (ID: 9)
   - Test workflow configuration
   
8. **NeighborhoodCommandFacebook** (ID: 10)
   - Neighborhood Command + Facebook Ad channel
   
9. **NeighborhoodCommandSms** (ID: 11)
   - Neighborhood Command + SMS channel
   
10. **NeighborhoodCommandDirectMail** (ID: 12)
    - Neighborhood Command + Direct Mail channel

---

## ⚙️ WORKFLOW ACTION TYPES (Individual Steps)

### EnumWorkflowActionType
These are the **individual steps** that can be executed within any workflow:

1. **QueueOptimizePropertyCollection** (ID: 1)
   - Queues property collection for data append (phone, email, demographics, financial)
   
2. **CheckOptimizationComplete** (ID: 2)
   - Checks if optimization/data append is complete
   
3. **QueueHUBAssetGeneration** (ID: 3)
   - Queues Genie Cloud asset generation (PDFs, images)
   
4. **CheckHUBAssetGenerated** (ID: 4)
   - Checks if Genie Cloud asset generation is complete
   
5. **QueueDirectMail** (ID: 5)
   - Queues direct mail for printing
   
6. **NotifyInternal** (ID: 7)
   - Sends internal notification to agent/team
   
7. **WorkflowCompletedSuccessfully** (ID: 9)
   - Marks workflow as successfully completed
   
8. **QueueFacebookAudience** (ID: 10)
   - Queues Facebook custom audience creation
   
9. **CheckFacebookAudienceComplete** (ID: 11)
   - Checks if Facebook audience creation is complete
   
10. **CreateFacebookImageAd** (ID: 13)
    - Creates Facebook image ad campaign
    
11. **QueueSmsReportSend** (ID: 14)
    - Queues SMS report for sending via Twilio
    
12. **CheckSmsReportSendComplete** (ID: 15)
    - Checks if SMS sending is complete
    
13. **ShareFacebookCustomAudience** (ID: 16)
    - Shares Facebook custom audience with ad account
    
14. **CheckDirectMailQueueStatus** (ID: 17)
    - Checks if direct mail is ready to print
    
15. **SendDirectMailToPrinter** (ID: 18)
    - Sends direct mail to printer for processing
    
16. **GetPropertyFromListing** (ID: 19)
    - Retrieves property data from MLS listing
    
17. **CreatePropertyCollection** (ID: 20)
    - Creates property collection (legacy)
    
18. **QueueMappedHubAssetGeneration** (ID: 21)
    - Queues Genie Cloud asset generation with status-based mapping
    
19. **SetLandingPage** (ID: 22)
    - Sets landing page URL for campaign
    
20. **CreateFacebookTrafficImageAd** (ID: 23)
    - Creates Facebook traffic ad campaign
    
21. **CreateFacebookImagePost** (ID: 24)
    - Creates Facebook image post
    
22. **ProcessBilling** (ID: 25)
    - Processes billing/credits for campaign
    
23. **CheckCollectionSize** (ID: 26)
    - Validates property collection size meets requirements
    
24. **CreateCastPropertyCollection** (ID: 27)
    - Creates property collection for cast workflow
    
25. **LogCastPropertyCollection** (ID: 28)
    - Logs property collection creation
    
26. **GetOptimalStatsInterval** (ID: 29)
    - Gets optimal statistics interval for area data
    
27. **WorkflowDelay** (ID: 30)
    - Adds delay between workflow steps

---

## 🗄️ DATABASE QUEUES

### Primary Workflow Queues:
1. **PropertyCastWorkflowQueue**
   - Main workflow queue table
   - Links to `PropertyCastWorkflow` (workflow configuration)
   - Contains: `PropertyCastId`, `PropertyCollectionDetailId`, `PropertyId`, `MlsId`, `MlsNumber`

2. **PropertyCastWorkflowQueueItem**
   - Individual workflow action items
   - Links to `PropertyCastWorkflowAction` (action configuration)
   - Contains: `WorkflowActionId`, `ResponseCode`, `ResponseDescription`, `StartDate`, `CompleteDate`, `Retries`

3. **SmsReportSendQueue**
   - Queue for SMS report sending
   - Links to `PropertyCollectionDetailId`
   - Contains: `SmsReportSendQueueId`, `PropertyCollectionDetailId`, `Status`

4. **FacebookAudienceQueue**
   - Queue for Facebook audience creation
   - Links to `PropertyCollectionDetailId`

5. **ListingCommandQueue**
   - Queue for Listing Command workflows
   - Triggered by new MLS listings

6. **NeighborhoodCommandQueue**
   - Queue for Neighborhood Command workflows
   - Area-based campaigns

7. **ReportQueue**
   - Queue for report generation
   - Used for data exports and optimization

---

## 🔧 STORED PROCEDURES (Workflow-Related)

From `TheGenie.ALL.Stored.Proceedures.11.5.2025.csv`:

1. **AggregateShortUrlAccess**
   - Aggregates short URL access counts
   
2. **AreaApnCountRebuild**
   - Rebuilds area APN count lookup table
   
3. **AreaTppCheck**
   - Checks TPP (Third Party Provider) data for area
   
4. **AreaTppOverlay**
   - Overlays TPP data on area
   
5. **AreaTppSummaryBuild**
   - Builds TPP summary for area
   
6. **DataAppendEstimateLogUpdate**
   - Updates data append estimate log
   
7. **FacebookSetDefaultAdAccountAndPage**
   - Sets default Facebook ad account and page
   
8. **GetAgentCodesByFarmGenieUser**
   - Gets agent codes by user
   
9. **GetAgentListingWithTitle**
   - Gets agent listing with title data
   
10. **GetAreaCounts**
    - Gets property counts for area
    
11. **GetExcludedProperties**
    - Gets excluded properties list
    
12. **GetHubThemeMatch**
    - Gets matching Hub theme for office
    
13. **GetPropertyMatches**
    - Gets property matches for collection
    
14. **GetUserLeadTagsReport**
    - Gets user lead tags report
    
15. **HubCloudSurroundingAreas**
    - Gets surrounding areas for Hub Cloud
    
16. **InsertGenieLeadTagSmsOptOut**
    - Inserts SMS opt-out tag for lead
    
17. **MonitorSmsMissedAreaCodes**
    - Monitors SMS for missed area codes
    
18. **NotificationGetNewListingsByDate**
    - Gets new listings by date for notifications
    
19. **NotificationGetSoldListingsByDate**
    - Gets sold listings by date for notifications
    
20. **NotificationWatchAreaCount**
    - Gets notification watch area count
    
21. **NotificationWatchLastSearchReport**
    - Gets last search report for notification watch
    
22. **QueueDataPointsByReport**
    - Queues data points by report type
    
23. **UserMasterAgentMapRebuild**
    - Rebuilds user master agent mapping

---

## 📊 WORKFLOW EXECUTION FLOW

### High-Level Process:
1. **Workflow Queued**
   - `PropertyCastWorkflowQueue` record created
   - Links to workflow configuration (`PropertyCastWorkflow`)

2. **Workflow Initialized**
   - `WorkflowInitializer.Init()` creates `PropertyCastWorkflowQueueItem` records
   - One item per action in workflow configuration
   - Items ordered by `ExecutionOrder`

3. **Workflow Processed**
   - `WorkflowProcessor.Process()` called
   - Gets unprocessed queue items
   - Processes each item in order

4. **Action Executed**
   - `WorkflowActionTypeFactory.Get()` creates action handler
   - Handler executes action
   - Response saved to queue item

5. **Error Handling**
   - Exceptions caught and logged
   - Retry logic if `RetryMaxAttempts` configured
   - Runtime checks for stuck workflows
   - Chat notifications for failures

6. **Workflow Completed**
   - All actions marked complete
   - `WorkflowCompletedSuccessfully` action marks workflow done
   - `CompleteDate` set on workflow queue

---

## 🔍 WORKFLOW CONFIGURATION SOURCES

### Test Configuration Files:
- `TestWorkflow01CastDirectMail.cs` - Competition Command Direct Mail
- `TestWorkflow04CastFacebook.cs` - Competition Command Facebook
- `TestWorkflow05CastSms.cs` - Competition Command SMS
- `TestWorkflow06ListingCommandSms.cs` - Listing Command SMS
- `TestWorkflow07ListingCommandFacebook.cs` - Listing Command Facebook
- `TestWorkflow08ListingCommandDirectMail.cs` - Listing Command Direct Mail
- `TestWorkflow09ListingCommandTesting.cs` - Listing Command Test
- `TestWorkflow10NCFacebook.cs` - Neighborhood Command Facebook
- `TestWorkflow11NCSms.cs` - Neighborhood Command SMS
- `TestWorkflow12NCDirectMail.cs` - Neighborhood Command Direct Mail

---

## 📝 NOTES

- **Workflows are templates** - Each workflow configuration defines a sequence of actions
- **Actions are reusable** - Same action type can be used in multiple workflows
- **Channels are independent** - SMS, Facebook, Direct Mail can be used with any product type
- **Error handling is built-in** - Retry logic, runtime checks, and notifications
- **Database-driven** - All workflow configurations stored in `PropertyCastWorkflow` and `PropertyCastWorkflowAction` tables

