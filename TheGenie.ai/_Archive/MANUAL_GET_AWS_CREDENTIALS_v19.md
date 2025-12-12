# Manual Steps to Get AWS Credentials

Since browser automation is having issues with GitHub, please follow these steps manually:

## Step 1: Go to Repository Settings
1. Open: https://github.com/1parkplace/genie-cloud
2. Click **Settings** (top navigation bar, next to "Insights")

## Step 2: Access Secrets
1. In the left sidebar, click: **Secrets and variables** → **Actions**
2. You'll see a list of secrets

## Step 3: Copy AWS Credentials
Click on each secret to view it (you may need to click "Update" to see the value):

- **AWS_ACCESS_KEY_ID** - Copy this value
- **AWS_SECRET_ACCESS_KEY** - Copy this value

## Step 4: Get Variables (Optional)
1. Click the **Variables** tab
2. Note these values:
   - **AWS_REGION** (probably `us-west-1`)
   - **GENIE_CLOUD_BUCKET** (probably `genie-cloud`)

## Step 5: Provide to Me
Once you have the credentials, tell me:
- AWS_ACCESS_KEY_ID: `[paste here]`
- AWS_SECRET_ACCESS_KEY: `[paste here]`
- AWS_DEFAULT_REGION: `us-west-1` (or whatever it shows)
- S3_BUCKET: `genie-cloud` (or whatever it shows)

## Alternative: Quick Copy Method
If you can see the secrets list, you can:
1. Right-click on each secret name
2. Click "Inspect" or "View Source" 
3. Look for the value in the HTML (though GitHub may mask it)

**OR** just tell me the values and I'll configure everything immediately!

