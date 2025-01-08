. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 6  > /dev/null 2>&1

backtotop
desc "Let's see if we can improve call latency by using semantic caching"
read -s
#################################################################
############# Task 6
#################################################################


export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


desc "Try calling the LLM, notice the time it takes to call the LLM in the x-envoy-upstream-service-time header"
print_gateway_command 
read -s
call_gateway 
read -s

backtotop
desc "Let's add caching"
read -s

run "cat resources/06-semantic-cache/route-options.yaml"
run "kubectl apply -f resources/06-semantic-cache/route-options.yaml"

desc "Try calling LLM again, so it wil be cached"
print_gateway_command 
read -s
call_gateway 
read -s

backtotop
desc "Try calling LLM again, notice the cache hit in header x-gloo-semantic-cache"
read -s

call_gateway 
read -s

