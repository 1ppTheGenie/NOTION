# Database Access Guide for AI Agents

## Overview
This project has direct database access to the production SQL Server. Scripts can query data directly without needing SSMS exports.

---

## Connection Details

```python
# Working connection pattern (use pyodbc, NOT pymssql)
import pyodbc

USER = "cursor"
PASSWORD = "1ppINSAyay$"
SERVER = "192.168.29.45"
DEFAULT_PORT = 1433

DATABASES = ["FarmGenie", "TitleData", "MlsListing"]
```

### Connection String Pattern
```python
def get_connection_string(driver: str, database: str) -> str:
    return (
        f"DRIVER={{{driver}}};"
        f"SERVER={SERVER},{DEFAULT_PORT};"
        f"DATABASE={database};"
        f"UID={USER};"
        f"PWD={PASSWORD};"
        "Encrypt=yes;"
        "TrustServerCertificate=yes"
    )

# Select driver (prefer 17 or 18)
drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])

# Connect
conn = pyodbc.connect(get_connection_string(driver, "FarmGenie"), autocommit=True)
```

### Important Notes
- **USE `pyodbc`** - pymssql hangs on this server
- SQL Server version: Microsoft SQL Server 2012 (SP4)
- Network: Server is on local network (192.168.29.x)

---

## Known Databases

### FarmGenie (Primary)
Main application database for the Genie real estate marketing platform.

**Key Tables:**
| Table | Purpose |
|-------|---------|
| `NotificationQueue` | SMS messages sent to prospects (audience SMS) |
| `TwilioMessage` | Twilio API message data with costs/status |
| `GenieLead` | Lead records with engagement tracking |
| `PropertyCollectionDetail` | Campaign/property collection data |
| `AspNetUsers` | User accounts |
| `ShortUrlData` | Short URL tracking for SMS links |

### TitleData
Title/escrow related data.

### MlsListing
MLS listing data for properties.

---

## Key Table Schemas

### NotificationQueue
```sql
-- SMS messages sent through the system
-- NotificationChannelId = 2 means SMS
SELECT 
    NotificationQueueId,
    CreateDate AS SmsDate,
    ProviderResponseKey AS MessageSid,  -- Twilio SID
    CustomData,                          -- JSON with campaign/user data
    AspNetUserIdFrom,
    NotificationChannelId
FROM dbo.NotificationQueue
WHERE NotificationChannelId = 2  -- SMS only
```

**CustomData JSON contains:**
- `TagMarketedByFirstName` / `TagMarketedByLastName` - Customer name for billing
- `TagLeadPropertyCollectionDetailId` - Campaign ID
- `ToPhoneNumber` - Recipient phone
- `Message` - SMS text content

### TwilioMessage
```sql
-- Twilio message costs and delivery status
SELECT Sid, DateSent, Status, Price, PriceUnit, [From], [To], ErrorCode
FROM dbo.TwilioMessage
```

---

## Working Query Examples

### Export SMS with Customer Data (for cost attribution)
```sql
SELECT 
    q.NotificationQueueId,
    q.CreateDate AS SmsDate,
    q.ProviderResponseKey AS MessageSid,
    CAST(q.CustomData AS nvarchar(max)) AS RawCustomData
FROM dbo.NotificationQueue q WITH (NOLOCK)
WHERE q.NotificationChannelId = 2
  AND q.CreateDate >= '2025-10-01'
  AND q.CreateDate < '2025-11-01'
  AND q.ProviderResponseKey IS NOT NULL
```

### Get Top Tables by Row Count
```sql
SELECT TOP 20
    s.name AS schema_name,
    t.name AS table_name,
    SUM(ps.row_count) AS row_count
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.dm_db_partition_stats ps
    ON ps.object_id = t.object_id
    AND ps.index_id IN (0, 1)
GROUP BY s.name, t.name
ORDER BY row_count DESC
```

### Check Table Exists
```sql
SELECT COUNT(*) 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'NotificationQueue'
```

---

## Available Scripts

