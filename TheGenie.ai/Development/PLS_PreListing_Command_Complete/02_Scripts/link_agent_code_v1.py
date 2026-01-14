"""
Link Texas Genie ASP User ID to MLS Agent Code 671645
This enables the widgets to pull data for Balcones Creek area.
"""
import pyodbc

# Texas Genie ASP User ID
USER_ID = 'a8436051-333d-4725-b8ce-88bf5262d26a'

# MLS Agent Code from SABOR
AGENT_CODE = '671645'

conn = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=192.168.29.45,1433;'
    'DATABASE=FarmGenie;'
    'UID=cursor;'
    'PWD=1ppINSAyay$;'
    'timeout=30'
)
cursor = conn.cursor()

# Check UserAgentCode table structure
print("=== UserAgentCode COLUMNS ===")
cursor.execute("SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'UserAgentCode' ORDER BY ORDINAL_POSITION")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

# See sample records
print("\n=== SAMPLE UserAgentCode RECORDS ===")
cursor.execute("SELECT TOP 5 * FROM UserAgentCode")
cols = [desc[0] for desc in cursor.description]
print(f"Columns: {cols}")
for row in cursor.fetchall():
    print(row)

# Check if Texas Genie already has an agent code
print(f"\n=== TEXAS GENIE AGENT CODES ===")
cursor.execute("SELECT * FROM UserAgentCode WHERE AspNetUserId = ?", USER_ID)
rows = cursor.fetchall()
if rows:
    print("Existing agent codes:")
    for row in rows:
        print(row)
else:
    print("No agent codes linked yet")

# Check UserAgentCodePrimary table too
print(f"\n=== UserAgentCodePrimary ===")
cursor.execute("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'UserAgentCodePrimary'")
print([row[0] for row in cursor.fetchall()])

cursor.execute("SELECT TOP 3 * FROM UserAgentCodePrimary")
for row in cursor.fetchall():
    print(row)

conn.close()
print("\n=== DONE ===")



