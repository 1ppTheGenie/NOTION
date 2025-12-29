"""
Explore Chris Plank Case - Detailed Data Collection
Find transaction, orders, login logs, usage activity
"""

import pyodbc
import pandas as pd
import sys
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8')

def connect():
    """Connect to FarmGenie database"""
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

def explore_chris_plank(conn):
    """Explore Chris Plank case in detail"""
    print("\n" + "="*80)
    print("CHRIS PLANK CASE - DETAILED EXPLORATION")
    print("="*80)
    
    # Chris Plank User ID from previous search
    chris_user_id = "f5174e53-8f6e-4d23-9eab-f8d6802b39c9"
    chris_email = "cp@pacificapg.com"
    
    print(f"\nUser ID: {chris_user_id}")
    print(f"Email: {chris_email}")
    print(f"Transaction Date: 12/5/2025")
    print(f"Amount: $67.50")
    print(f"PayPal Transaction ID: PP-R-THB-607760615")
    
    # 1. Get full user details
    print("\n" + "-"*80)
    print("1. USER DETAILS (AspNetUsers)")
    print("-"*80)
    user_query = f"SELECT * FROM dbo.AspNetUsers WHERE Id = '{chris_user_id}'"
    user_df = pd.read_sql(user_query, conn)
    print(user_df.to_string())
    
    # 2. Find orders for this user
    print("\n" + "-"*80)
    print("2. ORDERS (Order table)")
    print("-"*80)
    try:
        order_query = f"""
        SELECT TOP 10 * 
        FROM dbo.[Order] 
        WHERE UserId = '{chris_user_id}'
        ORDER BY CreatedDate DESC
        """
        order_df = pd.read_sql(order_query, conn)
        if len(order_df) > 0:
            print(f"Found {len(order_df)} orders")
            print(order_df.to_string())
        else:
            print("No orders found in Order table")
    except Exception as e:
        print(f"Error querying Order table: {e}")
        # Try to see table structure
        try:
            cols_query = """
            SELECT COLUMN_NAME, DATA_TYPE 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Order'
            """
            cols = pd.read_sql(cols_query, conn)
            print("\nOrder table columns:")
            print(cols.to_string())
        except:
            pass
    
    # 3. Find ListingCommandBilling for this user
    print("\n" + "-"*80)
    print("3. LISTING COMMAND BILLING")
    print("-"*80)
    try:
        lc_billing_query = f"""
        SELECT TOP 10 * 
        FROM dbo.ListingCommandBilling 
        WHERE UserId = '{chris_user_id}'
        ORDER BY CreatedDate DESC
        """
        lc_df = pd.read_sql(lc_billing_query, conn)
        if len(lc_df) > 0:
            print(f"Found {len(lc_df)} Listing Command billing records")
            print(lc_df.to_string())
        else:
            print("No Listing Command billing found")
            # Check table structure
            cols_query = """
            SELECT COLUMN_NAME, DATA_TYPE 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'ListingCommandBilling'
            """
            cols = pd.read_sql(cols_query, conn)
            print("\nListingCommandBilling table columns:")
            print(cols.to_string())
    except Exception as e:
        print(f"Error: {e}")
    
    # 4. Search for transaction by date (12/5/2025) and amount ($67.50)
    print("\n" + "-"*80)
    print("4. SEARCHING FOR TRANSACTION (12/5/2025, $67.50)")
    print("-"*80)
    
    # Try Order table with date
    try:
        trans_date_query = f"""
        SELECT TOP 10 * 
        FROM dbo.[Order] 
        WHERE UserId = '{chris_user_id}'
        AND CAST(CreatedDate AS DATE) = '2025-12-05'
        """
        trans_df = pd.read_sql(trans_date_query, conn)
        if len(trans_df) > 0:
            print("Found orders on 12/5/2025:")
            print(trans_df.to_string())
    except Exception as e:
        print(f"Error searching by date: {e}")
    
    # 5. Find login/access logs
    print("\n" + "-"*80)
    print("5. LOGIN/ACCESS LOGS (ActivityTracker)")
    print("-"*80)
    try:
        # First check ActivityTracker structure
        cols_query = """
        SELECT COLUMN_NAME, DATA_TYPE 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'ActivityTracker'
        """
        cols = pd.read_sql(cols_query, conn)
        print("ActivityTracker columns:")
        print(cols.to_string())
        
        # Try to find user ID column
        col_names = cols['COLUMN_NAME'].str.lower().tolist()
        if 'userid' in col_names or 'user_id' in col_names:
            user_col = [c for c in cols['COLUMN_NAME'] if 'user' in c.lower()][0]
            activity_query = f"""
            SELECT TOP 20 * 
            FROM dbo.ActivityTracker 
            WHERE [{user_col}] = '{chris_user_id}'
            ORDER BY CreatedDate DESC
            """
            activity_df = pd.read_sql(activity_query, conn)
            if len(activity_df) > 0:
                print(f"\nFound {len(activity_df)} activity records")
                print(activity_df.to_string())
            else:
                print("\nNo activity records found")
    except Exception as e:
        print(f"Error: {e}")
    
    # 6. Check UserWhmcs mapping
    print("\n" + "-"*80)
    print("6. WHMCS MAPPING (UserWhmcs)")
    print("-"*80)
    try:
        whmcs_query = f"""
        SELECT * 
        FROM dbo.UserWhmcs 
        WHERE UserId = '{chris_user_id}'
        """
        whmcs_df = pd.read_sql(whmcs_query, conn)
        if len(whmcs_df) > 0:
            print("WHMCS mapping found:")
            print(whmcs_df.to_string())
        else:
            print("No WHMCS mapping found")
    except Exception as e:
        print(f"Error: {e}")
    
    # 7. Check ListingCommand usage
    print("\n" + "-"*80)
    print("7. LISTING COMMAND USAGE")
    print("-"*80)
    try:
        # Check ListingCommandUserConfiguration
        lc_config_query = f"""
        SELECT * 
        FROM dbo.ListingCommandUserConfiguration 
        WHERE UserId = '{chris_user_id}'
        """
        lc_config_df = pd.read_sql(lc_config_query, conn)
        if len(lc_config_df) > 0:
            print("Listing Command configuration:")
            print(lc_config_df.to_string())
        else:
            print("No Listing Command configuration found")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    try:
        print("\nConnecting to database...")
        conn = connect()
        print("Connected!")
        
        explore_chris_plank(conn)
        
        conn.close()
        print("\n" + "="*80)
        print("EXPLORATION COMPLETE")
        print("="*80 + "\n")
        
    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()

