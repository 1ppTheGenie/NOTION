# PLS XML Generation Specification

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent  
**Target:** Friday Prototype

---

## 🎯 PURPOSE

Complete specification for generating PLS XML from database listing data, ready for GenieCloud rendering.

---

## 📋 XML STRUCTURE

### Complete XML Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<renderRoot>
    <!-- OUTPUT ATTRIBUTES -->
    <output 
        apiUrl="https://cloud-api.thegenie.ai/"
        siteUrl="https://cloud.thegenie.ai/"
        userId="{asp-user-id}"
        theme="{theme-name}"
        themeHue="dark"
        size="landing-page"
        renderId="pls-{pls-number}"
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
    
    <!-- DATE PERIOD -->
    <date period="Dec 2024 to Dec 2025" previousPeriod="Dec 2023 to Dec 2024"/>
    
    <!-- XSL ASSET -->
    <xslAsset>landing-pages/pls-hollywood</xslAsset>
    
    <!-- AGENT DATA -->
    <agents>
        <agent>
            <firstName>{firstName}</firstName>
            <lastName>{lastName}</lastName>
            <role>{marketingTitle}</role>
            <photo>{profilePhotoUrl}</photo>
            <personalLogoLight>{personalLogoDarkUrl}</personalLogoLight>
            <personalLogoDark>{personalLogoLightUrl}</personalLogoDark>
            <companyLogoLight>{companyLogoDarkUrl}</companyLogoLight>
            <companyLogoDark>{companyLogoLightUrl}</companyLogoDark>
            <mobile>{phone}</mobile>
            <email>{email}</email>
            <website>{website}</website>
            <agentId>{aspUserId}</agentId>
            <marketingName>{displayName}</marketingName>
            <marketingTitle>{marketingTitle}</marketingTitle>
            <marketingLicense>{licenseNumber}</marketingLicense>
            <address>
                <company>{companyName}</company>
                <street>{streetAddress}</street>
                <city>{city}</city>
                <state>{state}</state>
                <zip>{zip}</zip>
            </address>
        </agent>
    </agents>
    
    <!-- AREA DATA -->
    <areas>
        <area>
            <id>{areaId}</id>
            <name>{areaName}</name>
            <centerLat>{centerLat}</centerLat>
            <centerLng>{centerLng}</centerLng>
            <statistics lookbackMonths="12" propertyType="0"/>
        </area>
    </areas>
    
    <!-- SINGLE LISTING DATA -->
    <single>
        <mlsNumber>{plsNumber}</mlsNumber>
        <mlsId>999</mlsId>
        <price>{listPrice}</price>
        <salePrice></salePrice>
        <listed>{listDate}</listed>
        <soldDate></soldDate>
        <daysOnMarket>0</daysOnMarket>
        <type>{propertyType}</type>
        <listingStatus>{statusName}</listingStatus>
        <listingAgent>{agentName}</listingAgent>
        <statusTypeID>{statusTypeId}</statusTypeID>
        <description><![CDATA[{description}]]></description>
        <photoPrimary>{primaryPhotoUrl}</photoPrimary>
        <squareFeet>{sqft}</squareFeet>
        <lotSize>{lotSqft}</lotSize>
        <acres>{acres}</acres>
        <built>{yearBuilt}</built>
        <latitude>{latitude}</latitude>
        <longitude>{longitude}</longitude>
        
        <bedrooms count="{bedrooms}"/>
        <bathrooms total="{bathroomsTotal}" full="{bathroomsFull}" half="{bathroomsHalf}"/>
        <parking spaces="{parkingSpaces}" garage="{garageSpaces}"/>
        
        <address>
            <streetNumber>{streetNumber}</streetNumber>
            <street>{displayAddress}</street>
            <streetName>{streetName}</streetName>
            <city>{city}</city>
            <state>{state}</state>
            <zip>{zip}</zip>
        </address>
        
        <images>
            <image src="{photo1Url}"/>
            <image src="{photo2Url}"/>
            <image src="{photo3Url}"/>
        </images>
    </single>
    
    <!-- MLS DISPLAY -->
    <mlsDisplay><![CDATA[This is a private listing presented by {companyName}. Property information is deemed reliable but not guaranteed.]]></mlsDisplay>
