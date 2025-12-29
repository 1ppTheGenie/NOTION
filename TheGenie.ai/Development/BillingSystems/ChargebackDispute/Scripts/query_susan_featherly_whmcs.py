"""
WHMCS API - Data Collection for Susan Featherly Competition Command Dispute
Invoice: 62279
PayPal Case: PP-R-NVE-599340890
"""

import requests
import json

# WHMCS API Credentials (from verify_whmcs_transaction.py)
WHMCS_IDENTIFIER = 'K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q'
WHMCS_SECRET = 'nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV'
WHMCS_URL = 'https://accounts.1parkplace.com/includes/api.php'
WHMCS_ACCESS_KEY = 'whmcs!api@access$1ppGenie'

# Susan Featherly's WHMCS Client ID (from FarmGenie.dbo.UserWhmcs)
SUSAN_WHMCS_ID = 3158

# Invoice we're investigating
TARGET_INVOICE = 62279

print('='*80)
print('WHMCS API - DATA FOR SUSAN FEATHERLY')
print('Competition Command Dispute - Invoice 62279')
print('='*80)

# 1. Get client details
print('\n1. CLIENT DETAILS:')
payload = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetClientsDetails',
    'clientid': SUSAN_WHMCS_ID,
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

# 2. Get specific invoice 62279
print('\n2. INVOICE 62279 DETAILS:')
payload2 = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetInvoice',
    'invoiceid': TARGET_INVOICE,
    'responsetype': 'json'
}

try:
    response2 = requests.post(WHMCS_URL, data=payload2, verify=True, timeout=30)
    print(f'Status: {response2.status_code}')
    if response2.status_code == 200:
        data2 = response2.json()
        print(f'Result: {data2.get("result", "unknown")}')
        print(json.dumps(data2, indent=2))
except Exception as e:
    print(f'Exception: {e}')

# 3. Get all orders for this user
print('\n3. ALL ORDERS:')
payload3 = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetOrders',
    'userid': SUSAN_WHMCS_ID,
    'responsetype': 'json'
}

try:
    response3 = requests.post(WHMCS_URL, data=payload3, verify=True, timeout=30)
    print(f'Status: {response3.status_code}')
    if response3.status_code == 200:
        data3 = response3.json()
        print(f'Result: {data3.get("result", "unknown")}')
        if 'orders' in data3:
            orders = data3['orders']
            if 'order' in orders:
                order_list = orders['order']
                if isinstance(order_list, list):
                    print(f'  Found {len(order_list)} orders')
                    for o in order_list:
                        print(f'    ID: {o.get("id")} | Date: {o.get("date")} | Amount: ${o.get("amount", 0)} | Status: {o.get("orderstatus")} | PaymentMethod: {o.get("paymentmethod")}')
                        # Print order notes if available
                        if o.get('notes'):
                            print(f'      Notes: {o.get("notes")}')
                        # Print line items if available
                        if 'lineitems' in o:
                            items = o['lineitems']
                            if 'lineitem' in items:
                                for item in (items['lineitem'] if isinstance(items['lineitem'], list) else [items['lineitem']]):
                                    print(f'      Product: {item.get("product")} | ProductID: {item.get("producttype")}')
                else:
                    print(f'    Single order: {json.dumps(order_list, indent=2)}')
            else:
                print(f'  No orders found')
        else:
            print(f'  Response: {json.dumps(data3, indent=2)[:2000]}')
except Exception as e:
    print(f'Exception: {e}')

# 4. Get transactions
print('\n4. TRANSACTIONS:')
payload4 = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetTransactions',
    'clientid': SUSAN_WHMCS_ID,
    'responsetype': 'json'
}

try:
    response4 = requests.post(WHMCS_URL, data=payload4, verify=True, timeout=30)
    print(f'Status: {response4.status_code}')
    if response4.status_code == 200:
        data4 = response4.json()
        print(f'Result: {data4.get("result", "unknown")}')
        if 'transactions' in data4:
            trans = data4['transactions']
            if 'transaction' in trans:
                transactions = trans['transaction']
                if isinstance(transactions, list):
                    print(f'  Found {len(transactions)} transactions')
                    for t in transactions:
                        print(f'    ID: {t.get("id")} | Date: {t.get("date")} | Amount: ${t.get("amountin", 0)} | Gateway: {t.get("gateway")} | TransID: {t.get("transid")} | InvoiceID: {t.get("invoiceid")}')
                else:
                    print(f'    Single transaction: {transactions}')
except Exception as e:
    print(f'Exception: {e}')

# 5. Get client products (hosting/services)
print('\n5. CLIENT PRODUCTS/SERVICES:')
payload5 = {
    'identifier': WHMCS_IDENTIFIER,
    'secret': WHMCS_SECRET,
    'accesskey': WHMCS_ACCESS_KEY,
    'action': 'GetClientsProducts',
    'clientid': SUSAN_WHMCS_ID,
    'responsetype': 'json'
}

try:
    response5 = requests.post(WHMCS_URL, data=payload5, verify=True, timeout=30)
    print(f'Status: {response5.status_code}')
    if response5.status_code == 200:
        data5 = response5.json()
        print(f'Result: {data5.get("result", "unknown")}')
        print(json.dumps(data5, indent=2))
except Exception as e:
    print(f'Exception: {e}')

print('\n' + '='*80)
print('DATA COLLECTION COMPLETE')
print('='*80)

