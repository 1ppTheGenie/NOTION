# SOP: Competition Command Enhancement Orientation
## How to Get Cursor AI Up to Speed Instantly

**Version:** 1.0  
**Created:** 12/14/2025  
**Last Updated:** 12/14/2025  
**Author:** Steve Hundley  
**Purpose:** Eliminate repetitive onboarding questions for Competition Command Enhancement sessions

---

## QUICK START - Copy/Paste This Into Any New Chat

```
CONTEXT FOR THIS SESSION:

📂 CODEBASE LOCATIONS:
- C:\Cursor = Working directory with all docs
- C:\Cursor\Genie.Source.Code_v1 = .NET backend source
- C:\Cursor\GenieCLOUD_v1 = Node.js/React frontend
- C:\Cursor\GenieFeatureRequests = FR-001, FR-002, FR-003 docs
- C:\Cursor\NOTION = Local GitHub repo clone

📊 DATABASE:
- Server: 192.168.29.45 (also: server-mssql1.istrategy.com via VPN)
- User: cursor
- Database: FarmGenie
- Clicks = COUNT(DISTINCT GenieLeadId)
- CC = PropertyCastTypeId=1, LC = PropertyCastTypeId=2
- LeadTagTypeIds: 48=CTA, 51=OptOut, 52=Verified

🔧 SANDBOX:
- FarmGenie runs on IIS Express @ localhost:38949
- Login: shundley / 1ppINSAyay$
- VPN Required: SonicWall to 1pp network
- See: C:\Cursor\TheGenie_Sandbox_Setup_SOP_v2.md

📁 CURRENT PROJECT: Competition Command Enhancement (FR-001)
- Discovery v1.1: C:\Cursor\FR-001_CompetitionCommand_Discovery_v1.1.md
- Memory Log: C:\Cursor\WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancement_Workspace_v1.md

🌐 GITHUB: https://github.com/1ppTheGenie/NOTION
```

---

## COMPLETE FILE INVENTORY

### 🔴 SANDBOX & CODEBASE (Your Questions ANSWERED)

| Question You Asked | Answer | Reference File |
|--------------------|--------|----------------|
| "Do you have access to the Genie codebase?" | **YES** - Full .NET source code | `C:\Cursor\Genie.Source.Code_v1\` |
| "Is there a staging/dev environment?" | **YES** - Sandbox working on localhost:38949 | `C:\Cursor\TheGenie_Sandbox_Setup_SOP_v2.md` |
| "What language/framework is TheGenie admin built in?" | **.NET Framework 4.8 (C#)** + Angular 9 frontend | `C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\` |
| "Where is the Buy Area button code?" | `Smart.Core` project - need to investigate | `C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Core\` |
| "Where is Neighborhood Command subscription workflow?" | `Smart.Service.NeighborhoodCommand` | `C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\WindowsService\Smart.Service.NeighborhoodCommand\` |
| "Where is Listing Command wizard?" | `Smart.Service.ListingCommand` | `C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\WindowsService\Smart.Service.ListingCommand\` |

---

### 📦 SOURCE CODE STRUCTURE

```
C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\
│
├── Web\
│   ├── Smart.Web.FarmGenie\           ← MAIN APPLICATION (.NET 4.8 MVC)
│   │   ├── Smart.Dashboard\           ← Admin Dashboard
│   │   ├── Smart.Core\                ← Business Logic (OwnedAreaManager.cs HERE)
│   │   ├── Smart.Data\                ← Database Layer
│   │   └── Smart.NG.Agent\            ← Angular 9 Agent Portal (source)
│   │
│   ├── Smart.Api.GenieConnect\        ← API for external integrations
│   ├── Smart.Api.Notification\        ← Notification API
│   ├── Smart.Api.Oculus\              ← Oculus API
│   └── Smart.Api.Wrapper\             ← HTTP wrappers
│
└── WindowsService\
    ├── Smart.Service.ListingCommand\   ← LC workflow (INVESTIGATE THIS)
    ├── Smart.Service.NeighborhoodCommand\ ← NC workflow (INVESTIGATE THIS)
    ├── Smart.Service.PropertyCast\      ← CC campaigns live here
    ├── Smart.Service.Notification\      ← Notification service
    └── Smart.Service.PropertyCasterWorkflow\ ← Campaign orchestration
