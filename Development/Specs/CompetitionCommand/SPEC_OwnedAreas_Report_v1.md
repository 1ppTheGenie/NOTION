# Genie Owned Areas Report Specification
## Version 1.0 | December 2025

---

## 1. Report Overview

### Purpose
The Owned Areas Report provides a comprehensive inventory of all areas (zip codes) owned by Genie customers for the Competition Command (FarmCast) service. This report tracks ownership history, including start/end dates, and supports auditing area assignments and billing.

### Report Naming Convention
```
Genie_OwnedAreas_[YYYY-MM-DD]_v[#].csv
```
Example: `Genie_OwnedAreas_2025-12-10_v1.csv`

### Key Business Rules

| Rule | Description |
|------|-------------|
| **Hard Deletes** | UserOwnedArea records are HARD-DELETED when ownership ends - there is NO EndDate column |
| **End Date Inference** | OwnershipEndDate must be INFERRED from the last Competition Command campaign date |
| **Multiple Property Types** | Same AreaId can have multiple rows (SFR, Condo) for the same customer |
| **Competition Command Only** | This report covers Competition Command (FarmCast) areas only (AreaOwnershipTypeId = 1) |
| **Area Name Priority** | PolygonNameOverride.FriendlyName > ViewArea.Name > Zip Code |

---

## 2. Report Structure

### Output Format
- **File Type:** CSV (Google Sheets compatible)
- **Encoding:** UTF-8
- **Delimiter:** Comma

### Column Order (12 columns)

| # | Column Name | Data Type | Description |
|---|-------------|-----------|-------------|
| 1 | UserOwnedAreaId | Integer/NULL | Primary key (NULL if ownership ended) |
| 2 | AreaId | Integer | Unique area identifier |
| 3 | Area_Name | String | Resolved area name (FriendlyName or Zip) |
| 4 | Customer_Name | String | "FirstName LastName" |
| 5 | UserName | String | Login username |
| 6 | Email | String | Customer email |
| 7 | Property_Type | String | SFR, Condo, Townhouse, Multi-Family |
| 8 | Ownership_Start | DateTime | When area was purchased |
| 9 | Ownership_End | DateTime/NULL | When area was canceled (inferred) |
| 10 | Last_Campaign | DateTime/NULL | Most recent Competition Command campaign |
| 11 | Total_Campaigns | Integer | Total CC campaigns for this area |
| 12 | Status | String | Active, Ended |

---

## 3. Sample Data (5 Rows per Scenario)

### Active Ownership (Status = "Active")

```csv
UserOwnedAreaId,AreaId,Area_Name,Customer_Name,UserName,Email,Property_Type,Ownership_Start,Ownership_End,Last_Campaign,Total_Campaigns,Status
164,9602,Oakland 94602,David Higgins,DHiggins,david@cushrealestate.com,SFR,11-18-2024,,11-08-2025,151,Active
165,9602,Oakland 94602,David Higgins,DHiggins,david@cushrealestate.com,Condo,11-18-2024,,11-08-2025,151,Active
166,9610,Piedmont 94611,David Higgins,DHiggins,david@cushrealestate.com,SFR,11-18-2024,,11-11-2025,108,Active
153,8733,Thousand Oaks 91360,Debbie Gates,DebbieGates,homeswithdebbie@yahoo.com,SFR,10-02-2024,,11-08-2025,104,Active
156,9177,Moorpark 93021,Debbie Gates,DebbieGates,homeswithdebbie@yahoo.com,SFR,10-02-2024,,11-10-2025,107,Active
```

### Ended Ownership (Status = "Ended")

```csv
UserOwnedAreaId,AreaId,Area_Name,Customer_Name,UserName,Email,Property_Type,Ownership_Start,Ownership_End,Last_Campaign,Total_Campaigns,Status
,8913,San Carlos 92128,Summer Toth,SummerToth,summerraetoth@gmail.com,,,08-31-2025,08-31-2025,16,Ended
,9170,Ventura 93003,Summer Toth,SummerToth,summerraetoth@gmail.com,,,09-28-2025,09-28-2025,20,Ended
,8544,Brentwood 90049,Gary Gold,garygold,gary@soldbygold.net,,,01-05-2025,01-05-2025,25,Ended
,8905,San Carlos 92119,Angel Flores,AFlores1,sthorne0710@gmail.com,,,01-21-2025,01-21-2025,60,Ended
,8706,Agoura Hills 91301,Kim Ewing,Kewing66,theprimakimteam@gmail.com,,,09-21-2024,09-21-2024,2,Ended
```

**Date Format Standard:** `mm-dd-yyyy` (e.g., 11-18-2024)

---

## 4. Data Sources

