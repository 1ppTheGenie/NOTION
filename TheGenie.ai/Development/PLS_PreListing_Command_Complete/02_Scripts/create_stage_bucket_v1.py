"""
Create Stage S3 Bucket for GenieCloud
Version: 1.0
Created: 12/25/2025
"""

import boto3
from botocore.exceptions import ClientError

BUCKET = 'genie-cloud-stage'
REGION = 'us-west-1'

session = boto3.Session(profile_name='genie-hub-active')
s3 = session.client('s3', region_name=REGION)

# Create the bucket
try:
    s3.create_bucket(
        Bucket=BUCKET,
        CreateBucketConfiguration={'LocationConstraint': REGION}
    )
    print(f'[OK] Created bucket: {BUCKET}')
except ClientError as e:
    if 'BucketAlreadyOwnedByYou' in str(e):
        print(f'[OK] Bucket already exists: {BUCKET}')
    elif 'BucketAlreadyExists' in str(e):
        print(f'[FAIL] Bucket name taken by someone else: {BUCKET}')
        print('Try a different name like: genie-cloud-stage-1pp')
        exit(1)
    else:
        print(f'[FAIL] {e}')
        exit(1)

# Configure for static website hosting
try:
    s3.put_bucket_website(
        Bucket=BUCKET,
        WebsiteConfiguration={
            'IndexDocument': {'Suffix': 'index.html'},
            'ErrorDocument': {'Key': 'error.html'}
        }
    )
    print('[OK] Configured static website hosting')
except ClientError as e:
    print(f'[FAIL] Website config: {e}')

# Set public access (disable block)
try:
    s3.put_public_access_block(
        Bucket=BUCKET,
        PublicAccessBlockConfiguration={
            'BlockPublicAcls': False,
            'IgnorePublicAcls': False,
            'BlockPublicPolicy': False,
            'RestrictPublicBuckets': False
        }
    )
    print('[OK] Disabled public access block')
except ClientError as e:
    print(f'[WARN] Public access block: {e}')

# Add bucket policy for public read
policy = '''{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::''' + BUCKET + '''/*"
    }]
}'''

try:
    s3.put_bucket_policy(Bucket=BUCKET, Policy=policy)
    print('[OK] Added public read policy')
except ClientError as e:
    print(f'[WARN] Bucket policy: {e}')

print()
print('=' * 60)
print('STAGE BUCKET CREATED!')
print('=' * 60)
print(f'Bucket: {BUCKET}')
print(f'Region: {REGION}')
print(f'Website URL: http://{BUCKET}.s3-website-{REGION}.amazonaws.com/')
print('=' * 60)

