"""
Create Workflow Screenshots - Recreate TheGenie.ai UI Screens
Programmatically generates screenshots that match the actual system UI
"""
import pyodbc
import pandas as pd
from PIL import Image as PILImage, ImageDraw, ImageFont
import io
from datetime import datetime
import requests
from urllib.parse import urlparse

# Database connection
DB_SERVER = "192.168.29.45,1433"
DB_DATABASE = "FarmGenie"
DB_UID = "cursor"
DB_PWD = "1ppINSAyay$"

CHRIS_USER_ID = "f5174e53-8f6e-4d23-9eab-f8d6802b39c9"
QUEUE_IDS = [1236, 1237]
COLLECTION_ID = "1c7bdd67-9701-4159-8fa7-4f4a26c5e432"

def connect():
    drivers = [d for d in pyodbc.drivers() if "ODBC Driver" in d]
    driver = next((d for d in drivers if "17" in d or "18" in d), drivers[-1])
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_UID};PWD={DB_PWD};"
        "Encrypt=yes;TrustServerCertificate=yes"
    )
    return pyodbc.connect(conn_str, autocommit=True)

def create_property_listing_screen(property_data, width=1200, height=800):
    """Recreate the 'My MLS Listings' screen showing the property"""
    img = PILImage.new('RGB', (width, height), color='#ffffff')
    draw = ImageDraw.Draw(img)
    
    try:
        font_title = ImageFont.truetype("arial.ttf", 24)
        font_header = ImageFont.truetype("arial.ttf", 18)
        font_normal = ImageFont.truetype("arial.ttf", 14)
        font_small = ImageFont.truetype("arial.ttf", 12)
    except:
        font_title = ImageFont.load_default()
        font_header = ImageFont.load_default()
        font_normal = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # Header bar (dark blue)
    draw.rectangle([0, 0, width, 80], fill='#2c3e50')
    draw.text((20, 30), "TheGenie.ai", fill='#ffffff', font=font_title)
    
    # Sidebar (dark blue)
    draw.rectangle([0, 80, 250, height], fill='#34495e')
    
    # Main content area
    y = 100
    
    # Title
    draw.text((280, y), "My MLS Listings", fill='#2c3e50', font=font_title)
    y += 40
    
    # Subtitle
    draw.text((280, y), "Below is a look at your current inventory and sold listings over the last year.", 
              fill='#7f8c8d', font=font_normal)
    y += 50
    
    # Table header
    headers = ["MLS #", "Address", "City", "Zip", "List Price", "List Date"]
    x_start = 280
    col_widths = [120, 250, 150, 100, 150, 120]
    
    # Header background
    draw.rectangle([x_start, y, x_start + sum(col_widths), y + 40], fill='#ecf0f1', outline='#bdc3c7')
    
    x = x_start + 10
    for i, header in enumerate(headers):
        draw.text((x, y + 12), header, fill='#2c3e50', font=font_header)
        x += col_widths[i]
    
    y += 50
    
    # Property row
    mls = property_data.get('mls_number', 'SB25228445')
    address = property_data.get('address', '1816 9th Street')
    city = property_data.get('city', 'Manhattan Beach')
    zip_code = property_data.get('zip', '90266')
    price = property_data.get('price', '$4.20m')
    list_date = property_data.get('list_date', '10/03/2025')
    
    # Row background
    draw.rectangle([x_start, y, x_start + sum(col_widths), y + 60], fill='#ffffff', outline='#e0e0e0')
    
    x = x_start + 10
    values = [mls, address, city, zip_code, price, list_date]
    
    # MLS with LC tag
    draw.text((x, y + 20), mls, fill='#2c3e50', font=font_normal)
    draw.rectangle([x, y + 40, x + 30, y + 50], fill='#3498db', outline='#2980b9')
    draw.text((x + 5, y + 42), "LC", fill='#ffffff', font=ImageFont.load_default())
    x += col_widths[0]
    
    for i, value in enumerate(values[1:], 1):
        draw.text((x, y + 20), str(value), fill='#2c3e50', font=font_normal)
        x += col_widths[i]
    
    # Actions button
    draw.rectangle([x_start + sum(col_widths) - 100, y + 15, x_start + sum(col_widths) - 10, y + 45], 
                   fill='#3498db', outline='#2980b9')
    draw.text((x_start + sum(col_widths) - 85, y + 28), "Actions", fill='#ffffff', font=font_normal)
    
    return img

