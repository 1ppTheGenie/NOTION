# 🏢 OneParkPlace Genie Ecosystem Management

## Project Overview

**Project Name:** OneParkPlace Genie Ecosystem Management  
**Created:** December 29, 2025  
**Last Updated:** December 29, 2025 at 3:15 AM PST  
**Author:** Steve Hundley (CEO) + Cursor Opus Agent  
**Status:** 🔴 CRITICAL - Foundational Infrastructure Review  
**Purpose:** Reverse engineer and document the current DevOps state, establish proper processes

---

## Executive Summary

### 🎯 The Bottom Line

**There is NO deployment process to inherit.** Aaron Pavey deployed manually from his local machine, and that process knowledge was lost. Andrew Meyer (your son) continued development and apparently deployed his changes somehow (we need to ask him how). The India team (Ankit/Manoj) has been doing maintenance but likely has never deployed to production.

### 🚨 Critical Findings

| Finding | Status | Impact |
|---------|--------|--------|
| **No Release Pipelines Exist** | 🔴 CRITICAL | All deployments are 100% manual |
| **No Environments Configured** | 🔴 CRITICAL | No staging/production defined in DevOps |
| **No Deployment Groups** | 🔴 CRITICAL | No server targets configured |
| **Build Pipelines Abandoned** | 🔴 CRITICAL | Last automated build: Aug 23, 2023 |
| **Build Administrators Group Empty** | 🔴 CRITICAL | No one can trigger automated builds |
| **Sprint Iterations Stopped** | 🟡 WARNING | Last sprint R160 ended Aug 2024 |
| **Deployment Method = FileSystem** | 🟡 INFO | Publish to folder, then manual copy |

### 🔑 Key Discovery: How Deployments Actually Work

From analyzing the publish profiles in the source code, I found:

| Project | Publish Method | Destination |
|---------|----------------|-------------|
| **Smart.Dashboard** (Production) | FileSystem | `C:\Users\drewm\Documents\Deployments\TheGenie-Dashboard` |
| **Smart.Dashboard** (Staging) | FileSystem | `F:\1PP\Publish\WebFarmGenie` |
| **Smart.Api.Notification** | FileSystem | `F:\1PP\Publish\ApiNotification` |
| **Smart.Api.HttpWrapper** | Web Deploy | `https://1pp.azurewebsites.net` (Azure) |
| **Smart.Api.GenieConnect** | Web Deploy | `https://1pppublic7.azurewebsites.net` (Azure) |

**Translation:**
- `C:\Users\drewm\...` = Andrew Meyer's local machine (drewm = drew meyer)
- `F:\1PP\Publish\...` = Some server with an F: drive (likely a file share or mapped drive)
- Azure Web Deploy = Direct publish to Azure Web Apps

**Conclusion:** Andrew likely:
1. Builds in Visual Studio
2. Publishes to a local folder OR F: drive
3. Either copies files to production server OR publishes directly to Azure

---

## Section 1: Complete Azure DevOps Inventory

### 1.1 Organization Structure

| Property | Value |
|----------|-------|
| **Organization** | OneParkPlace |
| **Organization URL** | https://oneparkplace.visualstudio.com |
| **Primary Project** | SMART |
| **Source Control** | TFVC (Team Foundation Version Control) |
| **Current Changeset** | 4679 |
| **Total Changesets** | 4679+ |

### 1.2 Build Pipelines

| Pipeline Name | Last Run | Status | Duration | Trigger Path |
|---------------|----------|--------|----------|--------------|
| **DEV-WebApiOculus** | Aug 23, 2023 | ✅ Success | 3m 55s | $/SMART/1ppDevelopment/Application/Web/Smart.Api.Oculus |
| **DEV-WindowsServiceMasterAgent** | Dec 20, 2019 | ✅ Success | 1m 35s | $/SMART/1ppDevelopment/Application/WindowsService/Smart.Service.MasterMlsAgent |

**Total Build Pipelines:** 2  
**Last Build:** August 23, 2023 (16 months ago)  
**Both are Continuous Integration (CI) builds** - but nobody has triggered them in ages

### 1.3 Release Pipelines

| Status |
|--------|
| **No release pipelines found** |
| "Automate your release process in a few easy steps with a new pipeline" |

### 1.4 Environments

