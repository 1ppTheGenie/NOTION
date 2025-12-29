# PLS Workspace Memory Log - December 28, 2025

**Version:** 1.0  
**Created:** 12/28/2025  
**Author:** Steve Hundley / Cursor AI  
**Session:** Late evening session - Documentation consolidation & Collection Manager prep

---

## SESSION SUMMARY

This session focused on **documentation consolidation** and **Master Rules compliance** before beginning the Collection Manager UI development.

---

## KEY ACCOMPLISHMENTS

### 1. Documentation Consolidation (2+1 Architecture)

Established the consolidated document architecture:

| Document | Purpose | Current Version |
|----------|---------|-----------------|
| **PLS_MASTER_SPECIFICATION** | PLS UI, database, features, phases | v3.0 |
| **GENIECLOUD_ASSET_DEVELOPMENT** | XSL, themes, rendering, QA | v1.0 |
| **CONTRACT_PLS_to_GenieCloud** (Bridge) | Data handshake between teams | v3.0 |

### 2. Bridge Doc v3.0 Additions

Added major new section: **Asset Selection System (HubAssetSetting)**

- Documents how orders get assigned to landing pages
- Key tables: `HubAssetSetting`, `HubAssetSettingOverride`
- Workflow → AssetMap → HubAssetSettingId flow
- SQL scripts for adding PLS landing pages
- Proposed UI for asset selection at checkout

### 3. CTA System Deep Dive

Completed analysis of Call-to-Action system:

- Identified components: `_LeadCtaTag.jsx`, `_LandingPages.jsx`, `utils.js`
- Documented `getCtaData()` function with 11 CTA types
- Mapped tagging system: `SoftOptIn`, `FollowNeighborhood`, etc.
- Proposed Tom Ferry "Soft First Touch" strategy (CTA ID 10)

### 4. Collection System Discovery

Discovered collection architecture:

- Collections are JSON files in S3: `genie-tools/collections/{name}.json`
- 6 XSL templates in `_assets/_xsl/collections/`
- API exists: `get-collections`, `save-collection`, `get-collection-templates`
- **No admin UI exists** - Critical gap identified

### 5. Master Rules Compliance Fix

Fixed version numbering violation:

- Was editing v1 files and updating internal version without changing filename
- Corrected by creating proper v2, v3 files
- v1 files preserved (never overwritten)
- Both locations synced (PLS and GenieCloud repos)

---

## DELETED STANDALONE DOCS (Consolidated)

These docs were merged into the Bridge Doc v3:

| Former Doc | Merged Into |
|------------|-------------|
| `CTA_SYSTEM_DEEP_DIVE_v1.md` | CONTRACT v3 §CTA System |
| `CTA_TOM_FERRY_FOLLOW_IMPLEMENTATION_v1.md` | CONTRACT v3 §CTA System |
| `COLLECTION_MANAGER_CRITICAL_SPEC_v1.md` | CONTRACT v3 §Collection System |

---

## CRITICAL PRIORITY QUEUE

Updated Project Universe Dashboard with:

| Priority | Item | Status |
|:--------:|------|--------|
| 🔴 #1 | **Collection Manager UI** | Starting now |
| 🔴 #2 | Modern Mobile-First CTAs (Tom Ferry) | Pending |
| 🔴 #3 | PLS Aspen Template | Pending |

---

## KEY TECHNICAL DISCOVERIES

### HubAssetSetting System

```
ORDER → WorkflowId → ConfigurationJson.AssetMap 
    → HubAssetSettingId → HubAssetSetting table 
    → Override check → GenieCloud API
```

- LC SMS uses HubAssetSettingId=10 → `property-compare`
- Override table allows per-user or per-role customization
- **This is why all LC orders get the same landing page**

### Theme Hue Paradox

- For dark headers on social ads, use `themeHue="light"` (counterintuitive)
- The XSL uses `--theme-body-color` for headers, which flips with hue

### Logo Naming Convention

```javascript
// Names are intentionally SWAPPED
companyLogoLight → Actually DARK text logo → Use on Light backgrounds
companyLogoDark → Actually LIGHT/WHITE logo → Use on Dark backgrounds
```

---

## DATABASE DECISIONS CONFIRMED

| Decision | Answer |
|----------|--------|
| PLS Listing Storage | `MlsListing.dbo.Listing` with `MlsId=999` |
| Status Types | 6=Private Listing, 14=Coming Soon |
| PropertyCastType | 4 (new for PLS) |
| Billing Model | One-time (like Listing Command) |

---

## FILES MODIFIED THIS SESSION

### Created
- `CONTRACT_PLS_to_GenieCloud_v2.md` (both locations)
- `CONTRACT_PLS_to_GenieCloud_v3.md` (both locations)
- `PLS_MASTER_SPECIFICATION_v2.md`
- `PLS_MASTER_SPECIFICATION_v3.md`

### Updated
- `PROJECT_UNIVERSE_DASHBOARD_v1.html` - Added Critical Priority section

### Synced
- All CONTRACT versions synced between PLS and GenieCloud repos

---

## NEXT SESSION OBJECTIVES

1. **Build Collection Manager UI** - React component for selecting landing pages, CTAs, and assets
2. **Integrate with cloudHubAPI** - Use existing `save-collection` endpoint
3. **Add preview functionality** - Show rendered assets before publishing
4. **Test with 10037 Rebecca Place** - Validate with real PLS listing

---

## REFERENCE URLS

| Resource | URL |
|----------|-----|
| Dainelle Scott Collection (Gold Standard) | https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52 |
| 10037 Rebecca PLS Hollywood | https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html |
| Project Universe Dashboard | `file:///D:/Cursor/TheGenie.ai/Development/PROJECT_UNIVERSE_DASHBOARD_v1.html` |

---

## ASP USER IDs FOR TESTING

| User | ASP User ID | Notes |
|------|-------------|-------|
| Texas Genie (Steve) | `2d0bd648-3f05-4e9a-bec9-1fb050d5170b` | Inspired.RE branding |
| Dainelle Scott | `9f750957-4d66-4151-bd37-9588d17d4fb8` | Compass theme, working collection |
| Ed Kaminsky | `4865455f-29a0-4c8f-9938-8c4bab261ef6` | San Diego eXp |

---

## MASTER RULES REMINDER

1. **Never overwrite files** - Always create new version (v1 → v2)
2. **Filename must match internal version** - `*_v2.md` contains `Version: 2.0`
3. **Sync to both locations** - PLS Docs AND stage.geniecloud
4. **Change log required** - Document what changed in each version
5. **Date format** - MM/DD/YYYY
6. **No iCloud files** - Keep all assets in project folders

---

*End of session log. Collection Manager UI development beginning next.*

