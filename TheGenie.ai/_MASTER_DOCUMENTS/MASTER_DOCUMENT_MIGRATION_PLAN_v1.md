# Master Document Migration Plan
**Version:** 1.0  
**Created:** 12/31/2025  
**Last Updated:** 12/31/2025  
**Author:** Cursor AI Agent  
**Purpose:** Step-by-step plan to consolidate master documents into unified structure

---

## 🎯 MIGRATION OBJECTIVE

Consolidate all scattered master documents into a single source of truth location with proper sync to GitHub.

**Current State:**
- 5+ Master Index versions across 2 locations
- 4+ Dashboard versions across 3 locations
- No global rules (only project-specific)
- Version drift between local and GitHub
- Path inconsistencies (C: vs D:)

**Target State:**
- 1 Master Index in `_MASTER_DOCUMENTS/`
- 1 Dashboard in `_MASTER_DOCUMENTS/`
- 1 Global Rules in `_MASTER_DOCUMENTS/`
- Sync process documented and followed
- All old versions archived

---

## 📋 PRE-MIGRATION CHECKLIST

Before starting migration:

- [ ] Backup all existing master documents
- [ ] Create `_MASTER_DOCUMENTS` folder
- [ ] Notify team of upcoming changes
- [ ] Schedule 30-minute window for migration

---

## 🔧 MIGRATION STEPS

### Phase 1: Create Target Structure (5 minutes)

#### Step 1.1: Create _MASTER_DOCUMENTS Folder

```powershell
# Create the unified folder
New-Item -ItemType Directory -Path "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS" -Force

# Create mirror in GitHub clone
New-Item -ItemType Directory -Path "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS" -Force
```

#### Step 1.2: Create Archive Folder

```powershell
# Create archive for old versions
New-Item -ItemType Directory -Path "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\_ARCHIVE" -Force
```

---

### Phase 2: Consolidate Master Index (10 minutes)

#### Step 2.1: Identify Source Document

**Use:** `D:\Cursor\TheGenie.ai\Development\Paisley\MASTER_INDEX_v3.md` (v3.0, most current)

#### Step 2.2: Create Unified Master Index

```powershell
# Copy the latest version as the new unified index
Copy-Item "D:\Cursor\TheGenie.ai\Development\Paisley\MASTER_INDEX_v3.md" `
          "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\GLOBAL_MASTER_INDEX.md" -Force
```

#### Step 2.3: Update the New Index

Edit `GLOBAL_MASTER_INDEX.md`:
1. Change title to "Global Master Index for TheGenie.ai"
2. Update "Location" at bottom to `_MASTER_DOCUMENTS\`
3. Add reference to this migration
4. Increment version to v4.0 (new unified version)
5. Update Last Updated date

#### Step 2.4: Archive Old Versions

```powershell
# Move old versions to archive
Move-Item "D:\Cursor\TheGenie.ai\Development\Paisley\MASTER_INDEX_v1.md" `
          "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\_ARCHIVE\MASTER_INDEX_v1_ARCHIVED_2025-12-31.md"

Move-Item "D:\Cursor\TheGenie.ai\Development\Paisley\MASTER_INDEX_v3.md" `
          "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\_ARCHIVE\MASTER_INDEX_v3_ARCHIVED_2025-12-31.md"
```

---

### Phase 3: Consolidate Dashboard (10 minutes)

#### Step 3.1: Identify Source Document

**Use:** `D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v2.html` (v4.4, most current)

#### Step 3.2: Create Unified Dashboard

```powershell
# Copy the latest version as the new unified dashboard
Copy-Item "D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v2.html" `
          "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\PROJECT_UNIVERSE_DASHBOARD.html" -Force
```

#### Step 3.3: Update the New Dashboard

Edit `PROJECT_UNIVERSE_DASHBOARD.html`:
1. Update header version to v5.0 (new unified version)
2. Update footer version and location path
3. Add note about migration in a comment
4. Update Last Updated date

#### Step 3.4: Archive Old Versions

```powershell
# Move old versions to archive
Move-Item "D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v1.html" `
          "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\_ARCHIVE\PROJECT_UNIVERSE_DASHBOARD_v1_ARCHIVED_2025-12-31.html"

Move-Item "D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v2.html" `
          "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\_ARCHIVE\PROJECT_UNIVERSE_DASHBOARD_v2_ARCHIVED_2025-12-31.html"
```

---

### Phase 4: Create Global Rules (10 minutes)

#### Step 4.1: Create New Global Rules Document

Create `GLOBAL_MASTER_RULES.md` by merging:
- `Paisley\MASTER_RULES_v1.md` (base)
- User rules from Cursor
- Any other project rules

#### Step 4.2: Content for Global Rules