| Status |
|--------|
| **Create your first environment** |
| No environments configured |

### 1.5 Deployment Groups

| Status |
|--------|
| Empty - No deployment groups exist |

### 1.6 Library (Variable Groups)

| Status |
|--------|
| No variable groups visible |
| (May contain deployment secrets if any exist) |

---

## Section 2: Changeset Backlog Analysis

### 2.1 What's in Source Control Since Last Known Deployment?

**Assumption:** Aaron's last deployment was around September 2024 (Changeset 4665)

| Changeset Range | Count | Author | Period | Notes |
|-----------------|-------|--------|--------|-------|
| 4666-4677 | 12 | Andrew Meyer | Mar 17 - Apr 10, 2025 | Facebook v22, AgentImage, misc |
| 4678-4679 | 2 | Steve Hundley | Dec 29, 2025 | PayPal + SendGrid webhooks |
| **TOTAL UNDEPLOYED** | **14** | | | **Potentially undeployed** |

### 2.2 Andrew's Changes (Ask Him About These)

| Changeset | Date | Description | Question for Andrew |
|-----------|------|-------------|---------------------|
| **4677** | Apr 10, 2025 | page IG | Did you deploy this? |
| **4676** | Apr 10, 2025 | MP - R163c | Part of R163 release? |
| **4675** | Apr 10, 2025 | remove degreesoffreedom | What was this? |
| **4674** | Apr 10, 2025 | Advantage+ disallowed | Facebook ads change? |
| **4673** | Apr 9, 2025 | MP - R163b | Part of R163? |
| **4672** | Apr 9, 2025 | API - Facebook v22 Changes | Did FB require this? |
| **4671** | Apr 9, 2025 | MP - R163 | Release 163 main commit? |
| **4670** | Apr 9, 2025 | FB Ad Set Certification | Is this live? |
| **4669** | Mar 25, 2025 | MP - R162 | Release 162? |
| **4668** | Mar 25, 2025 | Bara | What is Bara? |
| **4667** | Mar 17, 2025 | MP - R161 | Release 161? |
| **4666** | Mar 17, 2025 | Add AgentImage to Consumer List | Is this working in prod? |

---

## Section 3: Application Inventory & Publish Profiles

### 3.1 All Publish Profiles Found

| Application | Profile Name | Method | Target | Framework |
|-------------|--------------|--------|--------|-----------|
| **Smart.Dashboard** | Production - SMARTAgent | FileSystem | `C:\Users\drewm\Documents\Deployments\TheGenie-Dashboard` | .NET |
| **Smart.Dashboard** | StagingLocalFolderProfile | FileSystem | `F:\1PP\Publish\WebFarmGenie` | .NET |
| **Smart.Api.Notification** | FolderProfile | FileSystem | `F:\1PP\Publish\ApiNotification` | .NET Core 2.1 |
| **Smart.Api.HttpWrapper** | 1pp - Web Deploy | Web Deploy | `1pp.azurewebsites.net` | .NET 6.0 |
| **Smart.Api.HttpWrapper** | 1pp - Zip Deploy | Zip Deploy | Azure | .NET 6.0 |
| **Smart.Api.HttpWrapper** | 1pp - FTP | FTP | Azure | .NET 6.0 |
| **Smart.Api.GenieConnect** | 1ppPublic7 - Web Deploy | Web Deploy | `1pppublic7.azurewebsites.net` | .NET 7.0 |
| **Smart.Api.GenieConnectInternal** | 1ppInternal7 - Web Deploy | Web Deploy | Azure | .NET |
| **Smart.Api.Utility** | 1ppInternal7 - Web Deploy | Web Deploy | Azure | .NET |
| **Smart.Api.MlsData** | 1pp - Web Deploy | Web Deploy | Azure | .NET |
| **Smart.Api.GenieSocket** | 1pp - Web Deploy | Web Deploy | Azure | .NET |
| **Smart.Api.PrintHouse** | 1pp - Web Deploy | Web Deploy | Azure | .NET |
| **Smart.Api.Oculus** | FolderProfile | FileSystem | Local | .NET |
| **Smart.Api.DataAppend** | FolderProfile | FileSystem | Local | .NET |
| **Smart.Api.Authentication** | FolderProfile | FileSystem | Local | .NET |
| **PropertyCasterWorkflow** | FolderProfile | FileSystem | Local | .NET |

