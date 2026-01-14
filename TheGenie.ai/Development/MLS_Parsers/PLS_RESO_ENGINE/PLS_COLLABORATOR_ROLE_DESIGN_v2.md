# PLS Collaborator Role Design Analysis
**Version:** 2.0  
**Created:** 01/05/2026  
**Last Updated:** 01/05/2026  
**Author:** Cursor AI Agent  
**Purpose:** Analysis of collaborator role lookup table design and usage

---

## 🎯 CURRENT DESIGN: pls_collaborator_role Lookup Table

### ⚠️ CLARIFICATION NEEDED: Purpose of Collaborator Roles

**Your Question:** "Is the intent to decide who has permission to view, edit or add a new PLS listing?"

**Current Design Intent (Unclear):**
The `pls_collaborator_role` table was designed to track **relationship types** (who is involved), but the **actual permissions** are controlled by the existing `Permission` table (210-214).

### Current Permission Model (Separate from Collaborator Roles)

**Permissions are controlled by `Permission` table:**
- **210: ManagePLS** - Create/edit/delete PLS listings
- **211: Menu PLS** - Access PLS menu item
- **212: View PLS History** - View status log
- **213: PLS Radar** - View all PLS listings (admin)
- **214: PLS Submit While Impersonating** - Submit as another user

**Access Control Logic:**
1. **Create/Edit:** Requires Permission 210 (Elite Agent or higher)
2. **View:** Requires Permission 211 (Menu PLS)
3. **View All:** Requires Permission 213 (Admin)
4. **Ownership:** `pls_tracking.agent_id` = listing owner
5. **Collaborators:** Tracked in `pls_collaborators` but permissions come from Permission table

### Two Possible Designs

#### Design A: Collaborator Roles = Relationship Tracking Only
**Purpose:** Track WHO is involved, but permissions come from Permission table

```
Collaborator Role → Relationship Type Only
├── title_rep = "This person is the title rep for this listing"
└── co_lister = "This person is a co-listing agent"

Permissions → Controlled by Permission Table (210-214)
├── Permission 210 = Can create/edit
├── Permission 211 = Can view
└── Application logic: "If user is collaborator AND has Permission 211, allow view"
```

**Usage:**
- Collaborator roles are **informational** (who is involved)
- Actual access controlled by **Permission table**
- Application checks: "Is user a collaborator? Do they have Permission 211?"

#### Design B: Collaborator Roles = Permission Control
**Purpose:** Collaborator roles directly control permissions

```
Collaborator Role → Permission Level
├── title_rep = View only (no edit)
└── co_lister = Can edit (shared ownership)

Permissions → Additional system-level permissions
├── Permission 210 = Can create new listings
└── Collaborator role = Can edit specific listing
```

**Usage:**
- Collaborator roles **control access** to specific listings
- Permission 210 = Can create listings
- Collaborator role = Can edit/view specific listing

### Current Roles (Only 2)

| role_id | role_code | role_name | Description |
|---------|-----------|-----------|-------------|
| 1 | title_rep | Title Representative | Title company representative |
| 2 | co_lister | Co-Listing Agent | Co-listing agent |

**Question:** Do these roles control permissions, or just track relationships?

---

## ❓ DESIGN QUESTION

**For only 2 static roles, is a lookup table necessary?**

### Option 1: Keep Lookup Table (Current Design)
**Pros:**
- ✅ Consistent with other normalized lookup tables
- ✅ Easy to add new roles in future
- ✅ Display names stored in database
- ✅ Can disable roles without data deletion
- ✅ Follows normalization best practices

**Cons:**
- ❌ Over-engineered for just 2 roles
- ❌ Extra JOIN required for queries
- ❌ Additional table to maintain
- ❌ More complex than needed

### Option 2: Use TINYINT with Constants
**Simpler approach:**
```sql
CREATE TABLE dbo.pls_collaborators (
    ...
    role_type_id TINYINT NOT NULL,
        -- 1 = Title Representative
        -- 2 = Co-Listing Agent
    ...
    CONSTRAINT CK_pls_collaborators_role CHECK (role_type_id IN (1, 2))
);
```

**Pros:**
- ✅ Simpler - no lookup table needed
- ✅ Faster queries (no JOIN)
- ✅ Less overhead
- ✅ Still normalized (integer, not string)

**Cons:**
- ❌ Display names in application code
- ❌ Harder to add new roles (schema change)
- ❌ Less flexible

### Option 3: Use CHECK Constraint with String (v1.1 approach)
**Original denormalized approach:**
```sql
CREATE TABLE dbo.pls_collaborators (
    ...
    role NVARCHAR(50) NOT NULL,
    CONSTRAINT CK_pls_collaborators_role CHECK (role IN ('title_rep', 'co_lister'))
);
```

**Pros:**
- ✅ Simplest approach
- ✅ No lookup table
- ✅ No JOIN needed
- ✅ Easy to read in queries

