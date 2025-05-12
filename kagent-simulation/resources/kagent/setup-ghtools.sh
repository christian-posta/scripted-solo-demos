#!/bin/bash

# Source the environment variables
source ~/bin/ai-keys



# Read the YAML file, substitute the environment variable, and apply to Kubernetes
# Escape forward slashes in the host value for sed

sed 's/\$GH_PAT\$/'$GITHUB_AIRE_PAT'/g' toolserver.yaml | kubectl apply -f -
#sed 's/\$GH_PAT\$/'$GITHUB_AIRE_PAT'/g' toolserver.yaml 