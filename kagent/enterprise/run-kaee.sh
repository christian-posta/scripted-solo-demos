#!/bin/bash

# Script to run port-forwards in the background with proper cleanup
# Usage: ./run-kaee.sh

set -e

# Array to store background process IDs
PIDS=()

# Function to cleanup background processes
cleanup() {
    echo "Cleaning up port-forward processes..."
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Terminating process $pid"
            kill "$pid"
        fi
    done
    echo "Cleanup complete"
    exit 0
}

# Set up signal handlers for cleanup
trap cleanup SIGINT SIGTERM EXIT

echo "Starting port-forwards..."

# Start port-forward for keycloak-agent-identity
echo "Port-forwarding keycloak-agent-identity:8080..."
kubectl port-forward svc/keycloak-agent-identity 8080 -n default &
PIDS+=($!)

# Start port-forward for kagent-enterprise-ui on port 8090
echo "Port-forwarding kagent-enterprise-ui:8090..."
kubectl port-forward svc/kagent-enterprise-ui 8090:8090 -n kagent &
PIDS+=($!)

# Start port-forward for kagent-enterprise-ui on port 4000
echo "Port-forwarding kagent-enterprise-ui:4000..."
kubectl port-forward svc/kagent-enterprise-ui 4000:80 -n kagent &
PIDS+=($!)

# Wait a moment for the port-forwards to establish
sleep 2

echo "Port-forwards started successfully!"
echo "Services available at:"
echo "  - keycloak-agent-identity: http://localhost:8080"
echo "  - kagent-enterprise-ui: http://localhost:8090"
echo "  - kagent-enterprise-ui: http://localhost:4000"
echo ""
echo "Press Ctrl+C to stop all port-forwards"

# Wait for all background processes
wait
