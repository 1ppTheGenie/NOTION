"""
Polished Chargeback Response Generator v1
Creates a human-readable, visually compelling dispute response
Following feedback from the GPT chat thread - no repetition, clean structure, empathetic opening
"""

import json
import sys
import re
import requests
import io
from datetime import datetime
from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak, 
    Table, TableStyle, Image, KeepTogether, HRFlowable
)
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY, TA_RIGHT
from PIL import Image as PILImage

sys.stdout.reconfigure(encoding='utf-8')

# Professional color palette - more muted and business-like
COLORS = {
    'navy': colors.HexColor('#1a365d'),       # Deep navy for headers
    'slate': colors.HexColor('#475569'),      # Slate for body text
    'blue': colors.HexColor('#2563eb'),       # Accent blue
    'green': colors.HexColor('#16a34a'),      # Success green
    'light_gray': colors.HexColor('#f1f5f9'), # Light backgrounds
    'border': colors.HexColor('#cbd5e1'),     # Border color
    'warm_gray': colors.HexColor('#64748b'),  # Secondary text
}

def download_image(url, max_width=400, max_height=300):
    """Download and resize an image from URL"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            img = PILImage.open(io.BytesIO(response.content))
            # Resize while maintaining aspect ratio
            img.thumbnail((max_width, max_height), PILImage.Resampling.LANCZOS)
            img_bytes = io.BytesIO()
            img.save(img_bytes, format='PNG')
            img_bytes.seek(0)
            return img_bytes
    except Exception as e:
        print(f"  Warning: Could not download image from {url}: {e}")
    return None

def add_page_number(canvas, doc):
    """Add page number to footer"""
    page_num = canvas.getPageNumber()
    canvas.saveState()
    canvas.setFont("Helvetica", 9)
    canvas.setFillColor(colors.HexColor('#64748b'))
    canvas.drawCentredString(letter[0]/2.0, 0.5*inch, f"Page {page_num}")
    # Add case ID in footer
    canvas.setFont("Helvetica", 8)
    canvas.drawRightString(letter[0] - 0.5*inch, 0.5*inch, "Case: PP-R-THB-607760615")
    canvas.restoreState()

def generate_polished_response():
    """Generate a polished, human-readable chargeback response"""
    
    print("\n" + "="*80)
    print("GENERATING POLISHED CHARGEBACK RESPONSE")
    print("="*80)
    
    # Evidence data (from our database queries)
    case = {
        'transaction_id': 'PP-R-THB-607760615',
        'customer_name': 'Chris Plank',
        'customer_email': 'cp@pacificapg.com',
        'customer_phone': '(310) 849-1530',
        'transaction_date': 'December 5, 2025',
        'transaction_amount': '$67.50',
        'property_address': '1816 9th Street, Manhattan Beach, CA 90266',
        'mls_number': 'SB25228445',
        'area': 'East Manhattan Beach',
        'service_type': 'SMS Text Messaging Campaign',
        'sms_target': 150,
        'sms_delivered': 149,
        'sms_engagements': 1,
        'whmcs_order_id': '9270',
        'order_date': 'December 4, 2025',
        'processed_date': 'December 5, 2025',
        'chargeback_reason': 'The buyer stated that they did not make this purchase.',
        'property_image_url': 'https://imagedelivery.net/C4KZEiOQLExN0SnSaqUP4A/3ca16b48-d8dc-4eb7-5617-3316fc04e800/public',
    }
    
    # Output path
    now = datetime.now()
    output_dir = Path("DefenseKits/DefenseKit_PP_R_THB_607760615_20251220_130839")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Find next version number
    existing = list(output_dir.glob("ChrisPlank_Dispute_Response_v*.pdf"))
    version = len(existing) + 1
    pdf_path = output_dir / f"ChrisPlank_Dispute_Response_v{version}.pdf"
    
    # Create PDF
    doc = SimpleDocTemplate(
        str(pdf_path), 
        pagesize=letter,
        rightMargin=0.75*inch, 
        leftMargin=0.75*inch,
        topMargin=0.75*inch, 
        bottomMargin=1*inch
    )
    
    story = []
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'Title',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=COLORS['navy'],
        spaceAfter=20,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    heading_style = ParagraphStyle(
        'Heading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=COLORS['navy'],
        spaceAfter=12,
        spaceBefore=20,
        fontName='Helvetica-Bold'
    )
    
    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontSize=11,
        textColor=COLORS['slate'],
        spaceAfter=10,
        alignment=TA_JUSTIFY,
        leading=16
    )
    
    emphasis_style = ParagraphStyle(
        'Emphasis',
        parent=body_style,
        fontName='Helvetica-Bold',
        textColor=COLORS['navy']
    )
    
    # ========================================================================
    # COVER PAGE
    # ========================================================================
    story.append(Spacer(1, 1.5*inch))
    
    story.append(Paragraph("DISPUTE RESPONSE", title_style))
    story.append(Spacer(1, 0.2*inch))
    
    subtitle = ParagraphStyle('Subtitle', parent=styles['Normal'], fontSize=14, 
                              textColor=COLORS['warm_gray'], alignment=TA_CENTER)
    story.append(Paragraph("PayPal Chargeback Case", subtitle))
    story.append(Paragraph(f"Case ID: {case['transaction_id']}", subtitle))
    
    story.append(Spacer(1, 0.5*inch))
    
    # Customer info box
    cover_data = [
        ['Customer', case['customer_name']],
        ['Email', case['customer_email']],
        ['Transaction Date', case['transaction_date']],
        ['Amount', case['transaction_amount']],
        ['Claim', '"Did not make this purchase"'],
    ]
    
    cover_table = Table(cover_data, colWidths=[2*inch, 3.5*inch])
    cover_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), COLORS['light_gray']),
        ('TEXTCOLOR', (0, 0), (-1, -1), COLORS['slate']),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 11),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 12),
        ('RIGHTPADDING', (0, 0), (-1, -1), 12),
        ('TOPPADDING', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(cover_table)
    
    story.append(Spacer(1, 0.5*inch))
    
    # Document metadata
    meta_style = ParagraphStyle('Meta', parent=styles['Normal'], fontSize=10, 
                                textColor=COLORS['warm_gray'], alignment=TA_CENTER)
    story.append(Paragraph(f"Prepared by TheGenie.ai Customer Experience Team", meta_style))
    story.append(Paragraph(f"wecare@thegenie.ai | 888-425-2300", meta_style))
    story.append(Paragraph(f"Document Date: {now.strftime('%B %d, %Y')}", meta_style))
    
    story.append(PageBreak())
    
    # ========================================================================
    # OPENING LETTER - Human, Empathetic, Clear
    # ========================================================================
    story.append(Paragraph("Dear PayPal Resolution Team,", body_style))
    story.append(Spacer(1, 0.15*inch))
    
    opening = """
    Thank you for the opportunity to respond to this dispute. We understand that reviewing 
    chargebacks requires careful consideration of the facts, and we've prepared this response 
    to provide you with clear, documented evidence of what actually occurred.
    """
    story.append(Paragraph(opening, body_style))
    
    summary = f"""
    <b>The Short Version:</b> On {case['order_date']}, {case['customer_name']} logged into their 
    account at TheGenie.ai, selected a property listing, configured an SMS marketing campaign 
    targeting 150 nearby property owners, reviewed their order, and completed the checkout. 
    We executed the campaign the next day—149 text messages were delivered to real property 
    owners. One person even responded. The service was fully delivered.
    """
    story.append(Paragraph(summary, body_style))
    
    key_facts = """
    <b>Key Facts at a Glance:</b><br/>
    • The customer has an active account and logged in to place this order<br/>
    • We have documented proof of every step of their order process<br/>
    • The SMS campaign was fully executed and delivered to 149 recipients<br/>
    • The customer never contacted us before filing this dispute—not once<br/>
    • This is a one-time digital service that cannot be "returned"
    """
    story.append(Paragraph(key_facts, body_style))
    
    closing_intro = """
    The following pages provide visual and documented evidence supporting each of these facts. 
    We respectfully request that this dispute be resolved in our favor.
    """
    story.append(Paragraph(closing_intro, body_style))
    
    story.append(Spacer(1, 0.2*inch))
    story.append(HRFlowable(width="100%", thickness=1, color=COLORS['border']))
    story.append(Spacer(1, 0.2*inch))
    
    # ========================================================================
    # WHAT WAS ORDERED - Visual Section
    # ========================================================================
    story.append(Paragraph("What Was Ordered", heading_style))
    
    # Try to download and include the property image
    print("  Downloading property image...")
    img_bytes = download_image(case['property_image_url'], max_width=450, max_height=280)
    
    if img_bytes:
        # Property image with caption
        prop_img = Image(img_bytes, width=4.5*inch, height=2.8*inch)
        story.append(prop_img)
        caption_style = ParagraphStyle('Caption', parent=styles['Normal'], fontSize=9, 
                                       textColor=COLORS['warm_gray'], alignment=TA_CENTER)
        story.append(Paragraph(f"<i>The listing: {case['property_address']}</i>", caption_style))
        story.append(Spacer(1, 0.15*inch))
    
    order_text = f"""
    {case['customer_name']} ordered our <b>Listing Command</b> service for their property listing 
    at {case['property_address']} (MLS #{case['mls_number']}). The service they selected was an 
    <b>SMS Text Messaging Campaign</b> targeting {case['sms_target']} nearby property owners 
    in the {case['area']} area.
    """
    story.append(Paragraph(order_text, body_style))
    
    # Order details table
    order_data = [
        ['Service Ordered', case['service_type']],
        ['Property Address', case['property_address']],
        ['MLS Number', case['mls_number']],
        ['Target Audience', f"{case['sms_target']} property owners"],
        ['Order Date', case['order_date']],
        ['WHMCS Order ID', case['whmcs_order_id']],
    ]
    
    order_table = Table(order_data, colWidths=[2.2*inch, 4*inch])
    order_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), COLORS['light_gray']),
        ('TEXTCOLOR', (0, 0), (-1, -1), COLORS['slate']),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(order_table)
    
    story.append(Spacer(1, 0.2*inch))
    
    # ========================================================================
    # WHAT WAS DELIVERED
    # ========================================================================
    story.append(Paragraph("What Was Delivered", heading_style))
    
    delivery_text = f"""
    The SMS campaign was processed and executed on <b>{case['processed_date']}</b>. 
    Here are the delivery results:
    """
    story.append(Paragraph(delivery_text, body_style))
    
    # SMS delivery stats - visual boxes
    stats_data = [
        ['TARGET AUDIENCE', 'MESSAGES DELIVERED', 'RESPONSES RECEIVED'],
        [str(case['sms_target']), str(case['sms_delivered']), str(case['sms_engagements'])],
    ]
    
    stats_table = Table(stats_data, colWidths=[2*inch, 2*inch, 2*inch])
    stats_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['navy']),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 9),
        ('FONTSIZE', (0, 1), (-1, 1), 28),
        ('FONTNAME', (0, 1), (-1, 1), 'Helvetica-Bold'),
        ('TEXTCOLOR', (0, 1), (-1, 1), COLORS['green']),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('TOPPADDING', (0, 1), (-1, 1), 15),
        ('BOTTOMPADDING', (0, 1), (-1, 1), 15),
        ('BOX', (0, 0), (-1, -1), 1, COLORS['border']),
        ('LINEBEFORE', (1, 0), (1, -1), 1, COLORS['border']),
        ('LINEBEFORE', (2, 0), (2, -1), 1, COLORS['border']),
    ]))
    story.append(stats_table)
    
    story.append(Spacer(1, 0.15*inch))
    
    delivery_detail = """
    <b>What this means:</b> We sent personalized text messages to 149 property owners on behalf 
    of the customer's listing. One recipient responded to the campaign. This service involves 
    real costs that we cannot recover:
    """
    story.append(Paragraph(delivery_detail, body_style))
    
    costs_text = """
    • <b>Data costs:</b> We purchased contact information from third-party data providers (Versium, Attom)<br/>
    • <b>SMS costs:</b> Twilio charged us for every message sent<br/>
    • <b>Processing:</b> Our system executed the campaign immediately upon order completion
    """
    story.append(Paragraph(costs_text, body_style))
    
    story.append(Spacer(1, 0.1*inch))
    
    non_refundable = """
    <b>Why this cannot be refunded:</b> This is a one-time digital service. The data was purchased. 
    The messages were sent. Real property owners received real text messages. The work is done. 
    There is nothing to "return."
    """
    story.append(Paragraph(non_refundable, body_style))
    
    story.append(PageBreak())
    
    # ========================================================================
    # CUSTOMER ACTIVITY PROOF
    # ========================================================================
    story.append(Paragraph("Proof: The Customer Placed This Order", heading_style))
    
    activity_intro = """
    Our system logs every step of the customer's journey. Here is the documented timeline of 
    what the customer did on the day they placed this order:
    """
    story.append(Paragraph(activity_intro, body_style))
    
    # Activity timeline
    activity_data = [
        ['Time', 'Action', 'What This Means'],
        ['7:35:24 PM', 'Customer logged in', 'IP: 253.44.124.95'],
        ['7:35:49 PM', 'Started Listing Command', 'Customer initiated the order process'],
        ['7:36:03 PM', 'Selected options', 'Customer configured their SMS campaign'],
        ['7:37:06 PM', 'Reviewed order', 'Customer saw the final price and details'],
        ['7:37:25 PM', 'Order completed', 'Customer authorized the $67.50 payment'],
    ]
    
    activity_table = Table(activity_data, colWidths=[1.3*inch, 2*inch, 2.7*inch])
    activity_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['navy']),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, COLORS['light_gray']]),
    ]))
    story.append(activity_table)
    
    story.append(Spacer(1, 0.15*inch))
    
    activity_conclusion = """
    <b>The evidence is clear:</b> The customer logged in from their own device, spent nearly 
    2 minutes configuring their order, reviewed it, and authorized the payment. This was not 
    an accident or unauthorized transaction.
    """
    story.append(Paragraph(activity_conclusion, body_style))
    
    story.append(Spacer(1, 0.2*inch))
    
    # ========================================================================
    # PROOF OF NO CONTACT
    # ========================================================================
    story.append(Paragraph("Proof: Customer Never Contacted Us", heading_style))
    
    no_contact_text = """
    Before filing this dispute, the customer never reached out to us. We searched all of our 
    support channels:
    """
    story.append(Paragraph(no_contact_text, body_style))
    
    contact_data = [
        ['Support Channel', 'Search Result'],
        ['Intercom (Live Chat/Email)', '0 conversations found'],
        ['Phone Support (888-425-2300)', '0 calls on record'],
        ['Email (wecare@thegenie.ai)', 'No messages received'],
    ]
    
    contact_table = Table(contact_data, colWidths=[3*inch, 3*inch])
    contact_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['navy']),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(contact_table)
    
    story.append(Spacer(1, 0.15*inch))
    
    no_contact_conclusion = """
    <b>This matters because:</b> If the customer truly didn't recognize this charge or had any 
    concerns, they would have contacted us first. Our contact information is prominently displayed 
    in their account and on every confirmation email. They chose to file a dispute without ever 
    reaching out.
    """
    story.append(Paragraph(no_contact_conclusion, body_style))
    
    story.append(Spacer(1, 0.2*inch))
    
    # ========================================================================
    # ACCOUNT INFORMATION
    # ========================================================================
    story.append(Paragraph("Customer Account Information", heading_style))
    
    account_text = """
    The customer has an active account with us. Here are the verified account details:
    """
    story.append(Paragraph(account_text, body_style))
    
    account_data = [
        ['Email Address', case['customer_email']],
        ['Username', 'ChrisPlank'],
        ['Phone Number', case['customer_phone']],
        ['Account Status', 'Active'],
        ['IP Addresses Used', '253.44.124.95, 253.119.141.152, 70.187.193.188'],
    ]
    
    account_table = Table(account_data, colWidths=[2.2*inch, 4*inch])
    account_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), COLORS['light_gray']),
        ('TEXTCOLOR', (0, 0), (-1, -1), COLORS['slate']),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(account_table)
    
    story.append(PageBreak())
    
    # ========================================================================
    # CONCLUSION
    # ========================================================================
    story.append(Paragraph("Conclusion", heading_style))
    
    conclusion_text = f"""
    We have provided clear and documented evidence that:
    """
    story.append(Paragraph(conclusion_text, body_style))
    
    conclusion_points = """
    <b>1. The customer made this purchase.</b> Our activity logs show them logging in, 
    configuring their order, reviewing the details, and authorizing payment—all within 
    a 2-minute window on December 4, 2025.<br/><br/>
    
    <b>2. The service was fully delivered.</b> We executed the SMS campaign on December 5, 2025. 
    149 text messages were sent to real property owners. One recipient responded.<br/><br/>
    
    <b>3. The customer never contacted us.</b> We searched all support channels and found 
    zero attempts to reach out before this dispute was filed.<br/><br/>
    
    <b>4. The customer's claim is false.</b> The statement "I did not make this purchase" 
    is directly contradicted by our documented activity logs and the customer's own account history.
    """
    story.append(Paragraph(conclusion_points, body_style))
    
    story.append(Spacer(1, 0.2*inch))
    
    request_text = """
    <b>Our Request:</b> Based on the evidence provided, we respectfully request that this 
    dispute be resolved in favor of TheGenie.ai. The customer received exactly what they 
    ordered, the service was fully delivered, and there is no valid basis for this chargeback.
    """
    story.append(Paragraph(request_text, body_style))
    
    story.append(Spacer(1, 0.3*inch))
    
    closing_text = """
    Thank you for your time and consideration.
    """
    story.append(Paragraph(closing_text, body_style))
    
    story.append(Spacer(1, 0.3*inch))
    
    signature = """
    <b>TheGenie.ai Customer Experience Team</b><br/>
    wecare@thegenie.ai<br/>
    888-425-2300
    """
    story.append(Paragraph(signature, body_style))
    
    # Build PDF
    print("  Building PDF...")
    doc.build(story, onFirstPage=add_page_number, onLaterPages=add_page_number)
    
    # Check file size
    file_size_mb = pdf_path.stat().st_size / (1024 * 1024)
    
    print(f"\n✅ Polished Response Generated: {pdf_path.name}")
    print(f"   Version: {version}")
    print(f"   File Size: {file_size_mb:.2f} MB")
    print(f"   Location: {pdf_path}")
    
    return pdf_path


if __name__ == "__main__":
    pdf_path = generate_polished_response()
    print("\n" + "="*80)
    print("GENERATION COMPLETE")
    print("="*80)
    print(f"\nOpen this file to review: {pdf_path}")

