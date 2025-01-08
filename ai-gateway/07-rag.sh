. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 7  > /dev/null 2>&1

backtotop
desc "Let's see if we can improve prompt performance by using RAG"
read -s
#################################################################
############# Task 7
#################################################################


desc "Try calling the LLM without RAG"
print_gateway_command "" "" "" "" "How many varieties of cheese are in France?"
read -s
call_gateway "" "" "" "" "How many varieties of cheese are in France?"
read -s



backtotop
desc "Let's add RAG"
read -s

run "cat resources/07-rag/route-options.yaml"
run "kubectl apply -f resources/07-rag/route-options.yaml"

desc "Try calling LLM again, so it wil be cached"
print_gateway_command "" "" "" "" "How many varieties of cheese are in France?"
read -s
call_gateway "" "" "" "" "How many varieties of cheese are in France?"
