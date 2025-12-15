# SOP: Competition Command Enhancement Orientation
## How to Get Cursor AI Up to Speed Instantly

**Version:** 2.0  
**Created:** 12/14/2025  
**Last Updated:** 12/14/2025  
**Author:** Steve Hundley  
**Purpose:** Eliminate repetitive onboarding questions for Competition Command Enhancement sessions

---

## QUICK START - Copy/Paste This Into Any New Chat

```
CONTEXT FOR THIS SESSION:

📂 PROJECT ROOT:
C:\Cursor\TheGenie.ai\Development\CompetitionCommand\

📁 FOLDER STRUCTURE:
├── FeatureRequests\  ← Discovery worksheets, design briefs
├── MemoryLogs\       ← Session history and handoffs
├── SOPs\             ← Operating procedures
└── Specs\            ← Technical specifications (DevSpecs)

📊 DATABASE:
- Server: 192.168.29.45 (or server-mssql1.istrategy.com via VPN)
- User: cursor
- Database: FarmGenie
- Clicks = COUNT(DISTINCT GenieLeadId)
- CC = PropertyCastTypeId=1, LC = PropertyCastTypeId=2
- LeadTagTypeIds: 48=CTA, 51=OptOut, 52=Verified

🔧 SANDBOX:
- FarmGenie: localhost:38949 (IIS Express)
- Login: shundley / 1ppINSAyay$
- VPN Required: SonicWall to 1pp network

💻 SOURCE CODE:
- C:\Cursor\Genie.Source.Code_v1\ = .NET backend
- C:\Cursor\GenieCLOUD_v1\ = Node.js/React frontend

🌐 GITHUB: https://github.com/1ppTheGenie/NOTION
```

---

## 📁 NEW ORGANIZED FOLDER STRUCTURE

```
C:\Cursor\TheGenie.ai\
│
├── Development\
│   ├── CompetitionCommand\              ← YOU ARE HERE
│   │   ├── FeatureRequests\             ← FR-001, FR-002, FR-003 discovery & design
│   │   ├── MemoryLogs\                  ← Session logs, handoffs
│   │   ├── SOPs\                        ← CC-specific procedures
│   │   └── Specs\                       ← DevSpecs (technical implementation)
│   │
│   ├── ListingCommand\
│   │   └── FeatureRequests\
│   │
│   └── NeighborhoodCommand\
│       └── FeatureRequests\
│
├── Operations\
│   ├── Reports\
│   │   ├── CompetitionCommand\
│   │   ├── ListingCommand\
│   │   └── Twilio\
│   ├── Scripts\
│   ├── SOPs\                            ← General ops SOPs (sandbox, etc.)
│   └── Specs\
│
└── SourceCode\                          ← Code documentation
```

---

## 📋 COMPETITION COMMAND FILES INVENTORY

### FeatureRequests (Discovery & Design)
| File | Description |
|------|-------------|
| `FR-001_CompetitionCommand_Discovery_v1.1.md` | **LATEST** - Full discovery session 12/14/2025 |
| `FR-001_AreaOwnership_DiscoveryWorksheet_v2.md` | Area ownership discovery |
| `FR-001_AreaOwnership_DesignBrief_v1.md` | Area ownership design brief |
| `FR-002_WHMCS_AreaBilling_DiscoveryWorksheet_v2.md` | WHMCS billing discovery |
| `FR-002_WHMCS_AreaBilling_DesignBrief_v1.md` | WHMCS billing design brief |
| `FR-003_ContentConfigurator_DiscoveryWorksheet_v2.md` | CTA/Content discovery |
| `FR-003_ContentConfigurator_DesignBrief_v1.md` | CTA/Content design brief |
| `DISCOVERY_MASTER_Competition_Command_Enhancement_v1.md` | Master package overview |

### Specs (Technical Implementation)
| File | Description |
|------|-------------|
| `FR-001_AreaOwnership_DevSpec_v2.md` | Area ownership technical spec |
| `FR-002_WHMCS_AreaBilling_DevSpec_v1.md` | WHMCS billing technical spec |
| `FR-003_ContentConfigurator_DevSpec_v1.md` | CTA configurator technical spec |

