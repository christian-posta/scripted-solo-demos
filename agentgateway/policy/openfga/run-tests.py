import asyncio
import sys
import os

# Add the current directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from relationships import AIGatewayReBAC


async def main():
    # Get store and model IDs from environment or command line
    api_url = os.getenv("FGA_API_URL", "http://localhost:8181")
    store_id = sys.argv[1] if len(sys.argv) > 1 else os.getenv("FGA_STORE_ID", "")
    model_id = sys.argv[2] if len(sys.argv) > 2 else os.getenv("FGA_MODEL_ID", "")
    
    if not store_id or not model_id:
        print("Usage: python run-tests.py <STORE_ID> <MODEL_ID>")
        print("Or set environment variables: FGA_STORE_ID, FGA_MODEL_ID")
        sys.exit(1)
    
    print(f"Connecting to OpenFGA at {api_url}")
    print(f"Store ID: {store_id}")
    print(f"Model ID: {model_id}")
    
    # Initialize the gateway
    gateway = AIGatewayReBAC(
        api_url=api_url,
        store_id=store_id,
        model_id=model_id
    )
    
    # Set up demo data for V3 model
    print("\nSetting up V3 demo relationships...")
    await gateway.setup_demo_relationships_v3()
    print("Done setting up demo relationships.\n")
    
    # Test access checks for V3 model
    print("Testing V3 authorization model...")
    print("=" * 70)
    
    # Test org-level provider entitlement
    print("\n[Test 1] Alice can access gpt4o (via org:acme → provider:openai)")
    alice_can_use_gpt4o = await gateway.can_access_model("alice", "gpt4o")
    print(f"  Result: {alice_can_use_gpt4o}")  # Expected: True
    
    print("\n[Test 2] Bob can access gpt4o (via org:acme → provider:openai)")
    bob_can_use_gpt4o = await gateway.can_access_model("bob", "gpt4o")
    print(f"  Result: {bob_can_use_gpt4o}")  # Expected: True
    
    # Test team-level model allowlist
    print("\n[Test 3] Bob can access claude-35 (via team:acme-ml allowlist)")
    bob_can_use_claude = await gateway.can_access_model("bob", "claude-35")
    print(f"  Result: {bob_can_use_claude}")  # Expected: True
    
    print("\n[Test 4] Alice cannot access claude-35 (not on allowlist)")
    alice_can_use_claude = await gateway.can_access_model("alice", "claude-35")
    print(f"  Result: {alice_can_use_claude}")  # Expected: False
    
    # Test direct model grant
    print("\n[Test 5] Erin can access gpt4o (direct grant)")
    erin_can_use_gpt4o = await gateway.can_access_model("erin", "gpt4o")
    print(f"  Result: {erin_can_use_gpt4o}")  # Expected: True
    
    # Test provider-level extra_can_use via model access
    print("\n[Test 6] Dave can access gpt4o (via provider:openai extra_can_use)")
    dave_can_use_gpt4o = await gateway.can_access_model("dave", "gpt4o")
    print(f"  Result: {dave_can_use_gpt4o}")  # Expected: True
    
    print("\n[Test 7] Dave cannot use provider:openai via can_use (no org membership)")
    dave_can_use_openai = await gateway.can_access_provider("dave", "openai")
    print(f"  Result: {dave_can_use_openai}")  # Expected: False
    
    print("\n[Test 8] Charlie cannot access gpt4o (no permissions)")
    charlie_can_use_gpt4o = await gateway.can_access_model("charlie", "gpt4o")
    print(f"  Result: {charlie_can_use_gpt4o}")  # Expected: False
    
    print("\n" + "=" * 70)
    print("\n✅ All V3 authorization tests completed!")
    
    # Clean up
    await gateway.close()


if __name__ == "__main__":
    asyncio.run(main())
