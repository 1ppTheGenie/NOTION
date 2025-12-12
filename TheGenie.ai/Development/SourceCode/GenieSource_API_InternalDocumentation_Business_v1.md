# Genie Source API System Documentation
**Audience:** Internal Engineering & Platform Operations  
**Version:** 1.0  
**Date:** November 15, 2025  
**Document Type:** System Architecture & Reverse Engineering

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [Service Inventory](#service-inventory)
4. [Shared Infrastructure](#shared-infrastructure)
5. [Deployment & Scalability Considerations](#deployment--scalability-considerations)
6. [Appendix A: Domain Models & Namespaces](#appendix-a-domain-models--namespaces)

---

## Executive Summary
The Genie Source portfolio hosts a suite of ASP.NET Core and legacy WebAPI services that power internal and partner integrations across authentication, lead management, MLS ingestion, marketing fulfillment, storage, notification, and telemetry. Each API is isolated in its own solution under `Genie.Source.Code/Web`, with shared business logic distributed through `Core`, `Data`, and `Model` projects. This document catalogs every API surface, endpoint, authentication pattern, and primary dependencies to support internal development, refactoring, and scalability planning.

---

## Architecture Overview
- **Language & Frameworks:** .NET 6/7 ASP.NET Core minimal APIs (FastEndpoints) for newer services, traditional ASP.NET WebAPI for legacy modules (DataAppend, Oculus).
- **Repository Layout:** Each API resides in a dedicated solution (e.g., `Smart.Api.GenieConnect.sln`) with supporting projects for Core services, data access, and shared models.
- **Cross-Cutting Services:** Common authentication via `Smart.Authentication.Core`, caching via `Smart.Common.Model.Cache`, logging via `Smart.Common.Model.Logging`, and response contracts stored in shared model libraries.
- **Hosting Pattern:** Web apps expose RESTful endpoints, Windows Services provide scheduled/background processing (outside scope of this document but referenced for orchestration).

```
Genie.Source.Code
└── Web
    ├── Smart.Api.Authentication        (Token issuance)
    ├── Smart.Api.DataAppend            (Contact enrichment)
    ├── Smart.Api.GenieConnect          (Public Genie Connect)
    ├── Smart.Api.GenieConnectInternal  (Internal Genie Connect)
    ├── Smart.Api.GenieSocket           (SignalR + token analytics)
    ├── Smart.Api.MlsData               (RESO listing/open-house APIs)
    ├── Smart.Api.Notification          (Email/SMS delivery)
    ├── Smart.Api.Oculus                (Legacy MLS bulk feeds)
    ├── Smart.Api.PrintHouse            (Print fulfillment)
    ├── Smart.Api.Storage               (Blob storage abstractions)
    ├── Smart.Api.Utility               (Logging endpoint)
    └── Smart.Api.Wrapper               (Outbound HTTP proxy)
```

---

## Service Inventory
### 1. Smart.Api.Authentication
- **Purpose:** Issue JWT/access tokens for downstream APIs using shared authentication service.
- **Key Endpoints:**
  - `POST /Authentication/authenticate` – Token issuance guarded by IP filter.[^auth-controller]
  - `POST /Authentication/authenticate-api` – Token issuance for API clients without IP filter restrictions.[^auth-controller]
  - `GET /Authentication/startup` – Health check string.
- **Dependencies:** `IAuthenticationService` (Smart.Authentication.Core); optional `SmartIpFilter` to restrict origin IPs.
- **Notes:** Review `Smart.Authentication.Data` for credential stores and add rate limiting before exposing externally.

### 2. Smart.Api.DataAppend
- **Purpose:** Aggregate contact, demographic, financial, address, and audience enrichment from multiple providers.
- **Routing:** Legacy WebAPI route template `api/{controller}/{action}`.[^dataappend-route]
- **Key Endpoints (all POST, attribute-routed via action names):**
  - `/api/contact/getcontact`
  - `/api/contact/getdemographics`
  - `/api/contact/getfinancial`
  - `/api/contact/getonlineaudience`
  - `/api/contact/getaddress`
- **Implementation:** Each action validates `ModelState` then delegates to `IDataAppendManager` for provider orchestration.[^dataappend-controller]
- **Dependencies:** AutoMapper profiles, Redis/SQL caching (via registry), provider credentials in config.
- **Notes:** Ensure credits and cache indicators returned by manager are surfaced to callers; add async support for throughput.

### 3. Smart.Api.GenieConnect (Public)
- **Purpose:** External Genie Connect API for lead creation, Zapier retrieval, and property optimization.
- **Endpoints:**
  - `GET /verify/anonymous` – Anonymous health check.[^genieconnect-verify]
  - `GET /verify/auth` – Authenticated health check (requires API key middleware).[^genieconnect-verify-auth]
  - `POST /lead/create` – Creates or updates lead information via `IGenieConnectService`.[^genieconnect-create-lead]
  - `GET /lead-zap/{ConsumerId}/{UserId}/{GenieLeadId}` – Retrieve Zapier payload.[^genieconnect-zap]
  - `POST /property/optimize` – Runs property optimization pipeline and returns owner-enriched details.[^genieconnect-optimize]
- **Dependencies:** `GenieConnect.InternalApi` service layer, caching, token validation via `AuthService` (API key lookup against `GenieApiToken`).
- **Security:** API key middleware (`Auth/ApiKeyAuth.cs`) plus optional rate limiting at reverse proxy.

### 4. Smart.Api.GenieConnectInternal
- **Purpose:** Mirrors public Genie Connect but optimized for internal services with IP allow-list and richer mapping.
- **Differences:** Additional `IpAllowedMiddleware` and mapping profiles under `Mapping/*` handle conversion between internal entities and public DTOs.
- **Endpoints:** Same paths as public service through `Endpoint/ApiPath.cs`.

### 5. Smart.Api.GenieSocket
- **Purpose:** SignalR conversation hub and token usage metrics for AI/chat features.
- **Endpoints:**
  - `POST /api/tokenusage/gettokencount` – Calculate token counts for content + model parameters via `TokenUsageManager`.[^geniesocket-controller]
  - `GET /api/tokenusage/test-connect` – Health check (anonymous).[ ^geniesocket-controller]
- **Real-Time:** `ConversationHub` implements `IConversationHub` for WebSocket messaging (review for scaling across multiple nodes with Redis backplane).

### 6. Smart.Api.MlsData
- **Purpose:** Modern RESO-compliant MLS listing, open house, and custom query endpoints.
- **Authentication:** `SmartAuthorize(EnumAuthenticationType.ApiMlsReso)` ensures API key + JWT referencing MLS subscription.[^mls-listing-controller]
- **Controllers & Routes:**
  - `GET /Listing/testconnect` (anonymous), `GET /Listing/testauthorize`, `GET /Listing/clearcache`, `GET /Listing/get/{mlsId}/{mlsNumber}`.[^mls-listing-controller]
  - `POST /Custom/query` – Arbitrary RESO search using `RequestCustomData`.[^mls-custom-controller]
  - `GET /OpenHouse/get/{mlsId}/{mlsNumber}` – Open house data pipeline.[^mls-openhouse-controller]
- **Dependencies:** `MlsData.Core.BLL.Reso` handlers, distributed cache service, configuration-driven MLS credentials.

### 7. Smart.Api.Notification
- **Purpose:** Email and SMS transactional messaging via provider adapters.
- **Email Controller Endpoints:**
  - `POST /Email/transactional` – Send templated email via `IEmailService`.[^notification-email]
  - `POST /Email/startupauth` – Authenticated health check.
  - `GET /Email/startup` – Anonymous health check.
  - `GET /Email/eventwebhook` – Inbound provider webhook processing through `IEmailWebhookService`.[^notification-email]
- **SMS Controller Endpoints:**
  - `POST /Sms/send` – Dispatch SMS via `ISmsService`.[^notification-sms]
  - `POST /Sms/startupauth`, `GET /Sms/startup` – Health checks.
- **Security:** Policy-based authorization `NotificationApi` (see Startup policies).

### 8. Smart.Api.Oculus (Legacy MLS Feed)
- **Purpose:** JWT-protected legacy MLS synchronization and listing detail retrieval.
- **Endpoints:**
  - `GET /api/listing?mlsId=&startDate=&endDate=` – Bulk feed of listings updated in date range.[^oculus-listing]
  - `GET /api/listing/getlistingdetail?mlsId=&mlsNumber=` – Listing detail (attribute routed by method name).
  - `POST /api/listing/clearcache` – Clears listing cache store.
  - Equivalent `AgentController`, `OfficeController`, `OpenHouseController` expose similar patterns.
- **Dependencies:** StructureMap DI, `Oculus.*` projects (authentication, cache, data, external HTTP, SQL).

### 9. Smart.Api.PrintHouse
- **Purpose:** Bridge between Genie asset generation and print vendors.
- **Endpoints:**
  - `POST /Print/process` – Submits `PrintHouseRequest` to `PrintHandler` for downstream processing.[^printhouse-controller]
  - `GET /Print/test-connect` – Health check.
- **Dependencies:** `PrintHouse.Core` for S3 access, vendor connectors, caching for job dedupe.

### 10. Smart.Api.Storage
- **Purpose:** Abstraction over storage containers (likely Azure Blob) for uploads and container management.
- **Endpoints:**
  - `POST /blob/upload` – Accepts `RequestFileUpload` to store binary content via `WebStorageManager`.[^storage-controller]
  - `POST /blob/create-container` – Idempotent container creation.
  - `GET /blob/test-authorize` – Authenticated check returning `ResponseGeneral`.
  - `GET /blob/test-connect` – Anonymous check.
- **Authentication:** `SmartAuthorize(EnumAuthenticationType.ApiStorage)` for protected routes.

### 11. Smart.Api.Utility
- **Purpose:** Internal logging endpoint for multi-service log aggregation.
- **Endpoints:**
  - `POST /log` – FastEndpoints handler writes `SmartLogRequest` through `ILogService`.[^utility-log]
  - `GET /verify/anonymous` – Health check.
- **Notes:** Ensure ingestion pipeline into centralized log store is resilient; consider throttling to prevent log storms.

### 12. Smart.Api.Wrapper (HTTP Proxy)
- **Purpose:** Central wrapper to proxy outbound HTTP requests with shared retry/security policies.
- **Endpoints:**
  - `POST /wrapper/process` – Executes `RequestSmartHttp` via `SmartRequestHandler`.[^wrapper-controller]
  - `GET /wrapper/test-connect` – Health check.
- **Usage:** Allows other services to call external systems with consistent logging and configuration.

---

## Shared Infrastructure
- **Authentication & Authorization:**
  - API key filters (`ApiKeyAuth`, `AuthApiKey`) and `SmartAuthorize` attribute map to enumerated auth types ensuring consistent token validation across services.[^genieconnect-verify-auth][^utility-verify]
  - JWT extraction utilities in Oculus use `TokenHelper` to read subscriber ID, enabling tenant scoping.[^oculus-listing]
- **Caching:** Many controllers accept `ICacheService` (`Smart.Common.Model.Cache.Interface`) enabling shared Redis/Memory cache strategies for MLS data, print jobs, etc.[^mls-listing-controller][^printhouse-controller]
- **Logging:** `Smart.Common.Model.Logging` & `ILogService` centralize log writes; Utility API exposes inbound endpoint for aggregated logs.[^utility-log]
- **Response Contracts:** Responses leverage `Smart.Common.Model.Response` wrappers for consistent success/failure semantics (e.g., `ResponseGeneral`).[^storage-controller]

---

## Deployment & Scalability Considerations
1. **Environment Configuration:** Each API ships with `appsettings.json` and `appsettings.Development.json`. External secrets (API keys, connection strings) must be injected via environment variables or secret stores—do not rely on checked-in values.
2. **FastEndpoints Hosting:** Newer services (GenieConnect, Utility) use FastEndpoints. Ensure minimal API pipeline is configured with swagger generation and standardized middleware (exception handling already present in `CustomException/ExceptionHandlerExtensions.cs`).
3. **Legacy WebAPI Services:** DataAppend and Oculus require IIS/Windows hosting or migration to ASP.NET Core. Plan containerization by wrapping with IIS in Windows containers or refactoring to .NET 6.
4. **Scaling Strategies:**
   - Stateless controllers allow horizontal scaling behind load balancers. Maintain sticky sessions for SignalR hubs (GenieSocket) or configure Redis backplane.
   - Cache busting endpoints (`/Listing/clearcache`) should be secured and audited; consider feature flags to disable in production.
   - Long-running operations (PrintHouse, DataAppend) should be monitored for latency; offload to background jobs where possible.
5. **Observability:** Instrument each API with structured logging (Utility API), metrics for throughput/error rates, and distributed tracing (add ActivitySource wrappers in BLL layers).
6. **Security Hardening:** Enforce HTTPS, add rate limiting middleware, monitor API key usage, and schedule credential rotation.

---

## Appendix A: Domain Models & Namespaces
- **Lead DTOs:** `GCPublic.Request.Lead.RequestApiCreateLead`, `GCPublic.Response.ApiResponseWithKey<long>`.
- **Property DTOs:** `GCPublic.Request.Property.ApiRequestOptimizeProperty`, `Smart.Common.GenieConnectWeb.Model.Public.Property.ApiPropertyWithOwnerInformation`.
- **Data Append Models:** Located under `Smart.Api.DataAppend/Models` (e.g., `GetContactRequest`, `GetFinancialResponse`).
- **MLS Models:** Provided by `MlsData.Model` and `MlsData.Core.BLL.Reso` handlers.
- **Notification Models:** `Smart.Common.Model.Email.SmartTemplateEmail`, `Smart.Common.Model.Sms.SmartSmsRequest`.
- **Storage Models:** `Smart.Storage.Model.Request.RequestFileUpload`, `RequestStorageContainer`.
- **Wrapper Models:** `Smart.Wrapper.Model.BLL.Request.RequestSmartHttp`.
- **Oculus Models:** `OculusApi.Models.Listing`, `ListingDetail`, `OpenHouse` etc., along with `ManagerResponse` wrappers.

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

[^dataappend-route]: 
```14:18:Genie.Source.Code/Web/Smart.Api.DataAppend/Smart.Api.DataAppend/App_Start/WebApiConfig.cs
config.Routes.MapHttpRoute(
    name: "DefaultApi",
    routeTemplate: "api/{controller}/{action}/{id}",
    defaults: new { id = RouteParameter.Optional }
);
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

[^genieconnect-verify]: 
```3:14:Genie.Source.Code/Web/Smart.Api.GenieConnect/Smart.Api.GenieConnect/Endpoint/Connect/EndpointVerify.cs
Get(ApiPath.Verify);
AllowAnonymous(Http.GET);
...
await SendAsync("Welcome to Genie Connect");
```

[^genieconnect-verify-auth]: 
```5:13:Genie.Source.Code/Web/Smart.Api.GenieConnect/Smart.Api.GenieConnect/Endpoint/Connect/EndpointVerifyAuth.cs
public override void Configure()
{
    Get(ApiPath.VerifyAuth);
}
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
```12:50:Genie.Source.Code/Web/Smart.Api.MlsData/Smart.Api.MlsData/Controllers/ListingController.cs
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

[^notification-email]: 
```22:47:Genie.Source.Code/Web/Smart.Api.Notification/Smart.Api.Notification/Controllers/EmailController.cs
[HttpPost("transactional")]
public IActionResult Transactional(SmartTemplateEmail email)
{
    return Ok(_emailService.SendTemplateEmail(email));
}
...
[HttpGet("eventwebhook")]
public IActionResult EventWebhook()
{
    _webhookService.ProcessEvents(Request.Body);
    return Ok("Events Processed");
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

[^geniesocket-controller]: 
```13:29:Genie.Source.Code/Web/Smart.Api.GenieSocket/Smart.Api.GenieSocket/Controllers/TokenUsageController.cs
[HttpPost]
[Route("gettokencount")]
public IActionResult GetTokenCount(TokenUsageRequest request)
{
    return Ok(TokenUsageManager.GetCount(request?.Content, request?.Model));
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

[^storage-controller]: 
```20:61:Genie.Source.Code/Web/Smart.Api.Storage/Smart.Api.Storage/Controllers/BlobController.cs
[HttpPost]
[Route("upload")]
public IActionResult Upload(RequestFileUpload request)
{
    return Ok(BLL.WebStorageManager.Upload(request));
}
...
[HttpGet]
[AllowAnonymous]
[Route("test-connect")]
public IActionResult TestConnect()
{
    return Ok(ResponseHelper.GetSuccess<ResponseGeneral>("Genie.ai Storage API, test connect"));
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

[^utility-verify]: 
```5:14:Genie.Source.Code/Web/Smart.Api.Utility/Smart.Api.Utility/Endpoint/Connect/EndpointVerify.cs
Get(ApiPath.Verify);
AllowAnonymous(Http.GET);
...
await SendAsync("Welcome to 1pp Utility API");
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
