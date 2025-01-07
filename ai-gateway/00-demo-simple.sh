. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD



desc "Let's see the resources needed to route to LLM upstreams"

#################################################################
############# Task 0
#################################################################
run "cat resources/00-basic-passthrough/upstreams.yaml"
run "cat resources/00-basic-passthrough/http-routes.yaml"

run "kubectl apply -f resources/00-basic-passthrough/"

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

OPENAI_API_KEY="KEY-HERE"
desc "Will run the following curl command"
desc "curl https://$GLOO_AI_GATEWAY:8080/v1/chat/completions \
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
curl https://api.openai.com/v1/chat/completions \
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
