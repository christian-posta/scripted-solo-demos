#!/bin/bash

# Script to get an access token from Auth0 using Device Code Flow
# This is the recommended flow for CLI tools and headless environments

# Configuration
AUTH0_DOMAIN="ceposta-solo.auth0.com"
CLIENT_ID="qJkccsQPnBhg2DNoaJ4k9SRFSBud9TKf"
AUDIENCE="https://ceposta-agw.ngrok.io/mcp"
SCOPE="${SCOPE:-openid profile email}"

# Source script.env if it exists (for AUTH0_CLI_CLIENT_SECRET)
if [ -f "$(dirname "$0")/script.env" ]; then
  source "$(dirname "$0")/script.env"
fi

# Device Code endpoint
DEVICE_CODE_URL="https://${AUTH0_DOMAIN}/oauth/device/code"
TOKEN_URL="https://${AUTH0_DOMAIN}/oauth/token"

# Step 1: Request device code
echo "Requesting device code from Auth0..."
DEVICE_RESPONSE=$(curl -s -X POST "${DEVICE_CODE_URL}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${CLIENT_ID}" \
  -d "scope=${SCOPE}" \
  -d "audience=${AUDIENCE}")

# Check if request was successful
if ! echo "$DEVICE_RESPONSE" | grep -q '"device_code"'; then
  echo "Error: Failed to get device code from Auth0" >&2
  echo "Response: $DEVICE_RESPONSE" >&2
  exit 1
fi

# Extract values from response
DEVICE_CODE=$(echo "$DEVICE_RESPONSE" | grep -o '"device_code":"[^"]*' | cut -d'"' -f4)
USER_CODE=$(echo "$DEVICE_RESPONSE" | grep -o '"user_code":"[^"]*' | cut -d'"' -f4)
VERIFICATION_URI=$(echo "$DEVICE_RESPONSE" | grep -o '"verification_uri_complete":"[^"]*' | cut -d'"' -f4)
if [ -z "$VERIFICATION_URI" ]; then
  VERIFICATION_URI=$(echo "$DEVICE_RESPONSE" | grep -o '"verification_uri":"[^"]*' | cut -d'"' -f4)
fi
INTERVAL=$(echo "$DEVICE_RESPONSE" | grep -o '"interval":[0-9]*' | cut -d':' -f2)
EXPIRES_IN=$(echo "$DEVICE_RESPONSE" | grep -o '"expires_in":[0-9]*' | cut -d':' -f2)

# Default interval if not provided
INTERVAL=${INTERVAL:-5}

# Step 2: Display instructions to user
echo ""
echo "=========================================="
echo "Auth0 Device Authorization"
echo "=========================================="
echo ""
echo "Please visit this URL in your browser:"
echo ""
echo "  ${VERIFICATION_URI}"
echo ""
if echo "$VERIFICATION_URI" | grep -q "user_code="; then
  echo "(The code is already included in the URL)"
else
  echo "And enter this code:"
  echo ""
  echo "  ${USER_CODE}"
  echo ""
fi
echo "Waiting for authorization..."
echo "This request will expire in ${EXPIRES_IN} seconds."
echo ""

# Step 3: Poll for token
ELAPSED=0
while [ $ELAPSED -lt $EXPIRES_IN ]; do
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
  
  # Build token request
  TOKEN_REQUEST="grant_type=urn:ietf:params:oauth:grant-type:device_code&device_code=${DEVICE_CODE}&client_id=${CLIENT_ID}"
  
  # Add client secret if available (for confidential clients)
  if [ -n "$AUTH0_CLI_CLIENT_SECRET" ]; then
    TOKEN_REQUEST="${TOKEN_REQUEST}&client_secret=${AUTH0_CLI_CLIENT_SECRET}"
  fi
  
  TOKEN_RESPONSE=$(curl -s -X POST "${TOKEN_URL}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "${TOKEN_REQUEST}")
  
  # Check for access token
  if echo "$TOKEN_RESPONSE" | grep -q '"access_token"'; then
    TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$TOKEN" ]; then
      echo ""
      echo "✓ Authorization successful!"
      echo ""
      echo "$TOKEN"
      exit 0
    fi
  fi
  
  # Check for authorization_pending (normal, keep polling)
  if echo "$TOKEN_RESPONSE" | grep -q '"error":"authorization_pending"'; then
    echo -n "."
    continue
  fi
  
  # Check for slow_down (adjust interval)
  if echo "$TOKEN_RESPONSE" | grep -q '"error":"slow_down"'; then
    INTERVAL=$((INTERVAL + 5))
    echo -n "."
    continue
  fi
  
  # Check for access_denied
  if echo "$TOKEN_RESPONSE" | grep -q '"error":"access_denied"'; then
    echo ""
    echo "Error: Authorization was denied by the user" >&2
    exit 1
  fi
  
  # Check for expired_token
  if echo "$TOKEN_RESPONSE" | grep -q '"error":"expired_token"'; then
    echo ""
    echo "Error: The device code has expired" >&2
    exit 1
  fi
  
  # Any other error
  if echo "$TOKEN_RESPONSE" | grep -q '"error"'; then
    echo ""
    echo "Error: Failed to get access token" >&2
    echo "Response: $TOKEN_RESPONSE" >&2
    exit 1
  fi
done

echo ""
echo "Error: Timeout waiting for authorization" >&2
exit 1