### Primary Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `UserOwnedArea` | Current area ownership records | UserOwnedAreaId, AspNetUserId, AreaId, PropertyTypeId, AreaOwnershipTypeId, CreateDate |
| `AspNetUsers` | User accounts | Id, UserName, Email |
| `AspNetUserProfiles` | User display names | AspNetUserId, FirstName, LastName |
| `PolygonNameOverride` | Custom area names per user | PolygonId, AspNetUserId, FriendlyName |
| `ViewArea` | Default area names | AreaId, Name |
| `AreaOwnershipType` | Ownership type lookup | AreaOwnershipTypeId, Name |
| `PropertyCollectionDetail` | Campaign history | PropertyCollectionDetailId, AspNetUserId, AreaId, CreateDate |
| `PropertyCastWorkflowQueue` | Campaign-to-PropertyCast link | CollectionId, PropertyCastId |
| `PropertyCast` | Campaign type filter | PropertyCastId, PopertyCastTriggerTypeId |

### Key Enumerations

#### PropertyTypeId (No Lookup Table - Enum in Code)
| Value | Name |
|-------|------|
| 0 | SFR |
| 1 | Condo |
| 2 | Townhouse |
| 3 | Multi-Family |

#### AreaOwnershipTypeId
| Value | Name | Description |
|-------|------|-------------|
| 1 | FarmCaster | Competition Command service |

#### PopertyCastTriggerTypeId (Filter for Competition Command)
| Value | Name |
|-------|------|
| 1 | ListingSold (Competition Command) |
| 2 | ListingNew (Listing Command) |

---

## 5. Source Code Reference

### UserOwnedArea Entity Model
**File:** `Smart.PropertyCast.Data\PropertyCast\SQL\Models\UserOwnedArea.cs`

```csharp
[Table("UserOwnedArea")]
[Index("AspNetUserId", "AreaId", "PropertyTypeId", "AreaOwnershipTypeId", 
       Name = "IX_UOA_UniqueOnwer", IsUnique = true)]
public partial class UserOwnedArea
{
    [Key]
    public int UserOwnedAreaId { get; set; }
    
    [Required]
    [StringLength(128)]
    public string AspNetUserId { get; set; }
    
    public int AreaId { get; set; }
    public int PropertyTypeId { get; set; }
    public int AreaOwnershipTypeId { get; set; }
    
    [Column(TypeName = "datetime")]
    public DateTime CreateDate { get; set; }
}
```

### Unique Constraint
- **Index:** `IX_UOA_UniqueOnwer`
- **Columns:** AspNetUserId + AreaId + PropertyTypeId + AreaOwnershipTypeId
- **Rule:** One customer cannot have duplicate entries for the same Area + PropertyType + OwnershipType

---

## 6. Column Definitions & Business Logic

### 6.1 UserOwnedAreaId
- **Source:** `UserOwnedArea.UserOwnedAreaId`
- **Value for Ended Ownership:** NULL (record was hard-deleted)

### 6.2 AreaId
- **Source:** `UserOwnedArea.AreaId` OR `PropertyCollectionDetail.AreaId` (for ended ownership)
- **Type:** Integer, always populated

### 6.3 Area_Name
- **Resolution Priority:**
```
1. PolygonNameOverride.FriendlyName (user-specific override)
2. ViewArea.Name (system default)
3. Raw AreaId as fallback (should never happen)
```
- **Format Examples:**
  - `Moorpark 93021`
  - `Piedmont 94611`
  - `Manhattan Beach - 90266`
  - `West Hollywood | 90069` → normalize to `West Hollywood 90069`

**SQL Logic:**
```sql
COALESCE(pno.FriendlyName, va.Name) AS Area_Name
```

### 6.4 Customer_Name
- **Source:** `AspNetUserProfiles.FirstName` + ' ' + `AspNetUserProfiles.LastName`
- **Fallback:** `AspNetUsers.UserName` if profile name is empty

### 6.5 UserName
- **Source:** `AspNetUsers.UserName`

### 6.6 Email
- **Source:** `AspNetUsers.Email`

### 6.7 Property_Type
- **Source:** `UserOwnedArea.PropertyTypeId` mapped to enum name
- **For Ended Ownership:** NULL (record deleted, type unknown)

**Mapping:**
```sql
CASE PropertyTypeId
    WHEN 0 THEN 'SFR'
    WHEN 1 THEN 'Condo'
    WHEN 2 THEN 'Townhouse'
    WHEN 3 THEN 'Multi-Family'
    ELSE NULL
END
```

### 6.8 Ownership_Start
- **Source:** `UserOwnedArea.CreateDate`
- **For Ended Ownership:** NULL (record deleted, unknown)

### 6.9 Ownership_End (INFERRED)
- **CRITICAL:** This field does NOT exist in the database
- **Logic:**
```
IF UserOwnedArea record exists:
    Ownership_End = NULL (still active)
ELSE IF Campaigns exist but no UserOwnedArea:
    Ownership_End = Last_Campaign date (inferred from campaign activity)
```

