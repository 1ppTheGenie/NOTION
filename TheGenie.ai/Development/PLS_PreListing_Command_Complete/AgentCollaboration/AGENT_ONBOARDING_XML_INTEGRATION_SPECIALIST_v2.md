# Agent Onboarding: XML/Integration Specialist - Complete Educational Content

**Version:** 2.0  
**Created:** 01/14/2026 4:00 AM  
**Last Updated:** 01/14/2026 4:00 AM  
**Author:** JR (Project Manager)  
**Status:** ✅ **COMPREHENSIVE ONBOARDING - READY FOR AGENT**

---

## 🎯 WELCOME TO THE PLS PROJECT

You've been assigned the **XML/Integration Specialist** role for the PLS (Paisley RESO Listing Engine) project. This is a comprehensive onboarding document with ALL context, prior discovery, ecosystem knowledge, GenieCloud contract specifications, and technical requirements you need to succeed.

**Your Mission:** Generate XML that drives GenieCloud marketing asset rendering, following the contract exactly to ensure all assets (landing pages, social ads, postcards, brochures) are generated correctly.

---

## 📚 SECTION 1: PROJECT CONTEXT & VISION

### What is PLS?

**PLS (Paisley RESO Listing Engine)** is a private listing service that enables real estate agents to:
- Create "Coming Soon" and "Private Listing" properties BEFORE they hit MLS
- Generate full marketing asset kits (landing pages, social ads, brochures) automatically
- Automate circle prospecting campaigns via Listing Command integration
- Future: One-button push to publish listings directly to Bridge/Trestle MLSs via RESO Insert

### Your Role in the System

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   FRONTEND   │────────▶│   BACKEND    │────────▶│   DATABASE   │
│      UI      │         │     API      │         │              │
└──────────────┘         └──────┬───────┘         └──────────────┘
                                │
                                │ XML Generation
                                ▼
                        ┌──────────────┐
                        │  GENIECLOUD  │
                        │              │
                        │ • XSL Templates│
                        │ • Puppeteer   │
                        │ • S3 Storage  │
                        │ (YOU ENABLE)  │
                        └──────────────┘
```

**You are the bridge** that:
- Takes PLS listing data from Backend API
- Generates XML per GenieCloud contract
- Calls GenieCloud API to trigger rendering
- Returns marketing asset URLs to users

---

## 📚 SECTION 2: ECOSYSTEM INTEGRATION CONTEXT

### GenieCloud Integration - The Critical Contract

**Contract Document:** `CONTRACT_PLS_to_GenieCloud_v6.1.md` - **THIS IS LAW**

**CRITICAL RULE:** Follow the contract EXACTLY. No deviations. No assumptions. The contract is the single source of truth.

### What GenieCloud Does

**GenieCloud** is the asset rendering engine that:
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

### Your Integration Point

**Backend API Endpoint:** `POST /api/pls/{listingNumber}/render`

**Your Responsibility:**
1. Load PLS listing data from database
2. Load agent marketing data (UserMarketingProfile)
3. Load area data (for market stats)
4. Build XML per contract v6.1
5. Validate XML structure
6. Call GenieCloud API: `POST https://cloud-api.thegenie.ai/api/render`
7. Return collection URL to user

**Coordination:** Work WITHIN Backend API codebase (coordinate with Backend API Specialist)

---

## 📚 SECTION 3: GENIECLOUD CONTRACT - COMPLETE SPECIFICATIONS

### Contract Document: v6.1

**Location:** `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md`

**CRITICAL:** Read this document COMPLETELY before starting any work.

### XML Structure Overview

