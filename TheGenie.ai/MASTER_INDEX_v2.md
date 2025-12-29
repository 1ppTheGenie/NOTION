# THEGENIE.AI MASTER INDEX
**Your Single Source of Truth for Everything**

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 2.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/22/2025 |
| **Purpose** | Master reference for all TheGenie.ai documentation, memory logs, and key locations |
| **Status** | ACTIVE - Reference this file at the start of every new chat session |

---

## 🚨 CRITICAL: DRIVE LOCATION

**ALL FILES MUST BE ON D: DRIVE - NEVER C: DRIVE**

When starting a new chat, say:
> "Reference the MASTER_INDEX at `D:\Cursor\TheGenie.ai\MASTER_INDEX_v2.md`"

This file tells me where EVERYTHING is located.

---

## 🌐 GLOBAL ASSET SOURCES (Search These First!)

### Dropbox - Primary Asset Library (NEW)

| Item | Value |
|------|-------|
| **Location** | `D:\Cursor\TheGenie.ai\Development\Integrations\Dropbox\` |
| **Total Size** | ~322 GB |
| **Status** | ✅ Synced and Accessible |
| **Purpose** | Historical assets, client files, marketing materials, templates |

**Key Folders in Dropbox:**

| Folder | Contents |
|--------|----------|
| `_HighTouchGenieClients\` | High-touch client files (Andrew Lyon, Chris Heller KW, Mark Rushford, etc.) |
| `1 Parkplace Clients\` | All 1PP client folders |
| `Farm Genie Assets\` | Farm Genie marketing materials and proofs |
| `Farm Genie - List To Leads Marketing\` | Lead marketing assets |
| `Marketing Hub Wizard Onboarding\` | Onboarding materials |
| `Paisley\` | Paisley AI assets |
| `MyNeighborhood.re Inventory\` | Neighborhood landing page inventory |
| `Corporate Assets\` | Corporate branding and assets |
| `WireFrames and CallOuts\` | UI/UX wireframes |

**Search Dropbox:**
```powershell
# Search for files by name
Get-ChildItem -Path "D:\Cursor\TheGenie.ai\Development\Integrations\Dropbox" -Recurse -Filter "*keyword*"

# Search inside files
Select-String -Path "D:\Cursor\TheGenie.ai\Development\Integrations\Dropbox\**\*.txt" -Pattern "search term"
```

---

## 🔥 MOST COMMONLY NEEDED - Database/SQL Access

**If you need to access the SQL database, here it is:**

| Item | Value |
|------|-------|
| **Server (VPN Required)** | `192.168.29.45` |
| **Server (Hostname)** | `server-mssql1.istrategy.com` |
| **Port** | `1433` |
| **User** | `cursor` |
| **Password** | `1ppINSAyay$` |
| **Primary Database** | `FarmGenie` |
| **MLS Database** | `MlsListing` |
| **Title Database** | `TitleData` |

**Python Connection Template:**
```python
import pyodbc
import pandas as pd

def connect():
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER=192.168.29.45,1433;"
        f"DATABASE=FarmGenie;"
        f"UID=cursor;PWD=1ppINSAyay$;"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)
```

**⚠️ IMPORTANT:** Requires SonicWall VPN connection to access `192.168.29.45`

---

## 📍 KEY LOCATIONS

### Workspace Memory Logs (Session Documentation)

| Location | Purpose | Status |
|----------|---------|--------|
| **Local (Working):** `D:\Cursor\TheGenie.ai\MemoryLogs\` | Where new memory logs are created during sessions | ✅ Active |
| **GitHub (Permanent):** `D:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\` | Permanent archive - ALL logs must be copied here | ✅ Active |
| **GitHub Remote:** `https://github.com/1ppTheGenie/NOTION/tree/main/TheGenie.ai/MemoryLogs` | Online repository | ✅ Active |

**Naming Convention:**
```
WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md
```

---

### Master Documentation Files

