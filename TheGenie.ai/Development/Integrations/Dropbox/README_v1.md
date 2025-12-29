# Dropbox Integration
**Read-Only API Access for File Search**

---

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/22/2025 |
| **Last Updated** | 12/22/2025 |
| **Author** | Cursor AI |
| **Status** | 🔧 In Progress |

---

## 📋 Purpose

Enable Cursor to search and read files from Dropbox (3TB) without syncing locally.

**Use Cases:**
- Search for keywords in files/folders
- Find assets for projects
- Copy relevant files to D: drive for processing
- Read-only access (no writing to Dropbox)

---

## 🔐 Credentials

| Item | Value |
|------|-------|
| **App Name** | CursorFileSearch |
| **App Key** | `4bz5wirp90snlfz` |
| **App Secret** | See Master Credential Tracker |
| **Access Token** | ⏳ PENDING - Generate in Dropbox Console |
| **Permission Type** | Scoped App |
| **Account Type** | Professional (3TB) |

**Console URL:** [Dropbox App Console](https://www.dropbox.com/developers/apps/info/4bz5wirp90snlfz)

---

## ✅ Setup Steps

### Step 1: Configure Permissions (In Dropbox Console)
1. Go to **Permissions** tab
2. Enable:
   - ✅ `files.metadata.read`
   - ✅ `files.content.read`
3. Click **Submit**

### Step 2: Generate Access Token
1. Go to **Settings** tab
2. Scroll to **OAuth 2** section
3. Click **Generate** under "Generated access token"
4. Copy the token
5. Add to Master Credential Tracker

### Step 3: Install Python SDK
```bash
pip install dropbox
```

### Step 4: Test Connection
```python
import dropbox

dbx = dropbox.Dropbox('YOUR_ACCESS_TOKEN')
account = dbx.users_get_current_account()
print(f"Connected as: {account.name.display_name}")
```

---

## 📁 Files in This Folder

| File | Purpose |
|------|---------|
| `README_v1.md` | This file - overview and setup |
| `dropbox_search_v1.py` | Search utility script (to be created) |

---

## 🔗 Related

- **Master Credential Tracker:** `G:\My Drive\Master_Credential_Tracker_v3.md`
- **Dropbox API Docs:** [developers.dropbox.com](https://www.dropbox.com/developers/documentation)

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/22/2025 | Initial creation. Documented Dropbox API app setup. Credentials captured (App Key: 4bz5wirp90snlfz). |

---

*Location: `D:\Cursor\TheGenie.ai\Development\Integrations\Dropbox\`*

