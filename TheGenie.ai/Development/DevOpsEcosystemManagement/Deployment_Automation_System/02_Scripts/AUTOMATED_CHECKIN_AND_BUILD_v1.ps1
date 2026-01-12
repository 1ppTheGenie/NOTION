# Automated Check-In and Build Trigger
# Version: 1.0
# Created: 01/12/2026 12:40 AM
# Author: Danny (Deployment Specialist)
# Purpose: Check in code via tf.exe, then trigger build via Azure DevOps REST API

param(
    [Parameter(Mandatory=$false)]
    [string]$CheckInComment,
    
    [Parameter(Mandatory=$false)]
    [string]$FormPath = "D:\Cursor\TheGenie.ai\Development\DevOpsEcosystemManagement\Monitoring\Server Troubleshooting\CheckInLogs\CHECKIN_WorkflowActionProcessorFix_20260112_v1.md"
)

$org = "oneparkplace"
$project = "SMART"
$buildDefinitionId = 5
$pat = "[AZURE_DEVOPS_PAT_TOKEN]"

Write-Host "=== AUTOMATED CHECK-IN AND BUILD ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get check-in comment from form if not provided
if ([string]::IsNullOrEmpty($CheckInComment)) {
    Write-Host "Reading check-in comment from form..." -ForegroundColor Yellow
    $formContent = Get-Content $FormPath -Raw
    if ($formContent -match '```\s*Fix:.*?Status:.*?```') {
        $CheckInComment = $matches[0] -replace '```', '' -replace '\r?\n', "`n"
        Write-Host "✅ Check-in comment extracted from form" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Could not extract comment from form, using default" -ForegroundColor Yellow
        $CheckInComment = "WorkflowActionProcessor Fix - InProgress Actions Blocking Workflow`n`nSee check-in form for complete details."
    }
}

# Step 2: Find tf.exe
Write-Host "Locating tf.exe..." -ForegroundColor Yellow
$vsPaths = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2026\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
)

$tfExe = $null
foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        $tfExe = $path
        Write-Host "✅ Found tf.exe: $path" -ForegroundColor Green
        break
    }
}

if (-not $tfExe) {
    Write-Host "❌ ERROR: tf.exe not found" -ForegroundColor Red
    Write-Host "Cannot check in code without tf.exe" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please check in manually via Visual Studio:" -ForegroundColor Yellow
    Write-Host "1. Open Visual Studio" -ForegroundColor White
    Write-Host "2. Go to Team Explorer → Pending Changes" -ForegroundColor White
    Write-Host "3. Paste check-in comment from form" -ForegroundColor White
    Write-Host "4. Click 'Check In'" -ForegroundColor White
    Write-Host "5. Note the changeset number" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run this script again with -ChangesetNumber parameter to trigger build" -ForegroundColor Yellow
    exit 1
}

# Step 3: Check pending changes
Write-Host ""
Write-Host "Checking pending changes..." -ForegroundColor Yellow
cd "C:\Sandbox\1ppDevelopment"

$pendingStatus = & $tfExe status /noprompt 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Warning: tf status returned exit code $LASTEXITCODE" -ForegroundColor Yellow
    Write-Host "Output: $pendingStatus" -ForegroundColor Gray
}

$pendingFiles = $pendingStatus | Where-Object { $_ -match '^\s+\$/' }
if ($pendingFiles.Count -eq 0) {
    Write-Host "⚠️ No pending changes found" -ForegroundColor Yellow
    Write-Host "Files may already be checked in, or workspace may not be mapped" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Checking workspace status..." -ForegroundColor Yellow
    & $tfExe workspaces /noprompt 2>&1 | Select-Object -First 10
    exit 1
}

Write-Host "✅ Found pending changes:" -ForegroundColor Green
$pendingFiles | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

# Step 4: Check in with comment
Write-Host ""
Write-Host "Checking in code..." -ForegroundColor Yellow
Write-Host "Comment length: $($CheckInComment.Length) characters" -ForegroundColor Gray

# Save comment to temp file (tf.exe has command line length limits)
$tempCommentFile = [System.IO.Path]::GetTempFileName()
$CheckInComment | Out-File -FilePath $tempCommentFile -Encoding UTF8

