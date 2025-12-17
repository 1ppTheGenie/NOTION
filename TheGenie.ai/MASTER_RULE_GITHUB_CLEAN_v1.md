# MASTER RULE: GitHub Clean Commits
**Prevent Garbage Files from Entering GitHub**

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Status** | ACTIVE - Master Rule |

---

## 🚨 THE PROBLEM

**What We're Preventing:**
- ❌ Committing duplicate v1 files with slightly different names
- ❌ Committing outdated versions when newer versions exist
- ❌ Committing test files, temporary files, or garbage
- ❌ Committing files that are "more or less not useful"
- ❌ Creating multiple v1 files for the same document

**Example of the Problem:**
```
❌ BAD:
- SPEC_Report_v1.md
- SPEC_Report_v1_FIXED.md
- SPEC_Report_v1_CORRECTED.md
- All are v1, all are similar, only one is current

✅ GOOD:
- SPEC_Report_v1.md (original)
- SPEC_Report_v2.md (corrected version)
- SPEC_Report_v1.md is deleted or archived
```

---

## ✅ WHAT GETS COMMITTED TO GITHUB

### ✅ ALWAYS COMMIT:

1. **Final/Approved Versions Only**
   - Latest version of any document
   - If v2 exists, don't commit v1
   - If v3 exists, don't commit v1 or v2

2. **Master Index Files**
   - MASTER_INDEX_v1.md
   - PERMANENT_DIRECTORY_STRUCTURE_v1.md
   - MASTER_RULE_*.md files

