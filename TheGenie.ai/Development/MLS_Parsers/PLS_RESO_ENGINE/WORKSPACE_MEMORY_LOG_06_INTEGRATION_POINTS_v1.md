# PLS RESO Engine - Workspace Memory Log: Integration Points
**Version:** 1.0  
**Created:** 01/10/2026  
**Last Updated:** 01/10/2026  
**Topic:** Paisley, GenieCloud, Listing Command, TitleGenie, Engagement Center  
**Status:** ✅ Active

---

## 📋 TOPIC OVERVIEW

This memory log captures all discussions, decisions, and documentation related to:
- Paisley AI integration
- GenieCloud XML generation
- Listing Command integration
- TitleGenie data sources
- Engagement Center workflows
- Mapbox integration

---

## 🤖 PAISLEY AI INTEGRATION

### Purpose
Generate AI-powered property descriptions for PLS listings.

### Integration Details
- **ChatStartTypeId:** 3 (Pre-Listing Focused)
- **Input Data:** Listing Data + Area Data
- **Output:** Professional property description
- **Trigger:** User clicks "Generate with AI" button (or auto-generates)

### API Endpoint
**POST /api/pls/generate-description**

**Request:**
```json
{
  "listingNumber": "PLS100000A",
  "areaId": 123,
  "tone": "professional"
}
```

**Response:**
```json
{
  "success": true,
  "description": "Beautiful home in desirable neighborhood...",
  "generatedBy": "Paisley AI",
  "chatStartTypeId": 3
}
```

### Workflow
1. User creates/edits PLS listing
2. System auto-fetches area data (for Paisley context)
3. User selects area (required for Paisley)
4. System calls Paisley with ChatStartTypeId=3
5. Paisley generates description using Assessor data + Area data
6. Description displayed with "Edit" button (no "Generate" button needed)

---

## ☁️ GENIECLOUD INTEGRATION

### Purpose
Generate marketing assets (landing pages, social ads, postcards, brochures) from PLS listings.

### XML Structure
Defined in `CONTRACT_PLS_to_GenieCloud_v6.1.md` Section 17.

### API Endpoint
**POST /api/pls/{listingNumber}/render**

**Process:**
1. System generates GenieCloud XML from PLS listing data
2. System calls GenieCloud API to create collection
3. GenieCloud generates marketing assets
4. System returns URLs to all assets

**Response:**
```json
{
  "success": true,
  "collectionId": "guid-here",
  "landingPageUrl": "https://cloud.thegenie.ai/genie-pages/...",
  "assets": {
    "socialAds": ["url1", "url2"],
    "postcards": ["url1", "url2"],
    "brochures": ["url1"]
  }
}
```

### XML Mapping
See `PLS_GENIECLOUD_XML_MAPPING_v1.md` for complete mapping specification.

**Key Mappings:**
- PLS listing → GenieCloud Collection
- Property data → XML elements
- Photos → GenieCloud photo references
- Description → GenieCloud description field

---

## 📋 LISTING COMMAND INTEGRATION

### Purpose
Enable circle prospecting automation for pre-MLS listings.

### Integration Points
1. **Listing Creation** - PLS listing triggers Listing Command workflow
2. **Area Selection** - Area data used for circle prospecting
3. **Lead Capture** - Engagement Center captures leads from PLS listings
4. **SMS Campaigns** - Automated SMS to area contacts

### Workflow
1. User creates PLS listing
2. System selects area (for Listing Command)
3. System triggers Listing Command workflow
4. Listing Command generates circle prospecting campaign
5. Engagement Center captures leads
6. SMS campaigns sent to area contacts

### Reference
- **MVP Example:** https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html
- **Collection:** https://cloud.thegenie.ai/genie-collection/15a521b8-3fbf-4042-bce3-58e378cd9a52

---

## 🏠 TITLEGENIE INTEGRATION

### Purpose
Pre-populate PLS listing data from TitleData/Assessor database.

### Data Sources
1. **TitleData.dbo.AttomDataAssessor** - 318 fields of property data
2. **TitleData.dbo.AssessorDataPropertyMap** - Property ID mapping
3. **Historical MLS Data** - Previous listing data

