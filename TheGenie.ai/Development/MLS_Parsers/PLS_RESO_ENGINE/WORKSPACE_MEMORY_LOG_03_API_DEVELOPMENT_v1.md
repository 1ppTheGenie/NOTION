# PLS RESO Engine - Workspace Memory Log: API Development
**Version:** 1.0  
**Created:** 01/10/2026  
**Last Updated:** 01/10/2026  
**Topic:** API Endpoints, Controllers, Business Logic, Request/Response Formats  
**Status:** ✅ Active

---

## 📋 TOPIC OVERVIEW

This memory log captures all discussions, decisions, and documentation related to:
- REST API endpoint design
- Controller implementation
- Business logic services
- Request/response formats
- Data validation
- Error handling

---

## 🎯 API ARCHITECTURE

### Controller: PlsController
**Location:** `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\PlsController.cs`

**Base Route:** `/api/pls`

### Service: PlsService
**Location:** Business logic layer (to be implemented)

**Responsibilities:**
- Data validation
- Business rule enforcement
- Database interaction coordination
- Error handling

---

## 📡 API ENDPOINTS

### POST /api/pls/create
**Purpose:** Create new PLS listing

**Request:**
```json
{
  "address": "10037 Rebecca Place",
  "city": "Boerne",
  "state": "TX",
  "zip": "78006",
  "propertyType": "Residential",
  "statusTypeId": 6,
  "userId": "guid-here"
}
```

**Response:**
```json
{
  "success": true,
  "listingNumber": "PLS100000A",
  "listingId": 12345,
  "message": "Listing created successfully"
}
```

### PUT /api/pls/{listingNumber}
**Purpose:** Update existing PLS listing

**Request:** Same as create, with listingNumber in URL

**Response:**
```json
{
  "success": true,
  "listingNumber": "PLS100000A",
  "message": "Listing updated successfully"
}
```

### GET /api/pls/{listingNumber}
**Purpose:** Retrieve PLS listing details

**Response:**
```json
{
  "listingNumber": "PLS100000A",
  "address": "10037 Rebecca Place",
  "city": "Boerne",
  "state": "TX",
  "zip": "78006",
  "statusTypeId": 6,
  "propertyType": "Residential",
  "createdDate": "2026-01-10T10:00:00Z",
  "owner": {
    "userId": "guid-here",
    "isPrimary": true
  }
}
```

### GET /api/pls/my-listings
**Purpose:** Get all PLS listings for current user

**Query Parameters:**
- `status` (optional) - Filter by status
- `page` (optional) - Pagination
- `pageSize` (optional) - Items per page

**Response:**
```json
{
  "listings": [
    {
      "listingNumber": "PLS100000A",
      "address": "10037 Rebecca Place",
      "statusTypeId": 6,
      "createdDate": "2026-01-10T10:00:00Z"
    }
  ],
  "totalCount": 1,
  "page": 1,
  "pageSize": 20
}
```

### POST /api/pls/{listingNumber}/render
**Purpose:** Generate GenieCloud XML and create marketing assets

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

### POST /api/pls/pre-populate
**Purpose:** Pre-populate listing data from TitleData/Assessor

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

### POST /api/pls/reverse-geocode (🔮 Future Feature)
**Purpose:** Convert latitude/longitude to address

**Request:**
```json
{
  "latitude": 29.7944,
  "longitude": -98.7319
}
```

**Response:**
```json
{
  "success": true,
  "address": "10037 Rebecca Place",
  "city": "Boerne",
  "state": "TX",
  "zip": "78006"
}
```

### POST /api/pls/upload-photo
**Purpose:** Upload property photos

**Request:** Multipart form data with image files

**Response:**
```json
{
  "success": true,
  "photos": [
    {
      "photoId": 123,
      "url": "https://cloud.thegenie.ai/genie-files/...",
      "thumbnailUrl": "https://cloud.thegenie.ai/genie-files/..."
    }
  ]
}
```

### POST /api/pls/generate-description
**Purpose:** Generate AI description using Paisley (ChatStartTypeId=3)

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

### PUT /api/pls/archive/{listingNumber}
**Purpose:** Archive PLS listing

**Response:**
```json
{
  "success": true,
  "listingNumber": "PLS100000A",
  "message": "Listing archived successfully"
}
```

---

## 🔧 DATA CONTROLLER ENDPOINTS

### DataController.PLS.cs (Partial Class)
**Location:** `C:\Sandbox\1ppDevelopment\Application\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\DataController.PLS.cs`

**Endpoints:**
- `GET /api/data/pls/pre-populate` - Pre-populate from TitleData
- `GET /api/data/pls/areas` - Get area data for Paisley
- `POST /api/data/pls/validate-address` - Validate address format

---

## 📚 KEY DOCUMENTS

| Document | Version | Purpose |
|----------|---------|---------|
| **DataController_Endpoints_v1.cs** | 1.0 | DataController endpoint specifications |
| **DataController_PLS_Complete_v1.cs** | 1.0 | Complete PLS DataController implementation |
| **DataController_PLS_Implementation_v1.cs** | 1.0 | PLS DataController implementation guide |
| **PlsController_Complete_v1.cs** | 1.0 | Complete PlsController implementation |

---

## 🔑 KEY DECISIONS

1. **RESTful Design** - Standard REST verbs (GET, POST, PUT, DELETE)
2. **JSON Format** - All requests/responses use JSON
3. **Error Handling** - Standard error response format with success flag
4. **Pagination** - Standard page/pageSize parameters
5. **Authentication** - Uses existing ASP.NET authentication
6. **Authorization** - User can only access their own listings (unless admin)

---

## ⚠️ CRITICAL NOTES

1. **PlsController.cs** was deleted during rollback - needs to be recreated
2. **DataController.PLS.cs** was deleted during rollback - needs to be recreated
3. **All endpoints must be tested in Sandbox first** before Production
4. **Error handling** must return user-friendly messages
5. **Validation** must occur before database operations

---

## 📝 CHANGELOG

- **2026-01-10:** Initial workspace memory log created
- **2026-01-09:** API endpoints documented in Project Blueprint
- **2026-01-06:** Future features added (reverse-geocode)
- **2026-01-02:** Initial API design completed

---

**Status:** ✅ Active - All API design decisions documented
