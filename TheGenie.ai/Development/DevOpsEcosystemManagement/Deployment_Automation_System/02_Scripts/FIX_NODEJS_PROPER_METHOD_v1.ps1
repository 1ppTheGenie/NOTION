# Fix Node.js Task - Proper Method (NodeTool Task)
# Version: 1.0
# Purpose: Replace Command Line workaround with proper "Use Node.js version" task

$org = "oneparkplace"
$project = "SMART"
$buildDefinitionId = 5
$pat = "[AZURE_DEVOPS_PAT_TOKEN]"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIXING NODE.JS TASK - PROPER METHOD" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

# Step 1: Get current pipeline definition
Write-Host "Step 1: Getting current pipeline definition..." -ForegroundColor Cyan
$getUrl = "https://dev.azure.com/$org/$project/_apis/build/definitions/$buildDefinitionId" + "?api-version=7.1"

try {
    $pipeline = Invoke-RestMethod -Uri $getUrl -Method Get -Headers $headers
    Write-Host "[OK] Pipeline retrieved (Revision: $($pipeline.revision))" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to get pipeline: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Find and remove Command Line workaround task
Write-Host ""
Write-Host "Step 2: Removing Command Line workaround task..." -ForegroundColor Cyan
$buildPhase = $pipeline.process.phases[0]
$removedCount = 0

$newSteps = @()
foreach ($step in $buildPhase.steps) {
    # Check if this is the Command Line workaround (by display name or task ID)
    if ($step.displayName -like "*Install Node.js*" -and 
        $step.task.id -eq "d9bafed4-0b18-4f58-968d-86655b4d2ce9") {
        Write-Host "  [WARN] Removing workaround task: $($step.displayName)" -ForegroundColor Yellow
        $removedCount++
        # Skip this step (don't add it to newSteps)
    } else {
        $newSteps += $step
    }
}

if ($removedCount -eq 0) {
    Write-Host "  [INFO] No Command Line workaround found (may have been removed already)" -ForegroundColor Gray
} else {
    Write-Host "  [OK] Removed $removedCount workaround task(s)" -ForegroundColor Green
    $buildPhase.steps = $newSteps
}

# Step 3: Check if NodeTool task already exists
Write-Host ""
Write-Host "Step 3: Checking for existing NodeTool task..." -ForegroundColor Cyan
$nodeToolExists = $false
$nodeToolIndex = -1

for ($i = 0; $i -lt $buildPhase.steps.Count; $i++) {
    if ($buildPhase.steps[$i].task.id -eq "31c75bbb-bcdf-4706-8d7c-4da6a1959bc2") {
        $nodeToolExists = $true
        $nodeToolIndex = $i
        Write-Host "  [WARN] NodeTool task already exists at index $i" -ForegroundColor Yellow
        Write-Host "  [INFO] Display Name: $($buildPhase.steps[$i].displayName)" -ForegroundColor Gray
        break
    }
}

# Step 4: Create proper NodeTool task object
Write-Host ""
Write-Host "Step 4: Creating proper NodeTool task..." -ForegroundColor Cyan

$nodeToolTask = @{
    name = "Install Node.js 14.x"
    enabled = $true
    continueOnError = $false
    alwaysRun = $false
    timeoutInMinutes = 0
    task = @{
        id = "31c75bbb-bcdf-4706-8d7c-4da6a1959bc2"
        versionSpec = "1.*"
        definitionType = "task"
    }
    inputs = @{
        versionSpec = "14.x"
        checkLatest = "false"
    }
}

Write-Host "  [OK] NodeTool task object created" -ForegroundColor Green
Write-Host "    Task ID: $($nodeToolTask.task.id)" -ForegroundColor Gray
Write-Host "    Version Spec: $($nodeToolTask.inputs.versionSpec)" -ForegroundColor Gray

# Step 5: Find Angular build task position
Write-Host ""
Write-Host "Step 5: Finding Angular build task position..." -ForegroundColor Cyan
$angularBuildIndex = -1

for ($i = 0; $i -lt $buildPhase.steps.Count; $i++) {
    $stepName = $buildPhase.steps[$i].displayName
    if ($stepName -like "*Angular*" -or 
        $stepName -like "*npm*build*" -or
        $stepName -like "*Build Angular*") {
        $angularBuildIndex = $i
        Write-Host "  [OK] Found Angular build task at index $i : $stepName" -ForegroundColor Green
        break
    }
}

if ($angularBuildIndex -eq -1) {
    Write-Host "  [WARN] Angular build task not found, will add NodeTool at beginning" -ForegroundColor Yellow
    $angularBuildIndex = 0
}

# Step 6: Insert NodeTool task before Angular build
Write-Host ""
Write-Host "Step 6: Inserting NodeTool task..." -ForegroundColor Cyan

if ($nodeToolExists) {
    Write-Host "  [WARN] NodeTool task already exists, skipping insertion" -ForegroundColor Yellow
} else {
    # Insert before Angular build
    $newSteps = @()
    for ($i = 0; $i -lt $buildPhase.steps.Count; $i++) {
        if ($i -eq $angularBuildIndex) {
            $newSteps += $nodeToolTask
            Write-Host "  [OK] Inserted NodeTool task at position $i" -ForegroundColor Green
        }
        $newSteps += $buildPhase.steps[$i]
    }
    $buildPhase.steps = $newSteps
}

# Step 7: Update pipeline
Write-Host ""
Write-Host "Step 7: Updating pipeline..." -ForegroundColor Cyan

$body = $pipeline | ConvertTo-Json -Depth 100 -Compress
$updateUrl = "https://dev.azure.com/$org/$project/_apis/build/definitions/$buildDefinitionId" + "?api-version=7.1"

try {
    $result = Invoke-RestMethod -Uri $updateUrl -Method Put -Headers $headers -Body $body
    Write-Host "  [OK] Pipeline updated successfully!" -ForegroundColor Green
    Write-Host "    New Revision: $($result.revision)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "[LINK] View pipeline: https://dev.azure.com/$org/$project/_build?definitionId=$buildDefinitionId" -ForegroundColor Cyan
} catch {
    Write-Host "  [ERROR] Failed to update pipeline: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  Response: $responseBody" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] NodeTool task added properly" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Queue a build to test" -ForegroundColor White
Write-Host "2. Verify build logs show 'Use Node.js version' task" -ForegroundColor White
Write-Host "3. Verify Node.js installation is fast - 1-2 seconds, not 30-60 seconds" -ForegroundColor White
Write-Host "4. Verify Angular build completes successfully" -ForegroundColor White
Write-Host ""