```markdown
# Global Master Rules for TheGenie.ai
**Version:** 1.0  
**Created:** 12/31/2025  
**Last Updated:** 12/31/2025  
**Author:** Cursor AI Agent  
**Status:** ACTIVE - These rules apply to ALL projects

---

## 🎯 SCOPE

These rules apply to ALL TheGenie.ai development projects. Project-specific rules may ADD to these but not OVERRIDE them.

---

## 📋 RULE 1: FILE VERSIONING

**NEVER OVERWRITE FILES** - Always use versioning
- Save edited files with new version number (v1, v2, v3...)
- Never edit and save as same filename
- Always preserve previous versions

**Version Increment:**
- Minor changes: +0.1 (e.g., v1.0 → v1.1)
- Major changes: +1.0 (e.g., v1.1 → v2.0)

---

## 📋 RULE 2: NO ASSUMPTIONS

If unclear, **STOP and ASK**
- Never assume requirements
- Always confirm before proceeding
- Ask clarifying questions

---

## 📋 RULE 3: NO PLACEHOLDERS

All data must be **REAL or CONFIRMED**
- Never use "[TBD]" or "[TODO]" in deliverables
- Never use placeholder text
- All data must be verified

---

## 📋 RULE 4: DOCUMENT REQUIREMENTS

Every document must include:
- Version number at top
- Created date (MM/DD/YYYY)
- Last Updated date (MM/DD/YYYY)
- Author name
- Change Log at bottom

---

## 📋 RULE 5: DATE FORMAT

Master date format: **MM/DD/YYYY**
- Use consistently everywhere
- No exceptions

---

## 📋 RULE 6: DRIVE LOCATION

**ALL FILES ON D: DRIVE - NEVER C:**
- D:\Cursor\TheGenie.ai\ is the root
- C: drive is TABOO

---

## 📋 RULE 7: LINKS OPEN EXTERNAL

All links use `target="_blank"`
- HTML: `<a href="url" target="_blank">Text</a>`
- Opens in new tab/window
- No exceptions for HTML files

---

## 📋 RULE 8: GITHUB SYNC

Sync to GitHub after EVERY edit
- Never let local get ahead of GitHub
- Same-day sync required
- Follow SOP_MASTER_DOCUMENT_MANAGEMENT

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/31/2025 | Initial global rules - consolidated from Paisley rules and user rules |
```

---

### Phase 5: Sync to GitHub (5 minutes)

#### Step 5.1: Copy to GitHub Clone

```powershell
# Sync all master documents to GitHub clone
Copy-Item "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\*" `
          "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS\" -Recurse -Force
```

#### Step 5.2: Commit and Push

```powershell
cd D:\Cursor\_SourceCode\NOTION

git add TheGenie.ai/_MASTER_DOCUMENTS/
git commit -m "Migration: Unified master documents into _MASTER_DOCUMENTS folder - v1.0"
git push origin main
```

#### Step 5.3: Verify on GitHub

1. Visit https://github.com/1ppTheGenie/NOTION
2. Navigate to `TheGenie.ai/_MASTER_DOCUMENTS/`
3. Verify all files present with correct content

---

### Phase 6: Update References (5 minutes)

#### Step 6.1: Update Cursor Memories

After migration, update the Cursor memory for Master Index path:
- Old: `D:\Cursor\TheGenie.ai\Development\Paisley\MASTER_INDEX_v3.md`
- New: `D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\GLOBAL_MASTER_INDEX.md`

#### Step 6.2: Leave Redirect Notes

Create a redirect note in the old location:

```powershell
# Create redirect note in Paisley folder
$content = @"
# ⚠️ MASTER INDEX MOVED

The Master Index has been moved to:
**D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\GLOBAL_MASTER_INDEX.md**

This file is a redirect notice. Do not create new master index files here.

See: SOP_MASTER_DOCUMENT_MANAGEMENT_v1.md for details.
"@

$content | Out-File "D:\Cursor\TheGenie.ai\Development\Paisley\README_MASTER_INDEX_MOVED.md"
```

---

## ✅ POST-MIGRATION VERIFICATION

### Checklist

- [ ] `_MASTER_DOCUMENTS` folder exists at `D:\Cursor\TheGenie.ai\Development\`
- [ ] `GLOBAL_MASTER_INDEX.md` is present and current
- [ ] `PROJECT_UNIVERSE_DASHBOARD.html` is present and current
- [ ] `GLOBAL_MASTER_RULES.md` is present and current
- [ ] `_ARCHIVE` subfolder contains old versions
- [ ] GitHub clone has mirror of `_MASTER_DOCUMENTS`
- [ ] GitHub shows all files pushed
- [ ] Old locations have redirect notices
- [ ] Cursor memories updated

### Verification Commands

```powershell
# Verify local structure
Get-ChildItem "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS" -Recurse

# Verify GitHub clone
Get-ChildItem "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS" -Recurse

# Compare file counts
$local = (Get-ChildItem "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS" -File).Count
$github = (Get-ChildItem "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS" -File).Count
Write-Host "Local: $local files, GitHub: $github files"
```

---

## 🚨 ROLLBACK PLAN

If migration fails, rollback using archived files:

```powershell
# Restore from archive
Copy-Item "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\_ARCHIVE\MASTER_INDEX_v3_ARCHIVED_*.md" `
          "D:\Cursor\TheGenie.ai\Development\Paisley\MASTER_INDEX_v3.md" -Force

Copy-Item "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\_ARCHIVE\PROJECT_UNIVERSE_DASHBOARD_v2_ARCHIVED_*.html" `
          "D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v2.html" -Force
```

---

## 📅 TIMELINE

| Phase | Duration | Description |
|-------|----------|-------------|
| Phase 1 | 5 min | Create folder structure |
| Phase 2 | 10 min | Consolidate Master Index |
| Phase 3 | 10 min | Consolidate Dashboard |
| Phase 4 | 10 min | Create Global Rules |
| Phase 5 | 5 min | Sync to GitHub |
| Phase 6 | 5 min | Update references |
| Verification | 5 min | Verify everything works |
| **Total** | **50 min** | Complete migration |

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/31/2025 | Initial migration plan - 6 phases, detailed steps, rollback plan, timeline |

---

*File: MASTER_DOCUMENT_MIGRATION_PLAN_v1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\MLS_Parsers\*

**Ready to Execute:** Run phases 1-6 to complete migration.

