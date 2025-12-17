# Guide for Other Cursor Agents
**Everything is Already Set Up - Here's Where to Find It**

---

## 🚨 START HERE - Read This First

**If you're asking the user to:**
- ❌ Import files
- ❌ Set up SQL Server
- ❌ Configure database connections
- ❌ Set up credentials

**STOP. Everything is already done. Read this guide instead.**

---

## 📍 MASTER INDEX - Your Single Source of Truth

**Location:** `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md`

**This file contains EVERYTHING:**
- Database connection info (prominently at the top)
- All file locations
- Sandbox information
- GitHub structure
- Memory logs catalog

**SAY THIS TO THE USER:**
> "Reference the MASTER_INDEX at `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md`"

Then read that file - it has everything you need.

---

## 🔥 DATABASE ACCESS - Already Configured

### Connection Information (From MASTER_INDEX):

| Item | Value |
|------|-------|
| **Server (VPN Required)** | `192.168.29.45` |
| **Server (Hostname)** | `server-mssql1.istrategy.com` |
| **Port** | `1433` |
| **User** | `cursor` |
| **Password** | `1ppINSAyay$` |
| **Primary Database** | `FarmGenie` |
| **MLS Database** | `MlsListing` |
| **Title Database** | `TitleData` |

### Python Connection Template (Already Working):

```python
import pyodbc
import pandas as pd

def connect():
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER=192.168.29.45,1433;"
        f"DATABASE=FarmGenie;"
        f"UID=cursor;PWD=1ppINSAyay$;"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)
```

**⚠️ IMPORTANT:** Requires SonicWall VPN connection to access `192.168.29.45`

**This is already set up. Don't ask the user to configure it.**

---

## 📁 WHERE TO FIND INFORMATION

### 1. Database Connection Info
- **Location:** `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md` (top of file)
- **Also:** `G:\My Drive\Master_Credential_Tracker_v2.md`

### 2. Technical Reference
- **Location:** `TheGenie.ai.Database\GenieCursor\SOP Documentations\WORKSPACE_MEMORY_v2.md`
- **Contains:** Database schema, product IDs, table structures, SQL examples

### 3. Sandbox Configuration
- **Location:** `c:\Cursor\_ARCHIVE_Downloads\sandbox_configs\`
- **Files:**
  - `env.sandbox.txt` - Environment variables
  - `Web.Sandbox.config` - Web configuration
  - `start-sandbox.ps1` - Startup script

### 4. Previous Session Memory Logs
- **Location:** `c:\Cursor\TheGenie.ai\MemoryLogs\`
- **GitHub:** `c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\`
- **Catalog:** See MASTER_INDEX for complete list

### 5. GitHub Repository
- **Location:** `c:\Cursor\_ARCHIVE_Downloads\NOTION\`
- **Remote:** `https://github.com/1ppTheGenie/NOTION`
- **Status:** PRIMARY documentation system (all files are here)

---

## 🎯 WHAT TO DO INSTEAD OF ASKING THE USER

### ❌ DON'T ASK:
- "Can you import the files?"
- "Can you set up SQL Server?"
- "Can you configure the database?"
- "Can you provide credentials?"

### ✅ DO THIS INSTEAD:

1. **Read the MASTER_INDEX:**
   ```
   c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md
   ```

2. **Check the Technical Reference:**
   ```
   TheGenie.ai.Database\GenieCursor\SOP Documentations\WORKSPACE_MEMORY_v2.md
   ```

3. **Check Previous Memory Logs:**
   ```
   c:\Cursor\TheGenie.ai\MemoryLogs\*.md
   ```

4. **Check GitHub:**
   ```
   c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\
   ```

5. **Use the Database Connection:**
   - Server: `192.168.29.45`
   - User: `cursor`
   - Password: `1ppINSAyay$`
   - Database: `FarmGenie`

---

## 📋 QUICK REFERENCE - Common Tasks

### Connect to Database:
```python
# Use the template from MASTER_INDEX
# It's already working - just copy it
```

### Find Previous Work:
```powershell
# Check memory logs
Get-ChildItem "c:\Cursor\TheGenie.ai\MemoryLogs\*.md"

# Check GitHub
Get-ChildItem "c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\*.md"
```

