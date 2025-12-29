#!/usr/bin/env python3
"""
Competition Command Chargeback Dispute Response Generator - Version 4
SUBSCRIPTION GOLD CLASS - GPT Advisor Optimized

Based on generate_polished_response_v12.py (GOLD STANDARD for one-offs)
Refined per GPT Advisor feedback to reach 9.7-9.8 score

CHANGES IN V4 (GPT Advisor Refinements):
1. Neutralized aggressive language ("demonstrably false" → "not supported by timeline")
2. Shortened Executive Summary to 6 bullets, strictly timeline-sequenced
3. Reduced emphasis callouts to ONE key finding
4. Trimmed Terms section by ~15%
5. Moved usage metrics out of Executive Summary to Service Delivery section

Case: Susan Featherly - Competition Command for ZIP 91325
PayPal Case ID: PP-R-NVE-599340890
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
    'subscription_duration': '8 months',
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
    
    # Usage Evidence (VERIFIED FROM DATABASE) - Moved to Service Delivery section per GPT advice
    'login_count': '6',
    'last_login_date': 'December 10, 2025',
    'activity_count': '88',
    'farm_cast_configs': '4',
    'farm_cast_log_count': '15,750',
    'last_service_run': 'December 10, 2025',
    
    # Browser/Device Info (VERIFIED FROM DATABASE)
    'login_ip': '241.208.224.127',
    'browser': 'Chrome 143.0.0.0',
    'os': 'macOS',
    'platform': 'Desktop',
    
    # Support Contact History (VERIFIED FROM INTERCOM)
    'intercom_conversations': '6',
}

# ============================================================================
# APPLE-STYLE COLOR PALETTE
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
# STYLES
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
    
    # Neutral tone for key finding (not aggressive red)
    styles.add(ParagraphStyle(
        name='KeyFinding',
        fontName='Helvetica-Bold',
        fontSize=10,
        textColor=COLORS['charcoal'],
        leading=14,
        spaceAfter=8,
        alignment=TA_LEFT,
        backColor=colors.HexColor('#fff3e0'),
        borderPadding=8,
    ))
    
    return styles


# ============================================================================
# NUMBERED CANVAS FOR DYNAMIC PAGE COUNTING
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
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_footer(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)
    
    def draw_page_footer(self, total_pages):
        self.saveState()
        self.setStrokeColor(COLORS['border'])
        self.setLineWidth(0.5)
        self.line(0.6*inch, 0.4*inch, 8*inch, 0.4*inch)
        self.setFont('Helvetica', 8)
        self.setFillColor(COLORS['medium_gray'])
        left_text = f"{CASE_DATA['customer_name']} | {CASE_DATA['transaction_id']} | {datetime.now().strftime('%m/%d/%Y')}"
        self.drawString(0.6*inch, 0.25*inch, left_text)
        right_text = f"Page {self._pageNumber} of {total_pages}"
        self.drawRightString(8*inch, 0.25*inch, right_text)
        self.restoreState()


# ============================================================================
# MAIN DOCUMENT GENERATOR - V4 (GPT ADVISOR OPTIMIZED)
# ============================================================================
def generate_competition_command_response(output_dir):
    """Generate subscription dispute response - GPT Advisor optimized for 9.7+ score"""
    
    case = CASE_DATA
    version = 4
    output_file = os.path.join(output_dir, f"SusanFeatherly_CompetitionCommand_Dispute_Response_v{version}.pdf")
    
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
    # PAGE 1: COVER / HEADER (Neutral tone, no aggressive callouts)
    # ========================================================================
    
    try:
        logo_response = requests.get(LOGO_URL, timeout=10)
        if logo_response.status_code == 200:
            logo_data = BytesIO(logo_response.content)
            logo_img = Image(logo_data, width=1.5*inch, height=0.5*inch)
            story.append(logo_img)
            story.append(Spacer(1, 0.15*inch))
    except:
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
    story.append(HRFlowable(width="50%", thickness=1, color=COLORS['border']))
    story.append(Spacer(1, 0.2*inch))
    story.append(Paragraph(
        f"<b>Document Prepared:</b> {datetime.now().strftime('%B %d, %Y')}<br/>"
        f"<b>Prepared By:</b> 1ParkPlace, Inc. Accounting &amp; Compliance",
        styles['AppleCentered']
    ))
    
    # ========================================================================
    # PAGE 2: EXECUTIVE SUMMARY (OPTIMIZED - 6 bullets, timeline-sequenced)
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>EXECUTIVE SUMMARY</b>", styles['AppleSection']))
    
    # GPT ADVISOR FIX: 6 bullets only, strictly timeline-sequenced
    # No usage metrics here - moved to Service Delivery section
    exec_bullets = [
        f"Customer subscribed to Competition Command on <b>{case['subscription_start_date']}</b> ({case['subscription_duration']} active subscription).",
        f"Customer authorized recurring monthly billing at {case['recurring_amount']}/month and made <b>{case['total_payments']} successful payments</b>.",
        f"The disputed payment of {case['transaction_amount']} was processed on <b>{case['transaction_date']}</b> as routine monthly billing.",
        f"Customer's cancellation request was submitted on <b>{case['cancellation_request_date']}</b> — {case['days_after_payment_cancellation']} days <b>after</b> the payment.",
        f"Dispute was filed on <b>{case['dispute_filed']}</b>, {case['days_after_transaction']} days after the transaction.",
        f"The documented timeline does not support the claim of \"cancelled before being billed.\"",
    ]
    
    for bullet in exec_bullets:
        story.append(Paragraph(f"<bullet>&bull;</bullet> {bullet}", styles['AppleBullet']))
    
    story.append(Spacer(1, 0.15*inch))
    
    # GPT ADVISOR FIX: Neutral conclusion, no "demonstrably false"
    conclusion = """
    Based on the documented timeline, the customer's cancellation request was submitted after 
    the disputed payment was processed. We respectfully request this dispute be resolved in 
    favor of the merchant.
    """
    story.append(Paragraph(conclusion, styles['AppleBody']))
    
    # Evidence checklist
    story.append(Paragraph("<b>EVIDENCE CHECKLIST</b>", styles['AppleSection']))
    
    checklist = [
        ['Requirement', 'Evidence Provided', 'Status'],
        ['Recurring Billing Consent', f'Monthly subscription since {case["subscription_start_date"]}', 'VERIFIED'],
        ['Payment History', f'{case["total_payments"]} successful payments, {case["total_amount_paid"]} total', 'VERIFIED'],
        ['Cancellation Timeline', f'Request made {case["days_after_payment_cancellation"]} days after payment', 'VERIFIED'],
        ['Customer Communication', 'Cancellation message on file with timestamp', 'VERIFIED'],
        ['Service Delivery', 'Active subscription with documented usage', 'VERIFIED'],
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
    
    # Payment history (REQUIRED for subscription disputes per GPT advice)
    story.append(Paragraph("<b>COMPLETE PAYMENT HISTORY</b>", styles['AppleSection']))
    story.append(Paragraph(
        "The following table documents all payments made by the customer, demonstrating "
        "ongoing authorized recurring billing:",
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
        ('TEXTCOLOR', (4, -1), (4, -1), COLORS['red']),
        ('FONTNAME', (4, -1), (4, -1), 'Helvetica-Bold'),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(payment_table)
    
    story.append(Spacer(1, 0.1*inch))
    story.append(Paragraph(
        "Eight prior payments were made without dispute, demonstrating customer awareness of recurring billing.",
        styles['AppleSmall']
    ))
    
    # ========================================================================
    # PAGE 4: CANCELLATION TIMELINE (ONE Key Finding callout here only)
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>2. CANCELLATION TIMELINE</b>", styles['AppleSection']))
    
    story.append(Paragraph(
        "The customer's claim states cancellation occurred before billing. The documented timeline:",
        styles['AppleBody']
    ))
    story.append(Spacer(1, 0.1*inch))
    
    timeline_data = [
        ['Date', 'Time', 'Event', 'Reference'],
        ['Oct 14, 2025', '08:00:23 AM', 'Payment Processed', f'Transaction {case["transaction_id"]}'],
        ['Oct 23, 2025', '12:22:01 AM', 'Cancellation Requested', f'Intercom #{case["cancellation_intercom_id"]}'],
        ['Oct 24, 2025', '-', 'Dispute Filed', case['paypal_case_id']],
    ]
    timeline_table = Table(timeline_data, colWidths=[1.2*inch, 1*inch, 1.8*inch, 2.2*inch])
    timeline_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLORS['charcoal']),
        ('TEXTCOLOR', (0, 0), (-1, 0), COLORS['white']),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLORS['border']),
        ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor('#e8f5e9')),
        ('BACKGROUND', (0, 2), (-1, 2), colors.HexColor('#fff3e0')),
        ('BACKGROUND', (0, 3), (-1, 3), colors.HexColor('#ffebee')),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(timeline_table)
    
    story.append(Spacer(1, 0.2*inch))
    
    story.append(Paragraph("<b>Customer's Cancellation Message (Intercom Record)</b>", styles['AppleSection']))
    story.append(Paragraph(
        f"<i>\"{case['cancellation_message']}\"</i>",
        styles['AppleBody']
    ))
    story.append(Spacer(1, 0.1*inch))
    story.append(Paragraph(
        f"<b>Timestamp:</b> October 23, 2025 at 12:22:01 AM PST<br/>"
        f"<b>Intercom Conversation ID:</b> {case['cancellation_intercom_id']}",
        styles['AppleSmall']
    ))
    
    story.append(Spacer(1, 0.2*inch))
    
    # GPT ADVISOR: ONE key finding callout only - neutral tone
    story.append(Paragraph("<b>Key Finding</b>", styles['TermsHeader']))
    # GPT ADVISOR FIX: Neutral language, not "demonstrably false"
    key_finding = """
    The customer's cancellation request was submitted <b>9 days after</b> the disputed payment 
    was processed. The stated reason of "cancelled before being billed" is not supported by 
    the documented timeline.
    """
    story.append(Paragraph(key_finding, styles['AppleBody']))
    
    # ========================================================================
    # PAGE 5: SERVICE USAGE (Usage metrics moved here per GPT advice)
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>3. SERVICE DELIVERY & USAGE</b>", styles['AppleSection']))
    
    story.append(Paragraph(
        "The Competition Command service was actively delivered and used throughout the subscription period:",
        styles['AppleBody']
    ))
    
    usage_data = [
        ['Metric', 'Value', 'Notes'],
        ['Tracking Configurations', case['farm_cast_configs'], 'Active monitoring setups for ZIP 91325'],
        ['Tracking Events Logged', case['farm_cast_log_count'], 'PropertyCast log entries'],
        ['Account Activities', case['activity_count'], 'Since September 2025'],
        ['Login Sessions', case['login_count'], 'Recorded browser sessions'],
        ['Last Service Run', case['last_service_run'], 'Most recent automated execution'],
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
    # PAGE 6: TERMS OF SERVICE (TRIMMED per GPT advice - ~200 words)
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>4. TERMS OF SERVICE</b>", styles['AppleSection']))
    
    # GPT ADVISOR: Trimmed to essentials only
    terms_text = """
    Competition Command is a monthly recurring subscription. By subscribing, the customer agreed to:
    <br/><br/>
    <b>Billing Terms:</b> Subscription renews automatically on the same day each month. 
    The recurring amount of $500.00/month is charged unless cancelled before the next billing date.
    <br/><br/>
    <b>Cancellation Policy:</b> Cancellation requests must be submitted before the next billing 
    cycle to prevent charges. Once a payment is processed, that billing period is paid in full.
    <br/><br/>
    In this case, the customer's October 23, 2025 cancellation request would have prevented 
    the November 14, 2025 billing, but does not apply to the already-processed October 14, 2025 payment.
    """
    story.append(Paragraph(terms_text, styles['TermsBody']))
    
    # ========================================================================
    # PAGE 7: MERCHANT REQUEST
    # ========================================================================
    story.append(PageBreak())
    
    story.append(Paragraph("<b>5. MERCHANT REQUEST</b>", styles['AppleSection']))
    
    # GPT ADVISOR: Neutral conclusion language
    conclusion = f"""
    Based on the evidence presented:
    <br/><br/>
    <b>1. Authorized Recurring Billing:</b> Customer subscribed {case['subscription_start_date']} and made {case['total_payments']} successful payments.
    <br/><br/>
    <b>2. Payment Processed Correctly:</b> The {case['transaction_date']} payment of {case['transaction_amount']} was routine monthly billing.
    <br/><br/>
    <b>3. Cancellation Request After Payment:</b> Customer contacted support {case['cancellation_request_date']} — {case['days_after_payment_cancellation']} days after payment.
    <br/><br/>
    <b>4. Service Delivered:</b> Active subscription with {case['farm_cast_log_count']} tracking events on record.
    """
    story.append(Paragraph(conclusion, styles['AppleBody']))
    story.append(Spacer(1, 0.2*inch))
    
    story.append(Paragraph(
        "The documented timeline does not support the stated dispute reason. "
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
        "position. All evidence has been gathered from production systems and represents "
        "accurate records of the transaction, service delivery, and customer communications.",
        styles['AppleCentered']
    ))
    
    # Build with NumberedCanvas
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
    print("GENERATING COMPETITION COMMAND DISPUTE RESPONSE v4")
    print("SUBSCRIPTION GOLD CLASS - GPT Advisor Optimized")
    print("="*80)
    
    base_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(base_dir, "DefenseKits")
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"  Output Dir: {output_dir}")
    
    output = generate_competition_command_response(output_dir)
    
    print("\n" + "="*80)
    print("GENERATION COMPLETE - TARGET SCORE: 9.7+")
    print("="*80 + "\n")
    
    # Open the PDF
    import subprocess
    subprocess.Popen(['start', '', output], shell=True)

