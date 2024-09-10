#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD



backtotop
desc "-----====Demo AI Gateway ====-----"
read -s

kubectl delete gateway http -n gloo-system > /dev/null 2>&1

desc "Let's update the gateway to use AI extensions"
run "kubectl apply -f resources/egress/ai-gateway-extensions.yaml"
run "kubectl get po -n gloo-system"

desc "Let's define some backend LLMs"
run "cat resources/egress/llm-providers.yaml" 
run "kubectl apply -f resources/egress/llm-providers.yaml"

desc "Let's specify some routes"
run "cat resources/egress/http-routes.yaml"
run "kubectl apply -f resources/egress/http-routes.yaml"


desc "Let's call the AI LLMs without providing a key and let the GW inject it"
run "cat ./call-ai-gateway.sh"
run "./call-ai-gateway.sh"





exit

# calling directly

curl "https://api.openai.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
        "model": "gpt-3.5-turbo",
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant."
            },
            {
                "role": "user",
                "content": "Write a haiku that explains the concept of recursion."
            }
        ]
    }'




