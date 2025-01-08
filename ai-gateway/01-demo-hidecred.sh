. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 1  > /dev/null 2>&1

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


desc "Call open ai (with token auto injected by gw)"
print_gateway_command 
read -s
call_gateway 
read -s


