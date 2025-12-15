# Changelog: Versium Cache PropertyID Migration
## First American (DataTree) → Attom PropertyID Update
### Version 1.0 | Date: 12/14/2025

---

## Section: Data Providers / Versium

**Related Systems:**
- FarmGenie.dbo.DataAppendContactLookup (Versium cache table)
- TitleData.dbo.AssessorDataPropertyMap (PropertyID mapping)
- Smart.Api.DataAppend (Versium API integration)

---

## Change Summary

| Item | Description |
|------|-------------|
| **Change Type** | Data Migration / Cache Preservation |
| **Affected Table** | FarmGenie.dbo.DataAppendContactLookup |
| **Records Affected** | 17.7M cache records (3.2M unique PropertyIDs) |
| **Purpose** | Preserve Versium lookup cache after PropertyID system change |
| **Estimated Savings** | ~15M Versium credits ($75,000+) |

---

## Background

When TheGenie migrated from **First American (DataTree)** to **Attom** as the property data provider, the PropertyID format changed. The Versium cache uses PropertyID as part of the lookup key:

```
Cache Key Format: ::PID-{PropertyId}::L-{LastName}::F-{FirstName}
```

Without migration, all 17.7M cached Versium lookups would become orphaned, requiring re-purchase of data at 22 credits per property.

---

## Changes Made

### 1. Analysis Phase (12/14/2025)

| Action | Result |
|--------|--------|
| Identified cache table | `FarmGenie.dbo.DataAppendContactLookup` |
| Counted total records | 17,730,412 |
| Counted unique PropertyIDs | 3,226,651 |
| Identified key format | `::PID-{id}::L-{name}::F-{name}` |

### 2. Mapping Creation (12/14/2025)

| Action | Result |
|--------|--------|
| Created mapping table | `FarmGenie.dbo.CachePropertyIdMapping` |
| Extracted cached PropertyIDs | 3,226,651 rows |
| Mapped to Attom IDs via FIPS+APN | 680,182 matches |
| Match rate | 21% (limited by Attom 6-state coverage) |

### 3. PropertyMap Update (12/14/2025)

| Action | Result |
|--------|--------|
| Updated `AssessorDataPropertyMap.AttomId` | 1,627,943 rows |
| Cross-reference source | `TitleData.dbo.AssessorDataLookupLatest` |
| Matching method | FIPS + APN exact match |

### 4. Migration Procedure Created (12/14/2025)

| Artifact | Location |
|----------|----------|
| Stored Procedure | `dbo.usp_MigrateVersiumCache_DataTreeToAttom` |
| Modes | Preview (safe) and Execute (with backup) |
| Status | **Ready but NOT executed** |

---

## Files Created

| File | Type | Location |
|------|------|----------|
| `usp_MigrateVersiumCache_DataTreeToAttom_v1.sql` | SQL Script | `Development/SQL/` |
| `AUDIT_VersiumCache_Architecture_v1.md` | Audit Doc | `Development/DataMigrations/` |
| `SOP_VersiumCache_Migration_v1.md` | SOP | `Development/DataMigrations/` |
| `SPEC_Versium_Credits_DataAppend_v1.md` | Spec | `Development/DataMigrations/` |

---

## Source Code References

| File | Path | Relevance |
|------|------|-----------|
| `ActionCacheCheck.cs` | `Smart.Api.DataAppend/Smart.DataAppend.Core/BLL/Actions/` | Cache lookup logic |
| `Utility.cs` | `Smart.Api.DataAppend/Smart.DataAppend.Core/BLL/` | Cache key generation |
| `AssessorDataPropertyMap.cs` | `Smart.Web.FarmGenie/Smart.Data/SQL/` | Entity Framework model |

---

## Next Steps

| Step | Owner | Status |
|------|-------|--------|
| Review this changelog | Team Lead | Pending |
| Execute migration in staging | DBA | Pending |
| Validate cache hits | Dev Team | Pending |
| Execute in production | DBA | Pending |

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Data loss | Procedure creates backup table before update |
| Wrong mappings | Preview mode shows exactly what will change |
| Performance | Batch processing, off-hours execution |

---

*Document Version: 1.0 | Created: 12/14/2025*
*Environment: PRODUCTION (192.168.29.45)*
*Procedure Status: Created but NOT executed*
