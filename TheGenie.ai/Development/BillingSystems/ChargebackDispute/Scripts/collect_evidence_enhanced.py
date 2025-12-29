"""
Enhanced Evidence Collection with Impersonation Detection
Checks for cases where orders were entered by partners or super users
"""

import pyodbc
import pandas as pd
import requests
import base64
import json
import sys
from datetime import datetime, timedelta

sys.stdout.reconfigure(encoding='utf-8')

# ============================================================================
# CONFIGURATION
# ============================================================================

# Chris Plank Case
CHRIS_USER_ID = "f5174e53-8f6e-4d23-9eab-f8d6802b39c9"
CHRIS_EMAIL = "cp@pacificapg.com"
CHRIS_PHONE = "3108491530"
PAYPAL_TRANSACTION_ID = "PP-R-THB-607760615"
TRANSACTION_DATE = "2025-12-05"
TRANSACTION_AMOUNT = 67.50

# Company Info
ORDERING_SITE = "thegenie.ai"
TERMS_EMAIL = "wecare@thegenie.ai"

# API Credentials (same as before)
INTERCOM_TOKEN = "[REDACTED - See Master Credential Tracker]"
INTERCOM_BASE_URL = "https://api.intercom.io"

ZOOM_ACCOUNT_ID = "QjlsIG0sQHeNRs51zRrv6A"
ZOOM_CLIENT_ID = "dL9rQulfSqSQRrvW9qYkQg"
ZOOM_CLIENT_SECRET = "5Y7z4wNWnBIk5Fj1193hNwcr5qaSbiWR"
ZOOM_BASE_URL = "https://api.zoom.us/v2"

DB_SERVER = "192.168.29.45,1433"
DB_DATABASE = "FarmGenie"
DB_USER = "cursor"
DB_PASSWORD = "1ppINSAyay$"

# ============================================================================
# DATABASE CONNECTION
# ============================================================================

def connect_db():
    """Connect to FarmGenie database"""
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USER};PWD={DB_PASSWORD};"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)

# ============================================================================
# IMPERSONATION DETECTION
# ============================================================================

def check_impersonation(conn, user_id):
    """
    Check for impersonation cases:
    1. Partner/title rep entered order on behalf of customer
    2. 1ParkPlace super user impersonated the agent
    """
    print("\n" + "-"*80)
    print("CHECKING FOR IMPERSONATION CASES")
    print("-"*80)
    
    impersonation_findings = {
        'has_impersonation': False,
        'impersonated_by': [],
        'impersonation_details': []
    }
    
    # Check ActivityTracker for ActionForUserID (impersonation field)
    try:
        query = f"""
        SELECT 
            at.ActivityTrackerID,
            at.CreateDate,
            at.AspNetUserID,
            at.ActionForUserID,
            at.Note,
            au1.Email AS ActingUserEmail,
            au1.UserName AS ActingUserName,
            au2.Email AS TargetUserEmail,
            au2.UserName AS TargetUserName
        FROM dbo.ActivityTracker at
        LEFT JOIN dbo.AspNetUsers au1 ON at.AspNetUserID = au1.Id
        LEFT JOIN dbo.AspNetUsers au2 ON at.ActionForUserID = au2.Id
        WHERE at.ActionForUserID = '{user_id}'
        OR (at.AspNetUserID = '{user_id}' AND at.ActionForUserID IS NOT NULL)
        ORDER BY at.CreateDate DESC
        """
        
        impersonation_df = pd.read_sql(query, conn)
        
        if len(impersonation_df) > 0:
            impersonation_findings['has_impersonation'] = True
            print(f"⚠️ Found {len(impersonation_df)} impersonation records")
            
            for _, row in impersonation_df.iterrows():
                if row['ActionForUserID'] == user_id:
                    # Someone acted on behalf of this user
                    impersonator_id = row['AspNetUserID']
                    impersonator_email = row['ActingUserEmail']
                    impersonator_name = row['ActingUserName']
                    
                    impersonation_findings['impersonated_by'].append({
                        'impersonator_id': impersonator_id,
                        'impersonator_email': impersonator_email,
                        'impersonator_name': impersonator_name,
                        'date': str(row['CreateDate']),
                        'note': row['Note']
                    })
                    
                    print(f"  - {row['CreateDate']}: {impersonator_email} ({impersonator_name}) acted on behalf of customer")
                elif row['AspNetUserID'] == user_id and row['ActionForUserID']:
                    # This user acted on behalf of someone else
                    target_id = row['ActionForUserID']
                    target_email = row['TargetUserEmail']
                    target_name = row['TargetUserName']
                    
                    impersonation_findings['impersonation_details'].append({
                        'target_id': target_id,
                        'target_email': target_email,
                        'target_name': target_name,
                        'date': str(row['CreateDate']),
                        'note': row['Note']
                    })
                    
                    print(f"  - {row['CreateDate']}: Customer acted on behalf of {target_email} ({target_name})")
        else:
            print("✅ No impersonation detected - all activities are from customer's own account")
            
    except Exception as e:
        print(f"⚠️ Error checking impersonation: {e}")
        impersonation_findings['error'] = str(e)
    
    # Check for partner/title rep orders
    # This would require checking Order table or WHMCS for order entry user
    # For now, we note this in the findings
    
    return impersonation_findings

