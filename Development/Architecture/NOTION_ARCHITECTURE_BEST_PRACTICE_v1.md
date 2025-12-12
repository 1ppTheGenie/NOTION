# Notion Architecture - Best Practice Library Science Structure
**Version:** 1.0  
**Date:** 2025-12-11  
**Approach:** Information Architecture Best Practices + Library Science Classification

---

## 🎯 DESIGN PRINCIPLES

1. **Functional Organization** - Organize by business function first
2. **Content Type Classification** - Standard content types across all functions
3. **Platform Hierarchy** - Platforms > Applications (proper hierarchy)
4. **Scalability** - Structure supports growth and sub-segmentation
5. **Library Science** - Subject → Category → Item classification

---

## 🏗️ PROPOSED STRUCTURE (Best Practice)

```
🏢 TheGenie.ai
│
├── 📊 Operations
│   ├── Plans/
│   │   └── [Sub-segmented as needed]
│   ├── Reports/
│   │   └── [Sub-segmented as needed]
│   ├── SOPs/
│   │   └── [Sub-segmented as needed]
│   └── Presentations/
│       └── [Sub-segmented as needed]
│
├── 🚀 Growth
│   ├── Plans/
│   ├── Reports/
│   ├── SOPs/
│   └── Presentations/
│
├── 🛠️ Support
│   ├── Plans/
│   ├── Reports/
│   ├── SOPs/
│   └── Presentations/
│
└── 💻 Development
    ├── Plans/
    ├── Reports/
    ├── SOPs/
    ├── Specs/
    │   ├── SourceCode/
    │   └── 3rd Party Vendors/ (e.g., Twilio)
    ├── Scripts/ (linked to end products)
    └── Platforms/ (HIGHER HIERARCHY than Applications)
        │
        ├── Main Genie
        │   └── Applications/
        │       ├── Competition Command
        │       ├── Listing Command
        │       ├── Neighborhood Command
        │       ├── TitleGenie
        │       ├── Marketing Hub
        │       ├── MLS Data/
        │       │   ├── SQL/
        │       │   ├── CSV/
        │       │   ├── Documentation/ (.md, .docx)
        │       │   └── [Other file types]
        │       └── [Other Main Genie apps]
        │
        ├── Genie Cloud
        │   └── Applications/
        │       └── [Genie Cloud applications]
        │
        ├── Genie WordPress
        │   └── Applications/
        │       └── [WordPress applications]
        │
        ├── Genie SQL
        │   └── Applications/
        │       └── [SQL applications]
        │
        └── APIs
            └── Applications/
                ├── APIs (as application)
                ├── Paisley (AskPaisley)
                ├── PUB
                └── ListMiner - GeoSocial Audience Builder
```

---

## 📚 LIBRARY SCIENCE CLASSIFICATION

### Level 1: Functional Area (Subject)
- Operations
- Growth
- Support
- Development

### Level 2: Content Type (Category)
- Plans
- Reports
- SOPs
- Presentations
- Specs (Development only)
- Scripts (Development only)

### Level 3: Platform (Development only - Subject subdivision)
- Main Genie
- Genie Cloud
- Genie WordPress
- Genie SQL
- APIs

### Level 4: Application (Development only - Item)
- Competition Command
- Listing Command
- Neighborhood Command
- etc.

### Level 5: Specific Item
- Individual reports, SOPs, specs, scripts

---

## 🎯 KEY STRUCTURAL DECISIONS

### 1. Platforms > Applications Hierarchy
- **Platforms** are the delivery mechanism (Main Genie, Genie Cloud, etc.)
- **Applications** are products delivered on those platforms
- This follows proper taxonomy: Platform (broader) → Application (specific)

### 2. Content Types Standardized
- All functional areas use same content types: Plans, Reports, SOPs, Presentations
- Development adds: Specs, Scripts
- This enables consistent navigation and classification

### 3. Sub-segmentation
- Each content type folder can be sub-segmented as needed
- Example: `Operations/Reports/CompetitionCommand/` or `Operations/Reports/Twilio/`
- Allows growth without restructuring

### 4. Scripts Linked to Products
- Scripts folder contains scripts that generate content
- Each script links to: Report, SOP, Plan, or Presentation it generates
- Maintains relationship between tool and output

### 5. 3rd Party Vendors
- Under Development/Specs/3rd Party Vendors
- Examples: Twilio (SMS infrastructure vendor)
- NOT applications - they're infrastructure/vendors

---

## 📋 CONTENT TYPE DEFINITIONS

### Plans
- Strategic plans, roadmaps, project plans
- Future-oriented content

### Reports
- Generated reports, analysis, data exports
- Historical/current state content

### SOPs (Standard Operating Procedures)
- Step-by-step procedures
- How-to documentation

### Presentations
- Slide decks, demos, training materials
- Visual/communication content

### Specs (Development only)
- Technical specifications
- Source code documentation
- 3rd party vendor documentation

### Scripts (Development only)
- Code that generates reports, SOPs, plans, presentations
- Automation tools
- Linked to their outputs

---

## ✅ STRUCTURE VALIDATION

### Library Science Principles Applied:
1. ✅ **Subject First** - Functional areas (Operations, Growth, etc.)
2. ✅ **Category Second** - Content types (Reports, SOPs, etc.)
3. ✅ **Item Third** - Specific files/documents
4. ✅ **Hierarchical** - Platforms > Applications
5. ✅ **Scalable** - Sub-segmentation supported

### Information Architecture Best Practices:
1. ✅ **Consistent Navigation** - Same structure across functions
2. ✅ **Logical Grouping** - Related content together
3. ✅ **Clear Hierarchy** - Platform > Application
4. ✅ **Flexible** - Can grow without restructuring
5. ✅ **Findable** - Clear paths to content

---

## 🎯 NEXT: CONFIRM STRUCTURE

**Does this structure:**
1. ✅ Fix Platforms > Applications hierarchy?
2. ✅ Follow Library Science best practices?
3. ✅ Support your logical organization (Operations, Growth, Support, Development)?
4. ✅ Allow for sub-segmentation as you grow?
5. ✅ Match your vision?

**Once confirmed, we proceed to Step 3: Pattern Matching Rules**

---

*This structure is based on Information Architecture and Library Science best practices, not on the messy Cursor file structure.*

