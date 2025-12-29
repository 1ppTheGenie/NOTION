"""
Verify leads from campaign and check for chargeback info
"""

import requests
import json
import pyodbc
import pandas as pd

WHMCS_IDENTIFIER = 'K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q'
WHMCS_SECRET = 'nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV'
WHMCS_URL = 'https://accounts.1parkplace.com/includes/api.php'
WHMCS_ACCESS_KEY = 'whmcs!api@access$1ppGenie'

CHRIS_ASPNET_ID = 'f5174e53-8f6e-4d23-9eab-f8d6802b39c9'

print('='*80)
print('ADDITIONAL VERIFICATION - LEADS AND CHARGEBACK INFO')
print('='*80)

# Connect to database
drivers = [d for d in pyodbc.drivers() if 'ODBC Driver' in d]
driver = next((d for d in drivers if '17' in d or '18' in d), drivers[-1])
conn_str = f'DRIVER={{{driver}}};SERVER=192.168.29.45,1433;DATABASE=FarmGenie;UID=cursor;PWD=1ppINSAyay$;Encrypt=yes;TrustServerCertificate=yes'
conn = pyodbc.connect(conn_str, autocommit=True)

# Get detailed lead count for the campaign
print('\n1. LEADS FROM THIS CAMPAIGN (SmsReportSendQueueId=12962):')
query1 = """
SELECT 
    COUNT(DISTINCT gl.GenieLeadId) as UniqueLeads,
    COUNT(*) as TotalRecords,
    MIN(gl.CreateDate) as FirstLead,
    MAX(gl.CreateDate) as LastLead
FROM dbo.GenieLead gl
JOIN dbo.GenieLeadSource gls ON gl.GenieLeadId = gls.GenieLeadId
WHERE gls.SmsReportSendQueueId = 12962
"""
df1 = pd.read_sql(query1, conn)
print(df1.to_string())

# Get specific leads
print('\n2. INDIVIDUAL LEADS FROM THIS CAMPAIGN:')
query2 = """
SELECT TOP 30
    gl.GenieLeadId,
    gl.CreateDate,
    gl.LeadName
FROM dbo.GenieLead gl
JOIN dbo.GenieLeadSource gls ON gl.GenieLeadId = gls.GenieLeadId
WHERE gls.SmsReportSendQueueId = 12962
ORDER BY gl.CreateDate ASC
"""
df2 = pd.read_sql(query2, conn)
print(df2.to_string())

conn.close()

# Now check WHMCS for any notes about chargebacks
print('\n3. CHECKING WHMCS FOR CHARGEBACK NOTES:')

def whmcs_call(action, extra_params={}):
    payload = {
        'identifier': WHMCS_IDENTIFIER,
        'secret': WHMCS_SECRET,
        'accesskey': WHMCS_ACCESS_KEY,
        'action': action,
        'responsetype': 'json'
    }
    payload.update(extra_params)
    return requests.post(WHMCS_URL, data=payload, verify=True, timeout=30).json()

# Get client details with notes
data = whmcs_call('GetClientsDetails', {'clientid': 3091, 'stats': True})
print(f"Result: {data.get('result', 'unknown')}")
if 'client' in data:
    c = data['client']
    print(f"Credit Balance: {c.get('credit', '0')}")
    print(f"Notes: {c.get('notes', 'NONE')}")

# Get ticket/support history
print('\n4. CHECKING FOR TICKETS/SUPPORT REQUESTS:')
data2 = whmcs_call('GetTickets', {'clientid': 3091})
print(f"Result: {data2.get('result', 'unknown')}")
if 'tickets' in data2:
    tickets = data2['tickets']
    if 'ticket' in tickets:
        tlist = tickets['ticket']
        if isinstance(tlist, list):
            print(f"Total Tickets: {len(tlist)}")
            for t in tlist:
                print(f"  ID: {t.get('id')} | Date: {t.get('date')} | Subject: {str(t.get('subject',''))[:50]} | Status: {t.get('status')}")
        else:
            print(f"Ticket: {tlist}")
    else:
        print("No tickets found")
else:
    print(f"Response: {json.dumps(data2, indent=2)[:500]}")

# Check for activity log
print('\n5. CHECKING WHMCS ACTIVITY LOG:')
data3 = whmcs_call('GetActivityLog', {'clientid': 3091, 'limitnum': 50})
print(f"Result: {data3.get('result', 'unknown')}")
if 'activity' in data3:
    activities = data3['activity']
    if 'entry' in activities:
        entries = activities['entry']
        if isinstance(entries, list):
            print(f"Total Activity Entries: {len(entries)}")
            # Look for chargeback-related entries
            for e in entries:
                desc = str(e.get('description', ''))
                if 'chargeback' in desc.lower() or 'dispute' in desc.lower() or 'refund' in desc.lower():
                    print(f"  FOUND: {e.get('date')} - {desc[:100]}")
        else:
            print(f"Entry: {entries}")
    else:
        print("No activity entries found")
else:
    print(f"Response: {json.dumps(data3, indent=2)[:500]}")

print('\n' + '='*80)
print('VERIFICATION COMPLETE')
print('='*80)

