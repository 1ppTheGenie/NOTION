"""
Find SABOR MLS Group ID and MLS ID
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

# Find SABOR MLS
print("=== MLS GROUPS ===")
cursor.execute("SELECT * FROM MlsGroup WHERE Name LIKE '%SABOR%' OR Name LIKE '%San Antonio%' OR Name LIKE '%Texas%'")
cols = [desc[0] for desc in cursor.description]
print(f"Columns: {cols}")
for row in cursor.fetchall():
    print(row)

# Check MLS table
print("\n=== MLS TABLE (San Antonio) ===")
cursor.execute("SELECT TOP 10 * FROM Mls WHERE Name LIKE '%San Antonio%' OR Name LIKE '%SABOR%' OR Name LIKE '%Texas%'")
cols = [desc[0] for desc in cursor.description]
print(f"Columns: {cols}")
for row in cursor.fetchall():
    print(row)

# Check existing 671645 agent code usage
print("\n=== AGENT CODE 671645 USAGE ===")
cursor.execute("SELECT * FROM UserAgentCode WHERE AgentCode = '671645'")
for row in cursor.fetchall():
    print(row)

conn.close()



