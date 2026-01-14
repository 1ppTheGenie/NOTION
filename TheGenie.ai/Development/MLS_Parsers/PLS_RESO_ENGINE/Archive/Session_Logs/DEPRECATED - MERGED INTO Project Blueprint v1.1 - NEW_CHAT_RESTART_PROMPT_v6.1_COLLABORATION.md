# New Chat Restart Prompt - PLS RESO Engine v6.1 Collaboration
**Date:** December 30, 2025  
**Purpose:** Restart conversation in fresh workspace with full context for collaborative design exploration

---

## 🎯 CONTEXT & GOAL

We're designing the **Paisley RESO Listing Engine (PLS)** - a private listing service for pre-MLS listings (Coming Soon/Private) that enables agents to market properties BEFORE they hit MLS, with future "one-button push" to automatically publish listings to Bridge/Trestle via RESO Insert.

**CRITICAL GOAL:** Minimize RESO table expansion. Only expand tables for PRE-LISTING command features that are:
- **NOT relevant to listing push** (RESO Insert to Bridge/Trestle)
- **ARE relevant to TitleGenie and Agent knowledge portal** (e.g., who sold the home prior, property history, etc.)

**This is a COLLABORATIVE EXPLORATION** - we're vetting approaches, not implementing yet. All ideas are on the table for discussion.

---

## 📋 CURRENT STATE - v6.1 Approach

### What We've Established

1. **Zero Schema Changes Approach (v6.1):**
   - Leverage existing `MlsListing.dbo.Listing` table structure
   - NO new columns added
   - Only new IDs/types (StatusTypeID, MlsId, PropertyCastTypeId)
   - PLS listings stored in same table as MLS listings

2. **Data Sources (Corrected):**
   - **TitleData.dbo.AttomDataAssessor** = Property data (Attom), NOT MLS data
   - **Historical MLS Data** = For pre-population and conflict resolution
   - **Paisley AI** = Pre-populate listing description (ChatStartTypeId=3)

