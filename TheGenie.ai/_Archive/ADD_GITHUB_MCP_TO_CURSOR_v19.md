# Add GitHub MCP to Cursor PC

## Current Status
- MCP config location: `C:\Users\Simulator\.cursor\mcp.json`
- Currently only has Notion configured
- Need to add GitHub MCP server

## Steps to Add GitHub MCP

### Option 1: Using Official GitHub MCP Server

1. **Install Node.js** (if not installed):
   - Download from: https://nodejs.org/
   - Install Node.js (includes npm)

2. **Install GitHub MCP Server**:
   ```bash
   npm install -g @modelcontextprotocol/server-github
   ```

3. **Get GitHub Personal Access Token**:
   - Go to: https://github.com/settings/tokens
   - Generate new token (classic)
   - Scopes needed: `repo`, `read:org` (if needed)
   - Copy the token

4. **Update MCP Config**:
   Edit `C:\Users\Simulator\.cursor\mcp.json`:
   ```json
   {
     "mcpServers": {
       "Notion": {
         "url": "https://mcp.notion.com/mcp",
         "headers": {}
       },
       "GitHub": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-github"
         ],
         "env": {
           "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token-here"
         }
       }
     }
   }
   ```

5. **Restart Cursor**

### Option 2: Using GitHub MCP via URL (if available)

Some MCP servers can be accessed via URL. Check if GitHub has a hosted MCP endpoint.

### Option 3: Check Mac Config

If your Mac has GitHub working, check the MCP config there:
- Mac location: `~/.cursor/mcp.json` or similar
- Copy the GitHub configuration to PC

## Quick Test

After adding, test with:
- Ask Cursor: "List my GitHub repositories"
- Or: "Get AWS credentials from GenieCloud GitHub repository"

