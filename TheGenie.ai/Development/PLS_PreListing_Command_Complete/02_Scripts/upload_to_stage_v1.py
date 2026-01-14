"""
Upload photos and HTML to Stage S3 Bucket
Version: 1.0
Created: 12/25/2025
"""

import boto3
from botocore.exceptions import ClientError
import os

BUCKET = 'genie-cloud-stage'
REGION = 'us-west-1'
BASE_PATH = r"D:\iCloudDrive\Desktop\2Desktop Folder\House\Texas Home\Rebecca Place\10037 Rebecca Pl"

# Photos to upload
PHOTOS = [
    ("Coming-Soon-Photos/10037_Rebecca_Front_of_Home.jpeg", "photos/front-of-home.jpg", "image/jpeg"),
    ("Coming-Soon-Photos/10037_Rebecca_Kitchen_1.jpeg", "photos/kitchen-1.jpg", "image/jpeg"),
    ("Coming-Soon-Photos/10037_Rebecca_Kitchen_2.jpeg", "photos/kitchen-2.jpg", "image/jpeg"),
    ("Coming-Soon-Photos/10037_Rebecca_Backyard_1.jpeg", "photos/backyard-1.jpg", "image/jpeg"),
    ("Coming-Soon-Photos/10037_Rebecca_Backyard_2.jpeg", "photos/backyard-2.jpg", "image/jpeg"),
]

session = boto3.Session(profile_name='genie-hub-active')
s3 = session.client('s3', region_name=REGION)

print("=" * 60)
print("Uploading photos to STAGE bucket")
print("=" * 60)

uploaded = []

for local_file, s3_key, content_type in PHOTOS:
    full_path = os.path.join(BASE_PATH, local_file)
    full_s3_key = f"genie-pages/10037-rebecca-coming-soon/{s3_key}"
    
    if not os.path.exists(full_path):
        print(f"[SKIP] Not found: {local_file}")
        continue
    
    try:
        s3.upload_file(
            full_path,
            BUCKET,
            full_s3_key,
            ExtraArgs={
                'ContentType': content_type,
                'CacheControl': 'max-age=31536000'
            }
        )
        url = f"http://{BUCKET}.s3-website-{REGION}.amazonaws.com/{full_s3_key}"
        print(f"[OK] {s3_key}")
        uploaded.append((s3_key, url))
    except ClientError as e:
        print(f"[FAIL] {s3_key}: {e}")

print()
print("=" * 60)
print("UPLOADED PHOTO URLS:")
print("=" * 60)
for name, url in uploaded:
    print(f"{name}:")
    print(f"  {url}")
print()

