# PLS GenieCloud Collection → XML Mapping Guide
**Version:** 1.0  
**Created:** 01/02/2026  
**Last Updated:** 01/02/2026  
**Author:** Cursor AI Agent  
**Purpose:** "Meet in the Middle" - Map existing GenieCloud collection prototype to XML format for new PLS content collections

---

## 🎯 EXECUTIVE SUMMARY

This document bridges the gap between:
- **What We Have:** GenieCloud collection prototype for 10037 Rebecca Place
- **What We Need:** XML format to drive new PLS content collections

**Goal:** Both teams (PLS and GenieCloud) can work from the same reference point.

---

## 📋 REFERENCE: 10037 REBECCA PLACE PROTOTYPE

### Live Collection
- **URL:** https://cloud.thegenie.ai/genie-pages/pls-10037-rebecca-place/pls-hollywood/index.html
- **Property:** 10037 Rebecca Place, Boerne, TX 78006
- **Status:** Private Listing (StatusTypeID=6)
- **Theme:** Compass Dark
- **PLS Number:** PLS-2025-00001 (example)

### What Rendered Successfully

| Asset Type | Asset Name | Status |
|------------|------------|--------|
| **Landing Page** | `pls-hollywood` | ✅ Rendered |
| **Social Graphics** | `lc-prop-post-03` | ✅ Rendered |
| **Social Graphics** | `lc-prop-post-01-vip` | ✅ Rendered |

---

## 🔄 COLLECTION → XML MAPPING

### Step 1: Identify Collection Assets

**Collection JSON Structure:**
```json
{
  "name": "PLS Social Collection v1",
  "version": 1,
  "template": "pls-social-collection",
  "sections": [
    {
      "sort": 1,
      "name": "Landing Pages",
      "assets": [
        {
          "sort": 1,
          "asset": "landing-pages/pls-hollywood",
          "name": "PLS Hollywood Landing"
        }
      ]
    },
    {
      "sort": 2,
      "name": "Social Media Assets",
      "assets": [
        {
          "sort": 1,
          "asset": "social-marketing-graphics/lc-prop-post-03",
          "name": "Cash Buyers"
        },
        {
          "sort": 2,
          "asset": "social-marketing-graphics/lc-prop-post-01-vip",
          "name": "Modern"
        }
      ]
    }
  ]
}
```

### Step 2: Map to XML Structure