3. **Memory Logs**
   - All memory logs (they're session documentation)
   - Only the final version (not drafts)

4. **Approved Deliverables**
   - Files in APPROVED/ folder
   - Final scripts, SOPs, specs
   - Production-ready reports

5. **Feature Requests (Final Versions)**
   - Latest version of FR-* files
   - Latest version of SPEC_* files
   - Latest version of SOP_* files

### ❌ NEVER COMMIT:

1. **Duplicate Versions**
   - If v2 exists, don't commit v1
   - If v3 exists, don't commit v1 or v2
   - Check for newer versions first

2. **Test/Temporary Files**
   - Files with "test", "temp", "tmp" in name
   - Files with "draft", "scratch", "notes" in name
   - Files with timestamps in name (unless intentional)

3. **Iteration Files**
   - Files with "_FIXED", "_CORRECTED", "_UPDATED" suffixes
   - Files with "_v1_1", "_v1_2" (should be v2)
   - Files with "_FINAL", "_COMPLETE" (if newer version exists)

4. **Garbage Files**
   - Empty files
   - Files with only comments
   - Files that are "more or less not useful"

5. **Working Files**
   - Files in Development/ that are still being worked on
   - Files that haven't been reviewed/approved

---

## 🔍 PRE-COMMIT CHECKLIST

**Before committing ANY file to GitHub, verify:**

### Step 1: Check for Newer Versions
```powershell
# Example: Before committing SPEC_Report_v1.md
# Check if SPEC_Report_v2.md or SPEC_Report_v3.md exists
Get-ChildItem "path\SPEC_Report_*.md"
```

**Rule:** If a newer version exists, DO NOT commit the older version.

### Step 2: Verify File is Final
- [ ] Is this the latest version?
- [ ] Are there any "_FIXED", "_CORRECTED" versions that should be the real v2?
- [ ] Has this file been reviewed/approved?
- [ ] Is this file actually useful (not garbage)?

### Step 3: Check File Name
- [ ] Does the version number match the actual version?
- [ ] Is the name consistent with naming conventions?
- [ ] Are there duplicate v1 files that should be consolidated?

### Step 4: Verify Content
- [ ] File is not empty
- [ ] File has actual content (not just comments)
- [ ] File is complete (not a partial draft)

---

## 📋 FILE NAMING RULES (Prevent Duplicates)

### ✅ CORRECT Versioning:

**When making corrections to v1:**
```
❌ WRONG:
- SPEC_Report_v1.md
- SPEC_Report_v1_FIXED.md  ← Creates duplicate v1

✅ RIGHT:
- SPEC_Report_v1.md (original - keep or delete)
- SPEC_Report_v2.md (corrected version)
```

**When making minor updates:**
```
❌ WRONG:
- SOP_Process_v1.md
- SOP_Process_v1_1.md  ← Should be v2

✅ RIGHT:
- SOP_Process_v1.md
- SOP_Process_v2.md (minor update = v2)
```

**When making major changes:**
```
✅ CORRECT:
- SOP_Process_v1.md
- SOP_Process_v2.md (major update)
```

### Version Number Rules:
- **v1 → v2:** Any change (minor or major)
- **v2 → v3:** Next change
- **Never:** v1_1, v1_FIXED, v1_CORRECTED
- **Always:** Increment the version number

---

## 🔄 CLEANUP PROCESS

### Before Committing to GitHub:

1. **Check for Duplicate v1 Files**
   ```powershell
   # Find all v1 files
   Get-ChildItem -Recurse -Filter "*_v1.*" | 
     Group-Object BaseName | 
     Where-Object { $_.Count -gt 1 }
   ```

2. **Identify Latest Versions**
   - For each document, find the highest version number
   - Only commit the highest version

3. **Archive or Delete Old Versions**
   - Move old versions to `_Archive/` folder (local only, not GitHub)
   - Or delete if truly obsolete

4. **Consolidate Similar Files**
   - If you find `SPEC_Report_v1.md` and `SPEC_Report_v1_FIXED.md`
   - Rename the FIXED one to `SPEC_Report_v2.md`
   - Delete or archive the original v1

---

## 📝 COMMIT WORKFLOW

### Step-by-Step Process:

1. **Before Adding Files:**
   ```powershell
   # Check what you're about to commit
   cd c:\Cursor\_ARCHIVE_Downloads\NOTION
   git status
   ```

2. **Review Each File:**
   - Is this the latest version?
   - Is there a newer version that should be committed instead?
   - Is this file actually useful?

3. **Clean Up:**
   - Remove duplicate v1 files
   - Remove outdated versions
   - Remove garbage files

4. **Add Only Clean Files:**
   ```powershell
   git add TheGenie.ai/[specific_file].md
   # NOT: git add -A (this adds everything!)
   ```

5. **Verify Before Commit:**
   ```powershell
   git status  # Review what's staged
   git diff --cached  # Review changes
   ```

6. **Commit with Clear Message:**
   ```powershell
   git commit -m "Add [document type]: [name] v[N] - [description] 12/15/2025"
   ```

7. **Push:**
   ```powershell
   git push origin main
   ```

---

## 🚨 CRITICAL RULES

### Rule 1: One Version Per Document
- Each document should have ONE current version in GitHub
- If v2 exists, v1 should not be in GitHub (archive locally)
- If v3 exists, v1 and v2 should not be in GitHub

### Rule 2: Never Commit "_FIXED" Files
- If you have `File_v1_FIXED.md`, rename it to `File_v2.md`
- Then commit `File_v2.md`
- Delete or archive `File_v1.md` and `File_v1_FIXED.md`

### Rule 3: Check Before Every Commit
- Always run `git status` first
- Review what you're committing
- Verify no duplicate versions

### Rule 4: Use Specific Adds
- **NEVER:** `git add -A` (adds everything, including garbage)
- **ALWAYS:** `git add TheGenie.ai/[specific_path]/[specific_file].md`
- Add files one at a time or by specific directory

### Rule 5: Archive Locally, Not GitHub
- Old versions go to `_Archive/` folder (local only)
- GitHub only has current versions
- Keep history locally, keep GitHub clean

---

## 🔧 CLEANUP SCRIPT (Future)

**Ideal Future State:**
A PowerShell script that:
1. Scans for duplicate v1 files
2. Identifies latest versions
3. Suggests what to commit
4. Prevents committing outdated versions

**For Now:**
- Manual review before each commit
- Follow the checklist above
- Use `git status` to review

---

## 📋 QUICK REFERENCE

### Before Committing, Ask:
1. ✅ Is this the latest version?
2. ✅ Are there newer versions that should be committed instead?
3. ✅ Is this file actually useful?
4. ✅ Does the version number match reality?
5. ✅ Are there duplicate v1 files that need consolidation?

### If Answer is NO to Any:
- **Don't commit**
- Fix the issue first
- Then commit

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/15/2025 | Initial master rule for clean GitHub commits |

---

**This rule is PERMANENT. Follow it for every GitHub commit.**

*Last Updated: 12/15/2025*

