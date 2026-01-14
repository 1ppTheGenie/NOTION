"""
Get MLS info for listing 1917644 to find correct MlsGroupId/MlsId for SABOR
"""
import pyodbc

# MlsListing database has the listings
conn = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=192.168.29.45,1433;'
    'DATABASE=MlsListing;'
    'UID=cursor;'
    'PWD=1ppINSAyay$;'
    'timeout=30'
)
cursor = conn.cursor()

# Get the MlsId for listing 1917644
print("=== LISTING 1917644 ===")
cursor.execute("SELECT MlsNumber, MlsId, MlsStatusId, DisplayAddress, City FROM Listing WHERE MlsNumber = '1917644'")
row = cursor.fetchone()
if row:
    print(f"MlsNumber: {row[0]}")
    print(f"MlsId: {row[1]}")
    print(f"MlsStatusId: {row[2]}")
    print(f"Address: {row[3]}")
    print(f"City: {row[4]}")
    mls_id = row[1]
else:
    print("Listing not found")
    mls_id = None

# Look up MLS table
if mls_id:
    print(f"\n=== MLS INFO (ID={mls_id}) ===")
    cursor.execute("SELECT * FROM Mls WHERE MlsId = ?", mls_id)
    row = cursor.fetchone()
    if row:
        cols = [desc[0] for desc in cursor.description]
        for i, col in enumerate(cols):
            print(f"{col}: {row[i]}")
    else:
        # List all MLS options
        print("MLS not found, listing all:")
        cursor.execute("SELECT MlsId, Name FROM Mls ORDER BY MlsId")
        for row in cursor.fetchall():
            print(f"  MlsId: {row[0]}, Name: {row[1]}")

conn.close()



