# Twilio Inbound Response Analysis - Technical Specification

**Version:** 1.0  
**Created:** 12-10-2025  
**Author:** Genie Analytics Team  
**Status:** Active  

---

## 1. Report Overview

**Purpose:** Analyze and classify inbound SMS responses to Delivery Farm phone numbers to identify warm leads and monitor opt-out rates.

**Output:** `Twilio_DeliveryFarm_Inbound_Analysis_v1.csv`

**Classification Categories:**
1. **Opt-Out** - Consumer has opted out (in TwilioOptOut table)
2. **Potential Engagement** - Consumer responded but did NOT opt out (warm lead)

---

## 2. Database Schema Reference

### 2.1 TwilioMessage Table

| Column | Type | Description |
|--------|------|-------------|
| Sid | varchar | Twilio message SID |
| DateSent | datetime | Message timestamp |
| To | varchar | Recipient phone (our Delivery Farm number) |
| From | varchar | Sender phone (consumer phone) |
| Status | varchar | 'received' for inbound messages |
| Body | varchar | Message content (if available) |

**Key Filter:**
- `Status = 'received'` - Only inbound messages
- `DateSent >= '2025-01-01'` - Date range filter

### 2.2 TwilioOptOut Table

| Column | Type | Description |
|--------|------|-------------|
| PhoneNumber | varchar | Opted-out consumer phone |
| MessagingServiceName | varchar | Service name |

**Purpose:** Identify which consumers have opted out

### 2.3 Phone Number Normalization

```python
def normalize_phone(p):
    """Convert phone to 10-digit format: XXXXXXXXXX"""
    p = str(p).replace('+1', '').replace('+', '')
    p = p.replace('-', '').replace('(', '').replace(')', '').replace(' ', '')
    if len(p) == 11 and p.startswith('1'):
        p = p[1:]  # Remove leading 1
    return p  # Returns 10-digit format
```

**Why Normalize:**
- Phone numbers stored in various formats (+1, dashes, parentheses)
- Normalization ensures accurate matching between tables

---

## 3. Classification Logic

### 3.1 Opt-Out Classification

```python
def classify_response(consumer_phone):
    """Classify inbound response"""
    if consumer_phone in opted_out_consumers:
        return 'Opt-Out'
    else:
        return 'Potential Engagement'
```

**Logic:**
1. Normalize consumer phone number
2. Check if exists in TwilioOptOut table (normalized)
3. If exists → 'Opt-Out'
4. If not exists → 'Potential Engagement'

### 3.2 Data Flow

```
TwilioMessage (Status='received')
    ↓
Filter to Delivery Farm numbers
    ↓
Normalize phone numbers
    ↓
Join with TwilioOptOut (normalized)
    ↓
Classify: Opt-Out vs Potential Engagement
    ↓
Generate analysis and reports
```

---

## 4. Output File Structure

### 4.1 CSV Columns

| Column | Description | Example |
|--------|-------------|---------|
| OurPhone | Delivery Farm number (normalized) | 4083514056 |
| ConsumerPhone | Consumer phone (normalized) | 8312781626 |
| DateSent | Response timestamp | 2025-11-15 14:23:45 |
| Status | Message status | received |
| Classification | Opt-Out or Potential Engagement | Potential Engagement |

### 4.2 File Location

```
C:\Cursor\Twilio_DeliveryFarm_Inbound_Analysis_v1.csv
```

---

## 5. Analysis Outputs

### 5.1 Summary Statistics

1. **Response Classification Summary:**
   - Total Opt-Outs (count, percentage)
   - Total Potential Engagement (count, percentage)

2. **Unique Responder Analysis:**
   - Unique consumers who opted out
   - Unique consumers who engaged (warm leads)

3. **Top Engaged Responders:**
   - Top 20 consumers by response count
   - Priority leads for agent follow-up

4. **Engagement by Delivery Farm Number:**
   - Opt-outs per number
   - Engaged responses per number
   - Total responses per number
   - Engagement rate per number

### 5.2 Console Output

