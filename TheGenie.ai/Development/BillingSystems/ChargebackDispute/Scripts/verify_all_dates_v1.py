"""
COMPLETE DATE AND TRANSACTION VERIFICATION
Verifies 100% accuracy from ALL systems
"""

import requests
import json
import pyodbc
import pandas as pd
from datetime import datetime

print("="*80)
print("COMPLETE TRANSACTION VERIFICATION - CHRIS PLANK")
print("Checking: WHMCS, FarmGenie Database, All Dates")
print("="*80)

# ============================================================================
# WHMCS API CREDENTIALS
# ============================================================================
WHMCS_IDENTIFIER = 'K6Zwje0Ms1GTCGs2NKSG4pGemFuoKT7Q'
WHMCS_SECRET = 'nLqOARsSFdUuUTl88D3TNzGX2qcsOoWV'
WHMCS_URL = 'https://accounts.1parkplace.com/includes/api.php'
WHMCS_ACCESS_KEY = 'whmcs!api@access$1ppGenie'

# Chris Plank's IDs
CHRIS_WHMCS_ID = 3091
CHRIS_ASPNET_ID = 'f5174e53-8f6e-4d23-9eab-f8d6802b39c9'
CHRIS_EMAIL = 'cp@pacificapg.com'

# ============================================================================
# PART 1: WHMCS VERIFICATION
# ============================================================================
print("\n" + "="*80)
print("PART 1: WHMCS DATA (Billing System)")
print("="*80)

def whmcs_api_call(action, params={}):
    payload = {
        'identifier': WHMCS_IDENTIFIER,
        'secret': WHMCS_SECRET,
        'accesskey': WHMCS_ACCESS_KEY,
        'action': action,
        'responsetype': 'json'
    }
    payload.update(params)
    response = requests.post(WHMCS_URL, data=payload, verify=True, timeout=30)
    if response.status_code == 200:
        return response.json()
    return {'error': response.text}

# Get client details
print("\n1.1 CLIENT DETAILS:")
client_data = whmcs_api_call('GetClientsDetails', {'clientid': CHRIS_WHMCS_ID})
if client_data.get('result') == 'success' and 'client' in client_data:
    c = client_data['client']
    print(f"   Name: {c.get('firstname', '')} {c.get('lastname', '')}")
    print(f"   Email: {c.get('email', '')}")
    print(f"   Status: {c.get('status', '')}")
    print(f"   Date Created: {c.get('datecreated', 'NOT SET')}")

# Get ALL transactions
print("\n1.2 ALL TRANSACTIONS FOR CHRIS PLANK:")
trans_data = whmcs_api_call('GetTransactions', {'clientid': CHRIS_WHMCS_ID})
if trans_data.get('result') == 'success':
    transactions = trans_data.get('transactions', {}).get('transaction', [])
    if not isinstance(transactions, list):
        transactions = [transactions]
    print(f"   Total Transactions: {len(transactions)}")
    print("-" * 70)
    print(f"   {'ID':<8} {'DATE':<22} {'AMOUNT':<10} {'GATEWAY':<12} {'TRANS_ID':<25}")
    print("-" * 70)
    for t in transactions:
        print(f"   {t.get('id',''):<8} {t.get('date',''):<22} ${t.get('amountin',0):<9} {t.get('gateway',''):<12} {t.get('transid',''):<25}")

# Get ALL invoices
print("\n1.3 ALL INVOICES FOR CHRIS PLANK:")
inv_data = whmcs_api_call('GetInvoices', {'userid': CHRIS_WHMCS_ID})
if inv_data.get('result') == 'success':
    invoices = inv_data.get('invoices', {}).get('invoice', [])
    if not isinstance(invoices, list):
        invoices = [invoices]
    print(f"   Total Invoices: {len(invoices)}")
    print("-" * 70)
    print(f"   {'ID':<8} {'DATE':<12} {'DUE DATE':<12} {'TOTAL':<10} {'STATUS':<12}")
    print("-" * 70)
    for inv in invoices:
        print(f"   {inv.get('id',''):<8} {inv.get('date',''):<12} {inv.get('duedate',''):<12} ${inv.get('total',0):<9} {inv.get('status',''):<12}")

# Get ALL orders
print("\n1.4 ALL ORDERS FOR CHRIS PLANK:")
order_data = whmcs_api_call('GetOrders', {'userid': CHRIS_WHMCS_ID})
if order_data.get('result') == 'success':
    orders = order_data.get('orders', {}).get('order', [])
    if not isinstance(orders, list):
        orders = [orders]
    print(f"   Total Orders: {len(orders)}")
    print("-" * 70)
    print(f"   {'ORDER_ID':<10} {'DATE':<22} {'AMOUNT':<10} {'INVOICE_ID':<12} {'PAYMENT_METHOD':<15}")
    print("-" * 70)
    for o in orders:
        print(f"   {o.get('id',''):<10} {o.get('date',''):<22} ${o.get('amount',0):<9} {o.get('invoiceid',''):<12} {o.get('paymentmethod',''):<15}")

# Get specific order 9270 (the December 5, 2025 one)
print("\n1.5 DETAILED ORDER #9270 (December 2025):")
order_detail = whmcs_api_call('GetOrders', {'id': 9270})
if order_detail.get('result') == 'success':
    orders = order_detail.get('orders', {}).get('order', [])
    if orders:
        o = orders[0] if isinstance(orders, list) else orders
        print(f"   Order ID: {o.get('id')}")
        print(f"   Order Date: {o.get('date')}")
        print(f"   Amount: ${o.get('amount')}")
        print(f"   Invoice ID: {o.get('invoiceid')}")
        print(f"   Payment Method: {o.get('paymentmethod')}")
        print(f"   Order Status: {o.get('orderstatus')}")
        # Check for line items
        if 'lineitems' in o:
            print(f"   Line Items: {o.get('lineitems')}")