```xml
<?xml version="1.0" encoding="UTF-8"?>
<renderRoot>
    <!-- OUTPUT ATTRIBUTES -->
    <output 
        apiUrl="https://cloud-api.thegenie.ai/"
        siteUrl="https://cloud.thegenie.ai/"
        userId="{asp-user-id}"
        theme="compass"
        themeHue="dark"
        size="landing-page"
        renderId="pls-{pls-number}-{asset-name}"
        version="3.0.0"
        year="2025"
        areaPeriod="12"
        propertyType="0"
        withBleed="false"
        withCrops="false"
        blurPrice="false"
        hideAVM="true"
        requireSignin="false"
        isLeadCapture="false"
    />
    
    <!-- DATE PERIOD -->
    <date 
        period="Dec 2024 to Dec 2025" 
        previousPeriod="Dec 2023 to Dec 2024"
    />
    
    <!-- XSL ASSET -->
    <xslAsset>landing-pages/pls-hollywood</xslAsset>
    
    <!-- AGENT DATA -->
    <agents>
        <agent>
            <firstName>Steve</firstName>
            <lastName>Hundley</lastName>
            <!-- ... full agent data ... -->
        </agent>
    </agents>
    
    <!-- AREA DATA -->
    <areas>
        <area>
            <id>12345</id>
            <name>Boerne</name>
            <!-- ... full area data ... -->
        </area>
    </areas>
    
    <!-- PROPERTY DATA -->
    <single>
        <mlsNumber>PLS100000A</mlsNumber>
        <price>749000</price>
        <statusTypeID>6</statusTypeID>
        <!-- ... full property data ... -->
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

## 📚 SECTION 4: PRIOR DISCOVERY FINDINGS

### What Was Discovered Before You

#### 1. GenieCloud Contract Discovery

**Finding:** GenieCloud has strict XML contract that must be followed exactly

**Contract:** `CONTRACT_PLS_to_GenieCloud_v6.1.md`

**Key Discoveries:**
- XML structure is very specific
- Field formats matter (attributes vs elements)
- StatusTypeID values are critical
- Theme and themeHue affect rendering

**Your Action:** Read contract completely, understand every field requirement

#### 2. Production Reference Discovery

**Finding:** Working PLS prototype exists

**Reference Collection:**
- URL: https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52
- Property: 28827 Balcones Crk, Boerne | MLS: 1917644
- Theme: compass | Created: 12/26/2025

**Assets Generated:**
- Postcards
- Social Ads (lc-prop-post-03, lc-prop-post-01-vip)
- Landing Pages
- Market Reports

**Your Usage:** Reference this collection to see what successful XML produces

#### 3. XML Mapping Discovery

**Finding:** XML mapping document exists

**Reference:** `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`

**Purpose:** Maps PLS data fields to GenieCloud XML structure

**Your Usage:** Use this as a reference for field mapping

#### 4. Collection System Discovery

**Finding:** GenieCloud has Collection Editor (standalone tool)

**Purpose:** Manage collections after creation

**Your Responsibility:** Ensure collections are created correctly so they can be managed in Collection Editor

#### 5. CTA System Discovery

**Finding:** GenieCloud has Call-to-Action (CTA) system

**Purpose:** Track clicks and conversions on marketing assets

**Your Responsibility:** Ensure CTA system is properly integrated in XML

---

## 📚 SECTION 5: YOUR DELIVERABLES - PHASE 4

### Must Complete (In Order)

1. **Wait for Phase 2 Completion**
   - Monitor Backend API Specialist status
   - Verify `/render` endpoint structure is ready
   - Coordinate with Backend API Specialist on implementation location

2. **Read Contract Completely**
   - Read `CONTRACT_PLS_to_GenieCloud_v6.1.md` completely
   - Understand every field requirement
   - Understand validation rules
   - Understand error handling

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

7. **Verify Marketing Assets**
   - Test landing page generation
   - Test social ad generation
   - Test postcard generation
   - Verify all assets render correctly

8. **Documentation**
   - Document XML generation logic
   - Update status file
   - Announce Phase 4 complete

### Success Criteria

- ✅ XML matches contract specification exactly
- ✅ GenieCloud accepts XML and creates collection
- ✅ Marketing assets (social ads, postcards, brochures) generated
- ✅ Landing pages created successfully
- ✅ Collection URLs returned correctly
- ✅ Error handling working

---

## 📚 SECTION 6: CRITICAL TECHNICAL SPECIFICATIONS

### XML Generation Method

**Location:** Within Backend API codebase (coordinate with Backend API Specialist)

**Method Signature:**
```csharp
public string BuildXml(PlsListing listing, UserMarketingProfile agent, AreaData area, string theme, string themeHue)
{
    // Generate XML per contract v6.1
    // Return XML string
}
```

### GenieCloud API Call

**Endpoint:** `POST https://cloud-api.thegenie.ai/api/render`

