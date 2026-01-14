# PLS RESO Engine - Workspace Memory Log: Database Design & Implementation
**Version:** 1.0  
**Created:** 01/10/2026  
**Last Updated:** 01/10/2026  
**Topic:** Database Schema, Tables, Stored Procedures, Master Data, SQL Scripts  
**Status:** ✅ Active

---

## 📋 TOPIC OVERVIEW

This memory log captures all discussions, decisions, and documentation related to:
- Database schema design
- Table structures and relationships
- Stored procedures
- Master data requirements
- SQL implementation scripts
- Database normalization decisions

---

## 🗄️ DATABASE STRATEGY

### Core Principle
**Zero Schema Changes** - Leverage existing `MlsListing.dbo.Listing` structure with MlsId=777

### Database Locations
- **MlsListing Database** - Main listing table (existing, no changes)
- **FarmGenie Database** - PLS-specific tables and procedures

---

## 📊 CORE TABLES

### MlsListing.dbo.Listing (Existing - No Changes)
- **MlsId:** 777 (PLS identifier)
- **StatusTypeID:** 6 (Private Listing) - NEEDS INSERT, 14 (Coming Soon) - EXISTS
- **PropertyCastTypeId:** 4 (PLS)
- **All existing columns** - No schema changes required

### FarmGenie.dbo.PlsListingOwnership (New)
**Purpose:** Links users to PLS listings (many-to-many relationship)

**Columns:**
- `PlsListingOwnershipId` (PK, int, identity)
- `UserId` (FK to AspNetUsers, uniqueidentifier)
- `ListingNumber` (FK to MlsListing.dbo.Listing.MlsNumber, varchar(50))
- `IsPrimaryOwner` (bit, default 0)
- `CreatedDate` (datetime, default GETDATE())
- `CreatedBy` (varchar(100))

**Indexes:**
- Unique index on (UserId, ListingNumber)
- Index on ListingNumber for lookups

### FarmGenie.dbo.PlsNumberSequence (New)
**Purpose:** Generates sequential PLS numbers (PLS100000A format)

**Columns:**
- `SequenceId` (int, identity)
- `CurrentNumber` (int, default 100000)
- `LastUpdated` (datetime, default GETDATE())

### FarmGenie.dbo.pls_tracking (New - Normalized Schema v3.0)
**Purpose:** Tracks PLS listing lifecycle events

**Columns:**
- `pls_tracking_id` (PK, bigint, identity)
- `listing_number` (FK to MlsListing.dbo.Listing.MlsNumber, varchar(50))
- `status_type_id` (FK to pls_status_type, int)
- `source_type_id` (FK to pls_source_type, int)
- `event_date` (datetime, default GETDATE())
- `notes` (varchar(500), nullable)
- `created_by` (varchar(100))

**Indexes:**
- Index on listing_number
- Index on event_date

### FarmGenie.dbo.pls_status_log (New - Normalized Schema v3.0)
**Purpose:** Historical status changes for PLS listings

**Columns:**
- `pls_status_log_id` (PK, bigint, identity)
- `listing_number` (FK to MlsListing.dbo.Listing.MlsNumber, varchar(50))
- `status_type_id` (FK to pls_status_type, int)
- `changed_date` (datetime, default GETDATE())
- `changed_by` (varchar(100))
- `previous_status_id` (int, nullable)

### FarmGenie.dbo.pls_status_type (New - Lookup Table)
**Purpose:** Master data for PLS status types

**Values:**
- 1: Draft
- 2: Active
- 3: Pending MLS
- 4: Published to MLS
- 5: Archived

### FarmGenie.dbo.pls_source_type (New - Lookup Table)
**Purpose:** Master data for PLS source types

**Values:**
- 1: Manual Entry
- 2: TitleGenie Import
- 3: MLS Import
- 4: API

### FarmGenie.dbo.pls_status_mapping (New - Mapping Table)
**Purpose:** Maps PLS status types to MlsListing StatusTypeID

**Columns:**
- `pls_status_type_id` (FK to pls_status_type, int)
- `mls_status_type_id` (int) - Maps to MlsListing.dbo.StatusType.StatusTypeID

---

## 🔧 STORED PROCEDURES

