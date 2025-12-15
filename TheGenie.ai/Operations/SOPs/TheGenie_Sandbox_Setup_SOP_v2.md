# TheGenie.ai Sandbox Setup - Standard Operating Procedure

**Version:** 2.0  
**Date:** 12/13/2025  
**Status:** Production Ready  
**Author:** Development Team

---

## Executive Summary

This SOP documents the complete setup process for TheGenie.ai local development sandbox, including lessons learned and fixes applied during initial setup. The sandbox enables developers to run the full Genie platform locally for development and testing.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [FarmGenie Backend Setup](#farmgenie-backend-setup)
4. [Angular Agent App Setup](#angular-agent-app-setup)
5. [Genie Cloud Setup](#genie-cloud-setup)
6. [Running the Sandbox](#running-the-sandbox)
7. [Known Issues & Solutions](#known-issues--solutions)
8. [Troubleshooting Guide](#troubleshooting-guide)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    TheGenie.ai Platform                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   FarmGenie     │  │   Agent App     │  │  Genie Cloud    │  │
│  │   (.NET 4.8)    │  │   (Angular 9)   │  │  (Node.js 18)   │  │
│  │                 │  │                 │  │                 │  │
│  │  Backend API    │  │  Dashboard UI   │  │  AWS Lambda     │  │
│  │  MVC Dashboard  │  │  Agent Portal   │  │  Rendering API  │  │
│  │  Admin Tools    │  │  Lead Capture   │  │  Paisley AI     │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
│           │                    │                    │           │
│           └────────────────────┼────────────────────┘           │
│                                │                                 │
│                    ┌───────────▼───────────┐                    │
│                    │   SQL Server          │                    │
│                    │   (Production DB)     │                    │
│                    │   server-mssql1       │                    │
│                    └───────────────────────┘                    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Visual Studio 2022 | Latest | .NET development |
| .NET Framework | 4.8 | Backend runtime |
| Node.js | 18.x | Genie Cloud |
| Node.js | 14.x | Angular 9 (if modifying) |
| NVM for Windows | 1.2.x | Node version management |
| IIS Express | Included with VS | Local web server |
| SQL Server Management Studio | Latest | Database access |
| SonicWall VPN Client | Latest | Network access |
| Git | Latest | Source control |

### Network Requirements

- **VPN Connection Required**: SonicWall Global VPN to 1pp network
- **Database Server**: `server-mssql1.istrategy.com` (NOT 10.10.10.200)
- **Production Server**: `\\server-webapp2.istrategy.com\wwwroot\FarmGenie\`

### Required Credentials

| Credential | Source | Purpose |
|------------|--------|---------|
| VPN Login | IT Department | Network access |
| Database (sa) | IT Department | SQL Server access |
| GitHub | 1ppTheGenie account | Source control |
| AWS Keys | IT Department | Genie Cloud (optional) |

---

## FarmGenie Backend Setup

### Step 1: Clone/Copy Source Code

```powershell
# Create sandbox directory
mkdir C:\Sandbox\Genie\Backend -Force

# Copy source from existing location or clone from repo
# Source location: C:\Cursor\Genie.Source.Code_v1\
```

### Step 2: Copy WHMCS.Net.dll (CRITICAL)

The WHMCS.Net library is a custom DLL not available on NuGet.

```powershell
# Create NuGet package folder structure
$destPath = "C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\packages\WHMCS.Net.0.4.0.0\lib\net48"
New-Item -ItemType Directory -Path $destPath -Force

# Copy from production server
Copy-Item "\\server-webapp2.istrategy.com\wwwroot\FarmGenie\Production\bin\WHMCS.Net.dll" $destPath
```

### Step 3: Fix Solution File

Remove the missing WHMCS.Net project reference from `FarmGenie.sln`:

**Remove these lines:**
```
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "WHMCS.Net", "Smart.Common.Whmcs\Smart.Common.Whmcs\WHMCS.Net.csproj", "{E60A7CDF-6F39-4A28-95CB-29D66CE98776}"
EndProject
```

Also remove all configuration entries containing GUID `E60A7CDF-6F39-4A28-95CB-29D66CE98776`.

### Step 4: Configure Web.config

**IMPORTANT**: Use hostname, NOT IP address for database connection.

```xml
<!-- CORRECT: Use hostname -->
<connectionStrings>
  <add name="FarmGenie" connectionString="Data Source=server-mssql1.istrategy.com;Initial Catalog=FarmGenie;User ID=sa;Password=neo222" />
</connectionStrings>

<!-- WRONG: IP may not route through VPN -->
<connectionStrings>
  <add name="FarmGenie" connectionString="Data Source=10.10.10.200;..." />
</connectionStrings>
```

### Step 5: Disable HTTPS Redirect for Local Development

In `Web.config`, comment out or remove the HTTPS redirect rule:

```xml
<!-- Disable for local HTTP development -->
<!-- <rule name="HTTPS Redirect" ...> -->
```

### Step 6: Unload Problematic Projects (if needed)

In Visual Studio, right-click and "Unload Project" for:
- `Test.FarmGenie` (test project with missing packages)
- `Smart.Twilio` (if build errors persist)

### Step 7: Build Solution

1. Open `FarmGenie.sln` in Visual Studio 2022
2. Right-click Solution → Restore NuGet Packages
3. Build → Build Solution (Ctrl+Shift+B)
4. Set `Smart.Dashboard` as Startup Project

---

## Angular Agent App Setup

The Angular Agent app is pre-compiled. Copy from production:

```powershell
# Copy compiled Angular app from production
$prodAgent = "\\server-webapp2.istrategy.com\wwwroot\FarmGenie\Production\agent"
$localAgent = "C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Dashboard\agent"

Copy-Item "$prodAgent\*" $localAgent -Recurse -Force
```

**Note**: If you need to modify the Angular source:
- Location: `Smart.NG.Agent` folder
- Requires Node.js 14.x
- Run `npm install` then `ng build`

---

## Genie Cloud Setup

### Step 1: Set Node.js Version

```powershell
nvm install 18
nvm use 18
```

### Step 2: Install Dependencies

```powershell
cd "C:\Sandbox\Genie\Cloud\GenieCLOUD\genie-cloud\genie-api"
npm install
```

### Step 3: Configure AWS Credentials

Create `C:\Users\<username>\.aws\credentials`:

```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
region = us-west-1
```

### Step 4: Run Local Server

```powershell
npm run dev
```

Server runs at: `http://localhost:3001`

---

## Running the Sandbox

### Quick Start Script

```powershell
# Start FarmGenie Sandbox
# Run this from PowerShell

# 1. Ensure VPN is connected
Write-Host "Make sure SonicWall VPN is connected!" -ForegroundColor Yellow

# 2. Start IIS Express for FarmGenie
cd "C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie"
& "C:\Program Files (x86)\IIS Express\iisexpress.exe" /config:".vs\FarmGenie\config\applicationhost.config" /site:Smart.Dashboard

# FarmGenie will be available at: http://localhost:38949
```

### Access URLs

| Application | URL | Notes |
|-------------|-----|-------|
| FarmGenie Dashboard | http://localhost:38949 | Main app |
| Agent Dashboard | http://localhost:38949/agent | Angular SPA |
| Genie Cloud API | http://localhost:3001 | Requires AWS credentials |

### Test Login

- **Username**: shundley
- **Password**: 1ppINSAyay$
- **Role**: Super User (can impersonate any user)

---

## Known Issues & Solutions

### Issue 1: WHMCS.Net.dll Missing

**Symptom**: Build fails with "WHMCS.Net not found"

**Solution**: Copy DLL from production server to packages folder (see Step 2 above)

### Issue 2: Database Connection Fails

**Symptom**: SQL timeout or connection refused

**Solutions**:
1. Verify VPN is connected (SonicWall)
2. Use `server-mssql1.istrategy.com` NOT `10.10.10.200`
3. Test connection: `Test-NetConnection -ComputerName server-mssql1.istrategy.com -Port 1433`

### Issue 3: Login Redirect Loop

**Symptom**: Login succeeds but redirects back to login

**Solution**: Disable HTTPS redirect in Web.config (production expects HTTPS, local uses HTTP)

### Issue 4: Agent Dashboard 404

**Symptom**: `/agent` returns "Resource not found"

**Solution**: Copy Angular app from production (see Angular Agent App Setup)

### Issue 5: Twilio NullReferenceException

**Symptom**: Exception on startup related to Twilio config

**Solution**: Either:
- Copy production Smart.Twilio.dll to bin folder
- Or unload Smart.Twilio project from solution

### Issue 6: WebApplication.targets Missing

**Symptom**: Command-line build fails for Smart.Dashboard

**Solution**: Must use full Visual Studio (not just Build Tools) for web projects

---

## Troubleshooting Guide

### Check VPN Connection
```powershell
Test-NetConnection -ComputerName server-mssql1.istrategy.com -Port 1433
# Should show: TcpTestSucceeded: True
```

### Check IIS Express Status
```powershell
Get-Process iisexpress -ErrorAction SilentlyContinue
netstat -ano | findstr ":38949"
```

### View Application Logs
```powershell
# IIS Express logs
Get-Content "$env:USERPROFILE\Documents\IISExpress\Logs\*.log" -Tail 50
```

### Reset Sandbox
```powershell
# Kill IIS Express
Stop-Process -Name iisexpress -Force -ErrorAction SilentlyContinue

# Clean build folders
Remove-Item "C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Dashboard\bin" -Recurse -Force
Remove-Item "C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Dashboard\obj" -Recurse -Force

# Rebuild in Visual Studio
```

---

## File Locations Reference

| Component | Location |
|-----------|----------|
| FarmGenie Solution | `C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\FarmGenie.sln` |
| Web.config | `C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config` |
| Angular Agent | `C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Dashboard\agent\` |
| WHMCS.Net DLL | `C:\Sandbox\Genie\Backend\...\packages\WHMCS.Net.0.4.0.0\lib\net48\WHMCS.Net.dll` |
| Genie Cloud | `C:\Sandbox\Genie\Cloud\GenieCLOUD\genie-cloud\genie-api\` |
| IIS Express Config | `C:\Sandbox\Genie\Backend\...\Smart.Web.FarmGenie\.vs\FarmGenie\config\applicationhost.config` |

---

## Production Server Reference

| Server | Purpose | Path |
|--------|---------|------|
| server-webapp2 | Web applications | `\\server-webapp2.istrategy.com\wwwroot\FarmGenie\` |
| server-mssql1 | SQL Server | Port 1433, User: sa |

### Production Folders
```
\\server-webapp2.istrategy.com\wwwroot\FarmGenie\
├── Production\     ← Live site
├── Stage\          ← Testing environment  
└── Dev\            ← Development (if exists)
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/12/2025 | Initial setup guide |
| 2.0 | 12/13/2025 | Complete rewrite after successful setup. Added WHMCS fix, database hostname fix, HTTPS disable, Angular copy, troubleshooting guide. |

---

## Next Steps / Pending Items

- [ ] **Genie Cloud**: Waiting for AWS credentials from IT
- [ ] **Source Control SOP**: Document Git workflow for team
- [ ] **Stage Environment**: Test deployment to Stage before Production

