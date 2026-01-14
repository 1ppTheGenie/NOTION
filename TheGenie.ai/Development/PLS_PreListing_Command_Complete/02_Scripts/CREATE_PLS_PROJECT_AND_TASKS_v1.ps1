# Create PLS Project and All Tasks in Task Manager
# Version: 1.0
# Created: 01/14/2026
# Purpose: Populate Task Manager with PLS project and all 51 tasks

$apiUrl = "http://localhost:5107/api"
$email = "pm@thegenie.ai"
$password = "PMLogin2026!"

Write-Host "=== PLS Project Setup Script ===" -ForegroundColor Cyan

# Step 1: Login
Write-Host "`n1. Logging in..." -ForegroundColor Yellow
$loginBody = @{
    Email = $email
    Password = $password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "$apiUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -UseBasicParsing
    $loginData = $loginResponse.Content | ConvertFrom-Json
    $token = $loginData.Token
    $userId = $loginData.User.Id
    Write-Host "   Login: OK - User ID: $userId" -ForegroundColor Green
} catch {
    Write-Host "   Login FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

# Step 2: Create PLS Project
Write-Host "`n2. Creating PLS Project..." -ForegroundColor Yellow
$projectBody = @{
    Name = "PLS Pre-Listing Command"
    Description = "Paisley RESO Listing Engine - Private Listing Service for pre-MLS listings with full marketing asset generation"
    Status = "Active"
    OwnerId = $userId
} | ConvertTo-Json

try {
    $projectResponse = Invoke-WebRequest -Uri "$apiUrl/projects" -Method POST -Body $projectBody -Headers $headers -UseBasicParsing
    $project = $projectResponse.Content | ConvertFrom-Json
    $projectId = $project.Id
    Write-Host "   Project Created: OK - Project ID: $projectId" -ForegroundColor Green
} catch {
    Write-Host "   Project Creation FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "   Error Details: $errorBody" -ForegroundColor Red
    }
    exit 1
}

# Step 3: Create All Tasks
Write-Host "`n3. Creating Tasks..." -ForegroundColor Yellow

# Phase 1: Database Foundation (8 tasks)
$phase1Tasks = @(
    @{ Title = "DB-001: Execute PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql"; Description = "Create all PLS tables"; StatusId = 1; Priority = 3 },
    @{ Title = "DB-002: Execute PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql"; Description = "PLS number generation"; StatusId = 1; Priority = 3 },
    @{ Title = "DB-003: Execute PLS_DATABASE_MASTER_DATA_v3.sql"; Description = "Master data inserts"; StatusId = 1; Priority = 3 },
    @{ Title = "DB-004: Execute PLS_STORED_PROCEDURES_COMPLETE_v1.sql"; Description = "All stored procedures"; StatusId = 1; Priority = 3 },
    @{ Title = "DB-005: Verify all tables, indexes, constraints created"; Description = "Verification"; StatusId = 1; Priority = 2 },
    @{ Title = "DB-006: Test PLS number generation (usp_GetNextPlsNumber)"; Description = "Test format: PLS100000A"; StatusId = 1; Priority = 2 },
    @{ Title = "DB-007: Verify master data inserted correctly"; Description = "Data verification"; StatusId = 1; Priority = 2 },
    @{ Title = "DB-008: Update status file and announce Phase 1 complete"; Description = "Handoff to Phase 2"; StatusId = 1; Priority = 2 }
)

# Phase 2: Backend API (16 tasks)
$phase2Tasks = @(
    @{ Title = "API-001: Implement PlsController.cs with all endpoints"; Description = "Core CRUD endpoints"; StatusId = 1; Priority = 3 },
    @{ Title = "API-002: Implement DataController.PLS.cs partial class"; Description = "Data controller"; StatusId = 1; Priority = 3 },
    @{ Title = "API-003: Create business logic service layer (PlsService)"; Description = "Service layer"; StatusId = 1; Priority = 3 },
    @{ Title = "API-004: Implement POST /api/pls/create endpoint"; Description = "Create listing"; StatusId = 1; Priority = 3 },
    @{ Title = "API-005: Implement PUT /api/pls/{listingNumber} endpoint"; Description = "Update listing"; StatusId = 1; Priority = 3 },
    @{ Title = "API-006: Implement GET /api/pls/{listingNumber} endpoint"; Description = "Get listing"; StatusId = 1; Priority = 3 },
    @{ Title = "API-007: Implement GET /api/pls/my-listings endpoint"; Description = "List user's listings"; StatusId = 1; Priority = 3 },
    @{ Title = "API-008: Implement POST /api/pls/pre-populate endpoint"; Description = "Title Genie integration"; StatusId = 1; Priority = 3 },
    @{ Title = "API-009: Implement POST /api/pls/generate-description endpoint"; Description = "Paisley integration (ChatStartTypeId=3)"; StatusId = 1; Priority = 3 },
    @{ Title = "API-010: Implement POST /api/pls/upload-photo endpoint"; Description = "S3 photo upload"; StatusId = 1; Priority = 3 },
    @{ Title = "API-011: Implement POST /api/pls/{listingNumber}/render endpoint"; Description = "Coordinate with XML Specialist"; StatusId = 1; Priority = 3 },
    @{ Title = "API-012: Implement PUT /api/pls/archive/{listingNumber} endpoint"; Description = "Archive listing"; StatusId = 1; Priority = 2 },
    @{ Title = "API-013: Implement data validation and error handling"; Description = "Validation layer"; StatusId = 1; Priority = 2 },
    @{ Title = "API-014: Create API documentation"; Description = "For Frontend Specialist"; StatusId = 1; Priority = 2 },
    @{ Title = "API-015: Write unit tests for critical endpoints"; Description = "Testing"; StatusId = 1; Priority = 2 },
    @{ Title = "API-016: Update status file and announce Phase 2 complete"; Description = "Handoff to Phase 3"; StatusId = 1; Priority = 2 }
)

