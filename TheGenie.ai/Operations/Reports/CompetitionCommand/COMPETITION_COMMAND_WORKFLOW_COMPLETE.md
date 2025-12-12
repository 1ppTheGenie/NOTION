# Competition Command Workflow - Complete Step-by-Step Analysis

**Date:** November 8, 2025  
**Product:** Competition Command (PropertyCastType = 1)  
**Channel:** SMS (DefaultSms workflow, ID: 5)  
**Source:** `TestWorkflow05CastSms.cs` + Source Code Analysis

---

## 🎯 OVERVIEW

**Competition Command** is a marketing campaign product that targets property owners near a subject property (recently sold or active listing). The SMS channel workflow consists of **12 sequential steps** that:

1. Generate marketing assets (PDFs, landing pages)
2. Create property collection
3. Optimize collection with data append
4. Queue and send SMS messages
5. Track completion

---

## 📊 WORKFLOW ARCHITECTURE

### Database Tables:
- **PropertyCastWorkflowQueue** - Main workflow queue record
- **PropertyCastWorkflowQueueItem** - Individual action items (one per step)
- **PropertyCollectionDetail** - Campaign record
- **SmsReportSendQueue** - SMS sending queue
- **ReportQueue** - Report/optimization queue

### Service Components:
- **PropertyCasterWorkflow Service** - Windows service that processes workflows
- **Genie Cloud API** - Generates assets and landing pages
- **Genie.ai Web API** - Handles SMS queuing and sending
- **NotificationWatch Service** - Sends SMS via Twilio

---

## 🔄 STEP-BY-STEP WORKFLOW (SMS Channel)

### **STEP 1: Get Optimal Stats Interval** (Optional)
**Action Type:** `GetOptimalStatsInterval` (ID: 29)  
**Workflow Action ID:** 131  
**Class:** `AreaStats.GetOptimalInterval`

#### What It Does:
- Calls `GetAreaStatsOptimalInterval` API
- Determines optimal time period for area statistics
- Used to select appropriate asset templates

#### Configuration:
```csharp
{
    Enabled: false,  // Can be enabled/disabled
    RetryMaxAttempts: 2,
    Method: {
        Name: "GetAreaStatsOptimalInterval",
        UseStaging: false
    }
}
```

#### Handoff to Next Step:
- Result stored in `PropertyCastWorkflowQueueItem.ItemJson`
- Referenced by subsequent Hub asset generation steps

#### Error Handling:
- **Retry Logic:** Up to 2 retries if API call fails
- **On Failure:** 
  - If retries exhausted → `QuitProcessing("Error message")`
  - Workflow stops, `CompleteDate` set, `ResponseCode = Error`
- **Runtime Check:** If action runs longer than `MaxRuntimeMinutes`, marked as failed

---

### **STEP 2: Queue Hub Download Asset Generation**
**Action Type:** `QueueMappedHubAssetGeneration` (ID: 21)  
**Workflow Action ID:** 135  
**Class:** `QueueHubAssetGeneration.QueueMappedHubAssetGeneration`

#### What It Does:
- Queues Genie Cloud to generate downloadable PDF report
- Maps different asset templates based on listing status (Active, Pending, Sold)
- Uses Hub Asset Setting ID: 58 for all statuses

#### Configuration:
```csharp
{
    UseHubStaging: false,
    RetryMaxAttempts: 3,
    AssetMap: [
        { ListingStatusId: Active, HubAssetSettingId: 58 },
        { ListingStatusId: Pending, HubAssetSettingId: 58 },
        { ListingStatusId: Sold, HubAssetSettingId: 58 }
    ],
    Method: {
        Name: "QueueHubAssetGeneration",
        UseStaging: false
    },
    ActionOptimalInterval: {
        ActionType: GetOptimalStatsInterval,
        WorkflowActionId: 131
    }
}
```

