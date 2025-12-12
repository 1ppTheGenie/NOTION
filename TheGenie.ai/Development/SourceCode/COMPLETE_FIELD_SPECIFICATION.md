# Complete Field Specification - Dave Higgins October 2025 Report
## All 21 Fields with Purpose, Use Case, Approach, and Expected Results

## CRITICAL RULE: AREA ID vs AREA NAME

**AreaId = INTERNAL ONLY**
- NEVER displayed to users
- NEVER asked from users
- Used only for database filtering (#1 PRIMARY FILTER criteria)

**Area Name = USER-FACING ONLY**
- Users provide Area Name as input (e.g., "Piedmont | 94611")
- Displayed in report header
- System converts Area Name → AreaId internally

**See:** `AREA_ID_VS_AREA_NAME_SPEC.md` for complete specification

---

## REPORT HEADER FIELDS

### HEADER 1: For (Agent Name)

**Purpose:**  
Identifies which agent this report is for.

**Use Case:**  
- Agent receives monthly report and confirms it's theirs
- System can generate reports for multiple agents
- Audit trail for who the report was generated for

**Approach:**  
```sql
SELECT 'David Higgins' AS [For]
FROM FarmGenie.dbo.AspNetUsers
WHERE Id = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
```

**Expected Results (5 rows):**
```
For
--------------
David Higgins
David Higgins
David Higgins
David Higgins
David Higgins
```

---

### HEADER 2: Date Range

**Purpose:**  
Shows the time period covered by this report.

**Use Case:**  
- Agent knows which month's activity is being reported
- Allows comparison between different months
- Confirms report is for correct time period

**Approach:**  
```sql
DECLARE @MonthStart DATE = '2025-10-01';
DECLARE @MonthEnd DATE = '2025-10-31';

SELECT CONVERT(VARCHAR(10), @MonthStart, 101) + ' - ' + CONVERT(VARCHAR(10), @MonthEnd, 101) AS [Date Range]
```

**Expected Results (5 rows):**
```
Date Range
----------------------
10/01/2025 - 10/31/2025
10/01/2025 - 10/31/2025
10/01/2025 - 10/31/2025
10/01/2025 - 10/31/2025
10/01/2025 - 10/31/2025
```

---

### HEADER 3: Area Name

**CRITICAL RULE: AreaId is INTERNAL ONLY - NEVER displayed or asked from users**

**Purpose:**  
Shows the marketing-friendly name of the geographic area where campaigns were run.

**Use Case:**  
- Agent provides Area Name as input (e.g., "Piedmont | 94611")
- System converts Area Name → AreaId internally for filtering
- AreaId is NEVER displayed to users
- Area Name is displayed in report header (user-friendly)
- Uses agent's custom override name if they've set one

**Approach:**  
```sql
SELECT TOP 1 
    COALESCE(pno.FriendlyName, va.AreaName, va.PolygonName) AS [Area Name]
FROM FarmGenie.dbo.PropertyCollectionDetail pcd
INNER JOIN FarmGenie.dbo.ViewArea va ON va.AreaId = pcd.AreaId
LEFT JOIN FarmGenie.dbo.PolygonNameOverride pno 
    ON pno.PolygonId = va.AreaId 
    AND pno.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01';
```

**Priority Order (3 levels only - NO FALLBACK):**
1. PolygonNameOverride.FriendlyName (agent's custom name)
2. ViewArea.AreaName (default marketing name)
3. ViewArea.PolygonName (polygon name)

**If all 3 are NULL, Area Name will be NULL (no fallback)**

**Expected Results (5 rows):**
```
Area Name
-----------------
Piedmont | 94611
Piedmont | 94611
Piedmont | 94611
Piedmont | 94611
Piedmont | 94611
```

---

## FIELD 1: Campaign Date

**Purpose:**  
The date when the agent created and launched the marketing campaign.

**Use Case:**  
- Track when campaigns were launched
- Analyze campaign frequency over time
- Correlate campaign timing with market conditions
- Sort campaigns chronologically

**Approach:**  
```sql
SELECT 
    pcd.PropertyCollectionDetailId,
    CONVERT(VARCHAR(10), pcd.CreateDate, 101) AS [Campaign Date]
FROM FarmGenie.dbo.PropertyCollectionDetail pcd
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01'
ORDER BY pcd.CreateDate;
```

**Data Source:**  
- Table: `FarmGenie.dbo.PropertyCollectionDetail`
- Column: `CreateDate`
- Format: MM/DD/YYYY

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Campaign Date
---------------------------|---------------
16819                      | 10/04/2025
16820                      | 10/04/2025
16825                      | 10/07/2025
16830                      | 10/09/2025
16835                      | 10/11/2025
```

---

## FIELD 2: Campaign Type

**Purpose:**  
Identifies the marketing campaign category (Competition Command, Listing Command, Nurture Command, or Facebook).

**Use Case:**  
- Distinguish between SMS-based campaigns and social media campaigns
- Filter reports by campaign type
- Compare performance across different campaign strategies
- Track which campaign types agent uses most

**Approach:**  
```sql
SELECT 
    pcd.PropertyCollectionDetailId,
    CASE 
        WHEN pcd.Name LIKE '%SMS%' THEN 'Competition Command'
        WHEN pcd.Name LIKE '%FB%' THEN 'Facebook'
        WHEN pcd.Name LIKE '%LC%' THEN 'Listing Command'
        WHEN pcd.Name LIKE '%NC%' THEN 'Nurture Command'
        ELSE 'Competition Command'
    END AS [Campaign Type]
FROM FarmGenie.dbo.PropertyCollectionDetail pcd
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01';
```

**Data Source:**  
- Table: `FarmGenie.dbo.PropertyCollectionDetail`
- Column: `Name` (parsed)
- Logic: Pattern matching on campaign name

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Campaign Type
---------------------------|-------------------
16819                      | Competition Command
16820                      | Competition Command
16825                      | Facebook
16830                      | Competition Command
16835                      | Competition Command
```

---

## FIELD 3: Subject Property

**Purpose:**  
The property address that is the focus of the marketing campaign (typically a recently sold or active listing).

**Use Case:**  
- Identify which property each campaign is promoting
- Track lead generation per property
- Calculate ROI per property marketed
- Agent can review campaign performance by specific property

**Approach:**  
```sql
SELECT 
    pcd.PropertyCollectionDetailId,
    CASE 
        WHEN CHARINDEX(' - ', pcd.Name) > 0 
        THEN LEFT(pcd.Name, CHARINDEX(' - ', pcd.Name) - 1)
        ELSE pcd.Name
    END AS [Subject Property]
FROM FarmGenie.dbo.PropertyCollectionDetail pcd
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01';
```

**Data Source:**  
- Table: `FarmGenie.dbo.PropertyCollectionDetail`
- Column: `Name` (parsed - extract address before first " - ")
- Example: "35 Randwick Ave - Sold - SMS" → "35 Randwick Ave"

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Subject Property
---------------------------|------------------
16819                      | 35 Randwick Ave
16820                      | 42 Ocean View Dr
16825                      | 15 Highland Rd
16830                      | 88 Lakeshore Blvd
16835                      | 22 Mountain View
```

---

## FIELD 4: Property Type

**Purpose:**  
The type of property being marketed (SFR, Condo, Townhouse, Multi-Family). This is set in the campaign configuration, not from the actual property.

**Use Case:**  
- Understand which property types generate most engagement
- Target specific property types for future campaigns
- Analyze market trends by property type
- Filter reports by property type

**Approach:**  
```sql
SELECT 
    pcd.PropertyCollectionDetailId,
    CASE pc.PropertyTypeId
        WHEN 0 THEN 'SFR'
        WHEN 1 THEN 'Condo'
        WHEN 2 THEN 'Townhouse'
        WHEN 3 THEN 'Multi-Family'
        ELSE 'Other'
    END AS [Property Type]
FROM FarmGenie.dbo.PropertyCollectionDetail pcd
LEFT JOIN FarmGenie.dbo.PropertyCastWorkflowQueue pcwq 
    ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
LEFT JOIN FarmGenie.dbo.PropertyCast pc 
    ON pc.PropertyCastId = pcwq.PropertyCastId
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01';
```

**Data Source:**  
- Table: `FarmGenie.dbo.PropertyCast`
- Column: `PropertyTypeId`
- Join Path: PropertyCollectionDetail → PropertyCastWorkflowQueue → PropertyCast
- Mapping: 0=SFR, 1=Condo, 2=Townhouse, 3=Multi-Family

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Property Type
---------------------------|-------------
16819                      | SFR
16820                      | SFR
16825                      | Condo
16830                      | SFR
16835                      | Townhouse
```

---

## FIELD 5: Listing Status

**Purpose:**  
The trigger type that launched the campaign (Listing New, Listing Sold). This is set in the PropertyCast configuration, NOT parsed from campaign name.

**Use Case:**  
- Distinguish between "Just Sold" campaigns and "New Listing" campaigns
- Analyze which trigger types generate better engagement
- Track campaign strategy effectiveness
- Sold properties generate buyer leads, active listings generate seller leads

**Approach:**  
```sql
SELECT 
    pcd.PropertyCollectionDetailId,
    pctt.Name AS [Listing Status]
FROM FarmGenie.dbo.PropertyCollectionDetail pcd
LEFT JOIN FarmGenie.dbo.PropertyCastWorkflowQueue pcwq 
    ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
LEFT JOIN FarmGenie.dbo.PropertyCast pc 
    ON pc.PropertyCastId = pcwq.PropertyCastId
LEFT JOIN FarmGenie.dbo.PropertyCastTriggerType pctt 
    ON pctt.PropertyCastTriggerTypeId = pc.PopertyCastTriggerTypeId
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01';
```

**Data Source:**  
- Table: `FarmGenie.dbo.PropertyCastTriggerType`
- Column: `Name`
- Join Path: PropertyCollectionDetail → PropertyCastWorkflowQueue → PropertyCast → PropertyCastTriggerType
- Values: "Listing New", "Listing Sold"

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Listing Status
---------------------------|---------------
16819                      | Listing Sold
16820                      | Listing New
16825                      | Listing Sold
16830                      | Listing Sold
16835                      | Listing New
```

---

## FIELD 6: Property Collection Count

**Purpose:**  
The target number of properties (comparable homes) included in the marketing campaign. This is the configuration setting, not the actual count.

**Use Case:**  
- Indicates campaign size and reach
- Directly correlates to SMS cost (more properties = more messages)
- Calculate cost per property reached
- ROI analysis and campaign planning

**Approach:**  
```sql
SELECT 
    pcd.PropertyCollectionDetailId,
    ISNULL(pcd.PropertyCount, 0) AS [Property Collection Count]
FROM FarmGenie.dbo.PropertyCollectionDetail pcd
WHERE pcd.AspNetUserId = '23d254fe-792f-44b2-b40f-9b1d7a12189d'
    AND pcd.CreateDate >= '2025-10-01'
    AND pcd.CreateDate < '2025-11-01';
```

**Data Source:**  
- Table: `FarmGenie.dbo.PropertyCollectionDetail`
- Column: `PropertyCount`
- Alternative: Can also extract from `SearchCriteria.TargetNumberOfProperties` JSON

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Property Collection Count
---------------------------|-------------------------
16819                      | 150
16820                      | 250
16825                      | 500
16830                      | 75
16835                      | 600
```

---

## FIELD 7: Messages Sent

**Purpose:**  
The total number of SMS messages sent to homeowners (audience) for this campaign. Does NOT include agent notification messages.

**Use Case:**  
- Primary metric for campaign reach
- Denominator for success rate, opt-out rate, and CTR calculations
- Directly correlates to SMS costs
- Critical for ROI analysis (leads per message sent)

**Approach:**  
```sql
WITH audience_sms AS (
    SELECT 
        TRY_CONVERT(bigint,
            CASE WHEN CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) > 0 
            THEN SUBSTRING(
                CAST(nq.CustomData AS nvarchar(max)), 
                CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) + 34,
                CASE 
                    WHEN PATINDEX('%[^0-9]%', SUBSTRING(CAST(nq.CustomData AS nvarchar(max)), 
                        CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) + 34, 20)) > 0
                    THEN PATINDEX('%[^0-9]%', SUBSTRING(CAST(nq.CustomData AS nvarchar(max)), 
                        CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) + 34, 20)) - 1
                    ELSE 20
                END
            )
            END
        ) AS PropertyCollectionDetailId
    FROM FarmGenie.dbo.NotificationQueue nq
    WHERE nq.CreateDate >= '2025-10-01'
        AND nq.CreateDate < '2025-11-01'
        AND nq.NotificationChannelId = 2  -- SMS
        AND nq.UserNotificationId IS NULL  -- Audience SMS only
        AND nq.CustomData LIKE '%TagLeadPropertyCollectionDetailId%'
)
SELECT 
    PropertyCollectionDetailId,
    COUNT(*) AS [Messages Sent]
FROM audience_sms
GROUP BY PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.NotificationQueue`
- Column: `CustomData` (JSON parsing to extract PropertyCollectionDetailId)
- Filter: `UserNotificationId IS NULL` (audience SMS, not agent notifications)
- Filter: `NotificationChannelId = 2` (SMS only)

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Messages Sent
---------------------------|-------------
16819                      | 148
16820                      | 245
16825                      | 0
16830                      | 73
16835                      | 592
```

---

## FIELD 8: Success Rate %

**Purpose:**  
The percentage of SMS messages that were successfully delivered to recipients (not failed, blocked, or undeliverable).

**Use Case:**  
- Key quality metric for campaign effectiveness
- Low success rates indicate data quality issues (bad phone numbers)
- Affects actual campaign reach (only delivered messages can generate leads)
- Used to optimize contact lists and reduce wasted costs

**Approach:**  
```sql
WITH audience_sms AS (
    -- Same CTE as Field 7
    ...
)
SELECT 
    asms.PropertyCollectionDetailId,
    COUNT(*) AS TotalMessages,
    SUM(CASE WHEN tm.Status IN ('delivered','sent') THEN 1 ELSE 0 END) AS DeliveredMessages,
    CAST(100.0 * SUM(CASE WHEN tm.Status IN ('delivered','sent') THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS DECIMAL(10,2)) AS [Success Rate %]
FROM audience_sms asms
LEFT JOIN FarmGenie.dbo.TwilioMessage tm 
    ON tm.Sid = asms.MessageSid
GROUP BY asms.PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.TwilioMessage`
- Column: `Status`
- Join: `NotificationQueue.ProviderResponseKey = TwilioMessage.Sid`
- Formula: (Delivered / Total) * 100
- Delivered statuses: 'delivered', 'sent'

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Messages Sent | Success Rate %
---------------------------|---------------|---------------
16819                      | 148           | 95.95
16820                      | 245           | 97.14
16825                      | 0             | 0.00
16830                      | 73            | 95.89
16835                      | 592           | 97.97
```

---

## FIELD 9: Opt Outs

**Purpose:**  
The number of recipients who opted out (replied "STOP") from receiving SMS messages.

**Use Case:**  
- Track audience fatigue and message quality
- Compliance metric (must honor opt-outs)
- High opt-out rates indicate poor targeting or message quality
- Used to clean contact lists

**Approach:**  
```sql
WITH audience_sms AS (
    -- Same CTE as Field 7
    ...
)
SELECT 
    asms.PropertyCollectionDetailId,
    COUNT(DISTINCT too.Phone) AS [Opt Outs]
FROM audience_sms asms
INNER JOIN FarmGenie.dbo.NotificationQueue nq 
    ON nq.NotificationQueueId = asms.NotificationQueueId
LEFT JOIN FarmGenie.dbo.TwilioOptOut too 
    ON too.Phone = nq.TargetKey
    AND too.EventDate >= '2025-10-01'
    AND too.EventDate < '2025-11-01'
WHERE too.Phone IS NOT NULL
GROUP BY asms.PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.TwilioOptOut`
- Column: `Phone`, `EventDate`
- Join: Match phone numbers from NotificationQueue.TargetKey
- Filter: Opt-outs within the month

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Opt Outs
---------------------------|----------
16819                      | 2
16820                      | 3
16825                      | 0
16830                      | 1
16835                      | 5
```

---

## FIELD 10: Opt Out %

**Purpose:**  
The percentage of message recipients who opted out.

**Use Case:**  
- Benchmark metric for message quality
- Industry standard: <1% is good, >2% is concerning
- Used to identify problematic campaigns
- Helps optimize messaging strategy

**Approach:**  
```sql
-- Calculated field
SELECT 
    PropertyCollectionDetailId,
    OptOuts,
    MessagesSent,
    CAST(100.0 * OptOuts / NULLIF(MessagesSent, 0) AS DECIMAL(10,2)) AS [Opt Out %]
FROM (
    -- Join Fields 7 and 9
    ...
);
```

**Data Source:**  
- Calculated: (Opt Outs / Messages Sent) * 100
- Depends on: Field 7 (Messages Sent) and Field 9 (Opt Outs)

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Opt Outs | Messages Sent | Opt Out %
---------------------------|----------|---------------|----------
16819                      | 2        | 148           | 1.35
16820                      | 3        | 245           | 1.22
16825                      | 0        | 0             | 0.00
16830                      | 1        | 73            | 1.37
16835                      | 5        | 592           | 0.84
```

---

## FIELD 11: Initial Click Count

**Purpose:**  
The number of times recipients clicked the landing page link in the SMS message.

**Use Case:**  
- Measures initial engagement with campaign
- Indicates message relevance and call-to-action effectiveness
- Used to calculate CTR (click-through rate)
- Funnel metric: clicks → CTA submissions → leads

**Approach:**  
```sql
SELECT 
    PropertyCollectionDetailId,
    COUNT(*) AS [Initial Click Count]
FROM FarmGenie.dbo.ClickEvent
WHERE EventDate >= '2025-10-01'
    AND EventDate < '2025-11-01'
    AND PropertyCollectionDetailId IS NOT NULL
GROUP BY PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.ClickEvent`
- Column: `PropertyCollectionDetailId`, `EventDate`
- Filter: Clicks within the month for this campaign

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Initial Click Count
---------------------------|-------------------
16819                      | 12
16820                      | 18
16825                      | 0
16830                      | 6
16835                      | 45
```

---

## FIELD 12: Initial Click % (CTR)

**Purpose:**  
Click-through rate - the percentage of message recipients who clicked the link.

**Use Case:**  
- Key engagement metric
- Industry benchmark: 2-5% is typical for SMS
- Measures message effectiveness and audience interest
- Used to optimize messaging and targeting

**Approach:**  
```sql
-- Calculated field
SELECT 
    PropertyCollectionDetailId,
    ClickCount,
    MessagesSent,
    CAST(100.0 * ClickCount / NULLIF(MessagesSent, 0) AS DECIMAL(10,2)) AS [Initial Click %]
FROM (
    -- Join Fields 7 and 11
    ...
);
```

**Data Source:**  
- Calculated: (Initial Click Count / Messages Sent) * 100
- Depends on: Field 7 (Messages Sent) and Field 11 (Initial Click Count)

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Clicks | Messages Sent | Initial Click %
---------------------------|--------|---------------|----------------
16819                      | 12     | 148           | 8.11
16820                      | 18     | 245           | 7.35
16825                      | 0      | 0             | 0.00
16830                      | 6      | 73            | 8.22
16835                      | 45     | 592           | 7.60
```

---

## FIELD 13: CTA Clicked (Submitted)

**Purpose:**  
The number of times recipients submitted the CTA form (e.g., "Get Property Value", "Request Showing").

**Use Case:**  
- Measures conversion from click to action
- Indicates landing page effectiveness
- Funnel metric: clicks → submissions → verified leads
- Used to calculate conversion rates

**Approach:**  
```sql
SELECT 
    PropertyCollectionDetailId,
    SUM(CASE WHEN Tag LIKE 'CTA%Accept' OR Tag LIKE 'CTA%Submit%' THEN 1 ELSE 0 END) AS [CTA Clicked]
FROM FarmGenie.dbo.CtaEvent
WHERE EventDate >= '2025-10-01'
    AND EventDate < '2025-11-01'
    AND PropertyCollectionDetailId IS NOT NULL
GROUP BY PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.CtaEvent`
- Column: `Tag`, `PropertyCollectionDetailId`
- Filter: Tag LIKE 'CTA%Accept' OR 'CTA%Submit%'

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | CTA Clicked
---------------------------|------------
16819                      | 3
16820                      | 5
16825                      | 0
16830                      | 2
16835                      | 8
```

---

## FIELD 14: CTA Verified

**Purpose:**  
The number of leads who completed the double opt-in verification (clicked verification link in email/SMS).

**Use Case:**  
- Measures high-quality, verified leads
- Indicates serious buyer/seller interest
- Used for lead quality scoring
- Funnel metric: submissions → verified → contacted

**Approach:**  
```sql
SELECT 
    PropertyCollectionDetailId,
    SUM(CASE WHEN Tag = 'CtaContactVerified' THEN 1 ELSE 0 END) AS [CTA Verified]
FROM FarmGenie.dbo.CtaEvent
WHERE EventDate >= '2025-10-01'
    AND EventDate < '2025-11-01'
    AND PropertyCollectionDetailId IS NOT NULL
GROUP BY PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.CtaEvent`
- Column: `Tag`, `PropertyCollectionDetailId`
- Filter: Tag = 'CtaContactVerified'

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | CTA Verified
---------------------------|-------------
16819                      | 2
16820                      | 3
16825                      | 0
16830                      | 1
16835                      | 5
```

---

## FIELD 15: Agent SMS Notify Count

**Purpose:**  
The number of SMS notifications sent TO the agent (lead alerts, new lead notifications).

**Use Case:**  
- Track how many times agent was notified about leads
- Separate from audience SMS (different cost tracking)
- Used to calculate agent notification costs
- Indicates campaign lead generation activity

**Approach:**  
```sql
WITH agent_sms AS (
    SELECT 
        TRY_CONVERT(bigint,
            CASE WHEN CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) > 0 
            THEN SUBSTRING(
                CAST(nq.CustomData AS nvarchar(max)), 
                CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) + 34,
                CASE 
                    WHEN PATINDEX('%[^0-9]%', SUBSTRING(CAST(nq.CustomData AS nvarchar(max)), 
                        CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) + 34, 20)) > 0
                    THEN PATINDEX('%[^0-9]%', SUBSTRING(CAST(nq.CustomData AS nvarchar(max)), 
                        CHARINDEX('"TagLeadPropertyCollectionDetailId":', CAST(nq.CustomData AS nvarchar(max))) + 34, 20)) - 1
                    ELSE 20
                END
            )
            END
        ) AS PropertyCollectionDetailId
    FROM FarmGenie.dbo.NotificationQueue nq
    WHERE nq.CreateDate >= '2025-10-01'
        AND nq.CreateDate < '2025-11-01'
        AND nq.NotificationChannelId = 2
        AND nq.UserNotificationId IS NOT NULL  -- Agent notifications
        AND nq.CustomData LIKE '%TagLeadPropertyCollectionDetailId%'
)
SELECT 
    PropertyCollectionDetailId,
    COUNT(*) AS [Agent SMS Notify Count]
FROM agent_sms
GROUP BY PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.NotificationQueue`
- Column: `CustomData` (JSON parsing)
- Filter: `UserNotificationId IS NOT NULL` (agent notifications, not audience)

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Agent SMS Notify Count
---------------------------|----------------------
16819                      | 3
16820                      | 5
16825                      | 0
16830                      | 2
16835                      | 8
```

---

## FIELD 16: Agent Notify Twilio Cost

**Purpose:**  
The total cost of SMS notifications sent to the agent for this campaign.

**Use Case:**  
- Track agent notification costs separately from audience costs
- Calculate true campaign ROI (total costs including agent alerts)
- Budget planning for notification services
- Identify campaigns with high notification costs

**Approach:**  
```sql
WITH agent_sms AS (
    -- Same CTE as Field 15
    ...
)
SELECT 
    agt.PropertyCollectionDetailId,
    SUM(ISNULL(ABS(tm.Price), 0)) AS [Agent Notify Twilio Cost]
FROM agent_sms agt
LEFT JOIN FarmGenie.dbo.TwilioMessage tm 
    ON tm.Sid = agt.MessageSid
GROUP BY agt.PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.TwilioMessage`
- Column: `Price` (absolute value)
- Join: Agent SMS messages via MessageSid

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Agent Notify Twilio Cost
---------------------------|------------------------
16819                      | $0.24
16820                      | $0.40
16825                      | $0.00
16830                      | $0.16
16835                      | $0.64
```

---

## FIELD 17: Total Twilio Cost

**Purpose:**  
The total cost of all SMS messages sent for this campaign (audience messages only, not including agent notifications).

**Use Case:**  
- Primary cost metric for campaign
- Calculate cost per lead generated
- ROI analysis (revenue vs. SMS costs)
- Budget tracking and forecasting

**Approach:**  
```sql
WITH audience_sms AS (
    -- Same CTE as Field 7
    ...
)
SELECT 
    asms.PropertyCollectionDetailId,
    SUM(ISNULL(ABS(tm.Price), 0)) AS [Total Twilio Cost]
FROM audience_sms asms
LEFT JOIN FarmGenie.dbo.TwilioMessage tm 
    ON tm.Sid = asms.MessageSid
GROUP BY asms.PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.TwilioMessage`
- Column: `Price` (absolute value)
- Join: Audience SMS messages via MessageSid

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Total Twilio Cost
---------------------------|------------------
16819                      | $11.84
16820                      | $19.60
16825                      | $0.00
16830                      | $5.84
16835                      | $47.36
```

---

## FIELD 18: Text Message ID

**Purpose:**  
The NotificationQueueId of the first SMS message sent for this campaign (representative sample).

**Use Case:**  
- Reference ID to look up message details
- Audit trail for campaign messages
- Link to full message history
- Troubleshooting and support

**Approach:**  
```sql
WITH audience_sms AS (
    -- Same CTE as Field 7
    ...
)
SELECT 
    PropertyCollectionDetailId,
    MIN(CAST(NotificationQueueId AS VARCHAR(20))) AS [Text Message ID]
FROM audience_sms
GROUP BY PropertyCollectionDetailId;
```

**Data Source:**  
- Table: `FarmGenie.dbo.NotificationQueue`
- Column: `NotificationQueueId`
- Logic: First message (MIN) for the campaign

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Text Message ID
---------------------------|----------------
16819                      | 1234567
16820                      | 1234890
16825                      | N/A
16830                      | 1235123
16835                      | 1235456
```

---

## FIELD 19: Text Message

**Purpose:**  
The actual SMS message text sent to recipients (sample from first message).

**Use Case:**  
- Review message content for quality
- Analyze which messages generate best engagement
- Compliance review
- Copy optimization

**Approach:**  
```sql
SELECT TOP 1
    nq.NotificationQueueId,
    nq.MessageBody AS [Text Message]
FROM FarmGenie.dbo.NotificationQueue nq
WHERE nq.NotificationQueueId = [Text Message ID from Field 18]
```

**Data Source:**  
- Table: `FarmGenie.dbo.NotificationQueue`
- Column: `MessageBody` (if exists) or extract from `CustomData`
- Note: May need to parse from CustomData JSON if MessageBody is NULL

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | Text Message
---------------------------|--------------------------------------------------
16819                      | Hi! 35 Randwick Ave just sold in your area...
16820                      | New listing alert! 42 Ocean View Dr is now...
16825                      | N/A
16830                      | Just sold! 88 Lakeshore Blvd closed for...
16835                      | Your neighbor just listed! 22 Mountain View...
```

---

## FIELD 20: CTA ID Presented

**Purpose:**  
The CTA template ID(s) presented to recipients in the landing page.

**Use Case:**  
- Track which CTA templates were used
- A/B testing different CTAs
- Analyze CTA effectiveness
- Audit which CTAs were presented

**Approach:**  
```sql
-- Extract from NotificationQueue.CustomData or separate CTA tracking
SELECT 
    PropertyCollectionDetailId,
    'CTA_' + CAST(CtaId AS VARCHAR(20)) AS [CTA ID Presented]
FROM FarmGenie.dbo.NotificationQueue
WHERE PropertyCollectionDetailId = [campaign id]
    AND CtaId IS NOT NULL
```

**Data Source:**  
- Table: `FarmGenie.dbo.NotificationQueue`
- Column: `CtaId` or extract from `CustomData`
- May need JSON parsing

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | CTA ID Presented
---------------------------|------------------
16819                      | CTA_123
16820                      | CTA_124
16825                      | N/A
16830                      | CTA_123
16835                      | CTA_125
```

---

## FIELD 21: CTA URL

**Purpose:**  
The landing page URL where recipients were directed when clicking the SMS link.

**Use Case:**  
- Verify correct landing pages were used
- Track which landing pages convert best
- Audit campaign URLs
- Troubleshoot broken links

**Approach:**  
```sql
-- Extract from NotificationQueue.CustomData
SELECT 
    PropertyCollectionDetailId,
    Url AS [CTA URL]
FROM FarmGenie.dbo.NotificationQueue
WHERE PropertyCollectionDetailId = [campaign id]
    AND Url IS NOT NULL
```

**Data Source:**  
- Table: `FarmGenie.dbo.NotificationQueue`
- Column: `Url` or extract from `CustomData.LandingPageUrl`
- May need JSON parsing

**Expected Results (5 rows):**
```
PropertyCollectionDetailId | CTA URL
---------------------------|--------------------------------------------------------
16819                      | https://app.thegenie.ai/p/abc123
16820                      | https://app.thegenie.ai/p/def456
16825                      | N/A
16830                      | https://app.thegenie.ai/p/ghi789
16835                      | https://app.thegenie.ai/p/jkl012
```

---

## SUMMARY

**Fields I Can Populate from CSV/Database:**
- ✅ Fields 1-6: Campaign details (Date, Type, Property, Type, Status, Count)
- ✅ Field 7-17: SMS metrics (requires NotificationQueue + TwilioMessage queries)
- ✅ Field 18-21: Message details (requires NotificationQueue queries)

**Critical Dependencies:**
- Fields 7-21 ALL depend on NotificationQueue data existing for October 2025
- If NotificationQueue has no data, Fields 7-21 will be zeros/N/A

**Next Step:**
Run `DAVE_HIGGINS_OCTOBER_2025_COMPLETE_REPORT.sql` and send me the results to verify.