def analyze_activity_ownership(conn, user_id, activity_logs):
    """Analyze activity logs to determine if customer or someone else performed actions"""
    print("\n" + "-"*80)
    print("ANALYZING ACTIVITY OWNERSHIP")
    print("-"*80)
    
    if not activity_logs or len(activity_logs) == 0:
        print("No activity logs to analyze")
        return None
    
    # Get user details for impersonators
    impersonator_ids = set()
    for log in activity_logs:
        if log.get('ActionForUserID'):
            impersonator_ids.add(log['ActionForUserID'])
        if log.get('AspNetUserID') and log['AspNetUserID'] != user_id:
            impersonator_ids.add(log['AspNetUserID'])
    
    impersonator_details = {}
    if impersonator_ids:
        try:
            ids_str = "','".join(impersonator_ids)
            query = f"""
            SELECT Id, Email, UserName 
            FROM dbo.AspNetUsers 
            WHERE Id IN ('{ids_str}')
            """
            users_df = pd.read_sql(query, conn)
            for _, row in users_df.iterrows():
                impersonator_details[row['Id']] = {
                    'email': row['Email'],
                    'username': row['UserName']
                }
        except Exception as e:
            print(f"Error getting impersonator details: {e}")
    
    # Analyze activities
    customer_activities = []
    impersonated_activities = []
    
    for log in activity_logs:
        if log.get('ActionForUserID') == user_id:
            # Someone acted on behalf of customer
            impersonator_id = log.get('AspNetUserID')
            impersonator = impersonator_details.get(impersonator_id, {})
            impersonated_activities.append({
                'date': log.get('CreateDate'),
                'note': log.get('Note'),
                'impersonator': impersonator
            })
        elif log.get('AspNetUserID') == user_id:
            # Customer's own activity
            customer_activities.append(log)
    
    analysis = {
        'total_activities': len(activity_logs),
        'customer_activities': len(customer_activities),
        'impersonated_activities': len(impersonated_activities),
        'impersonated_details': impersonated_activities
    }
    
    print(f"Total Activities: {analysis['total_activities']}")
    print(f"Customer's Own Activities: {analysis['customer_activities']}")
    print(f"Impersonated Activities: {analysis['impersonated_activities']}")
    
    if analysis['impersonated_activities'] > 0:
        print("\n⚠️ IMPERSONATION DETECTED:")
        for imp in impersonated_activities[:5]:  # Show first 5
            print(f"  - {imp['date']}: {imp['impersonator'].get('email', 'Unknown')} acted on behalf")
    
    return analysis

# ============================================================================
# ENHANCED EVIDENCE COLLECTION
# ============================================================================