**Reasoning:** When a customer cancels an area, the UserOwnedArea record is hard-deleted. The only way to know they ever owned the area is through historical campaign data.

### 6.10 Last_Campaign
- **Source:** `MAX(PropertyCollectionDetail.CreateDate)` filtered by Competition Command
- **Filter:** Only count campaigns where `PropertyCast.PropertyCastTypeId = 1  -- FarmCast = Competition Command (includes BOTH ListingSold and ListingNew triggers)`
- **Value:** NULL if no campaigns ever run

### 6.11 Total_Campaigns
- **Source:** `COUNT(*)` of Competition Command campaigns
- **Filter:** `PropertyCast.PropertyCastTypeId = 1  -- FarmCast = Competition Command (includes BOTH ListingSold and ListingNew triggers)`

### 6.12 Status
- **Derived Field:**
```
IF UserOwnedAreaId IS NOT NULL:
    Status = 'Active'
ELSE IF Last_Campaign IS NOT NULL:
    Status = 'Ended'
ELSE:
    Status = 'Unknown'
```

---

## 7. SQL Query Pattern

### Full Query with All Logic

```sql
WITH 
-- Current ownership records
CurrentOwnership AS (
    SELECT 
        uoa.UserOwnedAreaId,
        uoa.AspNetUserId,
        uoa.AreaId,
        uoa.CreateDate AS OwnershipStartDate,
        uoa.PropertyTypeId,
        uoa.AreaOwnershipTypeId
    FROM dbo.UserOwnedArea uoa WITH (NOLOCK)
),

-- Last Campaign Dates (Competition Command Only)
LastCampaignDates AS (
    SELECT 
        pcd.AspNetUserId,
        pcd.AreaId,
        MAX(pcd.CreateDate) AS LastCampaignDate,
        COUNT(*) AS TotalCampaigns
    FROM dbo.PropertyCollectionDetail pcd WITH (NOLOCK)
    INNER JOIN dbo.PropertyCastWorkflowQueue pcwq WITH (NOLOCK)
        ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
    INNER JOIN dbo.PropertyCast pc WITH (NOLOCK)
        ON pc.PropertyCastId = pcwq.PropertyCastId
    WHERE pcd.AreaId IS NOT NULL
        AND pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command (includes BOTH ListingSold and ListingNew triggers)  -- Competition Command ONLY
    GROUP BY pcd.AspNetUserId, pcd.AreaId
),

-- Historical ownership (areas with campaigns but no current record)
HistoricalOwnership AS (
    SELECT DISTINCT
        pcd.AspNetUserId,
        pcd.AreaId
    FROM dbo.PropertyCollectionDetail pcd WITH (NOLOCK)
    INNER JOIN dbo.PropertyCastWorkflowQueue pcwq WITH (NOLOCK)
        ON pcwq.CollectionId = pcd.PropertyCollectionDetailId
    INNER JOIN dbo.PropertyCast pc WITH (NOLOCK)
        ON pc.PropertyCastId = pcwq.PropertyCastId
    WHERE pcd.AreaId IS NOT NULL
        AND pc.PropertyCastTypeId = 1  -- FarmCast = Competition Command (includes BOTH ListingSold and ListingNew triggers)
        AND NOT EXISTS (
            SELECT 1 FROM CurrentOwnership co
            WHERE co.AspNetUserId = pcd.AspNetUserId
              AND co.AreaId = pcd.AreaId
        )
)

-- Final output
SELECT 
    co.UserOwnedAreaId,
    COALESCE(co.AreaId, ho.AreaId) AS AreaId,
    COALESCE(pno.FriendlyName, va.Name) AS Area_Name,
    COALESCE(up.FirstName + ' ' + up.LastName, u.UserName) AS Customer_Name,
    u.UserName,
    u.Email,
    CASE co.PropertyTypeId
        WHEN 0 THEN 'SFR'
        WHEN 1 THEN 'Condo'
        WHEN 2 THEN 'Townhouse'
        WHEN 3 THEN 'Multi-Family'
        ELSE NULL
    END AS Property_Type,
    co.OwnershipStartDate AS Ownership_Start,
    CASE 
        WHEN co.UserOwnedAreaId IS NOT NULL THEN NULL
        ELSE lcd.LastCampaignDate
    END AS Ownership_End,
    lcd.LastCampaignDate AS Last_Campaign,
    ISNULL(lcd.TotalCampaigns, 0) AS Total_Campaigns,
    CASE 
        WHEN co.UserOwnedAreaId IS NOT NULL THEN 'Active'
        WHEN lcd.LastCampaignDate IS NOT NULL THEN 'Ended'
        ELSE 'Unknown'
    END AS Status
FROM CurrentOwnership co
FULL OUTER JOIN HistoricalOwnership ho 
    ON ho.AspNetUserId = co.AspNetUserId AND ho.AreaId = co.AreaId
LEFT JOIN LastCampaignDates lcd 
    ON lcd.AspNetUserId = COALESCE(co.AspNetUserId, ho.AspNetUserId)
    AND lcd.AreaId = COALESCE(co.AreaId, ho.AreaId)
LEFT JOIN dbo.AspNetUsers u WITH (NOLOCK) 
    ON u.Id = COALESCE(co.AspNetUserId, ho.AspNetUserId)
LEFT JOIN dbo.AspNetUserProfiles up WITH (NOLOCK)
    ON up.AspNetUserId = COALESCE(co.AspNetUserId, ho.AspNetUserId)
LEFT JOIN dbo.ViewArea va WITH (NOLOCK) 
    ON va.AreaId = COALESCE(co.AreaId, ho.AreaId)
LEFT JOIN dbo.PolygonNameOverride pno WITH (NOLOCK) 
    ON pno.PolygonId = COALESCE(co.AreaId, ho.AreaId) 
    AND pno.AspNetUserId = COALESCE(co.AspNetUserId, ho.AspNetUserId)
ORDER BY Customer_Name, Area_Name, Property_Type;
```

