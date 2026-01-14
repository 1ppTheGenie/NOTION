# TitleGenie Title Rep Onboarding SOP

## Executive Summary

| Item | Details |
|------|---------|
| **Purpose** | Step-by-step process for onboarding new title reps to TitleGenie |
| **Current State** | Manual process — 1ParkPlace team enters title reps |
| **Key Outputs** | Active title rep account, certified user, ready to invite agents |
| **Remaining Work** | Self-service UI (Phase 2), county limits, trial period automation |
| **Last Validated** | December 22, 2025 |

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Phase 1: Lead Acquisition](#phase-1-lead-acquisition)
4. [Phase 2: Account Setup](#phase-2-account-setup)
5. [Phase 3: Training & Certification](#phase-3-training--certification)
6. [Phase 4: Activation](#phase-4-activation)
7. [Ongoing Support](#ongoing-support)
8. [Tracking & Metrics](#tracking--metrics)

---

## Overview

### Current Process (Manual — MVP)

```
┌─────────────────────────────────────────────────────────────────┐
│              TITLE REP ONBOARDING FLOW (MVP)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   STEP 1: LEAD ACQUISITION                                       │
│   → Identify title rep candidate                                 │
│   → Outreach (email, call, referral)                             │
│   → Interest confirmed                                           │
│                                                                  │
│   STEP 2: ACCOUNT SETUP                                          │
│   → 1ParkPlace team creates account                              │
│   → Set status: "Title Rep Invited"                              │
│   → Send login credentials                                       │
│                                                                  │
│   STEP 3: TRAINING & CERTIFICATION                               │
│   → Schedule training session                                    │
│   → Complete certification modules                               │
│   → Pass assessment                                              │
│                                                                  │
│   STEP 4: ACTIVATION                                             │
│   → Billing setup ($250/mo or $2,500/yr)                         │
│   → Activate Listing Command allowance (4/mo)                    │
│   → Set agent invitation limit (50)                              │
│   → Title rep begins inviting agents                             │
│                                                                  │
│   ONGOING: SUPPORT                                               │
│   → Office hours                                                 │
│   → Training refreshers                                          │
│   → Success tracking                                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Future Process (Automated — Phase 2)

- Self-service signup on TitleGenie website
- County-based limits (max title reps per county via FIPS code)
- Trial period (7 days or TBD)
- Automated training assignment
- Self-paced certification
- Automated billing via WHMCS (Product ID 83)

---

## Prerequisites

### For 1ParkPlace Team

| Requirement | Access Needed |
|-------------|---------------|
| Admin dashboard access | TheGenie admin portal |
| Billing system access | WHMCS or payment processor |
| Email system access | For sending credentials |
| Training materials | Certification recordings (4 sessions) |
| Tracking spreadsheet | Title rep onboarding tracker |

### For Title Rep

| Requirement | Details |
|-------------|---------|
| Email address | Work email preferred |
| Payment method | Credit card or invoice (enterprise) |
| Company information | Title company, role, location |
| Territory | Counties they serve (for future limits) |

---

## Phase 1: Lead Acquisition

### Step 1.1: Identify Candidate

**Sources:**
| Source | Priority | Notes |
|--------|----------|-------|
| Intercom database | HIGH | 1,000-2,000 past users |
| First American defectors | HIGH | Already know the product |
| Word of mouth referrals | HIGH | Warm leads |
| TitleGenie website inbound | MEDIUM | Organic interest |
| Cold outreach | LOW | Last resort |

### Step 1.2: Initial Outreach

**Email Template — Re-Engagement (Intercom List):**

```
Subject: Something NEW at TheGenie — Paisley AI is Here

Hi [FirstName],

We noticed you were a valued member of TheGenie community. 
A lot has changed since then, and we wanted to personally invite 
you back to see what's new.

Introducing Paisley AI — your knowledge generation engine that 
helps you open doors with top agents by delivering insights 
they can't get anywhere else.

What's included in TitleGenie ($250/mo):
✓ Farm Analyzer & Agent Scorecard (patented analytics)
✓ Paisley AI for content generation
✓ 4 Listing Commands/month ($400 value) to gift to agents
✓ Invite up to 50 agents
✓ Ongoing training & office hours

Would you like a quick 15-minute walk-through?

→ Book a Demo: [LINK]
→ Try It Free: [TRIAL LINK]

Best,
[Sender Name]
TheGenie.ai Team

P.S. Knowledge is not regulated — and that's exactly what you'll 
be offering your agents.
```

### Step 1.3: Qualification Checklist

| Criteria | Required? | Notes |
|----------|-----------|-------|
| Active title rep | YES | Currently working in title |
| Has agent relationships | YES | Agents to invite |
| Budget authority | YES | Can approve $250/mo |
| Territory defined | PREFERRED | For county limits (future) |
| Tech comfort level | PREFERRED | Can use web dashboard |

---

## Phase 2: Account Setup

### Step 2.1: Collect Information

**Required Fields:**
- First Name
- Last Name
- Email (will become login)
- Phone
- Title Company Name
- Role/Title
- Office Location (City, State, Zip)
- Counties Served (for future limits)

### Step 2.2: Create Account (Manual Process)

**Admin Steps:**

1. Log into TheGenie admin portal
2. Navigate to User Management
3. Create new user with collected information
4. Set user type: **Title Rep**
5. Set status: **Title Rep Invited**
6. Set partnership flag: **Advanced Tools Access = TRUE**
7. Save record

**Database Fields (for reference):**
```sql
-- Key fields to set
UserTypeId = [Title Rep ID]
PartnerTypeId = 2 (TitlePartner)
AdvancedToolsAccess = 1
Status = 'Invited'
```

### Step 2.3: Send Welcome Email

**Email Template — Account Created:**

```
Subject: Welcome to TitleGenie — Your Account is Ready

Hi [FirstName],

Your TitleGenie account has been created! 

Here's how to get started:

LOGIN DETAILS:
─────────────────
URL: https://app.thegenie.ai
Email: [their email]
Password: [temporary password or reset link]

NEXT STEPS:
1. Log in and reset your password
2. Schedule your training session: [CALENDAR LINK]
3. Complete certification (4 sessions, ~2 hours total)
4. Start inviting agents!

YOUR PACKAGE INCLUDES:
✓ TitleGenie Dashboard (Farm Analyzer, Agent Scorecard)
✓ Paisley AI (knowledge generation for agents)
✓ 4 Listing Commands/month to gift to agents
✓ Up to 50 agent invitations
✓ Ongoing office hours & support

Questions? Reply to this email or join our next office hours session.

Welcome aboard!

[Sender Name]
TheGenie.ai Team
```

### Step 2.4: Update Tracking

**Spreadsheet Columns:**
| Column | Value |
|--------|-------|
| Title Rep Name | [Name] |
| Email | [Email] |
| Company | [Title Company] |
| Territory | [Counties] |
| Status | Account Created |
| Account Created Date | [Date] |
| Training Scheduled | [Date or Pending] |
| Certified | No |
| Billing Status | Pending |
| Agents Invited | 0 |
| Notes | [Any notes] |

---

## Phase 3: Training & Certification

### Step 3.1: Schedule Training

**Training Options:**
| Option | Format | Duration |
|--------|--------|----------|
| Live Group Training | Webinar | 1 hour |
| 1:1 Training | Call/Zoom | 30 min |
| Self-Paced | Recorded | 4 sessions (~2 hrs) |

**Certification Recordings Available:**
- Session #1: Intro
- Session #2: Dashboard & Tools
- Session #3: Agent Invitation System
- Session #4: Advanced Strategies

### Step 3.2: Training Agenda (Live)

| Time | Topic |
|------|-------|
| 0-10 min | Welcome, overview, account verification |
| 10-25 min | Dashboard tour: Farm Analyzer, Agent Scorecard |
| 25-35 min | Paisley AI: Content generation demo |
| 35-45 min | Agent invitation system: How to invite, gamification |
| 45-55 min | Listing Command gifts: How to use your 4/month |
| 55-60 min | Q&A, next steps |

### Step 3.3: Certification Checklist

| Task | Required | Verified |
|------|----------|----------|
| Logged into dashboard | YES | ☐ |
| Viewed Farm Analyzer | YES | ☐ |
| Viewed Agent Scorecard | YES | ☐ |
| Used Paisley AI (1 conversation) | YES | ☐ |
| Invited first agent | YES | ☐ |
| Understands Listing Command gifts | YES | ☐ |
| Knows support channels | YES | ☐ |

### Step 3.4: Mark Certified

- Update tracking spreadsheet: Certified = YES
- Update system status: Title Rep Certified
- Send certification confirmation email

---

## Phase 4: Activation

### Step 4.1: Billing Setup

**Pricing Options:**
| Plan | Price | Savings |
|------|-------|---------|
| Monthly | $250/month | - |
| Annual | $2,500/year | 2 months free |

**Billing Methods (MVP):**
- Manual invoice
- Credit card (WHMCS Product ID 83)

### Step 4.2: Activate Subscription

1. Create invoice or charge card
2. Activate subscription in billing system
3. Update tracking: Billing Status = Active
4. Confirm payment received

### Step 4.3: Set Limits

| Setting | Value |
|---------|-------|
| Agent Invitation Limit | 50 |
| Listing Commands/Month | 4 |
| Subscription Tier | TitleGenie Standard |

### Step 4.4: Send Activation Confirmation

**Email Template — You're Live:**

```
Subject: You're Live on TitleGenie! 🎉

Hi [FirstName],

Congratulations — your TitleGenie subscription is now active!

YOUR MONTHLY PACKAGE:
─────────────────────
✓ Dashboard access: ACTIVE
✓ Agent invitations remaining: 50
✓ Listing Commands this month: 4 ($400 value)
✓ Paisley AI: UNLIMITED

QUICK START CHECKLIST:
☐ Invite your first 5 agents this week
☐ Use Paisley to generate content for a listing
☐ Gift a Listing Command to a top agent
☐ Join next week's office hours

SUPPORT:
─────────
Office Hours: [DAY/TIME] — [LINK]
Email: support@thegenie.ai
Help Docs: [LINK]

Let's grow your title business together!

[Sender Name]
TheGenie.ai Team
```

---

## Ongoing Support

### Office Hours

| Day | Time | Format | Link |
|-----|------|--------|------|
| TBD | TBD | Zoom | [LINK] |

**Office Hours Agenda:**
- Welcome new title reps
- Feature updates
- Q&A
- Success story sharing
- Tips & best practices

### Success Check-Ins

| Timing | Action |
|--------|--------|
| Week 1 | Check first login, first agent invited |
| Week 2 | Check Listing Commands used, engagement |
| Month 1 | Review: agents invited, Paisley usage, satisfaction |
| Month 3 | Retention check, upsell opportunities |

### Escalation Path

| Issue | Contact |
|-------|---------|
| Technical bugs | support@thegenie.ai |
| Billing questions | billing@thegenie.ai |
| Training needs | schedule office hours |
| Account issues | admin@thegenie.ai |

---

## Tracking & Metrics

### MVP Tracking (Spreadsheet)

**Columns:**
| Field | Description |
|-------|-------------|
| ID | Unique ID |
| Name | Title rep name |
| Email | Login email |
| Company | Title company |
| Territory | Counties served |
| Lead Source | Intercom, referral, inbound, etc. |
| Status | Lead → Account Created → Training → Certified → Active |
| Account Created | Date |
| Training Date | Date |
| Certified | Yes/No |
| Activated | Date |
| Billing Status | Pending/Active/Cancelled |
| Payment Method | Card/Invoice |
| Plan | Monthly/Annual |
| Agents Invited | Count |
| Listing Commands Used | Count |
| Last Login | Date |
| Notes | Free text |

### KPIs to Track (No Targets Yet)

| KPI | How to Measure |
|-----|----------------|
| Leads Generated | Count per source |
| Conversion Rate | Leads → Active |
| Time to Activate | Days from lead to active |
| Training Completion | % who complete certification |
| Agent Invitations | Avg per title rep |
| Listing Commands Used | % of 4/month used |
| Retention | % renewing month 2, 6, 12 |
| Revenue (MRR) | Sum of active subscriptions |

---

## Appendix: Templates

### A. Lead Tracking Spreadsheet Headers

```
ID | Name | Email | Phone | Company | Territory | Lead Source | Status | Account Created | Training Date | Certified | Activated | Billing Status | Plan | Agents Invited | LC Used | Last Login | Notes
```

### B. Quick Reference Checklist

**New Title Rep Onboarding Checklist:**

```
☐ Lead qualified
☐ Account created in system
☐ Welcome email sent
☐ Training scheduled
☐ Training completed
☐ Certification verified
☐ Billing setup complete
☐ Payment received
☐ Activation email sent
☐ Week 1 check-in scheduled
☐ Added to office hours invite
☐ Tracking spreadsheet updated
```

### C. System Access Quick Reference

| System | URL | Purpose |
|--------|-----|---------|
| TheGenie Dashboard | https://app.thegenie.ai | Main platform |
| Admin Portal | [INTERNAL] | User management |
| WHMCS | [INTERNAL] | Billing |
| Intercom | [INTERNAL] | Past user data |
| Tracking Sheet | [INTERNAL] | Onboarding tracker |

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 22, 2025 | AI Assistant | Initial SOP creation |

---

**Status:** Ready for Review and Implementation

