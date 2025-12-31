# Master Index for TheGenie.ai Development
**Version:** 2.0  
**Created:** 12/23/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI  
**Status:** Active Master Index

---

## 📚 PURPOSE

This Master Index serves as a central reference for all key documents, rules, specifications, and resources across all TheGenie.ai development projects including Paisley Pre-Listing Suite, DevOps Ecosystem Management, and other system projects.

---

## 📋 MASTER DOCUMENTS

### Rules & Standards
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **MASTER_RULES** | `MASTER_RULES_v1.md` | 1.1 | All master rules including file versioning, data quality, link behavior |
| **MASTER_INDEX** | `MASTER_INDEX_v1.md` | 1.0 | This file - central index of all project documents |

### Project Scope & Blueprint
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Project Scope Blueprint** | `PAISLEY_PROJECT_SCOPE_BLUEPRINT_v1.md` | 1.2 | Intent, objectives, and decision-making framework |
| **Project README** | `PAISLEY_PROJECT_README_v1.md` | 1.0 | Project overview and status |
| **Project Handoff** | `Paisley2.0/PAISLEY_PROJECT_HANDOFF_v1.md` | 1.0 | Complete handoff documentation |

### Specifications & Requirements
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Pre-Listing Kit SOP** | `SOP_TITLEGENIE_PRELISTING_KIT_v1.md` | 1.0 | SOP with Lawyers Title field requirements |
| **Property Profile Gap Analysis** | `PROPERTY_PROFILE_GAP_ANALYSIS_v1.md` | 1.0 | Field-by-field comparison with Lawyers Title |
| **Data Catalog** | `PAISLEY_PRELISTING_DATA_CATALOG_v1.md` | 1.0 | Complete data field catalog |
| **Data Catalog v2** | `PAISLEY_PRELISTING_DATA_CATALOG_v2.md` | 2.0 | Updated data catalog |

### Discovery & Analysis
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Complete Walkthrough** | `PAISLEY_PRELISTING_COMPLETE_WALKTHROUGH_v1.md` | 1.0 | Complete pre-listing workflow |
| **Discovery Questions** | `PAISLEY_DISCOVERY_QUESTIONS_v1.md` | 1.0 | Discovery questions document |
| **UI Discovery Findings** | `PAISLEY_UI_DISCOVERY_FINDINGS_v1.md` | 1.0 | UI/UX discovery results |
| **Pain Points Priority** | `PAISLEY_PAIN_POINTS_PRIORITY_v1.md` | 1.0 | Prioritized pain points |

### Design & Redesign
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Revolutionary Redesign** | `PAISLEY_PRELISTING_REVOLUTIONARY_REDESIGN_v1.md` | 1.0 | Redesign vision document |
| **CSS Improvements Spec** | `PAISLEY_CSS_IMPROVEMENTS_SPEC_v1.md` | 1.0 | CSS improvement specifications |

### Workspace & Memory
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Workspace Memory Log** | `PAISLEY_WORKSPACE_MEMORY_LOG_v1.md` | 1.0 | Workspace memory and context |
| **Complete Reverse Engineering** | `PAISLEY_COMPLETE_REVERSE_ENGINEERING_v1.md` | 1.0 | Reverse engineering analysis |

---

## 🎯 KEY RULES REFERENCE

### File Versioning
- **NEVER OVERWRITE FILES** - Always use versioning (v1, v2, v3...)
- See `MASTER_RULES_v1.md` Rule #1

### Links Open in External Browser
- **ALL LINKS OPEN IN EXTERNAL BROWSER** - Use `target="_blank"` for all links
- See `MASTER_RULES_v1.md` Rule #7
- Applies to all HTML anchor tags
- **CRITICAL:** All links to HTML files (prototypes, landing pages, etc.) MUST use `target="_blank"`
- This includes links in markdown documentation that point to HTML files
- Example: `<a href="prototype/file.html" target="_blank">Link Text</a>`