```

---

### 🌐 GENIE CLOUD STRUCTURE (Node.js/React)

```
C:\Cursor\GenieCLOUD_v1\GenieCLOUD\genie-cloud\
│
├── genie-api\                ← AWS Lambda backend (Node.js)
│   ├── src\
│   │   ├── index.js          ← Main entry point
│   │   ├── genieAI.js        ← AI/Paisley integration
│   │   └── utils\            ← Utilities
│   └── package.json
│
├── genie-components\         ← React components library
├── genie-collection-editor\  ← Collection management UI
├── genie-theme-editor\       ← Theme customization UI
├── genie-monitor\            ← System monitoring dashboard
│
└── public\                   ← Static assets
    └── _assets\
        └── _xsl\             ← XSLT templates for content rendering
```

---

### 📋 FEATURE REQUEST FILES (Competition Command Enhancement)

| FR # | Name | Latest Version | Location |
|------|------|----------------|----------|
| **FR-001** | Area Ownership & Waitlist | **v2** | `C:\Cursor\GenieFeatureRequests\FR-001_AreaOwnership_DiscoveryWorksheet_v2.md` |
| **FR-001** | Area Ownership Design Brief | v1 | `C:\Cursor\GenieFeatureRequests\FR-001_AreaOwnership_DesignBrief_v1.md` |
| **FR-001** | Area Ownership Dev Spec | **v2** | `C:\Cursor\GenieFeatureRequests\FR-001_AreaOwnership_DevSpec_v2.md` |
| **FR-002** | WHMCS Area Billing | **v2** | `C:\Cursor\GenieFeatureRequests\FR-002_WHMCS_AreaBilling_DiscoveryWorksheet_v2.md` |
| **FR-002** | WHMCS Design Brief | v1 | `C:\Cursor\GenieFeatureRequests\FR-002_WHMCS_AreaBilling_DesignBrief_v1.md` |
| **FR-002** | WHMCS Dev Spec | v1 | `C:\Cursor\GenieFeatureRequests\FR-002_WHMCS_AreaBilling_DevSpec_v1.md` |
| **FR-003** | Content Configurator | **v2** | `C:\Cursor\GenieFeatureRequests\FR-003_ContentConfigurator_DiscoveryWorksheet_v2.md` |
| **FR-003** | Content Configurator Design Brief | v1 | `C:\Cursor\GenieFeatureRequests\FR-003_ContentConfigurator_DesignBrief_v1.md` |
| **FR-003** | Content Configurator Dev Spec | v1 | `C:\Cursor\GenieFeatureRequests\FR-003_ContentConfigurator_DevSpec_v1.md` |

#### NEW (12/14/2025 Session)
| File | Version | Location |
|------|---------|----------|
| Competition Command Discovery | **v1.1** | `C:\Cursor\FR-001_CompetitionCommand_Discovery_v1.1.md` |
| Competition Command Memory Log | v1 | `C:\Cursor\WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancements_v1.md` |
| Discovery Master Package | v1 | `C:\Cursor\GenieFeatureRequests\DISCOVERY_MASTER_Competition_Command_Enhancement_v1.md` |
| Workspace Memory Log | v1 | `C:\Cursor\WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancement_Workspace_v1.md` |

---

### 📂 WORKSPACE MEMORY FILES (Session History)

| File | Purpose | Version |
|------|---------|---------|
| `WORKSPACE_MEMORY_MASTER_v10.md` | Notion integration session | Latest |
| `WORKSPACE_MEMORY_LOG_Sandbox_Complete_v1.md` | Sandbox setup complete | v1 |
| `WORKSPACE_MEMORY_LOG_Sandbox_Failure_v1.md` | Sandbox troubleshooting | v1 |
| `WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancements_v1.md` | CC Discovery session | v1 |
| `WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancement_Workspace_v1.md` | Workspace inventory | v1 |
| `TheGenie_Sandbox_Setup_SOP_v2.md` | How to run sandbox | **v2** |

---

### 🛠️ SOPs (Standard Operating Procedures)

| SOP | Purpose | Location |
|-----|---------|----------|
| **CC Enhancement Orientation** | This document - session quick start | `C:\Cursor\SOP_CompetitionCommand_Enhancement_Orientation_v1.md` |
| Sandbox Setup | How to run TheGenie locally | `C:\Cursor\TheGenie_Sandbox_Setup_SOP_v2.md` |
| CC Ownership Report | Generate CC ownership report | `C:\Cursor\GenieFeatureRequests\SOP_CC_Ownership_Report_v5.md` |
| CC Monthly Cost Report | Generate CC cost report | `C:\Cursor\GenieFeatureRequests\SOP_CC_Monthly_Cost_Report_v1.md` |
| Credential Tracker | Master credential management | `C:\Cursor\SOP_Credential_Tracker_Maintenance_v1.md` |

---

### 🌐 GITHUB REPOSITORY STRUCTURE

**Repo:** https://github.com/1ppTheGenie/NOTION

```
NOTION/
├── ChatGPT-Archives/           ← Exported ChatGPT conversations
├── Development/
│   ├── Architecture/           ← System architecture docs
│   ├── Documentation/          ← Workspace memory files
│   ├── FeatureRequests/        ← FR-001, etc.
│   └── Specs/                  ← Technical specifications
├── Documentation/              ← General documentation
├── Operations/
│   ├── MemoryLogs/             ← Session memory logs
│   ├── Reports/                ← Generated reports
│   └── SOPs/                   ← Standard procedures
└── TheGenie.ai/                ← Product-specific docs
    ├── Development/
    │   ├── FeatureRequests/    ← FR-001, FR-002, FR-003
    │   ├── SourceCode/         ← Code documentation
    │   └── SQL/                ← Database queries
    └── Operations/
        ├── Reports/
        ├── Scripts/
        ├── SOPs/
        └── Specs/
