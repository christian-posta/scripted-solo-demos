import asyncio
import os
from relationships import AIGatewayReBAC


async def demo():
    # Configuration - read from environment variables set by setup-openfga.sh
    API_URL = os.getenv("FGA_API_URL", "http://localhost:8181")
    STORE_ID = os.getenv("FGA_STORE_ID")
    MODEL_ID = os.getenv("FGA_MODEL_ID")
    
    if not STORE_ID or not MODEL_ID:
        print("❌ Error: FGA_STORE_ID and FGA_MODEL_ID environment variables must be set")
        print("Please run: source .env")
        print("Or run: ./setup-openfga.sh")
        return
    
    # Initialize the gateway with your OpenFGA details
    gateway = AIGatewayReBAC(
        api_url=API_URL,
        store_id=STORE_ID,
        model_id=MODEL_ID
    )
    
    # Set up demo data
    print("Setting up demo relationships...")
    await gateway.setup_demo_relationships()
    print("Done!\n")
    
    # Test access checks
    print("Testing access checks...")
    print("-" * 50)
    
    # Test 1: Alice has direct access to claude-3-opus
    alice_can_use_claude = await gateway.can_access_model("alice", "claude-3-opus")
    print(f"✅ Alice can access Claude 3 Opus: {alice_can_use_claude}")
    assert alice_can_use_claude == True, "Expected Alice to have access to Claude 3 Opus"
    
    # Test 2: Alice has direct access to gpt-4
    alice_can_use_gpt4 = await gateway.can_access_model("alice", "gpt-4")
    print(f"✅ Alice can access GPT-4: {alice_can_use_gpt4}")
    assert alice_can_use_gpt4 == True, "Expected Alice to have access to GPT-4"
    
    # Test 3: Alice should NOT have access to gemini-pro (no permission set)
    alice_can_use_gemini = await gateway.can_access_model("alice", "gemini-pro")
    print(f"❌ Alice can access Gemini Pro: {alice_can_use_gemini}")
    assert alice_can_use_gemini == False, "Expected Alice NOT to have access to Gemini Pro"
    
    # Test 4: Bob has direct access to gpt-4
    bob_can_use_gpt4 = await gateway.can_access_model("bob", "gpt-4")
    print(f"✅ Bob can access GPT-4: {bob_can_use_gpt4}")
    assert bob_can_use_gpt4 == True, "Expected Bob to have access to GPT-4"
    
    # Test 5: Bob should have access to claude-3-opus through team membership
    # (bob is member of dev_team, but we haven't given dev_team access to claude-3-opus)
    bob_can_use_claude = await gateway.can_access_model("bob", "claude-3-opus")
    print(f"❌ Bob can access Claude 3 Opus: {bob_can_use_claude}")
    assert bob_can_use_claude == False, "Expected Bob NOT to have access to Claude 3 Opus"
    
    # Test 6: Bob should have access to gemini-pro through team membership
    # (gemini-pro is available to team:dev_team)
    bob_can_use_gemini = await gateway.can_access_model("bob", "gemini-pro")
    print(f"✅ Bob can access Gemini Pro: {bob_can_use_gemini}")
    assert bob_can_use_gemini == True, "Expected Bob to have access to Gemini Pro via team"
    
    print("\n" + "=" * 50)
    print("✅ All tests passed!")
    
    # Clean up
    await gateway.close()


# Run the demo
if __name__ == "__main__":
    asyncio.run(demo())
