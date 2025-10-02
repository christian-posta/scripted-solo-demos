. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


## Prerequisites / Clean up
./reset-demo.sh --for 0  > /dev/null 2>&1


desc "Let's see the resources needed to route to LLM backends"

#################################################################
############# Task 0
#################################################################
run "cat resources/00-basic-passthrough/backends.yaml"
run "cat resources/00-basic-passthrough/http-routes.yaml"

run "kubectl apply -f resources/00-basic-passthrough/"

PORT=8080
export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):$PORT


if [[ -z "$GLOO_AI_GATEWAY" || "$GLOO_AI_GATEWAY" == ":$PORT" ]]; then
  echo "Could not determine GLOO_AI_GATEWAY IP automatically."
  read -p "Please enter the external IP or hostname for gloo-proxy-ai-gateway: " GLOO_AI_GATEWAY
  export GLOO_AI_GATEWAY
fi

OPENAI_API_KEY="KEY-HERE"
desc "Will run the following curl command"
desc "curl $GLOO_AI_GATEWAY/v1/chat/completions \
  -H \"Content-Type: application/json\" \
  -H \"Authorization: Bearer $OPENAI_API_KEY\" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "user",
        "content": "Hello! How are you?"
      }
    ]
  }'"
read -s
source ~/bin/ai-keys
echo "Calling $GLOO_AI_GATEWAY"
curl $GLOO_AI_GATEWAY/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "user",
        "content": "Hello! How are you?"
      }
    ]
  }'
