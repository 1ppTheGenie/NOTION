# Master Document Inventory
**Version:** 1.0  
**Created:** 12/31/2025  
**Last Updated:** 12/31/2025  
**Author:** Cursor AI Agent  
**Purpose:** Complete inventory of all master documents across local and GitHub locations

---

## 🎯 EXECUTIVE SUMMARY

This inventory documents all master documents across TheGenie.ai development projects. **Critical finding:** Documents are scattered across multiple locations with version drift and no sync process.

**Key Issues Identified:**
1. ❌ **No Single Source of Truth** - Files exist in multiple locations
2. ❌ **Version Drift** - Local versions are newer than GitHub versions
3. ❌ **Path Inconsistency** - Some files still reference C: drive (should be D:)
4. ❌ **Naming Confusion** - File names don't match internal version numbers
5. ❌ **No Sync Process** - No SOP for keeping local and GitHub in sync

---

## 📊 MASTER INDEX INVENTORY

### All Locations Found

| Location | File | Internal Version | Last Updated | Status |
|----------|------|------------------|--------------|--------|
| `D:\Cursor\TheGenie.ai\Development\Paisley\` | `MASTER_INDEX_v3.md` | v3.0 | 12/30/2025 | ✅ **LATEST** |
| `D:\Cursor\TheGenie.ai\Development\Paisley\` | `MASTER_INDEX_v1.md` | v2.0 | 12/30/2025 | ⚠️ Misnamed (says v2.0 inside) |
| `D:\Cursor\_SourceCode\NOTION\TheGenie.ai\` | `MASTER_INDEX_v2.md` | v2.0 | 12/22/2025 | ⚠️ Outdated (8 days behind) |
| `D:\Cursor\_SourceCode\NOTION\TheGenie.ai\` | `MASTER_INDEX_v1.md` | v1.0 | 12/15/2025 | ⚠️ OLD - Points to C: drive! |
| `D:\Cursor\_SourceCode\stage.geniecloud\` | `GENIECLOUD_ASSET_MASTER_INDEX_v1.html` | N/A | N/A | 🔄 Different purpose (asset catalog) |

### Version Comparison

| Feature | Paisley v3.0 (Local Latest) | NOTION v2.0 (GitHub) | NOTION v1.0 (GitHub Oldest) |
|---------|----------------------------|----------------------|------------------------------|
| PLS RESO Engine Section | ✅ Yes | ❌ No | ❌ No |
| DevOps Ecosystem Section | ✅ Yes | ❌ No | ❌ No |
| Credential Tracker Version | v4 | v4 | v2 |
| Drive Path | D:\ | D:\ | ❌ C:\ (WRONG) |
| MLS Data Discovery | ✅ Yes | ❌ No | ❌ No |
| Memory Log Catalog | ✅ Extensive | ✅ Yes | ✅ Basic |

### Recommended Source of Truth

**`D:\Cursor\TheGenie.ai\Development\Paisley\MASTER_INDEX_v3.md`** (v3.0)

Reasons:
- Most current (12/30/2025)
- Contains all project sections (PLS RESO, DevOps, Paisley)
- Uses correct D:\ drive paths
- References latest credential tracker (v4)

---

## 📊 PROJECT UNIVERSE DASHBOARD INVENTORY

### All Locations Found

| Location | File | Internal Version | Last Updated | Status |
|----------|------|------------------|--------------|--------|
| `D:\Cursor\TheGenie.ai\Development\` | `PROJECT_UNIVERSE_DASHBOARD_v2.html` | v4.4 | 12/30/2025 | ✅ **LATEST** |
| `D:\Cursor\TheGenie.ai\Development\` | `PROJECT_UNIVERSE_DASHBOARD_v1.html` | (older) | (older) | ⚠️ Superseded |
| `D:\Cursor\_SourceCode\NOTION\ProjectUniverse\` | `PROJECT_UNIVERSE_DASHBOARD_v2.html` | v4.3 | 12/28/2025 | ⚠️ Outdated (2 days behind) |
| `D:\Cursor\_SourceCode\NOTION\TheGenie.ai\Development\` | `PROJECT_UNIVERSE_DASHBOARD_v1.html` | (older) | (older) | ⚠️ Superseded |
| `D:\Cursor\_SourceCode\stage.geniecloud\` | `PROJECT_UNIVERSE_DASHBOARD.html` | N/A | N/A | 🔄 Different location |

### Version Comparison

| Feature | Local v2 (v4.4) | NOTION v2 (v4.3) |
|---------|----------------|------------------|
| Paisley RESO Engine Section | ✅ Yes | ❌ No |
| Memory Logs Section | ✅ Expanded | ✅ Yes |
| Billing Systems | ✅ Yes | ✅ Yes |
| Credentials Section | ✅ Yes | ✅ Yes |

### Recommended Source of Truth

**`D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v2.html`** (v4.4)

Reasons:
- Most current (12/30/2025)
- Contains Paisley RESO Engine section
- Is the actively maintained version

---

## 📊 MASTER RULES INVENTORY

### All Locations Found

| Location | File | Internal Version | Last Updated | Scope |
|----------|------|------------------|--------------|-------|
| `D:\Cursor\TheGenie.ai\Development\Paisley\` | `MASTER_RULES_v1.md` | v1.0/1.1 | 12/23/2025 | 🔧 Project-specific (Paisley) |
| `D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Docs\` | `MASTER_RULES_SubscriptionDisputes_v1.md` | v1.0 | N/A | 🔧 Domain-specific (Billing) |
| `D:\Cursor\_SourceCode\NOTION\TheGenie.ai\Development\BillingSystems\ChargebackDispute\Docs\` | `MASTER_RULES_SubscriptionDisputes_v1.md` | v1.0 | N/A | 🔧 Domain-specific (Billing) |

### Key Rules Found

From `Paisley\MASTER_RULES_v1.md`:
1. **File Versioning** - NEVER overwrite files, always version
2. **No Assumptions** - If unclear, STOP and ASK
3. **No Placeholders** - All data must be real
4. **Links Open External** - Use `target="_blank"`
5. **Date Format** - MM/DD/YYYY
6. **Document Requirements** - Version, Created, Updated, Author, Change Log

### Observation

**No GLOBAL Master Rules file exists!** - Only project-specific rules. Need to create a unified global rules document.

---

## 🔗 REFERENCE MAP

### Documents That Reference MASTER_INDEX

| Referencing Document | Location | Which Version Referenced |
|---------------------|----------|--------------------------|
| WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Study_Session_2025-12-17 | Paisley/ & NOTION/ | v1 (outdated C: path) |
| WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Discovery_2025-12-18_v1 | Paisley/ & NOTION/ | v1 (outdated C: path) |
| WORKSPACE_MEMORY_LOG_TitleGenie_Paisley_Discovery_Session_2025-12-19_v2 | Paisley/ & NOTION/ | Mixed |
| PAISLEY_CONSOLIDATION_PLAN_v1.md | Paisley/Paisley2.0/ | v1 |
| PAISLEY_PROJECT_INVENTORY_v1.md | Paisley/Paisley2.0/ | v1 |
| PERMANENT_DIRECTORY_STRUCTURE_v1.md | NOTION/ | v1 |
| PERMANENT_DIRECTORY_STRUCTURE_v2.md | NOTION/ | v1/v2 |
| MASTER_RULE_MEMORY_LOGS_v1.md | NOTION/ | v1 |
| MASTER_RULE_GITHUB_CLEAN_v1.md | NOTION/ | v1 |
| AGENT_GUIDE_Everything_Already_Setup_v1.md | NOTION/ | v1 |

### Documents That Reference PROJECT_UNIVERSE_DASHBOARD

| Referencing Document | Location | Which Version Referenced |
|---------------------|----------|--------------------------|
| MASTER_INDEX_v3.md | Paisley/ | v2.html (correct) |
| MASTER_INDEX_v1.md | Paisley/ | v1.html (outdated) |
| PLS_Workspace_Memory_Log_12-28-2025_v1.md | PLS/Docs/ | v2.html |
| WORKSPACE_CONTEXT_12-28-2025_v1.md | PLS/Discovery/ | v2.html |
| MOVE_ON_PROMPT_NEXT_SESSION_v1.txt | PLS/Discovery/ | v2.html |

---

## 🚨 CRITICAL ISSUES

### Issue 1: PATH INCONSISTENCY
**Problem:** NOTION's `MASTER_INDEX_v1.md` still points to `C:\Cursor\` instead of `D:\Cursor\`
**Impact:** Anyone following this index will get wrong paths
**Solution:** Delete v1 from NOTION or update to point to D: drive

### Issue 2: VERSION DRIFT
**Problem:** Local dashboards are 2+ days ahead of GitHub versions
**Impact:** GitHub users see outdated information
**Solution:** Implement immediate sync workflow after every update

### Issue 3: NAMING CONFUSION
**Problem:** `MASTER_INDEX_v1.md` in Paisley folder contains "Version: 2.0" internally
**Impact:** Confuses which version is actually current
**Solution:** Rename file to match internal version OR standardize that filename version = major version only

### Issue 4: NO GLOBAL RULES
**Problem:** Only project-specific rules exist (Paisley, Billing)
**Impact:** Inconsistent rules across projects
**Solution:** Create `GLOBAL_MASTER_RULES_v1.md` that all projects inherit

### Issue 5: DUAL LOCATIONS
**Problem:** Master documents exist in both:
- `D:\Cursor\TheGenie.ai\Development\` (active development)
- `D:\Cursor\_SourceCode\NOTION\` (GitHub clone)
**Impact:** Must manually keep both in sync
**Solution:** Define ONE as source, other as mirror with automated sync

---

## 📁 RECOMMENDED UNIFIED STRUCTURE

### Proposed Source of Truth Location

```
D:\Cursor\TheGenie.ai\Development\
├── _MASTER_DOCUMENTS/              ← NEW FOLDER - Single source of truth
│   ├── GLOBAL_MASTER_INDEX_v1.md          ← Unified master index
│   ├── GLOBAL_MASTER_RULES_v1.md          ← Unified rules (inherits all)
│   ├── PROJECT_UNIVERSE_DASHBOARD_v3.html ← Latest dashboard
│   └── SOP_MASTER_DOCUMENT_MANAGEMENT_v1.md ← This SOP
│
├── Paisley/                        ← Project-specific
│   ├── MASTER_INDEX_v3.md          ← DEPRECATED - Points to global
│   └── MASTER_RULES_v1.md          ← Project additions only
│
├── BillingSystems/                 ← Project-specific
│   └── MASTER_RULES_SubscriptionDisputes_v1.md ← Domain additions
│
└── MLS_Parsers/                    ← Project-specific
    └── PLS_RESO_ENGINE/
```

### GitHub Mirror

```
D:\Cursor\_SourceCode\NOTION\TheGenie.ai\
├── _MASTER_DOCUMENTS/              ← Mirror of source (synced)
│   ├── GLOBAL_MASTER_INDEX_v1.md
│   ├── GLOBAL_MASTER_RULES_v1.md
│   ├── PROJECT_UNIVERSE_DASHBOARD_v3.html
│   └── SOP_MASTER_DOCUMENT_MANAGEMENT_v1.md
│
└── (other folders remain as-is)
```

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/31/2025 | Initial inventory - discovered 5+ MASTER_INDEX versions, 4+ Dashboard versions, version drift issues, path inconsistencies, no sync process |

---

*File: MASTER_DOCUMENT_INVENTORY_v1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\MLS_Parsers\*

