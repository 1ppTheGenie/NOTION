# DISCOVERY: Step-by-Step System Integration
**Systematic Discovery Plan for Dispute Defense Automation**

---

## Version Information

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/19/2024 |
| **Last Updated** | 12/19/2024 |
| **Status** | ACTIVE - Discovery Plan |

---

## Executive Summary

**Goal:** Systematically discover and connect to all systems needed for automated dispute defense:
1. **WHMCS** - Billing system that connects to PayPal (get PayPal credentials through WHMCS)
2. **Intercom** - Customer support chat (where customers alert us to refund requests)
3. **Zoom Phone** - Phone system with recordings (800 number, staff phones, call logs)
4. **Asana** - Task management (for manual intervention assignments)

**Approach:** Step-by-step discovery, one system at a time, documenting findings as we go.

---

## Discovery Steps - Priority Order

### STEP 1: WHMCS Discovery & PayPal Connection
**Priority:** HIGHEST - This is the billing system that connects to PayPal

**What We Need to Discover:**
- [ ] WHMCS installation location/URL
- [ ] WHMCS admin credentials
- [ ] How WHMCS connects to PayPal
- [ ] PayPal credentials stored in WHMCS
- [ ] WHMCS database schema (orders, invoices, transactions)
- [ ] WHMCS API access (if available)
- [ ] How to query WHMCS for transaction data by PayPal transaction ID
- [ ] How to retrieve checkout IP addresses from WHMCS
- [ ] How to retrieve customer information from WHMCS

**Questions to Answer:**
1. Where is WHMCS hosted?
2. What database does WHMCS use? (Same FarmGenie database or separate?)
3. What tables in WHMCS store PayPal transaction data?
4. Can we access PayPal API credentials through WHMCS?
5. Does WHMCS have an API we can use?
6. How does WHMCS track PayPal transaction IDs?

**Value for Dispute Defense:**
- ✅ Source of PayPal transaction data
- ✅ Customer order information
- ✅ Payment authorization details
- ✅ Checkout IP addresses (if logged)
- ✅ PayPal API credentials (if stored in WHMCS)

---

### STEP 2: Intercom Discovery & API Access
**Priority:** HIGH - This is where customers contact us for refunds

**What We Need to Discover:**
- [ ] Intercom workspace URL
- [ ] Intercom admin access
- [ ] Intercom API credentials (Personal Access Token)
- [ ] How to search conversations by customer email
- [ ] How to export conversation history
- [ ] How to prove "no contact" (empty search results)
- [ ] Intercom API endpoints available
- [ ] Rate limits and API constraints

**Questions to Answer:**
1. What is the Intercom workspace URL?
2. Do we have Intercom admin access?
3. How do we get Intercom API access token?
4. Can we search conversations by email address?
5. Can we export conversation data?
6. How far back do conversation logs go?

**Value for Dispute Defense:**
- ✅ Search for customer support conversations
- ✅ Prove customer never contacted us before dispute
- ✅ Export conversation logs as evidence
- ✅ Document customer's attempt to resolve issue (if they did contact us)

**API Endpoints Needed:**
- `GET /conversations` - Search conversations
- `GET /conversations/{id}` - Get conversation details
- `GET /contacts` - Find contact by email
- `GET /messages` - Get message history

---

### STEP 3: Zoom Phone Discovery & Call Logs
**Priority:** HIGH - Phone recordings are valuable evidence

**What We Need to Discover:**
- [ ] Zoom Phone account access
- [ ] Zoom Phone API credentials
- [ ] How to search call logs by phone number
- [ ] How to search call logs by customer name
- [ ] How to access call recordings
- [ ] How to download call recordings
- [ ] Call log retention period
- [ ] API endpoints for call logs and recordings

**Questions to Answer:**
1. What is the Zoom Phone account URL?
2. Do we have admin access to Zoom Phone?
3. How do we get Zoom Phone API credentials?
4. Can we search call logs by customer phone number?
5. Can we search call logs by customer name/email?
6. How do we access call recordings?
7. How long are call recordings retained?

**Value for Dispute Defense:**
- ✅ Search for customer phone calls
- ✅ Prove customer never called us before dispute
- ✅ Access call recordings if customer did call
- ✅ Document customer's attempt to resolve issue via phone

**API Endpoints Needed:**
- `GET /phone/call_logs` - Search call logs
- `GET /phone/call_logs/{id}/recording` - Get call recording
- Search by phone number, date range, customer info

---

### STEP 4: Database Schema Discovery (FarmGenie)
**Priority:** HIGH - Core data source

