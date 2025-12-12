# Notion Integration - Quick Start Guide
**Version:** 1.0  
**Date:** 2025-12-11

---

## 🚀 Quick Setup (5 minutes)

### 1. Get Your Notion API Token

1. Go to: **https://www.notion.so/my-integrations**
2. Click **"+ New integration"**
3. Name it: `Cursor AI Integration`
4. Copy the **Internal Integration Token** (starts with `secret_`)

### 2. Set the Token

**Windows PowerShell:**
```powershell
$env:NOTION_API_TOKEN = "secret_your_token_here"
```

**Or edit `notion_config_v1.py`:**
```python
NOTION_API_TOKEN = "secret_your_token_here"
```

### 3. Share a Page with Integration

1. Open any Notion page
2. Click **"Share"** (top right)
3. Search for **"Cursor AI Integration"**
4. Add it as a collaborator

### 4. Test Connection

```powershell
python notion_api_v1.py
```

You should see:
```
✅ Notion API connection successful!
Found X pages in workspace:
  - Page Name (ID: abc123...)
```

### 5. Sync Workspace Memory

```powershell
# Set your root page ID (get from step 4)
$env:NOTION_ROOT_PAGE_ID = "your-page-id-here"

# Run sync
python sync_to_notion_v1.py
```

---

## 📁 Files Created

| File | Purpose |
|------|---------|
| `notion_config_v1.py` | Configuration and API token storage |
| `notion_api_v1.py` | Core Notion API functions |
| `sync_to_notion_v1.py` | Sync workspace memory to Notion |
| `NOTION_SETUP_INSTRUCTIONS_v1.md` | Detailed setup guide |
| `notion_requirements_v1.txt` | Python dependencies |

---

## 🎯 Next Steps

1. ✅ Get API token from Notion
2. ✅ Set `NOTION_API_TOKEN` environment variable
3. ✅ Share a page with the integration
4. ✅ Test connection: `python notion_api_v1.py`
5. ✅ Sync content: `python sync_to_notion_v1.py`

---

## 📚 Full Documentation

See `NOTION_SETUP_INSTRUCTIONS_v1.md` for detailed instructions and troubleshooting.

---

*Ready to connect! Follow the 5 steps above to get started.*

