# SOP: Lead-to-Listing Report Generation

## Executive Summary
| Item | Details |
|------|---------|
| **Purpose** | Standard procedure for generating lead-to-listing conversion reports |
| **Current State** | APPROVED - Production ready |
| **Key Outputs** | CSV reports showing lead conversion, agent performance, trends |
| **Last Validated** | 12/15/2025 |

---

## 1. Prerequisites

- Access to production SQL Server (192.168.29.45)
- SQL credentials (user: cursor)
- SQLCMD or SSMS installed
- Write access to output folder

---

## 2. Report Types

### 2.1 Deduplicated Listing Report
**Purpose:** All listings from our leads, one row per MLS number
**Script:** `SQL_LeadToListing_Deduplicated.sql`
**Output:** `Lead_To_Listing_DEDUPLICATED_YYYY-MM-DD.csv`

### 2.2 Year-over-Year Trend Report
**Purpose:** Show win rate trends by year
**Script:** `SQL_LeadToListing_ByYear.sql`
**Output:** `Lead_To_Listing_ByYear_YYYY-MM-DD.csv`

### 2.3 Recent Wins Analysis
**Purpose:** Deep dive on recent wins (last 30-90 days)
**Script:** `SQL_LeadToListing_RecentWins.sql`
**Output:** `Lead_To_Listing_RecentWins_YYYY-MM-DD.csv`

### 2.4 Agent Performance Report
**Purpose:** Win/loss by agent for period
**Script:** `SQL_LeadToListing_AgentPerformance.sql`
**Output:** `Lead_To_Listing_AgentPerformance_YYYY-MM-DD.csv`

---

## 3. Execution Steps

### Step 1: Connect to Production
```powershell
sqlcmd -S "192.168.29.45,1433" -U cursor -P "[PASSWORD]" -d FarmGenie
```

### Step 2: Run Query
```powershell
sqlcmd -S "192.168.29.45,1433" -U cursor -P "[PASSWORD]" -d FarmGenie `
  -i "SQL_LeadToListing_Deduplicated.sql" `
  -o "Lead_To_Listing_DEDUPLICATED_2025-12-15.csv" `
  -W -s","
```

### Step 3: Validate Output
- Check row count matches expected
- Verify date format is MM/DD/YYYY
- Confirm no special character corruption
- Verify WON vs LOST counts

### Step 4: Save to Standard Location
```
C:\Cursor\TheGenie.ai\Development\NurtureEngine\Discovery\
```

### Step 5: Push to GitHub
```powershell
cd C:\Cursor\_ARCHIVE_Downloads\NOTION
Copy-Item "[report].csv" "TheGenie.ai/Development/NurtureEngine/Discovery/"
git add -A
git commit -m "Lead-to-Listing report [date]"
git push origin main
```

---

## 4. Key Fields

| Field | Description |
|-------|-------------|
| MlsNumber | Unique listing identifier |
| ListDate | When property was listed |
| LeadCreated | When lead was generated |
| DaysNurture | Days from lead to listing |
| LeadSource | ExternalApiSMS, Facebook, DirectMail, etc. |
| GenieAgent | Our agent who received the lead |
| ListingAgent | Agent who actually got the listing |
| Outcome | WON (our agent) or LOST (other agent) |
| ListPrice | Listing price |
| YearsOwned | Tenure of owner |
| OwnerOccupied | Y/N |

---

## 5. Deduplication Rules

1. **One row per MLS Number** - Use ROW_NUMBER() to select earliest lead
2. **7+ day gap required** - Filter out same-day leads (noise)
3. **Exclude internal roles** - Filter RoleId NOT IN (17, 23, 20, 5, 21, 11)

---

## 6. Date Format Rules

- All dates must be **MM/DD/YYYY** format
- Use FORMAT() function in SQL
- Master rule per Workspace Memory

---

## 7. Troubleshooting

| Issue | Solution |
|-------|----------|
| Query timeout | Add `SET LOCK_TIMEOUT 60000` |
| Special characters in CSV | Clean with REPLACE() |
| Duplicate rows | Check ROW_NUMBER() logic |
| Missing listings | Verify FIPS/FormattedAPN join |

---

## 8. Schedule

| Report | Frequency | Owner |
|--------|-----------|-------|
| Deduplicated | Monthly | Operations |
| By Year | Quarterly | Operations |
| Recent Wins | Weekly | Sales |
| Agent Performance | Monthly | Management |

---

## 9. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/15/2025 | Initial SOP |

