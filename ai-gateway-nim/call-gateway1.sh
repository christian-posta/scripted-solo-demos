source ./env.sh
# consider updating to newer Gateway CRDs
export INGRESS_GW_ADDRESS1=$(kubectl --context $CLUSTER1 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

curl -v "$INGRESS_GW_ADDRESS1:8080/openai" -H content-type:application/json  -d '{
  "model": "gpt-3.5-turbo",
  "max_tokens": 4096,
  "top_p": 1,
  "n": 1,
  "stream": false,
  "stop": "\n",
  "frequency_penalty": 0.0,  
  "messages": [
    {
      "role": "system",
      "content": "You are a polite and respectful chatbot helping people plan a vacation"
    },
    {
      "role": "user",
      "content": "What should I do for a 4 day vacation in Spain?"
    }
  ]
}' | jq


