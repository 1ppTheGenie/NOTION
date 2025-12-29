"""
Explore Chris Plank Case - Fixed Column Names
"""

import pyodbc
import pandas as pd
import sys

sys.stdout.reconfigure(encoding='utf-8')

def connect():
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER=192.168.29.45,1433;"
        f"DATABASE=FarmGenie;"
        f"UID=cursor;PWD=1ppINSAyay$;"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)

def get_table_columns(conn, schema, table):
    """Get all columns for a table"""
    query = """
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
    ORDER BY ORDINAL_POSITION
    """
    return pd.read_sql(query, conn, params=(schema, table))

def explore_chris_plank(conn):
    chris_user_id = "f5174e53-8f6e-4d23-9eab-f8d6802b39c9"
    chris_email = "cp@pacificapg.com"
    
    print("\n" + "="*80)
    print("CHRIS PLANK CASE - FIXED QUERIES")
    print("="*80)
    print(f"\nUser ID: {chris_user_id}")
    print(f"Email: {chris_email}\n")
    
    # 1. Orders with correct column name
    print("-"*80)
    print("1. ORDERS (Order table)")
    print("-"*80)
    try:
        order_query = f"""
        SELECT TOP 10 * 
        FROM dbo.[Order] 
        WHERE AspNetUserId = '{chris_user_id}'
        ORDER BY CreateDate DESC
        """
        order_df = pd.read_sql(order_query, conn)
        if len(order_df) > 0:
            print(f"Found {len(order_df)} orders:")
            print(order_df.to_string())
        else:
            print("No orders found")
    except Exception as e:
        print(f"Error: {e}")
    
    # 2. ListingCommandBilling - check structure first
    print("\n" + "-"*80)
    print("2. LISTING COMMAND BILLING (checking structure)")
    print("-"*80)
    try:
        cols = get_table_columns(conn, 'dbo', 'ListingCommandBilling')
        print("Columns:")
        print(cols.to_string())
        
        # Find user ID column
        user_col = None
        for col in cols['COLUMN_NAME']:
            if 'user' in col.lower() or 'aspnet' in col.lower():
                user_col = col
                break
        
        if user_col:
            query = f"SELECT TOP 10 * FROM dbo.ListingCommandBilling WHERE [{user_col}] = '{chris_user_id}' ORDER BY CreateDate DESC"
            lc_df = pd.read_sql(query, conn)
            if len(lc_df) > 0:
                print(f"\nFound {len(lc_df)} billing records:")
                print(lc_df.to_string())
            else:
                print("\nNo billing records found")
    except Exception as e:
        print(f"Error: {e}")
    
    # 3. ActivityTracker - login/access logs
    print("\n" + "-"*80)
    print("3. LOGIN/ACCESS LOGS (ActivityTracker)")
    print("-"*80)
    try:
        activity_query = f"""
        SELECT TOP 20 
            at.ActivityTrackerID,
            at.CreateDate,
            at.Note,
            act.ActivityTypeName
        FROM dbo.ActivityTracker at
        LEFT JOIN dbo.ActivityType act ON at.ActivityTypeID = act.ActivityTypeID
        WHERE at.AspNetUserID = '{chris_user_id}'
        ORDER BY at.CreateDate DESC
        """
        activity_df = pd.read_sql(activity_query, conn)
        if len(activity_df) > 0:
            print(f"Found {len(activity_df)} activity records:")
            print(activity_df.to_string())
        else:
            print("No activity records found")
    except Exception as e:
        print(f"Error: {e}")
    
    # 4. UserWhmcs - check structure
    print("\n" + "-"*80)
    print("4. WHMCS MAPPING (UserWhmcs)")
    print("-"*80)
    try:
        cols = get_table_columns(conn, 'dbo', 'UserWhmcs')
        print("Columns:")
        print(cols.to_string())
        
        user_col = None
        for col in cols['COLUMN_NAME']:
            if 'user' in col.lower() or 'aspnet' in col.lower():
                user_col = col
                break
        
        if user_col:
            query = f"SELECT * FROM dbo.UserWhmcs WHERE [{user_col}] = '{chris_user_id}'"
            whmcs_df = pd.read_sql(query, conn)
            if len(whmcs_df) > 0:
                print(f"\nFound WHMCS mapping:")
                print(whmcs_df.to_string())
            else:
                print("\nNo WHMCS mapping found")
    except Exception as e:
        print(f"Error: {e}")
    
    # 5. OrderItem - find what was purchased
    print("\n" + "-"*80)
    print("5. ORDER ITEMS (OrderItem)")
    print("-"*80)
    try:
        # First get orders
        orders_query = f"SELECT OrderId FROM dbo.[Order] WHERE AspNetUserId = '{chris_user_id}'"
        orders = pd.read_sql(orders_query, conn)
        
        if len(orders) > 0:
            order_ids = orders['OrderId'].tolist()
            order_ids_str = ','.join(map(str, order_ids))
            
            cols = get_table_columns(conn, 'dbo', 'OrderItem')
            print("OrderItem columns:")
            print(cols.to_string())
            
            items_query = f"""
            SELECT oi.*, oit.OrderItemTypeName
            FROM dbo.OrderItem oi
            LEFT JOIN dbo.OrderItemType oit ON oi.OrderItemTypeId = oit.OrderItemTypeId
            WHERE oi.OrderId IN ({order_ids_str})
            ORDER BY oi.CreateDate DESC
            """
            items_df = pd.read_sql(items_query, conn)
            if len(items_df) > 0:
                print(f"\nFound {len(items_df)} order items:")
                print(items_df.to_string())
            else:
                print("\nNo order items found")
        else:
            print("No orders found to check items")
    except Exception as e:
        print(f"Error: {e}")
    
    # 6. Search for transaction around 12/5/2025
    print("\n" + "-"*80)
    print("6. TRANSACTIONS AROUND 12/5/2025")
    print("-"*80)
    try:
        trans_query = f"""
        SELECT TOP 10 * 
        FROM dbo.[Order] 
        WHERE AspNetUserId = '{chris_user_id}'
        AND CAST(CreateDate AS DATE) BETWEEN '2025-12-01' AND '2025-12-10'
        ORDER BY CreateDate DESC
        """
        trans_df = pd.read_sql(trans_query, conn)
        if len(trans_df) > 0:
            print(f"Found {len(trans_df)} orders in December 2025:")
            print(trans_df.to_string())
        else:
            print("No orders found in December 2025")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    try:
        conn = connect()
        explore_chris_plank(conn)
        conn.close()
        print("\n" + "="*80)
        print("EXPLORATION COMPLETE")
        print("="*80 + "\n")
    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()

