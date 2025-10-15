

#!/bin/bash

# Script to reset demo by deleting unwanted agents
# Usage: ./reset-demo.sh

set -e

NAMESPACE="kagent"

# Whitelist of agents to keep
WHITELIST=(
    "argo-rollouts-conversion-agent"
    "cilium-debug-agent"
    "cilium-manager-agent"
    "cilium-policy-agent"
    "helm-agent"
    "istio-agent"
    "k8s-agent"
    "kgateway-agent"
    "observability-agent"
    "promql-agent"
)

echo "Resetting demo by cleaning up unwanted agents and MCP servers..."
echo "Getting all agents in namespace $NAMESPACE..."

# Get all agent names
ALL_AGENTS=$(kubectl get agents -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

# Get all MCP server names
ALL_MCPSERVERS=$(kubectl get mcpservers -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

echo "Found agents: $ALL_AGENTS"
echo "Found MCP servers: $ALL_MCPSERVERS"
echo ""

echo "Agents to keep (whitelist):"
for agent in "${WHITELIST[@]}"; do
    echo "  - $agent"
done
echo ""

# Find agents to delete
AGENTS_TO_DELETE=()
for agent in $ALL_AGENTS; do
    # Check if agent is in whitelist
    FOUND=false
    for whitelist_agent in "${WHITELIST[@]}"; do
        if [[ "$agent" == "$whitelist_agent" ]]; then
            FOUND=true
            break
        fi
    done
    
    if [[ "$FOUND" == "false" ]]; then
        AGENTS_TO_DELETE+=("$agent")
    fi
done

# Check if there are MCP servers to delete
MCPSERVERS_TO_DELETE=()
if [[ -n "$ALL_MCPSERVERS" ]]; then
    for mcpserver in $ALL_MCPSERVERS; do
        MCPSERVERS_TO_DELETE+=("$mcpserver")
    done
fi

if [ ${#AGENTS_TO_DELETE[@]} -eq 0 ] && [ ${#MCPSERVERS_TO_DELETE[@]} -eq 0 ]; then
    echo "No agents or MCP servers to delete."
    exit 0
fi

echo "Agents to delete:"
if [ ${#AGENTS_TO_DELETE[@]} -eq 0 ]; then
    echo "  (none)"
else
    for agent in "${AGENTS_TO_DELETE[@]}"; do
        echo "  - $agent"
    done
fi

echo "MCP servers to delete:"
if [ ${#MCPSERVERS_TO_DELETE[@]} -eq 0 ]; then
    echo "  (none)"
else
    for mcpserver in "${MCPSERVERS_TO_DELETE[@]}"; do
        echo "  - $mcpserver"
    done
fi
echo ""

# Confirm deletion
read -p "Are you sure you want to delete these resources? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deletion cancelled."
    exit 0
fi

# Delete the agents
if [ ${#AGENTS_TO_DELETE[@]} -gt 0 ]; then
    echo "Deleting agents..."
    for agent in "${AGENTS_TO_DELETE[@]}"; do
        echo "Deleting agent: $agent"
        kubectl delete agent "$agent" -n $NAMESPACE
    done
fi

# Delete the MCP servers
if [ ${#MCPSERVERS_TO_DELETE[@]} -gt 0 ]; then
    echo "Deleting MCP servers..."
    for mcpserver in "${MCPSERVERS_TO_DELETE[@]}"; do
        echo "Deleting MCP server: $mcpserver"
        kubectl delete mcpserver "$mcpserver" -n $NAMESPACE
    done
fi

echo ""
echo "Demo reset complete!"
echo "Remaining agents:"
kubectl get agents -n $NAMESPACE
echo ""
echo "Remaining MCP servers:"
kubectl get mcpservers -n $NAMESPACE


