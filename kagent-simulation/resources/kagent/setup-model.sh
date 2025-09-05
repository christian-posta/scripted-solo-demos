#!/bin/bash

# Source the environment variables
source ~/bin/ai-keys

kubectl create secret generic gemini-gemini-2-5-flash \
  --from-literal=GEMINI_API_KEY=$GEMINI_API_KEY \
  -n kagent


kubectl apply -f gemini.yaml