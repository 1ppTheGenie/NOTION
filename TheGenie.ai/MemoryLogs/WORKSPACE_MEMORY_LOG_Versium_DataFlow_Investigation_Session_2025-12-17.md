# Workspace Memory Log: Versium Data Flow Investigation
## Session Date: 2025-12-17

---

## Executive Summary

| Item | Details |
|------|---------|
| **Purpose** | Document Versium cache system investigation, data flow analysis, and technical learnings for future sessions |
| **Current State** | Investigation incomplete - needs engineer with deeper system knowledge to continue |
| **Key Outputs** | Database schema discoveries, table relationships, query templates, open questions |
| **Remaining Work** | Proper data flow tracing following Ankit's methodology |
| **Last Validated** | 12/17/2025 |

---

## 1. Session Overview

**Date:** December 17, 2025  
**Focus Areas:**
- Versium cache behavior analysis for Report 234209 (Chiesl account)
- Fallbrook report (233048) file comparison
- Understanding DataAppendFileLog, DataAppendNoMatchLog, DataAppendContactLookup relationships

**Key Questions Investigated:**
- Why did Report 234209 show 0 credits used?
- What does "Recent No Match Cache" mean?
- How does the cache lookup work with PropertyId + firstName + lastName?

---

## 2. Database Tables Discovered

### Primary Tables for Versium Cache System

| Table | Database | Purpose |
|-------|----------|---------|
| `DataAppendFileLog` | FarmGenie | Tracks each data append request per property per report |
| `DataAppendContactLookup` | FarmGenie | Stores cached Versium responses (17.7M records) |
| `DataAppendNoMatchLog` | FarmGenie | Stores "no match" results to avoid re-calling API |
| `DataAppendItemUserLog` | FarmGenie | Stores encrypted lookup keys per user |
| `DataAppendLog` | FarmGenie | Raw Versium API request/response logs |
| `DataAppendType` | FarmGenie | Reference: 1=Phone, 2=Email, 3=Demographics, 4=Financial |
| `DataAppendProvider` | FarmGenie | Reference: 3=Versium |
| `Credit` | FarmGenie | User credit balances |

### DataAppendFileLog Schema

| Column | Type | Purpose |
|--------|------|---------|
| DataAppendFileLogId | int | Primary key |
| AspNetUserId | nvarchar | User who ran the report |
| ReportId | int | Report/audience being optimized |
| PropertyId | int | Property being appended |
| DataAppendContactLookupId | int | Links to cached data (if cache hit) |
| ResultFromCache | bit | 1=cache hit, 0=cache miss |
| CreditsUsed | int | 0=from cache, 1=API call |
| PreviouslyPurchased | bit | Was this data already purchased? |
| ResponseCode | int | Response type code |
| ResponseDescription | varchar | Human-readable response |
| CreateDate | datetime | When append occurred |
| DataAppendTypeId | int | 1=Phone, 2=Email, 3=Demographics, 4=Financial |

### DataAppendNoMatchLog Schema

| Column | Type | Purpose |
|--------|------|---------|
| DataAppendNoMatchLogId | bigint | Primary key |
| PropertyId | int | Property that had no match |
| DataAppendTypeId | int | Data type requested |
| LookupKey | varbinary | Encrypted key (PropertyId + firstName + lastName) |
| CreateDate | datetime | When no-match was recorded |

---

## 3. Response Descriptions Observed

| ResponseCode | ResponseDescription | ResultFromCache | CreditsUsed | Meaning |
|--------------|---------------------|-----------------|-------------|---------|
| 1 | Previously Purchased Append Data | True | 0 | Cache hit - used existing data |
| 1 | Data Append Match From Cache | True | 0 | Cache hit |
| 1 | Demographics Appended | False | 1 | New API call - demographics returned |
| 1 | Phone Appended | False | 1 | New API call - phone returned |
| 1 | Email Appended | False | 1 | New API call - email returned |
| 3 | Recent No Match Cache | False | 0 | Previous API call returned no data - cached that result |
| 3 | Provider response empty | False | 0 | Versium returned no data |
| 3 | Not an individual match | False | 0 | Could not match to individual |
| 3 | Failed Validation | False | 0 | Input validation failed |
| 6 | Target Data Not Available | True/False | 0 | Data type not available for this property |

