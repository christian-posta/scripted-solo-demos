#!/bin/bash

# Script to get an access token from Keycloak using Resource Owner Password Credentials Grant (ROPC)

# Configuration
KEYCLOAK_HOST="${KEYCLOAK_HOST:-localhost:8080}"
REALM="mcp-realm"
CLIENT_ID="openweb-ui"
CLIENT_SECRET="changeme"
USERNAME="mcp-user"
PASSWORD="user123"

# Token endpoint URL
TOKEN_URL="http://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token"

# Make the request using curl
RESPONSE=$(curl -s -X POST "${TOKEN_URL}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "username=${USERNAME}" \
  -d "password=${PASSWORD}")

# Check if the request was successful and extract the token
if echo "$RESPONSE" | grep -q '"access_token"'; then
  # Extract just the access token value
  TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
  
  if [ -n "$TOKEN" ]; then
    echo "$TOKEN"
    exit 0
  else
    echo "Error: Failed to extract access token from response" >&2
    echo "Response: $RESPONSE" >&2
    exit 1
  fi
else
  echo "Error: Failed to get access token from Keycloak" >&2
  echo "Response: $RESPONSE" >&2
  exit 1
fi

