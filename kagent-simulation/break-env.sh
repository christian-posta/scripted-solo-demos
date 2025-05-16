#!/bin/bash
set -euo pipefail

# Define a function to log messages with timestamp
log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $1"
}
``
# Check if a YAML file was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <yaml-file>"
    exit 1
fi

YAML_FILE="$1"
echo "YAML_FILE: $YAML_FILE"

# If "random" is specified, pick a random YAML file from scenarios directory
if [ "$YAML_FILE" = "random" ]; then
    SCENARIOS_DIR="./scenarios"
    if [ ! -d "$SCENARIOS_DIR" ]; then
        echo "Error: Scenarios directory not found at $SCENARIOS_DIR"
        exit 1
    fi
    
    # Get list of all YAML files
    YAML_FILES=($SCENARIOS_DIR/*.yaml)
    if [ ${#YAML_FILES[@]} -eq 0 ]; then
        echo "Error: No YAML files found in $SCENARIOS_DIR"
        exit 1
    fi
    
    # Pick a random file
    RANDOM_INDEX=$((RANDOM % ${#YAML_FILES[@]}))
    YAML_FILE="${YAML_FILES[$RANDOM_INDEX]}"
    log "Randomly selected scenario: $YAML_FILE"
fi

# Check if the file exists
if [ ! -f "$YAML_FILE" ]; then
    echo "Error: File $YAML_FILE does not exist"
    exit 1
fi

# Extract metadata from the YAML file
NAME=$(yq eval '.metadata.name' "$YAML_FILE")
DESCRIPTION=$(yq eval '.spec.description' "$YAML_FILE")
USER_PROMPT=$(yq eval '.spec.prompt' "$YAML_FILE")

# Print the challenge information
log "Challenge: $NAME"
log "Description: $DESCRIPTION"

# Extract and print the breaking steps
log "Breaking Steps:"
STEPS_COUNT=$(yq '.spec.steps | length' "$YAML_FILE")
for ((i=0; i<$STEPS_COUNT; i++)); do
    log "Step $((i+1)):"
    yq ".spec.steps[$i].run" "$YAML_FILE"
    log "----------------------------------------"
done

# Execute the breaking steps
log "Executing breaking steps..."
for ((i=0; i<$STEPS_COUNT; i++)); do
    log "Executing step $((i+1))..."
    # Get the entire command block as a single string
    cmd_block=$(yq ".spec.steps[$i].run" "$YAML_FILE")
    if [ ! -z "$cmd_block" ]; then
        log "Running command block:"
        echo "$cmd_block"
        # Execute the entire command block
        eval "$cmd_block"
    fi
done

# Wait for pods to stabilize
log "Waiting for pods to stabilize..."
while kubectl get pods -A 2>/dev/null | grep -E "ContainerCreating|Terminating"; do 
    sleep 5
done

# Show current pod status
log "Current pod status:"
kubectl get pods -A

log "Original Prompt: "
log "----------------------------------------"
log "$USER_PROMPT"
log "----------------------------------------"
