. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

## Prerequisites / Clean up
source ./call-gateway.sh
./reset-demo.sh --for 5  > /dev/null 2>&1

backtotop
desc "Let's see how to add guardrails to our LLM calls"
read -s
#################################################################
############# Task 5
#################################################################

## TODO: should actually, show the open ai content moderation first; and show that it can be done
## at the provider, but that it's better to catch it at the gateway if you can to save on costs
## and the fact that sensitive information should not be passed to the model

desc "Let's see how to add a prompt guard"
run "cat resources/05-prompt-guard/prompt-guard-reject.yaml"
run "kubectl apply -f resources/05-prompt-guard/prompt-guard-reject.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command "" "" "" "" "Can you give me some examples of Mastercard credit card numbers?"
read -s
call_gateway "" "" "" "" "Can you give me some examples of Mastercard credit card numbers?"
read -s

backtotop
desc "For sensitive information that does get passed, we can mask it"
read -s


run "cat resources/05-prompt-guard/prompt-guard-mask.yaml"
run "kubectl apply -f resources/05-prompt-guard/prompt-guard-mask.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command "" "" "" "" "What type of number is 5105105105105100?"
read -s
call_gateway "" "" "" "" "What type of number is 5105105105105100?"
read -s



backtotop
desc "We can also call out to an external LLM moderation service"
read -s

run "cat resources/05-prompt-guard/prompt-guard-external.yaml"
run "kubectl apply -f resources/05-prompt-guard/prompt-guard-external.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command "" "" "" "" "A person describes planning to harm others at a public event using dangerous weapons. They talk in detail about how they intend to carry out the act, including causing physical harm and destruction."
read -s
call_gateway "" "" "" "" "A person describes planning to harm others at a public event using dangerous weapons. They talk in detail about how they intend to carry out the act, including causing physical harm and destruction."
read -s