**Request Body:**
```json
{
  "userId": "{asp-user-id}",
  "listingId": "pls-PLS100000A",
  "assets": [
    "landing-pages/pls-hollywood",
    "social-marketing-graphics/lc-prop-post-03",
    "social-marketing-graphics/lc-prop-post-01-vip"
  ],
  "theme": "compass",
  "themeHue": "dark",
  "xml": "<renderRoot>...</renderRoot>"
}
```

**Response:**
```json
{
  "renderId": "pls-PLS100000A",
  "status": "queued",
  "collectionUrl": "https://cloud.thegenie.ai/genie-collection/{id}"
}
```

### Data Sources

**Listing Data:**
- `MlsListing.dbo.Listing` (MlsId=777)
- `MlsListing.dbo.Photo` (photos)

**Agent Data:**
- `FarmGenie.dbo.UserMarketingProfile`
- `FarmGenie.dbo.MarketingImage` (logos, photos)

**Area Data:**
- `FarmGenie.dbo.Area` (for market stats)

---

## 📚 SECTION 7: MUST-READ DOCUMENTS (In Priority Order)

### Priority 1: Core Contract Documents (READ FIRST - CRITICAL)

1. **GenieCloud Contract v6.1** ⭐⭐⭐ **CRITICAL - READ THIS FIRST**
   - `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md`
   - **Why:** This is THE contract - follow it exactly

2. **XML Mapping Guide**
   - `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`
   - **Why:** Maps PLS data to XML structure

3. **Project Blueprint - Integration Section**
   - `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md` - Section 7
   - **Why:** Complete integration specifications

### Priority 2: Reference Documents (CRITICAL)

4. **Production Reference Collection**
   - URL: https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52
   - **Why:** See what successful XML produces

5. **Workspace Memory Log - Integration Points**
   - `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_06_INTEGRATION_POINTS_v1.md`
   - **Why:** Historical context and integration decisions

### Priority 3: Supporting Documents (Reference)

6. **Database Schema**
   - `01_Master_Documents/PLS_DATABASE_SCHEMA_RELATIONAL_v1.md`
   - **Why:** Understand data structure you'll be mapping

7. **Ecosystem Document Catalog**
   - `01_Master_Documents/PLS_ECOSYSTEM_DOCUMENT_CATALOG_v1.md`
   - **Why:** Understand how PLS fits with other systems

---

## 📚 SECTION 8: COMMON PITFALLS & SOLUTIONS

### Pitfall 1: Not Following Contract Exactly

**❌ WRONG:** Deviating from contract, making assumptions  
**✅ CORRECT:** Follow contract v6.1 exactly - no deviations

### Pitfall 2: Wrong XML Format

**❌ WRONG:** `<bedrooms>4</bedrooms>`  
**✅ CORRECT:** `<bedrooms count="4"/>`

### Pitfall 3: Wrong StatusTypeID

**❌ WRONG:** Using StatusTypeID 1, 2, 3 (Active, Sold, Pending)  
**✅ CORRECT:** Use only StatusTypeID 6 (Private) or 14 (Coming Soon)

### Pitfall 4: Missing Required Fields

**❌ WRONG:** Omitting required fields from contract  
**✅ CORRECT:** Include ALL required fields per contract

### Pitfall 5: Not Validating XML

**❌ WRONG:** Sending XML to GenieCloud without validation  
**✅ CORRECT:** Validate XML structure before sending

---

## 📚 SECTION 9: DAILY WORKFLOW

### Morning (5 minutes)
1. Check `AgentStatus/AGENT_STATUS_ALL_v1.md` for project status
2. Check Backend API Specialist status for Phase 2 completion
3. Check `AgentCollaboration/BLOCKERS_v1.md` for blockers
4. Review your status file: `AgentStatus/AGENT_STATUS_XML_INTEGRATION_v1.md`

