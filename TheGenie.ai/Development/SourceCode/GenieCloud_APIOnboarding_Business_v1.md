# Genie Cloud API Onboarding Guide
**Audience:** External API Customers (Business & Technical Stakeholders)  
**Version:** 1.0  
**Date:** November 15, 2025  
**Document Type:** Customer Onboarding & Enablement

---

## Table of Contents
1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Onboarding Instructions](#onboarding-instructions)
4. [Primary Use Cases](#primary-use-cases)
5. [Implementation Examples](#implementation-examples)
6. [Combining Multiple APIs](#combining-multiple-apis)
7. [Best Practices for Success](#best-practices-for-success)
8. [Sales Enablement Notes](#sales-enablement-notes)
9. [Support & Next Steps](#support--next-steps)

---

## Overview
Genie Cloud delivers a comprehensive suite of marketing automation and real estate intelligence APIs spanning lead lifecycle, campaign activation, area analytics, and workflow orchestration. Customers can integrate directly via the `/api/Data/*` endpoints, automate inbound lead capture with `/api/webhooks`, and extend low-code flows with `/api/Zap/*` connectors.[^1]

---

## Requirements
- **Commercial Agreement:** Signed Genie Cloud API subscription with assigned customer success manager (CSM).
- **Credentials:** API key or OAuth client (issued after onboarding ticket is approved). Webhook integrations require Facebook App credentials.
- **Environment Access:** Production base URL `https://cloud-api.thegenie.ai/` and optional sandbox endpoint (request from CSM). Confirm IP allowlists if required.
- **Team Readiness:** Technical owner, marketing operator, compliance reviewer for data governance sign-off.
- **Tooling:** HTTPS client (Postman, Insomnia, curl) and CI/CD integration path for automated workflows.

---

## Onboarding Instructions
1. **Kick-off Call:** Align objectives, confirm target use cases, and define success metrics with your CSM.
2. **Provision Credentials:** Submit security questionnaire, receive API keys/webhook secrets, and store them in a secrets manager.
3. **Environment Validation:** Perform connectivity test (`GET /api/Zap/Connect` or small `POST /api/Data/InternalNotification`) to confirm authentication and TLS settings.[^1]
4. **Schema Mapping:** Review required request fields (`userId`, `areaId`, `mlsNumber`, etc.) and align with your CRM/marketing data models.[^1]
5. **Pilot Build:** Implement smoke tests for each selected endpoint. Capture sample payloads and validate response codes.
6. **Compliance Review:** Document PII touchpoints, retention plans, and consent handling before moving to production.
7. **Launch & Monitor:** Deploy integration, configure logging/alerting (4xx/5xx thresholds), and schedule quarterly business reviews with Genie Cloud.

---

## Primary Use Cases
- **Lead Intake & Enrichment:** Create, update, and tag leads using `CreateNewLead`, `CreateLeadNote`, `UpdateLead`, and `GetZapLead` to power CRM automations.[^1]
- **Campaign Activation:** Deploy direct mail and Facebook marketing assets with `CreateDirectMailing`, `CreateFacebookImageAd`, `ProcessDirectMail`, and `QueueFacebookCustomAudience`.
- **Area & Listing Intelligence:** Pull market boundaries and statistics via `GetAreaBoundary`, `GetAreaStatistics`, `GetListingByMlsNumber`, and `GetZipCodeStatistics` to feed dashboards or personalized marketing.
- **Workflow Rendering:** Trigger asset generation (`QueueHubAssetGeneration`, `WorkflowGetMlsListing`, `GenerateShortUrl`) and update billing (`WorkflowProcessBilling`).
- **Security & Account Setup:** Manage user onboarding with `SignupAgent`, `Send2FACode`, and `Verify2FACode` endpoints.

---

## Implementation Examples

### Example 1: Lead Capture to Nurture Workflow
1. **Webhook Intake:** Configure Facebook lead ads to POST to `https://cloud-api.thegenie.ai/api/webhooks` (Genie verifies via `GET /api/webhooks`).[^1]
2. **Lead Creation:** Invoke `POST /api/Data/CreateNewLead` with collected form data.
3. **Follow-up Tasks:** Use `POST /api/Data/CreateLeadNote` to schedule internal actions and `POST /api/Data/TrackUserActivity` to monitor engagement.

### Example 2: Market Report Generation
1. **Area Selection:** Call `POST /api/Data/GetAreaBoundary` and `POST /api/Data/GetAreaStatistics` using `areaId`.[^1]
2. **Asset Queue:** Post to `POST /api/Data/QueueHubAssetGeneration` with desired asset slug (e.g., `market-report-kit`).
3. **Distribution:** Once assets are ready, trigger `POST /api/Data/CreateDirectMailing` or `POST /api/Data/FacebookPostImage` for multi-channel delivery.

### Example 3: Zapier Connector Launch
1. **Connectivity Test:** `POST /api/Zap/Connect` ensures API credentials are valid.[^1]
2. **Lead Sync:** Configure Zap to call `POST /api/Zap/CreateLead` when a new CRM record appears.
3. **Reporting:** Periodically call `POST /api/Zap/GetLeads` to reconcile counts and push to BI tools.

---

## Combining Multiple APIs
- **Cross-Channel Campaigns:** Chain data endpoints (`GetAreaStatistics`, `GetListingByMlsNumber`) with marketing endpoints (`CreateFacebookImageAd`, `ProcessDirectMail`) to deliver consistent messaging across print and social channels.
- **Workflow Failover:** Use `/api/Data/QueueHubAssetGeneration` as the primary render trigger and extend with Zapier fallbacks (`/api/Zap/CreateLead`) to guarantee conversion follow-through.
- **End-to-End Automation:** Initiate alerts (`InternalNotification`) when a webhook lead arrives, then run billing (`WorkflowProcessBilling`) and asset delivery without manual intervention.
- **Data Integrity Loop:** After rendering, call `GetZipCodeStatistics` to refresh dashboards and update customer communications automatically.

---

## Best Practices for Success
- **Credential Hygiene:** Store all keys in a secrets vault; rotate at least quarterly.
- **Rate Governance:** Batch requests where possible and implement exponential backoff on HTTP 429/503 responses.
- **Logging & Observability:** Capture request IDs, timestamps, and endpoint names for troubleshooting. Redact PII before persisting logs.
- **Error Handling:** Treat 4xx responses as actionable client issues (invalid payload, missing permission); 5xx responses should trigger retries and escalation.
- **Change Management:** Subscribe to Genie Cloud release notes; test new endpoints in sandbox before production deployment.
- **Data Compliance:** Align stored responses with privacy requirements. Use `InternalNotification` for proactive alerts when workflows create sensitive data.

---

## Sales Enablement Notes
- **Differentiators:** Real estate-specific data depth (MLS, assessor, market stats) combined with ready-to-launch marketing automations reduces integration time-to-value.[^1]
- **Proof of Value:** Offer pilot programs targeting one use case (e.g., Facebook ads automation) with predefined KPIs (lead volume lift, time saved).
- **Packaging:** Bundle APIs by outcome (Lead Accelerator, Market Intelligence, Campaign Automation) and map each to relevant endpoints.
- **Support Structure:** Highlight dedicated CSM, solution engineer office hours, and prebuilt Zapier templates that minimize customer lift.

---

## Support & Next Steps
- **Technical Support:** Submit tickets through the Genie Cloud customer portal or email integrations@thegenie.ai.
- **Escalation Path:** Critical incidents escalate to the Genie Cloud NOC with <1 hour response targets for P1 issues.
- **Enablement Resources:** Access Postman collections, schema definitions, and deployment checklists from your CSM.
- **Quarterly Reviews:** Schedule joint sessions to assess API usage, performance, and roadmap alignment.

---

[^1]: TheGenie API Help Page – https://app.thegenie.ai/help