**What We Need to Discover:**
- [ ] Connect to FarmGenie database (192.168.29.45)
- [ ] Find tables that store orders/transactions
- [ ] Find tables that store customer/user data
- [ ] Find tables that store login/access logs
- [ ] Find tables that store usage/activity data
- [ ] Find tables that store email communications
- [ ] Map relationship between WHMCS and FarmGenie database
- [ ] Query for Chris Plank case data

**Questions to Answer:**
1. What tables store order/transaction data?
2. What tables store customer information?
3. What tables store login logs (IP addresses, timestamps)?
4. What tables store usage activity?
5. How is WHMCS data stored in FarmGenie?
6. Can we query by PayPal transaction ID?
7. Can we query by customer email?

**Value for Dispute Defense:**
- ✅ Transaction/order data
- ✅ Customer information
- ✅ Login logs with IP addresses
- ✅ Usage activity logs
- ✅ Service delivery confirmation

---

### STEP 5: Asana Setup (Last Priority)
**Priority:** MEDIUM - For manual intervention workflow

**What We Need to Discover:**
- [ ] Asana workspace access
- [ ] Asana API personal access token
- [ ] Create project structure for dispute cases
- [ ] Test task creation API
- [ ] Test task assignment
- [ ] Create task templates

**Questions to Answer:**
1. What is the Asana workspace?
2. How do we get Asana API access token?
3. What project structure should we use?
4. Who should tasks be assigned to?

**Value for Dispute Defense:**
- ✅ Create tasks for manual evidence collection
- ✅ Assign tasks to team members
- ✅ Track completion status
- ✅ Set deadlines based on dispute deadlines

---

## Integration Value Assessment

### WHMCS → PayPal
**Value:** ⭐⭐⭐⭐⭐ CRITICAL
- Primary source of PayPal transaction data
- May contain PayPal API credentials
- Tracks all orders and payments
- **Action:** Start here - this is the foundation

### Intercom → Customer Support
**Value:** ⭐⭐⭐⭐⭐ CRITICAL
- Proves customer never contacted us (or did contact us)
- Export conversation logs as evidence
- Shows customer's attempt to resolve issue
- **Action:** High priority - needed for "no contact" proof

### Zoom Phone → Call Logs
**Value:** ⭐⭐⭐⭐ HIGH
- Proves customer never called us (or did call us)
- Call recordings are strong evidence
- Shows customer's attempt to resolve via phone
- **Action:** High priority - valuable evidence source

### Database (FarmGenie) → Core Data
**Value:** ⭐⭐⭐⭐⭐ CRITICAL
- Login logs with IP addresses
- Usage activity logs
- Customer and transaction data
- **Action:** High priority - core evidence source

### Asana → Task Management
**Value:** ⭐⭐⭐ MEDIUM
- Manual intervention workflow
- Task assignment and tracking
- **Action:** Lower priority - can set up after core systems

---

## Next Steps - Immediate Action Plan

### Phase 1: WHMCS Discovery (START HERE)
1. Find WHMCS installation location
2. Get WHMCS admin access
3. Explore WHMCS database schema
4. Find PayPal credentials in WHMCS
5. Test WHMCS API (if available)
6. Document findings

### Phase 2: Intercom Discovery
1. Get Intercom workspace access
2. Obtain Intercom API credentials
3. Test conversation search by email
4. Test conversation export
5. Document API capabilities

### Phase 3: Zoom Phone Discovery
1. Get Zoom Phone account access
2. Obtain Zoom Phone API credentials
3. Test call log search
4. Test recording access
5. Document API capabilities

### Phase 4: Database Exploration
1. Connect to FarmGenie database
2. Map schema for orders, users, logs
3. Test queries for Chris Plank case
4. Document table structures

### Phase 5: Asana Setup
1. Get Asana workspace access
2. Obtain Asana API token
3. Create project structure
4. Test task creation

---

## Questions for You

Before I start discovery, I need:

1. **WHMCS:**
   - Where is WHMCS hosted? (URL or location)
   - Do you have admin credentials I can use?
   - Is WHMCS using the same FarmGenie database or separate?

2. **Intercom:**
   - What is the Intercom workspace URL?
   - Do you have admin access?
   - How do we get API credentials?

3. **Zoom Phone:**
   - What is the Zoom Phone account URL?
   - Do you have admin access?
   - How do we get API credentials?

4. **Access:**
   - Should I start with WHMCS first?
   - Do you want to provide credentials, or should I try to find them in existing documentation?

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 12/19/2024 | Initial step-by-step discovery plan created |

---

**Ready to start Step 1: WHMCS Discovery. Awaiting your go-ahead and access information.**