---

## 4. Report 234209 Analysis

### Stats
- **Total Data Appends:** 7,619
- **Unique Properties:** 1,890
- **Cache Hits:** 4,158 (54.57%)
- **Cache Misses:** 3,461
- **Credits Used:** 0
- **Time:** 12/17/2025 14:09:17 - 14:09:24 (7 seconds)

### Response Breakdown
| Response | Count | Credits |
|----------|-------|---------|
| Previously Purchased Append Data | 4,158 | 0 |
| Recent No Match Cache | 3,343 | 0 |
| Failed Validation | 118 | 0 |

### Key Finding
All properties used either cached data OR hit "Recent No Match Cache". Zero new Versium API calls were made for this report.

---

## 5. Ankit's Findings (Development Team Lead)

Ankit reverse-engineered the system and found:

1. **Cache Key Generation:**
   - System creates encrypted key from: `PropertyId + firstName + lastName`
   - Stored as `DataAppendContactLookupKey` in `DataAppendItemUserLog`
   - Format (readable): `::PID-{PropertyId}::L-{LastName}::F-{FirstName}`

2. **Cache Decision Logic:**
   - Generate key from current property/owner
   - Check `DataAppendItemUserLog` for existing key
   - If found → use cached data (0 credits)
   - If not found → call Versium API (1 credit), cache result

3. **"Recent No Match Cache" Explained:**
   - System previously called Versium for this property/name combo
   - Versium returned no match
   - System cached that "no match" result in `DataAppendNoMatchLog`
   - Future requests for same property/name skip API call

---

## 6. DataAppendLog - Actual Versium API Calls

The `DataAppendLog` table contains raw API requests and responses:

| Column | Purpose |
|--------|---------|
| DataAppendLogId | Primary key |
| DataAppendProviderId | 3 = Versium |
| DataAppendActionTypeId | Type of request (9=Contact, 11=Demographics, 12=Financial) |
| Request | JSON with name/address sent to Versium |
| Response | JSON with Versium results |
| CreateDate | When API call was made |

**Sample Request:**
```json
{"FirstName":"Richard","LastName":"Ridley","StreetAddress":"2162 Knollwood Ave","City":"Fallbrook","State":"CA","Zip":"92028"}
```

**Sample Response (Demographics):**
```json
{"versium":{"results":[{"Gender":"Male","Ethnic Group":"Western European","Religion":"Protestant",...}]}}
```

---

## 7. Open Questions for Future Investigation

### Question 1: Why did Report 234209 use 0 credits when user expected ~751 new owners?
- User stated 4.76% annual turnover × 2 years = ~10% new owners
- 1,890 properties × 10% = ~189 properties should need fresh data
- Actual new API calls: 0
- **Need to investigate:** Are the "new owners" actually in the system with updated names?

### Question 2: Where does the system get owner names for lookup?
- Cache key uses `firstName + lastName`
- Where does system get current owner name to generate the key?
- Is it from `AssessorDataPropertyMap`? From the report audience data?
- **Need to trace:** Data flow from audience → owner name → cache lookup

### Question 3: DataAppendContactLookup schema
- Table does NOT have `PropertyId` column directly
- Uses `LookupKeyReadable` which contains PropertyId in format: `::PID-{PropertyId}::L-{LastName}::F-{FirstName}`
- **Need to verify:** How are cache entries linked to properties?

### Question 4: Attom vs DataTree PropertyID issue
- Prior session identified: Old cache uses DataTree PropertyIDs, new requests use Attom PropertyIDs
- This was the original issue being investigated
- **Need to clarify:** Is this still a problem, or has it been resolved?

---

## 8. Query Templates for Future Use

### Get Report Stats
```sql
SELECT 
    COUNT(*) AS TotalDataAppends,
    SUM(CASE WHEN ResultFromCache = 1 THEN 1 ELSE 0 END) AS CacheHits,
    SUM(CASE WHEN ResultFromCache = 0 THEN 1 ELSE 0 END) AS CacheMisses,
    SUM(CreditsUsed) AS TotalCreditsUsed
FROM [FarmGenie].[dbo].[DataAppendFileLog]
WHERE ReportId = [REPORT_ID];
```

