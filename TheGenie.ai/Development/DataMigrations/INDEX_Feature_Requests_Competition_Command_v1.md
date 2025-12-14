# Feature Requests Index
## Competition Command Enhancement Project
### Version 1.0 | Date: 12/14/2025

---

## Project Overview

| Attribute | Value |
|-----------|-------|
| **Project Name** | Competition Command Enhancement |
| **Status** | Discovery Phase |
| **Started** | 12/13/2025 |
| **Location** | `/GenieFeatureRequests/` |

---

## Feature Requests

### FR-001: Area Ownership & Waitlist System

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| [DesignBrief](../GenieFeatureRequests/FR-001_AreaOwnership_DesignBrief_v1.md) | v1 | 12/13/2025 | UI/UX design and user stories |
| [DevSpec](../GenieFeatureRequests/FR-001_AreaOwnership_DevSpec_v2.md) | v2 | 12/13/2025 | Technical specification with schema |
| [DiscoveryWorksheet](../GenieFeatureRequests/FR-001_AreaOwnership_DiscoveryWorksheet_v1.md) | v1 | 12/13/2025 | Open questions for stakeholders |

**Summary:**  
Replaces `UserOwnedArea` with enhanced `AreaOwnership` system featuring soft deletes, status tracking, waitlist for exclusive areas, and automated notifications.

---

### FR-002: WHMCS Area Billing Integration

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| [DesignBrief](../GenieFeatureRequests/FR-002_WHMCS_AreaBilling_DesignBrief_v1.md) | v1 | 12/13/2025 | Billing flow and user experience |
| [DevSpec](../GenieFeatureRequests/FR-002_WHMCS_AreaBilling_DevSpec_v1.md) | v1 | 12/13/2025 | WHMCS API integration spec |
| [DiscoveryWorksheet](../GenieFeatureRequests/FR-002_WHMCS_AreaBilling_DiscoveryWorksheet_v1.md) | v1 | 12/13/2025 | Pricing and billing questions |

**Summary:**  
Connects area purchases to WHMCS for automated billing, promo codes, bundle discounts, and de-provisioning on cancellation.

---

### FR-003: Content Configurator

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| [DesignBrief](../GenieFeatureRequests/FR-003_ContentConfigurator_DesignBrief_v1.md) | v1 | 12/13/2025 | CTA/landing page configuration UI |
| [DevSpec](../GenieFeatureRequests/FR-003_ContentConfigurator_DevSpec_v1.md) | v1 | 12/13/2025 | Database-driven CTA system |
| [DiscoveryWorksheet](../GenieFeatureRequests/FR-003_ContentConfigurator_DiscoveryWorksheet_v1.md) | v1 | 12/13/2025 | CTA strategy questions |

**Summary:**  
UI for configuring landing pages and CTAs from Genie CLOUD, enabling A/B testing and CTA rotation. Includes new CTA types (Social Follow, Newsletter Signup).

---

## Master Discovery

| Document | Version | Date | Description |
|----------|---------|------|-------------|
| [Master Discovery](../GenieFeatureRequests/DISCOVERY_MASTER_Competition_Command_Enhancement_v1.md) | v1 | 12/14/2025 | Consolidated discovery from all FRs |

---

## Supporting Documents

### Reports (SOPs)

| Document | Version | Purpose |
|----------|---------|---------|
| [SOP_CC_Monthly_Cost_Report](../GenieFeatureRequests/SOP_CC_Monthly_Cost_Report_v1.md) | v1 | Monthly Twilio cost tracking |
| [SOP_CC_Ownership_Report](../GenieFeatureRequests/SOP_CC_Ownership_Report_v5.md) | v5 | Lifetime ownership performance |

---

## Reading Order

1. **Start with Master Discovery** - Get the big picture
2. **FR-001 DesignBrief** - Understand the core ownership concept
3. **FR-001 DevSpec** - Review the technical approach
4. **FR-002 DesignBrief** - Understand billing integration
5. **FR-003 DesignBrief** - Understand CTA configuration
6. **All DiscoveryWorksheets** - Answer open questions

---

## Next Steps

| Step | Owner | Target Date |
|------|-------|-------------|
| Review and answer discovery questions | Product Team | TBD |
| Confirm WHMCS Product ID | IT Team | ASAP |
| Begin FR-001 schema development | Dev Team | Sprint 51 |
| Create sandbox environment | DevOps | Before development |

---

## Related Resources

### Source Code References

| Area | Location |
|------|----------|
| Current OwnedArea | `Smart.Core/BLL/OwnedArea/OwnedAreaManager.cs` |
| WHMCS Integration | `Smart.Core/BLL/Billing/` |
| CTA System | `GenieCLOUD/genie-components/src/` |

### Notion Pages

All documents have been uploaded to Notion under:
- Development → Competition Command Enhancement → Feature Requests

---

*Document Version: 1.0 | Created: 12/14/2025*

