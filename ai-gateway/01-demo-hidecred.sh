. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


backtotop
desc "Let's see how we can remove sensitive API keys from the call"
read -s
#################################################################
############# Task 1
#################################################################

run "cat resources/01-call-llm/llm-providers.yaml"
run "cat resources/01-call-llm/http-routes.yaml"

desc "Let's apply these resources"
run "kubectl apply -f resources/01-call-llm/"

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


desc "Call open ai (with token auto injected by gw)"
run "curl -v \"$GLOO_AI_GATEWAY:8080/openai\" -H \"Content-Type: application/json\" -d '{
    \"model\": \"gpt-3.5-turbo\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": \"Tell me about Sedona, AZ in 20 words or fewer\"
      }
    ]
  }' | jq"


