# RESO Credentials Access Summary

**Version:** 1.0  
**Created:** 12/30/2025  
**Last Updated:** 12/30/2025  
**Author:** Cursor AI Agent

---

## The Problem

**RESO API credentials for MLS ID 2 (EBRDI/CCAR) are stored in:**
- **Database:** `1Parkplace` (Azure SQL Database)
- **Server:** `1parkplace-sql.database.windows.net`
- **Schema:** `mls`
- **Tables:** `ResoMlsSettings`, `ResoCredentialTrestle`, `ResoCredentialBridge`

**Current Status:** Cannot access - firewall blocking IP `173.172.255.188`

---

## Solution Options

### Option 1: Azure Portal Query Editor (RECOMMENDED)
- Log into https://portal.azure.com
- Navigate to: SQL databases → `1Parkplace` → Query editor
- No firewall changes needed
- Use queries below

### Option 2: Add IP to Firewall
- Azure Portal → SQL databases → `1Parkplace` → Networking
- Add client IP: `173.172.255.188` (or colo server's public IP)
- Wait 1-2 minutes, then connect

### Option 3: Have Azure Admin Run Queries
- Share queries below with Azure subscription admin
- They can run via Azure Portal Query Editor

---

## SQL Queries to Run

### Query 1: Get MLS ID 2 RESO Settings
```sql
SELECT 
    s.MlsId,
    s.ProviderTypeId,
    s.CredentialId,
    s.Enabled,
    p.Name AS ProviderName
FROM mls.ResoMlsSettings s
LEFT JOIN mls.ResoProvider p ON p.ResoProviderTypeId = s.ProviderTypeId
WHERE s.MlsId = 2;
```

### Query 2A: If ProviderTypeId = 1 (Trestle) - Get Credentials
```sql
SELECT 
    cr.ResoTrestleCredentialId,
    cr.ClientId,
    cr.ClientSecret,
    cr.TokenCacheMinutes,
    e.Endpoint AS TokenEndpoint,
    seg.Segment AS TokenSegment,
    scp.Scope,
    gt.GrantType
FROM mls.ResoCredentialTrestle cr
LEFT JOIN mls.ResoEndpoint e ON e.ResoEndpointId = cr.ResoEndpointId
LEFT JOIN mls.ResoEndpointSegment seg ON seg.ResoEndpointSegmentId = cr.TokenSegmentId
LEFT JOIN mls.ResoCredentialScope scp ON scp.ResoCredentialScopeId = cr.ScopeId
LEFT JOIN mls.ResoCredentialGrantType gt ON gt.ResoCredentialGrantTypeId = cr.GrantTypeId
WHERE cr.ResoTrestleCredentialId = (
    SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2
);
```

### Query 2B: If ProviderTypeId = 2 (Bridge) - Get Credentials
```sql
SELECT 
    cr.ResoBridgeCredentialId,
    cr.ServerToken,
    cr.TokenCacheInMinutes,
    br.Name AS DataSetName
FROM mls.ResoCredentialBridge cr
LEFT JOIN mls.ResoBridgeDataSet br ON br.MlsId = 2
WHERE cr.ResoBridgeCredentialId = (
    SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2
);
```

### Query 3: Get Query Templates
```sql
SELECT 
    q.Query,
    r.Resource,
    e.Endpoint AS DataEndpoint,
    seg.Segment AS DataSegment
FROM mls.ResoSingleListingResourceQuery q
LEFT JOIN mls.ResoDataResource r ON r.ResoDataResourceId = q.ResoDataResourceId
LEFT JOIN mls.ResoDataEndpoint de ON de.ProviderTypeId = (
    SELECT ProviderTypeId FROM mls.ResoMlsSettings WHERE MlsId = 2
) AND de.ResoDataResourceId = q.ResoDataResourceId
LEFT JOIN mls.ResoEndpoint e ON e.ResoEndpointId = de.ResoEndpointId
LEFT JOIN mls.ResoEndpointSegment seg ON seg.ResoEndpointSegmentId = de.ResoEndpointSegmentId
WHERE q.MlsId = 2 AND q.Enabled = 1;
```

---

## Connection Details

**Azure Database:**
- Server: `1parkplace-sql.database.windows.net`
- Database: `1Parkplace`
- Username: `azure-1parkplace`
- Password: `1pp@zu43$sql`

**Note:** Connection string found in `Smart.Api.MlsData/appsettings.json`

---

## What We'll Learn

After running these queries, we'll know:
1. ✅ Which RESO provider (Trestle vs Bridge technology)
2. ✅ Actual credentials (ClientId/Secret or ServerToken)
3. ✅ API endpoints (where to connect)
4. ✅ Query templates (how to request data)
5. ✅ Which organization MLS ID 2 connects to (based on endpoints/credentials)

---

## Next Steps

1. Choose one of the solution options above
2. Run Query 1 first to determine provider type
3. Run Query 2A or 2B based on provider type
4. Run Query 3 for query templates
5. Document findings in discovery document



