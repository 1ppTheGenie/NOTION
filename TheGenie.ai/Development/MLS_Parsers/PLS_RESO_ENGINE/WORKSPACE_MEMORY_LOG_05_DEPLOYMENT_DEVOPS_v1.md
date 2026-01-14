# PLS RESO Engine - Workspace Memory Log: Deployment & DevOps
**Version:** 1.0  
**Created:** 01/10/2026  
**Last Updated:** 01/10/2026  
**Topic:** Sandbox Deployment, Rollback Procedures, Configuration Management, IIS  
**Status:** ✅ Active - CRITICAL LESSONS LEARNED

---

## 📋 TOPIC OVERVIEW

This memory log captures all discussions, decisions, and documentation related to:
- Sandbox deployment procedures
- Rollback procedures and failures
- Configuration file management (Web.config, DLL.config)
- IIS Express and application startup
- Connection string management
- Deployment safety verification

---

## 🚨 CRITICAL LESSONS LEARNED

### Rollback Failure (01/09/2026 - 01/10/2026)

**Problem:** Sandbox deployment broke login functionality. Rollback procedure failed to restore system.

**Root Cause:** `bin\Smart.Dashboard.dll.config` was NOT included in backup/rollback procedures.

**Why It Failed:**
1. `Smart.Dashboard.dll.config` is loaded at application startup
2. Contains connection strings (DefaultConnection, FarmGenieConnectionString)
3. If DLL.config has wrong connection strings, authentication fails
4. Even if Web.config is correct, DLL.config takes precedence at startup
5. DLL.config was not backed up, so rollback couldn't restore it

**Fix Applied:**
1. Updated Deployment Prompt Beta (Section 14) to include DLL.config in all backups
2. Created/updated DLL.config to match Web.config connection strings
3. Verified both files point to production server (192.168.29.45,1433)
4. Documented critical lesson: DLL.config must ALWAYS be included in backups

**Files Affected:**
- `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config`
- `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\bin\Smart.Dashboard.dll.config`

---

## 📁 CONFIGURATION FILES

### Web.config
**Location:** `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config`

**Critical Settings:**
```xml
<connectionStrings>
  <add name="DefaultConnection" 
       providerName="System.Data.SqlClient" 
       connectionString="Server=192.168.29.45,1433;Database=FarmGenie;User Id=sa;Password=neo222;" />
  <add name="Smart.Data.Properties.Settings.FarmGenieConnectionString" 
       connectionString="Data Source=192.168.29.45;Initial Catalog=FarmGenie;Persist Security Info=True;User ID=sa;Password=neo222" 
       providerName="System.Data.SqlClient" />
</connectionStrings>

<system.web>
  <customErrors mode="On" />
</system.web>
```

### Smart.Dashboard.dll.config
**Location:** `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\bin\Smart.Dashboard.dll.config`

**Critical:** This file MUST match Web.config connection strings exactly.

**Why It Matters:**
- Loaded at application startup
- Takes precedence over Web.config for DLL configuration
- If missing or incorrect, authentication will fail

---

## 🔄 DEPLOYMENT PROCEDURES

### Pre-Deployment Checklist (Fortune 500 Enterprise Level)

1. **Create Timestamped Backup**
   ```powershell
   $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
   $backupPath = "I:\Backups\PreDeploy_$timestamp"
   New-Item -ItemType Directory -Path $backupPath
   
   # Backup ALL config files (Web.config AND DLL.config)
   Copy-Item "C:\Sandbox\...\Smart.Dashboard\Web.config" -Destination "$backupPath\Web.config"
   Copy-Item "C:\Sandbox\...\Smart.Dashboard\bin\Smart.Dashboard.dll.config" -Destination "$backupPath\Smart.Dashboard.dll.config"
   
   # Backup ALL DLLs
   Copy-Item "C:\Sandbox\...\Smart.Dashboard\bin\*.dll" -Destination "$backupPath\bin\"
   
   # Backup ALL modified controller files
   Copy-Item "C:\Sandbox\...\Controllers\*.cs" -Destination "$backupPath\Controllers\" -Recurse
   
   # Backup routing files
   Copy-Item "C:\Sandbox\...\App_Start\RouteConfig.cs" -Destination "$backupPath\RouteConfig.cs"
   ```

2. **Verify Rollback Procedure Ready**
   - Test restore from backup location
   - Verify backup contains ALL necessary files
   - Document rollback steps

