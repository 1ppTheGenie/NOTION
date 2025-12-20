# Workspace Memory Log: Automated Dispute Defense - System Integration
## Session Date: 2025-12-20

---

## Executive Summary

| Item | Details |
|------|---------|
| **Purpose** | Build automated dispute defense system for PayPal chargebacks - "push-button" evidence collection for Listing Command, Competition Command, Neighborhood Command, and ListMiner products |
| **Current State** | 75% Complete - All critical system integrations verified and operational. Ready for Kit creation phase. |
| **Key Outputs** | WHMCS API access verified, Intercom API verified, Zoom Phone API verified and tested. All credentials documented. |
| **Remaining Work** | Build automated evidence collection system (Kit creation), integrate database queries, create automated response generation |
| **Last Validated** | 12/20/2025 - All three systems (WHMCS, Intercom, Zoom Phone) tested and verified working |

---

## 1. Session Overview

**Date:** December 20, 2025  
**Duration:** Extended session  
**Focus Areas:**
- System integration and credential verification
- API access setup for WHMCS, Intercom, and Zoom Phone
- Discovery-driven approach (user requested methodical step-by-step process)
- Verification of all systems before Kit creation

**Key Questions Answered:**
- ✅ How do we access WHMCS API? (Found credentials in existing PowerShell script)
- ✅ How do we access Intercom API? (Token obtained, fixed padding issue)
- ✅ How do we access Zoom Phone API? (Created OAuth app, verified working)
- ✅ What credentials do we have? (All documented in Master Credential Tracker)

**Outcome:**
- All three critical systems are now accessible via API
- Ready to proceed with automated Kit creation
- User emphasized: "push-button" system with no manual intervention (except button click)

---

## 2. Key Discoveries

### 2.1 WHMCS Integration
**Status:** ✅ VERIFIED

**Key Findings:**
- WHMCS uses separate database (not on FarmGenie SQL server)
- API credentials found in existing PowerShell script: `Fix-WHMCS-States_v1.ps1`
- API URL: `https://accounts.1parkplace.com/includes/api.php`
- API Identifier and Secret confirmed working
- PayPal integration uses Payflow Pro (PayPal) - credentials stored in WHMCS admin panel
- Can query transactions via WHMCS API

**Credentials Location:**
- Found in: `c:\Cursor\TheGenie.ai\Development\WHMCS\Fix-WHMCS-States_v1.ps1`
- API Identifier: (stored in script)
- API Secret: (stored in script)
- Access Key: (stored in script)

**Value for Dispute Defense:**
- ✅ Query PayPal transactions by transaction ID
- ✅ Get customer order details
- ✅ Retrieve payment authorization data
- ✅ Access billing history

### 2.2 Intercom Integration
**Status:** ✅ VERIFIED

**Key Findings:**
- Workspace URL: `app.intercom.com/a/apps/m7py7ex5`
- Workspace ID: `m7py7ex5`
- Application Name: TheGenie.ai
- API Access Token: `dG9rOjgxYTYxMjI1X2ZiZGFfNGZkYV84ZjBlX2RlNDZjZTVmNjI3YzoxOjA=`
- **Critical Fix:** Token was missing `=` padding character - fixed after multiple attempts

**API Permissions Configured:**
- ✅ Read and list users and companies
- ✅ Read conversations (CRITICAL for dispute defense)
- ✅ Read events
- ✅ Write conversations
- ✅ Export message data