| Script | Purpose |
|--------|---------|
| `export_cc_sms_withdetails_v2.py` | Export NotificationQueue data to CSV |
| `build_oct_2025_bycustomer_v5.py` | Generate customer cost report from CSV |
| `sync_twilio_to_database_v1.py` | Sync Twilio API data to database |
| `build_report_from_csv_and_twilio_FINAL.py` | Full campaign cost report |

---

## Common Tasks

### Export Data from Database
```bash
# Activate venv first
& ".\.venv\Scripts\Activate.ps1"

# Export October 2025 SMS data
python export_cc_sms_withdetails_v2.py --start-date 2025-10-01 --end-date 2025-10-31

# Test connection only
python export_cc_sms_withdetails_v2.py --test-only
```

### Run Cost Reports
```bash
python build_oct_2025_bycustomer_v5.py
```

---

## Creating New Database Scripts

Template for new database export scripts:

```python
#!/usr/bin/env python3
"""
Script purpose here
"""
import pyodbc
import pandas as pd
from pathlib import Path

# Connection settings
USER = "cursor"
PASSWORD = "1ppINSAyay$"
SERVER = "192.168.29.45"
DATABASE = "FarmGenie"
PORT = 1433

def select_driver():
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    return next((d for d in drivers if "17" in d or "18" in d), drivers[-1])

def connect():
    driver = select_driver()
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={SERVER},{PORT};"
        f"DATABASE={DATABASE};"
        f"UID={USER};PWD={PASSWORD};"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)

def main():
    conn = connect()
    
    query = """
    SELECT * FROM dbo.YourTable WHERE ...
    """
    
    df = pd.read_sql(query, conn)
    df.to_csv("output.csv", index=False)
    
    conn.close()

if __name__ == "__main__":
    main()
```

---

## Troubleshooting

### Connection Hangs
- **DON'T use pymssql** - it hangs on this server
- **DO use pyodbc** with ODBC Driver 17 or 18

### Test Network Connectivity
```powershell
Test-NetConnection -ComputerName 192.168.29.45 -Port 1433
```

### Check Available Drivers
```python
import pyodbc
print(pyodbc.drivers())
# Should include: 'ODBC Driver 17 for SQL Server' or 'ODBC Driver 18 for SQL Server'
```

---

## File Naming Conventions

- SQL exports: `0XXX.TableName_Description.csv` (e.g., `0301.CC_SMS_WithDetails_v2.csv`)
- Reports: `Genie_Twilio-[ReportType]_[DateRange]_vX.xlsx`
- Scripts: `[action]_[description]_vX.py` (e.g., `export_cc_sms_withdetails_v2.py`)

---

## Virtual Environment

```powershell
# Activate (PowerShell)
& ".\.venv\Scripts\Activate.ps1"

# Required packages
pip install pyodbc pandas openpyxl python-dotenv
```

---

## Product Type Definitions (CC/LC/NC)

### How Products Are Identified

**Primary Source:** `utm_source` field in `ShortUrlData.Data` JSON
```python
# Extract from ShortUrlData.Data JSON:
# "utm_source": "Competition Command"  → CC
# "utm_source": "Listing Command"      → LC  
# "utm_source": "Neighborhood Command" → NC
```

**Secondary Source:** Campaign name patterns in `PropertyCollectionDetail.Name`
- `"- Sold - SMS"` → CC (Competition Command)
- `"- Active - SMS"` → LC (Listing Command)

### Product Definitions (Pending Confirmation)
| Code | Name | Description |
|------|------|-------------|
| CC | Competition Command | SMS to neighbors of **SOLD** properties |
| LC | Listing Command | SMS to neighbors of **ACTIVE** listings |
| NC | Neighborhood Command | SMS to general neighborhood area |

### Key Tables for Product Attribution
- `ShortUrlData` - Contains `utm_source` in `Data` JSON column
- `PropertyCollectionDetail` - Campaign names with Sold/Active patterns
- `PropertyCollectionType` - Collection METHOD (not product type!)

### Code Reference
See `build_report_from_csv_and_twilio_FINAL.py` lines 361-393 for product type extraction logic.

---

*Last updated: 2025-12-09*

