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
    
    # Upload model if needed (optional - can be done via CLI)
    # await gateway.upload_authorization_model("authorization-model.json")
    
    # Set up demo data
    print("\nSetting up demo relationships...")
    await gateway.setup_demo_relationships()
    print("Done setting up demo relationships.\n")
    
    # Test access checks
    print("Testing access checks...")
    
    alice_can_use_claude = await gateway.can_access_model("alice", "claude-3-opus")
    print(f"Alice can access Claude 3 Opus: {alice_can_use_claude}")  # Expected: True
    
    alice_can_use_gemini = await gateway.can_access_model("alice", "gemini-pro")
    print(f"Alice can access Gemini Pro: {alice_can_use_gemini}")  # Expected: False
    
    bob_can_use_gpt4 = await gateway.can_access_model("bob", "gpt-4")
    print(f"Bob can access GPT-4: {bob_can_use_gpt4}")  # Expected: True
    
    bob_can_use_claude = await gateway.can_access_model("bob", "claude-3-opus")
    print(f"Bob can access Claude 3 Opus: {bob_can_use_claude}")  # Expected: True (as contributor)
    
    # Test feature access
    print("\nTesting feature access...")
    
    alice_can_access_vision = await gateway.can_access_feature("alice", "vision")
    print(f"Alice can access vision feature: {alice_can_access_vision}")  # Expected: True
    
    alice_can_access_code = await gateway.can_access_feature("alice", "code_generation")
    print(f"Alice can access code_generation feature: {alice_can_access_code}")  # Expected: False
    
    # Test budget constraints
    print("\nTesting budget constraints...")
    
    alice_can_afford_small = await gateway.can_afford_model("alice", "claude-3-opus", 1000)
    print(f"Alice can use 1000 tokens with Claude 3 Opus: {alice_can_afford_small}")  # Expected: True
    
    alice_can_afford_large = await gateway.can_afford_model("alice", "claude-3-opus", 50000)
    print(f"Alice can use 50000 tokens with Claude 3 Opus: {alice_can_afford_large}")  # Expected: False (exceeds budget)
    
    print("\n✅ All tests completed!")


if __name__ == "__main__":
    asyncio.run(main())
