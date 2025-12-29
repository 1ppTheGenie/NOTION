#!/usr/bin/env python3
"""
Competition Command Chargeback Dispute Response Generator - Version 3
Based on generate_polished_response_v12.py (GOLD STANDARD)

Case: Susan Featherly - Competition Command for ZIP 91325
PayPal Case ID: PP-R-NVE-599340890
Transaction ID: 0XN48732G1786400J
Invoice: 62279
Amount: $500.00

CRITICAL FINDING: Customer claims "cancelled before being billed"
EVIDENCE: Customer contacted support to cancel on October 23, 2025 - 
          9 DAYS AFTER the October 14, 2025 payment was processed.
"""

import os
import json
from datetime import datetime
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    Image, PageBreak, HRFlowable, KeepTogether
)
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY, TA_RIGHT
from reportlab.pdfgen import canvas
from PIL import Image as PILImage, ImageDraw, ImageFont
from io import BytesIO
import requests

# 1ParkPlace logo URL
LOGO_URL = "https://cloud.thegenie.ai/_assets/images/1parkplace-logo.png"

# ============================================================================
# CASE DATA - SUSAN FEATHERLY (VERIFIED FROM WHMCS, DATABASE, INTERCOM)
# ============================================================================
CASE_DATA = {
    # Customer Information (VERIFIED)
    'customer_name': 'Susan Featherly',
    'customer_email': 'homesbypeter.susan@gmail.com',
    'aspnet_user_id': 'e48d2a8e-c991-44f4-b751-e170fc8df131',
    'whmcs_client_id': '3158',
    
    # Transaction Details (VERIFIED FROM WHMCS)
    'transaction_id': '0XN48732G1786400J',
    'paypal_case_id': 'PP-R-NVE-599340890',
    'transaction_amount': '$500.00',
    'transaction_date': 'October 14, 2025',
    'transaction_time': '08:00:23 AM PST',
    'payment_method': 'PayFlow Pro (PayPal)',
    
    # Order Details (VERIFIED FROM WHMCS)
    'order_id': '8923',
    'invoice_id': '62279',
    'whmcs_transaction_id': '48077',
    'product_id': '83',
    
    # Service Details (VERIFIED FROM WHMCS)
    'service_type': 'Competition Command - Monthly Subscription',
    'service_description': 'Competition Command for ZIP 91325',
    'zip_code': '91325',
    'billing_cycle': 'Monthly',
    'recurring_amount': '$500.00',
    
    # Subscription History (VERIFIED FROM WHMCS - 9 successful payments)
    'subscription_start_date': 'February 14, 2025',
    'total_payments': '9',
    'total_amount_paid': '$4,750.00',
    'payment_history': [
        {'date': 'February 14, 2025', 'amount': '$500.00', 'invoice': '61246'},
        {'date': 'March 14, 2025', 'amount': '$1,000.00', 'invoice': '61334'},
        {'date': 'April 14, 2025', 'amount': '$500.00', 'invoice': '61493'},
        {'date': 'May 14, 2025', 'amount': '$500.00', 'invoice': '61649'},
        {'date': 'June 14, 2025', 'amount': '$500.00', 'invoice': '61797'},
        {'date': 'July 14, 2025', 'amount': '$500.00', 'invoice': '61926'},
        {'date': 'August 14, 2025', 'amount': '$500.00', 'invoice': '62048'},
        {'date': 'September 14, 2025', 'amount': '$250.00', 'invoice': '62167'},
        {'date': 'October 14, 2025', 'amount': '$500.00', 'invoice': '62279'},  # DISPUTED
    ],
    
    # Dispute Details
    'dispute_reason': 'Customer claims cancelled before being billed',
    'dispute_filed': 'October 24, 2025',
    'days_after_transaction': '10',
    
    # CRITICAL EVIDENCE: Cancellation Request AFTER Payment
    'cancellation_request_date': 'October 23, 2025',
    'cancellation_request_time': '12:22:01 AM PST',
    'cancellation_intercom_id': '215471416308487',
    'cancellation_message': 'Hello, I am writing this email to cancel my account ASAP. Although I am very happy with the product, and would recommend it to my agents. Please let me know what I need to do to proceed.',
    'days_after_payment_cancellation': '9',
    
    # Usage Evidence (VERIFIED FROM DATABASE)
    'login_count': '6',  # BrowserUsage records
    'last_login_date': 'December 10, 2025',
    'activity_count': '88',  # ActivityTracker records since Sept 2025
    'farm_cast_configs': '4',  # PropertyCast configurations
    'farm_cast_log_count': '15,750',  # PropertyCastLog entries
    'last_service_run': 'December 10, 2025',
    
    # Browser/Device Info (VERIFIED FROM DATABASE - most recent)
    'login_ip': '241.208.224.127',
    'browser': 'Chrome 143.0.0.0',
    'os': 'macOS',
    'platform': 'Desktop',
    
    # Support Contact History (VERIFIED FROM INTERCOM)
    'intercom_conversations': '6',
    'total_support_contacts': '6',
    
    # Email confirmations
    'confirmation_email_date': 'October 14, 2025',
    'confirmation_email_status': 'Sent',
}

