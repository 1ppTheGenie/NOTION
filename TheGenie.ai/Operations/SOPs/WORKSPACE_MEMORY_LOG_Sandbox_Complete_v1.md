# Workspace Memory Log - Sandbox Setup Complete

**Session Date:** 12/13/2025  
**Session Duration:** Extended (~3+ hours)  
**Status:** FarmGenie Sandbox WORKING, Genie Cloud PENDING AWS credentials

---

## Session Summary

Successfully completed the TheGenie.ai local development sandbox setup. The FarmGenie backend and Angular Agent dashboard are fully operational. Genie Cloud setup is complete but awaiting AWS credentials from IT.

---

## What Was Accomplished

### ✅ FarmGenie Backend (.NET 4.8)
- Resolved WHMCS.Net.dll missing dependency by copying from production
- Fixed solution file by removing missing project reference
- Configured database connection to use hostname instead of IP
- Disabled HTTPS redirect for local HTTP development
- Unloaded problematic Smart.Twilio project
- Successfully built and running on IIS Express

### ✅ Angular Agent Dashboard
- Copied 352 compiled files from production server
- Agent dashboard fully functional at /agent route
- All navigation and features working

### ✅ Genie Cloud (Node.js 18)
- Installed Node.js 18.x via NVM
- Installed npm dependencies (128 packages)
- Created local development server (local-server.js)
- Added npm run dev script
- **BLOCKED**: Awaiting AWS credentials from IT

---

## Key Technical Discoveries

### 1. Database Connection
- **DO NOT USE**: `10.10.10.200` (IP doesn't route through VPN)
- **USE INSTEAD**: `server-mssql1.istrategy.com` (hostname resolves correctly)

### 2. WHMCS.Net Dependency
- Custom library, not available on public NuGet
- Must be copied from: `\\server-webapp2.istrategy.com\wwwroot\FarmGenie\Production\bin\WHMCS.Net.dll`
- Place in: `packages\WHMCS.Net.0.4.0.0\lib\net48\`

### 3. HTTPS vs HTTP
- Production uses HTTPS with redirect rules
- Local development uses HTTP
- Must disable HTTPS redirect in Web.config for local to work

### 4. Angular Agent App
- Pre-compiled, no need to build locally
- Simply copy from production `/agent/` folder
- Uses Angular 9, requires Node 14.x if rebuilding

### 5. Genie Cloud Architecture
- Runs on AWS Lambda (serverless)
- Uses AWS S3 for storage, SQS for messaging
- Local development requires AWS credentials
- Cannot use GitHub secrets (write-only)

---

## Files Created/Modified

### New Files Created
| File | Purpose |
|------|---------|
| `C:\Cursor\TheGenie_Sandbox_Setup_SOP_v2.md` | Complete setup SOP with fixes |
| `C:\Cursor\GENIE_CLOUD_SETUP_GUIDE_v1.md` | Genie Cloud specific setup guide |
| `genie-api\local-server.js` | Local development server for Genie Cloud |
| `genie-api\env-template.txt` | Environment variable template |

### Files Modified
| File | Changes |
|------|---------|
| `FarmGenie.sln` | Removed WHMCS.Net project reference |
| `Smart.Core.csproj` | Added WHMCS.Net DLL reference |
| `Web.config` | Updated DB connection, disabled HTTPS redirect |
| `genie-api\package.json` | Added dev/start scripts |
| `AuthorizeTwilioRequestAttribute.cs` | Added null checks (later reverted by using prod DLL) |

---

## Access Information

### FarmGenie Sandbox
- **URL**: http://localhost:38949
- **Agent Dashboard**: http://localhost:38949/agent
- **Login**: shundley / 1ppINSAyay$

### Start Command
```powershell
cd "C:\Sandbox\Genie\Backend\Genie.Source.Code\Web\Smart.Web.FarmGenie"
& "C:\Program Files (x86)\IIS Express\iisexpress.exe" /config:".vs\FarmGenie\config\applicationhost.config" /site:Smart.Dashboard
```

### Genie Cloud (when AWS credentials available)
- **URL**: http://localhost:3001
- **Start**: `nvm use 18 && cd genie-api && npm run dev`

---

## Pending Items

| Item | Status | Blocker |
|------|--------|---------|
| Genie Cloud AWS credentials | Waiting | Need from IT |
| Source Control SOP | Not started | - |
| Stage deployment testing | Not started | - |

---

## Lessons Learned

1. **Always check actual network routing** - IP addresses may not route through VPN even when VPN is connected
2. **Check production for custom DLLs** - Not everything is on NuGet
3. **Pre-compiled Angular apps save time** - No need to rebuild if not modifying
4. **GitHub secrets are write-only** - Can't retrieve values after creation
5. **IIS Express configs are in .vs folder** - Hidden folder with project-specific settings

---

## Server Ecosystem Reference

| Server | Role | Access |
|--------|------|--------|
| server-webapp2.istrategy.com | Web apps (IIS) | UNC path for files |
| server-mssql1.istrategy.com | SQL Server | Port 1433, sa/neo222 |
| AWS Lambda (us-west-1) | Genie Cloud | Need credentials |
| GitHub (1parkplace) | Source control | Connected via Cursor |

---

## Next Session Priorities

1. **Get AWS credentials from IT** for Genie Cloud
2. **Test full workflow**: Login → Impersonate → View Dashboard → Create Content
3. **Set up deployment workflow** to Stage environment
4. **Create Source Control SOP** for team collaboration

---

## Contact Information

- **IT Support**: For VPN, database, and AWS credentials
- **DevOps**: For GitHub secrets and deployment access
- **AWS Account**: 199352526440 (genie-hub-active, us-west-1)

