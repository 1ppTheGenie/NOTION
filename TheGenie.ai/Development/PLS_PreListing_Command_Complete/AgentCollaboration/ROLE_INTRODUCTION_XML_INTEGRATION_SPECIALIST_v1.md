# XML/Integration Specialist - PLS RESO Engine Project Introduction

**Version:** 1.0  
**Created:** 01/14/2026 6:30 AM  
**Priority:** 🔥 **URGENT - XML System Ready by Tomorrow** ⭐ **TOP PRIORITY**

---

## 🎯 YOUR MISSION

You are the **XML/Integration Specialist** for the **PLS (Paisley RESO Listing Engine)** project. Your job is to generate XML that drives GenieCloud marketing asset rendering, following the contract exactly to ensure all assets (landing pages, social ads, postcards, brochures) are generated correctly.

**CRITICAL DEADLINE:** PLS-RESO XML and management system must be ready by tomorrow. **YOU ARE TOP PRIORITY.**

---

## 📋 WHAT IS PLS?

**PLS (Paisley RESO Listing Engine)** enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate marketing assets (landing pages, social ads, brochures) automatically via GenieCloud
- Automate circle prospecting via Listing Command integration
- Future: One-button push to publish listings to Bridge/Trestle MLSs via RESO Insert

**Your Role:** Build the XML generation bridge (Phase 4) that connects PLS to GenieCloud. **THIS IS CRITICAL FOR TOMORROW'S DEADLINE.**

---

## 🔌 YOUR INTEGRATION POINT

### GenieCloud Integration - The Critical Contract

**Contract Document:** `CONTRACT_PLS_to_GenieCloud_v6.1.md` ⭐⭐⭐ **THIS IS LAW - READ THIS FIRST**

**CRITICAL RULE:** Follow the contract EXACTLY. No deviations. No assumptions. The contract is the single source of truth.

**What GenieCloud Does:**
- Takes XML data from PLS
- Applies XSL templates (themes)
- Renders HTML/SVG/PNG/PDF assets
- Stores assets in S3
- Creates collection pages

**Marketing Assets Generated:**
- Landing pages (responsive HTML)
- Social media graphics (1080x1080 PNG)
- Postcards (print-ready PDF)
- Brochures (print-ready PDF)
- Market reports (PDF)

---

## 📚 MUST-READ DOCUMENTS (In Order) - CRITICAL

### Priority 1: Core Contract Documents ⭐⭐⭐ **READ FIRST**

1. **GenieCloud Contract v6.1** ⭐⭐⭐ **CRITICAL - READ THIS FIRST**
   - `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md`
   - **Why:** This is THE contract - follow it exactly
   - **Action:** Read this document COMPLETELY before starting any work

2. **XML Mapping Guide**
   - `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`
   - **Why:** Maps PLS data to XML structure

3. **Project Blueprint - Integration Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 7
   - **Why:** Complete integration specifications

### Priority 2: Reference Documents

4. **Production Reference Collection** ⭐
   - URL: https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52
   - **Why:** See what successful XML produces

5. **Workspace Memory Log - Integration Points**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_06_INTEGRATION_POINTS_v1.md`
   - **Why:** Historical context and integration decisions

### Priority 3: Supporting Documents

6. **Database Schema**
   - `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
   - **Why:** Understand data structure you'll be mapping

---

## 🔑 CRITICAL INFORMATION

### XML Structure Overview

```xml
<?xml version="1.0" encoding="UTF-8"?>
<renderRoot>
    <output 
        userId="{asp-user-id}"
        theme="compass"
        themeHue="dark"
        renderId="pls-{pls-number}-{asset-name}"
        statusTypeID="6"  <!-- 6=Private, 14=Coming Soon -->
    />
    <xslAsset>landing-pages/pls-hollywood</xslAsset>
    <agents>
        <agent>
            <!-- Agent data from UserMarketingProfile -->
        </agent>
    </agents>
    <areas>
        <area>
            <!-- Area data for market stats -->
        </area>
    </areas>
    <single>
        <mlsNumber>PLS100000A</mlsNumber>
        <price>749000</price>
        <statusTypeID>6</statusTypeID>
        <!-- Full property data -->
    </single>
</renderRoot>
```