| File | Location | Purpose |
|------|----------|---------|
| **MASTER_INDEX** | `D:\Cursor\TheGenie.ai\MASTER_INDEX_v2.md` | This file - start here |
| **PERMANENT_STRUCTURE** | `D:\Cursor\TheGenie.ai\PERMANENT_DIRECTORY_STRUCTURE_v2.md` | Directory structure rules |
| **CURSOR_RULES** | `TheGenie.ai.Database\.cursorrules` | **🚨 COMPLETE MASTER RULES - Auto-loaded by Cursor** |
| **CREDENTIAL_TRACKER** | `G:\My Drive\Master_Credential_Tracker_v3.md` | All credentials and configuration |
| **GITHUB_CLEAN_RULE** | `D:\Cursor\TheGenie.ai\MASTER_RULE_GITHUB_CLEAN_v1.md` | Rules for clean commits |
| **MEMORY_LOG_RULES** | `D:\Cursor\TheGenie.ai\MASTER_RULE_MEMORY_LOGS_v1.md` | Memory log workflow |

---

### Integrations (Third-Party Services)

| Integration | Location | Status |
|-------------|----------|--------|
| **Dropbox** | `D:\Cursor\TheGenie.ai\Development\Integrations\Dropbox\` | ✅ Synced (~322 GB) |
| **WHMCS** | `D:\Cursor\TheGenie.ai\Development\Integrations\WHMCS\` | ✅ Active |
| **Intercom** | `D:\Cursor\TheGenie.ai\Development\Integrations\Intercom\` | ✅ Active |
| **AWS** | `D:\Cursor\TheGenie.ai\Development\Integrations\AWS\` | ⚠️ Pending |
| **Asana** | `D:\Cursor\TheGenie.ai\Development\Integrations\Asana\` | ⏳ Planned |
| **GoogleDrive** | `D:\Cursor\TheGenie.ai\Development\Integrations\GoogleDrive\` | ⏳ Planned |
| **iCloud** | `D:\Cursor\TheGenie.ai\Development\Integrations\iCloud\` | ⏳ Planned |

**Integrations Index:** `D:\Cursor\TheGenie.ai\Development\Integrations\README_v1.md`

---

### Sandbox Information

| Item | Location | Details |
|------|----------|---------|
| **Config Files** | `D:\Cursor\_ARCHIVE_Downloads\sandbox_configs\` | All sandbox configuration |
| **Environment** | `D:\Cursor\_ARCHIVE_Downloads\sandbox_configs\env.sandbox.txt` | Environment variables |
| **Web Config** | `D:\Cursor\_ARCHIVE_Downloads\sandbox_configs\Web.Sandbox.config` | IIS/Web configuration |
| **Startup Script** | `D:\Cursor\_ARCHIVE_Downloads\sandbox_configs\start-sandbox.ps1` | PowerShell startup script |

**Sandbox URLs:**
- FarmGenie: `http://localhost:38949`
- Agent Dashboard: `http://localhost:38949/agent`
- Test Login: `shundley / 1ppINSAyay$`

---

### GitHub Repository

| Item | Value |
|------|-------|
| **Repository** | `1ppTheGenie/NOTION` |
| **URL** | `https://github.com/1ppTheGenie/NOTION` |
| **Local Clone** | `D:\Cursor\_ARCHIVE_Downloads\NOTION\` |
| **Branch** | `main` |
| **Status** | PRIMARY documentation system (NOT Notion) |

**Structure:**
```
NOTION/
├── TheGenie.ai/
│   ├── MemoryLogs/          ← Session memory logs go here
│   ├── Development/         ← Feature requests, specs, discovery
│   │   └── Integrations/    ← Third-party service integrations
│   ├── Operations/          ← Reports, SOPs, scripts
│   └── APPROVED/            ← Finalized deliverables
```

---

## 📚 MEMORY LOG CATALOG

### All Workspace Memory Logs (Chronological)

| Date | Topic | File Name | Key Focus |
|------|-------|-----------|-----------|
| 12/15/2025 | Area Ownership & Lead Custody | `WORKSPACE_MEMORY_LOG_AreaOwnership_LeadCustody_Session_2025-12-15.md` | Schema design, orphaned leads (66.5%), referral system gap |
| 12/15/2025 | Competition Command Reports | `WORKSPACE_MEMORY_LOG_CCReports_Session_2025-12-15.md` | CC Monthly Cost Report v1.0, property type handling, notification logic |
| 12/15/2025 | Lead-to-Listing Analysis | `WORKSPACE_MEMORY_LOG_LeadToListing_Analysis_2025-12-15.md` | Conversion analysis (0.26% win rate), engagement enrichment, $21.5B lost revenue |
| 12/15/2025 | Nurture Engine Discovery | `WORKSPACE_MEMORY_LOG_NurtureEngine_Discovery_2025-12-15.md` | Strategic vision, 5-phase roadmap, ownership model, Christmas pilot |
| 12/16/2025 | Documentation System & Master Rules | `WORKSPACE_MEMORY_LOG_DocumentationSystem_MasterRules_Established_Session_2025-12-16.md` | MASTER_INDEX created, permanent documentation system, GitHub clean commit rules, agent guide |
| 12/16/2025 | Versium Executive Summary | `WORKSPACE_MEMORY_LOG_Versium_ExecutiveSummary_Documentation_Session_2025-12-16.md` | Versium cache migration documents organized, deployment spec updated with executive-friendly summary |
| 12/20/2025 | Automated Dispute Defense - System Integration | `WORKSPACE_MEMORY_LOG_AutomatedDisputeDefense_SystemIntegration_Session_2025-12-20_v1.md` | WHMCS, Intercom, Zoom Phone APIs verified and operational. All credentials documented. Ready for Kit creation phase. |
| 12/22/2025 | Dropbox Integration | This session | Dropbox synced to D: drive (~322 GB). Integrations folder structure created. |

---

## 🎯 QUICK REFERENCE COMMANDS

### Search Dropbox Assets
```powershell
# Find files by name in Dropbox
Get-ChildItem -Path "D:\Cursor\TheGenie.ai\Development\Integrations\Dropbox" -Recurse -Filter "*FarmGenie*"

