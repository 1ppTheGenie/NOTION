# Sanitize Secrets for GitHub Push
# Version: 1.0

$basePath = "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\Development\DevOpsEcosystemManagement\Deployment_Automation_System"

# Azure DevOps PAT
$azureDevOpsPat = "[AZURE_DEVOPS_PAT_TOKEN]"

# SendGrid API Key
$sendGridKey = "[SENDGRID_API_KEY]"

# Twilio Account SID
$twilioSid = "[TWILIO_ACCOUNT_SID]"

# GitHub Token
$githubToken = "[GITHUB_OAUTH_TOKEN]"

# Scripts to sanitize
$scripts = Get-ChildItem -Path "$basePath\02_Scripts\*.ps1" -Recurse

foreach ($script in $scripts) {
    $content = Get-Content $script.FullName -Raw
    $content = $content -replace [regex]::Escape($azureDevOpsPat), '[AZURE_DEVOPS_PAT_TOKEN]'
    Set-Content -Path $script.FullName -Value $content -NoNewline
    Write-Host "Sanitized: $($script.Name)" -ForegroundColor Green
}

# Infrastructure inventory to sanitize
$infraFile = "$basePath\06_Infrastructure\COMPLETE_INFRASTRUCTURE_INVENTORY_v1.md"
if (Test-Path $infraFile) {
    $content = Get-Content $infraFile -Raw
    $content = $content -replace [regex]::Escape($sendGridKey), '[SENDGRID_API_KEY]'
    $content = $content -replace [regex]::Escape($twilioSid), '[TWILIO_ACCOUNT_SID]'
    $content = $content -replace [regex]::Escape($githubToken), '[GITHUB_OAUTH_TOKEN]'
    Set-Content -Path $infraFile -Value $content -NoNewline
    Write-Host "Sanitized: COMPLETE_INFRASTRUCTURE_INVENTORY_v1.md" -ForegroundColor Green
}

Write-Host ""
Write-Host "All secrets sanitized!" -ForegroundColor Cyan
