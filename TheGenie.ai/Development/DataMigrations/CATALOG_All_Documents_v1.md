# Document Catalog
## TheGenie Workspace - Complete File Index
### Version 1.0 | Date: 12/14/2025

---

## Quick Navigation

| Section | Documents | Location |
|---------|-----------|----------|
| [Workspace Logs](#workspace-logs) | Memory logs, session records | Root |
| [Versium/Data Append](#versiumdata-append) | Cache, credits, migration | `/docs/` |
| [Feature Requests](#feature-requests) | FR-001, FR-002, FR-003 | `/GenieFeatureRequests/` |
| [SQL Scripts](#sql-scripts) | Stored procedures, queries | `/SQL/` |
| [Reports](#reports) | Cost reports, ownership reports | Various |

---

## Workspace Logs

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| `WORKSPACE_MEMORY_LOG_2025-12-14_v1.md` | v1 | 12/14/2025 | Session log - Versium cache, Feature Requests |

---

## Versium/Data Append

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| `docs/AUDIT_VersiumCache_Architecture_v1.md` | v1 | 12/14/2025 | Reverse-engineering of cache system |
| `docs/SOP_VersiumCache_Migration_v1.md` | v1 | 12/14/2025 | Step-by-step migration procedure |
| `docs/SPEC_Versium_Credits_DataAppend_v1.md` | v1 | 12/14/2025 | Credit consumption and packages |

### Key Findings

- **Cache Table:** `FarmGenie.dbo.DataAppendContactLookup`
- **Key Format:** `::PID-{PropertyId}::L-{LastName}::F-{FirstName}`
- **Total Records:** 17.7M (3.2M unique PropertyIDs)
- **Credits/Property:** 22 (Booster package)
- **Estimated Savings:** ~15M credits if cache preserved

---

## Feature Requests

### Index

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| `docs/INDEX_Feature_Requests_Competition_Command_v1.md` | v1 | 12/14/2025 | Project overview and reading order |

### FR-001: Area Ownership & Waitlist

| Document | Version | Date |
|----------|---------|------|
| `GenieFeatureRequests/FR-001_AreaOwnership_DesignBrief_v1.md` | v1 | 12/13/2025 |
| `GenieFeatureRequests/FR-001_AreaOwnership_DevSpec_v2.md` | v2 | 12/13/2025 |
| `GenieFeatureRequests/FR-001_AreaOwnership_DiscoveryWorksheet_v1.md` | v1 | 12/13/2025 |

### FR-002: WHMCS Area Billing

| Document | Version | Date |
|----------|---------|------|
| `GenieFeatureRequests/FR-002_WHMCS_AreaBilling_DesignBrief_v1.md` | v1 | 12/13/2025 |
| `GenieFeatureRequests/FR-002_WHMCS_AreaBilling_DevSpec_v1.md` | v1 | 12/13/2025 |
| `GenieFeatureRequests/FR-002_WHMCS_AreaBilling_DiscoveryWorksheet_v1.md` | v1 | 12/13/2025 |

### FR-003: Content Configurator

| Document | Version | Date |
|----------|---------|------|
| `GenieFeatureRequests/FR-003_ContentConfigurator_DesignBrief_v1.md` | v1 | 12/13/2025 |
| `GenieFeatureRequests/FR-003_ContentConfigurator_DevSpec_v1.md` | v1 | 12/13/2025 |
| `GenieFeatureRequests/FR-003_ContentConfigurator_DiscoveryWorksheet_v1.md` | v1 | 12/13/2025 |

### Master Discovery

| Document | Version | Date |
|----------|---------|------|
| `GenieFeatureRequests/DISCOVERY_MASTER_Competition_Command_Enhancement_v1.md` | v1 | 12/14/2025 |

---

## SQL Scripts

| Script | Version | Date | Description |
|--------|---------|------|-------------|
| `SQL/usp_MigrateVersiumCache_DataTreeToAttom_v1.sql` | v1 | 12/14/2025 | Cache migration stored procedure |

### Database Objects Created (Production)

| Object | Database | Type |
|--------|----------|------|
| `CachePropertyIdMapping` | FarmGenie | Table |
| `usp_MigrateVersiumCache_DataTreeToAttom` | FarmGenie | Procedure |
| `AssessorDataPropertyMap.AttomId` | TitleData | Column (updated) |

---

## Reports

### Competition Command Reports

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| `GenieFeatureRequests/SOP_CC_Ownership_Report_v5.md` | v5 | 12/14/2025 | Lifetime ownership performance |
| `GenieFeatureRequests/SOP_CC_Monthly_Cost_Report_v1.md` | v1 | 12/14/2025 | Monthly Twilio costs |

### Data Files

| File | Location | Description |
|------|----------|-------------|
| `Genie_CC_Ownership_LIFETIME_*.csv` | `/Twilio/REPORTS/` | Ownership lifetime data |
| `Genie_CC_Ownership_MONTHLY_*.csv` | `/Twilio/REPORTS/` | Monthly performance |

---

## Source Code References

| Area | Location |
|------|----------|
| OwnedArea Management | `Genie.Source.Code_v1/.../Smart.Core/BLL/OwnedArea/` |
| WHMCS Billing | `Genie.Source.Code_v1/.../Smart.Core/BLL/Billing/` |
| Versium Data Append | `Genie.Source.Code_v1/.../Smart.DataAppend.Core/BLL/Actions/` |
| CTA System | `GenieCLOUD_v1/GenieCLOUD/genie-cloud/genie-components/src/` |

---

## Document Naming Conventions

| Prefix | Meaning |
|--------|---------|
| `SOP_` | Standard Operating Procedure |
| `SPEC_` | Technical Specification |
| `AUDIT_` | Analysis/Review document |
| `INDEX_` | Navigation/Overview document |
| `FR-XXX_` | Feature Request documents |
| `DISCOVERY_` | Discovery worksheets |
| `CATALOG_` | File index documents |

### Versioning

All documents follow: `DocumentName_vN.md`
- Never overwrite - always increment version
- Include date in MM/DD/YYYY format

---

## Folder Structure

```
C:\Cursor\
├── WORKSPACE_MEMORY_LOG_2025-12-14_v1.md    # Session log
├── docs/                                      # Documentation
│   ├── CATALOG_All_Documents_v1.md           # This file
│   ├── AUDIT_VersiumCache_Architecture_v1.md
│   ├── SOP_VersiumCache_Migration_v1.md
│   ├── SPEC_Versium_Credits_DataAppend_v1.md
│   └── INDEX_Feature_Requests_Competition_Command_v1.md
├── GenieFeatureRequests/                      # Feature Requests
│   ├── FR-001_*.md                           # Area Ownership
│   ├── FR-002_*.md                           # WHMCS Billing
│   ├── FR-003_*.md                           # Content Configurator
│   └── DISCOVERY_MASTER_*.md                 # Master discovery
├── SQL/                                       # SQL Scripts
│   └── usp_MigrateVersiumCache_*.sql
├── Twilio/                                    # Twilio exports
│   └── REPORTS/                              # CSV reports
└── Genie.Source.Code_v1/                     # Source code reference
```

---

## How to Use This Catalog

1. **Finding a document:** Use Ctrl+F to search this file
2. **Understanding versions:** Always use the highest version number
3. **Creating new documents:** Follow naming conventions above
4. **Updating documents:** Create new version, never overwrite

---

*Document Version: 1.0 | Created: 12/14/2025*

