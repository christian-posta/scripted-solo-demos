#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== OpenFGA Setup Script ===${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Start OpenFGA server
echo -e "${YELLOW}Starting OpenFGA server...${NC}"
cd "$(dirname "$0")"
docker-compose up -d

# Wait for server to be ready
echo -e "${YELLOW}Waiting for OpenFGA server to be ready...${NC}"
sleep 5

MAX_RETRIES=30
RETRY_COUNT=0
while ! curl -sf http://localhost:8181/healthz > /dev/null 2>&1; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo -e "${RED}Error: OpenFGA server failed to start${NC}"
        exit 1
    fi
    sleep 1
done

echo -e "${GREEN}OpenFGA server is ready!${NC}"

# Check if FGA CLI is installed
if ! command -v fga &> /dev/null; then
    echo -e "${YELLOW}FGA CLI is not installed.${NC}"
    echo "Please install it from: https://github.com/openfga/cli"
    echo ""
    echo "For macOS:"
    echo "  brew install openfga/tap/fga"
    echo ""
    echo "After installing, run this script again."
    exit 1
fi

echo -e "${YELLOW}Creating OpenFGA store...${NC}"
STORE_RESPONSE=$(fga store create --name "AI Gateway ReBAC" --api-url http://localhost:8181 2>&1)
STORE_ID=$(echo "$STORE_RESPONSE" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -1)

if [ -z "$STORE_ID" ]; then
    echo -e "${RED}Error: Could not extract store ID from response:${NC}"
    echo "$STORE_RESPONSE"
    echo ""
    echo "Please run manually:"
    echo "  fga store create --name 'AI Gateway ReBAC' --api-url http://localhost:8181"
    echo "  (Copy the store ID from the output)"
    exit 1
fi

echo -e "${GREEN}Store created with ID: $STORE_ID${NC}"

echo -e "${YELLOW}Uploading authorization model...${NC}"
MODEL_PATH="$(dirname "$0")/authorization-model.json"

if [ ! -f "$MODEL_PATH" ]; then
    echo -e "${RED}Error: authorization-model.json not found at $MODEL_PATH${NC}"
    exit 1
fi

MODEL_RESPONSE=$(fga model write --store-id "$STORE_ID" --file "$MODEL_PATH" --api-url http://localhost:8181 2>&1)
MODEL_ID=$(echo "$MODEL_RESPONSE" | sed -n 's/.*"authorization_model_id":"\([^"]*\)".*/\1/p' | head -1)

if [ -z "$MODEL_ID" ]; then
    echo -e "${RED}Error: Could not extract model ID from response:${NC}"
    echo "$MODEL_RESPONSE"
    exit 1
fi

echo -e "${GREEN}Authorization model uploaded with ID: $MODEL_ID${NC}"

# Create a Python test runner script
cat > "$(dirname "$0")/run-tests.py" << EOF
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
EOF

chmod +x "$(dirname "$0")/run-tests.py"

# Write environment variables to .env file
ENV_FILE="$(dirname "$0")/.env"
cat > "$ENV_FILE" << EOF
# OpenFGA Configuration
# Generated by setup-openfga.sh on $(date)
export FGA_API_URL=http://localhost:8181
export FGA_STORE_ID=$STORE_ID
export FGA_MODEL_ID=$MODEL_ID
EOF

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Store ID: $STORE_ID"
echo "Model ID: $MODEL_ID"
echo ""
echo "Environment variables saved to: $ENV_FILE"
echo ""
echo "To run tests:"
echo "  source .env && python test-relationships.py"
echo ""
echo "To stop the OpenFGA server:"
echo "  docker-compose down"

