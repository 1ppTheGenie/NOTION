# TheGenie.ai File Organization System
## Discovery Questionnaire

**Purpose:** Gather team input to design a professional file organization system for all Genie-related documentation, reports, and code.

**Prepared by:** Cursor AI Assistant  
**Date:** December 11, 2025  
**Please return completed questionnaire to:** [Your email here]

---

## Instructions

Please review each section and provide your answers in the **RESPONSE** areas. If you're unsure, mark "TBD" and we'll discuss.

---

## Section 1: STAKEHOLDERS & ACCESS PATTERNS

### Who are the primary users of this system?

| Role | Example Person | Primary Use Case |
|------|----------------|------------------|
| A. Executive/Owner | | Review reports, approve specs, strategic decisions |
| B. Developer | | Reference specs, run scripts, understand data models |
| C. Operations | | Run recurring reports, monitor KPIs |
| D. External | | Compliance, billing verification |

### Questions:

**1.1 Who else besides you will access these files regularly?**

☐ Just me  
☐ Me + 1-2 developers  
☐ Me + full dev team  
☐ Me + staff + developers  
☐ Me + staff + clients/external  

**RESPONSE:**  
_____________________________________________

---

**1.2 Should some files be restricted (e.g., database credentials, API keys)?**

☐ Yes - need separate secure folder  
☐ No - everyone can see everything  
☐ Yes - credentials in separate password manager  

**RESPONSE:**  
_____________________________________________

---

**1.3 Do you need version history visible or just "latest stable"?**

☐ Only show latest stable version  
☐ Show latest + link to version history  
☐ Show all versions with status labels  

**RESPONSE:**  
_____________________________________________

---

## Section 2: FILE CATEGORIES

### Current file inventory:

| Category | Count | Examples |
|----------|------:|----------|
| **SOPs** (Standard Operating Procedures) | ~8 | How to run reports, step-by-step processes |
| **SPECs** (Technical Specifications) | ~10 | Field definitions, data sources, SQL patterns |
| **REPORTS** (Generated Output) | ~25 | CSV/Excel files with actual business data |
| **SCRIPTS** (Python/SQL) | ~40 | Code that generates reports |
| **INTEL** (Analysis/Findings) | ~5 | Investigation results, discovery documents |
| **FEATURE REQUESTS** | ~3 | Design briefs, development specs |
| **SOURCE CODE** (Reference) | ~50 | C# handlers, stored procedures |

### Questions:

**2.1 Does this categorization make sense for your workflow?**

☐ Yes, perfect  
☐ Mostly, with changes (specify below)  
☐ No, suggest new approach  

**RESPONSE:**  
_____________________________________________

---

**2.2 Are there categories we're missing?**

☐ No, this covers everything  
☐ Yes - add: _________________________________

**RESPONSE:**  
_____________________________________________

---

**2.3 Should SCRIPTS be bundled with their REPORTS, or kept separate?**

☐ Keep separate (Scripts folder, Reports folder)  
☐ Bundle together (each report has its script in same folder)  
☐ Other: _________________________________

**RESPONSE:**  
_____________________________________________

---

## Section 3: PRODUCT/SYSTEM HIERARCHY

### Our files relate to these Genie systems:

```
TheGenie.ai
├── Competition Command (CC) - Area-based marketing for agents
├── Listing Command (LC) - Listing-based marketing campaigns
├── Neighborhood Command (NC) - Neighborhood-focused outreach
├── Twilio Infrastructure - SMS delivery, phone numbers, billing
├── Lead Management (GenieLead) - Lead tracking and conversion
└── Core Platform - Users, Areas, Authentication, etc.
```

### Questions:

**3.1 Should the folder structure be organized by PRODUCT first, then FILE TYPE?**

**Option A - Product First:**
```
C:\Cursor\
├── CompetitionCommand\
│   ├── Reports\
│   ├── Specs\
│   ├── Scripts\
│   └── SOPs\
├── ListingCommand\
│   ├── Reports\
│   ├── Specs\
│   ├── Scripts\
│   └── SOPs\
├── Twilio\
│   ├── Reports\
│   ├── Specs\
│   └── ...
└── FeatureRequests\
```

☐ Yes, I prefer Option A (Product First)

---

**3.2 Or should it be organized by FILE TYPE first, then PRODUCT?**

**Option B - File Type First:**
```
C:\Cursor\
├── Reports\
│   ├── CompetitionCommand\
│   ├── ListingCommand\
│   └── Twilio\
├── Specs\
│   ├── CompetitionCommand\
│   ├── ListingCommand\
│   └── Twilio\
├── Scripts\
├── SOPs\
└── FeatureRequests\
```

☐ Yes, I prefer Option B (File Type First)

---

**3.3 Or a hybrid approach?**

☐ Yes, hybrid (explain): _________________________________

**RESPONSE:**  
_____________________________________________

---

## Section 4: VERSIONING STRATEGY

### Current State:
Files currently have versions like `_v1.py`, `_v2.py`, `_iter2.csv`

