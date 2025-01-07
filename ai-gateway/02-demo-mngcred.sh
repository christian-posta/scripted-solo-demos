. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


backtotop
desc "Let's see how we can call an LLM with a managed credential"
read -s

#################################################################
############# Task 2
#################################################################

run "cat resources/02-secure-llm-jwt/vh-options.yaml"
run "cat resources/02-secure-llm-jwt/route-options.yaml"

run "kubectl apply -f resources/02-secure-llm-jwt/"

desc "Try calling without a token:"

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

run "curl -v \"$GLOO_AI_GATEWAY:8080/openai\" -H \"Content-Type: application/json\" -d '{
    \"model\": \"gpt-3.5-turbo\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": \"Tell me about Sedona, AZ in 20 words or fewer\"
      }
    ]
  }' | jq"


desc "Now let's call with a token with the right permissions"

export EITAN_TOKEN=$(cat resources/tokens/eitan-openai.token)
cat resources/tokens/eitan-openai.token | jq -R 'split(".") |.[0:2] | map(@base64d) | map(fromjson)' -

read -s

run "curl \"$GLOO_AI_GATEWAY:8080/openai\" -H \"Content-Type: application/json\" -H \"Authorization: Bearer $EITAN_TOKEN\" -d '{
    \"model\": \"gpt-3.5-turbo\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": \"Tell me about Jerome, AZ in 20 words or fewer\"
      }
    ]
  }' | jq"