**For Each Asset in Collection, Generate XML:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<renderRoot>
    <!-- OUTPUT ATTRIBUTES - From Collection + User Context -->
    <output 
        apiUrl="https://cloud-api.thegenie.ai/"
        siteUrl="https://cloud.thegenie.ai/"
        userId="{asp-user-id-from-session}"
        theme="compass"
        themeHue="dark"
        size="landing-page"
        renderId="pls-{pls-number}-{asset-name}"
        version="3.0.0"
        year="2025"
        areaPeriod="12"
        propertyType="0"
        withBleed="false"
        withCrops="false"
        blurPrice="false"
        hideAVM="true"
        requireSignin="false"
        isLeadCapture="false"
    />
    
    <!-- DATE PERIOD - Calculated from current date -->
    <date 
        period="Dec 2024 to Dec 2025" 
        previousPeriod="Dec 2023 to Dec 2024"
    />
    
    <!-- XSL ASSET - From Collection JSON -->
    <xslAsset>landing-pages/pls-hollywood</xslAsset>
    
    <!-- AGENT DATA - From UserMarketingProfile -->
    <agents>
        <agent>
            <firstName>{from UserMarketingProfile}</firstName>
            <lastName>{from UserMarketingProfile}</lastName>
            <role>{MarketingTitle}</role>
            <photo>{MarketingImage Type 1}</photo>
            <personalLogoLight>{MarketingImage Type 2}</personalLogoLight>
            <personalLogoDark>{MarketingImage Type 3}</personalLogoDark>
            <companyLogoLight>{MarketingImage Type 4}</companyLogoLight>
            <companyLogoDark>{MarketingImage Type 6}</companyLogoDark>
            <mobile>{Phone formatted}</mobile>
            <email>{Email}</email>
            <website>{Website}</website>
            <agentId>{AspNetUserId}</agentId>
            <marketingName>{DisplayName}</marketingName>
            <marketingTitle>{MarketingTitle}</marketingTitle>
            <marketingLicense>{LicenseNumberDisplay}</marketingLicense>
            <address>
                <company>{CompanyName}</company>
                <street>{StreetAddress}</street>
                <city>{City}</city>
                <state>{State}</state>
                <zip>{Zip}</zip>
            </address>
        </agent>
    </agents>
    
    <!-- AREA DATA - From User Selection -->
    <areas>
        <area>
            <id>{AreaId}</id>
            <name>{AreaName}</name>
            <centerLat>{CenterLatitude}</centerLat>
            <centerLng>{CenterLongitude}</centerLng>
            <statistics lookbackMonths="12" propertyType="0"/>
        </area>
    </areas>
    
    <!-- SINGLE LISTING DATA - From MlsListing.dbo.Listing -->
    <single>
        <mlsNumber>{MlsNumber} e.g., PLS-2025-00001</mlsNumber>
        <mlsId>999</mlsId>
        <price>{OriginalListPrice} e.g., 749000</price>
        <salePrice></salePrice>
        <listed>{ListDate formatted MM/DD/YYYY}</listed>
        <soldDate></soldDate>
        <daysOnMarket>0</daysOnMarket>
        <type>{PropertyType} e.g., Single Family</type>
        <listingStatus>{StatusType.Name} e.g., Private Listing</listingStatus>
        <listingAgent>{ListingAgentName}</listingAgent>
        <statusTypeID>{StatusTypeID} e.g., 6</statusTypeID>
        <description><![CDATA[{Remarks}]]></description>
        <photoPrimary>{PhotoPrimaryUrl}</photoPrimary>
        <squareFeet>{Sqft} e.g., 3018</squareFeet>
        <lotSize>{LotSqft} e.g., 9101</lotSize>
        <acres>{calculated from LotSqft}</acres>
        <built>{YearBuilt} e.g., 2022</built>
        <latitude>{Latitude} e.g., 29.72229</latitude>
        <longitude>{Longitude} e.g., -98.68958</longitude>
        
        <bedrooms count="{Bedrooms}"/>
        <bathrooms total="{BathroomsTotal}" full="{BathroomsFull}" half="{BathroomsHalf}"/>
        <parking spaces="{ParkingSpaces}" garage="{GarageSpaces}"/>
        
        <address>
            <streetNumber>{StreetNumber} e.g., 10037</streetNumber>
            <street>{DisplayAddress} e.g., 10037 Rebecca Place</street>
            <streetName>{StreetName} e.g., Rebecca Place</streetName>
            <city>{City} e.g., Boerne</city>
            <state>{State} e.g., TX</state>
            <zip>{Zip} e.g., 78006</zip>
        </address>
        
        <images>
            <!-- From MlsListing.dbo.Photo, ordered by DisplayOrder -->
            <image src="{PhotoUrl}"/>
            <image src="{PhotoUrl}"/>
            <image src="{PhotoUrl}"/>
        </images>
    </single>
    
    <!-- MLS DISPLAY - Static for PLS -->
    <mlsDisplay><![CDATA[This is a private listing presented by {CompanyName}. Property information is deemed reliable but not guaranteed.]]></mlsDisplay>