The script prints:
- Response classification summary
- Unique responder counts
- Top engaged responders table
- Engagement by Delivery Farm number table
- Key insights and recommendations

---

## 6. Data Quality Requirements

### 6.1 Phone Number Matching

- **Requirement:** All phone numbers must be normalized before comparison
- **Validation:** Verify normalization function handles all formats
- **Test Cases:**
  - `+1 (408) 351-4056` → `4083514056`
  - `408-351-4056` → `4083514056`
  - `14083514056` → `4083514056`

### 6.2 Classification Accuracy

- **Requirement:** 100% accurate classification (binary: Opt-Out or Potential Engagement)
- **Validation:** Cross-check sample with TwilioOptOut table
- **Edge Cases:**
  - Consumer opts out AFTER responding → Classify as Opt-Out (current state)
  - Multiple responses from same consumer → Each response classified independently

### 6.3 Date Range

- **Requirement:** Configurable date range (default: 2025-01-01 to current)
- **Validation:** Ensure all relevant responses included
- **Consideration:** Historical data may be large - consider monthly batches

---

## 7. Performance Considerations

### 7.1 Query Optimization

- Use `WITH (NOLOCK)` for read-only queries
- Index on `TwilioMessage.Status` and `TwilioMessage.DateSent`
- Index on `TwilioOptOut.PhoneNumber` (normalized)

### 7.2 Data Volume

- **Typical:** 10,000-50,000 inbound messages per year
- **Peak:** 1,000+ per day during campaigns
- **Processing Time:** <30 seconds for full year

### 7.3 Memory Usage

- Load TwilioOptOut into set for O(1) lookup
- Process TwilioMessage in batches if needed
- Use pandas for efficient data manipulation

---

## 8. Integration Points

### 8.1 Lead Routing System

**Integration:** Route "Potential Engagement" responders to agents
- **Trigger:** New warm lead identified
- **Action:** Create GenieLead record or flag existing lead
- **Priority:** High (responded but didn't opt out)

### 8.2 Campaign Management

**Integration:** Monitor opt-out rates by campaign
- **Trigger:** Opt-out rate exceeds threshold
- **Action:** Review campaign content, adjust messaging
- **Threshold:** >2% opt-out rate

### 8.3 Reporting Dashboard

**Integration:** Include metrics in operations dashboard
- **Metrics:** Total responses, engagement rate, opt-out rate
- **Frequency:** Weekly updates
- **Visualization:** Charts showing trends over time

---

## 9. Script Dependencies

### 9.1 Python Libraries

```python
import pandas as pd
import pyodbc
```

### 9.2 Database Connection

```python
# SQL Server connection
SERVER = '192.168.29.45,1433'
DATABASE = 'FarmGenie'
UID = 'cursor'
PWD = '1ppINSAyay$'
```

### 9.3 Input Files

- `Twilio_Phone_Numbers_FULL_INVENTORY_v1.csv` - Delivery Farm phone list

---

## 10. Error Handling

### 10.1 Database Connection

- **Error:** Connection timeout
- **Action:** Retry with exponential backoff
- **Log:** Connection errors to file

### 10.2 Data Validation

- **Error:** Missing required columns
- **Action:** Validate schema before processing
- **Log:** Schema validation errors

### 10.3 Phone Normalization

- **Error:** Invalid phone format
- **Action:** Log invalid phones, skip or flag
- **Log:** Invalid phone numbers for review

---

## 11. File Naming Convention

```
Twilio_DeliveryFarm_Inbound_Analysis_[DateRange]_v[Version].csv

Example:
Twilio_DeliveryFarm_Inbound_Analysis_v1.csv
```

---

## 12. Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12-10-2025 | Initial specification - Inbound response classification and analysis |

---

## 13. Related Documents

- `SOP_Twilio_Inbound_Response_Analysis_v1.md` - Standard Operating Procedure
- `SOP_Twilio_DeliveryFarm_Usage_v1.md` - Usage tracking SOP
- `SPEC_Twilio_PhoneNumber_Reports_v1.md` - General phone number reports spec


