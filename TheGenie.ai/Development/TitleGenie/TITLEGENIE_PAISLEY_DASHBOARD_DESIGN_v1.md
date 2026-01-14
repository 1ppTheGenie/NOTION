# TitleGenie Paisley Dashboard - Screen-by-Screen Design

**Version:** 1.0  
**Created:** December 22, 2025  
**Purpose:** Design document for TitleGenie Paisley Dashboard - one screen at a time

---

## Executive Summary

| Field | Value |
|-------|-------|
| **Purpose** | Give title reps a dedicated Paisley AI interface to generate content for agent outreach and relationship building |
| **Current State** | 0% complete — Design phase |
| **Key Outputs** | Screen-by-screen design specs for TitleGenie Paisley Dashboard |
| **Remaining Work** | Complete all screen designs, then build |
| **Last Validated** | December 22, 2025 |

---

## Screen 1: Main Dashboard Overview

### Purpose
First screen title reps see when they access Paisley. Shows quick stats, recent activity, and quick access to main features.

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  TITLEGENIE PAISLEY DASHBOARD                                    │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  [Welcome Back, [Title Rep Name]]                               │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Total Agents │  │ Invitations  │  │ This Month   │         │
│  │              │  │ Sent         │  │ Listing Cmds │         │
│  │      12      │  │              │  │              │         │
│  │              │  │      8       │  │      2/4      │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  QUICK START                                              │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [📧 Generate Agent Outreach Email]                      │  │
│  │  [📱 Create LinkedIn Message]                            │  │
│  │  [📞 Phone Call Script]                                  │  │
│  │  [📊 Agent Prospect Research]                           │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  RECENT ACTIVITY                                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  • 2 hours ago - Generated email for Sarah Johnson      │  │
│  │  • Yesterday - Created LinkedIn message for Mike Chen   │  │
│  │  • 2 days ago - Phone script for Lisa Martinez         │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  TOP AGENT PROSPECTS                                     │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [Agent Name] | [Zip Code] | [Listings Last Year]       │  │
│  │  Sarah Johnson | 92037 | 24 listings                    │  │
│  │  Mike Chen | 92130 | 18 listings                        │  │
│  │  Lisa Martinez | 92014 | 15 listings                    │  │
│  │                                                           │  │
│  │  [View All Prospects →]                                  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Header**
   - Title: "TitleGenie Paisley Dashboard"
   - Welcome message with title rep name

2. **Stats Cards (3 cards)**
   - Total Agents: Count of agents currently partnered
   - Invitations Sent: Count of invitations sent this month
   - Listing Commands Used: X/4 used this month

3. **Quick Start Section**
   - 4 primary action buttons:
     - Generate Agent Outreach Email
     - Create LinkedIn Message
     - Phone Call Script
     - Agent Prospect Research

4. **Recent Activity Feed**
   - List of last 5-10 Paisley actions
   - Timestamp and action type

5. **Top Agent Prospects**
   - Table showing top 3-5 agent prospects
   - Columns: Name, Zip Code, Listings Last Year
   - Link to full prospects list

### Data Requirements

- Title rep user ID
- Partnered agents count (from UserPartner table)
- Invitations sent this month (from InvitationManager)
- Listing Commands used this month (manual tracking for now)
- Recent Paisley chat history
- Agent prospect data (from Agent Mining database)

### Navigation

- Clicking any Quick Start button → Goes to Screen 2 (Chat Interface)
- Clicking "View All Prospects" → Goes to Screen 3 (Agent Mining)
- Clicking any Recent Activity item → Opens that chat conversation

---

## Screen 2: Paisley Chat Interface

