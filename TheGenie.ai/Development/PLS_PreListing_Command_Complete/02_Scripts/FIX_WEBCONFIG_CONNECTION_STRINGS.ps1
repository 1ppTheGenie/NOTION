# Fix Web.config Connection Strings for PLS Project
# This script ensures all required connection strings are present with correct credentials

$webConfigPath = "C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Web.config"

if (-not (Test-Path $webConfigPath)) {
    Write-Host "ERROR: Web.config not found at: $webConfigPath" -ForegroundColor Red
    exit 1
}

Write-Host "Loading Web.config..." -ForegroundColor Yellow
[xml]$webConfig = Get-Content $webConfigPath

# Check if connectionStrings section exists
if (-not $webConfig.configuration.connectionStrings) {
    Write-Host "Creating connectionStrings section..." -ForegroundColor Yellow
    $connectionStringsNode = $webConfig.CreateElement("connectionStrings")
    $webConfig.configuration.AppendChild($connectionStringsNode) | Out-Null
}

# Define all required connection strings
$requiredConnections = @(
    @{
        Name = "DefaultConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;User Id=sa;Password=neo222;"
        Description = "Main application connection (ASP.NET Identity)"
    },
    @{
        Name = "FarmGenieConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=FarmGenie_Sandbox;User Id=sa;Password=neo222;"
        Description = "FarmGenie database connection"
    },
    @{
        Name = "MlsListingConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=MlsListing_Sandbox;User Id=sa;Password=neo222;"
        Description = "MLS Listing database connection"
    },
    @{
        Name = "TitleDataConnection"
        ConnectionString = "Server=192.168.29.45,1433;Database=TitleData;User Id=sa;Password=neo222;"
        Description = "TitleData database connection"
    }
)

Write-Host ""
Write-Host "Updating connection strings..." -ForegroundColor Yellow

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
Write-Host "Connection strings configured:" -ForegroundColor Yellow
foreach ($conn in $requiredConnections) {
    Write-Host "  - $($conn.Name): $($conn.Description)" -ForegroundColor White
}

Write-Host ""
Write-Host "IMPORTANT: Restart the application for changes to take effect." -ForegroundColor Yellow
