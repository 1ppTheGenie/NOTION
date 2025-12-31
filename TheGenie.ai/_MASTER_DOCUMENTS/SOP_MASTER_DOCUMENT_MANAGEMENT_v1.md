# SOP: Master Document Management
**Version:** 1.0  
**Created:** 12/31/2025  
**Last Updated:** 12/31/2025  
**Author:** Cursor AI Agent  
**Status:** ACTIVE - Follow this SOP for all master document updates

---

## 🎯 PURPOSE

This Standard Operating Procedure defines the unified system for managing Master Index, Project Universe Dashboard, and Master Rules documents across all TheGenie.ai development projects.

**Goals:**
1. Single source of truth for each master document
2. Clear update process with version control
3. Automated sync between local and GitHub
4. No more version drift or path inconsistencies

---

## 📁 UNIFIED LOCATION STRUCTURE

### Source of Truth (Local Development)

All master documents live in ONE location:

```
D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\
├── GLOBAL_MASTER_INDEX.md              ← The ONE master index
├── GLOBAL_MASTER_RULES.md              ← The ONE set of global rules
├── PROJECT_UNIVERSE_DASHBOARD.html     ← The ONE dashboard
├── MASTER_DOCUMENT_INVENTORY_v1.md     ← Inventory of all versions
├── SOP_MASTER_DOCUMENT_MANAGEMENT_v1.md ← This SOP
└── MIGRATION_PLAN_v1.md                ← Migration plan
```

### GitHub Mirror

Exact copy of source, synced after every update:

```
D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS\
└── (mirrors local folder exactly)
```

### Naming Convention

**Current Version Files (no version number):**
- `GLOBAL_MASTER_INDEX.md` (not `v1`, `v2`, etc.)
- `PROJECT_UNIVERSE_DASHBOARD.html`
- `GLOBAL_MASTER_RULES.md`

**Why?** Single file that's always current. No confusion about which version is latest.

**Versioned Backups:**
- When making major changes, create backup: `GLOBAL_MASTER_INDEX_BACKUP_2025-12-31.md`
- Internal version number tracks changes in Change Log

---

## 🔄 UPDATE PROCESS

### Step 1: Locate the Document

All master documents are in:
```
D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\
```

### Step 2: Make Your Edits

1. Open the document from `_MASTER_DOCUMENTS` folder
2. Make your changes
3. **Always update:**
   - "Last Updated" date in header
   - "Version" number in header
   - Add entry to Change Log at bottom

### Step 3: Version Numbering

| Change Type | Version Increment | Example |
|-------------|-------------------|---------|
| Minor fixes, typos, formatting | +0.1 | 2.3 → 2.4 |
| New sections, significant updates | +1.0 | 2.4 → 3.0 |
| Complete rewrite | +1.0 (major) | 3.0 → 4.0 |

### Step 4: Sync to GitHub (REQUIRED)

After EVERY update, sync to GitHub:

```powershell
# Navigate to NOTION folder
cd D:\Cursor\_SourceCode\NOTION

# Copy updated file(s) to mirror
Copy-Item "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\GLOBAL_MASTER_INDEX.md" `
          "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS\GLOBAL_MASTER_INDEX.md" -Force

# Commit and push
git add TheGenie.ai/_MASTER_DOCUMENTS/
git commit -m "Update GLOBAL_MASTER_INDEX to v[VERSION] - [brief description]"
git push origin main
```

### Step 5: Verify Sync

1. Check GitHub web: https://github.com/1ppTheGenie/NOTION
2. Verify file shows updated content
3. Verify "Last Updated" date matches local

---

## 📋 DOCUMENT-SPECIFIC GUIDELINES

### GLOBAL_MASTER_INDEX.md

**Purpose:** Central reference for all project documents, locations, and resources

**When to Update:**
- New project added
- New folder structure created
- Key document created/moved
- Credential tracker version changes
- External resource URLs change

**Required Sections:**
- Version Information (header)
- Purpose
- Key Locations
- Project Sections (one per project)
- External Resources
- Change Log

**Template:**
```markdown
# Global Master Index for TheGenie.ai
**Version:** X.Y  
**Created:** MM/DD/YYYY  
**Last Updated:** MM/DD/YYYY  
**Author:** [Name]  
**Status:** Active

---

## 🎯 PURPOSE
[Brief purpose statement]

---

## 📁 KEY LOCATIONS
[Table of critical paths]

---

## 🏢 [PROJECT NAME] SECTION
[Project-specific documents and resources]

---

## 🔗 EXTERNAL RESOURCES
[Credentials, dashboards, databases]

