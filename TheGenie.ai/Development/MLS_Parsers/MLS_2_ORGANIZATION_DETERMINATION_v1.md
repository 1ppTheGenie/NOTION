# MLS ID 2 Organization Determination - Bridge MLS vs Bay East

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Status:** 🔍 INVESTIGATION IN PROGRESS

---

## Executive Summary

**MLS ID 2** is currently named "EBRDI" / "MAX/EBRDI MLS" in the database. After the EBRD/CCAR split:
- **EBRD** became **Bridge MLS** (the organization)
- **CCAR** merged with another to become **Bay East**

**CRITICAL QUESTION:** Which organization is MLS ID 2 currently connected to?

---

## Evidence Found

### 1. Database Broker Name Analysis

**MLS ID 2 Listings:**
- **418 listings** with broker name = `bridgeMLS` (the MLS organization itself)
- **114 listings** with "Bay East" in broker name (e.g., "Bay East Brokers, Inc")
- **Total:** 508,224 listings in MLS ID 2

**Recent Activity:**
- Most recent `bridgeMLS` listing: **2019-09-11** (6+ years old - INACTIVE!)
- Most recent "Bay East" listing: **2025-12-24** (6 days ago - VERY ACTIVE!)

**⚠️ CRITICAL FINDING:** Bay East has **MUCH MORE RECENT** listings than bridgeMLS!

**Conclusion:** Both organizations appear to have listings in MLS ID 2, but `bridgeMLS` has significantly more (418 vs 114).

---

### 2. IDX Agreement Analysis

**Agreements Found:**
1. **`EBRD - Bridge MLS IDX Agreement Form.pdf`**
   - Mentions: "bridgeMLS" and "EBRD OR bridgeMLS"
   - Type: IDX Data Feed Agreement Version 6.0
   - Access types: RETS ACCESS or IDX-EZ
   - **This suggests agreement with Bridge MLS (the organization)**

2. **`CCAR EBRD IDX Agreement Form 2018-SIGNED (1).pdf`**
   - **SIGNED:** 06/25/2018
   - **Organization:** Contra Costa Association of REALTORS® (CCAR)
   - **Company:** 1parkplace Inc.
   - **Contact:** Steve Hundley, CEO
   - **Server IP:** 69.43.128.180 (for RETS access)
   - **Company URL:** http://www.1parkplace.com
   - **Phone:** 888-425-2300 Opt 2
   - **Address:** PO Box 501682, San Diego, CA 92150
   - **This is the CCAR agreement (which merged to become Bay East)**
   - **Access Type:** RETS ACCESS (includes pending and sold listing data)

**Conclusion:** We have an active agreement with **Bridge MLS** (the organization).

---

### 3. Database MLS Name

**Current Database Entry:**
- **MlsID:** 2
- **Name:** EBRDI
- **DisplayName:** MAX/EBRDI MLS
- **ParserID:** 2

**Note:** The name hasn't been updated to reflect the Bridge MLS rebrand, but the data shows `bridgeMLS` as the broker name.

---

## Key Findings

### ✅ CONFIRMED: Bridge MLS (Organization)

**Evidence:**
1. **418 listings** with broker name = `bridgeMLS` (the MLS organization)
2. **IDX Agreement** exists for "Bridge MLS"
3. **File name:** `EBRD - Bridge MLS IDX Agreement Form.pdf` confirms Bridge MLS connection

### ⚠️ UNCLEAR: Bay East Presence

**Evidence:**
1. **114 listings** with "Bay East" in broker name
2. Could be:
   - Legacy listings from before split
   - Bay East brokers still using MLS ID 2 feed
   - Separate feed that needs investigation

---

## Critical Questions Remaining

1. **Is MLS ID 2 the Bridge MLS feed?**
   - **Likely YES** - 418 `bridgeMLS` listings vs 114 Bay East
   - Need to confirm with RESO credentials (which organization the API connects to)

2. **Do we need a separate MLS ID for Bay East?**
   - **Possibly** - If Bay East has its own feed now
   - Check if there's a separate MLS ID in database

3. **Which RESO Provider Technology?**
   - Need to check Azure database for `ProviderTypeId`:
     - `1` = Trestle (CoreLogic)
     - `2` = Bridge (the RESO API provider technology)
   - **This is DIFFERENT from Bridge MLS the organization**

4. **Are the 114 Bay East listings:**
   - Part of the Bridge MLS feed (Bay East brokers using Bridge MLS)?
   - Or from a separate Bay East feed we're not aware of?

