. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

source ./call-deepseek.sh

backtotop
desc "Let's route traffic to a locally deployed and hosted Deepseek model"
desc "May be useful to pull up the Deployment resource for the ollama model"
read -s

desc "Let's make sure we have nodes with GPUs"
run "kubectl get nodes \"-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu\""

run "kubectl get pod -n ollama -o wide"

POD=$(kubectl get pods -n gpu-operator -l app=nvidia-driver-daemonset -o jsonpath='{.items[0].metadata.name}')
run "kubectl exec -it $POD -n gpu-operator -- nvidia-smi"

backtotop
desc "Let's set up routing to the local model"
read -s

run "kubectl get po -n gloo-system"

run "cat resources/deepseek/deepseek-local-upstream.yaml"
run "kubectl apply -f resources/deepseek/deepseek-local-upstream.yaml"

desc "Let's route traffic to the local model"
run "cat ./resources/traffic-control/http-routes-local.yaml"
run "kubectl apply -f ./resources/traffic-control/http-routes-local.yaml"

desc "Let's call the model"
print_gateway_command "" "" "" "What is 2 + 2?"
read -s
call_gateway "" "" "" "What is 2 + 2?"
read -s

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
read -s

backtotop
desc "Is Deepseek safe to call? In any event, we will need prompt guards to control input and output"
read -s

desc "Let's see how to add a prompt guard"
run "cat resources/promptguard/prompt-guard-reject.yaml"
run "kubectl apply -f resources/promptguard/prompt-guard-reject.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command $CEPOSTA_TOKEN "" "" "Can you give me some examples of Mastercard credit card numbers?"
read -s
call_gateway $CEPOSTA_TOKEN "" "" "Can you give me some examples of Mastercard credit card numbers?"
read -s

backtotop
desc "For sensitive information that does get passed, we can mask it"
read -s


run "cat resources/promptguard/prompt-guard-mask.yaml"
run "kubectl apply -f resources/promptguard/prompt-guard-mask.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command $CEPOSTA_TOKEN "" "" "What type of number is 5105105105105100?"
read -s
call_gateway $CEPOSTA_TOKEN "" "" "What type of number is 5105105105105100?"
read -s

backtotop
desc "We can also call out to an external LLM moderation service"
read -s

run "cat resources/promptguard/prompt-guard-external.yaml"
run "kubectl apply -f resources/promptguard/prompt-guard-external.yaml"

desc "Try calling the LLM asking for credit card numbers"
print_gateway_command $CEPOSTA_TOKEN "" "" "A person describes planning to harm others at a public event using dangerous weapons. They talk in detail about how they intend to carry out the act, including causing physical harm and destruction."
read -s
call_gateway $CEPOSTA_TOKEN "" "" "A person describes planning to harm others at a public event using dangerous weapons. They talk in detail about how they intend to carry out the act, including causing physical harm and destruction."
read -s