</renderRoot>
```

---

## 🔄 DATA MAPPING

### Listing Data → XML

| Database Field | XML Element | Transformation Logic |
|----------------|-------------|---------------------|
| `MlsNumber` | `<mlsNumber>` | Direct (e.g., "PLS-2025-00001") |
| `MlsID` | `<mlsId>` | Always `999` for PLS |
| `StatusTypeID` | `<statusTypeID>` | Direct (6 or 14) |
| `StatusType.Name` | `<listingStatus>` | Direct ("Private Listing" or "Coming Soon") |
| `OriginalListPrice` | `<price>` | Integer, no formatting (e.g., `749000`) |
| `Bedrooms` | `<bedrooms count="X"/>` | Attribute format |
| `BathroomsTotal` | `<bathrooms total="X" full="Y" half="Z"/>` | Split into attributes |
| `BathroomsFull` | `<bathrooms full="Y"/>` | Part of bathrooms element |
| `BathroomsHalf` | `<bathrooms half="Z"/>` | Part of bathrooms element |
| `Sqft` | `<squareFeet>` | Direct integer |
| `LotSqft` | `<lotSize>` | Direct integer |
| `YearBuilt` | `<built>` | Direct integer |
| `Remarks` | `<description>` | CDATA wrapped |
| `PhotoPrimaryUrl` | `<photoPrimary>` | Direct HTTPS URL |
| `Latitude` | `<latitude>` | Direct decimal |
| `Longitude` | `<longitude>` | Direct decimal |
| `DisplayAddress` | `<address><street>` | Direct |
| `StreetNumber` | `<address><streetNumber>` | Direct |
| `StreetName` | `<address><streetName>` | Direct |
| `City` | `<address><city>` | Direct |
| `State` | `<address><state>` | Direct |
| `Zip` | `<address><zip>` | Direct |
| `ListDate` | `<listed>` | Format: `MM/DD/YYYY` |

### Photo Data → XML

| Database Field | XML Element | Transformation Logic |
|----------------|-------------|---------------------|
| `Photo.PhotoUrl` | `<images><image src="..."/>` | Each photo becomes `<image>` element |
| `Photo.DisplayOrder` | Order in `<images>` | Sort by DisplayOrder |

**Query:**
```sql
SELECT PhotoUrl, DisplayOrder
FROM MlsListing.dbo.Photo
WHERE ListingID = @listingId
    AND MlsID = 999
ORDER BY DisplayOrder
```

### Agent Data → XML

| Source Table/Field | XML Element | Transformation Logic |
|-------------------|-------------|---------------------|
| `AspNetUserProfiles.FirstName` | `<firstName>` | Direct |
| `AspNetUserProfiles.LastName` | `<lastName>` | Direct |
| `UserMarketingProfile.DisplayName` | `<marketingName>` | Direct |
| `UserMarketingProfile.MarketingTitle` | `<marketingTitle>` | Direct |
| `UserMarketingProfile.LicenseNumberDisplay` | `<marketingLicense>` | Direct |
| `AspNetUsers.Email` | `<email>` | Direct |
| `UserMarketingProfile.Phone` | `<mobile>` | Format: `XXX.XXX.XXXX` |
| `UserMarketingProfile.Website` | `<website>` | Direct |
| `AspNetUsers.Id` | `<agentId>` | Direct (UUID) |
| Marketing Image Type 1 | `<photo>` | Profile photo URL |
| Marketing Image Type 2 | `<personalLogoLight>` | Actually dark logo |
| Marketing Image Type 3 | `<personalLogoDark>` | Actually light logo |
| Marketing Image Type 4 | `<companyLogoLight>` | Actually dark logo |
| Marketing Image Type 6 | `<companyLogoDark>` | Actually light logo |

**Query:**
```sql
SELECT 
    up.FirstName,
    up.LastName,
    ump.DisplayName,
    ump.MarketingTitle,
    ump.LicenseNumberDisplay,
    u.Email,
    ump.Phone,
    ump.Website,
    u.Id AS AspNetUserId
