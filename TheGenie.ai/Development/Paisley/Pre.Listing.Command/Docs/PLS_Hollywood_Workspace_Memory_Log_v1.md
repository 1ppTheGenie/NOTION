# PLS-Hollywood Workspace Memory Log

**Version:** 1.0  
**Created:** 12/25/2025  
**Last Updated:** 12/25/2025  
**Author:** Cursor AI / Steve Hundley  

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/25/2025 | Initial MVP release - 10037 Rebecca Place private listing page |
| 1.1 | 12/25/2025 | Added School District, Neighborhood, Home Condition fields |
| 1.2 | 12/25/2025 | Fixed theme: compass light → compass dark |
| 1.3 | 12/25/2025 | Removed Price Per Sq Ft, changed Status → Listing Status: Private |

---

## Project Overview

**Project Name:** Pre-Listing Service (PLS) Hollywood Landing Page  
**Purpose:** Create private listing and coming soon landing pages for properties not yet on MLS  
**Status:** MVP Complete - Pre-Release  

### Production URLs

| URL | Purpose |
|-----|---------|
| https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html | Canonical URL (use for QR code) |
| https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/lc-hollywood/index.html | Legacy URL (also works) |

---

## Technical Architecture

### System Components

1. **XSL Template:** `pls-hollywood.xsl` (cloned from `lc-hollywood.xsl`)
   - Location: `D:\Cursor\_SourceCode\stage.geniecloud\public\_assets\_xsl\landing-pages\pls-hollywood.xsl`
   - Supports statusTypeID 5 (Coming Soon) and 6 (Private Listing)

2. **XML Data File:** `pls-10037-rebecca.xml`
   - Location: `D:\Cursor\_SourceCode\stage.geniecloud\genie-processor\xml\pls-10037-rebecca.xml`
   - Contains all property, agent, and area data

3. **S3 Deployment:**
   - Bucket: `genie-cloud` (us-west-1)
   - AWS Profile: `genie-hub-active`
   - Path: `genie-pages/pls-10037-rebecca-place/pls-hollywood/`

### Data Sources

| Data Type | Source | Notes |
|-----------|--------|-------|
| Property Address | Attom Tax Records | 10037 Rebecca Place, Boerne, TX 78006 |
| Property Details | MLS Historical + Attom | 4 bed, 3 bath, 3,018 sqft, built 2022 |
| Agent Marketing | FarmGenie.UserMarketingProfile | Texas Genie account (Steve Hundley) |
| Area Data | GenieCloud API | Balcones Creek - All Neighborhoods (ID: 407559) |
| Widget Data | Spoofed via userId | Dainelle Scott's userId for live API data |

### Spoofing Mechanism

The PLS system uses "spoofing" to pull live widget data:
- **Display Agent:** Steve Hundley (Texas Genie marketing settings)
- **API UserId:** `9f750957-4d66-4151-bd37-9588d17d4fb8` (Dainelle Scott)
- **Why:** Dainelle has active MLS data that populates widgets; Steve's account doesn't

---

## Key Files

### Source Files (stage.geniecloud)

| File | Purpose |
|------|---------|
| `genie-processor/xml/pls-10037-rebecca.xml` | Property/Agent/Area XML data |
| `public/_assets/_xsl/landing-pages/pls-hollywood.xsl` | XSL template |
| `pls-10037-rebecca-final-mvp.html` | Final deployed HTML |

### Deployment Scripts

| Script | Purpose |
|--------|---------|
| `fix_brochure_to_form_v1.py` | Brochure button -> contact form |
| `fix_address_and_deploy_v1.py` | Address correction |
| `fix_all_encoding_v1.py` | Character encoding fixes |

### Property Data Files (Original Location)

| File | Location |
|------|----------|
| `10037_Rebecca_All_Fields_v1.csv` | iCloud project folder |
| `PLS_XML_Fields_10037_Rebecca_v1.csv` | XML field mapping |

---

## Known Limitations (MVP)

1. **Brochure Generation:** Not auto-generated; button scrolls to contact form
2. **Manual Deployment:** Bypasses normal GenieCloud order workflow
3. **Widget Data:** Requires spoofing another user's ID for API access
4. **Encoding Issues:** Required post-processing to fix UTF-8 characters

---

## Future Iterations

### Iteration 2: Brochure Integration
- Trigger brochure generation through genie-api render pipeline
- Use `flyers/lc-brochure-01` XSL template
- Auto-generate PDF on page creation

### Iteration 3: UI Interface
- Build interface to input property fields
- Connect to Attom/MLS data sources
- Generate XML automatically

### Iteration 4: Full Integration
- Connect to lead generation system
- UTM tracking and tagging
- Engagement center integration
- QR code auto-generation

---

## Database References

| Database | Table | Purpose |
|----------|-------|---------|
| FarmGenie | UserMarketingProfile | Agent marketing settings |
| FarmGenie | UserMarketingImage | Agent photos/logos |
| MlsListing | Listing | MLS property data |

### Key IDs

| Entity | ID | Notes |
|--------|-----|-------|
| Steve Hundley Agent ID | a8436051-333d-4725-b8ce-88bf5262d26a | Texas Genie account |
| Dainelle Scott User ID | 9f750957-4d66-4151-bd37-9588d17d4fb8 | Used for API spoofing |
| Balcones Creek Area ID | 407559 | All Neighborhoods |
| SABOR MLS ID | 68 | San Antonio Board of Realtors |

---

## API Endpoints

| Endpoint | Purpose |
|----------|---------|
| https://cloud-api.thegenie.ai/ | GenieCloud API (correct) |
| https://cloud.thegenie.ai/ | Site assets and pages |

**Note:** `genie-api.dynamicarray.co.uk` is deprecated/non-functional. Always use `cloud-api.thegenie.ai`.

---

## Theme Configuration

| Setting | Value |
|---------|-------|
| Theme | compass |
| Theme Hue | dark |
| CSS File | `/_assets/themes/compass.css` |
| HTML Class | `genie-landing-page compass dark asset-v` |
| Body Class | `lc-hollywood pls-hollywood compass dark` |

The "Compass Dark" theme uses `theme="compass"` with `themeHue="dark"` - there is no separate `compass-dark.css` file.

**IMPORTANT:** The HTML must have `compass dark` in the class attributes, NOT `compass light`. If the page shows blue/orange colors instead of black/white, check this setting.

---

## Contact

**Project Lead:** Steve Hundley  
**Email:** steve@hundley.com  
**Phone:** 619.507.4404  

