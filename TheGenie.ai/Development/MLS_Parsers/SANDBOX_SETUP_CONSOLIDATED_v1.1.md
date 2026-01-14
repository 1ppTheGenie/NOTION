# Sandbox Setup Guide - Consolidated
**Version:** 1.1  
**Created:** 12/30/2025 4:00 PM  
**Last Updated:** 01/01/2026 7:20 PM  
**Author:** Cursor AI Agent  
**Purpose:** Complete guide for setting up local sandbox environment for PLS prototyping

---

## 🎯 GOAL

Set up local sandbox with cloned databases:
- ✅ `FarmGenie` (365 GB - need strategy!)
- ✅ `MlsListing` (smaller)
- ✅ `TitleData` (Attom data)

**Options:**
1. **Full Clone** - Complete copy (if you have space)
2. **Schema-Only** - Structure only, add sample data
3. **Hybrid** - Schema + essential tables with data

---

## 🔍 CURRENT SANDBOX TOPOLOGY

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    CURRENT SANDBOX SETUP                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  LOCAL MACHINE (D: Drive)                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Source Code (VSS)                                        │   │
│  │  • Smart.Dashboard (Backend .NET)                        │   │
│  │  • Smart.NG.Agent (Frontend Angular)                     │   │
│  │  • genie-api (GenieCloud Node.js)                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                       │
│                           │ VPN Connection                        │
│                           ▼                                       │
│  PRODUCTION SERVER (192.168.29.45)                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  SQL Server (Production)                                  │   │
│  │  • FarmGenie (365 GB)                                    │   │
│  │  • MlsListing                                            │   │
│  │  • TitleData                                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  DEPLOYMENT FLOW:                                                │
│  Local Sandbox → Stage → Production                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Current Configuration

**From Master Index:**
- **Sandbox URLs:**
  - FarmGenie: `http://localhost:38949`
  - Agent Dashboard: `http://localhost:38949/agent`
  - Test Login: `shundley / 1ppINSAyay$`

**Production Server:**
- **IP:** `192.168.29.45`
- **Databases:** FarmGenie, MlsListing, TitleData
- **Access:** VPN connection required

---

## 📋 PREREQUISITES

### 1. Local SQL Server Installation

**Check if you have SQL Server:**
```powershell
# Check SQL Server version
Get-Service -Name "*SQL*" | Select-Object Name, Status, DisplayName

# Or check if sqlcmd exists
sqlcmd -?
```

**If you don't have SQL Server:**
- **Option A:** SQL Server Developer Edition (FREE)
  - Download: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
  - Full-featured, free for development
  
- **Option B:** SQL Server Express (FREE, limited to 10 GB per database)
  - ⚠️ **Problem:** FarmGenie is 365 GB - won't fit!
  - Use for MlsListing and TitleData only
  
- **Option C:** Docker SQL Server (FREE)
  - `docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourPassword123!" -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest`
  - Full SQL Server in container

---

## 🗄️ DATABASE CLONING STRATEGIES

### Strategy 1: Schema-Only Clone (RECOMMENDED for PLS)

