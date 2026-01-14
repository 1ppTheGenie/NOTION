# Fix Web.config for Hybrid Authentication Approach
# Production FarmGenie for authentication (users can log in)
# Sandbox FarmGenie for PLS data (development doesn't affect production)

$webConfigPath = "C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config"

if (-not (Test-Path $webConfigPath)) {
    Write-Host "ERROR: Web.config not found at: $webConfigPath" -ForegroundColor Red
    exit 1
}

Write-Host "Loading Web.config..." -ForegroundColor Yellow
[xml]$webConfig = Get-Content $webConfigPath

# HYBRID APPROACH:
# DefaultConnection -> Production FarmGenie (for authentication - has users)
# FarmGenieConnection -> Sandbox FarmGenie (for PLS data - development only)
# MlsListingConnection -> Sandbox MlsListing (for PLS data)
# TitleDataConnection -> Production TitleData (shared data)

$requiredConnections = @(
    @{
        Name = "DefaultConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=FarmGenie;User Id=sa;Password=neo222;"
        Description = "PRODUCTION - Authentication (has users)"
    },
    @{
        Name = "FarmGenieConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;User Id=sa;Password=neo222;"
        Description = "SANDBOX - PLS data (development only)"
    },
    @{
        Name = "MlsListingConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=MlsListing_Sandbox;User Id=sa;Password=neo222;"
        Description = "SANDBOX - PLS listings (development only)"
    },
    @{
        Name = "TitleDataConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=TitleData;User Id=sa;Password=neo222;"
        Description = "PRODUCTION - Shared property data"
    }
)

Write-Host ""
Write-Host "Updating connection strings (HYBRID APPROACH)..." -ForegroundColor Yellow
Write-Host "  -> DefaultConnection: PRODUCTION (for login)" -ForegroundColor Green
Write-Host "  -> FarmGenieConnection: SANDBOX (for PLS data)" -ForegroundColor Yellow
Write-Host ""

foreach ($conn in $requiredConnections) {
    $existing = $webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq $conn.Name }
    
    if ($existing) {
        Write-Host "  Updating: $($conn.Name)" -ForegroundColor Cyan
        $existing.connectionString = $conn.ConnectionString
    } else {
        Write-Host "  Adding: $($conn.Name)" -ForegroundColor Green
        $addNode = $webConfig.CreateElement("add")
        $addNode.SetAttribute("name", $conn.Name)
        $addNode.SetAttribute("connectionString", $conn.ConnectionString)
        $webConfig.configuration.connectionStrings.AppendChild($addNode) | Out-Null
    }
}

# Save Web.config
Write-Host ""
Write-Host "Saving Web.config..." -ForegroundColor Yellow
$webConfig.Save($webConfigPath)

Write-Host ""
Write-Host "Web.config updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "HYBRID CONFIGURATION:" -ForegroundColor Yellow
Write-Host "  DefaultConnection -> PRODUCTION FarmGenie (authentication)" -ForegroundColor Green
Write-Host "  FarmGenieConnection -> SANDBOX FarmGenie_Sandbox (PLS data)" -ForegroundColor Yellow
Write-Host "  MlsListingConnection -> SANDBOX MlsListing_Sandbox (PLS listings)" -ForegroundColor Yellow
Write-Host "  TitleDataConnection -> PRODUCTION TitleData (shared data)" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Restart the application for changes to take effect." -ForegroundColor Yellow
