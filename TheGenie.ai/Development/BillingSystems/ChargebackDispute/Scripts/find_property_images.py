"""
Find Property Images in Database
Query database to find where property/listing images are stored
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

def main():
    conn = connect()
    
    print("="*80)
    print("SEARCHING FOR PROPERTY IMAGE COLUMNS")
    print("="*80)
    
    # Search for image/photo columns
    query = """
    SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME LIKE '%Image%' 
       OR COLUMN_NAME LIKE '%Photo%' 
       OR COLUMN_NAME LIKE '%PhotoUrl%' 
       OR COLUMN_NAME LIKE '%ImageUrl%'
       OR COLUMN_NAME LIKE '%Picture%'
       OR COLUMN_NAME LIKE '%Img%'
    ORDER BY TABLE_NAME, COLUMN_NAME
    """
    
    df = pd.read_sql(query, conn)
    
    if len(df) > 0:
        print("\n✅ Found image/photo columns:")
        print(df.to_string(index=False))
    else:
        print("\n❌ No image/photo columns found")
    
    print("\n" + "="*80)
    print("SEARCHING FOR PROPERTY/LISTING TABLES")
    print("="*80)
    
    # Search for property/listing tables
    query2 = """
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE' 
      AND (TABLE_NAME LIKE '%Property%' 
           OR TABLE_NAME LIKE '%Listing%' 
           OR TABLE_NAME LIKE '%MLS%'
           OR TABLE_NAME LIKE '%Assessor%')
    ORDER BY TABLE_NAME
    """
    
    df2 = pd.read_sql(query2, conn)
    
    if len(df2) > 0:
        print("\n✅ Found property/listing tables:")
        print(df2.to_string(index=False))
        
        # Check columns in these tables
        print("\n" + "="*80)
        print("CHECKING COLUMNS IN PROPERTY/LISTING TABLES")
        print("="*80)
        
        for table in df2['TABLE_NAME']:
            query3 = f"""
            SELECT COLUMN_NAME, DATA_TYPE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = '{table}'
            ORDER BY ORDINAL_POSITION
            """
            df3 = pd.read_sql(query3, conn)
            print(f"\n{table}:")
            print(df3.to_string(index=False))
    else:
        print("\n❌ No property/listing tables found")
    
    print("\n" + "="*80)
    print("CHECKING LISTINGCOMMANDQUEUE FOR IMAGE DATA")
    print("="*80)
    
    # Check ListingCommandQueue for any image-related columns
    query4 = """
    SELECT COLUMN_NAME, DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ListingCommandQueue'
    ORDER BY ORDINAL_POSITION
    """
    df4 = pd.read_sql(query4, conn)
    print("\nListingCommandQueue columns:")
    print(df4.to_string(index=False))
    
    # Check if there's a PropertyId that links to a Property table
    if 'PropertyId' in df4['COLUMN_NAME'].values:
        print("\n✅ Found PropertyId column - checking Property table...")
        query5 = """
        SELECT TOP 1 COLUMN_NAME, DATA_TYPE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Property'
        ORDER BY ORDINAL_POSITION
        """
        try:
            df5 = pd.read_sql(query5, conn)
            if len(df5) > 0:
                print("Property table exists! Getting all columns:")
                query6 = """
                SELECT COLUMN_NAME, DATA_TYPE
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = 'Property'
                ORDER BY ORDINAL_POSITION
                """
                df6 = pd.read_sql(query6, conn)
                print(df6.to_string(index=False))
        except:
            print("Property table doesn't exist or can't be accessed")
    
    conn.close()

if __name__ == "__main__":
    main()

