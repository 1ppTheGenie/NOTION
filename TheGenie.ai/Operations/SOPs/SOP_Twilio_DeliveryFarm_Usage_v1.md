# SOP: Twilio Delivery Farm Usage & Response Report

**Version:** 1.0  
**Created:** 12-11-2025  
**Author:** Genie Analytics Team  
**Status:** Active  

---

## 1. Purpose

Generate a report of Delivery Farm phone number activity including:
- Outbound messages sent
- Inbound responses received
- Response rates by number, city, and state
- Geographic distribution analysis

---

## 2. Report Specifications

### 2.1 Output File

| File | Description |
|------|-------------|
| `Twilio_DeliveryFarm_Usage_Responses_2025_v1.csv` | Full usage and response data |

### 2.2 Column Definitions

| Column | Description | Source |
|--------|-------------|--------|
| Phone | Formatted phone number | Inventory |
| FriendlyName | Twilio name | Inventory |
| AreaCode | 3-digit area code | Extracted from Phone |
| City | City/region name | Area code mapping |
| State | 2-letter state code | Area code mapping |
| Outbound2025 | Messages sent in 2025 | TwilioMessage WHERE [From] = Phone |
| Inbound2025 | Responses received in 2025 | TwilioMessage WHERE [To] = Phone AND Status = 'received' |
| ResponseRate | (Inbound / Outbound) * 100 | Calculated |
| DateCreated | Provisioning date (MM-DD-YYYY) | Inventory |

### 2.3 Area Code Mapping

| State | Area Codes |
|-------|------------|
| CA | 209, 213, 310, 408, 415, 424, 510, 562, 619, 626, 650, 714, 760, 805, 818, 858, 909, 925, 949 |
| FL | 321, 352, 407 |
| TX | 512, 972 |

---

## 3. Data Sources

### 3.1 Primary Source
- **File:** `Twilio_Phone_Numbers_FULL_INVENTORY_v1.csv`
- **Filter:** Category = 'Delivery Farm Pool'

### 3.2 Database Queries

```sql
-- Outbound count
SELECT 
    REPLACE([From], '+1', '') as Phone,
    COUNT(*) as Outbound2025
FROM TwilioMessage
WHERE DateSent >= '2025-01-01' AND DateSent < '2026-01-01'
  AND [From] IS NOT NULL
GROUP BY [From]

-- Inbound count (responses)
SELECT 
    REPLACE([To], '+1', '') as Phone,
    COUNT(*) as Inbound2025
FROM TwilioMessage
WHERE DateSent >= '2025-01-01' AND DateSent < '2026-01-01'
  AND [To] IS NOT NULL
  AND Status = 'received'
GROUP BY [To]
```

---

## 4. Execution

### 4.1 Script
- **File:** `delivery_farm_with_responses_v1.py`
- **Location:** `C:\Cursor\`

### 4.2 Command
```powershell
python C:\Cursor\delivery_farm_with_responses_v1.py
```

---

## 5. Expected Benchmarks

| Metric | Expected Range |
|--------|----------------|
| Response Rate (Overall) | 2-4% |
| Response Rate (by number) | 1-6% |
| Anomaly Threshold | >10% (investigate) |

---

## 6. Anomaly Investigation

If a number shows >10% response rate:

1. Check for single responder dominating count
2. Review monthly breakdown for spikes
3. Check hour-of-day patterns (bot indicators)
4. Verify legitimate business use

**Investigation Script:** `investigate_bot_number_v1.py`

---

## 7. Quality Checks

1. ✅ Total Delivery Farm count = 73 (as of 12-11-2025)
2. ✅ Sort by State, then Outbound descending
3. ✅ Date format: MM-DD-YYYY
4. ✅ Separate City and State columns
5. ✅ Response rate calculated correctly

---

## 8. Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12-11-2025 | Initial creation with outbound, inbound, response rate |

