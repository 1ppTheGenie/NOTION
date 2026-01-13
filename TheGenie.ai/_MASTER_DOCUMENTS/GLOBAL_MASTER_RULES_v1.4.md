# Global Master Rules for TheGenie.ai
**Version:** 1.4  
**Created:** 12/31/2025 4:46 PM  
**Last Updated:** 01/13/2026 2:56 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ ACTIVE - These rules apply to ALL projects

---

## 🎯 SCOPE

These rules apply to **ALL** TheGenie.ai development projects. Project-specific rules may ADD to these but must NOT override them.

**Location:** `D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\GLOBAL_MASTER_RULES_v1.4.md`

---

## 📋 RULE 1: FILE VERSIONING

### Rule Statement
**NEVER OVERWRITE FILES** - Always use versioning (v1, v2, v3...)

### Details
- Save edited files with new version number
- **CRITICAL: Filename MUST match the version number in the document header**
- When updating a document's version number:
  1. Update the version number in the document header (e.g., v1.3 → v1.4)
  2. **Rename the file to match the new version** (e.g., `FILE_v1.3.md` → `FILE_v1.4.md`)
  3. Archive the old version file to the `Archive/` folder
  4. Update the change log with the new version entry
- Never edit and save as same filename
- Always preserve previous versions
- Exception: Master documents in `_MASTER_DOCUMENTS/` use single file with internal version tracking, BUT when version is updated, filename must still be updated to match

### Version Increment
| Change Type | Increment | Example |
|-------------|-----------|---------|
| Minor fixes, typos, formatting | +0.1 | v1.0 → v1.1 |
| New sections, significant updates | +1.0 | v1.1 → v2.0 |
| Complete rewrite | +1.0 (major) | v2.0 → v3.0 |

### Example
- ❌ Wrong: Edit `SPEC_v1.md` → Save as `SPEC_v1.md`
- ❌ Wrong: Update version to v1.4 in document but keep filename as `SPEC_v1.3.md`
- ✅ Correct: Edit `SPEC_v1.md` → Update version to v1.4 → Save as `SPEC_v1.4.md` → Archive `SPEC_v1.3.md`

---

## 📋 RULE 2: NO ASSUMPTIONS - NO GUESSING

### Rule Statement
If unclear, **STOP and ASK**. **NEVER GUESS**. Get EXACT FACTS.

### Details
- Never assume requirements
- Never use "most likely", "probably", "might be" - get EXACT facts
- Always confirm before proceeding
- Ask clarifying questions when needed
- Generate 5-10 discovery questions from vague statements
- **CRITICAL:** This is like medical equipment - wrong answers can kill. Get EXACT facts, not guesses.

### Example
- ❌ Wrong: "I'll assume they mean X and proceed"
- ❌ Wrong: "Most likely the issue is Y"
- ❌ Wrong: "Probably the deployment failed"
- ✅ Correct: "Before proceeding, I need to confirm: Do you mean X or Y?"
- ✅ Correct: "I need to check Event Viewer logs to get EXACT facts about what happened"
- ✅ Correct: "Let me compare exact timestamps to determine if deployment ran"

---

## 📋 RULE 3: NO PLACEHOLDERS

### Rule Statement
All data must be **REAL or CONFIRMED**

### Details
- Never use "[TBD]" or "[TODO]" in final deliverables
- Never use placeholder text like "Lorem ipsum"
- All data must be verified from database or confirmed sources
- If real data not available, ask for it

### Example
- ❌ Wrong: "Agent Name: [TBD]"
- ✅ Correct: "Agent Name: Dainelle Scott"

---

## 📋 RULE 4: DOCUMENT REQUIREMENTS

### Rule Statement
Every document must include standard header and changelog

### Required Header Fields
```markdown
# Document Title
**Version:** X.Y  
**Created:** MM/DD/YYYY HH:MM AM/PM  
**Last Updated:** MM/DD/YYYY HH:MM AM/PM  
**Author:** [Name]  
**Status:** [Active/Draft/Archived]
```