# ============================================================================
# APPLE-STYLE COLOR PALETTE (from v12)
# ============================================================================
COLORS = {
    'black': colors.HexColor('#000000'),
    'charcoal': colors.HexColor('#1d1d1f'),
    'dark_gray': colors.HexColor('#2d2d2d'),
    'medium_gray': colors.HexColor('#6e6e73'),
    'light_gray': colors.HexColor('#f5f5f7'),
    'white': colors.HexColor('#ffffff'),
    'blue': colors.HexColor('#0071e3'),
    'green': colors.HexColor('#34c759'),
    'red': colors.HexColor('#ff3b30'),
    'border': colors.HexColor('#d2d2d7'),
    'highlight': colors.HexColor('#f0f0f5'),
}

# ============================================================================
# STYLES (from v12)
# ============================================================================
def get_apple_styles():
    styles = getSampleStyleSheet()
    
    styles.add(ParagraphStyle(
        name='AppleTitle',
        fontName='Helvetica-Bold',
        fontSize=18,
        textColor=COLORS['black'],
        spaceAfter=4,
        alignment=TA_CENTER
    ))
    
    styles.add(ParagraphStyle(
        name='AppleSubtitle',
        fontName='Helvetica',
        fontSize=11,
        textColor=COLORS['medium_gray'],
        spaceAfter=12,
        alignment=TA_CENTER
    ))
    
    styles.add(ParagraphStyle(
        name='AppleSection',
        fontName='Helvetica-Bold',
        fontSize=12,
        textColor=COLORS['charcoal'],
        spaceBefore=14,
        spaceAfter=8,
    ))
    
    styles.add(ParagraphStyle(
        name='AppleBody',
        fontName='Helvetica',
        fontSize=10,
        textColor=COLORS['charcoal'],
        leading=14,
        spaceAfter=8,
        alignment=TA_LEFT
    ))
    
    styles.add(ParagraphStyle(
        name='AppleSmall',
        fontName='Helvetica',
        fontSize=9,
        textColor=COLORS['medium_gray'],
        leading=12,
        spaceAfter=6
    ))
    
    styles.add(ParagraphStyle(
        name='AppleBullet',
        fontName='Helvetica',
        fontSize=9,
        textColor=COLORS['charcoal'],
        leading=12,
        leftIndent=20,
        spaceAfter=3
    ))
    
    styles.add(ParagraphStyle(
        name='AppleCentered',
        fontName='Helvetica',
        fontSize=9,
        textColor=COLORS['medium_gray'],
        alignment=TA_CENTER,
        spaceAfter=4
    ))
    
    styles.add(ParagraphStyle(
        name='AppleFooter',
        fontName='Helvetica',
        fontSize=8,
        textColor=COLORS['medium_gray'],
    ))
    
    styles.add(ParagraphStyle(
        name='TermsHeader',
        fontName='Helvetica-Bold',
        fontSize=10,
        textColor=COLORS['charcoal'],
        spaceBefore=10,
        spaceAfter=4,
    ))
    
    styles.add(ParagraphStyle(
        name='TermsBody',
        fontName='Helvetica',
        fontSize=9,
        textColor=COLORS['charcoal'],
        leading=12,
        spaceAfter=4,
        alignment=TA_LEFT
    ))
    
    styles.add(ParagraphStyle(
        name='CriticalEvidence',
        fontName='Helvetica-Bold',
        fontSize=10,
        textColor=COLORS['red'],
        leading=14,
        spaceAfter=8,
        alignment=TA_LEFT
    ))
    
    return styles


