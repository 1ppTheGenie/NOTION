# TitleGenie Discovery Compilation
## Complete Research & Findings for Discovery Session

| **Version** | 1.0 |
|-------------|-----|
| **Created** | 2025-01-15 |
| **Last Updated** | 2025-01-15 |
| **Author** | AI Assistant |
| **Purpose** | Comprehensive compilation of all TitleGenie findings from C Drive, D Drive, and codebase for discovery session |

---

## Change Log
- **v1.0 (2025-01-15)**: Initial discovery compilation from all sources

---

## 🎯 EXECUTIVE SUMMARY

This document compiles **ALL** findings related to TitleGenie across:
- **C Drive** - Codebase, source files, documentation
- **D Drive** - Asset library, marketing materials, onboarding docs (updated from G Drive)
- **Codebase** - Invitation system, partnership logic, database structure

**Focus Areas (In Priority Order):**
1. Title rep onboarding process
2. Title partner invitation system
3. Title rep marketing/engagement strategy
4. TitleGenie product features/roadmap
5. Go To Market Plan and promotions

---

## 📚 SOURCES REVIEWED

### D Drive Asset Library (Updated from G Drive)
**Location:** `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\` ⏳ Verify path

| File | Location | Purpose |
|------|----------|---------|
| **Intro to TitleGenie.pptx** | `01_TheGenie_Core/` | Sales presentation |
| **TheGenie Title Operation Onboarding Worksheet Template.xlsx** | `01_TheGenie_Core/` | Title rep onboarding template |
| **Interview Notes - Top Title Reps - 092025.docx** | `01_TheGenie_Core/` | Title rep insights |
| **Guide for Title Reps on approaching agents.docx** | `03_Playbooks_Guides/` | Title rep sales guide |
| **title rep LC webinar email.txt** | `Extracted/DOCs/` | Listing Command webinar email |

### Codebase Files
**Location:** `TheGenie.ai.Database/Genie.Source.Code/`

| File | Purpose |
|------|---------|
| `InvitationManager.cs` | Title rep invitation acceptance logic |
| `TitlePartnerManager.cs` | Title partner relationship management |
| `AutoInvitationManager.cs` | Automated invitation processing |
| `TitlePartnerHandler.cs` | Notification handling for title partners |
| `EnumPartnerType.cs` | Partner type definitions (TitlePartner = 2) |
| `UserPartner` table | Database structure for partnerships |

### SQL Files
| File | Purpose |
|------|---------|
| `TitleGenieVustomers.sql` | Title company customer query/reporting |

---

## 🔍 FINDING #1: TITLE REP ONBOARDING PROCESS

### Current Onboarding Template
**File:** `TheGenie Title Operation Onboarding Worksheet Template.xlsx`

**Location:** `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\01_TheGenie_Core\` ⏳ Verify path

**Purpose:** Title rep onboarding worksheet template

**Status:** ⚠️ **NEEDS REVIEW** - Excel file, cannot read contents directly

---

### Onboarding Flow (From Code Analysis)

**Step 1: Invitation Sent**
- Agent invites title rep via invitation system
- Invitation email sent with unique URL
- Invitation stored in `FarmGenieInvitation` table

**Step 2: Title Rep Accepts Invitation**
- Title rep clicks invitation link
- `AcceptInvitation()` method called
- Creates partnership: `CreatePartnership(aspNetUserId, inviterAspNetUserId)`
- Partnership type: `EnumPartnerType.TitlePartner` (value = 2)

**Step 3: Marketing Profile Created**
- `CreateMarketingProfile()` called
- Creates `UserMarketingProfile` record
- Sets display name, email, phone
- Configures default theme

**Step 4: Notification Sent**
- `SendRepNotification()` called
- Email notification sent to title rep
- Confirms partnership creation

**Step 5: Partnership Active**
- Title rep can now see agent's dashboard
- Partnership tracked in `UserPartner` table
- `PartnerTypeId = 2` (TitlePartner)

---

### Key Code References

**InvitationManager.cs:**
```csharp
private void CreatePartnership(string aspNetUserId, string inviterAspNetUserId)
{
    using (var manager = new Core.BLL.Partner.PartnerManager())
    {
        var response = manager.CreateUserPartner(
            aspNetUserId, 
            inviterAspNetUserId, 
            (int)EnumPartnerType.TitlePartner
        );
    }
}
```

**Database Table:**
```sql
UserPartner
- UserPartnerId (BigInt, PK)
- AspNetUserId (Agent)
- PartnerAspNetUserId (Title Rep)
- PartnerTypeId (2 = TitlePartner)
- CreateDate
```

---

## 🔍 FINDING #2: TITLE PARTNER INVITATION SYSTEM

### Invitation Types

**1. Manual Invitation (Agent-Initiated)**
- Agent sends invitation to title rep
- Email with invitation link
- Title rep accepts → Partnership created

**2. Auto Invitation (System-Initiated)**
- `AutoInvitationManager.ProcessInvitations()`
- Processes unprocessed invitations
- Checks for existing invitations
- Sends invitation email automatically

---

### Invitation Flow

```
Agent Creates Invitation
    ↓
