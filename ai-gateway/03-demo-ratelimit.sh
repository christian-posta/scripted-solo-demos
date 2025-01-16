. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 3 > /dev/null 2>&1

backtotop
desc "Let's see how we can implement rate limiting based on prompt tokens"
read -s
#################################################################
############# Task 3
#################################################################


desc "Let's create a token rate limit (50 per hour) based on user id"

run "cat resources/03-ratelimit-token-usage/ratelimit-user.yaml"
run "cat resources/03-ratelimit-token-usage/openai-route-ratelimit.yaml"

run "kubectl apply -f resources/03-ratelimit-token-usage/"

export CEPOSTA_TOKEN=$(cat resources/tokens/ceposta-openai.token)
desc "This first call should go through"
print_gateway_command $CEPOSTA_TOKEN
read -s
call_gateway $CEPOSTA_TOKEN
read -s

desc "This second call should fail"
print_gateway_command $CEPOSTA_TOKEN
read -s
call_gateway $CEPOSTA_TOKEN