**Best for:** PLS prototyping (don't need all production data)

**Steps:**
1. **Export Schema Only:**
   ```sql
   -- Generate schema scripts
   -- Use SQL Server Management Studio: Tasks → Generate Scripts
   -- Select: Script database schema only
   ```

2. **Create Empty Databases:**
   ```sql
   CREATE DATABASE FarmGenie_Sandbox;
   CREATE DATABASE MlsListing_Sandbox;
   CREATE DATABASE TitleData_Sandbox;
   ```

3. **Run Schema Scripts:**
   - Execute generated schema scripts
   - Creates all tables, indexes, constraints

4. **Add Sample Data:**
   - Insert minimal test data for PLS development
   - Focus on tables needed for PLS (Listing, Agent, etc.)

**Advantages:**
- ✅ Fast setup
- ✅ Small disk space
- ✅ Clean test environment
- ✅ No production data concerns

---

### Strategy 2: Hybrid Clone (BALANCED)

**Best for:** Need some production data for realistic testing

**Steps:**
1. **Clone Schema** (same as Strategy 1)
2. **Selective Data Copy:**
   ```sql
   -- Copy only essential tables with data
   -- Example: Copy last 1000 listings
   SELECT TOP 1000 * INTO MlsListing_Sandbox.dbo.Listing 
   FROM MlsListing.dbo.Listing 
   ORDER BY ModifiedDate DESC;
   ```

3. **Copy Master Data:**
   - Copy lookup tables (StatusTypes, PropertyTypes, etc.)
   - Copy agent/office data
   - Copy area/neighborhood data

**Advantages:**
- ✅ Realistic test data
- ✅ Manageable size
- ✅ Faster than full clone

---

### Strategy 3: Full Clone (NOT RECOMMENDED)

**Best for:** Complete production replica (if you have 400+ GB free space)

**Steps:**
1. **Backup Production Databases:**
   ```sql
   BACKUP DATABASE FarmGenie TO DISK = 'C:\Backups\FarmGenie.bak';
   BACKUP DATABASE MlsListing TO DISK = 'C:\Backups\MlsListing.bak';
   BACKUP DATABASE TitleData TO DISK = 'C:\Backups\TitleData.bak';
   ```

2. **Restore to Local:**
   ```sql
   RESTORE DATABASE FarmGenie_Sandbox FROM DISK = 'C:\Backups\FarmGenie.bak';
   RESTORE DATABASE MlsListing_Sandbox FROM DISK = 'C:\Backups\MlsListing.bak';
   RESTORE DATABASE TitleData_Sandbox FROM DISK = 'C:\Backups\TitleData.bak';
   ```

**Disadvantages:**
- ❌ Requires 400+ GB disk space
- ❌ Slow backup/restore process
- ❌ Unnecessary for PLS prototyping

---

## 🔧 CONNECTION STRING CONFIGURATION

### Update appsettings.json

**For Local Sandbox:**
```json
{
  "ConnectionStrings": {
    "FarmGenie": "Server=localhost;Database=FarmGenie_Sandbox;Integrated Security=true;",
    "MlsListing": "Server=localhost;Database=MlsListing_Sandbox;Integrated Security=true;",
    "TitleData": "Server=localhost;Database=TitleData_Sandbox;Integrated Security=true;"
  }
}
```

**For Production Server (via VPN):**
```json
{
  "ConnectionStrings": {
    "FarmGenie": "Server=192.168.29.45;Database=FarmGenie;User Id=cursor;Password=1ppINSAyay$;",
    "MlsListing": "Server=192.168.29.45;Database=MlsListing;User Id=cursor;Password=1ppINSAyay$;",
    "TitleData": "Server=192.168.29.45;Database=TitleData;User Id=cursor;Password=1ppINSAyay$;"
  }
}
```

---

## ✅ VERIFICATION CHECKLIST

### Database Setup:
- [ ] SQL Server installed locally
- [ ] Databases created (FarmGenie_Sandbox, MlsListing_Sandbox, TitleData_Sandbox)
- [ ] Schema scripts executed
- [ ] Sample data inserted (if using Strategy 1 or 2)
- [ ] Connection strings updated in appsettings.json
- [ ] Application can connect to sandbox databases

### Application Setup:
- [ ] Source code pulled from VSS
- [ ] Dependencies restored (NuGet packages)
- [ ] Application builds successfully
- [ ] Application runs and connects to sandbox
- [ ] Can create test PLS listings

---

## 🚨 TROUBLESHOOTING

### Problem: Not Enough Disk Space
**Solution:**
- Use Strategy 1 (Schema-Only)
- Or Strategy 2 (Hybrid) with limited data
- Consider external drive for database files

### Problem: Can't Connect to Production Server
**Solution:**
- Verify VPN connection
- Check firewall rules
- Verify credentials (cursor / 1ppINSAyay$)
- Test connection: `sqlcmd -S 192.168.29.45 -U cursor -P "1ppINSAyay$"`

### Problem: Schema Scripts Fail
**Solution:**
- Check SQL Server version compatibility
- Review error messages
- May need to adjust scripts for local SQL Server version
- Consider using SQL Server Management Studio Generate Scripts wizard

---

## 📝 QUICK REFERENCE

| Item | Value |
|------|-------|
| **Production Server** | `192.168.29.45` |
| **Production User** | `cursor` |
| **Production Password** | `1ppINSAyay$` |
| **Local Server** | `localhost` |
| **Sandbox Databases** | `*_Sandbox` suffix |
| **Recommended Strategy** | Schema-Only (Strategy 1) |

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.1 | 01/01/2026 7:20 PM | **CONSOLIDATED** - Merged SANDBOX_DATABASE_SETUP_v1.md and SANDBOX_TOPOLOGY_ANALYSIS_v1.md into single comprehensive sandbox setup guide. Includes topology analysis, database cloning strategies, connection configuration, and troubleshooting. |
| 1.0 | 12/30/2025 4:00 PM | Initial sandbox setup documents (now consolidated) |

---

*File: SANDBOX_SETUP_CONSOLIDATED_v1.1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\MLS_Parsers\*

