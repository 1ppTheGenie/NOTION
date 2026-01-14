-- ============================================
-- GET MLS ID 2 (EBRDI) RESO CREDENTIALS
-- ============================================
-- Run these queries in Azure Portal Query Editor
-- Database: 1Parkplace
-- Schema: mls
-- ============================================

-- ============================================
-- QUERY 1: Get MLS ID 2 RESO Settings
-- ============================================
-- This tells us which provider (Trestle vs Bridge) and the CredentialId
-- ============================================
SELECT 
    s.MlsId,
    s.ProviderTypeId,
    s.CredentialId,
    s.Enabled,
    p.Name AS ProviderName,
    CASE 
        WHEN s.ProviderTypeId = 1 THEN 'Trestle (CoreLogic) - Uses ClientId/ClientSecret'
        WHEN s.ProviderTypeId = 2 THEN 'Bridge - Uses ServerToken'
        ELSE 'Unknown Provider'
    END AS ProviderDescription
FROM mls.ResoMlsSettings s
LEFT JOIN mls.ResoProvider p ON p.ResoProviderTypeId = s.ProviderTypeId
WHERE s.MlsId = 2;

-- ============================================
-- QUERY 2A: Get Trestle Credentials (if ProviderTypeId = 1)
-- ============================================
-- Run this if Query 1 shows ProviderTypeId = 1
-- ============================================
SELECT 
    cr.ResoTrestleCredentialId,
    cr.ClientId,
    cr.ClientSecret,
    cr.TokenCacheMinutes,
    e.Endpoint AS TokenEndpoint,
    seg.Segment AS TokenSegment,
    scp.Scope,
    gt.GrantType,
    'Trestle Provider - OAuth 2.0' AS AuthType
FROM mls.ResoCredentialTrestle cr
LEFT JOIN mls.ResoEndpoint e ON e.ResoEndpointId = cr.ResoEndpointId
LEFT JOIN mls.ResoEndpointSegment seg ON seg.ResoEndpointSegmentId = cr.TokenSegmentId
LEFT JOIN mls.ResoCredentialScope scp ON scp.ResoCredentialScopeId = cr.ScopeId
LEFT JOIN mls.ResoCredentialGrantType gt ON gt.ResoCredentialGrantTypeId = cr.GrantTypeId
WHERE cr.ResoTrestleCredentialId = (
    SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2
);

-- ============================================
-- QUERY 2B: Get Bridge Credentials (if ProviderTypeId = 2)
-- ============================================
-- Run this if Query 1 shows ProviderTypeId = 2
-- ============================================
SELECT 
    cr.ResoBridgeCredentialId,
    cr.ServerToken,
    cr.TokenCacheInMinutes,
    br.Name AS DataSetName,
    'Bridge Provider - ServerToken' AS AuthType
FROM mls.ResoCredentialBridge cr
LEFT JOIN mls.ResoBridgeDataSet br ON br.MlsId = 2
WHERE cr.ResoBridgeCredentialId = (
    SELECT CredentialId FROM mls.ResoMlsSettings WHERE MlsId = 2
);

-- ============================================
-- QUERY 3: Get Query Templates (Optional)
-- ============================================
-- This shows how queries are formatted for MLS ID 2
-- ============================================
SELECT 
    q.Query,
    r.Resource,
    e.Endpoint AS DataEndpoint,
    seg.Segment AS DataSegment,
    q.Enabled
FROM mls.ResoSingleListingResourceQuery q
LEFT JOIN mls.ResoDataResource r ON r.ResoDataResourceId = q.ResoDataResourceId
LEFT JOIN mls.ResoDataEndpoint de ON de.ProviderTypeId = (
    SELECT ProviderTypeId FROM mls.ResoMlsSettings WHERE MlsId = 2
) AND de.ResoDataResourceId = q.ResoDataResourceId
LEFT JOIN mls.ResoEndpoint e ON e.ResoEndpointId = de.ResoEndpointId
LEFT JOIN mls.ResoEndpointSegment seg ON seg.ResoEndpointSegmentId = de.ResoEndpointSegmentId
WHERE q.MlsId = 2 AND q.Enabled = 1;

-- ============================================
-- QUERY 4: Get All Active MLSs with RESO (Bonus)
-- ============================================
-- See which MLSs are configured for RESO API
-- ============================================
SELECT 
    s.MlsId,
    s.ProviderTypeId,
    s.Enabled,
    p.Name AS ProviderName,
    CASE 
        WHEN s.ProviderTypeId = 1 THEN 'Trestle'
        WHEN s.ProviderTypeId = 2 THEN 'Bridge'
        ELSE 'Unknown'
    END AS ProviderType
FROM mls.ResoMlsSettings s
LEFT JOIN mls.ResoProvider p ON p.ResoProviderTypeId = s.ProviderTypeId
WHERE s.Enabled = 1
ORDER BY s.MlsId;

-- ============================================
-- INSTRUCTIONS:
-- ============================================
-- 1. Log into Azure Portal: https://portal.azure.com
-- 2. Navigate to: SQL databases -> 1Parkplace -> Query editor
-- 3. Authenticate with: azure-1parkplace / 1pp@zu43$sql
-- 4. Run Query 1 first to see ProviderTypeId
-- 5. Then run Query 2A (if ProviderTypeId = 1) OR Query 2B (if ProviderTypeId = 2)
-- 6. Copy the credentials immediately!
-- ============================================



