"""
Find MLS tables and link agent code
"""
import pyodbc

conn = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=192.168.29.45,1433;'
    'DATABASE=FarmGenie;'
    'UID=cursor;'
    'PWD=1ppINSAyay$;'
    'timeout=30'
)
cursor = conn.cursor()

# Find tables with Mls in name
print("=== TABLES WITH MLS ===")
cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%Mls%' ORDER BY TABLE_NAME")
for row in cursor.fetchall():
    print(row[0])

# Look at UserMlsGroup table
print("\n=== UserMlsGroup SAMPLE ===")
cursor.execute("SELECT TOP 5 * FROM UserMlsGroup")
cols = [desc[0] for desc in cursor.description]
print(f"Columns: {cols}")
for row in cursor.fetchall():
    print(row)

# What MlsGroupId values exist in UserAgentCode?
print("\n=== DISTINCT MlsGroupId in UserAgentCode ===")
cursor.execute("SELECT DISTINCT MlsGroupId, MlsId, COUNT(*) as cnt FROM UserAgentCode GROUP BY MlsGroupId, MlsId ORDER BY cnt DESC")
for row in cursor.fetchall():
    print(f"MlsGroupId: {row[0]}, MlsId: {row[1]}, Count: {row[2]}")

conn.close()