# Phase 3: Frontend UI (12 tasks)
$phase3Tasks = @(
    @{ Title = "UI-001: Implement PlsMyListingsComponent"; Description = "List all user's PLS listings"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-002: Implement PlsCreateComponent"; Description = "Create new PLS listing form"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-003: Implement PlsEditComponent"; Description = "Edit existing listing"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-004: Implement PlsPhotoUploadComponent"; Description = "Photo upload interface"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-005: Implement PlsAreaSelectorComponent"; Description = "Area selection for Paisley"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-006: Implement PlsAIDescriptionComponent"; Description = "AI description generation UI"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-007: Implement Mapbox address autocomplete"; Description = "Address lookup"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-008: Implement mobile-first responsive design"; Description = "Mobile optimization"; StatusId = 1; Priority = 2 },
    @{ Title = "UI-009: Implement form validation (client-side)"; Description = "Validation"; StatusId = 1; Priority = 2 },
    @{ Title = "UI-010: Implement error handling and user feedback"; Description = "Error handling"; StatusId = 1; Priority = 2 },
    @{ Title = "UI-011: Integrate with Backend API endpoints"; Description = "API integration"; StatusId = 1; Priority = 3 },
    @{ Title = "UI-012: Update status file and announce Phase 3 complete"; Description = "Handoff to Phase 5"; StatusId = 1; Priority = 2 }
)

# Phase 4: XML/Integration (8 tasks)
$phase4Tasks = @(
    @{ Title = "XML-001: Implement XML generation from PLS listing data"; Description = "Follow contract v6.1 exactly"; StatusId = 1; Priority = 3 },
    @{ Title = "XML-002: Map PLS data to GenieCloud XML structure"; Description = "Contract mapping"; StatusId = 1; Priority = 3 },
    @{ Title = "XML-003: Integrate with Backend API /render endpoint"; Description = "Coordinate with Backend"; StatusId = 1; Priority = 3 },
    @{ Title = "XML-004: Implement GenieCloud API integration"; Description = "Call GenieCloud API"; StatusId = 1; Priority = 3 },
    @{ Title = "XML-005: Handle GenieCloud responses and errors"; Description = "Error handling"; StatusId = 1; Priority = 2 },
    @{ Title = "XML-006: Test XML schema validation"; Description = "Validation"; StatusId = 1; Priority = 2 },
    @{ Title = "XML-007: Verify marketing assets generated correctly"; Description = "Asset verification"; StatusId = 1; Priority = 2 },
    @{ Title = "XML-008: Update status file and announce Phase 4 complete"; Description = "Handoff to Phase 5"; StatusId = 1; Priority = 2 }
)

# Phase 5: Testing & Deployment (7 tasks)
$phase5Tasks = @(
    @{ Title = "DEPLOY-001: Create deployment scripts (PowerShell/Python)"; Description = "Supporting all phases"; StatusId = 3; Priority = 2 },
    @{ Title = "DEPLOY-002: Set up Sandbox test environment"; Description = "Test environment"; StatusId = 3; Priority = 2 },
    @{ Title = "DEPLOY-003: Create backup and rollback procedures"; Description = "Include DLL.config"; StatusId = 1; Priority = 2 },
    @{ Title = "DEPLOY-004: Integration testing (all phases)"; Description = "End-to-end testing"; StatusId = 1; Priority = 3 },
    @{ Title = "DEPLOY-005: End-to-end testing"; Description = "Full workflow test"; StatusId = 1; Priority = 3 },
    @{ Title = "DEPLOY-006: Production deployment"; Description = "Final deployment"; StatusId = 1; Priority = 4 },
    @{ Title = "DEPLOY-007: Post-deployment validation"; Description = "Verify production"; StatusId = 1; Priority = 3 }
)

$allTasks = $phase1Tasks + $phase2Tasks + $phase3Tasks + $phase4Tasks + $phase5Tasks
$taskCount = 0
$errorCount = 0

foreach ($task in $allTasks) {
    $taskBody = @{
        Title = $task.Title
        Description = $task.Description
        ProjectId = $projectId
        StatusId = $task.StatusId
        Priority = $task.Priority
        CreatedById = $userId
    } | ConvertTo-Json

    try {
        $taskResponse = Invoke-WebRequest -Uri "$apiUrl/tasks" -Method POST -Body $taskBody -Headers $headers -UseBasicParsing
        $taskCount++
        if ($taskCount % 10 -eq 0) {
            Write-Host "   Created $taskCount tasks..." -ForegroundColor Cyan
        }
    } catch {
        $errorCount++
        Write-Host "   ERROR creating task: $($task.Title)" -ForegroundColor Red
        Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Project Created: PLS Pre-Listing Command (ID: $projectId)" -ForegroundColor Green
Write-Host "Tasks Created: $taskCount / $($allTasks.Count)" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Yellow" })
if ($errorCount -gt 0) {
    Write-Host "Errors: $errorCount" -ForegroundColor Red
}
Write-Host "`nAccess Task Manager: http://localhost:5173" -ForegroundColor Cyan
Write-Host "Project ID: $projectId" -ForegroundColor Cyan