Invitation Record Created (FarmGenieInvitation)
    ↓
Invitation Email Sent
    ↓
Title Rep Clicks Link
    ↓
AcceptInvitation() Called
    ↓
Partnership Created (UserPartner)
    ↓
Marketing Profile Created
    ↓
Notification Sent
    ↓
Partnership Active
```

---

### Invitation URL Format

**From Code:**
```csharp
var invitationUrl = $"https://app.thegenie.ai/invitation/accept/{invitationId}/{hashedInvitation}";
```

**Components:**
- Base URL: `https://app.thegenie.ai/invitation/accept/`
- Invitation ID: Unique identifier
- Hashed Invitation: Security hash

---

### Invitation Status Tracking

**Activity Types:**
- `ActivityType.AgentApiSignUp` - Invitation created
- `ActivityType.InvitationLoaded` - Invitation page loaded
- `ActivityType.InvitationAccepted` - Invitation accepted

**Tracking:**
- All invitation activities tracked in `ActivityTracker` table
- Metadata includes invitation ID
- Used for analytics and reporting

---

### Key Code Files

**InvitationManager.cs:**
- `CreateInvitation()` - Creates invitation record
- `AcceptInvitation()` - Processes acceptance
- `GetPendingInvitationUser()` - Retrieves invitation data
- `MapAcceptInvitationViewModel()` - Maps user data

**AutoInvitationManager.cs:**
- `ProcessInvitations()` - Processes batch invitations
- `SendRepInvitationNotification()` - Sends notification email
- `ProcessInvitation()` - Handles individual invitation

---

## 🔍 FINDING #3: TITLE REP MARKETING/ENGAGEMENT STRATEGY

### Marketing Materials Found

**1. Sales Presentation**
- **File:** `Intro to TitleGenie.pptx`
- **Location:** `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\01_TheGenie_Core\` ⏳ Verify path
- **Purpose:** Sales presentation for TitleGenie
- **Status:** ⚠️ **NEEDS REVIEW** - PowerPoint file

**2. Sales Guide**
- **File:** `Guide for Title Reps on approaching agents.docx`
- **Location:** `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\03_Playbooks_Guides\` ⏳ Verify path
- **Purpose:** Guide for title reps on how to approach agents
- **Status:** ⚠️ **NEEDS REVIEW** - Word document

**3. Interview Notes**
- **File:** `Interview Notes - Top Title Reps - 092025.docx`
- **Location:** `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\01_TheGenie_Core\` ⏳ Verify path
- **Purpose:** Insights from top title reps
- **Status:** ⚠️ **NEEDS REVIEW** - Word document

---

### Email Campaigns Found

**1. Listing Command Webinar Email**
**File:** `title rep LC webinar email.txt`

**Content:**
```
Subject: Listing Command is ready to launch

[Titlerepfname],

You may have wondered what TheGenie has been up to over the past few months - 
wonder no more! We are now introducing our patented automatic listing marketing system.

This system is designed with THREE main things in mind:

1. Help your agents get the listing (and YOU the title order)
2. Help your agents KEEP the listing (and ensure you get a title order)
3. Generate NEW listings (and get more title orders!)

