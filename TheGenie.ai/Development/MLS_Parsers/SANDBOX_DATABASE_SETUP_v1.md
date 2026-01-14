# Sandbox Database Setup Guide

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Purpose:** Clone production databases to local sandbox for PLS prototyping

---

## 🎯 GOAL

Set up local sandbox with cloned databases:
- ✅ `FarmGenie` (365 GB - need strategy!)
- ✅ `MlsListing` (smaller)
- ✅ `TitleData` (Attom data)

**Options:**
1. **Full Clone** - Complete copy (if you have space)
2. **Schema-Only** - Structure only, add sample data
3. **Hybrid** - Schema + essential tables with data

---

## 📋 PREREQUISITES

### 1. Local SQL Server Installation

**Check if you have SQL Server:**
```powershell
# Check SQL Server version
Get-Service -Name "*SQL*" | Select-Object Name, Status, DisplayName

# Or check if sqlcmd exists
sqlcmd -?
```

**If you don't have SQL Server:**
- **Option A:** SQL Server Developer Edition (FREE)
  - Download: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
  - Full-featured, free for development
  
- **Option B:** SQL Server Express (FREE, limited to 10 GB per database)
  - ⚠️ **Problem:** FarmGenie is 365 GB - won't fit!
  - Use for MlsListing and TitleData only
  
- **Option C:** Docker SQL Server (FREE)
  - `docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourPassword123!" -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest`
  - Full SQL Server in container

### 2. Network Access

