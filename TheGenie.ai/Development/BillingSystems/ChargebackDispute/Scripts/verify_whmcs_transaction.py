"""
WHMCS API - Transaction Verification for Chris Plank
"""

import requests
import json

# WHMCS API Credentials
WHMCS_IDENTIFIER = 'K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q'
WHMCS_SECRET = 'nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV'
WHMCS_URL = 'https://accounts.1parkplace.com/includes/api.php'
WHMCS_ACCESS_KEY = 'whmcs!api@access$1ppGenie'

# Chris Plank's WHMCS Client ID from the evidence
CHRIS_WHMCS_ID = 3091

print('='*80)
print('WHMCS API - TRANSACTION VERIFICATION FOR CHRIS PLANK')
print('='*80)

# 1. Get client details
print('\n1. CLIENT DETAILS:')
payload = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetClientsDetails',
    'clientid': CHRIS_WHMCS_ID,
    'responsetype': 'json'
}

try:
    response = requests.post(WHMCS_URL, data=payload, verify=True, timeout=30)
    print(f'Status: {response.status_code}')
    if response.status_code == 200:
        data = response.json()
        print(f'Result: {data.get("result", "unknown")}')
        if 'client' in data:
            client = data['client']
            print(f'  Name: {client.get("firstname", "")} {client.get("lastname", "")}')
            print(f'  Email: {client.get("email", "")}')
            print(f'  Status: {client.get("status", "")}')
            print(f'  Date Created: {client.get("datecreated", "")}')
        else:
            print(f'  Response: {json.dumps(data, indent=2)[:1000]}')
    else:
        print(f'Error: {response.text[:500]}')
except Exception as e:
    print(f'Exception: {e}')

# 2. Get transactions
print('\n2. TRANSACTIONS:')
payload2 = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetTransactions',
    'clientid': CHRIS_WHMCS_ID,
    'responsetype': 'json'
}

try:
    response2 = requests.post(WHMCS_URL, data=payload2, verify=True, timeout=30)
    print(f'Status: {response2.status_code}')
    if response2.status_code == 200:
        data2 = response2.json()
        print(f'Result: {data2.get("result", "unknown")}')
        if 'transactions' in data2:
            trans = data2['transactions']
            if 'transaction' in trans:
                transactions = trans['transaction']
                if isinstance(transactions, list):
                    print(f'  Found {len(transactions)} transactions')
                    for t in transactions:
                        print(f'    ID: {t.get("id")} | Date: {t.get("date")} | Amount: ${t.get("amountin", 0)} | Gateway: {t.get("gateway")} | TransID: {t.get("transid")}')
                else:
                    print(f'    Single transaction: {transactions}')
            else:
                print(f'  No transactions found')
        else:
            print(f'  Response: {json.dumps(data2, indent=2)[:1000]}')
    else:
        print(f'Error: {response2.text[:500]}')
except Exception as e:
    print(f'Exception: {e}')

# 3. Get invoices
print('\n3. INVOICES:')
payload3 = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetInvoices',
    'userid': CHRIS_WHMCS_ID,
    'responsetype': 'json'
}

try:
    response3 = requests.post(WHMCS_URL, data=payload3, verify=True, timeout=30)
    print(f'Status: {response3.status_code}')
    if response3.status_code == 200:
        data3 = response3.json()
        print(f'Result: {data3.get("result", "unknown")}')
        if 'invoices' in data3:
            invs = data3['invoices']
            if 'invoice' in invs:
                invoices = invs['invoice']
                if isinstance(invoices, list):
                    print(f'  Found {len(invoices)} invoices')
                    for inv in invoices:
                        print(f'    ID: {inv.get("id")} | Date: {inv.get("date")} | Total: ${inv.get("total", 0)} | Status: {inv.get("status")}')
                else:
                    print(f'    Single invoice: {invoices}')
            else:
                print(f'  No invoices found')
        else:
            print(f'  Response: {json.dumps(data3, indent=2)[:1000]}')
    else:
        print(f'Error: {response3.text[:500]}')
except Exception as e:
    print(f'Exception: {e}')

# 4. Get orders
print('\n4. ORDERS:')
payload4 = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetOrders',
    'userid': CHRIS_WHMCS_ID,
    'responsetype': 'json'
}

try:
    response4 = requests.post(WHMCS_URL, data=payload4, verify=True, timeout=30)
    print(f'Status: {response4.status_code}')
    if response4.status_code == 200:
        data4 = response4.json()
        print(f'Result: {data4.get("result", "unknown")}')
        if 'orders' in data4:
            orders = data4['orders']
            if 'order' in orders:
                order_list = orders['order']
                if isinstance(order_list, list):
                    print(f'  Found {len(order_list)} orders')
                    for o in order_list:
                        print(f'    ID: {o.get("id")} | Date: {o.get("date")} | Amount: ${o.get("amount", 0)} | Status: {o.get("orderstatus")} | PaymentMethod: {o.get("paymentmethod")}')
                else:
                    print(f'    Single order: {order_list}')
            else:
                print(f'  No orders found')
        else:
            print(f'  Response: {json.dumps(data4, indent=2)[:1000]}')
    else:
        print(f'Error: {response4.text[:500]}')
except Exception as e:
    print(f'Exception: {e}')

print('\n' + '='*80)
print('VERIFICATION COMPLETE')
print('='*80)