### Purpose
Main interface where title reps interact with Paisley AI to generate agent outreach content. This is the core Paisley experience, customized for title rep use cases.

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  [← Back to Dashboard]  |  PAISLEY AI                            │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SELECT CHAT TYPE                                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │ 📧 Email     │  │ 📱 LinkedIn  │  │ 📞 Phone      │  │  │
│  │  │ Outreach     │  │ Message      │  │ Script       │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  │                                                           │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │ 📊 Prospect  │  │ 📝 Follow-Up │  │ 💬 General   │  │  │
│  │  │ Research     │  │ Sequence     │  │ Chat         │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SELECT AGENT PROSPECT                                   │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [Search agents...]                                      │  │
│  │                                                           │  │
│  │  ○ Sarah Johnson - 92037 - 24 listings last year       │  │
│  │  ○ Mike Chen - 92130 - 18 listings last year            │  │
│  │  ○ Lisa Martinez - 92014 - 15 listings last year        │  │
│  │  ○ [Create New Prospect]                                 │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CUSTOMIZE CONTENT                                       │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  Format: [Email ▼]  Tone: [Professional ▼]              │  │
│  │  Audience: [Agent Prospect ▼]  Style: [Conversational ▼] │  │
│  │                                                           │  │
│  │  [⚙️ Advanced Options]                                  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CHAT CONVERSATION                                        │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ Paisley:                                          │  │  │
│  │  │                                                    │  │  │
│  │  │ I see you're reaching out to Sarah Johnson, who   │  │  │
│  │  │ closed 24 listings in 92037 last year. Here's a  │  │  │
│  │  │ personalized email to introduce TitleGenie...      │  │  │
│  │  │                                                    │  │  │
│  │  │ [Generated Email Content]                         │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ You: Can you make it more casual?                 │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ Paisley:                                          │  │  │
│  │  │                                                    │  │  │
│  │  │ [Revised Email Content - More Casual Tone]        │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  [Type your message...]  [📎]  [🎤]  [Send]              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ACTIONS                                                  │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [📋 Copy to Clipboard]  [📧 Send Email]  [💾 Save]    │  │
│  │  [🔄 Regenerate]  [📤 Export]                           │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Chat Type Selection (6 types for Title Reps)**
   - Email Outreach (Chat Type #8)
   - LinkedIn Message
   - Phone Script
   - Prospect Research
   - Follow-Up Sequence
   - General Chat

2. **Agent Prospect Selector**
   - Search/filter agents
   - Select from existing prospects
   - Option to create new prospect
   - Shows agent stats (zip code, listings last year)

3. **Content Customization (Vibe Options)**
   - Format: Email, Text, Letter, Social Post
   - Tone: Professional, Friendly, Casual
   - Audience: Agent Prospect, Existing Partner, etc.
   - Writing Style: Formal, Conversational
   - Advanced Options: Language, length, specific instructions

4. **Chat Conversation Area**
   - Message history with Paisley
   - Streaming responses (real-time)
   - User can ask follow-up questions
   - Edit/refine generated content

5. **Input Area**
   - Text input
   - Attach files (optional)
   - Voice input (optional)
   - Send button

6. **Action Buttons**
   - Copy to Clipboard
   - Send Email (if email type)
   - Save to Library
   - Regenerate
   - Export (PDF, DOCX, etc.)

### Data Requirements

- Chat Type ID (8 for Title Rep Outreach)
- Selected Agent Prospect data:
  - Agent name
  - Zip code(s)
  - Listings last year
  - Brokerage
  - Contact info (if available)
- Title rep profile data:
  - Name
  - Company
  - Territory
- Vibe options from database
- Chat history (previous conversations)

### Navigation

- Back button → Returns to Screen 1 (Dashboard)
- Selecting different chat type → Refreshes interface with that type
- Selecting different agent → Loads that agent's data into context
- Clicking "Save" → Saves to Screen 4 (Content Library)

### Special Features

1. **Data-Driven Personalization**
   - Paisley automatically includes agent stats in prompts
   - Example: "You closed 12 listings in 92037 last year..."
   - Pulls from Agent Mining database

2. **Multi-Turn Conversations**
   - User can refine content through conversation
   - Paisley remembers context within session
   - Can ask for variations, edits, follow-ups

3. **Quick Actions**
   - Pre-filled prompts for common scenarios
   - "Generate cold outreach email"
   - "Create follow-up sequence"
   - "Research agent and create pitch"

---

## Screen 3: Agent Mining & Prospect Management

### Purpose
Help title reps discover top agent prospects in their territory, view agent analytics, and manage their prospect list. This is the "Agent Scorecard" and "Agent Mining" feature from the MVP roadmap.

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  [← Back to Dashboard]  |  AGENT MINING                         │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SEARCH & FILTER                                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [Search by name, zip, brokerage...]                     │  │
│  │                                                           │  │
│  │  Zip Code: [92037 ▼]  Brokerage: [All ▼]               │  │
│  │  Listings Range: [10+]  Sort By: [Listings ▼]           │  │
│  │                                                           │  │
│  │  [🔍 Search]  [🔄 Reset]                                │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  TOP AGENT PROSPECTS - ZIP 92037                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ Sarah Johnson                    [⭐ Add Prospect] │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Brokerage: Coldwell Banker                         │  │  │
│  │  │ Zip Codes: 92037, 92014                            │  │  │
│  │  │ Listings Last Year: 24                             │  │  │
│  │  │ Sales Volume: $18.5M                               │  │  │
│  │  │ Avg Days on Market: 32                             │  │  │
│  │  │                                                    │  │  │
│  │  │ [📊 View Full Profile]  [📧 Generate Outreach]    │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ Mike Chen                          [⭐ Add Prospect]│  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Brokerage: Berkshire Hathaway                      │  │  │
│  │  │ Zip Codes: 92130, 92131                           │  │  │
│  │  │ Listings Last Year: 18                             │  │  │
│  │  │ Sales Volume: $14.2M                              │  │  │
│  │  │ Avg Days on Market: 28                             │  │  │
│  │  │                                                    │  │  │
│  │  │ [📊 View Full Profile]  [📧 Generate Outreach]    │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ Lisa Martinez                       [⭐ Add Prospect]│  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Brokerage: Compass                                 │  │  │
│  │  │ Zip Codes: 92014                                   │  │  │
│  │  │ Listings Last Year: 15                             │  │  │
│  │  │ Sales Volume: $11.8M                               │  │  │
│  │  │ Avg Days on Market: 35                             │  │  │
│  │  │                                                    │  │  │
│  │  │ [📊 View Full Profile]  [📧 Generate Outreach]    │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  [Load More Results...]                                 │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  MY PROSPECTS (12)                                       │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [View All →]                                            │  │
│  │                                                           │  │
│  │  • Sarah Johnson - 92037 - Outreach sent 2 days ago     │  │
│  │  • Mike Chen - 92130 - No outreach yet                  │  │
│  │  • Lisa Martinez - 92014 - Follow-up scheduled          │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Search & Filter Bar**
   - Text search (name, zip, brokerage)
   - Zip code dropdown
   - Brokerage filter
   - Listings range filter (e.g., 10+ listings)
   - Sort options (Listings, Volume, Days on Market)

2. **Agent Prospect Cards**
   - Agent name
   - Brokerage
   - Zip codes they work
   - Key metrics:
     - Listings last year
     - Sales volume
     - Average days on market
   - Action buttons:
     - Add to Prospects
     - View Full Profile
     - Generate Outreach (goes to Screen 2)

3. **My Prospects Section**
   - Quick view of saved prospects
   - Status indicators (outreach sent, follow-up scheduled, etc.)
   - Link to full prospects list

### Data Requirements

- MLS data (agent transactions)
- Agent name, brokerage, zip codes
- Listings count (last 12 months)
- Sales volume (last 12 months)
- Average days on market
- Title rep's saved prospects list
- Outreach history (if tracked)

### Navigation

- Back button → Returns to Screen 1 (Dashboard)
- "Add Prospect" → Adds agent to "My Prospects"
- "View Full Profile" → Opens detailed agent profile modal
- "Generate Outreach" → Goes to Screen 2 (Chat Interface) with agent pre-selected
- "View All" (My Prospects) → Goes to Screen 4 (Prospects List)

### Special Features

1. **Patented Farm Analyzer Integration**
   - Shows market opportunity data
   - Highlights agents in high-opportunity areas
   - Data-driven prospect ranking

2. **Agent Scorecard Data**
   - Comprehensive agent performance metrics
   - Comparison to market averages
   - Trend analysis (improving/declining)

3. **Bulk Actions**
   - Select multiple agents
   - Generate batch outreach
   - Export prospect list

---

## Screen 4: Content Library & Saved Conversations

### Purpose
Title reps can save, organize, and reuse all content generated by Paisley. This includes emails, scripts, research notes, and full conversation histories.

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  [← Back to Dashboard]  |  CONTENT LIBRARY                      │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  FILTERS & SEARCH                                        │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [Search content...]                                      │  │
│  │                                                           │  │
│  │  Type: [All ▼]  Agent: [All ▼]  Date: [Last 30 Days ▼] │  │
│  │                                                           │  │
│  │  [🔍 Search]  [🔄 Reset]                                │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SAVED CONTENT                                           │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 📧 Email - Sarah Johnson                          │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Created: 2 days ago                               │  │  │
│  │  │ Subject: Introducing TitleGenie - 92037 Market...   │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View]  [📋 Copy]  [📧 Send]  [🗑️ Delete]    │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 📱 LinkedIn - Mike Chen                             │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Created: 5 days ago                                │  │  │
│  │  │ Preview: Hi Mike, I noticed you closed 18 listings...│  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View]  [📋 Copy]  [📤 Share]  [🗑️ Delete]   │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 📞 Phone Script - Lisa Martinez                      │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Created: 1 week ago                                │  │  │
│  │  │ Talking Points: 15 listings, 92014 market...       │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View]  [📋 Copy]  [📞 Call]  [🗑️ Delete]    │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 📊 Research - Sarah Johnson                         │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Created: 2 weeks ago                                │  │  │
│  │  │ Summary: 24 listings, $18.5M volume, Coldwell...   │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View]  [📋 Copy]  [📤 Export]  [🗑️ Delete]  │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CONVERSATION HISTORY                                    │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 💬 Conversation with Paisley - Sarah Johnson       │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Started: 2 days ago                                │  │  │
│  │  │ Messages: 8                                         │  │  │
│  │  │ Last message: "Can you make it more casual?"        │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View Full Conversation]  [🔄 Continue Chat]  │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 💬 Conversation with Paisley - Mike Chen            │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Started: 5 days ago                                │  │  │
│  │  │ Messages: 4                                         │  │  │
│  │  │ Last message: "Generate LinkedIn message"          │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View Full Conversation]  [🔄 Continue Chat]  │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ACTIONS                                                  │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [📤 Export All]  [🗂️ Organize]  [📥 Import]          │  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Filters & Search**
   - Text search across all saved content
   - Filter by content type (Email, LinkedIn, Phone, Research)
   - Filter by agent name
   - Filter by date range