#### Handoff to Next Step:
- Hub render ID stored in `PropertyCastWorkflowQueueItem.ItemJson`
- Used by Step 3 to check if generation is complete

#### Error Handling:
- **Retry Logic:** Up to 3 retries
- **On Failure:** 
  - Retries if `CanRetry()` returns true
  - Otherwise → `QuitProcessing("Error message")`
- **Dependencies:** If Step 1 (Optimal Interval) failed, this step may use fallback logic

---

### **STEP 3: Check Hub Download Generated**
**Action Type:** `CheckHUBAssetGenerated` (ID: 4)  
**Workflow Action ID:** 136  
**Class:** `CheckHubAsset.CheckHubAssetGenerated`

#### What It Does:
- Checks if Hub asset generation from Step 2 is complete
- Polls Genie Cloud API for render status
- Verifies asset is available for download

#### Configuration:
```csharp
{
    AssetGeneration: {
        ActionType: QueueMappedHubAssetGeneration,
        WorkflowActionId: 135
    }
}
```

#### Handoff to Next Step:
- If complete → `Completed()`, workflow continues
- If in progress → `InProgress()`, workflow pauses, will retry on next cycle
- Download URL stored for use in landing page generation

#### Error Handling:
- **Polling:** Continues checking until complete or failed
- **On Failure:** 
  - If asset generation failed → `QuitProcessing("Asset generation failed")`
- **Timeout:** If asset never completes, runtime check will mark as failed

---

### **STEP 4: Queue Hub Landing Page Generation**
**Action Type:** `QueueMappedHubAssetGeneration` (ID: 21)  
**Workflow Action ID:** 132  
**Class:** `QueueHubAssetGeneration.QueueMappedHubAssetGeneration`

#### What It Does:
- Queues Genie Cloud to generate landing page HTML
- Uses Hub Asset Setting ID: 54 for all listing statuses
- Landing page will be used in SMS messages

#### Configuration:
```csharp
{
    UseHubStaging: false,
    RetryMaxAttempts: 3,
    AssetMap: [
        { ListingStatusId: Active, HubAssetSettingId: 54 },
        { ListingStatusId: Pending, HubAssetSettingId: 54 },
        { ListingStatusId: Sold, HubAssetSettingId: 54 }
    ],
    ActionDownloadUrl: {
        ActionType: QueueMappedHubAssetGeneration,
        WorkflowActionId: 135  // References Step 2 download URL
    },
    Method: {
        Name: "QueueHubAssetGeneration",
        UseStaging: false
    }
}
```

#### Handoff to Next Step:
- Landing page render ID stored in `PropertyCastWorkflowQueueItem.ItemJson`
- Used by Step 5 to check completion and Step 10 to extract URL

#### Error Handling:
- **Retry Logic:** Up to 3 retries
- **Dependencies:** Requires Step 2 (Download URL) to be complete
- **On Failure:** Workflow stops, SMS cannot be sent without landing page

---

### **STEP 5: Check Hub Landing Page Generated**
**Action Type:** `CheckHUBAssetGenerated` (ID: 4)  
**Workflow Action ID:** 133  
**Class:** `CheckHubAsset.CheckHubAssetGenerated`

#### What It Does:
- Checks if landing page generation from Step 4 is complete
- Verifies landing page is available

#### Configuration:
```csharp
{
    AssetGeneration: {
        ActionType: QueueMappedHubAssetGeneration,
        WorkflowActionId: 132
    }
}
```

#### Handoff to Next Step:
- If complete → workflow continues to Step 6
- If in progress → workflow pauses, retries on next cycle

#### Error Handling:
- **Critical Step:** SMS cannot be sent without landing page
- **On Failure:** Workflow stops

---

### **STEP 6: Create Property Collection**
**Action Type:** `CreateCastPropertyCollection` (ID: 27)  
**Workflow Action ID:** 79  
**Class:** `CreateCollection.CreateCastPropertyCollection`

