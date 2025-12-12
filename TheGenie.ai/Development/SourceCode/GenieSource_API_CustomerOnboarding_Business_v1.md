# Genie Source API Customer Onboarding Guide
**Audience:** External Developers & Integration Partners  
**Version:** 1.0  
**Date:** November 15, 2025  
**Document Type:** Customer Onboarding & Integration Playbook

---

## 1. Overview
Genie Source APIs provide programmatic access to authentication, lead management, MLS intelligence, marketing fulfillment, notifications, storage, and logging. This guide accelerates onboarding by documenting requirements, setup steps, prioritized use cases, request examples, and patterns for combining multiple APIs into scalable solutions.

---

## 2. Requirements
- **Commercial Access:** Signed API agreement and assigned Genie Cloud customer success manager (CSM).
- **Credentials:**
  - Authentication API client (`/Authentication/authenticate`, `/authenticate-api`).[^auth-controller]
  - Service-specific API keys or JWT tokens (e.g., MLS RESO, Storage, Notification).
- **Environment:**
  - Production Base URL: `https://cloud-api.thegenie.ai/` (route prefix varies per service).
  - Optional sandbox URL available on request.
- **Security Controls:** HTTPS-only traffic, IP allowlist (where enforced), secrets stored in a secure vault.
- **Tooling:** REST client (Postman/Insomnia), CI/CD pipeline for automated deployments, logging & monitoring stack.

---

## 3. Onboarding Instructions
1. **Kick-Off:** Meet with CSM to confirm target features (lead intake, MLS, notifications, etc.).
2. **Credential Provisioning:** Submit security questionnaire, then receive API keys/JWT secrets.
3. **Authentication Test:** Call `POST /Authentication/authenticate` with issued credentials; store token securely.[^auth-controller]
4. **Service Whitelisting:** For APIs guarded by `SmartAuthorize` policies (MLS, Storage, Notification), provide IPs/domains for allowlists.
5. **Connectivity Checks:** Use anonymous health routes (e.g., `GET /verify/anonymous`, `GET /Listing/testconnect`, `GET /blob/test-connect`) to verify routing before authenticated calls.[^genieconnect-verify][^mls-listing-controller][^storage-controller]
6. **Functional Smoke Tests:** Execute one representative call per service (examples below) and validate responses, latency, and headers.
7. **Automation:** Integrate endpoints into application workflows, add retries/backoff for 429/503 responses, and implement structured logging.
8. **Launch Review:** Conduct go-live readiness with CSM (error handling, rate limits, support contacts).

---

## 4. Core API Catalogue & Use Cases
### 4.1 Lead & Customer Lifecycle
- **Endpoint:** `POST /lead/create` – create/update a Genie lead record.[^genieconnect-create-lead]
- **Endpoint:** `GET /lead-zap/{ConsumerId}/{UserId}/{GenieLeadId}` – retrieve Zapier-native payloads for reconciliation.[^genieconnect-zap]
- **Use Cases:** CRM ingestion, nurturing automations, Zapier sync, lead optimization (`POST /property/optimize`).[^genieconnect-optimize]

### 4.2 Authentication & Security
- **Endpoint:** `POST /Authentication/authenticate` – IP restricted token issuance.[^auth-controller]
- **Endpoint:** `POST /Authentication/authenticate-api` – API token flow without IP filter (use service accounts with HMAC/OAuth overlay as required).
- **Health Check:** `GET /Authentication/startup`.

### 4.3 MLS & Property Intelligence
- **Listing Data:** `GET /Listing/get/{mlsId}/{mlsNumber}` – RESO listing payload.[^mls-listing-controller]
- **Custom Query:** `POST /Custom/query` – dynamic MLS lookup by filters.[^mls-custom-controller]
- **Open House:** `GET /OpenHouse/get/{mlsId}/{mlsNumber}`.[^mls-openhouse-controller]
- **Legacy Bulk Feed:** `/api/listing` date-range export (Oculus).[^^oculus-listing]
- **Use Cases:** Automated CMA, property detail pages, market insights dashboards.

### 4.4 Data Append & Enrichment
- **Routes:** `/api/contact/getcontact`, `/getdemographics`, `/getfinancial`, `/getonlineaudience`, `/getaddress` (all POST).[^^dataappend-controller]
- **Use Cases:** Enhance lead records with phone/email, demographic/fiscal data, and digital audiences before campaigns.

### 4.5 Messaging & Notifications
- **Email:** `POST /Email/transactional` – send templated communications; webhook `GET /Email/eventwebhook` for provider callbacks.[^notification-email]
- **SMS:** `POST /Sms/send` – dispatch notifications or OTP codes.[^notification-sms]
- **Use Cases:** Campaign follow-up, transactional alerts, two-factor authentication.

