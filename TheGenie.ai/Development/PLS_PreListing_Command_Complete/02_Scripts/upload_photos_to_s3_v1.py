"""
Upload 10037 Rebecca Place photos to GenieCloud S3
Version: 1.0
Created: 12/25/2025
"""

import boto3
from botocore.exceptions import ClientError
import os

# Photos to upload
PHOTOS = [
    {
        "local": r"D:\iCloudDrive\Desktop\2Desktop Folder\House\Texas Home\Rebecca Place\10037 Rebecca Pl\Coming-Soon-Photos\10037_Rebecca_Front_of_Home.jpeg",
        "s3_key": "genie-pages/10037-rebecca-coming-soon/photos/front-of-home.jpg",
        "purpose": "hero"
    },
    {
        "local": r"D:\iCloudDrive\Desktop\2Desktop Folder\House\Texas Home\Rebecca Place\10037 Rebecca Pl\Coming-Soon-Photos\10037_Rebecca_Kitchen_1.jpeg",
        "s3_key": "genie-pages/10037-rebecca-coming-soon/photos/kitchen-1.jpg",
        "purpose": "gallery"
    },
    {
        "local": r"D:\iCloudDrive\Desktop\2Desktop Folder\House\Texas Home\Rebecca Place\10037 Rebecca Pl\Coming-Soon-Photos\10037_Rebecca_Kitchen_2.jpeg",
        "s3_key": "genie-pages/10037-rebecca-coming-soon/photos/kitchen-2.jpg",
        "purpose": "gallery"
    },
    {
        "local": r"D:\iCloudDrive\Desktop\2Desktop Folder\House\Texas Home\Rebecca Place\10037 Rebecca Pl\Coming-Soon-Photos\10037_Rebecca_Backyard_1.jpeg",
        "s3_key": "genie-pages/10037-rebecca-coming-soon/photos/backyard-1.jpg",
        "purpose": "gallery"
    },
    {
        "local": r"D:\iCloudDrive\Desktop\2Desktop Folder\House\Texas Home\Rebecca Place\10037 Rebecca Pl\Coming-Soon-Photos\10037_Rebecca_Backyard_2.jpeg",
        "s3_key": "genie-pages/10037-rebecca-coming-soon/photos/backyard-2.jpg",
        "purpose": "gallery"
    }
]

BUCKET = "genie-cloud"
REGION = "us-west-1"
PROFILE = "genie-hub-active"
BASE_URL = "https://cloud.thegenie.ai"

def upload_photos():
    print("=" * 60)
    print("Uploading 10037 Rebecca Place photos to GenieCloud S3")
    print("=" * 60)
    
    # Create session with profile
    session = boto3.Session(profile_name=PROFILE)
    s3 = session.client('s3', region_name=REGION)
    
    uploaded_urls = []
    
    for photo in PHOTOS:
        local_path = photo["local"]
        s3_key = photo["s3_key"]
        purpose = photo["purpose"]
        
        if not os.path.exists(local_path):
            print(f"[SKIP] File not found: {local_path}")
            continue
            
        try:
            # Upload with public-read ACL and correct content type
            s3.upload_file(
                local_path, 
                BUCKET, 
                s3_key,
                ExtraArgs={
                    'ContentType': 'image/jpeg',
                    'CacheControl': 'max-age=31536000'
                }
            )
            
            url = f"{BASE_URL}/{s3_key}"
            uploaded_urls.append({"url": url, "purpose": purpose, "key": s3_key})
            print(f"[OK] {purpose}: {url}")
            
        except ClientError as e:
            print(f"[FAIL] {purpose}: {e}")
            
    print("\n" + "=" * 60)
    print("UPLOADED PHOTO URLS:")
    print("=" * 60)
    for item in uploaded_urls:
        print(f"{item['purpose']}: {item['url']}")
        
    return uploaded_urls

if __name__ == "__main__":
    upload_photos()

