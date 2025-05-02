#!/bin/bash

# Source the environment variables
source ~/bin/ai-keys

# Create the Kubernetes secret
kubectl create secret generic kagent-pinecone -n kagent --from-literal=PINECONE_API_KEY="$PINECONE_API_KEY" --dry-run=client -o yaml | kubectl apply -f -

# Read the YAML file, substitute the environment variable, and apply to Kubernetes
# Escape forward slashes in the host value for sed
ESCAPED_HOST=$(echo "$PINECONE_INDEX_HOST" | sed 's/\//\\\//g')
sed 's/\$PINECONE_INDEX_HOST\$/'$ESCAPED_HOST'/g' kagent-memory-pinecone.yaml | kubectl apply -f -
