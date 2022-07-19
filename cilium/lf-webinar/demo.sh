#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD


run "kubectl apply -f apps/helloworld.yaml"
run "kubectl apply -f apps/sleep.yaml"

tmux split-window -v -d -c $SOURCE_DIR
desc "Try calling helloworld"
read -s

tmux select-pane -t 1
tmux send-keys -t 1 "kubectl exec -it deploy/sleep -- curl helloworld.default:5000/hello" 
#k exec -it deploy/sleep -n sleep2 -- curl helloworld.default:5000/hello
read -s

run "kubectl create ns sleep2"
run "kubectl apply -f apps/sleep.yaml -n sleep2"
desc "Try calling helloworld"
read -s
tmux select-pane -t 1
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl exec -it deploy/sleep -n sleep2 -- curl helloworld.default:5000/hello" 
read -s


backtotop
desc "Check Kubernetes SVC networking"
read -s

NODE_HASH=$(docker ps | grep kind1-control-plane | awk '{ print $ 1}')
run "docker exec -it $NODE_HASH  iptables -t nat -L"

backtotop
desc "Check Kubernetes NetworkPolicy"
read -s
run "cat  resources/nwpolicy.yaml"
run "kubectl apply -f resources/nwpolicy.yaml"

run "kubectl label ns default proj=lf-demo"

# check the call from ns2
desc "Now try call from ns2"
read -s
tmux select-pane -t 1
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl exec -it deploy/sleep -n sleep2 -- curl helloworld.default:5000/hello" 
read -s


# delete the policy
run "kubectl delete -f resources/nwpolicy.yaml"

backtotop
desc "Check Cilium"
read -s

run "kubectl get po -n kube-system"

backtotop
desc "Check Cilium Status and endpoints"
read -s
pod=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
run "kubectl -n kube-system exec -q ${pod} -- cilium status --verbose"
run "kubectl -n kube-system exec -q ${pod} -- cilium bpf lb list"


run "kubectl get ciliumendpoints"
run "kubectl get ciliumendpoints -l app=helloworld"
desc "Check out the Identity section"
run "kubectl get ciliumendpoints -l app=sleep -o jsonpath=\"{.items[].status.identity}\" | jq"

run "kubectl get ciliumidentities"
identity=$(kubectl get ciliumendpoints -l app=sleep -o jsonpath="{.items[].status.identity.id}")
run "kubectl get ciliumidentity $identity -o yaml"


run "cat ./resources/l3-policy.yaml"
run "kubectl apply -f ./resources/l3-policy.yaml"

desc "Now try call from sleep"
read -s
tmux select-pane -t 1
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl exec -it deploy/sleep -- curl helloworld.default:5000/hello" 

backtotop
desc "Check Cilium L7 handling"
read -s

run "cat ./resources/l7-policy.yaml"
run "kubectl apply -f ./resources/l7-policy.yaml"

desc "Try login to the Cilium agent and see what's running when we have an L7 policy!"
read -s
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl exec -it ds/cilium -n kube-system -- bash" 


read -s
desc "Clean up NetworkPolicy for the moment"
run "kubectl delete ciliumnetworkpolicy helloworld-cnp"

backtotop
desc "Check Istio"
read -s

run "istioctl install -y"
run "kubectl get po -n istio-system"
run "kubectl get po -n default"
run "kubectl label ns default istio-injection=enabled"
run "kubectl delete po --all"
run "kubectl get po -n default"


backtotop
desc "Enable mTLS"
read -s
cat "resources/default-peer-authentication.yaml"
run "kubectl apply -f resources/default-peer-authentication.yaml"

desc "Each service now has a cryptographic identity"
read -s
tmux select-pane -t 1
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl exec -it deploy/sleep -c istio-proxy -- openssl s_client -connect helloworld:5000 -showcerts" 

backtotop
desc "Use a service mesh auth policy"
read -s

desc "Take a look at an Istio AuthorizationPolicy"
run "cat resources/helloworld-authpolicy.yaml"

desc "Let's apply it"
run "kubectl apply -f resources/helloworld-authpolicy.yaml"

tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl exec -it deploy/sleep -- curl helloworld.default:5000/hello"

