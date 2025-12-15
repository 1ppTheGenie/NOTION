# Source Code Changelog
## Static Copy Analysis: November 2025
### Version 1.0 | Date: 12/14/2025

---

## Document Purpose

This changelog documents the state of the TheGenie source code as captured in the static copy made on **November 8, 2025**. It provides an inventory of all files, organized by area and modification date, for executive review.

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Static Copy Date** | 11/08/2025 |
| **Total Code Files** | 6,639 |
| **Genie.Source.Code** | 5,525 files |
| **GenieCLOUD** | 1,114 files |
| **Most Recent Changes** | 11/08/2025 (557 files) |
| **Bulk of Files** | 11/06/2025 (6,082 files) |

---

## Files by Date

| Date | Files Changed | Primary Areas |
|------|---------------|---------------|
| **11/08/2025** | 557 | GenieCLOUD XSL templates, Report pages |
| **11/06/2025** | 6,082 | All backend services, APIs, Windows services |

---

## Section 1: Backend Services (Windows Services)

### Smart.Service.TaxDataParser (Attom Data Integration)

Most recently modified service - handles property data from Attom.

| File | Modified | Size | Purpose |
|------|----------|------|---------|
| AttomDataFileHandler.cs | 11/06/2025 | 4,229 | Main Attom file handler |
| AttomDataFileHandlerBase.cs | 11/06/2025 | 2,899 | Base handler class |
| AttomDataParcelFileHandler.cs | 11/06/2025 | 3,573 | Parcel data handler |
| AttomFileHandlerFactory.cs | 11/06/2025 | 1,144 | Factory pattern |
| AttomFileProcessor.cs | 11/06/2025 | 3,056 | File processing logic |
| AttomService.cs | 11/06/2025 | 1,172 | Service coordination |
| AttomAvailableFileManager.cs | 11/06/2025 | 5,212 | File availability tracking |
| AttomUnzippedDataDirectory.cs | 11/06/2025 | 1,110 | Unzip directory handling |
| AttomFileBase.cs | 11/06/2025 | 553 | Base file class |
| ServiceConfiguration.cs | 11/06/2025 | 2,532 | Service config |

**Summary:** Active development on Attom property data integration.

---

### Smart.Service.PropertyCasterWorkflow (Campaign Workflow)

Core workflow engine for Competition Command and Listing Command campaigns.

| File | Modified | Size | Purpose |
|------|----------|------|---------|
| QueueManager.cs | 11/06/2025 | - | Queue management |
| PropertyCasterContext.cs | 11/06/2025 | - | Database context |
| EnumWorkflowActionType.cs | 11/06/2025 | - | Workflow action types |
| EnumPropertyCastWorkflow.cs | 11/06/2025 | - | Workflow enums |
| HubAssetData.cs | 11/06/2025 | - | Hub asset handling |
| ConfigurationAction*.cs | 11/06/2025 | - | Action configurations (10+ files) |
| MlsListingInfo.cs | 11/06/2025 | - | MLS listing data |
| EnumLeadInquiryType.cs | 11/06/2025 | - | Lead types |

**Summary:** Workflow engine with action configurations for SMS, Facebook, Direct Mail campaigns.

---

### Smart.Service.PropertyCast

Property casting (campaign triggering) service.

| File | Modified | Size | Purpose |
|------|----------|------|---------|
| ListingWithMasterAgents.cs | 11/06/2025 | - | Agent listing associations |
| RepositoryPropertyCaster.cs | 11/06/2025 | - | Data repository |
| PropertyCasterContext.cs | 11/06/2025 | - | EF context |
| TestZipCodeListings.cs | 11/06/2025 | - | Unit tests |
| GetAgentInfo.cs | 11/06/2025 | - | Agent info retrieval |

---

## Section 2: Web APIs

### Smart.Api.DataAppend (Versium Integration)

Handles Versium data append operations (Email, Phone, Demographics, Financial).

| File | Modified | Size | Purpose |
|------|----------|------|---------|
| ActionVersiumBase.cs | 11/06/2025 | - | Base Versium API class |
| ActionCacheCheck.cs | 11/06/2025 | - | Cache lookup logic |
| Utility.cs | 11/06/2025 | - | Cache key generation |
| DataAppendRepository.cs | 11/06/2025 | - | Data access |

**Summary:** Critical for Versium cache migration project.

---

### Smart.Api.Oculus

External API for data services.

| Files | Count |
|-------|-------|
| Core | 53 .cs files |
| Data | 41 .cs files |
| Model | 65 .cs files |

---

### Smart.Web.FarmGenie (Main Web Application)

The primary web application with dashboard, agent portal, and admin interfaces.

| Component | Files |
|-----------|-------|
| Total C# files | 2,972 |
| TypeScript files | 566 |
| CSS files | 483 |

