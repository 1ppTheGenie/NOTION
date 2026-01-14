# PLS Project - Agent Message Protocol
**Version:** 1.0  
**Created:** 01/13/2026 8:40 PM  
**Last Updated:** 01/13/2026 8:40 PM  
**Author:** Cursor AI Agent  
**Status:** ✅ Active

---

## 🎯 PURPOSE

This document defines the JSON message protocol for agent-to-agent communication in the PLS Pre-Listing Command project. Agents communicate via structured JSON messages to coordinate work, share handoffs, report blockers, and update status.

---

## 📋 MESSAGE TYPES

### 1. Handoff Message
**Purpose:** Transfer work from one agent to another when a phase/deliverable is complete.

```json
{
  "from": "pls-database",
  "to": "pls-backend-api",
  "type": "handoff",
  "timestamp": "2026-01-13T20:40:00Z",
  "subject": "Phase 1 Complete - Database Schema Ready",
  "body": "Database schema implementation complete. All tables created, stored procedures tested, master data inserted. PLS number generation verified (format: PLS100000A). Database ready for API integration.",
  "attachments": [
    "AgentStatus/AGENT_STATUS_DATABASE_v1.md",
    "02_Scripts/PLS_SCHEMA_EXTENSIONS_NORMALIZED_v3.sql"
  ],
  "actionRequired": true,
  "priority": "high",
  "deliverables": [
    "All database tables created in Sandbox",
    "usp_GetNextPlsNumber stored procedure working",
    "Master data inserted"
  ],
  "nextSteps": [
    "Review database schema documentation",
    "Begin implementing PlsController.cs",
    "Test API endpoints with database"
  ]
}
```

### 2. Blocker Message
**Purpose:** Report blockers that prevent work from continuing.

```json
{
  "from": "pls-backend-api",
  "to": "pls-database",
  "type": "blocker",
  "timestamp": "2026-01-13T20:45:00Z",
  "subject": "Blocker: Stored Procedure Return Type Mismatch",
  "body": "usp_GetNextPlsNumber returns VARCHAR(10) but API expects string. Need clarification on return format or update stored procedure.",
  "attachments": [
    "08_Source_Code/PlsController_Complete_v1.cs"
  ],
  "actionRequired": true,
  "priority": "high",
  "blockerDetails": {
    "severity": "high",
    "affectedWork": "Cannot implement PLS number generation in API",
    "attemptedSolutions": [
      "Tried casting return value",
      "Checked stored procedure definition"
    ],
    "neededFromRecipient": "Confirm return type or update stored procedure"
  }
}
```

### 3. Status Update Message
**Purpose:** Share progress updates without requiring action.

```json
{
  "from": "pls-frontend-ui",
  "to": "all",
  "type": "status_update",
  "timestamp": "2026-01-13T21:00:00Z",
  "subject": "Status Update: PlsCreateComponent 75% Complete",
  "body": "PlsCreateComponent implementation in progress. Form validation complete, Mapbox integration working, photo upload UI implemented. Remaining: API integration and error handling.",
  "attachments": [
    "AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md"
  ],
  "actionRequired": false,
  "priority": "low",
  "progress": {
    "phase": 3,
    "completion": 75,
    "completedTasks": [
      "Form validation",
      "Mapbox integration",
      "Photo upload UI"
    ],
    "remainingTasks": [
      "API integration",
      "Error handling"
    ]
  }
}
```

### 4. Question Message
**Purpose:** Ask questions or request clarification.

```json
{
  "from": "pls-xml-integration",
  "to": "pls-backend-api",
  "type": "question",
  "timestamp": "2026-01-13T21:15:00Z",
  "subject": "Question: XML Generation Location in API",
  "body": "Should XML generation be in PlsService class or separate XmlService class? Also, should we validate XML before sending to GenieCloud or let GenieCloud validate?",
  "attachments": [],
  "actionRequired": true,
  "priority": "medium",
  "questionDetails": {
    "context": "Implementing /render endpoint",
    "options": [
      "PlsService.BuildXml() method",
      "Separate XmlService class",
      "Extension method"
    ],
    "deadline": "2026-01-14T12:00:00Z"
  }
}
```

