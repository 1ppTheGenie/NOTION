# Quick AWS Setup - 3 Steps

## Step 1: Get Credentials from GitHub
1. Go to: https://github.com/1parkplace/genie-cloud/settings/secrets/actions
2. Click on **AWS_ACCESS_KEY_ID** → Copy the value
3. Click on **AWS_SECRET_ACCESS_KEY** → Copy the value

## Step 2: Create Credentials File
1. Create folder: `C:\Users\Simulator\.aws`
2. Create file: `C:\Users\Simulator\.aws\credentials`
3. Paste this (replace YOUR_ values):
   ```
   [genie-hub-active]
   aws_access_key_id = YOUR_ACCESS_KEY_ID_HERE
   aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_HERE
   ```

## Step 3: Test It
```powershell
python upload_reports_to_s3_v20.py
```

That's it! If it works, files will upload. If not, share the error and I'll help.