### MemoryLogs (Session History)
| File | Description |
|------|-------------|
| `WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancement_Workspace_v1.md` | Workspace inventory session |
| `WORKSPACE_MEMORY_LOG_CompetitionCommand_Enhancements_v1.md` | Discovery session log |
| `WORKSPACE_MEMORY_MASTER_v10.md` | Notion integration session |

### SOPs (Procedures)
| File | Description |
|------|-------------|
| `SOP_CompetitionCommand_Enhancement_Orientation_v2.md` | **THIS FILE** |
| `SOP_CC_Ownership_Report_v5.md` | Latest ownership report SOP |
| `SOP_CC_Monthly_Cost_Report_v1.md` | Cost report SOP |

---

## 💻 SOURCE CODE LOCATIONS

### .NET Backend
```
C:\Cursor\Genie.Source.Code_v1\Genie.Source.Code\
│
├── Web\Smart.Web.FarmGenie\             ← MAIN APPLICATION
│   ├── Smart.Dashboard\                 ← Admin Dashboard (MVC)
│   ├── Smart.Core\                      ← Business Logic
│   │   ├── Managers\OwnedAreaManager.cs ← BUY AREA CODE HERE
│   │   └── Billing\ListingCommandBillingHandler.cs ← Billing pattern
│   ├── Smart.Data\                      ← Database Layer
│   └── Smart.NG.Agent\                  ← Angular 9 Agent Portal
│
└── WindowsService\
    ├── Smart.Service.NeighborhoodCommand\ ← NC workflow (investigate)
    ├── Smart.Service.ListingCommand\      ← LC wizard (investigate)
    ├── Smart.Service.PropertyCast\        ← CC campaigns
    └── Smart.Service.Notification\        ← Notifications
```

### Node.js Frontend (Genie Cloud)
```
C:\Cursor\GenieCLOUD_v1\GenieCLOUD\genie-cloud\
│
├── genie-api\src\                       ← AWS Lambda backend
├── genie-components\src\utilities\      ← CTA config (utils.js)
├── genie-collection-editor\             ← Collection management
└── genie-theme-editor\                  ← Theme customization
```

---

## 🎯 ACTION ITEMS (From Discovery v1.1)

### Immediate Investigation Tasks
| # | Task | File to Read |
|:-:|------|--------------|
| 1 | "Buy Area" button code | `Smart.Core\Managers\OwnedAreaManager.cs` |
| 2 | NC subscription workflow | `WindowsService\Smart.Service.NeighborhoodCommand\` |
| 3 | LC wizard | `WindowsService\Smart.Service.ListingCommand\` |
| 4 | CTA tracking | `genie-components\src\utilities\utils.js` |
| 5 | Pixel/retargeting | FarmGenie dashboard code |

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

## 🔧 SANDBOX QUICK START

```powershell
# 1. Connect VPN (SonicWall)
# 2. Start IIS Express
cd "C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie"
& "C:\Program Files (x86)\IIS Express\iisexpress.exe" /config:".vs\FarmGenie\config\applicationhost.config" /site:Smart.Dashboard

# Access at: http://localhost:38949
# Login: shundley / 1ppINSAyay$
```

---

## 📊 DATABASE QUICK REFERENCE

| Fact | Value |
|------|-------|
| Server | 192.168.29.45 |
| User | cursor |
| Database | FarmGenie |
| CC PropertyCastTypeId | 1 |
| LC PropertyCastTypeId | 2 |
| LeadTagTypeId 48 | CTA Submitted |
| LeadTagTypeId 51 | Opt Out |
| LeadTagTypeId 52 | Verified |

---

## CHANGE LOG

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 1.0 | 12/14/2025 | Cursor AI | Initial SOP creation |
| 2.0 | 12/14/2025 | Cursor AI | Reorganized with proper folder hierarchy |

---

*Document: SOP_CompetitionCommand_Enhancement_Orientation_v2.md*
*Location: C:\Cursor\TheGenie.ai\Development\CompetitionCommand\SOPs\*