We're going over the program on Tuesday, August 16th at 11AM. 
Use the link below to join us and take your business to the next level!

TheGenie team
```

**Key Messaging:**
- Focus on title orders (benefit to title rep)
- Three value propositions:
  1. Help agents get listings → title orders
  2. Help agents keep listings → title orders
  3. Generate new listings → more title orders
- Webinar format for education

---

### Engagement Strategy (Inferred)

**Value Proposition:**
- Title reps get more title orders
- Agents get more listings
- Win-win partnership

**Messaging Themes:**
- "Help your agents get the listing (and YOU the title order)"
- Focus on mutual benefit
- Results-oriented (title orders = revenue)

**Channels:**
- Email campaigns
- Webinars
- One-on-one invitations
- Partnership relationships

---

## 🔍 FINDING #4: TITLEGENIE PRODUCT FEATURES/ROADMAP

### Current Features (From Code Analysis)

**1. Partnership System**
- Agents can invite title reps
- Title reps can be linked to agents
- Partnership tracked in database
- `GetTitlePartner()` method retrieves partner

**2. Invitation System**
- Manual invitations (agent-initiated)
- Auto invitations (system-initiated)
- Invitation tracking and analytics
- Email notifications

**3. Dashboard Integration**
- Title reps can see agent dashboard
- Partnership relationship displayed
- Shared access to agent data

**4. Notification System**
- Title rep notifications
- Invitation acceptance notifications
- Activity tracking

---

### Database Structure

**UserPartner Table:**
```sql
UserPartner
- UserPartnerId (BigInt, PK, Identity)
- AspNetUserId (Agent User ID)
- PartnerAspNetUserId (Title Rep User ID)
- PartnerTypeId (2 = TitlePartner)
- CreateDate
```

**PartnerType Table:**
```sql
PartnerType
- PartnerTypeId (PK)
- Name (e.g., "TitlePartner")
- Description
- MaxConnections
- CreateDate
```

**FarmGenieInvitation Table:**
```sql
FarmGenieInvitation
- FarmGenieInvitationId (PK)
- InviterAspNetUserId (Agent)
- InviteeAspNetUserId (Title Rep)
- InvitationEmailTo
- InvitationUrl
- ExpirationDate
- AcceptDate
- ProcessDate
```

---

### Code Architecture

**Managers:**
- `TitlePartnerManager` - Partner relationship management
- `InvitationManager` - Invitation processing
- `AutoInvitationManager` - Automated invitations
- `PartnerManager` - General partnership operations

**Handlers:**
- `TitlePartnerHandler` - Notification handling
- `InvitationNotificationManager` - Email notifications

**Models:**
- `EnumPartnerType` - Partner type enum (TitlePartner = 2)
- `UserPartner` - Partnership model
- `AcceptInvitationViewModel` - Invitation acceptance model

---

## 🔍 FINDING #5: GO TO MARKET PLAN AND PROMOTIONS

### Current GTM Tactics Found

**1. Webinar Strategy**
- Listing Command webinar for title reps
- Educational format
- Value-focused messaging
- Call-to-action: Join webinar

**2. Email Campaigns**
- Direct email to title reps
- Personalized messaging (`[Titlerepfname]`)
- Value proposition focused on title orders
- Webinar invitations

**3. Partnership Invitations**
- Agent-initiated invitations
- One-on-one relationship building
- Direct partnership creation

**4. Sales Materials**
- PowerPoint presentation (`Intro to TitleGenie.pptx`)
- Sales guide (`Guide for Title Reps on approaching agents.docx`)
- Onboarding worksheet template

---

### Promotional Messaging Themes

**From Webinar Email:**
1. **"Help your agents get the listing"** → Title orders
2. **"Help your agents KEEP the listing"** → Title orders
3. **"Generate NEW listings"** → More title orders

**Value Proposition:**
- Title reps benefit: More title orders
- Agents benefit: More listings
- Mutual benefit: Win-win partnership

---

### Customer Reporting

**SQL Query Found:** `TitleGenieVustomers.sql`

**Purpose:** Query title company customers and their activity

**Metrics Tracked:**
- Logins YTD
- Detail Views YTD
- Total Exports YTD
- Demo Actions YTD
- Saved Search YTD
- Scorecard View YTD
- Invited Agents YTD
- Lifetime Agent Invites
- Accepted Invitations YTD
- Last Login

**Organizations Tracked:**
- Windermere (PID 34)
- North American Title (PID 47)
- San Diego Title (PID 63)
- 1ParkPlace (PID 1)
- Wish Sotheby (PID 90)
- Fair Texas Title (PID 98)

---

## 📊 KEY INSIGHTS FROM CODE ANALYSIS

### Partnership Model

**Type:** `EnumPartnerType.TitlePartner = 2`

**Relationship:**
- One agent can have multiple title rep partners
- One title rep can partner with multiple agents
- Many-to-many relationship

**Database:**
- `UserPartner` table stores relationships
- `AspNetUserId` = Agent
- `PartnerAspNetUserId` = Title Rep
- `PartnerTypeId = 2` = TitlePartner

---

### Invitation System Architecture

**Manual Invitations:**
- Agent creates invitation
- Email sent to title rep
- Title rep accepts
- Partnership created

**Auto Invitations:**
- System processes unprocessed invitations
- Checks for existing invitations
- Sends invitation email
- Tracks processing

**Invitation Tracking:**
- All activities tracked
- Analytics available
- Reporting capabilities

---

### Integration Points

**Agent Dashboard:**
- `GetTitlePartner()` method
- Displays title partner information
- Shows "No Invitation Rep" if no partner

**Notification System:**
- Title rep notifications
- Invitation acceptance notifications
- Activity tracking

**Marketing Profile:**
- Created on invitation acceptance
- Stores display name, email, phone
- Configures default theme

---

## 📋 DISCOVERY QUESTIONS TO ANSWER

### 1. Title Rep Onboarding Process

**Questions:**
- What is the complete onboarding workflow?
- What steps does a title rep go through after accepting invitation?
- What training materials are provided?
- What is the onboarding worksheet template structure?
- How long does onboarding take?
- What are the success criteria?

**Files to Review:**
- `TheGenie Title Operation Onboarding Worksheet Template.xlsx`
- `Interview Notes - Top Title Reps - 092025.docx`
- `Guide for Title Reps on approaching agents.docx`

---

### 2. Title Partner Invitation System

**Questions:**
- How do agents discover title reps to invite?
- What is the invitation acceptance rate?
- How many title reps can one agent partner with?
- What happens if a title rep declines?
- Can title reps invite themselves?
- What is the invitation expiration policy?

**Code to Review:**
- `InvitationManager.cs` - Complete invitation flow
- `AutoInvitationManager.cs` - Auto invitation logic
- `FarmGenieInvitation` table - Database structure

---

### 3. Title Rep Marketing/Engagement Strategy

**Questions:**
- What is the complete marketing strategy?
- What email sequences exist?
- What webinar topics are most effective?
- How do we nurture title rep relationships?
- What content do title reps need?
- How do we measure engagement?

**Files to Review:**
- `Intro to TitleGenie.pptx` - Sales presentation
- `Guide for Title Reps on approaching agents.docx` - Sales guide
- `title rep LC webinar email.txt` - Email template
- All email templates in asset library

---

### 4. TitleGenie Product Features/Roadmap

**Questions:**
- What features currently exist?
- What features are planned?
- What is the product roadmap?
- What are the key differentiators?
- What integrations exist?
- What reporting capabilities are available?

**Code to Review:**
- All TitleGenie-related code files
- Database schema
- API endpoints
- Integration points

---

### 5. Go To Market Plan and Promotions

**Questions:**
- What is the complete GTM strategy?
- What promotional campaigns exist?
- What is the pricing model?
- What are the success metrics?
- How do we acquire title rep customers?
- What is the retention strategy?

**Files to Review:**
- All marketing materials
- Email templates
- Webinar content
- Sales presentations
- Pricing documents

---

## 📁 FILE INVENTORY

### Documents Found (Need Review)

| File | Location | Status |
|------|----------|--------|
| Intro to TitleGenie.pptx | `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\01_TheGenie_Core\` ⏳ Verify | ⚠️ Needs review |
| TheGenie Title Operation Onboarding Worksheet Template.xlsx | `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\01_TheGenie_Core\` ⏳ Verify | ⚠️ Needs review |
| Interview Notes - Top Title Reps - 092025.docx | `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\01_TheGenie_Core\` ⏳ Verify | ⚠️ Needs review |
| Guide for Title Reps on approaching agents.docx | `D:\My Drive\111PPDrive\Organized_TheGenie_Assets\03_Playbooks_Guides\` ⏳ Verify | ⚠️ Needs review |
| title rep LC webinar email.txt | `D:\My Drive\111PPDrive\Extracted\drive-download-20251213T022742Z-3-009\1ParkPlace\DOCs\` ⏳ Verify | ✅ Reviewed |

### Code Files Reviewed

| File | Purpose | Status |
|------|---------|--------|
| InvitationManager.cs | Invitation processing | ✅ Reviewed |
| TitlePartnerManager.cs | Partner management | ✅ Reviewed |
| AutoInvitationManager.cs | Auto invitations | ✅ Reviewed |
| TitlePartnerHandler.cs | Notification handling | ✅ Reviewed |
| EnumPartnerType.cs | Partner type definitions | ✅ Reviewed |

### SQL Files Found

| File | Purpose | Status |
|------|---------|--------|
| TitleGenieVustomers.sql | Customer reporting query | ✅ Reviewed |

---

## 🎯 NEXT STEPS FOR DISCOVERY SESSION

### Preparation Checklist

**Before Discovery Session:**
1. ✅ Review all code files (DONE)
2. ⏳ Review PowerPoint presentation (`Intro to TitleGenie.pptx`)
3. ⏳ Review onboarding worksheet template (Excel)
4. ⏳ Review interview notes (Word doc)
5. ⏳ Review sales guide (Word doc)
6. ⏳ Review all email templates
7. ⏳ Review webinar content
8. ⏳ Review pricing documents

**Discovery Session Agenda:**
1. **Title Rep Onboarding Process** (Priority 1)
   - Current workflow
   - Pain points
   - Improvement opportunities
   - Success metrics

2. **Title Partner Invitation System** (Priority 2)
   - Current system capabilities
   - Limitations
   - Enhancement needs
   - Integration opportunities

3. **Title Rep Marketing/Engagement Strategy** (Priority 3)
   - Current campaigns
   - Effectiveness
   - Content needs
   - Engagement tactics

4. **TitleGenie Product Features/Roadmap** (Priority 4)
   - Current features
   - Planned features
   - Roadmap priorities
   - Technical requirements

5. **Go To Market Plan and Promotions** (Priority 5)
   - GTM strategy
   - Promotional campaigns
   - Pricing model
   - Success metrics

---

## 📊 KEY METRICS TO DISCUSS

### From SQL Query Analysis

**Title Rep Activity Metrics:**
- Logins YTD
- Detail Views YTD
- Total Exports YTD
- Demo Actions YTD
- Saved Search YTD
- Scorecard View YTD
- Invited Agents YTD
- Lifetime Agent Invites
- Accepted Invitations YTD
- Last Login

**Organizations Tracked:**
- Multiple title companies
- Branch-level tracking
- User-level activity
- Partnership relationships

---

## 🔗 RELATED SYSTEMS

### Integration Points

**Agent Dashboard:**
- Title partner display
- Invitation management
- Partnership tracking

**Notification System:**
- Title rep notifications
- Invitation emails
- Activity tracking

**Marketing System:**
- Email campaigns
- Webinar invitations
- Content delivery

**Reporting System:**
- Customer activity reports
- Partnership analytics
- Invitation tracking

---

## ✅ SUMMARY

**What We Know:**
- ✅ Invitation system architecture
- ✅ Partnership database structure
- ✅ Code implementation details
- ✅ Email campaign examples
- ✅ Customer reporting queries

**What We Need to Discover:**
- ⏳ Complete onboarding workflow
- ⏳ Marketing strategy details
- ⏳ Product roadmap
- ⏳ GTM plan specifics
- ⏳ Promotional campaign details

**Ready for Discovery Session:** ✅ YES

---

**Status:** Complete compilation ready for discovery session review. All code analyzed, all files cataloged, all questions prepared.