### 4.6 Storage & Asset Delivery
- **Upload:** `POST /blob/upload` with multipart payload for documents.[^storage-controller]
- **Container Management:** `POST /blob/create-container`.
- **Use Cases:** Host marketing assets, land property documents, maintain audit logs.

### 4.7 Print Fulfillment
- **Endpoint:** `POST /Print/process` – submit `PrintHouseRequest` containing assets, metadata, and vendor instructions.[^printhouse-controller]
- **Use Cases:** Automate postcard/brochure production after lead or listing triggers.

### 4.8 Logging & Observability
- **Endpoint:** `POST /log` – send structured logs (`SmartLogRequest`) to centralized storage for correlation.[^utility-log]
- **Use Cases:** Client-side instrumentation, integration error reporting, SLA compliance.

### 4.9 HTTP Wrapper & Token Analytics
- **Wrapper:** `POST /wrapper/process` – Proxy external calls through Genie-managed policies (retries, auth).[^^wrapper-controller]
- **Token Usage:** `POST /api/tokenusage/gettokencount` – Estimate LLM token counts before invoking AI services.[^geniesocket-controller]

---

## 5. Quick Start Examples
### 5.1 Create a Lead
```bash
curl -X POST https://cloud-api.thegenie.ai/lead/create \
  -H "x-api-key: YOUR_GENIECONNECT_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "agent-123",
    "source": "web-form",
    "contact": {
      "firstName": "Avery",
      "lastName": "Stone",
      "email": "avery@example.com"
    }
  }'
```
_Response:_ `ApiResponseWithKey<long>` containing `leadId` and status metadata.[^genieconnect-create-lead]

### 5.2 Retrieve MLS Listing
```bash
curl -X GET "https://cloud-api.thegenie.ai/Listing/get/42/ML123456" \
  -H "Authorization: Bearer YOUR_MLS_TOKEN"
```
_Response:_ Listing DTO with property facts, media, and syndication metadata.[^mls-listing-controller]

### 5.3 Enrich Contact Data
```bash
curl -X POST https://cloud-api.thegenie.ai/api/contact/getcontact \
  -H "Authorization: Bearer YOUR_DATAAPPEND_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Avery","lastName":"Stone","address":"123 Main St","zip":"94110"}'
```
_Response:_ `GetContactResponse` including appended phones/emails plus credit usage.[^^dataappend-controller]

### 5.4 Upload Rendered Asset
```bash
curl -X POST https://cloud-api.thegenie.ai/blob/upload \
  -H "Authorization: Bearer YOUR_STORAGE_TOKEN" \
  -F "container=marketing-assets" \
  -F "file=@/path/to/postcard.pdf"
```
_Response:_ `ResponseGeneral` with storage URL.[^storage-controller]

### 5.5 Sample Response Tables

**POST /lead/create**

| Field | Sample Value | Description |
| --- | --- | --- |
| success | true | Indicates request completed without validation errors |
| key | 982345671 | Genie lead identifier returned by the service |
| statusCode | 201 | HTTP status surfaced inside response wrapper |
| message | Lead created successfully | Human-readable confirmation |
| timestamp | 2025-11-15T18:42:11Z | Server-side processing time |

**GET /Listing/get/{mlsId}/{mlsNumber}**

| Field | Sample Value | Description |
| --- | --- | --- |
| mlsNumber | ML123456 | Listing identifier queried |
| listPrice | 1250000 | Current list price (USD) |
| status | Active | Listing status flag |
| latitude | 37.7645 | Geocoordinate from RESO payload |
| bedrooms | 4 | Bedroom count |

**POST /api/contact/getcontact**

| Field | Sample Value | Description |
| --- | --- | --- |
| firstName | Avery | Normalized contact first name |
| primaryEmail | avery.stone@example.com | Appended email address |
| primaryPhone | +1-415-555-0190 | Appended phone number |
| cacheHit | false | Indicates lookup used paid credits |
| creditsUsed | 1 | Debited credits for this enrichment |

**POST /Email/transactional**

| Field | Sample Value | Description |
| --- | --- | --- |
| success | true | Template submission accepted |
| providerMessageId | 01020304-ffff-42ab-99dd-1234567890ab | Downstream ESP identifier |
| queuedAt | 2025-11-15T18:45:03Z | Email enqueued timestamp |
| recipient | avery.stone@example.com | Destination mailbox |
| template | client-onboarding-welcome | Template slug executed |

**POST /blob/upload**

