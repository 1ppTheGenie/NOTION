# AWS Setup Guide - For Beginners

## What We Need
To upload files to S3 (Amazon's file storage), we need AWS credentials. Think of it like a username and password for AWS.

## Step 1: Get Your AWS Credentials from GitHub

Your credentials are stored in your GitHub repository's secrets.

### 1.1 Go to GitHub
1. Open your browser
2. Go to: **https://github.com/1parkplace/genie-cloud**
3. Make sure you're signed in

### 1.2 Access Repository Settings
1. Click **Settings** (top right of the repository page, next to "Insights")
2. If you don't see Settings, you may not have admin access - ask someone who does

### 1.3 Get the Secrets
1. In the left sidebar, click: **Secrets and variables** → **Actions**
2. You'll see a list of secrets
3. Click on each one to view it:
   - **AWS_ACCESS_KEY_ID** - Click it, then click "Update" to see the value. Copy it.
   - **AWS_SECRET_ACCESS_KEY** - Click it, then click "Update" to see the value. Copy it.

### 1.4 Get the Variables (Optional but Helpful)
1. Click the **Variables** tab
2. Note these values:
   - **AWS_REGION** (probably `us-west-1`)
   - **GENIE_CLOUD_BUCKET** (probably `genie-cloud`)

## Step 2: Configure AWS on Your Windows PC

### Option A: Using AWS Credentials File (Recommended)

1. **Create the AWS folder:**
   - Press `Windows Key + R`
   - Type: `%USERPROFILE%\.aws`
   - Press Enter
   - If the folder doesn't exist, create it:
     - Go to `C:\Users\Simulator` (or your username)
     - Create a new folder named `.aws` (with the dot)

2. **Create the credentials file:**
   - Inside the `.aws` folder, create a new text file
   - Name it: `credentials` (no extension, just "credentials")
   - Open it in Notepad

3. **Add your credentials:**
   Paste this into the file (replace with your actual values):
   ```
   [genie-hub-active]
   aws_access_key_id = YOUR_ACCESS_KEY_HERE
   aws_secret_access_key = YOUR_SECRET_KEY_HERE
   ```

4. **Save and close the file**

### Option B: Using Environment Variables (Alternative)

1. **Open PowerShell as Administrator:**
   - Press `Windows Key + X`
   - Click "Windows PowerShell (Admin)" or "Terminal (Admin)"

2. **Set the variables:**
   Run these commands (replace with your actual values):
   ```powershell
   [System.Environment]::SetEnvironmentVariable('AWS_ACCESS_KEY_ID', 'YOUR_ACCESS_KEY_HERE', 'User')
   [System.Environment]::SetEnvironmentVariable('AWS_SECRET_ACCESS_KEY', 'YOUR_SECRET_KEY_HERE', 'User')
   [System.Environment]::SetEnvironmentVariable('AWS_DEFAULT_REGION', 'us-west-1', 'User')
   ```

3. **Close and reopen PowerShell** for changes to take effect

## Step 3: Test the Setup

After configuring credentials, test it:

1. **Open PowerShell** (regular, not admin)
2. **Run:**
   ```powershell
   python upload_reports_to_s3_v20.py
   ```

3. **What to expect:**
   - ✅ If it works: You'll see "Uploading..." messages and files being uploaded
   - ❌ If it fails: You'll see an error message - share it with me and I'll help fix it

## Step 4: Upload Files to S3

Once credentials are working, the script will:
- Upload all 45 report files to S3
- Create S3 URLs for each file
- Save results to `S3_UPLOAD_RESULTS_v20.csv`

## Troubleshooting

### "NoCredentialsError"
- Credentials file doesn't exist or is in wrong location
- Check: `C:\Users\Simulator\.aws\credentials` exists
- Check: File has `[genie-hub-active]` section

### "ProfileNotFound"
- Profile name doesn't match
- Make sure it says `[genie-hub-active]` in the credentials file

### "Access Denied"
- Credentials might be wrong
- Double-check you copied them correctly from GitHub
- Make sure there are no extra spaces

## What Happens Next

Once files are uploaded to S3:
1. ✅ All 45 reports will be accessible via S3 URLs
2. ✅ Notion pages will have working download links
3. ✅ Your team can access files from anywhere

## Need Help?

If you get stuck at any step, tell me:
- What step you're on
- What error message you see (if any)
- What you tried

I'll help you through it!

