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
    print("Setting up V3 demo relationships...")
    await gateway.setup_demo_relationships_v3()
    print("Done!\n")
    
    # Test access checks
    print("Testing V3 authorization model...")
    print("=" * 70)
    
    # Test 1: Alice (member of acme-eng) should have access to gpt4o via org entitlement
    print("\n[Test 1] Alice can access gpt4o (via org:acme → provider:openai)")
    alice_can_use_gpt4o = await gateway.can_access_model("alice", "gpt4o")
    print(f"  Result: {alice_can_use_gpt4o}")
    assert alice_can_use_gpt4o == True, "Expected Alice to have access to gpt4o via org entitlement"
    print("  ✅ PASS")
    
    # Test 2: Bob (member of acme-ml) should have access to gpt4o via org entitlement
    print("\n[Test 2] Bob can access gpt4o (via org:acme → provider:openai)")
    bob_can_use_gpt4o = await gateway.can_access_model("bob", "gpt4o")
    print(f"  Result: {bob_can_use_gpt4o}")
    assert bob_can_use_gpt4o == True, "Expected Bob to have access to gpt4o via org entitlement"
    print("  ✅ PASS")
    
    # Test 3: Bob (member of acme-ml) should have access to claude-35 via team allowlist
    print("\n[Test 3] Bob can access claude-35 (via team:acme-ml allowlist)")
    bob_can_use_claude = await gateway.can_access_model("bob", "claude-35")
    print(f"  Result: {bob_can_use_claude}")
    assert bob_can_use_claude == True, "Expected Bob to have access to claude-35 via team allowlist"
    print("  ✅ PASS")
    
    # Test 4: Alice (member of acme-eng) should NOT have access to claude-35
    print("\n[Test 4] Alice cannot access claude-35 (not on allowlist)")
    alice_can_use_claude = await gateway.can_access_model("alice", "claude-35")
    print(f"  Result: {alice_can_use_claude}")
    assert alice_can_use_claude == False, "Expected Alice NOT to have access to claude-35"
    print("  ✅ PASS")
    
    # Test 5: Erin has direct access to gpt4o
    print("\n[Test 5] Erin can access gpt4o (direct grant)")
    erin_can_use_gpt4o = await gateway.can_access_model("erin", "gpt4o")
    print(f"  Result: {erin_can_use_gpt4o}")
    assert erin_can_use_gpt4o == True, "Expected Erin to have direct access to gpt4o"
    print("  ✅ PASS")
    
    # Test 6: Dave can access gpt4o via provider:openai extra_can_use
    # Note: Dave has extra_can_use on provider:openai, which grants access to all models from that provider
    print("\n[Test 6] Dave can access gpt4o (via provider:openai extra_can_use)")
    dave_can_use_gpt4o = await gateway.can_access_model("dave", "gpt4o")
    print(f"  Result: {dave_can_use_gpt4o}")
    assert dave_can_use_gpt4o == True, "Expected Dave to have access to gpt4o via provider extra_can_use"
    print("  ✅ PASS")
    
    # Test 7: Dave should NOT have org-level provider access (only extra_can_use)
    print("\n[Test 7] Dave cannot use provider:openai via can_use (no org membership)")
    dave_can_use_openai = await gateway.can_access_provider("dave", "openai")
    print(f"  Result: {dave_can_use_openai}")
    assert dave_can_use_openai == False, "Expected Dave NOT to have provider-level can_use (only extra_can_use)"
    print("  ✅ PASS")
    
    # Test 8: Random user should NOT have access to gpt4o
    print("\n[Test 8] Charlie cannot access gpt4o (no permissions)")
    charlie_can_use_gpt4o = await gateway.can_access_model("charlie", "gpt4o")
    print(f"  Result: {charlie_can_use_gpt4o}")
    assert charlie_can_use_gpt4o == False, "Expected Charlie NOT to have access to gpt4o"
    print("  ✅ PASS")
    
    print("\n" + "=" * 70)
    print("✅ All V3 authorization tests passed!")
    
    # Clean up
    await gateway.close()


# Run the demo
if __name__ == "__main__":
    asyncio.run(demo())
