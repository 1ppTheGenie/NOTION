# Sandbox Topology Analysis & SQL Sandbox Recommendation

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Purpose:** Analyze current sandbox topology and recommend SQL sandbox approach for PLS prototyping

---

## 🔍 CURRENT SANDBOX TOPOLOGY

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    CURRENT SANDBOX SETUP                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  LOCAL MACHINE (D: Drive)                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Source Code (VSS)                                        │   │
│  │  • Smart.Dashboard (Backend .NET)                        │   │
│  │  • Smart.NG.Agent (Frontend Angular)                     │   │
│  │  • genie-api (GenieCloud Node.js)                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                       │
│                           │ VPN Connection                        │
│                           ▼                                       │
│  PRODUCTION SERVER (192.168.29.45)                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  SQL Server (Production)                                  │   │
│  │  • FarmGenie (365 GB)                                    │   │
│  │  • MlsListing                                            │   │
│  │  • TitleData                                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  DEPLOYMENT FLOW:                                                │
│  Local Sandbox → Stage → Production                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Current Configuration

**From Master Index v3.1:**
- **Sandbox URLs:**
  - FarmGenie: `http://localhost:38949`
  - Agent Dashboard: `http://localhost:38949/agent`
  - Test Login: `shundley / 1ppINSAyay$`

**From sandbox configs:**
- **Backend:** `C:\Sandbox\Genie\Backend\Smart.Dashboard`
- **Frontend:** `C:\Sandbox\Genie\Backend\Smart.NG.Agent`
- **Cloud:** `C:\Sandbox\Genie\Cloud\genie-api`
- **Database:** `192.168.29.45` (Production via VPN)

**Connection String (from env.sandbox.txt):**
```
DB_SERVER=192.168.29.45
DB_NAME=FarmGenie
DB_USER=cursor
```

---

## 🎯 ANALYSIS: SQL SANDBOX FOR PLS PROTOTYPING

### Current Approach (Production Database)

**Pros:**
- ✅ No setup required - already working
- ✅ Real data for testing
- ✅ No disk space needed locally
- ✅ Always up-to-date with production

**Cons:**
- ❌ **RISKY** - Testing PLS on production database
- ❌ **SLOW** - VPN latency for every query
- ❌ **BLOCKING** - Can't test destructive operations
- ❌ **NO ISOLATION** - Changes affect production data
- ❌ **NO EXPERIMENTATION** - Can't test schema changes freely

### Proposed Approach (Local SQL Sandbox)

**Pros:**
- ✅ **SAFE** - Isolated from production
- ✅ **FAST** - No VPN latency (local queries)
- ✅ **FREEDOM** - Can test schema changes, stored procedures
- ✅ **EXPERIMENTATION** - Can break things without worry
- ✅ **OFFLINE** - Works without VPN connection
- ✅ **PERFECT FOR PLS** - Need to create new tables, test workflows

**Cons:**
- ⚠️ **SETUP TIME** - 1-2 hours to clone databases
- ⚠️ **DISK SPACE** - Need ~50-100 GB (with hybrid approach)
- ⚠️ **MAINTENANCE** - Need to sync schema changes occasionally

---

## 💡 RECOMMENDATION: **YES - CREATE SQL SANDBOX**

### Why SQL Sandbox is Perfect for PLS:

1. **New Database Objects:**
   - Need to create `PlsListingOwnership` table
   - Need to create `PlsNumberSequence` table
   - Need to create `usp_GetNextPlsNumber` stored procedure
   - **Can't test these on production safely!**

2. **Schema Changes:**
   - Need to INSERT StatusType 6 (Private Listing)
   - Need to INSERT MlsId 999 (PLS)
   - Need to INSERT PropertyCastTypeId 4 (PLS)
   - **Need to test these changes before production!**

3. **Workflow Testing:**
   - Need to test Listing Command integration
   - Need to test XML generation
   - Need to test GenieCloud render
   - **Can't risk breaking production workflows!**

4. **Performance:**
   - Local queries are **10-100x faster** than VPN
   - Critical for rapid prototyping
   - Can iterate quickly

---

## 🚀 RECOMMENDED APPROACH: **HYBRID CLONE**

### Strategy: Schema + Essential Data