---

## 8. Customer Summary (From Current Data)

### Active Customers with Most Areas

| Customer | Areas Owned | Property Types |
|----------|-------------|----------------|
| Justin Tye | 8 | SFR + Condo |
| David Higgins | 4 | SFR + Condo |
| Javier Mendez | 2 | SFR + Condo |
| Debbie Gates | 3 | SFR only |
| Ed Kaminsky | 2 | SFR + Condo |

### Ended Ownership Examples

| Customer | Area | Last Campaign | Total Campaigns |
|----------|------|---------------|-----------------|
| Summer Toth | 92128 San Carlos | 2025-08-31 | 16 |
| Summer Toth | 93003 Ventura | 2025-09-28 | 20 |
| Gary Gold | 90049 Brentwood | 2025-01-05 | 25 |
| Angel Flores | 92119 Del Cerro | 2025-01-16 | 71 |
| Kim Ewing | 91301 Agoura Hills | 2024-09-21 | 2 |

---

## 9. Iteration 2 Preview: PropertyCast Status

**Next Phase:** Add PropertyCast configuration status to determine:
1. Is area actively casting? (PropertyCast.IsActive)
2. What triggers are enabled? (ListingSold Status: Active, Pending, Sold)
3. Last cast date vs. area ownership date

**Expected Additional Columns:**
| Column | Description |
|--------|-------------|
| Cast_Status | Active/Paused/Stopped |
| SFR_Active_Trigger | Yes/No |
| SFR_Pending_Trigger | Yes/No |
| SFR_Sold_Trigger | Yes/No |
| Condo_Active_Trigger | Yes/No |
| Condo_Pending_Trigger | Yes/No |
| Condo_Sold_Trigger | Yes/No |
| Last_Cast_Date | Most recent actual cast |

---

## 10. Data Validation Rules

### Required Fields
- AreaId: Must always have a value
- Customer_Name: Fallback to UserName if profile empty
- Status: Must be "Active" or "Ended"

### Business Logic Checks
- Active status should have UserOwnedAreaId (not NULL)
- Ended status should have NULL UserOwnedAreaId but valid Last_Campaign
- Total_Campaigns should be >= 0
- If Ownership_End is set, Status must be "Ended"

### Data Quality Flags
- Flag areas with 0 Total_Campaigns (purchased but never used)
- Flag areas with no campaigns in 90+ days (may need follow-up)
- Flag ended areas with high campaign counts (high-value churned customers)

---

## 11. File Locations

### Source Files Used for This Spec
```
C:\Cursor\drive-download_v1\AllOwnedAreas_WithEndDate_LastCampaign.csv
C:\Cursor\drive-download_v1\AllOwnedAreas_WithEndDate_LastCampaign.sql
C:\Cursor\drive-download_v1\AllOwnedAreas_FullHistory.csv
C:\Cursor\drive-download_v1\AllOwnedAreas_FullHistory.sql
C:\Cursor\Genie.Source.Code_v1\...\UserOwnedArea.cs
```

### Output Location
```
C:\Cursor\Twilio-20251209T200757Z-3-001\Twilio\REPORTS\Genie_OwnedAreas_[DATE]_v[#].csv
```

---

## 12. Approval & Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Report Author | | | |
| Data Validation | | | |
| Business Owner | | | |

---

*Document Version: 1.0*
*Last Updated: December 10, 2025*
*Source Data Date: November 11, 2025*

