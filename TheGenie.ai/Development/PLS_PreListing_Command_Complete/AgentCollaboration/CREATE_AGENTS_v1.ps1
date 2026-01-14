# PLS Project - Automated Agent Creation Script
# Version: 1.0
# Created: 01/13/2026 8:45 PM
# Purpose: Generate agent configuration files and setup instructions from AGENT_DEFINITIONS_JSON_v1.json

param(
    [switch]$GenerateConfigs,
    [switch]$GenerateInstructions,
    [switch]$CreateMessageFolders
)

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = Split-Path -Parent $scriptPath
$agentDefsPath = Join-Path $scriptPath "AGENT_DEFINITIONS_JSON_v1.json"

Write-Host "🚀 PLS Agent Creation Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Load agent definitions
if (-not (Test-Path $agentDefsPath)) {
    Write-Host "❌ ERROR: Agent definitions file not found: $agentDefsPath" -ForegroundColor Red
    exit 1
}

$agentDefs = Get-Content $agentDefsPath | ConvertFrom-Json
Write-Host "✅ Loaded agent definitions: $($agentDefs.agents.Count) agents" -ForegroundColor Green
Write-Host ""

# Create message folders structure
if ($CreateMessageFolders) {
    Write-Host "📁 Creating message folders..." -ForegroundColor Yellow
    $messagesPath = Join-Path $scriptPath "Messages"
    $folders = @("handoffs", "blockers", "status_updates", "questions", "coordination")
    
    foreach ($folder in $folders) {
        $folderPath = Join-Path $messagesPath $folder
        if (-not (Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            Write-Host "  ✅ Created: Messages/$folder/" -ForegroundColor Green
        } else {
            Write-Host "  ⏭️  Exists: Messages/$folder/" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Generate individual agent configuration files
if ($GenerateConfigs) {
    Write-Host "📝 Generating agent configuration files..." -ForegroundColor Yellow
    
    $agentsConfigPath = Join-Path $scriptPath "Agents"
    if (-not (Test-Path $agentsConfigPath)) {
        New-Item -ItemType Directory -Path $agentsConfigPath -Force | Out-Null
    }
    
    foreach ($agent in $agentDefs.agents) {
        $agentConfig = @{
            id = $agent.id
            name = $agent.name
            role = $agent.role
            description = $agent.description
            workspace = $agent.workspace
            masterDocuments = $agent.masterDocuments
            statusFile = $agent.statusFile
            phase = $agent.phase
            dependencies = $agent.dependencies
            handoffsTo = $agent.handoffsTo
            keyTasks = $agent.keyTasks
            successCriteria = $agent.successCriteria
        }
        
        $configFile = Join-Path $agentsConfigPath "$($agent.id).json"
        $agentConfig | ConvertTo-Json -Depth 10 | Set-Content $configFile -Encoding UTF8
        Write-Host "  ✅ Created: Agents/$($agent.id).json" -ForegroundColor Green
    }
    Write-Host ""
}

# Generate setup instructions for each agent
if ($GenerateInstructions) {
    Write-Host "📋 Generating agent setup instructions..." -ForegroundColor Yellow
    
    $instructionsPath = Join-Path $scriptPath "AgentInstructions"
    if (-not (Test-Path $instructionsPath)) {
        New-Item -ItemType Directory -Path $instructionsPath -Force | Out-Null
    }
    
    foreach ($agent in $agentDefs.agents) {
        $instructionFile = Join-Path $instructionsPath "$($agent.id)_SETUP_INSTRUCTIONS.md"
        
        $masterDocsList = $agent.masterDocuments | ForEach-Object { "- Read: $_" }
        $keyTasksList = $agent.keyTasks | ForEach-Object { "- $_" }
        $successCriteriaList = $agent.successCriteria | ForEach-Object { "- [ ] $_" }
        $keyDocsList = $agent.masterDocuments | ForEach-Object { "- ``$_``" }
        
        $instructions = @"
# $($agent.name) - Setup Instructions
**Version:** 1.0  
**Created:** $(Get-Date -Format "MM/dd/yyyy h:mm tt")  
**Agent ID:** $($agent.id)

---

## AGENT CONFIGURATION

**Name:** ``$($agent.name)``  
**Role:** $($agent.role)  
**Phase:** $($agent.phase)  
**Workspace:** ``$($agent.workspace)``

---

## DESCRIPTION TO COPY/PASTE

When creating this agent in Cursor, use this description:

```
$($agent.description)

STUDY FIRST:
$($masterDocsList -join "`n")

YOUR ROLE:
$($keyTasksList -join "`n")

WORKSPACE: $($agent.workspace)
STATUS FILE: $($agent.statusFile)
PHASE: $($agent.phase)
DEPENDENCIES: $($agent.dependencies -join ", ")
HANDOFFS TO: $($agent.handoffsTo -join ", ")

COMMUNICATION:
- Use JSON message protocol: AgentCollaboration/AGENT_MESSAGE_PROTOCOL_v1.md
- Update status file daily: $($agent.statusFile)
- Send messages to: $($agent.handoffsTo -join ", ")
```

---

## SUCCESS CRITERIA

$($successCriteriaList -join "`n")

---

## KEY DOCUMENTS

$($keyDocsList -join "`n")

---

**Status:** Ready for Agent Creation

"@
        
        Set-Content $instructionFile $instructions -Encoding UTF8
        Write-Host "  ✅ Created: AgentInstructions/$($agent.id)_SETUP_INSTRUCTIONS.md" -ForegroundColor Green
    }
    Write-Host ""
}

# Generate master setup summary
Write-Host "📊 Generating master setup summary..." -ForegroundColor Yellow
$summaryFile = Join-Path $scriptPath "AGENT_SETUP_SUMMARY_v1.md"

$agentsList = $agentDefs.agents | ForEach-Object { 
    "### $($_.name)`n**ID:** $($_.id)  `n**Phase:** $($_.phase)  `n**Instructions:** ``AgentInstructions/$($_.id)_SETUP_INSTRUCTIONS.md``  `n`n" 
}
$checklist = $agentDefs.agents | ForEach-Object { "- [ ] $($_.name) created and configured" }

$summary = @"
# PLS Project - Agent Setup Summary
**Version:** 1.0  
**Created:** $(Get-Date -Format "MM/dd/yyyy h:mm tt")  
**Generated By:** CREATE_AGENTS_v1.ps1

---

## QUICK START

1. **Run this script:** ``.\CREATE_AGENTS_v1.ps1 -GenerateConfigs -GenerateInstructions -CreateMessageFolders``
2. **Open Cursor** and navigate to Agents sidebar
3. **For each agent below**, click "New Agent" and copy/paste the description
4. **Verify** all agents are created and configured

---

## AGENTS TO CREATE

$($agentsList -join "`n")

---

## GENERATED FILES

- **Agent Configs:** ``AgentCollaboration/Agents/*.json``
- **Setup Instructions:** ``AgentCollaboration/AgentInstructions/*_SETUP_INSTRUCTIONS.md``
- **Message Folders:** ``AgentCollaboration/Messages/{handoffs,blockers,status_updates,questions,coordination}/``

---

## VERIFICATION CHECKLIST

$($checklist -join "`n")

---

**Status:** Generated

"@

Set-Content $summaryFile $summary -Encoding UTF8
Write-Host "  ✅ Created: AGENT_SETUP_SUMMARY_v1.md" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "✅ COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review generated files in AgentCollaboration/" -ForegroundColor White
Write-Host "  2. Open Cursor and create agents using the instructions" -ForegroundColor White
Write-Host "  3. Verify all agents are created and configured" -ForegroundColor White
Write-Host ""
