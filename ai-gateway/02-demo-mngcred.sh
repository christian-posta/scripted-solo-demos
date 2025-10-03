. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


## Prerequisites / Clean up
# We want this in the same state as the previous demo
source ./call-gateway.sh
./reset-demo.sh --for 2 > /dev/null 2>&1



backtotop
desc "Let's see how we can call an LLM with a managed credential"
read -s

#################################################################
############# Task 2
#################################################################

run "cat resources/02-secure-llm-jwt/gloo-traffic-policy.yaml"


run "kubectl apply -f resources/02-secure-llm-jwt/"



desc "Try calling without a token:"
print_gateway_command
read -s
call_gateway
read -s


export CEPOSTA_TOKEN=$(cat resources/tokens/alice.token)
backtotop
desc "Now let's call with a token with the right permissions"
desc "Let's see the token"
cat resources/tokens/alice.token | jq -R 'split(".") |.[0:2] | map(@base64d) | map(fromjson)' -
read -s

desc "Let's see the curl call"
print_gateway_command $CEPOSTA_TOKEN
read -s
call_gateway $CEPOSTA_TOKEN

