# Frontend UI Specialist - Action Plan (URGENT)

**From:** JR (Project Manager)  
**To:** Frontend UI Specialist  
**Date:** 01/14/2026 1:35 AM  
**Status:** 🚨 **START NOW**

---

## 🎯 YOUR TASK

**Build React Kanban board frontend for Task Manager**  
**Time:** 2-3 minutes  
**API Ready:** ✅ Backend API is running on http://localhost:5000

---

## 📋 STEP-BY-STEP INSTRUCTIONS

### Step 1: Open the Blueprint

**File:** `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md`  
**Lines to use:** 320-547 (Frontend React code)

### Step 2: Create React App

Open terminal in workspace root and run:

```bash
npm create vite@latest task-manager-ui -- --template react-ts
cd task-manager-ui
```

### Step 3: Install Dependencies

```bash
npm install @tanstack/react-query @dnd-kit/core @dnd-kit/sortable axios lucide-react
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### Step 4: Configure Tailwind CSS

Update `tailwind.config.js`:

```js
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

Add to `src/index.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Step 5: Create API Service

**File:** `src/services/api.ts`

Use blueprint lines 498-547 (copy the api.ts code exactly)

**Key:** Base URL is `http://localhost:5000/api`

### Step 6: Create Components

**From Blueprint:**

1. **KanbanBoard.tsx** - Lines 372-424
   - Location: `src/components/Board/KanbanBoard.tsx`

2. **TaskCard.tsx** - Lines 427-495
   - Location: `src/components/Board/TaskCard.tsx`

3. **Column.tsx** - Create basic column component (or use blueprint structure)

4. **Types** - Create `src/types/index.ts` with Task, Project interfaces

### Step 7: Create Basic App Structure

**File:** `src/App.tsx`:

```tsx
import { useState } from 'react';
import KanbanBoard from './components/Board/KanbanBoard';

function App() {
  const [projectId] = useState(1); // Default project for now

  return (
    <div className="h-screen bg-gray-100">
      <header className="bg-white shadow p-4">
        <h1 className="text-2xl font-bold">Task Manager</h1>
      </header>
      <main className="h-[calc(100vh-80px)]">
        <KanbanBoard projectId={projectId} />
      </main>
    </div>
  );
}

export default App;
```

### Step 8: Test the App

```bash
npm run dev
```

**Expected:** App runs on `http://localhost:3000`

**Verify:**
- ✅ App loads without errors
- ✅ Kanban board displays (5 columns: Backlog, To Do, In Progress, In Review, Done)
- ✅ Can connect to API (check browser console for API calls)
- ✅ Drag-and-drop works (if tasks exist)

### Step 9: Signal Completion

**Update:** `AgentCollaboration/HANDOFFS_v1.md`

Add this entry:

```markdown
### Handoff #3 - Frontend UI Specialist → Project Manager

**Date:** 01/14/2026 [TIME]
**From:** Frontend UI Specialist
**To:** Project Manager
**Status:** ✅ Complete

**Deliverable:** React Kanban board running on localhost:3000

**Location:**
- App URL: http://localhost:3000
- Project Location: `task-manager-ui/` (in workspace root)
- API Connection: http://localhost:5000/api

**Key Information:**
- ✅ React app created with Vite + TypeScript
- ✅ Kanban board with 5 columns (Backlog, To Do, In Progress, In Review, Done)
- ✅ Drag-and-drop functionality implemented (@dnd-kit)
- ✅ Connected to Backend API (localhost:5000)
- ✅ Tailwind CSS configured for styling

**Testing Status:**
- ✅ App builds and runs successfully
- ✅ Kanban board displays correctly
- ✅ API connection verified
- ✅ Drag-and-drop tested (if tasks exist)

**Known Issues:**
- None - ready for PM use

**Next Steps:**
- PM can now access Task Manager at http://localhost:3000
- Create projects and tasks via API or UI
- Full 7-minute setup complete!
```

**Also update:** `AgentStatus/AGENT_STATUS_FRONTEND_UI_v1.md`

- Mark task as complete
- Update status to "✅ Frontend Ready"

---

## ✅ SUCCESS CRITERIA

- [ ] React app created with Vite + TypeScript
- [ ] All dependencies installed
- [ ] Tailwind CSS configured
- [ ] API service created and connected to localhost:5000
- [ ] Kanban board component displays 5 columns
- [ ] App runs on localhost:3000
- [ ] Drag-and-drop functionality works
- [ ] Handoff signal sent to Project Manager

---

## 🚨 IMPORTANT NOTES

1. **API is Ready** - Backend API is running on http://localhost:5000 (Handoff #2 complete)
2. **Quick Task** - This should take 2-3 minutes
3. **Blueprint Reference** - Use blueprint lines 320-547 for exact code
4. **CORS** - Backend API already has CORS enabled for localhost:3000

---

## 📞 IF YOU GET STUCK

1. Check blueprint: `AgentCollaboration/Project Management/extracted/project-manager-blueprint.md` (lines 320-547)
2. Check Handoff #2: `AgentCollaboration/HANDOFFS_v1.md` for API details
3. Document blocker in: `AgentCollaboration/BLOCKERS_v1.md`
4. Tag JR (Project Manager) for help

---

## 🎯 QUICK REFERENCE

**API Endpoints (from Handoff #2):**
- Base URL: `http://localhost:5000/api`
- Auth: `POST /api/auth/register`, `POST /api/auth/login`
- Projects: `GET /api/projects`, `POST /api/projects`
- Tasks: `GET /api/tasks/project/{id}`, `POST /api/tasks`, `PUT /api/tasks/{id}/move`
- Swagger: `http://localhost:5000/swagger`

**Blueprint Sections:**
- Frontend Structure: Lines 320-352
- Dependencies: Lines 354-369
- KanbanBoard: Lines 372-424
- TaskCard: Lines 427-495
- API Service: Lines 498-547

---

**Status:** 🚀 **START NOW - 2-3 MINUTE TASK**