### Date Format
- Master date format: **MM/DD/YYYY**
- Use consistently in all documents

### Document Requirements
- Every document must include: Version, Created date, Last Updated date, Author, Change Log
- See `MASTER_RULES_v1.md` for full requirements

---

## 🔗 EXTERNAL RESOURCES

### Master Credential Tracker
- **Location:** `G:\My Drive\Master_Credential_Tracker_v4.md`
- **Contains:** All API credentials, database access, system configurations
- **Version:** v4 (updated 12/25/2025)

### Project Universe Dashboard
- **Location:** `D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v1.html`
- **Purpose:** Master dashboard for all TheGenie.ai projects
- **Contains:** Ecosystem map, project status, feature runways, workspace memory logs index

### Database
- **Server:** 192.168.29.45
- **User:** cursor
- **Databases:** FarmGenie, TitleData, MlsListing

### GitHub
- **Repository:** 1ppTheGenie/NOTION
- **Notion Workspace:** 9b72e4ec-dce0-8155-a440-00039beadab4

---

## 📁 PROTOTYPE FILES

### HTML Prototypes
| File | Location | Version | Description |
|------|----------|---------|-------------|
| **Pre-Listing Command Center** | `prototype/prelisting_command_center_v11.html` | 11 | Main command center interface |
| **Lawyers Title Replica** | `prototype/lawyers_title_property_profile_replica_v1.html` | 1 | Exact replica of Lawyers Title PDF |
| **Seller Kit** | `prototype/seller_kit_v2.html` | 2 | Seller property kit |
| **Agent Intel Report** | `prototype/agent_intel_report_v2.html` | 2 | Agent intelligence report |
| **Seller Intel Report** | `prototype/seller_intel_report_REAL_v1.html` | 1 | Seller intelligence report |
| **Parcel Plat Map** | `prototype/parcel_plat_map_v3.html` | 3 | Parcel plat map visualization |

---

## 🏢 DEVOPS ECOSYSTEM MANAGEMENT PROJECT

