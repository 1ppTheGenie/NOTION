"""
Query Listing Command Workflow Details
Find actual process steps, deliverables, and execution details
"""

import pyodbc
import pandas as pd
import sys
import json
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8')

# Database connection
SERVER = "192.168.29.45,1433"
DATABASE = "FarmGenie"
UID = "cursor"
PWD = "1ppINSAyay$"

CHRIS_USER_ID = "f5174e53-8f6e-4d23-9eab-f8d6802b39c9"
CONFIG_ID = 128  # From activity log: "Listing Command User Configuration Id: 128"
QUEUE_IDS = [1236, 1237]  # From activity log: "Listing Command Queue Ids: 1236, 1237"

def connect():
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"UID={UID};PWD={PWD};"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)

def get_table_structure(conn, table_name):
    """Get table structure"""
    query = f"""
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = '{table_name}'
    ORDER BY ORDINAL_POSITION
    """
    return pd.read_sql(query, conn)

def main():
    conn = None
    try:
        conn = connect()
        print("="*80)
        print("LISTING COMMAND WORKFLOW INVESTIGATION")
        print("="*80)
        
        # 1. ListingCommandUserConfiguration
        print("\n1. LISTING COMMAND USER CONFIGURATION")
        print("-"*80)
        try:
            query = f"""
            SELECT * FROM dbo.ListingCommandUserConfiguration 
            WHERE ListingCommandUserConfigurationId = {CONFIG_ID}
            """
            config_df = pd.read_sql(query, conn)
            if len(config_df) > 0:
                print(config_df.to_string())
                print("\nColumns:")
                print(get_table_structure(conn, 'ListingCommandUserConfiguration'))
            else:
                print("No configuration found for ID 128")
        except Exception as e:
            print(f"Error: {e}")
        
        # 2. ListingCommandSelectedActionType
        print("\n2. LISTING COMMAND SELECTED ACTIONS")
        print("-"*80)
        try:
            query = f"""
            SELECT * FROM dbo.ListingCommandSelectedActionType 
            WHERE ListingCommandUserConfigurationId = {CONFIG_ID}
            """
            actions_df = pd.read_sql(query, conn)
            if len(actions_df) > 0:
                print(actions_df.to_string())
            else:
                print("No selected actions found")
            print("\nColumns:")
            print(get_table_structure(conn, 'ListingCommandSelectedActionType'))
        except Exception as e:
            print(f"Error: {e}")
        
        # 3. Search for Queue/Processing tables
        print("\n3. SEARCHING FOR QUEUE/PROCESSING TABLES")
        print("-"*80)
        queue_tables = []
        query = """
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'dbo' AND (
            TABLE_NAME LIKE '%Queue%' OR 
            TABLE_NAME LIKE '%Process%' OR
            TABLE_NAME LIKE '%SMS%' OR
            TABLE_NAME LIKE '%Text%' OR
            TABLE_NAME LIKE '%Message%' OR
            TABLE_NAME LIKE '%DataAppend%' OR
            TABLE_NAME LIKE '%Property%' OR
            TABLE_NAME LIKE '%GenieLead%'
        )
        ORDER BY TABLE_NAME
        """
        tables_df = pd.read_sql(query, conn)
        print(f"Found {len(tables_df)} potential tables:")
        for _, row in tables_df.iterrows():
            print(f"  - {row['TABLE_NAME']}")
            queue_tables.append(row['TABLE_NAME'])
        
        # 4. Check GenieLead for leads generated
        print("\n4. GENIE LEAD (LEADS GENERATED)")
        print("-"*80)
        try:
            query = f"""
            SELECT TOP 20 
                gl.GenieLeadId,
                gl.CreateDate,
                gl.GenieLeadTypeId,
                glt.GenieLeadTypeName,
                gl.PropertyId,
                gl.UserId
            FROM dbo.GenieLead gl
            LEFT JOIN dbo.GenieLeadType glt ON gl.GenieLeadTypeId = glt.GenieLeadTypeId
            WHERE gl.UserId = '{CHRIS_USER_ID}'
            ORDER BY gl.CreateDate DESC
            """
            leads_df = pd.read_sql(query, conn)
            if len(leads_df) > 0:
                print(f"Found {len(leads_df)} leads")
                print(leads_df.to_string())
            else:
                print("No leads found")
        except Exception as e:
            print(f"Error: {e}")
        
        # 5. Check for PropertyCollection or similar
        print("\n5. PROPERTY COLLECTION TABLES")
        print("-"*80)
        prop_tables = []
        query = """
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'dbo' AND (
            TABLE_NAME LIKE '%Property%' OR
            TABLE_NAME LIKE '%Collection%'
        )
        ORDER BY TABLE_NAME
        """
        prop_df = pd.read_sql(query, conn)
        for _, row in prop_df.iterrows():
            print(f"  - {row['TABLE_NAME']}")
            prop_tables.append(row['TABLE_NAME'])
        
        # 6. Check for SMS/Text messaging tables
        print("\n6. SMS/TEXT MESSAGING TABLES")
        print("-"*80)
        sms_tables = []
        query = """
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'dbo' AND (
            TABLE_NAME LIKE '%SMS%' OR
            TABLE_NAME LIKE '%Text%' OR
            TABLE_NAME LIKE '%Message%' OR
            TABLE_NAME LIKE '%Twilio%'
        )
        ORDER BY TABLE_NAME
        """
        sms_df = pd.read_sql(query, conn)
        for _, row in sms_df.iterrows():
            print(f"  - {row['TABLE_NAME']}")
            sms_tables.append(row['TABLE_NAME'])
        
        # 7. Check for DataAppend tables
        print("\n7. DATA APPEND TABLES")
        print("-"*80)
        append_tables = []
        query = """
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'dbo' AND (
            TABLE_NAME LIKE '%DataAppend%' OR
            TABLE_NAME LIKE '%Append%' OR
            TABLE_NAME LIKE '%Optimize%'
        )
        ORDER BY TABLE_NAME
        """
        append_df = pd.read_sql(query, conn)
        for _, row in append_df.iterrows():
            print(f"  - {row['TABLE_NAME']}")
            append_tables.append(row['TABLE_NAME'])
        
        # 8. Try to find records by Queue IDs
        print("\n8. SEARCHING FOR QUEUE RECORDS")
        print("-"*80)
        for table in queue_tables[:5]:  # Check first 5 tables
            try:
                # Try to find QueueId column
                cols = get_table_structure(conn, table)
                if 'QueueId' in cols['COLUMN_NAME'].values or 'QueueID' in cols['COLUMN_NAME'].values:
                    col_name = 'QueueId' if 'QueueId' in cols['COLUMN_NAME'].values else 'QueueID'
                    query = f"""
                    SELECT TOP 10 * FROM dbo.{table}
                    WHERE {col_name} IN ({', '.join(map(str, QUEUE_IDS))})
                    """
                    queue_df = pd.read_sql(query, conn)
                    if len(queue_df) > 0:
                        print(f"\nFound records in {table}:")
                        print(queue_df.to_string())
            except Exception as e:
                pass  # Table might not have QueueId column
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    main()

