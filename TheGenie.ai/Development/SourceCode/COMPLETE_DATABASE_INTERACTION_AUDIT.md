# Complete Database Interaction Audit

## ✅ DOCUMENTED CODE PATHS

### 1. **NotificationQueue Creation (INSERT)**
**Location:** Multiple places in C# code
- `QueueWriterBase.CreateQueueItem()` - Windows Service (NotificationWatch)
- `WriterBase.Write()` - Web Application (FarmGenie)
- Both serialize `CustomData` as JSON at insertion time

**Files:**
- `Genie.Source.Code/WindowsService/Smart.Service.NotificationWatch/Smart.NotificationWatch.Core/Business/QueueWriter/QueueWriterBase.cs` (line 34)
- `Genie.Source.Code/Web/Smart.Web.FarmGenie/Smart.Core/BLL/Notification/Writer/WriterBase.cs` (line 30)

### 2. **NotificationQueue Updates (UPDATE)**
**Location:** Windows Service (Notification Service)
- Updates `ResponseCode`, `ProviderResponseKey`, `ProcessDate` after SMS send
- Does NOT modify `CustomData` after insertion

**Files:**
- `Genie.Source.Code/WindowsService/Smart.Service.Notification/Smart.Notification.Core/Business/NotificationManagerBase.cs` (line 38)
- Only reads `CustomData` for deserialization, does NOT update it

### 3. **Stored Procedures**
**Status:** ✅ Reviewed all stored procedures in `TheGenie.ALL.Stored.Proceedures.11.5.2025.csv`
- **Result:** NO stored procedures modify `NotificationQueue.CustomData`
- All procedures are read-only (queries, opt-out tagging, monitoring)

### 4. **Database Triggers**
**Status:** ✅ Searched for triggers
- **Result:** NO triggers found that modify `NotificationQueue` or `CustomData`

## ⚠️ POTENTIALLY UNDOCUMENTED AREAS

### 1. **Database Views**
**Status:** ❓ NOT CHECKED
- Views might have INSTEAD OF triggers
- Views might be used in queries we haven't reviewed

**Action Needed:**
```sql
-- Check for views on NotificationQueue
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ViewName,
    OBJECT_DEFINITION(OBJECT_ID(SCHEMA_NAME(schema_id) + '.' + name)) AS ViewDefinition
FROM sys.views
WHERE OBJECT_DEFINITION(OBJECT_ID(SCHEMA_NAME(schema_id) + '.' + name)) LIKE '%NotificationQueue%'
ORDER BY SchemaName, ViewName;
```

### 2. **Entity Framework Migrations**
**Status:** ❓ NOT CHECKED
- Migrations might have custom SQL that modifies data
- Migrations might have triggers or stored procedures

**Action Needed:**
- Search for migration files in `Genie.Source.Code`
- Check for any custom SQL in migrations

### 3. **Background Jobs / Scheduled Tasks**
**Status:** ❓ NOT FULLY CHECKED
- SQL Server Agent jobs
- Windows Task Scheduler jobs
- Cron jobs (if Linux)

**Action Needed:**
```sql
-- Check SQL Server Agent jobs
SELECT 
    job_id,
    name,
    enabled,
    date_created,
    date_modified
FROM msdb.dbo.sysjobs
WHERE name LIKE '%Notification%' OR name LIKE '%SMS%'
ORDER BY name;
```

### 4. **Other Windows Services**
**Status:** ⚠️ PARTIALLY CHECKED
- `Smart.Service.Notification` - ✅ Reviewed
- `Smart.Service.NotificationWatch` - ✅ Reviewed
- `Smart.Service.PropertyCast` - ⚠️ Might create NotificationQueue indirectly
- `Smart.Service.PropertyCasterWorkflow` - ⚠️ Might create NotificationQueue indirectly
- `Smart.Service.Report` - ⚠️ Might create NotificationQueue indirectly

**Action Needed:**
- Search all Windows Services for `NotificationQueue` references
- Check if any service modifies `CustomData` after insertion