### 5. Coordination Message
**Purpose:** Coordinate work between agents working in parallel.

```json
{
  "from": "pls-backend-api",
  "to": "pls-xml-integration",
  "type": "coordination",
  "timestamp": "2026-01-13T21:30:00Z",
  "subject": "Coordination: /render Endpoint Implementation",
  "body": "Starting /render endpoint implementation. Need to coordinate XML generation. Proposing: I implement endpoint structure, you implement XML generation as PlsService.BuildXml() method. We'll integrate in shared branch.",
  "attachments": [
    "08_Source_Code/PlsController_Complete_v1.cs"
  ],
  "actionRequired": true,
  "priority": "high",
  "coordinationDetails": {
    "sharedWork": "/render endpoint",
    "proposedApproach": "Backend API implements endpoint, XML Integration implements BuildXml()",
    "timeline": "Complete by 2026-01-15T18:00:00Z",
    "syncPoints": [
      "Daily standup at 9 AM",
      "Code review before merge"
    ]
  }
}
```

---

## 📁 MESSAGE STORAGE

### Message File Structure
```
AgentCollaboration/Messages/
├── handoffs/
│   ├── handoff_20260113_204000_pls-database_to_pls-backend-api.json
│   └── handoff_20260114_100000_pls-backend-api_to_pls-frontend-ui.json
├── blockers/
│   └── blocker_20260113_204500_pls-backend-api.json
├── status_updates/
│   └── status_20260113_210000_pls-frontend-ui.json
├── questions/
│   └── question_20260113_211500_pls-xml-integration.json
└── coordination/
    └── coordination_20260113_213000_pls-backend-api.json
```

### Message Naming Convention
`{type}_{timestamp}_{from}_to_{to}.json`

Example: `handoff_20260113_204000_pls-database_to_pls-backend-api.json`

---

## 🔄 WORKFLOW

### Sending a Message
1. Agent creates JSON message following protocol
2. Saves to appropriate folder in `AgentCollaboration/Messages/`
3. Updates status file with message reference
4. Recipient agent notified (via status dashboard or manual check)

### Receiving a Message
1. Agent checks `AgentCollaboration/Messages/` for new messages
2. Reads message JSON file
3. Updates status file with message receipt
4. Takes action (if actionRequired: true)
5. Responds if needed (creates new message)

### Message Acknowledgment
```json
{
  "from": "pls-backend-api",
  "to": "pls-database",
  "type": "handoff",
  "timestamp": "2026-01-13T20:50:00Z",
  "subject": "Acknowledgment: Database Schema Received",
  "body": "Received database schema handoff. Reviewing schema documentation and stored procedures. Will begin API implementation within 24 hours.",
  "actionRequired": false,
  "priority": "low",
  "acknowledgment": {
    "originalMessage": "handoff_20260113_204000_pls-database_to_pls-backend-api.json",
    "status": "acknowledged",
    "estimatedStart": "2026-01-14T09:00:00Z"
  }
}
```

---

## 🚨 PRIORITY LEVELS

- **Critical:** Immediate action required, blocks all work
- **High:** Action required within 24 hours, blocks specific work
- **Medium:** Action required within 48 hours, coordination needed
- **Low:** Informational, no immediate action required

---

## ✅ BEST PRACTICES

1. **Always include timestamp** - Use ISO-8601 format
2. **Be specific in subject** - Clear, actionable subject lines
3. **Attach relevant files** - Include file paths in attachments
4. **Set appropriate priority** - Don't mark everything as critical
5. **Acknowledge messages** - Respond to messages requiring action
6. **Update status files** - Reference messages in status files
7. **Use structured format** - Follow JSON schema exactly

---

## 📝 CHANGE LOG

| Version | Date/Time | Changes |
|:-------:|-----------|---------|
| 1.0 | 01/13/2026 8:40 PM | Initial message protocol created for agent-to-agent communication via JSON messages |

---

**Status:** ✅ Active

**Location:** `AgentCollaboration/AGENT_MESSAGE_PROTOCOL_v1.md`