### During Work
1. Implement XML generation following contract exactly
2. Test XML generation with sample data
3. Validate XML structure
4. Test GenieCloud API calls
5. Verify marketing assets are generated
6. Update progress in status file

### End of Day (5 minutes)
1. Update `AgentStatus/AGENT_STATUS_XML_INTEGRATION_v1.md` with progress
2. Document any blockers in `AgentCollaboration/BLOCKERS_v1.md`
3. Update deliverables checklist

---

## 📚 SECTION 10: COLLABORATION & HANDOFFS

### Dependencies
- **Backend API Specialist** - Works within Backend API codebase for `/render` endpoint
- **Database Specialist** - Needs PLS listing data structure

### Handoffs TO
- **DevOps Specialist** - Provides deployment requirements for GenieCloud integration

### Communication
- **Daily:** Update `AgentStatus/AGENT_STATUS_XML_INTEGRATION_v1.md`
- **Blockers:** Document in `AgentCollaboration/BLOCKERS_v1.md`
- **Completions:** Announce in `AgentCollaboration/HANDOFFS_v1.md`

---

## ✅ ONBOARDING CHECKLIST

Before you start work, verify you've completed:

- [ ] Read this entire onboarding document
- [ ] Read GenieCloud Contract v6.1 COMPLETELY (CRITICAL)
- [ ] Read XML Mapping Guide
- [ ] Reviewed production reference collection
- [ ] Understood XML structure requirements
- [ ] Understood StatusTypeID requirements (6 or 14 only)
- [ ] Understood field format requirements (attributes vs elements)
- [ ] Set up status tracking file
- [ ] Waiting for Phase 2 completion (Backend API Specialist)

---

## 🎯 NEXT STEPS

1. **Complete onboarding checklist above**
2. **Read Contract v6.1 COMPLETELY** - This is the most important step
3. **Wait for Phase 2 completion** - Monitor Backend API Specialist status
4. **Coordinate with Backend API Specialist** - Determine implementation location
5. **Plan XML generation** - Map all data sources to XML structure
6. **Begin implementation** - Start with XML generation method
7. **Test XML generation** - Verify structure matches contract
8. **Test GenieCloud API** - Verify assets are generated
9. **Update status and announce Phase 4 complete**

---

## 📞 ESCALATION

**If Blocked:**
1. Document in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag Backend API Specialist if endpoint coordination needed
3. Tag Project Manager (JR) if contract questions
4. Update status file with blocker details

**Questions?**
- Review contract v6.1 first
- Check production reference collection
- Review XML mapping guide
- Document questions in blockers file if needed

---

## 📚 REFERENCE QUICK LINKS

- **Your Role:** `AgentCollaboration/AGENT_ROLE_XML_INTEGRATION_SPECIALIST_v1.md`
- **GenieCloud Contract:** `01_Master_Documents/CONTRACT_PLS_to_GenieCloud_v6.1.md` ⭐⭐⭐ **CRITICAL**
- **XML Mapping:** `01_Master_Documents/PLS_GENIECLOUD_XML_MAPPING_v1.md`
- **Project Blueprint:** `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v2.0.md`
- **Production Reference:** https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52
- **Status Tracking:** `AgentStatus/AGENT_STATUS_XML_INTEGRATION_v1.md`
- **Blockers:** `AgentCollaboration/BLOCKERS_v1.md`
- **Handoffs:** `AgentCollaboration/HANDOFFS_v1.md`

---

**Status:** ✅ **COMPREHENSIVE ONBOARDING COMPLETE**

**Welcome to the team! You're building the bridge to GenieCloud that generates all the marketing assets. The contract is your bible - follow it exactly. You have all the context and knowledge you need. Let's build this right!**

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | 01/14/2026 4:00 AM | JR (Project Manager) | Comprehensive rewrite with full ecosystem context, prior discovery findings, complete GenieCloud contract specifications, XML structure requirements, common pitfalls, and educational content. This is the complete educational package for XML/Integration Specialist onboarding. |
| 1.0 | 01/13/2026 | JR (Project Manager) | Initial XML/Integration Specialist role definition. |
