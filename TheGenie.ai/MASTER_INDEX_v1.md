# THEGENIE.AI MASTER INDEX
**Your Single Source of Truth for Everything**

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Purpose** | Master reference for all TheGenie.ai documentation, memory logs, and key locations |
| **Status** | ACTIVE - Reference this file at the start of every new chat session |

---

## 🚨 START HERE - Quick Orientation

**When starting a new chat, say:**
> "Reference the MASTER_INDEX at `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md`"

This file tells me where EVERYTHING is located.

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

**SQL Server Management Studio Connection:**
- Server: `192.168.29.45,1433` or `server-mssql1.istrategy.com,1433`
- Authentication: SQL Server Authentication
- Login: `cursor`
- Password: `1ppINSAyay$`

**⚠️ IMPORTANT:** Requires SonicWall VPN connection to access `192.168.29.45`

**Full Database Details:** See "Database Access" section below for complete reference.

---

## 📍 KEY LOCATIONS

### Workspace Memory Logs (Session Documentation)

| Location | Purpose | Status |
|----------|---------|--------|
| **Local (Working):** `c:\Cursor\TheGenie.ai\MemoryLogs\` | Where new memory logs are created during sessions | ✅ Active |
| **GitHub (Permanent):** `c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\` | Permanent archive - ALL logs must be copied here | ✅ Active |
| **GitHub Remote:** `https://github.com/1ppTheGenie/NOTION/tree/main/TheGenie.ai/MemoryLogs` | Online repository | ✅ Active |

**Naming Convention:**
```
WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md
```

**Examples:**
- `WORKSPACE_MEMORY_LOG_AreaOwnership_LeadCustody_Session_2025-12-15.md`
- `WORKSPACE_MEMORY_LOG_CCReports_Session_2025-12-15.md`
- `WORKSPACE_MEMORY_LOG_NurtureEngine_Discovery_2025-12-15.md`

---

### Master Documentation Files

| File | Location | Purpose |
|------|----------|---------|
| **MASTER_INDEX** | `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md` | This file - start here |
| **WORKSPACE_MEMORY** | `TheGenie.ai.Database\GenieCursor\SOP Documentations\WORKSPACE_MEMORY_v2.md` | Technical reference (database, products, reports) |
| **CREDENTIAL_TRACKER** | `G:\My Drive\Master_Credential_Tracker_v2.md` | All credentials and configuration |
| **CURSOR_RULES** | `TheGenie.ai.Database\.cursorrules` | Master rules for file handling, GitHub, QA |
| **GITHUB_CLEAN_RULE** | `c:\Cursor\TheGenie.ai\MASTER_RULE_GITHUB_CLEAN_v1.md` | Rules for clean commits - prevent garbage files |

---

### Sandbox Information

| Item | Location | Details |
|------|----------|---------|
| **Config Files** | `c:\Cursor\_ARCHIVE_Downloads\sandbox_configs\` | All sandbox configuration |
| **Environment** | `c:\Cursor\_ARCHIVE_Downloads\sandbox_configs\env.sandbox.txt` | Environment variables |
| **Web Config** | `c:\Cursor\_ARCHIVE_Downloads\sandbox_configs\Web.Sandbox.config` | IIS/Web configuration |
| **Startup Script** | `c:\Cursor\_ARCHIVE_Downloads\sandbox_configs\start-sandbox.ps1` | PowerShell startup script |

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
| **Local Clone** | `c:\Cursor\_ARCHIVE_Downloads\NOTION\` |
| **Branch** | `main` |
| **Status** | PRIMARY documentation system (NOT Notion) |

**Structure:**
```
NOTION/
├── TheGenie.ai/
│   ├── MemoryLogs/          ← Session memory logs go here
│   ├── Development/          ← Feature requests, specs, discovery
│   ├── Operations/           ← Reports, SOPs, scripts
│   └── APPROVED/             ← Finalized deliverables
```

---

### Database Access

| Item | Value |
|------|-------|
| **Server (VPN)** | `192.168.29.45` |
| **Server (Hostname)** | `server-mssql1.istrategy.com` |
| **User** | `cursor` |
| **Password** | `1ppINSAyay$` |
| **Primary DB** | `FarmGenie` |
| **MLS DB** | `MlsListing` |
| **Title DB** | `TitleData` |

**Connection String Template:**
```python
SERVER = "192.168.29.45"
PORT = 1433
DATABASE = "FarmGenie"
USER = "cursor"
PASSWORD = "1ppINSAyay$"
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

### Story Arc (What We've Learned)