def create_listing_command_history_screen(property_data, sms_data, width=1200, height=900):
    """Recreate the 'Listing Command History' screen with SMS campaign results"""
    img = PILImage.new('RGB', (width, height), color='#ffffff')
    draw = ImageDraw.Draw(img)
    
    try:
        font_title = ImageFont.truetype("arial.ttf", 24)
        font_header = ImageFont.truetype("arial.ttf", 18)
        font_normal = ImageFont.truetype("arial.ttf", 14)
        font_small = ImageFont.truetype("arial.ttf", 12)
        font_large = ImageFont.truetype("arial.ttf", 20)
    except:
        font_title = ImageFont.load_default()
        font_header = ImageFont.load_default()
        font_normal = ImageFont.load_default()
        font_small = ImageFont.load_default()
        font_large = ImageFont.load_default()
    
    # Header
    draw.rectangle([0, 0, width, 80], fill='#2c3e50')
    draw.text((20, 30), "TheGenie.ai | Listing Command", fill='#ffffff', font=font_title)
    
    # Sidebar
    draw.rectangle([0, 80, 250, height], fill='#34495e')
    
    y = 100
    
    # Title
    draw.text((280, y), "Listing Command History", fill='#2c3e50', font=font_title)
    y += 30
    draw.text((280, y), "Commanded Listing Activity", fill='#7f8c8d', font=font_normal)
    y += 60
    
    # Property image (left side) - Fetch actual MLS image
    prop_img_width = 300
    prop_img_height = 200
    image_url = property_data.get('image_url')
    
    if image_url:
        try:
            # Download and resize the actual property image
            response = requests.get(image_url, timeout=10)
            if response.status_code == 200:
                prop_img = PILImage.open(io.BytesIO(response.content))
                prop_img = prop_img.resize((prop_img_width, prop_img_height), PILImage.Resampling.LANCZOS)
                img.paste(prop_img, (280, y))
            else:
                # Fallback to placeholder if download fails
                draw.rectangle([280, y, 280 + prop_img_width, y + prop_img_height], 
                             fill='#ecf0f1', outline='#bdc3c7')
                draw.text((280 + prop_img_width//2 - 50, y + prop_img_height//2 - 10), 
                          "Image Unavailable", fill='#95a5a6', font=font_normal)
        except Exception as e:
            # Fallback to placeholder if any error
            draw.rectangle([280, y, 280 + prop_img_width, y + prop_img_height], 
                         fill='#ecf0f1', outline='#bdc3c7')
            draw.text((280 + prop_img_width//2 - 50, y + prop_img_height//2 - 10), 
                      "Image Unavailable", fill='#95a5a6', font=font_normal)
    else:
        # No image URL available
        draw.rectangle([280, y, 280 + prop_img_width, y + prop_img_height], 
                     fill='#ecf0f1', outline='#bdc3c7')
        draw.text((280 + prop_img_width//2 - 50, y + prop_img_height//2 - 10), 
                  "Image Unavailable", fill='#95a5a6', font=font_normal)
    
    # Property details (right of image)
    x_details = 280 + prop_img_width + 20
    draw.text((x_details, y), f"MLS Number - {property_data.get('mls_number', 'SB25228445')}", 
              fill='#2c3e50', font=font_header)
    y += 30
    draw.text((x_details, y), property_data.get('address', '1816 9th Street, Manhattan Beach, CA, 90266'), 
              fill='#7f8c8d', font=font_normal)
    y += 30
    
    # Status badge
    draw.rectangle([x_details, y, x_details + 150, y + 30], fill='#f39c12', outline='#e67e22')
    draw.text((x_details + 10, y + 8), "Pending - Single Family Detached", 
              fill='#ffffff', font=font_small)
    
    y += 80
    
    # SMS Campaign Section
    draw.rectangle([280, y, width - 280, y + 150], fill='#f8f9fa', outline='#dee2e6')
    
    y += 20
    draw.text((300, y), "Text Message Campaign", fill='#2c3e50', font=font_header)
    y += 30
    
    # SMS Icon placeholder
    draw.ellipse([300, y, 340, y + 40], fill='#27ae60', outline='#229954')
    draw.text((310, y + 10), "SMS", fill='#ffffff', font=font_small)
    
    # Campaign stats
    x_stats = 360
    draw.text((x_stats, y), f"Processed {sms_data.get('processed_date', '12/5/2025')}", 
              fill='#2c3e50', font=font_normal)
    y += 25
    
    stats = [
        ("150", "Audience"),
        ("149", "Delivered"),
        ("1", "Engagements")
    ]
    
    x = x_stats
    for value, label in stats:
        draw.text((x, y), value, fill='#27ae60', font=font_large)
        draw.text((x, y + 25), label, fill='#7f8c8d', font=font_small)
        x += 120
    
    y += 50
    draw.text((x_stats, y), 
              f"Your text message campaign was processed on {sms_data.get('processed_date', '12/5/2025')}.", 
              fill='#7f8c8d', font=font_normal)
    
    return img

def create_listing_command_config_screen(config_data, width=1200, height=800):
    """Recreate the 'Listing Command Configuration' screen"""
    img = PILImage.new('RGB', (width, height), color='#ffffff')
    draw = ImageDraw.Draw(img)
    
    try:
        font_title = ImageFont.truetype("arial.ttf", 24)
        font_header = ImageFont.truetype("arial.ttf", 18)
        font_normal = ImageFont.truetype("arial.ttf", 14)
        font_small = ImageFont.truetype("arial.ttf", 12)
    except:
        font_title = ImageFont.load_default()
        font_header = ImageFont.load_default()
        font_normal = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # Header
    draw.rectangle([0, 0, width, 80], fill='#2c3e50')
    draw.text((20, 30), "TheGenie.ai | Listing Command", fill='#ffffff', font=font_title)
    
    # Sidebar
    draw.rectangle([0, 80, 250, height], fill='#34495e')
    
    y = 100
    
    # Title
    draw.text((280, y), "Listing Command Configuration", fill='#2c3e50', font=font_title)
    y += 60
    
    # Channels section
    draw.text((280, y), "Channels", fill='#2c3e50', font=font_header)
    y += 30
    
    channels = [
        ("SMS", "150 Properties", '#27ae60'),
    ]
    
    x = 280
    for channel, count, color in channels:
        # Channel box
        draw.rectangle([x, y, x + 200, y + 80], fill='#f8f9fa', outline='#dee2e6')
        draw.text((x + 20, y + 10), channel, fill='#2c3e50', font=font_header)
        draw.rectangle([x + 150, y + 20, x + 190, y + 50], fill=color, outline=color)
        draw.text((x + 160, y + 32), count, fill='#ffffff', font=font_normal)
        x += 220
    
    y += 120
    
    # Criteria section
    draw.text((280, y), "Criteria", fill='#2c3e50', font=font_header)
    y += 30
    
    criteria = [
        ("Property Type", "SFR"),
        ("Avm", "No Min - No Max"),
        ("Beds", "4 - 6"),
        ("Years in House", "No Min - No Max"),
        ("Occupancy", "All"),
        ("Agent Properties", "Excluded")
    ]
    
    x = 280
    for i, (label, value) in enumerate(criteria):
        if i % 2 == 0 and i > 0:
            x = 280
            y += 40
        draw.text((x, y), f"{label}: {value}", fill='#2c3e50', font=font_normal)
        x += 300
    
    return img

def create_review_order_screen(order_data, width=1200, height=900):
    """Recreate the 'Review Order' screen"""
    img = PILImage.new('RGB', (width, height), color='#ffffff')
    draw = ImageDraw.Draw(img)
    
    try:
        font_title = ImageFont.truetype("arial.ttf", 24)
        font_header = ImageFont.truetype("arial.ttf", 18)
        font_normal = ImageFont.truetype("arial.ttf", 14)
        font_small = ImageFont.truetype("arial.ttf", 12)
        font_large = ImageFont.truetype("arial.ttf", 20)
    except:
        font_title = ImageFont.load_default()
        font_header = ImageFont.load_default()
        font_normal = ImageFont.load_default()
        font_small = ImageFont.load_default()
        font_large = ImageFont.load_default()
    
    # Header
    draw.rectangle([0, 0, width, 80], fill='#2c3e50')
    draw.text((20, 30), "TheGenie.ai | Review", fill='#ffffff', font=font_title)
    
    # Progress bar
    draw.rectangle([0, 80, width, 120], fill='#ecf0f1')
    steps = ["Select Listing", "Select Area", "Select Product", "Review Order"]
    step_width = width // len(steps)
    for i, step in enumerate(steps):
        x = i * step_width
        if i == len(steps) - 1:  # Current step
            draw.ellipse([x + step_width//2 - 15, 95, x + step_width//2 + 15, 125], 
                        fill='#3498db', outline='#2980b9')
            draw.text((x + step_width//2 - 40, 105), step, fill='#3498db', font=font_small)
        else:
            draw.ellipse([x + step_width//2 - 10, 100, x + step_width//2 + 10, 120], 
                        fill='#95a5a6', outline='#7f8c8d')
            draw.text((x + step_width//2 - 40, 105), step, fill='#95a5a6', font=font_small)
    
    y = 140
    
    # Title
    draw.text((280, y), "Take a Moment To Review Your Selections", fill='#2c3e50', font=font_title)
    y += 60
    
    # Left column - Configuration
    x_left = 280
    draw.text((x_left, y), "No Facebook Listing Command", fill='#2c3e50', font=font_header)
    y += 40
    
    # Channels
    draw.text((x_left, y), "Channels", fill='#7f8c8d', font=font_normal)
    y += 25
    draw.text((x_left + 20, y), "• Direct Mail: 0", fill='#2c3e50', font=font_normal)
    y += 25
    draw.text((x_left + 20, y), "• SMS: 150", fill='#2c3e50', font=font_normal)
    y += 40
    
    # Target Statuses
    draw.text((x_left, y), "Target Statuses", fill='#7f8c8d', font=font_normal)
    y += 25
    draw.rectangle([x_left + 20, y, x_left + 100, y + 25], fill='#f39c12', outline='#e67e22')
    draw.text((x_left + 30, y + 5), "Pending", fill='#ffffff', font=font_small)
    y += 50
    
    # Target Criteria
    draw.text((x_left, y), "Target Criteria", fill='#7f8c8d', font=font_normal)
    y += 25
    criteria_text = [
        "Ownership Type: All",
        "Property Type: SFR",
        "Avm: No Min - No Max",
        "Beds: No Min - No Max",
        "Years in House: No Min - No Max",
        "Occupancy: All",
        "Agent Properties: Excluded"
    ]
    for crit in criteria_text:
        draw.text((x_left + 20, y), crit, fill='#2c3e50', font=font_small)
        y += 20
    
    # Right column - Order Summary
    x_right = 650
    y = 200
    
    # Order details box
    draw.rectangle([x_right, y, x_right + 400, y + 300], fill='#f8f9fa', outline='#dee2e6')
    
    y += 20
    draw.text((x_right + 20, y), "Order Details", fill='#2c3e50', font=font_header)
    y += 40
    
    order_info = [
        ("Listing Agent Name", "Christopher Plank"),
        ("Address", "1816 9th Street, Manhattan Beach, CA, 90266"),
        ("Product", "No Facebook Listing Command"),
        ("Area", "East Manhattan Beach"),
        ("* Estimate", "$75.00")
    ]
    
    for label, value in order_info:
        draw.text((x_right + 20, y), f"{label}: {value}", fill='#2c3e50', font=font_normal)
        y += 30
    
    # Place Order button
    y += 40
    draw.rectangle([x_right + 20, y, x_right + 200, y + 50], fill='#3498db', outline='#2980b9')
    draw.text((x_right + 60, y + 15), "Place Your Order", fill='#ffffff', font=font_header)
    
    return img

def get_workflow_data():
    """Query database for all workflow data"""
    conn = connect()
    data = {
        'property': {},
        'sms': {},
        'config': {},
        'order': {}
    }
    
    try:
        # Get property details from queue
        query = f"""
        SELECT TOP 1
            lcq.MlsNumber,
            lcq.MlsId,
            lcq.ListingStatusId,
            lcq.AreaId
        FROM dbo.ListingCommandQueue lcq
        WHERE lcq.ListingCommandQueueId IN ({', '.join(map(str, QUEUE_IDS))})
        ORDER BY lcq.CreateDate DESC
        """
        df = pd.read_sql(query, conn)
        if len(df) > 0:
            # Map ListingStatusId to status name (2 = Sold, 1 = Pending, 0 = Active)
            status_id = df.iloc[0]['ListingStatusId']
            status_map = {0: 'Active', 1: 'Pending', 2: 'Sold'}
            status = status_map.get(status_id, 'Pending')
            
            mls_number = df.iloc[0]['MlsNumber']
            mls_id = df.iloc[0]['MlsId']
            
            # Get property image from UserMlsListingImage
            image_url = None
            try:
                image_query = f"""
                SELECT TOP 1 Url
                FROM dbo.UserMlsListingImage
                WHERE (MlsNumber = '{mls_number}' OR MlsId = {mls_id})
                ORDER BY [Order] ASC, CreateDate DESC
                """
                image_df = pd.read_sql(image_query, conn)
                if len(image_df) > 0:
                    image_url = image_df.iloc[0]['Url']
            except Exception as e:
                print(f"Warning: Could not fetch property image: {e}")
            
            data['property'] = {
                'mls_number': mls_number,
                'mls_id': mls_id,
                'address': '1816 9th Street',
                'city': 'Manhattan Beach',
                'zip': '90266',
                'price': '$4.20m',
                'list_date': '10/03/2025',
                'status': status,
                'area': 'East Manhattan Beach',  # From evidence
                'image_url': image_url
            }
        
        # SMS data (from evidence)
        data['sms'] = {
            'audience': 150,
            'delivered': 149,
            'engagements': 1,
            'processed_date': '12/5/2025'
        }
        
        # Config data
        data['config'] = {
            'sms_count': 150,
            'property_type': 'SFR',
            'beds_min': 4,
            'beds_max': 6
        }
        
        # Order data
        data['order'] = {
            'agent': 'Christopher Plank',
            'address': '1816 9th Street, Manhattan Beach, CA, 90266',
            'product': 'No Facebook Listing Command',
            'area': 'East Manhattan Beach',
            'estimate': '$75.00'
        }
        
    except Exception as e:
        print(f"Error querying data: {e}")
    finally:
        conn.close()
    
    return data

def generate_all_screenshots():
    """Generate all workflow screenshots"""
    data = get_workflow_data()
    
    screenshots = {}
    
    # 1. Property Listing Screen
    screenshots['property_listing'] = create_property_listing_screen(data['property'])
    
    # 2. Listing Command History Screen
    screenshots['command_history'] = create_listing_command_history_screen(data['property'], data['sms'])
    
    # 3. Configuration Screen
    screenshots['config'] = create_listing_command_config_screen(data['config'])
    
    # 4. Review Order Screen
    screenshots['review_order'] = create_review_order_screen(data['order'])
    
    return screenshots

if __name__ == "__main__":
    print("Generating workflow screenshots...")
    screenshots = generate_all_screenshots()
    
    for name, img in screenshots.items():
        filename = f"workflow_screenshot_{name}.png"
        img.save(filename)
        print(f"Saved: {filename}")

