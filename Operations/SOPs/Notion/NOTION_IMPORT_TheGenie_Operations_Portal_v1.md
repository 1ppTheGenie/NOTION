# 🏠 TheGenie.ai Operations Portal

> **The 1parkplace Operations Brain Center**
> 
> Owner: Steve Hundley | Last Updated: December 11, 2025

---

## 🔗 Quick Links

| Resource | Link |
|----------|------|
| TheGenie App | https://app.thegenie.ai |
| Help Page | https://app.thegenie.ai/help |
| AWS Console | https://console.aws.amazon.com |

---

# 📂 OPERATIONS

## 📊 Reports

### Competition Command Reports

| Report | Version | Description | Script |
|--------|---------|-------------|--------|
| **CC Monthly Ownership** | v5_iter2 ✅ | Lifetime ownership with campaigns, SMS, clicks, CTR, leads | `build_cc_ownership_LIVE_v2.py` |
| **CC Monthly Cost** | v5 ✅ | Monthly costs by user/area with invoice allocation | `build_cc_monthly_report_v3.py` |

---

### Listing Command Reports

| Report | Version | Description | Script |
|--------|---------|-------------|--------|
| **LC Monthly Performance** | v10 ✅ | Orders, channels, revenue, profit, performance metrics | `build_lc_performance_v10.py` |

---

### Twilio Reports

| Report | Version | Description | Script |
|--------|---------|-------------|--------|
| **Invoice Reconciliation** | COMPLETE ✅ | November 2025 cost breakdown by service | `final_recon_nov_v1.py` |
| **Phone Inventory** | v1 ✅ | All 122 numbers with categories and costs | `analyze_phone_numbers_v1.py` |
| **Phone Usage Assessment** | v1 ✅ | Orphan detection, 24 release candidates ($355/yr savings) | `assess_phone_usage_v1.py` |
| **Delivery Farm Usage** | v2 ✅ | 73 numbers, outbound/inbound by state | `delivery_farm_usage_2025_v1.py` |
| **Engagement Analysis** | v1 ✅ | 6,697 missed opportunities, 5 bots identified | `engagement_analysis_v1.py` |

---

### Engagement Reports (NEW)

| Report | Records | Description |
|--------|---------|-------------|
| **Missed Opportunities by Agent** | By agent | Unconverted engagement |
| **Warm Leads for Follow-up** | 5,716 | Consumer phones ready for outreach |
| **Potential Bots** | 5 | High-frequency responders to block |
| **Conversion by Agent** | By agent | Engagement-to-lead rates |

---

## 📋 SOPs (Standard Operating Procedures)

### How to Run Reports

| SOP | Purpose |
|-----|---------|
| **SOP_CC_Ownership_Report_v5.md** | Generate CC ownership lifetime report |
| **SOP_CC_Monthly_Cost_Report_v2.md** | Generate monthly CC cost report |
| **SOP_LC_MonthlyPerformance_v1.md** | Generate LC performance report |
| **SOP_Twilio_Invoice_Reconciliation_v1.md** | Reconcile Twilio monthly invoice |
| **SOP_Twilio_Phone_Inventory_v1.md** | Audit phone numbers and costs |
| **SOP_Twilio_DeliveryFarm_Usage_v1.md** | Analyze delivery farm activity |

---

## 📐 Technical Specifications

| Spec | Version | Purpose |
|------|---------|---------|
| **SPEC_OwnedAreas_Report_v2.md** | v2 ✅ | CC ownership report field definitions |
| **SPEC_CompCommand_MonthlyCostReport_v3.md** | v3 ✅ | CC monthly cost calculations |
| **SPEC_LC_MonthlyPerformance_v2.md** | v2 ✅ | LC performance 21-column spec |
| **SPEC_Twilio_PhoneNumber_Reports_v1.md** | v1 ✅ | Twilio phone report specs |

---

# 🚀 GROWTH (Sales & Marketing)

## 📢 Go-to-Market

| Document | Status | Description |
|----------|--------|-------------|
| *Coming soon* | 🔜 | Presentations, website design, creative assets |

---

# 🛠️ SUPPORT (Customer Experience)

## 📞 Support Resources

| Document | Status | Description |
|----------|--------|-------------|
| *Coming soon* | 🔜 | Customer support guides, FAQs |

---

# 💻 SYSTEM DEVELOPMENT

## 🏗️ Architecture

### Source Code Organization

```
TheGenie.ai Platform (nTier Architecture)
│
├── 📦 Database Layer
│   ├── FarmGenie (Main DB)
│   ├── MlsListing (Property data)
│   └── Stored Procedures
│
├── ⚙️ Logic Layer
│   ├── Windows Services
│   │   ├── Smart.Service.ListingCommand
│   │   ├── Smart.Service.PropertyCast
│   │   └── Smart.Service.PropertyCasterWorkflow
│   └── APIs
│       ├── Smart.Api.Oculus
│       └── Smart.Api.DataAppend
│
├── 🖥️ UI Layer
│   ├── Smart.Dashboard (Agent Portal)
│   └── Admin Portal
│
├── ☁️ GenieCLOUD (AWS)
│   ├── genie-api (Lambda)
│   ├── genie-processor (Lambda)
│   ├── genie-renderer (Lambda)
│   └── genie-components (React)
│
├── 📰 MarketingHub (WordPress)
│
└── 🌐 TheGenie.ai Website
```