**You need access to production server:**
- Server: `server-mssql1.istrategy.com` (or `192.168.29.45`)
- Credentials: `sa` / `neo222` (full access)
- Or: `cursor` / `1ppINSAyay$` (read-only - can't backup)

---

## 🚀 OPTION 1: FULL CLONE (If You Have Space)

### Step 1: Backup Production Databases

**On production server (via RDP or SQL Server Management Studio):**

```sql
-- Backup FarmGenie
BACKUP DATABASE [FarmGenie]
TO DISK = 'D:\Backups\FarmGenie_Full_Backup.bak'
WITH COMPRESSION, INIT;

-- Backup MlsListing
BACKUP DATABASE [MlsListing]
TO DISK = 'D:\Backups\MlsListing_Full_Backup.bak'
WITH COMPRESSION, INIT;

-- Backup TitleData
BACKUP DATABASE [TitleData]
TO DISK = 'D:\Backups\TitleData_Full_Backup.bak'
WITH COMPRESSION, INIT;
```

**Check backup sizes:**
```sql
EXEC xp_cmdshell 'dir D:\Backups\*.bak';
```

### Step 2: Copy Backups to Local Machine

**Option A: Network Share**
```powershell
# Map network drive
net use Z: \\server-mssql1.istrategy.com\Backups

# Copy files
Copy-Item Z:\FarmGenie_Full_Backup.bak D:\Sandbox\Backups\
Copy-Item Z:\MlsListing_Full_Backup.bak D:\Sandbox\Backups\
Copy-Item Z:\TitleData_Full_Backup.bak D:\Sandbox\Backups\
```

**Option B: RDP Copy/Paste**
- RDP to production server
- Copy `.bak` files
- Paste to local machine

**Option C: FTP/SFTP**
- Upload backups to FTP server
- Download to local machine

### Step 3: Restore to Local SQL Server

```sql
-- Restore FarmGenie
RESTORE DATABASE [FarmGenie_Sandbox]
FROM DISK = 'D:\Sandbox\Backups\FarmGenie_Full_Backup.bak'
WITH 
    MOVE 'FarmGenie' TO 'D:\Sandbox\Data\FarmGenie_Sandbox.mdf',
    MOVE 'FarmGenie_Log' TO 'D:\Sandbox\Logs\FarmGenie_Sandbox_Log.ldf',
    REPLACE;

-- Restore MlsListing
RESTORE DATABASE [MlsListing_Sandbox]
FROM DISK = 'D:\Sandbox\Backups\MlsListing_Full_Backup.bak'
WITH 
    MOVE 'MlsListing' TO 'D:\Sandbox\Data\MlsListing_Sandbox.mdf',
    MOVE 'MlsListing_Log' TO 'D:\Sandbox\Logs\MlsListing_Sandbox_Log.ldf',
    REPLACE;

-- Restore TitleData
RESTORE DATABASE [TitleData_Sandbox]
FROM DISK = 'D:\Sandbox\Backups\TitleData_Full_Backup.bak'
WITH 
    MOVE 'TitleData' TO 'D:\Sandbox\Data\TitleData_Sandbox.mdf',
    MOVE 'TitleData_Log' TO 'D:\Sandbox\Logs\TitleData_Sandbox_Log.ldf',
    REPLACE;
```

---

## 🎯 OPTION 2: SCHEMA-ONLY + SAMPLE DATA (RECOMMENDED)

**Best for prototyping - much smaller footprint!**

### Step 1: Generate Schema Scripts

**On production server, generate schema-only scripts:**

```sql
-- Script all tables, views, stored procedures, functions
-- Use SQL Server Management Studio:
-- Right-click database → Tasks → Generate Scripts
-- Select: "Script entire database and all database objects"
-- Advanced options: "Script Data" = FALSE, "Script Schema" = TRUE
```

**Or use PowerShell script:**

```powershell
# Save as: GenerateSchemaScripts.ps1
$server = "server-mssql1.istrategy.com"
$databases = @("FarmGenie", "MlsListing", "TitleData")
$outputPath = "D:\Sandbox\SchemaScripts\"

foreach ($db in $databases) {
    sqlcmd -S $server -U sa -P neo222 -d $db -Q "EXEC sp_helpdb '$db'" | Out-File "$outputPath\$db_Schema.sql"
}
```

### Step 2: Create Schema-Only Databases Locally

```sql
-- Create empty databases
CREATE DATABASE [FarmGenie_Sandbox];
CREATE DATABASE [MlsListing_Sandbox];
CREATE DATABASE [TitleData_Sandbox];
```

### Step 3: Run Schema Scripts

```sql
-- Execute schema scripts in order:
-- 1. Tables
-- 2. Views
-- 3. Stored Procedures
-- 4. Functions
-- 5. Indexes
-- 6. Constraints

USE [FarmGenie_Sandbox];
GO
:r D:\Sandbox\SchemaScripts\FarmGenie_Tables.sql
:r D:\Sandbox\SchemaScripts\FarmGenie_Views.sql
:r D:\Sandbox\SchemaScripts\FarmGenie_StoredProcedures.sql
```

### Step 4: Add Essential Sample Data

**For PLS prototyping, you need:**

```sql
-- 1. User data (for testing)
USE [FarmGenie_Sandbox];
GO

-- Copy your test user
INSERT INTO [dbo].[AspNetUsers] (Id, UserName, Email, ...)
SELECT Id, UserName, Email, ...
FROM [FarmGenie].[dbo].[AspNetUsers]
WHERE Id = 'your-user-id-here';

-- Copy user profile
INSERT INTO [dbo].[AspNetUserProfiles] (...)
SELECT ...
FROM [FarmGenie].[dbo].[AspNetUserProfiles]
WHERE AspNetUserId = 'your-user-id-here';

-- Copy marketing profile
INSERT INTO [dbo].[UserMarketingProfile] (...)
SELECT ...
FROM [FarmGenie].[dbo].[UserMarketingProfile]
WHERE AspNetUserId = 'your-user-id-here';

-- 2. MLS data (for reference)
USE [MlsListing_Sandbox];
GO

-- Copy MLS master list
INSERT INTO [dbo].[Mls] (...)
SELECT * FROM [MlsListing].[dbo].[Mls];

-- Copy StatusType
INSERT INTO [dbo].[StatusType] (...)
SELECT * FROM [MlsListing].[dbo].[StatusType];

-- 3. Area data (for widgets)
USE [FarmGenie_Sandbox];
GO

-- Copy a few test areas
INSERT INTO [dbo].[Area] (...)
SELECT TOP 10 * FROM [FarmGenie].[dbo].[Area]
WHERE AreaName LIKE '%Balcones%' OR AreaName LIKE '%San Antonio%';
```

---

## 🎯 OPTION 3: HYBRID APPROACH (BEST FOR PLS)

**Schema + Essential Tables with Data**

### Step 1: Create Databases

```sql
CREATE DATABASE [FarmGenie_Sandbox];
CREATE DATABASE [MlsListing_Sandbox];
CREATE DATABASE [TitleData_Sandbox];
```

### Step 2: Copy Schema Only

```sql
-- Use SQL Server Management Studio Generate Scripts
-- Script entire database schema (no data)
```

### Step 3: Copy Essential Tables with Data

**For PLS prototyping, copy these tables WITH data:**

```sql
-- FarmGenie_Sandbox - Essential Tables
USE [FarmGenie_Sandbox];
GO

-- User tables (your test user only)
INSERT INTO [dbo].[AspNetUsers] (...)
SELECT * FROM [FarmGenie].[dbo].[AspNetUsers]
WHERE Id = 'your-user-id-here';

INSERT INTO [dbo].[AspNetUserProfiles] (...)
SELECT * FROM [FarmGenie].[dbo].[AspNetUserProfiles]
WHERE AspNetUserId = 'your-user-id-here';

INSERT INTO [dbo].[UserMarketingProfile] (...)
SELECT * FROM [FarmGenie].[dbo].[UserMarketingProfile]
WHERE AspNetUserId = 'your-user-id-here';

-- Role/Permission tables (all - small)
INSERT INTO [dbo].[AspNetRoles] (...)
SELECT * FROM [FarmGenie].[dbo].[AspNetRoles];

INSERT INTO [dbo].[Permission] (...)
SELECT * FROM [FarmGenie].[dbo].[Permission];

INSERT INTO [dbo].[RolePermission] (...)
SELECT * FROM [FarmGenie].[dbo].[RolePermission];

-- Area tables (sample areas)
INSERT INTO [dbo].[Area] (...)
SELECT TOP 50 * FROM [FarmGenie].[dbo].[Area]
WHERE AreaName LIKE '%San Antonio%' OR AreaName LIKE '%Boerne%';

-- PropertyCastType (all - small)
INSERT INTO [dbo].[PropertyCastType] (...)
SELECT * FROM [FarmGenie].[dbo].[PropertyCastType];

-- HubAssetSetting (all - small)
INSERT INTO [dbo].[HubAssetSetting] (...)
SELECT * FROM [FarmGenie].[dbo].[HubAssetSetting];

-- MlsListing_Sandbox - Essential Tables
USE [MlsListing_Sandbox];
GO

-- MLS master list (all - small)
INSERT INTO [dbo].[Mls] (...)
SELECT * FROM [MlsListing].[dbo].[Mls];

-- StatusType (all - small)
INSERT INTO [dbo].[StatusType] (...)
SELECT * FROM [MlsListing].[dbo].[StatusType];

-- Sample listings (for reference)
INSERT INTO [dbo].[Listing] (...)
SELECT TOP 100 * FROM [MlsListing].[dbo].[Listing]
WHERE MlsID IN (2, 68, 82)  -- EBRDI, Sabor, Austin
ORDER BY MlsUpdateDate DESC;

-- TitleData_Sandbox - Essential Tables
USE [TitleData_Sandbox];
GO

-- Assessor data (sample properties)
INSERT INTO [dbo].[AttomDataAssessor] (...)
SELECT TOP 1000 * FROM [TitleData].[dbo].[AttomDataAssessor]
WHERE City LIKE '%Boerne%' OR City LIKE '%San Antonio%';
```

---

## 🔧 AUTOMATED SCRIPT (POWERSHELL)

**Save as: `CloneDatabasesToSandbox.ps1`**

```powershell
# Configuration
$prodServer = "server-mssql1.istrategy.com"
$prodUser = "sa"
$prodPassword = "neo222"
$localServer = "localhost"
$localUser = "sa"
$localPassword = "YourLocalPassword123!"

$databases = @("FarmGenie", "MlsListing", "TitleData")
$backupPath = "D:\Sandbox\Backups\"
$restorePath = "D:\Sandbox\Data\"

# Create directories
New-Item -ItemType Directory -Force -Path $backupPath
New-Item -ItemType Directory -Force -Path $restorePath

foreach ($db in $databases) {
    Write-Host "Processing $db..."
    
    # Step 1: Backup from production
    $backupFile = "$backupPath${db}_Full_Backup.bak"
    Write-Host "  Backing up $db..."
    
    $backupQuery = @"
BACKUP DATABASE [$db]
TO DISK = '$backupFile'
WITH COMPRESSION, INIT;
"@
    
    sqlcmd -S $prodServer -U $prodUser -P $prodPassword -Q $backupQuery
    
    # Step 2: Restore to local
    Write-Host "  Restoring $db to local..."
    
    $restoreQuery = @"
RESTORE DATABASE [${db}_Sandbox]
FROM DISK = '$backupFile'
WITH 
    MOVE '$db' TO '$restorePath${db}_Sandbox.mdf',
    MOVE '${db}_Log' TO '$restorePath${db}_Sandbox_Log.ldf',
    REPLACE;
"@
    
    sqlcmd -S $localServer -U $localUser -P $localPassword -Q $restoreQuery
    
    Write-Host "  ✓ $db cloned successfully!"
}

Write-Host "`nAll databases cloned to sandbox!"
```

---

## 🔗 UPDATE CONNECTION STRINGS

**After cloning, update your app config:**

```json
// appsettings.Development.json
{
  "ConnectionStrings": {
    "FarmGenie": "Server=localhost;Database=FarmGenie_Sandbox;User ID=sa;Password=YourLocalPassword123!;",
    "MlsListing": "Server=localhost;Database=MlsListing_Sandbox;User ID=sa;Password=YourLocalPassword123!;",
    "TitleData": "Server=localhost;Database=TitleData_Sandbox;User ID=sa;Password=YourLocalPassword123!;"
  }
}
```

---

## ✅ VERIFICATION

**Test your sandbox:**

```sql
-- Check databases exist
SELECT name, size, database_id
FROM sys.databases
WHERE name LIKE '%Sandbox%';

-- Check table counts
USE [FarmGenie_Sandbox];
SELECT COUNT(*) AS TableCount FROM sys.tables;

USE [MlsListing_Sandbox];
SELECT COUNT(*) AS ListingCount FROM [dbo].[Listing];

-- Test PLS stored procedure
USE [FarmGenie_Sandbox];
EXEC dbo.usp_GetNextPlsNumber;
-- Should return: "PLS-2025-00001"
```

---

## 🎯 RECOMMENDED APPROACH FOR PLS PROTOTYPE

**For Friday prototype, I recommend:**

1. ✅ **Schema-Only** for all 3 databases
2. ✅ **Sample Data** for:
   - Your test user (AspNetUsers, UserMarketingProfile)
   - MLS master list (Mls table)
   - StatusType table
   - Area table (10-20 test areas)
   - PropertyCastType table
   - Permission/Role tables
3. ✅ **Empty** for large tables (Listing, GenieLead, etc.)

**This gives you:**
- ✅ Full schema (all tables, stored procedures, functions)
- ✅ Test data for PLS development
- ✅ Small footprint (~1-2 GB instead of 365 GB)
- ✅ Fast setup (30 minutes vs. hours)

---

## 🚨 TROUBLESHOOTING

### Issue: "Insufficient disk space"
**Solution:** Use Schema-Only approach (Option 2)

### Issue: "Cannot connect to production server"
**Solution:** 
- Check VPN connection
- Verify credentials
- Try IP address instead of hostname

### Issue: "Backup file too large to copy"
**Solution:**
- Use compression: `WITH COMPRESSION`
- Or use Schema-Only approach

### Issue: "SQL Server Express size limit"
**Solution:**
- Use SQL Server Developer Edition (free)
- Or use Docker SQL Server

---

## 📝 NEXT STEPS

1. **Choose approach** (I recommend Option 3: Hybrid)
2. **Set up local SQL Server** (if needed)
3. **Run backup/restore scripts**
4. **Verify sandbox works**
5. **Update connection strings**
6. **Start PLS development!**

---

**Status:** ✅ Ready to Execute - Choose Your Approach!



