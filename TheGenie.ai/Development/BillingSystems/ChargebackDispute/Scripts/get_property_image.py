"""
Get Property Image URL for MLS Listing
Query UserMlsListingImage table to get property image
"""
import pyodbc
import pandas as pd
import sys

sys.stdout.reconfigure(encoding='utf-8')

MLS_NUMBER = "SB25228445"
CHRIS_USER_ID = "f5174e53-8f6e-4d23-9eab-f8d6802b39c9"

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
    print(f"SEARCHING FOR PROPERTY IMAGES FOR MLS: {MLS_NUMBER}")
    print("="*80)
    
    # Query UserMlsListingImage table
    query = f"""
    SELECT TOP 1
        UserMlsListingImageId,
        AspNetUserId,
        MlsId,
        MlsNumber,
        Url,
        [Order],
        CreateDate
    FROM dbo.UserMlsListingImage
    WHERE MlsNumber = '{MLS_NUMBER}'
       OR AspNetUserId = '{CHRIS_USER_ID}'
    ORDER BY [Order] ASC, CreateDate DESC
    """
    
    df = pd.read_sql(query, conn)
    
    if len(df) > 0:
        print("\n✅ Found property image(s):")
        print(df.to_string(index=False))
        print(f"\n✅ Primary Image URL: {df.iloc[0]['Url']}")
    else:
        print("\n❌ No images found in UserMlsListingImage table")
        print("\nChecking if we can get MlsId from ListingCommandQueue...")
        
        # Get MlsId from ListingCommandQueue
        query2 = f"""
        SELECT TOP 1 MlsId, MlsNumber
        FROM dbo.ListingCommandQueue
        WHERE MlsNumber = '{MLS_NUMBER}'
        ORDER BY CreateDate DESC
        """
        df2 = pd.read_sql(query2, conn)
        
        if len(df2) > 0:
            mls_id = df2.iloc[0]['MlsId']
            print(f"✅ Found MlsId: {mls_id}")
            
            # Try querying by MlsId
            query3 = f"""
            SELECT TOP 1
                UserMlsListingImageId,
                AspNetUserId,
                MlsId,
                MlsNumber,
                Url,
                [Order],
                CreateDate
            FROM dbo.UserMlsListingImage
            WHERE MlsId = {mls_id}
            ORDER BY [Order] ASC, CreateDate DESC
            """
            df3 = pd.read_sql(query3, conn)
            
            if len(df3) > 0:
                print("\n✅ Found property image by MlsId:")
                print(df3.to_string(index=False))
                print(f"\n✅ Primary Image URL: {df3.iloc[0]['Url']}")
            else:
                print(f"\n❌ No images found for MlsId: {mls_id}")
                print("\n⚠️  Property images may be stored elsewhere or need to be fetched from MLS API")
        else:
            print("❌ Could not find MlsId for this listing")
    
    conn.close()

if __name__ == "__main__":
    main()

