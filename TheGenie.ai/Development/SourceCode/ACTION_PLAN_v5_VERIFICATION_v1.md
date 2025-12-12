# ACTION PLAN: Verify v5 Query Works

## Step 1: Test WHERE Clause First (5 minutes)

**File:** `VERIFY_v5_WHERE_CLAUSE_v1.sql`

**What to do:**
1. Open `VERIFY_v5_WHERE_CLAUSE_v1.sql` in Azure Data Studio
2. Run the query
3. Check the result:
   - ✅ If it returns **19,664** → WHERE clause works, proceed to Step 2
   - ❌ If it returns **0** → WHERE clause is broken, stop and report issue

**Expected Result:** 19,664 records

---

## Step 2: Run Full v5 Query (10-15 minutes)

**File:** `0301.CC_SMS_WithDetails_v2_ULTRA_FAST_v5.sql`

**What to do:**
1. Open `0301.CC_SMS_WithDetails_v2_ULTRA_FAST_v5.sql` in Azure Data Studio
2. Run the query
3. Check the output:
   - ✅ If Step 1 prints "Loaded 19664 SMS records" → Query works!
   - ❌ If Step 1 prints "Loaded 0 SMS records" → Query is broken, report issue

**Expected Result:** 
- Step 1: "Loaded 19664 SMS records"
- Final output: Multiple rows with PropertyCollectionDetailId populated

---

## Step 3: Export Results (if Step 2 succeeds)

**What to do:**
1. In Azure Data Studio, right-click on the results grid
2. Select "Save Results As..."
3. Save as: `0301.CC_SMS_WithDetails_v2.csv`
4. Verify the CSV has data (not all zeros/NULLs)

---

## If Something Fails

**Report:**
- Which step failed (1, 2, or 3)
- What error message you got (if any)
- What the actual result was vs. expected result

---

## Quick Reference

| Step | File | Expected Result | Time |
|------|------|----------------|------|
| 1 | `VERIFY_v5_WHERE_CLAUSE_v1.sql` | 19,664 records | 5 min |
| 2 | `0301.CC_SMS_WithDetails_v2_ULTRA_FAST_v5.sql` | "Loaded 19664 SMS records" | 10-15 min |
| 3 | Export CSV | File with data | 2 min |

