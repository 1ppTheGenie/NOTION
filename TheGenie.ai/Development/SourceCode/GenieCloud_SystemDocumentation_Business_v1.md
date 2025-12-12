# Genie Cloud Database Extractor Documentation
**Internal Business Documentation**  
**Version:** 1.0  
**Date:** November 15, 2025  
**Document Type:** System Architecture & Reverse Engineering

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [Workflow Collections](#workflow-collections)
4. [Source Code Components](#source-code-components)
5. [Database API Catalog](#database-api-catalog)
6. [Processing Flow Details](#processing-flow-details)
7. [Security and Compliance](#security-and-compliance)
8. [Operations Playbook](#operations-playbook)
9. [File Catalog](#file-catalog)
10. [Appendices](#appendices)

---

## Executive Summary

### Purpose
The Genie Cloud Database Extractor toolset provides rapid discovery of data volume hot spots and stored procedure inventories across three production SQL Server databases: `FarmGenie`, `TitleData`, and `MlsListing`. The scripts deliver consistent CSV exports that leadership can use for migration sizing, integration planning, and compliance reviews.

### Key Capabilities
- **Top Table Snapshots**: Automatically surfaces the 20 heaviest tables per database using the shared `TOP_TABLES_QUERY` statement.
- **Stored Procedure Catalogs**: Enumerates domain-relevant stored procedures filtered by business-critical keywords (Lead, Area, Stat, Assessor, Listing).
- **Driver Agnostic Connectivity**: Supports ODBC Driver 17/18, SQLAlchemy, and `pymssql` so analysts can operate in heterogeneous workstation environments.
- **Credential Management Options**: Provides both hard-coded service credentials for unattended jobs and an interactive variant that prompts analysts for temporary accounts.
- **Versioned Output**: Generates timestamped desktop folders and versioned CSVs to preserve audit trails without overwriting prior evidence.

### Business Value
- Accelerates due diligence for Genie Cloud modernization projects by making data gravity visible within minutes.
- Equips operations and security teams with an authoritative list of stored procedures that touch lead, listing, tax, and notification data domains.
- Reduces analyst effort when validating service level agreements or troubleshooting data quality issues, because the exports flag where the largest workloads sit.
- Creates a reusable foundation for building automated governance dashboards and migration readiness scorecards.

---

## Architecture Overview

### High-Level System Design
```
┌───────────────────────────┐
│ Analyst / Scheduler       │
└──────────────┬────────────┘
               │ CLI invocation
               ▼
┌───────────────────────────┐
│ Python Runtime            │
│ - genie_dump_auto*.py     │
│ - geniero_dump_v*.py      │
│ - pymssql fallback        │
└──────────────┬────────────┘
               │ ODBC / Tabular Data Stream
               ▼
┌───────────────────────────┐
│ SQL Server 2019 Instance  │
│ Databases:                │
│ - FarmGenie               │
│ - TitleData               │
│ - MlsListing              │
└──────────────┬────────────┘
               │ Rowsets (top tables + SP metadata)
               ▼
┌───────────────────────────┐
│ CSV Deliverables          │
│ - {db}_TopTables.csv      │
│ - {db}_SPs_v1.csv         │
└───────────────────────────┘
```

### Technology Stack
- **Runtime:** Python 3.x
- **Database Drivers:** `pyodbc`, `sqlalchemy` (ODBC bridge), `pymssql`
- **Data Handling:** `csv`, `pandas` (in `genie_dump_auto.py`)
- **Target Databases:** Microsoft SQL Server (default port 1433) hosted at `192.168.29.45`
- **Authentication:** Service accounts (`cursor`, `genie_ro`) or analyst-supplied credentials

### Control Surface
- Command-line execution with console logging
- Output persisted locally in the repository path or a timestamped Desktop folder (`~/Desktop/GenieAudit_v1_{timestamp}`)
- Version naming pattern prevents overwrites and keeps evidence chains intact

---

## Workflow Collections

### Collection A: Automated Top Table Snapshot (`genie_dump_auto*.py`)
**Objective:** Identify the 20 largest tables in each database for capacity planning.

```
Start
  ↓
Resolve SQL Server driver (`_select_driver` or SQLAlchemy introspection)
  ↓
Assemble connection string with encryption + trust settings
  ↓
Execute `TOP_TABLES_QUERY` against each database
  ↓
Stream results into `{database}_TopTables.csv`
  ↓
Log driver selection and generated file names
```

- `genie_dump_auto.py` uses SQLAlchemy + pandas for ease of transformation.
- `genie_dump_auto_v2.py` and `genie_dump_auto_v3.py` rely on `pyodbc` for lighter deployments; v3 enforces explicit port handling and encryption defaults.

### Collection B: Stored Procedure Discovery (`geniero_dump_v1` – `v3`)
**Objective:** Produce both top table metrics and stored procedure inventories keyed to operational keywords.

```
Start → Build timestamped Desktop folder
      → Connect with read-only service account (`genie_ro`)
      → Run `q_top` to capture top tables
      → Run `q_sps` to list procedures matching keyword filters
      → Persist outputs as `{db}_TopTables_v1.csv` and `{db}_SPs_v1.csv`
      → Close connection and repeat for next database
      → Console confirmation of output folder
```

- `v1` performs manual CSV concatenation; `v2` introduces `csv.writer` for reliability; `v3` relaxes encryption to support VPN-constrained desktops.

### Collection C: Driver Fallback (`geniero_dump_v4_pymssql.py`)
**Objective:** Guarantee connectivity when ODBC drivers are unavailable.

```
Start
  ↓
Instantiate `pymssql` connection per database
  ↓
Re-run the top table and stored procedure queries
  ↓
Write CSV outputs using Python `csv`
  ↓
Notify operator of success and target folder
```

### Collection D: Interactive Credential Run (`geniero_dump_v5_prompt.py`)
**Objective:** Allow security-conscious analysts to run audits without hard-coded credentials.

```
Prompt analyst for SQL credentials (username + password)
  ↓
Construct ODBC connection string with supplied identity
  ↓
For each database execute `q_top` and `q_sps`
  ↓
Generate Desktop audit folder containing CSV exports
  ↓
Confirm completion in console
```

---

## Source Code Components

| Module | Role | Key Functions / Blocks | Notable Behaviors | Dependencies |
|--------|------|------------------------|-------------------|--------------|
| `genie_dump_auto.py` | Baseline automation using SQLAlchemy | Inline `run(db)` function loops databases | Uses pandas `read_sql` for simplified export, encrypt flag disabled to accommodate on-prem network | `sqlalchemy`, `pandas`, `pyodbc` |
| `genie_dump_auto_v2.py` | Lightweight ODBC variant | `_select_driver`, `_connection_string`, `_fetch_top_tables`, `run_dump`, `main` | Adds dynamic driver discovery, writes CSV with standard library writer, port parameter passed separately | `pyodbc`, `csv`, `pathlib` |
| `genie_dump_auto_v3.py` | Hardened ODBC variant | Same function set as v2 with encryption toggled on by default | Binds server + port in connection string, enforces `Encrypt=yes` while trusting server certificate for compatibility | `pyodbc`, `csv`, `pathlib` |
| `geniero_dump_v1.py` | First-generation audit script | `dump`, inline loop | Manual CSV writing without `csv` module, outputs both tables and stored procedure inventories | `pyodbc`, `datetime`, `os` |
| `geniero_dump_v2.py` | Reliable CSV writer update | `dump` uses `csv.writer` | Produces cleaner CSV with proper quoting; keeps read-only account credentials | `pyodbc`, `csv` |
| `geniero_dump_v3.py` | Encryption relaxed | Same as v2 but toggles `Encrypt=no` | Intended for analysts behind SSL-intercepting appliances | `pyodbc`, `csv` |
| `geniero_dump_v4_pymssql.py` | Driver fallback | `pymssql.connect` usage | Maintains identical query logic with alternative driver | `pymssql`, `csv` |
| `geniero_dump_v5_prompt.py` | Interactive credential run | Prompts via `input` and `getpass` | Removes stored credentials from source, aligns with least privilege | `pyodbc`, `getpass`, `csv` |

### Shared Query Assets
- `TOP_TABLES_QUERY` / `q_top`: returns schema, table, and row counts ordered by volume.
- `q_sps`: filters stored procedures by keyword across `sys.objects` and `sys.sql_modules` to surface operational logic tied to leads, listings, stats, and assessor data.

---

## Database API Catalog

The repository includes CSV exports that act as a point-in-time catalog of key stored procedures. Counts are derived from the checked-in artifacts.

### FarmGenie Stored Procedures (`Sps-FarmGenie.v1.csv`)
- **Procedures Listed:** 28
- **Operational Themes:** Lead management (`GenieLeadIsFirstNameMatch`), area analytics (`GetAreaCounts`, `HubCloudSurroundingAreas`), marketing notifications (`NotificationGetNewListingsByDate`), data hygiene (`MonitorSmsMissedAreaCodes`).
- **Usage Insight:** Focused on outbound engagement and area intelligence supporting Genie Cloud marketing workflows.

### Master Database Stored Procedures (`Sps-Master.v1.csv`)
- **Procedures Listed:** 907
- **Operational Themes:** Contact lifecycle (`ContactUpdateOptedOutFlagByContactID`), MLS ingestion pipeline (`del_spMLSParserStatusUpdate`, `ExportMlsListingsMessageSend`), property watch analytics (`GeneratePropertyWatchStatisticsReport`), infrastructure maintenance (`DatabaseIntegrityCheck`).
- **Observation:** The Master database functions as the integration hub, orchestrating MLS feeds, contact management, marketing fulfillment, and data warehouse maintenance.

### MLSListing Stored Procedures (`Sps-MLSListing.v1.csv`)
- **Procedures Listed:** 280
- **Operational Themes:** Polygon + geography tooling (`FindPolygonsByPoint`, `CombineMultiplePolygonsCreateNew`), listing aggregation (`AggregationProcessingComplete`, `ApiHubGetListingsForStats`), farm analytics (`FarmAgentListingSelectByAgentID_v2`).
- **Observation:** Emphasizes geospatial operations and analytics endpoints that feed Genie Cloud reporting.

### TitleData Stored Procedures (`Sps-TitleData.v1.csv`)
- **Procedures Listed:** 112
- **Operational Themes:** ATTOM tax import orchestration (`Attom_TaxImport_AssessorData_InsertUpdate`), mortgage and deed ingestion (`A25_MortgageDeedData_dt_v2_Insert`), foreclosure tracking (`A25_NODData_dt_v2_Update`).
- **Observation:** TitleData holds sensitive ownership, mortgage, and foreclosure datasets powering valuation and compliance features.

### Table Volume Snapshots
- `FarmGenie.v1.csv`, `TitleData.Tablesv1.csv`, and `MLSListing.Tablesv1.csv` each list the top 20 tables by row count. Row volumes range from ~10⁴ to 2.96×10⁸ records, highlighting the massive footprint of `Listing_Feature` and related MLS history tables.

---

## Processing Flow Details

### Stage 1: Environment Preparation
1. Resolve SQL Server driver (`pyodbc.drivers()` with preference for versions 18, 17, 13).
2. Construct connection string with consistent parameters (server, port, encryption, trust configuration).
3. Prepare output directory (`Path(__file__).parent` or timestamped Desktop folder) and set filename conventions.

### Stage 2: Data Extraction
1. Establish `pyodbc` / `pymssql` / SQLAlchemy connection with autocommit enabled.
2. Execute `TOP_TABLES_QUERY` to pull the largest tables.
3. For `geniero_*` scripts, execute `q_sps` to scan stored procedure definitions containing operational keywords.

### Stage 3: Serialization & Delivery
1. Marshal rowsets into CSV using either pandas `to_csv` or `csv.writer` to ensure consistent quoting.
2. Persist outputs using deterministic naming (`{Database}_TopTables.csv`, `{Database}_SPs_v1.csv`).
3. Print console summary of driver used and generated files to support manual audit logging.

### Stage 4: Analyst Consumption
1. Import CSVs into Excel, Power BI, or data cataloging tools.
2. Use row counts to prioritize migration testing and index tuning.
3. Use stored procedure lists to scope application refactors, API wrappers, and deprecation candidates.

---

## Security and Compliance

- **Credential Exposure:** Several scripts embed service credentials in plaintext (`cursor`, `genie_ro`). Immediate action recommended to migrate to environment variables or secrets managers.
- **Encryption Behavior:** Variants toggle `Encrypt=yes/no`. Ensure analysts select the hardened (`v3`) script when connecting over untrusted networks.
- **Access Scope:** Stored procedure query filters target business-critical operations; handle exports under least privilege policies and store them in encrypted locations.
- **Auditability:** Timestamped folders and versioned filenames preserve forensic history but should be cataloged in secure evidence repositories with checksum validation.

---

## Operations Playbook

### Prerequisites
- Python 3.x environment with `pyodbc`, `pandas`, `sqlalchemy`, and `pymssql` installed.
- SQL Server network access to `192.168.29.45:1433`.
- Valid service account or analyst credentials with read permissions on `sys` catalogs and target schemas.

### Running `genie_dump_auto_v3.py`
1. `python genie_dump_auto_v3.py`
2. Confirm console output: driver used and generated CSV filenames.
3. Validate each CSV contains 20 records plus header.

### Running `geniero_dump_v5_prompt.py`
1. `python geniero_dump_v5_prompt.py`
2. Supply temporary credentials when prompted.
3. Retrieve outputs under `~/Desktop/GenieAudit_v1_{timestamp}` and archive securely.

### Verification Checklist
- Ensure CSV timestamp matches execution window.
- Spot check row counts against SQL Server Management Studio queries.
- Confirm stored procedure CSVs retain alphabetical sorting for searchability.

### Operational Recommendations
- Wrap scripts in scheduled tasks (e.g., monthly) to monitor growth trends.
- Feed CSV outputs into centralized data catalog (e.g., Collibra, Alation) for lineage tracking.
- Replace plaintext credentials with managed identity solutions (Azure Managed Identity, AWS Secrets Manager, or HashiCorp Vault).

---

## File Catalog

A detailed asset catalog with script-by-script metadata is maintained in `GenieCloud_AssetCatalog_Business_v1.csv`. Refer to that file for:
- Component descriptions and responsibilities
- Dependency references
- Output file mappings and expected record counts
- Operational status (Production, Analysis, Deprecated)

---

## Appendices

### Appendix A: Data Volume Highlights
- `MLSListing`.`Listing_Feature` holds ~296M rows, indicating heavy analytical workloads and the need for partitioning strategies.
- `TitleData`.`AssessorDataProviderProperty` contains over 46M rows, underscoring the sensitivity of owner data handling.
- `FarmGenie`.`LeadPropertyMatch` (~178K rows) shows active matching logic that must be preserved during migration.

### Appendix B: Known Gaps
- Stored procedure definitions are not included; only names are cataloged. Capture scripts should be extended to export definitions where compliance allows.
- No automated unit tests accompany the Python scripts. Introduce smoke tests that validate connectivity and CSV schema.
- Error handling is minimal; consider wrapping database calls with try/except to surface actionable diagnostics.

### Appendix C: Next Actions
- Harden credential management and rotate service passwords immediately.
- Automate weekly exports and trend analysis to observe data growth.
- Integrate outputs with reverse engineering efforts on the Genie Cloud application tier to map stored procedures to API endpoints.

---

**End of Documentation**