**Cons:**
- ❌ Not normalized (string storage)
- ❌ Display names in application code
- ❌ Harder to add new roles (schema change)
- ❌ Inconsistent with other normalized tables

---

## 🔍 INTENDED USAGE SCENARIOS

### Scenario 1: Adding a Collaborator
```sql
-- Current (Normalized v2.0):
DECLARE @role_id TINYINT = (SELECT role_id FROM pls_collaborator_role WHERE role_code = 'title_rep');
INSERT INTO pls_collaborators (listing_id, user_id, role_id)
VALUES (12345, 'user-guid', @role_id);

-- Or using view:
INSERT INTO pls_collaborators (listing_id, user_id, role_id)
SELECT 12345, 'user-guid', role_id 
FROM pls_collaborator_role 
WHERE role_code = 'title_rep';
```

### Scenario 2: Querying Collaborators with Display Names
```sql
-- Current (Normalized v2.0):
SELECT 
    pc.listing_id,
    u.Email,
    pcr.role_name AS role_display_name,
    pc.joined_at
FROM pls_collaborators pc
INNER JOIN AspNetUsers u ON u.Id = pc.user_id
INNER JOIN pls_collaborator_role pcr ON pcr.role_id = pc.role_id
WHERE pc.listing_id = 12345;
```

### Scenario 3: Permission-Based Access Control
**CRITICAL QUESTION:** How should collaborator roles interact with permissions?

#### Option A: Roles Control Permissions (Permission Control)
**Design:** Collaborator roles directly grant/deny access

```
Access Logic:
├── Listing Owner (pls_tracking.agent_id)
│   └── Full access (create, edit, delete, publish)
├── Co-Lister (role = 'co_lister')
│   └── Can edit listing (shared ownership)
└── Title Rep (role = 'title_rep')
    └── View only (no edit)
```

**Database Changes Needed:**
- Add `can_edit BIT` to `pls_collaborator_role` table
- Add `can_view BIT` to `pls_collaborator_role` table
- Application checks role permissions, not Permission table

#### Option B: Roles Are Informational (Current Assumption)
**Design:** Roles track relationships, Permission table controls access

```
Access Logic:
├── Permission 210 (ManagePLS) = Can create/edit listings
├── Permission 211 (Menu PLS) = Can view listings
└── Collaborator = Can view THIS listing (if has Permission 211)
    └── Still needs Permission 210 to edit
```

**Database:** No changes needed - roles are relationship tracking only

#### Option C: Hybrid (Recommended)
**Design:** Roles indicate relationship + permission level

```
Access Logic:
├── Listing Owner
│   └── Full access (via Permission 210)
├── Co-Lister
│   └── Can edit THIS listing (even without Permission 210 for other listings)
└── Title Rep
    └── Can view THIS listing (even without Permission 211 for other listings)
```

**Database Changes Needed:**
- Add permission flags to `pls_collaborator_role`:
  - `can_view_listing BIT` - Can view this specific listing
  - `can_edit_listing BIT` - Can edit this specific listing
- Application logic: "If collaborator on listing, grant listing-specific permissions"

---

## 💡 RECOMMENDATION

### If Roles Are Static (Unlikely to Change)
**Recommendation:** Use **Option 2 (TINYINT with constants)**

```sql
CREATE TABLE dbo.pls_collaborators (
    id INT IDENTITY(1,1) NOT NULL,
    listing_id INT NOT NULL,
    user_id NVARCHAR(450) NOT NULL,
    role_type_id TINYINT NOT NULL,
        -- 1 = Title Representative (view only)
        -- 2 = Co-Listing Agent (can edit)
    joined_at DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT PK_pls_collaborators PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pls_collaborators_user FOREIGN KEY (user_id) 
        REFERENCES dbo.AspNetUsers(Id) ON DELETE CASCADE,
    CONSTRAINT CK_pls_collaborators_role CHECK (role_type_id IN (1, 2)),
    CONSTRAINT UQ_pls_collaborators_listing_user_role UNIQUE (listing_id, user_id, role_type_id)
);
```

**Benefits:**
- Still normalized (integer, not string)
- No lookup table overhead
- Faster queries
- Simpler for 2 static roles

### If Roles May Expand (Future-Proof)
**Recommendation:** Keep **Option 1 (Lookup Table)**

**Future roles might include:**
- Photographer
- Stager
- Lender
- Inspector
- Transaction Coordinator
- Marketing Specialist

**If this is likely, lookup table is worth it.**

---

## 🎯 CRITICAL QUESTIONS FOR CLARIFICATION

### Question 1: What is the PRIMARY purpose of collaborator roles?

**A. Permission Control (Roles grant access)**
- Co-Lister can edit the listing (even without Permission 210)
- Title Rep can view the listing (even without Permission 211)
- Roles override or supplement Permission table

**B. Relationship Tracking (Roles are informational)**
- Roles just indicate "who is involved"
- Actual access still requires Permission table (210-214)
- Collaborators need Permission 211 to view, Permission 210 to edit