FROM FarmGenie.dbo.AspNetUsers u
INNER JOIN FarmGenie.dbo.AspNetUserProfiles up ON up.AspNetUserId = u.Id
LEFT JOIN FarmGenie.dbo.UserMarketingProfile ump ON ump.AspNetUserId = u.Id
WHERE u.Id = @userId
```

### Area Data → XML

| Source Table/Field | XML Element | Transformation Logic |
|-------------------|-------------|---------------------|
| `Area.AreaId` | `<area><id>` | Direct |
| `Area.AreaName` | `<area><name>` | Direct |
| `Area.CenterLatitude` | `<area><centerLat>` | Direct |
| `Area.CenterLongitude` | `<area><centerLng>` | Direct |

---

## 💻 CODE IMPLEMENTATION

### C# XML Generation Function

```csharp
using System.Xml.Linq;

public class PlsXmlGenerator
{
    public string GenerateXml(PlsListing listing, UserMarketingProfile agent, Area area, List<Photo> photos)
    {
        var xml = new XDocument(
            new XElement("renderRoot",
                // Output attributes
                new XElement("output",
                    new XAttribute("apiUrl", "https://cloud-api.thegenie.ai/"),
                    new XAttribute("siteUrl", "https://cloud.thegenie.ai/"),
                    new XAttribute("userId", agent.AspNetUserId),
                    new XAttribute("theme", agent.Theme ?? "compass"),
                    new XAttribute("themeHue", "dark"),
                    new XAttribute("size", "landing-page"),
                    new XAttribute("renderId", $"pls-{listing.MlsNumber}"),
                    new XAttribute("version", "3.0.0"),
                    new XAttribute("year", DateTime.Now.Year.ToString()),
                    new XAttribute("areaPeriod", "12"),
                    new XAttribute("propertyType", "0"),
                    new XAttribute("withBleed", "false"),
                    new XAttribute("withCrops", "false"),
                    new XAttribute("blurPrice", "false"),
                    new XAttribute("hideAVM", "true"),
                    new XAttribute("requireSignin", "false"),
                    new XAttribute("isLeadCapture", "false")
                ),
                
                // Date period
                new XElement("date",
                    new XAttribute("period", $"{DateTime.Now.AddMonths(-12):MMM yyyy} to {DateTime.Now:MMM yyyy}"),
                    new XAttribute("previousPeriod", $"{DateTime.Now.AddMonths(-24):MMM yyyy} to {DateTime.Now.AddMonths(-12):MMM yyyy}")
                ),
                
                // XSL Asset
                new XElement("xslAsset", "landing-pages/pls-hollywood"),
                
                // Agent data
                BuildAgentXml(agent),
                
                // Area data
                BuildAreaXml(area),
                
                // Listing data
                BuildListingXml(listing, photos)
            )
        );
        
        return xml.ToString();
    }
    
    private XElement BuildAgentXml(UserMarketingProfile agent)
    {
        return new XElement("agents",
            new XElement("agent",
                new XElement("firstName", agent.FirstName ?? ""),
                new XElement("lastName", agent.LastName ?? ""),
                new XElement("role", agent.MarketingTitle ?? ""),
                new XElement("photo", GetMarketingImage(agent.AspNetUserId, 1) ?? ""),
                new XElement("personalLogoLight", GetMarketingImage(agent.AspNetUserId, 2) ?? ""),
                new XElement("personalLogoDark", GetMarketingImage(agent.AspNetUserId, 3) ?? ""),
                new XElement("companyLogoLight", GetMarketingImage(agent.AspNetUserId, 4) ?? ""),
                new XElement("companyLogoDark", GetMarketingImage(agent.AspNetUserId, 6) ?? ""),
                new XElement("mobile", FormatPhone(agent.Phone) ?? ""),
                new XElement("email", agent.Email ?? ""),
                new XElement("website", agent.Website ?? ""),
                new XElement("agentId", agent.AspNetUserId),
                new XElement("marketingName", agent.DisplayName ?? ""),
                new XElement("marketingTitle", agent.MarketingTitle ?? ""),
                new XElement("marketingLicense", agent.LicenseNumberDisplay ?? ""),
                new XElement("address",
                    new XElement("company", agent.CompanyName ?? ""),
                    new XElement("street", agent.StreetAddress ?? ""),
                    new XElement("city", agent.City ?? ""),
                    new XElement("state", agent.State ?? ""),
                    new XElement("zip", agent.Zip ?? "")
                )
            )
        );
    }
    
