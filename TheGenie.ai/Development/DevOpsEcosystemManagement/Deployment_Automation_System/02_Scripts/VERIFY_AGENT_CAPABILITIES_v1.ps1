# Verify Agent Capabilities and Find Correct Node.js Task
# Version: 1.0

$org = "oneparkplace"
$project = "SMART"
$buildDefinitionId = 5
$pat = "[AZURE_DEVOPS_PAT_TOKEN]"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFYING AGENT CAPABILITIES" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

$getUrl = "https://dev.azure.com/$org/$project/_apis/build/definitions/$buildDefinitionId" + "?api-version=6.0"

try {
    $buildDef = Invoke-RestMethod -Uri $getUrl -Headers $headers -Method Get
    
    Write-Host "Build Pipeline Configuration:" -ForegroundColor Cyan
    Write-Host ""
    
    # Check agent specification
    if ($buildDef.process.agentSpecification) {
        Write-Host "Agent Specification: $($buildDef.process.agentSpecification)" -ForegroundColor White
        if ($buildDef.process.agentSpecification -like "*windows-2022*" -or $buildDef.process.agentSpecification -like "*windows-2019*") {
            Write-Host "  Type: Microsoft-hosted agent" -ForegroundColor Green
            Write-Host "  Admin Rights: YES (Microsoft-hosted agents have admin rights)" -ForegroundColor Green
            Write-Host "  Node.js Available: YES (pre-installed)" -ForegroundColor Green
        }
    } else {
        Write-Host "Agent Specification: Not set (may use default)" -ForegroundColor Yellow
    }
    
    # Check process type
    Write-Host ""
    Write-Host "Process Type: $($buildDef.process.type)" -ForegroundColor White
    if ($buildDef.process.type -eq 1) {
        Write-Host "  Type: Classic Build Pipeline" -ForegroundColor Green
    }
    
    # Check existing tasks for Node.js tool installer patterns
    Write-Host ""
    Write-Host "Analyzing existing tasks for Node.js tool installer..." -ForegroundColor Cyan
    $phase = $buildDef.process.phases[0]
    
    Write-Host ""
    Write-Host "Current tasks and their task IDs:" -ForegroundColor Cyan
    foreach ($step in $phase.steps) {
        $taskId = $step.task.definition.id
        $taskName = if ($step.task.definition.name) { $step.task.definition.name } else { "Unknown" }
        Write-Host "  $($step.displayName)" -ForegroundColor White
        Write-Host "    Task ID: $taskId" -ForegroundColor Gray
        Write-Host "    Task Name: $taskName" -ForegroundColor Gray
        
        # Check if this is a Node.js related task
        if ($taskName -like "*Node*" -or $step.displayName -like "*Node*") {
            Write-Host "    >>> NODE.JS RELATED TASK FOUND <<<" -ForegroundColor Green
        }
    }
    
    # Check if Node.js tool installer task exists in pipeline
    $nodeJsTask = $phase.steps | Where-Object { 
        $_.task.definition.id -eq "116e85a8-8f11-4f7b-9a2c-6195899512ea" -or
        $_.task.definition.name -eq "NodeTool" -or
        $_.displayName -like "*Node.js*"
    }
    
    if ($nodeJsTask) {
        Write-Host ""
        Write-Host "Node.js task found in pipeline!" -ForegroundColor Green
        Write-Host "  Display Name: $($nodeJsTask.displayName)" -ForegroundColor White
        Write-Host "  Task ID: $($nodeJsTask.task.definition.id)" -ForegroundColor White
        Write-Host "  Task Name: $($nodeJsTask.task.definition.name)" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "No Node.js tool installer task found in pipeline" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
