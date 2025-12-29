# SMS Alert System Specification
## TheGenie.ai - Azure DevOps Notifications via Twilio

**Version:** 1.0  
**Created:** December 29, 2025  
**Last Updated:** December 29, 2025  
**Author:** AI Agent / Steve Hundley  

---

## 📋 EXECUTIVE SUMMARY

This document specifies an SMS Alert System that sends text message notifications for critical Azure DevOps events. The system uses Twilio SMS API integrated with Azure DevOps Service Hooks.

---

## 🎯 ALERT MENU

### Available Alert Types

| ID | Alert Type | Trigger | Message Template | Priority |
|----|------------|---------|------------------|----------|
| 1 | **Production Approval Needed** | Release pending approval | "🚨 PROD APPROVAL: {ReleaseName} ready for Production. Approve: {ApprovalUrl}" | 🔴 HIGH |
| 2 | **Build Failed** | Build pipeline fails | "❌ BUILD FAILED: {BuildName} - {ErrorMessage}" | 🔴 HIGH |
| 3 | **Deployment Failed** | Release deployment fails | "❌ DEPLOY FAILED: {ReleaseName} to {Stage} - {ErrorMessage}" | 🔴 HIGH |
| 4 | **Deployment Succeeded** | Release completes successfully | "✅ DEPLOYED: {ReleaseName} to {Stage}" | 🟢 LOW |
| 5 | **Code Checked In** | New changeset in TFVC | "📝 CHECK-IN: {User} - {Comment}" | 🟡 MEDIUM |
| 6 | **Work Item Assigned** | Work item assigned to you | "📋 TASK: {Title} assigned to you" | 🟡 MEDIUM |

### Default Configuration (Initial)

| Alert | Enabled | Recipients |
|-------|---------|------------|
| Production Approval Needed | ✅ YES | Steve Hundley |
| Build Failed | ✅ YES | Steve Hundley |
| Deployment Failed | ✅ YES | Steve Hundley |
| Deployment Succeeded | ❌ NO | - |
| Code Checked In | ❌ NO | - |
| Work Item Assigned | ❌ NO | - |

---

## 🔧 TECHNICAL ARCHITECTURE

```
┌─────────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│   Azure DevOps      │────►│  Webhook Endpoint    │────►│    Twilio API   │
│   Service Hook      │     │  (Smart.Dashboard)   │     │                 │
└─────────────────────┘     └──────────────────────┘     └─────────────────┘
                                      │                           │
                                      │                           ▼
                                      │                    ┌─────────────┐
                                      │                    │  SMS to     │
                                      └───────────────────►│  Steve's    │
                                                           │  Phone      │
                                                           └─────────────┘
```

---

## 📱 TWILIO CONFIGURATION

| Setting | Value |
|---------|-------|
| Account SID | [See Master Credential Tracker] |
| Auth Token | (stored securely - see Master Credential Tracker) |
| From Phone | +16193043643 |
| To Phone | +16195074404 (Steve Hundley) |

---

## 🌐 WEBHOOK ENDPOINT

### Endpoint URL
```
https://thegenie.ai/api/alerts/devops
```

### Staging Endpoint (for testing)
```
https://stage.thegenie.ai/api/alerts/devops
```

### HTTP Method
`POST`

### Authentication
Azure DevOps Service Hooks use a shared secret for verification.

---

## 📝 AZURE DEVOPS SERVICE HOOK CONFIGURATION

### Step 1: Navigate to Service Hooks
```
https://oneparkplace.visualstudio.com/SMART/_settings/serviceHooks
```

### Step 2: Create Webhook for "Release deployment approval pending"
- **Trigger:** Release deployment approval pending
- **Filters:** Stage = Production
- **Action:** Web Hook
- **URL:** https://thegenie.ai/api/alerts/devops
- **Resource details:** Send all

### Step 3: Create Webhook for "Build completed" (Failure Only)
- **Trigger:** Build completed
- **Filters:** Build status = Failed
- **Action:** Web Hook
- **URL:** https://thegenie.ai/api/alerts/devops

---

## 💻 CODE IMPLEMENTATION

### Location
```
D:\Cursor\_SourceCode\Genie.Source.Code_v1\Genie.Source.Code\Web\Smart.Web.FarmGenie\Smart.Dashboard\Controllers\AlertsController.cs
```

### Dependencies
- Twilio NuGet Package (already in project)
- Smart.Dashboard project

---

## 🧪 TESTING PLAN

1. Deploy webhook to Staging
2. Configure Service Hook in Azure DevOps (pointing to staging URL)
3. Trigger a test build
4. Verify SMS is received
5. Update URL to Production
6. Document phone number for Steve

---

## 📊 FUTURE ENHANCEMENTS

1. **Admin UI** - Web interface to enable/disable alerts
2. **Multiple Recipients** - Add more phone numbers
3. **Quiet Hours** - Don't send SMS between 10pm-7am
4. **Alert History** - Log all sent alerts in database
5. **Slack/Teams Integration** - Alternative notification channels

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/29/2025 | AI Agent | Initial specification |



