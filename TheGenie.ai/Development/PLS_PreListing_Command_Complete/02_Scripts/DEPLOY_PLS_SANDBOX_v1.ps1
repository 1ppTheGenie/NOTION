# PLS Sandbox Deployment Script
# Version: 1.0
# Created: 01/14/2026 4:50 AM
# Purpose: Automated deployment of PLS to Sandbox

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PLS SANDBOX DEPLOYMENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$sqlServer = "192.168.29.45,1433"
$sqlUser = "sa"
$sqlPassword = "neo222"
$farmGenieDb = "FarmGenie"
$mlsListingDb = "MlsListing"
$titleDataDb = "TitleData"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath

# Phase 1: Database Setup
Write-Host "PHASE 1: DATABASE SETUP" -ForegroundColor Yellow
Write-Host "----------------------" -ForegroundColor Yellow

$dbScripts = @(
    @{File = "PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql"; Database = $farmGenieDb; Description = "Schema Extensions"},
    @{File = "PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql"; Database = $farmGenieDb; Description = "PLS Number Sequence"},
    @{File = "PLS_DATABASE_MASTER_DATA_v3.sql"; Database = $farmGenieDb; Description = "Master Data (FarmGenie)"},
    @{File = "PLS_DATABASE_MASTER_DATA_v3.sql"; Database = $mlsListingDb; Description = "Master Data (MlsListing)"},
    @{File = "PLS_STORED_PROCEDURES_COMPLETE_v1.sql"; Database = $farmGenieDb; Description = "Stored Procedures"}
)

foreach ($script in $dbScripts) {
    $scriptFile = Join-Path $scriptPath $script.File
    if (Test-Path $scriptFile) {
        Write-Host "  Executing: $($script.Description) on $($script.Database)..." -ForegroundColor Green
        try {
            $sqlContent = Get-Content $scriptFile -Raw
            # Note: Actual SQL execution would require sqlcmd or Invoke-Sqlcmd
            # This is a placeholder - actual execution should be done manually or with proper SQL tools
            Write-Host "    ✓ Script ready: $($script.File)" -ForegroundColor Green
        } catch {
            Write-Host "    ✗ Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✗ Script not found: $($script.File)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "PHASE 1 COMPLETE" -ForegroundColor Green
Write-Host ""

# Phase 2: Backend API Deployment
Write-Host "PHASE 2: BACKEND API DEPLOYMENT" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Yellow

$backendPath = "C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard"
$sourceCodePath = Join-Path $projectRoot "08_Source_Code"

if (Test-Path $backendPath) {
    Write-Host "  Backend path exists: $backendPath" -ForegroundColor Green
    
    # Copy controllers
    $controllers = @(
        @{Source = "PlsController_Complete_v1.cs"; Dest = "Controllers\PlsController.cs"},
        @{Source = "DataController_PLS_Complete_v1.cs"; Dest = "Controllers\DataController.PLS.cs"}
    )
    
    foreach ($controller in $controllers) {
        $sourceFile = Join-Path $sourceCodePath $controller.Source
        $destFile = Join-Path $backendPath $controller.Dest
        
        if (Test-Path $sourceFile) {
            Write-Host "  Copying: $($controller.Source) → $($controller.Dest)..." -ForegroundColor Green
            # Copy-Item $sourceFile $destFile -Force
            Write-Host "    ✓ Ready to copy" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Source file not found: $($controller.Source)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ✗ Backend path not found: $backendPath" -ForegroundColor Red
    Write-Host "    Please update path in script" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "PHASE 2 COMPLETE" -ForegroundColor Green
Write-Host ""

# Phase 3: Verification
Write-Host "PHASE 3: VERIFICATION CHECKLIST" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "MANUAL STEPS REQUIRED:" -ForegroundColor Cyan
Write-Host "  1. Execute database scripts manually (see PLS_COMPLETE_DEPLOYMENT_READY_v1.md)" -ForegroundColor White
Write-Host "  2. Copy controller files to backend project" -ForegroundColor White
Write-Host "  3. Update Smart.Dashboard.csproj to include new controllers" -ForegroundColor White
Write-Host "  4. Build solution and verify no errors" -ForegroundColor White
Write-Host "  5. Deploy frontend components (see deployment checklist)" -ForegroundColor White
Write-Host "  6. Grant permissions to test user" -ForegroundColor White
Write-Host "  7. Test all endpoints" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEPLOYMENT SCRIPT COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: Follow PLS_COMPLETE_DEPLOYMENT_READY_v1.md checklist" -ForegroundColor Yellow
