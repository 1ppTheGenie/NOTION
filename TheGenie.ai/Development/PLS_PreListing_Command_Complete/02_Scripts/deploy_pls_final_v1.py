"""
Deploy PLS-Hollywood 10037 Rebecca to GenieCloud Production
Version: 1.0
Created: 12/25/2025

This deploys the rendered HTML to cloud.thegenie.ai for live widget data.
"""
import boto3
from botocore.exceptions import ClientError

# AWS Configuration - from Master Credential Tracker
AWS_PROFILE = 'genie-hub-active'
BUCKET = 'genie-cloud'
REGION = 'us-west-1'

# File paths
HTML_FILE = r"D:\Cursor\TheGenie.ai\Development\Paisley\Pre.Listing.Command\Content\pls-10037-rebecca-final.html"
S3_KEY = "genie-pages/pls/10037-rebecca-place/index.html"

# Production URL
PRODUCTION_URL = f"https://cloud.thegenie.ai/{S3_KEY}"

def deploy():
    print(f"Deploying to S3...")
    print(f"  Bucket: {BUCKET}")
    print(f"  Key: {S3_KEY}")
    print(f"  Region: {REGION}")
    
    session = boto3.Session(profile_name=AWS_PROFILE)
    s3 = session.client('s3', region_name=REGION)
    
    try:
        with open(HTML_FILE, 'rb') as f:
            html_content = f.read()
        
        s3.put_object(
            Bucket=BUCKET,
            Key=S3_KEY,
            Body=html_content,
            ContentType='text/html',
            CacheControl='max-age=0'
        )
        
        print(f"\nSUCCESS!")
        print(f"\nLIVE URL:")
        print(f"   {PRODUCTION_URL}")
        print(f"\nPage is now live with real-time market data!")
        
    except ClientError as e:
        print(f"ERROR: {e}")
        return False
    except Exception as e:
        print(f"ERROR: {e}")
        return False
    
    return True

if __name__ == "__main__":
    deploy()

