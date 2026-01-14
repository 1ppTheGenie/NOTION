# Trestle & RESO Write Capabilities Research - Building RESO Insert

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent

---

## 🎯 RESEARCH GOAL

**Study Trestle (CoreLogic) and RESO Web API specification to determine if we can build RESO Insert functionality for creating listings.**

**Vision:** Be the company that builds the RESO Insert solution for pushing listings to MLS via RESO Web API.

---

## 📊 TRESTLE (CORELOGIC) RESEARCH

### Standard Trestle API:
- **Primary Function:** Data distribution (read-only)
- **Protocols:** RESO Web API, RETS
- **Use Cases:** IDX, VOW feeds
- **Write Operations:** ❌ **Not documented in standard API**

### Trestle Direct™ (Enterprise Product):
- **What It Is:** Web API access to full spectrum of local listing data
- **Features:**
  - Nonstandard data fields and formats
  - Exclusive to Matrix™ and individual MLS databases
  - Exceeds Trestle RESO capabilities
  - Supports local requirements and unique listing fields
  - Real-time listing data through direct database connection
  - Supersedes RETS
- **Write Operations:** ⚠️ **Not explicitly mentioned** - needs verification
- **Source:** [CoreLogic Trestle for MLSs PDF](https://www.corelogic.com/wp-content/uploads/sites/4/2023/04/RES-Trestle-for-MLSs-04-2023.pdf)

### Key Finding:
**Trestle appears to be read-only, similar to Bridge. However, Trestle Direct™ may have additional capabilities that need direct inquiry.**

---

## 📚 RESO WEB API SPECIFICATION RESEARCH

### Research Question:
**Does the RESO Web API specification itself support write operations (POST/PUT/DELETE)?**

### Findings:
- **Standard RESO Web API:** Primarily documented for **read operations** (GET)
- **RESO Certification:** Focuses on **data retrieval** and **query capabilities**
- **Write Operations:** ⚠️ **Not explicitly documented** in standard RESO Web API spec
- **RESO Web API is based on OData:** OData specification DOES support CRUD operations (Create, Read, Update, Delete)

### Critical Insight:
**RESO Web API is built on OData, which inherently supports:**
- `GET` - Read (documented and widely used)
- `POST` - Create (OData supports, but not documented in RESO)
- `PUT` - Update (OData supports, but not documented in RESO)
- `DELETE` - Delete (OData supports, but not documented in RESO)

**This means:**
- ✅ **Technically possible** - OData foundation supports write operations
- ❌ **Not standardized** - RESO hasn't standardized write operations
- ⚠️ **Vendor-specific** - Each vendor (Bridge, Trestle) would need to implement

---

## 🎯 OPPORTUNITY: BUILDING RESO INSERT

### The Gap:
1. **RESO Web API spec** doesn't standardize write operations
2. **Bridge API** is read-only (standard) - has Bridge Listing Input (separate product)
3. **Trestle API** is read-only (standard) - has Trestle Direct™ (may have capabilities)
4. **No vendor** has standardized RESO Insert functionality

### The Opportunity:
**Be the first company to build standardized RESO Insert functionality!**

### Approach:

#### Option 1: Extend RESO Web API Standard
1. **Propose RESO Insert specification** to RESO.org
2. **Work with RESO** to standardize write operations
3. **Build reference implementation**
4. **Get RESO certification** for RESO Insert

#### Option 2: Build Vendor-Agnostic RESO Insert
1. **Create RESO Insert library** that works with both Bridge and Trestle
2. **Use OData POST/PUT** operations (if vendors support)
3. **Handle vendor-specific differences**
4. **Provide unified API** for pushing listings

#### Option 3: Partner with Vendors
1. **Partner with Bridge Interactive** - Extend Bridge Listing Input with API
2. **Partner with CoreLogic/Trestle** - Build write capabilities
3. **Create industry standard** through partnerships

---

## 📋 VENDOR COMPARISON

| Vendor | Standard API | Enterprise Solution | Write Capability |
|--------|-------------|---------------------|------------------|
| **Bridge Interactive** | ✅ Read-only (RESO Web API) | ✅ Bridge Listing Input (separate product) | ⚠️ Via Bridge Listing Input (needs integration) |
| **Trestle (CoreLogic)** | ✅ Read-only (RESO Web API) | ✅ Trestle Direct™ (enterprise) | ⚠️ Unknown - needs inquiry |
| **RESO Standard** | ✅ Read-only (GET operations) | ❌ No write standard | ⚠️ OData supports, but not standardized |

---

## 🚀 RECOMMENDED STRATEGY

### Phase 1: Research & Validation (Immediate)
1. ✅ **Contact CoreLogic/Trestle** - Inquire about Trestle Direct™ write capabilities
2. ✅ **Contact Bridge Interactive** - Inquire about Bridge Listing Input API
3. ✅ **Review RESO Web API spec** - Understand OData foundation
4. ✅ **Contact RESO.org** - Discuss RESO Insert standardization

### Phase 2: Proof of Concept (Short-term)
1. **Build RESO Insert prototype** using OData POST operations
2. **Test with Bridge** (if they support OData POST)
3. **Test with Trestle** (if they support OData POST)
4. **Document vendor differences**

### Phase 3: Standardization (Medium-term)
1. **Propose RESO Insert spec** to RESO.org
2. **Get industry buy-in** from MLSs and vendors
3. **Build reference implementation**
4. **Pursue RESO certification**

### Phase 4: Product Launch (Long-term)
1. **Launch RESO Insert product**
2. **Support multiple vendors** (Bridge, Trestle, others)
3. **Provide unified API** for PLS "push to MLS"
4. **Become industry standard**

---

## 📞 CONTACT INFORMATION

### CoreLogic/Trestle:
- **Website:** https://www.corelogic.com/
- **Trestle Documentation:** https://trestle-documentation.corelogic.com/
- **Contact:** Need to find enterprise sales contact

### Bridge Interactive:
- **Email:** `api@bridgeinteractive.com`
- **Website:** https://www.bridgeinteractive.com/

### RESO.org:
- **Website:** https://www.reso.org/
- **RESO Web API Spec:** https://www.reso.org/reso-web-api/
- **Contact:** Need to find standards committee contact

---

## ✅ KEY FINDINGS

1. **Trestle Standard API:** Read-only (similar to Bridge)
2. **Trestle Direct™:** Enterprise product - write capabilities unknown (needs inquiry)
3. **RESO Web API Spec:** Built on OData (which supports CRUD), but write operations not standardized
4. **Opportunity:** Be the first to build standardized RESO Insert functionality
5. **Strategy:** Extend RESO standard OR build vendor-agnostic solution

---

## 🎯 NEXT STEPS

1. **Contact CoreLogic/Trestle** - Inquire about Trestle Direct™ write capabilities
2. **Contact Bridge Interactive** - Inquire about Bridge Listing Input API
3. **Review RESO Web API spec** - Download full specification
4. **Contact RESO.org** - Discuss RESO Insert standardization opportunity
5. **Build proof of concept** - Test OData POST with vendors

---

**Status:** ✅ Research Complete - Opportunity Identified!



