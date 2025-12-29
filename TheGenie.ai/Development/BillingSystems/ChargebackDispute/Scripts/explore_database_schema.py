"""
Database Schema Exploration for Dispute Defense Kit
Find tables for orders, transactions, users, login logs, usage activity
"""

import pyodbc
import pandas as pd
import sys

# Fix Unicode encoding for Windows
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

def explore_schema(conn):
    """Explore database schema to find relevant tables"""
    print("\n" + "="*80)
    print("DATABASE SCHEMA EXPLORATION")
    print("="*80)
    
    # Get all tables
    print("\n1. FINDING ALL TABLES")
    print("-" * 80)
    tables_query = """
    SELECT 
        TABLE_SCHEMA,
        TABLE_NAME,
        TABLE_TYPE
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE'
    ORDER BY TABLE_SCHEMA, TABLE_NAME
    """
    
    tables_df = pd.read_sql(tables_query, conn)
    print(f"Found {len(tables_df)} tables")
    
    # Look for order/transaction related tables
    print("\n2. SEARCHING FOR ORDER/TRANSACTION TABLES")
    print("-" * 80)
    order_keywords = ['order', 'transaction', 'payment', 'purchase', 'invoice', 'billing', 'whmcs']
    order_tables = tables_df[
        tables_df['TABLE_NAME'].str.contains('|'.join(order_keywords), case=False, na=False)
    ]
    print(f"Found {len(order_tables)} potential order/transaction tables:")
    for _, row in order_tables.iterrows():
        print(f"  - {row['TABLE_SCHEMA']}.{row['TABLE_NAME']}")
    
    # Look for user/customer related tables
    print("\n3. SEARCHING FOR USER/CUSTOMER TABLES")
    print("-" * 80)
    user_keywords = ['user', 'customer', 'client', 'account', 'member', 'aspnet']
    user_tables = tables_df[
        tables_df['TABLE_NAME'].str.contains('|'.join(user_keywords), case=False, na=False)
    ]
    print(f"Found {len(user_tables)} potential user/customer tables:")
    for _, row in user_tables.iterrows():
        print(f"  - {row['TABLE_SCHEMA']}.{row['TABLE_NAME']}")
    
    # Look for login/access log tables
    print("\n4. SEARCHING FOR LOGIN/ACCESS LOG TABLES")
    print("-" * 80)
    log_keywords = ['log', 'login', 'access', 'audit', 'activity', 'session', 'track']
    log_tables = tables_df[
        tables_df['TABLE_NAME'].str.contains('|'.join(log_keywords), case=False, na=False)
    ]
    print(f"Found {len(log_tables)} potential log tables:")
    for _, row in log_tables.iterrows():
        print(f"  - {row['TABLE_SCHEMA']}.{row['TABLE_NAME']}")
    
    # Look for usage/activity tables
    print("\n5. SEARCHING FOR USAGE/ACTIVITY TABLES")
    print("-" * 80)
    activity_keywords = ['usage', 'activity', 'campaign', 'report', 'download', 'click', 'view', 'action']
    activity_tables = tables_df[
        tables_df['TABLE_NAME'].str.contains('|'.join(activity_keywords), case=False, na=False)
    ]
    print(f"Found {len(activity_tables)} potential activity tables:")
    for _, row in activity_tables.iterrows():
        print(f"  - {row['TABLE_SCHEMA']}.{row['TABLE_NAME']}")
    
    # Look for Listing Command specific tables
    print("\n6. SEARCHING FOR LISTING COMMAND TABLES")
    print("-" * 80)
    lc_keywords = ['listing', 'command', 'propertycast', 'genielead']
    lc_tables = tables_df[
        tables_df['TABLE_NAME'].str.contains('|'.join(lc_keywords), case=False, na=False)
    ]
    print(f"Found {len(lc_tables)} potential Listing Command tables:")
    for _, row in lc_tables.iterrows():
        print(f"  - {row['TABLE_SCHEMA']}.{row['TABLE_NAME']}")
    
    return {
        'all_tables': tables_df,
        'order_tables': order_tables,
        'user_tables': user_tables,
        'log_tables': log_tables,
        'activity_tables': activity_tables,
        'lc_tables': lc_tables
    }

