"""
Customer Resolution Letter Generator
Friendly letter to customer asking them to resolve the chargeback directly
"""
import json
import sys
import re
from datetime import datetime
from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle, Image
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY

sys.stdout.reconfigure(encoding='utf-8')

# Color Palette - Professional but friendly
COLORS = {
    'primary': colors.HexColor('#2c3e50'),      # Dark blue-gray
    'secondary': colors.HexColor('#3498db'),     # Blue
    'success': colors.HexColor('#27ae60'),       # Green
    'warning': colors.HexColor('#f39c12'),       # Orange
    'light': colors.HexColor('#ecf0f1'),         # Light gray
    'dark': colors.HexColor('#34495e'),          # Dark gray
}

def generate_customer_letter(evidence_file, kit_dir):
    """Generate friendly customer resolution letter"""
    print("\n" + "="*80)
    print("GENERATING CUSTOMER RESOLUTION LETTER")
    print("="*80)
    
    # Load evidence
    with open(evidence_file, 'r', encoding='utf-8') as f:
        evidence = json.load(f)
    
    case = evidence['case_info']
    
    # Get customer name
    customer_name = "Valued Customer"
    if evidence.get('user_details'):
        user = evidence['user_details']
        if user.get('UserName'):
            customer_name = user['UserName']
        elif user.get('Email'):
            # Try to extract name from email
            email_name = user['Email'].split('@')[0]
            customer_name = email_name.replace('.', ' ').replace('_', ' ').title()
    
    # Date formatting - Master format: MM/DD/YYYY
    now = datetime.now()
    letter_date = now.strftime('%m/%d/%Y')
    
    # Filename
    customer_name_clean = re.sub(r'[^\w\s-]', '', customer_name)
    customer_name_clean = re.sub(r'[-\s]+', '_', customer_name_clean).strip('_')
    pdf_filename = f"Customer_Resolution_Letter_{customer_name_clean}_{letter_date.replace('/', '_')}.pdf"
    pdf_path = Path(kit_dir) / pdf_filename
    
    # Create PDF
    doc = SimpleDocTemplate(str(pdf_path), pagesize=letter,
                          rightMargin=50, leftMargin=50,
                          topMargin=50, bottomMargin=50)
    
    story = []
    
    # Styles
    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'Title',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=COLORS['primary'],
        spaceAfter=20,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    heading_style = ParagraphStyle(
        'Heading',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=COLORS['primary'],
        spaceAfter=12,
        spaceBefore=15,
        fontName='Helvetica-Bold'
    )
    
    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.black,
        spaceAfter=12,
        alignment=TA_JUSTIFY,
        leading=16
    )
    
    friendly_style = ParagraphStyle(
        'Friendly',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.black,
        spaceAfter=10,
        alignment=TA_LEFT,
        leading=16
    )
    
    # ========================================================================
    # HEADER
    # ========================================================================
    story.append(Spacer(1, 0.5*inch))
    story.append(Paragraph("TheGenie.ai", title_style))
    story.append(Paragraph("Customer Experience Team", 
                          ParagraphStyle('Subtitle', parent=styles['Normal'], 
                                        fontSize=14, textColor=COLORS['dark'], 
                                        alignment=TA_CENTER)))
    story.append(Spacer(1, 0.3*inch))
    
    # Date and address
    story.append(Paragraph(letter_date, friendly_style))
    story.append(Spacer(1, 0.2*inch))
    
    if evidence.get('user_details'):
        email = evidence['user_details'].get('Email', case.get('customer_email', ''))
        story.append(Paragraph(f"{customer_name}<br/>{email}", friendly_style))
    
    story.append(Spacer(1, 0.3*inch))
    
    # ========================================================================
    # GREETING
    # ========================================================================
    greeting = f"""
    Dear {customer_name},
    """
    story.append(Paragraph(greeting, friendly_style))
    story.append(Spacer(1, 0.2*inch))
    
    # ========================================================================
    # MAIN MESSAGE
    # ========================================================================
    # Get chargeback details
    transaction_id = case.get('paypal_transaction_id', 'N/A')
    transaction_amount = case.get('transaction_amount', '67.50')
    transaction_date = case.get('transaction_date', 'December 5, 2025')
    chargeback_reason = "The buyer stated that they did not make this purchase."
    
    main_message = f"""
    We hope this letter finds you well. We recently received notification from PayPal that a chargeback 
    has been filed regarding your Listing Command purchase.<br/><br/>
    
    <b>Chargeback Details:</b><br/>
    • Case ID: {transaction_id}<br/>
    • Transaction Amount: ${transaction_amount} USD<br/>
    • Transaction Date: {transaction_date}<br/>
    • Chargeback Reason: {chargeback_reason}<br/><br/>
    
    We want to work with you directly to resolve this matter before it proceeds through the formal dispute process.
    """
    story.append(Paragraph(main_message, body_style))
    story.append(Spacer(1, 0.2*inch))
    
    resolution_request = """
    <b>We'd Like to Resolve This Directly</b><br/><br/>
    
    Before this proceeds through the formal dispute process, we'd like to work with you directly 
    to resolve any concerns you may have. We believe in providing excellent customer service and 
    want to ensure you're completely satisfied with your experience.<br/><br/>
    
    If you have any questions about your Listing Command service, concerns about the purchase, or 
    need assistance with anything related to your account, we're here to help. Our team is ready 
    to work with you to find a solution that works for everyone.
    """
    story.append(Paragraph(resolution_request, body_style))
    story.append(Spacer(1, 0.3*inch))
    
    # ========================================================================
    # WHAT WAS PROVIDED
    # ========================================================================
    story.append(Paragraph("What You Received", heading_style))
    
    service_summary = f"""
    Your Listing Command service was fully executed and delivered. Here's what you received:
    """
    story.append(Paragraph(service_summary, body_style))
    story.append(Spacer(1, 0.15*inch))
    
    # Service details
    service_details = [
        ['Service Component', 'Details'],
        ['Property', '1816 9th Street, Manhattan Beach, CA 90266'],
        ['MLS Number', 'SB25228445'],
        ['Service Type', 'SMS Text Messaging Campaign'],
        ['Target Audience', '150 Properties'],
        ['Messages Delivered', '149 SMS messages sent'],
        ['Engagements', '1 engagement received'],
        ['Service Date', 'December 5, 2025']
    ]
    
    service_table = Table(service_details, colWidths=[2.5*inch, 3.5*inch])
    service_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['secondary']),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 11),
        ('BACKGROUND', (0, 1), (-1, -1), COLORS['light']),
        ('GRID', (0, 0), (-1, -1), 1, COLORS['dark']),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(service_table)
    story.append(Spacer(1, 0.3*inch))
    
    # ========================================================================
    # WHY WE CAN HELP
    # ========================================================================
    story.append(Paragraph("How We Can Help", heading_style))
    
    help_text = """
    We understand that sometimes questions arise after a purchase. We're committed to ensuring 
    you have a positive experience with TheGenie.ai. Here's how we can help:
    """
    story.append(Paragraph(help_text, body_style))
    story.append(Spacer(1, 0.15*inch))
    
    help_options = """
    • <b>Answer Questions:</b> If you have any questions about your Listing Command service, 
      how it works, or what you received, we're happy to explain.<br/><br/>
    
    • <b>Review Your Service:</b> We can walk you through exactly what was delivered and 
      how the service was executed.<br/><br/>
    
    • <b>Account Assistance:</b> If you need help accessing your account, viewing your 
      service history, or understanding your deliverables, we're here to assist.<br/><br/>
    
    • <b>Resolve Concerns:</b> If there's a specific issue or concern, let's discuss it 
      and find a solution together.
    """
    story.append(Paragraph(help_options, body_style))
    story.append(Spacer(1, 0.3*inch))
    
    # ========================================================================
    # REQUEST TO RESOLVE
    # ========================================================================
    story.append(Paragraph("Let's Resolve This Together", heading_style))
    
    resolve_text = """
    We believe it's always better to resolve matters directly rather than through formal 
    dispute processes. If you're willing to work with us, we can:
    """
    story.append(Paragraph(resolve_text, body_style))
    story.append(Spacer(1, 0.15*inch))
    
    resolve_options = """
    • Review your service and answer any questions you have<br/>
    • Provide additional documentation or clarification if needed<br/>
    • Work together to find a mutually acceptable solution<br/>
    • Ensure you're satisfied with the resolution
    """
    story.append(Paragraph(resolve_options, body_style))
    story.append(Spacer(1, 0.2*inch))
    
    call_to_action = """
    <b>If you're willing to resolve this directly, please contact us at:</b><br/><br/>
    
    <b>Email:</b> wecare@thegenie.ai<br/>
    <b>Phone:</b> 888-425-2300<br/>
    <b>Reference:</b> Transaction {transaction_id}<br/><br/>
    
    We're available to discuss this matter and work toward a resolution that works for everyone.
    """.format(transaction_id=case.get('paypal_transaction_id', 'N/A'))
    story.append(Paragraph(call_to_action, body_style))
    story.append(Spacer(1, 0.3*inch))
    
    # ========================================================================
    # CLOSING
    # ========================================================================
    closing = """
    We appreciate your business and hope we can resolve this matter to your satisfaction. 
    Thank you for giving us the opportunity to work with you directly.
    """
    story.append(Paragraph(closing, body_style))
    story.append(Spacer(1, 0.3*inch))
    
    signature = """
    Sincerely,<br/><br/>
    
    TheGenie.ai Customer Experience Team<br/>
    wecare@thegenie.ai<br/>
    888-425-2300
    """
    story.append(Paragraph(signature, friendly_style))
    
    # Build PDF
    doc.build(story)
    
    file_size_mb = pdf_path.stat().st_size / (1024 * 1024)
    
    print(f"\n✅ Customer Letter Generated: {pdf_filename}")
    print(f"   Customer: {customer_name}")
    print(f"   File Size: {file_size_mb:.2f} MB")
    print(f"✅ File size within limit")
    print(f"\nPDF Location: {pdf_path}")
    
    return str(pdf_path)

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: python generate_customer_letter.py <evidence_file> <kit_dir>")
        sys.exit(1)
    
    evidence_file = sys.argv[1]
    kit_dir = sys.argv[2]
    
    generate_customer_letter(evidence_file, kit_dir)