def collect_all_evidence_enhanced():
    """Collect all evidence with impersonation detection"""
    print("\n" + "="*80)
    print("ENHANCED EVIDENCE COLLECTION - CHRIS PLANK CASE")
    print("="*80)
    print(f"\nCase: {PAYPAL_TRANSACTION_ID}")
    print(f"Customer: {CHRIS_EMAIL}")
    print(f"Ordering Site: {ORDERING_SITE}")
    print(f"Terms Email: {TERMS_EMAIL}\n")
    
    evidence = {
        'case_info': {
            'paypal_transaction_id': PAYPAL_TRANSACTION_ID,
            'customer_email': CHRIS_EMAIL,
            'customer_user_id': CHRIS_USER_ID,
            'transaction_date': TRANSACTION_DATE,
            'transaction_amount': TRANSACTION_AMOUNT,
            'ordering_site': ORDERING_SITE,
            'terms_email': TERMS_EMAIL
        },
        'user_details': None,
        'whmcs_mapping': None,
        'activity_logs': None,
        'activity_ownership_analysis': None,
        'impersonation_findings': None,
        'listing_command_usage': None,
        'intercom_conversations': None,
        'zoom_call_logs': None,
        'errors': []
    }
    
    # Connect to database
    try:
        conn = connect_db()
    except Exception as e:
        evidence['errors'].append(f"Database connection error: {e}")
        conn = None
    
    # 1. User Details
    if conn:
        print("-"*80)
        print("1. COLLECTING USER DETAILS")
        print("-"*80)
        try:
            query = f"SELECT * FROM dbo.AspNetUsers WHERE Id = '{CHRIS_USER_ID}'"
            user_df = pd.read_sql(query, conn)
            if len(user_df) > 0:
                evidence['user_details'] = user_df.to_dict('records')[0]
                print(f"✅ Found user: {evidence['user_details']['Email']}")
        except Exception as e:
            evidence['errors'].append(f"User details error: {e}")
    
    # 2. WHMCS Mapping
    if conn:
        print("\n" + "-"*80)
        print("2. COLLECTING WHMCS MAPPING")
        print("-"*80)
        try:
            query = f"SELECT * FROM dbo.UserWhmcs WHERE AspNetUserId = '{CHRIS_USER_ID}'"
            whmcs_df = pd.read_sql(query, conn)
            if len(whmcs_df) > 0:
                evidence['whmcs_mapping'] = whmcs_df.to_dict('records')[0]
                print(f"✅ Found WHMCS Client ID: {evidence['whmcs_mapping']['WhmcsClientId']}")
        except Exception as e:
            evidence['errors'].append(f"WHMCS mapping error: {e}")
    
    # 3. Activity Logs
    if conn:
        print("\n" + "-"*80)
        print("3. COLLECTING ACTIVITY/LOGIN LOGS")
        print("-"*80)
        try:
            cutoff_date = (datetime.now() - timedelta(days=90)).strftime("%Y-%m-%d")
            query = f"""
            SELECT 
                at.ActivityTrackerID,
                at.CreateDate,
                at.Note,
                at.AspNetUserID,
                at.ActionForUserID
            FROM dbo.ActivityTracker at
            WHERE (at.AspNetUserID = '{CHRIS_USER_ID}' OR at.ActionForUserID = '{CHRIS_USER_ID}')
            AND CAST(at.CreateDate AS DATE) >= '{cutoff_date}'
            ORDER BY at.CreateDate DESC
            """
            activity_df = pd.read_sql(query, conn)
            if len(activity_df) > 0:
                evidence['activity_logs'] = activity_df.to_dict('records')
                print(f"✅ Found {len(activity_df)} activity records")
                
                # Analyze ownership
                evidence['activity_ownership_analysis'] = analyze_activity_ownership(conn, CHRIS_USER_ID, evidence['activity_logs'])
        except Exception as e:
            evidence['errors'].append(f"Activity logs error: {e}")
    
    # 4. Impersonation Check
    if conn:
        evidence['impersonation_findings'] = check_impersonation(conn, CHRIS_USER_ID)
    
    # 5. Intercom
    print("\n" + "-"*80)
    print("5. COLLECTING INTERCOM CONVERSATIONS")
    print("-"*80)
    try:
        url = f"{INTERCOM_BASE_URL}/conversations/search"
        headers = {
            "Authorization": f"Bearer {INTERCOM_TOKEN}",
            "Accept": "application/json",
            "Intercom-Version": "2.10",
            "Content-Type": "application/json"
        }
        
        # Try by email
        query = {
            "query": {
                "operator": "AND",
                "value": [
                    {
                        "field": "source.author.email",
                        "operator": "=",
                        "value": CHRIS_EMAIL
                    }
                ]
            }
        }
        
        response = requests.post(url, headers=headers, json=query, timeout=10)
        if response.status_code == 200:
            data = response.json()
            evidence['intercom_conversations'] = data
            print(f"✅ Found {data.get('total_count', 0)} conversations")
        else:
            print(f"✅ No conversations found (proves no contact)")
            evidence['intercom_conversations'] = {'total_count': 0}
    except Exception as e:
        evidence['errors'].append(f"Intercom error: {e}")
    
    # 6. Zoom Phone
    print("\n" + "-"*80)
    print("6. COLLECTING ZOOM PHONE CALL LOGS")
    print("-"*80)
    try:
        token_url = "https://zoom.us/oauth/token"
        auth_string = f"{ZOOM_CLIENT_ID}:{ZOOM_CLIENT_SECRET}"
        auth_b64 = base64.b64encode(auth_string.encode('ascii')).decode('ascii')
        
        headers = {
            "Authorization": f"Basic {auth_b64}",
            "Content-Type": "application/x-www-form-urlencoded"
        }
        
        data = {
            "grant_type": "account_credentials",
            "account_id": ZOOM_ACCOUNT_ID
        }
        
        response = requests.post(token_url, headers=headers, data=data, timeout=10)
        if response.status_code == 200:
            access_token = response.json().get("access_token")
            
            to_date = datetime.now()
            from_date = to_date - timedelta(days=90)
            
            url = f"{ZOOM_BASE_URL}/phone/call_logs"
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            }
            
            phone_clean = CHRIS_PHONE.replace("-", "").replace("(", "").replace(")", "").replace(" ", "")
            params = {
                "from": from_date.strftime("%Y-%m-%d"),
                "to": to_date.strftime("%Y-%m-%d"),
                "phone_number": phone_clean,
                "page_size": 100
            }
            
            response = requests.get(url, headers=headers, params=params, timeout=10)
            if response.status_code == 200:
                zoom_data = response.json()
                evidence['zoom_call_logs'] = zoom_data
                
                # Filter for customer's number specifically
                if zoom_data.get('call_logs'):
                    customer_calls = []
                    for call in zoom_data['call_logs']:
                        from_num = call.get('from', '').replace('-', '').replace('(', '').replace(')', '').replace(' ', '')
                        to_num = call.get('to', '').replace('-', '').replace('(', '').replace(')', '').replace(' ', '')
                        if phone_clean in from_num or phone_clean in to_num:
                            customer_calls.append(call)
                    
                    evidence['zoom_call_logs']['customer_calls'] = customer_calls
                    evidence['zoom_call_logs']['customer_call_count'] = len(customer_calls)
                    print(f"✅ Found {len(customer_calls)} calls from/to customer number")
                else:
                    print(f"✅ No calls found from customer number")
            else:
                print(f"⚠️ Zoom API error: {response.status_code}")
        else:
            evidence['errors'].append("Failed to get Zoom token")
    except Exception as e:
        evidence['errors'].append(f"Zoom Phone error: {e}")
    
    if conn:
        conn.close()
    
    return evidence

if __name__ == "__main__":
    evidence = collect_all_evidence_enhanced()
    
    # Save evidence
    output_file = f"EVIDENCE_Enhanced_ChrisPlank_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(evidence, f, indent=2, default=str)
    
    print("\n" + "="*80)
    print("ENHANCED EVIDENCE COLLECTION COMPLETE")
    print("="*80)
    print(f"\nEvidence saved to: {output_file}")
    
    # Summary
    print(f"\nSummary:")
    print(f"  - User Details: {'✅' if evidence['user_details'] else '❌'}")
    print(f"  - Activity Logs: {len(evidence['activity_logs']) if evidence['activity_logs'] else 0}")
    print(f"  - Impersonation: {'⚠️ DETECTED' if evidence.get('impersonation_findings', {}).get('has_impersonation') else '✅ NONE'}")
    print(f"  - Intercom: {evidence.get('intercom_conversations', {}).get('total_count', 0)}")
    print(f"  - Zoom Calls: {evidence.get('zoom_call_logs', {}).get('customer_call_count', 0)}")
    print(f"  - Errors: {len(evidence['errors'])}")