```

---

## KEY TECHNICAL FACTS

### Database Schema Awareness
| Table | Purpose |
|-------|---------|
| `UserOwnedArea` | Current area ownership (NO history, hard deletes) |
| `PropertyCast` | Campaign configurations |
| `PropertyCasterInfo` | Campaign execution details |
| `GenieLead` | Lead records |
| `LeadTagType` | Lead classification (48=CTA, 51=OptOut, 52=Verified) |

### Code Pattern References
| Pattern | File to Study |
|---------|---------------|
| Billing Handler | `Smart.Core\Billing\ListingCommandBillingHandler.cs` |
| Owned Area Manager | `Smart.Core\Managers\OwnedAreaManager.cs` |
| Notification Service | `Smart.Service.Notification\` |
| Property Cast Workflow | `Smart.Service.PropertyCasterWorkflow\` |

### Integration Points
| Integration | Status |
|-------------|--------|
| Genie ↔ WHMCS | ✅ Exists |
| Genie ↔ Twilio | ✅ Exists |
| Genie ↔ Versium | ✅ Exists |
| Genie ↔ MLS | ✅ Exists |
| Genie ↔ Attom | ✅ Exists |

---

## ACTION ITEMS (From Discovery v1.1)

### Immediate Investigation Tasks
| # | Task | Files to Read |
|:-:|------|--------------|
| 1 | Investigate "Buy Area" button code | `Smart.Core\Managers\OwnedAreaManager.cs` |
| 2 | Review NC subscription workflow | `Smart.Service.NeighborhoodCommand\` |
| 3 | Review LC wizard | `Smart.Service.ListingCommand\` |
| 4 | Document current CTA tracking | `genie-cloud\genie-components\src\utilities\utils.js` |
| 5 | Review pixel/retargeting setup | Look in FarmGenie dashboard code |

### Build Priorities
| Priority | Feature |
|:--------:|---------|
| 1 | Area ownership with history (soft deletes) |
| 2 | Waitlist system |
| 3 | Radar dashboard |
| 4 | Onboarding wizard |
| 5 | CTA tracking improvements |
| 6 | Lead to List matching |
| 7 | Customer-facing reports |

---

## CHANGE LOG

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 1.0 | 12/14/2025 | Cursor AI | Initial SOP creation with complete inventory |

---

*Document: SOP_CompetitionCommand_Enhancement_Orientation_v1.md*
*Purpose: One-stop reference for starting any Competition Command Enhancement session*