### Critical Format Requirements

| Field | Format | Example | ❌ WRONG |
|-------|--------|---------|----------|
| `bedrooms` | Attribute | `<bedrooms count="4"/>` | `<bedrooms>4</bedrooms>` |
| `bathrooms` | Attributes | `<bathrooms total="3" full="3" half="0"/>` | `<bathrooms>3</bathrooms>` |
| `images` | Child elements | `<image src="..."/>` | Just URLs in text |
| `statusTypeID` | Number | `6` or `14` | String "Private Listing" |

### Status Type Codes

| StatusTypeID | Name | PLS Use | XSL Caption |
|:------------:|------|:-------:|-------------|
| **6** | **Private Listing** | **✅** | "Private Listing" |
| **14** | **Coming Soon** | **✅** | "Coming Soon" |

**CRITICAL:** PLS should ONLY use StatusTypeID 6 or 14.

---

## ✅ YOUR DELIVERABLES

### Must Complete (In Order):

1. **Read Contract Completely** ⭐⭐⭐ **CRITICAL FIRST STEP**
   - Read `CONTRACT_PLS_to_GenieCloud_v6.1.md` COMPLETELY
   - Understand every field requirement
   - Understand validation rules
   - Understand error handling

2. **Coordinate with Backend API Specialist**
   - Determine implementation location (within Backend API codebase)
   - Coordinate on `/render` endpoint implementation

3. **Implement XML Generation**
   - Create `PlsService.BuildXml()` method
   - Map PLS listing data to XML structure
   - Map agent data to XML structure
   - Map area data to XML structure
   - Follow contract exactly

4. **Implement XML Validation**
   - Validate XML structure
   - Validate required fields
   - Validate field formats (attributes vs elements)
   - Validate StatusTypeID values

5. **Integrate with GenieCloud API**
   - Call `POST https://cloud-api.thegenie.ai/api/render`
   - Handle GenieCloud responses
   - Handle errors
   - Return collection URL

6. **Test XML Generation**
   - Test with sample PLS listing
   - Verify XML structure matches contract
   - Verify GenieCloud accepts XML
   - Verify assets are generated

**Success Criteria:**
- ✅ XML matches contract specification exactly
- ✅ GenieCloud accepts XML and creates collection
- ✅ Marketing assets (social ads, postcards, brochures) generated
- ✅ Landing pages created successfully
- ✅ Collection URLs returned correctly

---

## 🚨 CRITICAL RULES

1. **Contract is Law** - Follow `CONTRACT_PLS_to_GenieCloud_v6.1.md` exactly - no deviations
2. **Read Contract First** - Read contract COMPLETELY before starting any work
3. **Test XML Schema** - Validate XML against contract before sending to GenieCloud
4. **Verify Assets** - Test that all marketing assets are generated correctly
5. **Coordinate with Backend** - XML generation is part of Backend API `/render` endpoint

---

## 📞 QUICK REFERENCE

- **GenieCloud Contract:** `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md` ⭐⭐⭐ **CRITICAL**
- **XML Mapping:** `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`
- **Production Reference:** https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52
- **Status Tracking:** `AgentStatus/AGENT_STATUS_XML_INTEGRATION_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **READY TO START - TOP PRIORITY**

**You're Phase 4 - the XML bridge. READ THE CONTRACT FIRST. Follow it exactly. This is critical for tomorrow's deadline.**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 01/14/2026 6:30 AM | JR (Project Manager) | Initial role introduction for XML/Integration Specialist. Focused on PLS-RESO project with complete knowledge locations. Emphasizes contract compliance and tomorrow's deadline. |
