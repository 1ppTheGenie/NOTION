# Fix Web.config - All Production Connections for GET operations
# Only PLS-specific operations use Sandbox

$webConfigPath = "C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config"

if (-not (Test-Path $webConfigPath)) {
    Write-Host "ERROR: Web.config not found at: $webConfigPath" -ForegroundColor Red
    exit 1
}

Write-Host "Loading Web.config..." -ForegroundColor Yellow
[xml]$webConfig = Get-Content $webConfigPath

# ALL PRODUCTION CONNECTIONS for GET operations
# Only PLS-specific writes go to sandbox (handled in code)
$requiredConnections = @(
    @{
        Name = "DefaultConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=FarmGenie;User Id=sa;Password=neo222;"
        Description = "PRODUCTION - Authentication"
    },
    @{
        Name = "FarmGenieConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=FarmGenie;User Id=sa;Password=neo222;"
        Description = "PRODUCTION - All GET operations"
    },
    @{
        Name = "MlsListingConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=MlsListing;User Id=sa;Password=neo222;"
        Description = "PRODUCTION - All GET operations"
    },
    @{
        Name = "TitleDataConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=TitleData;User Id=sa;Password=neo222;"
        Description = "PRODUCTION - All GET operations"
    },
    @{
        Name = "FarmGenieConnection_PLS"
        ConnectionString = "Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;User Id=sa;Password=neo222;"
        Description = "SANDBOX - PLS-specific writes only"
    },
    @{
        Name = "MlsListingConnection_PLS"
        ConnectionString = "Server=192.168.29.45,1433;Database=MlsListing_Sandbox;User Id=sa;Password=neo222;"
        Description = "SANDBOX - PLS-specific writes only"
    }
)

Write-Host ""
Write-Host "Updating connection strings (ALL PRODUCTION for GET, SANDBOX for PLS writes)..." -ForegroundColor Yellow
Write-Host "  -> All connections: PRODUCTION (for reading data)" -ForegroundColor Green
Write-Host "  -> PLS connections: SANDBOX (for PLS-specific writes)" -ForegroundColor Yellow
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
Write-Host "CONFIGURATION:" -ForegroundColor Yellow
Write-Host "  DefaultConnection -> PRODUCTION FarmGenie (authentication)" -ForegroundColor Green
Write-Host "  FarmGenieConnection -> PRODUCTION FarmGenie (all GET operations)" -ForegroundColor Green
Write-Host "  MlsListingConnection -> PRODUCTION MlsListing (all GET operations)" -ForegroundColor Green
Write-Host "  TitleDataConnection -> PRODUCTION TitleData (all GET operations)" -ForegroundColor Green
Write-Host "  FarmGenieConnection_PLS -> SANDBOX FarmGenie_Sandbox (PLS writes only)" -ForegroundColor Yellow
Write-Host "  MlsListingConnection_PLS -> SANDBOX MlsListing_Sandbox (PLS writes only)" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: Update PlsController to use *_PLS connection strings for PLS-specific operations." -ForegroundColor Yellow
Write-Host "IMPORTANT: Restart the application for changes to take effect." -ForegroundColor Yellow
