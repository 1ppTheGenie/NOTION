# Verify Node.js Fix Status
# Version: 1.0

$org = "oneparkplace"
$project = "SMART"
$buildDefinitionId = 5
$pat = "[AZURE_DEVOPS_PAT_TOKEN]"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFYING NODE.JS FIX STATUS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

# Get current build definition
$getUrl = "https://dev.azure.com/$org/$project/_apis/build/definitions/$buildDefinitionId`?api-version=6.0"

try {
    $buildDef = Invoke-RestMethod -Uri $getUrl -Headers $headers -Method Get
    Write-Host "Retrieved build pipeline" -ForegroundColor Green
    Write-Host ""
    
    $phase = $buildDef.process.phases[0]
    
    Write-Host "Current tasks in pipeline:" -ForegroundColor Cyan
    Write-Host ""
    
    $nodeJsFound = $false
    $nodeJsVersion = ""
    
    for ($i = 0; $i -lt $phase.steps.Count; $i++) {
        $task = $phase.steps[$i]
        $taskName = $task.displayName
        $taskType = $task.task.definition.name
        
        if ($taskType -eq "NodeTool" -or $taskName -like "*Node.js*" -or $taskName -like "*Use Node*") {
            $nodeJsFound = $true
            $nodeJsVersion = $task.inputs.versionSpec
            Write-Host "   [$i] $taskName" -ForegroundColor Green
            Write-Host "       Type: $taskType" -ForegroundColor Gray
            Write-Host "       Version: $nodeJsVersion" -ForegroundColor $(if ($nodeJsVersion -eq "14.x") { "Green" } else { "Yellow" })
        } else {
            Write-Host "   [$i] $taskName" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    
    if ($nodeJsFound) {
        if ($nodeJsVersion -eq "14.x") {
            Write-Host "SUCCESS! Node.js 14.x is configured!" -ForegroundColor Green
            Write-Host "Status: FIX COMPLETE" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "WARNING: Node.js task exists but version is $nodeJsVersion (not 14.x)" -ForegroundColor Yellow
            Write-Host "Status: NEEDS UPDATE" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "Node.js task NOT FOUND in pipeline" -ForegroundColor Red
        Write-Host "Status: NOT FIXED YET" -ForegroundColor Red
        Write-Host ""
        Write-Host "The fix has NOT been applied yet." -ForegroundColor Yellow
        Write-Host "Please complete the 2-minute manual fix in the browser." -ForegroundColor Cyan
        exit 1
    }
    
} catch {
    Write-Host "ERROR: Could not verify pipeline status" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}