</renderRoot>
```

---

## 📊 DATA SOURCE MAPPING TABLE

### Collection JSON → XML Output Attributes

| Collection Field | XML Element | Data Source | Example |
|-------------------|-------------|-------------|---------|
| `sections[].assets[].asset` | `<xslAsset>` | Collection JSON | `landing-pages/pls-hollywood` |
| `sections[].assets[].name` | (Not in XML) | Collection JSON | Display name only |
| `template` | (Not in XML) | Collection JSON | Used for collection page |

### User Context → XML Agent Data

| Database Table/Field | XML Element | Query/Logic |
|----------------------|-------------|-------------|
| `AspNetUsers.Id` | `<agentId>` | From JWT token |
| `AspNetUserProfiles.FirstName` | `<firstName>` | JOIN AspNetUsers |
| `AspNetUserProfiles.LastName` | `<lastName>` | JOIN AspNetUsers |
| `UserMarketingProfile.DisplayName` | `<marketingName>` | JOIN AspNetUsers |
| `UserMarketingProfile.MarketingTitle` | `<marketingTitle>`, `<role>` | JOIN AspNetUsers |
| `UserMarketingProfile.LicenseNumberDisplay` | `<marketingLicense>` | JOIN AspNetUsers |
| `AspNetUsers.Email` | `<email>` | Direct |
| `UserMarketingProfile.Phone` | `<mobile>` | Format: XXX.XXX.XXXX |
| `UserMarketingProfile.Website` | `<website>` | Direct |
| `MarketingImage` Type 1 | `<photo>` | Query by UserId + TypeId |
| `MarketingImage` Type 2 | `<personalLogoLight>` | Query by UserId + TypeId |
| `MarketingImage` Type 3 | `<personalLogoDark>` | Query by UserId + TypeId |
| `MarketingImage` Type 4 | `<companyLogoLight>` | Query by UserId + TypeId |
| `MarketingImage` Type 6 | `<companyLogoDark>` | Query by UserId + TypeId |
| `UserMarketingProfile.CompanyName` | `<address><company>` | Direct |
| `UserMarketingProfile.StreetAddress` | `<address><street>` | Direct |
| `UserMarketingProfile.City` | `<address><city>` | Direct |
| `UserMarketingProfile.State` | `<address><state>` | Direct |
| `UserMarketingProfile.Zip` | `<address><zip>` | Direct |

### MlsListing.dbo.Listing → XML Single Data

| Database Field | XML Element | Transformation | Example |
|----------------|-------------|----------------|---------|
| `MlsNumber` | `<mlsNumber>` | Direct | `PLS-2025-00001` |
| `MlsID` | `<mlsId>` | Always `999` | `999` |
| `StatusTypeID` | `<statusTypeID>` | Direct | `6` |
| `StatusType.Name` | `<listingStatus>` | JOIN StatusType | `Private Listing` |
| `OriginalListPrice` | `<price>` | Integer, no formatting | `749000` |
| `Bedrooms` | `<bedrooms count="X"/>` | Attribute format | `count="4"` |
| `BathroomsTotal` | `<bathrooms total="X"/>` | Attribute format | `total="3"` |
| `BathroomsFull` | `<bathrooms full="X"/>` | Attribute format | `full="3"` |
| `BathroomsHalf` | `<bathrooms half="X"/>` | Attribute format | `half="0"` |
| `Sqft` | `<squareFeet>` | Direct integer | `3018` |
| `LotSqft` | `<lotSize>` | Direct integer | `9101` |
| `YearBuilt` | `<built>` | Direct integer | `2022` |
| `Remarks` | `<description>` | CDATA wrapped | `<![CDATA[...]]>` |
| `PhotoPrimaryUrl` | `<photoPrimary>` | Direct HTTPS URL | `https://...` |
| `Latitude` | `<latitude>` | Direct decimal | `29.72229` |
| `Longitude` | `<longitude>` | Direct decimal | `-98.68958` |
| `DisplayAddress` | `<address><street>` | Direct | `10037 Rebecca Place` |
| `StreetNumber` | `<address><streetNumber>` | Direct | `10037` |
| `StreetName` | `<address><streetName>` | Direct | `Rebecca Place` |
| `City` | `<address><city>` | Direct | `Boerne` |
| `State` | `<address><state>` | Direct | `TX` |
| `Zip` | `<address><zip>` | Direct | `78006` |
| `ListDate` | `<listed>` | Format: `MM/DD/YYYY` | `12/30/2025` |
| `ParkingSpaces` | `<parking spaces="X"/>` | Attribute format | `spaces="3"` |
| `GarageSpaces` | `<parking garage="X"/>` | Attribute format | `garage="3"` |

### MlsListing.dbo.Photo → XML Images

| Database Field | XML Element | Transformation |
|----------------|-------------|----------------|
| `PhotoUrl` | `<images><image src="..."/>` | Each photo becomes `<image>` element |
| `DisplayOrder` | Order in `<images>` | Sort by DisplayOrder ASC |