#### What It Does:
- Calls `PropertyCastCreatePropertyCollection` API
- Creates `PropertyCollectionDetail` record in database
- Links collection to subject property and area
- This is the **campaign record** that will be tracked

#### Configuration:
```csharp
{
    CastActionType: Sms,
    RetryMaxAttempts: 3,
    Method: {
        Name: "PropertyCastCreatePropertyCollection",
        UseStaging: false
    }
}
```

#### Handoff to Next Step:
- `PropertyCollectionDetailId` stored in `PropertyCastWorkflowQueueItem.ItemJson`
- Used by all subsequent steps to link data

#### Error Handling:
- **Retry Logic:** Up to 3 retries
- **On Failure:** 
  - Without collection, no campaign exists
  - Workflow stops, no SMS can be sent
- **Database Constraint:** If collection already exists, may return error

---

### **STEP 7: Queue Optimization (Data Append)**
**Action Type:** `QueueOptimizePropertyCollection` (ID: 1)  
**Workflow Action ID:** 16  
**Class:** `QueueOptimization.QueueOptimizePropertyCollection`

#### What It Does:
- Queues property collection for data append
- Appends phone numbers, email addresses, demographics, financial data
- Uses "Booster" package for data append
- Creates `ReportQueue` record

#### Configuration:
```csharp
{
    DataToAppend: [Phone, Email, Demographics, Financial],
    EmailFile: false,
    Package: Booster,
    ReportType: MailListCleanExport,
    Method: {
        Name: "OptimizePropertyCollection",
        UseStaging: false
    }
}
```

#### Handoff to Next Step:
- `ReportQueueId` stored in `PropertyCastWorkflowQueueItem.ItemJson`
- Used by Step 8 to check completion and Step 11 to queue SMS

#### Error Handling:
- **Retry Logic:** Up to 3 retries
- **On Failure:** 
  - Without phone numbers, SMS cannot be sent
  - Workflow stops
- **Data Quality:** If no phone numbers found, optimization may succeed but SMS will have no recipients

---

### **STEP 8: Check Optimization Complete**
**Action Type:** `CheckOptimizationComplete` (ID: 2)  
**Workflow Action ID:** 17  
**Class:** `CheckOptimization.CheckOptimizeComplete`

#### What It Does:
- Checks if data append/optimization from Step 7 is complete
- Polls `ReportQueue` table for completion status
- Verifies phone numbers and emails are appended

#### Configuration:
```csharp
{
    OptimizedAction: {
        ActionType: QueueOptimizePropertyCollection,
        WorkflowActionId: 16
    }
}
```

#### Handoff to Next Step:
- If complete → workflow continues
- If in progress → workflow pauses, retries on next cycle

#### Error Handling:
- **Polling:** Continues until complete or failed
- **On Failure:** 
  - If optimization failed → `QuitProcessing("Optimization failed")`
- **Timeout:** Runtime check prevents infinite waiting

---

### **STEP 9: Log Cast Property Collection**
**Action Type:** `LogCastPropertyCollection` (ID: 28)  
**Workflow Action ID:** 80  
**Class:** `CollectionLog.CastCollectionLogger`

#### What It Does:
- Logs property collection creation for tracking/auditing
- Calls `LogPropertyCastCollection` API
- Records collection details and metadata

#### Configuration:
```csharp
{
    RetryMaxAttempts: 3,
    Method: {
        Name: "LogPropertyCastCollection",
        UseStaging: false
    },
    CollectionCreationAction: {
        WorkflowActionId: 79,
        ActionType: CreateCastPropertyCollection
    }
}
```

#### Handoff to Next Step:
- Logging is non-blocking
- Workflow continues regardless of logging success/failure

#### Error Handling:
- **Non-Critical:** Logging failures do not stop workflow
- **Retry Logic:** Up to 3 retries
- **On Failure:** Workflow continues, but audit trail may be incomplete

---

