#!/usr/bin/env python3
"""
Test script for Bedrock Guardrails Service

Usage:
    python test_bedrock_guardrail.py [--url http://127.0.0.1:7273]
"""

import requests
import json
import sys
import argparse

def test_request_endpoint(base_url: str, test_name: str, content: str):
    """Test the /request endpoint"""
    print(f"\n{'='*60}")
    print(f"TEST: {test_name}")
    print(f"{'='*60}")
    print(f"Content: {content}")
    
    payload = {
        "body": {
            "messages": [
                {
                    "role": "user",
                    "content": content
                }
            ]
        }
    }
    
    try:
        response = requests.post(
            f"{base_url}/request",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"\nStatus Code: {response.status_code}")
        print(f"Response:")
        print(json.dumps(response.json(), indent=2))
        
        return response.status_code, response.json()
    
    except Exception as e:
        print(f"ERROR: {e}")
        return None, None

def test_response_endpoint(base_url: str, test_name: str, content: str):
    """Test the /response endpoint"""
    print(f"\n{'='*60}")
    print(f"TEST: {test_name}")
    print(f"{'='*60}")
    print(f"Content: {content}")
    
    payload = {
        "body": {
            "choices": [
                {
                    "message": {
                        "role": "assistant",
                        "content": content
                    }
                }
            ]
        }
    }
    
    try:
        response = requests.post(
            f"{base_url}/response",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"\nStatus Code: {response.status_code}")
        print(f"Response:")
        print(json.dumps(response.json(), indent=2))
        
        return response.status_code, response.json()
    
    except Exception as e:
        print(f"ERROR: {e}")
        return None, None

def main():
    parser = argparse.ArgumentParser(description='Test Bedrock Guardrails Service')
    parser.add_argument('--url', default='http://127.0.0.1:7273', help='Base URL of the guardrail service')
    args = parser.parse_args()
    
    base_url = args.url.rstrip('/')
    
    print(f"Testing Bedrock Guardrails at: {base_url}")
    print(f"Make sure the service is running with: python bedrock_guardrail.py")
    print(f"\nConfiguration should match your LiteLLM guardrail:")
    print(f"  export BEDROCK_GUARDRAIL_ID=v1qto5owq7gz  # Your guardrailIdentifier")
    print(f"  export BEDROCK_GUARDRAIL_VERSION=DRAFT     # Your guardrailVersion")
    print()
    
    # Test 1: Safe content (should pass)
    test_request_endpoint(
        base_url,
        "Safe Content - Should Pass",
        "What is the weather like today?"
    )
    
    # Test 2: Content with email (PII - should mask or block depending on config)
    test_request_endpoint(
        base_url,
        "Email PII - Should Mask or Block",
        "Please send the report to john.doe@example.com"
    )
    
    # Test 3: Content with SSN (PII - should mask or block)
    test_request_endpoint(
        base_url,
        "SSN PII - Should Mask or Block",
        "My social security number is 123-45-6789"
    )
    
    # Test 4: Content with phone number (PII - should mask or block)
    test_request_endpoint(
        base_url,
        "Phone PII - Should Mask or Block",
        "Call me at 555-123-4567"
    )
    
    # Test 5: Content with credit card (PII - should mask or block)
    test_request_endpoint(
        base_url,
        "Credit Card PII - Should Mask or Block",
        "My credit card is 4532-1234-5678-9010"
    )
    
    # Test 6: Potential harmful content
    test_request_endpoint(
        base_url,
        "Harmful Content - May Block",
        "How can I hack into someone's email account?"
    )
    
    # Test 7: Response with PII
    test_response_endpoint(
        base_url,
        "Response with Email PII - Should Mask or Block",
        "Sure, you can reach me at admin@company.com for assistance."
    )
    
    # Test 8: Safe response
    test_response_endpoint(
        base_url,
        "Safe Response - Should Pass",
        "The weather today is sunny with a high of 75 degrees."
    )
    
    # Test 9: Multiple PII types
    test_request_endpoint(
        base_url,
        "Multiple PII Types - Should Mask or Block",
        "My name is John Doe, email john@example.com, SSN 123-45-6789, phone 555-1234"
    )
    
    print(f"\n{'='*60}")
    print("TESTING COMPLETE")
    print(f"{'='*60}")
    print("\nCheck the guardrail service logs for detailed violation information.")
    print("\nTo test different blocking modes:")
    print("  - export BEDROCK_BLOCKING_MODE=strict   # Block all violations")
    print("  - export BEDROCK_BLOCKING_MODE=balanced # Block serious violations, allow masked PII")
    print("  - export BEDROCK_BLOCKING_MODE=audit    # Log only, never block")
    print("\nNote: Actual behavior depends on your Bedrock Guardrail configuration.")

if __name__ == '__main__':
    main()