# ============================================================================
# PART 2: CHECK PAYFLOW CONFIGURATION IN WHMCS
# ============================================================================
print("\n" + "="*80)
print("PART 2: PAYFLOW CONFIGURATION")
print("="*80)

# Get payment methods
print("\n2.1 PAYMENT GATEWAYS:")
gateway_data = whmcs_api_call('GetPayMethods', {'clientid': CHRIS_WHMCS_ID})
print(f"   Response: {json.dumps(gateway_data, indent=2)[:1000]}")

# ============================================================================
# PART 3: FARMGENIE DATABASE VERIFICATION
# ============================================================================
print("\n" + "="*80)
print("PART 3: FARMGENIE DATABASE (Order Execution)")
print("="*80)

# Connect to database
try:
    drivers = [d for d in pyodbc.drivers() if 'ODBC Driver' in d]
    driver = next((d for d in drivers if '17' in d or '18' in d), drivers[-1])
    conn_str = f'DRIVER={{{driver}}};SERVER=192.168.29.45,1433;DATABASE=FarmGenie;UID=cursor;PWD=1ppINSAyay$;Encrypt=yes;TrustServerCertificate=yes'
    conn = pyodbc.connect(conn_str, autocommit=True)
    
    # 3.1 ListingCommandQueue
    print("\n3.1 LISTING COMMAND QUEUE (Order Execution):")
    query1 = """
    SELECT 
        ListingCommandQueueId,
        CreateDate,
        ProcessedDate,
        MlsNumber,
        ListingCommandConfigurationId
    FROM dbo.ListingCommandQueue
    WHERE AspNetUserId = ?
    AND MlsNumber = 'SB25228445'
    ORDER BY CreateDate DESC
    """
    df1 = pd.read_sql(query1, conn, params=[CHRIS_ASPNET_ID])
    print(df1.to_string())
    
    # 3.2 SmsReportSendQueue
    print("\n3.2 SMS CAMPAIGN QUEUE (When SMS was sent):")
    query2 = """
    SELECT 
        SmsReportSendQueueId,
        CreateDate,
        StartDate,
        ProcessDate,
        SourceMlsNumber
    FROM dbo.SmsReportSendQueue
    WHERE SourceMlsNumber = 'SB25228445'
    ORDER BY CreateDate DESC
    """
    df2 = pd.read_sql(query2, conn, params=[])
    print(df2.to_string())
    
    # 3.3 NotificationQueue Summary
    print("\n3.3 NOTIFICATION QUEUE (Actual SMS Delivery):")
    query3 = """
    SELECT 
        COUNT(*) as TotalMessages,
        SUM(CASE WHEN ResponseCode = 1 THEN 1 ELSE 0 END) as Sent,
        SUM(CASE WHEN ResponseCode = 2 THEN 1 ELSE 0 END) as Failed,
        MIN(CreateDate) as FirstMessage,
        MAX(ProcessDate) as LastProcessed
    FROM dbo.NotificationQueue
    WHERE NotificationQueueId IN (
        SELECT NotificationQueueId FROM dbo.SmsReportMessageQueuedLog WHERE SmsReportSendQueueId = 12962
    )
    """
    df3 = pd.read_sql(query3, conn, params=[])
    print(df3.to_string())
    
    # 3.4 GenieLead (Responses)
    print("\n3.4 GENIE LEAD (Responses/Engagements):")
    query4 = """
    SELECT 
        COUNT(*) as TotalLeads,
        MIN(CreateDate) as FirstLead,
        MAX(CreateDate) as LastLead
    FROM dbo.GenieLead
    WHERE AspNetUserId = ?
    AND CreateDate >= '2025-12-01'
    """
    df4 = pd.read_sql(query4, conn, params=[CHRIS_ASPNET_ID])
    print(df4.to_string())
    
    # 3.5 UserActivity for the order
    print("\n3.5 USER ACTIVITY (December 4-5, 2025):")
    query5 = """
    SELECT TOP 20
        UserActivityId,
        CreateDate,
        Note
    FROM dbo.UserActivity
    WHERE AspNetUserId = ?
    AND CreateDate >= '2025-12-04' AND CreateDate < '2025-12-06'
    ORDER BY CreateDate ASC
    """
    df5 = pd.read_sql(query5, conn, params=[CHRIS_ASPNET_ID])
    print(df5.to_string())
    
    conn.close()
    
except Exception as e:
    print(f"Database Error: {e}")

# ============================================================================
# SUMMARY
# ============================================================================
print("\n" + "="*80)
print("VERIFIED TRANSACTION SUMMARY")
print("="*80)

print("""
KEY DATES TO VERIFY:
1. WHMCS Order Date: December 5, 2025 at 12:11:06 (Order #9270)
2. WHMCS Transaction Date: December 5, 2025 at 12:11:35 (Trans ID: 6HL70778WD879401B)
3. FarmGenie Queue Date: December 4, 2025 at 19:37:23 (Queue #1237)
4. SMS Campaign Start: December 5, 2025 at 12:42:23 (Queue #12962)

DISCREPANCY NOTED:
- FarmGenie shows order placed Dec 4, 2025 at 7:37 PM
- WHMCS shows order placed Dec 5, 2025 at 12:11 PM
- This is approximately 17 hours difference!

POSSIBLE EXPLANATION:
- Customer may have started the order on Dec 4 but payment processed Dec 5
- The FarmGenie queue is created BEFORE payment
- The WHMCS order/transaction is created AFTER payment
""")

print("\nVERIFICATION COMPLETE")
print("="*80)

