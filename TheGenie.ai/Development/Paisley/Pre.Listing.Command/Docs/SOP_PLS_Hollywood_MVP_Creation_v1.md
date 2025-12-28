# SOP: Creating a PLS-Hollywood Private Listing Page (MVP)

**Version:** 1.0  
**Created:** 12/25/2025  
**Last Updated:** 12/25/2025  
**Author:** Cursor AI / Steve Hundley  

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/25/2025 | Initial MVP SOP for manual PLS page creation |

---

## Purpose

This SOP outlines the steps to create a Private Listing or Coming Soon landing page using the PLS-Hollywood template. This is the MVP (Minimum Viable Product) process that bypasses the normal GenieCloud order workflow.

---

## Prerequisites

1. Access to stage.geniecloud repository
2. AWS credentials (genie-hub-active profile)
3. Property data (address, specs, photos)
4. Agent marketing settings (from FarmGenie database)
5. Python with boto3, requests, lxml installed

---

## Required Data Fields

### Property Information

| Field | Required | Example | Source |
|-------|----------|---------|--------|
| Street Number | Yes | 10037 | Attom/MLS |
| Street Name | Yes | Rebecca Place | Attom/MLS |
| City | Yes | Boerne | Attom/MLS |
| State | Yes | TX | Attom/MLS |
| Zip | Yes | 78006 | Attom/MLS |
| Price | Yes | 749000 | User Input |
| Bedrooms | Yes | 4 | Attom/MLS |
| Bathrooms Total | Yes | 3 | Attom/MLS |
| Square Feet | Yes | 3018 | Attom/MLS |
| Year Built | Yes | 2022 | Attom/MLS |
| Lot Size (sqft) | Yes | 9101 | Attom |
| Latitude | Yes | 29.72229 | Attom/MLS |
| Longitude | Yes | -98.68958 | Attom/MLS |
| Description | Yes | (narrative) | User Input |
| Status Type | Yes | 5=Coming Soon, 6=Private Listing | User Input |
| Primary Photo URL | Yes | S3 URL | Uploaded |

### Agent Information

| Field | Required | Source |
|-------|----------|--------|
| First Name | Yes | UserMarketingProfile |
| Last Name | Yes | UserMarketingProfile |
| Marketing Name | Yes | UserMarketingProfile |
| Email | Yes | UserMarketingProfile |
| Mobile | Yes | UserMarketingProfile |
| Photo URL | Yes | UserMarketingImage |
| Company Name | Yes | UserMarketingProfile |
| Website | No | UserMarketingProfile |
| Marketing About | No | UserMarketingProfile |

### Area Information

| Field | Required | Notes |
|-------|----------|-------|
| Area ID | Yes | From GenieCloud Areas table |
| Area Name | Yes | Matches Area ID |

---

## Step-by-Step Process

### Step 1: Gather Property Data

1. Query Attom data for property details:
   - Use PropertyID or APN lookup
   - Get address, specs, coordinates

2. Prepare property photos:
   - Upload to S3 staging bucket
   - Note the full URLs

3. Write property description or use AI generator

### Step 2: Gather Agent Data

1. Query FarmGenie.UserMarketingProfile:
```sql
SELECT * FROM FarmGenie.dbo.UserMarketingProfile 
WHERE AspNetUserId = 'agent-guid-here'
```

2. Query agent photo:
```sql
SELECT * FROM FarmGenie.dbo.UserMarketingImage 
WHERE AspNetUserId = 'agent-guid-here'
AND MarketingImageTypeId = 1  -- Agent Photo
```

### Step 3: Create XML Data File

1. Copy the template from:
   `D:\Cursor\_SourceCode\stage.geniecloud\genie-processor\xml\pls-10037-rebecca.xml`

2. Update all fields with new property data

3. Key XML attributes to set:

```xml
<output 
    apiUrl="https://cloud-api.thegenie.ai/" 
    siteUrl="https://cloud.thegenie.ai/" 
    userId="[SPOOF-USER-ID]"  <!-- User with active MLS data -->
    agentCode="[MLS-AGENT-CODE]"
    theme="compass" 
    themeHue="dark" 
    propertyType="0"  <!-- 0=Single Family -->
    mlsId="68"  <!-- SABOR MLS -->
    hideAVM="true"
    isLeadCapture="false"
/>
```

4. Set status in `<single>` section:
   - `<statusTypeID>5</statusTypeID>` for Coming Soon
   - `<statusTypeID>6</statusTypeID>` for Private Listing

### Step 4: Upload Photos to S3

```python
import boto3

session = boto3.Session(profile_name='genie-hub-active', region_name='us-west-1')
s3 = session.client('s3')

s3.upload_file(
    'local-photo.jpg',
    'genie-cloud',
    'genie-pages/[property-folder]/photos/photo-name.jpg',
    ExtraArgs={'ContentType': 'image/jpeg'}
)
```

### Step 5: Render and Deploy

Since XSLT transformation requires the full XSL import chain, use the post-processing approach:

1. Start with a working rendered HTML (from a similar page)
2. Use Python to:
   - Download the template HTML
   - Replace property-specific content
   - Fix encoding issues
   - Deploy to S3

```python
# Deploy script pattern
session = boto3.Session(profile_name='genie-hub-active', region_name='us-west-1')
s3 = session.client('s3')

s3.upload_file(
    'final-page.html',
    'genie-cloud',
    'genie-pages/[property-folder]/pls-hollywood/index.html',
    ExtraArgs={'ContentType': 'text/html; charset=utf-8'}
)
```

### Step 6: Post-Deployment QA

1. Check the live URL
2. Verify:
   - Address displays correctly
   - Photos load
   - Map centers on property
   - Widgets populate with data
   - Contact form works
   - No encoding issues (Â characters, smart quotes)

3. Fix any issues and redeploy

---

## Folder Structure

```
D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\
├── Docs\
│   ├── PLS_Hollywood_Workspace_Memory_Log_v1.md
│   └── SOP_PLS_Hollywood_MVP_Creation_v1.md
├── Scripts\
│   └── (deployment scripts)
├── XML\
│   └── (XML data files)
└── HTML\
    └── (rendered HTML files)
```

---

## Common Issues and Fixes

### Issue: Encoding Problems (Â characters)
**Fix:** Post-process HTML to replace Unicode characters:
```python
html = html.replace('\u00c2', '')
html = html.replace('\u2019', "'")  # Smart apostrophe
```

### Issue: Widgets Show "No Data"
**Fix:** Ensure userId is set to an agent with active MLS data in that area

### Issue: Map Not Centered
**Fix:** Verify latitude/longitude in XML match property location

### Issue: Theme Looks Wrong
**Fix:** Use `theme="compass"` with `themeHue="dark"` (not `theme="compass-dark"`)

### Issue: API Errors
**Fix:** Use `https://cloud-api.thegenie.ai/` (not dynamicarray.co.uk)

---

## Future Enhancements (Post-MVP)

1. **Brochure Auto-Generation:** Trigger genie-api render for PDF brochure
2. **UI Interface:** Web form to input property data
3. **XML Generator:** Auto-create XML from form input
4. **Full Integration:** Connect to Engagement Center, lead tagging, UTM tracking
5. **Description Writer:** AI-powered property description generator

---

## Reference Files

| File | Location | Purpose |
|------|----------|---------|
| pls-hollywood.xsl | stage.geniecloud/public/_assets/_xsl/landing-pages/ | XSL template |
| pls-10037-rebecca.xml | stage.geniecloud/genie-processor/xml/ | Sample XML |
| 10037_Rebecca_All_Fields_v1.csv | iCloud project folder | Field reference |

---

## Support

For questions about this SOP, contact:
- **Steve Hundley:** steve@hundley.com
- **TheGenie Tech Team:** (internal)