**For PLS prototyping, you need:**

1. **Full Schema** (all tables, stored procedures, functions, views)
   - Size: ~500 MB - 1 GB
   - Time: 30 minutes

2. **Essential Data:**
   - Your test user (AspNetUsers, UserMarketingProfile)
   - MLS master list (Mls table)
   - StatusType table
   - Area table (20-50 test areas)
   - PropertyCastType table
   - Permission/Role tables
   - Sample listings (100-500 for reference)
   - Sample Attom data (1000 properties)
   - Size: ~5-10 GB
   - Time: 1 hour

**Total Size:** ~10-15 GB (vs 365 GB full clone)

**Total Time:** ~2 hours setup

---

## 📋 IMPLEMENTATION PLAN

### Step 1: Create Local SQL Server Instance

**If you don't have SQL Server locally:**
- Install SQL Server Developer Edition (FREE)
- Or use Docker SQL Server

### Step 2: Clone Databases (Hybrid Approach)

**Use the scripts in `SANDBOX_DATABASE_SETUP_v1.md`:**
1. Generate schema scripts from production
2. Create empty databases locally
3. Run schema scripts
4. Copy essential data (see list above)

### Step 3: Update Connection Strings

**Update `Web.Sandbox.config`:**
```xml
<connectionStrings>
  <add name="FarmGenie" 
       connectionString="Server=localhost;Database=FarmGenie_Sandbox;User ID=sa;Password=YourLocalPassword;" />
  <add name="MlsListing" 
       connectionString="Server=localhost;Database=MlsListing_Sandbox;User ID=sa;Password=YourLocalPassword;" />
  <add name="TitleData" 
       connectionString="Server=localhost;Database=TitleData_Sandbox;User ID=sa;Password=YourLocalPassword;" />
</connectionStrings>
```

### Step 4: Test Sandbox

**Verify:**
- Can connect to local databases
- Can query tables
- Can create PLS listings
- Can test stored procedures

---

## 🎯 FINAL RECOMMENDATION

### **YES - Create SQL Sandbox for PLS Prototyping**

**Reasons:**
1. ✅ **Safety** - Can't risk breaking production
2. ✅ **Speed** - Local queries are much faster
3. ✅ **Freedom** - Can experiment with schema changes
4. ✅ **Isolation** - PLS development won't affect production
5. ✅ **Perfect Fit** - PLS needs new tables, stored procedures, workflows

**Approach:**
- Use **Hybrid Clone** (Schema + Essential Data)
- Size: ~10-15 GB (manageable with new drive)
- Time: ~2 hours setup
- Maintenance: Sync schema changes monthly

**Alternative (If Space is Tight):**
- Use **Schema-Only** approach
- Add sample data manually as needed
- Size: ~1-2 GB
- Time: ~30 minutes setup

---

## ✅ DECISION MATRIX

| Factor | Production DB | Local SQL Sandbox |
|--------|--------------|-------------------|
| **Safety** | ❌ Risky | ✅ Safe |
| **Speed** | ❌ Slow (VPN) | ✅ Fast (local) |
| **Setup Time** | ✅ 0 minutes | ⚠️ 2 hours |
| **Disk Space** | ✅ 0 GB | ⚠️ 10-15 GB |
| **Freedom to Experiment** | ❌ Limited | ✅ Full |
| **Schema Changes** | ❌ Can't test | ✅ Can test |
| **Workflow Testing** | ❌ Risky | ✅ Safe |
| **Offline Development** | ❌ Requires VPN | ✅ Works offline |

**Winner:** **Local SQL Sandbox** (for PLS prototyping)

---

## 📝 NEXT STEPS

1. **Confirm you have SQL Server locally** (or install Developer Edition)
2. **Choose approach:**
   - **Hybrid** (recommended) - Schema + Essential Data (~10-15 GB)
   - **Schema-Only** (if space is tight) - Just structure (~1-2 GB)
3. **Run scripts from `SANDBOX_DATABASE_SETUP_v1.md`**
4. **Update connection strings in `Web.Sandbox.config`**
5. **Test sandbox connection**
6. **Start PLS development!**

---

**Status:** ✅ **RECOMMENDED - Create SQL Sandbox for PLS Prototyping**