def explore_table_structure(conn, schema, table_name):
    """Get column information for a specific table"""
    query = """
    SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH,
        IS_NULLABLE,
        COLUMN_DEFAULT
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
    ORDER BY ORDINAL_POSITION
    """
    return pd.read_sql(query, conn, params=(schema, table_name))

def search_chris_plank(conn):
    """Search for Chris Plank case data"""
    print("\n" + "="*80)
    print("SEARCHING FOR CHRIS PLANK CASE")
    print("="*80)
    
    # Search by name
    print("\n1. Searching by name 'Chris Plank' or 'Plank'...")
    
    # Try common user tables
    user_tables_to_check = [
        ('dbo', 'AspNetUsers'),
        ('dbo', 'User'),
        ('dbo', 'Customer'),
        ('dbo', 'Client'),
        ('dbo', 'Account')
    ]
    
    for schema, table in user_tables_to_check:
        try:
            # Check if table exists and has name/email columns
            check_query = f"""
            SELECT COLUMN_NAME 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{table}'
            """
            cols = pd.read_sql(check_query, conn)
            col_names = cols['COLUMN_NAME'].str.lower().tolist()
            
            if any('name' in c or 'email' in c or 'firstname' in c or 'lastname' in c for c in col_names):
                # Try to search
                name_cols = [c for c in cols['COLUMN_NAME'] if 'name' in c.lower() or 'first' in c.lower() or 'last' in c.lower()]
                email_cols = [c for c in cols['COLUMN_NAME'] if 'email' in c.lower()]
                
                if name_cols:
                    search_col = name_cols[0]
                    query = f"SELECT TOP 10 * FROM [{schema}].[{table}] WHERE [{search_col}] LIKE '%Plank%' OR [{search_col}] LIKE '%Chris%'"
                    try:
                        results = pd.read_sql(query, conn)
                        if len(results) > 0:
                            print(f"\n  Found in {schema}.{table}:")
                            print(results.to_string())
                            return results
                    except Exception as e:
                        pass
        except Exception as e:
            pass
    
    # Search by PayPal transaction ID
    print("\n2. Searching by PayPal transaction ID 'PP-R-THB-607760615'...")
    
    transaction_tables_to_check = [
        ('dbo', 'Order'),
        ('dbo', 'Transaction'),
        ('dbo', 'Payment'),
        ('dbo', 'Invoice'),
        ('dbo', 'Purchase')
    ]
    
    for schema, table in transaction_tables_to_check:
        try:
            check_query = f"""
            SELECT COLUMN_NAME 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{table}'
            """
            cols = pd.read_sql(check_query, conn)
            col_names = cols['COLUMN_NAME'].str.lower().tolist()
            
            if any('transaction' in c or 'paypal' in c or 'payment' in c or 'reference' in c for c in col_names):
                trans_cols = [c for c in cols['COLUMN_NAME'] if any(x in c.lower() for x in ['transaction', 'paypal', 'payment', 'reference', 'id'])]
                
                if trans_cols:
                    search_col = trans_cols[0]
                    query = f"SELECT TOP 10 * FROM [{schema}].[{table}] WHERE [{search_col}] LIKE '%607760615%' OR [{search_col}] LIKE '%PP-R-THB%'"
                    try:
                        results = pd.read_sql(query, conn)
                        if len(results) > 0:
                            print(f"\n  Found in {schema}.{table}:")
                            print(results.to_string())
                            return results
                    except Exception as e:
                        pass
        except Exception as e:
            pass
    
    print("\n  No results found. Will need to explore further.")
    return None

if __name__ == "__main__":
    try:
        print("\nConnecting to database...")
        conn = connect()
        print("Connected successfully!")
        
        # Explore schema
        schema_info = explore_schema(conn)
        
        # Search for Chris Plank
        chris_data = search_chris_plank(conn)
        
        # Explore key tables in detail
        print("\n" + "="*80)
        print("EXPLORING KEY TABLES IN DETAIL")
        print("="*80)
        
        # Explore AspNetUsers if it exists
        try:
            print("\n7. AspNetUsers Table Structure:")
            print("-" * 80)
            users_cols = explore_table_structure(conn, 'dbo', 'AspNetUsers')
            print(users_cols.to_string())
        except Exception as e:
            print(f"  Could not explore AspNetUsers: {e}")
        
        conn.close()
        print("\n" + "="*80)
        print("EXPLORATION COMPLETE")
        print("="*80 + "\n")
        
    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()

