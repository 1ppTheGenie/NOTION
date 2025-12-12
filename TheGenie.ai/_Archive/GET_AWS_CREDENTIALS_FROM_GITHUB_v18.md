# Get AWS Credentials from GitHub

## The Problem
- GitHub is connected on your Mac Cursor but not on PC
- AWS credentials are stored in GitHub Secrets
- Need to access them to upload files to S3

## Solutions

### Option 1: Add GitHub MCP to PC (If Available)
1. Check if GitHub MCP server exists for Cursor
2. Add it to `%USERPROFILE%\.cursor\mcp.json`
3. Configure with your GitHub token

### Option 2: Get Credentials Manually (FASTEST)
1. Go to your GenieCloud GitHub repository
2. Settings → Secrets and variables → Actions
3. Copy:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
4. Give them to me - I'll configure and upload files immediately

### Option 3: Use GitHub CLI
If you have GitHub CLI installed:
```bash
gh auth login
gh secret list --repo <your-repo>
```

### Option 4: Check Mac Cursor Config
Copy the MCP config from your Mac to see how GitHub is configured there.

## What I Need
Either:
- GitHub repository URL + I guide you to get credentials
- AWS credentials directly (I configure them)
- Mac MCP config file (to see how GitHub is set up)

