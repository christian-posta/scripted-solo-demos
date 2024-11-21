source ./env.sh
# consider updating to newer Gateway CRDs
export INGRESS_GW_ADDRESS1=$(kubectl --context $CLUSTER1 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

curl -X 'POST' \
    "$INGRESS_GW_ADDRESS1:8080/nim" \
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