2. **Saved Content Cards**
   - Content type icon (📧 📱 📞 📊)
   - Agent name
   - Creation date
   - Preview/summary
   - Action buttons:
     - View (full content)
     - Copy (to clipboard)
     - Send/Share (context-specific)
     - Delete

3. **Conversation History**
   - List of all Paisley conversations
   - Shows agent name, start date, message count
   - Last message preview
   - Actions:
     - View Full Conversation
     - Continue Chat (resume conversation)

4. **Bulk Actions**
   - Export All (PDF, DOCX, CSV)
   - Organize (folders/tags)
   - Import (from other sources)

### Data Requirements

- Saved content records:
  - Content type
  - Agent name
  - Generated content text
  - Creation date
  - Metadata (subject, preview, etc.)
- Conversation history:
  - Chat ID
  - Agent name
  - Message count
  - Last message
  - Full message history

### Navigation

- Back button → Returns to Screen 1 (Dashboard)
- "View" → Opens content in modal or full screen
- "Continue Chat" → Goes to Screen 2 (Chat Interface) with conversation history loaded
- "Send Email" → Opens email client or sends via integration
- "Export" → Downloads content in selected format

### Special Features

1. **Content Templates**
   - Save successful content as templates
   - Reuse for similar agents
   - Customize template variables

