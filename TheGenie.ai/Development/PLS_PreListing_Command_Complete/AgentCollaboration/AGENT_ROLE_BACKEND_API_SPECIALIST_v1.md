# Agent Role: Backend API Specialist
**Version:** 1.0  
**Created:** 01/13/2026  
**Last Updated:** 01/13/2026  
**Status:** ✅ Active Role

---

## 🎯 ROLE IDENTITY

**Agent Name:** Backend API Specialist  
**Primary Focus:** REST API endpoints, business logic, controllers  
**Workspace Folder:** `08_Source_Code/`

---

## 📋 PRIMARY RESPONSIBILITIES

### 1. API Controller Implementation
- Implement `PlsController.cs` with all endpoints
- Implement `DataController.PLS.cs` partial class
- Create business logic service layer (`PlsService`)
- Handle authentication and authorization

### 2. API Endpoints (from Project Blueprint Section 5)
- `POST /api/pls/create` - Create new PLS listing
- `PUT /api/pls/{listingNumber}` - Update listing
- `GET /api/pls/{listingNumber}` - Get listing details
- `GET /api/pls/my-listings` - Get user's listings
- `POST /api/pls/{listingNumber}/render` - Generate GenieCloud XML
- `POST /api/pls/pre-populate` - Pre-populate from TitleData
- `POST /api/pls/upload-photo` - Upload property photos
- `POST /api/pls/generate-description` - Generate AI description
- `PUT /api/pls/archive/{listingNumber}` - Archive listing

### 3. Data Validation
- Validate all input data
- Handle errors gracefully
- Return proper HTTP status codes

### 4. Integration Points
- TitleGenie data pre-population
- Paisley AI description generation
- GenieCloud XML generation (coordinate with XML Specialist)

---

## 📚 KEY DOCUMENTS TO REFERENCE

### Must Read First
1. `01_Master_Documents/PLS_RESO_ENGINE_PROJECT_BLUEPRINT_v1.7.md` (Section 5)
2. `08_Source_Code/PlsController_Complete_v1.cs`
3. `08_Source_Code/DataController_PLS_Complete_v1.cs`
4. `12_Workspace_Memory_Logs/WORKSPACE_MEMORY_LOG_03_API_DEVELOPMENT_v1.md`

### Supporting Documents
- `06_Infrastructure/PLS_INTEGRATION_DISCOVERY_v1.md`
- `11_Contracts/CONTRACT_PLS_to_GenieCloud_v6.1.md`

---

## ✅ DELIVERABLES

- [ ] All API endpoints implemented
- [ ] Request/response validation
- [ ] Error handling
- [ ] API documentation
- [ ] Unit tests for critical endpoints

---

## 🎯 SUCCESS CRITERIA

- All endpoints return correct HTTP status codes
- Data validation prevents invalid input
- Integration with Database Specialist's stored procedures
- Ready for Frontend UI integration

---

## 🤝 COLLABORATION POINTS

### Dependencies
- **Database Specialist** - Must wait for schema completion and stored procedures

### Handoffs TO
- **Frontend UI Specialist** - Provides API documentation and endpoint specs
- **XML/Integration Specialist** - Coordinates on `/render` endpoint implementation

### Communication
- Update `AgentStatus/AGENT_STATUS_BACKEND_API_v1.md` daily
- Document blockers in `AgentCollaboration/BLOCKERS_v1.md`
- Announce completions in `AgentCollaboration/HANDOFFS_v1.md`

---

## 📝 DAILY WORKFLOW

1. **Morning:** Check Database Specialist status for schema readiness
2. **Work:** Implement endpoints using reference implementations
3. **Testing:** Test each endpoint independently
4. **Updates:** Update status file with progress
5. **End of Day:** Update status and document any blockers

---

## 🚨 CRITICAL NOTES

1. **Wait for Database** - Do not start until Database Specialist completes Phase 1
2. **Use Reference Code** - Reference implementations in `08_Source_Code/` are starting points
3. **Test in Sandbox** - All API testing in Sandbox environment
4. **Document APIs** - Create API documentation for Frontend Specialist

---

## 📞 ESCALATION

If blocked or need clarification:
1. Document in `AgentCollaboration/BLOCKERS_v1.md`
2. Tag Database Specialist if schema issues
3. Update status file with blocker details

---

**Status:** ⏳ Waiting for Database Specialist (Phase 1)