    private XElement BuildAreaXml(Area area)
    {
        return new XElement("areas",
            new XElement("area",
                new XElement("id", area.AreaId),
                new XElement("name", area.AreaName ?? ""),
                new XElement("centerLat", area.CenterLatitude ?? ""),
                new XElement("centerLng", area.CenterLongitude ?? ""),
                new XElement("statistics",
                    new XAttribute("lookbackMonths", "12"),
                    new XAttribute("propertyType", "0")
                )
            )
        );
    }
    
    private XElement BuildListingXml(PlsListing listing, List<Photo> photos)
    {
        var statusName = listing.StatusTypeID == 6 ? "Private Listing" : "Coming Soon";
        
        return new XElement("single",
            new XElement("mlsNumber", listing.MlsNumber),
            new XElement("mlsId", "999"),
            new XElement("price", listing.OriginalListPrice),
            new XElement("salePrice", ""),
            new XElement("listed", listing.ListDate?.ToString("MM/dd/yyyy") ?? ""),
            new XElement("soldDate", ""),
            new XElement("daysOnMarket", "0"),
            new XElement("type", listing.PropertyType ?? "Single Family"),
            new XElement("listingStatus", statusName),
            new XElement("listingAgent", listing.ListingAgentName ?? ""),
            new XElement("statusTypeID", listing.StatusTypeID),
            new XElement("description", new XCData(listing.Remarks ?? "")),
            new XElement("photoPrimary", listing.PhotoPrimaryUrl ?? ""),
            new XElement("squareFeet", listing.Sqft ?? 0),
            new XElement("lotSize", listing.LotSqft ?? 0),
            new XElement("acres", CalculateAcres(listing.LotSqft)),
            new XElement("built", listing.YearBuilt ?? 0),
            new XElement("latitude", listing.Latitude ?? 0),
            new XElement("longitude", listing.Longitude ?? 0),
            
            // Bedrooms (attribute format)
            new XElement("bedrooms",
                new XAttribute("count", listing.Bedrooms ?? 0)
            ),
            
            // Bathrooms (attribute format)
            new XElement("bathrooms",
                new XAttribute("total", listing.BathroomsTotal ?? 0),
                new XAttribute("full", listing.BathroomsFull ?? 0),
                new XAttribute("half", listing.BathroomsHalf ?? 0)
            ),
            
            // Parking (attribute format)
            new XElement("parking",
                new XAttribute("spaces", listing.ParkingSpaces ?? 0),
                new XAttribute("garage", listing.GarageSpaces ?? 0)
            ),
            
            // Address
            new XElement("address",
                new XElement("streetNumber", listing.StreetNumber ?? ""),
                new XElement("street", listing.DisplayAddress ?? ""),
                new XElement("streetName", listing.StreetName ?? ""),
                new XElement("city", listing.City ?? ""),
                new XElement("state", listing.State ?? ""),
                new XElement("zip", listing.Zip ?? "")
            ),
            
            // Images (child elements)
            new XElement("images",
                photos.OrderBy(p => p.DisplayOrder).Select(p =>
                    new XElement("image",
                        new XAttribute("src", p.PhotoUrl)
                    )
                )
            )
        );
    }
    
    private string GetMarketingImage(string userId, int imageTypeId)
    {
        // Query MarketingImage table
        // Return HTTPS URL or empty string
        return ""; // Implement based on your MarketingImage table structure
    }
    