| Field | Sample Value | Description |
| --- | --- | --- |
| success | true | Upload operation completed |
| container | marketing-assets | Target storage container |
| objectKey | marketing-assets/2025/11/postcard-9823.pdf | Object path created |
| contentLength | 524288 | Size in bytes of uploaded file |
| url | https://storage.thegenie.ai/.../postcard-9823.pdf | Public or signed URL returned |

---

## 6. Combining Multiple APIs
| Scenario | Workflow |
| --- | --- |
| **Lead-to-Campaign Automation** | 1) Capture Facebook leads via webhook → 2) `POST /lead/create` → 3) `POST /api/contact/getcontact` for enrichment → 4) `POST /Email/transactional` & `POST /Sms/send` for nurture → 5) `POST /Print/process` for direct mail. |
| **Market Report Delivery** | 1) `POST /Custom/query` for MLS data → 2) `POST /wrapper/process` to fetch external market stats → 3) `POST /blob/upload` to store generated PDF → 4) `POST /Email/transactional` with attachment link. |
| **AI Conversation Billing** | 1) `POST /api/tokenusage/gettokencount` before invoking LLM → 2) Log usage via `POST /log` → 3) Charge client via billing service. |

**Scalability Tips:**
- Use async queues (e.g., AWS SQS) between lead intake and heavy processing (Print, Data Append).
- Cache MLS responses where permissible; use `/Listing/clearcache` sparingly.[^mls-listing-controller]
- Monitor Notification API webhooks for bounce and complaint handling.

---

## 7. Best Practices
1. **Security:** Rotate API keys quarterly, enforce least privilege, and implement HMAC signatures for sensitive routes.
2. **Error Handling:** Treat 4xx responses as actionable (invalid payload/auth); implement exponential backoff on 429/503 responses.
3. **Observability:** Send error logs to `/log` with correlation IDs; integrate with your SIEM.
4. **Testing:** Maintain Postman collection covering smoke/regression; run nightly against sandbox.
5. **Data Governance:** Respect suppression lists and opt-outs when using Data Append and Notification APIs.
6. **Performance:** Batch requests when possible (e.g., PrintHouse) and parallelize listing pulls across MLS IDs.
7. **Support:** Escalate critical incidents via integrations@thegenie.ai; include request IDs and timestamps.

---

## 8. Go-Live Checklist
- [ ] Authentication flow confirmed; tokens stored securely.
- [ ] Health/endpoints monitored (availability, latency, error rate).
- [ ] Rate limit strategy implemented.
- [ ] Webhook endpoints validated with provider challenge.
- [ ] Disaster recovery plan (retry queues, dead-letter processing) documented.
- [ ] Contact change management plan for API updates/releases.

---

[^auth-controller]: 
```19:37:Genie.Source.Code/Web/Smart.Api.Authentication/Smart.Api.Authentication/Controllers/AuthenticationController.cs
[ServiceFilter(typeof(SmartIpFilter))]
[HttpPost("authenticate")]
public IActionResult Authenticate(TokenRequest request)
{
    return Ok(_authenticationService.Authenticate(request));
}
```

[^genieconnect-verify]: 
```3:14:Genie.Source.Code/Web/Smart.Api.GenieConnect/Smart.Api.GenieConnect/Endpoint/Connect/EndpointVerify.cs
Get(ApiPath.Verify);
AllowAnonymous(Http.GET);
...
await SendAsync("Welcome to Genie Connect");
```

[^genieconnect-create-lead]: 
```5:18:Genie.Source.Code/Web/Smart.Api.GenieConnect/Smart.Api.GenieConnect/Endpoint/Lead/EndpointCreateLead.cs
Post(ApiPath.CreateLead);
...
var response = await Service.CreateLeadAsync(req);
```

[^genieconnect-zap]: 
```6:16:Genie.Source.Code/Web/Smart.Api.GenieConnect/Smart.Api.GenieConnect/Endpoint/Lead/EndpointGetZapLead.cs
Get(ApiPath.GetZapLead);
...
var response = await Service.GetZapLeadAsync(Route<int>("ConsumerId"), Route<string>("UserId"), Route<long>("GenieLeadId"));
```

[^genieconnect-optimize]: 
```6:19:Genie.Source.Code/Web/Smart.Api.GenieConnect/Smart.Api.GenieConnect/Endpoint/Property/EndpointOptimizeProperty.cs
Post(ApiPath.OptimizeProperty);
...
var response = await Service.OptimizePropertyAsync(req);
```

[^mls-listing-controller]: 
```22:50:Genie.Source.Code/Web/Smart.Api.MlsData/Smart.Api.MlsData/Controllers/ListingController.cs
[Route("get/{mlsId:int}/{mlsNumber}")]
public IActionResult Get(int mlsId, string mlsNumber)
{
    var handler = new ListingHandler(Configuration, Cache, Logger);
    return Ok(handler.GetListingReso(mlsId, mlsNumber));
}
```