### usp_GetNextPlsNumber
**Purpose:** Generates next PLS number in format PLS{6-digit}{letter}

**Format:** PLS100000A, PLS100001B, etc. (6 digits + single letter suffix)

**Logic:**
1. Lock PlsNumberSequence table
2. Increment CurrentNumber
3. Calculate letter suffix (A-Z, then AA-ZZ)
4. Return formatted number
5. Update LastUpdated timestamp

**Usage:**
```sql
DECLARE @PlsNum VARCHAR(10);
EXEC FarmGenie.dbo.usp_GetNextPlsNumber @PlsNumber = @PlsNum OUTPUT;
SELECT @PlsNum; -- Returns: PLS100000A
```

---

## 📦 MASTER DATA

### Required Master Data Inserts

1. **pls_status_type** - Status type lookup values
2. **pls_source_type** - Source type lookup values
3. **pls_status_mapping** - Status mapping to MlsListing
4. **StatusType** (MlsListing) - StatusTypeID 6 (Private Listing) - NEEDS INSERT
5. **PlsNumberSequence** - Initialize with CurrentNumber = 100000

---

## 📁 SQL SCRIPTS

| Script | Version | Purpose | Database |
|--------|---------|---------|----------|
| **PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql** | 3.0 | Create all PLS tables | FarmGenie |
| **PLS_DATABASE_PLSNUMBER_SEQUENCE_v4.sql** | 4.0 | Create sequence table and procedure | FarmGenie |
| **PLS_DATABASE_MASTER_DATA_v3.sql** | 3.0 | Insert master data | FarmGenie + MlsListing |
| **PLS_STORED_PROCEDURES_COMPLETE_v1.sql** | 1.0 | All stored procedures | FarmGenie |
| **PLS_COMPLETE_DATABASE_SETUP_v1.sql** | 1.0 | Complete setup (all scripts combined) | Both |

---

## 🔄 SCHEMA EVOLUTION

### v1.0 → v2.0 Changes
- Added collaborator concept (later removed)
- Initial table structure

### v2.0 → v3.0 Changes (Normalized Schema)
- **Removed:** Collaborator concept, denormalized tracking
- **Added:** Lookup tables (pls_status_type, pls_source_type)
- **Added:** Mapping table (pls_status_mapping)
- **Added:** Normalized tracking (pls_tracking, pls_status_log)
- **Changed:** PLS number format to PLS{6-digit}{letter}

---

## 📚 KEY DOCUMENTS

| Document | Version | Purpose |
|----------|---------|---------|
| **PLS_DATABASE_SCHEMA_RELATIONAL_v1.md** | 1.0 | Relational DB schema with joins & indexes |
| **PLS_SCHEMA_VISUAL_DIAGRAM_NORMALIZED_v3.md** | 3.0 | Visual ERD diagram |
| **PLS_SCHEMA_CHANGES_v2_to_v3.md** | 2.0 | Schema evolution documentation |
| **PLS_DATABASE_ITEMS_CHECKLIST_v3.md** | 3.0 | Database setup checklist |

---

## 🔑 KEY DECISIONS

1. **MlsId = 777** - Changed from 999 to 777 for PLS identifier
2. **Normalized Schema v3.0** - Moved from denormalized to lookup tables
3. **PLS Number Format** - PLS{6-digit}{letter} (e.g., PLS100000A)
4. **No Schema Changes to MlsListing** - Use existing structure
5. **StatusTypeID 6** - Needs INSERT into MlsListing.dbo.StatusType
6. **PropertyCastTypeId = 4** - Standard for PLS listings

---

## ⚠️ CRITICAL NOTES

1. **StatusTypeID 6** does NOT exist in database - requires INSERT before PLS can use Private Listing status
2. **StatusTypeID 14** (Coming Soon) EXISTS - ready to use
3. **PlsNumberSequence** must be initialized with CurrentNumber = 100000
4. **All scripts must be tested in Sandbox first** before Production

---

## 📝 CHANGELOG

- **2026-01-10:** Initial workspace memory log created
- **2026-01-05:** Schema normalized to v3.0, PLS number format changed
- **2026-01-04:** MlsID changed to 777
- **2026-01-02:** Initial database schema designed

---

**Status:** ✅ Active - All database design decisions documented