2. **Content Analytics**
   - Track which content gets responses
   - Success rate by content type
   - Best performing templates

3. **Organization Tools**
   - Folders/tags for organizing content
   - Favorites/starred items
   - Archive old content

---

## Screen 5: Agent Invitation Management

### Purpose
Title reps can view all their agent invitations, track acceptance status, manage partnerships, and see agent activity. This integrates with the existing InvitationManager system.

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  [← Back to Dashboard]  |  AGENT INVITATIONS                    │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Total        │  │ Accepted     │  │ Pending      │         │
│  │ Invitations  │  │              │  │              │         │
│  │              │  │              │  │              │         │
│  │      25      │  │      12       │  │      8        │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  INVITE NEW AGENT                                       │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  Agent Email: [________________________]                  │  │
│  │  Agent Name: [________________________]                  │  │
│  │  Optional Message: [________________________]           │  │
│  │                                                           │  │
│  │  [📧 Use Paisley to Generate Invitation Email]          │  │
│  │  [✉️ Send Invitation]                                   │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  MY AGENTS (12 Active Partners)                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ ✅ Sarah Johnson - Active Partner                  │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Joined: 3 months ago                               │  │  │
│  │  │ Last Activity: 2 days ago                         │  │  │
│  │  │ Listings This Month: 2                            │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View Dashboard]  [📧 Contact]  [📊 Analytics] │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ ✅ Mike Chen - Active Partner                       │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Joined: 2 months ago                              │  │  │
│  │  │ Last Activity: 1 week ago                         │  │  │
│  │  │ Listings This Month: 1                            │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View Dashboard]  [📧 Contact]  [📊 Analytics] │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  PENDING INVITATIONS (8)                                 │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ ⏳ Lisa Martinez                                    │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Invited: 5 days ago                                │  │  │
│  │  │ Status: Email sent, awaiting response              │  │  │
│  │  │                                                    │  │  │
│  │  │ [📧 Resend Invitation]  [📝 Follow-Up Email]      │  │  │
│  │  │ [🗑️ Cancel Invitation]                           │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ ⏳ John Smith                                       │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Invited: 2 weeks ago                              │  │  │
│  │  │ Status: Email sent, no response                   │  │  │
│  │  │                                                    │  │  │
│  │  │ [📧 Resend Invitation]  [📝 Follow-Up Email]      │  │  │
│  │  │ [🗑️ Cancel Invitation]                           │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  INVITATION LIMIT                                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  You have used 12 of 50 available invitations            │  │
│  │  [████████░░░░░░░░░░░░] 24% used                         │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Stats Cards (3 cards)**
   - Total Invitations: All-time count
   - Accepted: Number of active partnerships
   - Pending: Invitations awaiting response