---

### Key Source Files

| Service | Key Files | Purpose |
|---------|-----------|---------|
| Listing Command | `ListingCommandQueueHandler.cs` | Order queuing: 1 order = 1 MLS + 1-3 statuses |
| Listing Command | `ListingCommandV2Handler.cs` | Action execution: SMS, FB, Direct Mail |
| Property Cast | `PropertyCastHandler.cs` | Campaign trigger execution |

---

## 🔌 Database Reference

### Connection Details

| Setting | Value |
|---------|-------|
| Server | 192.168.29.45 |
| Port | 1433 |
| Database | FarmGenie |
| User | cursor |

### Key Tables

| Table | Purpose |
|-------|---------|
| `PropertyCast` | Campaign triggers |
| `PropertyCollectionDetail` | Campaign definitions |
| `SmsReportSendQueue` | SMS batches |
| `GenieLead` | Lead records |
| `GenieLeadTag` | CTA/Opt-out tracking |
| `ListingCommandQueue` | LC orders |
| `UserOwnedArea` | Area ownership |

---

## 🎯 Feature Requests

| ID | Feature | Status | Documents |
|----|---------|--------|-----------|
| FR-001 | Area Ownership & Waitlist System | 📝 Design Complete | [Design Brief] [Dev Spec v2] [Discovery] |

### FR-001: Area Ownership & Waitlist

**Problem:** Hard deletes lose history, no waitlist for exclusive areas

**Solution:** Soft deletes with history tracking, waitlist queue with notifications

**New Tables:**
- `AreaOwnership` - Replaces UserOwnedArea
- `AreaOwnershipHistory` - Audit trail
- `AreaCampaignHistory` - Campaign tracking
- `AreaWaitlist` - Queue management

---

# 📱 APPLICATIONS

## Products/Services

| App | PropertyCastTypeId | Description |
|-----|-------------------|-------------|
| **Competition Command** | 1 | Area-based SMS marketing |
| **Listing Command** | 2 | Listing-based campaigns |
| **Neighborhood Command** | 3 | Neighborhood marketing |
| **TitleGenie** | - | Title/escrow tools |
| **GeoSocial Audience Builder** | - | Facebook audience tools |
| **AskPaisley** | - | AI assistant |

---

# 🚨 CRITICAL LEARNINGS

## ⚠️ Never Forget These!

### 1. Click Calculation
```
❌ WRONG: SUM(AccessCount) = page views
✅ RIGHT: COUNT(DISTINCT GenieLeadId) = actual clicks

Expected CTR: 2-5%
If CTR > 10%: Your calculation is WRONG!
```

### 2. Competition Command Filter
```sql
-- ✅ CORRECT: Both trigger types
WHERE PropertyCastTypeId = 1

-- ❌ WRONG: Misses 66% of campaigns!
WHERE PopertyCastTriggerTypeId = 1
```

### 3. Lead Tag IDs
| ID | Tag | Use For |
|----|-----|---------|
| 48 | OptInContact | CTA_Submitted |
| 51 | OptOutSms | Opt_Outs |
| 52 | CtaContactVerified | CTA_Verified |

---

# 📊 BENCHMARKS (November 2025)

| Metric | Value |
|--------|-------|
| **CC SMS Sent** | 19,875 |
| **CC Cost** | $360.78 |
| **LC Orders** | 21 |
| **LC Revenue** | ~$1,900 |
| **LC Profit Margin** | 96.4% |
| **Twilio Invoice** | $722.89 |
| **Phone Numbers** | 122 |
| **Orphan Numbers** | 24 ($355/yr savings) |
| **Missed Opportunities** | 6,697 (88.6%) |
| **Bots Identified** | 5 |

---

# 🗂️ FILE NAMING CONVENTION

```
[System]_[Type]_[Name]_[Date]_v[#].[ext]

Examples:
CC_Report_MonthlyOwnership_2025-12_v2.csv
LC_Spec_Performance_v3.md
Twilio_SOP_InvoiceReconciliation_v1.md
```

---

# 📝 CHANGELOG

| Date | Update |
|------|--------|
| 2025-12-11 | Created Operations Portal |
| 2025-12-11 | Added Engagement Analysis reports |
| 2025-12-11 | Identified 5 bot phone numbers |
| 2025-12-10 | Completed LC Performance Report v10 |
| 2025-12-10 | Fixed click calculation (AccessCount → GenieLeadId) |

---

*Last updated: December 11, 2025 by Cursor AI*




