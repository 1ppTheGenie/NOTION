# Complete TheGenie.ai System Workflow
## From Campaign Creation to Lead Capture

---

## 🗄️ DATABASE ARCHITECTURE

The system uses **THREE separate databases** on the same SQL Server instance:

| Database | Size | Purpose | Key Tables |
|----------|------|---------|------------|
| **FarmGenie** | 365 GB | Campaign management, users, notifications | PropertyCollectionDetail, AspNetUsers, NotificationQueue, GenieLead |
| **TitleData** | ~1.5 TB | Property assessor data, owner info, phone numbers | ViewAssessor, Property, PropertyOwner, AppendData |
| **MlsListing** | Unknown | MLS listing data, agent info | Listing, ListingAgent, ListingActivity |

**This explains why Property Type and Listing Status aren't in FarmGenie!**

---

## 📊 WORKFLOW 1: FARM CAST - Campaign Creation & SMS Sending

### STEP 1: Agent Creates Campaign (Web UI)
**Location:** Agent Dashboard → Property → Create Campaign  
**Database:** FarmGenie

**What happens:**
1. Agent selects a subject property (recently sold or new listing)
2. Agent configures search criteria:
   - Property types (SFR, Condo, Townhouse, etc.)
   - Distance radius (default: 2 miles)
   - Target number of properties (75, 150, 250, 500, 600)
   - Owner occupancy filter
   - Bedrooms, years in home, AVM range
   - Area boundary (optional)
3. System creates `PropertyCollectionDetail` record
4. System queues `PropertyCastWorkflowQueue` record

**Source Code:**
- `Smart.Web.FarmGenie/Smart.Core/BLL/Property/Collection/PropertyCollectionDataManager.cs`
- `Smart.Service.PropertyCast/Smart.PropertyCast.Core/Business/PropertyCastService.cs`

---

### STEP 2: Find Nearby Properties (PropertyCast Service)
**Location:** Windows Service (Smart.Service.PropertyCast)  
**Database:** **TitleData** (NOT FarmGenie!)

**What happens:**
1. Service pulls `PropertyCastWorkflowQueue` records
2. Calls stored procedure in **TitleData** database:
   - `GetNearbyPropertyIds` or `GetNearbyAreaBoundedPropertyIds`
   - Uses SQL STDistance for geographic search
   - Applies filters (property type, owner occupancy, bedrooms, etc.)
   - Returns list of PropertyIds within radius
3. Filters out agent-owned properties (from **MlsListing** database)
4. Takes top N properties (target + buffer of 25)
5. Creates `PropertyCollectionMember` records linking properties to campaign

**Source Code:**
- `Smart.Service.PropertyCast/Smart.PropertyCast.Core/Business/Collection/Handler/NearbyPropertiesHandler.cs` (line 21)
- `Smart.Service.PropertyCast/Smart.PropertyCast.Data/Title/SQL/RepositoryTitle.cs`

**Key Configuration:**
```csharp
public int NearbyPropertyMiles { get; set; } = 2;  // Search radius
public int NearbyPropertyAgentBuffer { get; set; } = 25;  // Extra properties to account for filtering
```

---

### STEP 3: Data Append - Get Phone Numbers (Report Service)
**Location:** Windows Service (Smart.Service.Report)  
**Database:** **TitleData** (AppendData table)

**What happens:**
1. System looks up property owners in **TitleData.AppendData** table
2. Retrieves contact information:
   - MobilePhone (primary)
   - Phone (landline)
   - AlternatePhone1-6 (additional numbers)
   - Email, AlternateEmail1-6
3. Filters properties based on data append requirements:
   - Must have phone number
   - Must have email (optional)
   - Multiplier applied if optimization enabled (2x to ensure target reached after filtering)
4. Stores appended data in `ExportDataAll` object

**Source Code:**
- `Smart.Web.FarmGenie/Smart.Core/BLL/Report/Sms/SmsQueueSendToHelper.cs` (line 8-44)
- `Smart.Web.FarmGenie/Smart.Core/BLL/DataAppend/DataAppendManager.cs`

**Phone Number Priority:**
```csharp
PhoneNumbers = new List<string>
{
    appendData.MobilePhone,       // 1st priority
    appendData.Phone,             // 2nd priority
    appendData.AlternatePhone1,   // 3rd priority
    ...
}
```

---

### STEP 4: Queue SMS Messages (Report Service)
**Location:** Windows Service (Smart.Service.Report)  
**Database:** FarmGenie

