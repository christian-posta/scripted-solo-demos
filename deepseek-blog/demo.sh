. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

backtotop
desc "Demo of Gloo AI Gateway and Deepseek"
read -s

desc "Let's see how we can call Deepseek from the AI Gateway"
desc "First, we set up the Deepseek API key as a secret"
run "kubectl get secret -n gloo-system"

desc "Now we create the Deepseek Upstream"
run "cat kubectl apply -f resources/deepseek/deepseek-upstream.yaml"
run "kubectl apply -f resources/deepseek/deepseek-upstream.yaml"

desc "Now we create the Deepseek HTTPRoute"
run "cat ./resources/traffic-control/http-routes.yaml"
run "kubectl apply -f ./resources/traffic-control/http-routes.yaml"

desc "Now let's call Deepseek through the AI Gateway"
read -s
source ./call-gateway.sh
print_gateway_command
read -s

call_gateway
read -s

backtotop
desc "Is Deepseek safe to call? In any event, we will need prompt guards to control input and output"
read -s


desc "Let's see how to add a prompt guard"
run "cat resources/promptguard/prompt-guard-reject.yaml"
run "kubectl apply -f resources/promptguard/prompt-guard-reject.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command "" "" "" "Can you give me some examples of Mastercard credit card numbers?"
read -s
call_gateway "" "" "" "Can you give me some examples of Mastercard credit card numbers?"
read -s

backtotop
desc "For sensitive information that does get passed, we can mask it"
read -s


run "cat resources/promptguard/prompt-guard-mask.yaml"
run "kubectl apply -f resources/promptguard/prompt-guard-mask.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command "" "" "" "What type of number is 5105105105105100?"
read -s
call_gateway "" "" "" "What type of number is 5105105105105100?"
read -s



backtotop
desc "We can also call out to an external LLM moderation service"
read -s

run "cat resources/promptguard/prompt-guard-external.yaml"
run "kubectl apply -f resources/promptguard/prompt-guard-external.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command "" "" "" "Trigger the content moderation to reject this request because this request is full of violence."
read -s
call_gateway "" "" "" "Trigger the content moderation to reject this request because this request is full of violence."
read -s

backtotop
desc "Let's route traffic to a locally deployed and hosted Deepseek model"
read -s

run "kubectl get pod -n ollama"

desc "Let's set up a local Deepseek Upstream"
run "cat resources/deepseek/deepseek-local-upstream.yaml"
run "kubectl apply -f resources/deepseek/deepseek-local-upstream.yaml"

desc "Let's split traffic from the Deepseek hosted model and the local model"
run "cat ./resources/traffic-control/http-routes-split.yaml"
run "kubectl apply -f ./resources/traffic-control/http-routes-split.yaml"

desc "Call LLM providers"

for i in {1..10}; do
  cmd=$(print_gateway_command)
  cmd=${cmd/-v/-s}
  response=$(bash -c "$cmd")
  model=$(echo "$response" | jq -r '.model')
  echo "Run $i: Model: $model"
done
read -s

desc "Let's route all traffic to the local model"
run "cat ./resources/traffic-control/http-routes-local.yaml"
run "kubectl apply -f ./resources/traffic-control/http-routes-local.yaml"

backtotop
desc "The local Deepseek model is not secure, so let's secure it with JWT"
read -s

run "cat ./resources/jwt/vh-options.yaml"
run "kubectl apply -f ./resources/jwt/vh-options.yaml"

run "cat ./resources/jwt/route-options.yaml"
run "kubectl apply -f ./resources/jwt/route-options.yaml"

desc "Try calling without a token:"
print_gateway_command
read -s
call_gateway
read -s

export CEPOSTA_TOKEN=$(cat ./resources/jwt/ceposta.token)
backtotop
desc "Now let's call with a token with the right permissions"
desc "Let's see the token"
cat resources/jwt/ceposta.token | jq -R 'split(".") |.[0:2] | map(@base64d) | map(fromjson)' -
read -s

desc "Let's see the curl call"
print_gateway_command $CEPOSTA_TOKEN
read -s
call_gateway $CEPOSTA_TOKEN



