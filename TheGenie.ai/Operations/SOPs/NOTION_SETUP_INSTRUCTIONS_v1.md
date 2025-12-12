# Notion API Setup Instructions
**Version:** 1.0  
**Date:** 2025-12-11  
**Purpose:** Connect Cursor to Notion workspace for automated documentation management

---

## 🎯 Goal

Set up Notion API integration so Cursor/AI can automatically:
- Create and update documentation pages
- Sync workspace memory to Notion
- Maintain a web-based operations portal
- Structure content like `https://app.thegenie.ai/help`

---

## 📋 Step-by-Step Setup

### Step 1: Create Notion Integration

1. Go to **https://www.notion.so/my-integrations**
2. Click **"+ New integration"**
3. Fill in:
   - **Name:** `Cursor AI Integration` (or your preferred name)
   - **Logo:** (optional)
   - **Associated workspace:** Select your workspace
   - **Type:** Internal
4. Click **"Submit"**
5. **Copy the "Internal Integration Token"** - this is your API key!

### Step 2: Set API Token

**Option A: Environment Variable (Recommended)**
```powershell
# Windows PowerShell
$env:NOTION_API_TOKEN = "your_token_here"
```

**Option B: Update Config File**
Edit `notion_config_v1.py` and set:
```python
NOTION_API_TOKEN = "your_token_here"
```

⚠️ **Security Note:** Never commit API tokens to git! Use environment variables in production.

### Step 3: Share Pages with Integration

1. In Notion, go to the page you want Cursor to manage
2. Click **"Share"** (top right)
3. Click **"Add people, emails, groups, or integrations"**
4. Search for your integration name (e.g., "Cursor AI Integration")
5. Click to add it
6. The integration now has access to that page and all child pages

### Step 4: Get Page/Database IDs

**Method 1: From Notion URL**
- Open the page in Notion
- URL format: `https://www.notion.so/PageName-{32-char-id}`
- Copy the 32-character ID (with dashes)

**Method 2: Use Search Script**
```bash
python notion_api_v1.py
```
This will list all accessible pages with their IDs.

### Step 5: Test Connection

Run the test script:
```bash
python notion_api_v1.py
```

Expected output:
```
Testing Notion API connection...
✅ Notion API connection successful!

Found X pages in workspace:
  - Page Name (ID: abc123...)
  ...
```

---

## 🔧 Configuration

### Workspace ID
Your Notion Workspace ID: `9b72e4ec-dce0-8155-a440-00039beadab4`

### Required Files
- `notion_config_v1.py` - Configuration and API token
- `notion_api_v1.py` - Core API functions
- `sync_to_notion_v1.py` - Sync script (to be created)

---

## 📚 Notion API Documentation

- **Official Docs:** https://developers.notion.com/
- **API Reference:** https://developers.notion.com/reference
- **SDK Examples:** https://github.com/makenotion/notion-sdk-py

---

## 🚨 Troubleshooting

### Error: "NOTION_API_TOKEN not set"
- Make sure you set the environment variable or updated `notion_config_v1.py`
- Restart your terminal/IDE after setting environment variable

### Error: "401 Unauthorized"
- Check that your API token is correct
- Make sure you copied the full token (starts with `secret_`)

### Error: "404 Not Found" when accessing pages
- The integration doesn't have access to that page
- Share the page with the integration (Step 3)

### Error: "403 Forbidden"
- The integration doesn't have permission
- Re-share the page and ensure it's added as a collaborator

---

## ✅ Next Steps

After setup is complete:
1. Run `python notion_api_v1.py` to verify connection
2. Run `python sync_to_notion_v1.py` to sync workspace memory
3. Set up automated sync (optional - can be scheduled)

---

## 📝 Notes

- **Permissions:** Integration needs to be shared with each page it will access
- **Rate Limits:** Notion API has rate limits (3 requests/second)
- **Version:** Using Notion API version `2022-06-28`
- **Workspace:** All operations are scoped to your workspace

---

*Last updated: 2025-12-11*

