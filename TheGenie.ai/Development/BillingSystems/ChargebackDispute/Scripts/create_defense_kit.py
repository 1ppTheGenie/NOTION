"""
AUTOMATED CHARGEBACK DEFENSE KIT GENERATOR
Push-Button System - Enter Transaction ID, Get Complete Evidence Kit
"""

import sys
import json
from pathlib import Path

# Import evidence collection and kit building modules
from collect_evidence_chris_plank import collect_all_evidence
from build_defense_kit import save_kit, generate_kit_summary

sys.stdout.reconfigure(encoding='utf-8')

def create_kit_from_transaction_id(transaction_id, customer_email=None):
    """
    Main function: Create defense kit from PayPal transaction ID
    
    Args:
        transaction_id: PayPal transaction ID (e.g., "PP-R-THB-607760615")
        customer_email: Optional - customer email if known
    
    Returns:
        Path to created kit directory
    """
    print("\n" + "="*80)
    print("AUTOMATED CHARGEBACK DEFENSE KIT GENERATOR")
    print("="*80)
    print(f"\nTransaction ID: {transaction_id}")
    if customer_email:
        print(f"Customer Email: {customer_email}")
    
    print("\n" + "-"*80)
    print("STEP 1: COLLECTING EVIDENCE FROM ALL SYSTEMS")
    print("-"*80)
    
    # TODO: Query WHMCS API for transaction details
    # For now, using Chris Plank case as template
    # In production, this would:
    # 1. Query WHMCS API for transaction by PayPal ID
    # 2. Get customer email, user ID, transaction date, amount
    # 3. Then collect evidence
    
    # Collect evidence
    evidence = collect_all_evidence()
    
    # Update case info with provided transaction ID
    if transaction_id:
        evidence['case_info']['paypal_transaction_id'] = transaction_id
    
    if customer_email:
        evidence['case_info']['customer_email'] = customer_email
    
    print("\n" + "-"*80)
    print("STEP 2: GENERATING DEFENSE KIT")
    print("-"*80)
    
    # Generate kit
    kit_dir = save_kit(evidence)
    
    # Display summary
    summary = generate_kit_summary(evidence)
    print("\n" + summary)
    
    return kit_dir

if __name__ == "__main__":
    # Example usage
    if len(sys.argv) > 1:
        transaction_id = sys.argv[1]
        customer_email = sys.argv[2] if len(sys.argv) > 2 else None
    else:
        # Default to Chris Plank case for testing
        transaction_id = "PP-R-THB-607760615"
        customer_email = "cp@pacificapg.com"
        print("Using test case (Chris Plank)")
        print("Usage: python create_defense_kit.py <TRANSACTION_ID> [CUSTOMER_EMAIL]")
    
    kit_dir = create_kit_from_transaction_id(transaction_id, customer_email)
    
    print("\n" + "="*80)
    print("✅ DEFENSE KIT CREATED SUCCESSFULLY")
    print("="*80)
    print(f"\nKit Location: {kit_dir}")
    print("\nFiles Generated:")
    print("  - 00_EXECUTIVE_SUMMARY.txt - Quick overview")
    print("  - 01_DETAILED_EVIDENCE_REPORT.txt - Complete evidence report")
    print("  - 02_RAW_EVIDENCE_DATA.json - Raw data for reference")
    print("\nNext Steps:")
    print("  1. Review Executive Summary")
    print("  2. Review Detailed Evidence Report")
    print("  3. Compile into PDF (if needed)")
    print("  4. Submit to PayPal Resolution Center")