try {
    $checkinResult = & $tfExe checkin /comment:"@$tempCommentFile" /noprompt 2>&1
    $checkinOutput = $checkinResult -join "`n"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Check-in successful!" -ForegroundColor Green
        
        # Extract changeset number
        if ($checkinOutput -match 'Changeset\s+(\d+)') {
            $changesetNumber = $matches[1]
            Write-Host "✅ Changeset: $changesetNumber" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Could not extract changeset number from output" -ForegroundColor Yellow
            Write-Host "Output: $checkinOutput" -ForegroundColor Gray
            $changesetNumber = "UNKNOWN"
        }
    } else {
        Write-Host "❌ Check-in failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Output: $checkinOutput" -ForegroundColor Red
        Remove-Item $tempCommentFile -ErrorAction SilentlyContinue
        exit 1
    }
} catch {
    Write-Host "❌ ERROR during check-in: $_" -ForegroundColor Red
    Remove-Item $tempCommentFile -ErrorAction SilentlyContinue
    exit 1
} finally {
    Remove-Item $tempCommentFile -ErrorAction SilentlyContinue
}

# Step 5: Update form with changeset number
Write-Host ""
Write-Host "Updating check-in form with changeset number..." -ForegroundColor Yellow
$formContent = Get-Content $FormPath -Raw
$formContent = $formContent -replace '\[Will be assigned after check-in - Changeset #\]', $changesetNumber
$formContent = $formContent -replace 'Changeset \[NUMBER\]', "Changeset $changesetNumber"
$formContent = $formContent -replace 'Check-In Completed.*?`\[YES/NO\]', "Check-In Completed: `YES"
$formContent = $formContent -replace 'Changeset Number.*?`\[Changeset #\]', "Changeset Number: `$changesetNumber"
$formContent = $formContent -replace 'Check-In Date/Time.*?`\[MM/DD/YYYY HH:MM AM/PM\]', "Check-In Date/Time: `$(Get-Date -Format 'MM/dd/yyyy hh:mm tt')"
$formContent = $formContent -replace 'Check-In Status.*?`\[SUCCESS/FAILED\]', "Check-In Status: `SUCCESS"
Set-Content -Path $FormPath -Value $formContent
Write-Host "✅ Form updated with changeset $changesetNumber" -ForegroundColor Green

# Step 6: Trigger build via Azure DevOps REST API
Write-Host ""
Write-Host "Triggering build via Azure DevOps REST API..." -ForegroundColor Yellow

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

$buildBody = @{
    definition = @{
        id = $buildDefinitionId
    }
    sourceVersion = "C$changesetNumber"
    reason = "manual"
    parameters = "{}"
} | ConvertTo-Json -Depth 10

$buildUrl = "https://dev.azure.com/$org/$project/_apis/build/builds?api-version=7.1"

try {
    $buildResponse = Invoke-RestMethod -Uri $buildUrl -Headers $headers -Method Post -Body $buildBody
    $buildId = $buildResponse.id
    $buildNumber = $buildResponse.buildNumber
    
    Write-Host "✅ Build triggered successfully!" -ForegroundColor Green
    Write-Host "  Build ID: $buildId" -ForegroundColor Cyan
    Write-Host "  Build Number: $buildNumber" -ForegroundColor Cyan
    Write-Host "  Build URL: $($buildResponse.url)" -ForegroundColor Cyan
    
    # Update form with build number
    $formContent = Get-Content $FormPath -Raw
    $formContent = $formContent -replace 'Build Number.*?`\[Will be filled after build', "Build Number: `$buildNumber"
    Set-Content -Path $FormPath -Value $formContent
    Write-Host "✅ Form updated with build number $buildNumber" -ForegroundColor Green
    
} catch {
    Write-Host "❌ ERROR triggering build: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can manually trigger the build:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://oneparkplace.visualstudio.com/SMART/_build" -ForegroundColor White
    Write-Host "2. Click 'Run pipeline' on SMART-Dashboard-Build" -ForegroundColor White
    Write-Host "3. Select changeset: C$changesetNumber" -ForegroundColor White
    Write-Host "4. Click 'Run'" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "=== COMPLETE ===" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  ✅ Check-in: Changeset $changesetNumber" -ForegroundColor White
Write-Host "  ✅ Build: $buildNumber (ID: $buildId)" -ForegroundColor White
Write-Host "  ✅ Form updated with changeset and build number" -ForegroundColor White
Write-Host ""
Write-Host "Monitor build progress:" -ForegroundColor Cyan
Write-Host "  https://oneparkplace.visualstudio.com/SMART/_build?definitionId=5" -ForegroundColor Gray
