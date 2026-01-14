"""
Deploy LC-Hollywood v8 to GenieCloud S3 Bucket
Version: 1.0
Created: 12/25/2025
Purpose: Upload Coming Soon page to GenieCloud sandbox
"""

import boto3
from botocore.exceptions import ClientError
import os

# Configuration
LOCAL_FILE = r"D:\iCloudDrive\Desktop\2Desktop Folder\House\Texas Home\Rebecca Place\10037 Rebecca Pl\lc-hollywood_10037_rebecca_v8.html"

# Two possible buckets - try genie-hub-2 first (dev/stage), then genie-cloud (production)
BUCKETS = [
    {
        "name": "genie-hub-2",
        "region": "eu-west-2",
        "profile": None,  # default credentials
        "description": "Development/Stage bucket (Europe)"
    },
    {
        "name": "genie-cloud", 
        "region": "us-west-1",
        "profile": "genie-hub-active",
        "description": "Production bucket (US West)"
    }
]

# S3 path for the file
S3_KEY = "genie-pages/10037-rebecca-coming-soon/lc-hollywood/index.html"

def upload_to_bucket(bucket_config):
    """Upload file to specified S3 bucket"""
    try:
        print(f"\n{'='*60}")
        print(f"Attempting upload to: {bucket_config['name']}")
        print(f"Description: {bucket_config['description']}")
        print(f"Region: {bucket_config['region']}")
        print(f"S3 Path: s3://{bucket_config['name']}/{S3_KEY}")
        print(f"{'='*60}")
        
        # Create session with or without profile
        if bucket_config['profile']:
            session = boto3.Session(
                profile_name=bucket_config['profile'],
                region_name=bucket_config['region']
            )
        else:
            session = boto3.Session(region_name=bucket_config['region'])
        
        # Create S3 client
        s3 = session.client('s3')
        
        # Check if file exists
        if not os.path.exists(LOCAL_FILE):
            print(f"ERROR: Local file not found: {LOCAL_FILE}")
            return False
            
        print(f"Local file size: {os.path.getsize(LOCAL_FILE):,} bytes")
        
        # Upload with public-read ACL and HTML content type
        print("Uploading...")
        s3.upload_file(
            LOCAL_FILE,
            bucket_config['name'],
            S3_KEY,
            ExtraArgs={
                'ContentType': 'text/html',
                'CacheControl': 'max-age=60'  # Short cache for development
            }
        )
        
        print(f"[OK] SUCCESS! File uploaded to {bucket_config['name']}")
        
        # Generate URL
        if bucket_config['name'] == 'genie-hub-2':
            url = f"https://genie-hub-2.s3.eu-west-2.amazonaws.com/{S3_KEY}"
        else:
            url = f"https://cloud.thegenie.ai/{S3_KEY}"
            
        print(f"\n[LINK] Preview URL: {url}")
        return True, url
        
    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', 'Unknown')
        error_msg = e.response.get('Error', {}).get('Message', str(e))
        print(f"[FAIL] FAILED: {error_code} - {error_msg}")
        return False, None
    except Exception as e:
        print(f"[FAIL] ERROR: {str(e)}")
        return False, None

def list_buckets():
    """List all accessible S3 buckets to verify credentials"""
    print("\n" + "="*60)
    print("Checking AWS credentials and listing accessible buckets...")
    print("="*60)
    
    try:
        s3 = boto3.client('s3', region_name='us-west-1')
        response = s3.list_buckets()
        
        print(f"\n[OK] AWS credentials are valid!")
        print(f"Found {len(response['Buckets'])} buckets:\n")
        
        for bucket in response['Buckets']:
            print(f"  - {bucket['Name']} (created: {bucket['CreationDate'].strftime('%Y-%m-%d')})")
            
        return True
    except Exception as e:
        print(f"[FAIL] AWS credentials error: {str(e)}")
        return False

def main():
    print("="*60)
    print("  GenieCloud S3 Deployment Script v1.0")
    print("  Deploying: lc-hollywood_10037_rebecca_v8.html")
    print("="*60)
    
    # First verify credentials
    if not list_buckets():
        print("\n[WARN]  Cannot continue without valid AWS credentials")
        return
    
    # Try each bucket
    success_url = None
    for bucket_config in BUCKETS:
        success, url = upload_to_bucket(bucket_config)
        if success:
            success_url = url
            break  # Stop after first successful upload
    
    if success_url:
        print("\n" + "="*60)
        print("[OK] DEPLOYMENT COMPLETE!")
        print("="*60)
        print(f"\nPreview your page at:")
        print(f"  {success_url}")
        print("\nNote: It may take a few moments for the CDN to update.")
    else:
        print("\n" + "="*60)
        print("[FAIL] DEPLOYMENT FAILED")
        print("="*60)
        print("\nPossible issues:")
        print("  1. AWS credentials may not have S3 write permissions")
        print("  2. Bucket names may be incorrect")
        print("  3. Network connectivity issues")

if __name__ == "__main__":
    main()

