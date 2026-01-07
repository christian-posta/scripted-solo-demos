#!/bin/bash

# Script to update AWS Bedrock credentials from assume-role output
# Usage:
#   Option 1: Pipe the assume-role output to this script
#     aws sts assume-role ... | ./update-bedrock-credentials.sh
#   Option 2: Run the assume-role command directly
#     ./update-bedrock-credentials.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
EXAMPLE_ENV_FILE="${SCRIPT_DIR}/example.env"

# Function to read credentials from stdin or run assume-role command
get_credentials() {
    if [ -t 0 ]; then
        # No input piped, run the assume-role command
        echo "Running aws sts assume-role..." >&2
        aws sts assume-role \
            --profile default \
            --role-arn arn:aws:iam::606469916935:role/bedrock-agentgateway-role \
            --role-session-name agentgateway-lab \
            --duration-seconds 3600 \
            --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
            --output text
    else
        # Read from stdin
        cat
    fi
}

# Read credentials (from stdin or command)
CREDENTIALS=$(get_credentials)

# Parse the three values (tab-separated)
read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< "$CREDENTIALS"

# Validate we got all three values
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "Error: Failed to parse credentials. Expected 3 tab-separated values." >&2
    echo "Got: $CREDENTIALS" >&2
    exit 1
fi

echo "Parsed credentials:" >&2
echo "  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:0:10}..." >&2
echo "  AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:0:10}..." >&2
echo "  AWS_SESSION_TOKEN: ${AWS_SESSION_TOKEN:0:20}..." >&2

# Create .env file from example.env if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating .env file from example.env..." >&2
    cp "$EXAMPLE_ENV_FILE" "$ENV_FILE"
fi

# Update the AWS credentials in .env file
echo "Updating .env file..." >&2

# Use sed to update the values, or append if they don't exist
if grep -q "^AWS_ACCESS_KEY_ID=" "$ENV_FILE"; then
    sed -i.bak "s|^AWS_ACCESS_KEY_ID=.*|AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\"|" "$ENV_FILE"
else
    echo "AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\"" >> "$ENV_FILE"
fi

if grep -q "^AWS_SECRET_ACCESS_KEY=" "$ENV_FILE"; then
    sed -i.bak "s|^AWS_SECRET_ACCESS_KEY=.*|AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\"|" "$ENV_FILE"
else
    echo "AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\"" >> "$ENV_FILE"
fi

if grep -q "^AWS_SESSION_TOKEN=" "$ENV_FILE"; then
    sed -i.bak "s|^AWS_SESSION_TOKEN=.*|AWS_SESSION_TOKEN=\"$AWS_SESSION_TOKEN\"|" "$ENV_FILE"
else
    echo "AWS_SESSION_TOKEN=\"$AWS_SESSION_TOKEN\"" >> "$ENV_FILE"
fi

# Clean up backup file (macOS creates .bak)
rm -f "${ENV_FILE}.bak"

echo "Updated .env file successfully" >&2

# Source the .env file and rebuild the Kubernetes secret
echo "Rebuilding Kubernetes secret..." >&2
cd "$SCRIPT_DIR"
source .env

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: bedrock-secret
  namespace: enterprise-agentgateway
type: Opaque
stringData:
  accessKey: ${AWS_ACCESS_KEY_ID}
  secretKey: ${AWS_SECRET_ACCESS_KEY}
  sessionToken: ${AWS_SESSION_TOKEN}
EOF

echo "Successfully updated bedrock-secret in Kubernetes!" >&2