### Questions:

**4.1 What should happen to old versions?**

☐ A) Move to an `/Archive/` folder (out of sight but preserved)  
☐ B) Keep in same folder but marked as superseded in index  
☐ C) Delete after new version is validated and approved  

**RESPONSE:**  
_____________________________________________

---

**4.2 For the "landing page" index, what should we show?**

☐ A) Only the latest stable version  
☐ B) Latest version + link to version history  
☐ C) All versions with status (Current / Deprecated / Archived)  

**RESPONSE:**  
_____________________________________________

---

## Section 5: NAMING CONVENTIONS

### Proposed Standard:

```
[System]_[Type]_[Name]_[Date]_v[#].[ext]
```

### Examples:
- `CC_Report_MonthlyOwnership_2025-12_v2.csv`
- `LC_Spec_Performance_v3.md`
- `Twilio_SOP_InvoiceReconciliation_v1.md`
- `CC_Script_BuildOwnershipReport_v4.py`

### Questions:

**5.1 Does this naming convention work for you?**

☐ Yes, perfect  
☐ Yes, with modifications (specify below)  
☐ No, prefer different approach  

**RESPONSE:**  
_____________________________________________

---

**5.2 Should dates be included in all files or just reports?**

☐ All files should have dates  
☐ Only reports (data outputs) need dates  
☐ No dates in filenames - use folder structure instead  

**RESPONSE:**  
_____________________________________________

---

**5.3 Any preferences on separators?**

☐ Underscore: `CC_Report_Ownership_v1.csv`  
☐ Hyphen: `CC-Report-Ownership-v1.csv`  
☐ Mixed: `CC_Report-Ownership_v1.csv`  
☐ No preference  

**RESPONSE:**  
_____________________________________________

---

## Section 6: LANDING PAGE FORMAT

### Options for the master index/catalog:

| Option | Format | Pros | Cons |
|--------|--------|------|------|
| A | Markdown file (`INDEX.md`) | Easy to maintain, version-controlled, works in any editor | Not as visual |
| B | Excel workbook | Filterable, sortable, clickable hyperlinks | Manual updates needed |
| C | HTML page | Professional look, can auto-generate | Requires web hosting |
| D | All of the above | Flexibility for different users | More maintenance |

### Questions:

**6.1 Which format(s) do you prefer?**

☐ A) Markdown only  
☐ B) Excel only  
☐ C) HTML only  
☐ D) Multiple formats (which ones?): _________________________________

**RESPONSE:**  
_____________________________________________

---

**6.2 Should the index auto-update when files change?**

☐ Yes - automatically scan and update  
☐ No - manually curated for quality control  
☐ Hybrid - auto-detect new files, manual review before publishing  

**RESPONSE:**  
_____________________________________________

---

## Section 7: IMMEDIATE PRIORITIES

**7.1 What's the MOST PAINFUL disorganization issue right now?**

☐ Can't find files quickly  
☐ Don't know which version is current  
☐ Files scattered across too many folders  
☐ No documentation on what files do  
☐ Other: _________________________________

**RESPONSE:**  
_____________________________________________

---

**7.2 Should we reorganize existing files immediately?**

☐ Yes - reorganize everything now  
☐ No - just establish system going forward, migrate gradually  
☐ Partial - reorganize critical files now, others later  

**RESPONSE:**  
_____________________________________________

---

**7.3 Are there files that should be deleted/cleaned up?**

☐ Yes - old test files, duplicates  
☐ No - keep everything for now  
☐ Unsure - need to review first  

**RESPONSE:**  
_____________________________________________

---

## Section 8: ADDITIONAL INPUT

**8.1 Any other requirements or preferences not covered above?**

**RESPONSE:**  
_____________________________________________
_____________________________________________
_____________________________________________

---

**8.2 Who should be the "owner" of this file organization system?**

**RESPONSE:**  
_____________________________________________

---

**8.3 How often should the index be reviewed/updated?**

☐ Daily  
☐ Weekly  
☐ After each major deliverable  
☐ Monthly  

**RESPONSE:**  
_____________________________________________

---

## Summary of Critical Decisions Needed

| # | Decision | Options | Your Choice |
|---|----------|---------|-------------|
| 1 | Who accesses files? | Just you / Team / External | |
| 2 | Folder hierarchy? | Product-first / Type-first / Hybrid | |
| 3 | Old versions? | Archive / Delete / Keep all | |
| 4 | Landing page format? | MD / Excel / HTML / All | |
| 5 | Naming convention? | Proposed standard / Modified | |

---

## Next Steps

Once this questionnaire is completed:

1. **Review responses** with team if applicable
2. **Design folder structure** based on decisions
3. **Create naming convention guide** for all contributors
4. **Build landing page/index** in chosen format(s)
5. **Migrate existing files** to new structure
6. **Document the system** in an SOP for ongoing maintenance

---

**Thank you for completing this questionnaire!**

*Please return to: [Your contact info]*

