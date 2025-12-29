"""
Query actual Listing Command workflow execution details
"""

import pyodbc
import pandas as pd
import sys
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8')

SERVER = "192.168.29.45,1433"
DATABASE = "FarmGenie"
UID = "cursor"
PWD = "1ppINSAyay$"

CHRIS_USER_ID = "f5174e53-8f6e-4d23-9eab-f8d6802b39c9"
CONFIG_ID = 128
QUEUE_IDS = [1236, 1237]

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

def main():
    conn = None
    try:
        conn = connect()
        print("="*80)
        print("LISTING COMMAND WORKFLOW DETAILS")
        print("="*80)
        
        # 1. ListingCommandQueue
        print("\n1. LISTING COMMAND QUEUE RECORDS")
        print("-"*80)
        try:
            query = f"""
            SELECT TOP 10 * FROM dbo.ListingCommandQueue
            WHERE ListingCommandQueueId IN ({', '.join(map(str, QUEUE_IDS))})
            ORDER BY CreateDate DESC
            """
            queue_df = pd.read_sql(query, conn)
            if len(queue_df) > 0:
                print(queue_df.to_string())
            else:
                print("No queue records found for those IDs")
        except Exception as e:
            print(f"Error: {e}")
        
        # 2. PropertyCollection
        print("\n2. PROPERTY COLLECTION")
        print("-"*80)
        try:
            query = f"""
            SELECT TOP 10 * FROM dbo.PropertyCollection
            WHERE AspNetUserId = '{CHRIS_USER_ID}'
            ORDER BY CreateDate DESC
            """
            prop_df = pd.read_sql(query, conn)
            if len(prop_df) > 0:
                print(f"Found {len(prop_df)} property collections")
                print(prop_df.to_string())
            else:
                print("No property collections found")
        except Exception as e:
            print(f"Error: {e}")
        
        # 3. PropertyCastActionType (to understand what action type 1 is)
        print("\n3. PROPERTY CAST ACTION TYPES")
        print("-"*80)
        try:
            query = """
            SELECT * FROM dbo.PropertyCastActionType
            ORDER BY PropertyCastActionTypeId
            """
            action_types_df = pd.read_sql(query, conn)
            print(action_types_df.to_string())
        except Exception as e:
            print(f"Error: {e}")
        
        # 4. DataAppendOrder (to see if data append was ordered)
        print("\n4. DATA APPEND ORDERS")
        print("-"*80)
        try:
            query = f"""
            SELECT TOP 10 * FROM dbo.DataAppendOrder
            WHERE AspNetUserId = '{CHRIS_USER_ID}'
            ORDER BY CreateDate DESC
            """
            append_df = pd.read_sql(query, conn)
            if len(append_df) > 0:
                print(f"Found {len(append_df)} data append orders")
                print(append_df.to_string())
            else:
                print("No data append orders found")
        except Exception as e:
            print(f"Error: {e}")
        
        # 5. SmsReportSendQueue (SMS messages sent)
        print("\n5. SMS MESSAGES SENT")
        print("-"*80)
        try:
            query = f"""
            SELECT TOP 20 
                srsq.SmsReportSendQueueId,
                srsq.CreateDate,
                srsq.AspNetUserId,
                srsq.MessageText,
                srsq.PhoneNumber,
                srsq.Status
            FROM dbo.SmsReportSendQueue srsq
            WHERE srsq.AspNetUserId = '{CHRIS_USER_ID}'
            ORDER BY srsq.CreateDate DESC
            """
            sms_df = pd.read_sql(query, conn)
            if len(sms_df) > 0:
                print(f"Found {len(sms_df)} SMS messages")
                print(sms_df.to_string())
            else:
                print("No SMS messages found")
        except Exception as e:
            print(f"Error: {e}")
        
        # 6. PropertyCastWorkflowQueueItem (workflow items processed)
        print("\n6. PROPERTY CAST WORKFLOW QUEUE ITEMS")
        print("-"*80)
        try:
            query = f"""
            SELECT TOP 20 
                pcwqi.PropertyCastWorkflowQueueItemId,
                pcwqi.CreateDate,
                pcwqi.PropertyCastWorkflowQueueId,
                pcwqi.PropertyId
            FROM dbo.PropertyCastWorkflowQueueItem pcwqi
            INNER JOIN dbo.PropertyCastWorkflowQueue pcwq ON pcwqi.PropertyCastWorkflowQueueId = pcwq.PropertyCastWorkflowQueueId
            WHERE pcwq.AspNetUserId = '{CHRIS_USER_ID}'
            ORDER BY pcwqi.CreateDate DESC
            """
            workflow_df = pd.read_sql(query, conn)
            if len(workflow_df) > 0:
                print(f"Found {len(workflow_df)} workflow items processed")
                print(workflow_df.to_string())
            else:
                print("No workflow items found")
        except Exception as e:
            print(f"Error: {e}")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    main()

