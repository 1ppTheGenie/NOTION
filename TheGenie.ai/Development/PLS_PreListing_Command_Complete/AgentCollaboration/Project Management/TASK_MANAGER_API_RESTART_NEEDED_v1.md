# Task Manager API - Restart Required

**Version:** 1.0  
**Created:** 01/14/2026 2:45 AM  
**Status:** ⚠️ **ACTION REQUIRED**

---

## 🔧 ISSUE FIXED

**Problem:** API was returning 500 Internal Server Error due to circular reference in JSON serialization.

**Error:** `A possible object cycle was detected... Status.Tasks.Status.Tasks...`

**Root Cause:** TaskItem model has navigation properties (Status, Assignee) that have back-references to Tasks, creating a circular dependency.

---

## ✅ FIXES APPLIED

### 1. JSON Serialization Configuration
**File:** `TaskManager.Api/Program.cs`

Added `ReferenceHandler.IgnoreCycles` to JSON options:
```csharp
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.WriteIndented = true;
    });
```

### 2. CORS Configuration Updated
**File:** `TaskManager.Api/Program.cs`

Added `http://localhost:5173` to allowed origins:
```csharp
policy.WithOrigins("http://localhost:3000", "http://localhost:5173")
```

### 3. Query Optimization
**File:** `TaskManager.Api/Controllers/TasksController.cs`

Added `.AsSplitQuery()` to prevent circular reference issues in EF Core queries.

---

## 🚀 ACTION REQUIRED

**The API must be restarted for these changes to take effect.**

### Steps to Restart:

1. **Stop the current API process:**
   - Find the process running on port 5107
   - Kill the process (or stop it in Visual Studio/terminal)

2. **Rebuild and restart:**
   ```bash
   cd TaskManager.Api
   dotnet build
   dotnet run
   ```

3. **Verify:**
   - API should start on `http://localhost:5107`
   - Test endpoint: `http://localhost:5107/api/tasks/project/1` (with auth token)
   - Should return tasks without 500 error

---

## ✅ AFTER RESTART

Once the API is restarted:
- Frontend will be able to fetch tasks successfully
- All 51 PLS tasks will appear in the Kanban board
- No more circular reference errors

---

**Status:** ⚠️ **WAITING FOR API RESTART**
