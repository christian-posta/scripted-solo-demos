. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 5  > /dev/null 2>&1

backtotop
desc "We can also call out to our own Presidio guardrail service"
desc "Make sure the presidio service is running"
read -s

run "cat resources/base/05-prompt-guard/prompt-guard-presidio-local.yaml"
run "kubectl apply -f resources/base/05-prompt-guard/prompt-guard-presidio-local.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command "" "" "" "" "What type of number is 5105-1051-0510-5100" "mask"
read -s
call_gateway "" "" "" "" "What type of number is 5105-1051-0510-5100" "mask"
read -s
