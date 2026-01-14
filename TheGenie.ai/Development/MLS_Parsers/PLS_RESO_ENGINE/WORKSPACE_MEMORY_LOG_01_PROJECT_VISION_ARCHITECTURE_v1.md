# PLS RESO Engine - Workspace Memory Log: Project Vision & Architecture
**Version:** 1.0  
**Created:** 01/10/2026  
**Last Updated:** 01/10/2026  
**Topic:** Project Vision, Goals, System Architecture, 3-Layer Architecture  
**Status:** ✅ Active

---

## 📋 TOPIC OVERVIEW

This memory log captures all discussions, decisions, and documentation related to:
- Project vision and business goals
- System architecture design
- 3-layer architecture (Data/Function/Interface)
- Integration strategy
- Business value propositions

---

## 🎯 PROJECT VISION & GOALS

### Vision Statement
> Enable agents to become "early movers" by marketing properties BEFORE they hit MLS, with full marketing automation and seamless transition to MLS when ready.

### Primary Goals
1. **Create Pre-MLS Listings** - Agents can create Coming Soon/Private listings in TheGenie system
2. **Generate Marketing Assets** - Automatic creation of landing pages, social ads, brochures via GenieCloud
3. **Circle Prospecting Automation** - Full Listing Command integration for pre-MLS listings
4. **Zero Schema Changes** - Leverage existing `MlsListing.dbo.Listing` structure
5. **Future RESO Insert** - One-button push to Bridge/Trestle MLSs (strategic opportunity)

### Business Value
| Value Proposition | Impact |
|-------------------|--------|
| **Early Mover Advantage** | Agents market properties BEFORE they hit MLS |
| **Listing Command Integration** | Full circle prospecting automation for pre-MLS listings |
| **Zero Double Entry** | Future RESO Insert eliminates manual MLS entry |
| **Time Savings** | AI pre-population reduces data entry by 80% |
| **Marketing Assets** | Automatic generation of landing pages, social ads, brochures |

---

## 🏗️ SYSTEM ARCHITECTURE

### High-Level Architecture
The PLS system integrates with 4 core systems:
1. **TITLE GENIE** - Property research, Attom/MLS data (provides property data)
2. **PAISLEY** - AI content generation, ChatStartTypeId=3 "Pre-Listing Focused" uses Assessor data
3. **PRE-LISTING COMMAND** - Coming Soon / Private Listing page generator (MVP COMPLETE)
4. **ENGAGEMENT CENTER** - Lead capture, UTM tracking, data append, workflows

### Key Integration Points
- **GenieCloud** - XML generation for marketing assets
- **Listing Command** - Circle prospecting automation
- **Paisley AI** - Description generation (ChatStartTypeId=3)
- **TitleGenie** - Property data pre-population
- **Engagement Center** - Lead capture and tracking

---

## 🔄 3-LAYER ARCHITECTURE

From `CONTRACT_PLS_to_GenieCloud_v6.1.md` Section 17:

### Layer 1: DATA LAYER (Backend Infrastructure)
- Database structure (MlsListing.dbo.Listing, supporting tables)
- Stored procedures (usp_GetNextPlsNumber)
- Data sources (TitleData, Historical MLS)

### Layer 2: FUNCTION LAYER (API Endpoints)
- REST API controllers (PlsController)
- Business logic services (PlsService)
- Data validation and transformation

### Layer 3: INTERFACE LAYER (UI Components)
- Angular components (PlsCreateComponent, PlsMyListingsComponent)
- User workflows and navigation
- Form validation and error handling

---

## 📚 KEY DOCUMENTS

| Document | Version | Purpose |
|----------|---------|---------|
| **PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md** | 1.15 | Complete project blueprint - single source of truth |
| **PLS_3_LAYER_GAP_ANALYSIS_v1.md** | 1.0 | 3-layer architecture gap analysis |
| **CONTRACT_PLS_to_GenieCloud_v6.1.md** | 6.1 | XML structure, API endpoints, 3-layer architecture |
| **PLS_MASTER_SPECIFICATION_v3.md** | 3.0 | Complete PLS system spec |

---

## 🔑 KEY DECISIONS

1. **Database Strategy** - Use existing `MlsListing.dbo.Listing` with MlsId=777 (NOT 999 as originally planned)
2. **PLS Number Format** - Changed to `PLS{6-digit}{letter}` (e.g., PLS100000A)
3. **Status Types** - StatusTypeID 6 (Private Listing) needs INSERT, StatusTypeID 14 (Coming Soon) exists
4. **PropertyCastTypeId** - Use PropertyCastTypeId=4 for PLS
5. **No Schema Changes** - Leverage existing structure, add supporting tables only

---

## 📝 CHANGELOG

- **2026-01-10:** Initial workspace memory log created
- **2026-01-09:** PLS number format changed to PLS{6-digit}{letter}
- **2026-01-05:** MlsID changed to 777, normalized schema with lookup tables
- **2026-01-02:** Initial project blueprint created

---

**Status:** ✅ Active - All project vision and architecture decisions documented