**Query:**
```sql
SELECT PhotoUrl, DisplayOrder
FROM MlsListing.dbo.Photo
WHERE ListingID = @listingId
    AND MlsID = 999
ORDER BY DisplayOrder ASC
```

### Area Data → XML Areas

| Database Table/Field | XML Element | Query/Logic |
|----------------------|-------------|-------------|
| `Area.AreaId` | `<area><id>` | From user selection |
| `Area.AreaName` | `<area><name>` | JOIN Area |
| `Area.CenterLatitude` | `<area><centerLat>` | JOIN Area |
| `Area.CenterLongitude` | `<area><centerLng>` | JOIN Area |

---

## 🔧 IMPLEMENTATION GUIDE

### For PLS Backend Team

**Step 1: Load Collection JSON**
```csharp
// Read collection JSON from S3 or database
var collection = await LoadCollection("pls-social-collection-v1");
```

**Step 2: For Each Asset in Collection**
```csharp
foreach (var section in collection.Sections)
{
    foreach (var asset in section.Assets)
    {
        // Generate XML for this asset
        var xml = BuildXmlForAsset(asset, listing, agent, area);
        
        // POST to GenieCloud
        await PostToGenieCloud(xml, asset.AssetPath);
    }
}
```

**Step 3: Build XML**
```csharp
public string BuildXmlForAsset(
    CollectionAsset asset, 
    PlsListing listing, 
    UserMarketingProfile agent, 
    Area area)
{
    var xml = new XDocument(
        new XElement("renderRoot",
            BuildOutputAttributes(asset, agent),
            BuildDateElement(),
            new XElement("xslAsset", asset.AssetPath),
            BuildAgentXml(agent),
            BuildAreaXml(area),
            BuildListingXml(listing)
        )
    );
    
    return xml.ToString();
}
```

### For GenieCloud Team

**Step 1: Receive XML**
- XML arrives via POST /api/render
- Parse XML structure
- Validate against contract

**Step 2: Render Assets**
- Use `<xslAsset>` to select XSL template
- Apply `<output>` attributes (theme, size, etc.)
- Render using `<single>`, `<agents>`, `<areas>` data

**Step 3: Return Collection URL**
- Generate collection ID
- Store rendered assets in S3
- Return collection URL

---

## ✅ VALIDATION CHECKLIST

### Before Sending XML to GenieCloud

- [ ] All required fields present (per Contract v6.1 Section 7)
- [ ] `statusTypeID` is 6 or 14
- [ ] `bedrooms` uses attribute format: `<bedrooms count="4"/>`
- [ ] `bathrooms` uses attribute format: `<bathrooms total="3" full="3" half="0"/>`
- [ ] `images` uses child elements: `<image src="..."/>`
- [ ] `description` wrapped in CDATA: `<![CDATA[...]]>`
- [ ] All image URLs are HTTPS and accessible
- [ ] Agent logos fetched using correct Marketing Image Type IDs
- [ ] Date format: `MM/DD/YYYY` for `<listed>`
- [ ] Price is integer (no decimals, no formatting)

### After GenieCloud Renders

- [ ] Collection URL returned
- [ ] All assets rendered successfully
- [ ] Landing page accessible
- [ ] Social graphics accessible
- [ ] Images display correctly (no "PICTURE PENDING")
- [ ] Status caption correct ("Private Listing" or "Coming Soon")
- [ ] Agent logos display correctly

---

## 📝 EXAMPLE: COMPLETE XML FOR 10037 REBECCA