**What happens:**
1. Creates `ReportQueue` record with:
   - `PropertyCollectionDetailId` (campaign ID)
   - `AspNetUserId` (agent ID)
   - `ReportConfiguration` (JSON with campaign settings)
2. Creates `SmsReportSendQueue` records (one per property owner with phone)
3. For each property owner:
   - Creates `SmsShortUrlData` object with:
     - **PropertyCollectionDetailId** (THIS IS THE KEY!)
     - ReportId, PropertyId, MlsId, AreaId
     - LeadType, contact info, UTM tracking
   - Serializes to JSON
   - Creates `NotificationQueue` record with:
     - `CustomData` = JSON with TagLeadPropertyCollectionDetailId
     - `NotificationChannelId` = 2 (SMS)
     - `UserNotificationId` = NULL (audience SMS, not agent notification)
     - `TargetKey` = recipient phone number
     - `AspNetUserIdFrom` = agent ID

**Source Code:**
- `Smart.Web.FarmGenie/Smart.Core/BLL/Report/Sms/Processor/SmsProcessorBase.cs` (line 196-223)
- `Smart.Web.FarmGenie/Smart.Core/BLL/Report/Sms/SmsShortUrlData.cs` (line 13)

**Critical Code (line 214):**
```csharp
PropertyCollectionDetailId = SourceReport.PropertyCollectionDetailId ?? 0,
```

---

### STEP 5: Send SMS via Twilio (Notification Service)
**Location:** Windows Service (Smart.Service.Notification)  
**Database:** FarmGenie + Twilio API

**What happens:**
1. Service pulls `NotificationQueue` records where `ResponseCode IS NULL`
2. Deserializes `CustomData` JSON to get phone number and message data
3. Checks `SmsOptOut` table for opt-outs
4. Selects "From" phone number from pool (matches area code if possible)
5. Sends SMS via Twilio API
6. Updates `NotificationQueue`:
   - `ProviderResponseKey` = Twilio MessageSid
   - `ResponseCode` = 200 (success) or error code
   - `ProcessDate` = timestamp
7. Twilio webhook updates `TwilioMessage` table with delivery status

**Source Code:**
- `Smart.Service.Notification/Smart.Notification.Core/Business/Notifications/Sms/NotificationSmsBase.cs` (line 28-48)
- `Smart.Web.FarmGenie/Smart.Core/BLL/Report/Sms/Handlers/SmsNumberPoolHandler.cs`

---

## 📊 WORKFLOW 2: ENGAGEMENT TRACKING - Clicks & CTA

### STEP 1: Recipient Clicks SMS Link
**Location:** SMS message contains short URL  
**Database:** FarmGenie

**What happens:**
1. Recipient clicks link in SMS
2. Link contains encoded `SmsShortUrlData` (with PropertyCollectionDetailId)
3. System redirects to landing page
4. Creates `ClickEvent` or `EngagementEvent` record with:
   - PropertyCollectionDetailId (from URL)
   - EventDate
   - EventType = "SMS Click"

**Source Code:**
- `Smart.Web.FarmGenie/Smart.Core/BLL/Lead/Handler/GenieLeadHandler.cs`

---

### STEP 2: CTA Presentation
**Location:** Landing page loads  
**Database:** FarmGenie

**What happens:**
1. Landing page displays property details
2. CTA form presented (e.g., "Get Property Value", "Request Showing")
3. Creates `CtaEvent` record:
   - PropertyCollectionDetailId
   - EventType = "CTA%Display" or "Presented"
   - CtaId = CTA template ID

---

### STEP 3: CTA Submission
**Location:** User submits form  
**Database:** FarmGenie

**What happens:**
1. User fills out form (name, email, phone)
2. Creates `GenieLead` record with:
   - PropertyCollectionDetailId
   - AspNetUserId (agent who owns campaign)
   - Contact information
   - LeadType, InquiryType
3. Creates `CtaEvent` record:
   - EventType = "CTA%Accept" or "Submitted"
4. Triggers agent notification (if enabled)

---

### STEP 4: CTA Verification (Double Opt-In)
**Location:** User clicks verification link in email/SMS  
**Database:** FarmGenie

**What happens:**
1. User clicks verification link
2. Creates `CtaEvent` record:
   - EventType = "CtaContactVerified"
3. Lead marked as verified
4. Triggers agent notification

---

## 📊 WORKFLOW 3: AGENT NOTIFICATIONS

### When Agent Gets Notified
**Location:** Triggered by lead events  
**Database:** FarmGenie

