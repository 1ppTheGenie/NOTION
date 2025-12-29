"""
Generate Both Documents - Customer Letter and Merchant Dispute Response
Main entry point that generates both documents
"""
import sys
from pathlib import Path
from generate_customer_letter import generate_customer_letter
from generate_chargeback_response import generate_chargeback_response

def main():
    if len(sys.argv) < 3:
        print("Usage: python generate_both_documents.py <evidence_file> <kit_dir> [terms_file]")
        sys.exit(1)
    
    evidence_file = sys.argv[1]
    kit_dir = sys.argv[2]
    terms_file = sys.argv[3] if len(sys.argv) > 3 else None
    
    print("="*80)
    print("GENERATING BOTH DOCUMENTS")
    print("="*80)
    print(f"Evidence File: {evidence_file}")
    print(f"Kit Directory: {kit_dir}")
    print(f"Terms File: {terms_file if terms_file else 'None'}")
    print("="*80)
    
    # Generate customer letter
    print("\n1. GENERATING CUSTOMER RESOLUTION LETTER...")
    print("-"*80)
    customer_letter_path = generate_customer_letter(evidence_file, kit_dir)
    
    # Generate merchant dispute response
    print("\n2. GENERATING MERCHANT DISPUTE RESPONSE...")
    print("-"*80)
    merchant_response_path = generate_chargeback_response(evidence_file, kit_dir, terms_file)
    
    print("\n" + "="*80)
    print("BOTH DOCUMENTS GENERATED SUCCESSFULLY")
    print("="*80)
    print(f"\n✅ Customer Letter: {Path(customer_letter_path).name}")
    print(f"✅ Merchant Response: {Path(merchant_response_path).name}")
    print(f"\nBoth documents are ready for review and submission.")

if __name__ == "__main__":
    main()