2. **Invite New Agent Form**
   - Agent email input
   - Agent name input
   - Optional custom message
   - "Use Paisley" button (generates invitation email via Screen 2)
   - Send Invitation button

3. **My Agents Section (Active Partners)**
   - List of all accepted agents
   - Status: Active Partner
   - Key metrics:
     - Join date
     - Last activity
     - Listings this month
   - Actions:
     - View Dashboard (agent's TheGenie dashboard)
     - Contact (email/phone)
     - Analytics (agent performance)

4. **Pending Invitations Section**
   - List of invitations not yet accepted
   - Status indicators
   - Invitation date
   - Actions:
     - Resend Invitation
     - Follow-Up Email (via Paisley)
     - Cancel Invitation

5. **Invitation Limit Tracker**
   - Progress bar showing X/50 used
   - Visual indicator of remaining invitations
   - Note: Manual enforcement for MVP (Phase 1)

### Data Requirements

- Title rep user ID
- Invitation records (from InvitationManager):
  - Agent email
  - Invitation date
  - Status (pending, accepted, declined)
  - Response date
- Partnership records (from UserPartner table):
  - Agent user ID
  - Partnership date
  - Status
- Agent activity data:
  - Last login
  - Listings this month
  - Platform usage

### Navigation

- Back button → Returns to Screen 1 (Dashboard)
- "Use Paisley" → Goes to Screen 2 (Chat Interface) with invitation email template
- "View Dashboard" → Opens agent's TheGenie dashboard (existing feature)
- "Follow-Up Email" → Goes to Screen 2 (Chat Interface) with follow-up template
- "Analytics" → Shows agent performance metrics

### Special Features

1. **Paisley Integration**
   - Generate personalized invitation emails
   - Create follow-up sequences
   - Customize messaging per agent

2. **Invitation Tracking**
   - Track email opens (if available)
   - Track link clicks
   - Reminder notifications for pending invitations

3. **Agent Lock Feature**
   - Once agent accepts, they're "locked" to this title rep
   - Prevents other title reps from inviting same agent
   - Exclusive partnership

4. **Bulk Invitations**
   - Select multiple prospects
   - Send batch invitations
   - Track all in one place

---

## Screen 6: Listing Command Management

### Purpose
Title reps can view their monthly Listing Command allocation (4 per month), gift Listing Commands to agents, and track usage. This is a key part of the $250/month offer.

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  [← Back to Dashboard]  |  LISTING COMMANDS                      │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  MONTHLY ALLOCATION                                      │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  This Month (December 2025):                            │  │
│  │  [████████░░░░░░░░░░░░] 2 of 4 used (50%)               │  │
│  │                                                           │  │
│  │  Next Reset: January 1, 2026                             │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  GIFT A LISTING COMMAND                                 │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  Select Agent: [Sarah Johnson ▼]                        │  │
│  │                                                           │  │
│  │  Listing Address: [________________________]            │  │
│  │  (Optional - can be added later)                        │  │
│  │                                                           │  │
│  │  Message to Agent:                                       │  │
│  │  [Use Paisley to generate message...]                   │  │
│  │  [________________________________________________]      │  │
│  │                                                           │  │
│  │  [📝 Use Paisley to Write Message]                      │  │
│  │  [🎁 Gift Listing Command]                               │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  GIFTED THIS MONTH (2)                                   │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 🎁 Sarah Johnson                                   │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Gifted: December 15, 2025                          │  │  │
│  │  │ Listing: 123 Main St, San Diego, CA 92037         │  │  │
│  │  │ Status: ✅ Used by agent                           │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View Details]  [📊 Track Results]            │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │ 🎁 Mike Chen                                        │  │  │
│  │  │ ──────────────────────────────────────────────────  │  │  │
│  │  │ Gifted: December 20, 2025                         │  │  │
│  │  │ Listing: (Not yet specified)                      │  │  │
│  │  │ Status: ⏳ Pending - Agent hasn't used yet        │  │  │
│  │  │                                                    │  │  │
│  │  │ [👁️ View Details]  [📧 Remind Agent]             │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  HISTORY                                                  │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [View All History →]                                   │  │
│  │                                                           │  │
│  │  November 2025: 4 of 4 used                             │  │
│  │  October 2025: 3 of 4 used                              │  │
│  │  September 2025: 4 of 4 used                            │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  WHAT IS A LISTING COMMAND?                              │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  A Listing Command is a $100 marketing package that      │  │
│  │  includes:                                               │  │
│  │  • Social media graphics                                 │  │
│  │  • Email templates                                       │  │
│  │  • Landing page                                          │  │
│  │  • Marketing automation                                  │  │
│  │                                                           │  │
│  │  You get 4 per month to gift to agents. This helps you  │  │
│  │  build relationships and get more title orders.        │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Monthly Allocation Tracker**
   - Progress bar showing X/4 used
   - Percentage used
   - Reset date (first of next month)

