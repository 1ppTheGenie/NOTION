# Integrations
**Third-Party Service Integrations for TheGenie.ai**

---

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Created** | 12/22/2025 |
| **Last Updated** | 12/22/2025 |
| **Author** | Cursor AI |

---

## 📁 Integration Folders

| Folder | Service | Purpose | Status |
|--------|---------|---------|--------|
| `Dropbox\` | Dropbox API | Read-only file search across 3TB Dropbox | 🔧 In Progress |
| `Asana\` | Asana API | Task/project management integration | ⏳ Planned |
| `WHMCS\` | WHMCS API | Billing system integration | ✅ Active |
| `AWS\` | Amazon Web Services | Cloud infrastructure (Genie Cloud) | ✅ Active |
| `GoogleDrive\` | Google Drive API | File storage and sync | ⏳ Planned |
| `Intercom\` | Intercom API | Customer support/chat integration | ✅ Active |
| `iCloud\` | iCloud Drive | Apple cloud storage access | ⏳ Planned |

---

## 📋 Standard Structure for Each Integration

```
[IntegrationName]\
├── README_v1.md           ← Overview and status
├── CREDENTIALS_v1.md      ← API keys, tokens (reference to secure storage)
├── SETUP_v1.md            ← Setup instructions
├── Scripts\               ← Python/PowerShell scripts
└── Docs\                  ← API documentation, notes
```

---

## 🔐 Credential Storage

**All credentials are stored in:**
`G:\My Drive\Master_Credential_Tracker_v[N].md`

Integration folders contain **references** to credentials, not the actual secrets.

---

## Change Log

| Version | Date | Changes |
|:-------:|------|---------|
| 1.0 | 12/22/2025 | Initial creation. Added Dropbox, Asana, WHMCS, AWS, GoogleDrive, Intercom, iCloud folders. |

---

*Location: `D:\Cursor\TheGenie.ai\Development\Integrations\`*
*GitHub: `TheGenie.ai/Development/Integrations/`*