    private string FormatPhone(string phone)
    {
        // Format: XXX.XXX.XXXX
        if (string.IsNullOrEmpty(phone)) return "";
        var digits = new string(phone.Where(char.IsDigit).ToArray());
        if (digits.Length == 10)
            return $"{digits.Substring(0, 3)}.{digits.Substring(3, 3)}.{digits.Substring(6, 4)}";
        return phone;
    }
    
    private decimal CalculateAcres(int? lotSqft)
    {
        if (!lotSqft.HasValue) return 0;
        return Math.Round((decimal)lotSqft.Value / 43560, 3);
    }
}
```

---

## ✅ VALIDATION RULES

### Required Fields

| XML Element | Required | Error if Missing |
|-------------|:--------:|------------------|
| `<mlsNumber>` | ✅ | "MLS number is required" |
| `<mlsId>` | ✅ | Always 999 |
| `<statusTypeID>` | ✅ | Must be 6 or 14 |
| `<price>` | ✅ | Must be > 0 |
| `<bedrooms>` | ✅ | Must have `count` attribute |
| `<bathrooms>` | ✅ | Must have `total`, `full`, `half` attributes |
| `<squareFeet>` | ✅ | Must be > 0 |
| `<address>/*` | ✅ | All address sub-elements required |
| `<photoPrimary>` | ✅ | Valid HTTPS URL |
| `<images><image>` | ✅ | At least 1 image |

### Format Validation

| Field | Format | Validation |
|-------|--------|------------|
| `price` | Integer | No decimals, no formatting |
| `bedrooms` | Attribute | `<bedrooms count="4"/>` NOT `<bedrooms>4</bedrooms>` |
| `bathrooms` | Attributes | `<bathrooms total="3" full="3" half="0"/>` |
| `images` | Child elements | `<image src="..."/>` NOT just URLs |
| `description` | CDATA | Wrap in `<![CDATA[...]]>` |

---

## 🧪 TEST XML

### Sample Complete XML

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
        renderId="pls-PLS-2025-00001"
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
            <personalLogoLight></personalLogoLight>
            <personalLogoDark></personalLogoDark>
            <companyLogoLight></companyLogoLight>
            <companyLogoDark></companyLogoDark>
            <mobile>619.507.4404</mobile>
            <email>steve@inspired.re</email>
            <website>www.Inspired.RE</website>
            <agentId>9f750957-4d66-4151-bd37-9588d17d4fb8</agentId>
            <marketingName>Steve Hundley</marketingName>
            <marketingTitle>Luxury Specialist</marketingTitle>
            <marketingLicense>TREC# 671645</marketingLicense>
            <address>
                <company>Inspired Real Estate</company>
                <street></street>
                <city>San Antonio</city>
                <state>TX</state>
                <zip>78254</zip>
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
        <photoPrimary>https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/front-of-home.jpg</photoPrimary>
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
            <image src="https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/front-of-home.jpg"/>
            <image src="https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/kitchen-1.jpg"/>
            <image src="https://genie-cloud-stage.s3.us-west-1.amazonaws.com/genie-pages/10037-rebecca-coming-soon/photos/kitchen-2.jpg"/>
        </images>
    </single>
    
    <mlsDisplay><![CDATA[This is a private listing presented by Inspired Real Estate. Property information is deemed reliable but not guaranteed.]]></mlsDisplay>
</renderRoot>
```

---

## 🔗 INTEGRATION WITH GENIECLOUD

### API Call

```http
POST https://cloud-api.thegenie.ai/api/render
Content-Type: application/json

{
    "userId": "9f750957-4d66-4151-bd37-9588d17d4fb8",
    "listingId": "pls-PLS-2025-00001",
    "assets": [
        "landing-pages/pls-hollywood",
        "social-marketing-graphics/lc-prop-post-03",
        "social-marketing-graphics/lc-prop-post-01-vip"
    ],
    "theme": "compass",
    "themeHue": "dark",
    "xml": "<renderRoot>...</renderRoot>"
}
```

---

**Status:** ✅ Specification Complete - Ready for Implementation!