2. **Gift Listing Command Form**
   - Agent selector (dropdown of partnered agents)
   - Listing address input (optional)
   - Message to agent textarea
   - "Use Paisley" button (generates message via Screen 2)
   - Gift button

3. **Gifted This Month Section**
   - List of all Listing Commands gifted this month
   - Shows:
     - Agent name
     - Gift date
     - Listing address (if specified)
     - Status (Used, Pending, Expired)
   - Actions:
     - View Details
     - Track Results
     - Remind Agent

4. **History Section**
   - Previous months' usage
   - Quick view of historical data
   - Link to full history

5. **Information Section**
   - Explains what a Listing Command is
   - Value proposition
   - How it helps title reps

### Data Requirements

- Title rep user ID
- Listing Command records:
  - Agent user ID
  - Gift date
  - Listing address (optional)
  - Status (pending, used, expired)
  - Usage date (when agent used it)
- Monthly allocation tracking
- Agent list (from UserPartner table)

### Navigation

- Back button → Returns to Screen 1 (Dashboard)
- "Use Paisley" → Goes to Screen 2 (Chat Interface) with Listing Command message template
- "View Details" → Shows full Listing Command details
- "Track Results" → Shows agent's usage and results
- "Remind Agent" → Sends reminder email (via Paisley)

