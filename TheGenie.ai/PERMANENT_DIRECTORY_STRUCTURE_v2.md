# PERMANENT DIRECTORY STRUCTURE - TheGenie.ai
**This Structure is PERMANENT - Do Not Change Without Approval**

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 2.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/22/2025 |
| **Status** | PERMANENT - Reference in all sessions |

---

## 🚨 CRITICAL: DRIVE LOCATION

**ALL FILES MUST BE ON D: DRIVE - NEVER C: DRIVE**

| Item | Path |
|------|------|
| **Working Location** | `D:\Cursor\TheGenie.ai\` |
| **GitHub Location** | `D:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\` |
| **Source Code** | `D:\Cursor\_SourceCode\` |

**RULE:** NEVER, EVER save files to C: drive.

---

## 🏗️ ROOT STRUCTURE

```
D:\Cursor\TheGenie.ai\
├── MASTER_INDEX_v1.md                    ← START HERE (master reference)
├── PERMANENT_DIRECTORY_STRUCTURE_v2.md    ← This file
├── MemoryLogs\                            ← Session memory logs (working location)
│   └── WORKSPACE_MEMORY_LOG_*.md
├── Development\                           ← Feature development
│   ├── CompetitionCommand\
│   ├── ListingCommand\
│   ├── NurtureEngine\
│   ├── LeadCustody\
│   ├── Integrations\                      ← Third-party service integrations (NEW)
│   │   ├── Dropbox\
│   │   ├── Asana\
│   │   ├── WHMCS\
│   │   ├── AWS\
│   │   ├── GoogleDrive\
│   │   ├── Intercom\
│   │   └── iCloud\
│   └── [Other Features]\
├── Operations\                             ← Operational documents
│   ├── Reports\
│   ├── Scripts\
│   ├── SOPs\
│   └── Specs\
└── APPROVED\                               ← Finalized deliverables
    ├── CompetitionCommand_KPI_Reports\
    └── LeadToListing_Reports\
