#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

##############################
# Set up port forwarding
##############################
backtotop
desc "Using this federated mesh, we can do things like control the access policies "
read -s

desc "Let's port-forward the bookinfo demo so we can see its behavior"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl port-forward deployments/productpage-v1 9080 --context $CLUSTER_1" C-m

desc "Go to the browser make sure it works"
read -s


##############################
# Let's enable access policy on the VM
##############################
backtotop
desc "Let's enable access policy on the virtualmesh"
read -s

run "cat resources/virtual-mesh-access.yaml"
run "kubectl apply -f resources/virtual-mesh-access.yaml --context $CLUSTER_1"

desc "We should see we cannot access bookinfo correctly"
read -s

##############################
# Check under the covers Istio
##############################
desc "Let's see what was created under the covers"
run "kubectl get authorizationpolicies -A  --context $CLUSTER_1"
run "kubectl get authorizationpolicies global-access-control -o yaml -n istio-system --context $CLUSTER_1"


##############################
# Start to enable traffic
##############################
backtotop
desc "Now let's enable traffic"
read -s

run "cat resources/enable-productpage-acp.yaml"
run "kubectl apply -f resources/enable-productpage-acp.yaml --context $CLUSTER_1"

desc "Go check to see whether productpage can reach details and reviews"
read -s

desc "Now let's enable reviews-ratings"
run "cat resources/enable-reviews-acp.yaml"
run "kubectl apply -f resources/enable-reviews-acp.yaml --context $CLUSTER_1"