# ============================================================================
# NUMBERED CANVAS FOR DYNAMIC PAGE COUNTING (from v12)
# ============================================================================
class NumberedCanvas(canvas.Canvas):
    """Two-pass page counting - ALWAYS use this"""
    
    def __init__(self, *args, **kwargs):
        canvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []
    
    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()
    
    def save(self):
        """Add page numbers to each page."""
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_footer(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)
    
    def draw_page_footer(self, total_pages):
        """Draw footer with accurate page count on each page."""
        self.saveState()
        
        # Footer line
        self.setStrokeColor(COLORS['border'])
        self.setLineWidth(0.5)
        self.line(0.6*inch, 0.4*inch, 8*inch, 0.4*inch)
        
        # Left side: Document info
        self.setFont('Helvetica', 8)
        self.setFillColor(COLORS['medium_gray'])
        left_text = f"{CASE_DATA['customer_name']} | {CASE_DATA['transaction_id']} | {datetime.now().strftime('%m/%d/%Y')}"
        self.drawString(0.6*inch, 0.25*inch, left_text)
        
        # Right side: Page number (DYNAMIC)
        right_text = f"Page {self._pageNumber} of {total_pages}"
        self.drawRightString(8*inch, 0.25*inch, right_text)
        
        self.restoreState()


