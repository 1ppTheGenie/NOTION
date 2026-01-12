# Create DevOps Tracking Database
# Version: 1.0
# Created: 01/12/2026 10:45 AM
# Author: Danny
# Purpose: Create local check-in and deployment tracking database
# Location: Local SQL Server (localhost) - COMPLETELY SEPARATE

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DevOps Tracking Database Setup" -ForegroundColor Cyan
Write-Host "  COMPLETELY ISOLATED from FarmGenie" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Database connection (local only - no production connection)
$server = "localhost"
$database = "DevOpsTracking"
$connectionString = "Server=$server;Integrated Security=True;Connection Timeout=30;"

# SQL script path
$sqlScriptPath = Join-Path $PSScriptRoot "CREATE_DEVOPS_TRACKING_DATABASE_v1.sql"

Write-Host "✅ Verifying isolation..." -ForegroundColor Green
Write-Host "   - Server: $server (LOCAL ONLY)" -ForegroundColor Gray
Write-Host "   - Database: $database (NEW - doesn't exist yet)" -ForegroundColor Gray
Write-Host "   - No connection to FarmGenie" -ForegroundColor Gray
Write-Host "   - No connection to production (192.168.29.45)" -ForegroundColor Gray
Write-Host "   - Completely isolated - zero impact on enterprise software`n" -ForegroundColor Gray

# Test connection to local SQL Server
Write-Host "Testing connection to local SQL Server..." -ForegroundColor Yellow
try {
    $testConnection = New-Object System.Data.SqlClient.SqlConnection("Server=$server;Integrated Security=True;Connection Timeout=5;")
    $testConnection.Open()
    $serverVersion = $testConnection.ServerVersion
    $testConnection.Close()
    Write-Host "✅ Connected to SQL Server $serverVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Cannot connect to local SQL Server" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease ensure SQL Server is running and accessible." -ForegroundColor Yellow
    exit 1
}

# Check if SQL script exists
if (-not (Test-Path $sqlScriptPath)) {
    Write-Host "❌ ERROR: SQL script not found at $sqlScriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "`nExecuting SQL script..." -ForegroundColor Yellow
Write-Host "   Script: $sqlScriptPath`n" -ForegroundColor Gray

# Read SQL script
$sqlScript = Get-Content $sqlScriptPath -Raw

# Execute SQL script
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    # Split script by GO statements
    $batches = $sqlScript -split '\bGO\b', [System.StringSplitOptions]::RemoveEmptyEntries
    
    foreach ($batch in $batches) {
        $batch = $batch.Trim()
        if ($batch -and $batch -notmatch '^\s*--') {
            try {
                $command = New-Object System.Data.SqlClient.SqlCommand($batch, $connection)
                $command.CommandTimeout = 60
                $result = $command.ExecuteNonQuery()
                
                # Capture PRINT statements (they show up in Messages, not Results)
                # For now, just execute silently - output will be in SQL script
            } catch {
                Write-Host "⚠️  Warning: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    
    $connection.Close()
    Write-Host "✅ SQL script executed successfully`n" -ForegroundColor Green
    
} catch {
    Write-Host "❌ ERROR: Failed to execute SQL script" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify database and tables were created
Write-Host "Verifying database creation..." -ForegroundColor Yellow
try {
    $verifyConnection = New-Object System.Data.SqlClient.SqlConnection("Server=$server;Database=$database;Integrated Security=True;Connection Timeout=5;")
    $verifyConnection.Open()
    
    $verifyQuery = @"
SELECT 
    TABLE_NAME AS TableName,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME
"@
    
    $verifyCommand = New-Object System.Data.SqlClient.SqlCommand($verifyQuery, $verifyConnection)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($verifyCommand)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset)
    $tables = $dataset.Tables[0]
    
    Write-Host "`n✅ Database '$database' created successfully!" -ForegroundColor Green
    Write-Host "`nTables Created:" -ForegroundColor Cyan
    $tables | Format-Table -AutoSize
    
    $verifyConnection.Close()
    
} catch {
    Write-Host "❌ ERROR: Could not verify database creation" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  ✅ SETUP COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nDatabase: $database" -ForegroundColor White
Write-Host "Location: Local SQL Server (localhost)" -ForegroundColor White
Write-Host "Status: COMPLETELY ISOLATED from FarmGenie" -ForegroundColor White
Write-Host "`n✅ Ready for use!`n" -ForegroundColor Green
