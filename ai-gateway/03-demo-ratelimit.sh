. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

backtotop
desc "Let's see how we can implement rate limiting based on prompt tokens"
read -s
#################################################################
############# Task 3
#################################################################


export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


desc "Let's create a token rate limit (70 per hour) based on user id"

run "cat resources/03-ratelimit-token-usage/ratelimit-user.yaml"
run "cat resources/03-ratelimit-token-usage/openai-route-ratelimit.yaml"

run "kubectl apply -f resources/03-ratelimit-token-usage/"

export EITAN_TOKEN=$(cat resources/tokens/eitan-openai.token)
run "curl \"$GLOO_AI_GATEWAY:8080/openai\" -H \"Content-Type: application/json\" -H \"Authorization: Bearer $EITAN_TOKEN\" -d '{
    \"model\": \"gpt-3.5-turbo\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": \"Tell me about Flagstaff, AZ which is a city in Arizona, with -- believe it or not, a ski resort. \"
      }
    ]
  }' | jq"

desc "This first request goes through, but subsequent will fail"
run "curl -v \"$GLOO_AI_GATEWAY:8080/openai\" -H \"Content-Type: application/json\" -H \"Authorization: Bearer $EITAN_TOKEN\" -d '{
    \"model\": \"gpt-3.5-turbo\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": \"Tell me about Williams, AZ \"
      }
    ]
  }' | jq"