**Search Strategy:**
- Primary: Search by `external_id` (Intercom's user ID field) - TheGenie and Intercom have API connection
- Fallback: Search by email if user ID not found

**Value for Dispute Defense:**
- ✅ Search customer conversations by user ID or email
- ✅ Prove customer never contacted support before dispute
- ✅ Retrieve all support interactions
- ✅ Export conversation history as evidence

### 2.3 Zoom Phone Integration
**Status:** ✅ VERIFIED AND TESTED

**Key Findings:**
- Account URL: `thegenie-ai.zoom.us`
- 800 Number: `(888) 425-2300` (Main Auto Receptionist, Ext.801)
- App Name: `Cursor-API`
- App Type: Server-To-Server OAuth (Account-level app)

**API Credentials (FINAL):**
- Account ID: `QjlsIG0sQHeNRs51zRrv6A` (lowercase 'l' not uppercase 'I')
- Client ID: `dL9rQulfSqSQRrvW9qYkQg`
- Client Secret: `5Y7z4wNWnBIk5Fj1193hNwcr5qaSbiWR` (BIk not Blk)

**Setup Process:**
1. Created developer role in Zoom admin portal
2. Enabled "Zoom for developers" and "Server-to-server OAuth app" permissions
3. Created OAuth app in Zoom Developer Portal
4. Configured scopes: `phone:read:phone_call_log`, `phone:read:phone_recording`, `phone:read:phone_number`
5. Activated app (required step that was initially missed)

**API Test Results:**
- ✅ Access token obtained successfully
- ✅ Call logs API working (found 49 calls in test)
- ✅ Search by phone number working (found 49 calls for 888-425-2300)
- ✅ API base URL: `https://api.zoom.us/v2`

**Value for Dispute Defense:**
- ✅ Search call logs by customer phone number
- ✅ Prove customer never called before dispute
- ✅ Access call recordings if customer did call
- ✅ Document customer's attempt to resolve issue via phone

### 2.4 Database Access
**Status:** ⏳ PENDING (Next Phase)

**Known Information:**
- Server: `192.168.29.45` (requires SonicWall VPN)
- Hostname: `server-mssql1.istrategy.com`
- User: `cursor`
- Password: `1ppINSAyay$`
- Primary Database: `FarmGenie`
- MLS Database: `MlsListing`
- Title Database: `TitleData`

**Remaining Discovery:**
- [ ] Find tables storing orders/transactions
- [ ] Find tables storing customer/user data
- [ ] Find tables storing login/access logs
- [ ] Find tables storing usage/activity data
- [ ] Query Chris Plank case (PP-R-THB-607760615)

---

## 3. Decisions Made

### 3.1 Architecture Decisions
1. **Back-end API Access Only:** User explicitly requested no front-end logins - all access via APIs
2. **Automated System:** Goal is "push-button" automation - no manual intervention except button click
3. **Discovery-Driven Approach:** User requested methodical step-by-step discovery before building solutions
4. **System Priority:** WHMCS → Intercom → Zoom Phone → Database → Asana

### 3.2 Process Decisions
1. **Verification Before Proceeding:** User emphasized 100% verification of each system before moving to next
2. **Credential Management:** All credentials documented in Master Credential Tracker (Google Drive)
3. **Versioning:** All documents follow versioning rules (never overwrite, always increment)

### 3.3 Business Rules Confirmed
1. **Products in Scope:**
   - Listing Command (one-off product) - PRIMARY FOCUS
   - Competition Command (subscription product)
   - Neighborhood Command (one-off or subscription)
   - ListMiner (one-off product)

2. **Dispute Defense Requirements:**
   - Prove service was delivered
   - Prove customer authorized payment
   - Prove customer agreed to terms
   - Prove customer never contacted support
   - Prove customer used the service

3. **Evidence Types Needed:**
   - Payment authorization (IP address, device info)
   - Terms agreement (checkout screenshot, checkbox timestamp)
   - Service delivery (access confirmation, login logs)
   - Usage logs (platform activity, feature usage)
   - Communication logs (Intercom, Zoom Phone, email)
   - No contact proof (searches across all channels)

---

## 4. Files Created

### Discovery Documents
- `FR_AutomatedDisputeDefense_Discovery_v1.md` - Feature request discovery document
- `DISCOVERY_StepByStep_SystemIntegration_v1.md` - Step-by-step integration plan
- `DISCOVERY_WHMCS_Verified_v2.md` - WHMCS verification results
- `DISCOVERY_Intercom_Verified_v2.md` - Intercom verification results
- `DISCOVERY_ZoomPhone_Verified_v2.md` - Zoom Phone verification results
- `DISCOVERY_SystemVerification_v1.md` - System verification summary
- `DISCOVERY_VerificationSummary_v1.md` - Verification summary
- `DISCOVERY_FinalVerification_v1.md` - Final verification status

### Setup Guides
- `DISCOVERY_Intercom_Setup_v1.md` - Intercom API setup guide
- `DISCOVERY_WHMCS_Verification_v1.md` - WHMCS verification steps
- `ZOOM_Phone_Setup_StepByStep_v1.md` - Zoom Phone setup guide
- `ZOOM_Phone_Step1_Access_v1.md` - Zoom Phone access steps
- `ZOOM_Phone_CallLogs_Access_v1.md` - Zoom Phone call logs access guide

### Credential Documentation
- `G:\My Drive\Master_Credential_Tracker_v3.md` - Master credential tracker (updated)

### Legacy Documents (Set Aside)
- `ListingCommand_TermsOfService_ChargebackDefense_v1.txt` - Set aside per user request
- `ListingCommand_RefundPolicy_ChargebackDefense_v1.txt` - Set aside per user request
- `ListingCommand_CheckoutPageCompliance_v1.txt` - Set aside per user request
- `ListingCommand_SOP_PayPalDisputeDefense_v1.txt` - Set aside per user request
- `ListingCommand_EvidenceCollectionTemplate_v1.txt` - Set aside per user request
- `ListingCommand_ClientCommunicationTemplates_v1.txt` - Set aside per user request
- `ListingCommand_ChargebackDefenseKit_Index_v1.txt` - Set aside per user request
- `ListingCommand_QuickReference_DisputeDefense_v1.txt` - Set aside per user request

**Note:** User requested these be set aside as "unicorn" strategies not connected to real case. Discovery-driven approach preferred.

---

## 5. Technical Learnings

### 5.1 WHMCS API
- **Database Location:** WHMCS uses separate database, not on FarmGenie SQL server
- **API Access:** Credentials found in existing PowerShell scripts (reusable pattern)
- **PayPal Integration:** Uses Payflow Pro - credentials stored in WHMCS admin panel
- **API Endpoint:** `https://accounts.1parkplace.com/includes/api.php`

### 5.2 Intercom API
- **Token Format:** Base64 encoded, requires proper padding (`=` character)
- **Search Strategy:** Use `external_id` (user ID) first, then email as fallback
- **API Version:** Using `Intercom-Version: 2.10` header
- **Authentication:** Bearer token in Authorization header

### 5.3 Zoom Phone API
- **OAuth Flow:** Server-to-Server OAuth requires Account ID, Client ID, and Client Secret
- **Grant Type:** `account_credentials` (not authorization_code)
- **Token Endpoint:** `https://zoom.us/oauth/token`
- **Activation Required:** App must be activated in Developer Portal before credentials work
- **Common Errors:**
  - "Invalid client_id or client_secret" = App not activated OR credentials copied incorrectly
  - Account ID case sensitivity matters (lowercase 'l' vs uppercase 'I')
  - Client Secret case sensitivity matters (BIk vs Blk)

### 5.4 Credential Management
- **Master Credential Tracker:** Located in Google Drive (`G:\My Drive\Master_Credential_Tracker_v3.md`)
- **Versioning:** Always increment version numbers, never overwrite
- **Security:** Credentials stored in Google Drive (not Notion) for security

---

## 6. Next Steps

### Immediate Actions (Next Session)
1. **Database Schema Discovery:**
   - Connect to FarmGenie database
   - Find tables for orders/transactions
   - Find tables for login/usage logs
   - Query Chris Plank case data

2. **Kit Creation (Automated System):**
   - Build "Create Chargeback Defense Kit" button/function
   - Integrate all three APIs (WHMCS, Intercom, Zoom Phone)
   - Automate evidence collection
   - Generate evidence package (PDF)

3. **Evidence Collection Automation:**
   - Query WHMCS for transaction data
   - Search Intercom for conversations
   - Search Zoom Phone for call logs
   - Query database for login/usage logs
   - Compile all evidence into single package

### Short-Term Plans
1. **Test with Real Case:**
   - Use Chris Plank case (PP-R-THB-607760615) as test
   - Verify all evidence collection works
   - Refine automation based on results

2. **Asana Integration (If Needed):**
   - Set up Asana API access
   - Create project structure for dispute cases
   - Create task templates for manual intervention

3. **PayPal Integration:**
   - Access PayPal Resolution Center
   - Automate dispute response submission
   - Track dispute status

### Long-Term Roadmap
1. **Multi-Product Support:**
   - Extend to Competition Command (subscription)
   - Extend to Neighborhood Command
   - Extend to ListMiner

2. **Advanced Features:**
   - Automated dispute monitoring
   - Proactive evidence collection
   - Dispute win rate tracking
   - Evidence quality scoring

---

## 7. Key Credentials Summary

### WHMCS
- API URL: `https://accounts.1parkplace.com/includes/api.php`
- API Identifier: (in PowerShell script)
- API Secret: (in PowerShell script)
- Access Key: (in PowerShell script)

### Intercom
- Workspace ID: `m7py7ex5`
- API Token: `dG9rOjgxYTYxMjI1X2ZiZGFfNGZkYV84ZjBlX2RlNDZjZTVmNjI3YzoxOjA=`
- API Base URL: `https://api.intercom.io`
- API Version: `2.10`

### Zoom Phone
- Account ID: `QjlsIG0sQHeNRs51zRrv6A`
- Client ID: `dL9rQulfSqSQRrvW9qYkQg`
- Client Secret: `5Y7z4wNWnBIk5Fj1193hNwcr5qaSbiWR`
- API Base URL: `https://api.zoom.us/v2`
- 800 Number: `(888) 425-2300`

**⚠️ IMPORTANT:** All credentials stored in `G:\My Drive\Master_Credential_Tracker_v3.md`

---

## 8. User Feedback & Course Corrections

### Initial Approach Correction
**User Feedback:** "I'm a bit surprised you did not ask any discovery questions. Let's start over from the beginning - I would like to ask you to read the Master Index and Master Rules first then lets tackle this project."

**Adjustment:** Set aside initial "Chargeback Defense Kit" deliverables and restarted with discovery-driven approach.

### Credential Access Preference
**User Feedback:** "Negative. you've never before needed. a front end Log in to WHMCS. You have API access to it. and all credentials are in your possession. Let's do it the right way. Where it's all back in Access, no logins to front ends."

**Adjustment:** Pivoted from front-end login to back-end API access using existing credentials.

### Intercom Search Strategy
**User Feedback:** "Regarding your step on Search customer conversations by email. I'm wondering why you couldn't search them by ASP user ID since the Genie and Intercom have an API connection and conversations are automatically connected to each user's account."

**Adjustment:** Updated to prioritize searching by `external_id` (user ID) first, then email as fallback.

### Verification Before Proceeding
**User Feedback:** "I see that you say questions to answer. Can you try to answer those first before we go to Zoom? I want to make sure that we check off each application."

**Adjustment:** Implemented 100% verification of each system before proceeding to next.

### Automation Emphasis
**User Feedback:** "Just so we're clear, The exercise we're going through right now is to create an automated process. There will be no manual intervention. Except for... a screen that says create a chargeback Defense kit. Here's your screen. Thank you."

**Adjustment:** Confirmed goal is fully automated "push-button" system.

---

## 9. Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/20/2025 | Initial memory log created. Documented system integration phase completion. All three systems (WHMCS, Intercom, Zoom Phone) verified and operational. Ready for Kit creation phase. |

---

## 10. Related Documents

- **Master Index:** `c:\Cursor\TheGenie.ai\MASTER_INDEX_v1.md`
- **Master Credential Tracker:** `G:\My Drive\Master_Credential_Tracker_v3.md`
- **Feature Request Discovery:** `FR_AutomatedDisputeDefense_Discovery_v1.md`
- **System Integration Plan:** `DISCOVERY_StepByStep_SystemIntegration_v1.md`

---

**Status:** ✅ **SYSTEM INTEGRATION PHASE COMPLETE - READY FOR KIT CREATION**

*Last Updated: 12/20/2025*