### 3.2 Deployment Architecture Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DEPLOYMENT TARGETS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────┐    ┌─────────────────────────────────────┐│
│  │   AZURE WEB APPS    │    │      LOCAL/FILE SHARE               ││
│  │                     │    │                                     ││
│  │  • 1pp.azurewebsites.net                                       ││
│  │  • 1pppublic7.azurewebsites.net   • F:\1PP\Publish\...        ││
│  │  • 1ppinternal7 (?)               • C:\Users\drewm\...        ││
│  │                     │    │                                     ││
│  │  [Web Deploy]       │    │  [FileSystem → Manual Copy]        ││
│  └─────────────────────┘    └─────────────────────────────────────┘│
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Section 4: Questions for Andrew Meyer

### Priority 1: Deployment Process

```
Hey Andrew,

I'm documenting the deployment process since we need to train the India team.
Can you answer these questions when you have a moment?

1. DEPLOYMENT METHOD:
   - The publish profiles point to "C:\Users\drewm\Documents\Deployments\TheGenie-Dashboard"
   - After publishing there, what's the next step to get code to production?
   - Do you copy files somewhere? RDP to a server? Use a script?

2. THE F: DRIVE:
   - Some profiles point to "F:\1PP\Publish\..."
   - What is that? A network share? A VM? A deployment server?
   - How does code get from F: drive to production?

3. YOUR RECENT CHANGES (Mar-Apr 2025):
   - Changesets 4666-4677 show R161, R162, R163 releases
   - Did you deploy these to production?
   - If yes, how?

4. AZURE WEB APPS:
   - Some APIs deploy directly to Azure (1pp.azurewebsites.net, 1pppublic7.azurewebsites.net)
   - Do you have Azure credentials saved in Visual Studio?
   - Does the India team need Azure access?

5. STAGING:
   - stage.thegenie.ai - how is this deployed?
   - Same process as production, or different?

Thanks!
Dad
```

---

## Section 5: Users & Permissions

### 5.1 Current Azure DevOps Users

| User | Email | Access Level | Last Accessed | Role |
|------|-------|--------------|---------------|------|
| Andrew Meyer | drewmeyer@1parkplace.com | Basic | Dec 29, 2025 | Former IT Manager/Developer |
| Andrew Meyer | andrewmeyer23@gmail.com | Basic | Apr 18, 2025 | (Alternate account) |
| **Ankit Bhatia** | ankit.bhatia@reliqus.com | Basic | Dec 29, 2025 | India Team |
| **Manoj Sharma** | manoj.sharma@reliqus.com | Basic | Dec 29, 2025 | India Team |
| **Steve Hundley** | steve.hundley@1parkplace.com | Basic | Dec 29, 2025 | CEO |
| Gerome Wilson | gwilson.1parkplace.com@live.com | Basic | Dec 23, 2025 | ? |
| Jahsh Arshad | jahsh@1parkplace.com | Basic | Aug 4, 2025 | ? |
| sfox@1parkplace.com | sfox@1parkplace.com | Basic | Never | (Not activated) |
| support@reliqus.com | support@reliqus.com | Basic | Never | (Not activated) |

**Total Active Users:** 7  

### 5.2 Permission Groups

| Group | Members | Status |
|-------|---------|--------|
| **Build Administrators** | **0 members** | 🔴 EMPTY - This is why Ankit can't deploy |
| **Project Administrators** | Unknown | Need to check |
| **Contributors** | Most users | Standard access |
| **SMART Team** | Manoj + others | Default team |

---

## Section 6: Sprint History

### 6.1 Sprint Pattern

| Year | Sprints | Notes |
|------|---------|-------|
| 2024 | R148 - R160 | 13 sprints, then stopped |
| 2025 | None created | R161-R163 appear in commit messages only |

### 6.2 Last Sprint Details

| Sprint | Start | End | Status |
|--------|-------|-----|--------|
| R160 | Aug 12, 2024 | Aug 23, 2024 | ✅ Completed |
| R161 | — | — | ❌ Never created (but Andrew labeled commits R161) |
| R162 | — | — | ❌ Never created (but Andrew labeled commits R162) |
| R163 | — | — | ❌ Never created (but Andrew labeled commits R163) |