**Location:** `D:\Cursor\TheGenie.ai\Development\DevOpsEcosystemManagement\`  
**Purpose:** CI/CD pipelines, webhook integrations, deployment processes, and infrastructure management

### Project Structure
| Folder | Location | Purpose |
|--------|----------|---------|
| **Deployments** | `DevOpsEcosystemManagement/Deployments/` | Release tracking, approval processes, release history |
| **CI_CD_Pipelines** | `DevOpsEcosystemManagement/CI_CD_Pipelines/` | Pipeline documentation, SOPs, infrastructure setup, analysis |
| **Webhooks** | `DevOpsEcosystemManagement/Webhooks/` | Webhook integration documentation (PayPal, SendGrid, SMS Alerts) |
| **Infrastructure** | `DevOpsEcosystemManagement/Infrastructure/` | Ecosystem management, agent installation, security audits, analysis |

### Standard Operating Procedures (SOPs)

#### CI/CD Pipeline SOPs
| SOP | Location | Version | Description |
|-----|----------|---------|-------------|
| **CI/CD Pipeline Deployment** | `DevOpsEcosystemManagement/CI_CD_Pipelines/SOPs/SOP_CICD_PIPELINE_DEPLOYMENT_v2.md` | 2.0 | Complete CI/CD pipeline deployment procedures |
| **Deployment Testing** | `DevOpsEcosystemManagement/CI_CD_Pipelines/SOPs/SOP_DEPLOYMENT_TESTING_v1.md` | 1.0 | Testing procedures for deployments |
| **Team Deployment Instructions** | `DevOpsEcosystemManagement/CI_CD_Pipelines/SOPs/TEAM_DEPLOYMENT_INSTRUCTIONS_v1.md` | 1.0 | Step-by-step deployment guide for team |

### Deployments Folder
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Deployment Approval Checklist** | `DevOpsEcosystemManagement/Deployments/Approval_Process/DEPLOYMENT_APPROVAL_CHECKLIST_v1.md` | 1.0 | Pre-flight checklist for Production approvals |
| **Release Analysis** | `DevOpsEcosystemManagement/Deployments/Release_Tracking/MANOJ_RELEASES_ANALYSIS_v1.md` | 1.0 | Analysis of releases vs Release-4 |

### CI/CD Pipelines Folder
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Deployment Process Analysis** | `DevOpsEcosystemManagement/CI_CD_Pipelines/Analysis/DEPLOYMENT_PROCESS_ANALYSIS_v1.md` | 1.0 | Complete deployment process analysis |
| **Deployment Security Audit** | `DevOpsEcosystemManagement/CI_CD_Pipelines/Analysis/DEPLOYMENT_SECURITY_AUDIT_v1.md` | 1.0 | Security audit of deployment processes |
| **Deployment Handoff v1** | `DevOpsEcosystemManagement/CI_CD_Pipelines/Handoffs/DEPLOYMENT_HANDOFF_PROMPT_v1.md` | 1.0 | Initial handoff document |
| **Deployment Handoff v2** | `DevOpsEcosystemManagement/CI_CD_Pipelines/Handoffs/DEPLOYMENT_HANDOFF_PROMPT_v2.md` | 2.0 | Updated handoff document |

### Webhooks Folder
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **PayPal Webhook Deployment Guide** | `DevOpsEcosystemManagement/Webhooks/PayPal/PAYPAL_WEBHOOK_DEPLOYMENT_GUIDE_v2.md` | 2.0 | PayPal webhook deployment guide |
| **PayPal Webhook Handoff** | `DevOpsEcosystemManagement/Webhooks/PayPal/HANDOFF_PayPal_Webhook_Deployment_v1.md` | 1.0 | PayPal webhook handoff document |
| **SendGrid Webhook Integration** | `DevOpsEcosystemManagement/Webhooks/SendGrid/SENDGRID_WEBHOOK_INTEGRATION_SPEC_v1.md` | 1.0 | SendGrid webhook integration specification |
| **SMS Alert System Spec** | `DevOpsEcosystemManagement/Webhooks/SMS_Alerts/SMS_ALERT_SYSTEM_SPEC_v1.md` | 1.0 | SMS alert system specification |
| **Service Hooks Setup** | `DevOpsEcosystemManagement/Webhooks/SMS_Alerts/SETUP_SERVICE_HOOKS_v1.md` | 1.0 | Azure DevOps service hooks setup guide |

### Infrastructure Folder
| Document | Location | Version | Description |
|----------|----------|---------|-------------|
| **Ecosystem Management** | `DevOpsEcosystemManagement/Infrastructure/Ecosystem_Management/PROJECT_GENIE_ECOSYSTEM_MANAGEMENT_v2.md` | 2.0 | Complete ecosystem audit and management |
| **Production Agent Install** | `DevOpsEcosystemManagement/Infrastructure/Agent_Installation/PRODUCTION_AGENT_INSTALL_INSTRUCTIONS_v1.md` | 1.0 | Production agent installation guide |
| **DevOps Roadmap** | `DevOpsEcosystemManagement/Infrastructure/Roadmaps/ROADMAP_DEVOPS_ENHANCEMENTS_v1.md` | 1.0 | DevOps enhancement roadmap |
| **AI Model Analysis** | `DevOpsEcosystemManagement/Infrastructure/Analysis/AI_MODEL_RECOMMENDATION_ANALYSIS_v1.md` | 1.0 | AI model analysis for workspace |

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 2.0 | 12/30/2025 | Added DevOps Ecosystem Management section with all folders, SOPs, and documents. Updated purpose to cover all projects. Updated Master Credential Tracker to v4. Added Project Universe Dashboard reference. |
| 1.0 | 12/23/2025 | Initial master index creation - comprehensive index of all Paisley project documents |

---

*File: MASTER_INDEX_v1.md*  
*Location: D:\Cursor\TheGenie.ai\Development\Paisley\*

