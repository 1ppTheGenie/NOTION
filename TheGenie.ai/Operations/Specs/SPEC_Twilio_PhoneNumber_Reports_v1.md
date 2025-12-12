# Twilio Phone Number Reports - Technical Specification

**Version:** 1.0  
**Created:** 12-11-2025  
**Author:** Genie Analytics Team  
**Status:** Active  

---

## 1. Report Suite Overview

| Report | Purpose | Primary Output |
|--------|---------|----------------|
| Phone Inventory | Complete list of all Twilio numbers | `Twilio_Phone_Numbers_FULL_INVENTORY_v1.csv` |
| Usage Assessment | Identify orphan/unused numbers | `Twilio_Phone_Usage_Assessment_v1.csv` |
| Delivery Farm Usage | Pool number activity & responses | `Twilio_DeliveryFarm_Usage_Responses_2025_v1.csv` |

---

## 2. Database Schema Reference

### 2.1 TwilioMessage Table

| Column | Type | Description |
|--------|------|-------------|
| Sid | varchar | Twilio message SID |
| DateSent | datetime | Message timestamp |
| To | varchar | Recipient phone |
| From | varchar | Sender phone |
| Status | varchar | delivered/sent/received/undelivered/failed |
| Price | decimal | Message cost |
| PriceUnit | varchar | Currency (USD) |
| ErrorCode | int | Error code if failed |
| ErrorMessage | varchar | Error description |

### 2.2 TwilioPhoneNumber Table

| Column | Type | Description |
|--------|------|-------------|
| PhoneNumber | varchar | Phone number |
| AspNetUserId | uniqueidentifier | Assigned user |
| Enabled | bit | Active status |
| CreateDate | datetime | Provisioning date |

### 2.3 Key Status Values

| Status | Meaning | Direction |
|--------|---------|-----------|
| sent | Queued for delivery | Outbound |
| delivered | Successfully delivered | Outbound |
| undelivered | Failed to deliver | Outbound |
| failed | Error occurred | Outbound |
| received | Inbound message | Inbound |

---

## 3. Phone Number Normalization

### 3.1 Standard Format
```
+1 (XXX) XXX-XXXX
```

### 3.2 Normalization Function
```python
def normalize_phone(p):
    p = str(p).replace('+1', '').replace('+', '')
    p = p.replace('-', '').replace('(', '').replace(')', '').replace(' ', '')
    if len(p) == 11 and p.startswith('1'):
        p = p[1:]
    return p  # Returns 10-digit format: XXXXXXXXXX
```

---

## 4. Area Code to Location Mapping

```python
AREA_CODE_MAP = {
    # California
    '209': ('Stockton/Modesto', 'CA'),
    '213': ('Los Angeles', 'CA'),
    '310': ('West LA/Santa Monica', 'CA'),
    '408': ('San Jose', 'CA'),
    '415': ('San Francisco', 'CA'),
    '424': ('Los Angeles', 'CA'),
    '510': ('Oakland/East Bay', 'CA'),
    '562': ('Long Beach', 'CA'),
    '619': ('San Diego', 'CA'),
    '626': ('Pasadena', 'CA'),
    '650': ('San Mateo/Palo Alto', 'CA'),
    '714': ('Orange County', 'CA'),
    '760': ('North San Diego', 'CA'),
    '805': ('Ventura/Santa Barbara', 'CA'),
    '818': ('San Fernando Valley', 'CA'),
    '858': ('San Diego', 'CA'),
    '909': ('Inland Empire', 'CA'),
    '925': ('Contra Costa', 'CA'),
    '949': ('South Orange County', 'CA'),
    # Florida
    '321': ('Orlando', 'FL'),
    '352': ('Gainesville/Ocala', 'FL'),
    '407': ('Orlando', 'FL'),
    # Texas
    '512': ('Austin', 'TX'),
    '972': ('Dallas', 'TX'),
}
```

---

## 5. Cost Calculations

### 5.1 Monthly Phone Costs

| Type | Monthly Cost |
|------|-------------|
| Local Number | $1.15 |
| Toll-Free (8XX) | $2.15 |

### 5.2 Cost Detection
```python
def get_monthly_cost(phone):
    if '844' in phone or '855' in phone or '800' in phone or '888' in phone:
        return 2.15
    return 1.15
```

---

## 6. Usage Status Classification

```python
def classify_usage(last_activity, total_messages):
    if total_messages == 0:
        return 'NEVER USED'
    
    days_ago = (datetime.now() - last_activity).days
    
    if days_ago <= 30:
        return 'ACTIVE (30 days)'
    elif days_ago <= 90:
        return 'RECENT (90 days)'
    elif days_ago <= 365:
        return 'STALE (1 year)'
    else:
        return 'DORMANT (>1 year)'
```

---

## 7. Response Rate Calculation

```python
response_rate = (inbound_count / outbound_count) * 100

# Benchmarks
NORMAL_RATE = 2.0 - 4.0  # percent
ANOMALY_THRESHOLD = 10.0  # percent - investigate if exceeded
```

---

## 8. Report Date Format

**Standard:** `MM-DD-YYYY`

```python
df['DateCreated'] = pd.to_datetime(df['DateCreated']).dt.strftime('%m-%d-%Y')
```

---

## 9. File Naming Convention

```
Twilio_[ReportType]_[Scope]_[DateRange]_v[Version].csv

Examples:
- Twilio_Phone_Numbers_FULL_INVENTORY_v1.csv
- Twilio_Phone_Usage_Assessment_v1.csv
- Twilio_DeliveryFarm_Usage_Responses_2025_v1.csv
```

---

## 10. Quality Gates

| Check | Requirement |
|-------|-------------|
| Phone count | Matches Twilio invoice |
| Cost estimate | Within 5% of invoice |
| Date format | MM-DD-YYYY |
| State/City | Separate columns |
| Sort order | By State, then by metric |
| Response rate | Flag if >10% |

---

## 11. Scripts Reference

| Script | Purpose |
|--------|---------|
| `analyze_phone_numbers_v1.py` | Full inventory with categories |
| `assess_phone_usage_v1.py` | Usage assessment and orphan detection |
| `delivery_farm_usage_2025_v1.py` | Delivery Farm outbound only |
| `delivery_farm_with_responses_v1.py` | Delivery Farm with inbound responses |
| `investigate_bot_number_v1.py` | Anomaly investigation |
| `check_inbound_responses_v1.py` | Inbound capability check |

---

## 12. Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12-11-2025 | Initial specification |