### Special Features

1. **Paisley Integration**
   - Generate personalized gift messages
   - Create reminder emails
   - Customize messaging per agent

2. **Usage Tracking**
   - Track when agent uses the Listing Command
   - Show results/metrics (if available)
   - ROI tracking (did it lead to title order?)

3. **Reminder System**
   - Automatic reminders for unused Listing Commands
   - Expiration warnings
   - Follow-up suggestions

4. **Compliance Note**
   - Clear messaging that 1ParkPlace pays for Listing Commands
   - Title rep is recommending/referring, not paying
   - Compliant with RESPA regulations

---

## Screen 7: Settings & Profile

### Purpose
Title reps can manage their profile, preferences, billing, and Paisley settings. This includes customization options for how Paisley generates content.

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  [← Back to Dashboard]  |  SETTINGS & PROFILE                   │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  PROFILE INFORMATION                                     │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  Name: [John Smith________________]                     │  │
│  │  Email: [john.smith@titlecompany.com]                  │  │
│  │  Phone: [(555) 123-4567]                                │  │
│  │  Company: [ABC Title Company]                           │  │
│  │  Title: [Senior Title Representative]                  │  │
│  │                                                           │  │
│  │  [💾 Save Changes]                                      │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  PAISLEY PREFERENCES                                   │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  Default Tone: [Professional ▼]                         │  │
│  │  Default Writing Style: [Conversational ▼]            │  │
│  │  Default Format: [Email ▼]                             │  │
│  │                                                           │  │
│  │  ☑ Include agent statistics in outreach                │  │
│  │  ☑ Use data-driven personalization                     │  │
│  │  ☐ Include compliance disclaimers                       │  │
│  │                                                           │  │
│  │  [💾 Save Preferences]                                  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  NOTIFICATION SETTINGS                                   │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  ☑ Email when agent accepts invitation                 │  │
│  │  ☑ Email when agent uses Listing Command                │  │
│  │  ☐ Weekly activity summary                              │  │
│  │  ☑ Monthly usage report                                 │  │
│  │                                                           │  │
│  │  [💾 Save Preferences]                                  │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  BILLING & SUBSCRIPTION                                 │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  Current Plan: TitleGenie Professional                 │  │
│  │  Price: $250/month                                       │  │
│  │  Next Billing Date: January 1, 2026                     │  │
│  │                                                           │  │
│  │  Payment Method: •••• •••• •••• 1234                  │  │
│  │  [💳 Update Payment Method]                             │  │
│  │                                                           │  │
│  │  Billing History: [View All →]                          │  │
│  │                                                           │  │
│  │  [📄 Download Invoice]  [🔄 Change Plan]               │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  TERRITORY SETTINGS                                      │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  Primary Zip Codes:                                      │  │
│  │  [92037] [92014] [92130] [92131] [×]                   │  │
│  │  [+ Add Zip Code]                                        │  │
│  │                                                           │  │
│  │  Counties: [San Diego County ▼]                         │  │
│  │                                                           │  │
│  │  [💾 Save Territory]                                    │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ACCOUNT ACTIONS                                         │  │
│  │  ──────────────────────────────────────────────────────  │  │
│  │                                                           │  │
│  │  [📥 Export My Data]  [🔐 Change Password]             │  │
│  │  [📚 Help & Support]  [🚪 Sign Out]                    │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Profile Information**
   - Name, email, phone
   - Company name
   - Title/role
   - Save button