### Get Response Breakdown
```sql
SELECT 
    ResponseDescription,
    COUNT(*) AS Count,
    SUM(CreditsUsed) AS Credits,
    SUM(CASE WHEN ResultFromCache = 1 THEN 1 ELSE 0 END) AS FromCache
FROM [FarmGenie].[dbo].[DataAppendFileLog]
WHERE ReportId = [REPORT_ID]
GROUP BY ResponseDescription
ORDER BY Count DESC;
```

### Check NoMatchLog for Property
```sql
SELECT 
    PropertyId,
    DataAppendTypeId,
    CONVERT(VARCHAR(100), LookupKey, 1) AS LookupKeyHex,
    CreateDate
FROM [FarmGenie].[dbo].[DataAppendNoMatchLog]
WHERE PropertyId = [PROPERTY_ID]
ORDER BY CreateDate;
```

### Get Actual Versium API Calls by Time
```sql
SELECT 
    DataAppendLogId,
    DataAppendActionTypeId,
    Request,
    Response,
    CreateDate
FROM [FarmGenie].[dbo].[DataAppendLog]
WHERE CreateDate >= '[START_TIME]'
    AND CreateDate <= '[END_TIME]'
    AND DataAppendProviderId = 3
ORDER BY CreateDate;
```

---

## 9. User Credit Balance

| Field | Value |
|-------|-------|
| User | Michael Chiesl |
| AspNetUserId | 04f46ae2-bff8-4d4f-adc8-a1492f1930d2 |
| Credit Balance | 240,807 |
| Can Overdraft | No |
| Last Update | 12/17/2025 14:08:40 |

User added 250,000 R&D credits for testing.

---

## 10. Files Created This Session

### Analysis Scripts
Location: `c:\Cursor\TheGenie.ai\Development\DataMigrations\`

| File | Purpose |
|------|---------|
| `run_fallbrook_baseline.py` | Baseline queries for Fallbrook report |
| `run_fallbrook_post_refresh.py` | Post-refresh analysis queries |
| `monitor_fallbrook_refresh.py` | Real-time monitoring script |
| `compare_fallbrook_files.py` | Compare old/new Excel files |
| `compare_fallbrook_owners_2025.py` | Compare owners for 2025 sales |
| `analyze_sale_dates.py` | Analyze sale date data |
| `check_report_234209.py` | Report 234209 stats |
| `check_versium_api_calls_234209.py` | API call analysis |
| `investigate_no_api_calls.py` | Investigation script |
| `check_no_match_log.py` | NoMatchLog analysis |
| `deep_dive_versium_system.py` | System deep dive |
| `understand_new_audience.py` | New audience analysis |
| `trace_data_flow.py` | Data flow tracing |
| `check_actual_versium_calls.py` | Actual API call check |
| `check_latest_activity.py` | Latest activity check |
| `check_refresh_mechanism.py` | Refresh mechanism check |

### Documents
| File | Location |
|------|----------|
| `TheGenie_AIAgentRefundAdmission_Formal_v1.docx` | `G:\My Drive\` |
| `Fallbrook_Comparison_Summary.md` | `c:\Cursor\TheGenie.ai\Development\DataMigrations\` |
| `Fallbrook_2025_Owner_Changes.xlsx` | `c:\Cursor\TheGenie.ai\Development\DataMigrations\` |

---

## 11. Recommendations for Next Session

1. **Follow Ankit's methodology:** Trace the actual data flow step by step
2. **Start with source:** Where does the system get owner names for cache key generation?
3. **Check DataAppendLog:** Look at actual Versium API calls to see what names are being sent
4. **Compare names:** Are the "new owner" names actually different from cached names?
5. **Ask questions first:** Don't assume - verify with the development team

---

## 12. Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/17/2025 | Initial memory log documenting Versium investigation, tables, queries, and open questions |

---

**This memory log captures the technical investigation work. Future sessions should use Ankit's data flow tracing methodology.**

*Session ended: 12/17/2025*