---

## Next Steps

### IMMEDIATE (To Answer Questions)

1. **✅ Extract text from IDX agreements** - COMPLETED
   - Look for contact info, websites, API portal URLs

2. **⏳ Access Azure database** - PENDING (firewall issue)
   - Query `mls.ResoMlsSettings` for MLS ID 2
   - Get `ProviderTypeId` (1=Trestle, 2=Bridge technology)
   - Get credentials and endpoints

3. **⏳ Check for Bay East MLS ID** - PENDING
   - Search database for separate Bay East MLS entry
   - Check if Bay East has its own feed

4. **✅ Contact Information Extraction** - COMPLETED
   - **From CCAR Agreement (2018):**
     - **Organization:** Contra Costa Association of REALTORS® (CCAR)
     - **Company:** 1parkplace Inc.
     - **Contact:** Steve Hundley, CEO
     - **Server IP:** 69.43.128.180 (for RETS access)
     - **Company URL:** http://www.1parkplace.com
     - **Phone:** 888-425-2300 Opt 2
     - **Address:** PO Box 501682, San Diego, CA 92150
     - **Signed Date:** 06/25/2018
   - **Note:** This is CCAR (which merged to become Bay East)
   - **Need:** Current Bay East contact info and portal URLs

---

## Preliminary Conclusion - UPDATED WITH RECENT DATA

**Based on current evidence:**

**⚠️ CONFLICTING EVIDENCE - NEEDS RESOLUTION:**

**Evidence for Bridge MLS:**
- 418 listings with `bridgeMLS` broker name (vs 114 Bay East)
- Active IDX agreement with Bridge MLS
- File naming confirms Bridge MLS connection

**Evidence for Bay East (STRONGER):**
- **Most recent Bay East listing: 2025-12-24 (6 days ago)**
- **Most recent bridgeMLS listing: 2019-09-11 (6+ years old)**
- Bay East listings are **ACTIVELY UPDATING**
- Bridge MLS listings appear to be **LEGACY/INACTIVE**

**REVISED CONCLUSION:**
**MLS ID 2 appears to be connected to BAY EAST (the merged organization), NOT Bridge MLS**

The 418 bridgeMLS listings are likely legacy data from before the split. The active, updating feed appears to be Bay East.

**However, we need to:**
- **URGENT:** Confirm via RESO credentials (which organization the API connects to)
- **URGENT:** Check if we have active agreement with Bay East (CCAR agreement is from 2018)
- **URGENT:** Determine if Bay East has separate MLS ID or uses MLS ID 2
- Identify which RESO provider technology is used (Bridge vs Trestle)
- **Why are bridgeMLS listings 6+ years old?** Are they legacy or is there a separate feed?

---

## Files in Project Folder

All IDX agreements have been copied to:
`D:\Cursor\TheGenie.ai\Development\MLS_Parsers\`

1. `CCAR EBRD IDX Agreement Form 2018-SIGNED (1).pdf`
2. `CCAR EBRD IDX Agreement Form 2018.pdf`
3. `EBRD - Bridge MLS IDX Agreement Form.pdf`
4. `EBRD - Jeff Kenney and 1ParkPlace IDX Agreement Formm.pdf`
5. `IDX_Agreement_Text_Extracted.txt` (extracted text)
6. `Bridge_MLS_IDX_Agreement_Text_Extracted.txt` (extracted text)

---

---

## Contact Information Extracted

### From CCAR IDX Agreement (2018) - Now Bay East

| Field | Value |
|-------|-------|
| **Organization** | Contra Costa Association of REALTORS® (CCAR) |
| **Current Name** | Bay East (after merger) |
| **Company** | 1parkplace Inc. |
| **Contact** | Steve Hundley, CEO |
| **Phone** | 888-425-2300 Opt 2 |
| **Email** | (Not in agreement - need to find) |
| **Address** | PO Box 501682, San Diego, CA 92150 |
| **Company URL** | http://www.1parkplace.com |
| **Server IP (RETS)** | 69.43.128.180 |
| **Agreement Date** | 06/25/2018 |
| **Access Type** | RETS ACCESS (includes pending and sold listing data) |

**⚠️ NEED TO FIND:**
- Current Bay East website/portal
- Bay East support contact
- Bay East API/RESO credentials portal
- Current agreement status (2018 agreement may need renewal)

---

**File Location:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\MLS_2_ORGANIZATION_DETERMINATION_v1.md`

