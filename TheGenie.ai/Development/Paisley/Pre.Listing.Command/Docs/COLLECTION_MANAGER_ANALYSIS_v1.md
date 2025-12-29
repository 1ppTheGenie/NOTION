# Collection Manager UI - Analysis & Recommendations

**Version:** 1.0  
**Created:** 12/28/2025  
**Author:** Steve Hundley / Cursor AI  
**Status:** DISCOVERY COMPLETE - Action items identified

---

## 🎉 GOOD NEWS: Collection Editor Already Exists!

A **fully functional Collection Editor** already exists in the GenieCloud codebase:

| Component | Location |
|-----------|----------|
| Source Code | `stage.geniecloud/genie-collection-editor/src/` |
| Components | 8 Solid.js components |
| API Integration | Connected to cloudHubAPI.js |
| Built Version | `stage.geniecloud/public/genie-tools/collection-editor/` |

### Current Capabilities

The existing Collection Editor can:

- ✅ List all collections from S3
- ✅ Create new collections
- ✅ Edit collection sections (name, caption, description)
- ✅ Add/remove assets to sections
- ✅ Reorder assets (up/down)
- ✅ Set asset name overrides
- ✅ Configure QR destinations
- ✅ Configure LPO (Landing Page Only) settings
- ✅ Hide/show assets
- ✅ Save collections back to S3
- ✅ Duplicate collections

---

## ❌ CURRENT PROBLEM: Deployment Issue

The live collection editor at `cloud.thegenie.ai/genie-tools/collection-editor/` is **broken**:

| Issue | Details |
|-------|---------|
| Current State | Shows "Genie Monitor" instead of Collection Editor |
| Root Cause | `genie-monitor` build overwrites collection-editor directory |
| Evidence | Both projects use same output path in vite.config.js |

### Vite Config Conflict

```javascript
// genie-collection-editor/vite.config.js
outDir: `../public/genie-tools/collection-editor/`

// genie-monitor/vite.config.mjs (LINE 42)
outDir: `../public/genie-tools/collection-editor/`  // SAME PATH!
```

**This is a DevOps bug** - two different apps building to the same directory.

---

## 🔧 RECOMMENDED FIX

### Option A: Fix the Build Path (Recommended)

1. Change `genie-monitor` output directory to `/genie-tools/monitor/`
2. Rebuild `genie-collection-editor`
3. Deploy to S3/CloudFront

### Option B: Separate the Apps

1. Keep them in different folders
2. Update build scripts
3. Deploy independently

---

## 🆕 WHAT'S NEEDED FOR PLS

The existing Collection Editor is **admin-only**. For PLS, we need:

### New Features Required

| Feature | Priority | Description |
|---------|----------|-------------|
| **Customer-Facing Collection Selector** | HIGH | Dropdown during checkout to select collection |
| **Preview Mode** | HIGH | Show rendered assets before purchase |
| **CTA Selector** | HIGH | Choose which CTA appears on landing pages |
| **Role-Based Access** | MEDIUM | Different collections for different roles |
| **PLS-Specific Collections** | HIGH | Collections designed for Private/Coming Soon |

### Integration Points

```
PLS UI (New) → HubAssetSetting Table → Collection JSON → GenieCloud Render
     ↓
  Customer selects collection at checkout
     ↓
  Order links to HubAssetSettingId
     ↓
  Render uses collection JSON for asset list
```

---

## 📋 ACTION ITEMS

### Immediate (John/UK - GenieCloud Team)

| Priority | Task |
|:--------:|------|
| 🔴 | Fix `genie-monitor` vite output path to `/genie-tools/monitor/` |
| 🔴 | Rebuild and deploy `genie-collection-editor` |
| 🟡 | Verify collection editor is accessible at `/genie-tools/collection-editor/` |

### Phase 1 (PLS Team)

| Priority | Task |
|:--------:|------|
| 🔴 | Create PLS-specific collection JSON (e.g., `pls-social-collection-v1.json`) |
| 🔴 | Add HubAssetSetting record for PLS collection |
| 🟡 | Build customer-facing collection selector component |

### Phase 2 (Both Teams)

| Priority | Task |
|:--------:|------|
| 🟡 | Add CTA configuration to collection JSON schema |
| 🟡 | Build preview mode in collection selector |
| 🟢 | Implement role-based collection restrictions |

---

## 📂 EXISTING COLLECTION JSON FILES

Found in `public/genie-tools/collections/`:

| File | Purpose |
|------|---------|
| `listing-command-sample.json` | LC Proof Kit |
| `neighborhood-command-sample.json` | NC Proof Kit |
| `just-listed-kit.json` | Just Listed Kit |
| `just-listed-kit-paisley-plus.json` | Premium version |
| `market-report-kit.json` | Market Insider Kit |
| `market-report-kit-paisley-plus.json` | Premium version |
| `oh-marketing-kit.json` | Open House Kit |
| `farm-domination-kit.json` | Farm Domination |
| **`pls-social-collection-v1.json`** | **PLS collection (already created!)** |

---

## 🔍 EXISTING API ENDPOINTS

From `cloudHubAPI.js`:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `get-collections` | POST | List all collections from S3 |
| `save-collection` | POST | Save collection to S3 |
| `get-collection-templates` | POST | List XSL collection templates |
| `get-assets` | POST | List all available XSL assets |
| `get-themes` | POST | List all CSS themes |

---

## 📊 COLLECTION JSON SCHEMA

```json
{
  "version": 2,
  "name": "Collection Display Name",
  "template": "listing-command-proof",
  "sections": [
    {
      "name": "Section Name",
      "meta": {
        "caption": "Section caption text",
        "description": "Section description"
      },
      "assets": [
        {
          "folder": "social-marketing-graphics",
          "stylesheet": "lc-prop-post-03",
          "name": "Optional Override Name",
          "qrUrl": "landing-page-name",
          "lpo": null,
          "hide": false
        }
      ]
    }
  ]
}
```

---

## 🎯 NEXT STEPS

1. **Report DevOps bug** to John/UK team (vite output path conflict)
2. **Create PLS collection selector** component for checkout flow
3. **Add CTA field** to collection JSON schema
4. **Build preview** functionality

---

## RELATED DOCUMENTS

| Document | Location |
|----------|----------|
| CONTRACT_PLS_to_GenieCloud_v3.md | Same folder + stage.geniecloud |
| PLS_MASTER_SPECIFICATION_v3.md | Same folder |
| GENIECLOUD_ASSET_DEVELOPMENT_v1.md | stage.geniecloud |

---

*Collection Editor exists and works - just needs deployment fix and PLS-specific enhancements.*