### **STEP 10: Set Landing Page**
**Action Type:** `SetLandingPage` (ID: 22)  
**Workflow Action ID:** 61  
**Class:** `SetLandingPage.SetHubLandingPage`

#### What It Does:
- Extracts landing page URL from Step 4 Hub asset generation
- Stores URL in `PropertyCollectionDetail` or workflow item
- URL will be used in SMS messages

#### Configuration:
```csharp
{
    LandingPageGeneration: {
        ActionType: QueueMappedHubAssetGeneration,
        WorkflowActionId: 132
    }
}
```

#### Handoff to Next Step:
- Landing page URL stored for Step 11
- Used when creating SMS messages

#### Error Handling:
- **Critical Step:** SMS requires landing page URL
- **On Failure:** 
  - If landing page not found → `QuitProcessing("Unable to load landing page")`
- **Dependencies:** Requires Step 4 and Step 5 to be complete

---

### **STEP 11: Queue SMS Report Send**
**Action Type:** `QueueSmsReportSend` (ID: 14)  
**Workflow Action ID:** 18  
**Class:** `QueueSmsReport.QueueSmsReportSend`

#### What It Does:
- **CRITICAL STEP** - Queues SMS messages for sending
- Calls `QueueSmsReportSend` API
- Creates `SmsReportSendQueue` record
- Links to optimized report (Step 7), landing page (Step 10)
- Selects SMS template based on listing status (Active vs Sold)

#### Configuration:
```csharp
{
    UtmSource: "Competition Command",
    CtaGroupId: 2,
    QueueOptimizePropertyCollection: {
        ActionType: QueueOptimizePropertyCollection,
        WorkflowActionId: 16
    },
    LandingPageGeneration: {
        ActionType: SetLandingPage,
        WorkflowActionId: 61
    },
    SmsGroups: {
        Active: 1,
        Sold: 2
    },
    Method: {
        Name: "QueueSmsReportSend",
        UseStaging: false
    }
}
```

#### Process Details:
1. Loads `ReportId` from Step 7 (optimization)
2. Loads `LandingPageUrl` from Step 10
3. Determines listing status (Active, Pending, Sold)
4. Selects SMS template group based on status
5. Creates `SmsReportSendRequest` with:
   - `ReportId` - Links to optimized property collection
   - `LandingPageUrl` - Short URL for SMS
   - `SmsTemplateGroupId` - Template to use
   - `UtmSource` - "Competition Command"
   - `CtaGroupId` - CTA popup configuration
   - `PropertyCastTypeId` - 1 (Competition Command)

6. Calls Genie.ai Web API `QueueSmsReportSend`
7. API creates `SmsReportSendQueue` record
8. API creates `SmsReportMessageQueuedLog` records (one per property)
9. API queues `NotificationQueue` records for SMS sending
10. Returns `SmsReportSendQueueId`

#### Handoff to Next Step:
- `SmsReportSendQueueId` stored in `PropertyCastWorkflowQueueItem.ItemJson`
- Used by Step 12 to check completion

#### Error Handling:
- **Retry Logic:** Up to 3 retries
- **Validation Errors:**
  - No ReportId → `QuitProcessing("Unable to load source Report Id")`
  - No AreaId (for NC) → `QuitProcessing("Unable to load source Area")`
  - No MlsId (for CC/LC) → `QuitProcessing("Unable to load source Mls Id")`
  - No Landing Page → Exception thrown
- **API Errors:**
  - If API returns error → Retry if `CanRetry()`, else `QuitProcessing()`
- **Chat Notification:** Sends success notification to agent

#### Critical Dependencies:
- **Step 7 (Optimization)** - Must be complete, provides ReportId
- **Step 10 (Landing Page)** - Must be complete, provides URL
- **Step 6 (Collection)** - Must exist, linked via PropertyCollectionDetailId

---

### **STEP 12: Check SMS Report Send Complete**
**Action Type:** `CheckSmsReportSendComplete` (ID: 15)  
**Workflow Action ID:** 19  
**Class:** `CheckSmsReport.CheckSmsReportSendComplete`

