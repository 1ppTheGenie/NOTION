# SOP: Twilio Phone Number Inventory Report

**Version:** 1.0  
**Created:** 12-11-2025  
**Author:** Genie Analytics Team  
**Status:** Active  

---

## 1. Purpose

Generate a comprehensive inventory of all Twilio phone numbers in the account, including:
- Phone number details
- Category/purpose classification
- User assignments
- Usage status
- Monthly costs

---

## 2. Report Specifications

### 2.1 Output Files

| File | Description |
|------|-------------|
| `Twilio_Phone_Numbers_FULL_INVENTORY_v1.csv` | Complete inventory with all details |
| `Twilio_Phone_Usage_Assessment_v1.csv` | Usage analysis with activity status |

### 2.2 Column Definitions

| Column | Description | Source |
|--------|-------------|--------|
| Phone | Formatted phone number (+1 (XXX) XXX-XXXX) | phone_numbers_inventory.csv |
| FriendlyName | Twilio-assigned name | phone_numbers_inventory.csv |
| Category | Classification (Delivery Farm, User Assigned, etc.) | Derived from FriendlyName |
| Assigned_User | User name if assigned | Derived |
| DateCreated | Date number was provisioned (MM-DD-YYYY) | phone_numbers_inventory.csv |
| Monthly_Cost | Estimated monthly cost ($1.15 local, $2.15 toll-free) | Calculated |
| TotalMessages | Messages sent via TwilioMessage | TwilioMessage table |
| LastActivity | Most recent message date | TwilioMessage table |
| UsageStatus | ACTIVE/RECENT/STALE/DORMANT/NEVER USED | Calculated |
| IsAssignedInDB | Whether in TwilioPhoneNumber table | TwilioPhoneNumber table |

### 2.3 Category Classifications

| Category | Criteria |
|----------|----------|
| Delivery Farm Pool | FriendlyName contains "Delivery Farm" |
| SMS Farm Pool | FriendlyName contains "SMS Farm" |
| Number Farm Pool | FriendlyName contains "number farm" |
| User Assigned | FriendlyName contains user name pattern |
| ADP System | FriendlyName contains "ADP" |
| Other/System | All other numbers |

### 2.4 Usage Status Definitions

| Status | Definition |
|--------|------------|
| ACTIVE (30 days) | Sent messages within last 30 days |
| RECENT (90 days) | Sent messages within last 90 days |
| STALE (1 year) | Last activity 90 days - 1 year ago |
| DORMANT (>1 year) | Last activity over 1 year ago |
| NEVER USED | No messages ever sent |

---

## 3. Data Sources

### 3.1 Primary Source
- **File:** `phone_numbers_inventory.csv`
- **Location:** `C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\`
- **Origin:** Twilio Console export

### 3.2 Database Sources

```sql
-- TwilioMessage for usage data
SELECT [From], COUNT(*), MAX(DateSent)
FROM TwilioMessage
GROUP BY [From]

-- TwilioPhoneNumber for assignments
SELECT PhoneNumber, AspNetUserId, Enabled
FROM TwilioPhoneNumber
```

---

## 4. Execution

### 4.1 Script
- **File:** `analyze_phone_numbers_v1.py`
- **Location:** `C:\Cursor\`

### 4.2 Command
```powershell
python C:\Cursor\analyze_phone_numbers_v1.py
```

### 4.3 Dependencies
- pandas
- pyodbc
- Database access to FarmGenie (192.168.29.45)

---

## 5. Quality Checks

1. ✅ Total count matches Twilio invoice phone count
2. ✅ All categories sum to total
3. ✅ Monthly cost estimate within 5% of invoice
4. ✅ Date format: MM-DD-YYYY

---

## 6. Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12-11-2025 | Initial creation |