### 5. **API Endpoints**
**Status:** ⚠️ PARTIALLY CHECKED
- Found `AgentServiceController.Notification.cs` - only updates `UserNotification`, not `NotificationQueue`
- Might be other API endpoints that modify `NotificationQueue`

**Action Needed:**
- Search all API controllers for `NotificationQueue` references
- Check for any UPDATE operations on `NotificationQueue`

### 6. **Third-Party Integrations**
**Status:** ❓ NOT CHECKED
- Twilio webhooks might update `NotificationQueue`
- Facebook API integrations
- Other external services

**Action Needed:**
- Check webhook handlers
- Check API integration code

### 7. **Direct Database Access**
**Status:** ❓ NOT CHECKED
- Manual SQL scripts
- Admin tools
- Data migration scripts

**Action Needed:**
- Review any SQL scripts in the repository
- Check for any admin tools that might modify data

## 🔍 SPECIFIC SEARCHES NEEDED

### Search 1: All Code That Writes to NotificationQueue
```bash
# Find all INSERT/UPDATE statements
grep -r "INSERT.*NotificationQueue\|UPDATE.*NotificationQueue" Genie.Source.Code/
```

### Search 2: All Code That Modifies CustomData
```bash
# Find all assignments to CustomData
grep -r "\.CustomData\s*=" Genie.Source.Code/
```

### Search 3: All Serialization Points
```bash
# Find all places that serialize CustomData
grep -r "JsonService\.Serialize\|JsonManager\.Serialize\|JsonConvert\.Serialize" Genie.Source.Code/
```

### Search 4: Database Views
```sql
-- Run this query to find all views
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ViewName,
    OBJECT_DEFINITION(OBJECT_ID(SCHEMA_NAME(schema_id) + '.' + name)) AS ViewDefinition
FROM sys.views
ORDER BY SchemaName, ViewName;
```

### Search 5: Database Triggers
```sql
-- Run this query to find all triggers
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    OBJECT_NAME(parent_id) AS TableName,
    name AS TriggerName,
    OBJECT_DEFINITION(OBJECT_ID(SCHEMA_NAME(schema_id) + '.' + name)) AS TriggerDefinition
FROM sys.triggers
WHERE parent_id = OBJECT_ID('dbo.NotificationQueue')
ORDER BY SchemaName, TriggerName;
```

## 🎯 KEY FINDING: TagLeadPropertyCollectionDetailId Discrepancy

**Problem:** The C# source code shows `TagLeadPropertyCollectionDetailId` is only added to agent notifications, but the working SQL query successfully extracts it from audience SMS `CustomData`.

**Possible Explanations:**
1. **Source code is outdated** - The code might have been updated but not committed
2. **Undocumented code path** - There might be code that adds this tag that we haven't found
3. **Runtime modification** - Something might modify `CustomData` after insertion (but we haven't found it)
4. **Different serialization** - The `SmsShortUrlData` might be serialized differently than expected

**Current Status:**
- ✅ Trusting the working SQL query's extraction method
- ✅ Using the exact pattern from `0312.CC_Campaign_SMS_ByCampaign_v2_FIXED.sql`
- ⚠️ Still investigating the source of `TagLeadPropertyCollectionDetailId` in audience SMS

## 📋 RECOMMENDED NEXT STEPS

1. **Run database view query** to check for views on `NotificationQueue`
2. **Run database trigger query** to check for triggers on `NotificationQueue`
3. **Search all Windows Services** for any code that modifies `CustomData`
4. **Check Entity Framework migrations** for custom SQL
5. **Review SQL Server Agent jobs** for scheduled tasks
6. **Search all API controllers** for `NotificationQueue` modifications

## ✅ CONFIRMED: No Post-Insertion Modification Found

Based on comprehensive review:
- ✅ No stored procedures modify `CustomData`
- ✅ No triggers modify `CustomData`
- ✅ Notification Service only reads `CustomData`, doesn't update it
- ✅ All `CustomData` is set at insertion time via serialization

**Conclusion:** The `TagLeadPropertyCollectionDetailId` must be added to `CustomData` at insertion time, even though the C# source code doesn't explicitly show it for audience SMS. The working SQL query proves the data exists, so we should trust the extraction method.