**Key Areas:**
- `Smart.Core/BLL/OwnedArea/` - Area ownership management
- `Smart.Core/BLL/Billing/` - WHMCS billing integration
- `Smart.Dashboard/BLL/` - Dashboard business logic
- `Smart.NG.Agent/` - Angular agent portal

---

## Section 3: GenieCLOUD (Frontend Assets)

### XSL Templates (Report Generation)

Most recently updated area (11/08/2025).

| File | Size | Purpose |
|------|------|---------|
| home-prices-style-1.xsl | 3,033 | Home prices report v1 |
| home-prices-style-2.xsl | 4,691 | Home prices report v2 |
| home-prices-style-3.xsl | 6,032 | Home prices report v3 |
| home-prices-style-4.xsl | 8,004 | Home prices report v4 |
| home-prices-style-5.xsl | 5,836 | Home prices report v5 |
| fast-facts-style-1.xsl | 6,471 | Fast facts v1 |
| fast-facts-style-2.xsl | 7,514 | Fast facts v2 |
| ed-kaminsky-*.xsl | Various | Custom agent templates |
| single-listing-*.xsl | Various | Listing display |
| sales-to-list-price.xsl | 7,115 | Market analytics |

**Total XSL files:** 400+

---

### Landing Pages (React/Solid.js)

| File | Version | Purpose |
|------|---------|---------|
| _LandingPages.js | 2.5.9b | Main landing page controller |
| _LeadCtaTag.js | 2.5.9b | CTA popup handling |
| _Genies.js | 2.5.9b | Core components |
| MarketUpdate.js | - | Market update display |
| MarketRadar.js | - | Market radar component |
| FastFacts.js | - | Fast facts component |
| PeopleBuying.js | - | People buying component |

**Versions in static copy:**
- 2.4.19
- 2.5.7
- 2.5.9b

---

### Genie Tools

| Tool | Purpose |
|------|---------|
| collection-editor | Asset collection management |
| error-viewer | Error monitoring |
| theme-editor | Theme customization |
| monitor | System monitoring |

---

## Section 4: Configuration Files

### appsettings.json Files

| Service | Location |
|---------|----------|
| PropertyCasterWorkflow | WindowsService/Smart.Service.PropertyCasterWorkflow/ |
| TaxDataParser | WindowsService/Smart.Service.TaxDataParser/ |
| Various APIs | Web/Smart.Api.*/ |

---

## Section 5: Test Files

| Test Project | Files |
|--------------|-------|
| Smart.Test.CastWorkflow | TestWorkflow01-12 configurations |
| Smart.Test.PropertyCast | TestZipCodeListings |
| Smart.TaxDataParser.Test | UnitTestTaxData |

---

## File Type Summary

| Extension | Genie.Source | GenieCLOUD | Total |
|-----------|--------------|------------|-------|
| .cs | 4,521 | 0 | 4,521 |
| .ts | 566 | 0 | 566 |
| .js | 0 | 360 | 360 |
| .jsx | 0 | 80+ | 80+ |
| .xsl | 0 | 429 | 429 |
| .json | 50+ | 50+ | 100+ |
| .css | 483 | 44 | 527 |
| .config | 50+ | 0 | 50+ |

---

## Key Observations

### 1. Recent Development Focus (November 2025)

- **Attom Integration:** Heavy work on TaxDataParser service for Attom property data
- **Report Templates:** XSL templates for market reports actively updated
- **Workflow Engine:** PropertyCasterWorkflow configurations refined

### 2. Architecture Patterns

- **Entity Framework:** Used across data access layers
- **Repository Pattern:** Standard data access abstraction
- **Factory Pattern:** AttomFileHandlerFactory for handler creation
- **WHMCS Integration:** Existing patterns for billing

### 3. Frontend Stack

- **GenieCLOUD:** React/Solid.js with Vite
- **FarmGenie:** Angular (Smart.NG.Agent)
- **XSL Transforms:** Report generation

---

## Recommendations for Next Steps

1. **Compare with Live:** Use Git to compare this static copy against current production
2. **Track Changes:** Implement changelog tracking going forward
3. **Version Control:** Ensure all changes are committed with descriptive messages
4. **Documentation:** Document major changes as they occur

---

## Appendix A: Full File Count by Directory

| Directory | File Count |
|-----------|------------|
| Web/Smart.Web.FarmGenie | 5,666 |
| WindowsService/Smart.Service.PropertyCasterWorkflow | 249 |
| WindowsService/Smart.Service.TaxDataParser | 93 |
| WindowsService/Smart.Service.PropertyCast | 126 |
| Web/Smart.Api.DataAppend | 91+ |
| Web/Smart.Api.Oculus | 200+ |
| GenieCLOUD/genie-cloud | 557 |
| GenieCLOUD/genie-cloud-1 | 557 |

---

*Document Version: 1.0 | Created: 12/14/2025 | Source: Static copy dated 11/08/2025*