**C. Hybrid (Roles grant listing-specific permissions)**
- Permission 210 = Can create new listings
- Collaborator role = Can access THIS specific listing
- Co-Lister can edit THIS listing without Permission 210
- Title Rep can view THIS listing without Permission 211

### Question 2: Access Control Scenarios

**Scenario A: Title Rep wants to view listing**
- Do they need Permission 211 (Menu PLS)?
- Or does being a collaborator grant access automatically?

**Scenario B: Co-Lister wants to edit listing**
- Do they need Permission 210 (ManagePLS)?
- Or does being a co-lister grant edit access automatically?

**Scenario C: User wants to create new listing**
- Always requires Permission 210 (ManagePLS)?
- Or can co-lister create if they have Permission 210?

### Question 3: Will collaborator roles expand beyond 2?
- If yes → Keep lookup table (easier to add new roles)
- If no → Could simplify to TINYINT constants

### Question 4: Preference for consistency vs simplicity?
- Consistent with other lookup tables → Keep lookup table
- Simpler for just 2 roles → Use TINYINT constants

---

## 📊 COMPARISON TABLE

| Aspect | Lookup Table | TINYINT Constants | String CHECK |
|--------|--------------|-------------------|--------------|
| **Normalization** | ✅ Full 3NF | ✅ Normalized (int) | ❌ Denormalized |
| **Storage** | 1 byte + lookup | 1 byte | ~50 bytes |
| **Query Performance** | JOIN required | Direct | Direct |
| **Add New Role** | INSERT | Schema change | Schema change |
| **Display Names** | ✅ In DB | ❌ In code | ❌ In code |
| **Consistency** | ✅ Matches other lookups | ⚠️ Different pattern | ❌ Not normalized |
| **Complexity** | Higher | Lower | Lowest |
| **Future-Proof** | ✅ Yes | ❌ No | ❌ No |

---

## 🔄 PROPOSED DESIGN OPTIONS

### Option 1: Permission Control Design (If Roles Control Access)

**Enhanced Lookup Table:**
```sql
CREATE TABLE dbo.pls_collaborator_role (
    role_id TINYINT IDENTITY(1,1) NOT NULL,
    role_code NVARCHAR(50) NOT NULL,
    role_name NVARCHAR(100) NOT NULL,
    can_view_listing BIT NOT NULL DEFAULT 1,  -- NEW: Permission flag
    can_edit_listing BIT NOT NULL DEFAULT 0,  -- NEW: Permission flag
    description NVARCHAR(500) NULL,
    display_order TINYINT NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    ...
);
```

**Master Data:**
- title_rep: `can_view_listing = 1`, `can_edit_listing = 0` (view only)
- co_lister: `can_view_listing = 1`, `can_edit_listing = 1` (can edit)

**Access Logic:**
```sql
-- Check if user can edit listing
SELECT 
    CASE 
        WHEN pt.agent_id = @userId THEN 1  -- Owner always can
        WHEN pc.role_id IS NOT NULL AND pcr.can_edit_listing = 1 THEN 1  -- Collaborator with edit permission
        ELSE 0
    END AS can_edit
FROM pls_tracking pt
LEFT JOIN pls_collaborators pc ON pc.listing_id = pt.listing_id AND pc.user_id = @userId
LEFT JOIN pls_collaborator_role pcr ON pcr.role_id = pc.role_id
WHERE pt.listing_id = @listingId;
```

### Option 2: Relationship Tracking Only (Simpler)

**Remove lookup table, use TINYINT:**
```sql
CREATE TABLE dbo.pls_collaborators (
    ...
    role_type_id TINYINT NOT NULL,
        -- 1 = Title Representative (informational)
        -- 2 = Co-Listing Agent (informational)
    ...
    CONSTRAINT CK_pls_collaborators_role CHECK (role_type_id IN (1, 2))
);
```

**Access Logic:**
- Permissions come from Permission table (210-214)
- Collaborator role is just for display/relationship tracking
- Application checks: "Is user collaborator? Do they have Permission 211?"

### Option 3: Hybrid (Recommended if Roles Grant Listing-Specific Access)

**Keep lookup table with permission flags:**
- Roles grant access to THIS specific listing
- Permission 210 still required to create NEW listings
- Best of both worlds: system permissions + listing-specific access

---

## 📚 RELATED DOCUMENTS

- **Normalized SQL Script:** `PLS_SCHEMA_EXTENSIONS_NORMALIZED_v2.sql`
- **Visual Diagram:** `PLS_SCHEMA_VISUAL_DIAGRAM_NORMALIZED_v2.md`

---

## 🔄 CHANGE LOG

| Version | Date | Changes |
|:-------:|------|---------|
| 2.0 | 01/05/2026 | Initial analysis - exploring design alternatives for collaborator roles |

---

**Status:** ⏳ Awaiting Decision - Should we keep lookup table or simplify to TINYINT constants?

**Your Input Needed:** How do you want to use collaborator roles, and will they expand beyond 2?

