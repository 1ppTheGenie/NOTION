# Workspace Memory Log
## Competition Command Enhancement Workspace

---

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/14/2025 |
| **Last Updated** | 12/14/2025 |
| **Author** | Steve Hundley |
| **Facilitator** | Cursor AI |
| **Session Type** | Workspace Inventory & Orientation |

---

# SESSION SUMMARY

This session created a comprehensive inventory of all TheGenie workspace assets relevant to the **Competition Command Enhancement** project. The goal was to eliminate repetitive onboarding questions and create a "quick start" reference for future sessions.

---

# KEY ACCOMPLISHMENTS

## 1. Complete Codebase Inventory

### Source Code Located
| Component | Path | Tech Stack |
|-----------|------|------------|
| **FarmGenie Backend** | `C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\` | .NET 4.8, C# |
| **Agent Dashboard** | `Smart.NG.Agent\` | Angular 9 |
| **Windows Services** | `WindowsService\Smart.Service.*\` | .NET Services |
| **Genie Cloud** | `C:\Cursor\GenieCLOUD_v1\GenieCLOUD\genie-cloud\` | Node.js 18, React |

### Key Files Identified for Investigation
| Task | File to Investigate |
|------|---------------------|
| "Buy Area" button | `Smart.Core\Managers\OwnedAreaManager.cs` |
| NC subscription workflow | `WindowsService\Smart.Service.NeighborhoodCommand\` |
| LC wizard | `WindowsService\Smart.Service.ListingCommand\` |
| Billing pattern | `Smart.Core\Billing\ListingCommandBillingHandler.cs` |
| CTA configuration | `genie-cloud\genie-components\src\utilities\utils.js` |

---

## 2. Feature Request Documentation Catalogued

### Competition Command Enhancement Bundle (FR-001)
| Document Type | Latest Version | Location |
|---------------|----------------|----------|
| Discovery Worksheet (Original) | v2 | `C:\Cursor\GenieFeatureRequests\FR-001_AreaOwnership_DiscoveryWorksheet_v2.md` |
| Discovery Worksheet (New Session) | v1.1 | `C:\Cursor\FR-001_CompetitionCommand_Discovery_v1.1.md` |
| Design Brief | v1 | `C:\Cursor\GenieFeatureRequests\FR-001_AreaOwnership_DesignBrief_v1.md` |
| Dev Spec | v2 | `C:\Cursor\GenieFeatureRequests\FR-001_AreaOwnership_DevSpec_v2.md` |
| Master Package | v1 | `C:\Cursor\GenieFeatureRequests\DISCOVERY_MASTER_Competition_Command_Enhancement_v1.md` |

### Related Feature Requests
| FR # | Name | Latest Version |
|------|------|----------------|
| FR-002 | WHMCS Area Billing | v2 |
| FR-003 | Content Configurator | v2 |

---

## 3. Sandbox Setup Confirmed

### Environment Status
| Component | Status | Access |
|-----------|--------|--------|
| FarmGenie Backend | ✅ Working | localhost:38949 |
| Angular Agent Dashboard | ✅ Working | localhost:38949/agent |
| Database (FarmGenie) | ✅ Connected | 192.168.29.45 / cursor |
| Genie Cloud | ⏳ Pending AWS credentials | localhost:3001 |
| VPN (SonicWall) | ✅ Required for DB access | - |

### Login Credentials
- **URL:** http://localhost:38949
- **Username:** shundley
- **Password:** 1ppINSAyay$

---

## 4. Documents Created This Session

| Document | Version | Purpose |
|----------|---------|---------|
| `SOP_CompetitionCommand_Enhancement_Orientation_v1.md` | v1 | Quick-start reference for any session |
| `WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancement_Workspace_v1.md` | v1 | This file - session record |

---

# QUESTIONS ANSWERED

| Question Asked | Answer Found |
|----------------|--------------|
| Do you have codebase access? | **YES** - Full .NET source at `C:\Cursor\Genie.Source.Code_v1\` |
| Is there a dev environment? | **YES** - Sandbox at localhost:38949 (IIS Express) |
| What language/framework? | **.NET 4.8 (C#)** + Angular 9 + Node.js |
| Where is "Buy Area" code? | `Smart.Core\Managers\OwnedAreaManager.cs` |
| Where is NC workflow? | `WindowsService\Smart.Service.NeighborhoodCommand\` |
| Where is LC wizard? | `WindowsService\Smart.Service.ListingCommand\` |

---

# TECHNICAL REFERENCE

## Database Facts
| Fact | Value |
|------|-------|
| Server | 192.168.29.45 (or server-mssql1.istrategy.com via VPN) |
| User | cursor |
| Database | FarmGenie |
| Clicks Definition | COUNT(DISTINCT GenieLeadId) |
| CC PropertyCastTypeId | 1 |
| LC PropertyCastTypeId | 2 |
| LeadTagTypeId 48 | CTA Submitted |
| LeadTagTypeId 51 | Opt Out |
| LeadTagTypeId 52 | Verified |

## GitHub Repository
| Field | Value |
|-------|-------|
| Repo | https://github.com/1ppTheGenie/NOTION |
| Branch | main |
| Commits | 1,712+ |

---

# INVESTIGATION ACTION ITEMS (NEXT STEPS)

## From Discovery v1.1
| # | Task | Target File |
|:-:|------|-------------|
| 1 | Investigate "Buy Area" button code | `OwnedAreaManager.cs` |
| 2 | Review NC subscription workflow | `Smart.Service.NeighborhoodCommand\` |
| 3 | Review LC wizard (MLS, content selection) | `Smart.Service.ListingCommand\` |
| 4 | Document current CTA tracking | `utils.js` in genie-cloud |
| 5 | Review pixel/retargeting setup | FarmGenie dashboard code |

## Build Priorities (After Investigation)
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

# FILE LOCATIONS QUICK REFERENCE

## Local Paths
| Purpose | Path |
|---------|------|
| Working Directory | `C:\Cursor\` |
| Source Code | `C:\Cursor\Genie.Source.Code_v1\` |
| Genie Cloud | `C:\Cursor\GenieCLOUD_v1\` |
| Feature Requests | `C:\Cursor\GenieFeatureRequests\` |
| GitHub Clone | `C:\Cursor\NOTION\` |
| Sandbox SOP | `C:\Cursor\TheGenie_Sandbox_Setup_SOP_v2.md` |

## GitHub URLs
| Purpose | URL |
|---------|-----|
| Main Repo | https://github.com/1ppTheGenie/NOTION |
| Discovery v1.1 | https://github.com/1ppTheGenie/NOTION/blob/main/Development/FeatureRequests/FR-001_CompetitionCommand_Discovery_v1.1.md |
| Memory Log | https://github.com/1ppTheGenie/NOTION/blob/main/Operations/MemoryLogs/WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancements_v1.md |

---

# RELATED MEMORY LOGS

| Log | Date | Focus |
|-----|------|-------|
| `WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancements_v1.md` | 12/14/2025 | Discovery session |
| `WORKSPACE_MEMORY_LOG_Sandbox_Complete_v1.md` | 12/13/2025 | Sandbox setup |
| `WORKSPACE_MEMORY_MASTER_v10.md` | 12/12/2025 | Notion integration |

---

# CHANGE LOG

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 1.0 | 12/14/2025 | Cursor AI | Initial workspace inventory and orientation session |

---

*Document: WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancement_Workspace_v1.md*
*Session Date: 12/14/2025*
*Purpose: Comprehensive workspace inventory for Competition Command Enhancement project*

