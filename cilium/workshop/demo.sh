#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD


pod=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')


backtotop
desc "Let's check the status of Cilium"
read -s


run "kubectl -n kube-system exec -q ${pod} -- cilium status --verbose"


backtotop
desc "Check load balancing in Cilium"
read -s


run "kubectl -n bookinfo get svc reviews"
run "kubectl -n bookinfo get pods -l app=reviews -o wide"
run "kubectl -n kube-system exec -q ${pod} -- cilium bpf lb list"


desc "Check the communication between nodes"

run "kubectl get nodes -o wide"
run "kubectl -n kube-system exec -q ${pod} -- cilium bpf tunnel list"


backtotop
desc "Check the Cilium API"
read -s

run "kubectl -n bookinfo scale deploy/details-v1 --replicas=2"
run "kubectl -n bookinfo get ciliumendpoints"
run "kubectl -n bookinfo get ciliumendpoints -l app=productpage -o yaml"

desc "Check out the Identity section"
run "kubectl -n bookinfo get ciliumendpoints -l app=productpage -o jsonpath=\"{.items[].status.identity}\" | jq"


run "kubectl get ciliumidentities"

identity=$(kubectl -n bookinfo get ciliumendpoints -l app=productpage -o jsonpath="{.items[].status.identity.id}")

run "kubectl get ciliumidentity $identity -o yaml"

backtotop
desc "Check Networking Policy (L3)"
read -s

desc "Apply a policy that only product page service can call reviews"
run "cat ./l3-policy.yaml"
run "kubectl apply -f ./l3-policy.yaml"

# Try call reviews from *details*... it shouldn't work
desc "Try call reviews from *details*... it shouldn't work"
pod=$(kubectl -n bookinfo get pods -l app=details -o jsonpath='{.items[0].metadata.name}')
run "kubectl -n bookinfo debug -i -q ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews:9080/reviews/0"

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
node=$(kubectl -n bookinfo get pods -l app=reviews -o jsonpath='{.items[0].spec.nodeName}')
pod=$(kubectl -n kube-system get pods -l k8s-app=cilium -o json | jq -r ".items[] | select(.spec.nodeName==\"${node}\") | .metadata.name" | tail -1)
tmux send-keys -t 1 "kubectl -n kube-system exec -q $pod -- cilium monitor --type drop" C-m

desc "Try run again..."
pod=$(kubectl -n bookinfo get pods -l app=details -o jsonpath='{.items[0].metadata.name}')
run "kubectl -n bookinfo debug -i -q ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews:9080/reviews/0"


backtotop
desc "Check Networking Policy (L7)"
read -s

desc "Note the processes running on the cilium daemon sets..."
read -s
kubectl -n bookinfo get pods -l app=reviews -o json | jq -r '.items[].spec.nodeName' | sort -u | while read node; do
  kubectl -n kube-system get pods -l k8s-app=cilium -o json | jq -r ".items[] | select(.spec.nodeName==\"${node}\") | .metadata.name" | while read pod; do
    kubectl -n kube-system exec -q ${pod} -- ps -ef
  done
done

read -s

desc "Lets update the Networking Policy to use L7 policies"
run "cat ./l7-policy.yaml"
run "kubectl apply -f ./l7-policy.yaml"

desc "Now check what processes are running..."
read -s
kubectl -n bookinfo get pods -l app=reviews -o json | jq -r '.items[].spec.nodeName' | sort -u | while read node; do
  kubectl -n kube-system get pods -l k8s-app=cilium -o json | jq -r ".items[] | select(.spec.nodeName==\"${node}\") | .metadata.name" | while read pod; do
    kubectl -n kube-system exec -q ${pod} -- ps -ef
  done
done

read -s

desc "Try call the reviews service again from details"
pod=$(kubectl -n bookinfo get pods -l app=details -o jsonpath='{.items[0].metadata.name}')
run "kubectl -n bookinfo debug -i -q ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews:9080/reviews/0"
