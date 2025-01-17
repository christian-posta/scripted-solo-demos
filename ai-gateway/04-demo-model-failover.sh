. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 4  > /dev/null 2>&1

backtotop
desc "Let's see how a model failover works"
read -s
#################################################################
############# Task 4
#################################################################


export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

desc "Let's see a model that's been deployed that will cause 429 errors"
run "kubectl get po -n gloo-system -l app=model-failover"

desc "Let's see how to speficy failover models"
run "cat resources/04-model-failover/llm-providers.yaml"

desc "Let's see how we handle 429s and retries"
run "cat resources/04-model-failover/route-options.yaml"

desc "Let's see how we specify the routes"
run "cat resources/04-model-failover/http-routes.yaml"

desc "Let's apply these resources"
run "kubectl apply -f resources/04-model-failover/"


desc "Try calling the LLM with model set to gpt-4o"
print_gateway_command "" "gpt-4o"
read -s
call_gateway "" "gpt-4o"
read -s

backtotop
desc "Let's see the logs of the model-failover pod"
read -s

run "kubectl logs deploy/model-failover -n gloo-system"

desc "Let's look closer at the last two lines"
run "kubectl logs deploy/model-failover -n gloo-system | tail -n 2 | jq '.msg | fromjson' | jq '.'"
