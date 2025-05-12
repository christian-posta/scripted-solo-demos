#!/bin/bash

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Clone the repository
git clone git@github.com:christian-posta/aire-sample-apps.git "$TEMP_DIR"
cd "$TEMP_DIR"

# Configure git user (required for commits)
git config user.email "script@example.com"
git config user.name "EnvBreaker007"

# Make sure we're on main
git checkout main

# Reset main to the clean-version tag
git reset --hard clean-version

# Force push the changes to main
git push -f origin main

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"
echo "Cleanup complete"

# Restart the frontend-v1 deployment


