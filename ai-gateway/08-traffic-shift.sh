. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 8  > /dev/null 2>&1

backtotop
desc "Let's take a look at shifting traffic between providers"
read -s
#################################################################
############# Task 7
#################################################################

desc "As we've seen, we can route traffic to OpenAI"
desc "Let's see if we can route traffic to a locally running LLM"
read -s

run "kubectl get po -n ollama"
run "cat resources/08-provider-traffic-shift/llm-providers.yaml"
run "kubectl apply -f resources/08-provider-traffic-shift/llm-providers.yaml"

run "cat resources/08-provider-traffic-shift/http-routes.yaml"
run "kubectl apply -f resources/08-provider-traffic-shift/http-routes.yaml"

backtotop
desc "Let's test the traffic shifting"
read -s

desc "Call LLM providers"

for i in {1..10}; do
  cmd=$(print_gateway_command)
  cmd=${cmd/-v/-s}
  response=$(bash -c "$cmd")
  model=$(echo "$response" | jq -r '.model')
  echo "Run $i: Model: $model"
done


backtotop
desc "Now let's route all traffic to the local LLM"
read -s

run "kubectl apply -f resources/08-provider-traffic-shift/http-routes-qwen-100.yaml"

for i in {1..10}; do
  cmd=$(print_gateway_command)
  cmd=${cmd/-v/-s}
  response=$(bash -c "$cmd")
  model=$(echo "$response" | jq -r '.model')
  echo "Run $i: Model: $model"
done