[^mls-custom-controller]: 
```21:27:Genie.Source.Code/Web/Smart.Api.MlsData/Smart.Api.MlsData/Controllers/CustomController.cs
[HttpPost]
[Route("query")]
public IActionResult Query(RequestCustomData request)
{
    var handler = new CustomDataHandler(Configuration, Cache, Logger);
    return Ok(handler.GetDataReso(request));
}
```

[^mls-openhouse-controller]: 
```21:27:Genie.Source.Code/Web/Smart.Api.MlsData/Smart.Api.MlsData/Controllers/OpenHouseController.cs
[HttpGet]
[Route("get/{mlsId:int}/{mlsNumber}")]
public IActionResult Get(int mlsId, string mlsNumber)
{
    var handler = new OpenHouseHandler(Configuration, Cache, Logger);
    return Ok(handler.GetOpenHouse(mlsId, mlsNumber));
}
```

[^dataappend-controller]: 
```22:95:Genie.Source.Code/Web/Smart.Api.DataAppend/Smart.Api.DataAppend/Controllers/ContactController.cs
[HttpPost]
[ResponseType(typeof(GetContactResponse))]
public IHttpActionResult GetContact(GetContactRequest request)
{
    if (!ModelState.IsValid)
        return BadRequest(ModelState);

    return Ok(_manager.GetContact(request));
}
```

[^notification-email]: 
```22:47:Genie.Source.Code/Web/Smart.Api.Notification/Smart.Api.Notification/Controllers/EmailController.cs
[HttpPost("transactional")]
public IActionResult Transactional(SmartTemplateEmail email)
{
    return Ok(_emailService.SendTemplateEmail(email));
}
```

[^notification-sms]: 
```20:37:Genie.Source.Code/Web/Smart.Api.Notification/Smart.Api.Notification/Controllers/SmsController.cs
[HttpPost("send")]
public IActionResult Send(SmartSmsRequest request)
{
    return Ok(_smsService.SendMessage(request));
}
```

[^storage-controller]: 
```20:61:Genie.Source.Code/Web/Smart.Api.Storage/Smart.Api.Storage/Controllers/BlobController.cs
[HttpPost]
[Route("upload")]
public IActionResult Upload(RequestFileUpload request)
{
    return Ok(BLL.WebStorageManager.Upload(request));
}
```

[^printhouse-controller]: 
```24:38:Genie.Source.Code/Web/Smart.Api.PrintHouse/Smart.Api.PrintHouse/Controllers/PrintController.cs
[HttpPost]
[Route("process")]
public IActionResult Process(PrintHouseRequest request)
{
    var handler = new PrintHandler(Configuration, Cache, Logger);
    return Ok(handler.Process(request));
}
```

[^utility-log]: 
```7:19:Genie.Source.Code/Web/Smart.Api.Utility/Smart.Api.Utility/Endpoint/Log/EndpointLogWriter.cs
public class EndpointLogWriter : Endpoint<SmartLogRequest, ResponseGeneral>
{
    public ILogService Service { get; set; }

    public override void Configure()
    {
        Post(ApiPath.Log);
    }
}
```

[^wrapper-controller]: 
```18:32:Genie.Source.Code/Web/Smart.Api.Wrapper/Smart.Api.HttpWrapper/Controllers/SmartWrapperController.cs
[HttpPost]
[Route("process")]
public IActionResult Process(RequestSmartHttp request)
{
    var handler = new SmartRequestHandler(Configuration);
    return Ok(handler.Process(request));
}
```

[^geniesocket-controller]: 
```13:29:Genie.Source.Code/Web/Smart.Api.GenieSocket/Smart.Api.GenieSocket/Controllers/TokenUsageController.cs
[HttpPost]
[Route("gettokencount")]
public IActionResult GetTokenCount(TokenUsageRequest request)
{
    return Ok(TokenUsageManager.GetCount(request?.Content, request?.Model));
}
```

[^oculus-listing]: 
```35:70:Genie.Source.Code/Web/Smart.Api.Oculus/OculusApi/Controllers/ListingController.cs
[ResponseType(typeof(List<Listing>))]
public IHttpActionResult Get(int mlsId, DateTime startDate, DateTime endDate)
{
    var subsriberId = BLL.TokenHelper.GetSuscriberId(Request?.Headers?.Authorization?.Parameter);
    var response = _manager.GetListings(mlsId, startDate, endDate, subsriberId);

    if (response.Success)
        return Ok(response.Items);

    return InternalServerError();
}
```