**Observation:** Andrew continued labeling his commits with sprint numbers even though sprints weren't formally created in Azure DevOps. This suggests he was maintaining his own rhythm outside the system.

---

## Section 7: Recommended Deployment Schedule (Steve's to Set)

### 7.1 Proposed Sprint Cadence

| Sprint | Start Date | End Date | Duration |
|--------|------------|----------|----------|
| **R164** | Dec 30, 2025 | Jan 10, 2026 | 2 weeks |
| R165 | Jan 13, 2026 | Jan 24, 2026 | 2 weeks |
| R166 | Jan 27, 2026 | Feb 7, 2026 | 2 weeks |

*Note: Andrew used R161-R163, so continuing with R164 maintains numbering.*

### 7.2 Proposed Deployment Windows

| Day | Time (PST) | Activity |
|-----|------------|----------|
| **Wednesday** | EOD | Code freeze |
| **Thursday** | 10:00 AM | Deploy to staging |
| **Thursday** | 2:00 PM | Deploy to production (after staging verification) |
| **Friday** | All day | Monitor, fix if needed |
| **Never** | — | Weekend deployments |

### 7.3 Proposed Approval Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   CHECKIN   │────▶│   STAGING   │────▶│ PRODUCTION  │
│             │     │             │     │             │
│ Any Dev     │     │ Auto        │     │ Steve       │
│ (TFVC)      │     │ (Thursday)  │     │ Approves    │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Section 8: Action Items

### 8.1 Immediate (Tonight)

| # | Action | Owner | Status |
|---|--------|-------|--------|
| 1 | Add Ankit + Manoj to Build Administrators | Steve | ⏳ Pending |
| 2 | Send questions to Andrew (Section 4) | Steve | ⏳ Pending |

### 8.2 This Week

| # | Action | Owner | Status |
|---|--------|-------|--------|
| 3 | Get answers from Andrew on deployment | Andrew | ⏳ Pending |
| 4 | Document deployment steps (based on Andrew's answers) | Agent | ⏳ Waiting |
| 5 | Create Sprint R164 in Azure DevOps | Steve | ⏳ Pending |
| 6 | Deploy 4678-4679 to staging (Steve watches) | Ankit/Andrew | ⏳ Pending |
| 7 | Verify staging works | Steve | ⏳ Pending |
| 8 | Deploy to production | TBD | ⏳ Pending |

### 8.3 Q1 2026 Goals

| Goal | Description |
|------|-------------|
| **Create Release Pipeline** | At least for staging deployments |
| **Document Full Process** | SOP for any team member to deploy |
| **Set Up Approvals** | Steve must approve production |
| **Add Monitoring** | Know when deployments succeed/fail |

---

## Section 9: Raw Data Appendix

### 9.1 Publish Profile Locations

```
D:\Cursor\_SourceCode\Genie.Source.Code_v1\Genie.Source.Code\Web\
├── Smart.Web.FarmGenie\Smart.Dashboard\Properties\PublishProfiles\
│   ├── Production - SMARTAgent.pubxml
│   └── StagingLocalFolderProfile.pubxml
├── Smart.Api.Notification\Smart.Api.Notification\Properties\PublishProfiles\
│   └── FolderProfile.pubxml
├── Smart.Api.HttpWrapper\Smart.Api.HttpWrapper\Properties\PublishProfiles\
│   ├── 1pp - Web Deploy.pubxml
│   ├── 1pp - Zip Deploy.pubxml
│   └── 1pp - FTP.pubxml
└── (etc.)
```

### 9.2 Azure Web App Targets

| Azure Site | SCM URL | IIS App Path |
|------------|---------|--------------|
| 1pp.azurewebsites.net | 1pp.scm.azurewebsites.net:443 | 1pp/api-client |
| 1pppublic7.azurewebsites.net | 1pppublic7.scm.azurewebsites.net:443 | 1ppPublic7/api |

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/29/2025 | Initial discovery document - Azure DevOps audit |
| 2.0 | 12/29/2025 | Added publish profile analysis, deployment architecture, questions for Andrew, complete changeset backlog analysis |

---

*File: PROJECT_GENIE_ECOSYSTEM_MANAGEMENT_v2.md*  
*Location: D:\Cursor\TheGenie.ai\Development\*  
*Project: OneParkPlace Genie Ecosystem Management*