2. **Paisley Preferences**
   - Default tone (Professional, Friendly, Casual)
   - Default writing style (Formal, Conversational)
   - Default format (Email, Text, Letter, etc.)
   - Toggle options:
     - Include agent statistics
     - Use data-driven personalization
     - Include compliance disclaimers

3. **Notification Settings**
   - Email preferences for various events
   - Toggle switches for each notification type
   - Save button

4. **Billing & Subscription**
   - Current plan display
   - Price and billing date
   - Payment method (masked)
   - Actions:
     - Update Payment Method
     - View Billing History
     - Download Invoice
     - Change Plan

5. **Territory Settings**
   - Primary zip codes (tags/chips)
   - Add/remove zip codes
   - County selection
   - Save button

6. **Account Actions**
   - Export My Data (GDPR compliance)
   - Change Password
   - Help & Support
   - Sign Out

### Data Requirements

- Title rep user profile:
  - Name, email, phone
  - Company, title
- Paisley preferences (stored in user settings)
- Notification preferences
- Billing information (from WHMCS or billing system)
- Territory data (zip codes, counties)

### Navigation

- Back button → Returns to Screen 1 (Dashboard)
- "Update Payment Method" → Opens payment form/modal
- "View Billing History" → Shows invoice list
- "Export My Data" → Downloads user data export
- "Help & Support" → Opens support/help center

### Special Features

1. **Paisley Customization**
   - Save default preferences
   - Apply to all new conversations
   - Override per conversation if needed

2. **Territory Management**
   - Define primary zip codes
   - Used for agent mining filtering
   - Used for market analysis

3. **Data Export**
   - GDPR compliance
   - Export all saved content, conversations, prospects
   - Download as ZIP file

4. **Billing Integration**
   - Connect to WHMCS (Product ID 83)
   - Show subscription status
   - Handle plan changes

---

## Summary: Complete Dashboard Flow

### Navigation Map

```
Screen 1: Main Dashboard
    ├─→ Screen 2: Paisley Chat Interface
    │       ├─→ Screen 4: Content Library (Save)
    │       └─→ Screen 3: Agent Mining (Select Prospect)
    │
    ├─→ Screen 3: Agent Mining
    │       └─→ Screen 2: Paisley Chat (Generate Outreach)
    │
    ├─→ Screen 4: Content Library
    │       └─→ Screen 2: Paisley Chat (Continue Conversation)
    │
    ├─→ Screen 5: Agent Invitations
    │       └─→ Screen 2: Paisley Chat (Generate Invitation)
    │
    ├─→ Screen 6: Listing Commands
    │       └─→ Screen 2: Paisley Chat (Generate Message)
    │
    └─→ Screen 7: Settings & Profile
```

### Key Features Across All Screens

1. **Paisley Integration**
   - Every screen can launch Paisley chat
   - Context-aware prompts
   - Data-driven personalization

2. **Agent-Centric Design**
   - All features focus on agent relationships
   - Track agent activity and engagement
   - Measure success through agent partnerships

3. **Content Management**
   - Save everything Paisley generates
   - Organize by agent, type, date
   - Reuse successful content

4. **Compliance Built-In**
   - Clear messaging about Listing Commands
   - RESPA-compliant language
   - No kickback risk

---

## Implementation Notes

### Phase 1 (MVP - Manual)
- All screens functional
- Manual Listing Command tracking (spreadsheet)
- Manual invitation limit enforcement
- Basic Paisley chat (Chat Type #8)

### Phase 2 (Automation)
- Automated Listing Command tracking
- Automated invitation limit enforcement
- 90-day activity auto-uninvite
- Pre-listing nurture automation

### Technical Requirements
- New database tables for saved content
- Paisley Chat Type #8 (Title Rep Outreach)
- Agent Mining database integration
- WHMCS billing integration (Product ID 83)
- Email integration for invitations

---

**END OF DESIGN DOCUMENT**

**Version:** 1.0  
**Status:** Complete - All 7 screens designed  
**Next Step:** Review with user, then begin implementation