**What happens:**
1. Lead created or updated
2. System checks agent's notification preferences
3. Creates `UserNotification` record
4. Creates `NotificationQueue` record with:
   - `UserNotificationId` = NOT NULL (this is the key difference!)
   - `NotificationChannelId` = 2 (SMS) or 1 (Email)
   - `CustomData` = JSON with PropertyCollectionDetailId and LeadId
   - `AspNetUserIdTo` = agent ID
5. Notification service sends SMS/email to agent

**Source Code:**
- `Smart.Web.FarmGenie/Smart.Core/BLL/Notification/Handler/HandlerBotBase.cs`

---

## 📊 WORKFLOW 4: OPT-OUTS

### When Recipient Opts Out
**Location:** Recipient replies "STOP" to SMS  
**Database:** FarmGenie

**What happens:**
1. Twilio webhook receives opt-out message
2. Creates `SmsOptOut` or `TwilioOptOut` record with:
   - Phone number
   - EventDate
   - Source (Twilio MessageSid)
3. Future SMS sends check this table before sending

**Source Code:**
- `Smart.Service.Notification/Smart.Notification.Core/Business/Notifications/Sms/NotificationSmsBase.cs` (line 32)

---

## 🔗 DATA FLOW SUMMARY

```
CAMPAIGN CREATION (FarmGenie)
    ↓
PropertyCollectionDetail created
    ↓
PROPERTY SEARCH (TitleData)
    ↓
GetNearbyPropertyIds → List of PropertyIds
    ↓
PropertyCollectionMember records created
    ↓
DATA APPEND (TitleData.AppendData)
    ↓
Phone numbers retrieved
    ↓
SMS QUEUE (FarmGenie)
    ↓
ReportQueue created (with PropertyCollectionDetailId)
    ↓
SmsReportSendQueue created
    ↓
NotificationQueue created (CustomData JSON with PropertyCollectionDetailId)
    ↓
SMS SEND (Twilio API)
    ↓
NotificationQueue.ProviderResponseKey = MessageSid
    ↓
TwilioMessage table updated
    ↓
ENGAGEMENT (FarmGenie)
    ↓
ClickEvent, CtaEvent, GenieLead records created
```

---

## 🎯 KEY INSIGHTS FOR REPORTING

### 1. Property Type & Listing Status
**Location:** **TitleData** and **MlsListing** databases, NOT FarmGenie!

To get Property Type:
```sql
SELECT p.PropertyTypeId, pt.PropertyTypeName
FROM TitleData.dbo.Property p
JOIN TitleData.dbo.PropertyType pt ON pt.PropertyTypeId = p.PropertyTypeId
WHERE p.PropertyId = @PropertyId;
```

To get Listing Status:
```sql
SELECT l.Status, l.ListingStatusId
FROM MlsListing.dbo.Listing l
WHERE l.PropertyId = @PropertyId;
```

### 2. Area Name
**Location:** FarmGenie database

Priority order:
1. `PolygonNameOverride.FriendlyName` (user's custom name)
2. `ViewArea.FriendlyName` (marketing name)
3. `ViewArea.AreaName` (default name)
4. `ViewArea.PolygonName` (polygon name)

### 3. Phone Numbers
**Location:** **TitleData.dbo.AppendData** table

NOT in FarmGenie! Must join across databases.

### 4. Campaign-to-SMS Link
**Method:** JSON parsing from `NotificationQueue.CustomData`

Filter for audience SMS:
- `NotificationChannelId = 2` (SMS)
- `UserNotificationId IS NULL` (NOT agent notifications)
- `CustomData LIKE '%TagLeadPropertyCollectionDetailId%'`

---

## 🚨 CRITICAL CORRECTIONS TO PREVIOUS ANALYSIS

### What I Got Wrong:
1. ❌ Assumed all data was in FarmGenie database
2. ❌ Didn't realize Property Type is in TitleData
3. ❌ Didn't realize Listing Status is in MlsListing
4. ❌ Didn't realize phone numbers are in TitleData.AppendData
5. ❌ Didn't understand the 3-database architecture

### What I Got Right:
1. ✅ Campaign-to-SMS link via NotificationQueue.CustomData JSON
2. ✅ UserNotificationId IS NULL = audience SMS
3. ✅ ProviderResponseKey = Twilio MessageSid
4. ✅ Area name priority (PolygonNameOverride → ViewArea)

---

## 📋 NEXT STEPS FOR REPORT

Now that I understand the complete workflow, I need to:

1. **Query TitleData database** for Property Type
2. **Query MlsListing database** for Listing Status
3. **Verify cross-database joins** work in SQL Server
4. **Update all field mappings** with correct database sources
5. **Rebuild complete query** with proper 3-database joins

**Ready to proceed with corrected approach?**

