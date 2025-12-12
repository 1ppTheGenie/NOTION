# SOP: Twilio Inbound Response Analysis - Delivery Farm Numbers

**Version:** 1.0  
**Created:** 12-10-2025  
**Author:** Genie Analytics Team  
**Status:** Active  

---

## 1. Purpose

Analyze inbound SMS responses to Delivery Farm phone numbers to:
- **Classify responses** into Opt-Outs vs Potential Engagement
- **Identify warm leads** (consumers who responded but did NOT opt out)
- **Track engagement** by Delivery Farm number
- **Monitor opt-out rates** and identify trends
- **Support lead routing** to appropriate agents

**Why This Matters:**
- Consumers who respond to marketing SMS but don't opt out are showing interest
- These are high-value leads that should be routed to agents immediately
- Monitoring opt-out rates helps maintain compliance and sender reputation
- This is an **ongoing operations task** that must be performed regularly

---

## 2. Report Specifications

### 2.1 Output File

| File | Description |
|------|-------------|
| `Twilio_DeliveryFarm_Inbound_Analysis_v1.csv` | Complete inbound response data with classifications |

### 2.2 Column Definitions

| Column | Description | Source |
|--------|-------------|--------|
| OurPhone | Delivery Farm phone number (normalized) | TwilioMessage [To] |
| ConsumerPhone | Consumer phone number (normalized) | TwilioMessage [From] |
| DateSent | Response timestamp | TwilioMessage DateSent |
| Status | Message status | TwilioMessage Status ('received') |
| Classification | Opt-Out or Potential Engagement | TwilioOptOut lookup |

### 2.3 Classification Logic

**Opt-Out:**
- Consumer phone number exists in `TwilioOptOut` table
- These consumers have explicitly opted out of SMS communications
- **Action:** Remove from future campaigns, respect opt-out

**Potential Engagement:**
- Consumer responded but is NOT in `TwilioOptOut` table
- These are warm leads showing interest
- **Action:** Route to agent, flag as high-priority lead

---

## 3. Data Sources

### 3.1 Primary Sources

1. **TwilioMessage Table**
   - Filter: `Status = 'received'` (inbound messages)
   - Filter: `DateSent >= '2025-01-01'` (or relevant date range)
   - Filter: `[To]` in Delivery Farm phone numbers

2. **TwilioOptOut Table**
   - All opted-out consumer phone numbers
   - Used to classify responses

3. **Phone Inventory**
   - File: `Twilio_Phone_Numbers_FULL_INVENTORY_v1.csv`
   - Filter: `Category = 'Delivery Farm Pool'`

### 3.2 Database Queries

```sql
-- Get all opted-out consumers
SELECT PhoneNumber, MessagingServiceName
FROM TwilioOptOut WITH (NOLOCK)

-- Get inbound messages to Delivery Farm numbers
SELECT 
    [To] as OurPhone,
    [From] as ConsumerPhone,
    DateSent,
    Status
FROM TwilioMessage WITH (NOLOCK)
WHERE Status = 'received'
  AND DateSent >= '2025-01-01'
  AND [To] IN (Delivery Farm phone numbers)
ORDER BY DateSent DESC
```

---

## 4. Execution

### 4.1 Script
- **File:** `analyze_inbound_responses_v1.py`
- **Location:** `C:\Cursor\`

### 4.2 Command
```powershell
python C:\Cursor\analyze_inbound_responses_v1.py
```

### 4.3 Frequency
- **Recommended:** Weekly or bi-weekly
- **Critical Periods:** After major campaigns (daily)
- **This is an ongoing operations task** - must stay on top of responses

---

## 5. Output Analysis

### 5.1 Summary Metrics

The script outputs:

1. **Response Classification Summary:**
   - Total Opt-Outs (count and percentage)
   - Total Potential Engagement (count and percentage)

2. **Unique Responder Analysis:**
   - Unique consumers who opted out
   - Unique consumers who engaged (warm leads)

3. **Top Engaged Responders:**
   - Consumers with highest response counts
   - These are priority leads for agent follow-up

4. **Engagement by Delivery Farm Number:**
   - Opt-outs per number
   - Engaged responses per number
   - Engagement rate per number

### 5.2 Key Insights

The script provides insights on:

1. **Engagement Opportunity:**
   - Number of warm leads (responded but didn't opt out)
   - These should be flagged for immediate agent follow-up

2. **Opt-Out Analysis:**
   - Total opt-outs (expected cost of marketing)
   - Monitor opt-out RATE (should be <2% of sends)

3. **Next Steps:**
   - Cross-reference engaged responders with GenieLead table
   - Check if they became actual leads
   - Build "missed opportunity" report for responses not converted

---

## 6. Action Items

### 6.1 For Warm Leads (Potential Engagement)

1. **Flag as High Priority:**
   - These phone numbers should be flagged in the system
   - Route to the agent whose area triggered the campaign

2. **Follow-Up Workflow:**
   - Consider automated follow-up for high-response consumers
   - Manual outreach for top engaged responders

3. **Lead Conversion Tracking:**
   - Cross-reference with GenieLead table
   - Track conversion rate of engaged responders

### 6.2 For Opt-Outs

1. **Respect Opt-Out:**
   - Ensure these numbers are removed from future campaigns
   - Verify opt-out is properly recorded in TwilioOptOut table

2. **Monitor Rate:**
   - Opt-out rate should be <2% of total sends
   - Investigate if rate exceeds threshold

---

## 7. Quality Checks

1. ✅ All Delivery Farm numbers included (73 as of 12-10-2025)
2. ✅ Phone numbers normalized correctly (10-digit format)
3. ✅ Opt-out classification matches TwilioOptOut table
4. ✅ Date range covers relevant period
5. ✅ Output file saved to correct location

---

## 8. Related Scripts

| Script | Purpose |
|--------|---------|
| `analyze_inbound_responses_v1.py` | **This analysis** - Classify and analyze inbound responses |
| `delivery_farm_with_responses_v1.py` | Track usage and response rates |
| `check_inbound_responses_v1.py` | Verify inbound message capability |

---

## 9. Expected Benchmarks

| Metric | Expected Range | Action if Exceeded |
|--------|----------------|-------------------|
| Opt-Out Rate | <2% of sends | Investigate campaign content |
| Engagement Rate | 2-4% of sends | Normal - route to agents |
| Single Responder Dominance | <50% of responses | Investigate for bot activity |

---

## 10. Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12-10-2025 | Initial creation - Inbound response classification and analysis |

---

## 11. Notes

- **This is one of many scripts** that may accomplish similar tasks
- **Operations must stay on top of this** - it's a critical ongoing job
- Consider automating lead routing for high-engagement responders
- Regular monitoring helps identify trends and opportunities early


