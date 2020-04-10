#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh


desc "Now that we've got our mesh federated, let's take a look at the networking"
read -s
desc "Show some of the underlying Istio objects automatically created"
run "kubectl get serviceentry -A --context $CLUSTER_1"
run "kubectl get serviceentry -A --context $CLUSTER_2"
run "kubectl get serviceentry reviews.default.cluster-2 -o yaml -n istio-system  --context $CLUSTER_1"

run "kubectl get svc istio-ingressgateway -n istio-system  --context $CLUSTER_2"

desc "We've also created a destination rule to set ISTIO_MUTUAL tls"
run "kubectl get dr reviews.default.cluster-2 -n istio-system -o yaml --context $CLUSTER_1"

backtotop
desc "Let's port forward the productpage app so we can call it"
read -s

desc "Let's port-forward the bookinfo demo so we can see its behavior"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl port-forward deployments/productpage-v1 9080" C-m

# wait 
desc "Go to product page in browser http://localhost:9080"
read -s

backtotop
desc "Now let's route reviews traffic to balance between cluster 1 and 2"
read -s

run "cat resources/cross-cluster-traffic-policy.yaml"
run "kubectl apply -f resources/cross-cluster-traffic-policy.yaml"
run "kubectl get virtualservice -A"
run "kubectl get virtualservice -A -o yaml"

desc "Go check the browser before we clean up"
read -s

backtotop
desc "It's possible we end up with traffic rules cross cluster that make it difficult to understand"
read -s
desc "We can use meshctl describe to get the rules for a particular service"
run "meshctl describe --help"

backtotop
desc "Let's see what rules are on the reviews service"
run "meshctl describe service reviews.default.cluster-1"


desc "Now time to clean up"
read -s
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m

desc "Proceed further to reset this demo"
read -s

desc "Are you sure?"
read -s

run "kubectl delete -f resources/cross-cluster-traffic-policy.yaml --context $CLUSTER_1"
run "kubectl delete vs reviews -n default --context $CLUSTER_1"
desc "Wait a few moments and check the VSs are deleted"
read -s
run "kubectl get virtualservice -A -o yaml"