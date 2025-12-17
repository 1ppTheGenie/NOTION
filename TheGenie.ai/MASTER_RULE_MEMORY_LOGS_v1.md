# MASTER RULE: Workspace Memory Logs
**This Rule is PERMANENT - Follow in Every Session**

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/15/2025 |
| **Last Updated** | 12/15/2025 |
| **Status** | ACTIVE - Master Rule |

---

## 🚨 THE RULE

**EVERY session that produces significant work, discoveries, or decisions MUST have a Workspace Memory Log created and stored in the permanent location.**

---

## 📝 WHEN TO CREATE A MEMORY LOG

### ✅ CREATE A LOG WHEN:
- Session produces new discoveries or insights
- Decisions are made about features, architecture, or processes
- Analysis is completed (reports, data exploration)
- New features are designed or specified
- Problems are solved or workarounds found
- User provides important context or requirements

### ❌ SKIP A LOG WHEN:
- Simple file read/write operations
- Quick questions answered
- Trivial edits with no context needed

---

## 📍 WHERE TO CREATE MEMORY LOGS

### Step 1: Create During Session
**Location:** `c:\Cursor\TheGenie.ai\MemoryLogs\`

**Naming Convention:**
```
WORKSPACE_MEMORY_LOG_[Topic]_Session_[YYYY-MM-DD].md
```

**Examples:**
- `WORKSPACE_MEMORY_LOG_AreaOwnership_LeadCustody_Session_2025-12-15.md`
- `WORKSPACE_MEMORY_LOG_CCReports_Session_2025-12-15.md`
- `WORKSPACE_MEMORY_LOG_NurtureEngine_Discovery_2025-12-15.md`

### Step 2: Copy to GitHub (Permanent)
**Source:** `c:\Cursor\TheGenie.ai\MemoryLogs\[filename].md`  
**Destination:** `c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\[filename].md`

**Action:** Copy file maintaining exact name and structure

### Step 3: Commit to GitHub
```bash
cd c:\Cursor\_ARCHIVE_Downloads\NOTION
git add TheGenie.ai/MemoryLogs/[filename].md
git commit -m "Add memory log: [Topic] session [YYYY-MM-DD]"
git push origin main
```

### Step 4: Update MASTER_INDEX
- Add new log to catalog in `MASTER_INDEX_v1.md`
- Update story arc if new patterns emerge
- Increment version if structure changes

---

## 📋 MEMORY LOG TEMPLATE

Every memory log should include:

```markdown
# Workspace Memory Log: [Topic]
## Session Date: [YYYY-MM-DD]

---

## Executive Summary

| Item | Details |
|------|---------|
| **Purpose** | What problem does this solve? |
| **Current State** | Completion % and what's working |
| **Key Outputs** | What the document produces |
| **Remaining Work** | What iterations are planned |
| **Last Validated** | Date and what was confirmed |

---

## 1. Session Overview
- Date, duration, focus areas
- Key questions answered
- Outcome/decisions made

## 2. Key Discoveries
- Critical findings
- Data insights
- Problems identified

## 3. Decisions Made
- Architecture decisions
- Process decisions
- Business rules confirmed

## 4. Files Created
- List all files created this session
- Paths and purposes

## 5. Technical Learnings
- Database insights
- Code patterns
- Gotchas and solutions

## 6. Next Steps
- Immediate actions
- Short-term plans
- Long-term roadmap

## 7. Change Log
- Version history
```

**Reference existing logs for full examples:**
- `WORKSPACE_MEMORY_LOG_NurtureEngine_Discovery_2025-12-15.md` (comprehensive example)

---

## 🔄 WORKFLOW CHECKLIST

When creating a memory log:

- [ ] Create file in `c:\Cursor\TheGenie.ai\MemoryLogs\`
- [ ] Use correct naming convention
- [ ] Include Executive Summary
- [ ] Document all key discoveries
- [ ] List all files created
- [ ] Copy to GitHub location
- [ ] Commit to GitHub
- [ ] Update MASTER_INDEX catalog
- [ ] Verify file appears in GitHub remote

---

## 🎯 QUICK REFERENCE

### Find All Memory Logs
```powershell
# Working location
Get-ChildItem "c:\Cursor\TheGenie.ai\MemoryLogs\*.md"

# GitHub location
Get-ChildItem "c:\Cursor\_ARCHIVE_Downloads\NOTION\TheGenie.ai\MemoryLogs\*.md"
```

### Search Memory Logs
```powershell
# Search for topic
Select-String -Path "c:\Cursor\TheGenie.ai\MemoryLogs\*.md" -Pattern "[Topic]"
```

### Access Master Index
```
c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md
```

---

## 🚨 CRITICAL REMINDERS

1. **GitHub is PRIMARY** - All logs must be in GitHub (NOT Notion)
2. **Never Skip** - If in doubt, create a log
3. **Update Index** - Always update MASTER_INDEX when adding logs
4. **Follow Naming** - Use exact naming convention
5. **Executive Summary** - Every log needs 5-second understanding at top

---

## 📚 RELATED DOCUMENTS

| Document | Location | Purpose |
|----------|----------|---------|
| MASTER_INDEX | `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md` | Master reference |
| Directory Structure | `c:\Cursor\TheGenie.ai\PERMANENT_DIRECTORY_STRUCTURE_v1.md` | Structure reference |
| .cursorrules | `TheGenie.ai.Database\.cursorrules` | Master rules |

---

## 📝 CHANGE LOG

| Version | Date | Changes |
|--------|------|---------|
| 1.0 | 12/15/2025 | Initial master rule created |

---

**This rule is PERMANENT. Follow it in every session.**

*Last Updated: 12/15/2025*

