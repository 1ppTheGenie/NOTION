# SOP: CI/CD Pipeline Deployment Process
## SMART-Dashboard-Deploy Release Pipeline

**Version:** 2.0  
**Created:** December 29, 2025  
**Last Updated:** December 29, 2025  
**Author:** AI Agent / Steve Hundley  

---

## 📋 EXECUTIVE SUMMARY

This document defines the Standard Operating Procedure for deploying code changes to TheGenie.ai platform using Azure DevOps CI/CD Pipelines. The pipeline was created to replace the previous manual deployment process and provide automated, auditable, and reliable deployments.

**Key Components:**
- **Build Pipeline:** `SMART-Dashboard-Build` - Compiles code and produces artifacts
- **Release Pipeline:** `SMART-Dashboard-Deploy` - Deploys artifacts to Staging/Production

---

## 🏗️ PIPELINE ARCHITECTURE

### Build Pipeline (CI)

| Property | Value |
|----------|-------|
| **Name** | SMART-Dashboard-Build |
| **URL** | [Azure DevOps Build Pipeline](https://oneparkplace.visualstudio.com/SMART/_build?definitionId=5) |
| **Source** | TFVC - $/SMART |
| **Agent Pool** | Azure Pipelines (windows-2019) |
| **Artifact** | `drop` |

**Build Tasks:**
1. Use NuGet 4.4.1
2. NuGet restore
3. Build solution **/*.sln
4. Test Assemblies
5. Publish symbols path
6. **Publish Artifact: drop** ← Consumed by Release Pipeline

### Release Pipeline (CD)

| Property | Value |
|----------|-------|
| **Name** | SMART-Dashboard-Deploy |
| **URL** | [Azure DevOps Release Pipeline](https://oneparkplace.visualstudio.com/SMART/_release?definitionId=1) |
| **Artifact Source** | SMART-Dashboard-Build (Build Pipeline output) |
| **Default Version** | Latest |

### Stages

| Stage | Deployment Group | Approval Required | Description |
|-------|-----------------|-------------------|-------------|
| **Staging** | Staging | No | Auto-deploys after release creation |
| **Production** | SMART-Production | **Yes - Steve Hundley** | Requires explicit approval (30-day timeout) |

---

## 🖥️ SERVER INFRASTRUCTURE

### Deployment Targets
Both deployment groups have agents installed on **SERVER-WEBAPP2** (physical server in colo facility).

| Server | Role | Agent Status | Location |
|--------|------|--------------|----------|
| SERVER-WEBAPP2 | Staging + Production Host | ✅ Online | Colo Facility |

### IIS Configuration (TO BE CONFIRMED)

| Setting | Staging | Production |
|---------|---------|------------|
| Website Name | `Default Web Site` (placeholder) | TBD |
| Physical Path | TBD | TBD |
| Virtual Application | TBD | TBD |

> ⚠️ **ACTION REQUIRED:** Get actual IIS website names from Andrew

---

## 📦 DEPLOYMENT TASKS (Staging Stage)

### Current Configuration

| Order | Task | Description |
|-------|------|-------------|
| 1 | **MSBuild** | Builds solution `**/*.sln` |
| 2 | **IIS Web App Deploy** | Deploys to IIS website "Default Web Site" |

### Tasks Needed (To Be Added)

1. **NuGet Restore** - Restore NuGet packages before build
2. **Variable substitution** - Transform web.config for environment
3. **Take App Offline** - Enable during deployment (already available in IIS task)

---

## 🚀 HOW TO CREATE A RELEASE

### Method 1: Manual Release

1. Navigate to: [SMART-Dashboard-Deploy Pipeline](https://oneparkplace.visualstudio.com/SMART/_release?definitionId=1)
2. Click **"Create release"**
3. Select artifact version (Latest or specific changeset)
4. Add release notes
5. Click **"Create"**
6. Monitor deployment progress

### Method 2: Trigger on Check-in (Not Yet Configured)

> **Pending:** Continuous deployment trigger needs to be enabled

---

## ✅ DEPLOYMENT APPROVAL PROCESS

### Production Deployment

1. **Staging must succeed first**
2. When Staging completes, Production enters "Pending Approval" state
3. Approver (Steve Hundley) receives email notification
4. Navigate to release and click **"Approve"** or **"Reject"**
5. Add approval comments
6. Production deployment proceeds

### Approval Settings
- **Approver:** Steve Hundley
- **Timeout:** 30 days
- **Notification:** Email

---

## 🔧 CONFIGURATION REQUIREMENTS

### Questions for Andrew

Before the pipeline is fully operational, the following information is needed:

1. **What is the IIS website name on SERVER-WEBAPP2?**
   - Is it "Default Web Site" or something else?
   - Is there a separate site for staging vs production?

2. **What is the physical path for deployment?**
   - Example: `D:\Websites\TheGenie` or similar

3. **Are there Virtual Applications configured?**
   - Smart.Dashboard, Smart.Api.Notification, etc.

4. **Web.config Transforms:**
   - Are there separate configs for staging vs production?
   - Connection strings, API keys, etc.

5. **Web Deploy installed?**
   - Is MSDeploy/Web Deploy installed on the server?
   - Required for the IIS Web App Deploy task

---

## 📊 MONITORING & VERIFICATION

### Post-Deployment Checklist

| Item | How to Verify |
|------|---------------|
| Site loads | Navigate to https://thegenie.ai |
| Login works | Test login functionality |
| Database connection | Verify data appears |
| API endpoints | Test key API calls |
| No console errors | Check browser developer tools |

### Rollback Procedure

1. Navigate to previous successful release
2. Click **"Deploy"** → Select stage
3. Choose "Deploy to [Staging/Production]"
4. Monitor deployment

---

## 📁 RELATED DOCUMENTATION

| Document | Location |
|----------|----------|
| DevOps Ecosystem Management | `D:\Cursor\TheGenie.ai\Development\PROJECT_GENIE_ECOSYSTEM_MANAGEMENT_v2.md` |
| Project Universe Dashboard | `D:\Cursor\TheGenie.ai\Development\PROJECT_UNIVERSE_DASHBOARD_v1.html` |
| Pipeline YAML (Reference) | `D:\Cursor\TheGenie.ai\Development\BillingSystems\Chargeback-dispute-System\Pipelines\azure-pipelines.yml` |

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | 12/29/2025 | AI Agent | Added Build Pipeline (SMART-Dashboard-Build), linked Release Pipeline artifact source, configured Production stage with SMART-Production deployment group |
| 1.0 | 12/29/2025 | AI Agent | Initial creation - Pipeline structure, Staging configuration |

---

## 🔮 NEXT STEPS

### Immediate (Phase 1)
1. [ ] Get IIS configuration details from Andrew (website names, physical paths)
2. [ ] Update Website Name in Staging IIS deploy task (currently "Default Web Site" placeholder)
3. [ ] Add deployment task to Production stage deployment group job
4. [ ] Run first Build Pipeline to generate artifacts
5. [ ] Create first Release to test Staging deployment

### Short-term (Phase 2)
1. [ ] Enable continuous deployment trigger (auto-release on build success)
2. [ ] Add build verification tests
3. [ ] Configure environment-specific variables (connection strings, etc.)
4. [ ] Remove unused "Agent job" from both Staging and Production stages

### Long-term (Phase 3)
1. [ ] Add automated smoke tests
2. [ ] Implement deployment slots for zero-downtime
3. [ ] Add Slack/Teams notifications
4. [x] ~~Create build pipeline for artifact packaging~~ **DONE - SMART-Dashboard-Build created**

---

## 💡 TIPS FOR SUCCESS

1. **Never deploy on Friday afternoon** - Standard industry practice
2. **Always check Staging first** - Production approval requires Staging success
3. **Keep release notes detailed** - Future you will thank present you
4. **Monitor post-deployment** - Don't walk away immediately
5. **Know the rollback plan** - Before you deploy, know how to undo

---

*This SOP is a living document. Update as the pipeline evolves.*

