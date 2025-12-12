# GitHub Repository Plan

## NEW REPOSITORY NEEDED

**Repository Name:** `1parkplace/genie-operations-reports` (or your preferred name)

**Purpose:** Store operational reports - SEPARATE from application code

**Why Separate:**
- Application repo (`genie-cloud`) is for code
- Reports repo is for operational documentation
- Keeps concerns separated
- Easier to manage permissions

## Structure

```
genie-operations-reports/
├── reports/
│   ├── competition-command/
│   │   ├── monthly-cost/
│   │   └── ownership/
│   ├── listing-command/
│   │   ├── monthly-performance/
│   │   ├── monthly-cost/
│   │   └── orders/
│   └── twilio/
│       ├── invoice-reconciliation/
│       └── sms-detail/
```

## Files to Upload

- 45 report files (CSV, Excel)
- All organized by classification

## Next Steps

1. Create new GitHub repository
2. Upload files to new repo
3. Update Notion pages with new repo URLs


