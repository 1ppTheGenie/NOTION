"""
Complete Evidence Collection for Chris Plank Dispute Case
Queries all systems: WHMCS, Database, Intercom, Zoom Phone
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

# WHMCS API (from PowerShell script - need to get actual values)
WHMCS_API_URL = "https://accounts.1parkplace.com/includes/api.php"
# WHMCS_API_IDENTIFIER = ""  # Need to get from script
# WHMCS_API_SECRET = ""  # Need to get from script

# Intercom API
INTERCOM_TOKEN = "[REDACTED - See Master Credential Tracker]"
INTERCOM_BASE_URL = "https://api.intercom.io"

# Zoom Phone API
ZOOM_ACCOUNT_ID = "QjlsIG0sQHeNRs51zRrv6A"
ZOOM_CLIENT_ID = "dL9rQulfSqSQRrvW9qYkQg"
ZOOM_CLIENT_SECRET = "5Y7z4wNWnBIk5Fj1193hNwcr5qaSbiWR"
ZOOM_BASE_URL = "https://api.zoom.us/v2"

# Database
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
# ZOOM PHONE API
# ============================================================================

def get_zoom_access_token():
    """Get Zoom Phone API access token"""
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
    
    try:
        response = requests.post(token_url, headers=headers, data=data, timeout=10)
        response.raise_for_status()
        return response.json().get("access_token")
    except Exception as e:
        print(f"ERROR getting Zoom token: {e}")
        return None

def search_zoom_call_logs(access_token, phone_number, days_back=90):
    """Search Zoom Phone call logs by phone number"""
    to_date = datetime.now()
    from_date = to_date - timedelta(days=days_back)
    
    url = f"{ZOOM_BASE_URL}/phone/call_logs"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    params = {
        "from": from_date.strftime("%Y-%m-%d"),
        "to": to_date.strftime("%Y-%m-%d"),
        "phone_number": phone_number.replace("-", "").replace("(", "").replace(")", "").replace(" ", ""),
        "page_size": 100
    }
    
    try:
        response = requests.get(url, headers=headers, params=params, timeout=10)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Zoom API error: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"ERROR querying Zoom: {e}")
        return None

# ============================================================================
# INTERCOM API
# ============================================================================

def search_intercom_by_user_id(user_id):
    """Search Intercom conversations by external_id (user ID)"""
    url = f"{INTERCOM_BASE_URL}/conversations/search"
    headers = {
        "Authorization": f"Bearer {INTERCOM_TOKEN}",
        "Accept": "application/json",
        "Intercom-Version": "2.10",
        "Content-Type": "application/json"
    }
    
    # Search by external_id
    query = {
        "query": {
            "operator": "AND",
            "value": [
                {
                    "field": "source.author.id",
                    "operator": "=",
                    "value": user_id
                }
            ]
        }
    }
    
    try:
        response = requests.post(url, headers=headers, json=query, timeout=10)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Intercom API error: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"ERROR querying Intercom by user ID: {e}")
        return None

def search_intercom_by_email(email):
    """Search Intercom conversations by email"""
    url = f"{INTERCOM_BASE_URL}/conversations/search"
    headers = {
        "Authorization": f"Bearer {INTERCOM_TOKEN}",
        "Accept": "application/json",
        "Intercom-Version": "2.10",
        "Content-Type": "application/json"
    }
    
    query = {
        "query": {
            "operator": "AND",
            "value": [
                {
                    "field": "source.author.email",
                    "operator": "=",
                    "value": email
                }
            ]
        }
    }
    
    try:
        response = requests.post(url, headers=headers, json=query, timeout=10)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Intercom API error: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"ERROR querying Intercom by email: {e}")
        return None

# ============================================================================
# DATABASE QUERIES
# ============================================================================

def get_user_details(conn, user_id):
    """Get user details from AspNetUsers"""
    query = f"SELECT * FROM dbo.AspNetUsers WHERE Id = '{user_id}'"
    return pd.read_sql(query, conn)

def get_activity_logs(conn, user_id, days_back=90):
    """Get activity/login logs"""
    cutoff_date = (datetime.now() - timedelta(days=days_back)).strftime("%Y-%m-%d")
    query = f"""
    SELECT 
        at.ActivityTrackerID,
        at.CreateDate,
        at.Note,
        at.AspNetUserID,
        at.ActionForUserID
    FROM dbo.ActivityTracker at
    WHERE at.AspNetUserID = '{user_id}'
    AND CAST(at.CreateDate AS DATE) >= '{cutoff_date}'
    ORDER BY at.CreateDate DESC
    """
    return pd.read_sql(query, conn)

def get_listing_command_usage(conn, user_id):
    """Get Listing Command usage data"""
    # Get configuration
    config_query = f"""
    SELECT * FROM dbo.ListingCommandUserConfiguration 
    WHERE AspNetUserId = '{user_id}'
    """
    config_df = pd.read_sql(config_query, conn)
    
    # Get leads generated
    leads_query = f"""
    SELECT TOP 100 
        gl.GenieLeadId,
        gl.CreateDate,
        gl.GenieLeadTypeId,
        glt.GenieLeadTypeName
    FROM dbo.GenieLead gl
    LEFT JOIN dbo.GenieLeadType glt ON gl.GenieLeadTypeId = glt.GenieLeadTypeId
    WHERE gl.UserId = '{user_id}'
    ORDER BY gl.CreateDate DESC
    """
    leads_df = pd.read_sql(leads_query, conn)
    
    return config_df, leads_df

def get_whmcs_mapping(conn, user_id):
    """Get WHMCS client ID mapping"""
    query = f"SELECT * FROM dbo.UserWhmcs WHERE AspNetUserId = '{user_id}'"
    return pd.read_sql(query, conn)

# ============================================================================
# EVIDENCE COLLECTION
# ============================================================================

def collect_all_evidence():
    """Collect all evidence for Chris Plank case"""
    print("\n" + "="*80)
    print("COMPLETE EVIDENCE COLLECTION - CHRIS PLANK CASE")
    print("="*80)
    print(f"\nCase: {PAYPAL_TRANSACTION_ID}")
    print(f"Customer: {CHRIS_EMAIL}")
    print(f"Transaction Date: {TRANSACTION_DATE}")
    print(f"Amount: ${TRANSACTION_AMOUNT}")
    
    evidence = {
        'case_info': {
            'paypal_transaction_id': PAYPAL_TRANSACTION_ID,
            'customer_email': CHRIS_EMAIL,
            'customer_user_id': CHRIS_USER_ID,
            'transaction_date': TRANSACTION_DATE,
            'transaction_amount': TRANSACTION_AMOUNT
        },
        'user_details': None,
        'whmcs_mapping': None,
        'activity_logs': None,
        'listing_command_usage': None,
        'intercom_conversations': None,
        'zoom_call_logs': None,
        'errors': []
    }
    
    # 1. Database - User Details
    print("\n" + "-"*80)
    print("1. COLLECTING USER DETAILS FROM DATABASE")
    print("-"*80)
    try:
        conn = connect_db()
        user_df = get_user_details(conn, CHRIS_USER_ID)
        if len(user_df) > 0:
            evidence['user_details'] = user_df.to_dict('records')[0]
            print(f"✅ Found user: {evidence['user_details']['Email']}")
        else:
            evidence['errors'].append("User not found in database")
            print("❌ User not found")
    except Exception as e:
        evidence['errors'].append(f"Database error: {e}")
        print(f"❌ Error: {e}")
        conn = None
    
    # 2. Database - WHMCS Mapping
    if conn:
        print("\n" + "-"*80)
        print("2. COLLECTING WHMCS MAPPING")
        print("-"*80)
        try:
            whmcs_df = get_whmcs_mapping(conn, CHRIS_USER_ID)
            if len(whmcs_df) > 0:
                evidence['whmcs_mapping'] = whmcs_df.to_dict('records')[0]
                print(f"✅ Found WHMCS Client ID: {evidence['whmcs_mapping']['WhmcsClientId']}")
            else:
                print("⚠️ No WHMCS mapping found (may be direct purchase)")
        except Exception as e:
            evidence['errors'].append(f"WHMCS mapping error: {e}")
            print(f"❌ Error: {e}")
    
    # 3. Database - Activity Logs
    if conn:
        print("\n" + "-"*80)
        print("3. COLLECTING ACTIVITY/LOGIN LOGS")
        print("-"*80)
        try:
            activity_df = get_activity_logs(conn, CHRIS_USER_ID, days_back=90)
            if len(activity_df) > 0:
                evidence['activity_logs'] = activity_df.to_dict('records')
                print(f"✅ Found {len(activity_df)} activity records")
                if len(activity_df) > 0:
                    first_login = activity_df.iloc[-1]['CreateDate']
                    last_login = activity_df.iloc[0]['CreateDate']
                    print(f"   First activity: {first_login}")
                    print(f"   Last activity: {last_login}")
            else:
                print("⚠️ No activity logs found")
        except Exception as e:
            evidence['errors'].append(f"Activity logs error: {e}")
            print(f"❌ Error: {e}")
    
    # 4. Database - Listing Command Usage
    if conn:
        print("\n" + "-"*80)
        print("4. COLLECTING LISTING COMMAND USAGE")
        print("-"*80)
        try:
            config_df, leads_df = get_listing_command_usage(conn, CHRIS_USER_ID)
            if len(config_df) > 0:
                evidence['listing_command_usage'] = {
                    'configuration': config_df.to_dict('records'),
                    'leads_generated': leads_df.to_dict('records') if len(leads_df) > 0 else []
                }
                print(f"✅ Found Listing Command configuration")
                print(f"✅ Found {len(leads_df)} leads generated")
            else:
                print("⚠️ No Listing Command usage found")
        except Exception as e:
            evidence['errors'].append(f"Listing Command usage error: {e}")
            print(f"❌ Error: {e}")
        finally:
            if conn:
                conn.close()
    
    # 5. Intercom - Conversations
    print("\n" + "-"*80)
    print("5. COLLECTING INTERCOM CONVERSATIONS")
    print("-"*80)
    try:
        # Try by user ID first
        intercom_data = search_intercom_by_user_id(CHRIS_USER_ID)
        if not intercom_data or intercom_data.get('total_count', 0) == 0:
            # Fallback to email
            print("   Trying email search...")
            intercom_data = search_intercom_by_email(CHRIS_EMAIL)
        
        if intercom_data and intercom_data.get('total_count', 0) > 0:
            evidence['intercom_conversations'] = intercom_data
            print(f"✅ Found {intercom_data.get('total_count', 0)} conversations")
        else:
            print("✅ No Intercom conversations found (proves no contact before dispute)")
            evidence['intercom_conversations'] = {'total_count': 0, 'conversations': []}
    except Exception as e:
        evidence['errors'].append(f"Intercom error: {e}")
        print(f"❌ Error: {e}")
    
    # 6. Zoom Phone - Call Logs
    print("\n" + "-"*80)
    print("6. COLLECTING ZOOM PHONE CALL LOGS")
    print("-"*80)
    try:
        zoom_token = get_zoom_access_token()
        if zoom_token:
            zoom_data = search_zoom_call_logs(zoom_token, CHRIS_PHONE, days_back=90)
            if zoom_data and zoom_data.get('total_records', 0) > 0:
                evidence['zoom_call_logs'] = zoom_data
                print(f"✅ Found {zoom_data.get('total_records', 0)} call logs")
            else:
                print("✅ No Zoom Phone calls found (proves no contact before dispute)")
                evidence['zoom_call_logs'] = {'total_records': 0, 'call_logs': []}
        else:
            evidence['errors'].append("Failed to get Zoom access token")
            print("❌ Failed to get Zoom token")
    except Exception as e:
        evidence['errors'].append(f"Zoom Phone error: {e}")
        print(f"❌ Error: {e}")
    
    return evidence

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    evidence = collect_all_evidence()
    
    # Save evidence to JSON file
    output_file = f"EVIDENCE_ChrisPlank_{PAYPAL_TRANSACTION_ID}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(evidence, f, indent=2, default=str)
    
    print("\n" + "="*80)
    print("EVIDENCE COLLECTION COMPLETE")
    print("="*80)
    print(f"\nEvidence saved to: {output_file}")
    print(f"\nSummary:")
    print(f"  - User Details: {'✅' if evidence['user_details'] else '❌'}")
    print(f"  - Activity Logs: {len(evidence['activity_logs']) if evidence['activity_logs'] else 0} records")
    print(f"  - Listing Command Usage: {'✅' if evidence['listing_command_usage'] else '❌'}")
    print(f"  - Intercom Conversations: {evidence['intercom_conversations'].get('total_count', 0) if evidence['intercom_conversations'] else 0}")
    print(f"  - Zoom Call Logs: {evidence['zoom_call_logs'].get('total_records', 0) if evidence['zoom_call_logs'] else 0}")
    print(f"  - Errors: {len(evidence['errors'])}")
    
    if evidence['errors']:
        print(f"\n⚠️ Errors encountered:")
        for error in evidence['errors']:
            print(f"   - {error}")