#### What It Does:
- Checks if SMS sending from Step 11 is complete
- Polls `SmsReportSendQueue` table for status
- Verifies all SMS messages have been queued to `NotificationQueue`

#### Configuration:
```csharp
{
    QueueSmsReportSend: {
        ActionType: QueueSmsReportSend,
        WorkflowActionId: 18
    }
}
```

#### Process Details:
1. Loads `SmsReportSendQueueId` from Step 11
2. Queries `SmsReportSendQueue` table
3. Checks `ResponseCode`:
   - Success (200) → `Completed()`, workflow continues
   - In Progress (null or pending) → `InProgress()`, retry later
   - Error → `QuitProcessing("Sms report send failed")`

#### Handoff to Next Step:
- If complete → Workflow can proceed to completion
- If in progress → Workflow pauses, will check again on next cycle

#### Error Handling:
- **Polling:** Continues until complete or failed
- **On Failure:** 
  - If `SmsReportSendQueue.ResponseCode` indicates error → `QuitProcessing()`
  - Workflow stops, SMS sending failed
- **Timeout:** Runtime check prevents infinite waiting

---

## 🔄 WORKFLOW COMPLETION

### Final Step (Not in SMS workflow, but available):
**Action Type:** `WorkflowCompletedSuccessfully` (ID: 9)  
**Class:** `WorkflowCompletion.WorkflowComplete`

#### What It Does:
- Marks workflow as successfully completed
- Sets `CompleteDate` on `PropertyCastWorkflowQueue`
- Final status update

---

## ⚠️ ERROR HANDLING ARCHITECTURE

### Retry Logic:
- **Per-Step Retries:** Each step can have `RetryMaxAttempts` configured
- **Retry Counter:** Stored in `PropertyCastWorkflowQueueItem.Retries`
- **Retry Condition:** `CanRetry()` checks if retries < max attempts
- **On Retry:** `InProgress()` returned, workflow pauses, retries on next cycle

### Runtime Checks:
- **Max Runtime:** Each action can have `MaxRuntimeMinutes` configured
- **Runtime Handler:** `WorkflowActionRuntimeHandler.CheckRuntime()`
- **On Timeout:** 
  - `ResponseCode = Error`
  - `MarkCompleted = true`
  - `ContinueProcessing = false`
  - Workflow stops

### Exception Handling:
- **Try/Catch:** All action executions wrapped in try/catch
- **On Exception:**
  - Exception logged via `Logger.LogError()`
  - `SetWorkflowQueueItemError()` called
  - `QuitProcessing("Error")` returned
  - Workflow stops

### Workflow-Level Error Responses:

#### `InProgress()`:
- **When:** Action not complete, but should retry
- **Result:** Workflow pauses, will retry on next service cycle
- **ContinueProcessing:** `false` (stops processing remaining steps)
- **MarkCompleted:** `false` (action not done)

#### `Completed()`:
- **When:** Action completed successfully
- **Result:** Workflow continues to next step
- **ContinueProcessing:** `true` (process next step)
- **MarkCompleted:** `true` (action done)

#### `QuitProcessing(message)`:
- **When:** Action failed and cannot retry, or critical error
- **Result:** Workflow stops immediately
- **ContinueProcessing:** `false` (stops processing)
- **MarkCompleted:** `true` (action marked as failed)
- **ResponseCode:** `Error`
- **Chat Notification:** Failure notification sent to dev team (if configured)

### Chat Notifications:
- **Success:** Step 11 sends notification to agent when SMS queued
- **Failure:** Workflow-level failures send notification to dev team
- **Configuration:** `ChatMessageConfiguration` in action config

---

## 🔗 HANDOFF MECHANISMS

