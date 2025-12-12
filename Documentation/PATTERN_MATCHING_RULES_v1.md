# Pattern Matching Rules for File Classification
**Version:** 1.0  
**Date:** 2025-12-11  
**Purpose:** Define patterns to classify 9,601 files into Notion structure

---

## 🎯 PATTERN MATCHING APPROACH

### Confidence Threshold: 90%
- Files with ≥90% confidence → Auto-classified
- Files with <90% confidence → EXCEPTION folder for human review

### Classification Dimensions:
1. **Functional Area** (Operations, Growth, Support, Development)
2. **Content Type** (Plans, Reports, SOPs, Presentations, Specs, Scripts)
3. **Platform** (Main Genie, Genie Cloud, etc.) - Development only
4. **Application** (Competition Command, Listing Command, etc.) - Development only
5. **System/Vendor** (Twilio, etc.) - For vendor/infrastructure content

---

## 📋 PATTERN RULES BY FUNCTIONAL AREA

### 1. OPERATIONS

#### Keywords/Patterns:
- **Reports:**
  - Filename contains: `report`, `_report_`, `Report_`
  - Path contains: `Operations/Reports/` or `Reports/`
  - Extension: `.csv`, `.xlsx`, `.xls`
  - Keywords: `monthly`, `cost`, `ownership`, `performance`, `inventory`, `usage`, `reconciliation`
  
- **SOPs:**
  - Filename contains: `SOP_`, `sop_`, `SOP:`, `procedure`, `process`
  - Path contains: `SOPs/` or `Operations/SOPs/`
  - Extension: `.md`, `.docx`
  - Keywords: `how to`, `step by step`, `standard operating`
  
- **Plans:**
  - Filename contains: `plan`, `roadmap`, `strategy`, `planning`
  - Keywords: `quarterly`, `annual`, `strategic`
  
- **Presentations:**
  - Filename contains: `presentation`, `deck`, `slides`, `demo`
  - Extension: `.pptx`, `.pdf` (if presentation content)
  - Keywords: `pitch`, `overview`, `training`

#### System/Vendor Patterns:
- **Twilio:** `twilio`, `Twilio_`, `sms`, `phone`, `message`
- **Competition Command:** `CC_`, `competition`, `compcommand`, `ownedareas`
- **Listing Command:** `LC_`, `listing`, `listingcommand`, `mlslisting`

---

### 2. GROWTH

#### Keywords/Patterns:
- **Reports:**
  - Keywords: `growth`, `sales`, `marketing`, `revenue`, `conversion`, `acquisition`
  - Path contains: `Growth/` or `Marketing/`
  
- **SOPs:**
  - Keywords: `sales process`, `marketing`, `campaign`, `gtm`
  
- **Plans:**
  - Keywords: `go to market`, `gtm`, `marketing plan`, `sales strategy`
  
- **Presentations:**
  - Keywords: `pitch deck`, `sales deck`, `marketing materials`

---

### 3. SUPPORT

#### Keywords/Patterns:
- **Reports:**
  - Keywords: `support`, `ticket`, `customer`, `satisfaction`, `response time`
  - Path contains: `Support/`
  
- **SOPs:**
  - Keywords: `support process`, `troubleshooting`, `customer service`
  
- **Plans:**
  - Keywords: `support strategy`, `customer success`

---

### 4. DEVELOPMENT

#### Keywords/Patterns:
- **Reports:**
  - Keywords: `development`, `dev`, `code`, `feature`, `bug`, `sprint`
  - Path contains: `Development/` or `SourceCode/`
  
- **SOPs:**
  - Keywords: `development process`, `deployment`, `testing`, `code review`
  
- **Specs:**
  - Filename contains: `SPEC_`, `spec_`, `Spec_`, `specification`, `blueprint`
  - Path contains: `Specs/` or `Development/Specs/`
  - Extension: `.md`, `.docx`
  - Keywords: `technical spec`, `design spec`, `architecture`
  
- **SourceCode:**
  - Path contains: `SourceCode/`, `Genie.Source.Code/`, `src/`
  - Extension: `.cs`, `.ts`, `.js`, `.py`, `.sql`
  - Keywords: `handler`, `service`, `controller`, `model`
  
- **3rd Party Vendors:**
  - Filename/path contains: `twilio`, `vendor`, `3rd party`, `third party`
  - Path contains: `3rd Party Vendors/` or `Vendors/`
  - Keywords: `api key`, `integration`, `external service`
  
- **Scripts:**
  - Filename contains: `build_`, `generate_`, `create_`, `script`, `_v1.py`, `_v2.py`
  - Extension: `.py`, `.sql`, `.ps1`, `.sh`
  - Path contains: `Scripts/` or `Operations/Scripts/`
  - Keywords: `build`, `generate`, `export`, `import`, `sync`
  