3. **Field Mapping Analysis:**
   - Complete deep dive: `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
   - 318 TitleData fields → 93 MlsListing fields
   - Join strategy: APN (primary) or address (fallback)
   - Conflict resolution: Square footage (TitleData = original, MLS = updated)

4. **Design Decisions - NOT Hardwired:**
   - MlsId value (TBD - not hardwired to 999)
   - Listing number format (TBD - not hardwired to PLS-YYYY-NNNNN)
   - StatusTypeID values (Coming Soon, Private Listing - TBD)
   - PropertyCastTypeId value (TBD - not hardwired to 4)

---

## 💡 CONCEPTUAL IDEA - User's Proposal

**User's Conceptual Direction (NOT a direct order - open for discussion):**

> "Minimize RESO table expansion and only expand on the tables for PRE LISTING command that are not relevant to the listing push, but are relevant to the TitleGenie and Agent knowledge portal - like who sold the home prior..."

**Key Points:**
- **Minimize expansion** of tables that feed RESO Insert (listing push)
- **Expand only** for PRE-LISTING command features
- **Focus on** TitleGenie and Agent knowledge portal features
- **Example:** Property history (who sold the home prior, sale history, etc.)

**This is a CONCEPT to explore** - not a locked-in plan. We need to:
1. Think critically about this approach
2. Consider alternative approaches
3. Get feedback from all sides
4. Vet the approach before locking in

---

## 🤔 CRITICAL THINKING QUESTIONS

### Question 1: What Tables Feed RESO Insert vs PRE-LISTING Features?

**RESO Insert (Listing Push) Needs:**
- Core listing data (address, price, beds, baths, sqft, etc.)
- Agent/broker data
- Status, property type
- Photos, description
- **All of this exists in `MlsListing.dbo.Listing`**

**PRE-LISTING Command Features (TitleGenie/Agent Portal) Needs:**
- Property history (who sold prior, sale dates, sale prices)
- Owner information (current owner, previous owners)
- Tax assessment history
- Property research data (Attom detailed fields)
- Agent knowledge/notes
- **This may NOT exist in `MlsListing.dbo.Listing`**

### Question 2: Where Should PRE-LISTING Features Live?

**Option A: Separate Tables (User's Concept)**
- Keep `MlsListing.dbo.Listing` clean for RESO Insert
- Create separate tables for PRE-LISTING features:
  - `PlsPropertyHistory` (sale history, owner history)
  - `PlsAgentNotes` (agent knowledge portal)
  - `PlsPropertyResearch` (TitleGenie data cache)
- **Pros:** Clean separation, RESO Insert stays simple
- **Cons:** More tables, more joins, more complexity

**Option B: Extended Data Column**
- Use existing `ExtendedData` XML column in `MlsListing.dbo.Listing`
- Store PRE-LISTING features as XML/JSON
- **Pros:** No new tables, keeps structure simple
- **Cons:** Harder to query, less normalized

**Option C: Hybrid Approach**
- Core listing data in `MlsListing.dbo.Listing` (for RESO Insert)
- PRE-LISTING features in separate tables (for TitleGenie/Agent portal)
- Link via ListingID
- **Pros:** Best of both worlds
- **Cons:** More complex, but manageable

### Question 3: What About Ownership Tracking?

**Current v6.1 Approach:**
- Minimal supporting table for ownership (if needed)
- Or use existing user/listing relationships

**User's Concept Suggests:**
- Ownership might be part of PRE-LISTING features (Agent knowledge portal)
- Not needed for RESO Insert
- Could live in separate table

**Alternative:**
- Ownership is needed for both RESO Insert (who created listing) and Agent portal (who owns/manages)
- Might need to be in core table or separate table

---

## 📊 ALTERNATIVE APPROACHES TO EXPLORE

### Alternative 1: Minimal Core + Rich Extensions

**Core Table (RESO Insert):**
- `MlsListing.dbo.Listing` - Zero changes, just new IDs/types
- All RESO Insert fields already exist

**Extension Tables (PRE-LISTING Features):**
- `PlsPropertyHistory` - Sale history, owner history, property timeline
- `PlsAgentKnowledge` - Agent notes, research, insights
- `PlsPropertyResearch` - Cached TitleGenie/Attom data (for quick access)

**Link:** Via `ListingID` foreign key

**Pros:**
- RESO Insert stays zero-lift (uses core table only)
- PRE-LISTING features get rich data structure
- Clear separation of concerns
- Queryable, normalized data

**Cons:**
- More tables to manage
- More joins for full property view

### Alternative 2: Extended Data Column

**Core Table:**
- `MlsListing.dbo.Listing` - Zero changes
- Use existing `ExtendedData` XML column for PRE-LISTING features

**Pros:**
- No new tables
- Simple structure
- All data in one place

**Cons:**
- Harder to query PRE-LISTING features
- Less normalized
- XML/JSON parsing overhead

### Alternative 3: Hybrid - Core + Light Extensions

**Core Table:**
- `MlsListing.dbo.Listing` - Zero changes

**Light Extensions:**
- `PlsPropertyHistory` - Only sale history (who sold, when, price)
- Use TitleGenie/Attom for other research (don't cache, query on demand)

**Pros:**
- Minimal table expansion
- Focused on most-used PRE-LISTING feature (sale history)
- Other research queries TitleGenie directly

**Cons:**
- May need to query TitleGenie frequently
- Less cached data

---

## 🔍 WHAT WE NEED TO DECIDE

### Decision 1: Table Structure
- [ ] Option A: Separate tables for PRE-LISTING features
- [ ] Option B: Extended Data column
- [ ] Option C: Hybrid approach
- [ ] Option D: Other (propose)

### Decision 2: What PRE-LISTING Features Need Tables?
- [ ] Property history (sale history, owner history)
- [ ] Agent knowledge/notes
- [ ] Cached TitleGenie data
- [ ] Other (specify)

### Decision 3: Ownership Tracking
- [ ] In core table (if needed for RESO Insert)
- [ ] In separate PRE-LISTING table
- [ ] Use existing user/listing relationships
- [ ] Other (specify)

### Decision 4: Design Decisions (Still TBD)
- [ ] MlsId value
- [ ] Listing number format
- [ ] StatusTypeID values
- [ ] PropertyCastTypeId value

---

## 📁 KEY DOCUMENTS TO REVIEW

1. **Contract v6.1:** `CONTRACT_PLS_to_GenieCloud_v6.1.md`
   - Current approach documented
   - Zero schema changes strategy
   - Data sources corrected

2. **Field Mapping Analysis:** `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md`
   - Complete field-by-field mapping
   - Join strategies
   - Conflict resolution

3. **Workspace Memory Logs:**
   - `MLS_Data_Discovery/WORKSPACE_MEMORY_LOG_MLS_Data_Discovery_2025-12-30_v1.md`
   - `PLS_RESO_ENGINE/WORKSPACE_MEMORY_LOG_PLS_RESO_Engine_2025-12-30_v1.md`

4. **Related Specs (May Need Updates):**
   - `PLS_DATABASE_IMPLEMENTATION_SPEC_v1.md`
   - `PLS_UI_SPECIFICATION_v1.md`
   - `PLS_XML_GENERATION_SPEC_v1.md`

---

## ⚠️ RISKS & CONCERNS IDENTIFIED

1. **Contract Sync:** v6.1 only in PLS location, not synced to GenieCloud location
2. **Breaking Changes:** Other specs may reference old approach
3. **Design Decisions:** Many values still TBD
4. **Field Mapping Accuracy:** Needs verification against actual database
5. **Historical MLS Data:** Availability and performance not tested
6. **Zero Schema Assumption:** May need supporting tables after all

---

## 🎯 YOUR TASK

**As the AI assistant, please:**

1. **Review the user's conceptual idea** about minimizing RESO table expansion
2. **Think critically** - is the v6.1 approach the best, or are there better alternatives?
3. **Propose alternative approaches** if you see a better way to achieve the goal
4. **Consider the trade-offs** of each approach
5. **Help vet the approach** before we lock in a plan
6. **Get feedback from all sides** - consider what each team (Data Layer, Function Layer, Interface Layer, GenieCloud) needs

**Remember:** This is collaborative exploration. The user's last message was a conceptual idea, not a direct order. Think creatively and propose the best solution, even if it differs from what was initially suggested.

---

## 💬 CONVERSATION STARTER

"Hi! I'm picking up the PLS RESO Engine design collaboration. We've established a v6.1 approach with zero schema changes, but the user has proposed a conceptual idea about minimizing RESO table expansion and only expanding tables for PRE-LISTING command features (TitleGenie/Agent portal) that aren't relevant to listing push.

Before we lock in a plan, I'd like to:
1. Explore alternative approaches to achieve this goal
2. Think critically about what tables are truly needed
3. Get your feedback on the trade-offs
4. Vet the approach collaboratively

What are your thoughts on the best way to structure this?"

---

**Location:** `D:\Cursor\TheGenie.ai\Development\MLS_Parsers\PLS_RESO_ENGINE\NEW_CHAT_RESTART_PROMPT_v6.1_COLLABORATION.md`

