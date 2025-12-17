# PERMANENT DIRECTORY STRUCTURE - TheGenie.ai
**This Structure is PERMANENT - Do Not Change Without Approval**

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Status** | PERMANENT - Reference in all sessions |

---

## 🏗️ ROOT STRUCTURE

```
C:\Cursor\TheGenie.ai\
├── MASTER_INDEX_v1.md                    ← START HERE (master reference)
├── PERMANENT_DIRECTORY_STRUCTURE_v1.md    ← This file
├── MemoryLogs\                            ← Session memory logs (working location)
│   └── WORKSPACE_MEMORY_LOG_*.md
├── Development\                           ← Feature development
│   ├── CompetitionCommand\
│   ├── ListingCommand\
│   ├── NurtureEngine\
│   ├── LeadCustody\
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

## 📝 MEMORY LOGS - PERMANENT STRUCTURE

### Working Location (Where Created)
```
C:\Cursor\TheGenie.ai\MemoryLogs\
└── WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md
```

**Purpose:** Temporary working location during session
**Action:** Files created here, then copied to GitHub

### Permanent Location (GitHub)
```
C:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\
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
C:\Cursor\TheGenie.ai\Development\
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
C:\Cursor\TheGenie.ai\Operations\Reports\
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
C:\Cursor\TheGenie.ai\Operations\Scripts\
└── [ScriptName]_v[N].py
```

### SOPs
```
C:\Cursor\TheGenie.ai\Operations\SOPs\
└── SOP_[ProcessName]_v[N].md
```

---

## ✅ APPROVED STRUCTURE

### Finalized Deliverables
```
C:\Cursor\TheGenie.ai\APPROVED\
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
C:\Cursor\_ARCHIVE_Downloads\NOTION\
└── TheGenie.ai\
    ├── MemoryLogs\           ← ALL memory logs (permanent)
    ├── Development\          ← Feature development
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
2. `cd c:\Cursor\_ARCHIVE_Downloads\NOTION`
3. `git add -A`
4. `git commit -m "Descriptive message with date"`
5. `git push origin main`

---

## 🗂️ OTHER KEY LOCATIONS

### Sandbox Configuration
```
C:\Cursor\_ARCHIVE_Downloads\sandbox_configs\
├── env.sandbox.txt
├── Web.Sandbox.config
└── start-sandbox.ps1
```

### Master Documentation
```
G:\My Drive\
├── Master_Credential_Tracker_v2.md
└── [Other master files]
```

### Technical Reference
```
TheGenie.ai.Database\GenieCursor\SOP Documentations\
└── WORKSPACE_MEMORY_v2.md
```

### Source Code
```
C:\Cursor\_SourceCode\
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

### 1. Never Overwrite Files
- Always increment version numbers
- Check for existing versions before saving

### 2. GitHub is PRIMARY
- All documentation must be in GitHub
- NOT Notion (deprecated)
- Commit after every session

### 3. Memory Logs Workflow
- Create in: `C:\Cursor\TheGenie.ai\MemoryLogs\`
- Copy to: `C:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\`
- Commit to GitHub
- Update MASTER_INDEX

### 4. Directory Structure is Permanent
- Do NOT create new top-level folders without approval
- Follow existing patterns
- Document changes in MASTER_INDEX

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/15/2025 | Initial permanent structure document created |

---

**This structure is PERMANENT. Do not modify without updating this document and MASTER_INDEX.**

*Last Updated: 12/15/2025*

