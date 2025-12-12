# COMPETITION COMMAND - DISCOVERY QUESTIONS

**Date:** November 8, 2025  
**Purpose:** Understand Competition Command product from top to bottom  
**Status:** Questions to clarify understanding

---

## CRITICAL QUESTIONS ABOUT COMPETITION COMMAND

### 1. OWNED AREAS vs CAMPAIGNS

**Question 1.1:** What is the relationship between `UserOwnedArea` and Competition Command campaigns (`PropertyCollectionDetail`)?
- Do Competition Command campaigns **MUST** be in areas that the agent owns (`UserOwnedArea`)?
- Or can agents run campaigns in any area, regardless of ownership?
- Is `UserOwnedArea` a **permission/access control** mechanism, or just a **tracking** mechanism?

**Question 1.2:** When an agent creates a Competition Command campaign:
- Does the system check if they own the area (`UserOwnedArea`)?
- What happens if they try to create a campaign in an area they don't own?
- Can agents "own" an area but never run campaigns there?

**Question 1.3:** For the report:
- Should we **filter** campaigns by owned areas only?
- Or should we report on **all** campaigns, regardless of ownership?
- What is the business requirement?

---

### 2. AREA ID vs AREA NAME IN COMPETITION COMMAND

**Question 2.1:** When a Competition Command campaign is created:
- How is `AreaId` determined?
- Is it based on the subject property's location?
- Is it based on the search radius around the subject property?
- Or is it explicitly selected by the agent?

**Question 2.2:** Can a single Competition Command campaign span multiple areas?
- Or is each campaign always in exactly one area?
- If multiple areas, how is `PropertyCollectionDetail.AreaId` determined?

**Question 2.3:** For the report:
- When we say "Area Name" in the header, what does it represent?
- Is it the area where the **subject property** is located?
- Or is it the area where the **target properties** (audience) are located?
- Or is it the area that the **agent owns**?

---

### 3. COMPETITION COMMAND WORKFLOW

**Question 3.1:** From the workflow documentation, I see:
- Step 6: Creates `PropertyCollectionDetail` (campaign record)
- Step 11: Creates `SmsReportSendQueue` and `NotificationQueue` records

**Question:** 
- At what point in the workflow is `AreaId` set on `PropertyCollectionDetail`?
- Is it set in Step 6, or earlier?
- What determines which `AreaId` is used?

**Question 3.2:** The workflow shows:
- Subject property is selected by agent
- Search criteria defines nearby properties
- Properties are optimized (data append)
- SMS messages are sent to property owners

**Question:**
- Does the `AreaId` on `PropertyCollectionDetail` represent:
  - The area of the **subject property**?
  - The area where **most target properties** are located?
  - The area that the **agent owns** (if applicable)?

---

### 4. PROPERTY COLLECTION DETAIL vs USER OWNED AREA

**Question 4.1:** I see two different concepts:
- `UserOwnedArea` - Areas the agent "owns" (their farm areas)
- `PropertyCollectionDetail` - Actual campaigns that were run

**Question:**
- Can an agent own an area (`UserOwnedArea`) but never run a campaign there?
- Can an agent run a campaign (`PropertyCollectionDetail`) in an area they don't own?
- What is the business logic that connects these two?

**Question 4.2:** For the "full history of area owners":
- Do you want:
  - All `UserOwnedArea` records (who owns what areas, when)?
  - All `PropertyCollectionDetail` records (what campaigns were run, where)?
  - Both, with a relationship mapping?

---

### 5. REPORT REQUIREMENTS

**Question 5.1:** For the Dave Higgins October 2025 report:
- Should we filter by:
  - Areas he **owns** (`UserOwnedArea`)?
  - Areas where he **ran campaigns** (`PropertyCollectionDetail`)?
  - Both?

**Question 5.2:** For the eventual "all users" report:
- Should we:
  - Generate one report per agent?
  - Generate one report per agent per area?
  - Generate one combined report for all agents?
- How should we handle agents who own areas but never ran campaigns?
- How should we handle agents who ran campaigns in areas they don't own?

---

### 6. AREA NAME RESOLUTION

**Question 6.1:** I understand the priority order:
1. `PolygonNameOverride.FriendlyName` (agent's custom name)
2. `ViewArea.AreaName` (default marketing name)
3. `ViewArea.PolygonName` (polygon name)

**Question:**
- For Competition Command campaigns, should Area Name be resolved:
  - Using the **agent's** `PolygonNameOverride` (agent-specific)?
  - Or using a **global** Area Name (same for all agents)?
- If agent-specific, what if the agent doesn't have a custom name for that area?

**Question 6.2:** For the report header:
- If a campaign is in AreaId 9610:
  - Should we show Dave's custom name (if he has one)?
  - Or should we show the default Area Name?
- What if Dave has multiple campaigns in the same area - same Area Name for all?

---

## WHAT I NEED TO KNOW

1. **Business Logic:** How do owned areas relate to campaigns?
2. **Filtering:** Should reports filter by owned areas or all campaigns?
3. **Area Resolution:** How is AreaId determined for Competition Command campaigns?
4. **Report Scope:** What should be included in "all users" report?
5. **Area Name:** Agent-specific or global for reports?

---

## NEXT STEPS

Once you answer these questions, I will:
1. Update the export queries accordingly
2. Update the report generation logic
3. Ensure accurate filtering and data presentation
4. Create the "all users" report framework