### Previous Action Handler:
- **Class:** `PreviousAction.PreviousActionHandler`
- **Purpose:** Retrieves data from previous workflow steps
- **Methods:**
  - `GetIntKeyFromPreviousAction()` - Gets integer ID (e.g., ReportId, SmsReportSendQueueId)
  - `GetRawValueFromPreviousAction()` - Gets string value (e.g., LandingPageUrl)

### Data Storage:
- **ItemJson:** Stores result data from each step
- **Format:** Usually integer ID or JSON string
- **Retrieval:** Via `PreviousActionHandler` using `ConfigurationPreviousAction`

### Workflow Queue Item Linking:
- **PropertyCastWorkflowQueueItemId:** Unique ID for each action item
- **WorkflowActionId:** Links to `PropertyCastWorkflowAction` (step configuration)
- **ExecutionOrder:** Determines processing order
- **Dependencies:** Via `ConfigurationPreviousAction` references

---

## 📊 DATA FLOW SUMMARY

### Campaign Creation → SMS Sending:

1. **PropertyCastWorkflowQueue** created
   - Links to workflow configuration (DefaultSms = 5)
   - Contains: PropertyCastId, PropertyCollectionDetailId, PropertyId, MlsId

2. **WorkflowInitializer** creates queue items
   - 12 `PropertyCastWorkflowQueueItem` records created
   - Ordered by `ExecutionOrder`
   - Each linked to `PropertyCastWorkflowAction`

3. **WorkflowProcessor** processes items sequentially
   - Gets unprocessed items
   - Executes each action
   - Stores results in `ItemJson`

4. **Step 6:** `PropertyCollectionDetail` created
   - Campaign record in database
   - Links to agent, area, property

5. **Step 7:** `ReportQueue` created
   - Optimization/data append queued
   - Phone numbers and emails appended

6. **Step 11:** `SmsReportSendQueue` created
   - SMS sending queued
   - Links to ReportQueue and LandingPageUrl

7. **Genie.ai Web API** processes SMS queue
   - Creates `SmsReportMessageQueuedLog` records
   - Creates `NotificationQueue` records
   - Generates short URLs with `SmsShortUrlData`

8. **NotificationWatch Service** sends SMS
   - Reads `NotificationQueue` records
   - Sends via Twilio API
   - Updates `NotificationQueue` with Twilio response

9. **Step 12:** Verifies SMS queuing complete
   - Checks `SmsReportSendQueue` status
   - Workflow completes when all SMS queued

---

## 🎯 KEY INSIGHTS

### Critical Path:
- **Steps 6, 7, 10, 11** are critical - workflow cannot complete without them
- **Steps 1-5** are asset generation - required for SMS content
- **Step 12** is verification - ensures SMS was queued

### Dependencies:
- **Step 11 depends on:** Steps 7 (ReportId) and 10 (LandingPageUrl)
- **Step 10 depends on:** Steps 4 and 5 (Landing page generation)
- **Step 8 depends on:** Step 7 (Optimization)
- **All steps depend on:** Step 6 (Property Collection)

### Error Recovery:
- **Retry Logic:** Most steps have 2-3 retry attempts
- **Non-Blocking:** Step 9 (Logging) failures don't stop workflow
- **Critical Failures:** Steps 6, 7, 10, 11 failures stop workflow immediately

### Performance:
- **Parallel Processing:** Asset generation (Steps 2-5) can run in parallel with optimization (Steps 7-8)
- **Polling:** Steps 3, 5, 8, 12 use polling - may take multiple cycles
- **Runtime Limits:** Each step has `MaxRuntimeMinutes` to prevent infinite loops

---

## 📝 NOTES

- **Workflow is database-driven:** All configurations stored in `PropertyCastWorkflow` and `PropertyCastWorkflowAction` tables
- **Service polling:** PropertyCasterWorkflow service polls for unprocessed workflows
- **Idempotent:** Actions can be safely retried
- **Audit Trail:** All actions logged with timestamps, response codes, descriptions
- **Configuration Flexibility:** Each workflow can have different step configurations