# ============================================================================
# MAIN DOCUMENT GENERATOR
# ============================================================================
def generate_competition_command_response(output_dir):
    """Generate complete dispute response for Competition Command subscription"""
    
    case = CASE_DATA
    version = 3
    output_file = os.path.join(output_dir, f"SusanFeatherly_CompetitionCommand_Dispute_Response_v{version}.pdf")
    
    # Create document
    doc = SimpleDocTemplate(
        output_file,
        pagesize=letter,
        rightMargin=0.6*inch,
        leftMargin=0.6*inch,
        topMargin=0.5*inch,
        bottomMargin=0.6*inch
    )
    
    styles = get_apple_styles()
    story = []
    
    # ========================================================================
    # PAGE 1: COVER / HEADER
    # ========================================================================
    
    # Try to add 1ParkPlace logo
    try:
        logo_response = requests.get(LOGO_URL, timeout=10)
        if logo_response.status_code == 200:
            logo_data = BytesIO(logo_response.content)
            logo_img = Image(logo_data, width=1.5*inch, height=0.5*inch)
            story.append(logo_img)
            story.append(Spacer(1, 0.15*inch))
    except Exception as e:
        print(f"  Note: Could not load logo: {e}")
        story.append(Spacer(1, 0.3*inch))
    
    story.append(Paragraph("MERCHANT DISPUTE RESPONSE", styles['AppleTitle']))
    story.append(Paragraph("Competition Command Subscription - Evidence Package", styles['AppleSubtitle']))
    story.append(Spacer(1, 0.2*inch))
    
    # Reference table
    ref_data = [
        ['MERCHANT', '1ParkPlace, Inc. (dba TheGenie.ai)'],
        ['CARDHOLDER', case['customer_name']],
        ['TRANSACTION ID', case['transaction_id']],
        ['PAYPAL CASE ID', case['paypal_case_id']],
        ['AMOUNT', case['transaction_amount']],
        ['TRANSACTION DATE', f"{case['transaction_date']} at {case['transaction_time']}"],
        ['SERVICE', case['service_description']],
        ['1PARKPLACE ORDER ID', case['order_id']],
        ['1PARKPLACE INVOICE', case['invoice_id']],
        ['DISPUTE REASON', case['dispute_reason']],
    ]
    ref_table = Table(ref_data, colWidths=[1.8*inch, 4.8*inch])
    ref_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (0, -1), COLORS['white']),
        ('BACKGROUND', (1, 0), (1, -1), COLORS['light_gray']),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(ref_table)
    
    story.append(Spacer(1, 0.4*inch))
    
    # CRITICAL EVIDENCE HIGHLIGHT
    story.append(Paragraph(
        "<b>⚠️ CRITICAL EVIDENCE:</b> Customer claims they \"cancelled before being billed.\" "
        "Our records prove the customer contacted support to cancel on <b>October 23, 2025</b> — "
        "<b>9 DAYS AFTER</b> the disputed payment was processed on October 14, 2025.",
        styles['CriticalEvidence']
    ))
    
    story.append(Spacer(1, 0.3*inch))
    story.append(HRFlowable(width="50%", thickness=1, color=COLORS['border']))
    story.append(Spacer(1, 0.2*inch))
    story.append(Paragraph(
        f"<b>Document Prepared:</b> {datetime.now().strftime('%B %d, %Y')}<br/>"
        f"<b>Prepared By:</b> 1ParkPlace, Inc. Accounting &amp; Compliance",
        styles['AppleCentered']
    ))
    
    # ========================================================================
    # PAGE 2: EXECUTIVE SUMMARY + CHECKLIST
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>EXECUTIVE SUMMARY</b>", styles['AppleSection']))
    
    exec_bullets = [
        f"Customer has been an active subscriber since <b>{case['subscription_start_date']}</b> (8+ months).",
        f"This is a <b>recurring monthly subscription</b> at {case['recurring_amount']}/month, not a one-time purchase.",
        f"Customer has made <b>{case['total_payments']} successful payments</b> totaling {case['total_amount_paid']}.",
        f"The disputed payment of {case['transaction_amount']} was processed on <b>{case['transaction_date']}</b>.",
        f"Customer contacted support to cancel on <b>{case['cancellation_request_date']}</b> — <b>{case['days_after_payment_cancellation']} days AFTER</b> payment.",
        f"Customer's own message: \"I am writing this email to cancel my account ASAP.\"",
        f"Service was actively used: {case['farm_cast_log_count']} tracking events, {case['activity_count']} activities logged.",
        f"Dispute filed <b>{case['days_after_transaction']} days</b> after payment, with cancellation request occurring after billing.",
    ]
    
    for bullet in exec_bullets:
        story.append(Paragraph(f"<bullet>&bull;</bullet> {bullet}", styles['AppleBullet']))
    
    story.append(Spacer(1, 0.15*inch))
    
    conclusion = """
    Based on the evidence provided, the customer's claim of "cancelled before being billed" is 
    <b>demonstrably false</b>. The cancellation request was made <b>9 days after</b> the payment 
    was processed. We respectfully request this dispute be resolved in favor of the merchant.
    """
    story.append(Paragraph(conclusion, styles['AppleBody']))
    
    # Evidence checklist
    story.append(Paragraph("<b>EVIDENCE CHECKLIST (Card Network Compliance)</b>", styles['AppleSection']))
    
    checklist = [
        ['Requirement', 'Evidence Provided', 'Status'],
        ['Recurring Billing Consent', 'Monthly subscription since Feb 2025, 9 successful payments', 'VERIFIED'],
        ['Payment Processing', f'Transaction {case["transaction_id"]} on {case["transaction_date"]}', 'VERIFIED'],
        ['Service Delivery', f'{case["farm_cast_log_count"]} tracking events, service ran Dec 10, 2025', 'VERIFIED'],
        ['Cancellation Timeline', 'Request made Oct 23, 2025 - 9 days AFTER Oct 14 payment', 'VERIFIED'],
        ['Customer Communication', f'{case["intercom_conversations"]} Intercom conversations on record', 'VERIFIED'],
        ['Account Activity', f'{case["activity_count"]} activities, {case["login_count"]} logins recorded', 'VERIFIED'],
    ]
    check_table = Table(checklist, colWidths=[1.8*inch, 3.2*inch, 1.2*inch])
    check_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (-1, 0), COLORS['white']),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('ALIGN', (2, 0), (2, -1), 'CENTER'),
        ('TEXTCOLOR', (2, 1), (2, -1), COLORS['green']),
        ('FONTNAME', (2, 1), (2, -1), 'Helvetica-Bold'),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(check_table)
    
    # ========================================================================
    # PAGE 3: SUBSCRIPTION DETAILS + PAYMENT HISTORY
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>1. SUBSCRIPTION DETAILS</b>", styles['AppleSection']))
    
    order_data = [
        ['Service', case['service_type']],
        ['Description', case['service_description']],
        ['Exclusive ZIP Code', case['zip_code']],
        ['Billing Cycle', case['billing_cycle']],
        ['Recurring Amount', case['recurring_amount']],
        ['Subscription Start', case['subscription_start_date']],
        ['Total Payments Made', case['total_payments']],
        ['Total Amount Paid', case['total_amount_paid']],
        ['Product ID', case['product_id']],
    ]
    order_table = Table(order_data, colWidths=[1.8*inch, 4.8*inch])
    order_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), COLORS['highlight']),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(order_table)
    story.append(Spacer(1, 0.2*inch))
    
    # Payment history
    story.append(Paragraph("<b>COMPLETE PAYMENT HISTORY (9 Successful Payments)</b>", styles['AppleSection']))
    story.append(Paragraph(
        "The following table shows all payments made by the customer since subscription start. "
        "This demonstrates ongoing, authorized recurring billing:",
        styles['AppleSmall']
    ))
    
    payment_data = [['#', 'Date', 'Amount', 'Invoice', 'Status']]
    for i, payment in enumerate(case['payment_history'], 1):
        status = 'DISPUTED' if payment['invoice'] == '62279' else 'PAID'
        payment_data.append([str(i), payment['date'], payment['amount'], payment['invoice'], status])
    
    payment_table = Table(payment_data, colWidths=[0.4*inch, 1.5*inch, 1*inch, 1*inch, 1*inch])
    payment_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (-1, 0), COLORS['white']),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('ALIGN', (0, 0), (0, -1), 'CENTER'),
        ('ALIGN', (4, 0), (4, -1), 'CENTER'),
        ('TEXTCOLOR', (4, -1), (4, -1), COLORS['red']),  # DISPUTED in red
        ('FONTNAME', (4, -1), (4, -1), 'Helvetica-Bold'),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(payment_table)
    
    story.append(Spacer(1, 0.15*inch))
    story.append(Paragraph(
        "<b>Note:</b> The customer successfully made 8 prior payments without dispute. "
        "This pattern demonstrates authorized recurring billing.",
        styles['AppleSmall']
    ))
    
    # ========================================================================
    # PAGE 4: CRITICAL EVIDENCE - CANCELLATION TIMELINE
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>2. CRITICAL EVIDENCE: CANCELLATION TIMELINE</b>", styles['AppleSection']))
    
    story.append(Paragraph(
        "The customer claims they \"cancelled before being billed.\" Our records prove otherwise:",
        styles['AppleBody']
    ))
    story.append(Spacer(1, 0.1*inch))
    
    timeline_data = [
        ['Date', 'Time', 'Event', 'Evidence'],
        ['Oct 14, 2025', '08:00:23 AM', 'PAYMENT PROCESSED', f'Transaction {case["transaction_id"]}'],
        ['Oct 23, 2025', '12:22:01 AM', 'CANCELLATION REQUESTED', f'Intercom Conv #{case["cancellation_intercom_id"]}'],
        ['Oct 24, 2025', '-', 'DISPUTE FILED', case['paypal_case_id']],
    ]
    timeline_table = Table(timeline_data, colWidths=[1.2*inch, 1*inch, 1.8*inch, 2.2*inch])
    timeline_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (-1, 0), COLORS['white']),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor('#e8f5e9')),  # Green highlight for payment
        ('BACKGROUND', (0, 2), (-1, 2), colors.HexColor('#fff3e0')),  # Orange highlight for cancel
        ('BACKGROUND', (0, 3), (-1, 3), colors.HexColor('#ffebee')),  # Red highlight for dispute
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(timeline_table)
    
    story.append(Spacer(1, 0.2*inch))
    
    story.append(Paragraph("<b>CUSTOMER'S ACTUAL CANCELLATION MESSAGE (Intercom Record)</b>", styles['AppleSection']))
    story.append(Paragraph(
        f"<i>\"{case['cancellation_message']}\"</i>",
        styles['AppleBody']
    ))
    story.append(Spacer(1, 0.1*inch))
    story.append(Paragraph(
        f"<b>Timestamp:</b> October 23, 2025 at 12:22:01 AM PST<br/>"
        f"<b>Intercom Conversation ID:</b> {case['cancellation_intercom_id']}<br/>"
        f"<b>State:</b> Closed (responded to by support)",
        styles['AppleSmall']
    ))
    
    story.append(Spacer(1, 0.2*inch))
    
    # Gap analysis box
    story.append(Paragraph("<b>⚠️ KEY FINDING</b>", styles['TermsHeader']))
    gap_text = """
    The customer's cancellation request was made <b>9 days and 16 hours AFTER</b> the payment 
    was processed. The customer's claim of "cancelled before being billed" is factually incorrect 
    and disproven by our communication records.
    """
    story.append(Paragraph(gap_text, styles['AppleBody']))
    
    # ========================================================================
    # PAGE 5: SERVICE USAGE EVIDENCE
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>3. PROOF OF SERVICE DELIVERY & USAGE</b>", styles['AppleSection']))
    
    story.append(Paragraph(
        "The Competition Command service was actively used by the customer. Our database records prove:",
        styles['AppleBody']
    ))
    
    usage_data = [
        ['Metric', 'Value', 'Notes'],
        ['Farm Cast Configurations', case['farm_cast_configs'], 'Active monitoring setups for ZIP 91325'],
        ['Tracking Events Logged', case['farm_cast_log_count'], 'Property cast log entries'],
        ['Total Activities', case['activity_count'], 'Since September 2025'],
        ['Login Sessions', case['login_count'], 'Recorded browser sessions'],
        ['Last Service Run', case['last_service_run'], 'Most recent automated execution'],
        ['Last Login', case['last_login_date'], 'Most recent account access'],
    ]
    usage_table = Table(usage_data, colWidths=[1.8*inch, 1.2*inch, 3.2*inch])
    usage_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (-1, 0), COLORS['white']),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(usage_table)
    
    story.append(Spacer(1, 0.2*inch))
    
    # Device info
    story.append(Paragraph("<b>Device & Session Information</b>", styles['AppleSection']))
    
    device_data = [
        ['Attribute', 'Value'],
        ['Browser', case['browser']],
        ['Operating System', case['os']],
        ['Platform', case['platform']],
        ['IP Address', case['login_ip']],
    ]
    device_table = Table(device_data, colWidths=[1.5*inch, 4.8*inch])
    device_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (-1, 0), COLORS['white']),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(device_table)
    
    # ========================================================================
    # PAGE 6: SUPPORT CONTACT HISTORY
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>4. CUSTOMER SUPPORT CONTACT HISTORY</b>", styles['AppleSection']))
    
    story.append(Paragraph(
        f"The customer has contacted support <b>{case['intercom_conversations']} times</b> via Intercom. "
        "The cancellation request on October 23, 2025 was processed, but occurred AFTER the disputed payment.",
        styles['AppleBody']
    ))
    
    contact_data = [
        ['Date', 'Channel', 'Summary', 'Timing'],
        ['Oct 23, 2025', 'Intercom', 'Cancellation request', 'AFTER Oct 14 payment'],
        ['Oct 23, 2025', 'Intercom', 'Paisley AI chat', 'AFTER Oct 14 payment'],
        ['Sep 3, 2025', 'Intercom', 'General inquiry', 'BEFORE Oct 14 payment'],
        ['Aug 21, 2025', 'Intercom', 'General inquiry', 'BEFORE Oct 14 payment'],
        ['Mar 27, 2025', 'Intercom', 'Billing question ($1000 charge)', 'BEFORE Oct 14 payment'],
    ]
    contact_table = Table(contact_data, colWidths=[1.2*inch, 1*inch, 2*inch, 2*inch])
    contact_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (-1, 0), COLORS['white']),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('BACKGROUND', (0, 1), (-1, 2), colors.HexColor('#fff3e0')),  # Highlight post-payment contacts
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(contact_table)
    
    story.append(Spacer(1, 0.15*inch))
    story.append(Paragraph(
        "<b>CONCLUSION:</b> None of the contacts prior to October 14, 2025 were cancellation requests. "
        "The first and only cancellation request was made on October 23, 2025 — 9 days after the disputed payment.",
        styles['AppleBody']
    ))
    
    # ========================================================================
    # PAGE 7: TERMS OF SERVICE
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>5. TERMS OF SERVICE & SUBSCRIPTION AGREEMENT</b>", styles['AppleSection']))
    
    terms_intro = """
    Competition Command is a monthly recurring subscription service. By subscribing, 
    the customer agreed to the following terms:
    """
    story.append(Paragraph(terms_intro, styles['AppleBody']))
    story.append(Spacer(1, 0.1*inch))
    
    story.append(Paragraph("<b>BILLING TERMS</b>", styles['TermsHeader']))
    
    billing_terms = """
    <br/>&#10004; <b>Recurring Billing:</b> Subscription renews automatically each month
    <br/>&#10004; <b>Billing Date:</b> Same day each month as original subscription
    <br/>&#10004; <b>Amount:</b> $500.00/month for exclusive ZIP code territory
    <br/>&#10004; <b>Cancellation:</b> Must be requested before next billing cycle
    <br/>&#10004; <b>Pro-rata Refunds:</b> Not available for partial month usage
    """
    story.append(Paragraph(billing_terms, styles['TermsBody']))
    story.append(Spacer(1, 0.15*inch))
    
    story.append(Paragraph("<b>CANCELLATION POLICY</b>", styles['TermsHeader']))
    
    cancel_terms = """
    Cancellation requests must be submitted <b>before</b> the next billing cycle to avoid charges.
    Once a payment is processed, the service period is paid for in full.
    <br/><br/>
    In this case, the customer's cancellation request on October 23, 2025 would have prevented 
    the <b>November 14, 2025</b> billing — but does not qualify for refund of the already-processed 
    October 14, 2025 payment.
    """
    story.append(Paragraph(cancel_terms, styles['TermsBody']))
    
    # ========================================================================
    # PAGE 8: MERCHANT REQUEST
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>6. MERCHANT REQUEST</b>", styles['AppleSection']))
    
    conclusion = f"""
    Based on the evidence presented:
    <br/><br/>
    <b>1. Authorized Recurring Billing:</b> Customer subscribed February 14, 2025 and made 9 successful payments.
    <br/><br/>
    <b>2. Payment Processed Correctly:</b> October 14, 2025 payment of {case['transaction_amount']} was routine monthly billing.
    <br/><br/>
    <b>3. Cancellation Request AFTER Payment:</b> Customer contacted support October 23, 2025 — 9 days AFTER payment.
    <br/><br/>
    <b>4. Service Actively Used:</b> {case['farm_cast_log_count']} tracking events, service ran as recently as {case['last_service_run']}.
    <br/><br/>
    <b>5. Customer's Own Words:</b> "I am writing this email to cancel my account ASAP" — dated October 23, 2025.
    """
    story.append(Paragraph(conclusion, styles['AppleBody']))
    story.append(Spacer(1, 0.2*inch))
    
    story.append(Paragraph(
        "<b>The customer's claim of \"cancelled before being billed\" is demonstrably false.</b><br/><br/>"
        "<b>We respectfully request this dispute be resolved in favor of the merchant.</b>",
        styles['AppleBody']
    ))
    story.append(Spacer(1, 0.4*inch))
    
    # Signature block
    story.append(HRFlowable(width="100%", thickness=1, color=COLORS['border']))
    story.append(Spacer(1, 0.15*inch))
    
    sig_text = f"""
    <b>1ParkPlace, Inc.</b><br/>
    Accounting &amp; Compliance<br/>
    <br/>
    Email: wecare@thegenie.ai<br/>
    Phone: 888-425-2300<br/>
    <br/>
    <i>Powered by 1ParkPlace</i><br/>
    <br/>
    <b>Document Generated:</b> {datetime.now().strftime("%B %d, %Y at %I:%M %p")}<br/>
    <b>Reference:</b> {case['transaction_id']}<br/>
    <b>Case ID:</b> {case['paypal_case_id']}
    """
    story.append(Paragraph(sig_text, styles['AppleCentered']))
    
    # ========================================================================
    # END OF DOCUMENT
    # ========================================================================
    story.append(PageBreak())
    story.append(Spacer(1, 2*inch))
    story.append(Paragraph("END OF DOCUMENT", styles['AppleTitle']))
    story.append(Spacer(1, 0.2*inch))
    story.append(Paragraph(
        "This evidence package contains complete documentation supporting the merchant's "
        "position in this dispute. All evidence has been gathered from our production systems "
        "and represents accurate records of the transaction, service delivery, and customer communications.",
        styles['AppleCentered']
    ))
    
    # Build with NumberedCanvas for DYNAMIC page counting
    print("  Building PDF with DYNAMIC page counting...")
    doc.build(story, canvasmaker=NumberedCanvas)
    
    file_size = os.path.getsize(output_file) / (1024 * 1024)
    print(f"\n[OK] Complete Response Generated: {os.path.basename(output_file)}")
    print(f"   Version: {version}")
    print(f"   File Size: {file_size:.2f} MB")
    print(f"   Location: {output_file}")
    
    return output_file


# ============================================================================
# MAIN
# ============================================================================
if __name__ == "__main__":
    print("\n" + "="*80)
    print("GENERATING COMPETITION COMMAND DISPUTE RESPONSE v3")
    print("Case: Susan Featherly - Competition Command for ZIP 91325")
    print("="*80)
    
    base_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(base_dir, "DefenseKits")
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"  Output Dir: {output_dir}")
    
    output = generate_competition_command_response(output_dir)
    
    print("\n" + "="*80)
    print("GENERATION COMPLETE")
    print("="*80 + "\n")
    
    # Open the PDF
    import subprocess
    subprocess.Popen(['start', '', output], shell=True)