---

## 🔄 CHANGE LOG
| Version | Date | Changes |
|---------|------|---------|
| X.Y | MM/DD/YYYY | [What changed] |
```

### PROJECT_UNIVERSE_DASHBOARD.html

**Purpose:** Visual dashboard for all development projects

**When to Update:**
- New project added
- Project status changes
- New memory logs added
- Milestones completed
- Key documents added

**Required Updates:**
1. Update header "Last Updated" date and version
2. Update footer with same info
3. Add/modify project sections
4. Keep memory log tables current

**Update Process:**
1. Edit HTML file directly
2. Test in browser (open file:// path)
3. Verify all links work (especially `target="_blank"`)
4. Sync to GitHub

### GLOBAL_MASTER_RULES.md

**Purpose:** Universal rules that apply to ALL TheGenie.ai projects

**When to Update:**
- New rule established
- Rule clarified or modified
- Project-specific rule promoted to global

**Rule Categories:**
1. File Versioning Rules
2. Documentation Rules
3. Data Quality Rules
4. Link Behavior Rules
5. Database Rules

**Project-Specific Rules:**
- Remain in project folders (e.g., `Paisley/MASTER_RULES_v1.md`)
- Must NOT conflict with global rules
- Can ADD to global rules, not override

---

## 🚨 CRITICAL REQUIREMENTS

### NEVER Do These:

1. ❌ **NEVER edit documents in the GitHub clone folder**
   - Always edit in `D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\`
   - Then sync to GitHub clone

2. ❌ **NEVER forget to update Change Log**
   - Every edit MUST have a Change Log entry
   - Date + version + what changed

3. ❌ **NEVER leave version drift**
   - Sync to GitHub SAME DAY as edit
   - Do not let local get ahead of GitHub

4. ❌ **NEVER use C: drive paths**
   - All paths must be D: drive
   - If you see C: path, fix it immediately

5. ❌ **NEVER create duplicate master documents**
   - ONE master index, ONE dashboard, ONE global rules
   - Project-specific docs are ADDITIONS, not replacements

### ALWAYS Do These:

1. ✅ **ALWAYS check Change Log before editing**
   - Know what the current version is
   - Know what changed recently

2. ✅ **ALWAYS test HTML in browser before committing**
   - Open in Chrome/Edge
   - Verify links work
   - Verify formatting correct

3. ✅ **ALWAYS use MM/DD/YYYY date format**
   - Consistent across all documents
   - In header, change log, and content

4. ✅ **ALWAYS sync immediately after edit**
   - Don't wait until end of session
   - Sync right after saving

---

## 🔧 QUICK REFERENCE COMMANDS

### Find Master Documents
```powershell
# List master documents
Get-ChildItem "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\"
```

### Sync to GitHub
```powershell
# Quick sync script
cd D:\Cursor\_SourceCode\NOTION

# Copy all master docs
Copy-Item "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\*" `
          "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS\" -Recurse -Force

# Commit
git add TheGenie.ai/_MASTER_DOCUMENTS/
git commit -m "Sync master documents - $(Get-Date -Format 'yyyy-MM-dd')"
git push origin main
```

### Check Version Status
```powershell
# Compare local vs GitHub versions
$localFile = Get-Content "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\GLOBAL_MASTER_INDEX.md" | Select-Object -First 5
$gitFile = Get-Content "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS\GLOBAL_MASTER_INDEX.md" | Select-Object -First 5

Write-Host "Local:" $localFile
Write-Host "GitHub:" $gitFile
```

---

## 📊 AUDIT CHECKLIST

Use this checklist weekly to verify document health:

### Master Index
- [ ] Version in header matches Change Log
- [ ] Last Updated date is accurate
- [ ] All project sections are current
- [ ] All file paths are correct (D: drive)
- [ ] External resources are accessible
- [ ] GitHub version matches local

### Project Universe Dashboard
- [ ] Version in header and footer match
- [ ] Last Updated date is accurate
- [ ] All project status badges are current
- [ ] All links have `target="_blank"`
- [ ] Memory log tables are up to date
- [ ] GitHub version matches local

### Global Rules
- [ ] No conflicting rules across projects
- [ ] All rules have examples
- [ ] Project-specific rules link to global
- [ ] GitHub version matches local

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/31/2025 | Initial SOP - unified location structure, update process, sync workflow, critical requirements, audit checklist |

---

*File: SOP_MASTER_DOCUMENT_MANAGEMENT_v1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\MLS_Parsers\*

**Next Step:** Execute the Migration Plan to consolidate existing documents.

