# Azure DevOps User Audit Report
## OneParkPlace Organization - SMART Project

**Version:** 1.1  
**Created:** December 29, 2025  
**Last Updated:** December 29, 2025  
**Author:** AI Agent / Steve Hundley  

---

## 📋 EXECUTIVE SUMMARY

This report documents a comprehensive audit of all users and permissions in the Azure DevOps OneParkPlace organization. The audit was conducted to ensure:
1. Only authorized personnel have admin access
2. No one can manually push to production without approval
3. India team members have appropriate (but limited) access
4. Steve Hundley maintains full control as the organization owner

---

## 👥 COMPLETE USER INVENTORY

### All Organization Users (8 Total)

| # | Name | Email | Access Level | Date Added | Last Accessed | Status |
|---|------|-------|--------------|------------|---------------|--------|
| 1 | Andrew Meyer | andrewmeyer23@gmail.com | Basic | 7/17/2013 | 4/18/2025 | ⚠️ INACTIVE (8+ months) |
| 2 | Andrew Meyer | drewmeyer@1parkplace.com | Basic | 4/12/2023 | 12/29/2025 | ✅ Active |
| 3 | Ankit Bhatia | ankit.bhatia@reliqus.com | Basic | 5/27/2025 | 12/29/2025 | ✅ Active (India Team) |
| 4 | Gerome Wilson | gwilson.1parkplace.com@live.com | Basic | 7/18/2013 | 12/23/2025 | ✅ Active |
| 5 | Manoj Sharma | manoj.sharma@reliqus.com | Basic | 5/27/2025 | 12/29/2025 | ✅ Active (India Team) |
| 6 | **Steve Hundley** | steve.hundley@1parkplace.com | Basic | 1/23/2025 | 12/29/2025 | ✅ Active (OWNER) |
| 7 | sfox@1parkplace.com | sfox@1parkplace.com | **Stakeholder** | 5/8/2025 | Never | ❄️ ON ICE (Changed 12/29/2025) |
| 8 | support@reliqus.com | support@reliqus.com | Basic | 5/21/2025 | Never | 🔴 NEVER LOGGED IN |

---

## 🔐 CRITICAL ADMIN GROUPS

### Project Collection Administrators (HIGHEST PRIVILEGE)
**Description:** Members can perform ALL privileged operations on the Team Project Collection.

| # | Name | Email | Type |
|---|------|-------|------|
| 1 | Project Collection Service Accounts | (system) | Group |
| 2 | **Andrew Meyer** | drewmeyer@1parkplace.com | AAD User |
| 3 | **Andrew Meyer** | andrewmeyer23@gmail.com | User |
| 4 | **Steve Hundley** | steve.hundley@1parkplace.com | AAD User ✅ |

### Project Collection Build Administrators
**Description:** Members can administer build resources.
- (To be audited if needed)

### 1parkplace Developer Admins
**Description:** "The Super Code Monkeys!"
- (Custom group - to be audited if needed)

### 1parkplace Developers
**Description:** "The Code Monkeys!"
- (Custom group - to be audited if needed)

---

## ✅ SECURITY ASSESSMENT

### Good News (What's Already Correct)

| Finding | Status |
|---------|--------|
| Steve Hundley is a Project Collection Administrator | ✅ GOOD |
| India team (Ankit, Manoj, support@reliqus) NOT in Project Collection Administrators | ✅ GOOD |
| All users have "Basic" access level (not Enterprise/Advanced) | ✅ GOOD |
| Two accounts never logged in (sfox, support@reliqus) - limited exposure | ✅ GOOD |

### ⚠️ Items Requiring Attention

| Issue | Risk Level | Recommendation |
|-------|------------|----------------|
| Andrew Meyer has TWO accounts in Project Collection Administrators | 🟡 Medium | Consider consolidating to one account (drewmeyer@1parkplace.com) |
| andrewmeyer23@gmail.com account inactive since April 2025 | 🟡 Medium | Remove from Project Collection Administrators |
| sfox@1parkplace.com never logged in | ✅ RESOLVED | Changed to Stakeholder access (12/29/2025) |
| support@reliqus.com never logged in | 🟢 Low | Generic account - consider removing |

---

## 🎯 RECOMMENDED ACTIONS

### Immediate Actions (Do Now)

1. **Remove andrewmeyer23@gmail.com from Project Collection Administrators**
   - This is Andrew's old personal Gmail
   - He now uses drewmeyer@1parkplace.com
   - No need for dual admin access

2. ~~**Verify sfox@1parkplace.com purpose**~~ ✅ DONE
   - Changed from Basic to Stakeholder (12/29/2025)
   - Account is now "on ice" with minimal access
   - Can be upgraded back to Basic if consultant work resumes

3. **Review support@reliqus.com**
   - Generic India team support account
   - Never logged in - consider removing

### Optional Actions (Nice to Have)

1. **Add Steve Hundley to "1parkplace Developer Admins"**
   - Provides additional visibility into developer group permissions

2. **Create a "Production Approvers" group**
   - Add only Steve Hundley
   - Use for release pipeline approvals

---

## 🔒 PRODUCTION PROTECTION

### Current State
- The Release Pipeline (SMART-Dashboard-Deploy) requires **Steve Hundley's approval** before Production deployment
- This was configured today (12/29/2025)

### No One Can Manually Push to Production Because:
1. ✅ Release Pipeline has pre-deployment approval gate
2. ✅ Only Steve Hundley is an approver
3. ✅ Pipeline deploys via Deployment Agent (not manual copy)
4. ⚠️ Andrew still has server access (he can technically RDP and copy files)

### To Fully Lock Down Production:
1. Change server passwords (Andrew knows them)
2. Use Azure Key Vault for credentials (not local passwords)
3. Enable Azure DevOps audit logs
4. Consider IP-based firewall rules on servers

---

## 📊 SUMMARY TABLE

| Category | Count | Notes |
|----------|-------|-------|
| Total Users | 8 | |
| Active Users | 5 | Last 30 days |
| Inactive Users | 1 | andrewmeyer23@gmail.com (8 months) |
| Never Logged In | 2 | sfox, support@reliqus |
| Project Collection Admins | 4 | 1 system, 2 Andrew, 1 Steve |
| India Team Members | 3 | Ankit, Manoj, support@reliqus |
| 1ParkPlace Team | 5 | Steve, Andrew (x2), Gerome, sfox |

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/29/2025 | AI Agent | Initial audit - complete user inventory, admin group analysis, recommendations |
| 1.1 | 12/29/2025 | AI Agent | sfox@1parkplace.com changed to Stakeholder access ("on ice") |

