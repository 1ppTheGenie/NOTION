# PLS Project - Generate Agent Instructions
# Version: 1.0
# Purpose: Generate individual agent setup instruction files

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
# Use sprint-based definitions
$agentDefsPath = Join-Path $scriptPath "AGENT_DEFINITIONS_SPRINT_v1.json"
$instructionsPath = Join-Path $scriptPath "AgentInstructions"

# Create directory
if (-not (Test-Path $instructionsPath)) {
    New-Item -ItemType Directory -Path $instructionsPath -Force | Out-Null
}

# Load agent definitions
$agentDefs = Get-Content $agentDefsPath | ConvertFrom-Json

foreach ($agent in $agentDefs.agents) {
    $instructionFile = Join-Path $instructionsPath "$($agent.id)_SETUP_INSTRUCTIONS.md"
    
    $lines = @()
    $lines += "# $($agent.name) - Setup Instructions"
    $lines += "**Version:** 1.0"
    $lines += "**Created:** $(Get-Date -Format 'MM/dd/yyyy h:mm tt')"
    $lines += "**Agent ID:** $($agent.id)"
    $lines += ""
    $lines += "---"
    $lines += ""
    $lines += "## AGENT CONFIGURATION"
    $lines += ""
        $lines += "**Name:** $($agent.name)"
        $lines += "**Role:** $($agent.role)"
        $lines += "**Sprint Focus:** $($agent.sprintFocus)"
        $lines += "**Workspace:** $($agent.workspace)"
    $lines += ""
    $lines += "---"
    $lines += ""
    $lines += "## DESCRIPTION TO COPY/PASTE"
    $lines += ""
    $lines += "When creating this agent in Cursor, use this description:"
    $lines += ""
    $lines += "``````"
        $lines += $agent.description
        $lines += ""
        $lines += "CURRENT SPRINT: Sprint 1 - MVP Foundation"
        $lines += "SPRINT FOCUS: $($agent.sprintFocus)"
        $lines += ""
        $lines += "STUDY FIRST:"
        $lines += "- Read: AgentCollaboration/PLS_AGENT_COORDINATION_MASTER_v1.md"
        $lines += "- Read: AgentCollaboration/SPRINT_MODEL_GUIDE_v1.md"
        foreach ($doc in $agent.masterDocuments) {
            if ($doc -notlike "AgentCollaboration/PLS_AGENT_COORDINATION_MASTER_v1.md") {
                $lines += "- Read: $doc"
            }
        }
        $lines += ""
        $lines += "YOUR SPRINT 1 TASKS:"
        foreach ($task in $agent.keyTasks) {
            $lines += "- $task"
        }
        $lines += ""
        $lines += "WORKSPACE: $($agent.workspace)"
        $lines += "STATUS FILE: $($agent.statusFile)"
        $deps = if ($agent.taskDependencies.Count -gt 0) { $agent.taskDependencies -join ", " } else { "None" }
        $lines += "TASK DEPENDENCIES: $deps"
        $handoffs = if ($agent.handoffsTo.Count -gt 0) { $agent.handoffsTo -join ", " } else { "None" }
        $lines += "HANDOFFS TO: $handoffs"
    $lines += ""
    $lines += "COMMUNICATION:"
    $lines += "- Use JSON message protocol: AgentCollaboration/AGENT_MESSAGE_PROTOCOL_v1.md"
    $lines += "- Update status file daily: $($agent.statusFile)"
    $lines += "- Send messages to: $handoffs"
    $lines += "``````"
    $lines += ""
    $lines += "---"
    $lines += ""
    $lines += "## SUCCESS CRITERIA"
    $lines += ""
    foreach ($criteria in $agent.successCriteria) {
        $lines += "- [ ] $criteria"
    }
    $lines += ""
    $lines += "---"
    $lines += ""
    $lines += "## KEY DOCUMENTS"
    $lines += ""
    foreach ($doc in $agent.masterDocuments) {
        $lines += "- ``$doc``"
    }
    $lines += ""
    $lines += "**Status:** Ready for Agent Creation"
    
    $lines | Set-Content $instructionFile -Encoding UTF8
    Write-Host "Created: $instructionFile" -ForegroundColor Green
}

Write-Host "`nDone! Generated $($agentDefs.agents.Count) agent instruction files." -ForegroundColor Cyan
