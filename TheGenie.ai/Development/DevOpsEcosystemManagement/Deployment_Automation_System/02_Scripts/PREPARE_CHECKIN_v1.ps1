# Prepare Check-In Script
# Version: 1.0
# Created: 01/13/2026 5:45 AM
# Author: Auto (AI Agent)
# Purpose: Automates backup + comment generation for check-in

param(
    [string]$CheckInFormPath,  # Path to Check-In QC Form JSON
    [string]$OutputCommentFile = "CHECKIN_COMMENT.txt"  # Where to save comment
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PREPARE CHECK-IN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# STEP 1: Read Check-In QC Form
if (-not $CheckInFormPath) {
    # Try to find latest form
    $formDir = "D:\Cursor\TheGenie.ai\Development\DevOpsEcosystemManagement\Monitoring\Server Troubleshooting\CheckInLogs"
    $latestForm = Get-ChildItem $formDir -Filter "CIL_*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestForm) {
        $CheckInFormPath = $latestForm.FullName
        Write-Host "Found latest form: $($latestForm.Name)" -ForegroundColor Gray
    } else {
        Write-Host "❌ ERROR: No Check-In QC Form found" -ForegroundColor Red
        Write-Host "   Please fill out Check-In QC Form first" -ForegroundColor Yellow
        exit 1
    }
}

if (-not (Test-Path $CheckInFormPath)) {
    Write-Host "❌ ERROR: Check-In QC Form not found: $CheckInFormPath" -ForegroundColor Red
    exit 1
}

Write-Host "STEP 1: Reading Check-In QC Form..." -ForegroundColor Yellow
$form = Get-Content $CheckInFormPath | ConvertFrom-Json

if ($form.ReadyForCheckIn -ne "YES") {
    Write-Host "⚠️  WARNING: Form not marked as 'Ready for Check-In'" -ForegroundColor Yellow
    Write-Host "   Please mark 'Ready for Check-In' in form before running this script" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (Y/N)"
    if ($continue -ne "Y") {
        exit 1
    }
}

Write-Host "✅ Form read successfully" -ForegroundColor Green
Write-Host ""

# STEP 2: Run Pre-Commit Backup
Write-Host "STEP 2: Running Pre-Commit Backup..." -ForegroundColor Yellow

$backupScript = "D:\Cursor\TheGenie.ai\Development\DevOpsEcosystemManagement\Monitoring\Server Troubleshooting\Danny\PRE_COMMIT_BACKUP_v1.ps1"

if (-not (Test-Path $backupScript)) {
    Write-Host "⚠️  WARNING: Backup script not found: $backupScript" -ForegroundColor Yellow
    Write-Host "   Skipping backup (not recommended)" -ForegroundColor Yellow
    $backupToken = $null
} else {
    try {
        # Run backup script
        & $backupScript
        
        # Check for backup token
        $tokenFile = "D:\Cursor\TheGenie.ai\Development\DevOpsEcosystemManagement\Monitoring\Server Troubleshooting\Danny\LAST_BACKUP_TOKEN.json"
        if (Test-Path $tokenFile) {
            $tokenData = Get-Content $tokenFile | ConvertFrom-Json
            $backupToken = $tokenData.Token
            $backupPath = $tokenData.BackupPath
            Write-Host "✅ Backup successful" -ForegroundColor Green
            Write-Host "   Backup Location: $backupPath" -ForegroundColor Gray
            Write-Host "   Backup Token: $backupToken" -ForegroundColor Gray
        } else {
            Write-Host "⚠️  WARNING: Backup token not found" -ForegroundColor Yellow
            $backupToken = $null
        }
    } catch {
        Write-Host "❌ ERROR: Backup failed - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Check-in should not proceed until backup succeeds" -ForegroundColor Yellow
        $backupToken = $null
    }
}

Write-Host ""

# STEP 3: Generate Check-In Comment
Write-Host "STEP 3: Generating Check-In Comment..." -ForegroundColor Yellow

$comment = @"
=== CHECK-IN COMMENT ===

1. SUMMARY
$($form.Summary)

2. FILES MODIFIED
$($form.FilesModified -join "`n")

3. IMPACT ANALYSIS
$($form.ImpactAnalysis)

4. TESTING SUMMARY
$($form.TestingSummary)

5. DATABASE CHANGES
$($form.DatabaseChanges)

6. CONFIGURATION CHANGES
$($form.ConfigurationChanges)

7. DEPENDENCIES
$($form.Dependencies)

8. PERFORMANCE IMPACT
$($form.PerformanceImpact)

9. SECURITY REVIEW
$($form.SecurityReview)

10. BACKUP
Backup: $(if ($backupPath) { Split-Path $backupPath -Leaf } else { "NOT CREATED" })
Location: $(if ($backupPath) { $backupPath } else { "N/A" })
Token: $(if ($backupToken) { $backupToken } else { "N/A" })
"@

# Save comment to file
$commentPath = Join-Path (Split-Path $CheckInFormPath) $OutputCommentFile
$comment | Out-File -FilePath $commentPath -Encoding UTF8

Write-Host "✅ Check-in comment generated" -ForegroundColor Green
Write-Host "   Comment saved to: $commentPath" -ForegroundColor Gray
Write-Host ""

# STEP 4: Copy Comment to Clipboard
Write-Host "STEP 4: Copying Comment to Clipboard..." -ForegroundColor Yellow

try {
    $comment | Set-Clipboard
    Write-Host "✅ Comment copied to clipboard" -ForegroundColor Green
    Write-Host "   You can now paste it into Visual Studio (Ctrl+V)" -ForegroundColor Gray
} catch {
    Write-Host "⚠️  WARNING: Could not copy to clipboard" -ForegroundColor Yellow
    Write-Host "   Please copy comment manually from: $commentPath" -ForegroundColor Yellow
}

Write-Host ""

# STEP 5: Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CHECK-IN READY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open Visual Studio" -ForegroundColor White
Write-Host "2. Go to Team Explorer → Pending Changes" -ForegroundColor White
Write-Host "3. Review files (they should be visible)" -ForegroundColor White
Write-Host "4. Paste check-in comment (Ctrl+V)" -ForegroundColor White
Write-Host "5. Click 'Check In' button" -ForegroundColor White
Write-Host ""
Write-Host "Files to Check In:" -ForegroundColor Yellow
if ($form.FilesModified) {
    foreach ($file in $form.FilesModified) {
        Write-Host "  - $file" -ForegroundColor Gray
    }
} else {
    Write-Host "  (Files will appear in Visual Studio pending changes)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Comment File:" -ForegroundColor Yellow
Write-Host "  $commentPath" -ForegroundColor Gray
Write-Host ""
if ($backupToken) {
    Write-Host "✅ Backup: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backup: NOT CREATED (check-in not recommended)" -ForegroundColor Yellow
}
Write-Host ""