```

---

## 🔌 INTEGRATIONS STRUCTURE (NEW in v2.0)

### Location
```
D:\Cursor\TheGenie.ai\Development\Integrations\
├── README_v1.md              ← Overview of all integrations
├── Dropbox\                  ← Dropbox API (file search)
├── Asana\                    ← Asana API (task management)
├── WHMCS\                    ← WHMCS API (billing)
├── AWS\                      ← Amazon Web Services
├── GoogleDrive\              ← Google Drive API
├── Intercom\                 ← Intercom API (support)
└── iCloud\                   ← iCloud Drive access
```

### Standard Structure Per Integration
```
[IntegrationName]\
├── README_v1.md           ← Overview and status
├── CREDENTIALS_v1.md      ← Reference to secure credential storage
├── SETUP_v1.md            ← Setup instructions
├── Scripts\               ← Python/PowerShell scripts
└── Docs\                  ← API documentation, notes
```

### Credential Storage Rule
**All credentials stored in:** `G:\My Drive\Master_Credential_Tracker_v[N].md`
Integration folders contain **references only**, not actual secrets.

---

## 📝 MEMORY LOGS - PERMANENT STRUCTURE

### Working Location (Where Created)
```
D:\Cursor\TheGenie.ai\MemoryLogs\
└── WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md
```

**Purpose:** Temporary working location during session
**Action:** Files created here, then copied to GitHub

### Permanent Location (GitHub)
```
D:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\
└── WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md
```

**Purpose:** Permanent archive - ALL logs must be here
**Action:** Copy from working location, commit to GitHub

### GitHub Remote
```
https://github.com/1ppTheGenie/NOTION/tree/main/TheGenie.ai/MemoryLogs
```

**Purpose:** Online repository (PRIMARY documentation system)
**Action:** Push commits to main branch

---

## 📁 DEVELOPMENT STRUCTURE

### Feature Development
```
D:\Cursor\TheGenie.ai\Development\
├── [FeatureName]\
│   ├── Discovery\          ← Discovery documents, analysis
│   ├── Design\             ← Wireframes, ERDs, architecture
│   ├── Specs\              ← Feature specs, dev specs
│   ├── Scripts\            ← SQL, Python, automation
│   └── SOPs\               ← Standard operating procedures
```

**Examples:**
- `Development\CompetitionCommand\`
- `Development\NurtureEngine\`
- `Development\LeadCustody\`
- `Development\Integrations\` ← NEW

### Naming Conventions

**Feature Requests:**
```
FR-[###]_[FeatureName]_[Type]_v[N].md
```
- Example: `FR-001_AreaOwnership_DevSpec_v2.md`

**Specifications:**
```
SPEC_[FeatureName]_[ReportName]_v[N].md
```
- Example: `SPEC_CompCommand_MonthlyCostReport_v3.md`

**SOPs:**
```
SOP_[FeatureName]_[ProcessName]_v[N].md
```
- Example: `SOP_CC_Monthly_Cost_Report_v2.md`

---

## 📊 OPERATIONS STRUCTURE

### Reports
```
D:\Cursor\TheGenie.ai\Operations\Reports\
├── [ReportCategory]\
│   ├── Scripts\            ← Python scripts
│   ├── Output\             ← CSV, Excel outputs
│   └── Archive\             ← Historical reports
```

**Examples:**
- `Operations\Reports\CompetitionCommand\`
- `Operations\Reports\LeadToListing\`
- `Operations\Reports\Twilio\`

### Scripts
```
D:\Cursor\TheGenie.ai\Operations\Scripts\
└── [ScriptName]_v[N].py
```

### SOPs
```
D:\Cursor\TheGenie.ai\Operations\SOPs\
└── SOP_[ProcessName]_v[N].md
```

---

## ✅ APPROVED STRUCTURE

### Finalized Deliverables
```
D:\Cursor\TheGenie.ai\APPROVED\
├── [ProjectName]\
│   ├── Scripts\             ← Final production scripts
│   ├── SOPs\               ← Final SOPs
│   ├── Reports\             ← Sample/archive reports
│   └── ROADMAP_*.md         ← Project roadmaps
```

**Examples:**
- `APPROVED\CompetitionCommand_KPI_Reports\`
- `APPROVED\LeadToListing_Reports\`

**Rule:** Only FINAL, approved versions go here. Working versions stay in Development.

---

## 🔄 GITHUB STRUCTURE (PRIMARY)

### Repository Location
```
D:\Cursor\_ARCHIVE_Downloads\NOTION\
└── TheGenie.ai\
    ├── MemoryLogs\           ← ALL memory logs (permanent)
    ├── Development\          ← Feature development
    │   └── Integrations\     ← Third-party integrations (NEW)
    ├── Operations\           ← Operations docs
    └── APPROVED\             ← Finalized deliverables
```

### GitHub Remote
```
https://github.com/1ppTheGenie/NOTION
```

**Branch:** `main`
**Status:** PRIMARY documentation system (NOT Notion)

### Commit Process
1. Copy files to GitHub structure (maintain hierarchy)
2. `cd D:\Cursor\_ARCHIVE_Downloads\NOTION`
3. `git add TheGenie.ai/Development/Integrations/` (add specific paths, NOT -A)
4. `git commit -m "Descriptive message with date"`
5. `git push origin main`

---

## 🗂️ OTHER KEY LOCATIONS

### Sandbox Configuration
```
D:\Cursor\_ARCHIVE_Downloads\sandbox_configs\
├── env.sandbox.txt
├── Web.Sandbox.config
└── start-sandbox.ps1
```

### Master Documentation
```
G:\My Drive\
├── Master_Credential_Tracker_v3.md
└── [Other master files]
```

### Technical Reference
```
TheGenie.ai.Database\GenieCursor\SOP Documentations\
└── WORKSPACE_MEMORY_v2.md
```

### Source Code
```
D:\Cursor\_SourceCode\
├── Genie.Source.Code_v1\
└── GenieCLOUD_v1\
```

---

## 📋 FILE NAMING RULES

### Memory Logs
```
WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md
```
- Topic: Short descriptive name (e.g., "AreaOwnership", "CCReports")
- Date: YYYY-MM-DD format
- Example: `WORKSPACE_MEMORY_LOG_NurtureEngine_Discovery_2025-12-15.md`

### Feature Requests
```
FR-[###]_[FeatureName]_[Type]_v[N].md
```
- ###: 3-digit number (001, 002, etc.)
- Type: DesignBrief, DevSpec, DiscoveryWorksheet, etc.
- Example: `FR-001_AreaOwnership_DevSpec_v2.md`

### Specifications
```
SPEC_[FeatureName]_[ReportName]_v[N].md
```
- Example: `SPEC_CompCommand_MonthlyCostReport_v3.md`

### SOPs
```
SOP_[FeatureName]_[ProcessName]_v[N].md
```
- Example: `SOP_CC_Monthly_Cost_Report_v2.md`

### Scripts
```
[script_name]_v[N].py
```
- Example: `build_cc_monthly_report_v3.py`

### Reports
```
[Client]_[ReportName]_[Date]_v[N].[ext]
```
- Example: `Genie_CC_MonthlyCost_11-2025_v5.csv`

---

## 🚨 CRITICAL RULES

### 1. NEVER Save to C: Drive
- ALL files must be on D: drive
- C: drive is TABOO
- Check paths before every save

### 2. Never Overwrite Files
- Always increment version numbers
- Check for existing versions before saving

### 3. GitHub is PRIMARY
- All documentation must be in GitHub
- NOT Notion (deprecated)
- Commit after every session

### 4. Memory Logs Workflow
- Create in: `D:\Cursor\TheGenie.ai\MemoryLogs\`
- Copy to: `D:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\`
- Commit to GitHub
- Update MASTER_INDEX

### 5. Directory Structure is Permanent
- Do NOT create new top-level folders without approval
- Follow existing patterns
- Document changes in MASTER_INDEX

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/15/2025 | Initial permanent structure document created |
| 2.0 | 12/22/2025 | **MAJOR UPDATE:** (1) Changed all paths from C: to D: drive. (2) Added Integrations folder under Development with sub-folders: Dropbox, Asana, WHMCS, AWS, GoogleDrive, Intercom, iCloud. (3) Added critical rule: NEVER save to C: drive. (4) Updated credential tracker reference to v3. |

---

**This structure is PERMANENT. Do not modify without updating this document and MASTER_INDEX.**

*Last Updated: 12/22/2025*