3. **Pre-Deployment Safety Verification**
   - Verify connection strings point to correct server
   - Verify database connectivity
   - Verify no duplicate connection strings
   - Verify customErrors mode is appropriate

4. **Deploy Changes**
   - Build solution
   - Copy files to deployment location
   - Update configuration files

5. **Post-Deployment Validation**
   - Test login functionality
   - Test database connectivity
   - Test application startup
   - Verify no errors in logs

### Rollback Procedure

```powershell
$backupPath = "I:\Backups\PreDeploy_20260109_143000"

# Restore ALL config files
Copy-Item "$backupPath\Web.config" -Destination "C:\Sandbox\...\Smart.Dashboard\Web.config" -Force
Copy-Item "$backupPath\Smart.Dashboard.dll.config" -Destination "C:\Sandbox\...\Smart.Dashboard\bin\Smart.Dashboard.dll.config" -Force

# Restore ALL DLLs
Copy-Item "$backupPath\bin\*.dll" -Destination "C:\Sandbox\...\Smart.Dashboard\bin\" -Force

# Restore ALL controller files
Copy-Item "$backupPath\Controllers\*.cs" -Destination "C:\Sandbox\...\Controllers\" -Recurse -Force

# Restore routing files
Copy-Item "$backupPath\RouteConfig.cs" -Destination "C:\Sandbox\...\App_Start\RouteConfig.cs" -Force

# Recycle IIS / Restart IIS Express
```

---

## 🔧 CONNECTION STRING MANAGEMENT

### Production Server
- **Server:** 192.168.29.45,1433
- **Database:** FarmGenie
- **User:** sa
- **Password:** neo222

### Connection Strings Required
1. **DefaultConnection** - For ASP.NET Identity (authentication)
2. **Smart.Data.Properties.Settings.FarmGenieConnectionString** - For data access

### Common Issues
1. **Duplicate Connection Strings** - Causes configuration error
2. **Wrong Server** - localhost instead of production server
3. **Mismatched DLL.config** - DLL.config doesn't match Web.config
4. **Missing DLL.config** - DLL.config doesn't exist (will use defaults)

---

## 🛠️ IIS EXPRESS MANAGEMENT

### Starting IIS Express
- Visual Studio: F5 or Start Debugging
- Command Line: `iisexpress.exe /path:"C:\Sandbox\..." /port:8091`

### Stopping IIS Express
- Visual Studio: Stop Debugging
- Task Manager: End `iisexpress.exe` process
- Command Line: Find process and kill

### Configuration Changes
- **Requires Restart** - IIS Express must be restarted after config changes
- **Check Process** - Verify old process is stopped before starting new one

---

## 📚 KEY DOCUMENTS

| Document | Version | Purpose |
|----------|---------|---------|
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md** | 1.15 | Section 14: Deployment Prompt Beta (updated with DLL.config) |
| **FIX_WEBCONFIG_CONNECTION_STRINGS.ps1** | 1.0 | PowerShell script to fix connection strings |
| **FIX_PRODUCTION_CONNECTIONS.ps1** | 1.0 | PowerShell script to fix production connections |
| **FIX_HYBRID_CONNECTION_STRINGS.ps1** | 1.0 | PowerShell script to fix hybrid connections |

---

## 🔑 KEY DECISIONS

1. **Fortune 500 Enterprise Procedures** - All deployments must follow strict backup/rollback
2. **DLL.config Must Be Backed Up** - Critical lesson learned from rollback failure
3. **Connection String Verification** - Must verify before and after deployment
4. **Sandbox First** - All changes tested in Sandbox before Production
5. **No Assumptions** - Verify everything, test everything

---

## ⚠️ CRITICAL RULES

1. **NEVER deploy without backup** - Timestamped backup is mandatory
2. **ALWAYS include DLL.config in backup** - This was the rollback failure
3. **VERIFY connection strings** - Before and after deployment
4. **TEST login after deployment** - Authentication is critical
5. **RESTART IIS Express** - After any configuration changes
6. **NO production changes** - Sandbox only until fully tested

---

## 📝 CHANGELOG

- **2026-01-10:** Initial workspace memory log created
- **2026-01-10:** Documented rollback failure and DLL.config lesson
- **2026-01-09:** Deployment Prompt Beta updated to include DLL.config
- **2026-01-09:** Sandbox safety verification integrated

---

**Status:** ✅ Active - Critical deployment lessons documented