```xml
<?xml version="1.0" encoding="UTF-8"?>
<renderRoot>
    <output 
        apiUrl="https://cloud-api.thegenie.ai/"
        siteUrl="https://cloud.thegenie.ai/"
        userId="9f750957-4d66-4151-bd37-9588d17d4fb8"
        theme="compass"
        themeHue="dark"
        size="landing-page"
        renderId="pls-PLS-2025-00001-pls-hollywood"
        version="3.0.0"
        year="2025"
        areaPeriod="12"
        propertyType="0"
        withBleed="false"
        withCrops="false"
        blurPrice="false"
        hideAVM="true"
        requireSignin="false"
        isLeadCapture="false"
    />
    <date period="Dec 2024 to Dec 2025" previousPeriod="Dec 2023 to Dec 2024"/>
    <xslAsset>landing-pages/pls-hollywood</xslAsset>
    
    <agents>
        <agent>
            <firstName>Steve</firstName>
            <lastName>Hundley</lastName>
            <role>Luxury Specialist</role>
            <photo>https://imagedelivery.net/.../public</photo>
            <personalLogoLight>https://imagedelivery.net/.../user_logo_dark</personalLogoLight>
            <personalLogoDark>https://imagedelivery.net/.../user_logo_light</personalLogoDark>
            <companyLogoLight>https://imagedelivery.net/.../company_logo_dark</companyLogoLight>
            <companyLogoDark>https://imagedelivery.net/.../company_logo_light</companyLogoDark>
            <mobile>619.507.4404</mobile>
            <email>steve@inspired.re</email>
            <website>www.Inspired.RE</website>
            <agentId>9f750957-4d66-4151-bd37-9588d17d4fb8</agentId>
            <marketingName>Steve Hundley</marketingName>
            <marketingTitle>Luxury Specialist</marketingTitle>
            <marketingLicense>TREC# 671645</marketingLicense>
            <address>
                <company>Inspired Real Estate, Inc</company>
                <street>123 Main St</street>
                <city>Boerne</city>
                <state>TX</state>
                <zip>78006</zip>
            </address>
        </agent>
    </agents>
    
    <areas>
        <area>
            <id>407559</id>
            <name>Balcones Creek - All Neighborhoods</name>
            <centerLat>29.6547</centerLat>
            <centerLng>-98.4936</centerLng>
            <statistics lookbackMonths="12" propertyType="0"/>
        </area>
    </areas>
    
    <single>
        <mlsNumber>PLS-2025-00001</mlsNumber>
        <mlsId>999</mlsId>
        <price>749000</price>
        <salePrice></salePrice>
        <listed>12/30/2025</listed>
        <soldDate></soldDate>
        <daysOnMarket>0</daysOnMarket>
        <type>Single Family</type>
        <listingStatus>Private Listing</listingStatus>
        <listingAgent>Steve Hundley</listingAgent>
        <statusTypeID>6</statusTypeID>
        <description><![CDATA[Welcome to this stunning 2022-built home in the highly sought-after Balcones Creek community.]]></description>
        <photoPrimary>https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/pls-10037-rebecca-place/photos/front-of-home.jpg</photoPrimary>
        <squareFeet>3018</squareFeet>
        <lotSize>9101</lotSize>
        <acres>0.209</acres>
        <built>2022</built>
        <latitude>29.72229</latitude>
        <longitude>-98.68958</longitude>
        
        <bedrooms count="4"/>
        <bathrooms total="3" full="3" half="0"/>
        <parking spaces="3" garage="3"/>
        
        <address>
            <streetNumber>10037</streetNumber>
            <street>10037 Rebecca Place</street>
            <streetName>Rebecca Place</streetName>
            <city>Boerne</city>
            <state>TX</state>
            <zip>78006</zip>
        </address>
        
        <images>
            <image src="https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/pls-10037-rebecca-place/photos/front-of-home.jpg"/>
            <image src="https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/pls-10037-rebecca-place/photos/kitchen-1.jpg"/>
            <image src="https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/pls-10037-rebecca-place/photos/kitchen-2.jpg"/>
        </images>
    </single>
    
    <mlsDisplay><![CDATA[This is a private listing presented by Inspired Real Estate, Inc. Property information is deemed reliable but not guaranteed.]]></mlsDisplay>
</renderRoot>
```

---

## 🔗 REFERENCE DOCUMENTS

- **Contract:** `CONTRACT_PLS_to_GenieCloud_v6.1.md` Section 4-6
- **XML Spec:** `PLS_XML_GENERATION_SPEC_v1.md`
- **Collection System:** `CONTRACT_PLS_to_GenieCloud_v6.1.md` Section 12-13

---

**Status:** ✅ Mapping Complete - Ready for Implementation

**Next Action:** Both teams review and confirm mapping accuracy.