**⚠️ CRITICAL: Include TIME (not just date) in all timestamps.**
- **Why:** Multiple files created same day need differentiation
- **Especially important:** Code files (they don't use version naming in filename)
- **Applies to:** Documents, SOPs, prompts, specs, code files, ALL files

### Required Footer
```markdown
## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| X.Y | MM/DD/YYYY HH:MM AM/PM | What changed |
```

---

## 📋 RULE 5: DATE/TIME FORMAT

### Rule Statement
Master date/time format: **MM/DD/YYYY HH:MM AM/PM**

### Details
- **ALWAYS include TIME** in timestamps (not just date)
- Use consistently in ALL files: documents, SOPs, prompts, specs, code files
- **Critical for code files** - they don't use version naming, so time is the only differentiator
- Applies to: headers, change logs, file comments, Notion entries
- No exceptions

### Examples
- ❌ Wrong: 12/31/2025, 2025-12-31, Dec 31 2025
- ✅ Correct: 12/31/2025 4:43 PM
- ✅ Correct: 12/31/2025 10:15 AM

### Code File Example
```csharp
// Created: 12/31/2025 2:30 PM
// Last Updated: 12/31/2025 4:45 PM
// Author: Cursor AI Agent
```

---

## 📋 RULE 6: DRIVE LOCATION

### Rule Statement
**ALL FILES ON D: DRIVE - NEVER C:**

### Details
- Root: `D:\Cursor\TheGenie.ai\`
- C: drive is TABOO - no exceptions
- If you see a C: path, fix it immediately

### Key Paths
| Purpose | Path |
|---------|------|
| Master Documents | `D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\` |
| Development | `D:\Cursor\TheGenie.ai\Development\` |
| GitHub Clone | `D:\Cursor\_SourceCode\NOTION\` |

---

## 📋 RULE 7: LINKS OPEN EXTERNAL

### Rule Statement
All HTML links use `target="_blank"`

### Details
- Opens links in new tab/window
- Applies to all `<a>` tags in HTML files
- Critical for prototypes, landing pages, dashboards

### Example
- ❌ Wrong: `<a href="url">Link</a>`
- ✅ Correct: `<a href="url" target="_blank">Link</a>`

---

## 📋 RULE 8: GITHUB SYNC

### Rule Statement
Sync to GitHub after **EVERY** edit to master documents

### Details
- Never let local get ahead of GitHub
- Same-day sync required
- Follow SOP_MASTER_DOCUMENT_MANAGEMENT

### Sync Command
```powershell
cd D:\Cursor\_SourceCode\NOTION
Copy-Item "D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\*" `
          "D:\Cursor\_SourceCode\NOTION\TheGenie.ai\_MASTER_DOCUMENTS\" -Recurse -Force
git add TheGenie.ai/_MASTER_DOCUMENTS/
git commit -m "Sync: [description]"
git push origin main
```

---

## 📋 RULE 9: CLICKABLE LINKS

### Rule Statement
**NEVER show raw URLs** - Always format as clickable hyperlinks

### Details
- Markdown: `[Link Text](URL)`
- Every URL must be clickable
- Applies to Notion links, GitHub links, all URLs

### Example
- ❌ Wrong: `https://github.com/1ppTheGenie/NOTION`
- ✅ Correct: `[GitHub NOTION Repo](https://github.com/1ppTheGenie/NOTION)`

---

## 📋 RULE 10: CONFIRM BEFORE DELIVERY

### Rule Statement
Always confirm file type, client type, and tone before delivering

### Details
- Confirm file type: `.docx`, `.xlsx`, `.md`, `.html`
- Confirm client/user type: Mega Team, Agent, Title Rep, etc.
- Confirm tone: single or split document
- Never deliver without confirmation

---

## 📋 RULE 11: DRA-2026 COMPLIANCE

### Rule Statement
**ALL documents must comply with DRA-2026 (Document Reduction Act of 2026)**

### Details
- Create master session document for each project/case
- Append exhibits if needed (must be cataloged in master)
- Reduce quantity of documents through consolidation
- Leave no documents orphaned (all must be indexed/referenced)
- Never create duplicate documents (update master instead)
- Archive old versions (never delete)

### Master Policy Document
- **[DRA_2026_POLICY_v1.md](file:///D:/Cursor/TheGenie.ai/Development/_MASTER_DOCUMENTS/DRA_2026_POLICY_v1.md)** - Single source of truth for DRA-2026 policy

**DRA-2026 applies to:**
- ✅ ALL workspaces
- ✅ ALL chat sessions
- ✅ ALL projects
- ✅ ALL documents

**DRA-2026 is the #1 policy for document management, equal to Master Rules.**

---

## 📊 DATA QUALITY RULES

### Never Show (Always Hide)
- Household Income (always inaccurate)
- Estimated Wealth/Net Worth (always inaccurate)
- Home Value Range with $250K delta (use AVM only)
- Data Source Names (never disclose Versium, Attom, etc.)

### Always Flag/Verify
- Email addresses (may be stale)
- Phone numbers (may be outdated)
- Contact data from cache (needs verification)

### Always Include
- Fresh Versium Pull for Pre-Listing (ALWAYS pull fresh - NEVER use cache)
- Living SqFt from Attom `SumLivingAreaSqFt`
- Mailing Address (separately from property address)

---

## 🔗 PROJECT-SPECIFIC RULES

Project-specific rules extend (but don't override) these global rules:

| Project | Rules Document |
|---------|----------------|
| Paisley | `Paisley\MASTER_RULES_v1.md` |
| Billing | `BillingSystems\...\MASTER_RULES_SubscriptionDisputes_v1.md` |

---

## 🔄 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.4 | 01/13/2026 2:56 PM | **CRITICAL UPDATE TO RULE 1:** Added explicit requirement that filename MUST match version number in document header. When updating version: (1) Update version in header, (2) Rename file to match new version, (3) Archive old version, (4) Update change log. This prevents confusion and ensures version consistency between filename and document content. |
| 1.3 | 01/13/2026 4:50 AM | Added Rule 11: DRA-2026 Compliance. DRA-2026 is the #1 policy for document management, equal to Master Rules. Applies to ALL workspaces, chat sessions, projects, and documents. Linked to master DRA-2026 policy document. |
| 1.2 | 01/02/2026 5:30 PM | Updated Rule 2: Added "NO GUESSING" requirement. Never use "most likely", "probably", "might be". Get EXACT FACTS. This is like medical equipment - wrong answers can kill. |
| 1.1 | 12/31/2025 4:50 PM | Updated Rule 4 & 5: Added TIME requirement to all timestamps. Critical for code files and same-day file differentiation. |
| 1.0 | 12/31/2025 4:46 PM | Initial global rules - consolidated from Paisley rules, user rules, and established patterns. 10 core rules + data quality section. |

---

*This file is the **SINGLE SOURCE OF TRUTH** for global rules. Project rules must align with these.*  
*Location: D:\Cursor\TheGenie.ai\Development\_MASTER_DOCUMENTS\GLOBAL_MASTER_RULES_v1.4.md*