**Week 1 (12/15/2025):** Foundation & Discovery
1. **Area Ownership Crisis** - Discovered 66.5% of leads are orphaned when agents cancel
2. **Lead Custody Solution** - Designed schema where 1PP owns leads, agents have licenses
3. **CC Reports** - Built monthly cost reports with proper property type separation
4. **Conversion Crisis** - Found 0.26% win rate, $21.5B in lost listings
5. **Nurture Engine Vision** - Strategic roadmap to replace GoHighLevel, build purpose-specific CRM

**Week 2 (12/16/2025):** Documentation System & Process
6. **Documentation System Established** - MASTER_INDEX created, permanent structure, GitHub clean commit rules
7. **Versium Cache Migration** - Executive summary documents organized, deployment spec updated for development team

**Key Patterns:**
- Ownership model: 1PP owns everything (territory, leads, audience, pages)
- Agents are partners/lessees, not owners
- Handoff is broken - need structured transition
- Engagement enrichment needed before handoff
- Two-sided CRM: Agent acquisition + Consumer nurturing

---

## 🔄 WORKFLOW: Creating & Managing Memory Logs

### Step 1: Create During Session
- **Location:** `c:\Cursor\TheGenie.ai\MemoryLogs\`
- **Naming:** `WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md`
- **Template:** Use existing logs as template (Executive Summary, Session Info, Key Findings, etc.)

### Step 2: Copy to GitHub
- **Source:** `c:\Cursor\TheGenie.ai\MemoryLogs\[filename].md`
- **Destination:** `c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\[filename].md`
- **Action:** Copy file maintaining exact name

### Step 3: Commit to GitHub
```bash
cd c:\Cursor\_ARCHIVE_Downloads\NOTION
git add TheGenie.ai/MemoryLogs/[filename].md
git commit -m "Add memory log: [Topic] session [YYYY-MM-DD]"
git push origin main
```

### Step 4: Update This Index
- Add new log to "Memory Log Catalog" section above
- Update "Story Arc" if new patterns emerge
- Increment version number if structure changes

---

## 🎯 QUICK REFERENCE COMMANDS

### Find Memory Logs
```powershell
# List all memory logs
Get-ChildItem "c:\Cursor\TheGenie.ai\MemoryLogs\*.md"

# List GitHub memory logs
Get-ChildItem "c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\*.md"
```

### Search Memory Logs
```powershell
# Search for topic across all logs
Select-String -Path "c:\Cursor\TheGenie.ai\MemoryLogs\*.md" -Pattern "AreaOwnership"
```

### Access Sandbox
```powershell
# Start sandbox
cd c:\Cursor\_ARCHIVE_Downloads\sandbox_configs
.\start-sandbox.ps1
```

---

## 📋 MASTER RULES (From Memory Logs)

### File Versioning
- **NEVER overwrite files** - Always increment version number
- Format: `[Name]_v[N].ext` or `[Name]_[YYYY-MM-DD]_v[N].ext`
- Minor changes: v1.0 → v1.1
- Major changes: v1.1 → v2.0

### Documentation
- **GitHub is PRIMARY** - All docs must be in GitHub (NOT Notion)
- **Memory logs are REQUIRED** - Every session gets a memory log
- **Executive Summary** - Every document needs 5-second understanding at top

### Database
- **Clicks = COUNT(DISTINCT GenieLeadId)** - NOT AccessCount
- **Property Types are SEPARATE** - SFR (0) and Condo (1) are different orders
- **CC = PropertyCastTypeId = 1** - Includes BOTH trigger types (ListingSold + ListingNew)

---

## 🔗 RELATED DOCUMENTS

| Document | Location | Purpose |
|----------|----------|---------|
| WORKSPACE_MEMORY_v2.md | `TheGenie.ai.Database\GenieCursor\SOP Documentations\` | Technical reference |
| Master Credential Tracker | `G:\My Drive\Master_Credential_Tracker_v2.md` | Credentials |
| .cursorrules | `TheGenie.ai.Database\.cursorrules` | Master rules |
| MASTER_CATALOG | `111PPDrive\Organized_TheGenie_Assets\00_MASTER_CATALOG_v1.md` | Asset library |

---

## ✅ CHECKLIST: Starting a New Chat

When you start a new chat, I should:

- [ ] Read this MASTER_INDEX file
- [ ] Check recent memory logs in `c:\Cursor\TheGenie.ai\MemoryLogs\`
- [ ] Understand current project context from latest log
- [ ] Know where to save new memory logs
- [ ] Know GitHub location for permanent storage
- [ ] Reference WORKSPACE_MEMORY_v2.md for technical details if needed

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/15/2025 | Initial master index created with all key locations, memory log catalog, and workflow |

---

**This file is PERMANENT. Update it when structure changes. Reference it at the start of every session.**

*Last Updated: 12/15/2025*

