Test out the openai endpoint:

export INGRESS_GW_ADDRESS=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")
echo "AI Gateway endpoint: $INGRESS_GW_ADDRESS"

curl "$INGRESS_GW_ADDRESS:8080/openai" -H content-type:application/json  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
    },
    {
      "role": "user",
      "content": "Compose a poem that explains the concept of recursion in programming."
    }
  ]
}' | jq



Test out the NIM endpoint:

curl -X 'POST' \
    "$INGRESS_GW_ADDRESS:8080/nim" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
  "messages": [
    {
      "content": "You are a polite and respectful chatbot helping people plan a vacation.",
      "role": "system"
    },
    {
      "content": "What should I do for a 4 day vacation in Spain?",
      "role": "user"
    }
  ],
  "model": "meta/llama-3.1-8b-instruct",
  "max_tokens": 4096,
  "top_p": 1,
  "n": 1,
  "stream": false,
  "stop": "\n",
  "frequency_penalty": 0.0
}' | jq

## Test combined
curl "$INGRESS_GW_ADDRESS:8080/openai" -H content-type:application/json -H 'accept: application/json' \
 -d '{
  "messages": [
    {
      "role": "system",
      "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
    },
    {
      "role": "user",
      "content": "Compose a poem that explains the concept of recursion in programming."
    }
  ]
}' | jq