### API Endpoint
**POST /api/pls/pre-populate**

**Request:**
```json
{
  "address": "10037 Rebecca Place",
  "city": "Boerne",
  "state": "TX",
  "zip": "78006",
  "latitude": 29.7944,
  "longitude": -98.7319
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "yearBuilt": 2020,
    "sqFt": 2500,
    "bedrooms": 3,
    "bathrooms": 2,
    "lotSqFt": 10000,
    "garageSpaces": 2,
    "propertyType": "Residential"
  },
  "source": "TitleData.Assessor",
  "confidence": 0.95
}
```

### Field Mapping
See `TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md` for complete mapping (318 → 93 fields).

**Key Mappings:**
- Assessor.YearBuilt → Listing.YearBuilt
- Assessor.SqFt → Listing.Sqft
- Assessor.Bedrooms → Listing.Bedrooms
- Assessor.Bathrooms → Listing.BathroomsTotal

---

## 📧 ENGAGEMENT CENTER INTEGRATION

### Purpose
Capture leads from PLS listings and track engagement.

### Integration Points
1. **Lead Capture** - UTM tracking from PLS landing pages
2. **Data Append** - Versium cache for contact data
3. **Workflows** - Automated follow-up sequences
4. **SMS Campaigns** - Listing Command integration

### UTM Tracking
- **Source:** PLS
- **Medium:** Pre-Listing
- **Campaign:** {ListingNumber}
- **Content:** {AssetType} (social-ad, postcard, etc.)

### Lead Data
- **Property ID** - For data append
- **UTM Parameters** - For campaign tracking
- **Engagement Metrics** - Clicks, opens, conversions

---

## 🗺️ MAPBOX INTEGRATION

### Purpose
Address lookup, reverse geocoding, and satellite photo generation.

### Features
1. **Address Autocomplete** - Mapbox Geocoding API
2. **Reverse Geocoding** - Convert lat/lng to address (future feature)
3. **Satellite Photos** - Auto-generate property boundary + best angle view

### API Endpoints
- **Address Lookup:** Mapbox Geocoding API
- **Satellite Photo:** Mapbox Static Images API

### Prototype
See `PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html` for working prototype.

**Features:**
- Address autocomplete
- Map display
- Property boundary overlay
- Best angle calculation

---

## 📚 KEY DOCUMENTS

| Document | Version | Purpose |
|----------|---------|---------|
| **CONTRACT_PLS_to_GenieCloud_v6.1.md** | 6.1 | XML structure, API endpoints, 3-layer architecture |
| **PLS_GENIECLOUD_XML_MAPPING_v1.md** | 1.0 | Collection → XML mapping specification |
| **TITLEDATA_TO_MLSLISTING_FIELD_MAPPING_ANALYSIS_v1.md** | 1.0 | Field mapping analysis (318 → 93 fields) |
| **PLS_PROTOTYPE_ADDRESS_LOOKUP_v4.html** | 4.0 | Mapbox address lookup prototype |

---

## 🔑 KEY DECISIONS

1. **Paisley ChatStartTypeId=3** - Pre-Listing Focused for description generation
2. **GenieCloud XML** - Standard format for marketing asset generation
3. **Listing Command** - Full integration for circle prospecting
4. **TitleGenie** - Primary data source for pre-population
5. **Mapbox** - Address lookup and satellite photo generation
6. **Engagement Center** - Lead capture and tracking

---

## ⚠️ CRITICAL NOTES

1. **Area Selection Required** - Paisley needs area data for context
2. **XML Format** - Must match GenieCloud contract exactly
3. **Field Mapping** - 318 Assessor fields → 93 MlsListing fields
4. **UTM Tracking** - Required for Engagement Center lead tracking
5. **Mapbox API Key** - Must be configured for address lookup

---

## 📝 CHANGELOG

- **2026-01-10:** Initial workspace memory log created
- **2026-01-09:** Paisley integration workflow updated
- **2026-01-06:** Mapbox integration added
- **2026-01-02:** Initial integration specifications completed

---

**Status:** ✅ Active - All integration points documented
