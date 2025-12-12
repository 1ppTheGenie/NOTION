# Post Parser Aggregation Job - Analysis

## Search Results

**Status:** Not found as a Windows Service in source code  
**Likely Location:** SQL Server Agent Job or external scheduler

## Found Components

### Stored Procedures (MlsListing Database)

Found these aggregation-related stored procedures:

1. **`AggregationMlsProcessingQueueInsert`** - Inserts items into aggregation processing queue
2. **`AggregationProcessingComplete`** - Marks aggregation processing as complete
3. **`AggregationProcessingSetMls`** - Sets MLS for aggregation processing
4. **`AggregationQueueMonitor`** - Monitors aggregation queue status

**Location:** `MlsListing.dbo` schema

### Related Parser Procedures (Master Database)

1. **`del_spMLSParserStatusUpdate`** - Updates MLS parser status
2. **`ExportMlsListingsMessageSend`** - Sends MLS listing export messages
3. **`ImportMlsListingsMessageSend`** - Sends MLS listing import messages

**Location:** `Master.dbo` schema

## Where to Look

### Option 1: SQL Server Agent Jobs
The "Post Parser Aggregation Job" is likely a **SQL Server Agent Job** that runs after MLS parsing completes.

**To Find:**
```sql
-- Check SQL Server Agent Jobs
SELECT 
    job_id,
    name AS JobName,
    enabled,
    date_created,
    date_modified,
    description
FROM msdb.dbo.sysjobs
WHERE name LIKE '%Aggregation%'
   OR name LIKE '%Parser%'
   OR name LIKE '%Post%'
ORDER BY name;

-- Check job steps
SELECT 
    j.name AS JobName,
    js.step_id,
    js.step_name,
    js.command,
    js.database_name,
    js.subsystem
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id
WHERE j.name LIKE '%Aggregation%'
   OR j.name LIKE '%Parser%'
   OR j.name LIKE '%Post%'
ORDER BY j.name, js.step_id;
```

### Option 2: Windows Task Scheduler
Check Windows Task Scheduler for scheduled tasks that call aggregation procedures.

### Option 3: Service Configuration
Check if there's a service configuration that references aggregation:

```sql
-- Check ConfigurationSetting for aggregation references
SELECT * FROM FarmGenie.dbo.ConfigurationSetting
WHERE ConfigurationJson LIKE '%Aggregation%'
   OR Name LIKE '%Aggregation%'
   OR ConfigurationJson LIKE '%Parser%';
```

### Option 4: Check Service Logs/Config Files
Look for:
- Service configuration files (`.config`, `.json`)
- Log files mentioning "Aggregation" or "Post Parser"
- Windows Event Logs

## Process Flow (Inferred)

Based on stored procedure names, the likely flow is:

```
1. MLS Parser completes → Updates status via del_spMLSParserStatusUpdate
2. Trigger/Job detects parser completion
3. Calls AggregationMlsProcessingQueueInsert → Queues MLS for aggregation
4. AggregationProcessingSetMls → Sets MLS ID for processing
5. Aggregation processing runs (likely in batches)
6. AggregationProcessingComplete → Marks processing complete
7. AggregationQueueMonitor → Monitors queue status
```

## Next Steps

1. **Check SQL Server Agent Jobs** - Most likely location
2. **Check Windows Task Scheduler** - Alternative scheduler
3. **Query aggregation queue tables** - See what's queued:
   ```sql
   -- Check if aggregation queue table exists
   SELECT * FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_NAME LIKE '%Aggregation%'
      OR TABLE_NAME LIKE '%Queue%';
   ```
4. **Check service logs** - Look for aggregation-related log entries
5. **Check stored procedure definitions** - See what they do:
   ```sql
   -- Get stored procedure definition
   EXEC sp_helptext 'AggregationProcessingComplete';
   EXEC sp_helptext 'AggregationMlsProcessingQueueInsert';
   ```

## Related Files Found

- `APIs/Sps-MLSListing.v1.csv` - Lists aggregation stored procedures
- `APIs/Sps-Master.v1.csv` - Lists parser-related stored procedures

## Notes

The "Post Parser Aggregation Job" is likely:
- A SQL Server Agent Job (most common for this type of workflow)
- Scheduled to run after MLS parser completes
- Calls the aggregation stored procedures in sequence
- May be triggered by parser completion rather than scheduled

