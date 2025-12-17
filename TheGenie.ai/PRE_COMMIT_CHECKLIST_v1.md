# Pre-Commit Checklist
**Use This Before Every GitHub Commit**

---

## 🚨 BEFORE COMMITTING - CHECK THIS LIST

### Step 1: Check for Newer Versions
- [ ] Is this the latest version of this file?
- [ ] Are there v2, v3, etc. versions that should be committed instead?
- [ ] If newer version exists, commit that one instead

**Command to check:**
```powershell
# Find all versions of a file
Get-ChildItem "path\*[filename]*.md" | Sort-Object Name
```

### Step 2: Check for Duplicate v1 Files
- [ ] Are there multiple v1 files with slightly different names?
- [ ] Example: `File_v1.md` and `File_v1_FIXED.md`?
- [ ] If yes, rename the FIXED one to v2, delete/archive the old v1

**Command to find duplicates:**
```powershell
# Find duplicate v1 files
Get-ChildItem -Recurse -Filter "*_v1.*" | 
  Group-Object { $_.BaseName -replace '_v1.*$', '' } | 
  Where-Object { $_.Count -gt 1 }
```

### Step 3: Verify File is Useful
- [ ] File is not empty
- [ ] File has actual content (not just comments)
- [ ] File is complete (not a partial draft)
- [ ] File is not a test/temp file

### Step 4: Check File Name
- [ ] Version number matches actual version
- [ ] No "_FIXED", "_CORRECTED", "_UPDATED" suffixes (should be v2)
- [ ] Name follows naming conventions
- [ ] No duplicate v1 files

### Step 5: Review What You're Committing
```powershell
# Check git status
cd c:\Cursor\_ARCHIVE_Downloads\NOTION
git status

# Review what's staged
git diff --cached
```

- [ ] Only committing files that pass all checks above
- [ ] Not using `git add -A` (adds everything including garbage)
- [ ] Adding files specifically: `git add TheGenie.ai/[path]/[file].md`

---

## ✅ READY TO COMMIT?

**Only if ALL checks pass:**
```powershell
cd c:\Cursor\_ARCHIVE_Downloads\NOTION
git add TheGenie.ai/[specific_path]/[specific_file].md
git commit -m "Add [type]: [name] v[N] - [description] 12/15/2025"
git push origin main
```

---

## 🚨 RED FLAGS - DO NOT COMMIT IF:

- ❌ File has "_FIXED" or "_CORRECTED" in name (rename to v2 first)
- ❌ Newer version exists (commit the newer one)
- ❌ Multiple v1 files for same document (consolidate first)
- ❌ File is empty or just comments
- ❌ File is test/temp/draft
- ❌ Using `git add -A` without reviewing

---

**Reference:** `MASTER_RULE_GITHUB_CLEAN_v1.md` for complete rules.

*Last Updated: 12/15/2025*

