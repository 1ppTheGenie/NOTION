# API & MCP Connections for CTA Strategy

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Document all API and MCP connections needed for CTA strategy |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial API/MCP connections document

---

## 🔌 EXISTING APIS (Already in System)

### Facebook API

**Location:** `Smart.Social/BLL/Facebook/Api/FacebookApi.cs`

**Available Methods:**
- ✅ `GetPages(string token, string userId)` - Get user's pages
- ✅ `GetPage(string token, string pageId)` - Get page details
- ✅ `CreateAdForm(...)` - Create lead forms
- ✅ `CreateAdSet(...)` - Create ad sets
- ❌ `CreatePage(...)` - NOT available (Facebook restriction)

**Usage:**
```csharp
// Get pages for user
var pages = facebookApi.GetPages(accessToken, userId);

// Get specific page
var page = facebookApi.GetPage(accessToken, pageId);
```

**Limitation:** Cannot create pages via API (must be manual)

---

### Twilio SMS API

**Location:** `Smart.Service.Notification/Smart.Notification.Core/`

**Available Methods:**
- ✅ Send SMS
- ✅ Track delivery
- ✅ Handle opt-outs
- ✅ Get message status

**Usage:**
```csharp
// SMS sending handled by NotificationWatch service
// Opt-out handled by SmsCanTextHandler
```

**New Requirements:**
- ⏳ SMS opt-in storage
- ⏳ Nurture sequence triggers

---

### Genie Cloud API

**Location:** `GenieCLOUD/genie-cloud/genie-api/`

**Available Endpoints:**
- ✅ `get-landing-data` - Get landing page data
- ✅ `create-lead` - Create/update lead
- ✅ `get-cta-data` - Get CTA configuration

**New Requirements:**
- ⏳ New CTA endpoint (ID: 10)
- ⏳ SMS opt-in endpoint
- ⏳ Facebook page URL endpoint

---

## 🆕 NEW APIS NEEDED

### myneighborhood.re API

**Purpose:** Generate and serve zip code reports

**Endpoints Needed:**

1. **Generate Report**
   ```
   POST /api/reports/generate
   {
     "zipCode": "92037",
     "format": "html" // or "pdf"
   }
   ```

2. **Get Report**
   ```
   GET /api/reports/{zipCode}
   Returns: HTML report page
   ```

3. **Track Report View**
   ```
   POST /api/reports/{zipCode}/track
   {
     "genieLeadId": 12345,
     "eventType": "ReportViewed"
   }
   ```

**Implementation:**
- Create new API service
- Connect to market data source
- Generate HTML/PDF reports
- Store in database or file system

---

### SMS Nurture API

**Purpose:** Manage SMS nurture sequences

**Endpoints Needed:**

1. **Start Nurture Sequence**
   ```
   POST /api/nurture/start
   {
     "genieLeadId": 12345,
     "phoneNumber": "7145551234",
     "zipCode": "92037",
     "sequenceType": "7DayContentCycle"
   }
   ```

2. **Get Next Message**
   ```
   GET /api/nurture/{genieLeadId}/next
   Returns: Next SMS message in sequence
   ```

3. **Update Sequence**
   ```
   PUT /api/nurture/{genieLeadId}
   {
     "currentWeek": 2,
     "lastSent": "2025-01-15T10:00:00Z"
   }
   ```

**Implementation:**
- Create new service
- Schedule SMS sends
- Track sequence progress
- Handle opt-outs

---

## 🔗 MCP CONNECTIONS

### Facebook MCP (If Available)

**Purpose:** Manage Facebook pages and content

**Operations:**
- Get page insights
- Post to page
- Get page followers
- Track engagement

**Status:** Check if MCP server available for Facebook

---

### SMS/Twilio MCP (If Available)

**Purpose:** Send SMS and track delivery

**Operations:**
- Send SMS
- Get delivery status
- Handle opt-outs
- Get message history

**Status:** Check if MCP server available for Twilio

---

## 📊 DATABASE CONNECTIONS

### FarmGenie Database

**Tables Used:**
- `GenieLead` - Lead records
- `CtaEvent` - CTA tracking
- `NotificationQueue` - SMS queue
- `SmsOptOut` - Opt-out list

**New Tables Needed:**
- `FacebookCommunityPages` - Facebook page mapping
- `SmsOptIn` - SMS consent records
- `NurtureSequence` - Nurture tracking

**Connection:**
- Existing connection string
- Add new tables via migration

---

## 🛠️ IMPLEMENTATION PLAN

### Phase 1: Database Setup

**Tasks:**
1. Create `FacebookCommunityPages` table
2. Create `SmsOptIn` table (if new)
3. Add columns to `GenieLead` (if needed)
4. Create migration scripts

**SQL:**
```sql
-- See CTA_STRATEGY_BLUEPRINT_v1.md for schema
```

---

### Phase 2: API Development

**Tasks:**
1. Create myneighborhood.re API service
2. Create SMS nurture API service
3. Update Genie Cloud API (new CTA endpoint)
4. Add Facebook page URL endpoint

**Files:**
- `myneighborhood-api/` (new service)
- `nurture-api/` (new service)
- `genie-cloud/genie-api/` (updates)

---

### Phase 3: Integration

**Tasks:**
1. Connect CTA component to APIs
2. Connect SMS nurture to Twilio
3. Connect Facebook redirect to page URLs
4. Connect myneighborhood.re to report generation

**Testing:**
- End-to-end flow testing
- API integration testing
- Error handling

---

## ✅ CHECKLIST

### APIs
- [ ] Facebook API (existing - verify access)
- [ ] Twilio API (existing - verify access)
- [ ] Genie Cloud API (existing - add new endpoints)
- [ ] myneighborhood.re API (new - create)
- [ ] SMS Nurture API (new - create)

### MCPs
- [ ] Facebook MCP (check availability)
- [ ] Twilio MCP (check availability)

### Database
- [ ] FacebookCommunityPages table
- [ ] SmsOptIn table
- [ ] Migration scripts
- [ ] Connection strings

### Integration
- [ ] CTA component → APIs
- [ ] SMS nurture → Twilio
- [ ] Facebook redirect → Page URLs
- [ ] myneighborhood.re → Report generation

---

## 📚 RELATED DOCUMENTS

- `CTA_STRATEGY_BLUEPRINT_v1.md` - Complete architecture
- `SOP_CTA_STRATEGY_ONBOARDING_v1.md` - Setup guide
- `CTA_IMPLEMENTATION_RECOMMENDATIONS_v1.md` - Technical details

---

**Next Steps:** Verify existing API access, create new APIs, set up database tables, then integrate.

