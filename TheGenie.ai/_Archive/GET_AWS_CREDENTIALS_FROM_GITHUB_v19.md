# Get AWS Credentials from GitHub - Step by Step

## The Repository
- **URL**: https://github.com/1parkplace/genie-cloud
- **Credentials Location**: GitHub Secrets (not in code files)

## Steps to Get AWS Credentials

### 1. Sign in to GitHub
- Go to: https://github.com/login
- Sign in with your GitHub account

### 2. Navigate to Repository Settings
- Go to: https://github.com/1parkplace/genie-cloud
- Click **Settings** (top right of repository page)

### 3. Access Secrets
- In left sidebar, click: **Secrets and variables** → **Actions**
- You'll see:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `CLOUDFRONT_DISTRIBUTION_ID` (if needed)

### 4. Copy the Values
- Click on each secret name
- Click **Update** or view the value
- Copy the values

### 5. Also Get Variables (if needed)
- Click: **Variables** tab
- You'll see:
  - `AWS_REGION` (probably `us-west-1` based on workflow)
  - `GENIE_CLOUD_BUCKET` (probably `genie-cloud`)

## What I Need From You

Once you have the credentials, provide:
1. **AWS_ACCESS_KEY_ID**: `your-access-key-here`
2. **AWS_SECRET_ACCESS_KEY**: `your-secret-key-here`
3. **AWS_DEFAULT_REGION**: `us-west-1` (or whatever region)
4. **S3_BUCKET**: `genie-cloud` (or whatever bucket name)

## Alternative: Use GitHub CLI

If you have GitHub CLI installed:
```bash
gh auth login
gh secret list --repo 1parkplace/genie-cloud
```

## After You Provide Credentials

I will:
1. Configure AWS credentials in environment
2. Upload all report files to S3
3. Generate S3 URLs for each file
4. Create Notion pages with working S3 links
5. Complete the Operations Portal setup

