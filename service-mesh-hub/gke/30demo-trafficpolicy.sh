#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

kubectl config use-context $MGMT_CONTEXT

desc "In the previous demos, we federated the meshes and enabled access"

##############################
# Revie Service entries
##############################
backtotop
desc "Now that we've got our mesh federated, let's take a look at the networking"
read -s
desc "Show some of the underlying Istio objects automatically created"
run "kubectl get serviceentry -A --context $CLUSTER_1"
run "kubectl get serviceentry -A --context $CLUSTER_2"
run "kubectl get serviceentry reviews.default.svc.cluster-2.global -o yaml -n istio-system  --context $CLUSTER_1"

run "kubectl get svc istio-ingressgateway -n istio-system  --context $CLUSTER_2"

desc "We've also created a destination rule to set ISTIO_MUTUAL tls"

backtotop
desc "Now let's control the traffic for services running on cluster 1"
read -s

run "cat resources/reviews-tp-v1.yaml"
run "kubectl apply -f resources/reviews-tp-v1.yaml"

desc "Go check the routing in the browser"
read -s

desc "Let's introduce v2"
run "cat resources/reviews-tp-v1-v2.yaml"
run "kubectl apply -f resources/reviews-tp-v1-v2.yaml"

desc "When we introduce v3, we will need to route across clusters"


backtotop
desc "Now let's route reviews traffic to balance between cluster 1 and 2"
read -s

run "cat resources/reviews-tp-c1-c2.yaml"

desc "Let's apply it and see what resources it creates"
run "kubectl apply -f resources/reviews-tp-c1-c2.yaml"
run "kubectl get virtualservice -A --context $CLUSTER_1"
run "kubectl get virtualservice -A -o yaml --context $CLUSTER_1"

desc "Damn! We didn't enable traffic for cluster 2 for reviews!"
run "kubectl apply -f resources/enable-reviews-cluster-2.yaml"

backtotop
desc "It's possible we end up with traffic rules cross cluster that make it difficult to understand"
read -s
desc "We can use meshctl describe to get the rules for a particular service"
run "meshctl describe --help"

backtotop
desc "Let's see what rules are on the reviews service"
run "meshctl describe traffictarget reviews-default-cluster-1"