# Search content inside Dropbox files
Select-String -Path "D:\Cursor\TheGenie.ai\Development\Integrations\Dropbox\**\*.md" -Pattern "keyword"
```

### Find Memory Logs
```powershell
# List all memory logs
Get-ChildItem "D:\Cursor\TheGenie.ai\MemoryLogs\*.md"

# List GitHub memory logs
Get-ChildItem "D:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\*.md"
```

### Search Memory Logs
```powershell
# Search for topic across all logs
Select-String -Path "D:\Cursor\TheGenie.ai\MemoryLogs\*.md" -Pattern "AreaOwnership"
```

---

## 📋 MASTER RULES QUICK REFERENCE

**🚨 IMPORTANT:** `.cursorrules` is automatically loaded by Cursor and contains the COMPLETE master rules.

**Full Rules Location:** `TheGenie.ai.Database\.cursorrules`

### Critical Rules (Quick Reference)

#### Drive Location
- **NEVER save to C: drive** - ALL files must be on D: drive
- C: drive is TABOO - no exceptions

#### File Versioning
- **NEVER overwrite files** - Always increment version number
- Format: `[Name]_v[N].ext` or `[Name]_[YYYY-MM-DD]_v[N].ext`
- Minor changes: v1.0 → v1.1
- Major changes: v1.1 → v2.0

#### Documentation System
- **GitHub is PRIMARY** - All docs must be in GitHub (NOT Notion)
- **Memory logs are REQUIRED** - Every significant session gets a memory log
- **NEVER use `git add -A`** - Add files specifically

#### Database Rules
- **Clicks = COUNT(DISTINCT GenieLeadId)** - NOT AccessCount
- **CC = PropertyCastTypeId = 1** - Competition Command

---

## ✅ CHECKLIST: Starting a New Chat

When you start a new chat, I should:

- [ ] **Study this MASTER_INDEX file** (required before starting any task)
- [ ] **Check Dropbox** for existing assets related to the project
- [ ] **Review `.cursorrules`** (automatically loaded)
- [ ] Check recent memory logs in `D:\Cursor\TheGenie.ai\MemoryLogs\`
- [ ] Know where to save new files (D: drive ONLY)
- [ ] Know GitHub location for permanent storage

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/15/2025 | Initial master index created with all key locations, memory log catalog, and workflow |
| 1.1 | 12/19/2025 | Added critical versioning rule: Date changes don't reset version numbers |
| 1.2 | 12/20/2025 | Added Automated Dispute Defense system integration memory log |
| 1.3 | 12/20/2025 | Added rule: Never create duplicate v1 files |
| 2.0 | 12/22/2025 | **MAJOR UPDATE:** (1) Changed ALL paths from C: to D: drive. (2) Added Dropbox as Global Asset Source (~322 GB synced). (3) Added Integrations section with all third-party services. (4) Updated credential tracker to v3. (5) Added "Check Dropbox first" to new chat checklist. |

---

**This file is PERMANENT. Update it when structure changes. Reference it at the start of every session.**

*Last Updated: 12/22/2025*