- **Platforms:**
  - **Main Genie:** `main genie`, `farmgenie`, `genie main`, `smart.web.farmgenie`
  - **Genie Cloud:** `geniecloud`, `genie-cloud`, `geniecloud_v1`
  - **Genie WordPress:** `wordpress`, `wp`, `genie wordpress`
  - **Genie SQL:** `sql`, `database`, `genie sql`
  - **APIs:** `api`, `apis`, `geniesource`, `genieconnect`
  
- **Applications:**
  - **Competition Command:** `competition`, `compcommand`, `CC_`, `ownedareas`
  - **Listing Command:** `listing`, `listingcommand`, `LC_`
  - **Neighborhood Command:** `neighborhood`, `neighborhoodcommand`, `NC_`
  - **TitleGenie:** `titlegenie`, `title`
  - **Paisley:** `paisley`, `askpaisley`
  - **PUB:** `pub`
  - **ListMiner:** `listminer`, `geosocial`, `audience builder`
  - **Marketing Hub:** `marketing hub`, `marketinghub`
  - **APIs:** `api`, `apis`, `geniesource`
  - **MLS Data:** `mlslisting`, `MLSListing`, `mls listing` (special handling - goes to MLS Data section)

---

## 🔍 PATTERN MATCHING ALGORITHM

### Step 1: Extract Metadata
- Filename
- File path
- File extension
- Keywords from filename
- File size
- Last modified date

### Step 2: Functional Area Detection
- Check path patterns first (most reliable)
- Check filename keywords
- Check content type patterns
- Score: 0-100%

### Step 3: Content Type Detection
- Check filename patterns (SOP_, SPEC_, Report_, etc.)
- Check path patterns
- Check extension patterns
- Score: 0-100%

### Step 4: System/Vendor Detection (if applicable)
- Check filename prefixes (CC_, LC_, Twilio_, etc.)
- Check path patterns
- Check keywords
- Score: 0-100%

### Step 5: Platform Detection (Development only)
- Check path patterns
- Check keywords
- Check application patterns
- Score: 0-100%

### Step 6: Application Detection (Development only)
- Check filename patterns
- Check keywords
- Check platform context
- Score: 0-100%

### Step 7: Calculate Confidence
- Weighted average of all scores
- Functional Area: 30%
- Content Type: 30%
- System/Vendor: 20%
- Platform: 10% (if Development)
- Application: 10% (if Development)

### Step 8: Classification Decision
- **≥90% confidence:** Auto-classify to target location
- **<90% confidence:** Move to EXCEPTION folder

---

## 📊 EXAMPLE PATTERNS

### Example 1: High Confidence (95%)
- **File:** `CC_Report_MonthlyOwnership_2025-12_v5_iter2.csv`
- **Path:** `TheGenie.ai/Operations/Reports/CompetitionCommand/`
- **Analysis:**
  - Functional Area: Operations (100% - path match)
  - Content Type: Report (100% - filename + path)
  - System: Competition Command (100% - CC_ prefix)
  - **Confidence: 96.7%** → Auto-classify

### Example 2: High Confidence (92%)
- **File:** `SOP_Twilio_Invoice_Reconciliation_v1.md`
- **Path:** `Twilio-20251209T200757Z-3-001/Twilio/REPORTS/`
- **Analysis:**
  - Functional Area: Operations (90% - Twilio is ops vendor)
  - Content Type: SOP (100% - SOP_ prefix)
  - System: Twilio (100% - filename + path)
  - **Confidence: 96%** → Auto-classify

### Example 3: Low Confidence (65%)
- **File:** `investigate_order_1212.py`
- **Path:** `Twilio-20251209T200757Z-3-001/Twilio/REPORTS/`
- **Analysis:**
  - Functional Area: Unknown (40% - unclear)
  - Content Type: Script (80% - .py extension)
  - System: Unknown (30% - no clear pattern)
  - **Confidence: 50%** → EXCEPTION folder

---

## 📁 EXCEPTION FOLDER STRUCTURE

```
EXCEPTIONS/
├── Low_Confidence/ (<90%)
│   ├── Operations/
│   ├── Growth/
│   ├── Support/
│   └── Development/
│
└── Unclassified/ (0% confidence)
    └── [Files with no patterns matched]
```

---

## ✅ NEXT: EXECUTE PATTERN MATCHING

Ready to run pattern matching algorithm on 9,601 files.

**Output:**
1. Classification report (files classified vs. exceptions)
2. Confidence scores for each file
3. EXCEPTION folder with files needing review
4. Mapping to Notion structure

---

*Pattern matching rules ready for execution.*

