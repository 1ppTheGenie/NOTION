"""
Get detailed Intercom conversation data for Susan Featherly
Contact ID: 6733c9c27967637d3d224f2d
"""

import requests
import json
from datetime import datetime

INTERCOM_TOKEN = "[REDACTED - See Master Credential Tracker]"
INTERCOM_BASE_URL = "https://api.intercom.io"

headers = {
    "Authorization": f"Bearer {INTERCOM_TOKEN}",
    "Accept": "application/json",
    "Intercom-Version": "2.10",
    "Content-Type": "application/json"
}

# Conversation IDs from the search
conversation_ids = [
    "215471416308487",
    "215471416438563", 
    "215471416379863",
    "215470650422802",
    "215470441190422",
    "117032700499734"
]

print('='*80)
print('INTERCOM CONVERSATION DETAILS - SUSAN FEATHERLY')
print('='*80)

# Disputed transaction date: October 14, 2025 (epoch: 1728864000)
# Dispute filed: October 24, 2025 (from case info)
TRANSACTION_DATE = datetime(2025, 10, 14)
DISPUTE_DATE = datetime(2025, 10, 24)

for conv_id in conversation_ids:
    print(f'\n--- Conversation {conv_id} ---')
    url = f"{INTERCOM_BASE_URL}/conversations/{conv_id}"
    
    try:
        response = requests.get(url, headers=headers, timeout=30)
        if response.status_code == 200:
            data = response.json()
            
            # Get timestamps
            created_at = data.get('created_at', 0)
            updated_at = data.get('updated_at', 0)
            created_date = datetime.fromtimestamp(created_at) if created_at else None
            updated_date = datetime.fromtimestamp(updated_at) if updated_at else None
            
            print(f'Created: {created_date}')
            print(f'Updated: {updated_date}')
            print(f'State: {data.get("state")}')
            
            # Check if this is before or after transaction/dispute
            if created_date:
                if created_date < TRANSACTION_DATE:
                    timing = "BEFORE TRANSACTION"
                elif created_date < DISPUTE_DATE:
                    timing = "AFTER TRANSACTION, BEFORE DISPUTE"
                else:
                    timing = "AFTER DISPUTE FILED"
                print(f'Timing: {timing}')
            
            # Get source/first message
            source = data.get('source', {})
            if source:
                body = source.get('body', '')
                # Clean HTML
                import re
                clean_body = re.sub('<[^<]+?>', '', body)[:500] if body else ''
                print(f'Subject/First Message: {clean_body[:200]}...' if len(clean_body) > 200 else f'Subject/First Message: {clean_body}')
            
            # Get conversation parts (messages)
            parts = data.get('conversation_parts', {}).get('conversation_parts', [])
            print(f'Total messages: {len(parts)}')
            
            # Check for cancellation-related keywords
            all_text = str(data).lower()
            if 'cancel' in all_text:
                print('*** CONTAINS "CANCEL" ***')
            if 'refund' in all_text:
                print('*** CONTAINS "REFUND" ***')
            if 'chargeback' in all_text:
                print('*** CONTAINS "CHARGEBACK" ***')
            if 'dispute' in all_text:
                print('*** CONTAINS "DISPUTE" ***')
                
        else:
            print(f'Error: {response.status_code} - {response.text[:200]}')
    except Exception as e:
        print(f'Exception: {e}')

print('\n' + '='*80)
print('ANALYSIS COMPLETE')
print('='*80)


