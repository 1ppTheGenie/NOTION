# 🚀 Production Deployment Agent Installation

## Document Info
- **Created:** December 29, 2025
- **Author:** Steve Hundley + Cursor Agent
- **Server:** SERVER-WEBAPP2
- **Time Required:** 5 minutes

---

## Overview

SERVER-WEBAPP2 already has the **staging** agent installed. We need to add the **production** agent to the same server.

---

## Steps for Andrew

### Step 1: RDP into SERVER-WEBAPP2

Connect to the server (same one where staging agent runs)

### Step 2: Open PowerShell as Administrator

Right-click PowerShell → **"Run as Administrator"**

### Step 3: Run This Script

Copy and paste this entire block:

```powershell
$ErrorActionPreference="Stop";If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")){ throw "Run command in an administrator PowerShell prompt"};If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))){ throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." };If(-NOT (Test-Path $env:SystemDrive\'azagent')){mkdir $env:SystemDrive\'azagent'}; cd $env:SystemDrive\'azagent'; for($i=1; $i -lt 100; $i++){$destFolder="A"+$i.ToString();if(-NOT (Test-Path ($destFolder))){mkdir $destFolder;cd $destFolder;break;}}; $agentZip="$PWD\agent.zip";$DefaultProxy=[System.Net.WebRequest]::DefaultWebProxy;$securityProtocol=@();$securityProtocol+=[Net.ServicePointManager]::SecurityProtocol;$securityProtocol+=[Net.SecurityProtocolType]::Tls12;[Net.ServicePointManager]::SecurityProtocol=$securityProtocol;$WebClient=New-Object Net.WebClient; $Uri='https://download.agent.dev.azure.com/agent/4.266.2/vsts-agent-win-x64-4.266.2.zip';if($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri))){$WebClient.Proxy= New-Object Net.WebProxy($DefaultProxy.GetProxy($Uri).OriginalString, $True);}; $WebClient.DownloadFile($Uri, $agentZip);Add-Type -AssemblyName System.IO.Compression.FileSystem;[System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD");.\config.cmd --deploymentpool --deploymentpoolname "SMART-Production" --agent $env:COMPUTERNAME --runasservice --work '_work' --url 'https://oneparkplace.visualstudio.com/'; Remove-Item $agentZip;
```

### Step 4: Answer the Prompts

When the script asks:

| Prompt | Answer |
|--------|--------|
| Authentication type | Press Enter (default: Integrated) |
| Service account | Press Enter (default: NT AUTHORITY\SYSTEM) |

### Step 5: Verify Success

1. Go to: https://oneparkplace.visualstudio.com/_settings/deploymentpools
2. Click **SMART-Production**
3. You should see **SERVER-WEBAPP2** listed as "Online"

---

## After Completion

Notify Steve that the agent is installed. He will then configure the deployment pipeline.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Not running as Administrator" | Close PowerShell, right-click, "Run as Administrator" |
| Authentication fails | Create a PAT at https://oneparkplace.visualstudio.com/_usersSettings/tokens |
| Agent already exists | The script auto-creates A1, A2, etc. folders - this is normal |

---

## Current State After Install

| Pool | Server | Status |
|------|--------|--------|
| SMART-Staging | SERVER-WEBAPP2 | ✅ Online |
| SMART-Production | SERVER-WEBAPP2 | ✅ Online (after this install) |