### Find SQL Scripts:
```powershell
# Check Development folder
Get-ChildItem "c:\Cursor\TheGenie.ai\Development\**\*.sql" -Recurse

# Check GitHub
Get-ChildItem "c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\Development\**\*.sql" -Recurse
```

### Find Python Scripts:
```powershell
# Check Operations folder
Get-ChildItem "c:\Cursor\TheGenie.ai\Operations\**\*.py" -Recurse

# Check GitHub
Get-ChildItem "c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\Operations\**\*.py" -Recurse
```

---

## 🚨 IF YOU'RE STUCK

### Step 1: Read MASTER_INDEX
**Location:** `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md`

### Step 2: Check Memory Logs
**Location:** `c:\Cursor\TheGenie.ai\MemoryLogs\`

Look for logs related to your task:
- Database work → Check all logs
- Reports → Check CCReports, LeadToListing logs
- Features → Check AreaOwnership, NurtureEngine logs

### Step 3: Check Technical Reference
**Location:** `TheGenie.ai.Database\GenieCursor\SOP Documentations\WORKSPACE_MEMORY_v2.md`

This has:
- Database schema
- Table structures
- SQL examples
- Product IDs
- Common queries

### Step 4: Check GitHub
**Location:** `c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\`

Everything is organized here:
- `Development/` - Feature work
- `Operations/` - Reports, scripts
- `MemoryLogs/` - Session documentation

---

## 💬 WHAT TO SAY TO THE USER

**Instead of asking them to do setup, say:**

> "I'm referencing the MASTER_INDEX to find the database connection information and previous work. Everything appears to be already configured. Let me check the memory logs to see how this was done previously."

**Then:**
1. Read MASTER_INDEX
2. Check relevant memory logs
3. Use the information you find
4. Don't ask the user to do things that are already done

---

## ✅ VERIFICATION CHECKLIST

Before asking the user to do anything, verify:

- [ ] Have I read the MASTER_INDEX?
- [ ] Have I checked the memory logs?
- [ ] Have I checked the technical reference?
- [ ] Have I checked GitHub for previous work?
- [ ] Is what I'm asking for already documented somewhere?
- [ ] Can I find the answer myself?

**If you can't find it after checking all these sources, THEN ask the user.**

---

## 📝 EXAMPLE: Finding Database Info

**❌ WRONG:**
> "Can you provide the SQL Server connection details?"

**✅ RIGHT:**
> "I found the database connection information in the MASTER_INDEX. Server: 192.168.29.45, User: cursor, Database: FarmGenie. I'll use this to connect."

---

## 🎯 KEY POINTS

1. **Everything is documented** - Check MASTER_INDEX first
2. **Database is configured** - Use the connection info provided
3. **Files are organized** - Check GitHub structure
4. **Previous work exists** - Check memory logs
5. **Don't ask user to repeat work** - Find it yourself first

---

## 📚 RELATED DOCUMENTS

| Document | Location | Purpose |
|----------|----------|---------|
| **MASTER_INDEX** | `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md` | Start here - everything is here |
| **Technical Reference** | `TheGenie.ai.Database\GenieCursor\SOP Documentations\WORKSPACE_MEMORY_v2.md` | Database, schema, SQL |
| **Credentials** | `G:\My Drive\Master_Credential_Tracker_v2.md` | All credentials |
| **Directory Structure** | `c:\Cursor\TheGenie.ai\PERMANENT_DIRECTORY_STRUCTURE_v1.md` | File organization |

---

## 🚨 REMEMBER

**The user has already done the setup work. Your job is to:**
1. Find the information that already exists
2. Use the configurations that are already in place
3. Reference previous work that's already documented
4. Only ask for NEW information, not things that are already done

**If a previous agent "made it happen like magic," it's because they:**
- Read the MASTER_INDEX
- Checked the memory logs
- Used the existing database connection
- Found the information that was already there

**You can do the same thing. Start with the MASTER_INDEX.**

---

**This guide is for Cursor agents. Share this with any agent who is struggling.**

*Created: 12/15/2025*

